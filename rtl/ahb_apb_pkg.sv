package ahb_apb_pkg;

    typedef struct packed {
        logic hwrite;           //0 => read  & 1 => write
        logic [31:0] haddr;     
        logic [31:0] hwdata;     
        logic [2:0] hsize;      // size of package
        logic [1:0] htrans;     // state of master
        
    } ahb_packet_t;

    parameter int FIFO_WIDTH = $bits(ahb_packet_t); // 70 bits

endpackage : ahb_apb_pkg
