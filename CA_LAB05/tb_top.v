`timescale 1ns / 1ps

module tb_top;

    // Inputs
    reg clk;
    reg pbin;
    reg [15:0] physical_sw;

    // Outputs
    wire [15:0] physical_leds;

    // Instantiate the Unit Under Test (UUT)
    top_fsm_system uut (
        .clk(clk), 
        .pbin(pbin), 
        .physical_sw(physical_sw), 
        .physical_leds(physical_leds)
    );

    // Clock generation (10ns period -> 100MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        pbin = 1; // Assert reset button initially
        physical_sw = 16'd0;

        // Wait 100 ns for global reset to finish
        #100;
        pbin = 0; // Release reset button
        #100;

        // Test Case 1: Apply zero switch value (System should remain in WAIT state)
        physical_sw = 16'd0;
        #100;

        // Test Case 2: Apply non-zero switch value to start countdown (e.g., 3)
        // Note: Because the simulation uses MAX_COUNT = 2 in clock_divider, 
        // the "slow_clk" will toggle very fast (every 2 clock cycles).
        physical_sw = 16'd3;
        
        // Wait long enough for the countdown to complete and return to 0
        #200; 
        
        // Clear switches back to 0
        physical_sw = 16'd0;
        #100;

        // Test Case 3: Test reset during countdown
        physical_sw = 16'd5; // Start a new countdown from 5
        #50;                 // Let it count down briefly
        
        pbin = 1;            // Press the reset button mid-countdown
        #20;
        pbin = 0;            // Release reset button
        
        // Clear switches
        physical_sw = 16'd0;
        
        // Wait to observe that LEDs and counter were cleared
        #100;

        $finish;
    end
endmodule