`timescale 1ns / 1ps

module full_comparator(
    input wire a, b,
    output wire l, e, g
    );
wire not_a, not_b;
wire v1_1, v1_2, v2_1;

nand(not_a, a, a);
nand(not_b, b, b);
nand(v1_1, not_a, b);
nand(v1_2, not_b, a);

nand(l, v1_1, v1_1);

nand(v2_1, v1_1, v1_2);
nand(e, v2_1, v2_1);

nand(g, v1_2, v1_2);

endmodule

module and2(
    input wire a, b,
    output wire out
    );
wire ab;
nand(ab, a, b);
nand(out, ab, ab);

endmodule

module and3(
    input wire a, b, c,
    output wire out
    );

wire ab, not_ab, abc;
nand(ab, a, b);
nand(not_ab, ab, ab);
nand(abc, not_ab, c);
nand(out, abc, abc);
endmodule

module or2(
    input wire a, b,
    output wire out
    );
wire not_a, not_b;
nand(not_a, a, a);
nand(not_b, b, b);

nand(out, not_a, not_b);
endmodule

module full_comparator_seq(
    input wire a, b, fl, fe, fg,
    output wire l, e, g
);

wire not_fl, not_fg, fc_l, fc_e, fc_g, add3_out, andl_out, andg_out;
nand(not_fl, fl, fl);
nand(not_fg, fg, fg);

full_comparator fc_i(.a(a), .b(b), .l(fc_l), .e(fc_e), .g(fc_g));
and3 and3_i(.a(not_fl), .b(fe), .c(not_fg), .out(add3_out));

and2 and2_i1(.a(fc_l), .b(add3_out), .out(andl_out));
and2 and2_i2(.a(fc_e), .b(add3_out), .out(e));
and2 and2_i3(.a(fc_g), .b(add3_out), .out(andg_out));

or2 or_i1(.a(andl_out), .b(fl), .out(l));
or2 or_i2(.a(andg_out), .b(fg), .out(g));

endmodule



module full_comparator4(
    input wire[0:3] a,
    input wire[0:3] b,
    input fl, fe, fg,
    output l, e, g
    );
wire[2:0] fcsl_out, fcse_out, fcsg_out;
full_comparator_seq fcs1(a[0],b[0],fl,fe,fg,fcsl_out[0],fcse_out[0],fcsg_out[0]);
full_comparator_seq fcs2(a[1],b[1],fcsl_out[0],fcse_out[0],fcsg_out[0], fcsl_out[1],fcse_out[1],fcsg_out[1]);
full_comparator_seq fcs3(a[2],b[2],fcsl_out[1],fcse_out[1],fcsg_out[1], fcsl_out[2],fcse_out[2],fcsg_out[2]);
full_comparator_seq fcs4(a[3],b[3],fcsl_out[2],fcse_out[2],fcsg_out[2],l,e,g);    
endmodule
