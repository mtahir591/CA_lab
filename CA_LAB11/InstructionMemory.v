module InstructionMemory (
    input wire [31:0] read_addr,
    output reg [31:0] inst
);
    always @(*) begin
        case (read_addr[7:2]) // Decode the word-aligned address
            6'd0: inst = 32'h00A00093; // addi x1, x0, 10
            6'd1: inst = 32'hFE000EE3; // beq x0, x0, -4
            default: inst = 32'b0;
        endcase
    end
endmodule