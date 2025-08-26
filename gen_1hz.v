module Gen_1Hz (
    input  wire clk_50Mhz,
    input  wire rst_n,
    output wire clk_1Hz
);
    parameter MAX_COUNT = 50_000_000 / 2 - 1;  // chia đôi để toggle

    reg [25:0] counter_reg;
    reg clk_1Hz_reg;

    always @(posedge clk_50Mhz or negedge rst_n) begin
        if (!rst_n) begin
            counter_reg <= 26'd0;
            clk_1Hz_reg <= 1'b0;
        end
        else begin
            if (counter_reg == MAX_COUNT) begin
                counter_reg <= 26'd0;
                clk_1Hz_reg <= ~clk_1Hz_reg;  // toggle tạo 50% duty
            end
            else begin
                counter_reg <= counter_reg + 1;
            end
        end
    end

    assign clk_1Hz = clk_1Hz_reg;
endmodule
