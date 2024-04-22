/* Frequency clock divider */
module freq_div 
#(
    parameter DIV_CNT = 10,
    parameter WIDTH = $clog2(DIV_CNT)
)
(
    input clk_in,
    input rst_n,
    input enable,
    output clk_out
);
    reg [WIDTH-1:0] cnt;

    always @(posedge clk_in or negedge rst_n) begin
        if(!rst_n)
            cnt <= {WIDTH{1'b0}};
        else if (enable)
            if (cnt == DIV_CNT - 1)
                cnt <= {WIDTH{1'b0}};
            else 
                cnt <= cnt + 1'b1;
        else 
            cnt <= cnt;
    end

    assign clk_out = (cnt == 0 && rst_n && enable) ? 1'b1 : 1'b0;
endmodule