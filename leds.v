`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muddassir Ali

// Module Name: leds
// Project Name: Counter
// Target Devices: Baasys 3
// 
//////////////////////////////////////////////////////////////////////////////////


module leds(
    input clk,
    input rst,
    input [15:0] btns,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,
    input [15:0] switches,
    output [31:0] readData
    );
  
    assign readData = {16'd0, switches};
endmodule