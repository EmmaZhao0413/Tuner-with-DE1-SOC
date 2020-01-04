module max_finder(clk, reset, start, mag, pts, max_index ,max_mag, done, index0);
	input clk;
	input reset;
	input [10:0]pts;
	input [31:0]mag;
	input start;
	output reg [10:0]max_index;
	output reg [31:0]max_mag;
	output reg done;
	output reg [10:0]index0;
	
	reg [31:0]Max = 0;
	reg [10:0]MaxIndex = 0;
	
	reg [10:0]counter = 0;
	
	always @(posedge clk) begin
		if (reset || (!start) )begin
			MaxIndex <= 0;
			Max <= 0;
			counter <= 0;
			done <= 0;
			max_index <= 0;
			max_mag <= 0;
			end
		else begin
			if (counter == pts) begin
				done <= 1;
				end
			else begin
				counter <= counter +1;
				if (mag == 0) begin
					index0 <= counter;
					end
				if (Max < mag) begin
					MaxIndex <= counter;
					Max <= mag;
					end
				end//else
			end//else
			
		max_index <= MaxIndex;
		max_mag <= Max;
	end//always
		
endmodule
				
				
				
			