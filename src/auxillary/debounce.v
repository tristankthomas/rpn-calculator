module debounce
#(
	parameter CLK_PERIOD_ns = 20,
	parameter DEBOUNCE_TIMER_ns = 30_000_000 //30ms
	
)
(	
	input wire clk,
	input wire enable,
	input wire resetn,
	input wire sig_i,
	output wire sig_o
);

	// syncronise the input
	wire sig_i_sync;
	
	synchroniser sync
	(
		.clk(clk),
		.in(sig_i),
		.in_sync(sig_i_sync)
	);

	localparam TIMER_ADJUST = DEBOUNCE_TIMER_ns - 2 * CLK_PERIOD_ns; // Since the synchroniser synchronises input by two clock cycles
	
	// States
	localparam
		ON = 1'b1,
		OFF = 1'b0;

	
	
	reg state = OFF;
	wire timer_resetn;
	wire timer_start;
	wire done;
	
	// counter instansitation
	timer
	#(
		.CLK_PERIOD_ns(CLK_PERIOD_ns),
		.TIMER_PERIOD_TYPE("ns"),
		.TIMER_PERIOD_ns(TIMER_ADJUST)
	)
	
	timer_inst
	(
		.clk(clk),
		.enable(enable),
		.resetn(resetn),
		.sync_resetn(timer_resetn),
		.start(timer_start),
		.done(done)
	);
	
	
	always @(posedge clk or negedge resetn) begin // 
		if (!resetn) begin
			state <= OFF;
		end else begin
			if (enable == 1'b1) begin
				case (state)
					ON:
						if (done && !sig_i_sync)
							state <= OFF;
						else
							state <= ON;
					OFF:
						if (done && sig_i_sync)
							state <= ON;
						else
							state <= OFF;
				endcase
			
			end
			
		end
	end
	
	assign timer_resetn = (sig_i_sync != sig_o);
	assign timer_start = !done && sig_i_sync != sig_o;
	assign sig_o = state;


	
	
	
endmodule
	
	
	