module main_control(
    input [6:0] opcode,
    output reg RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch,
    output reg [1:0] ALUOp
);
    always @(*) begin
        // Default safe values to handle don't-care (X) conditions
        {RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp} = 8'b00000000;
        
        case(opcode)
            7'b0110011: begin // R-type
                RegWrite = 1; ALUSrc = 0; MemRead = 0; MemWrite = 0; MemtoReg = 0; Branch = 0; ALUOp = 2'b10;
            end
            7'b0010011: begin // I-type
                RegWrite = 1; ALUSrc = 1; MemRead = 0; MemWrite = 0; MemtoReg = 0; Branch = 0; ALUOp = 2'b11;
            end
            7'b0000011: begin // Load
                RegWrite = 1; ALUSrc = 1; MemRead = 1; MemWrite = 0; MemtoReg = 1; Branch = 0; ALUOp = 2'b00;
            end
            7'b0100011: begin // Store
                RegWrite = 0; ALUSrc = 1; MemRead = 0; MemWrite = 1; MemtoReg = 0; Branch = 0; ALUOp = 2'b00;
            end
            7'b1100011: begin // Branch
                RegWrite = 0; ALUSrc = 0; MemRead = 0; MemWrite = 0; MemtoReg = 0; Branch = 1; ALUOp = 2'b01;
            end
        endcase
    end
endmodule