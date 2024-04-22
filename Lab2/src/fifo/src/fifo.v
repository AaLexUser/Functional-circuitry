`timescale 1ns / 1ps
module fifo 
#(
    parameter DATA_WIDTH = 32,
    parameter PTR_WIDTH = 3
)
(
    input clk,
    input rst,

    input [DATA_WIDTH-1:0] din,
    input push,

    output reg [DATA_WIDTH-1:0] dout,
    output reg rd_en,
    input pop

);
    /* Pointers to head and tail of the FIFO */
    reg [PTR_WIDTH-1:0] rd_ptr;
    reg [PTR_WIDTH-1:0] wr_ptr;

    /* FIFO memory */
    reg [DATA_WIDTH-1:0] mem [0:2**PTR_WIDTH-1];

    /* Signals to indicate empty and full status */
    wire empty, full;

    reg[PTR_WIDTH-1:0] dist;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
            wr_ptr <= 0;
            dist <= 0;
        end
        else begin
            case ({push, pop})
                2'b10: begin // Push
                    if (!full) begin
                        mem[wr_ptr] <= din;
                        wr_ptr <= wr_ptr + 1;
                    end
                end
                2'b01: begin // Pop
                    if (!empty) begin
                        dout <= mem[rd_ptr];
                        rd_en <= 1;
                        rd_ptr <= rd_ptr + 1;
                    end
                end
                2'b11: begin // Push and Pop
                    if (!full) begin
                        mem[wr_ptr] <= din;
                        wr_ptr <= wr_ptr + 1;
                        dout <= mem[rd_ptr];
                        rd_en <= 1;
                    end
                end
            endcase
        end 
    end

    assign empty = (wr_ptr == rd_ptr) & push ? 0 :
                    (wr_ptr == rd_ptr) & pop ? 1 : 1;
    assign full = (wr_ptr == rd_ptr) & pop ? 0 :
                    (wr_ptr == rd_ptr) & push ? 1 : 1;
endmodule
