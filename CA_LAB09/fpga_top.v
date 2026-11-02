module fpga_top(
    input clk,
    input [10:0] sw,  // sw[6:0] for opcode, sw[9:7] for funct3, sw[10] for funct7 bit 5
    output [9:0] led  // led outputs for control signals
);
    wire [6:0] opcode = sw[6:0];
    wire [2:0] funct3 = sw[9:7];
    wire [6:0] funct7 = {1'b0, sw[10], 5'b00000};
    
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    // Instantiate Modules
    main_control main_ctrl(
        .opcode(opcode),
        .RegWrite(RegWrite), .ALUSrc(ALUSrc), .MemRead(MemRead), 
        .MemWrite(MemWrite), .MemtoReg(MemtoReg), .Branch(Branch), 
        .ALUOp(ALUOp)
    );

    alu_control alu_ctrl(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );

    // FSM or Direct Mapping for Verification
    // Map outputs to LEDs for visual verification
    assign led[0] = RegWrite;
    assign led[1] = ALUSrc;
    assign led[2] = MemRead;
    assign led[3] = MemWrite;
    assign led[4] = MemtoReg;
    assign led[5] = Branch;
    assign led[9:6] = ALUControl;

endmodule
