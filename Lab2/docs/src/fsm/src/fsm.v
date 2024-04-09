`include "fsm/src/sub.v"
`include "fsm/src/adder.v"
`include "fsm/src/mul2.v"
`include "fsm/src/div2.v"
module fsm 
#(
    parameter WIDTH = 32,
    parameter OP_WIDTH = WIDTH + 3
)
(
    input clk,
    input [WIDTH - 1:0] a, b,
    input rst_n,
    output reg[OP_WIDTH-1:0] out,
    output reg ready
);

    localparam [3:0]
        S0 = 4'b0000,
        S1 = 4'b0001,
        S2 = 4'b0010,
        S3 = 4'b0011,
        S4 = 4'b0100,
        S5 = 4'b0101,
        S6 = 4'b0110,
        S7 = 4'b0111;
    reg [3:0] state;

    /* registers to store intermediate results */
    reg[OP_WIDTH - 1:0] reg1, reg2, reg3, reg4;

    reg[1:0] mul_cnt = 0;

    /* instantiate div2 module */
    reg [OP_WIDTH - 1:0] div2_in;
    wire [OP_WIDTH - 1:0] div2_out;
    div2 #(.WIDTH(OP_WIDTH)) div2_inst (
        .in(div2_in),
        .out(div2_out)
    );

    /* instantiate adder module */
    reg [OP_WIDTH - 1:0] add_a, add_b;
    wire [OP_WIDTH - 1:0] add_z;
    adder #(.WIDTH(OP_WIDTH)) add_inst (
        .x(add_a),
        .y(add_b),
        .z(add_z)
    );

    /* instantiate mul2 module */
    reg [OP_WIDTH - 1:0] mul2_in;
    wire [OP_WIDTH - 1:0] mul2_out;
    mul2 #(.WIDTH(OP_WIDTH)) mul2_inst (
        .in(mul2_in),
        .out(mul2_out)
    );

    /* instantiate sub module */
    reg [OP_WIDTH - 1:0] sub_a, sub_b;
    wire [OP_WIDTH - 1:0] sub_z;
    sub #(.WIDTH(OP_WIDTH)) sub_inst (
        .x(sub_a),
        .y(sub_b),
        .z(sub_z)
    );

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            state <= S0;
            out <= {WIDTH + 4{1'b0}};
            ready <= 1'b0;
        end
        else begin
            case (state)
                S0: begin
                    if(!ready) begin
                        /* load A and B */
                        reg1 <= a;
                        reg2 <= b;
                        reg3 <= a;
                        reg4 <= b;
                        state <= S1;
                    end
                end
                S1: begin
                    /* reg1 = (A / 2) */
                    reg1 <= div2_out;
                    state <= S2;
                end
                S2: begin
                    /* reg1 = (A / 2 + B) */
                    reg1 <= add_z;
                    state <= S3;
                end
                S3: begin
                    /* reg4 = (B / 2) */
                    reg4 <= div2_out;
                    state <= S4;
                end
                S4: begin
                    /* reg3 = (A - B / 2)*/
                    reg3 <= sub_z;
                    state <= S5;
                end
                S5: begin
                    /* reg1 = ((A / 2) + B) * 8 */
                    if(mul_cnt !== 2'd2) begin
                        reg1 <= mul2_out;
                        mul_cnt <= mul_cnt + 1;
                        state <= S5;
                    end
                    else begin
                        mul_cnt <= 0;
                        reg1 <= mul2_out;
                        state <= S6;
                    end
                end
                S6: begin
                    /* reg3 = (A - B / 2) * 4 */
                    if (mul_cnt !== 2'd1) begin
                        reg3 <= mul2_out;
                        mul_cnt <= mul_cnt + 1;
                        state <= S6;
                    end
                    else begin
                        mul_cnt <= 0;
                        reg3 <= mul2_out;
                        state <= S7;
                    end
                end
                S7: begin
                    /* out = ((A / 2) + B) * 8 + (A - B / 2) * 4 */
                    out <= add_z;
                    state <= S0;
                    ready <= 1'b1;
                end
                default: 
                    state <= state;
            endcase
        end
    end

    /* Connect inputs of adder, mul2, sub and div2 */
    always@(*) begin
        case (state)
            S1: begin
                div2_in = reg1;
            end 
            S2: begin
                add_a = reg1;
                add_b = reg2;
            end
            S3: begin
                div2_in = reg4;
            end
            S4: begin
                sub_a = reg3;
                sub_b = reg4;
            end
            S5: begin
                mul2_in = reg1;
            end
            S6: begin
                mul2_in = reg3;
            end
            S7: begin
                add_a = reg1;
                add_b = reg3;
            end
            default: begin
                div2_in = 0;
                add_a = 0;
                add_b = 0;
                mul2_in = 0;
                sub_a = 0;
                sub_b = 0;
            end
        endcase
    end
endmodule