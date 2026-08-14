`ifndef FIFO_FULL_SEQ_SV
`define FIFO_FULL_SEQ_SV

class fifo_full_seq extends base_sequence;

    // Factory Registration
    `uvm_object_utils(fifo_full_seq)

    // Number of Transactions
    localparam int NUM_WRITES = 64;

    // Constructor
    function new(string name = "fifo_full_seq");
        super.new(name);
    endfunction

    // Sequence Body
    virtual task body();

    int i;

    super.body();

    `uvm_info(get_type_name(),

   "========== FIFO FULL TEST STARTED ==========",
              UVM_LOW)

    // Generate Continuous Write Transactions
    for(i = 0; i < NUM_WRITES; i++) begin

        `uvm_info(get_type_name(),
                  $sformatf("START TXN %0d", i),
                  UVM_NONE)

        req = ahb_transaction::type_id::create($sformatf("req_%0d", i));

        start_item(req);

        if(!req.randomize() with {
                hwrite == 1'b1;

             htrans inside {
                  2'b10,
                 2'b11
             };

             hsize inside {
                3'b000,
                3'b001,
                3'b010
            };
        })

        `uvm_error(get_type_name(),
                       $sformatf("Randomization Failed at Transaction %0d", i))

        finish_item(req);

        `uvm_info(get_type_name(),
                  $sformatf("FINISH TXN %0d", i),
                  UVM_NONE)

        `uvm_info(get_type_name(),
                  $sformatf("WRITE[%0d] ADDR=%08h DATA=%08h",
                            i,
                            req.haddr,
                            req.hwdata),
                  UVM_MEDIUM)

    end


    `uvm_info(get_type_name(),
              $sformatf("Successfully Generated %0d WRITE Transactions",
                        NUM_WRITES),
              UVM_LOW)

    `uvm_info(get_type_name(),
              "========== FIFO FULL TEST COMPLETED ==========",
              UVM_LOW)

    `uvm_info(get_type_name(),
              "SEQUENCE FINISHED",
              UVM_NONE)

    `uvm_info(get_type_name(),
          "BODY FINISHED",
          UVM_NONE)

            

    endtask

endclass

`endif