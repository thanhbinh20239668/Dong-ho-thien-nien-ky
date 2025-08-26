module Display (
    input wire clk,
    input wire rst_n,
    input wire smh_dmy,       
    input wire dem_chinh,      
    input wire [1:0] blink_led,
    input wire [7:0] bcd_ss,
    input wire [7:0] bcd_mm,
    input wire [7:0] bcd_hh,
    input wire [7:0] bcd_dd,
    input wire [7:0] bcd_mo,
    input wire [15:0] bcd_yyyy,
    output wire [6:0] LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7
);

    reg [24:0] blink_counter; 
    wire blink_enable;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            blink_counter <= 0;
        end else begin
            blink_counter <= blink_counter + 1;
        end
    end
    assign blink_enable = blink_counter[24];
    
    function [6:0] decode_7seg;
        input [3:0] bcd;
        case(bcd)
            4'h0: decode_7seg = 7'b1000000;
            4'h1: decode_7seg = 7'b1111001;
            4'h2: decode_7seg = 7'b0100100;
            4'h3: decode_7seg = 7'b0110000;
            4'h4: decode_7seg = 7'b0011001;
            4'h5: decode_7seg = 7'b0010010;
            4'h6: decode_7seg = 7'b0000010;
            4'h7: decode_7seg = 7'b1111000;
            4'h8: decode_7seg = 7'b0000000;
            4'h9: decode_7seg = 7'b0010000;
            default: decode_7seg = 7'b1111111;
        endcase
    endfunction

    reg [6:0] seg_data_0, seg_data_1, seg_data_2, seg_data_3;
    reg [6:0] seg_data_4, seg_data_5, seg_data_6, seg_data_7;

    always @(smh_dmy, dem_chinh, blink_led, blink_enable, 
              bcd_ss, bcd_mm, bcd_hh, bcd_dd, bcd_mo, bcd_yyyy) 
    begin
        reg [3:0] bcd_in_0, bcd_in_1, bcd_in_2, bcd_in_3;
        reg [3:0] bcd_in_4, bcd_in_5, bcd_in_6, bcd_in_7;
        
        if (smh_dmy == 0) begin
            bcd_in_0 = 4'hF;
            bcd_in_1 = 4'hF;
            bcd_in_2 = bcd_ss[3:0];
            bcd_in_3 = bcd_ss[7:4];
            bcd_in_4 = bcd_mm[3:0];
            bcd_in_5 = bcd_mm[7:4];
            bcd_in_6 = bcd_hh[3:0];
            bcd_in_7 = bcd_hh[7:4];
        end else begin
            bcd_in_0 = bcd_yyyy[3:0];
            bcd_in_1 = bcd_yyyy[7:4];
            bcd_in_2 = bcd_yyyy[11:8];
            bcd_in_3 = bcd_yyyy[15:12];
            bcd_in_4 = bcd_mo[3:0];
            bcd_in_5 = bcd_mo[7:4];
            bcd_in_6 = bcd_dd[3:0];
            bcd_in_7 = bcd_dd[7:4];
        end

        seg_data_0 = decode_7seg(bcd_in_0);
        seg_data_1 = decode_7seg(bcd_in_1);
        seg_data_2 = decode_7seg(bcd_in_2);
        seg_data_3 = decode_7seg(bcd_in_3);
        seg_data_4 = decode_7seg(bcd_in_4);
        seg_data_5 = decode_7seg(bcd_in_5);
        seg_data_6 = decode_7seg(bcd_in_6);
        seg_data_7 = decode_7seg(bcd_in_7);

        if (dem_chinh && blink_enable) begin
            if (smh_dmy == 0) begin
                case (blink_led)
                    2'b00: begin seg_data_2 = 7'h7F; seg_data_3 = 7'h7F; end
                    2'b01: begin seg_data_4 = 7'h7F; seg_data_5 = 7'h7F; end
                    2'b10: begin seg_data_6 = 7'h7F; seg_data_7 = 7'h7F; end
                    default: begin end
                endcase
            end else begin
                case (blink_led)
                    2'b00: begin seg_data_0=7'h7F; seg_data_1=7'h7F; seg_data_2=7'h7F; seg_data_3=7'h7F; end
                    2'b01: begin seg_data_4 = 7'h7F; seg_data_5 = 7'h7F; end
                    2'b10: begin seg_data_6 = 7'h7F; seg_data_7 = 7'h7F; end
                    default: begin end
                endcase
            end
        end
    end

    assign LED0 = seg_data_0;
    assign LED1 = seg_data_1;
    assign LED2 = seg_data_2;
    assign LED3 = seg_data_3;
    assign LED4 = seg_data_4;
    assign LED5 = seg_data_5;
    assign LED6 = seg_data_6;
    assign LED7 = seg_data_7;
                            
endmodule