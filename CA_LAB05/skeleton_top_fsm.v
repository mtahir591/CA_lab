`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muddassir Ali

// Module Name: top_fsm_system
// Project Name: Counter
// Target Devices: Baasys 3
// 
//////////////////////////////////////////////////////////////////////////////////

module top_fsm_system (
    input wire clk,
    input wire pbin,
    input wire [15:0] physical_sw,
    output wire [15:0] physical_leds
);

    // DEBOUNCER (Cleans up the physical reset button signal)
    wire rst_clean;
  	wire [31:0] switch_data; // hold the value read from the switches
  	reg [31:0] led_write_data = 32'd0; // counter value here
  	wire slow_clk;
  
    debouncer rst_db (
      			.clk(clk),
        		.pbin(pbin), 
      				.pbout(rst_clean)	//generated a clean signal
    ); 

    
    
    leds switch_reader (
      			.clk(clk), .rst(rst_clean),
                    .btns(16'd0),			// Not used for this FSM
                    .writeData(32'd0),			// We don't write to switches
                    .writeEnable(1'b0),			// Disabled
                    .readEnable(1'b1),			// Always ON so we can monitor switches
                    .memAddress(30'd0),       
                    .switches(physical_sw),		// Plug in the physical switches
                    .readData(switch_data)		// output data 
    );
    
    switches led_writer (
                    .clk(clk), .rst(rst_clean),
                    .writeData(led_write_data),
                    .writeEnable(1'b1),         	// Always ON so LEDs update instantly
                    .readEnable(1'b0), .memAddress(30'd0),
                    .readData(),                	// Ignored
                    .leds(physical_leds)      
    );
    
    clock_divider ticker (
                    .clk_in(clk),          		// Feed it the 100MHz fast clock
                    .rst(rst_clean),       		// Feed it the clean reset signal
                    .clk_out(slow_clk)     		// It spits out the 1Hz slow clock!
    );

    // FSM State Definitions
    localparam S_WAIT  = 1'b0;
    localparam S_COUNT = 1'b1;

    reg state_reg, state_next;
    reg [15:0] count_reg, count_next;

    // Rising edge detector for the 1Hz slow_clk
    reg slow_clk_d;
    wire slow_clk_tick;
    
    always @(posedge clk) begin
        slow_clk_d <= slow_clk;
    end
    assign slow_clk_tick = slow_clk & ~slow_clk_d;

    // FSM Sequential Block (State and Data Registers)
    always @(posedge clk or posedge rst_clean) begin
        if (rst_clean) begin
            state_reg <= S_WAIT;
            count_reg <= 16'd0;
        end else begin
            state_reg <= state_next;
            count_reg <= count_next;
        end
    end

    // FSM Combinational Block (Next State and Next Data Logic)
    always @(*) begin
        // Default assignments to prevent latches
        state_next = state_reg;
        count_next = count_reg;

        case (state_reg)
            S_WAIT: begin
                // Wait for a non-zero switch input to start
                if (physical_sw != 16'd0) begin
                    count_next = physical_sw;
                    state_next = S_COUNT;
                end else begin
                    count_next = 16'd0;
                end
            end

            S_COUNT: begin
                // Decrement counter exactly once per second
                if (slow_clk_tick) begin
                    count_next = count_reg - 1'b1;
                end

                // Return to WAIT state when countdown reaches 0
                if (count_next == 16'd0) begin
                    state_next = S_WAIT;
                end
            end

            default: begin
                state_next = S_WAIT;
                count_next = 16'd0;
            end
        endcase
    end

    always @(*) begin
    led_write_data = {16'd0, count_reg};
    end
    endmodule