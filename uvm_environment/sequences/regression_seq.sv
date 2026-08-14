`ifndef REGRESSION_SEQ_SV
`define REGRESSION_SEQ_SV

class regression_seq extends base_sequence;

    `uvm_object_utils(regression_seq)

    single_write_seq     sw_seq;
    single_read_seq      sr_seq;
    multiple_write_seq   mw_seq;
    multiple_read_seq    mr_seq;
    write_read_seq       wr_seq;
    fifo_full_seq        ff_seq;
    fifo_empty_seq       fe_seq;
    wait_state_seq       ws_seq;
    clock_ratio_seq      cr_seq;
    random_rw_seq        rand_seq;
    back_to_back_seq     b2b_seq;
    boundary_address_seq boundary_seq;
    data_pattern_seq     data_seq;
    reset_during_transfer_seq reset_seq;

    function new(string name="regression_seq");
        super.new(name);
    endfunction

    task body();

        sw_seq = single_write_seq::type_id::create("sw_seq");
        sw_seq.start(m_sequencer);

        sr_seq = single_read_seq::type_id::create("sr_seq");
        sr_seq.start(m_sequencer);

        mw_seq = multiple_write_seq::type_id::create("mw_seq");
        mw_seq.start(m_sequencer);

        mr_seq = multiple_read_seq::type_id::create("mr_seq");
        mr_seq.start(m_sequencer);

        wr_seq = write_read_seq::type_id::create("wr_seq");
        wr_seq.start(m_sequencer);

        ff_seq = fifo_full_seq::type_id::create("ff_seq");
        ff_seq.start(m_sequencer);

        fe_seq = fifo_empty_seq::type_id::create("fe_seq");
        fe_seq.start(m_sequencer);

        ws_seq = wait_state_seq::type_id::create("ws_seq");
        ws_seq.start(m_sequencer);

        cr_seq = clock_ratio_seq::type_id::create("cr_seq");
        cr_seq.start(m_sequencer);

        rand_seq = random_rw_seq::type_id::create("rand_seq");
        rand_seq.start(m_sequencer);

        b2b_seq = back_to_back_seq::type_id::create("b2b_seq");
        b2b_seq.start(m_sequencer);

        boundary_seq = boundary_address_seq::type_id::create("boundary_seq");
        boundary_seq.start(m_sequencer);

        data_seq = data_pattern_seq::type_id::create("data_seq");
        data_seq.start(m_sequencer);

        reset_seq = reset_during_transfer_seq::type_id::create("reset_seq");
        reset_seq.start(m_sequencer);

    endtask

endclass

`endif
