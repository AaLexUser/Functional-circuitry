`timescale 1ns / 1ps //reference time / precision


module full_comparator4_tb;
//inputs
reg[3:0] a, b;
reg fl, fe, fg;
//outputs
wire l;
wire e;
wire g;

// Unit under test (UUT)

full_comparator4 uut(a, b, fl, fe, fg, l, e, g);

//32 bit integer
integer i, j;

reg[3:0] expr_lt, expr_eq, expr_gt;

initial
begin
{fl, fe, fg} = 3'b010;
    for (i = 0; i < 16; i = i + 1) begin
        a = i;
        for (j = 0; j < 16; j = j + 1) begin
            b = j;
            expr_lt = ( i < j );
            expr_eq = ( i == j );
            expr_gt = ( i > j );
            #10;
            if (l == expr_lt & e == expr_eq & g == expr_gt) begin
                $display("[CORRECT]: a = %d, b = %d, l = %d, e = %d, g = %d", a, b, l, e, g);
            end else begin
                 $display("[INCORRECT]: a=%d, b=%d, expr_lt=%d, expr_eq=%d, expr_gt=%d, l=%d, e=%d, g=%d",
                 a, b, expr_lt, expr_eq, expr_gt, l, e, g);
            end
        end
    end
$stop;
end


endmodule
