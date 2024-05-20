module freq_div #(
    parameter DIV_CNT = 50_000
) (
    input  wire clk,
    input  wire rst,
    input  wire enable,
    output reg  div_clk = 0
);

  localparam WIDTH = $clog2(DIV_CNT);

  reg [WIDTH-1:0] cnt = 0;

  always @(posedge clk or posedge rst) begin
    if (rst) cnt <= {WIDTH{1'b0}};
    else if (enable) begin
      if (cnt == DIV_CNT) cnt <= {WIDTH{1'b0}};
      else cnt <= cnt + 1'b1;
    end
  end


  always @(posedge clk or posedge rst) begin
    if (rst) div_clk <= 1'b0;
    else if (enable) begin
      if (cnt == DIV_CNT) div_clk <= ~div_clk;
    end
  end

endmodule
