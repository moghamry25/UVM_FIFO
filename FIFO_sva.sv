module FIFO_sva (
    input logic clk,
    input logic rst_n,
    input logic wr_en,
    input logic wr_ack,
    input logic rd_en,
    input logic full,
    input logic almostfull,
    input logic almostempty,
    input logic empty,
    input logic overflow,
    input logic underflow,
     logic [3:0] count
);
parameter FIFO_DEPTH = 8;
Almostempty:assert property (@(posedge clk) (count==1) |-> (almostempty==1));
Almostfull:assert property (@(posedge clk) (count == FIFO_DEPTH-1) |-> (almostfull==1));
Empty:assert property (@(posedge clk) (!count ) |-> (empty==1));
Full:assert property (@(posedge clk) (count == FIFO_DEPTH) |-> (full==1));
Overflow:assert property (@(posedge clk) disable iff(!rst_n)(full && wr_en && !rd_en) |=> overflow == 1);
Underflow:assert property (@(posedge clk)disable iff(!rst_n) (rd_en&&!wr_en&&empty) |=>underflow==1);
Wr_Ack:assert property(@(posedge clk)disable iff(!rst_n ||(!wr_en&&!rd_en)) (full |=> !wr_ack));
endmodule
