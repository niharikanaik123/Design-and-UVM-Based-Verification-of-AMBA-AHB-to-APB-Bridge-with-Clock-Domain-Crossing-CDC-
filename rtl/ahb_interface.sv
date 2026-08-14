import ahb_apb_pkg::*;

module ahb_interface #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter FIFO_WIDTH = ahb_apb_pkg::FIFO_WIDTH
)(
    input  logic HCLK,
    input  logic HRESETn,

    // AHB Slave Interface
    input  logic HSEL,
    input  logic HREADY,
    input  logic [1:0] HTRANS,
    input  logic HWRITE,
    input  logic [2:0] HSIZE,
    input  logic [ADDR_WIDTH-1:0] HADDR,
    input  logic [DATA_WIDTH-1:0] HWDATA,

    // FIFO Interface
    input  logic fifo_full,
    output logic fifo_wr_en,
    output logic [FIFO_WIDTH-1:0] fifo_wdata,

    // Response Synchronizer
    input  logic [DATA_WIDTH-1:0] PRDATA_SYNC,
    input  logic READ_VALID,
    input  logic PSLVERR_SYNC,

    // AHB Outputs
    output logic [DATA_WIDTH-1:0] HRDATA,
    output logic HREADYOUT,
    output logic [1:0] HRESP
);

    logic write_pending;  //indicate write operations is pending
    logic err_cycle2;

    logic hwrite_reg;           //temp reg for storing transaction
    logic [2:0] hsize_reg;
    logic [ADDR_WIDTH-1:0] haddr_reg;
    logic [1:0] htrans_reg;

    // 2-state FSM  for read
    typedef enum logic {
        READ_IDLE,
        READ_WAIT_RESP         //waiting for response from synchronizer
    } read_state_t;

    read_state_t read_state;

    logic addr_phase;           // indicate adder phase 
    logic accept_xfer;          // accept new transaction or not 
    logic accept_read;
    logic accept_write;
    logic addr_phase_d;        // adder phase delayed version 

    // adder_phase_d = 1 => data phase is coming & adder phase went already
    // adder_phase_d = 0 => data phase went adder phase is coming 

    assign addr_phase = HSEL && HTRANS[1];
            
    assign accept_xfer = addr_phase && !addr_phase_d && !fifo_full && !write_pending && (read_state == READ_IDLE) && !err_cycle2;
    
    // addr phase = 1  addr phase delay version = 0  => then accept transfer  

    assign accept_read = accept_xfer && !HWRITE;
    assign accept_write = accept_xfer && HWRITE;

    logic read_complete_ok;
    logic read_complete_err;    //  read cycle status

    assign read_complete_ok = (read_state == READ_WAIT_RESP) && READ_VALID && !PSLVERR_SYNC;
    assign read_complete_err = (read_state == READ_WAIT_RESP) && READ_VALID && PSLVERR_SYNC;

    ahb_packet_t tx_packet;    // fifo packet variable 
    logic [DATA_WIDTH-1:0] hrdata_reg;

    always_ff @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn)
        addr_phase_d <= 1'b0;
    else
        addr_phase_d <= addr_phase;
end

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            fifo_wr_en <= 1'b0;
            tx_packet <= '0;
            hrdata_reg <= '0;

            hwrite_reg <= 1'b0;
            hsize_reg <= '0;
            haddr_reg <= '0;
            htrans_reg <= '0;

            read_state <= READ_IDLE;
            write_pending <= 1'b0;
            err_cycle2 <= 1'b0;
        end 
        else begin
            fifo_wr_en <= 1'b0;      

            if (err_cycle2)          // clearing error_cycle bit
                err_cycle2 <= 1'b0;

            //----------------------------------------------------
            // Address Phase Capture
            //----------------------------------------------------
            $display("[%0t] HSEL=%0b HTRANS=%b HREADY=%0b HREADYOUT=%0b write_pending=%0b accept=%0b",
            $time, HSEL, HTRANS, HREADY, HREADYOUT, write_pending, accept_xfer);

            $display("[%0t] BUS HADDR=%h HTRANS=%b HSEL=%b HREADY=%b HREADYOUT=%b",
            $time, HADDR, HTRANS, HSEL, HREADY, HREADYOUT);


            if (accept_xfer) begin

                $display("[%0t] ACCEPT_XFER Addr=%h HWRITE=%0b",$time, HADDR, HWRITE);


                if (!HWRITE) begin          // add Phase for read 
                    fifo_wr_en <= 1'b1;

                    tx_packet.hwrite <= 1'b0;
                    tx_packet.haddr <= HADDR;
                    tx_packet.hwdata <= 32'b0;
                    tx_packet.hsize <= HSIZE;
                    tx_packet.htrans <= HTRANS;

                    read_state <= READ_WAIT_RESP;

                    $display("[%0t] AHB IF : READ REQUEST  Addr=%h", $time, HADDR);

                end     
                else begin                  // add phase for write
                    hwrite_reg <= HWRITE;
                    hsize_reg <= HSIZE;
                    haddr_reg <= HADDR;
                    htrans_reg <= HTRANS;

                    write_pending <= 1'b1;
                end
            end

            //----------------------------------------------------
            // Write Data Phase
            //----------------------------------------------------
            if (write_pending && !fifo_full) begin

                $display("[%0t] WRITE_PENDING=%0b haddr_reg=%h HADDR=%h HSEL=%0b HTRANS=%b",
                $time, write_pending, haddr_reg, HADDR, HSEL, HTRANS);

                fifo_wr_en <= 1'b1;

                 $display("[%0t] FIFO WRITE Addr=%h", $time, haddr_reg);

                tx_packet.hwrite <= hwrite_reg;
                tx_packet.haddr  <= haddr_reg;
                tx_packet.hwdata <= HWDATA;
                tx_packet.hsize  <= hsize_reg;
                tx_packet.htrans <= htrans_reg;

                write_pending <= 1'b0;
            end

            
            // Data Phase for Read 
            if (read_state == READ_WAIT_RESP && READ_VALID) begin

                $display("[%0t] AHB IF : READ_VALID received", $time);
                $display("[%0t] AHB IF : PRDATA_SYNC=%h", $time, PRDATA_SYNC);

                hrdata_reg <= PRDATA_SYNC;

                if (PSLVERR_SYNC)
                    err_cycle2 <= 1'b1;

                read_state <= READ_IDLE;
            end
        end
    end

    assign fifo_wdata = tx_packet;  // assigning packet to fifo_wdata

    assign HRDATA = read_complete_ok ? PRDATA_SYNC : hrdata_reg;    // Assigning read data when read_complete is ok 

    //------------------------------------------------------------
    // Output Logic
    //------------------------------------------------------------
    always_comb begin
        if (err_cycle2) begin
            // second cycle of the 2-cycle AHB error response
            HRESP = 2'b01;
            HREADYOUT = 1'b1;
        end
        else if (read_complete_err) begin
            // first cycle of the 2-cycle AHB error response
            HRESP = 2'b01;
            HREADYOUT = 1'b0;
        end
        else if (read_complete_ok) begin
            HRESP = 2'b00;
            HREADYOUT = 1'b1;
        end
        else if (accept_read || accept_write) begin
            HRESP = 2'b00;
            HREADYOUT = 1'b0;
        end
        else if (write_pending) begin
            HRESP = 2'b00;
            HREADYOUT = 1'b0;
        end
        else begin
            HRESP = 2'b00;

            case (read_state)
                READ_IDLE: HREADYOUT = !fifo_full;
                READ_WAIT_RESP: HREADYOUT = 1'b0;
                default: HREADYOUT = 1'b1;
            endcase
        end
    end

endmodule