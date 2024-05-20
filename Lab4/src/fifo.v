module fifo #(
    parameter DATA_WIDTH = 32,
    parameter PTR_WIDTH  = 3
) (
    input clk,
    input rst_n,

    input [DATA_WIDTH-1:0] din,
    input push,
    input pop,
    output reg [DATA_WIDTH-1:0] dout
);
  /* Pointers to head and tail of the FIFO */
  reg [PTR_WIDTH-1:0] rd_ptr;
  reg [PTR_WIDTH-1:0] wr_ptr;

  /* FIFO memory */
  reg [DATA_WIDTH-1:0] mem[0:2**PTR_WIDTH-1];

  reg [PTR_WIDTH:0] count;

  /* Signals to indicate empty and full status */
  wire empty = (count == 0);
  wire full = (count == (2 ** PTR_WIDTH));

  always @(*) begin
    if (pop && !empty) dout = mem[rd_ptr];
    else dout = 0;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rd_ptr <= 0;
      wr_ptr <= 0;
      count  <= 0;
    end else begin
      if (push && !full) begin
        mem[wr_ptr] <= din;
        wr_ptr <= wr_ptr + 1;
        count <= count + 1;
      end
      if (pop && !empty) begin
        rd_ptr <= rd_ptr + 1;
        count  <= count - 1;
      end
    end
  end

endmodule
