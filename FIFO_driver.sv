package FIFO_driver;
import uvm_pkg::*;
import FIFO_config::*;
import FIFO_sequence_item::*;
`include "uvm_macros.svh"
class FIFO_driver extends uvm_driver#(FIFO_sequence_item);
    `uvm_component_utils(FIFO_driver)
    virtual FIFO_if FIFO_vif;
    
    FIFO_sequence_item seq_item;
    function new(string name = "FIFO_driver", uvm_component parent =null);
        super.new(name,parent);
    endfunction 
   

    

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            seq_item=FIFO_sequence_item::type_id::create("seq_item");
            seq_item_port.get_next_item(seq_item);

            FIFO_vif.rst_n=seq_item.rst_n;
            FIFO_vif.wr_en=seq_item.wr_en;
            FIFO_vif.rd_en=seq_item.rd_en;
            FIFO_vif.data_in=$random;
            
            @(negedge FIFO_vif.clk);
            seq_item_port.item_done();
        end
    endtask : run_phase
endclass 
endpackage