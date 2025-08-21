module month #(
    parameter SELECT_MONTH = 3'b100
)(
    input wire clk_1Hz, rst_n, en_1, up, down,
    input wire [2:0] select_item, // chọn thành phần để chỉnh 100: tháng, ...
    input wire carry_in,
    output reg [3:0] month_bin,
    output reg carry_out //báo tràn sang năm
);

always @(posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) begin
        month_bin <= 4'd1;
        carry_out <= 1'b0;
    end
    else if (en_1 && carry_in && (select_item != SELECT_MONTH)) begin
        if (month_bin == 4'd12) begin
            month_bin <= 4'd1;
            carry_out <= 1'b1;
        end
        else begin
            month_bin <= month_bin + 1'b1;
            carry_out <= 1'b0;
        end
    end
    else begin
        carry_out <= 1'b0;
    end
end

always @(posedge up or posedge down or negedge rst_n) begin
    if (!rst_n) begin
        month_bin <= 4'd1;
    end
    else if (select_item == SELECT_MONTH) begin
        if (up) begin
            if (month_bin == 4'd12)
            month_bin <= 4'd1;
            else
            month_bin <= month_bin + 1'b1;
        end
        else if (down) begin
            if (month_bin == 4'd1)
            month_bin <= 4'd12;
            else 
            month_bin <= month_bin - 1'b1;
        end
    end
end
endmodule