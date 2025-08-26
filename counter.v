module counter (
    input wire clk_1Hz, rst_n, up, down,
    input wire [2:0] select_item,
    output wire [7:0] bcd_ss, bcd_mm, bcd_hh, bcd_dd, bcd_mo,
    output wire [15:0] bcd_yyyy
);

wire [5:0] sec_bin, min_bin;
wire [4:0] hour_bin, day_bin;
wire [3:0] month_bin;
wire [11:0] year_bin;
wire c_sec2min;
wire c_min2hour;
wire c_hour2day;
wire c_day2month;
wire c_month2year;

wire en_1 = 1;

leap_year isLeap (
    .year_bin(year_bin),
    .leap_year(leap_year)
);

sec isSec (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up), .down(down),
    .select_item(select_item), .sec_bin(sec_bin), .carry_out(c_sec2min)
);

min isMin (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up), .down(down),
    .select_item(select_item), .carry_in(c_sec2min), .min_bin(min_bin), .carry_out(c_min2hour)
);

hour isHour (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up), .down(down),
    .select_item(select_item), .carry_in(c_min2hour), .hour_bin(hour_bin), .carry_out(c_hour2day)
);

day isDay (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up), .down(down),
    .select_item(select_item), .carry_in(c_hour2day), .day_bin(day_bin), .carry_out(c_day2month),
    .month_bin(month_bin), .leap_year(leap_year)
);

month isMonth (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up), .down(down),
    .select_item(select_item), .carry_in(c_day2month), .month_bin(month_bin), .carry_out(c_month2year)
);

year isYear (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up), .down(down),
    .select_item(select_item), .carry_in(c_month2year), .year_bin(year_bin)
);

bin_to_bcd isBinToBCD (
    .sec_bin(sec_bin), .min_bin(min_bin), .hour_bin(hour_bin), .day_bin(day_bin),
    .month_bin(month_bin), .year_bin(year_bin), .bcd_ss(bcd_ss), .bcd_mm(bcd_mm),
    .bcd_hh(bcd_hh), .bcd_dd(bcd_dd), .bcd_mo(bcd_mo), .bcd_yyyy(bcd_yyyy)
);
endmodule