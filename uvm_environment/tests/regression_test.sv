`ifndef REGRESSION_TEST_SV
`define REGRESSION_TEST_SV

class regression_test extends base_test;

    `uvm_component_utils(regression_test)

    regression_seq seq;

    function new(string name="regression_test",
                 uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        cfg.cov_mode = REGRESSION;

    endfunction

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        seq = regression_seq::type_id::create("seq");

        seq.start(env.ahb_agnt.seqr);

        #1000ns;

        phase.drop_objection(this);

    endtask

endclass

`endif
