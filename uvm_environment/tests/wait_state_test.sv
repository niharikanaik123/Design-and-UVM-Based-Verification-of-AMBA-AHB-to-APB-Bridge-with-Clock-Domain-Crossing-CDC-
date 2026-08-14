`ifndef WAIT_STATE_TEST_SV
`define WAIT_STATE_TEST_SV

class wait_state_test extends base_test;

    // Factory Registration
    `uvm_component_utils(wait_state_test)

    
    function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    cfg.cov_mode = WAIT_STATE;

    `uvm_info(get_type_name(),
              "Coverage Mode = WAIT_STATE",
              UVM_LOW)

    endfunction

    // Sequence Handle
    wait_state_seq seq;

    // Constructor
    function new(string name = "wait_state_test",uvm_component parent = null);

        super.new(name,parent);

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        `uvm_info(get_type_name(),"Starting Wait State Test",UVM_LOW)

        // Create Sequence
        seq = wait_state_seq::type_id::create("seq");

        // Start Sequence
        seq.start(env.ahb_agnt.seqr);

        `uvm_info(get_type_name(),
                  "Wait State Test Completed",
                  UVM_LOW)

        phase.drop_objection(this);

    endtask

endclass

`endif
