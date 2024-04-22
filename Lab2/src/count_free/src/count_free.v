`include "count_free/src/freq_div.v"
/* sequential input, parallel output */
module shift_left 
#(
    parameter WIDTH = 32
)
(
    input clk,
    input rst,
    input data_in,
    input shift_enable,
    output reg [WIDTH - 1:0] data_out
);
    always @(posedge clk) begin
        if (shift_enable)
            data_out <= {data_out[WIDTH-2:0], data_in};
    end
    always @(posedge rst) begin
        data_out <= {WIDTH{1'b0}};
    end 
endmodule

module counter_upd
#(
    parameter WIDTH = 32
)
(
    input clk,
    input rst,
    input enable,
    input load,
    input [WIDTH - 1:0] data_in,
    output reg [WIDTH - 1:0] cnt
);
    always @(posedge clk) begin
        if(load)
            cnt <= data_in;
        else if (enable)
            cnt <= cnt + 1'b1;
        else 
            cnt <= cnt;
    end
    always@(posedge rst) begin
        if(rst)
            cnt <= {WIDTH{4'hF}};
    end
endmodule


module count_free 
#(
    parameter WIDTH = 32,
    parameter DIV_CNT = 10
)
(
    input clk,
    input en,
    input rst,
    input start_req_i,
    input start_data_i,
    input ready_i,
    output result_rsp_o,
    output reg busy_o
);

localparam [1:0] 
    WAIT = 2'b00,
    READ = 2'b01,
    COUNT = 2'b10;

    reg [1:0] state;

    wire fd_clk;

    freq_div freq_div_inst (
        .clk_in(clk),
        .rst_n(~rst),
        .enable(en),
        .clk_out(fd_clk)
    );

    reg shlft_en;
    wire [WIDTH-1:0] shlft_out;

    shift_left shlft (
        .clk(fd_clk),
        .rst(rst),
        .data_in(start_data_i),
        .shift_enable(shlft_en),
        .data_out(shlft_out)
    );

    reg cnt_rst;
    reg cnt_en;
    reg cnt_ld;
    reg [WIDTH-1:0] cnt_data;
    wire [WIDTH-1:0] cnt_out;

    counter_upd cnt (
        .clk(fd_clk),
        .rst(cnt_rst),
        .enable(cnt_en),
        .load(cnt_ld),
        .data_in(cnt_data),
        .cnt(cnt_out)
    );
    
    always @(posedge rst) begin
        shlft_en <= 1'b1;

            cnt_rst <= 1'b1;
            cnt_en <= 1'b0;

            busy_o <= 1'b0;
            state <= WAIT;
    end

    always @(posedge fd_clk) begin
        if(en) begin
            case (state)
                WAIT: begin
                    cnt_rst <= 1'b0;
                    if (start_req_i) begin
                        cnt_ld <= 1'b1;
                        busy_o <= 1'b1;
                        state <= READ;
                    end
                end
                READ: begin
                    if (!start_req_i) begin
                        shlft_en <= 1'b0;
                        cnt_ld <= 1'b0;
                        cnt_en <= 1'b1;
                        
                        state <= COUNT;
                    end
                end
                COUNT: begin
                    if (!cnt_out) begin
                        cnt_en <= 1'b0;
                        if(ready_i) begin
                            cnt_rst <= 1'b1;
                            busy_o <= 1'b0;
                            state <= WAIT;
                        end
                    end
                end
                default: begin
                    state <= WAIT;
                end
            endcase
        end
    end

    assign result_rsp_o = !cnt_out ? 1'b1 : 1'b0;

    always @(*) begin
        cnt_data = ~shlft_out + 1'b1;
    end


endmodule