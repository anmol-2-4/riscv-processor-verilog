// Arithmetic Logic Unit for the supported RV32I subset.
// ALU control: 000 = ADD, 001 = SUB, 010 = AND, 011 = OR, 100 = XOR.
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  alu_control,
    output reg  [31:0] result,
    output wire        zero
);

    // Combinational ALU: result follows the current operands and control.
    always @(*) begin
        case (alu_control)
            3'b000: result = a + b;
            3'b001: result = a - b;
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            default: result = 32'b0;
        endcase
    end

    // BEQ uses this flag after the ALU subtracts its two source operands.
    assign zero = (result == 32'b0);

endmodule
