/* Toggles between the display modes on rising edge of trigger */

module mode_toggler
(
	input wire trigger,
	output reg mode_num = 0
);
	
	always @(posedge trigger) begin
		mode_num <= !mode_num;
	end
	
endmodule
		
		
	