import ahb_apb_pkg::*;

`timescale 1ns / 1ps

module Async_fifo #(
    parameter WIDTH = FIFO_WIDTH,   // fifo width 70 bits
    parameter DEPTH = 16
)(
    input wire we_clk,
    input wire we_en,
    input wire we_rst,
    input wire [WIDTH-1:0] W_data,
    output wire full,

    input wire re_clk,
    input wire re_en,
    input wire re_rst,
    output wire [WIDTH-1:0] r_data,
    output wire empty
);

    localparam ADDER = $clog2(DEPTH);    // adder = 4

    wire [ADDER-1:0] we_addr;
    wire [ADDER-1:0] re_addr;

    wire [ADDER:0] we_grey;             // extra bit for compare logic
    wire [ADDER:0] re_grey;

    wire [ADDER:0] we_grey_sync;
    wire [ADDER:0] re_grey_sync;

    reg [WIDTH-1:0] mem [0:DEPTH-1];

    // Read Block
    async_fifo_read #(ADDER) read_inst (
        .re_clk(re_clk),
        .re_rst(re_rst),
        .re_en(re_en),
        .we_grey_sync(we_grey_sync),
        .re_addr(re_addr),
        .re_grey(re_grey),
        .empty(empty)
    );

    // write Block
    async_fifo_write #(ADDER) write_inst (
        .we_clk(we_clk),
        .we_rst(we_rst),
        .we_en(we_en),
        .re_grey_sync(re_grey_sync),
        .we_addr(we_addr),
        .we_grey(we_grey),
        .full(full)
    );

    // read Synchronizer
    fifo_synchronizer #(.WIDTH(ADDER+1)) sync_read (
        .clk(we_clk),
        .rst(we_rst),
        .din(re_grey),
        .dout(re_grey_sync)
    );

    // write Synchronizer
    fifo_synchronizer #(.WIDTH(ADDER+1)) sync_write (
        .clk(re_clk),
        .rst(re_rst),
        .din(we_grey),
        .dout(we_grey_sync)
    );

    // memory Write
    always @(posedge we_clk) begin
        if (we_en && !full) begin
            mem[we_addr] <= W_data;
        end
    end

    // memory read
    assign r_data = mem[re_addr];

    always @(posedge re_clk) begin
        if (re_en && !empty) begin
            $display("[%0t] FIFO READ PTR=%0d DATA=%h", $time, re_addr, r_data);
        end
    end
endmodule


module async_fifo_read #(
    parameter ADDER = 4
)(
    input wire re_clk,
    input wire re_rst,
    input wire re_en,
    input wire [ADDER:0] we_grey_sync,
    output wire [ADDER-1:0] re_addr,
    output reg [ADDER:0] re_grey,
    output reg empty
);

    reg [ADDER:0] re_bin;            // binary adder for locating current mem location of fifo 
    wire [ADDER:0] re_bin_next;      
    wire [ADDER:0] re_grey_next;
    wire empty_next;

    assign re_addr = re_bin[ADDER-1:0];    // assigning bin adder to re_adder lsb (4 bits)

    assign re_bin_next = re_bin + (re_en & ~empty);            // Increment logic after read
    assign re_grey_next = (re_bin_next >> 1) ^ re_bin_next;   // converting binary to grey 
    assign empty_next = (re_grey_next == we_grey_sync);       // Checking empty condition
    
    always @(posedge re_clk or negedge re_rst) begin
        if (!re_rst) begin
            re_bin <= {(ADDER+1){1'b0}};           // replication operator
            re_grey <= {(ADDER+1){1'b0}};
            empty <= 1'b1;                         // after reset fifo should be empty so empty = 1 
        end else begin
            re_bin <= re_bin_next;        // assigning all values to posedge of re_clk 
            re_grey <= re_grey_next;
            empty <= empty_next;
        end
    end

endmodule



module async_fifo_write #(
    parameter ADDER = 4
)(
    input wire we_clk,
    input wire we_rst,
    input wire we_en,
    input wire [ADDER:0] re_grey_sync,
    output wire [ADDER-1:0] we_addr,
    output reg [ADDER:0] we_grey,
    output reg full
);

    reg [ADDER:0] we_bin;                 // binary adder for locating current mem location of fifo
    wire [ADDER:0] we_bin_next;
    wire [ADDER:0] we_grey_next;
    wire full_next;

    assign we_addr = we_bin[ADDER-1:0];   // assigning bin adder to re_adder lsb (4 bits)

    assign we_bin_next = we_bin + (we_en & ~full);             // Increment logic after write
    assign we_grey_next = (we_bin_next >> 1) ^ we_bin_next;    // converting binary to grey 

    assign full_next = (we_grey_next == {~re_grey_sync[ADDER:ADDER-1], re_grey_sync[ADDER-2:0]}); // Checking full condition
 

    always @(posedge we_clk or negedge we_rst) begin
        if (!we_rst) begin
            we_bin <= {(ADDER+1){1'b0}};
            we_grey <= {(ADDER+1){1'b0}};
            full <= 1'b0;
        end else begin
            we_bin <= we_bin_next;       
            we_grey <= we_grey_next;
            full <= full_next;
        end
    end

endmodule


// basic two stage synchronizer 
module fifo_synchronizer #(
    parameter WIDTH = 5
)(
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout
);

    reg [WIDTH-1:0] dout_stage1;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            dout_stage1 <= {WIDTH{1'b0}};
            dout <= {WIDTH{1'b0}};
        end else begin
            dout_stage1 <= din;
            dout <= dout_stage1; 
        end
    end

endmodule
