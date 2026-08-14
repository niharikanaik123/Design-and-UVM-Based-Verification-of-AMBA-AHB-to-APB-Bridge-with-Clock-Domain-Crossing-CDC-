`ifndef AHB_AGENT_SV
`define AHB_AGENT_SV

class ahb_agent extends uvm_agent;

    // Factory Registration

    `uvm_component_utils(ahb_agent)

    // Components

    ahb_driver     drv;
    ahb_sequencer  seqr;
    ahb_monitor    mon;

    // Constructor

    function new(string name = "ahb_agent",uvm_component parent = null);
             super.new(name, parent);

    endfunction

    // Build Phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        drv  = ahb_driver    ::type_id::create("drv", this);
        seqr = ahb_sequencer ::type_id::create("seqr", this);
        mon  = ahb_monitor   ::type_id::create("mon", this);

    endfunction

    // Connect Phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        drv.seq_item_port.connect(seqr.seq_item_export);

    endfunction

endclass

`endif
