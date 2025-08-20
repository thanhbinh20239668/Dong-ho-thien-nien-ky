module year #(
    parameter YEAR_MIN = 12'd2001,
    parameter YEAR_MAX = 12'd3000
)(
    input wire clk_1Hz, rst_n, en_1, up, down,
    input wire adjust, //0: đếm, 1: chỉnh
    input wire carry_in,
    output reg [11:0] year_bin
);

always @(posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) begin
        year_bin <= YEAR_MIN;
    end
    else if (en_1 && carry_in && !adjust) begin
        if (year_bin == YEAR_MAX)
        year_bin <= YEAR_MIN;
        else 
        year_bin <= year_bin + 1'b1;
    end
end

always @(posedge up or posedge down or negedge rst_n) begin
    if (!rst_n) begin
        year_bin <= YEAR_MIN;
    end
    else if (adjust) begin
        if (up) begin
            if (year_bin == YEAR_MAX)
            year_bin <= YEAR_MIN;
            else
            year_bin <= year_bin + 1'b1;
        end
        else if (down) begin
            if (year_bin == YEAR_MIN)
            year_bin <= YEAR_MAX;
            else
            year_bin <= year_bin - 1'b1;
        end
    end
end
endmodule