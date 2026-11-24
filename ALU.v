module ALU (
    input wire [31:0] in1,
    input wire [31:0] in2,
    input wire [3:0] alu_control,
    output reg [31:0] result,
    output wire zero
);
    always @(*) begin
        case (alu_control)
            4'b0000: result = in1 & in2; // AND
            4'b0001: result = in1 | in2; // OR
            4'b0010: result = in1 + in2; // ADD
            4'b0110: result = in1 - in2; // SUB
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);
endmodule