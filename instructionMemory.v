`timescale 1ns / 1ps

module instructionMemory #(
    parameter OPERAND_LENGTH = 31,
    parameter SIM_FAST = 0
)(
    input  [OPERAND_LENGTH:0] instAddress,
    output [31:0]             instruction
);
    // 8-bit wide memory array with 256 locations
    reg [7:0] memory [0:255];
    integer i;
    initial begin
        // Initialize memory with zeros
        
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 8'h00;
        end
        // Load the assembled machine code for FPGA synthesis
        $readmemh("program.mem", memory); 
    end

    // RISC-V is little-endian. Address bits 1:0 are ignored for word alignment.
    wire [7:0] a = {instAddress[7:2], 2'b00};
    assign instruction = {memory[a + 3], memory[a + 2], memory[a + 1], memory[a]};

endmodule