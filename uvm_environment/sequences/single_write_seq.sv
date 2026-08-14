`ifndef SINGLE_WRITE_SEQ_SV
`define SINGLE_WRITE_SEQ_SV

class single_write_seq extends base_sequence;

    
    // Factory Registration
    `uvm_object_utils(single_write_seq)

    // Constructor
    function new(string name = "single_write_seq");
        super.new(name);
    endfunction

    // Sequence Body
    virtual task body();

        super.body();

        req = ahb_transaction::type_id::create("req");

        start_item(req);

        if(!req.randomize() with {

            hwrite == 1'b1;
            htrans == 2'b10;      // NONSEQ
            hsize  == 3'b010;     // WORD

        })
            `uvm_error(get_type_name(),"Randomization Failed")

        finish_item(req);

        `uvm_info(get_type_name(),
                  $sformatf("Single WRITE : ADDR = %0h DATA = %0h",req.haddr,req.hwdata),UVM_LOW)

    endtask

endclass

`endif