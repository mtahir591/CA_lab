module immGen (
    input wire [31:0] inst,
    output reg [31:0] imm_out
);
    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            7'b0010011, 7'b0000011: // I-Type (ALU immediate, Load)
                imm_out = {{20{inst[31]}}, inst[31:20]};
            7'b0100011: // S-Type (Store)
                imm_out = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            7'b1100011: // B-Type (Branch)
                imm_out = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            default: 
                imm_out = 32'b0;
        endcase
    end
endmodule