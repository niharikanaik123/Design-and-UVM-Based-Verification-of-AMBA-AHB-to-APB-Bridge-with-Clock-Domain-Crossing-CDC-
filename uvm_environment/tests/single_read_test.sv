`ifndef SINGLE_READ_TEST_SV
`define SINGLE_READ_TEST_SV

class single_read_test extends base_test;

    // Factory Registration
    `uvm_component_utils(single_read_test)

    
    function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    cfg.cov_mode = SINGLE_READ;


    `uvm_info(get_type_name(),
              "Coverage Mode = SINGLE_READ",
              UVM_LOW)
    endfunction
    
    // Sequence Handle
    single_read_seq seq;

    // Constructor
    function new(string name = "single_read_test",uvm_component parent = null);

        super.new(name,parent);

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "Starting Single Read Test",
                  UVM_LOW)

        // Create Sequence
        seq = single_read_seq::type_id::create("seq");

        // Start Sequence
        seq.start(env.ahb_agnt.seqr);

        `uvm_info(get_type_name(),
                  "Single Read Test Completed",
                  UVM_LOW)

        phase.drop_objection(this);

    endtask

endclass

`endif

