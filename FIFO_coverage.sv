package FIFO_coverage;
import uvm_pkg::*;
import FIFO_sequence_item::*;
`include "uvm_macros.svh"
class FIFO_coverage extends uvm_component;
`uvm_component_utils(FIFO_coverage)
uvm_analysis_export #(FIFO_sequence_item)cov_export;
uvm_tlm_analysis_fifo #(FIFO_sequence_item)cov_fifo;
FIFO_sequence_item sqr_item_cov;
covergroup g1;
        write :     coverpoint sqr_item_cov.wr_en;
        read:       coverpoint sqr_item_cov.rd_en;
        write_ack:  coverpoint sqr_item_cov.wr_ack;
        OVERFFLOW:  coverpoint sqr_item_cov.overflow;
        UNDERFLOW:  coverpoint sqr_item_cov.underflow;
        FULL:       coverpoint sqr_item_cov.full;
        EMPTY:      coverpoint sqr_item_cov.empty;
        Almost_empty:coverpoint sqr_item_cov.almostempty;
        Almost_full:coverpoint sqr_item_cov.almostfull;

        crossofwriteack : cross write,read,write_ack{
            ignore_bins rd = binsof(write)intersect{0}&&binsof(read)intersect{1}&&binsof(write_ack)intersect{1};}
        crossoffull     : cross write,read,FULL{
            ignore_bins rd_full = binsof(write)intersect{0}&&binsof(read)intersect{1}&&binsof(FULL)intersect{1};
            ignore_bins wr_rd_full = binsof(write)intersect{1}&&binsof(read)intersect{1}&&binsof(FULL)intersect{1};}
        crossofempty     : cross write,read,EMPTY{
            ignore_bins wr_empty = binsof(write)intersect{1}&&binsof(read)intersect{0}&&binsof(EMPTY)intersect{1};
            ignore_bins w_r_empty = binsof(write)intersect{1}&&binsof(read)intersect{1}&&binsof(EMPTY)intersect{1};}
        crossofOVERFFLOW     : cross write,read,OVERFFLOW{
            ignore_bins rd_overflow = binsof(write)intersect{0}&&binsof(read)intersect{1}&&binsof(OVERFFLOW)intersect{1};
            ignore_bins w_r_overflow = binsof(write)intersect{1}&&binsof(read)intersect{1}&&binsof(OVERFFLOW)intersect{1};}
        crossofUNDERFLOW     : cross write,read,UNDERFLOW{
            ignore_bins wr_underflow = binsof(write)intersect{1}&&binsof(read)intersect{0}&&binsof(UNDERFLOW)intersect{1};
            ignore_bins wr_rd_underflow = binsof(write)intersect{1}&&binsof(read)intersect{1}&&binsof(UNDERFLOW)intersect{1};}
        crossofAlmost_empty     : cross write,read,Almost_empty;
        crossofAlmost_full     : cross write,read,Almost_full;
endgroup        
    function new(string name = "FIFO_coverage",uvm_component parent = null);
        super.new(name,parent);
        g1=new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cov_export = new("cov_export",this);
        cov_fifo = new("cov_fifo",this);
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        cov_export.connect(cov_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);


        forever begin
            cov_fifo.get(sqr_item_cov);
            g1.sample();
        end
    endtask
endclass

endpackage