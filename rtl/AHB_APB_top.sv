`timescale 1ns/1ps

import ahb_apb_pkg::*;

module ahb2apb_bridge_top #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter FIFO_WIDTH = ahb_apb_pkg::FIFO_WIDTH
)(
    // AHB Clock & Reset
    input logic HCLK,
    input logic HRESETn,

    // APB Clock & Reset
    input logic PCLK,
    input logic PRESETn,

    // AHB Slave Interface
    input logic HSEL,
    input logic HREADY,
    input logic [1:0] HTRANS,
    input logic HWRITE,
    input logic [2:0] HSIZE,
    input logic [ADDR_WIDTH-1:0] HADDR,
    input logic [DATA_WIDTH-1:0] HWDATA,

    output logic [DATA_WIDTH-1:0] HRDATA,
    output logic HREADYOUT,
    output logic [1:0] HRESP,

    // APB Master Interface
    output logic PSEL,
    output logic PENABLE,
    output logic PWRITE,
    output logic [ADDR_WIDTH-1:0] PADDR,
    output logic [DATA_WIDTH-1:0] PWDATA,

    input logic PREADY,
    input logic [DATA_WIDTH-1:0] PRDATA,
    input logic PSLVERR
);

    // Internal FIFO Signals
    logic fifo_wr_en;
    logic fifo_rd_en;
    logic fifo_full;
    logic fifo_empty;

    ahb_packet_t fifo_wdata;
    ahb_packet_t fifo_packet;

    // Response Synchronizer Signals
    logic read_valid;
    logic apb_error;
    logic [DATA_WIDTH-1:0] read_data;
    logic busy_pclk;

    logic READ_VALID_SYNC;
    logic PSLVERR_SYNC;
    logic [DATA_WIDTH-1:0] PRDATA_SYNC;

    // AHB Interface Instance
    ahb_interface #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .FIFO_WIDTH (FIFO_WIDTH)	
    ) u_ahb_interface (
        .HCLK (HCLK),
        .HRESETn (HRESETn),
        .HSEL (HSEL),
        .HREADY (HREADY),
        .HTRANS (HTRANS),
        .HWRITE (HWRITE),
        .HSIZE (HSIZE),
        .HADDR (HADDR),
        .HWDATA (HWDATA),
        .fifo_full (fifo_full),
        .fifo_wr_en (fifo_wr_en),
        .fifo_wdata (fifo_wdata),
        .PRDATA_SYNC (PRDATA_SYNC),
        .READ_VALID (READ_VALID_SYNC),
        .PSLVERR_SYNC (PSLVERR_SYNC),
        .HRDATA (HRDATA),
        .HREADYOUT (HREADYOUT),
        .HRESP (HRESP)
    );

    // Asynchronous FIFO Instance
    Async_fifo #(
        .WIDTH (FIFO_WIDTH)
    ) u_async_fifo (
        .we_clk (HCLK),
        .we_rst (HRESETn),
        .we_en (fifo_wr_en),
        .W_data (fifo_wdata),
        .re_clk (PCLK),
        .re_rst (PRESETn),
        .re_en (fifo_rd_en),
        .r_data (fifo_packet),
        .full (fifo_full),
        .empty (fifo_empty)
    );

    // APB Controller FSM Instance
    apb_controller_fsm #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) u_apb_controller (
        .pclk (PCLK),
        .presetn (PRESETn),
        .fifo_empty (fifo_empty),
        .fifo_packet (fifo_packet),
        .fifo_rd_en (fifo_rd_en),
        .pready (PREADY),
        .pslverr (PSLVERR),
        .prdata (PRDATA),
        .psel (PSEL),
        .penable (PENABLE),
        .pwrite (PWRITE),
        .paddr (PADDR),
        .pwdata (PWDATA),
        .busy_pclk (busy_pclk),
        .read_valid (read_valid),
        .apb_error (apb_error),
        .read_data (read_data)
    );

    // Response Synchronizer Instance
response_synchronizer #(
    .DATA_WIDTH (DATA_WIDTH)
) u_resp_sync (
    .pclk (PCLK),
    .presetn (PRESETn),
    .read_valid (read_valid),
    .apb_error (apb_error),
    .read_data (read_data),
    .busy_pclk (busy_pclk),
    .hclk (HCLK),
    .hresetn (HRESETn),
    .read_valid_sync (READ_VALID_SYNC),
    .pslverr_sync (PSLVERR_SYNC),
    .prdata_sync (PRDATA_SYNC)
);
endmodule
