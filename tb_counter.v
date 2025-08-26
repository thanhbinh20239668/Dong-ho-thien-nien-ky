`timescale 1ns/1ps

module tb_counter_60s;

    // Inputs
    reg clk_1Hz;
    reg rst_n;
    reg up;
    reg down;
    reg [2:0] select_item;

    // Outputs
    wire [7:0] bcd_ss, bcd_mm, bcd_hh, bcd_dd, bcd_mo;
    wire [15:0] bcd_yyyy;

    // Instantiate the Unit Under Test (UUT)
    counter uut (
        .clk_1Hz(clk_1Hz),
        .rst_n(rst_n),
        .up(up),
        .down(down),
        .select_item(select_item),
        .bcd_ss(bcd_ss),
        .bcd_mm(bcd_mm),
        .bcd_hh(bcd_hh),
        .bcd_dd(bcd_dd),
        .bcd_mo(bcd_mo),
        .bcd_yyyy(bcd_yyyy)
    );

    // Clock generation (fast clock for simulation)
    initial clk_1Hz = 0;
    always #1 clk_1Hz = ~clk_1Hz; // 2ns period = "1Hz" nhanh cho simulation

    // Test sequence
    initial begin
        // Initialize inputs
        rst_n = 0;
        up = 0;
        down = 0;
        select_item = 3'd7;

        // Apply reset
        #5 rst_n = 1;

        // Run simulation for 60 "seconds" (60 cycles of clk_1Hz)
        // 1 cycle = 2ns, muốn 60 giây = 60 * 2ns * 2 (toggling clk) = 240ns
        #240;

        // Finish simulation
        $stop;
    end

    // Monitor outputs
    initial begin
        $display("Time(ns) | SS | MM | HH");
        $monitor("%0t | %0d | %0d | %0d", $time, bcd_ss, bcd_mm, bcd_hh);
    end

endmodule
