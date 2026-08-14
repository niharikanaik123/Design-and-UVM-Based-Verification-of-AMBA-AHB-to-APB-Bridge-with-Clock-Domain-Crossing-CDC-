`ifndef CLOCK_RATIO_TEST_SV
`define CLOCK_RATIO_TEST_SV

class clock_ratio_test extends base_test;

    // Factory Registration
    `uvm_component_utils(clock_ratio_test)

    
    function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    cfg.cov_mode = CLOCK_RATIO;

    `uvm_info(get_type_name(),
              "Coverage Mode = CLOCK_RATIO",
              UVM_LOW)

    endfunction

    // Sequence Handle
    clock_ratio_seq seq;

    // Constructor
    function new(string name = "clock_ratio_test",
                 uvm_component parent = null);

        super.new(name,parent);

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "Starting Clock Ratio Test",
                  UVM_LOW)

        // Create Sequence
        seq = clock_ratio_seq::type_id::create("seq");

        // Start Sequence
        seq.start(env.ahb_agnt.seqr);

        `uvm_info(get_type_name(),
                  "Clock Ratio Test Completed",
                  UVM_LOW)

        phase.drop_objection(this);

    endtask

endclass

`endif

