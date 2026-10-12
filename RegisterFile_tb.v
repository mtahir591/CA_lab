`timescale 1ns / 1ps

module RegisterFile_tb;
    reg clk;
    reg rst;
    reg WriteEnable;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [31:0] WriteData;
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;

    RegisterFile uut (
        .clk(clk),
        .rst(rst),
        .WriteEnable(WriteEnable),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0; rst = 1; WriteEnable = 0;
        rs1 = 0; rs2 = 0; rd = 0; WriteData = 0;
        
        #10 rst = 0;

        // Test i: Write to x5 and verify
        #10 WriteEnable = 1; rd = 5; WriteData = 32'hDEADBEEF;
        #10 WriteEnable = 0; rs1 = 5; 
        // ReadData1 should now be 32'hDEADBEEF

        // Test ii: Attempt to write to x0
        #10 WriteEnable = 1; rd = 0; WriteData = 32'hFFFFFFFF;
        #10 WriteEnable = 0; rs2 = 0;
        // ReadData2 should remain 32'h00000000

        // Test iii: Simultaneous reads
        #10 WriteEnable = 1; rd = 6; WriteData = 32'h12345678;
        #10 WriteEnable = 0; rs1 = 5; rs2 = 6;
        // ReadData1 = DEADBEEF, ReadData2 = 12345678

        // Test iv: Overwrite a register
        #10 WriteEnable = 1; rd = 5; WriteData = 32'hBEEFDEAD;
        #10 WriteEnable = 0; rs1 = 5;
        // ReadData1 should now be 32'hBEEFDEAD

        // Test v: Reset behavior
        #10 rst = 1;
        #10 rst = 0; rs1 = 5; rs2 = 6;
        // Both outputs should return to 0

        #20 $finish;
    end
endmodule