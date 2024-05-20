module BCD_converter #(
    parameter DATA_IN_WIDTH  = 16,
    parameter DATA_OUT_WIDTH = 20
) (
    input clk,
    input en,
    input [DATA_IN_WIDTH - 1:0] data_i,
    output reg [DATA_OUT_WIDTH - 1:0] data_o = 0,
    output reg rdy_o,
    output reg busy_o
);

  localparam BCD_WIDTH = DATA_IN_WIDTH + DATA_OUT_WIDTH;
  localparam CNT_WIDTH = $clog2(DATA_OUT_WIDTH) + 1;
  localparam SH_WIDTH = $clog2(DATA_IN_WIDTH) + 1;

  localparam [2:0] IDLE = 3'b000, SETUP = 3'b001, ADD = 3'b010, SHIFT = 3'b011, DONE = 3'b100;
  reg [BCD_WIDTH - 1:0] bcd_data = 0;
  reg [2:0] state = 0;
  reg [CNT_WIDTH:0] add_counter = 0;
  reg [SH_WIDTH:0] sh_counter = 0;
  wire [DATA_OUT_WIDTH-1:0] zeros;
  assign zeros = {DATA_OUT_WIDTH{1'b0}};
  
  always @(posedge clk) begin
    if (en) begin
      if (!busy_o) begin
        bcd_data <= {zeros, data_i};
        rdy_o <= 0;
        state <= SETUP;
      end
    end else begin
      case (state)
        IDLE: begin
          busy_o <= 0;  //TODO:
        end
        SETUP: begin
          busy_o <= 1;
          state <= ADD;
        end
        ADD: begin
          if (bcd_data[(DATA_OUT_WIDTH-1)+add_counter*4-:4] > 3'd4)
            bcd_data[BCD_WIDTH-1:DATA_IN_WIDTH] <= bcd_data[BCD_WIDTH-1:DATA_IN_WIDTH] + (2'd3 << (add_counter*4));
          add_counter <= add_counter + 1;
          if (add_counter == (DATA_OUT_WIDTH / 4)) begin
            add_counter <= 0;
            state <= SHIFT;
          end
        end
        SHIFT: begin
          sh_counter <= sh_counter + 1;
          bcd_data   <= bcd_data << 1;
          if (sh_counter == (DATA_IN_WIDTH - 1)) begin
            sh_counter <= 0;
            state <= DONE;
          end else begin
            state <= ADD;
          end
        end
        DONE: begin
          rdy_o  <= 1;
          data_o <= bcd_data[BCD_WIDTH-1:DATA_IN_WIDTH];
          state <= IDLE;
        end
        default: state <= IDLE;
      endcase
    end
  end



endmodule
