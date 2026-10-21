module button_debouncer #(
    parameter THRESHOLD = 1_000_000
)(
    input clk,
    input pbin,
    output reg pbout = 1'b0
);
    reg s0 = 1'b0, s1 = 1'b0;
    reg [31:0] cnt = 32'd0;

    always @(posedge clk) begin
        s0 <= pbin;
        s1 <= s0;
        if (s1 == pbout)
            cnt <= 32'd0;
        else if (cnt == THRESHOLD - 1) begin
            pbout <= s1;
            cnt   <= 32'd0;
        end else
            cnt <= cnt + 32'd1;
    end
endmodule