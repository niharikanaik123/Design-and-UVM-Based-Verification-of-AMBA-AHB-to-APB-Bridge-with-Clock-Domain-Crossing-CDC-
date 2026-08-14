`ifndef MULTIPLE_READ_SEQ_SV
`define MULTIPLE_READ_SEQ_SV

class multiple_read_seq extends base_sequence;

    // Factory Registration
    `uvm_object_utils(multiple_read_seq)

    // Constructor
    function new(string name="multiple_read_seq");
        super.new(name);
    endfunction

    // Sequence Body
    virtual task body();

    bit [31:0] addr[12];
    bit [31:0] data[12];
    bit [2:0]  size;

    super.body();

    foreach(addr[i]) begin

             case(i)

              0,3,6,9   : size = 3'b000; // BYTE
              1,4,7,10  : size = 3'b001; // HALF
              2,5,8,11  : size = 3'b010; // WORD

              endcase


        data[i]=$urandom;

        //---------------- WRITE ----------------

        req = ahb_transaction::type_id::create($sformatf("wr_%0d",i));

        start_item(req);

       assert(req.randomize() with {
              hwrite == 1;
              htrans == 2'b10;
              hsize  == local::size;
              haddr  == local::addr[i];
              hwdata == local::data[i];
          });

        finish_item(req);

        //---------------- READ ----------------

        req = ahb_transaction::type_id::create($sformatf("rd_%0d",i));

        start_item(req);

        assert(req.randomize() with {
                hwrite == 0;
                htrans == 2'b10;
                hsize  == local::size;
                haddr  == local::addr[i];
            });

        finish_item(req);

    end

endtask

endclass

`endif