module Millennium_CLK (
    input        clk,                                                                        
    input        rst,                                                                               // Button[3]
    input        dis_sel,           // Chon che do hien thi: 0: gio-phut-giay, 1: ngay-thang-nam    // SW[0]
    input        mode_sel,          // Chon che do hoat dong: 0: dem gio, 1: dieu chinh thoi gian   // SW[17]
    input        adjust,            // Chon doi tuong dieu chinh                                    // Button[2]
    input        up_btn,            // Dieu chinh thoi gian len                                     // Button[0]
    input        down_btn,          // Dieu chinh thoi gian xuong                                   // Button[1]
    output wire [6:0] LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7
);

// Tao day dan dau ra cho control
wire en_1, smh_dmy, dem_chinh, up, down;
wire [1:0] blink_group;
wire [2:0] select_item;

    control ct1 (.clk(clk), .rst(rst), .dis_sel(dis_sel), .mode_sel(mode_sel),
                . adjust(adjust), .up_btn(up_btn), .down_btn(down_btn), .en_1(en_1), .blink_group(blink_group),
                .smh_dmy(smh_dmy), .dem_chinh(dem_chinh), .select_item(select_item), .up(up), .down(down));

// Tao day dan dau ra 1Hz cho gen1Hz
wire clk_1Hz;

    Gen_1Hz gen (.clk_50Mhz(clk), .rst_n(rst), .clk_1Hz(clk_1Hz));

// Tao day dan dau ra cho khoi counter
wire [7:0] bcd_ss, bcd_mm, bcd_hh, bcd_dd, bcd_mo;
wire [15:0] bcd_yyyy;

    counter ct2 (.clk_1Hz(clk_1Hz), .rst_n(rst), .en_1(en_1), .up(up), .down(down),
                 .select_item(select_item), .bcd_ss(bcd_ss), .bcd_mm(bcd_mm), .bcd_hh(bcd_hh),
                 .bcd_dd(bcd_dd), .bcd_mo(bcd_mo), .bcd_yyyy(bcd_yyyy));

// Tao instance cho Display

    Display dis (.clk(clk), .rst_n(rst), .smh_dmy(smh_dmy), .dem_chinh(dem_chinh),
                 .blink_led(blink_group), .bcd_ss(bcd_ss), .bcd_mm(bcd_mm), .bcd_hh(bcd_hh),
                 .bcd_dd(bcd_dd), .bcd_mo(bcd_mo), .bcd_yyyy(bcd_yyyy),
                 .LED0(LED0), .LED1(LED1), .LED2(LED2), .LED3(LED3), .LED4(LED4), .LED5(LED5), .LED6(LED6), .LED7(LED7));

endmodule

