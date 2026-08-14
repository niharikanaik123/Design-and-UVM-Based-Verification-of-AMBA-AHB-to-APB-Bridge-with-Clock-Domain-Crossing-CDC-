`ifndef RANDOM_RW_SEQ_SV
`define RANDOM_RW_SEQ_SV

class random_rw_seq extends base_sequence;

    `uvm_object_utils(random_rw_seq)

    rand int unsigned num_trans;

    constraint num_trans_c {
        num_trans inside {[20:30]};
    }

    function new(string name = "random_rw_seq");
        super.new(name);
    endfunction

    virtual task body();

        bit [31:0] addr_q[$];

        bit [31:0] a;
        bit [31:0] d;

        bit [2:0] sz;
        bit [1:0] tr;
        bit       wr;

        super.body();

        if (!randomize(num_trans)) begin
            num_trans = 20;
        end

        `uvm_info(get_type_name(), $sformatf("Generating %0d transactions",num_trans),UVM_LOW)

        for (int i = 0; i < num_trans; i++) begin

            // Force initial WRITE transactions
            if (i < 8)
                wr = 1'b1;
            else
                wr = $urandom_range(0,1);

            // Address distribution
            if (i < 3) begin

                // LOW
                a = 32'h00000020 + (i * 4);

            end
            else if (i < 6) begin

                // MID
                a = 32'h00000100 + ((i-3) * 4);

            end
            else if (i < 8) begin

                // HIGH
                a = 32'h00000200 + ((i-6) * 4);

            end
            else if (!wr && addr_q.size() != 0) begin

                // Read previously written address
                a = addr_q[$urandom_range(0,addr_q.size()-1)];

            end
            else begin

                // Random aligned address
                a = ($urandom_range(0,255) << 2);

            end

            // Transfer size
            case (i % 3)

                0: sz = 3'b000;       // BYTE
                1: sz = 3'b001;       // HALF
                default: sz = 3'b010; // WORD

            endcase

            // Transfer type
            if ((i == 0) || ((i % 4) == 0))
                tr = 2'b10;           // NONSEQ
            else
                tr = 2'b11;           // SEQ

            // Random data
            d = $urandom;

            // Create transaction
            req = ahb_transaction::type_id::create(
                      $sformatf("rr_%0d", i));

            start_item(req);

            if (!req.randomize() with {

                hwrite == local::wr;
                haddr  == local::a;
                hwdata == local::d;
                hsize  == local::sz;
                htrans == local::tr;

            }) begin

                `uvm_fatal(get_type_name(),$sformatf("Transaction randomization failed at %0d",i))
            end

            finish_item(req);

            // Save WRITE address
            if (wr)
                addr_q.push_back(a);

            // Display
            `uvm_info(get_type_name(),

                $sformatf(
                "[%0d] %s ADDR=%08h DATA=%08h SIZE=%0d HTRANS=%02b",i,wr ? "WRITE" : "READ",a,d,sz,tr),UVM_LOW)

        end

    endtask

endclass

`endif