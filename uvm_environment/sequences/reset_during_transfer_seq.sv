`ifndef RESET_DURING_TRANSFER_SEQ_SV
`define RESET_DURING_TRANSFER_SEQ_SV

class reset_during_transfer_seq extends base_sequence;

  `uvm_object_utils(reset_during_transfer_seq)

  function new(string name="reset_during_transfer_seq");
    super.new(name);
  endfunction

  virtual task body();

    super.body();

    // WRITE BEFORE RESET
    req = ahb_transaction::type_id::create("wr_before_reset");

    fork

      // RESET THREAD
      begin

        #15ns;

        `uvm_info(get_type_name(),
                  "ASSERT RESET DURING TRANSFER",
                  UVM_LOW)

        uvm_hdl_force("tb_top.HRESETn",0);

        #30ns;

        uvm_hdl_force("tb_top.HRESETn",1);

        #10ns;

        uvm_hdl_release("tb_top.HRESETn");

      end

      // WRITE THREAD
      begin

        start_item(req);

        assert(req.randomize() with{

          hwrite==1;
          htrans==2'b10;
          hsize==3'b010;
          haddr==32'h00000200;

        });

        req.hwdata=32'h11111111;

        finish_item(req);

      end

    join


    // WRITE AFTER RESET
    req=ahb_transaction::type_id::create("wr_after_reset");

    start_item(req);

    assert(req.randomize() with{

        hwrite==1;
        htrans==2'b10;
        hsize==3'b010;
        haddr==32'h00000204;

    });

    req.hwdata=32'h22222222;

    finish_item(req);


    // READ SAME ADDRESS
    req=ahb_transaction::type_id::create("rd_after_reset");

    start_item(req);

    assert(req.randomize() with{

        hwrite==0;
        htrans==2'b10;
        hsize==3'b010;
        haddr==32'h00000204;

    });

    finish_item(req);


    // BYTE WRITE
    req=ahb_transaction::type_id::create("byte_write");

    start_item(req);

    assert(req.randomize() with{

        hwrite==1;
        htrans==2'b10;
        hsize==3'b000;
        haddr==32'h00000208;

    });

    req.hwdata=32'hAAAAAAAA;

    finish_item(req);


    // HALFWORD READ
    req=ahb_transaction::type_id::create("half_read");

    start_item(req);

    assert(req.randomize() with{

        hwrite==0;
        htrans==2'b10;
        hsize==3'b001;
        haddr==32'h00000208;

    });

    finish_item(req);

    `uvm_info(get_type_name(),"RESET DURING TRANSFER COMPLETED",UVM_LOW)

  endtask

endclass

`endif