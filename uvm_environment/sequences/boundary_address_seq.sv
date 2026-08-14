
`ifndef BOUNDARY_ADDRESS_SEQ_SV
`define BOUNDARY_ADDRESS_SEQ_SV

class boundary_address_seq extends base_sequence;

    `uvm_object_utils(boundary_address_seq)

    function new(string name="boundary_address_seq");
        super.new(name);
    endfunction

    virtual task body();

        bit [31:0] addr[9];
        bit [31:0] data;

        super.body();

        // Boundary addresses
        
        addr[0] = 32'h00000000;
        addr[1] = 32'h000000FC;
        addr[2] = 32'h00000100;
        addr[3] = 32'h000001FC;
        addr[4] = 32'h00000200;
        addr[5] = 32'h000003FC;
        addr[6] = 32'h00000020;
        addr[7] = 32'h00000180;
        addr[8] = 32'h00000280;


        // WRITE To READ each boundary address
        
        for (int i = 0; i < 9; i++) begin

            data = 32'hB0000000 + i;

            // WRITE
            
            req = ahb_transaction::type_id::create(
                    $sformatf("bd_wr_%0d", i));

            start_item(req);

            if (!req.randomize() with {

                hwrite == 1'b1;

                htrans == ((i == 0) ? 2'b10 : 2'b11);

                hsize == 3'b010;

                haddr == local::addr[i];

                hwdata == local::data;

            })
                `uvm_fatal(
                    get_type_name(),
                    $sformatf(
                    "Boundary WRITE randomization failed for address %08h",
                    addr[i])
                )

            finish_item(req);


            // READ
            
            req = ahb_transaction::type_id::create(
                    $sformatf("bd_rd_%0d", i));

            start_item(req);

            if (!req.randomize() with {

                hwrite == 1'b0;

                htrans == 2'b11;

                hsize == 3'b010;

                haddr == local::addr[i];

            })
                `uvm_fatal(
                    get_type_name(),
                    $sformatf(
                    "Boundary READ randomization failed for address %08h",
                    addr[i])
                )

            finish_item(req);

        end

    endtask

endclass

`endif
