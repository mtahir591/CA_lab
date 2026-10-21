`timescale 1ns / 1ps

module datamem(
    input clk,
    input rst,
    input memwrite,
    input [31:0] addr,
    input [31:0] writedata,
    output reg [31:0] datamemout
);

    reg [31:0] mem [0:511];

    always @(posedge clk) begin
        if (rst) begin
            datamemout <= 32'b0;
        end else if (memwrite == 1'b1) begin
            mem[addr[8:0]] <= writedata;
        end else begin
            datamemout <= mem[addr[8:0]];
        end
    end

endmodule