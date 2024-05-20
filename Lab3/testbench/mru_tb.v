`timescale 1ns / 1ps
`include "binval27seg/src/mru.v"
module mru_tb;
  reg clk = 0;
  reg rst_n = 1;
  reg en = 1;
  reg set_i = 0;
  reg [15:0] data_i = 0;
  reg bcd_rdy = 0;
  reg get_i = 0;
  wire [19:0] data_o;
  wire busy_o;
  wire valid_o;

  mru #(
      .MAX_RATE(0)
  ) uut (
      .clk    (clk),
      .rst_n  (rst_n),
      .en     (en),
      .set_i  (set_i),
      .data_i (data_i),
      .bcd_rdy(bcd_rdy),
      .get_i  (get_i),
      .data_o (data_o),
      .busy_o (busy_o),
      .valid_o(valid_o)
  );

  always #5 clk = ~clk;

  initial begin
    rst_n = 0;
    en = 1;
    #10 rst_n = 1;
    #10 data_i = 16'd65233;
    #10 set_i = 1;
    #10 set_i = 0;
    #10;
    while (busy_o == 1) begin
      @(posedge clk);
    end
    #10 data_i = 0;
    #10 get_i = 1;
    #10 get_i = 0;
    #10 bcd_rdy = 1;
    while (busy_o == 1) begin
      @(posedge clk);
    end
    #10 bcd_rdy = 0;
    $finish;
  end

endmodule



