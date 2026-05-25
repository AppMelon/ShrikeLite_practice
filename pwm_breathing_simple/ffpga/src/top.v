(* top *) module top #(
	CLK = 50_000_000,
	BAUD_RATE = 115_200
)(
	(* iopad_external_pin, clkbuf_inhibit *) input clk,
	(* iopad_external_pin *) output led,
	(* iopad_external_pin *) output led_en,
	(* iopad_external_pin *) input rst,
	//(* iopad_external_pin *) input brightness,
	(* iopad_external_pin *) output clk_en
);
	parameter BRIGHT_CHANGE = 500_000;
	
	assign clk_en = 1'b1;
	assign led_en = 1'b1;
	
	reg [7:0] brightness;
	reg [31:0] counter;
	reg cs, ns;
	
	always @(posedge clk) begin
		if(rst) begin
			brightness <= 8'b0;
			counter <= 32'b0;
		end
		else if(counter == BRIGHT_CHANGE) begin
			counter <= 32'b0;
			brightness <= (cs)?brightness + 1'b1 : brightness - 1'b1;
		end
		else begin
			counter <= counter + 1'b1;
		end
	end
	
	always @(*) begin
		case(cs)
			1'b0 : ns = (brightness == 8'b0);
			1'b1 : ns = (brightness != 8'hFF);
			default : ns = 1'b1;
		endcase
	end
	
	always @(posedge clk) begin
		if(rst) begin
			cs <= 1'b1;
		end
		else begin
			cs <= ns;
		end
	end
	
	pwm # ( .WIDTH(8))
	PWM_1
		( 
		.i_clk(clk),
		.i_rst(rst),
		.i_en(1'b1),
		.i_duty(brightness),
		.o_pwm(led)
		);

endmodule