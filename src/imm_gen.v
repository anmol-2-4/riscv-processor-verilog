// Immediate generator for the I, S and B instruction formats used here.
// imm_type: 00 = I-type, 01 = S-type, 10 = B-type.
module imm_gen (
    input  wire [31:0] instruction,
    input  wire [1:0]  imm_type,
    output reg  [31:0] immediate
);

    always @(*) begin
        case (imm_type)
            // ADDI and LW: sign-extend the 12-bit I-type immediate.
            2'b00: immediate = {{20{instruction[31]}}, instruction[31:20]};

            // SW: immediate bits are split between instruction[31:25] and [11:7].
            2'b01: immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

            // BEQ: reconstruct the signed B-type offset; bit 0 is implicitly zero.
            2'b10: immediate = {{19{instruction[31]}}, instruction[31], instruction[7],
                                instruction[30:25], instruction[11:8], 1'b0};

            default: immediate = 32'b0;
        endcase
    end

endmodule
