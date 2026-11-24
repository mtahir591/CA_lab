`timescale 1ns / 1ps

module io_sync_regs (
    input             sys_clk,
    input      [15:0] raw_sw,
    input             raw_btn,
    input             we_led,
    input      [15:0] din_led,
    output reg [15:0] clean_sw,
    output reg        clean_btn,
    output reg [15:0] out_led
);
    // Double-flop synchronizer stages
    reg [15:0] sync_stage1_sw  = 16'd0;
    reg        sync_stage1_btn = 1'b0;

    initial begin
        clean_sw  = 16'd0;
        clean_btn = 1'b0;
        out_led   = 16'd0;
    end

    always @(posedge sys_clk) begin
        // Stage 1
        sync_stage1_sw  <= raw_sw;
        sync_stage1_btn <= raw_btn;
        
        // Stage 2 (Clean)
        clean_sw  <= sync_stage1_sw;
        clean_btn <= sync_stage1_btn;
        
        // LED Write
        if (we_led) begin
            out_led <= din_led;
        end
    end
endmodule