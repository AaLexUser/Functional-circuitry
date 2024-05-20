`timescale 1ns / 1ps
`include "binval27seg/src/BCD_converter.v"
module BCD_converter_tb;
  localparam DATA_IN_WIDTH = 20, DATA_OUT_WIDTH = 24;
  reg clk = 0;
  reg en = 0;
  reg [DATA_IN_WIDTH-1:0] data_i = 0;
  wire [DATA_OUT_WIDTH-1:0] data_o;
  wire rdy_o;
  wire [3:0] digit1;
  wire [3:0] digit2;
  wire [3:0] digit3;
  wire [3:0] digit4;
  wire [3:0] digit5;
  wire [3:0] digit6;
  BCD_converter #(
      .DATA_IN_WIDTH (DATA_IN_WIDTH),
      .DATA_OUT_WIDTH(DATA_OUT_WIDTH)
  ) uut (
      .clk   (clk),
      .en    (en),
      .data_i(data_i),
      .data_o(data_o),
      .rdy_o (rdy_o)
  );

  always #5 clk = ~clk;

  initial begin
    data_i = 20'd865534;
    en = 1;
    #20 en = 0;
    #1400 $finish;
  end
  assign digit1 = data_o[3:0];
  assign digit2 = data_o[7:4];
  assign digit3 = data_o[11:8];
  assign digit4 = data_o[15:12];
  assign digit5 = data_o[19:16];
  assign digit6 = data_o[23:20];

endmodule
