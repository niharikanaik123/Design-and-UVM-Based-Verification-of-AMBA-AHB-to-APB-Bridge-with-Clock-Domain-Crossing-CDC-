`ifndef APB_MONITOR_SV
`define APB_MONITOR_SV

class apb_monitor extends uvm_monitor;

    // Factory Registration

    `uvm_component_utils(apb_monitor)

    // Configuration

    bridge_config cfg;

    // Virtual Interface

    virtual apb_if vif;

    // Analysis Port

    uvm_analysis_port #(apb_transaction) ap;

    // Constructor

    function new(string name = "apb_monitor",uvm_component parent = null);
        super.new(name, parent);

        ap = new("ap", this);

    endfunction

    // Build Phase

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(bridge_config)::get(
                this,
                "",
                "bridge_cfg",
                cfg))
        begin

            `uvm_fatal(
                get_type_name(),
                "bridge_config not found"
            )

        end

     vif = cfg.apb_vif;

    endfunction

    // Run Phase

    task run_phase(uvm_phase phase);

        apb_transaction tr;

        forever begin

            @(vif.mon_cb);

            if (vif.mon_cb.PSEL &&
                vif.mon_cb.PENABLE)
            begin
            
                tr = apb_transaction::type_id::create("tr");
            
                tr.pwrite = vif.mon_cb.PWRITE;
                tr.paddr  = vif.mon_cb.PADDR;
                tr.pwdata = vif.mon_cb.PWDATA;

            // WRITE
            
                if (tr.pwrite)
                begin

                    do begin
                        @(vif.mon_cb);
                    end
                    while (!(vif.mon_cb.PSEL &&
                             vif.mon_cb.PENABLE &&
                             vif.mon_cb.PREADY));
                
                    tr.pslverr = vif.mon_cb.PSLVERR;
                                
                    ap.write(tr);

                    `uvm_info(
                        get_type_name(),
                        $sformatf(
                            "APB WRITE ADDR=%08h DATA=%08h RESP=%0b",
                            tr.paddr,
                            tr.pwdata,
                            tr.pslverr
                        ),
                        UVM_MEDIUM
                    )

                end

            
                // READ
            
                else
                begin

                    //------------------------------------------------
                    // IMPORTANT:
                    // Do NOT sample PRDATA when PREADY=0.
                    //
                    // Wait for actual completion.
                    //------------------------------------------------
                    do begin
                        @(vif.mon_cb);
                    end
                    while (!(vif.mon_cb.PSEL &&
                             vif.mon_cb.PENABLE &&
                             vif.mon_cb.PREADY));

                    //------------------------------------------------
                    // Now PRDATA is valid
                    //------------------------------------------------
                    tr.prdata  = vif.mon_cb.PRDATA;
                    tr.pslverr = vif.mon_cb.PSLVERR;

                    //------------------------------------------------
                    // Send transaction
                    //------------------------------------------------
                    ap.write(tr);

                    `uvm_info(
                        get_type_name(),
                        $sformatf(
                            "APB READ ADDR=%08h DATA=%08h RESP=%0b",
                            tr.paddr,
                            tr.prdata,
                            tr.pslverr
                        ),
                        UVM_MEDIUM
                    )

                end

            end

        end

    endtask

endclass

`endif