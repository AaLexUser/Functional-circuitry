module counter 
#(
    parameter WIDTH = 32
)
(
    input clk,
    input rst_n,
    input enable,
    output reg [WIDTH - 1:0] cnt
);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            cnt <= {WIDTH{1'b0}};
        else if (enable)
            cnt <= cnt + 1'b1;
        else 
            cnt <= cnt;
    end
endmodule