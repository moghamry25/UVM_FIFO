import FIFO_test::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
module FIFO_top();
    bit clk;
    initial begin
        forever begin
            #1 clk =~clk;
        end
    end
   
    FIFO_if vif(clk);
    FIFO DUT(vif.data_in, vif.wr_en, vif.rd_en, clk, vif.rst_n,
     vif.full, vif.empty, vif.almostfull, vif.almostempty,
      vif.wr_ack, vif.overflow, vif.underflow, vif.data_out);
    bind FIFO FIFO_sva FIFO_sva_inst(clk,vif.rst_n,vif.wr_en,vif.wr_ack,vif.rd_en
    ,vif.full,vif.almostfull,vif.almostempty,vif.empty,vif.overflow,vif.underflow,DUT.count);
    initial begin
        uvm_config_db#(virtual FIFO_if )::set(null,"uvm_test_top","FIFO_SET",vif);
        run_test("FIFO_test");   
    end

endmodule