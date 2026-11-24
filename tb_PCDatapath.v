module tb_PCDatapath();
    reg clk, reset, PCSrc;
    reg [31:0] inst;
    wire [31:0] current_pc, next_seq_pc, branch_target, next_pc, imm_out;

    ProgramCounter pc_inst (.clk(clk), .reset(reset), .next_pc(next_pc), .pc(current_pc));
    pcAdder pc_add_inst (.pc(current_pc), .next_seq_pc(next_seq_pc));
    immGen ig_inst (.inst(inst), .imm_out(imm_out));
    branchAdder br_add_inst (.pc(current_pc), .imm(imm_out), .branch_target(branch_target));
    mux2 pc_mux (.d0(next_seq_pc), .d1(branch_target), .sel(PCSrc), .y(next_pc));

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; PCSrc = 0; inst = 32'b0;
        #10 reset = 0;
        #10 PCSrc = 0; inst = 32'h00A00093; // addi x1, x0, 10
        #20 PCSrc = 1; inst = 32'hFE000EE3; // beq x0, x0, -4 
        #20 $finish;
    end
endmodule