module blink #(
	parameter FREQ = 1,		// in Hz
	parameter CLK = 50_000_000
)(
	input clk,
	output led,
	output led_en,
	output clk_en
);
	
	parameter CLK_LED = CLK / FREQ;

	assign clk_en = 1'b1;
	assign led_en = 1'b1;
	
	reg [31:0] counter;
	reg led_status;
	
	always @(posedge clk) begin
		counter <= counter + 1'b1;
		if(counter == CLK_LED) begin
			led_status = !led_status;
			counter <= 32'b0;
		end
	end
	
	assign led = led_status;

endmodule