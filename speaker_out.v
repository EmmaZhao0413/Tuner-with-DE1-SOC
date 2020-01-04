module speaker_out (
	// Inputs
	CLOCK_50,
	KEY,
	SW, note_num1,

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
	LEDR,
	start,mag,done

);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input		[0:0]	KEY;
input		[0:0]	SW;
input		[5:0]note_num1;

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


output [7:0]LEDR;
output start;
output [63:0]mag;
wire [10:0]index;
input done;



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

assign delay = {4'b0000, 15'd3000};

wire [31:0] sound = SW[0] ? 0 : mag_out; 


/*******************************************/
wire [31:0]mag_out;
//assign LEDR[9:0] = left_channel_audio_in[31:22];
//assign LEDR[9:0] = mag_out[31:22];
//assign LEDR[0] = audio_in_available;
playtone  P0(.CLOCK_50(CLOCK_50), .reset(~KEY[0]), .note_num(note_num1), 
.ready_read(1'b1), .audio_out(mag_out[31:0]), .ready_out());
/*******************************************/
assign read_audio_in			= audio_in_available & audio_out_allowed;

assign left_channel_audio_out	= left_channel_audio_in+sound;
assign right_channel_audio_out	= right_channel_audio_in+sound;
assign write_audio_out			= audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[0]),

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

/*output start;
output [63:0]mag;
wire [10:0]index;
output done;*/
/*wire [31:0]LEFT;
assign LEFT[31:0] = left_channel_audio_in[31:0] >>> 3;*/


//assign mag[31:0]= mag_out[31:0];

	Filter F0(.CLOCK_50(CLOCK_50), 
             .reset_n(~KEY[0]),
				 .write_in(left_channel_audio_in),
				 .ready_write(1'b1),
				 .write_out(),
				 .start(start),
				 .mag(mag),
				 .index(index),
				 .done(1'b1), .LEDR(LEDR[7:0]));

				 

endmodule


