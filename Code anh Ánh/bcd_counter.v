module bcd_counter (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       load_en,
    input  wire [7:0] load_val,
    input  wire       count_enable,
    input  wire       set_enable,
    input  wire       incr,
    input  wire       decr,
    input  wire [7:0] max_val,
    input  wire [7:0] rst_val,
    input  wire [7:0] wrap_min,   // << NEW: mốc dưới khi SET mode
    output reg  [7:0] count_out,
    output wire       carry_out
);
    reg [7:0] next_count;
    assign carry_out = (count_enable && (count_out == max_val));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) count_out <= rst_val;
        else        count_out <= next_count;
    end

    always @(*) begin
        next_count = count_out;

        if (load_en) begin
            next_count = load_val;

        end else if (set_enable) begin
            if (incr) begin
                if (count_out == max_val)           next_count = wrap_min;             // dùng wrap_min
                else if (count_out[3:0] == 4'h9)    next_count = {count_out[7:4]+1,4'h0};
                else                                 next_count = count_out + 1;
            end else if (decr) begin
                if (count_out == wrap_min)          next_count = max_val;              // dùng wrap_min
                else if (count_out[3:0] == 4'h0)    next_count = {count_out[7:4]-1,4'h9};
                else                                 next_count = count_out - 1;
            end

        end else if (count_enable) begin
            if (count_out == max_val)               next_count = rst_val;              // RUN mode dùng rst_val
            else if (count_out[3:0] == 4'h9)        next_count = {count_out[7:4]+1,4'h0};
            else                                     next_count = count_out + 1;
        end
    end
endmodule
