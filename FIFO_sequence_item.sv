package FIFO_sequence_item;
import uvm_pkg::*;
`include "uvm_macros.svh"
class FIFO_sequence_item extends uvm_sequence_item;
`uvm_object_utils(FIFO_sequence_item)
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
rand logic [FIFO_WIDTH-1:0] data_in;
rand logic  rst_n, wr_en, rd_en;
logic [FIFO_WIDTH-1:0] data_out;
logic wr_ack, overflow;
logic full, empty, almostfull, almostempty, underflow;
    function new(string name = "FIFO_sequence_item");
        super.new(name);
    endfunction 

    

    constraint assert_reset{
        rst_n dist{0:=5,1:=95};
    } 

    constraint write_enable{
        wr_en dist{1:=100,0:=0};
        rd_en dist{1:=0,0:=100};
    }

    constraint read_enable{
        wr_en dist{1:=0,0:=100};
        rd_en dist{1:=100,0:=0};
    }

    constraint write_read_enable{
        wr_en dist{1:=100,0:=0};
        rd_en dist{1:=100,0:=0};
    }
    constraint write_read_unable{
        wr_en dist{0:=100,1:=0};
        rd_en dist{0:=100,1:=0};
    }

endclass 

endpackage