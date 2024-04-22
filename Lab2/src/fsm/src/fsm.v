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
        S5 = 3'b101;

    reg [2:0] state;
    reg mul_cnt = 0; 

    /* instantiate div2 module */
    wire [WIDTH - 1:0] div2_in;
    wire [WIDTH - 1:0] div2_out;
    div2 #(.WIDTH(WIDTH)) div2_inst (
    .in(div2_in),
    .out(div2_out)
    );

    /* instantiate adder module */
    wire [OP_WIDTH - 1:0] add_a, add_b;
    wire [OP_WIDTH - 1:0] add_z;
    adder #(.WIDTH(OP_WIDTH)) add_inst (
        .x(add_a),
        .y(add_b),
        .z(add_z)
    );

    /* instantiate mul2 module */
    wire [OP_WIDTH - 1:0] mul2_in;
    wire [OP_WIDTH - 1:0] mul2_out;
    mul2 #(.WIDTH(OP_WIDTH)) mul2_inst (
        .in(mul2_in),
        .out(mul2_out)
    );

    /* instantiate sub module */
    wire[WIDTH - 1:0] sub_b;
    wire [WIDTH - 1:0] sub_z;
    sub #(.WIDTH(WIDTH)) sub_inst (
        .x(a),
        .y(sub_b),
        .z(sub_z)
    );

    // Additional registers to manage values consistently
    reg [OP_WIDTH - 1:0] reg1, reg2;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            state <= S0;
            out <= {WIDTH + 4{1'b0}};
            mul_cnt <= 0;
            ready <= 1'b0;
        end
        else begin
            mul_cnt <= !mul_cnt;
            if(!ready) begin
                case (state)
                    S0: begin
                        /* reg1 = (A / 2) */
                        reg1 <= div2_out;
                        state <= S1;
                    end
                    S1: begin
                        /* reg2 = (B / 2) */
                        reg2 <= div2_out;
                        /* reg1 = (A / 2 + B) */
                        reg1 <= add_z;
                        state <= S2;
                    end
                    S2: begin
                        /* reg2 = (A - B / 2)*/
                        reg2 <= sub_z;
                        /* reg1 = ((A / 2) + B) * 2 */
                        reg1 <= mul2_out;
                        state <= S3;
                    end
                    S3: begin
                        /* reg1 = ((A / 2) + B) * 2 * 4 */
                        reg1 <= mul2_out;
                        state <= !mul_cnt ? S4 : S3;
                    end
                    S4: begin
                        /* reg2 = (A - B / 2) * 4 */
                        reg2 <= mul2_out;
                        state <= !mul_cnt ? S5 : S4;
                        
                    end
                    S5: begin
                        /* out = ((A / 2) + B) * 8 + (A - B / 2) * 4 */
                        out <= add_z;
                        ready <= 1'b1;
                    end
                    default: begin
                        state <= S0;
                    end
                endcase
            end
        end
    end

    assign div2_in = state == S0 ? a :
            state == S1 ? b : 0;
    assign sub_b = state == S2 ? reg2 : 0;
    assign mul2_in = state == S2 || state == S3 ? reg1 : 
                    state == S4 ? reg2 : 0;
    assign add_a = state == S1 ? reg1: 
                    state == S5 ? reg1 : 0;
    assign add_b = state == S1 ? b : state == S5 ? reg2 : 0;
endmodule