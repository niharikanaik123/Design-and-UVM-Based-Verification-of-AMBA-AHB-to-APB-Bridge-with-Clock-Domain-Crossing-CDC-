`ifndef WRITE_READ_SEQ_SV
`define WRITE_READ_SEQ_SV

class write_read_seq extends base_sequence;

    // Factory Registration
    `uvm_object_utils(write_read_seq)

    // Constructor
    function new(string name = "write_read_seq");
        super.new(name);
    endfunction

    // Sequence Body
    virtual task body();

        bit [31:0] addr[9];
        bit [31:0] data[9];
        bit [2:0]  size;
        bit [1:0]  trans;

        super.body();

        // Address Map
        addr[0] = 32'h00000020;
        addr[1] = 32'h00000080;
        addr[2] = 32'h000000F0;

        addr[3] = 32'h00000110;
        addr[4] = 32'h00000180;
        addr[5] = 32'h000001F0;

        addr[6] = 32'h00000210;
        addr[7] = 32'h00000280;
        addr[8] = 32'h000003F0;

        // WRITE -> READ
        foreach(addr[i]) begin

            // Transfer Size
            case(i%3)
                0 : size = 3'b000;   // BYTE
                1 : size = 3'b001;   // HALF
                2 : size = 3'b010;   // WORD
            endcase

            // Transfer Type
            
            if(i%2)
                trans = 2'b11;       // SEQ
            else
                trans = 2'b10;       // NONSEQ

            data[i] = $urandom;

            // WRITE
            req = ahb_transaction::type_id::create($sformatf("wr_%0d",i));

            start_item(req);

            assert(req.randomize() with {

                hwrite == 1'b1;
                haddr  == local::addr[i];
                hwdata == local::data[i];
                hsize  == local::size;
                htrans == local::trans;

            });

            finish_item(req);

            `uvm_info(get_type_name(),$sformatf("WRITE[%0d] ADDR=%08h DATA=%08h SIZE=%0d HTRANS=%b",i,req.haddr,req.hwdata,req.hsize,req.htrans),UVM_MEDIUM)

            // READ
            req = ahb_transaction::type_id::create($sformatf("rd_%0d",i));

            start_item(req);

            assert(req.randomize() with {

                hwrite == 1'b0;
                haddr  == local::addr[i];
                hsize  == local::size;
                htrans == local::trans;

            });

            finish_item(req);

            `uvm_info(get_type_name(),$sformatf("READ[%0d] ADDR=%08h SIZE=%0d HTRANS=%b",i,req.haddr,req.hsize,req.htrans),UVM_MEDIUM)

        end

        `uvm_info(get_type_name(),
                  "WRITE-READ Sequence Completed",
                  UVM_LOW)

    endtask

endclass

`endif