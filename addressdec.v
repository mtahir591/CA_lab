`timescale 1ns / 1ps

module addressdec(
    input [31:0] addr,
    input memwrite,
    input memread,
    output DM,
    output LED,
    output Switch
);

    wire [1:0] selector;
    assign selector = addr[9:8];

    assign DM = ((selector == 2'b00) || (selector == 2'b01)) && (memwrite == 1'b1);
    assign LED = (selector == 2'b10) && (memwrite == 1'b1);
    assign Switch = (selector == 2'b11) && (memread == 1'b1);

endmodule