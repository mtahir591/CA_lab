`timescale 1ns / 1ps

module rv32i_cpu (
    input         clk,
    input         rst,
    output [31:0] inst_addr,
    input  [31:0] inst_data,
    output        mem_we,
    output        mem_re,
    output [31:0] data_addr,
    output [31:0] data_din,
    input  [31:0] data_dout
);
    // Program Counter
    reg  [31:0] prog_cnt = 32'd0;
    wire [31:0] prog_cnt_next4 = prog_cnt + 32'd4;
    reg  [31:0] prog_cnt_branch;
    assign inst_addr = prog_cnt;

    // Decode Aliases
    wire [6:0] opc = inst_data[6:0];
    wire [4:0] rd  = inst_data[11:7];
    wire [2:0] f3  = inst_data[14:12];
    wire [4:0] rs1 = inst_data[19:15];
    wire [4:0] rs2 = inst_data[24:20];
    wire [6:0] f7  = inst_data[31:25];

    // Immediate Extensions
    wire [31:0] ext_i = {{20{inst_data[31]}}, inst_data[31:20]};
    wire [31:0] ext_s = {{20{inst_data[31]}}, inst_data[31:25], inst_data[11:7]};
    wire [31:0] ext_b = {{19{inst_data[31]}}, inst_data[31], inst_data[7], inst_data[30:25], inst_data[11:8], 1'b0};
    wire [31:0] ext_u = {inst_data[31:12], 12'b0};
    wire [31:0] ext_j = {{11{inst_data[31]}}, inst_data[31], inst_data[19:12], inst_data[20], inst_data[30:21], 1'b0};

    // Instruction Types
    wire t_alu     = (opc == 7'b0110011);
    wire t_alu_imm = (opc == 7'b0010011);
    wire t_load    = (opc == 7'b0000011);
    wire t_store   = (opc == 7'b0100011);
    wire t_branch  = (opc == 7'b1100011);
    wire t_jal     = (opc == 7'b1101111);
    wire t_jalr    = (opc == 7'b1100111);
    wire t_lui     = (opc == 7'b0110111);
    wire t_auipc   = (opc == 7'b0010111);

    wire rf_we = t_alu | t_alu_imm | t_load | t_jal | t_jalr | t_lui | t_auipc;
    assign mem_we = t_store;
    assign mem_re = t_load;

    // Register File
    reg [31:0] reg_file [0:31];
    integer i;
    initial begin
        
        for (i = 0; i < 32; i = i + 1) reg_file[i] = 32'd0;
    end

    wire [31:0] val_rs1 = (rs1 == 5'd0) ? 32'd0 : reg_file[rs1];
    wire [31:0] val_rs2 = (rs2 == 5'd0) ? 32'd0 : reg_file[rs2];

    // ALU Logic
    wire use_imm = t_alu_imm | t_load | t_store | t_jalr | t_lui | t_auipc;
    wire [31:0] alu_imm = t_store ? ext_s : ((t_lui | t_auipc) ? ext_u : ext_i);
    wire [31:0] operand_a = t_auipc ? prog_cnt : (t_lui ? 32'd0 : val_rs1);
    wire [31:0] operand_b = use_imm ? alu_imm : val_rs2;
    wire [4:0]  shift_amt = operand_b[4:0];

    reg [31:0] alu_result;
    always @(*) begin
        alu_result = operand_a + operand_b; // Base operation
        if (t_alu | t_alu_imm) begin
            case (f3)
                3'b000: alu_result = (t_alu & f7[5]) ? (operand_a - operand_b) : (operand_a + operand_b);
                3'b001: alu_result = operand_a << shift_amt;
                3'b010: alu_result = ($signed(operand_a) < $signed(operand_b)) ? 32'd1 : 32'd0;
                3'b011: alu_result = (operand_a < operand_b) ? 32'd1 : 32'd0;
                3'b100: alu_result = operand_a ^ operand_b;
                3'b101: alu_result = f7[5] ? ($signed(operand_a) >>> shift_amt) : (operand_a >> shift_amt);
                3'b110: alu_result = operand_a | operand_b;
                3'b111: alu_result = operand_a & operand_b;
            endcase
        end
    end

    assign data_addr = alu_result;
    assign data_din  = val_rs2;

    // Branch Control
    reg branch_hit;
    always @(*) begin
        case (f3)
            3'b000:  branch_hit = (val_rs1 == val_rs2);
            3'b001:  branch_hit = (val_rs1 != val_rs2);
            3'b100:  branch_hit = ($signed(val_rs1) <  $signed(val_rs2));
            3'b101:  branch_hit = ($signed(val_rs1) >= $signed(val_rs2));
            3'b110:  branch_hit = (val_rs1 <  val_rs2);
            3'b111:  branch_hit = (val_rs1 >= val_rs2);
            default: branch_hit = 1'b0;
        endcase
    end

    // Next PC Logic
    always @(*) begin
        if (t_jal)                          prog_cnt_branch = prog_cnt + ext_j;
        else if (t_jalr)                    prog_cnt_branch = (val_rs1 + ext_i) & 32'hFFFF_FFFE;
        else if (t_branch && branch_hit)    prog_cnt_branch = prog_cnt + ext_b;
        else                                prog_cnt_branch = prog_cnt_next4;
    end

    always @(posedge clk) begin
        if (rst) prog_cnt <= 32'd0;
        else     prog_cnt <= prog_cnt_branch;
    end

    // Writeback Logic
    wire [31:0] wb_mux = (t_jal | t_jalr) ? prog_cnt_next4 :
                         (t_load)         ? data_dout : alu_result;

    always @(posedge clk) begin
        if (rf_we && (rd != 5'd0) && !rst) begin
            reg_file[rd] <= wb_mux;
        end
    end
endmodule