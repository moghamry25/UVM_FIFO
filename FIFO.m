classdef FIFO
    properties
        data_in          
        wr_en            
        rd_en            
        clk              
        rst_n            
        FIFO_WIDTH = 1; 
        FIFO_DEPTH = 8;  
        mem              
        wr_ptr           
        rd_ptr           
        count            
        overflow         
        underflow        
        empty
        full
        almostfull
        almostempty
        wr_ack           
        data_out         
    end
    
    methods
        % Constructor
        function obj = FIFO()
            obj.mem = zeros(obj.FIFO_DEPTH, obj.FIFO_WIDTH); % Initialize memory
            obj.wr_ptr = 0;
            obj.rd_ptr = 0;
            obj.count = 0;
            obj.overflow = false;
            obj.underflow = false;
            obj.wr_ack = false;
            obj.full=0;
            obj.empty=1;
            obj.almostempty=0;
            obj.almostfull=0;
            obj.data_out = zeros(1, obj.FIFO_WIDTH);
        end
        
        % Write operation
        function obj = write(obj, data)
            if obj.rst_n == 0
                obj.wr_ptr = 0;
                obj.count = 0;
                obj.overflow = false;
                obj.wr_ack = false;
            elseif obj.wr_en && obj.count < obj.FIFO_DEPTH
                obj.mem(obj.wr_ptr + 1, :) = data; % Write data to memory
                obj.wr_ack = true; % Acknowledge write
                obj.wr_ptr = mod(obj.wr_ptr + 1, obj.FIFO_DEPTH); % Increment write pointer
                obj.count = obj.count + 1; % Update count
                
            else
                obj.wr_ack = false; % No write acknowledgment if full
                obj.overflow = obj.count >= obj.FIFO_DEPTH; % Set overflow flag
            end
        end
        
        % Read operation
        function [obj, data_out] = read(obj)
            data_out = zeros(1, obj.FIFO_WIDTH); % Default output
            if obj.rst_n == 0
                obj.rd_ptr = 0;
                obj.count = 0;
                obj.underflow = false;
            elseif obj.rd_en && obj.count > 0
                data_out = obj.mem(obj.rd_ptr + 1, :); % Read data from memory
                obj.rd_ptr = mod(obj.rd_ptr + 1, obj.FIFO_DEPTH); % Increment read pointer
                obj.count = obj.count - 1; % Decrease count
            else
                obj.underflow = obj.count <= 0; % Set underflow flag
            end
        end


        function [obj, data_out] = all(obj, data)
            % Initialize output
            data_out = [];
        
            if obj.rst_n == 0
                % Reset state
                obj.rd_ptr = 0;
                obj.wr_ptr = 0;
                obj.count = 0;
                obj.underflow = 0;
                obj.overflow = 0;
                obj.empty = 1;
                obj.full = 0;
                obj.almostfull = 0;
                obj.almostempty = 0;
                obj.wr_ack = 0;
            elseif obj.wr_en && obj.rd_en && obj.full
                % Read from FIFO when both write and read enable are high and FIFO is full
                data_out = obj.mem(obj.rd_ptr + 1, :);
                obj.rd_ptr = mod(obj.rd_ptr + 1, obj.FIFO_DEPTH);
                obj.count = obj.count - 1;
                obj.almostfull = 1; % This could be updated based on the current count
                obj.wr_ack = 0;
            elseif obj.wr_en && obj.rd_en && obj.empty
                % Write to FIFO when both write and read enable are high and FIFO is empty
                obj.mem(obj.wr_ptr + 1, :) = data;
                obj.wr_ack = 1;
                obj.wr_ptr = mod(obj.wr_ptr + 1, obj.FIFO_DEPTH);
                obj.count = obj.count + 1;
                obj.almostempty = 1; % This could be updated based on the current count
            elseif obj.wr_en && obj.rd_en && ~obj.empty && ~obj.full 
                % Write and read when FIFO is neither empty nor full
                obj.mem(obj.wr_ptr + 1, :) = data;
                obj.wr_ack = 1;
                obj.wr_ptr = mod(obj.wr_ptr + 1, obj.FIFO_DEPTH);
                data_out = obj.mem(obj.rd_ptr + 1, :);
                obj.rd_ptr = mod(obj.rd_ptr + 1, obj.FIFO_DEPTH);
            elseif ~obj.wr_en && obj.rd_en && ~obj.empty
                % Read from FIFO when only read enable is high
                data_out = obj.mem(obj.rd_ptr + 1, :);
                obj.rd_ptr = mod(obj.rd_ptr + 1, obj.FIFO_DEPTH);
                obj.count = obj.count - 1;
                obj.wr_ack = 0;
                obj.underflow = 0;
                obj.full = (obj.count == obj.FIFO_DEPTH);
            elseif ~obj.wr_en && obj.rd_en && obj.empty
                % Underflow condition
                obj.underflow = 1;
            elseif obj.wr_en && ~obj.rd_en && ~obj.full
                % Write to FIFO when only write enable is high
                obj.mem(obj.wr_ptr + 1, :) = data;
                obj.wr_ack = 1;
                obj.wr_ptr = mod(obj.wr_ptr + 1, obj.FIFO_DEPTH);
                obj.count = obj.count + 1;
                obj.overflow = 0;        
                obj.empty = (obj.count == 0);
            else
                % Handle unexpected conditions
                disp('Unexpected condition in FIFO operation.');
            end    
        end
        



    end
end



