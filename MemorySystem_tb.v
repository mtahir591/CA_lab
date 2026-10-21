`timescale 1ns / 1ps

module MemorySystem_tb();

    reg clk;
    reg rst;
    reg [31:0] address;
    reg readEnable;
    reg writeEnable;
    reg [31:0] writeData;
    reg [15:0] switches;

    wire [31:0] readData;
    wire [15:0] leds;

    addressDecoderTop uut (
        .clk(clk),
        .rst(rst),
        .address(address),
        .readEnable(readEnable),
        .writeEnable(writeEnable),
        .writeData(writeData),
        .switches(switches),
        .readData(readData),
        .leds(leds)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        address = 32'h0000_0000;
        readEnable = 0;
        writeEnable = 0;
        writeData = 32'h0000_0000;
        switches = 16'hCAFE;

        #20 rst = 0;

        @(negedge clk);
        address = 32'd16;          
        writeData = 32'h1234_5678;
        writeEnable = 1;
        readEnable = 0;

        @(negedge clk);
        writeEnable = 0;
        readEnable = 1;
        #10; 

        @(negedge clk);
        address = 32'd300;         
        writeData = 32'hABCD_EF01;
        writeEnable = 1;
        readEnable = 0;

        @(negedge clk);
        writeEnable = 0;
        readEnable = 1;
        #10;

        @(negedge clk);
        address = 32'd528;         
        writeData = 32'h0000_F0F0;
        writeEnable = 1;
        readEnable = 0;

        @(negedge clk);
        address = 32'd848;         
        writeEnable = 0;
        readEnable = 1;

        #20;
        $finish;
    end

endmodule