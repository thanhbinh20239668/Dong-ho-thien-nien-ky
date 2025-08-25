module edge_detector 
(
    input  wire clk,
    input  wire btn_in,
    output wire pulse_out
);
    reg prev_state;
    always @(posedge clk) begin
        prev_state <= btn_in;
    end
    assign pulse_out = btn_in & ~prev_state;
endmodule