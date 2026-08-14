`ifndef AHB_DRIVER_SV
`define AHB_DRIVER_SV

class ahb_driver extends uvm_driver #(ahb_transaction);

    // Factory Registration
   
    `uvm_component_utils(ahb_driver)

    // Configuration
   
    bridge_config cfg;
    virtual ahb_if vif;

    // Constructor
   
    function new(string name = "ahb_driver",uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase
   
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db#(bridge_config)::get(
                this,
                "",
                "bridge_cfg",
                cfg))
        begin
            `uvm_fatal("DRV","Configuration Not Found");
        end

        vif = cfg.ahb_vif;

    endfunction
    
    // Run Phase
    
    task run_phase(uvm_phase phase);

        vif.drv_cb.HSEL   <= 1'b0;
        vif.drv_cb.HREADY <= 1'b1;
        vif.drv_cb.HTRANS <= 2'b00;
        vif.drv_cb.HWRITE <= 1'b0;
        vif.drv_cb.HADDR  <= '0;
        vif.drv_cb.HWDATA <= '0;
        vif.drv_cb.HSIZE  <= '0;

        wait(vif.HRESETn);

        forever begin

            seq_item_port.get_next_item(req);

            drive_transfer(req);

            seq_item_port.item_done();

        end

    endtask

    // Drive Protocol Transfer
   
    task drive_transfer(ahb_transaction tr);
     
        while(!vif.HREADYOUT)
            @(posedge vif.HCLK);

        // ADDRESS PHASE
    
        @(posedge vif.HCLK);
      
        vif.drv_cb.HSEL   <= 1'b1;
        vif.drv_cb.HREADY <= 1'b1;
        vif.drv_cb.HTRANS <= tr.htrans;
        vif.drv_cb.HWRITE <= tr.hwrite;
        vif.drv_cb.HSIZE  <= tr.hsize;
        vif.drv_cb.HADDR  <= tr.haddr;

         $display("[%0t] DRIVER SEND ADDR=%h DATA=%h WRITE=%0b", $time, tr.haddr, tr.hwdata, tr.hwrite);

        // WRITE TRANSFER
      
        if(tr.hwrite) begin

         @(posedge vif.HCLK);

         vif.drv_cb.HWDATA <= tr.hwdata;

         while(!vif.HREADYOUT)
        @(posedge vif.HCLK);

         vif.drv_cb.HTRANS <= 2'b00;

        end
       
        // READ TRANSFER
      
        else begin

         @(posedge vif.HCLK);
         vif.drv_cb.HTRANS <= 2'b00;

         @(posedge vif.HCLK);

         while(!vif.HREADYOUT)
         @(posedge vif.HCLK);

        tr.hrdata = vif.HRDATA;
        tr.hresp  = vif.HRESP;

        end

        @(posedge vif.HCLK);

        vif.drv_cb.HSEL   <= 1'b0;
        vif.drv_cb.HWRITE <= 1'b0;
        vif.drv_cb.HADDR  <= '0;
        vif.drv_cb.HWDATA <= '0;
        vif.drv_cb.HSIZE  <= '0;

        `uvm_info(get_type_name(),
                  $sformatf("Transfer Completed : %s ADDR=%08h", tr.hwrite ? "WRITE" : "READ", tr.haddr),
                  UVM_MEDIUM)

    endtask

endclass

`endif