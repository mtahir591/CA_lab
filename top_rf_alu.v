`timescale 1ns / 1ps

module top_rf_alu(
    input clk,
    input btn,           
    input [15:0] sw,      
    output [15:0] led 
);

    // Lab 5 Interconnects
    wire btn_debounced;
    wire [31:0] switch_data;
    reg [31:0] led_write_data;
    
    // Register File connections
    reg rf_we;
    reg [4:0] rf_rs1, rf_rs2, rf_rd;
    reg [31:0] rf_wdata;
    wire [31:0] rf_rdata1, rf_rdata2;
    
    // ALU connections
    reg [3:0] alu_ctrl;
    wire [31:0] alu_result;
    wire alu_zero;

    // FSM States
    localparam S_INIT_X1 = 2'b00;
    localparam S_INIT_X2 = 2'b01;
    localparam S_MANUAL  = 2'b10;
    
    reg [1:0] state = S_INIT_X1;

    // 1. Lab 5 Debouncer (Pass-through)
    debouncer btn_db(
        .clk(clk),
        .pbin(btn),
        .pbout(btn_debounced)
    );

    // 2. Lab 5 "leds" module (Used to read physical switches)
    leds switch_reader (
        .clk(clk), 
        .rst(btn_debounced),
        .btns(16'd0),           
        .writeData(32'd0),      
        .writeEnable(1'b0),     
        .readEnable(1'b1),      
        .memAddress(30'd0),       
        .switches(sw),          
        .readData(switch_data)  
    );
    
    // 3. Lab 5 "switches" module (Used to write to physical LEDs)
    switches led_writer (
        .clk(clk), 
        .rst(btn_debounced),
        .writeData(led_write_data),
        .writeEnable(1'b1),     
        .readEnable(1'b0), 
        .memAddress(30'd0),
        .readData(),            
        .leds(led)      
    );

    // 4. Instantiate Register File
    RegisterFile core_rf(
        .clk(clk),
        .rst(btn_debounced), // Center button resets the Register File
        .WriteEnable(rf_we),
        .rs1(rf_rs1),
        .rs2(rf_rs2),
        .rd(rf_rd),
        .WriteData(rf_wdata),
        .ReadData1(rf_rdata1),
        .ReadData2(rf_rdata2)
    );

    // 5. Instantiate ALU
    ALU core_alu(
        .A(rf_rdata1),
        .B(rf_rdata2),
        .ALUControl(alu_ctrl),
        .ALUResult(alu_result),
        .Zero(alu_zero)
    );

    // 6. Startup FSM and Hardware Mapping
    always @(posedge clk) begin
        if (btn_debounced) begin
            state <= S_INIT_X1;
            led_write_data <= 32'd0;
        end else begin
            case(state)
                S_INIT_X1: begin
                    // Write Constant A to x1
                    rf_we <= 1'b1;
                    rf_rs1 <= 5'd0; rf_rs2 <= 5'd0; // Unused during write
                    rf_rd <= 5'd1;
                    rf_wdata <= 32'h10101010;
                    state <= S_INIT_X2;
                end
                
                S_INIT_X2: begin
                    // Write Constant B to x2
                    rf_we <= 1'b1;
                    rf_rd <= 5'd2;
                    rf_wdata <= 32'h01010101;
                    state <= S_MANUAL;
                end
                
                S_MANUAL: begin
                    // Map physical switches to control paths
                    rf_rs1 <= 5'd1; // Hardcode Source A to x1
                    rf_rs2 <= 5'd2; // Hardcode Source B to x2
                    
                    rf_we    <= switch_data[15];       // sw[15] controls WriteEnable
                    rf_rd    <= switch_data[14:10];    // sw[14:10] selects target rd
                    alu_ctrl <= switch_data[3:0];      // sw[3:0] controls ALU operation
                    
                    // Route ALU result back to Register File write data
                    rf_wdata <= alu_result;
                    
                    // Update led_write_data (driven to physical LEDs by led_writer)
                    // Top 2 LEDs = state, LED 13 = zero flag, Lower 13 = result
                    led_write_data[31:16] <= 16'd0;
                    led_write_data[15:14] <= state;               
                    led_write_data[13]    <= alu_zero;            
                    led_write_data[12:0]  <= alu_result[12:0];    
                end
                default: state <= S_INIT_X1;
            endcase
        end
    end
endmodule