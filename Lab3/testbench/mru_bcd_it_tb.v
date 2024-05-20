`timescale 1ns / 1ps
`include "binval27seg/src/mru_bcd_it.v"
module mru_bcd_it_tb;

  reg clk = 0;
  reg rst_n = 1;
  reg en = 1;
  reg set_i = 0;
  reg [15:0] data_i = 0;
  reg get_i = 0;
  wire [19:0] data_o;
  wire [23:0] bcd_digits;
  wire busy_o;
  wire bcd_cvt_busy;

  mru_bcd_it uut (
      .clk         (clk),
      .en          (en),
      .rst_n       (rst_n),
      .set_i       (set_i),
      .get_i       (get_i),
      .data_i      (data_i),
      .bcd_digits  (bcd_digits),
      .busy_o      (busy_o),
      .bcd_cvt_busy(bcd_cvt_busy)
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
    while (busy_o == 1) begin
      @(posedge clk);
    end
    #10;
    while (bcd_cvt_busy == 1) begin
      @(posedge clk);
    end
    $finish;
  end



endmodule
