// Arithmetic Logic Unit for the small RV32I subset.
// ALU control: 2'b00 = ADD, 2'b01 = SUB.
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [1:0]  alu_control,
    output reg  [31:0] result,
    output wire        zero
);

    always @(*) begin
        case (alu_control)
            2'b00: result = a + b;
            2'b01: result = a - b;
            default: result = 32'b0;
        endcase
    end

    // Used by BEQ: subtracting equal values produces zero.
    assign zero = (result == 32'b0);

endmodule
