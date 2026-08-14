import ahb_apb_pkg::*;

typedef enum logic [2:0] {
    IDLE,
    SETUP,
    ENABLE,
    WAIT_RESP,
    DONE
} apb_state_t;

module apb_controller_fsm #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic pclk,
    input logic presetn,

    // fifo Interface
    input logic fifo_empty,
    input ahb_packet_t fifo_packet,
    output logic fifo_rd_en,

    // slave interface
    input logic pready,
    input logic pslverr,
    input logic [DATA_WIDTH-1:0] prdata,
    output logic psel,
    output logic penable,
    output logic pwrite,
    output logic [ADDR_WIDTH-1:0] paddr,
    output logic [DATA_WIDTH-1:0] pwdata,

    // Response Synchronize
    input logic busy_pclk,
    output logic read_valid,
    output logic apb_error,
    output logic [DATA_WIDTH-1:0] read_data
);

    apb_state_t current_state, next_state;

    logic [1:0] htrans_reg;
    logic hwrite_reg;
    logic [ADDR_WIDTH-1:0] haddr_reg;
    logic [DATA_WIDTH-1:0] hwdata_reg;
    logic [2:0] hsize_reg;

    logic resp_capture_pclk;
    logic resp_valid_d;

   
    logic enable_prev;
    logic pready_qual;

    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn)
            enable_prev <= 1'b0;
        else
            enable_prev <= (current_state == ENABLE);
    end

    assign pready_qual = enable_prev && pready;

    // Latch AHB packet from FIFO
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            htrans_reg <= '0;
            hwrite_reg <= 1'b0;
            haddr_reg <= '0;
            hwdata_reg <= '0;
            hsize_reg <= '0;
        end
        else if (current_state == SETUP) begin
            htrans_reg <= fifo_packet.htrans;
            hwrite_reg <= fifo_packet.hwrite;
            haddr_reg <= fifo_packet.haddr;
            hwdata_reg <= fifo_packet.hwdata;
            hsize_reg <= fifo_packet.hsize;
        end
    end    

    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            read_data <= '0;
            apb_error <= 1'b0;
            resp_capture_pclk <= 1'b0;
            resp_valid_d <= 1'b0;
        end
        else begin

            resp_capture_pclk <= 1'b0;
            resp_valid_d <= resp_capture_pclk;

            if ((current_state == ENABLE) && pready_qual && !hwrite_reg) begin

                read_data <= prdata;
                apb_error <= pslverr;

                resp_capture_pclk <= 1'b1;
            end
        end
    end

    // FSM State Register
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end        
        
    // FSM Next State Logic
    // Both write- and read-completion checks now use pready_qual.
    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (!fifo_empty)
                    next_state = SETUP;
            end

            SETUP: begin
                next_state = ENABLE;
            end

            ENABLE: begin
                if (pready_qual) begin
                    if (!hwrite_reg)
                        next_state = WAIT_RESP;
                    else
                        next_state = DONE;
                end
            end

            WAIT_RESP: begin
                if (!busy_pclk)
                    next_state = DONE;
                   
            end

            DONE: begin
                if (!fifo_empty)
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // Output Logic
    always_comb begin

        fifo_rd_en = 1'b0;
        psel = 1'b0;
        penable = 1'b0;
        pwrite = 1'b0;
        paddr = '0;
        pwdata = '0;
        read_valid = 1'b0;

        case (current_state)

            SETUP: begin
                if (htrans_reg[1] || fifo_packet.htrans[1]) begin
                    psel = 1'b1;
                    penable = 1'b0;
                    pwrite = fifo_packet.hwrite;
                    paddr = fifo_packet.haddr;
                    pwdata = fifo_packet.hwdata;
                end
            end

            ENABLE: begin
                psel = 1'b1;
                penable = 1'b1;
                pwrite = hwrite_reg;
                paddr = haddr_reg;
                pwdata = hwdata_reg;


                if (pready_qual)
                    fifo_rd_en = 1'b1;
            end

            WAIT_RESP: begin
            end

            DONE: begin
            end

            default: begin
            end

        endcase

        if (resp_valid_d)
            read_valid = 1'b1;
    end

endmodule
