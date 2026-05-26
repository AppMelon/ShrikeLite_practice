(* top *) module top #(
	parameter CLK = 50_000_000,
	parameter BAUD_RATE = 115200
)(
	(* iopad_external_pin, clkbuf_inhibit *) input clk,
	(* iopad_external_pin *) input rx,
	(* iopad_external_pin *) input rst,
	(* iopad_external_pin *) output led,
	(* iopad_external_pin *) output led_en,
	(* iopad_external_pin *) output clk_en
);

	assign led_en = 1'b1;
	assign clk_en = 1'b1;
	
	wire [7:0] data;
	wire data_done, data_parity;
	
	uart_receiver uart1_rx
	(	.i_clk(clk),
		.i_rst_n(~rst),
		.i_rx(rx),
		.o_rx_data(data),
		.o_rx_done(data_done),
		.o_parity_error(data_parity)
	);
	
	reg [7:0] duty_cycle;

	always @(posedge clk) begin
    		if(data_done) begin
    			duty_cycle <= data;
    		end
	end
	
	pwm PWM1
	( 	.i_clk(clk),
		.i_rst(rst),
		.i_en(1'b1),
		.i_duty(duty_cycle),
		.o_pwm(led)
	);

endmodule