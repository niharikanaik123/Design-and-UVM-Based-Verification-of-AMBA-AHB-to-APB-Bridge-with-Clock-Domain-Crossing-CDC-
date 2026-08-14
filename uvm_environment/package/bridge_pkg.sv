`ifndef BRIDGE_PKG_SV
`define BRIDGE_PKG_SV

package bridge_pkg;

    // UVM Package

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // RTL Package

    import ahb_apb_pkg::*;

    // Configuration

    `include "bridge_config.sv"

    // Transactions

    `include "ahb_transaction.sv"
    `include "apb_transaction.sv"

    // Sequencer

    `include "ahb_sequencer.sv"

    // Sequences

    `include "base_sequence.sv"
    `include "reset_sequence.sv"
    `include "single_write_seq.sv"
    `include "single_read_seq.sv"
    `include "multiple_write_seq.sv"
    `include "multiple_read_seq.sv"
    `include "write_read_seq.sv"
    `include "fifo_full_seq.sv"
    `include "fifo_empty_seq.sv"
    `include "wait_state_seq.sv"
    `include "clock_ratio_seq.sv"
    `include "regression_seq.sv"
    `include "random_rw_seq.sv"
    `include "back_to_back_seq.sv"
    `include "boundary_address_seq.sv"
    `include "data_pattern_seq.sv"
    `include "reset_during_transfer_seq.sv"

    // Driver

    `include "ahb_driver.sv"

    // Monitors

    `include "ahb_monitor.sv"
    `include "apb_monitor.sv"

    // Agents

    `include "ahb_agent.sv"
    `include "apb_agent.sv"

    // Functional Coverage

    `include "bridge_coverage.sv"

    // Scoreboard

    `include "bridge_scoreboard.sv"

    // Environment

    `include "bridge_env.sv"

    // Tests

    `include "base_test.sv"
    `include "reset_test.sv"
    `include "single_write_test.sv"
    `include "single_read_test.sv"
    `include "multiple_write_test.sv"
    `include "multiple_read_test.sv"
    `include "write_read_test.sv"
    `include "fifo_full_test.sv"
    `include "fifo_empty_test.sv"
    `include "wait_state_test.sv"
    `include "clock_ratio_test.sv"
    `include "regression_test.sv"
    `include "random_rw_test.sv"
    `include "back_to_back_test.sv"
    `include "boundary_address_test.sv"
    `include "data_pattern_test.sv"
    `include "reset_during_transfer_test.sv"

endpackage

`endif