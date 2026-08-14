`ifndef APB_TRANSACTION_SV
`define APB_TRANSACTION_SV

class apb_transaction extends uvm_sequence_item;

    // APB Signals

    logic                 pwrite;
    logic [31:0]          paddr;
    logic [31:0]          pwdata;

    logic [31:0]          prdata;
    logic                 pslverr;

    // Factory Registration

    `uvm_object_utils_begin(apb_transaction)

        `uvm_field_int(pwrite  , UVM_ALL_ON)
        `uvm_field_int(paddr   , UVM_ALL_ON)
        `uvm_field_int(pwdata  , UVM_ALL_ON)
        `uvm_field_int(prdata  , UVM_ALL_ON)
        `uvm_field_int(pslverr , UVM_ALL_ON)

    `uvm_object_utils_end

    // Constructor

    function new(string name="apb_transaction");
        super.new(name);
    endfunction

endclass

`endif
