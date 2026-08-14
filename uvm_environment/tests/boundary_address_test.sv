`ifndef BOUNDARY_ADDRESS_TEST_SV
`define BOUNDARY_ADDRESS_TEST_SV

class boundary_address_test extends base_test;
    `uvm_component_utils(boundary_address_test)

    boundary_address_seq seq;

    function new(string name="boundary_address_test", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cfg.cov_mode = BOUNDARY_ADDRESS;
        cfg.back_to_back_mode = 0;
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq = boundary_address_seq::type_id::create("seq");
        seq.start(env.ahb_agnt.seqr);
        #500ns;
        phase.drop_objection(this);
    endtask
endclass

`endif
