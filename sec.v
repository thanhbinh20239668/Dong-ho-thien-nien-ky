module sec (
    input wire clk_1Hz, rst_n, en_1, up, down,
    input wire adjust, // 0: đếm, 1: chỉnh
    output reg [5:0] sec_bin,
    output reg carry_out // báo tràn sang phút
);

always @(posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) begin
        sec_bin <= 6'd0;
        carry_out <= 1'b0;
    end
    else if (en_1 && !adjust) begin
        if(sec_bin == 6'd59) begin
            sec_bin <= 6'd0;
            carry_out <= 1'b1;
        end
        else begin
            sec_bin <= sec_bin + 1'b1;
            carry_out <= 0;
        end
    end
    else begin 
        carry_out <= 1'b0;
    end
end

always @(posedge up or posedge down or negedge rst_n) begin
    if (!rst_n) begin
        sec_bin <= 6'd0;
    end
    else if (adjust) begin
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
end
endmodule