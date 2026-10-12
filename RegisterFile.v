`timescale 1ns / 1ps

module RegisterFile (
    input wire clk,
    input wire rst,
    input wire WriteEnable,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,
    input wire [31:0] WriteData,
    output wire [31:0] ReadData1,
    output wire [31:0] ReadData2
);
    // 32 registers, each 32 bits wide
    reg [31:0] registers [31:0];
    integer i;

    // Asynchronous reads: x0 is hardwired to 0, otherwise read from the array
    assign ReadData1 = (rs1 == 5'b0) ? 32'b0 : registers[rs1];
    assign ReadData2 = (rs2 == 5'b0) ? 32'b0 : registers[rs2];

    // Synchronous write
    always @(posedge clk) begin
        if (rst) begin
            // Optional: Clear all registers on reset
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (WriteEnable && rd != 5'b0) begin
            // Write data to rd, ignoring writes to x0
            registers[rd] <= WriteData;
        end
    end
endmodule