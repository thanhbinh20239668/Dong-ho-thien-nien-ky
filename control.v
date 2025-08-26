module control (
    input        clk,
    input        rst,
    input        dis_sel,     // Chon che do hien thi: 0: gio-phut-giay, 1: ngay-thang-nam
    input        mode_sel,    // Chon che do hoat dong: 0: dem gio, 1: dieu chinh thoi gian
    input        adjust,      // Chon doi tuong dieu chinh
    input        up_btn,      // Dieu chinh thoi gian len
    input        down_btn,    // Dieu chinh thoi gian xuong
    output reg   en_1,        // Tin hieu cho phep counter chay
    output reg [1:0] blink_group, // Chon nhom led nhap nhay khi dang duoc dieu chinh
    output reg   smh_dmy,     // Dau vao cua khoi Display, giup xac dinh hien thi cai gi
    output reg   dem_chinh,   // Dau vao khoi Counter, giup biet dang ow che do dem hay chinh
    output reg [2:0] select_item, // Chon doi tuong dieu chinh (000: giay, 001: phut,...,101: nam)
    output reg   up,          // Tin hieu dieu chinh thoi gian tang, gui vao khoi counter
    output reg   down         // Tin hieu dieu chinh thoi gian giam, gui vao khoi counter
);

    // --- Debounce và phát hiện cạnh xuống cho adjust ---
    reg [19:0] adj_debounce_cnt;
    reg adj_stable, adj_ff0, adj_ff1;
    wire adjust_negedge;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            adj_debounce_cnt <= 0;
            adj_stable <= 1; // Active-low: mặc định thả = 1
            adj_ff0 <= 1;
            adj_ff1 <= 1;
        end else begin
            if (adjust == adj_stable) begin
                adj_debounce_cnt <= 0; // Reset counter nếu input thay đổi
            end else begin
                if (adj_debounce_cnt < 20'd500_000) // 10ms @ 50MHz
                    adj_debounce_cnt <= adj_debounce_cnt + 1;
                else
                    adj_stable <= adjust; // Cập nhật trạng thái ổn định
            end
            adj_ff0 <= adj_stable;
            adj_ff1 <= adj_ff0;
        end
    end
    assign adjust_negedge = ~adj_stable & adj_ff1; // Phát hiện cạnh xuống (1->0)

    // --- Debounce và phát hiện cạnh xuống cho up_btn ---
    reg [19:0] up_debounce_cnt;
    reg up_stable, up_ff0, up_ff1;
    wire up_negedge;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            up_debounce_cnt <= 0;
            up_stable <= 1;
            up_ff0 <= 1;
            up_ff1 <= 1;
        end else begin
            if (up_btn == up_stable) begin
                up_debounce_cnt <= 0;
            end else begin
                if (up_debounce_cnt < 20'd500_000)
                    up_debounce_cnt <= up_debounce_cnt + 1;
                else
                    up_stable <= up_btn;
            end
            up_ff0 <= up_stable;
            up_ff1 <= up_ff0;
        end
    end
    assign up_negedge = ~up_stable & up_ff1;

    // --- Debounce và phát hiện cạnh xuống cho down_btn ---
    reg [19:0] down_debounce_cnt;
    reg down_stable, down_ff0, down_ff1;
    wire down_negedge;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            down_debounce_cnt <= 0;
            down_stable <= 1;
            down_ff0 <= 1;
            down_ff1 <= 1;
        end else begin
            if (down_btn == down_stable) begin
                down_debounce_cnt <= 0;
            end else begin
                if (down_debounce_cnt < 20'd500_000)
                    down_debounce_cnt <= down_debounce_cnt + 1;
                else
                    down_stable <= down_btn;
            end
            down_ff0 <= down_stable;
            down_ff1 <= down_ff0;
        end
    end
    assign down_negedge = ~down_stable & down_ff1;

    // --- Chọn đối tượng chỉnh ---
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            select_item <= 3'b000;
        end else if (mode_sel) begin
            if (adjust_negedge) begin // Dùng cạnh xuống
                if (select_item == 3'b101) // Năm là mục cuối
                    select_item <= 3'b000;
                else
                    select_item <= select_item + 1'b1;
            end
        end else begin
            select_item <= 3'b000; // Reset khi về chế độ đếm
        end
    end

    // --- Mã hóa blink_group ---
    always @(mode_sel, smh_dmy, select_item) begin
        if (mode_sel) begin
            if (smh_dmy == 0) begin  // Nhóm giờ-phút-giây
                case (select_item)
                    3'b000: blink_group = 2'b00;  // Giây (seg2-3)
                    3'b001: blink_group = 2'b01;  // Phút (seg4-5)
                    3'b010: blink_group = 2'b10;  // Giờ (seg6-7)
                    default: blink_group = 2'b00;
                endcase
            end else begin  // Nhóm ngày-tháng-năm
                case (select_item)
                    3'b011: blink_group = 2'b10;  // Ngày (seg6-7)
                    3'b100: blink_group = 2'b01;  // Tháng (seg4-5)
                    3'b101: blink_group = 2'b00;  // Năm (seg0-3)
                    default: blink_group = 2'b00;
                endcase
            end
        end else begin
            blink_group = 2'b00;  // Không blink khi đếm
        end
    end

    // --- Điều khiển smh_dmy ---
    always @(dis_sel) begin
        smh_dmy = dis_sel;
    end

    // --- Điều khiển dem_chinh và en_1 ---
    always @(mode_sel) begin
        if (mode_sel) begin
            dem_chinh = 1;  // Chỉnh
            en_1 = 0;       // Không chạy counter
        end else begin
            dem_chinh = 0;  // Đếm
            en_1 = 1;       // Bật counter
        end
    end

    // --- Xuất tín hiệu up/down sạch cho counter ---
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            up <= 0;
            down <= 0;
        end else if (mode_sel) begin
            up <= up_negedge;     // Dùng cạnh xuống
            down <= down_negedge; // Dùng cạnh xuống
        end else begin
            up <= 0;
            down <= 0;
        end
    end

endmodule