module transfer(CLOCK_50, KEY, PS2_CLK,
	PS2_DAT, HEX0, HEX1, HEX2, HEX3, note_num, outc , MX, MY);
	input CLOCK_50;
	input	[0:0]KEY;

	inout	PS2_CLK;
	inout	PS2_DAT;


	output [6:0]HEX0;
	output [6:0]HEX1;
	output [6:0]HEX2;
	output [6:0]HEX3;
	//output [0:0]LEDR;
	output [7:0]MX;
	output [6:0]MY;

	wire [7:0]mx;
	wire [7:0]my;
	wire click;
	output reg [5:0]note_num;
	output reg outc;


	ps2_mouse P0(.CLOCK_50(CLOCK_50), .KEY(KEY[0]), .PS2_CLK(PS2_CLK),
	.PS2_DAT(PS2_DAT), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), 
	.HEX3(HEX3), .xpos(mx), .ypos(my), .click(click));
	
	always@(posedge CLOCK_50) begin
		outc <= 1'b0;
		if ((mx == 8'h54) && (my >= 8'h41) && (my <= 8'h71)) begin
			note_num <= 6'b010110;//76
			if (click) begin
				outc <= 1'b1;
				end
			else begin
				outc <= 1'b0;
				end
			end
		else if ((mx == 8'h57) && (my >= 8'h41) && (my <= 8'h71)) begin
			note_num <= 6'b011001;//73
			if (click) begin
				outc <= 1'b1;
				end
			else begin
				outc <= 1'b0;
				end
			end
		else if ((mx == 8'h5A) && (my >= 8'h41) && (my <= 8'h71)) begin
			note_num <= 6'b011101;//70
			if (click) begin
				outc <= 1'b1;
				end
			else begin
				outc <= 1'b0;
				end
			end
		else if ((mx == 8'h51) && (my >= 8'h41) && (my <= 8'h71)) begin
			note_num <= 6'b100000;//67
			if (click) begin
				outc <= 1'b1;
				end
			else begin
				outc <= 1'b0;
				end
			end
		else begin
			note_num <= 6'b0000000;
			outc <= 1'b0;
			end
		end

		//assign LEDR[5:0] = note_num[5:0];
		//assign LEDR[7] = outc;
		//assign LEDR[7:0] = my[7:0];
		assign MX[7:0] = mx[7:0];
		assign MY[6:0] = my[6:0];
endmodule
