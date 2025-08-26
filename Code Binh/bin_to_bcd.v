module bin_to_bcd (
    input wire [5:0] sec_bin, min_bin,
    input wire [4:0] hour_bin, day_bin,
    input wire [3:0] month_bin,
    input wire [11:0] year_bin,
    output reg [7:0] bcd_ss, bcd_mm, bcd_hh, bcd_dd, bcd_mo,
    output reg [15:0] bcd_yyyy
);
//double dabble algorithm
reg [19:0] shift8; //3 nibble + 8-bit bin
reg [35:0] shift16; // 5 nibble + 16-bit bin
integer i;

always @(sec_bin or min_bin or hour_bin or day_bin or month_bin or year_bin) begin
    //chuyển đổi giây
    shift8 = 0;
    shift8[7:0] = sec_bin;
    for (i = 0; i < 8; i = i + 1) begin
        if (shift8[11:8] >= 5) shift8[11:8] = shift8[11:8] + 3;
        if (shift8[15:12] >= 5) shift8[15:12] = shift8[15:12] + 3;
        shift8 = shift8 << 1;
    end
    bcd_ss = shift8[15:8];

    //chuyển đổi phút
    shift8 = 0;
    shift8[7:0] = min_bin;
    for (i = 0; i < 8; i = i + 1) begin
        if (shift8[11:8] >= 5) shift8[11:8] = shift8[11:8] + 3;
        if (shift8[15:12] >= 5) shift8[15:12] = shift8[15:12] + 3;
        shift8 = shift8 << 1;
    end
    bcd_mm = shift8[15:8];

    //chuyển đổi giờ
    shift8 = 0;
    shift8[7:0] = hour_bin;
    for (i = 0; i < 8; i = i + 1) begin
        if (shift8[11:8] >= 5) shift8[11:8] = shift8[11:8] + 3;
        if (shift8[15:12] >= 5) shift8[15:12] = shift8[15:12] + 3;
        shift8 = shift8 << 1;
    end
    bcd_hh = shift8[15:8];

    //chuyển đổi ngày
    shift8 = 0;
    shift8[7:0] = day_bin;
    for (i = 0; i < 8; i = i + 1) begin
        if (shift8[11:8] >= 5) shift8[11:8] = shift8[11:8] + 3;
        if (shift8[15:12] >= 5) shift8[15:12] = shift8[15:12] + 3;
        shift8 = shift8 << 1;
    end
    bcd_dd = shift8[15:8];

    //chuyển đổi tháng
    shift8 = 0;
    shift8[7:0] = month_bin;
    for (i = 0; i < 8; i = i + 1) begin
        if (shift8[11:8] >= 5) shift8[11:8] = shift8[11:8] + 3;
        if (shift8[15:12] >= 5) shift8[15:12] = shift8[15:12] + 3;
        shift8 = shift8 << 1;
    end
    bcd_mo = shift8[15:8];

    //chuyển đổi năm
    shift16 = 0;
    shift16[11:0] = year_bin;
    for (i = 0; i < 12; i = i + 1) begin
        if (shift16[15:12] >= 5) shift16[15:12] = shift16[15:12] + 3;
        if (shift16[19:16] >= 5) shift16[19:16] = shift16[19:16] + 3;
        if (shift16[23:20] >= 5) shift16[23:20] = shift16[23:20] + 3;
        if (shift16[27:24] >= 5) shift16[27:24] = shift16[27:24] + 3;
        shift16 = shift16 << 1;
    end
    bcd_yyyy = shift16[27:12];
end
endmodule