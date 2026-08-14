`ifndef AHB_MONITOR_SV
`define AHB_MONITOR_SV

class ahb_monitor extends uvm_monitor;

    // Factory Registration

    `uvm_component_utils(ahb_monitor)

    // Configuration

    bridge_config cfg;

    // Virtual Interface

    virtual ahb_if vif;

    // Analysis Port
    
    uvm_analysis_port #(ahb_transaction) ap;

    // Constructor
    function new(string name = "ahb_monitor",uvm_component parent = null);
        super.new(name, parent);

        ap = new("ap", this);

    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(bridge_config)::get(
                this,
                "",
                "bridge_cfg",
                cfg)) begin

            `uvm_fatal(get_type_name(),
                       "bridge_config not found")
        end

        vif = cfg.ahb_vif;

        if (vif == null) begin

            `uvm_fatal(get_type_name(),
                       "AHB virtual interface is NULL")

        end

    endfunction

    // Run Phase

    task run_phase(uvm_phase phase);

        ahb_transaction tr;

        forever begin

            @(vif.mon_cb);

            // Detect valid AHB transfer
            if (vif.mon_cb.HSEL &&
                vif.mon_cb.HTRANS[1]) begin

                tr = ahb_transaction::type_id::create( "tr", this);

                // Capture address phase
            
                tr.haddr  = vif.mon_cb.HADDR;
                tr.hwrite = vif.mon_cb.HWRITE;
                tr.hsize  = vif.mon_cb.HSIZE;
                tr.htrans = vif.mon_cb.HTRANS;

                // WRITE
        
                if (tr.hwrite) begin

                    @(vif.mon_cb);

                    tr.hwdata = vif.mon_cb.HWDATA;

                end

                // Wait for transfer completion
            
                while (!vif.mon_cb.HREADYOUT) begin

                    @(vif.mon_cb);

                end

                // Capture response
            
                tr.hresp = vif.mon_cb.HRESP;

                // READ
            
                if (!tr.hwrite) begin

                    tr.hrdata = vif.mon_cb.HRDATA;

                end

                // Send transaction to subscribers
            
                ap.write(tr);

                // Debug message
            
                `uvm_info(
                    get_type_name(),

                    $sformatf(
                    "AHB MONITOR -> %s ADDR=%08h DATA=%08h HSIZE=%0d HTRANS=%02b HRESP=%0b",
                    tr.hwrite ? "WRITE" : "READ",
                    tr.haddr,
                    tr.hwrite ? tr.hwdata : tr.hrdata,
                    tr.hsize,
                    tr.htrans,
                    tr.hresp),

                    UVM_LOW)

            end

        end

    endtask

endclass

`endif