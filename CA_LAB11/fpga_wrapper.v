module fpga_wrapper(
    input wire clk,      // 100MHz from Basys 3
    input wire btnC,     // Center button for reset
    output wire [15:0] led // 16 LEDs above the switches
);
    reg [25:0] clk_divider;
    wire slow_clk;
    
    // Slow down the 100MHz clock to ~1.5 Hz
    always @(posedge clk) begin
        clk_divider <= clk_divider + 1;
    end
    assign slow_clk = clk_divider[25]; // Extract the 25th bit

    // Instantiate your processor
    TopLevelProcessor cpu (
        .clk(slow_clk),
        .reset(btnC),
        .current_pc(led) // Route PC to LEDs
    );
endmodule