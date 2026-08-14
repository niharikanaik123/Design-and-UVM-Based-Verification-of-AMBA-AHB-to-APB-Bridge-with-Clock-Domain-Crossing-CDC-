`timescale 1ns/1ps

`ifndef AHB_IF_SV
`define AHB_IF_SV

interface ahb_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic HCLK,
    input logic HRESETn
);
    // AHB Master TO  DUT Signals
  
    logic                    HSEL;
    logic                    HREADY;
    logic [1:0]              HTRANS;
    logic                    HWRITE;
    logic [2:0]              HSIZE;
    logic [ADDR_WIDTH-1:0]   HADDR;
    logic [DATA_WIDTH-1:0]   HWDATA;
  
    // DUT To Master Signals
  
    logic [DATA_WIDTH-1:0]   HRDATA;
    logic                    HREADYOUT;
    logic [1:0]              HRESP;

    // Driver Clocking Block

    clocking drv_cb @(posedge HCLK);

        default input #1 output #0;

        output HSEL;
        output HREADY;
        output HTRANS;
        output HWRITE;
        output HSIZE;
        output HADDR;
        output HWDATA;

        input HRDATA;
        input HREADYOUT;
        input HRESP;

    endclocking

    // Monitor Clocking Block
  
    clocking mon_cb @(posedge HCLK);

        default input #1;

        input HSEL;
        input HREADY;
        input HTRANS;
        input HWRITE;
        input HSIZE;
        input HADDR;
        input HWDATA;

        input HRDATA;
        input HREADYOUT;
        input HRESP;

    endclocking

    // Driver Modport
  
    modport DRV (
        clocking drv_cb,
        input HCLK,
        input HRESETn
    );

    // Monitor Modport
  
    modport MON (
        clocking mon_cb,
        input HCLK,
        input HRESETn
    );

endinterface

`endif