`timescale 1ns / 1ps

module fpga_fsm_top(
    input clk,
    input rst,
    input [15:0] sw,
    output [15:0] led
);

    localparam IDLE = 3'd0,
               READ_SWITCHES = 3'd1,
               WRITE_DATAMEM = 3'd2,
               READ_DATAMEM = 3'd3,
               WRITE_LED = 3'd4;

    reg [2:0] state;
    reg [31:0] address;
    reg readEnable;
    reg writeEnable;
    reg [31:0] writeData;
    wire [31:0] readData;

    addressDecoderTop u_mem_sys (
        .clk(clk),
        .rst(rst),
        .address(address),
        .readEnable(readEnable),
        .writeEnable(writeEnable),
        .writeData(writeData),
        .switches(sw),
        .readData(readData),
        .leds(led)
    );

    reg [19:0] clk_div;
    always @(posedge clk) clk_div <= clk_div + 1;
    wire slow_clk = clk_div[19];

    always @(posedge slow_clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            address <= 32'd0;
            readEnable <= 1'b0;
            writeEnable <= 1'b0;
            writeData <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    readEnable <= 1'b0;
                    writeEnable <= 1'b0;
                    state <= READ_SWITCHES;
                end
                READ_SWITCHES: begin
                    address <= 32'h0000_0300;
                    readEnable <= 1'b1;
                    writeEnable <= 1'b0;
                    state <= WRITE_DATAMEM;
                end
                WRITE_DATAMEM: begin
                    address <= 32'h0000_0004;
                    writeData <= ~readData; // Inverts data for hardware testing
                    readEnable <= 1'b0;
                    writeEnable <= 1'b1;
                    state <= READ_DATAMEM;
                end
                READ_DATAMEM: begin
                    address <= 32'h0000_0004;
                    readEnable <= 1'b1;
                    writeEnable <= 1'b0;
                    state <= WRITE_LED;
                end
                WRITE_LED: begin
                    address <= 32'h0000_0200;
                    writeData <= readData;
                    readEnable <= 1'b0;
                    writeEnable <= 1'b1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule