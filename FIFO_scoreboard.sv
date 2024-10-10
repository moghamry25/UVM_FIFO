package FIFO_scoreboard;
import uvm_pkg::*;
import FIFO_sequence_item::*;
`include "uvm_macros.svh"
class FIFO_scoreboard extends uvm_scoreboard;
`uvm_component_utils(FIFO_scoreboard)
uvm_analysis_export#(FIFO_sequence_item)sb_export;
uvm_tlm_analysis_fifo#(FIFO_sequence_item)sb_fifo;
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;



    logic  [FIFO_WIDTH-1:0] data_out_ref;
    logic  wr_ack_ref, overflow_ref,full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

    localparam max_fifo_addr = $clog2(FIFO_DEPTH);

    logic [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

    logic [max_fifo_addr-1:0] wr_ptr_ref, rd_ptr_ref;
    logic [max_fifo_addr:0] count_ref;
    FIFO_sequence_item sqr_item;
    int correct_count = 0 ;
    int error_count = 0 ;
    function new(string name ="FIFO_scoreboard" , uvm_component parent = null );
        super.new(name,parent);
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_export=new("sb_export",this);
        sb_fifo = new("sb_fifo",this);
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        sb_export.connect(sb_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
        sb_fifo.get(sqr_item);
        reference_model(sqr_item);

    if ( (data_out_ref != sqr_item.data_out)||
        (wr_ack_ref != sqr_item.wr_ack) || 
        (overflow_ref != sqr_item.overflow) || 
        (underflow_ref != sqr_item.underflow) || 
        (full_ref != sqr_item.full) || 
        (empty_ref != sqr_item.empty) || 
        (almostempty_ref != sqr_item.almostempty) || 
        (almostfull_ref != sqr_item.almostfull)) begin   

        error_count = error_count + 1;
        $display("ERROR DETECTED!!!");
        $display("Expected values: ");

        $display("  wr_ack         = %0b | Received: %0b", wr_ack_ref, sqr_item.wr_ack);
        $display("  overflow       = %0b | Received: %0b", overflow_ref, sqr_item.overflow);
        $display("  underflow      = %0b | Received: %0b", underflow_ref, sqr_item.underflow);
        $display("  full           = %0b | Received: %0b", full_ref, sqr_item.full);
        $display("  empty          = %0b | Received: %0b", empty_ref, sqr_item.empty);
        $display("  almostempty    = %0b | Received: %0b", almostempty_ref, sqr_item.almostempty);
        $display("  almostfull     = %0b | Received: %0b", almostfull_ref, sqr_item.almostfull);
        
        $stop;
    end else begin
        correct_count = correct_count + 1;

    end
    end
    
endtask

task reference_model(FIFO_sequence_item sqr_item);
    
    if (!sqr_item.rst_n) begin
        
        
        full_ref = 0;
        empty_ref = 1;
        almostfull_ref = 0;
        almostempty_ref = 0;
        overflow_ref = 0;
        underflow_ref = 0;
        wr_ack_ref = 0 ;
        wr_ptr_ref = 0 ;
        rd_ptr_ref = 0 ;
        count_ref = 0 ;
    end 
    else begin
        
        if (({sqr_item.wr_en, sqr_item.rd_en} == 2'b11) && empty_ref  ) begin
		mem[wr_ptr_ref] = sqr_item.data_in;
		wr_ack_ref = 1;
		wr_ptr_ref = wr_ptr_ref + 1;
		
	end
    else if (({sqr_item.wr_en, sqr_item.rd_en} == 2'b11) && !empty_ref && !full_ref ) begin
		mem[wr_ptr_ref] = sqr_item.data_in;
		wr_ack_ref = 1;
		wr_ptr_ref = wr_ptr_ref + 1;
		
	end
	else if (({sqr_item.wr_en, sqr_item.rd_en}  == 2'b10) && count_ref < FIFO_DEPTH) begin
		mem[wr_ptr_ref] = sqr_item.data_in;
		wr_ack_ref = 1;
		wr_ptr_ref = wr_ptr_ref + 1;
	end
	else if ({sqr_item.wr_en, sqr_item.rd_en}  == 2'b00) begin
		
	end
	else begin 
		wr_ack_ref = 0; 
		if (full_ref && sqr_item.wr_en&&!sqr_item.rd_en) //3
			overflow_ref = 1;
		else
			overflow_ref = 0;
	end

     if ((({sqr_item.wr_en, sqr_item.rd_en} == 2'b11) && full_ref ) ) begin
		data_out_ref = mem[rd_ptr_ref];
		rd_ptr_ref = rd_ptr_ref + 1;
	end
    else if ((({sqr_item.wr_en, sqr_item.rd_en} == 2'b11) && !full_ref &&!empty_ref ) ) begin
		data_out_ref = mem[rd_ptr_ref];
		rd_ptr_ref = rd_ptr_ref + 1;
	end
	else if ((({sqr_item.wr_en, sqr_item.rd_en} == 2'b11) && !empty_ref ) ) begin
		data_out_ref = mem[rd_ptr_ref];
		rd_ptr_ref = rd_ptr_ref + 1;
		count_ref = count_ref - 1 ; 
	end
	else if (({sqr_item.wr_en, sqr_item.rd_en} == 2'b01) && count_ref != 0&&!empty_ref) begin
		data_out_ref = mem[rd_ptr_ref];
		rd_ptr_ref = rd_ptr_ref + 1;
	end
	else if ({sqr_item.wr_en, sqr_item.rd_en} == 2'b00) begin
		
	end
	else begin
	  if ((!empty_ref && ({sqr_item.wr_en, sqr_item.rd_en} == 2'b11)) ||(({sqr_item.wr_en, sqr_item.rd_en} == 2'b01)&&empty_ref)) begin
		underflow_ref = 1 ;
	  end
	  else begin
		underflow_ref = 0 ; 
	  end
	end

        if	( ({sqr_item.wr_en, sqr_item.rd_en} == 2'b10) && !full_ref) 
			count_ref = count_ref + 1;
		else if ( ({sqr_item.wr_en, sqr_item.rd_en} == 2'b01) && !empty_ref)
			count_ref = count_ref - 1;
		else if (({sqr_item.wr_en, sqr_item.rd_en} == 2'b11) && full_ref  ) begin
			count_ref = count_ref - 1;
		end
		else if (({sqr_item.wr_en, sqr_item.rd_en} == 2'b11) && empty_ref ) begin
			count_ref = count_ref + 1;
		end
        else begin
            
        end

        full_ref = (count_ref == FIFO_DEPTH)? 1 : 0;
        almostempty_ref = (count_ref == 1)? 1 : 0;
        almostfull_ref = (count_ref == FIFO_DEPTH-1)? 1 : 0;
        empty_ref = (count_ref == 0)? 1 : 0;
    end
        
endtask
endclass 
    
endpackage