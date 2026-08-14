`ifndef BACK_TO_BACK_SEQ_SV
`define BACK_TO_BACK_SEQ_SV

class back_to_back_seq extends base_sequence;

  `uvm_object_utils(back_to_back_seq)

  function new(string name = "back_to_back_seq");
    super.new(name);
  endfunction

  virtual task body();

    bit [31:0] addr[6];
    bit [31:0] data;
    bit [2:0]  sz;

    super.body();

    addr[0] = 32'h00000020;
    addr[1] = 32'h00000040;
    addr[2] = 32'h00000080;
    addr[3] = 32'h00000100;
    addr[4] = 32'h00000200;
    addr[5] = 32'h00000300;

    for (int i = 0; i < 6; i++) begin

      data = 32'hA5000000 + i;

      case (i % 3)
        0: sz = 3'b000;
        1: sz = 3'b001;
        2: sz = 3'b010;
      endcase

      // WRITE
      req = ahb_transaction::type_id::create($sformatf("wr_%0d", i));

      start_item(req);

      if (!req.randomize() with {
            hwrite == 1;
            htrans == ((i == 0) ? 2'b10 : 2'b11);
            haddr  == local::addr[i];
            hwdata == local::data;
            hsize  == local::sz;
          })
        `uvm_fatal(get_type_name(), "WRITE Randomization Failed");

      `uvm_info("SEQ_DEBUG",
        $sformatf("WRITE: HWRITE=%0d HTRANS=%0b ADDR=%08h DATA=%08h",
                  req.hwrite,
                  req.htrans,
                  req.haddr,
                  req.hwdata),
        UVM_NONE)

      finish_item(req);

      `uvm_info(get_type_name(),
        $sformatf("WRITE ADDR=%08h DATA=%08h",
                  req.haddr,
                  req.hwdata),
        UVM_LOW)

      // READ SAME ADDRESS
      req = ahb_transaction::type_id::create($sformatf("rd_%0d", i));

      start_item(req);

      if (!req.randomize() with {
            hwrite == 0;
            htrans == 2'b11;
            haddr  == local::addr[i];
            hsize  == local::sz;
          })
        `uvm_fatal(get_type_name(), "READ Randomization Failed");

      `uvm_info("SEQ_DEBUG",
        $sformatf("READ : HWRITE=%0d HTRANS=%0b ADDR=%08h",
                  req.hwrite,
                  req.htrans,
                  req.haddr),
        UVM_NONE)

      finish_item(req);

      `uvm_info(get_type_name(),
        $sformatf("READ ADDR=%08h",
                  req.haddr),
        UVM_LOW);

    end

  endtask

endclass

`endif