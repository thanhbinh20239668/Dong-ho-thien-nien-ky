module leap_year (
    input wire [11:0] year_bin,
    output reg leap_year
);

always @(year_bin) begin
    if ((year_bin % 400 == 0) || ((year_bin % 4 == 0) && (year_bin % 100 != 0)))
    leap_year = 1'b1;
    else
    leap_year = 1'b0;
end
endmodule