`ifndef BRIDGE_ENV_SV
`define BRIDGE_ENV_SV

class bridge_env extends uvm_env;

    // Factory Registration

    `uvm_component_utils(bridge_env)

    // Environment Components

    ahb_agent          ahb_agnt;
    apb_agent          apb_agnt;
    bridge_scoreboard  sb;
    bridge_coverage    cov;

    // Constructor

    function new(string name = "bridge_env",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        ahb_agnt = ahb_agent::type_id::create("ahb_agnt",this);
        apb_agnt = apb_agent::type_id::create("apb_agnt",this);
        sb       = bridge_scoreboard::type_id::create("sb",this);
        cov      = bridge_coverage::type_id::create("cov",this);

        uvm_config_db#(bridge_coverage)::set(
            this,
            "sb",
            "coverage_handle",
            cov
        );

    endfunction

    // Connect Phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        ahb_agnt.mon.ap.connect(sb.ahb_imp);
        ahb_agnt.mon.ap.connect(cov.analysis_export);
        apb_agnt.mon.ap.connect(sb.apb_imp);

    endfunction

endclass

`endif
