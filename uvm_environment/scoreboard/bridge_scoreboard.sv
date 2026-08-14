
`ifndef BRIDGE_SCOREBOARD_SV
`define BRIDGE_SCOREBOARD_SV

`uvm_analysis_imp_decl(_ahb)
`uvm_analysis_imp_decl(_apb)

class bridge_scoreboard extends uvm_scoreboard;

// Factory Registration

`uvm_component_utils(bridge_scoreboard)

// Analysis Ports

uvm_analysis_imp_ahb #(ahb_transaction, bridge_scoreboard) ahb_imp;
uvm_analysis_imp_apb #(apb_transaction, bridge_scoreboard) apb_imp;

// Bridge Configuration

bridge_config cfg;

// Expected Write Queue

typedef struct {
    logic [31:0] addr;
    logic [31:0] data;
} exp_write_t;

exp_write_t exp_write_q[$];

// Reference Memory

logic [31:0] ref_mem [0:255];
bit          mem_valid [0:255];

// Statistics

int total_ahb_write;
int total_ahb_read;

int total_apb_write;
int total_apb_read;

int pass_count;
int fail_count;

int write_id;
int read_id;

int expected_errors;
int observed_errors;

// Constructor


function new(string name="bridge_scoreboard",uvm_component parent=null);
    super.new(name,parent);

    ahb_imp = new("ahb_imp",this);
    apb_imp = new("apb_imp",this);

endfunction

// Build Phase


function void build_phase(uvm_phase phase);

    super.build_phase(phase);
  
    // Get bridge configuration
 
    if(!uvm_config_db#(bridge_config)::get(
        this,
        "",
        "bridge_cfg",
        cfg))
    begin

        `uvm_fatal(
            get_type_name(),
            "bridge_config not found")

    end

    // Initialize Reference Memory

    foreach(ref_mem[i]) begin

        ref_mem[i]   = '0;
        mem_valid[i] = 1'b0;

    end

    // Initialize Statistics
 
    total_ahb_write = 0;
    total_ahb_read  = 0;
    total_apb_write = 0;
    total_apb_read  = 0;
    pass_count = 0;
    fail_count = 0;
    write_id = 0;
    read_id  = 0;
    expected_errors = 0;
    observed_errors = 0;
    exp_write_q.delete();

endfunction

// AHB Analysis Port

function void write_ahb(ahb_transaction tr);

    int addr;
    exp_write_t exp_tr;

    addr = tr.haddr[9:2];

    // Address Range Check

    if(addr > 255) begin

        fail_count++;

        `uvm_error(
            get_type_name(),
            $sformatf(
            "AHB address outside reference memory : %08h",
            tr.haddr))

        return;

    end

    // WRITE Transaction

    if(tr.hwrite) begin

        total_ahb_write++;
        write_id++;

        // Update Reference Memory

        ref_mem[addr]   = tr.hwdata;
        mem_valid[addr] = 1'b1;

        // Push Expected APB Write
  
        exp_tr.addr = tr.haddr;
        exp_tr.data = tr.hwdata;

        exp_write_q.push_back(exp_tr);

    end

    // READ Transaction

    else begin

        total_ahb_read++;
        read_id++;

        // Address Never Written
     
        if(!mem_valid[addr]) begin

            fail_count++;

            `uvm_warning(
                get_type_name(),
                $sformatf(
                "[AHB READ %0d] ADDR=%08h never written",
                read_id,
                tr.haddr))

            return;

        end

        // Compare Returned Data
   
        if(!$isunknown(tr.hrdata) &&
           tr.hrdata == ref_mem[addr]) begin

            pass_count++;

            `uvm_info(
                get_type_name(),
                $sformatf(
                "[AHB READ %0d PASS] ADDR=%08h DATA=%08h",
                read_id,
                tr.haddr,
                tr.hrdata),
                UVM_LOW);

        end
        else begin

            fail_count++;

            `uvm_error(
                get_type_name(),
                $sformatf(
                "[AHB READ %0d FAIL] ADDR=%08h EXPECTED=%08h ACTUAL=%08h",
                read_id,
                tr.haddr,
                ref_mem[addr],
                tr.hrdata));

        end

    end

endfunction

// APB Analysis Port

function void write_apb(apb_transaction tr);

    int addr;
    exp_write_t exp_tr;

    addr = tr.paddr[9:2];

    // Address Range Check
 
    if(addr > 255) begin

        fail_count++;

        `uvm_error(
            get_type_name(),
            $sformatf(
            "APB address outside reference memory : %08h",
            tr.paddr))

        return;

    end

    // APB ERROR

    if(tr.pslverr) begin

        observed_errors++;

        else begin

            fail_count++;

            `uvm_error(
                get_type_name(),
                $sformatf(
                "[UNEXPECTED APB ERROR] ADDR=%08h",
                tr.paddr))

        end
        return;

    end

    // WRITE

    if(tr.pwrite) begin

        total_apb_write++;

        // Queue Empty

        if(exp_write_q.size() == 0) begin

            fail_count++;

            `uvm_error(
                get_type_name(),
                $sformatf(
                "Unexpected APB WRITE ADDR=%08h DATA=%08h (Queue Empty)",
                tr.paddr,
                tr.pwdata))

            return;

        end

        // Pop Expected Transaction

        exp_tr = exp_write_q.pop_front();

        // Address Check

        if(exp_tr.addr !== tr.paddr) begin

            fail_count++;

            `uvm_error(
                get_type_name(),
                $sformatf(
                "ADDRESS MISMATCH EXP=%08h ACT=%08h",
                exp_tr.addr,
                tr.paddr))

        end

        // Data Check

        else if(exp_tr.data !== tr.pwdata) begin

            fail_count++;

            `uvm_error(
                get_type_name(),
                $sformatf(
                "DATA MISMATCH ADDR=%08h EXP=%08h ACT=%08h",
                tr.paddr,
                exp_tr.data,
                tr.pwdata))

        end

        else begin

            pass_count++;

            `uvm_info(
                get_type_name(),
                $sformatf(
                "[APB WRITE PASS] ADDR=%08h DATA=%08h OUTSTANDING=%0d",
                tr.paddr,
                tr.pwdata,
                exp_write_q.size()),
                UVM_LOW)

        end

    end

    // READ
 
    else begin

        total_apb_read++;

        // Address Never Written

             if(!mem_valid[addr]) begin

            fail_count++;

            `uvm_warning(
                get_type_name(),
                $sformatf(
                "APB READ from unwritten ADDR=%08h",
                tr.paddr))

            return;

        end

        // Compare Read Data
 
        if(!$isunknown(tr.prdata) &&
           tr.prdata == ref_mem[addr]) begin

            pass_count++;

            `uvm_info(
                get_type_name(),
                $sformatf(
                "[APB READ PASS] ADDR=%08h DATA=%08h",
                tr.paddr,
                tr.prdata),
                UVM_LOW);

        end
        else begin

            fail_count++;

            `uvm_error(
                get_type_name(),
                $sformatf(
                "[APB READ FAIL] ADDR=%08h EXPECTED=%08h ACTUAL=%08h",
                tr.paddr,
                ref_mem[addr],
                tr.prdata));

        end

    end

endfunction

// Report Phase

    // Outstanding Queue Warning
   
    if(exp_write_q.size() != 0) begin

        `uvm_warning(
            get_type_name(),
            $sformatf(
            "%0d Writes Still Outstanding",
            exp_write_q.size()))

    end

    // Summary
   
    `uvm_info(
        get_type_name(),
        "==============================================================",
        UVM_NONE)

    `uvm_info(
        get_type_name(),
        "               BRIDGE SCOREBOARD SUMMARY",
        UVM_NONE)

    `uvm_info(
        get_type_name(),
        "==============================================================",
        UVM_NONE)

    `uvm_info(
        get_type_name(),
        $sformatf(
        "AHB Writes              : %0d",
        total_ahb_write),
        UVM_NONE)

    `uvm_info(
        get_type_name(),
        $sformatf(
        "AHB Reads               : %0d",
        total_ahb_read),
        UVM_NONE)

    `uvm_info(
        get_type_name(),
        $sformatf(
        "APB Writes              : %0d",
        total_apb_write),
        UVM_NONE)

    `uvm_info(
        get_type_name(),
        $sformatf(
        "APB Reads               : %0d",
        total_apb_read),
        UVM_NONE)

    `uvm_info(
        get_type_name(),
        "--------------------------------------------------------------",
        UVM_NONE)

    `uvm_info(
        get_type_name(),
        $sformatf(
        "PASS Count              : %0d",
        pass_count),
        UVM_NONE)

    `uvm_info(
        get_type_name(),
        $sformatf(
        "FAIL Count              : %0d",
        fail_count),
        UVM_NONE)

    `uvm_info(
        get_type_name(),
        $sformatf(
        "Outstanding Writes      : %0d",
        exp_write_q.size()),
        UVM_NONE)

    `uvm_info(
        get_type_name(),
        $sformatf(
        "Expected Errors         : %0d",
        expected_errors),
        UVM_NONE)

    `uvm_info(
        get_type_name(),
        $sformatf(
        "Observed Errors         : %0d",
        observed_errors),
        UVM_NONE)

    `uvm_info(
        get_type_name(),
        "--------------------------------------------------------------",
        UVM_NONE)


    // Overall Result

    if((fail_count == 0) &&
       (exp_write_q.size() == 0)) begin

        `uvm_info(
            get_type_name(),
            "******************* TEST RESULT : PASS *******************",
            UVM_NONE)
    end

    else begin

        `uvm_error(
            get_type_name(),
            $sformatf(
            "******************* TEST RESULT : FAIL ******************* Outstanding=%0d Failures=%0d",
            exp_write_q.size(),
            fail_count))

    end


    `uvm_info(
        get_type_name(),
        "==============================================================",
        UVM_NONE)

endfunction

endclass

`endif
