package FIFO_sequence_read_enable;

    
import uvm_pkg::*;
import FIFO_sequence_item::*;
`include "uvm_macros.svh"

class FIFO_sequence_read_enable extends uvm_sequence#(FIFO_sequence_item);
    `uvm_object_utils(FIFO_sequence_read_enable)
    FIFO_sequence_item sqr_item;
    function new(string name = "FIFO_sequence_read_enable");
        super.new(name);
    endfunction 

    task body;
       repeat(10)begin
        
        sqr_item = FIFO_sequence_item::type_id::create("sqr_item");
        sqr_item.constraint_mode(0);
        sqr_item.read_enable.constraint_mode(1);
        sqr_item.assert_reset.constraint_mode(1);
        start_item(sqr_item);
        assert(sqr_item.randomize());
        finish_item(sqr_item);
       end 
    endtask
endclass 


    
endpackage