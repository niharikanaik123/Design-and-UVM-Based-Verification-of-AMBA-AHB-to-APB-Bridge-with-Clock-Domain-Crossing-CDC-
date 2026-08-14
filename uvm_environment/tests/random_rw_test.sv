`ifndef RANDOM_RW_TEST_SV
`define RANDOM_RW_TEST_SV

class random_rw_test extends base_test;

    `uvm_component_utils(random_rw_test)

    random_rw_seq seq;

    function new(string name = "random_rw_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Select coverage mode
        cfg.cov_mode = RANDOM_RW;

        cfg.back_to_back_mode = 0;

    endfunction

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        seq = random_rw_seq::type_id::create("seq");

        if (!seq.randomize()) begin
            `uvm_fatal(get_type_name(),
                       "Sequence randomization failed")
        end

        `uvm_info(get_type_name(),
                  "Starting random_rw_seq",
                  UVM_LOW)

        seq.start(env.ahb_agnt.seqr);

        #500ns;

        phase.drop_objection(this);

    endtask

endclass

`endif