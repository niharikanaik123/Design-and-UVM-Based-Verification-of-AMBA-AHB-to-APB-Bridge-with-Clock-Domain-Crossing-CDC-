`ifndef MULTIPLE_WRITE_SEQ_SV
`define MULTIPLE_WRITE_SEQ_SV

class multiple_write_seq extends base_sequence;

    // Factory Registration
    `uvm_object_utils(multiple_write_seq)

    // Number of Transactions
    rand int unsigned num_trans;

    constraint num_trans_c {
        num_trans inside {[10:20]};
    }

    // Constructor
    
    function new(string name = "multiple_write_seq");
        super.new(name);
    endfunction

    
    // Sequence Body
    
    virtual task body();

    bit [2:0] size;
    bit [1:0] trans;
    bit [31:0] addr[12];

    super.body();

    foreach(addr[i]) begin

        // Address
        case(i)

            // LOW
            0 : addr[i]=32'h00000020;
            1 : addr[i]=32'h00000040;
            2 : addr[i]=32'h00000080;
            3 : addr[i]=32'h000000F0;

            // MID
            4 : addr[i]=32'h00000110;
            5 : addr[i]=32'h00000140;
            6 : addr[i]=32'h00000180;
            7 : addr[i]=32'h000001F0;

            // HIGH
            8  : addr[i]=32'h00000210;
            9  : addr[i]=32'h00000240;
            10 : addr[i]=32'h00000280;
            11 : addr[i]=32'h000003F0;

        endcase

        // Transfer Size
        
        case(i)

            0,3,6,9   : size = 3'b000;   // BYTE

            1,4,7,10  : size = 3'b001;   // HALF

            2,5,8,11  : size = 3'b010;   // WORD

        endcase

        
        // Transfer Type
        
        case(i)

            0,2,4,6,8,10 : trans = 2'b10;   // NONSEQ

            1,3,5,7,9,11 : trans = 2'b11;   // SEQ

        endcase

        // WRITE
        req = ahb_transaction::type_id::create($sformatf("wr_%0d",i));

        start_item(req);

        assert(req.randomize() with {

            hwrite == 1;

            htrans == local::trans;

            hsize  == local::size;

            haddr  == local::addr[i];

        });

        finish_item(req);

        `uvm_info(get_type_name(),
                  $sformatf("WRITE[%0d] ADDR=%08h SIZE=%0d HTRANS=%0b DATA=%08h",
                            i,
                            req.haddr,
                            req.hsize,
                            req.htrans,
                            req.hwdata),
                  UVM_LOW)

    end

endtask

endclass

`endif