module PWM # (
	parameter WIDTH = 8
)(
	input clk,
	input rst,
	input [WIDTH-1:0] brightness,
	output led
);
	reg [WIDTH-1:0] counter;
	
	always @(posedge clk) begin
		if(rst) begin
			counter <= 0;
		end
		counter <= counter + 1'b1;
	end
	
	assign led = (counter<brightness);

endmodule