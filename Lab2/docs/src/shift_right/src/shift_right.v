/* 32 - bit Right Shift register with shift_enable */
module shift_right 
#(
    parameter WIDTH = 32
)
(
    input clk,
    input rst_n,
    input [WIDTH - 1:0] data_in,
    input shift_enable,
    input load,
    output reg serial_out
);

    reg [WIDTH - 1:0] data_out;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            {serial_out, data_out} <= {1'b0, {WIDTH-1{1'b0}}};
        else if(load)
            data_out <= data_in;
        else if (shift_enable)
            {data_out[WIDTH-1:0], serial_out} <= {1'b0, data_out[WIDTH-1:0]};
        else 
            data_out <= data_out;
    end

endmodule