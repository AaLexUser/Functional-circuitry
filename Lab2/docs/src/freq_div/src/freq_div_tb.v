`timescale 1ns/1ps
`include "freq_div/src/freq_div.v"

module freq_div_tb;
    localparam DIV_CNT = 10;
    reg  clk_in;
    reg  rst_n;
    reg enable;
    wire clk_out;
    freq_div #(.DIV_CNT(DIV_CNT)) fd_dut(
        .clk_in (clk_in),
        .rst_n (rst_n),
        .enable (enable),
        .clk_out (clk_out)
    );

    reg passed = 1;
    reg tst_out;

    /* Clock generation */

    initial begin
        clk_in = 0;
        forever #10 clk_in = !clk_in;
    end

    task check;
        begin
            if(tst_out != clk_out) begin
                $display("[T=%0g] Test failed: expected %g, got %g", $time, tst_out, clk_out);
                passed = 1'b0;
            end
        end
    endtask

    integer i;
    initial begin
        $dumpfile("build/freq_div.vcd");
        $dumpvars(1);
        $monitor("[T=%0d] enable=%b, rst_n=%b, cnt=%0d, clk_out=%b", $time, enable, rst_n, fd_dut.cnt, clk_out);

        
        rst_n = 0;
        enable = 1;
        #1 rst_n = 1;

        tst_out = 1'b0;

        /* Test 1: Count test */
        $display("[T=%0g] Test 1: Count test", $time);
        for(i = 1; i < 98; i = i + 1) begin
            @(posedge clk_in) begin
                if(i % DIV_CNT == 0)
                    tst_out = 1'b1;
                else tst_out = 1'b0;
            end
            @(negedge clk_in) begin
                check;
            end
        end

        /* Test 2: Reset, Should Be 0 */
        $display("[T=%0g] Test 2: Reset, Should Be 0", $time);
        @(posedge clk_in) begin
            rst_n <= 0;
            tst_out <= 0;
        end
        @(negedge clk_in) check;

        #1 rst_n = 1;

        /* Test 3: Continue count */
        $display("[T=%0g] Test 3: Continue count", $time);
        for(i = 1; i < 98; i = i + 1) begin
            @(posedge clk_in) begin
                if(i % DIV_CNT == 0)
                    tst_out = 1'b1;
                else tst_out = 1'b0;
            end
            @(negedge clk_in) begin
                check;
            end
        end

        /* Test 4: Enable disable */
        $display("[T=%0g] Test 4: Enable disable", $time);
        rst_n = 0;
        enable <= 0;
        @(posedge clk_in) begin
            tst_out <= 0;
            rst_n <= 1;
        end
        repeat(93) @(negedge clk_in) check;

        if(passed)
            $display("[T=%0g] All tests passed", $time);
        else
            $display("[T=%0g] Some tests failed", $time);
        #30; $finish;

    end
endmodule