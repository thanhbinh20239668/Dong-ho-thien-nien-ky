// clock_divider.v — bản sạch cho Quartus (không concatenation với hằng unsized)

module clock_divider (
    input  wire clk,
    input  wire rst_n,
    output reg  tick_1hz,
    output reg  tick_1000hz,
    output reg  blink_enable   // ~2Hz (toggle mỗi 0.25s → 4Hz, bạn đổi MAX nếu muốn 2Hz thực)
);
    // Ràng buộc độ rộng hằng số theo độ rộng counter
    localparam [25:0] COUNTER_1HZ_MAX   = 26'd50_000_000 - 26'd1;   // 50 MHz
    localparam [15:0] COUNTER_1KHZ_MAX  = 16'd50_000     - 16'd1;   // 1 kHz
    localparam [23:0] COUNTER_BLINK_MAX = 24'd12_500_000 - 24'd1;   // 0.25 s

    reg [25:0] counter_1hz;
    reg [15:0] counter_1khz;
    reg [23:0] counter_blink;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter_1hz   <= 26'd0; tick_1hz    <= 1'b0;
            counter_1khz  <= 16'd0; tick_1000hz <= 1'b0;
            counter_blink <= 24'd0; blink_enable<= 1'b0;
        end else begin
            // 1 Hz tick (xung 1 chu kỳ)
            if (counter_1hz == COUNTER_1HZ_MAX) begin
                counter_1hz <= 26'd0;
                tick_1hz    <= 1'b1;
            end else begin
                counter_1hz <= counter_1hz + 26'd1;
                tick_1hz    <= 1'b0;
            end

            // 1 kHz tick (xung 1 chu kỳ)
            if (counter_1khz == COUNTER_1KHZ_MAX) begin
                counter_1khz  <= 16'd0;
                tick_1000hz   <= 1'b1;
            end else begin
                counter_1khz  <= counter_1khz + 16'd1;
                tick_1000hz   <= 1'b0;
            end

            // Blink toggle
            if (counter_blink == COUNTER_BLINK_MAX) begin
                counter_blink <= 24'd0;
                blink_enable  <= ~blink_enable;
            end else begin
                counter_blink <= counter_blink + 24'd1;
                // blink_enable giữ nguyên ở các chu kỳ còn lại
            end
        end
    end
endmodule
