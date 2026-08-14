`ifndef RESET_SEQUENCE_SV
`define RESET_SEQUENCE_SV

class reset_sequence extends base_sequence;

    // Factory Registration
    `uvm_object_utils(reset_sequence)

    // Constructor
    function new(string name = "reset_sequence");
        super.new(name);
    endfunction

    // Body
    virtual task body();

        `uvm_info(get_type_name(),
                  "Power-On Reset is generated from tb_top",
                  UVM_LOW)
        #1;

    endtask

endclass

`endif