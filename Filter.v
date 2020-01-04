module Filter(CLOCK_50, 
             reset_n,
				 write_in,
				 ready_write,
				 write_out,
				 start,
				 mag,
				 index,
				 done, LEDR);
				 
	output [7:0]LEDR;
	assign LEDR[7:0] = mag[63:56];
				 
	input CLOCK_50;
   input reset_n;		
	input [31:0]write_in;
	input ready_write;
	output write_out;
	//from upstream module
	
	output reg start;
	output [63:0]mag;
	reg [63:0]mag1;
	reg [63:0]mag2;
	output [10:0]index;
	input done;
	//to downstream module
	
	//wires connected to fft
	reg [1:0] sink_error = 2'b0;
	reg sink_sop = 1'b0;
	reg sink_eop = 1'b0;
	wire source_sop;
	wire source_eop;
	wire signed [31:0]source_real;
	wire signed [31:0]source_imag;
	wire [1:0] source_error;
	wire source_valid;
	//wire sink_ready = 1'b1;
	
	wire [10:0]fftpts_in = 11'b01000000000;
	reg [10:0]counter = 11'b0;
	

	wire sop;
	wire eop;
	wire [31:0]sink_imag = 32'b0;
	//wire inverse = 1'b0;
	wire [1:0]error;
	//counter to set sop and eop
	always @(posedge CLOCK_50) begin
		if (reset_n) begin
			sink_sop <= 1'b0;
			sink_eop <= 1'b0;
			counter <= 11'b0;
			end
		else begin
			if (counter == 0) begin
				sink_sop <=1'b1;
				sink_eop <=1'b0;
				counter <= counter +1;
				end
			else if (counter == 1) begin
				sink_sop <=1'b0;
				counter <= counter +1;
				end
			else if (counter == 1023) begin
				sink_eop <=1'b1;
				counter <= 0;
				end
			else begin
				sink_sop <=1'b0;
				sink_eop <=1'b0;
				counter <= counter +1;
				end
			end
	end
	
			
	
	//set values for sink_error
	always @(posedge CLOCK_50) begin
		if (reset_n) begin
			sink_error <= 2'b00;
			end
		else begin
			if ((!sink_sop) && (counter == 1)) begin
				sink_error <= 2'b01;
				end
		/*else if ((counter == 1023) && (!sink_eop)) begin
			sink_error <= 2'b10;
			end*/
		/*else if (write_in <= 10) begin //too small or large magnitude of frequency
			sink_error <= 2'b11;
			end*/
			else begin
				sink_error <= 2'b00;
				end
			end
	end
	

	assign sop = sink_sop;
	assign eop = sink_eop;
	assign error[1:0] = sink_error[1:0];
	//call fft
	FFT u0 (
		.clk          (CLOCK_50),          //    clk.clk
		.reset_n      (~reset_n),      //    rst.reset_n
		.sink_valid   (ready_write),   //   sink.sink_valid
		.sink_ready   (write_out),   //       .sink_readywrite_in <= 10
		.sink_error   (error),   //       .sink_error
		.sink_sop     (sop),     //       .sink_sop
		.sink_eop     (eop),     //       .sink_eop
		.sink_real    (write_in),    //       .sink_real
		.sink_imag    (sink_imag),    //       .sink_imag
		.fftpts_in    (fftpts_in),    //       .fftpts_in
		.inverse      (1'b0),      //       .inverse
		.source_valid (source_valid), // source.source_valid
		.source_ready (done), //       .source_ready
		.source_error (source_error), //       .source_error
		.source_sop   (source_sop),   //       .source_sop
		.source_eop   (source_eop),   //       .source_eop
		.source_real  (source_real),  //       .source_real
		.source_imag  (source_imag),  //       .source_imag
		.fftpts_out   (index)    //       .fftpts_out
	);

	
	
	//check if the filter is ready to start (output to next module)
	always @(posedge CLOCK_50)begin
	if ((source_sop == 1'b1) && (source_error == 2'b00) && (source_valid)) begin
		start <= 1'b1;
		end
	else if ((source_eop == 1'b1) && (source_error == 2'b00) && (source_valid)) begin
		start <= 1'b0;
		end
	else begin
		start <= 1'b1;
		end
	end
	
	//find the magnitude of each output number
	always @(posedge CLOCK_50)begin
		mag1 <= (source_real * source_real);
      mag2 <= (source_imag * source_imag);

      end
  assign mag = mag1 + mag2;
endmodule
