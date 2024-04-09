`timescale 1ns / 1ps

module andd3_tb;
//inputs
reg a, b, c;
wire out;

or2 uut(.a(a), .b(b), .out(out));

integer i, j;
initial 
begin
    for (i = 0; i < 2; i = i + 1) begin
        a = i;
        for (j = 0; j < 2; j = j + 1) begin
            b = j;
            #1;
         end
     end
     $stop;      
end
endmodule

