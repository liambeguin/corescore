`default_nettype none

module corescorecore_pf (
	input  wire i_clk,
	input  wire resetb,
	output wire o_led1,
	output wire o_led2,
	output wire o_led3 = 1'b0,
	output wire o_led4 = 1'b0,
	output wire o_led5 = 1'b0,
	output wire o_led6 = 1'b0,
	output wire o_led7 = 1'b0,
	output wire o_led8 = 1'b0,
	output wire o_uart_tx);

	parameter memfile_emitter = "emitter.hex";

	wire	clk;
	wire	rst;
	wire	q;
	wire	CLKINT_0_Y;
	reg		heartbeat;

	CLKINT CLKINT_0 (
		.A (i_clk),
		.Y (CLKINT_0_Y)
	);

	pf_clock_gen #(
		.refclk(50),
		.frequency(32)
	) clock_gen (
		.i_clk (CLKINT_0_Y),
		.o_clk (clk)
	);

	wire [7:0]	tdata;
	wire		tlast;
	wire		tvalid;
	wire		tready;

	corescorecore corescorecore (
		.i_clk		(clk),
		.i_rst		(rst),
		.o_tdata	(tdata),
		.o_tlast	(tlast),
		.o_tvalid	(tvalid),
		.i_tready	(tready)
	);

	emitter #(
		.memfile (memfile_emitter)
	) emitter (
		.i_clk		(clk),
		.i_rst		(rst),
		.i_tdata	(tdata),
		.i_tlast	(tlast),
		.i_tvalid	(tvalid),
		.o_tready	(tready),
		.o_uart_tx	(o_uart_tx)
	);

	// heartbeat LED
	reg [$clog2(32000000)-1:0] count = 0;
	always @(posedge clk) begin
		if (rst) begin
			count <= 0;
			heartbeat <= 0;
		end else
			count <= count + 1;
		if (count == 32000000-1) begin
			heartbeat <= !heartbeat;
			count <= 0;
		end
	end

	assign rst = ~resetb;
   //Mirror UART output to LED
	assign o_led1 = o_uart_tx;
	assign o_led2 = heartbeat;

endmodule
