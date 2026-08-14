`ifndef DATA_PATTERN_TEST_SV
`define DATA_PATTERN_TEST_SV

class data_pattern_test extends base_test;
    `uvm_component_utils(data_pattern_test)

    data_pattern_seq seq;

    function new(string name="data_pattern_test", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cfg.cov_mode = DATA_PATTERN;
        cfg.back_to_back_mode = 0;
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq = data_pattern_seq::type_id::create("seq");
        seq.start(env.ahb_agnt.seqr);
        #500ns;
        phase.drop_objection(this);
    endtask
endclass

`endif
