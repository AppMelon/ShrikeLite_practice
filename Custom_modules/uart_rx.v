// Custom Module

module uart_rx #(
	parameter CLK = 50_000_000,
	parameter BAUD_RATE = 115_200,
	parameter WIDTH = 8
)(
	input clk,
	input rx,
	output [WIDTH-1:0] data,
	output data_valid
);
	parameter ACTUAL_CLK = CLK / BAUD_RATE;

	parameter IDLE = 3'b000;
	parameter START = 3'b001;
	parameter DATA = 3'b010;
	parameter STOP = 3'b011;
	parameter DONE = 3'b100;
	
	reg [2:0] cs;
	reg [17:0] clock_counter;
	reg [7:0] ind;
	reg [WIDTH-1:0] received_data;
	reg valid;
	
	always @(posedge clk) begin
		case(cs)
			IDLE: begin
				valid <= 1'b0;
				clock_counter <= 0;
				ind <= 0;
				if(rx==1'b0) begin
					cs <= START;
				end
				else begin
					cs <= IDLE;
				end
			end
			
			START: begin
				if(clock_counter == ACTUAL_CLK / 2) begin
					if(rx==1'b0) begin
						clock_counter <= 0;
						cs <= DATA;
					end
					else begin
						cs <= IDLE;
					end
				end
				else begin
					clock_counter <= clock_counter + 1'b1;
					cs <= START;
				end
			end
			
			DATA: begin
				if(clock_counter < ACTUAL_CLK-1) begin
					clock_counter <= clock_counter + 1'b1;
					cs <= DATA;
				end
				else begin
					clock_counter <= 0;
					received_data[ind] <= rx;
					if(ind<WIDTH-1) begin
						ind <= ind + 1'b1;
						cs <= DATA;
					end
					else begin
						ind <= 0;
						cs <= STOP;
					end
				end
			end
			
			STOP: begin
				if(clock_counter < ACTUAL_CLK-1) begin
					clock_counter <= clock_counter + 1'b1;
					cs <= STOP;
				end
				else begin
					clock_counter <= 0;
					valid <= 1'b1;
					cs <= DONE;
				end
			end
			
			DONE: begin
				cs <= IDLE;
				valid <= 1'b0;
			end
			
			default: cs <= IDLE;
		endcase
	end
	
	assign data_valid = valid;
	assign data = received_data;
	
endmodule
