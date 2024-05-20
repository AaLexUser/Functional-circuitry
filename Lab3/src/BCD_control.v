module BCD_control (
    input [3:0] digit1,  // ones
    input [3:0] digit2,  // tens
    input [3:0] digit3,  // hundreds
    input [3:0] digit4,  // thousands
    input [3:0] digit8,  // buff size
    input [2:0] refreshcounter,
    input en,
    output reg [3:0] ONE_DIGIT = 0  // choose which digit is to be displayed
);

  always @(*) begin
    if (en) begin
      case (refreshcounter)
        3'd0: ONE_DIGIT = digit1;  // digit 1 value ON
        3'd1: ONE_DIGIT = digit2;  // digit 2 value ON
        3'd2: ONE_DIGIT = digit3;  // digit 3 value ON
        3'd3: ONE_DIGIT = digit4;  // digit 4 value ON  
        3'd7: ONE_DIGIT = digit8;
        default: ONE_DIGIT = 0;
      endcase
    end else ONE_DIGIT = 0;
  end
endmodule
