module mouse_display(KEY, PS2_CLK, PS2_DAT, 
			HEX0, HEX1, HEX2, HEX3,
			note_num2, lowhigh, CLOCK_50, VGA_R,
			VGA_G,
			VGA_B,
			VGA_HS,
			VGA_VS,
			VGA_BLANK_N,
			VGA_SYNC_N,
			VGA_CLK, mouse_note, SW
			);
			
	input	[0:0]KEY;
	input [0:0]SW;
	

	inout	PS2_CLK;
	inout	PS2_DAT;


	output [6:0]HEX0;
	output [6:0]HEX1;
	output [6:0]HEX2;
	output [6:0]HEX3;
	//output [1:0]LEDR;
			
		
	wire [5:0]note_num1;	
	input [5:0]note_num2;
	//assign note_num2[5:0] = SW[5:0];
	input [1:0]lowhigh;
	//assign lowhigh[1:0] = SW[9:8];
	//input ready; //ready to start FSM
	wire reset;
	assign reset = KEY[0];
//input ismouse;
	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK_N;
	output VGA_SYNC_N;
	output VGA_CLK;

	output [5:0]mouse_note;
	
	//input click;

	wire [7:0]plotx;
	wire [6:0]ploty;
	wire [8:0]plotc;

	//mouse input
	wire [7:0]mx;
	wire [6:0]my;
	wire [7:0]MX;
	wire [6:0]MY;
	assign MY = my - 7'h32;
	assign MX = mx - 8'h0E;
	reg [5:0]note_num;
	
	wire outc;//if the click is valid
	reg [1:0]pitch;
	
	reg [16:0]counter;
	reg enable;
	wire Enable = enable;
	
	wire [8:0]background;
	
	always@(*) begin
		if ((outc) && (SW[0]==1'b0)) begin
			note_num = note_num1;
			pitch = 2'b10;
			end
		else if (SW[0] == 1'b1) begin
			note_num = note_num2;
			pitch[1:0] = lowhigh[1:0];
			end
		else begin
			note_num = 6'b0;
			end
		end
	
	wire [1:0]PITCH;
	assign PITCH[1:0] = pitch[1:0];
	wire [5:0]NOTE;
	assign NOTE [5:0]= note_num[5:0]; 
	
	always @(posedge CLOCK_50) begin
		if (counter == 24999) begin
			counter <= 17'b0;
			enable <= 1'b1;
			end
		else begin
			counter <= counter +1;
			enable <= 1'b0;
			end
	end
	
	wire ERS;
	wire ERM;
	wire PS;
	wire PM;
	wire [5:0]county;
	wire [7:0]pastmx;
	wire [6:0]pastmy;
	
	
	//assign LEDR[0] = enable;
	//assign LEDR[5:0] = note_num1[5:0];
	//assign LEDR[1] = outc;
	assign mouse_note[5:0] = outc ? note_num1[5:0] : 6'b0;
	
	ram_background R0(.address((pastmy)*160 + pastmx), .clock(CLOCK_50), .wren(1'b0),	.q(background));
	
	transfer T0(.CLOCK_50(CLOCK_50), .KEY(KEY[0]), .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT),
	.HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), 
	.note_num(note_num1), .outc(outc), .MX(mx), .MY(my));
	
	control C0(.reset(~KEY[0]), .enable(Enable), .county(county), .clock(CLOCK_50), .ERS(ERS),
	.ERM(ERM), .PS(PS), .PM(PM)); 
	
	datapath D0(.reset(~KEY[0]), .clock(CLOCK_50), .ERS(ERS), .ERM(ERM), .PS(PS), 
	.background(background),.PM(PM), .note_num(NOTE), .pastmx(pastmx), .pastmy(pastmy),
	.pitch(PITCH), .mx(MX), .my(MY), .county(county), .outc(outc), .plotx(plotx),
	.ploty(ploty), .plotc(plotc));
	
	vga_adapter VGA(
			.resetn(reset),
			.clock(CLOCK_50),
			.colour(plotc),
			.x(plotx),
			.y((ERS|PS | ~(ERS|ERM|PS|PM)) ? ploty+county : ploty),
			.plot(1'b1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 3;
		defparam VGA.BACKGROUND_IMAGE = "background.mif";
endmodule
	
	
	
module control(reset, enable, county, clock, ERS, ERM, PS, PM);
	input reset;
	input enable;
	input [5:0]county;
	input clock;
	output reg ERS;
	output reg ERM;
	output reg PS;
	output reg PM;
	
	reg [2:0]current_state, next_state;
	parameter ers = 3'b000,
				erm = 3'b001,
				ps = 3'b010,
				pm = 3'b011,
				Wait = 3'b100;
	always @(*)
	begin: state_table
		case (current_state)
			ers: if (county == 48) begin
					next_state = erm;
					end
					else begin
					next_state = ers;
					end
			erm: next_state = ps;
			ps: if (county == 48) begin
					next_state = pm;
					end
				else begin
					next_state = ps;
					end
			pm: next_state = Wait;
			Wait: next_state = enable ? ers : Wait;
		endcase
	end
	
	always @(*)
	begin: state_t
		case (current_state)
			ers: begin
				ERS = 1'b1;
				ERM = 1'b0;
				PS = 1'b0;
				PM = 1'b0;
				end
			erm: begin
				ERS = 1'b0;
				ERM = 1'b1;
				PS = 1'b0;
				PM = 1'b0;
				end
			ps: begin
				ERS = 1'b0;
				ERM = 1'b0;
				PS = 1'b1;
				PM = 1'b0;
				end
			pm: begin
				ERS = 1'b0;
				ERM = 1'b0;
				PS = 1'b0;
				PM = 1'b1;
				end
			Wait: begin
				ERS = 1'b0;
				ERM = 1'b0;
				PS = 1'b0;
				PM = 1'b0;
				end
		endcase
	end
	
	
	always @(posedge clock)
	begin: state_FFs
      if(reset == 1'b1)begin
         current_state <= ers;
         end
      else begin
			current_state <= next_state;
			end
   end 
endmodule
	
	

module datapath(reset, clock, ERS, ERM, PS, PM, background, note_num, pitch, 
county, mx, my, pastmx, pastmy, outc, plotx, ploty, plotc);
	input reset;
	input clock;
	input ERS;
	input ERM;
	input PS;
	input PM;
	input [8:0]background;
	input [5:0]note_num;
	input [1:0]pitch;
	input [7:0]mx;
	input [6:0]my;
	input outc;
	output reg[7:0]plotx;
	output reg[6:0]ploty;
	output reg[8:0]plotc;
	
	output reg [7:0]pastmx;
	output reg [6:0]pastmy;
	reg [7:0]pastx;
	
	//assign pastx = note_x;
	
	reg [7:0]note_x;// register x-position of the string
	//reg [6:0]note_y; //register y-position of the string
	reg [8:0]note_c;
	output reg [5:0]county;
	
	always @(posedge clock) begin
		if (note_num == 6'b010110)begin
			note_x <= 8'b01000110;//70
			end
		else if (note_num == 6'b011001)begin
			note_x <= 8'b01001001;//73
			end	
		else if (note_num == 6'b011101)begin
			note_x <= 8'b01001100;//76
			end
		else if (note_num == 6'b100000)begin
			note_x <= 8'b01000011;//67
			end
		else begin
			note_x <= pastx;
			end
	end
	
	always @(posedge clock) begin
		
		if (note_num ==  6'b010110 || note_num ==  6'b011001 ||
			note_num ==  6'b011101 || note_num ==  6'b100000 ) begin
			if (pitch == 2'b00) begin//low
				note_c <= 9'b111001001;
				end
			else if (pitch == 2'b11) begin//high
				note_c <= 9'b001010101;
				end
			else if (pitch == 2'b10) begin
				note_c <= 9'b010101010;//right
				end
			else begin
				note_c <= 9'b111111111;//default-white
				end
			end
		else begin
			note_c <= 9'b111111111;
			end
		end
	
	always @(posedge clock)begin
		if (reset == 1'b1) begin
			plotx <= note_x;
			ploty <= 7'b0010000;
			if (county == 48) begin
				//ploty <= ploty + county;
				county <= 6'b0;
				end
			else begin
				//ploty <= ploty + county;
				county <= county + 1;
				end
			plotc <= 9'b111111111;
			end/*
		if (erase) begin
			plotx <= note_x;
			ploty <= 7'b00010000;
			if (county == 48) begin
				//ploty <= ploty + county;
				county <= 6'b0;
				end
			else begin
				//ploty <= ploty + county;
				county <= county + 1;
				end
			plotc <= 9'b111111111;
			end*/
		if (ERS) begin
			plotx <= note_x;	
			ploty <= 7'b0010000;
			plotc <= note_c;
			if (county == 48) begin
				//ploty <= ploty + county;
				county <= 6'b0;
				end
			else begin
				//ploty <= ploty + county;
				county <= county + 1;
				end	
			end
		else if (ERM) begin
			plotx <= pastmx;
			ploty <= pastmy;
			plotc <= background;
			end
		else if (PS) begin
			plotx <= note_x;
			ploty <= 7'b0010000;
			pastx <= note_x;
			plotc <= note_c;
			if (county == 48) begin
				//ploty <= ploty + county;
				county <= 6'b0;
				end
			else begin
				//ploty <= ploty + county;
				county <= county + 1;
				end	
			end
		else if (PM) begin
			plotx <= mx;
			pastmx <= mx;
			ploty <= my;
			pastmy <= my;
			plotc <= 9'b111110000;
			end
		/*else begin
			plotx <= plotx;
			ploty <= ploty;
			plotc <= plotc;
			
			end*/
		/*if (county == 48) begin
			county <= 6'b0;
			end
		else begin
			county<= county +1;
			end*/
		end
	
endmodule
	
	
	/*
module control(ready, reset, clock, color);
	input ready;
	input reset;
	input clock;
	output reg color;
	//output [2:0]LEDR;
	
	reg [22:0]DelayCounter = 23'b0;
	
	reg [1:0] current_state, next_state;
	parameter start = 2'b00,
	          draw = 2'b01,
	          Wait = 2'b10;
				 
	always @(*)
	begin: state_table
	   case (current_state)
			start: next_state = ready? draw : start;
			draw: next_state = Wait;
			Wait: next_state = draw;
			default: next_state = start;
		endcase
	end//fsm
	
	//output datapath signals
	always @(*) begin
		color = 1'b0;
		case (current_state) 
			start: color = 1'b0;//do not change the color
			draw: color = 1'b1;//change the color
			Wait: color = 1'b0;
		endcase
	end//

	
	always@(posedge clock)
   begin: state_FFs
      if(!reset)begin
         current_state <= start;
         end
      else begin
			if (current_state == Wait) begin
		      if (DelayCounter == 8333334) begin
				   DelayCounter <= 23'b0;
					current_state <= next_state;
					end
				else begin
				   DelayCounter <= DelayCounter +1;
					end
				end
			else begin
				current_state <= next_state;
				end
		end
   end 
	
	//assign LEDR[1:0] = current_state[1:0];
	
endmodule*/

/*
module datapath(note_num, lowhigh, clock, reset, color, plotx, ploty, plotc, county, mx, my);
	input [5:0]note_num;
	input [1:0]lowhigh;
	input clock;
	input reset;
	input color;
	
	//output to vga adapter
	output reg [7:0]plotx;
	output reg [6:0]ploty;
	output reg [8:0]plotc;
	
	output reg [5:0]county;
	output [8:0]LEDR;

	input [7:0]mx;
	input [6:0]my;
	
	reg [5:0]counter = 6'b0;
	
	
	
	
	always @(posedge clock) begin
		if (counter == 6'b110010) begin//erase the mouse
			county <= 6'b0;
			plotx <= mx;
			ploty <= my;
			plotc <= 9'b111111111;
			counter <= 6'b0;
			end
		else if (counter == 6'b000000) begin//draw mouse
			county <= 6'b0;
			plotx <= mx;
			ploty <= my;
			plotc <= //background color
			counter <= counter + 1;
			end
		else begin//draw the string
			ploty <= 7'b00010000;
			plotc <= 9'b111111111;
			if (!reset) begin
				plotc <= 9'b111111111;
				end
			else if (click) begin
				plox <= mx;
				plotc <= 9'b010101010;
				end

			else begin
		
			//control plot x
				if (note_num == 6'b010110)begin
					plotx <= 8'b01000110;//70
					end
				else if (note_num == 6'b011001)begin
					plotx <= 8'b01001001;//73
					end	
				else if (note_num == 6'b011101)begin
					plotx <= 8'b01001100;//76
					end
				else if (note_num == 6'b100000)begin
					plotx <= 8'b01000011;//67
					end
				
			//control plot color
				if (color) begin
					if (lowhigh == 2'b00) begin//low
						plotc <= 9'b111001001;
						end
					else if (lowhigh == 2'b11) begin//high
						plotc <= 9'b001010101;
						end
					else begin
						plotc <= 9'b010101010;//right
						end
					end
				else begin
					plotc <= plotc;
					end
			end//end else -plotx,pltc
			if (county == 48) begin
				county <= 6'b0;
				end
			else begin
				county <= county+1;
				end
			counter <= counter +1;
			end
			
	end//always block
	
endmodule*/
