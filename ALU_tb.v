`timescale 1ns / 1ps

module ALU_tb();
    reg [31:0] A, B;
    reg [3:0] ALUControl;
    wire [31:0] ALUResult;
    wire Zero;

    ALU uut (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    initial begin
        A = 32'h0000000A; B = 32'h00000005; 
        
        ALUControl = 4'b0010; #10; // ADD
        ALUControl = 4'b0110; #10; // SUB
        
        A = 32'h00000005; ALUControl = 4'b0110; #10; // SUB (Trigger Zero)
        
        A = 32'h000000FF; B = 32'h00000F0F; 
        ALUControl = 4'b0000; #10; // AND
        ALUControl = 4'b0001; #10; // OR
        ALUControl = 4'b0111; #10; // XOR
        
        A = 32'h00000001; B = 32'h00000002; ALUControl = 4'b1000; #10; // SLL
        
        A = 32'h00000008; ALUControl = 4'b1001; #10; // SRL
        
        $finish;
    end
endmodule