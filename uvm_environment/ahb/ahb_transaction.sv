`ifndef AHB_TRANSACTION_SV
`define AHB_TRANSACTION_SV

class ahb_transaction extends uvm_sequence_item;

    // AHB Inputs
   
    rand bit          hwrite;
    rand bit [31:0]   haddr;
    rand bit [31:0]   hwdata;
    rand bit [2:0]    hsize;
    rand bit [1:0]    htrans;

    // AHB Outputs
   
    logic [31:0]       hrdata;
    logic[1:0]         hresp;

    // Constraints
 
    constraint valid_htrans {
        htrans inside {2'b10,2'b11};      // NONSEQ or SEQ
    }

    constraint valid_hsize {
        hsize inside {3'b000,3'b001,3'b010};
    }

    constraint word_align {
        haddr[1:0] == 2'b00;
    }

    // Factory Registration
  
    `uvm_object_utils_begin(ahb_transaction)

        `uvm_field_int(hwrite , UVM_ALL_ON)
        `uvm_field_int(haddr  , UVM_ALL_ON)
        `uvm_field_int(hwdata , UVM_ALL_ON)
        `uvm_field_int(hsize  , UVM_ALL_ON)
        `uvm_field_int(htrans , UVM_ALL_ON)
        `uvm_field_int(hrdata , UVM_ALL_ON)
        `uvm_field_int(hresp  , UVM_ALL_ON)

    `uvm_object_utils_end

    // Constructor

    function new(string name="ahb_transaction");
        super.new(name);
    endfunction

endclass

`endif
