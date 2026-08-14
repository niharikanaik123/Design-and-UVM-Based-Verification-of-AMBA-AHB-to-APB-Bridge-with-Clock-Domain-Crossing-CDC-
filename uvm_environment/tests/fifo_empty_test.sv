`ifndef FIFO_EMPTY_TEST_SV
`define FIFO_EMPTY_TEST_SV

class fifo_empty_test extends base_test;

    // Factory Registration
    `uvm_component_utils(fifo_empty_test)

    
    function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    cfg.cov_mode = FIFO_EMPTY;

    `uvm_info(get_type_name(),
              "Coverage Mode = FIFO_EMPTY",
              UVM_LOW)

    endfunction

    // Sequence Handle
    fifo_empty_seq seq;

    // Constructor
    function new(string name = "fifo_empty_test",
                 uvm_component parent = null);

        super.new(name,parent);

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "Starting FIFO Empty Test",
                  UVM_LOW)

        // Create Sequence
        seq = fifo_empty_seq::type_id::create("seq");

        // Start Sequence
        seq.start(env.ahb_agnt.seqr);

        `uvm_info(get_type_name(),
                  "FIFO Empty Test Completed",
                  UVM_LOW)

        phase.drop_objection(this);

    endtask

endclass

`endif
