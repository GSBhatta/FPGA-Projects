`timescale 1ns/1ps
module adc_interface(
    input clk, rst_n, 
    input dout,
    input mode_input,
    output reg [2:0] mode,           // 000,001,010,011,100
    input [2:0] channel_in,     // <--- new: user-selected channel

    output reg cs_n, sclk, din, cnv,
    output reg [11:0] data, display,
    output clk_xk,
    output reg [3:0] address,
    output reg [3:0] sclk_count,
    output reg [9:0] count,
	 output reg [2:0] state,
	 output reg mode_count
);

parameter SAMPLES = 50000;
localparam CLOCK = 50000000;
localparam COUNT = (CLOCK / SAMPLES);

reg [3:0] addr;
reg [1:0] pulse_count;
reg [2:0] next_state, prev_state;
reg [2:0] prev_mode;
reg mode_in;
parameter IDLE = 3'b000;
parameter SINGLE = 3'b001;
parameter CONTINUOUS = 3'b010;
parameter SINGLE_CONT = 3'b011;
parameter CONT_ONESHOT = 3'b100;

//-----------------------------------------------------------------------------
//PULSE COUNT LOGIC
//-----------------------------------------------------------------------------
always @(posedge clk)
begin
    if (!rst_n)
    begin
        pulse_count <= 2'd0;
    end
    
    else
    begin
        if (!mode_input && pulse_count < 2'd3)
            pulse_count <= pulse_count + 1'd1;
        
        else if (!mode_input && pulse_count == 2'd3)
            pulse_count <= pulse_count;
            
        else if (mode_input)
            pulse_count <= 2'd0;
            
        else
            pulse_count <= 2'd0;
    end
end       

//-----------------------------------------------------------------------------
//MODE_IN LOGIC
//-----------------------------------------------------------------------------
always @(posedge clk)
begin
    if (!rst_n)
    begin
        mode_in <= 1'b1;
    end
    
    else
    begin
        case (mode_input)
            1'b1 : mode_in <= 1'b1;
            1'b0 : mode_in <= (pulse_count == 2'd1) ? 1'b0 : 1'b1;
            default : mode_in <= 1'b1;
        endcase
    end
end
	
//-----------------------------------------------------------------------------
// COUNT LOGIC 
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        prev_state <= IDLE;
    end
    else begin
        // Save the previous state BEFORE updating state
        prev_state <= state;

        // Update current state
        case(state)
            IDLE:state <= (!mode_in) ? SINGLE : IDLE;
				SINGLE:state <= (!mode_in) ? CONTINUOUS : SINGLE;
            CONTINUOUS:state <= (!mode_in) ? SINGLE_CONT : CONTINUOUS;
            SINGLE_CONT:state <= (!mode_in) ? CONT_ONESHOT : SINGLE_CONT;
            CONT_ONESHOT:state <= (!mode_in) ? IDLE : CONT_ONESHOT;
            default:state <= IDLE;
        endcase
    end
end


//-----------------------------------------------------------------------------
//MODE LOGIC
//-----------------------------------------------------------------------------
always @(posedge clk)
begin
	if (!rst_n)
	begin
		mode <= 3'b000;
	end
	
	else
	begin
		case(state)
			IDLE : mode <= 3'b000;
			SINGLE : mode <= 3'b001;
			CONTINUOUS : mode <= 3'b010;
			SINGLE_CONT : mode <= 3'b011;
			CONT_ONESHOT : mode <= 3'b100;
			default : mode <= 3'b000;
		endcase
	end
end

//-----------------------------------------------------------------------------
//COUNT LOGIC
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		count <= 0;
	end
	
	else
	begin			
		if (prev_state == state)
		begin
			if (count < COUNT - 1 && mode_count == 0)
				count <= count + 1;
				
			else if (count == COUNT - 1 && mode_count == 0)
				count <= 0;
			
			else if ((count < COUNT - 1 || count == COUNT - 1) && mode_count == 1)
				count <= count;
						
			else
				count <= count + 1;
		end
		
		else
			count <= 0;
	end
end

//-----------------------------------------------------------------------------
//MODE_COUNT LOGIC
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		mode_count <= 0;
	end
	
	else
	begin
		case (state)
			IDLE : mode_count <= 0;
			
			SINGLE : begin
				if (count < COUNT - 1 && mode_count == 0)
					mode_count <= 0;
					
				else if (count >= COUNT - 1 && mode_count == 0)
					mode_count <= 1;
					
				else if (count >= COUNT - 1 && mode_count == 1)
					mode_count <= mode_count;
			end
			
			CONTINUOUS : mode_count <= 0;
			
			SINGLE_CONT : mode_count <= 0;
			
			CONT_ONESHOT : begin
				if (addr < 8)
				begin
					if (count < COUNT - 1)
						mode_count <= 0;
						
					else if (count == COUNT - 1)
					begin
						mode_count <= 0;
					end
				end
				
				if (addr == 8)
				begin
					if (count < COUNT - 1)
						mode_count <= 0;
					
					else if (count >= COUNT - 1)
						mode_count <= 1;
				end
				
				else
				begin
					mode_count <= mode_count;
				end
			end
		endcase 
	end
end

//-----------------------------------------------------------------------------
//ADDR LOGIC
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		addr <= 0;
	end
	
	else
	begin
		if (state == SINGLE || state == SINGLE_CONT)
			addr <= channel_in;
			
		else if (prev_state == state && count == COUNT - 1 && state != CONT_ONESHOT)
		begin
			if (addr < 7)
				addr <= addr + 1;
				
			else
				addr <= 0;
		end
		
		else if (prev_state == state && count == COUNT - 1 && state == CONT_ONESHOT)
		begin
			if (addr < 8)
				addr <= addr + 1;
				
			else
				addr <= 0; //0 initially
		end
			
		else if (prev_state != state)
		begin
			addr <= 0;
		end
	end
end

//-----------------------------------------------------------------------------
//ADDRESS DISPLAY LOGIC
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		address <= 0;
	end
	
	else
	begin
		address <= addr;
	end
end

//-----------------------------------------------------------------------------
//CNV LOGIC
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		cnv <= 0;
	end
	
	else
	begin
		if (mode_count == 0)
		begin
			if (count == 1 || count == 0)
			begin
				cnv <= 1;
			end
			
			else
			begin
				cnv <= 0;
			end
		end
		
		else if (mode_count == 1)
		begin
			cnv <= 0;
		end
	end
end

//-----------------------------------------------------------------------------
//CS' LOGIC
//-----------------------------------------------------------------------------	
always @(negedge clk)
begin  
    if (!rst_n)
        cs_n <= 1'b1;
   
    if (state == IDLE)
			cs_n <= 1'b1;
			
	 else
    begin
        if (cnv == 1'b1 && count > 0)
            cs_n <= 1'b0;

        else if (count == 10'd0)
            cs_n <= 1'b1;

        else 
            cs_n <= 1'b0;
    end
end

//-----------------------------------------------------------------------------
//SCLK COUNT
//-----------------------------------------------------------------------------
always @(negedge rst_n or negedge clk)
begin
    if (!rst_n)
        sclk_count <= 4'd0;

    else
    begin
        if (cs_n == 0 && sclk_count < 4'd7 && count < 250)
            sclk_count <= sclk_count + 1'd1;
        
		  else if (cs_n == 0 && count >= 250)
				sclk_count <= sclk_count;
		  
		  else
            sclk_count <= 4'd0;
    end
end

//-----------------------------------------------------------------------------
//SCLK LOGIC
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        sclk <= 1'b1;
    
    else
    begin
        if (cs_n == 1'b1)
            sclk <= 1;
                
        else if (cs_n == 1'b0 && sclk_count == 4'd0 && count < 250 && mode_count != 1)
            sclk <= ~sclk;
        
		  else if (cs_n == 1'b0 && sclk_count == 4'd0 && count < 250 && mode_count == 1)
            sclk <= sclk;
		  
        else if (cs_n == 1'b0 && count >= 250 && (mode_count == 1 || mode_count == 0))
				sclk <= 1'b1;
				
		  else
            sclk <= sclk;
    end
end

//-----------------------------------------------------------------------------
//DIN LOGIC
//-----------------------------------------------------------------------------
always @(negedge clk)
begin
    if (!rst_n)
    begin   
        din <= 1'b0;
    end
    
    else
    begin
        if (cs_n == 1'b0 && count == 8'd41)
        begin
            din <= addr[2];
        end
        
        else if (cs_n == 1'b0 && count == 8'd57)
        begin
            din <= addr[1];
        end 
        
        else if (cs_n == 1'b0 && count == 8'd73)
        begin
            din <= addr[0];
        end 
        
        else
        begin
            din <= din;
        end
    end
end

//-----------------------------------------------------------------------------
//DOUT LOGIC
//-----------------------------------------------------------------------------
always @(negedge rst_n or posedge sclk)
begin
    if (!rst_n)
    begin
        data <= 12'd0;
    end
    
    else
    begin
        data <= {data[10:0], dout};
    end
end 

//-----------------------------------------------------------------------------
//DISPLAY LOGIC
//-----------------------------------------------------------------------------
always @(posedge clk)
begin
	if (!rst_n)
	begin
		display <= 12'd0;
	end
	
	else
	begin
		if (sclk && cnv)
		begin
			display <= data;
		end
		 
		else if ((state == SINGLE || state == CONT_ONESHOT) && cs_n)
		begin
			display <= data;
		end
		
		else
		begin
			display <= display;
		end
	end
end
		
endmodule
