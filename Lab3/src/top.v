module top #(
    parameter MAX_RATE = 0
) (
    input clk,
    input rst_n,
    input set_i,
    input get_i,
    input [15:0] switch,
    output wire [7:0] anode,
    output wire [7:0] cathode,
    output wire mru_busy//,
   // output wire refresh_clock
);

  reg en = 1;
  localparam DATA_IN_WIDTH = 20, DATA_OUT_WIDTH = 24;
  wire [2:0] refreshcounter;
  wire [3:0] ONE_DIGIT;
    wire refresh_clock;
  
  reg rst = 0;
  wire [DATA_OUT_WIDTH - 1:0] bcd_digits;
  wire [DATA_IN_WIDTH-1:0] data_o;
  reg bcd_rdy;
  wire valid_o;


  freq_div refreshclk_wapper (
      .clk    (clk),
      .rst    (rst),
      .enable (en),
      .div_clk(refresh_clock)
  );
  
  wire deb_set_i;
  debounce deb_wapper_set (
      .clk      (refresh_clock),
      .rst_n    (rst_n),
      .button   (set_i),
      .debounced(deb_set_i)
  );
  
  wire deb_get_i;
  debounce deb_wapper_get (
      .clk      (refresh_clock),
      .rst_n    (rst_n),
      .button   (get_i),
      .debounced(deb_get_i)
  );
  
  
  reg bcd_cvt_busy;
  mru #(
      .MAX_RATE(MAX_RATE)
  ) mru_obj (
      .clk    (refresh_clock),
      .rst_n  (rst_n),
      .en     (en),
      .set_i  (set_i),
      .data_i (switch),
      .bcd_busy(bcd_cvt_busy),
      .get_i  (get_i),
      .data_o (data_o),
      .busy_o (mru_busy),
      .valid_o(valid_o)
  );

  refreshcounter refreshcnt_wapper (
      .refresh_clock (refresh_clock),
      .refreshcounter(refreshcounter)
  );

  anode_control anode_ctrl_wapper (
      .refreshcounter(refreshcounter),
      .anode         (anode)
  );


  BCD_control BCD_ctrl_wapper (
      .digit1        (data_o[3:0]),
      .digit2        (data_o[7:4]),
      .digit3        (data_o[11:8]),
      .digit4        (data_o[15:12]),
      .digit8        (data_o[19:16]),
      .en            (en),
      .refreshcounter(refreshcounter),
      .ONE_DIGIT     (ONE_DIGIT)
  );

  BCD_to_Cathodes BCD2Ctds (
      .digit  (ONE_DIGIT),
      .cathode(cathode)
  );


endmodule
/*
*                           ______________       ______________               _____________                ____________
*                          |              |     |     BCD      |   digit1    |             |              |            |
*                          |              |     |   converter  |-------------|             |              |            |
*                          |     MRU      |     |              |   digit2    |    BCD      |  4           |   BCD to   |   8             ____
*                ____      |              |     |              |-------------|   Control   |--/-----------|  Cathodes  |---/------------|____| cathode[7:0]
*  switch[15:0] |____|-----|              |-----| data_i       |   digit3    |             |ONE_DIGIT[3:0]|            |                 
*                          |              |     |              |-------------|             |              |            |
*                         _|clk           |     |              |   digit4    |             |              |____________|
*                        | |______________|     |              |-------------|             |
*                        |                      |              |   digit5    |             |
*                        |______________________| clk          |-------------|             |
*                                           |   |______________|             |_____________|            
*                                           |                                       |
*                                           |                                       |
*                                           |                                       |
*                                           |                                       |
*                                           |                                       |
*                                           |                                       |
*                                           |                                       |
*                                           |                                       |
*                                           |                       __________      |
*                                           |                      |          |     |
*                                           |        refresh_clock |  Refresh |  2  |
*                                           |                 _____|  Counter |__/__| refreshcounter[1:0]
*                                           |                |     |__________|     |
*                                           |                |                      |   
*                                           |                |__________            |
*                                           |                           |           |
*                 _________                 |                           |     ______|_____      
*       ____     |  Freq   |                |                           |    |  Anode     |                     4 anode[3:0]          ____
*  clk |____|____|  Div    |________________|___________________________|    |  Control   |---------------------/--------------------|____| anode[3:0]
*                |_________|                                                 |____________|                                           
*                     
*/



