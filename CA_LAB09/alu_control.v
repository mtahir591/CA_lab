module alu_control(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] ALUControl
);
    always @(*) begin
        ALUControl = 4'b0000; // Default
        case(ALUOp)
            2'b00: ALUControl = 4'b0010; // Load/Store -> ADD
            2'b01: ALUControl = 4'b0110; // Branch -> SUB
            2'b10, 2'b11: begin // R-type or I-type
                case(funct3)
                    3'b000: ALUControl = (ALUOp == 2'b10 && funct7[5]) ? 4'b0110 : 4'b0010; // SUB vs ADD
                    3'b001: ALUControl = 4'b0011; // SLL
                    3'b101: ALUControl = 4'b0101; // SRL
                    3'b111: ALUControl = 4'b0000; // AND
                    3'b110: ALUControl = 4'b0001; // OR
                    3'b100: ALUControl = 4'b0100; // XOR
                    default: ALUControl = 4'b0000;
                endcase
            end
        endcase
    end
endmodule
