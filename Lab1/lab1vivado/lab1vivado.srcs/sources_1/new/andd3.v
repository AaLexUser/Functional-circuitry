`timescale 1ns / 1ps


module andd3(
input wire a, b, c,
    output wire out
    );

wire ab, not_ab, abc;
nand(ab, a, b);
nand(not_ab, ab, ab);
nand(abc, not_ab, c);
nand(out, abc, abc);
endmodule
