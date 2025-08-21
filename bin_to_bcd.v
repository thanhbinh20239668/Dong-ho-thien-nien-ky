module bin_to_bcd (
    input wire [5:0] sec_bin, min_bin,
    input wire [4:0] hour_bin, day_bin,
    input wire [3:0] month_bin,
    input wire [11:0] year_bin,
    output reg [7:0] bcd_ss, bcd_mm, bcd_hh, bcd_dd, bcd_mo,
    output reg [15:0] bcd_yyyy
);
//double dabble algorithm
function [7:0] bin8_to_bcd;
input [7:0] bin;
integer i;
reg [19:0] shift; //3 nibble + 8-bit bin
begin
    shift = 20'd0;
    shift[7:0] = bin;
    for (i = 0; i < 8; i = i + 1) begin
        if (shift[11:8] >= 5) shift[11:8] = shift[11:8] + 3;
        if (shift[15:12] >= 5) shift[15:12] = shift[15:12] + 3;
        shift = shift << 1;
    end
    bin8_to_bcd = shift[15:8];
end
endfunction

function [15:0] bin16_to_bcd;
input [15:0] bin;
integer i;
reg [35:0] shift; //5 nibble + 16-bit bin
begin
    shift = 36'd0;
    shift[15:0] = bin;
    for (i = 0; i < 16; i = i + 1) begin
        if (shift[19:16] >= 5) shift[19:16] = shift[19:16] + 3;
        if (shift[23:20] >= 5) shift[23:20] = shift[23:20] + 3;
        if (shift[27:24] >= 5) shift[27:24] = shift[27:24] + 3;
        if (shift[31:28] >= 5) shift[31:28] = shift[31:28] + 3;
        shift = shift << 1;
    end
    bin16_to_bcd = shift[31:16];
end
endfunction 

always @(sec_bin or min_bin or hour_bin or day_bin or month_bin or year_bin) begin
    bcd_ss = bin8_to_bcd(sec_bin);
    bcd_mm = bin8_to_bcd(min_bin);
    bcd_hh = bin8_to_bcd(hour_bin);
    bcd_dd = bin8_to_bcd(day_bin);
    bcd_mo = bin8_to_bcd(month_bin);
    bcd_yyyy = bin16_to_bcd(year_bin);
end
endmodule