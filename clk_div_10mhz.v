`timescale 1ns / 1ps

module clk_div_10mhz #(
    parameter RATIO = 10,
    parameter USE_BUFFER = 1
)(
    input  clk_100m,
    output clk_10m
);
    reg [7:0] counter = 8'd0;
    reg clk_track = 1'b0;

    always @(posedge clk_100m) begin
        if (counter >= (RATIO/2 - 1)) begin
            counter <= 8'd0;
            clk_track <= ~clk_track;
        end else begin
            counter <= counter + 8'd1;
        end
    end

    generate
        if (USE_BUFFER) begin : gen_buf
            BUFG clk_buf (.I(clk_track), .O(clk_10m));
        end else begin : gen_no_buf
            assign clk_10m = clk_track;
        end
    endgenerate
endmodule