module pcAdder (
    input wire [31:0] pc,
    output wire [31:0] next_seq_pc
);
    assign next_seq_pc = pc + 32'd4;
endmodule