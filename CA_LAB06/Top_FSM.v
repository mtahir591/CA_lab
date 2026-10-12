`timescale 1ns / 1ps

module Top_FSM(
    input clk,
    input btn,           
    input [15:0] sw,      
    output [15:0] led 
);

    wire [31:0] alu_out;
    wire zero_flag;
    wire btn_debounced;
    wire [15:0] clean_sw;
    
    reg [3:0] current_alu_ctrl;
    reg [1:0] state;
    reg [15:0] led_reg;
    
    // Fixed operands
    wire [31:0] op_A = 32'h10101010;
    wire [31:0] op_B = 32'h01010101;

    // 1. Re-using Debouncer
    debouncer btn_db(
        .clk(clk),
        .pbin(btn),
        .pbout(btn_debounced)
    );

    // 2. Re-using Switches interface
    switches sw_interface(
        .board_switches(sw),
        .control_out(clean_sw)
    );

    // 3. Re-using LEDs interface
    leds led_interface(
        .result_in(led_reg),
        .board_leds(led)
    );

    // Instantiate ALU
    ALU core_alu(
        .A(op_A),
        .B(op_B),
        .ALUControl(current_alu_ctrl),
        .ALUResult(alu_out),
        .Zero(zero_flag)
    );

    initial begin
        state = 2'b00;
        current_alu_ctrl = 4'b0000;
        led_reg = 16'b0;
    end

    // FSM to read switches and update LEDs on button press
    always @(posedge clk) begin
        case(state)
            2'b00: begin // WAIT_FOR_PRESS
                if (btn_debounced) state <= 2'b01;
            end
            2'b01: begin // READ_SWITCHES
                current_alu_ctrl <= clean_sw[3:0]; // Map lower 4 switches to ALUControl
                state <= 2'b10;
            end
            2'b10: begin // UPDATE_LEDS
                led_reg[14:0] <= alu_out[14:0];    // Map result to lower 15 LEDs
                led_reg[15] <= zero_flag;          // Map Zero flag to 16th LED
                if (!btn_debounced) state <= 2'b00; // Wait for release
            end
            default: state <= 2'b00;
        endcase
    end

endmodule

// --- Lab 5 Interface Modules Below ---

module debouncer(
    input clk,
    input pbin,
    output reg pbout
);
    reg [19:0] count; 
    reg sync_0, sync_1;
    
    always @(posedge clk) begin
        sync_0 <= pbin;
        sync_1 <= sync_0;
    end
    
    always @(posedge clk) begin
        if (pbout == sync_1) begin
            count <= 0;
        end else begin
            count <= count + 1;
            if (count == 20'hFFFFF) begin 
                pbout <= sync_1;
                count <= 0;
            end
        end
    end
endmodule

module switches(
    input [15:0] board_switches,
    output [15:0] control_out
);
    assign control_out = board_switches;
endmodule

module leds(
    input [15:0] result_in,
    output [15:0] board_leds
);
    assign board_leds = result_in;
endmodule
