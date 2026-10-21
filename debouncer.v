`timescale 1ns / 1ps

module debouncer(
    input clk,
    input pbin,
    output pbout
    );
  
    assign pbout = pbin;
endmodule