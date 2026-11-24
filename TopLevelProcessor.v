(* dont_touch = "true" *)
module TopLevelProcessor (
    input wire clk,
    input wire reset,
    output wire [15:0] current_pc
);
    (* dont_touch = "true" *) wire [31:0] pc, next_pc, seq_pc, branch_target, inst;
    (* dont_touch = "true" *) wire [31:0] read_data1, read_data2, alu_result, mem_read_data, write_data;
    (* dont_touch = "true" *) wire [31:0] imm_out, alu_in2;
    (* dont_touch = "true" *) wire [3:0] alu_control;
    (* dont_touch = "true" *) wire branch_flag, alu_src, reg_write, mem_write, mem_read, mem_to_reg, zero;
    wire pc_src;

    // Route PC to the LEDs
    assign current_pc = pc[15:0];
    
    // THE MISSING AND GATE: Only branch if it's a branch instruction AND the comparison is true
    assign pc_src = branch_flag & zero; 

    ProgramCounter pc_reg (.clk(clk), .reset(reset), .next_pc(next_pc), .pc(pc));
    pcAdder add4 (.pc(pc), .next_seq_pc(seq_pc));
    branchAdder addBr (.pc(pc), .imm(imm_out), .branch_target(branch_target));
    mux2 pc_mux (.d0(seq_pc), .d1(branch_target), .sel(pc_src), .y(next_pc));
    immGen ig (.inst(inst), .imm_out(imm_out));

    InstructionMemory imem (.read_addr(pc), .inst(inst));
    
    ControlUnit ctrl (
        .inst(inst), .branch(branch_flag), .mem_read(mem_read), 
        .mem_to_reg(mem_to_reg), .mem_write(mem_write), 
        .alu_src(alu_src), .reg_write(reg_write), .alu_control(alu_control)
    );

    RegisterFile regfile (
        .clk(clk), .reg_write(reg_write), 
        .read_reg1(inst[19:15]), .read_reg2(inst[24:20]), .write_reg(inst[11:7]),
        .write_data(write_data), .read_data1(read_data1), .read_data2(read_data2)
    );

    mux2 alu_mux (.d0(read_data2), .d1(imm_out), .sel(alu_src), .y(alu_in2));
    
    ALU alu (
        .in1(read_data1), .in2(alu_in2), .alu_control(alu_control),
        .result(alu_result), .zero(zero)
    );

    DataMemory dmem (
        .clk(clk), .mem_write(mem_write), .mem_read(mem_read),
        .address(alu_result), .write_data(read_data2), .read_data(mem_read_data)
    );
    
    mux2 wb_mux (.d0(alu_result), .d1(mem_read_data), .sel(mem_to_reg), .y(write_data));
endmodule