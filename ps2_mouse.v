module ps2_mouse(CLOCK_50, KEY, PS2_CLK,
	PS2_DAT, HEX0, HEX1, HEX2, HEX3, xpos, ypos, click);
// Inputs
	input	CLOCK_50;
	input	[0:0]KEY;

// Bidirectionals
	inout	PS2_CLK;
	inout	PS2_DAT;

//output
	output [6:0]HEX0;
	output [6:0]HEX1;
	output [6:0]HEX2;
	output [6:0]HEX3;
	//output [0:0]LEDR;
	
	
	//output reg [7:0]xpos;
	//output reg [7:0]ypos;
	output reg click;

	wire	[7:0]ps2_key_data;
	wire	ps2_key_pressed;

// Internal Registers
	reg		[7:0]last_data_received;
	reg 	[1:0]counter;
	output reg 	[7:0]xpos = 8'b0;
	output reg 	[7:0]ypos = 8'b0;
	
	PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed),
);

	always @(posedge CLOCK_50)
	begin
		if (~KEY[0])begin
			last_data_received <= 8'h00;
			xpos <= 8'd00;
			ypos <= 8'd00;
			end
		else if (ps2_key_pressed == 1'b1)begin
			last_data_received <= ps2_key_data;
			if (counter == 2'b00) begin
				click <= last_data_received[0];
				counter <= counter +1;
				end
			else if (counter == 2'b01) begin
				xpos <= xpos + last_data_received;
				counter <= counter +1;
				end
			else if (counter == 2'b10) begin
				ypos <= ypos + last_data_received;
				counter <= 2'b00;
				end
			end
	end

	
	//assign LEDR[0] = click;
	//assign mx[7:0] = xpos[7:0];
	//assign my[6:0] = ypos[6:0];
	hex_decoder H0(xpos[3:0], HEX0);
	hex_decoder H1(xpos[7:4], HEX1);
	hex_decoder H2(ypos[3:0], HEX2);
	hex_decoder H3(ypos[7:4], HEX3);

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
