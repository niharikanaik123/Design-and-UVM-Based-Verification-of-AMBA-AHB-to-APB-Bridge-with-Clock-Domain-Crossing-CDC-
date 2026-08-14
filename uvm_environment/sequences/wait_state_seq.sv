`ifndef WAIT_STATE_SEQ_SV
`define WAIT_STATE_SEQ_SV

class wait_state_seq extends base_sequence;

    // Factory Registration
    `uvm_object_utils(wait_state_seq)

    // Constructor
    function new(string name="wait_state_seq");
        super.new(name);
    endfunction

    // Body
    virtual task body();

        bit [31:0] addr[9];
        bit [31:0] data[9];
        bit [2:0]  size;
        bit [1:0]  trans;

        super.body();

        // Address Map
        addr[0]=32'h20;
        addr[1]=32'h80;
        addr[2]=32'hF0;

        addr[3]=32'h110;
        addr[4]=32'h180;
        addr[5]=32'h1F0;

        addr[6]=32'h210;
        addr[7]=32'h280;
        addr[8]=32'h3F0;

        // WRITE -> READ
        foreach(addr[i]) begin

            // HSIZE
            case(i%3)
                0 : size = 3'b000;     // BYTE
                1 : size = 3'b001;     // HALF
                2 : size = 3'b010;     // WORD
            endcase

            // HTRANS
            if(i%2)
                trans = 2'b11;         // SEQ
            else
                trans = 2'b10;         // NONSEQ

            data[i] = $urandom;

            // WRITE
            req = ahb_transaction::type_id::create($sformatf("wr_%0d",i));

            start_item(req);

            assert(req.randomize() with {

                hwrite == 1;
                haddr  == local::addr[i];
                hwdata == local::data[i];
                hsize  == local::size;
                htrans == local::trans;

            });

            finish_item(req);

            // READ
            req = ahb_transaction::type_id::create($sformatf("rd_%0d",i));

            start_item(req);

            assert(req.randomize() with {

                hwrite == 0;
                haddr  == local::addr[i];
                hsize  == local::size;
                htrans == local::trans;

            });

            finish_item(req);

        end

        `uvm_info(get_type_name(),"WAIT STATE SEQUENCE COMPLETED",UVM_LOW)

    endtask

endclass

`endif