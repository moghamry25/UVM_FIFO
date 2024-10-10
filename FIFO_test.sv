package FIFO_test;
import FIFO_env::*;
import uvm_pkg::*;
import FIFO_config::*;
import FIFO_sequence_write_enable::*;
import FIFO_sequence_read_enable::*;
import FIFO_sequence_write_read_enable::*;
import FIFO_sequence_write_read_unable::*;
import FIFO_sequence_reset::*;
import FIFO_sequence_random::*;
`include "uvm_macros.svh"
class FIFO_test extends uvm_test;
    `uvm_component_utils(FIFO_test)
    FIFO_env env;
    FIFO_config cfg;
    FIFO_sequence_reset sqr_reset;
    FIFO_sequence_write_enable sqr_write;
    FIFO_sequence_read_enable sqr_read;
    FIFO_sequence_write_read_enable sqr_write_read;
    FIFO_sequence_write_read_unable sqr_wr_rd_unable;
    FIFO_sequence_random sqr_random;
    function new(string name ="FIFO_test",uvm_component parent = null);
        super.new(name,parent);
    endfunction 
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = FIFO_env::type_id::create("env",this);
        cfg = FIFO_config::type_id::create("cfg",this);
        sqr_reset=FIFO_sequence_reset::type_id::create("sqr_reset");
        sqr_write=FIFO_sequence_write_enable::type_id::create("sqr_write");
        sqr_read=FIFO_sequence_read_enable::type_id::create("sqr_read");
        sqr_write_read=FIFO_sequence_write_read_enable::type_id::create("sqr_write_read");
        sqr_wr_rd_unable=FIFO_sequence_write_read_unable::type_id::create("sqr_wr_rd_unable");
        sqr_random=FIFO_sequence_random::type_id::create("sqr_random");
        if(!uvm_config_db#(virtual FIFO_if)::get(this,"","FIFO_SET",cfg.FIFO_vif))
            `uvm_fatal("build phase","Test unable to get the virtual interface of the FIFO");
        uvm_config_db#(FIFO_config)::set(this,"*","CFG",cfg);
    endfunction
    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);


        `uvm_info("run_phase","Assert reset.",UVM_MEDIUM)
        sqr_reset.start(env.agt.sqr);
        `uvm_info("run_phase","Start write only.",UVM_MEDIUM)        
        sqr_write.start(env.agt.sqr);
        `uvm_info("run_phase","Start read only.",UVM_MEDIUM)        
        sqr_read.start(env.agt.sqr);
        `uvm_info("run_phase","Start write and read.",UVM_MEDIUM)        
        sqr_write_read.start(env.agt.sqr);
        `uvm_info("run_phase","Start unable write and read.",UVM_MEDIUM)        
        sqr_wr_rd_unable.start(env.agt.sqr);
        `uvm_info("run_phase","Start random.",UVM_MEDIUM)        
        sqr_random.start(env.agt.sqr);
        `uvm_info("run_phase","END.",UVM_MEDIUM)        

        phase.drop_objection(this);
    endtask : run_phase
endclass
endpackage