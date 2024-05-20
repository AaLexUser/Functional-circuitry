module mru #(
    parameter BUF_SIZE = 8,
    parameter WIDTH = 16,
    parameter MAX_RATE = 100000000
) (
    input clk,
    input rst_n,
    input en,
    input set_i,
    input [15:0] data_i,
    input bcd_busy,
    input get_i,  // Flag to get data
    output reg [19:0] data_o,
    output reg busy_o,
    output reg valid_o
);
  localparam [2:0] IDLE = 3'b000, CHECKING_HIT = 3'b001, HIT_UPDATING = 3'b010, WRITE_VALUE = 3'b011, SEND_DATA = 3'b100;

  reg [         15:0] dataCopy;
  reg [WIDTH - 1 : 0] outs                            [BUF_SIZE - 1:0];
  reg [          2:0] state;

  reg [          3:0] hitIndex;  // reg to counting
  reg [          2:0] index;  // last in MRU
  reg [          3:0] freeEl = 3'b0;  // first free_el
  reg [         31:0] set_cnt = 0;
  reg [         31:0] get_cnt = 0;


  always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      outs[0] <= 20'd0;
      outs[1] <= 20'd0;
      outs[2] <= 20'd0;
      outs[3] <= 20'd0;

      outs[4] <= 20'd0;
      outs[5] <= 20'd0;
      outs[6] <= 20'd0;
      outs[7] <= 20'd0;

      dataCopy <= 20'd0;

      hitIndex <= 4'd0;
      index <= 3'd0;
      freeEl <= 4'd0;

      data_o <= 20'd0;
      busy_o <= 1'b0;
      state <= IDLE;
      valid_o <= 1'b1;
    end else if (en) begin
      case (state)
        IDLE: begin
          case ({
            set_i, get_i
          })
            2'b01: begin
              if (get_cnt >= MAX_RATE) begin
                busy_o <= 1'b1;
                if (data_i >= freeEl) data_o[19:0] <= 0;
                else data_o[19:0] <= {freeEl, outs[data_i]};
                valid_o <= 1'b1;
                get_cnt <= 0;
                state <= IDLE;
              end else if (get_i) begin
                get_cnt <= get_cnt + 1;
              end
            end
            2'b10: begin
              if (set_cnt >= MAX_RATE) begin
                busy_o <= 1'b1;
                state <= CHECKING_HIT;
                dataCopy <= data_i;
                hitIndex <= 0;
              end else if (set_cnt) begin
                set_cnt <= set_cnt + 1;
              end
            end
            default: begin
              state <= IDLE;
            end
          endcase
        end
        SEND_DATA: begin
          if (!bcd_busy) begin
            valid_o <= 1'b0;
            busy_o  <= 1'b0;
            state   <= IDLE;
          end
        end
        CHECKING_HIT: begin
          if (hitIndex > 7) begin
            state <= WRITE_VALUE;
            if (freeEl < 4'd8) begin
              index  <= freeEl;
              freeEl <= freeEl + 1;
            end
          end else begin
            case (hitIndex)
              0: begin
                if (outs[0] == dataCopy) state <= HIT_UPDATING;
                else hitIndex <= hitIndex + 1;
              end
              1: begin
                if (outs[1] == dataCopy) state <= HIT_UPDATING;
                else hitIndex <= hitIndex + 1;
              end
              2: begin
                if (outs[2] == dataCopy) state <= HIT_UPDATING;
                else hitIndex <= hitIndex + 1;
              end
              3: begin
                if (outs[3] == dataCopy) state <= HIT_UPDATING;
                else hitIndex <= hitIndex + 1;
              end
              4: begin
                if (outs[4] == dataCopy) state <= HIT_UPDATING;
                else hitIndex <= hitIndex + 1;
              end
              5: begin
                if (outs[5] == dataCopy) state <= HIT_UPDATING;
                else hitIndex <= hitIndex + 1;
              end
              6: begin
                if (outs[6] == dataCopy) state <= HIT_UPDATING;
                else hitIndex <= hitIndex + 1;
              end
              7: begin
                if (outs[7] == dataCopy) state <= HIT_UPDATING;
                else hitIndex <= hitIndex + 1;
              end
            endcase
          end
        end
        HIT_UPDATING: begin
          index  <= hitIndex;
          busy_o <= 1'b0;
          state  <= IDLE;
        end
        WRITE_VALUE: begin
          case (index)
            0: outs[0] <= dataCopy;
            1: outs[1] <= dataCopy;
            2: outs[2] <= dataCopy;
            3: outs[3] <= dataCopy;
            4: outs[4] <= dataCopy;
            5: outs[5] <= dataCopy;
            6: outs[6] <= dataCopy;
            7: outs[7] <= dataCopy;
          endcase
          busy_o <= 1'b0;
          state  <= IDLE;
        end
      endcase
    end
  end
endmodule
