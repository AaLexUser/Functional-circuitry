`include "binval27seg/src/mru.v"
`include "binval27seg/src/BCD_converter.v"

module mru_bcd_it(
    input wire clk,
    input wire en,
    input wire rst_n,
    input wire set_i,
    input wire get_i,
    input wire [15:0] data_i,
    output wire [23:0] bcd_digits,
    output wire busy_o,
    output wire bcd_cvt_busy
);
  localparam DATA_IN_WIDTH = 20, DATA_OUT_WIDTH = 24;
  wire [19:0] data_o;
  reg bcd_rdy;
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

  wire bcd_cvt_rdy;
  BCD_converter #(
      .DATA_IN_WIDTH (20),
      .DATA_OUT_WIDTH(24)
  ) bcd (
      .clk   (clk),
      .en    (valid_o),
      .data_i(data_o),
      .data_o(bcd_digits),
      .busy_o(bcd_cvt_busy),
      .rdy_o (bcd_cvt_rdy)
  );

  always @(*) bcd_rdy = ~bcd_cvt_busy;
endmodule