`ifndef BRIDGE_CONFIG_SV
`define BRIDGE_CONFIG_SV

typedef enum {
    REGRESSION,
    SINGLE_WRITE,
    SINGLE_READ,
    MULTIPLE_WRITE,
    MULTIPLE_READ,
    WRITE_READ,
    FIFO_FULL,
    FIFO_EMPTY,
    WAIT_STATE,
    CLOCK_RATIO,
    RANDOM_RW,
    BACK_TO_BACK,
    BOUNDARY_ADDRESS,
    DATA_PATTERN,
    RESET_DURING_TRANSFER,
} coverage_mode_e;

class bridge_config extends uvm_object;
    `uvm_object_utils(bridge_config)

    virtual ahb_if ahb_vif;
    virtual apb_if apb_vif;

    coverage_mode_e cov_mode;

    int wait_cycles = 0;
    int hclk_period = 10;
    int pclk_period = 10;

    bit enable_coverage   = 1;
    bit enable_assertions = 1;
    bit back_to_back_mode = 0;

    function new(string name="bridge_config");
        super.new(name);
        cov_mode = REGRESSION;
    endfunction
endclass

`endif
