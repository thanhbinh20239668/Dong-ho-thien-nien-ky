
module century_clock (
    input  wire       CLOCK_50,
    input  wire [1:0] SW,
    input  wire [3:0] KEY,
    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7
);
    // -------------------------------------------------
    // 1) Tín hiệu điều khiển
    // -------------------------------------------------
    wire rst_n = KEY[0];
    wire display_selector = SW[1];            // 0: Time (__ HH MM SS), 1: Date (DD MM CC YY)
    wire tick_1hz, tick_1000hz, blink_enable;
    wire clk_tick = SW[0] ? tick_1000hz : tick_1hz;

    wire pulse_mode, pulse_incr, pulse_decr;
    edge_detector u_ed_mode(.clk(CLOCK_50), .btn_in(~KEY[1]), .pulse_out(pulse_mode));
    edge_detector u_ed_incr(.clk(CLOCK_50), .btn_in(~KEY[2]), .pulse_out(pulse_incr));
    edge_detector u_ed_decr(.clk(CLOCK_50), .btn_in(~KEY[3]), .pulse_out(pulse_decr));

    clock_divider u_clk_divider(
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .tick_1hz(tick_1hz),
        .tick_1000hz(tick_1000hz),
        .blink_enable(blink_enable)
    );

    // -------------------------------------------------
    // 2) FSM chế độ
    // -------------------------------------------------
    localparam RUN_MODE   = 3'd0,
                SET_SEC    = 3'd1,
                SET_MIN    = 3'd2,
                SET_HOUR   = 3'd3,
                SET_DAY    = 3'd4,
                SET_MON    = 3'd5,
                SET_YEAR_YY= 3'd6,
                SET_YEAR_CC= 3'd7;

    reg [2:0] current_mode;
    always @(posedge CLOCK_50 or negedge rst_n) begin
        if (!rst_n) current_mode <= RUN_MODE;
        else if (pulse_mode) current_mode <= (current_mode == SET_YEAR_CC) ? RUN_MODE : current_mode + 1'b1;
    end

    // -------------------------------------------------
    // 3) Năm nhuận đầy đủ (không dùng * và %)
    // -------------------------------------------------
    wire [7:0] year_yy_bcd, year_cc_bcd;

    // BCD -> nhị phân: x10 = (<<3)+(<<1)
    wire [6:0] year_yy_bin = (year_yy_bcd[7:4] << 3) + (year_yy_bcd[7:4] << 1) + year_yy_bcd[3:0];
    wire [6:0] year_cc_bin = (year_cc_bcd[7:4] << 3) + (year_cc_bcd[7:4] << 1) + year_cc_bcd[3:0];

    // CC*100 = CC*(64+32+4) = (<<6)+(<<5)+(<<2)
    wire [15:0] year_full = (year_cc_bin << 6) + (year_cc_bin << 5) + (year_cc_bin << 2) + year_yy_bin;

    // chia hết cho 4: 2 bit thấp = 0
    wire year_div_by_4   = (year_full[1:0] == 2'b00);
    // chia hết cho 100: YY == 00
    wire year_div_by_100 = (year_yy_bcd == 8'h00);
    // chia hết cho 400: YY == 00 và CC ∈ {20,24,28}
    wire year_div_by_400 = (year_yy_bcd == 8'h00) &&
                           (year_cc_bcd == 8'h20 || year_cc_bcd == 8'h24 || year_cc_bcd == 8'h28);

    wire is_leap_year = year_div_by_400 || (year_div_by_4 && !year_div_by_100);

    // -------------------------------------------------
    // 4) Bộ đếm BCD và điều khiển
    // -------------------------------------------------
    wire [7:0] sec_bcd, min_bcd, hr_bcd, day_bcd, mon_bcd;
    wire sec_carry, min_carry, hr_carry, day_carry, mon_carry, yy_carry;

    wire sec_set_en    = (current_mode == SET_SEC);
    wire min_set_en    = (current_mode == SET_MIN);
    wire hr_set_en     = (current_mode == SET_HOUR);
    wire day_set_en    = (current_mode == SET_DAY);
    wire mon_set_en    = (current_mode == SET_MON);
    wire yr_yy_set_en  = (current_mode == SET_YEAR_YY);
    wire yr_cc_set_en  = (current_mode == SET_YEAR_CC);

    wire sec_count_en   = (current_mode == RUN_MODE) && clk_tick;
    wire min_count_en   = (current_mode == RUN_MODE) && sec_carry;
    wire hr_count_en    = (current_mode == RUN_MODE) && min_carry;
    wire day_count_en   = (current_mode == RUN_MODE) && hr_carry;
    wire mon_count_en   = (current_mode == RUN_MODE) && day_carry;
    wire yr_yy_count_en = (current_mode == RUN_MODE) && mon_carry;
    wire yr_cc_count_en = (current_mode == RUN_MODE) && yy_carry;

    // Tháng: 30/31/28-29
    reg [7:0] days_in_month_bcd;
    always @(*) begin
        case (mon_bcd)
            8'h04, 8'h06, 8'h09, 8'h11: days_in_month_bcd = 8'h30; // 30
            8'h02: days_in_month_bcd = is_leap_year ? 8'h29 : 8'h28;
            default: days_in_month_bcd = 8'h31;                    // 31
        endcase
    end

    // Mốc đổi 3000 -> 2001: khi mon_carry và năm đang là 3000 (CC=30, YY=00)
    wire end_of_era_load_en = mon_carry && (year_cc_bcd == 8'h30) && (year_yy_bcd == 8'h00);

    // sec
    bcd_counter sec_cnt(
        .clk(CLOCK_50), .rst_n(rst_n),
        .load_en(1'b0), .load_val(8'h00),
        .count_enable(sec_count_en), .set_enable(sec_set_en),
        .incr(pulse_incr), .decr(pulse_decr),
        .max_val(8'h59), .rst_val(8'h00), .wrap_min(8'h00),
        .count_out(sec_bcd), .carry_out(sec_carry)
    );
    // min
    bcd_counter min_cnt(
        .clk(CLOCK_50), .rst_n(rst_n),
        .load_en(1'b0), .load_val(8'h00),
        .count_enable(min_count_en), .set_enable(min_set_en),
        .incr(pulse_incr), .decr(pulse_decr),
        .max_val(8'h59), .rst_val(8'h00), .wrap_min(8'h00),
        .count_out(min_bcd), .carry_out(min_carry)
    );
    // hour
    bcd_counter hr_cnt(
        .clk(CLOCK_50), .rst_n(rst_n),
        .load_en(1'b0), .load_val(8'h00),
        .count_enable(hr_count_en), .set_enable(hr_set_en),
        .incr(pulse_incr), .decr(pulse_decr),
        .max_val(8'h23), .rst_val(8'h00), .wrap_min(8'h00),
        .count_out(hr_bcd), .carry_out(hr_carry)
    );
    // day (1..29/30/31)
    bcd_counter day_cnt(
        .clk(CLOCK_50), .rst_n(rst_n),
        .load_en(1'b0), .load_val(8'h00),
        .count_enable(day_count_en), .set_enable(day_set_en),
        .incr(pulse_incr), .decr(pulse_decr),
        .max_val(days_in_month_bcd), .rst_val(8'h01), .wrap_min(8'h01),
        .count_out(day_bcd), .carry_out(day_carry)
    );
    // month (1..12)
    bcd_counter mon_cnt(
        .clk(CLOCK_50), .rst_n(rst_n),
        .load_en(1'b0), .load_val(8'h00),
        .count_enable(mon_count_en), .set_enable(mon_set_en),
        .incr(pulse_incr), .decr(pulse_decr),
        .max_val(8'h12), .rst_val(8'h01), .wrap_min(8'h01),
        .count_out(mon_bcd), .carry_out(mon_carry)
    );
    // year YY (00..99): reset mặc định 01 để boot 2001, nhưng SET được 00 nhờ wrap_min=00
    bcd_counter yr_yy_cnt (
    .clk(CLOCK_50), .rst_n(rst_n),
    .load_en(end_of_era_load_en), .load_val(8'h01),
    .count_enable(yr_yy_count_en), .set_enable(yr_yy_set_en),
    .incr(pulse_incr), .decr(pulse_decr),
    .max_val(8'h99), .rst_val(8'h01), .wrap_min(8'h00),   // << quan trọng
    .count_out(year_yy_bcd), .carry_out(yy_carry)
);

bcd_counter yr_cc_cnt (
    .clk(CLOCK_50), .rst_n(rst_n),
    .load_en(end_of_era_load_en), .load_val(8'h20),
    .count_enable(yr_cc_count_en), .set_enable(yr_cc_set_en),
    .incr(pulse_incr), .decr(pulse_decr),
    .max_val(8'h30), .rst_val(8'h20), .wrap_min(8'h20),   // 20..30
    .count_out(year_cc_bcd), .carry_out()
);


    // -------------------------------------------------
    // 5) Hiển thị 8 x 7-seg + blink theo field
    // -------------------------------------------------
    reg [3:0] bcd_to_hex [0:7];
    always @(*) begin
        if (display_selector) begin
            {bcd_to_hex[7], bcd_to_hex[6]} = day_bcd;
            {bcd_to_hex[5], bcd_to_hex[4]} = mon_bcd;
            {bcd_to_hex[3], bcd_to_hex[2]} = year_cc_bcd;
            {bcd_to_hex[1], bcd_to_hex[0]} = year_yy_bcd;
        end else begin
            // Hour Display
            bcd_to_hex[3] = 4'hF; bcd_to_hex[2] = 4'hF;
            {bcd_to_hex[7], bcd_to_hex[6]} = hr_bcd;
            {bcd_to_hex[5], bcd_to_hex[4]} = min_bcd;
            {bcd_to_hex[1], bcd_to_hex[0]} = sec_bcd;
        end

        if (blink_enable) begin
            case (current_mode)
                SET_SEC:     if (!display_selector) {bcd_to_hex[1], bcd_to_hex[0]} = {4'hF,4'hF};
                SET_MIN:     if (!display_selector) {bcd_to_hex[5], bcd_to_hex[4]} = {4'hF,4'hF};
                SET_HOUR:    if (!display_selector) {bcd_to_hex[7], bcd_to_hex[6]} = {4'hF,4'hF};
                SET_DAY:     if ( display_selector) {bcd_to_hex[7], bcd_to_hex[6]} = {4'hF,4'hF};
                SET_MON:     if ( display_selector) {bcd_to_hex[5], bcd_to_hex[4]} = {4'hF,4'hF};
                SET_YEAR_CC: if ( display_selector) {bcd_to_hex[3], bcd_to_hex[2]} = {4'hF,4'hF};
                SET_YEAR_YY: if ( display_selector) {bcd_to_hex[1], bcd_to_hex[0]} = {4'hF,4'hF};
                default: ;
            endcase
        end
    end

    seven_segment_decoder dec0(.bcd_in(bcd_to_hex[0]), .seven_seg_out(HEX0));
    seven_segment_decoder dec1(.bcd_in(bcd_to_hex[1]), .seven_seg_out(HEX1));
    seven_segment_decoder dec2(.bcd_in(bcd_to_hex[2]), .seven_seg_out(HEX2));
    seven_segment_decoder dec3(.bcd_in(bcd_to_hex[3]), .seven_seg_out(HEX3));
    seven_segment_decoder dec4(.bcd_in(bcd_to_hex[4]), .seven_seg_out(HEX4));
    seven_segment_decoder dec5(.bcd_in(bcd_to_hex[5]), .seven_seg_out(HEX5));
    seven_segment_decoder dec6(.bcd_in(bcd_to_hex[6]), .seven_seg_out(HEX6));
    seven_segment_decoder dec7(.bcd_in(bcd_to_hex[7]), .seven_seg_out(HEX7));
endmodule
