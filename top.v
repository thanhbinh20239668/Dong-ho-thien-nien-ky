module top (
    input wire clk_1Hz, rst_n, en_1,
    input wire adjust_sec, up_sec, down_sec,
    input wire adjust_min, up_min, down_min,
    input wire adjust_hour, up_hour, down_hour,
    input wire adjust_day, up_day, down_day,
    input wire adjust_month, up_month, down_month,
    input wire adjust_year, up_year, down_year,
    output wire [5:0] sec_bin, min_bin,
    output wire [4:0] hour_bin, day_bin,
    output wire [3:0] month_bin,
    output wire leap_year
);

wire c_sec2min;
wire c_min2hour;
wire c_hour2day;
wire c_day2month;
wire c_month2year;

leap_year isLeap (
    .year_bin(year_bin),
    .leap_year(leap_year)
);

sec isSec (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up_sec), .down(down_sec),
    .adjust(adjust_sec), .sec_bin(sec_bin), .carry_out(c_sec2min)
);

min isMin (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up_min), .down(down_min),
    .adjust(adjust_min), .carry_in(c_sec2min), .min_bin(min_bin), .carry_out(c_min2hour)
);

hour isHour (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up_hour), .down(down_hour),
    .adjust(adjust_hour), .carry_in(c_min2hour), .hour_bin(hour_bin), .carry_out(c_hour2day)
);

day isDay (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up_day), .down(down_day),
    .adjust(adjust_day), .carry_in(c_hour2day), .day_bin(day_bin), .carry_out(c_day2month),
    .month_bin(month_bin), .leap_year(leap_year)
);

month isMonth (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up_month), .down(down_month),
    .adjust(adjust_month), .carry_in(c_day2month), .month_bin(month_bin), .carry_out(c_month2year)
);

year #(
    .YEAR_MIN(12'd2001),
    .YEAR_MAX(12'd3000)
) isYear (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up_year), .down(down_year),
    .adjust(adjust_year), .carry_in(c_month2year), .year_bin(year_bin)
);
endmodule