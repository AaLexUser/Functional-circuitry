`timescale 1ns / 1ps

module debounce #(
    parameter DELAY = 0 /* Number of clock cycles to wait before considering the button stable */
) (
    input clk,
    input rst_n,
    input button,
    output reg debounced
);

  reg [32:0] counter;
  reg prev_state;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter <= 0;
      prev_state <= 1'b0;
      debounced <= 1'b0;
    end else begin
      if (button != prev_state) begin
        counter <= 0;
      end else if (counter == DELAY) begin
        debounced <= button;
      end else begin
        counter <= counter + 1;
      end
      prev_state <= button;
    end
  end
endmodule

