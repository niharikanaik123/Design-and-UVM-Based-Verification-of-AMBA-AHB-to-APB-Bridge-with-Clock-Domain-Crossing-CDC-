`ifndef BASE_SEQUENCE_SV
`define BASE_SEQUENCE_SV

class base_sequence extends uvm_sequence #(ahb_transaction);

    // Factory Registration
    `uvm_object_utils(base_sequence)

    // Transaction Handle
    ahb_transaction req;

    // Constructor
    function new(string name = "base_sequence");
        super.new(name);
    endfunction

    // Body
    virtual task body();
s
        `uvm_info(get_type_name(),
                  "Base Sequence Started",
                  UVM_LOW)

    endtask

endclass

`endif