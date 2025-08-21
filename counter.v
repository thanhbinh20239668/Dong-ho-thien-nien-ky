module counter #(
    parameter SELECT_SEC = 3'b000,
    parameter SELECT_MIN = 3'b001,
    parameter SELECT_HOUR = 3'b010,
    parameter SELECT_DAY = 3'b011,
    parameter SELECT_MONTH = 3'b100,
    parameter SELECT_YEAR = 3'b101
)(
    input wire clk_1Hz, rst_n, en_1, up, down,
    input wire [2:0] select_item,
    output wire [5:0] sec_bin, min_bin,
    output wire [4:0] hour_bin, day_bin,
    output wire [3:0] month_bin,
    output wire [11:0] year_bin,
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

sec #(.SELECT_SEC(SELECT_SEC)) isSec (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up), .down(down),
    .select_item(select_item), .sec_bin(sec_bin), .carry_out(c_sec2min)
);

min #(.SELECT_MIN(SELECT_MIN)) isMin (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up), .down(down),
    .select_item(select_item), .carry_in(c_sec2min), .min_bin(min_bin), .carry_out(c_min2hour)
);

hour #(.SELECT_HOUR(SELECT_HOUR)) isHour (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up), .down(down),
    .select_item(select_item), .carry_in(c_min2hour), .hour_bin(hour_bin), .carry_out(c_hour2day)
);

day #(.SELECT_DAY(SELECT_DAY)) isDay (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up), .down(down),
    .select_item(select_item), .carry_in(c_hour2day), .day_bin(day_bin), .carry_out(c_day2month),
    .month_bin(month_bin), .leap_year(leap_year)
);

month #(.SELECT_MONTH(SELECT_MONTH)) isMonth (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up), .down(down),
    .select_item(select_item), .carry_in(c_day2month), .month_bin(month_bin), .carry_out(c_month2year)
);

year #(
    .SELECT_YEAR(SELECT_YEAR),
    .YEAR_MIN(12'd2001),
    .YEAR_MAX(12'd3000)
) isYear (
    .clk_1Hz(clk_1Hz), .rst_n(rst_n), .en_1(en_1), .up(up), .down(down),
    .select_item(select_item), .carry_in(c_month2year), .year_bin(year_bin)
);
endmodule