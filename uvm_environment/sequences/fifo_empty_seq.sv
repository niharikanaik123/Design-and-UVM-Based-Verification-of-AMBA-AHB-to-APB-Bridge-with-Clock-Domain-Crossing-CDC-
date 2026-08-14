`ifndef FIFO_EMPTY_SEQ_SV
`define FIFO_EMPTY_SEQ_SV

class fifo_empty_seq extends base_sequence;

    // Factory Registration
    `uvm_object_utils(fifo_empty_seq)

    // Constructor
    function new(string name="fifo_empty_seq");
        super.new(name);
    endfunction

    // Sequence Body
    virtual task body();

        bit [31:0] addr[12];
        bit [2:0]  size;
        bit [1:0]  trans;

        super.body();

        `uvm_info(get_type_name(),
                  "========== FIFO EMPTY TEST STARTED ==========",
                  UVM_LOW)

        // Address Map
        addr[0]  = 32'h00000020;
        addr[1]  = 32'h00000080;
        addr[2]  = 32'h000000F0;

        addr[3]  = 32'h00000110;
        addr[4]  = 32'h00000180;
        addr[5]  = 32'h000001F0;

        addr[6]  = 32'h00000210;
        addr[7]  = 32'h00000280;
        addr[8]  = 32'h000003F0;

        addr[9]  = 32'h00000040;
        addr[10] = 32'h00000140;
        addr[11] = 32'h00000240;

        // WRITE PHASE
        foreach(addr[i]) begin

            case(i%3)
                0 : size = 3'b000;      // BYTE
                1 : size = 3'b001;      // HALF
                2 : size = 3'b010;      // WORD
            endcase

            if(i%2)
                trans = 2'b11;          // SEQ
            else
                trans = 2'b10;          // NONSEQ

            req = ahb_transaction::type_id::create($sformatf("wr_%0d",i));

            start_item(req);

            assert(req.randomize() with {

                hwrite == 1'b1;
                haddr  == local::addr[i];
                hsize  == local::size;
                htrans == local::trans;

            });

            finish_item(req);

            `uvm_info(get_type_name(),
                      $sformatf("WRITE[%0d] ADDR=%08h DATA=%08h",
                                i,
                                req.haddr,
                                req.hwdata),
                      UVM_MEDIUM)

        end

        // READ PHASE
        foreach(addr[i]) begin

            case(i%3)
                0 : size = 3'b000;
                1 : size = 3'b001;
                2 : size = 3'b010;
            endcase

            if(i%2)
                trans = 2'b11;
            else
                trans = 2'b10;

            req = ahb_transaction::type_id::create($sformatf("rd_%0d",i));

            start_item(req);

            assert(req.randomize() with {

                hwrite == 1'b0;
                haddr  == local::addr[i];
                hsize  == local::size;
                htrans == local::trans;

            });

            finish_item(req);

            `uvm_info(get_type_name(),
                      $sformatf("READ[%0d] ADDR=%08h",
                                i,
                                req.haddr),
                      UVM_MEDIUM)

        end

        // EXTRA READ AFTER FIFO EMPTY
        req = ahb_transaction::type_id::create("empty_read");

        start_item(req);

        assert(req.randomize() with {

            hwrite == 1'b0;
            htrans == 2'b10;
            hsize  == 3'b010;
            haddr  == 32'h00000020;

        });

        finish_item(req);

        `uvm_info(get_type_name(),
                  "EXTRA READ AFTER FIFO EMPTY",
                  UVM_MEDIUM)

        `uvm_info(get_type_name(),
                  "========== FIFO EMPTY TEST COMPLETED ==========",
                  UVM_LOW)

    endtask

endclass

`endif