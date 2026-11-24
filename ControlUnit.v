module ControlUnit (
    input wire [31:0] inst,
    output reg branch,
    output reg mem_read,
    output reg mem_to_reg,
    output reg mem_write,
    output reg alu_src,
    output reg reg_write,
    output reg [3:0] alu_control
);
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire funct7_5 = inst[30];

    always @(*) begin
        // Default values to prevent latches
        branch = 0; mem_read = 0; mem_to_reg = 0;
        mem_write = 0; alu_src = 0; reg_write = 0;
        alu_control = 4'b0000;

        case (opcode)
            7'b0110011: begin // R-Type (add, sub)
                reg_write = 1;
                if (funct3 == 3'b000 && funct7_5 == 1) alu_control = 4'b0110; // SUB
                else alu_control = 4'b0010; // ADD
            end
            7'b0010011: begin // I-Type (addi)
                alu_src = 1; reg_write = 1; alu_control = 4'b0010; // ADD
            end
            7'b0000011: begin // Load (lw)
                alu_src = 1; mem_to_reg = 1; reg_write = 1; mem_read = 1; alu_control = 4'b0010; // ADD
            end
            7'b0100011: begin // Store (sw)
                alu_src = 1; mem_write = 1; alu_control = 4'b0010; // ADD
            end
            7'b1100011: begin // Branch (beq)
                branch = 1; alu_control = 4'b0110; // SUB (used for comparison)
            end
        endcase
    end
endmodule