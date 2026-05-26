// ---------------------------------------------------------------------------
// © 2024 Renesas Electronics
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
// Base Module Name: pwm
// Target Device: SLG47910
// Tools version:
//   Software: ForgeFPGA Workshop v.6.34
//   Hardware: FPGAPAK Development Board Rev.1.1
// Revision:
//   01.26.2022 r001 - New design
//   01.25.2023 r002 - Code style review
//   03.29.2024 r003 - Limits added in the parameters comments
// ---------------------------------------------------------------------------
// Description :
//   PWM (Pulse Width Modulation) is a method of reducing the average power delivered by an electrical signal,
//   by effectively chopping it up into discrete parts.
// ---------------------------------------------------------------------------

`timescale 1ns / 1ps

module pwm #(
  parameter WIDTH = 8   // It’s the width of the PWM counter (Type - Decimal, Default value = 8, Min value = 2, Max value = 16)
) (
  input             i_clk,  // input clock signal
  input             i_rst,  // input reset signal
  input             i_en,   // input enable signal
  input [WIDTH-1:0] i_duty, // inputs bus of data that define the pulse width
  output reg        o_pwm   // output PWM signal
);

  reg [WIDTH-1:0] r_cnt = 'h0;

  // PWM counter (WIDTH-bit)
  always @(posedge i_clk) begin
    if (i_rst) begin
      r_cnt <= 'h0;
    end else if (i_en) begin
      r_cnt <= r_cnt + 1;
    end
  end

  // PWM signal
  always @(posedge i_clk) begin
    if (i_rst) begin
      o_pwm <= 1'b0;
    end else if (i_en) begin
      o_pwm <= (r_cnt < i_duty) ? 1'b1 : 1'b0;
    end else begin
      o_pwm <= 1'b0;
    end
  end

endmodule
