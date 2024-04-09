`timescale 1ps/1ps
module sub 
#(
    parameter WIDTH = 32
)
(
    input [WIDTH - 1:0] x, y,
    output [WIDTH - 1:0] z
);
    assign z = x + (~y) + 1;
  
endmodule