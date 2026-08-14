module response_synchronizer #(
    parameter DATA_WIDTH = 32
)(
    // APB Clock Domain
    input logic pclk,
    input logic presetn,
    input logic read_valid,
    input logic apb_error,
    input logic [DATA_WIDTH-1:0] read_data,
    output logic busy_pclk,

    // AHB Clock Domain
    input logic hclk,
    input logic hresetn,

    // Outputs to AHB Interface
    output logic read_valid_sync,
    output logic pslverr_sync,
    output logic [DATA_WIDTH-1:0] prdata_sync
);


// APB DOMAIN: capture + request toggle
logic req_toggle_pclk;
logic [DATA_WIDTH-1:0] read_data_reg;
logic error_reg;

logic ack_toggle;
logic ack_ff1_pclk, ack_ff2_pclk;

// ACK Synchronizer
always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
        ack_ff1_pclk <= 1'b0;
        ack_ff2_pclk <= 1'b0;
    end
    else begin
        ack_ff1_pclk <= ack_toggle;
        ack_ff2_pclk <= ack_ff1_pclk;
    end
end

// Busy Generation
logic handshake_pending_pclk;

assign handshake_pending_pclk = (req_toggle_pclk != ack_ff2_pclk);
assign busy_pclk = handshake_pending_pclk;

// Capture APB Read Response
always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
        req_toggle_pclk <= 1'b0;
        read_data_reg <= '0;
        error_reg <= 1'b0;
    end
    else if (read_valid && !busy_pclk) begin
        read_data_reg <= read_data;
        error_reg <= apb_error;
        req_toggle_pclk <= ~req_toggle_pclk;
    end
end


// HCLK DOMAIN: synchronize request toggle
logic req_ff1_hclk;
logic req_ff2_hclk;
logic req_ff2_d_hclk;

always_ff @(posedge hclk or negedge hresetn) begin
    if (!hresetn) begin
        req_ff1_hclk <= 1'b0;
        req_ff2_hclk <= 1'b0;
        req_ff2_d_hclk <= 1'b0;
    end
    else begin
        req_ff1_hclk <= req_toggle_pclk;
        req_ff2_hclk <= req_ff1_hclk;
        req_ff2_d_hclk <= req_ff2_hclk;
    end
end

wire req_pulse_hclk = req_ff2_hclk ^ req_ff2_d_hclk;


always_ff @(posedge hclk or negedge hresetn) begin
    if (!hresetn) begin
        read_valid_sync <= 1'b0;
        prdata_sync <= '0;
        pslverr_sync <= 1'b0;
    end
    else begin
        read_valid_sync <= req_pulse_hclk;

        if (req_pulse_hclk) begin
            prdata_sync <= read_data_reg;
            pslverr_sync <= error_reg;
        end
    end
end


always_ff @(posedge hclk or negedge hresetn) begin
    if (!hresetn)
        ack_toggle <= 1'b0;
    else if (read_valid_sync)
        ack_toggle <= ~ack_toggle;
end

endmodule
