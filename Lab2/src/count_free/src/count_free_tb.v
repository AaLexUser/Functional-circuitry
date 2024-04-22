`timescale 1ns/1ps
`include "count_free/src/count_free.v"

module count_free_tb;
    reg clk, en, rst;
    reg start_req_i, start_data_i, ready_i;
    wire result_rsp_o, busy_o;

    count_free cf(
        .clk(clk),
        .en(en),
        .rst(rst),
        .start_req_i(start_req_i),
        .start_data_i(start_data_i),
        .ready_i(ready_i),
        .result_rsp_o(result_rsp_o),
        .busy_o(busy_o)
    );

    reg [31:0] tst_out;
    reg tst_busy;

    reg[31:0] tst_resp = 4'b1011;

    reg passed = 1'b1;

    task check;
        begin
            if(tst_out !== result_rsp_o) begin
                $display("[T=%0d] Test failed: expected_rsp %g, got %g", $time, tst_out, result_rsp_o);
                passed = 1'b0;
            end 
            if(tst_busy !== busy_o) begin
                $display("[T=%0d] Test failed: expected_busy %g, got %g", $time, tst_busy, busy_o);
                passed = 1'b0;
            end 
        end
    endtask

    /* Clock generation */
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    integer i;

    initial begin
        $dumpfile("build/count_free.vcd");
        $dumpvars(1);

        // $monitor("[T=%0d] state->%0d, cnt_ld=%0d, busy_o=%b, cnt_en=%0b, cnt_out=%0b, shlft_out=%0b, result_rsp_o=%0b", 
        // $time, (cf.state), (cf.cnt_ld), busy_o, cf.cnt_en, cf.cnt_out, cf.shlft_out, result_rsp_o);

        rst <= 0;
        en <= 0;
        start_req_i <= 0;
        start_data_i <= 0;
        ready_i <= 0;

        /* Test 1: Reset */
        $display("[T=%0g] Test 1: Reset", $time);
        @(negedge clk) begin
            rst <= 1;
            tst_out <= 0;
            tst_busy <= 0;
        end

        repeat(10) @(negedge clk);
        check;
        #1 rst = 0;
        #1 en = 1;
        tst_out <= 0;
        tst_busy <= 1;
        start_req_i <= 1;

        /* Test 2: Count */
        $display("[T=%0g] Test 2: Count", $time);
        for (i = 0; i < 4; i = i + 1) begin
            start_data_i <= tst_resp >> i;
            repeat(10) @(negedge clk);
            check;
        end
        start_req_i <= 0;
        repeat(14*10) @(negedge clk);
        tst_busy = 1;
        tst_out = 1;
        check;

        @(negedge clk) begin
            ready_i <= 1;
        end

        repeat(10) @(negedge clk);
        tst_busy = 0;
        tst_out = 0;
        check;

        repeat(20) @(negedge clk);
        check;

        if(passed)
            $display("[T=%0g] All tests passed", $time);
        else
            $display("[T=%0g] Some tests failed", $time);

        #20 $finish;

        
        




    end



endmodule