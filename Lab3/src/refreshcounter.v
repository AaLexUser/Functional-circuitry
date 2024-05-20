module refreshcounter (
    input refresh_clock,
    output reg [2:0] refreshcounter = 0
);

  always @(posedge refresh_clock) begin
    refreshcounter <= refreshcounter + 1;
  end

endmodule
