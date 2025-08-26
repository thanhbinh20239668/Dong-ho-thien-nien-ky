`timescale 1ns/1ps
module tb_sec;
    reg clk_1Hz, rst_n, en_1, up, down;
    reg [2:0] select_item;
    wire [5:0] sec_bin;
    wire carry_out;

    sec dut (
        .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1),
        .up(up), .down(down), .select_item(select_item),
        .sec_bin(sec_bin), .carry_out(carry_out)
    );

    // clock 10ns
    initial begin
        clk_1Hz = 0;
        forever #5 clk_1Hz = ~clk_1Hz;
    end

    // tiện tạo pulse 1 chu kỳ
    task pulse_up;   begin up=1;   @(posedge clk_1Hz); up=0;   end endtask
    task pulse_down; begin down=1; @(posedge clk_1Hz); down=0; end endtask

    initial begin
        rst_n = 0; en_1 = 0; up = 0; down = 0; select_item = 3'b111; // không chỉnh
        repeat(2) @(posedge clk_1Hz);
        rst_n = 1;

        // Đếm bình thường ~65 giây
        en_1 = 1;
        select_item = 3'b111;   // != 000 để cho phép đếm
        repeat(65) @(posedge clk_1Hz);

        // Vào chế độ chỉnh giây, thử UP/DOWN mỗi lần 1 đơn vị
        en_1 = 0;
        select_item = 3'b000;   // chỉnh giây
        pulse_up();    // +1
        pulse_up();    // +1
        pulse_down();  // -1

        // Thử wrap 59->0
        // Đẩy sec_bin lên 59 nhanh cho demo:
        repeat(60) pulse_up();

        // quay lại đếm tự động và kiểm tra carry_out
        en_1 = 1;
        select_item = 3'b111;
        repeat(3) @(posedge clk_1Hz);

        $stop;
    end
endmodule
