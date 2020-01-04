module Tuner(CLOCK_50, VGA_R,
			VGA_G,
			VGA_B,
			VGA_HS,
			VGA_VS,
			VGA_BLANK_N,
			VGA_SYNC_N,
			VGA_CLK,
			KEY, SW,// control playout/mic_in
//input/output from audio controller
	// Inputs

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,

	PS2_CLK,
	PS2_DAT,
	HEX0, HEX1, HEX2, HEX3, LEDR, HEX4, HEX5);
	
	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK_N;
	output VGA_SYNC_N;
	output VGA_CLK;
	
	input [2:0]KEY;
	input [9:0]SW;
	
	input	AUD_ADCDAT;
	inout	AUD_BCLK;
	inout	AUD_ADCLRCK;
	inout	AUD_DACLRCK;
	inout	FPGA_I2C_SDAT;
	inout	PS2_CLK;
	inout	PS2_DAT;
	output AUD_XCK;
	output AUD_DACDAT;
	output FPGA_I2C_SCLK;
	
	output [6:0]HEX0;
	output [6:0]HEX1;
	output [6:0]HEX2;
	output [6:0]HEX3;
	output [6:0]HEX4;
	output [6:0]HEX5;
	output [9:0]LEDR;
	
	
	//wire to connect mic_in & maxFreqDetector
	wire start;//from maxf to mic_in
	wire [63:0]mag;//from mic_in to maxf
	//wire [10:0]index;//from mic_in to maxf
	wire done;
	
	//wire to connect maxFreq & VGA display
	//wire [5:0]note_num;//final diaplay note_num
	wire [5:0]note_num1;//from ps2 input
	wire [5:0]note_num2;//from freq detect
	wire [1:0]lowhigh;
	
	//wire to connect mouse and display
	/*wire click;
	wire [7:0]mx;
	wire [6:0]my;
	wire [7:0]mx1;
	wire [6:0]my1;
	wire outc;*/
	//assign LEDR[1:0] = lowhigh[1:0];
	//hex_decoder H0(.hex_digit(note_num2[3:0]), .segments(HEX0[6:0]));
	//hex_decoder H1(.hex_digit(note_num2[5:4]), .segments(HEX1[6:0]));
	
	reg [27:0]counter =28'b0;
	reg [1:0]pitch;
	always @(posedge CLOCK_50) begin
		if (counter == 0) begin
			if (done) begin
				pitch <= lowhigh;
				counter <= counter+1;
				end
			else begin
				counter <= 0;
				//pitch <= pitch;
				end
			end
		else if (counter == 8333334) begin
			counter <= 0;
			//pitch <= pitch;
			end
		else begin
			counter <= counter+ 1;
			//pitch <= pitch;
			end
	end
	
	
//	assign LEDR[0] = done;
	//assign LEDR[7:6] = lowhigh[1:0];
	//assign LEDR[9:8] = pitch[1:0];
	speaker_out S0(.CLOCK_50(CLOCK_50), .KEY(KEY[0]), .SW(SW[0]), .note_num1(note_num1), 
	.AUD_ADCDAT(AUD_ADCDAT),
	.AUD_BCLK(AUD_BCLK),	.AUD_ADCLRCK(AUD_ADCLRCK), .AUD_DACLRCK(AUD_DACLRCK),
	.FPGA_I2C_SDAT(FPGA_I2C_SDAT), .AUD_XCK(AUD_XCK), .AUD_DACDAT(AUD_DACDAT),
	.FPGA_I2C_SCLK(FPGA_I2C_SCLK), .start(start), .done(1'b1), .mag(mag), .LEDR(LEDR[7:0]));//, .LEDR(LEDR[9:2]));
	
	maxFreqDetect m1(.start(start), .reset(~KEY[0]), .clk(CLOCK_50), 
	.mag(mag), .note(note_num2), .done(done), .pitch_indicator(lowhigh), 
	.expected(SW[6:1]));//.HEX4(HEX4[6:0]), .HEX5(HEX5[6:0]));//, .LEDR(LEDR[8:0]));//, .HEX0(HEX0[6:0]), .HEX1(HEX1[6:0]), .HEX2(HEX2[6:0]), .HEX3(HEX3[6:0]), 
	//.HEX4(HEX4[6:0]), .HEX5(HEX5[6:0]));
	
	
	mouse_display m2(.KEY(KEY[0]), .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT), 
			.HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .note_num2(note_num2),
			.lowhigh(pitch), .CLOCK_50(CLOCK_50), .VGA_R(VGA_R), .VGA_G(VGA_G),
			.VGA_B(VGA_B),	.VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_N(VGA_BLANK_N),
			.VGA_SYNC_N(VGA_SYNC_N), 
			.VGA_CLK(VGA_CLK), 
			.mouse_note(note_num1), .SW(SW[0]));
			

endmodule


