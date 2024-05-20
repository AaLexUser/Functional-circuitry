`timescale 1ns / 1ps

module fifo_tb;
  localparam WIDTH = 32;
  localparam PTR_WIDTH = 3;
  reg clk, rst_n, push, pop;
  reg [WIDTH-1:0] din;
  wire [WIDTH-1:0] dout;

  fifo #(
      .DATA_WIDTH(WIDTH),
      .PTR_WIDTH (PTR_WIDTH)
  ) ff (
      .clk  (clk),
      .rst_n  (rst_n),
      .din  (din),
      .push (push),
      .dout (dout),
      .pop  (pop)
  );

  reg tst_out;
  reg [3:0] test_num;  /* Test case number */

  reg passed = 1;
  /* Clock generation */
  always begin
    #5 clk = ~clk;
  end

  integer i;
  initial begin
    $dumpfile("build/fifo.vcd");
    $dumpvars(1);
    $monitor("rst_n=%b, push=%b, pop=%b, wr_ptr=%b, rd_ptr=%b, din=%0h, dout=%0h, full=%0b, empty=%0b"
             , rst_n, push, pop, ff.wr_ptr, ff.rd_ptr, din, dout, ff.full, ff.empty);
    clk  <= 0;
    rst_n  <= 0;
    push <= 0;
    pop  <= 0;
    #10;
    rst_n <= 1;
    #10;
    test_num <= 0;
    $display("Test 1: Basic write/read");
    write_data(4'b1010);
    read_data();
    check_output(4'b1010);
    reset();
    $display("Test 2: Overflow condition");
    for (i = 0; i < 8; i = i + 1) write_data(i);
    write_data(4'b0101);  // Attempt to write when full
    check_full_flag();
    reset();
    $display("Test 3: Underflow condition");
    for (i = 0; i < 8; i = i + 1) write_data(i);
    for (i = 0; i < 8; i = i + 1) read_data();
    @(negedge clk) begin
      pop <= 1;
    end
    @(negedge clk) begin
      pop <= 0;
    end
    check_empty_flag();
    reset();
    $display("Test 4: PUSH and POP on the same clock cycle");
    write_data(4'b1011);
    @(negedge clk) begin
      din  <= 4'b1010;
      push <= 1;
      pop  <= 1;
    end
    @(negedge clk) begin
      push <= 0;
      pop  <= 0;
    end
    @(posedge clk);
    if (dout !== 4'b1011) begin
      $display("Error: Expected output %h, got %h", 4'b1011, dout);
      passed = 0;
    end

    if (passed) $display("[T=%0g] All tests passed", $time);
    else $display("[T=%0g] Some tests failed", $time);

    #100;
    $finish;

  end

  task run_test;
    input reg [3:0] test_id;
    integer i;

    begin
      case (test_id)
        0: begin  // Basic write/read
          write_data(4'b1010);
          read_data();
          check_output(4'b1010);
        end
        1: begin  // Overflow condition
          for (i = 0; i < 8; i = i + 1) write_data(i);
          write_data(4'b0101);  // Attempt to write when full
          check_full_flag();
        end
        2: begin  // Underflow condition
          for (i = 0; i < 8; i = i + 1) write_data(i);
          for (i = 0; i < 8; i = i + 1) read_data();
          @(negedge clk) begin
            pop <= 1;
          end
          @(negedge clk) begin
            pop <= 0;
          end
          check_empty_flag();
        end
      endcase
    end
  endtask

  task reset;
    begin
      @(negedge clk) begin
        rst_n <= 0;
      end
      @(negedge clk) begin
        rst_n <= 1;
      end
    end
  endtask


  task write_data;
    input reg [WIDTH-1:0] data;

    begin
      @(negedge clk) begin
        din  <= data;
        push <= 1;
      end
      @(negedge clk) begin
        push <= 0;
      end
    end
  endtask

  task read_data;
    begin
      @(negedge clk) begin
        pop <= 1;
      end
      @(negedge clk) begin
        pop <= 0;
      end
    end
  endtask

  task check_output;
    input reg [32:0] expected_value;
    begin
      @(posedge clk);
      if (dout !== expected_value) begin
        $display("Error: Expected output %h, got %h", expected_value, dout);
        passed = 0;
      end
    end
  endtask
  task check_full_flag;
    begin
      @(posedge clk);
      if (!ff.full) begin
        $display("Error: FIFO should be full but full flag is not set");
        passed = 0;
      end
    end
  endtask
  task check_empty_flag;
    begin
      @(posedge clk);
      if (!ff.empty) begin
        $display("Error: FIFO should be empty but empty flag is not set");
        passed = 0;
      end
    end
  endtask






endmodule
