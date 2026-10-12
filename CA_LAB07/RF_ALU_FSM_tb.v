`timescale 1ns / 1ps

module RF_ALU_FSM_tb();
    reg clk;
    reg rst;
    
    // Register File Controls
    reg WriteEnable;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] WriteData;
    wire [31:0] ReadData1, ReadData2;
    
    // ALU Controls
    reg [3:0] ALUControl;
    wire [31:0] ALUResult;
    wire Zero;
    
    // FSM States
    localparam IDLE = 3'b000;
    localparam INIT_REGS = 3'b001;
    localparam READ_REGS = 3'b010;
    localparam ALU_OP = 3'b011;
    localparam WRITE_REGS = 3'b100;
    
    reg [2:0] state;
    reg [3:0] test_step; // Tracks which ALU operation we are testing

    // Instantiate Register File
    RegisterFile rf (
        .clk(clk),
        .rst(rst),
        .WriteEnable(WriteEnable),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    // Instantiate ALU
    ALU core_alu (
        .A(ReadData1),
        .B(ReadData2),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1;
        WriteEnable = 0; rs1 = 0; rs2 = 0; rd = 0; WriteData = 0; ALUControl = 0;
        state = IDLE; test_step = 0;
        #15 rst = 0;
    end

    // FSM Logic
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            test_step <= 0;
            WriteEnable <= 0;
        end else begin
            case (state)
                IDLE: begin
                    WriteEnable <= 0;
                    if (test_step == 0) state <= INIT_REGS;
                    else if (test_step <= 7) state <= READ_REGS;
                    else $finish; // All operations done
                end
                
                INIT_REGS: begin
                    // Write fixed constants into x1 and x2
                    WriteEnable <= 1;
                    if (rs1 == 0) begin
                        rd <= 5'd1; WriteData <= 32'h10101010; rs1 <= 1;
                    end else begin
                        rd <= 5'd2; WriteData <= 32'h01010101; 
                        state <= IDLE; test_step <= 1;
                    end
                end
                
                READ_REGS: begin
                    WriteEnable <= 0;
                    rs1 <= 5'd1; // Source A = x1
                    rs2 <= 5'd2; // Source B = x2
                    state <= ALU_OP;
                end
                
                ALU_OP: begin
                    // Assign ALU operation based on step
                    case (test_step)
                        1: ALUControl <= 4'b0010; // ADD
                        2: ALUControl <= 4'b0110; // SUB
                        3: ALUControl <= 4'b0000; // AND
                        4: ALUControl <= 4'b0001; // OR
                        5: ALUControl <= 4'b0111; // XOR
                        6: ALUControl <= 4'b1000; // SLL
                        7: ALUControl <= 4'b1001; // SRL
                    endcase
                    state <= WRITE_REGS;
                end
                
                WRITE_REGS: begin
                    // Write result to rd (x4 through x10)
                    WriteEnable <= 1;
                    rd <= test_step + 5'd3; 
                    WriteData <= ALUResult;
                    
                    // BEQ conditional check: if Zero, write flag to x11
                    if (Zero && test_step == 2) begin
                         // If SUB results in 0
                         rd <= 5'd11; WriteData <= 32'hFFFFFFFF;
                    end
                    
                    test_step <= test_step + 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
