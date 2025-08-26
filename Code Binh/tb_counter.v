`timescale 1ns/1ps

module tb_counter;

    // Inputs
    reg clk_1Hz;
    reg rst_n;
    reg up;
    reg down;
    reg [2:0] select_item;

    // Outputs
    wire [7:0] bcd_ss, bcd_mm, bcd_hh, bcd_dd, bcd_mo;
    wire [15:0] bcd_yyyy;

    // Instantiate DUT
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

    // Clock generation (siêu nhanh)
    initial clk_1Hz = 0;
    always #0.001 clk_1Hz = ~clk_1Hz; // Chu kỳ = 0.002 ns
    initial begin
        // Reset
        rst_n = 0;
        up = 1; down = 0; select_item = 3'b111;
        #1 rst_n = 1;

        $display("Simulation bắt đầu: kiểm tra leap year và đến năm 2012.");
    end

    // Hiển thị khi vào tháng 2/2008
    always @(posedge clk_1Hz) begin
        if (uut.bcd_yyyy == 2008 && uut.bcd_mo == 2) begin
            $display(">>> Đang ở tháng 2 năm 2008. Ngày: %0d/%0d/%0d", uut.bcd_dd, uut.bcd_mo, uut.bcd_yyyy);
        end

        if (uut.bcd_yyyy >= 2012) begin
            $display(">>> Đến năm 2012. Ngày: %0d/%0d/%0d", uut.bcd_dd, uut.bcd_mo, uut.bcd_yyyy);
            $stop; // Dừng mô phỏng tại đây
        end
    end

    // Dump waveform cho ModelSim hoặc GTKWave
    initial begin
        $dumpfile("counter_tb.vcd");
        $dumpvars(0, tb_counter);
    end

endmodule
