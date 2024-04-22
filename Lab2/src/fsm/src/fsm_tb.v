`timescale 1ps/1ps
`include "fsm/src/fsm.v"
module fsm_tb;
    localparam WIDTH = 32;
    localparam OP_WIDTH = WIDTH + 4;
    reg clk;
    reg [WIDTH - 1:0] a, b;
    reg rst_n;
    wire ready;
    wire [OP_WIDTH-1:0] out;
    reg passed = 1;
    reg [OP_WIDTH-1:0] tst_out;
    fsm #(.WIDTH(WIDTH)) fsm_dut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .out(out),
        .ready(ready)
    );

    /* Clock generation */
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    task check;
        begin
            if(tst_out !== out) begin
                $display("[T=%0g] Test failed: expected %g, got %g", $time, tst_out, out);
                passed = 0;
            end 
        end
    endtask

    task calfunc(input [WIDTH - 1:0] a, b, output [OP_WIDTH-1:0] out);
        begin
            out = ((a / 2) + b) * 8 + (a - (b / 2)) * 4;
        end
    endtask

    initial begin
        $dumpfile("build/fsm.vcd");
        $dumpvars(1);

        $monitor("[T=%0d] state->%0d, reg1=%0d, reg2=%0d, add_a=%0d, add_b=%0d, div2_in=%0d, mul2_in=%0d, mul_cnt=%0d, ready=%b, out=%0d", 
            $time, fsm_dut.state,fsm_dut.reg1, fsm_dut.reg2,fsm_dut.add_a, fsm_dut.add_b, fsm_dut.div2_in, fsm_dut.mul2_in, fsm_dut.mul_cnt, fsm_dut.ready, fsm_dut.out);

        rst_n = 0;
        
        /* Test: a = 6 and b = 4 */
        $display("[T=%0g] Test 1: a = 6, b = 4", $time);
        @(negedge clk) begin
            a <= 32'd6;
            b <= 32'd4;
            rst_n <= 1;
        end
        while (!ready) begin
            @(posedge clk);
        end
        calfunc(a, b, tst_out);
        check;

        /* Test: Reset */
        $display("[T=%0g] Test 2: Reset", $time);
        @(negedge clk) begin
            rst_n <= 0;
            a <= 32'd5678;
            b <= 32'd1234;
        end
        tst_out = 0;
        @(posedge clk) check;

        @(negedge clk) begin
            rst_n <= 1;
        end

        while(!ready) begin
            @(posedge clk);
        end
        calfunc(a, b, tst_out);
        @(posedge clk) check;

        /* Test: Max values a = 2^32 - 1 and b = 2^32 - 1 */
        $display("[T=%0g] Test 3: a = 2^32 - 1, b = 2^32 - 1", $time);
        @(negedge clk) begin
            rst_n <= 0;
        end
        @(negedge clk) begin
            // a = 2^32 - 1
            a <= 32'hFFFFFFFF;
            // b = 2^32 - 1
            b <= 32'hFFFFFFFF;
            rst_n <= 1;
        end
        while (!ready) begin
            @(posedge clk);
        end
        calfunc(a, b, tst_out);
        @(posedge clk) check;

        /* Test: Zero values a = 0 and b = 0 */
        $display("[T=%0g] Test 4: a = 0, b = 0", $time);
        @(negedge clk) begin
            a <= 32'h0;
            b <= 32'h0;
            rst_n <= 0;
        end
        @(negedge clk) begin
            rst_n <= 1;
        end
        while (!ready) begin
            @(posedge clk);
        end
        calfunc(a, b, tst_out);
        @(posedge clk) check;

        if(passed)
            $display("[T=%0g] All tests passed", $time);
        else
            $display("[T=%0g] Some tests failed", $time);
        #30; $finish;
    end  
    
endmodule