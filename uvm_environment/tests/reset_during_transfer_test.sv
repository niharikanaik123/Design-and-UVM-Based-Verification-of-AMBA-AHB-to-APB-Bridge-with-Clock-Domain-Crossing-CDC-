`ifndef RESET_DURING_TRANSFER_TEST_SV
`define RESET_DURING_TRANSFER_TEST_SV

class reset_during_transfer_test extends base_test;

  `uvm_component_utils(reset_during_transfer_test)

  reset_during_transfer_seq seq;

  function new(string name="reset_during_transfer_test",uvm_component parent=null);

    super.new(name,parent);

  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    cfg.cov_mode = RESET_DURING_TRANSFER;
    cfg.back_to_back_mode = 0;

  endfunction


  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq = reset_during_transfer_seq::type_id::create("seq");

    seq.start(env.ahb_agnt.seqr);

    #1500ns;

    phase.drop_objection(this);

  endtask

endclass

`endif