module sec #(
    parameter SELECT_SEC = 3'b000
)(
    input wire clk_1Hz, rst_n, en_1, up, down,
    input wire [2:0] select_item, // chọn thành phần để chỉnh 000: giây, ...
    output reg [5:0] sec_bin,
    output reg carry_out // báo tràn sang phút
);

always @(posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) begin
        sec_bin <= 6'd0;
        carry_out <= 1'b0;
    end
    else begin
        carry_out <= 1'b0; //reset mặc định
        if (select_item == SELECT_SEC) begin //chỉnh
            if (up) begin
                if (sec_bin == 6'd59)
                    sec_bin <= 6'd0;
                else
                    sec_bin <= sec_bin + 1'b1;
            end
            else if (down) begin
                if (sec_bin == 6'd0)
                    sec_bin <= 6'd59;
                else
                    sec_bin <= sec_bin - 1'b1;
            end
        end
        else if (en_1) begin //đếm
            if (sec_bin == 6'd59) begin
                sec_bin <= 6'd0;
                carry_out <= 1'b1;
            end
            else begin
                sec_bin <= sec_bin + 1'b1;
                carry_out <= 1'b0;
            end
        end
    end
end
endmodule