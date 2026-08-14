module apb_slave_model (
    apb_if vif
);
    // 1KB internal RAM peripheral
    logic [31:0] mem [0:255];
    logic        read_pending;
    logic        penable_prev;   // for edge-detecting entry into ENABLE

    always_ff @(posedge vif.PCLK or negedge vif.PRESETn) begin
        if (!vif.PRESETn) begin
            vif.PREADY   <= 1'b1;
            vif.PRDATA   <= 32'b0;
            vif.PSLVERR  <= 1'b0;
            read_pending <= 1'b0;
            penable_prev <= 1'b0;

        end
        else begin

            penable_prev <= vif.PENABLE;

            if (read_pending) begin
                // DEBUG
                $display("[%0t] APB SLAVE READ : mem[%0d] = %h",
                         $time,
                         vif.PADDR[9:2],
                         mem[vif.PADDR[9:2]]);

                // Fetch completes this cycle
                vif.PRDATA   <= mem[vif.PADDR[9:2]];
                vif.PREADY   <= 1'b1;
                read_pending <= 1'b0;
            end
    
            else if (vif.PSEL && vif.PENABLE && !penable_prev) begin
                if (vif.PWRITE) begin
                    // DEBUG
                    $display("[%0t] APB SLAVE WRITE : mem[%0d] <= %h",
                             $time,
                             vif.PADDR[9:2],
                             vif.PWDATA);
                    // Write to memory
                    mem[vif.PADDR[9:2]] <= vif.PWDATA;
                    vif.PREADY <= 1'b1;
                end
                else begin
                    // DEBUG
                    $display("[%0t] APB SLAVE READ REQUEST : Addr=%h Index=%0d",
                             $time,
                             vif.PADDR,
                             vif.PADDR[9:2]);
                    // Read request accepted
                    vif.PREADY   <= 1'b0;
                    read_pending <= 1'b1;
                end
            end
            else begin
                vif.PREADY <= 1'b1;
            end
        end
    end

    // DEBUG : Print outputs after NBA updates

    always @(posedge vif.PCLK) begin
        #0;
        $display("[%0t] APB SLAVE STATE : PSEL=%0b PENABLE=%0b PWRITE=%0b PREADY=%0b PRDATA=%h READ_PENDING=%0b",
                 $time,
                 vif.PSEL,
                 vif.PENABLE,
                 vif.PWRITE,
                 vif.PREADY,
                 vif.PRDATA,
                 read_pending);
    end
endmodule

