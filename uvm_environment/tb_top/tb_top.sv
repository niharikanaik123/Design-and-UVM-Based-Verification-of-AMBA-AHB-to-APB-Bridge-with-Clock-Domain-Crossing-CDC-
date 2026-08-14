`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

import ahb_apb_pkg::*;
import bridge_pkg::*;  

module tb_top;

    // Clock & Reset

    logic HCLK;
    logic PCLK;
   
    logic HRESETn;
    logic PRESETn;

    // Interface Instances
   
    ahb_if ahb_vif(
        .HCLK(HCLK),
        .HRESETn(HRESETn)
    );

    apb_if apb_vif(
        .PCLK(PCLK),
        .PRESETn(PRESETn)
    );

    // DUT Instance
   
    ahb2apb_bridge_top #(

        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .FIFO_WIDTH(FIFO_WIDTH)

    ) dut (

        // AHB Clock & Reset
       
        .HCLK(HCLK),
        .HRESETn(HRESETn),

        // APB Clock & Reset
       
        .PCLK(PCLK),
        .PRESETn(PRESETn),

        // AHB Interface
       
        .HSEL      (ahb_vif.HSEL),
        .HREADY    (ahb_vif.HREADY),
        .HTRANS    (ahb_vif.HTRANS),
        .HWRITE    (ahb_vif.HWRITE),
        .HSIZE     (ahb_vif.HSIZE),
        .HADDR     (ahb_vif.HADDR),
        .HWDATA    (ahb_vif.HWDATA),

        .HRDATA    (ahb_vif.HRDATA),
        .HREADYOUT (ahb_vif.HREADYOUT),
        .HRESP     (ahb_vif.HRESP),

        // APB Interface
     
        .PSEL      (apb_vif.PSEL),
        .PENABLE   (apb_vif.PENABLE),
        .PWRITE    (apb_vif.PWRITE),
        .PADDR     (apb_vif.PADDR),
        .PWDATA    (apb_vif.PWDATA),

        .PREADY    (apb_vif.PREADY),
        .PRDATA    (apb_vif.PRDATA),
        .PSLVERR   (apb_vif.PSLVERR)

    );

    // APB Slave Model
    
    apb_slave_model apb_slave(

        .vif(apb_vif)

    );

    // Clock Generation
  
    initial begin

        HCLK = 100;     // HCLK = 100 MHz 100 for fifo full

        forever #5 HCLK = ~HCLK;

    end

    initial begin

        PCLK = 10;     // PCLK = 50 MHz 10 for fifo full

        forever #10 PCLK = ~PCLK;

    end

    // Power-On Reset
    
    initial begin

        HRESETn = 0;
        PRESETn = 0;

        ahb_vif.HSEL   = 0;
        ahb_vif.HREADY = 1;
        ahb_vif.HTRANS = 2'b00;
        ahb_vif.HWRITE = 0;
        ahb_vif.HSIZE  = 3'b010;
        ahb_vif.HADDR  = '0;
        ahb_vif.HWDATA = '0;

        repeat(5) @(posedge HCLK);

        HRESETn = 1;
        PRESETn = 1;

    end
   
    // Assertions
   
    bridge_assertions assertions (
        
        // AHB
       
        .HCLK      (HCLK),
        .HRESETn   (HRESETn),

        .HSEL      (ahb_vif.HSEL),
        .HREADY    (ahb_vif.HREADY),
        .HREADYOUT (ahb_vif.HREADYOUT),
        .HTRANS    (ahb_vif.HTRANS),
        .HWRITE    (ahb_vif.HWRITE),
        .HADDR     (ahb_vif.HADDR),
        .HRESP     (ahb_vif.HRESP),

        // APB
   
        .PSEL      (apb_vif.PSEL),
        .PENABLE   (apb_vif.PENABLE),
        .PREADY    (apb_vif.PREADY),
        .PWRITE    (apb_vif.PWRITE),
        .PADDR     (apb_vif.PADDR),

        .PSLVERR   (apb_vif.PSLVERR)

    );

    // Bridge Configuration
  
    bridge_config cfg;

    // UVM Configuration
    
    initial begin

        cfg = bridge_config::type_id::create("cfg");

        // Virtual Interfaces
        
        cfg.ahb_vif = ahb_vif;
        cfg.apb_vif = apb_vif;

        // User Configuration
       
        cfg.enable_coverage   = 1;
        cfg.enable_assertions = 1;

        // Store Configuration
       
        uvm_config_db #(bridge_config)::set(

            null,
            "*",
            "bridge_cfg",
            cfg

        );

    end

    // Start UVM
   
    initial begin
        
        // Select the test from the command line:
        // vsim work.tb_top +UVM_TESTNAME=data_pattern_test
        run_test();
    end

endmodule
