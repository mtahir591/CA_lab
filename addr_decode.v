`timescale 1ns / 1ps

module addr_decode (
    input  [31:0] address_in,
    output        en_ram,
    output        en_led,
    output        en_sw,
    output        en_rst
);
    // Evaluates memory-mapped peripheral boundaries
    assign en_ram = (address_in[31:10] == 22'd0);
    assign en_led = (address_in == 32'h2000_0000);
    assign en_sw  = (address_in == 32'h2000_0004);
    assign en_rst = (address_in == 32'h2000_0008);
endmodule