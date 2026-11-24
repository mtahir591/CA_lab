module branchAdder (
    input wire [31:0] pc,
    input wire [31:0] imm,
    output wire [31:0] branch_target
);
    // immGen already appends the 0, so just add them directly
    assign branch_target = pc + imm;
endmodule