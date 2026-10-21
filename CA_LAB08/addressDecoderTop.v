`timescale 1ns / 1ps

module addressDecoderTop(
    input clk,
    input rst,
    input [31:0] address,
    input readEnable,
    input writeEnable,
    input [31:0] writeData,
    input [15:0] switches,
    output [31:0] readData,
    output [15:0] leds
);

    wire DM, LED, Switch;
    wire [31:0] datamemout;
    wire [31:0] switchReadData;
    wire [31:0] unused_readData;

    addressdec u_dec (
        .addr(address),
        .memwrite(writeEnable),
        .memread(readEnable),
        .DM(DM),
        .LED(LED),
        .Switch(Switch)
    );

    datamem u_dm (
        .clk(clk),
        .rst(rst),
        .memwrite(DM),
        .addr(address),
        .writedata(writeData),
        .datamemout(datamemout)
    );

    switches u_led (
        .clk(clk),
        .rst(rst),
        .writeData(writeData),
        .writeEnable(LED),
        .readEnable(1'b0),
        .memAddress(address[29:0]),
        .readData(unused_readData),
        .leds(leds)
    );

    leds u_sw (
        .clk(clk),
        .rst(rst),
        .btns(16'd0),
        .writeData(32'd0),
        .writeEnable(1'b0),
        .readEnable(Switch),
        .memAddress(address[29:0]),
        .switches(switches),
        .readData(switchReadData)
    );

    assign readData = (Switch) ? switchReadData : datamemout;

endmodule
