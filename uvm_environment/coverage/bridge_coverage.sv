`ifndef BRIDGE_COVERAGE_SV
`define BRIDGE_COVERAGE_SV

class bridge_coverage extends uvm_subscriber #(ahb_transaction);
    
    // Factory Registration
    
    `uvm_component_utils(bridge_coverage)

    // Transaction
   
    ahb_transaction tr;

    // Configuration
   
    bridge_config cfg;

    // Coverage Mode
   
    coverage_mode_e cov_mode;

    // Additional coverage for added regression tests

    covergroup back_to_back_cg;
        option.per_instance = 1;
        cp_rw: coverpoint tr.hwrite { bins RD={0}; bins WR={1}; }
        cp_addr: coverpoint tr.haddr[9:2] { bins ALL={[0:255]}; }
    endgroup

    covergroup boundary_address_cg;
        option.per_instance = 1;
        cp_addr: coverpoint tr.haddr[9:2] {
            bins boundary[] = {0,63,64,127,128,255};
        }
    endgroup

    covergroup data_pattern_cg;
        option.per_instance = 1;
        cp_data: coverpoint tr.hwdata {
            bins ZERO={32'h00000000};
            bins ONES={32'hffffffff};
            bins ALT1={32'haaaaaaaa};
            bins ALT2={32'h55555555};
        }
    endgroup

    covergroup bridge_cg;
        option.per_instance = 1;
        option.name = "bridge_cg";
        cp_rw : coverpoint tr.hwrite {
            bins READ  = {0};
            bins WRITE = {1};
        }
        cp_htrans : coverpoint tr.htrans {
            bins NONSEQ = {2'b10};
            bins SEQ    = {2'b11};
            ignore_bins IDLE = {2'b00};
            ignore_bins BUSY = {2'b01};
        }
        cp_hsize : coverpoint tr.hsize {
            bins BYTE = {3'b000};
            bins HALF = {3'b001};
            bins WORD = {3'b010};
            ignore_bins RESERVED = {[3'b011:3'b111]};
        }
        cp_addr : coverpoint tr.haddr[9:2] {
            bins LOW  = {[0:63]};
            bins MID  = {[64:127]};
            bins HIGH = {[128:255]};
        }
        cp_resp : coverpoint tr.hresp {
            bins OKAY  = {2'b00};
            bins ERROR = {2'b01};
        }
        rw_addr_cross :
            cross cp_rw, cp_addr;
        rw_size_cross :
            cross cp_rw, cp_hsize;
        rw_trans_cross :
            cross cp_rw, cp_htrans;
        rw_resp_cross :
            cross cp_rw, cp_resp;
    endgroup

    covergroup write_cg;

        option.per_instance = 1;
        option.name = "write_cg";
        cp_htrans : coverpoint tr.htrans {
            bins NONSEQ = {2'b10};
            bins SEQ    = {2'b11};
        }
        cp_hsize : coverpoint tr.hsize {
            bins BYTE = {3'b000};
            bins HALF = {3'b001};
            bins WORD = {3'b010};
        }
        cp_addr : coverpoint tr.haddr[9:2] {
            bins LOW  = {[0:63]};
            bins MID  = {[64:127]};
            bins HIGH = {[128:255]};
        }
        cp_resp : coverpoint tr.hresp {
            bins OKAY  = {2'b00};
            bins ERROR = {2'b01};
        }
        addr_trans :
            cross cp_addr, cp_htrans;
        addr_size :
            cross cp_addr, cp_hsize;
        addr_resp :
            cross cp_addr, cp_resp;

    endgroup

    covergroup read_cg;
        option.per_instance = 1;
        option.name = "read_cg";
        cp_htrans : coverpoint tr.htrans {
            bins NONSEQ = {2'b10};
            bins SEQ    = {2'b11};
        }
        cp_hsize : coverpoint tr.hsize {
            bins BYTE = {3'b000};
            bins HALF = {3'b001};
            bins WORD = {3'b010};
        }
        cp_addr : coverpoint tr.haddr[9:2] {
            bins LOW  = {[0:63]};
            bins MID  = {[64:127]};
            bins HIGH = {[128:255]};
        }
        cp_resp : coverpoint tr.hresp {
            bins OKAY  = {2'b00};
            bins ERROR = {2'b01};
        }
        addr_trans :
            cross cp_addr, cp_htrans;
        addr_size :
            cross cp_addr, cp_hsize;
        addr_resp :
            cross cp_addr, cp_resp;
    endgroup

    covergroup write_read_cg;
        option.per_instance = 1;
        option.name = "write_read_cg";
        cp_rw : coverpoint tr.hwrite {
            bins WRITE = {1};
            bins READ  = {0};
        }
        cp_addr : coverpoint tr.haddr[9:2] {
            bins LOW  = {[0:63]};
            bins MID  = {[64:127]};
            bins HIGH = {[128:255]};
        }
        cp_resp : coverpoint tr.hresp {
            bins OKAY  = {2'b00};
            bins ERROR = {2'b01};
        }
        rw_addr :
            cross cp_rw, cp_addr;
        rw_resp :
            cross cp_rw, cp_resp;
    endgroup

    covergroup fifo_full_cg;
        option.per_instance = 1;
        option.name = "fifo_full_cg";
        cp_write : coverpoint tr.hwrite {
            bins WRITE = {1};
        }
        cp_htrans : coverpoint tr.htrans {
            bins NONSEQ = {2'b10};
            bins SEQ    = {2'b11};
        }
        cp_hsize : coverpoint tr.hsize {

            bins BYTE = {3'b000};
            bins HALF = {3'b001};
            bins WORD = {3'b010};
        }
        cp_addr : coverpoint tr.haddr[9:2] {
            bins LOW  = {[0:63]};
            bins MID  = {[64:127]};
            bins HIGH = {[128:255]};
        }
        cp_resp : coverpoint tr.hresp {
            bins OKAY  = {2'b00};
            bins ERROR = {2'b01};
        }
        addr_size :
            cross cp_addr, cp_hsize;
        addr_trans :
            cross cp_addr, cp_htrans;
    endgroup

    covergroup fifo_empty_cg;
        option.per_instance = 1;
        option.name = "fifo_empty_cg";
        cp_rw : coverpoint tr.hwrite {
            bins READ  = {0};
            bins WRITE = {1};
        }
        cp_htrans : coverpoint tr.htrans {
            bins NONSEQ = {2'b10};
            bins SEQ    = {2'b11};
        }
        cp_addr : coverpoint tr.haddr[9:2] {
            bins LOW  = {[0:63]};
            bins MID  = {[64:127]};
            bins HIGH = {[128:255]};
        }
        cp_resp : coverpoint tr.hresp {
            bins OKAY  = {2'b00};
            bins ERROR = {2'b01};
        }
        rw_addr :
            cross cp_rw, cp_addr;
        rw_trans :
            cross cp_rw, cp_htrans;
    endgroup

    covergroup wait_state_cg;
        option.per_instance = 1;
        option.name = "wait_state_cg";
        cp_rw : coverpoint tr.hwrite {
            bins READ  = {0};
            bins WRITE = {1};
        }

        cp_htrans : coverpoint tr.htrans {
            bins NONSEQ = {2'b10};
            bins SEQ    = {2'b11};
        }

        cp_hsize : coverpoint tr.hsize {
            bins BYTE = {3'b000};
            bins HALF = {3'b001};
            bins WORD = {3'b010};
        }
        rw_trans :
            cross cp_rw, cp_htrans;
    endgroup

    covergroup clock_ratio_cg;
        option.per_instance = 1;
        option.name = "clock_ratio_cg";
        cp_rw : coverpoint tr.hwrite {
            bins READ  = {0};
            bins WRITE = {1};
        }
        cp_htrans : coverpoint tr.htrans {
            bins NONSEQ = {2'b10};
            bins SEQ    = {2'b11};
        }
        cp_addr : coverpoint tr.haddr[9:2] {
            bins LOW  = {[0:63]};
            bins MID  = {[64:127]};
            bins HIGH = {[128:255]};
        }
        rw_addr :
            cross cp_rw, cp_addr;
    endgroup

    covergroup reset_during_transfer_cg;
        option.per_instance = 1;
        option.name = "reset_during_transfer_cg";
            cp_rw : coverpoint tr.hwrite {
                bins READ  = {0};
                bins WRITE = {1};
           }
            cp_htrans : coverpoint tr.htrans {
                bins NONSEQ = {2'b10};
                bins SEQ    = {2'b11};
            }
            cp_hsize : coverpoint tr.hsize {
                bins BYTE = {3'b000};
                bins HALF = {3'b001};
                bins WORD = {3'b010};
            }
            cp_addr : coverpoint tr.haddr[9:2] {
                bins LOW  = {[0:63]};
                bins MID  = {[64:127]};
                bins HIGH = {[128:255]};
            }
            cp_resp : coverpoint tr.hresp {
                bins OKAY  = {2'b00};
                bins ERROR = {2'b01};
            }
            rw_addr  : cross cp_rw, cp_addr;
            rw_size  : cross cp_rw, cp_hsize;
            rw_trans : cross cp_rw, cp_htrans;
        endgroup
   
   // CONSTRUCTOR
    
    function new(
        string name = "bridge_coverage", uvm_component parent = null );
        super.new(name, parent);

        bridge_cg      = new();
        write_cg       = new();
        read_cg        = new();
        write_read_cg  = new();
        fifo_full_cg   = new();
        fifo_empty_cg  = new();
        wait_state_cg  = new();
        clock_ratio_cg = new();
	    reset_during_transfer_cg = new();

    endfunction

    // BUILD PHASE

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(bridge_config)::get(
                this,
                "",
                "bridge_cfg",
                cfg
        )) begin

            `uvm_fatal(
                "COV",
                "Bridge Config Not Found"
            )

        end

        cov_mode = cfg.cov_mode;

        `uvm_info(
            "COV",
            $sformatf(
                "Coverage Mode = %s",
                cov_mode.name()
            ),
            UVM_LOW
        )

    endfunction

    //ahb write

    function void write(ahb_transaction t);

        if (t == null) begin

            `uvm_warning(
                "COV",
                "NULL transaction received"
            )
            return;
        end
        tr = t;

        // Select covergroup
    
        case (cov_mode)

            REGRESSION: begin
                bridge_cg.sample();
            end

            RANDOM_RW: begin
                bridge_cg.sample();
            end

            BACK_TO_BACK: begin
                back_to_back_cg.sample();
            end

            DATA_PATTERN: begin
                data_pattern_cg.sample();
            end

            BOUNDARY_ADDRESS: begin
                boundary_address_cg.sample();
            end

            SINGLE_WRITE: begin
                if (tr.hwrite)
                    write_cg.sample();
            end

            SINGLE_READ: begin
                if (!tr.hwrite)
                    read_cg.sample();
            end

            MULTIPLE_WRITE: begin
                if (tr.hwrite)
                    write_cg.sample();
            end

            MULTIPLE_READ: begin
                if (!tr.hwrite)
                    read_cg.sample();
            end

            WRITE_READ: begin
                write_read_cg.sample();
            end

            FIFO_FULL: begin
                fifo_full_cg.sample();
            end

            FIFO_EMPTY: begin
                fifo_empty_cg.sample();
            end

            WAIT_STATE: begin
                wait_state_cg.sample();
            end

            CLOCK_RATIO: begin
               clock_ratio_cg.sample();
            end
        
		    RESET_DURING_TRANSFER: begin
                reset_during_transfer_cg.sample();
            end

            default: begin
                bridge_cg.sample();
            end

        endcase
    endfunction

    // GET COVERAGE

    function real get_cov();

        case (cov_mode)

            REGRESSION,
            RANDOM_RW:
                return bridge_cg.get_coverage();

            BACK_TO_BACK:
                return back_to_back_cg.get_coverage();

            BOUNDARY_ADDRESS:
                return boundary_address_cg.get_coverage();

            DATA_PATTERN:
                return data_pattern_cg.get_coverage();

            SINGLE_WRITE,
            MULTIPLE_WRITE:
                return write_cg.get_coverage();

            SINGLE_READ,
            MULTIPLE_READ:
                return read_cg.get_coverage();

            WRITE_READ:
                return write_read_cg.get_coverage();

            FIFO_FULL:
                return fifo_full_cg.get_coverage();

            FIFO_EMPTY:
                return fifo_empty_cg.get_coverage();

            WAIT_STATE:
                return wait_state_cg.get_coverage();

            CLOCK_RATIO:
                return clock_ratio_cg.get_coverage();

	        RESET_DURING_TRANSFER:
	             return reset_during_transfer_cg.get_coverage();

            default:
                return bridge_cg.get_coverage();

        endcase
    endfunction

    // REPORT PHASE

    function void report_phase(uvm_phase phase);

        real cov;
        super.report_phase(phase);
        cov = get_cov();
        `uvm_info(
            "COVERAGE",
            "==============================================",
            UVM_NONE
        )

        case (cov_mode)

            REGRESSION: begin
                `uvm_info(
                    "COVERAGE",
                    $sformatf(
                        "Regression Coverage : %0.2f%%",
                        cov
                    ),
                    UVM_NONE
                )

            end

            RANDOM_RW: begin

                `uvm_info(
                    "COVERAGE",
                    $sformatf(
                        "Random RW Coverage : %0.2f%%",
                        cov
                    ),
                    UVM_NONE
                )

            end

            BOUNDARY_ADDRESS: begin

                `uvm_info(
                    "COVERAGE",
                    $sformatf(
                        "Boundary Address Coverage : %0.2f%%",
                        cov
                    ),
                    UVM_NONE
                )

            end

            SINGLE_WRITE: begin

                `uvm_info(
                    "COVERAGE",
                    $sformatf(
                        "Single Write Coverage : %0.2f%%",
                        cov
                    ),
                    UVM_NONE
                )

            end

            SINGLE_READ: begin

                `uvm_info(
                    "COVERAGE",
                    $sformatf(
                        "Single Read Coverage : %0.2f%%",
                        cov
                    ),
                    UVM_NONE
                )

            end

            MULTIPLE_WRITE: begin

                `uvm_info(
                    "COVERAGE",
                    $sformatf(
                        "Multiple Write Coverage : %0.2f%%",
                        cov
                    ),
                    UVM_NONE
                )

            end

            MULTIPLE_READ: begin

                `uvm_info(
                    "COVERAGE",
                    $sformatf(
                        "Multiple Read Coverage : %0.2f%%",
                        cov
                    ),
                    UVM_NONE
                )

            end

            WRITE_READ: begin

                `uvm_info(
                    "COVERAGE",
                    $sformatf(
                        "Write Read Coverage : %0.2f%%",
                        cov
                    ),
                    UVM_NONE
                )

            end

            FIFO_FULL: begin

                `uvm_info(
                    "COVERAGE",
                    $sformatf(
                        "FIFO Full Coverage : %0.2f%%",
                        cov
                    ),
                    UVM_NONE
                )

            end

            FIFO_EMPTY: begin

                `uvm_info(
                    "COVERAGE",
                    $sformatf(
                        "FIFO Empty Coverage : %0.2f%%",
                        cov
                    ),
                    UVM_NONE
                )

            end

            WAIT_STATE: begin

                `uvm_info(
                    "COVERAGE",
                    $sformatf(
                        "Wait State Coverage : %0.2f%%",
                        cov
                    ),
                    UVM_NONE
                )

            end

            CLOCK_RATIO: begin

                `uvm_info(
                    "COVERAGE",
                    $sformatf(
                        "Clock Ratio Coverage : %0.2f%%",
                        cov
                    ),
                    UVM_NONE
                )

            end
	

	        RESET_DURING_TRANSFER: begin

             `uvm_info(
                "COVERAGE",
                $sformatf(
                    "Reset During Transfer Coverage : %0.2f%%",
                    cov
                ),
                UVM_NONE
            );

            end

            default: begin

                `uvm_info(
                    "COVERAGE",
                    $sformatf(
                        "Coverage : %0.2f%%",
                        cov
                    ),
                    UVM_NONE
                )
            end

        endcase

        `uvm_info(
            "COVERAGE",
            "==============================================",
            UVM_NONE
        )

    endfunction

endclass

`endif