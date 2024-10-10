package FIFO_monitor;
import uvm_pkg::*;
import FIFO_config::*;
import FIFO_sequence_item::*;
`include "uvm_macros.svh"
class FIFO_monitor extends uvm_monitor;
    `uvm_component_utils(FIFO_monitor)
    virtual FIFO_if FIFO_vif;
    
    FIFO_sequence_item seq_item;
    uvm_analysis_port#(FIFO_sequence_item)mon_ap;
    function new(string name = "FIFO_monitor", uvm_component parent =null);
        super.new(name,parent);
    endfunction 
   
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_ap=new("mon_ap",this);
    endfunction
    

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            seq_item=FIFO_sequence_item::type_id::create("seq_item");


            seq_item.rst_n= FIFO_vif.rst_n;
            seq_item.wr_en=FIFO_vif.wr_en;
            seq_item.rd_en=FIFO_vif.rd_en;
            seq_item.data_in=FIFO_vif.data_in;
            seq_item.data_out=FIFO_vif.data_out;
            seq_item.wr_ack=FIFO_vif.wr_ack;
            seq_item.full=FIFO_vif.full;
            seq_item.almostfull=FIFO_vif.almostfull;
            seq_item.empty=FIFO_vif.empty;
            seq_item.almostempty=FIFO_vif.almostempty;
            seq_item.underflow=FIFO_vif.underflow;
            seq_item.overflow=FIFO_vif.overflow;
            
            @(negedge FIFO_vif.clk);
            mon_ap.write(seq_item);
        end
    endtask : run_phase
endclass 
endpackage  