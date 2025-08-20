module hour (
    input wire clk_1Hz, rst_n, en_1, up, down,
    input wire adjust, //0: đếm, 1: chỉnh
    input wire carry_in,
    output reg [4:0] hour_bin,
    output reg carry_out //báo tràn sang ngày
);

always @(posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) begin
        hour_bin <= 5'd0;
        carry_out <= 1'b0;
    end
    else if (en_1 && carry_in && !adjust) begin
        if (hour_bin == 5'd23) begin
            hour_bin <= 5'd0;
            carry_out <= 1'b1;
        end
        else begin
            hour_bin <= hour_bin + 1'b1;
            carry_out <= 1'b0;
        end
    end
    else begin 
        carry_out <= 1'b0;
    end
end

always @(posedge up or posedge down or negedge rst_n) begin
    if (!rst_n) begin
        hour_bin <= 5'd0;
    end
    else if (adjust) begin
        if (up) begin
            if (hour_bin == 5'd23)
            hour_bin <= 5'd0;
            else 
            hour_bin <= hour_bin + 1'b1;
        end
        else if (down) begin
            if (hour_bin == 5'd0)
            hour_bin <= 5'd23;
            else
            hour_bin <= hour_bin - 1'b1;
        end
    end
end
endmodule