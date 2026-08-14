`ifndef WRITE_READ_TEST_SV
`define WRITE_READ_TEST_SV

class write_read_test extends base_test;

    // Factory Registration
    `uvm_component_utils(write_read_test)

    
    function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    cfg.cov_mode = WRITE_READ;

    `uvm_info(get_type_name(),
              "Coverage Mode = WRITE_READ",
              UVM_LOW)

    endfunction
    // Sequence Handle
    write_read_seq seq;

    // Constructor
    function new(string name = "write_read_test",
                 uvm_component parent = null);

        super.new(name,parent);

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "Starting Write-Read Test",
                  UVM_LOW)

        // Create Sequence
        seq = write_read_seq::type_id::create("seq");

        // Start Sequence
        seq.start(env.ahb_agnt.seqr);

        `uvm_info(get_type_name(),"Write-Read Test Completed",UVM_LOW)

        phase.drop_objection(this);

    endtask

endclass

`endif
