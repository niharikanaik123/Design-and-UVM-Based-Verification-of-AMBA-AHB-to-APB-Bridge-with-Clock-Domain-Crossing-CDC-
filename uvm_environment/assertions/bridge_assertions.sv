`ifndef BRIDGE_ASSERTIONS_SV
`define BRIDGE_ASSERTIONS_SV

module bridge_assertions (

    input logic        HCLK,
    input logic        HRESETn,

    // AHB Interface
   
    input logic        HSEL,
    input logic        HREADY,
    input logic        HREADYOUT,
    input logic [1:0]  HTRANS,
    input logic        HWRITE,
    input logic [31:0] HADDR,
    input logic [1:0]  HRESP,

    // APB Interface
   
    input logic        PSEL,
    input logic        PENABLE,
    input logic        PREADY,
    input logic        PWRITE,
    input logic [31:0] PADDR,

    input logic        PSLVERR

);

    // 1. PENABLE can only be HIGH when PSEL is HIGH
    property p_penable_requires_psel;
        @(posedge HCLK)
        disable iff(!HRESETn)
        PENABLE |-> PSEL;
    endproperty

    A_PENABLE_REQUIRES_PSEL :
    assert property(p_penable_requires_psel)
    else
        $error("PENABLE HIGH while PSEL LOW");


    // 2. PENABLE should be asserted only after PSEL
   
    property p_enable_after_setup;
        @(posedge HCLK)
        disable iff(!HRESETn)
        $rose(PENABLE) |-> PSEL;
    endproperty

    A_ENABLE_AFTER_SETUP :
    assert property(p_enable_after_setup)
    else
        $error("PENABLE asserted before PSEL");


    // 3. Valid transfer requires HSEL

    property p_valid_transfer;
        @(posedge HCLK)
        disable iff(!HRESETn)
        HTRANS[1] |-> HSEL;
    endproperty

    A_VALID_TRANSFER :
    assert property(p_valid_transfer)
    else
        $error("HTRANS indicates valid transfer while HSEL LOW");


    // 4. During APB wait state address must remain stable
   
    property p_apb_addr_stable;
        @(posedge HCLK)
        disable iff(!HRESETn)
        (PSEL && PENABLE && !PREADY)
        |-> $stable(PADDR);
    endproperty

    A_APB_ADDR_STABLE :
    assert property(p_apb_addr_stable)
    else
        $error("PADDR changed during APB wait state");


    // 5Read transaction should eventually complete

        property p_read_complete;

        @(posedge HCLK)
         disable iff(!HRESETn)

          (HSEL && HTRANS[1] && !HWRITE)
          |-> ##[1:80] HREADYOUT;
        
        endproperty

        A_READ_COMPLETE:
        assert property(p_read_complete)
        else
        $error("Read transaction did not complete within expected latency");

  
    // 6. Write transaction should eventually complete
 
    property p_write_complete;
        @(posedge HCLK)
        disable iff(!HRESETn)
        (HSEL && HTRANS[1] && HWRITE)
        |-> ##[1:1000] HREADYOUT;
    endproperty

    A_WRITE_COMPLETE :
    assert property(p_write_complete)
    else
        $error("Write transaction timeout");


    // 7. HRESP should never be X
  
    property p_hresp_known;
        @(posedge HCLK)
        disable iff(!HRESETn)
        !$isunknown(HRESP);
    endproperty

    A_HRESP_KNOWN :
    assert property(p_hresp_known)
    else
        $error("Unknown value detected on HRESP");


    // 8. PSLVERR should only occur during an APB access

    property p_pslverr_valid;
        @(posedge HCLK)
        disable iff(!HRESETn)
        PSLVERR |-> (PSEL && PENABLE);
    endproperty

    A_PSLVERR_VALID :
    assert property(p_pslverr_valid)
    else
        $error("PSLVERR asserted without active APB transfer");

endmodule

`endif