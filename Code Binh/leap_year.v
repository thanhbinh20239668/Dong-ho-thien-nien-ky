module leap_year (
    input wire [11:0] year_bin,
    output reg leap_year
);

integer chia100;
integer chia400;
integer i;

always @(year_bin) begin
    leap_year = 0; //tránh latch
    chia100 = year_bin;
    chia400 = year_bin;

    if (year_bin[1:0] == 2'b00) begin
        for (i = 0; i < 30; i = i + 1) begin
            if (chia100 >= 100)
                chia100 = chia100 - 100;
            else
                chia100 = chia100;
        end

        for (i = 0; i < 7; i = i + 1) begin
            if (chia400 >= 400)
                chia400 = chia400 - 400;
            else
                chia400 = chia400;
        end

        if ((chia100 != 0) || (chia400 == 0))
            leap_year = 1;
        else 
            leap_year = 0;
    end
    else 
    leap_year = 0;
end
endmodule