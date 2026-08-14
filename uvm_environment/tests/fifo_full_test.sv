`ifndef FIFO_FULL_TEST_SV
`define FIFO_FULL_TEST_SV

class fifo_full_test extends base_test;

    // Factory Registration
    `uvm_component_utils(fifo_full_test)

    
    function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    cfg.cov_mode = FIFO_FULL;

    `uvm_info(get_type_name(),"Coverage Mode = FIFO_FULL",UVM_LOW)

    endfunction

    // Sequence Handle
    fifo_full_seq seq;

    // Constructor
    function new(string name = "fifo_full_test",
                 uvm_component parent = null);

        super.new(name,parent);

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "Starting FIFO Full Test",
                  UVM_LOW)

         `uvm_info(get_type_name(),
          "Before seq.start()",
          UVM_NONE)         

        // Create Sequence
        seq = fifo_full_seq::type_id::create("seq");

        // Start Sequence
        seq.start(env.ahb_agnt.seqr);

        #2us

        `uvm_info(get_type_name(),
          "After seq.start()",
          UVM_NONE)

        `uvm_info(get_type_name(),
                  "FIFO Full Test Completed",
                  UVM_LOW)

        phase.drop_objection(this);

        `uvm_info(get_type_name(),
          "After drop_objection()",
          UVM_NONE)

        `uvm_info(get_type_name(),
          "BODY FINISHED",
          UVM_NONE)

    endtask

endclass

`endif
