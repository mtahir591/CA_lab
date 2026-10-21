module top_memtest #(
    parameter DEBOUNCE_COUNT = 1_000_000
)(
    input wire clk,
    input wire pbin,
    input wire pbwrite,
    input wire [15:0] physical_sw,
    output wire [15:0] physical_leds
);
    wire rst;
    debouncer rst_db(
        .clk(clk),
        .pbin(pbin),
        .pbout(rst)
    );

    wire writeClean;
    button_debouncer #(.THRESHOLD(DEBOUNCE_COUNT)) write_db(
        .clk(clk),
        .pbin(pbwrite),
        .pbout(writeClean)
    );

    reg writePrev = 1'b0;
    always @(posedge clk) writePrev <= writeClean;
    wire writePulse = writeClean & ~writePrev;

    wire [31:0] address   = {22'd0, physical_sw[15:6]};
    wire [31:0] writeData = {28'd0, physical_sw[3:0]};
    wire [31:0] readData;

    addressDecoderTop mem_sys(
        .clk(clk),
        .rst(rst),
        .address(address),
        .readEnable(1'b1),
        .writeEnable(writePulse),
        .writeData(writeData),
        .switches(physical_sw),
        .readData(readData),
        .leds()
    );

    assign physical_leds = {12'd0, readData[3:0]};
endmodule