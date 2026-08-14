`ifndef SINGLE_READ_SEQ_SV
`define SINGLE_READ_SEQ_SV

class single_read_seq extends base_sequence;

    // Factory Registration
    `uvm_object_utils(single_read_seq)

    // Constructor
    function new(string name = "single_read_seq");
        super.new(name);
    endfunction

    // Sequence Body
    virtual task body();

        bit [31:0] addr;
        bit [31:0] data;

        super.body();

        // Generate common address and data
        addr = $urandom;
        data = $urandom;

        // WRITE Transaction
        req = ahb_transaction::type_id::create("write_req");

        start_item(req);

        if(!req.randomize() with {
            hwrite == 1'b1;
            htrans == 2'b10;      // NONSEQ
            hsize  == 3'b010;     // WORD
            haddr  == local::addr;
            hwdata == local::data;
        })
            `uvm_error(get_type_name(),"WRITE Randomization Failed")

        finish_item(req);

        `uvm_info(get_type_name(),
                  $sformatf("WRITE : ADDR=%08h DATA=%08h",
                            addr,data),
                  UVM_LOW)

        #20ns;

        // READ Transaction
        req = ahb_transaction::type_id::create("read_req");

        start_item(req);

        if(!req.randomize() with {
            hwrite == 1'b0;
            htrans == 2'b10;      // NONSEQ
            hsize  == 3'b010;     // WORD
            haddr  == local::addr;
        })
            `uvm_error(get_type_name(),"READ Randomization Failed")

        finish_item(req);

        `uvm_info(get_type_name(),
                  $sformatf("READ  : ADDR=%08h",addr),UVM_LOW)

    endtask

endclass

`endif