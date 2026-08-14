`ifndef MULTIPLE_WRITE_TEST_SV
`define MULTIPLE_WRITE_TEST_SV

class multiple_write_test extends base_test;

    // Factory Registration
    `uvm_component_utils(multiple_write_test)

    
    function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    cfg.cov_mode = MULTIPLE_WRITE;


    `uvm_info(get_type_name(),
              "Coverage Mode = MULTIPLE_WRITE",
              UVM_LOW)
    endfunction
    
    // Sequence Handle
    multiple_write_seq seq;

    // Constructor
    function new(string name = "multiple_write_test",
                 uvm_component parent = null);

        super.new(name,parent);

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "Starting Multiple Write Test",
                  UVM_LOW)

        // Create Sequence
        seq = multiple_write_seq::type_id::create("seq");

        // Start Sequence
        seq.start(env.ahb_agnt.seqr);

         #500ns;

        `uvm_info(get_type_name(),
                  "Multiple Write Test Completed",
                  UVM_LOW)

        phase.drop_objection(this);

    endtask

endclass

`endif

