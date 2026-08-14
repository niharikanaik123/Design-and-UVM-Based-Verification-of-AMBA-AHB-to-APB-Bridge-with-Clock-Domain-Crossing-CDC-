`ifndef RESET_TEST_SV
`define RESET_TEST_SV

class reset_test extends base_test;

    // Factory Registration
    `uvm_component_utils(reset_test)

    // Constructor
    function new(string name="reset_test",
                 uvm_component parent=null);

        super.new(name,parent);

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        `uvm_info(get_type_name(),"Running Power-On Reset Test",UVM_LOW)

        #100ns;

        phase.drop_objection(this);

    endtask

endclass

`endif
