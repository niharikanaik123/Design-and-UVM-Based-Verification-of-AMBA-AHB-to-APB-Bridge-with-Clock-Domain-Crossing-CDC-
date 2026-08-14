```systemverilog
`ifndef DATA_PATTERN_SEQ_SV
`define DATA_PATTERN_SEQ_SV

class data_pattern_seq extends base_sequence;
    `uvm_object_utils(data_pattern_seq)

    function new(string name="data_pattern_seq");
        super.new(name);
    endfunction

    virtual task body();
        
        bit [31:0] patterns[5];
        // Address used for the current write/read transaction.
        bit [31:0] addr;

        super.body();

        
        patterns[0] = 32'h00000000;
        patterns[1] = 32'hFFFFFFFF;
        patterns[2] = 32'hAAAAAAAA;
        patterns[3] = 32'h55555555;
        patterns[4] = 32'h12345678;
        
        for (int i = 0; i < 5; i++) begin
            addr = 32'h00000020 + i * 4;
            // Create the write transaction for the current pattern.
            req = ahb_transaction::type_id::create(
                $sformatf("pat_wr_%0d", i)
            );

            start_item(req);

            if (!req.randomize() with {
                // This transaction is an AHB write.
                hwrite == 1'b1;
                // First transfer is NONSEQ; subsequent transfers are SEQ.
                htrans == ((i == 0) ? 2'b10 : 2'b11);
                // 32-bit transfer.
                hsize  == 3'b010;
                // Use the calculated address and selected test pattern.
                haddr  == local::addr;
                hwdata == local::patterns[i];
            })
                `uvm_fatal(
                    get_type_name(),
                    "Pattern write randomization failed"
                )

            finish_item(req);
            req = ahb_transaction::type_id::create(
                $sformatf("pat_rd_%0d", i)
            );

            start_item(req);

            if (!req.randomize() with {
                // This transaction is an AHB read.
                hwrite == 1'b0;
                // Each read starts a new transfer.
                htrans == 2'b10;
                // Read the same 32-bit word that was written.
                hsize  == 3'b010;
                haddr  == local::addr;
            })
                `uvm_fatal(
                    get_type_name(),
                    "Pattern read randomization failed"
                )

            finish_item(req);
        end
    endtask

endclass

`endif
