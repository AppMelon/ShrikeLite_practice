// ---------------------------------------------------------------------------
// © 2025 Renesas Electronics
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
// OR OTHER DEALINGS IN THE SOFTWARE.
// ---------------------------------------------------------------------------
// Base Module Name: uart_receiver
// Target Devices: SLG47910
// Tools version:
//   Software: ForgeFPGA Workshop v.6.50
//   Hardware: FPGAPAK Development Board Rev.2.0
// Revision:
//   07.08.2021 r001 - New design
//   09.16.2022 r002 - Code style review
//   04.02.2024 r003 - Limits added in the parameters comments
//   11.06.2025 r004 - Modules redesign
// ---------------------------------------------------------------------------
// Description :
// The UART module (Universal Asynchronous receiver-transmitter) used for asynchronous serial communication,
// the module function is to convert outgoing data into serial binary stream and vice versa.
// _______      ____________________________________________________________
//        \____/_____X_____X_____X_____X_____X_____X_____X_____X_____X_____X
//       [START][LSB........... DATA FRAME ................MSB][PAR_B][STOP]
// ---------------------------------------------------------------------------

`timescale 1ns/1ps

module uart_receiver #(
  parameter IN_CLK_HZ         = 50_000_000, // input operating frequency Hz (Type - Decimal, Default value = 50_000_000, Min value = 1_000_000, Max value = 60_000_000)
  parameter DATA_FRAME        = 8,          // number of data bits (5 ~ 9 bits long) (Type - Decimal, Default value = 8, Min value = 5, Max value = 9)
  parameter BAUD_RATE         = 115_200,    // transmitting speed 4_800 - 115_200 (Type - Decimal, Default value = 115_200, Value = [4_800, 9_600, 19_200, 38_400, 57_600, 115_200])
  parameter OVERSAMPLING_MODE = 16,         // bit offset or overlap (Type - Decimal, Default value = 16, Value = [8, 16])
  parameter PARITY_TYPE       = 0,          // error-checking bit added to a data frame: 0 - PARITY_NONE, 1 - PARITY_EVEN and 2 - PARITY_ODD (Type - Decimal, Default value = 0, Value = [0, 1, 2])
  parameter STOP_BIT          = 0,          // length of stop bit: 0 - 1 bit, 1 - 1.5 bit and 2 - 2 bit (Type - Decimal, Default value = 0, Value = [0, 1, 2])
  parameter LSB               = 1'b0        // when one, data starts from LSB, otherwise data starts from MSB (Type - Boolean, Default value = 1'b1, Min value = 1'b0, Max value = 1'b1)
) (
// common port
  input                       i_clk,         // input clock signal
  input                       i_rst_n,       // input negative reset signal
// interface port
  input                       i_rx,          // rx input carries the input serial data
// internal port
  output     [DATA_FRAME-1:0] o_rx_data,     // receive data output bus
  output                      o_rx_done,     // done signal
  output                      o_parity_error // indicates a parity mismatch in the received UART frame
);

// Signal declaration
  wire w_tick;

// Control receiving data via UART
  uart_receiveruart_receiver_rx #(
    .DATA_FRAME         (DATA_FRAME        ),
    .BAUD_RATE          (BAUD_RATE         ),
    .OVERSAMPLING_MODE  (OVERSAMPLING_MODE ),
    .PARITY_TYPE        (PARITY_TYPE       ),
    .STOP_BIT           (STOP_BIT          ),
    .LSB                (LSB               )
  ) uart_receiver_rx_wrapper (
    .i_clk              (i_clk             ),
    .i_rst_n            (i_rst_n           ),
    .i_rx               (i_rx              ),
    .i_tick             (w_tick            ),
    .o_rx_data          (o_rx_data         ),
    .o_rx_done          (o_rx_done         ),
    .o_parity_error     (o_parity_error    )
  );

// Module generate one bit period
  uart_receiverbaud_rate_generator_rx #(
    .BAUD_RATE         (BAUD_RATE         ),
    .OVERSAMPLING_MODE (OVERSAMPLING_MODE ),
    .IN_CLK_HZ         (IN_CLK_HZ         )
  ) baud_rate_gen_rx_wrapper (
    .i_clk             (i_clk             ),
    .i_rst_n           (i_rst_n           ),
    .o_tick            (w_tick            )
  );

endmodule

// Control receiving data via UART
module uart_receiveruart_receiver_rx #(
  parameter DATA_FRAME        = 8,           // number of data bits (5 ~ 9 bits long) (Type - Decimal, Default value = 8, Min value = 5, Max value = 9)
  parameter BAUD_RATE         = 115_200,     // transmitting speed 9_600 - 115_200 (Type - Decimal, Default value = 115_200, Value = [4_800, 9_600, 19_200, 38_400, 57_600, 115_200])
  parameter OVERSAMPLING_MODE = 16,          // bit offset or overlap (Type - Decimal, Default value = 16, Value = [8, 16])
  parameter PARITY_TYPE       = 0,           // error-checking bit added to a data frame: 0 - PARITY_NONE, 1 - PARITY_EVEN and 2 - PARITY_ODD (Type - Decimal, Default value = 0, Value = [0, 1, 2])
  parameter STOP_BIT          = 0,           // length of stop bit: 0 - 1 bit, 1 - 1.5 bit and 2 - 2 bit (Type - Decimal, Default value = 0, Value = [0, 1, 2])
  parameter LSB               = 1'b1         // when one, data starts from LSB, otherwise data starts from MSB (Type - Boolean, Default value = 1'b1, Min value = 1'b0, Max value
) (
  input                       i_clk,         // input clock signal
  input                       i_rst_n,       // input reset signal
  input                       i_rx,          // rx input carries the input serial data
  input                       i_tick,        // input 'tick' pulse with a defined period
  output reg [DATA_FRAME-1:0] o_rx_data,     // receive data output bus
  output reg                  o_rx_done,     // done signal
  output reg                  o_parity_error // indicates a parity mismatch in the received UART frame
);

// Localparam declaration
  localparam STOP_BIT_P1 = (STOP_BIT == 1)        ? (OVERSAMPLING_MODE / 2) : OVERSAMPLING_MODE;
  localparam STOP_BIT_P2 = (STOP_BIT == 0)        ? DATA_FRAME : DATA_FRAME + 1;
  localparam STOP_BIT_P3 = (PARITY_TYPE == 2'b00) ? STOP_BIT_P2 : STOP_BIT_P2 + 1;
  localparam I_CNT_VAL   = (PARITY_TYPE == 2'b00) ? DATA_FRAME + 1 : DATA_FRAME + 2;
  localparam B_CNT_WIDTH = $clog2(OVERSAMPLING_MODE);

// Signal declaration
  reg                               r_receive, r_parity_check;
  reg [2:0]                         r_rx_sync;
  reg [$clog2(OVERSAMPLING_MODE):0] r_baud_counter;
  reg [$clog2(I_CNT_VAL-1):0]       r_bit_index;
  wire                              w_start_det;

// Create internal signals and counters
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      r_rx_sync <= 3'b111;
    end else begin
      r_rx_sync <= {r_rx_sync[1:0], i_rx};
    end
  end

  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      r_receive <= 1'b0;
    end else if (r_baud_counter == STOP_BIT_P1 && r_bit_index == STOP_BIT_P3) begin
      r_receive <= 1'b0;
    end else if (!r_rx_sync[1] && r_baud_counter[B_CNT_WIDTH - 1]) begin
      r_receive <= 1'b1;
    end
  end

  assign w_start_det = ~r_receive & r_rx_sync[2] & ~r_rx_sync[1];

  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      r_baud_counter <= 'h0;
    end else if (w_start_det || r_baud_counter[B_CNT_WIDTH] || (!r_receive && r_baud_counter[B_CNT_WIDTH - 1])) begin
      r_baud_counter <= 'h0;
    end else begin
      if (i_tick) begin
        r_baud_counter <= r_baud_counter + 1;
      end
    end
  end

  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      r_bit_index <= 'h0;
    end else if (!r_receive) begin
      r_bit_index <= 'h0;
    end else begin
      if (r_baud_counter[B_CNT_WIDTH]) begin
        r_bit_index <= r_bit_index + 1;
      end
    end
  end

// Create output signals
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_rx_data <= 'h0;
    end else if (r_bit_index < DATA_FRAME && r_baud_counter[B_CNT_WIDTH]) begin
      if (LSB) begin
        o_rx_data <= {r_rx_sync[1], o_rx_data[DATA_FRAME-1:1]};
      end else begin
        o_rx_data <= {o_rx_data[DATA_FRAME-2:0], r_rx_sync[1]};
      end
    end
  end

  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      r_parity_check <= 1'b0;
    end else if (r_bit_index == I_CNT_VAL - 2 && r_baud_counter[B_CNT_WIDTH]) begin
      if (PARITY_TYPE == 2'b01) begin
        r_parity_check <= (r_rx_sync[1] != ^o_rx_data);
      end else if (PARITY_TYPE == 2'b10) begin
        r_parity_check <= (r_rx_sync[1] == ^o_rx_data);
      end
    end
  end

  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_rx_done <= 1'b0;
    end else if (!r_receive) begin
      o_rx_done <= 1'b0;
    end else if (i_tick) begin
      if (PARITY_TYPE != 2'b00 && r_bit_index == I_CNT_VAL - 1) begin
        o_rx_done <= ~r_parity_check;
      end else if (r_bit_index == I_CNT_VAL - 1) begin
        o_rx_done <= 1'b1;
      end
    end
  end

  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_parity_error <= 1'b0;
    end else if (!r_receive) begin
      o_parity_error <= 1'b0;
    end else if (i_tick) begin
      if (PARITY_TYPE != 2'b00 && r_bit_index == I_CNT_VAL - 1) begin
        o_parity_error <= r_parity_check;
      end else if (r_bit_index == I_CNT_VAL - 1) begin
        o_parity_error <= 1'b0;
      end
    end
  end

endmodule

// Module generate one bit period
module uart_receiverbaud_rate_generator_rx #(
  parameter IN_CLK_HZ         = 50_000_000, // input operating frequency Hz (Type - Decimal, Default value = 50_000_000, Min value = 1_000_000, Max value = 60_000_000)
  parameter BAUD_RATE         = 115_200,    // transmitting speed 4_800 - 115_200 (Type - Decimal, Default value = 115_200, Value = [4_800, 9_600, 19_200, 38_400, 57_600, 115_200])
  parameter OVERSAMPLING_MODE = 16          // bit offset or overlap (Type - Decimal, Default value = 16, Value = [8, 16])
) (
  input      i_clk,                         // input clock signal
  input      i_rst_n,                       // input negative reset signal
  output reg o_tick                         // output 'tick' pulse with a defined period
);

// Counter parameters depends from UART speed and oscillator period
  localparam DIV_CNT_VAL   = (IN_CLK_HZ / (BAUD_RATE * OVERSAMPLING_MODE)) - 1;
  localparam DIV_CNT_WIDTH = $clog2(DIV_CNT_VAL);

  reg [DIV_CNT_WIDTH-1:0] r_count;

// Counter UART speed (bit period)
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      r_count <= 'h0;
      o_tick  <= 1'b0;
    end else begin
      r_count <= r_count + 1;
      o_tick  <= 'b0;
      if (r_count == DIV_CNT_VAL) begin
        r_count <= 'h0;
        o_tick  <= 'b1;
      end
    end
  end

endmodule
