`timescale 1ns / 1ps

module ram_1kb (
    input         sys_clk,
    input         we, // write enable
    input  [31:0] addr,
    input  [31:0] din,
    output [31:0] dout
);
    reg [31:0] memory_array [0:255];
    integer k;
    initial begin
        
        for (k = 0; k < 256; k = k + 1) begin
            memory_array[k] = 32'd0;
        end
    end

    // Word alignment logic
    wire [7:0] word_idx = addr[9:2];
    assign dout = memory_array[word_idx];

    always @(posedge sys_clk) begin
        if (we) begin
            memory_array[word_idx] <= din;
        end
    end
endmodule