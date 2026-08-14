`ifndef BACK_TO_BACK_TEST_SV
`define BACK_TO_BACK_TEST_SV

class back_to_back_test extends base_test;

    `uvm_component_utils(back_to_back_test)

    back_to_back_seq seq;

    
    // Constructor
    function new(string name = "back_to_back_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        cfg.cov_mode           = BACK_TO_BACK;
        cfg.back_to_back_mode  = 1;
    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        seq = back_to_back_seq::type_id::create("seq");
	seq.start(env.ahb_agnt.seqr);
	// Wait for APB side to complete
    #500ns;

        if(seq == null)
            `uvm_fatal("SEQ", "Failed to create back_to_back_seq")

        seq.start(env.ahb_agnt.seqr);

        cfg.back_to_back_mode = 0;

        phase.drop_objection(this);

    endtask

endclass

`endif