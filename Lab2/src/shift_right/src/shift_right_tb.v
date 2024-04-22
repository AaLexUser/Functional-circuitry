`timescale 1ns/100ps
`include "shift_right/src/shift_right.v"

module shift_right_tb;
    localparam WIDTH=32;

    reg clk;
    reg rst_n;
    reg [WIDTH-1:0] data_in;
    reg shift_en;
    reg load;
    wire serial_out;

    reg passed = 1;

    reg tst_out;
    reg [WIDTH-1:0] tst_temp;
    reg [WIDTH-1:0] tst_value = 32'hFF123456;

    shift_right #(.WIDTH(WIDTH)) shift_right_dut (
        .clk(clk),
        .load(load),
        .rst_n(rst_n),
        .data_in(data_in),
        .shift_enable(shift_en),
        .serial_out(serial_out)
    );

    /* Clock generation */
    initial begin
      clk = 0;
      forever #10 clk = ~clk;
    end

    task check;
        begin
            if(tst_out !== serial_out) begin
                $display("[T=%0g] Test failed: expected %g, got %g", $time, tst_out, serial_out);
                passed = 0;
            end 
        end
    endtask

    integer i;

    initial begin
        $dumpfile("build/shift_right.vcd");
        $dumpvars(1);
        $display("#################### Starting simulation ####################");
        
        shift_en = 0;
        rst_n = 1;
        load = 0;

        tst_temp = tst_value;

        @(negedge clk) begin
            data_in <= tst_value;
            load <= 1;
        end
        @(negedge clk) begin
            load <= 0;
        end
        shift_en <= 1;

        /* Test: Load value */
        $display("########## TEST: Load value ##########");
        for (i = 0; i < 32; i = i + 1) begin
            @(posedge clk)
                {tst_temp[WIDTH-1:0], tst_out} <= {1'b0, tst_temp[WIDTH-1:0]};
            @(negedge clk) check;
        end

        /* Test: Reset, Should Be 0 */
        $display("########## TEST: Reset ##########");
        rst_n = 0;
        tst_out = 0;
        @(posedge clk) check;
        rst_n = 1;

        /* Test: Buffer is empty */
        $display("########## TEST: Buffer is empty ##########");
        @(posedge clk) check;

        /* Test: Shift right continue */
        $display("########## TEST: Shift right continue ##########");
        @(negedge clk) begin
            tst_temp <= tst_value;
            data_in <= tst_value;
            load <= 1;
        end
        @(negedge clk) begin
            load <= 0;
        end
        shift_en <= 1;

        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk)
                {tst_temp[WIDTH-1:0], tst_out} <= {1'b0, tst_temp[WIDTH-1:0]};
            @(negedge clk) check;
        end
        if(passed)
            $display("[T=%0g] All tests passed", $time);
        else
            $display("[T=%0g] Some tests failed", $time);
        #10; $finish;
    end


endmodule