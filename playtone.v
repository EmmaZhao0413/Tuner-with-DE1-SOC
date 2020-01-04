module playtone(CLOCK_50,reset, note_num, audio_out, ready_read, ready_out);//KEY,SW,LEDR
	input CLOCK_50;
	input reset;
	//wire reset = KEY[0];
	
	input [6:0]note_num;
	//wire [5:0]note_num = SW;//A2-22/C3-25/E3-29/G3-32/A3-34
	
	//connect to audio controller
	input ready_read;// = SW[6];
	output reg [31:0]audio_out;
	//output [9:0]LEDR;
	output reg ready_out;// =1'b1;

	reg [31:0]countdata;// = 11'b00000000000;
	
	
	reg [6:0]counter;//number of bits one cycle of note
	reg [7:0]count_note;//count in one cycle
	
	always @(*) begin
		if(reset == 1'b1) begin
			counter = 7'b0110111;//half of the cycle
			end
		else begin
			if (note_num == 6'b010110)begin
				counter = 7'b1101101;
				end
			else if (note_num == 6'b011001)begin
				counter = 7'b1011100;
				end
			else if (note_num == 6'b011101)begin
				counter = 7'b1001010;
				end
			else if (note_num == 6'b100000)begin
				counter = 7'b0111101;
				end
			else begin
				counter = 7'b0110111;
				end
		end//else
	end//always
	
	always @(posedge CLOCK_50) begin
		if (reset == 1'b1)begin
			audio_out <= 32'h000000000;
			ready_out <= 1'b1;
			end
		else if (!ready_read) begin
			audio_out <= audio_out;
			end
		else if (counter == 7'b0110111) begin
			audio_out <= 32'b0;
			end
		else begin
			if (countdata == 32'hFFFFFFFF) begin
				countdata <= 11'b0;
				ready_out <= 1'b0;
				audio_out <= audio_out;
				end
			else if (countdata == 32'h0FFFFFFF) begin
				countdata <=countdata +1;
				ready_out <= 1'b1;
				end
			else begin
				if (count_note == (counter <<< 1)) begin
					count_note <= 0;
					end
				else begin
					count_note <= count_note +1;
					if (count_note == counter) begin
						audio_out <= 32'h00800000;
						end
					else if (count_note == 0)begin
						audio_out <= 32'hFF7FFFFF;//magnitude of the audio
						end
					else begin
						audio_out <= audio_out;
						
						end
						
					end
				ready_out <= 1'b0;
				countdata <= countdata +1;	
			end
			
		end//else*/
	end//always
	
	//assign LEDR[9:7] = audio_out[25:23];
	//assign LEDR[6] = ready_out;
endmodule
				