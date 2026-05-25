(* top *) module top #(
	parameter CLK = 50_000_000,
	parameter BAUD_RATE = 115200
)(
	(* iopad_external_pin, clkbuf_inhibit *) input clk,
	(* iopad_external_pin *) input rx,
	(* iopad_external_pin *) input rst,
	(* iopad_external_pin *) output reg led,
	(* iopad_external_pin *) output led_en,
	(* iopad_external_pin *) output clk_en
);

	assign led_en = 1'b1;
	assign clk_en = 1'b1;
	
	wire [7:0] data;
	wire data_valid;
	wire parity_error;
	uart_receiver UART1 
	(	.i_clk(clk),
		.i_rst_n(~rst),
		.i_rx(rx),
		.o_rx_data(data),
		.o_rx_done(data_valid),
		.o_parity_error(parity_error)
	);
	
	assign led = data_valid;
// 	always @(posedge clk) begin
// 		if(rst) begin
// 			led <= 1'b0;
// 		end
// 		else if (data_valid) begin
// 			if(data==8'h61) begin
// 				led <= 1'b1;
// 			end
// 			else if(data==8'h62) begin
// 				led <= 1'b0;
// 			end
// 			else begin
// 				led <= led;
// 			end
// 		end
// 	end
	
endmodule