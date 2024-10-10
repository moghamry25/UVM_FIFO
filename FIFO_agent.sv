package FIFO_agent;

import uvm_pkg::*;
import FIFO_driver::*;
import FIFO_sequencer::*;
import FIFO_config::*;
import FIFO_monitor::*;
import FIFO_sequence_item::*;

`include "uvm_macros.svh"

class FIFO_agent extends uvm_agent;
`uvm_component_utils(FIFO_agent)
    FIFO_driver driver;
    FIFO_sequencer sqr;
    FIFO_config cfg;
    FIFO_monitor mon;
    uvm_analysis_port#(FIFO_sequence_item)agt_ap;
    function new(string name = "FIFO_agent",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#( FIFO_config)::get(this,"","CFG",cfg))
            `uvm_fatal("build phase","Test unable to get the virtual interface of the FIFO");
        driver = FIFO_driver::type_id::create("driver",this);
        sqr = FIFO_sequencer::type_id::create("sqr",this);
        mon = FIFO_monitor::type_id::create("mon",this);
        agt_ap=new("agt_ap",this);
    endfunction

    function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
        driver.FIFO_vif = cfg.FIFO_vif;
        mon.FIFO_vif = cfg.FIFO_vif;
        driver.seq_item_port.connect(sqr.seq_item_export);
        mon.mon_ap.connect(agt_ap);
    endfunction

endclass
endpackage