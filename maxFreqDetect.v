//TOP_LEVEL_MODULE

module maxFreqDetect(start, reset, clk, expected, mag, note, done, pitch_indicator);//, HEX4, HEX5, freakMax);//, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	 input start;
	 input reset;
	 input [63:0]mag;
	 //input [10:0]pts;
	 input clk;
	 input [5:0]expected;
	 
	 
	 output done;
	 output [5:0]note;
	 output [1:0]pitch_indicator;
	 //output [63:0]freakMax;
	 //wire [10:0]p;
	 //output [6:0]HEX4, HEX5;
	 //output [9:0]LEDR;
	 //output [6:0]HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	 
	 wire [10:0]maxIndex;
	 wire MIfound_FDstart;
	 wire FDfound_TCstart;
	 wire [63:0]max_freq;
	 wire [63:0]MaxMag;
	 //wire [1:0]ppppitch;
	 
	 //assign freakMax[63:0] = MaxMag[63:0];
	 
	 

	 max_finder MFind(.clk(clk), .reset(1'b0), .start(1'b1), .mag(mag), .max_index(maxIndex),
	 .done(done), .max_mag(MaxMag[63:0]));//, .LEDR(LEDR[8:0]));, .num_pts(p));
	 
	 maxFreq MFreq(.clk(clk), .max_index(maxIndex), .start(start), .reset(1'b0), 
	 .freq(max_freq[63:0]), .done(FDfound_TCstart));
	 
	 toneCheck TC(.clk(clk), .start(1'b1), .freq(max_freq[63:0]), .expected(expected),
	 .note_Num(note), .pitch(pitch_indicator), .Done());
	 //assign ppppitch[1:0] = pitch_indicator;
	 //assign LEDR[9] = mag[27];
	 //assign LEDR[3] = maxIndex[10];
	 //assign LEDR[3] = MIfound_FDstart;
	 //assign LEDR[2] = FDfound_TCstart;
	 //assign LEDR[1] = done;
	 //assign LEDR[0] = reset;
	 
	 /*
	 hex_decoder H0(.hex_digit(pitch_indicator[1:0]), .segments(HEX0[6:0]));
	 hex_decoder H1(.hex_digit(maxIndex[4:0]), .segments(HEX1[6:0]));
	 hex_decoder H2(.hex_digit(maxIndex[9:5]), .segments(HEX2[6:0]));
	 hex_decoder H3(.hex_digit(maxIndex[10]), .segments(HEX3[6:0]));
	 hex_decoder H4(.hex_digit(note[5:4]), .segments(HEX5[6:0]));
	 hex_decoder H5(.hex_digit(note[3:0]), .segments(HEX4[6:0]));
	 //hex_decoder H5(.hex_digit(note[31:27]), .segments(HEX5[6:0]));*/
	 
	 
	 
endmodule

module max_finder(clk, reset, start, mag, max_index, done, max_mag ,LEDR);//, num_pts);
	//localparam SHIFT_BITS = 10;
	localparam NUM_PTS = 523;
	localparam HALF_WINDOW = 512;
	//localparam SHIFT_BITS = 3;
	input clk;
	input reset;
	//input [10:0]pts;
	input [31:0]mag;
	input start;
	output reg [10:0]max_index;
	output reg [63:0]max_mag;
	output reg done;
	
	output [8:0]LEDR;
	
	assign LEDR[8:0]= counter[8:0];
	//output reg [10:0]index0;
	//output [10:0]num_pts;
	//wire [10:0]num_pts;
	
	reg [63:0]Max;
	reg [10:0]MaxIndex = 11'b0;
	
	reg [9:0]counter;

	//assign num_pts[10:0] = 1<<SHIFT_BITS;
	always @(posedge clk) begin
		if (reset == 1'b1)begin
			MaxIndex <= 0;
			Max <= 0;
			counter <= 0;
			done <= 0;
			max_index <= 0;
			//max_mag <= 0;
			end
		else if(start == 1'b0) begin
			MaxIndex <= 0;
			Max <= 0;
			counter <= 0;
			done <= 0;
			max_index <= 0;
			//max_mag <= 0;
			end
		else begin
			if (counter == 0) begin
				done <= 1'b0;
				end
			else if (counter == NUM_PTS) begin
				done <= 1'b1;
				counter <= 0;
				MaxIndex <= 0;
				Max <= 0;
				//start <= 1'b0;
				end
			else if (counter > HALF_WINDOW+2) begin
				done <= 1'b0;
				//if (mag == 0) begin
					//index0 <= counter;
					//end
				if (Max < mag) begin
					MaxIndex <= (counter - HALF_WINDOW);
					Max <= mag;
					end
				else begin
					MaxIndex <= MaxIndex;
					Max <= Max;
				end
				//counter <= counter + 1;
				end//else if
			else begin
				done <= 1'b0;
				MaxIndex <= MaxIndex;
				Max <= Max;
				end
			counter <= counter + 1;
			end//else
			
		max_index <= MaxIndex;
		max_mag <= Max;
	end//always
		
endmodule

module maxFreq(clk, max_index, start, reset, freq, done);
	localparam SAMPLE_FREQ = 48000; //sample frequency
	localparam SHIFT_BITS = 10;
	//localparam SHIFT_BITS = 3;
	input [10:0]max_index;
	//input [10:0]pts; //SHIFT_BITS
	input start;
	input reset;
	input clk;
	
	output [31:0]freq;
	output done;
	
	reg [31:0]freq_reg;
	reg [31:0]mult;
	reg Done = 1'b0;
	//reg [15:0]shifted;

	//bitwise operation
	always@(posedge clk)
	begin
		if(reset == 1'b1) begin
			freq_reg <= 32'b0;
			Done <= 1'b0;
		end
		else if(start) begin
			mult <= SAMPLE_FREQ*max_index;
			//shifted <= mult >>> pts;
			freq_reg <= (mult >> SHIFT_BITS);
			//freq_reg <= (mult >>> pts);
			Done <= 1'b1;
		end
		else begin
			freq_reg <= freq_reg;
			Done <= 1'b0;
		end
	end
	assign done = Done;
	assign freq = freq_reg;
endmodule
	
module toneCheck(clk, start, freq, expected, note_Num, pitch, Done);
	input [31:0]freq;
	input start;
	input [5:0]expected;
	input clk;
	
	output [5:0]note_Num;
	output [1:0]pitch; //low = 00, high = 11, correct = 10;
	output Done;
	
	reg [5:0]noteNum;
	reg [1:0]isLow_High = 2'b01;
	reg done;
	
	
	localparam A_2 = 22;//010110
	localparam C_3 = 25;//011001
	localparam E_3 = 29;//011101
	localparam G_3 = 32;//100000
	//localparam DEF = 0;
	
	always@(posedge clk)
	begin
		if(start == 1'b1) begin
			if (expected == A_2) begin
				//if(freq <= 241)begin
				noteNum <= A_2;
				if(freq < 210)begin
					isLow_High <= 2'b00;
					//done <= 1'b1;
				end
				else if(freq > 230)begin
					isLow_High <= 2'b11;
					//done <= 1'b1;
				end
				else begin
					isLow_High <= 2'b10;
					//done <= 1'b0;
				end
				done <= 1'b1;
			end
			else if(expected == C_3) begin
				//else if((freq > 241) && (freq <= 296)) begin
				noteNum <= C_3;
				if(freq < 240) begin
					isLow_High <= 2'b00;
					//done <= 1'b1;
				end
				else if(freq > 280) begin
					isLow_High <= 2'b11;
					//done <= 1'b1;
				end
				else begin
					isLow_High <= 2'b10;
					//done <= 1'b0;
				end
				done <= 1'b1;
			end
			else if(expected == E_3) begin
				//else if((freq > 296) && (freq <= 361)) begin
				noteNum <= E_3;
				if(freq < 310) begin
					isLow_High <= 2'b00;
					//done <= 1'b1;
				end
				else if(freq > 360) begin
					isLow_High <= 2'b11;
					//done <= 1'b1;
				end
				else begin
					isLow_High <= 2'b10;
					//done <= 1'b0;
				end
				done <= 1'b1;
			end
			else if(expected == G_3) begin
				//else if(freq > 361) begin
				noteNum <= G_3;
				if(freq < 380) begin
					isLow_High <= 2'b00;
					//done <= 1'b1;
				end
				else if(freq > 400) begin
					isLow_High <= 2'b11;
					//done <= 1'b1;
				end
				else begin
					isLow_High <= 2'b10;
					//done <= 1'b0;
				end
				done <= 1'b1;
			end
			else begin
				noteNum <= 0;
				isLow_High <= 2'b01;
				done <= 1'b0;
			end
		end
		else begin
			noteNum <= 6'b0;
			isLow_High <= 2'b01;
			done <= 1'b0;
		end
	end

	assign Done = done;
	assign note_Num = noteNum;
	assign pitch = isLow_High;
endmodule

/*
module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule*/
			
	
	
	