`ifndef BASE_TEST_SV
`define BASE_TEST_SV

class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    bridge_env     env;
    bridge_config  cfg;

    function new(string name="base_test",uvm_component parent=null);
            super.new(name,parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db#(bridge_config)::get(this,"","bridge_cfg",cfg))
        begin
            `uvm_fatal("CFG","Bridge configuration not found")
        end

        if(cfg == null)
            `uvm_fatal("CFG","Bridge configuration is NULL")

        env = bridge_env::type_id::create("env",this);

    endfunction


    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

endclass

`endif