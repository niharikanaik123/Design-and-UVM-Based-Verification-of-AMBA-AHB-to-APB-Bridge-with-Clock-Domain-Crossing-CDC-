`ifndef APB_AGENT_SV
`define APB_AGENT_SV

class apb_agent extends uvm_agent;

    // Factory Registration
  
    `uvm_component_utils(apb_agent)
    
    // Components
   
    apb_monitor mon;
   
    // Constructor
    
    function new(string name = "apb_agent",uvm_component parent = null);
        super.new(name,parent);

    endfunction

    // Build Phase
  
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        mon = apb_monitor::type_id::create("mon",this);

    endfunction

endclass

`endif
