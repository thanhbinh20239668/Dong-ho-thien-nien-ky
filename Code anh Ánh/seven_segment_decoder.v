
module seven_segment_decoder(
    input [3:0] bcd_in,
    output reg [6:0] seven_seg_out // g --> a
);
    always @(*) begin
        case(bcd_in)
            4'h0: seven_seg_out = 7'b1000000; // 0
            4'h1: seven_seg_out = 7'b1111001; // 1
            4'h2: seven_seg_out = 7'b0100100; // 2
            4'h3: seven_seg_out = 7'b0110000; // 3
            4'h4: seven_seg_out = 7'b0011001; // 4
            4'h5: seven_seg_out = 7'b0010010; // 5
            4'h6: seven_seg_out = 7'b0000010; // 6
            4'h7: seven_seg_out = 7'b1111000; // 7
            4'h8: seven_seg_out = 7'b0000000; // 8
            4'h9: seven_seg_out = 7'b0010000; // 9
            4'hA: seven_seg_out = 7'b0111111; // Dấu gạch ngang '-'
            default: seven_seg_out = 7'b1111111; // Off
        endcase
    end
endmodule