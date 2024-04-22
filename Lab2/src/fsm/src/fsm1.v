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
        S6 = 3'b110,
        S7 = 3'b111;

    reg [2:0] state, next_state;
    reg [1:0] mul_cnt = 0; 
    reg [1:0] next_mul_cnt;

    /* instantiate div2 module */
    reg [WIDTH - 1:0] div2_in;
    wire [WIDTH - 1:0] div2_out;
    div2 #(.WIDTH(WIDTH)) div2_inst (
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
    wire [WIDTH - 1:0] sub_z;
    sub #(.WIDTH(WIDTH)) sub_inst (
        .x(a),
        .y(div2_out[WIDTH-1:0]),
        .z(sub_z)
    );

    // Additional registers to manage values consistently
     reg[OP_WIDTH - 1:0] reg1, reg2, reg3, reg4;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            state <= S0;
            out <= {WIDTH + 4{1'b0}};
            ready <= 1'b0;
        end
        else begin
            state <= next_state;
            mul_cnt <= next_mul_cnt;
            case (state)
                S0: begin
                    if(!ready) begin
                        /* reg1 = (A / 2) */
                        reg1 <= a;
                        reg2 <= b;
                        reg3 <= a;
                        reg4 <= b;
                    end
                end
                S1: begin
                    /* reg1 = (A / 2) */
                    reg1 <= div2_out;
                end
                S2: begin
                    /* reg2 = (B / 2) */
                    /* reg1 = (A / 2 + B) */
                    reg1 <= add_z;
                end
                S3: begin
                    /* reg2 = (A - B / 2)*/
                    reg2 <= sub_z;
                    /* reg1 = ((A / 2) + B) * 2 */
                    mul2_in <= mul2_out;
                end
                S4: begin
                    /* reg1 = ((A / 2) + B) * 2 * 4 */
                    mul2_in <= mul2_out;
                end
                S5: begin
                    /* reg2 = (A - B / 2) * 4 */
                    add_b <= mul2_out;
                end
                S6: begin
                    /* out = ((A / 2) + B) * 8 + (A - B / 2) * 4 */
                    out <= add_z;
                    ready <= 1'b1;
                end
                default: begin
                    out <= out;
                    ready <= 1'b0;
                end
            endcase
        end
    end

    /* Connect inputs of adder, mul2, sub and div2 */
    always@(*) begin
        next_state = state;
        next_mul_cnt = mul_cnt;
        case (state)
            S0: begin
                next_state = S1;
            end 
            S1: begin
                div2_in = reg1;
                next_state = S2;
            end
            S2: begin
                div2_in = reg4;
                add_a = reg1;
                add_b = reg2;
                next_state = S3;
            end
            S3: begin
                mul2_in = reg1;
                next_state = S4;
            end
            S4: begin
                if(mul_cnt == 2'b10) begin
                    next_state = S5;
                    next_mul_cnt = 2'b00;
                    add_a = mul2_in;
                end else begin
                    next_mul_cnt = mul_cnt + 2'b01;
                end
            end
            S5: begin
                mul2_in = reg2;
                if (mul_cnt == 2'b01) begin
                    next_state = S6;
                    next_mul_cnt = 2'b00;
                end else begin
                    next_mul_cnt = mul_cnt + 2'b01;
                end
            end
            S6: begin
                next_state = S0;
            end
            default: next_state = S0;
        endcase
    end
endmodule