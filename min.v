module min #(
    parameter SELECT_MIN = 3'b001
)(
    input wire clk_1Hz, rst_n, en_1, up, down,
    input wire [2:0] select_item, // chọn thành phần để chỉnh 001: phút, ...
    input wire carry_in,
    output reg [5:0] min_bin,
    output reg carry_out //báo tràn sang giờ
);

always @(posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) begin
        min_bin <= 6'd0;
        carry_out <= 1'b0;
    end
    else begin
        carry_out <= 1'b0; // reset mặc định
        if (select_item == SELECT_MIN) begin //chỉnh
            if (up) begin
                if (min_bin == 6'd59)
                    min_bin <= 6'd0;
                else 
                    min_bin <= min_bin + 1'b1;
            end
            else if (down) begin
                if (min_bin == 6'd0)
                    min_bin <= 6'd59;
                else 
                    min_bin <= min_bin - 1'b1;
            end
        end
        else if (en_1 && carry_in) begin //đếm
            if (min_bin == 6'd59) begin
                min_bin <= 6'd0;
                carry_out <= 1'b1;
            end
            else begin
                min_bin <= min_bin + 1'b1;
                carry_out <= 1'b0;
            end
        end
    end
end
endmodule