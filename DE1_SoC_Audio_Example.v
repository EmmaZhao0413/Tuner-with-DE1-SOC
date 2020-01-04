
module DE1_SoC_Audio_Example (
	// Inputs
	CLOCK_50,
	KEY,
	SW,

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
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX4_bin,
	HEX3_bin

);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input		[3:0]	KEY;
input		[3:0]	SW;

input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;
output       [6:0]HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;
output	[3:0]	HEX4_bin;
output	[3:0]	HEX3_bin;


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;



// Internal Registers

reg [18:0] delay_cnt;
wire [18:0] delay;

reg snd;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 
 *****************************************************************************/

always @(posedge CLOCK_50)
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
	end else delay_cnt <= delay_cnt + 1;

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign delay = {SW[3:0], 15'd3000};

wire [31:0] sound = (SW == 0) ? 0 : snd ? 32'd10000000 : -32'd10000000;


assign read_audio_in			= audio_in_available & audio_out_allowed;

assign left_channel_audio_out	= left_channel_audio_in+sound;
assign right_channel_audio_out	= right_channel_audio_in+sound;
assign write_audio_out			= audio_in_available & audio_out_allowed;
//HEX0-2 SHOW LEFT CHANNEL
//HEX3-5 SHOW RIGHT CHANNEL
wire      Enable;
wire      [23:0] RDiv;
wire      [31:0] divOut_left;
//wire      [31:0] divOut_right;

assign    Enable = (RDiv == 20'b00000000000000000000)?1:0;

RateDivider rd0(
			.Clock(CLOCK_50),
			.q(RDiv)
         );
//using added sound one 
divOut do0(.inSound(left_channel_audio_out),.clk(Enable), .outSound(divOut_left));
//divOut do1(.inSound(right_channel_audio_out),.clk(Enable), .outSound(divOut_right));

hex_decoder H0(
        .hex_digit(divOut_left[11:8]), 
        .segments(HEX0)
        );
		  
		  
hex_decoder H1(
        .hex_digit(divOut_left[15:12]), 
        .segments(HEX1)
        );
		 
hex_decoder H2(
        .hex_digit(divOut_left[19:16]), 
        .segments(HEX2)
        );

hex_decoder H3(
        .hex_digit(divOut_left[23:20]), 
        .segments(HEX3)
        );
assign HEX3_bin = divOut_left[23:20];		  
hex_decoder H4(
        .hex_digit(divOut_left[27:24]), 
        .segments(HEX4)
        );
assign HEX4_bin = divOut_left[27:24];

hex_decoder H5(
        .hex_digit(divOut_left[31:28]), 
        .segments(HEX5)
        );
/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[2]),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);

endmodule

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
endmodule

module RateDivider (Clock,q);
	input Clock;
	output reg[23:0] q;
	always @ (posedge Clock)
	begin
		if(q == 24'b000000000000000000000000)//when it is the min value
				q <= 24'b111111111111111111111111;
		else
				q <= q-1; 
	end
endmodule

module divOut(inSound, clk, outSound);
		input [31:0] inSound;
		input clk;
		output reg[31:0] outSound;
		
		always @(posedge clk)
			
			if(inSound[31] == 1'b1)begin 
				outSound <= ~inSound;
			end 
			else begin 
				outSound <= inSound;
			end
endmodule 







	
	
	
	
	
	
	
	
	
	
	
	
	
	
