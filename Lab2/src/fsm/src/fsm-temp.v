`include "fsm/src/sub.v"
`include "fsm/src/adder.v"
`include "fsm/src/mul2.v"
`include "fsm/src/div2.v"
module fsm 
#(
    parameter WIDTH = 32,
    parameter OP_WIDTH = WIDTH + 4,
    parameter DIV_WIDTH = WIDTH - 1,
    parameter MUL1_WIDTH = WIDTH + 3,
    parameter MUL2_WIDTH = WIDTH,
    parameter ADDER1_WIDTH = WIDTH,
    parameter ADDER2_WIDTH = WIDTH + 3,
    parameter SUB_WIDTH = WIDTH - 2
)
(
    input clk,
    input [WIDTH - 1:0] a, b,
    input rst_n,
    output reg[OP_WIDTH-1:0] out,
    output reg ready
);

    localparam [2:0]
        S0 = 3'b000,
        S1 = 3'b001,
        S2 = 3'b010,
        S3 = 3'b011,
        S4 = 3'b100,
        S5 = 3'b101,
        S6 = 3'b110;
    reg [2:0] state;

    reg[1:0] mul_cnt = 2'b00;

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
                        /* reg1 = (A / 2) */
                        add_a <= div2_out;
                        state <= S1;
                    end
                end
                S1: begin
                    /* reg2 = (B / 2) */
                    sub_b <= div2_out;
                    /* reg1 = (A / 2 + B) */
                    mul2_in <= add_z;
                    state <= S2;
                end
                S2: begin
                     /* reg2 = (A - B / 2)*/
                    add_b <= sub_z;
                    /* reg1 = ((A / 2) + B) * 2 */
                    add_a <= mul2_out;
                    state <= S3;
                end
                S3: begin
                    /* reg1 = ((A / 2) + B) * 2 * 4 */
                    if(!mul_cnt[1]) begin
                        mul_cnt <= mul_cnt + 1'b1;
                        add_a <= mul2_out;
                        state <= S3;
                    end
                    else begin
                        mul_cnt <= 2'b00;
                        state <= S4;
                    end
                end
                S4: begin
                    /* reg2 = (A - B / 2) * 4 */
                    if (!mul_cnt[1]) begin
                        mul_cnt <= mul_cnt + 1'b1;
                        add_b <= mul2_out;
                        state <= S4;
                    end
                    else begin
                        mul_cnt <= 2'b00;
                        state <= S5;
                    end
                end
                S5: begin
                    /* out = ((A / 2) + B) * 8 + (A - B / 2) * 4 */
                    out <= add_z;
                    state <= S0;
                    ready <= 1'b1;
                end
            endcase
        end
    end

    /* Connect inputs of adder, mul2, sub and div2 */
    always@(*) begin
        case (state)
            S0: begin
                div2_in = a;
                add_b = b;
                sub_a = a;
            end 
            S1: begin
                div2_in = add_b;
            end
            S2: begin
                sub_b = div2_out;
            end
            S3: begin
                mul2_in = add_a;
                sub_a = 0;
                sub_b = 0;
                div2_in = 0;
            end
            S4: begin
                mul2_in = add_b;
                sub_a = 0;
                sub_b = 0;
                div2_in = 0;
            end
            S5: begin
                sub_a = 0;
                sub_b = 0;
                div2_in = 0;
                mul2_in = 0;
            end
            default begin
                add_a = 0;
                add_b = 0;
                sub_a = 0;
                sub_b = 0;
                div2_in = 0;
                mul2_in = 0;
            end
        endcase
    end
endmodule