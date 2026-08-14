`timescale 1ns/1ps

`ifndef APB_IF_SV
`define APB_IF_SV

interface apb_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic PCLK,
    input logic PRESETn
);
    // DUT To APB Slave
    
    logic                    PSEL;
    logic                    PENABLE;
    logic                    PWRITE;
    logic [ADDR_WIDTH-1:0]   PADDR;
    logic [DATA_WIDTH-1:0]   PWDATA;
    
    // APB Slave TO DUT
    
    logic                    PREADY;
    logic                    PSLVERR;
    logic [DATA_WIDTH-1:0]   PRDATA;

    // Monitor Clocking Block
  
    clocking mon_cb @(posedge PCLK);

        default input #1;

        input PSEL;
        input PENABLE;
        input PWRITE;
        input PADDR;
        input PWDATA;

        input PREADY;
        input PSLVERR;
        input PRDATA;

    endclocking

    // Monitor Modport
   
    modport MON (
        clocking mon_cb,
        input PCLK,
        input PRESETn
    );

endinterface

`endif