`ifndef MULTIPLE_READ_TEST_SV
`define MULTIPLE_READ_TEST_SV

class multiple_read_test extends base_test;

    // Factory Registration
    `uvm_component_utils(multiple_read_test)

    
    function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    cfg.cov_mode = MULTIPLE_READ;

    `uvm_info(get_type_name(),
              "Coverage Mode = MULTIPLE_READ",
              UVM_LOW)
    endfunction
    
    // Sequence Handle
    multiple_read_seq seq;

    // Constructor
    function new(string name = "multiple_read_test",
                 uvm_component parent = null);

        super.new(name,parent);
        
    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "Starting Multiple Read Test",
                  UVM_LOW)

        // Create Sequence
        seq = multiple_read_seq::type_id::create("seq");

        // Start Sequence
        seq.start(env.ahb_agnt.seqr);

        `uvm_info(get_type_name(),
                  "Multiple Read Test Completed",
                  UVM_LOW)

        phase.drop_objection(this);

    endtask

endclass

`endif
