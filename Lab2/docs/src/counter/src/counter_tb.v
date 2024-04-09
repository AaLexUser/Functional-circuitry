`timescale 1ns/10ps
`include "counter/src/counter.v"

module counter_tb;
    localparam WIDTH = 32;
    
    reg clk;
    reg rst_n;
    reg enable;
    wire [WIDTH-1:0] cnt;

    reg [WIDTH-1:0] tst_out;

    reg passed = 1'b1;

    counter #(.WIDTH(WIDTH)) counter_dut(
        .clk (clk),
        .rst_n (rst_n),
        .enable (enable),
        .cnt (cnt)
    );

    /* Clock generation */
    initial begin
        clk = 0;
        forever #10 clk = !clk;
    end

    task check;
        begin
            if(tst_out != cnt) begin
                $display("[T=%0g] Test failed: expected %g, got %g", $time, tst_out, cnt);
                passed = 1'b0;
            end
        end
    endtask

    integer i;
    initial begin
        rst_n = 0;
        enable = 1;
        #1 rst_n = 1;

        tst_out = {WIDTH{1'b0}};

        /* Test 1: Count to 10 */
        for(i = 1; i < 10; i = i + 1) begin
            @(posedge clk) begin
                tst_out = i;
            end
            @(negedge clk) check;
        end


        /* Test 2: Reset, Should Be 0 */
        @(posedge clk) begin
            rst_n <= 0;
            tst_out <= 0;
        end
        @(negedge clk) check;

        rst_n <= 1;

        /* Test 3: Count to 3 */
        for(i = 1; i < 3; i = i + 1) begin
            @(posedge clk) begin
                tst_out = i;
            end
            @(negedge clk) check;
        end

        /* Test 4: Enable = 0, Should Be 3 */
        @(posedge clk) begin
            enable <= 0;
            tst_out <= 3;
        end
        repeat(10) @(negedge clk) check;

        /* Test 5: Continue, Enable = 1, Should Be 17 */
        @(posedge clk) begin
            enable <= 1;
            tst_out <= 3;
        end
        for(i = 4; i < 17; i = i + 1) begin
            @(posedge clk) begin
                tst_out = i;
            end
            @(negedge clk) check;
        end

        if(passed)
            $display("[T=%0g] All tests passed", $time);
        else
            $display("[T=%0g] Some tests failed", $time);
        #10; $finish;
    end

    initial begin
        $dumpfile("build/counter.vcd");
        $dumpvars(1);
    end



endmodule