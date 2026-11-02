module tb_control;
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    main_control mc(opcode, RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp);
    alu_control ac(ALUOp, funct3, funct7, ALUControl);

    initial begin
        // Test R-type ADD
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        // Test Load LW
        opcode = 7'b0000011; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        // Test Branch BEQ
        opcode = 7'b1100011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $finish;
    end
endmodule
