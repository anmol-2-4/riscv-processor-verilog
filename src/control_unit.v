// Main decoder for the nine supported instructions:
// ADD, SUB, ADDI, LW, SW, BEQ, AND, OR and XOR.
module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        reg_write,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        alu_src,
    output reg        branch,
    output reg [2:0]  alu_control,
    output reg [1:0]  imm_type,
    output reg        illegal_instruction
);

    always @(*) begin
        // Safe defaults: unsupported instructions do not alter registers or memory.
        reg_write           = 1'b0;
        mem_write           = 1'b0;
        mem_to_reg          = 1'b0;
        alu_src             = 1'b0;
        branch              = 1'b0;
        alu_control         = 3'b000;
        imm_type            = 2'b00;
        illegal_instruction = 1'b0;

        case (opcode)
            // R-type: ADD, SUB, AND, OR and XOR.
            7'b0110011: begin
                if (funct3 == 3'b000 && funct7 == 7'b0000000) begin
                    reg_write   = 1'b1;
                    alu_control = 3'b000; // ADD
                end else if (funct3 == 3'b000 && funct7 == 7'b0100000) begin
                    reg_write   = 1'b1;
                    alu_control = 3'b001; // SUB
                end else if (funct3 == 3'b111 && funct7 == 7'b0000000) begin
                    reg_write   = 1'b1;
                    alu_control = 3'b010; // AND
                end else if (funct3 == 3'b110 && funct7 == 7'b0000000) begin
                    reg_write   = 1'b1;
                    alu_control = 3'b011; // OR
                end else if (funct3 == 3'b100 && funct7 == 7'b0000000) begin
                    reg_write   = 1'b1;
                    alu_control = 3'b100; // XOR
                end else begin
                    illegal_instruction = 1'b1;
                end
            end

            // I-type: ADDI.
            7'b0010011: begin
                if (funct3 == 3'b000) begin
                    reg_write   = 1'b1;
                    alu_src     = 1'b1;
                    alu_control = 3'b000;
                    imm_type    = 2'b00;
                end else begin
                    illegal_instruction = 1'b1;
                end
            end

            // I-type load: LW.
            7'b0000011: begin
                if (funct3 == 3'b010) begin
                    reg_write   = 1'b1;
                    mem_to_reg  = 1'b1;
                    alu_src     = 1'b1;
                    alu_control = 3'b000;
                    imm_type    = 2'b00;
                end else begin
                    illegal_instruction = 1'b1;
                end
            end

            // S-type store: SW.
            7'b0100011: begin
                if (funct3 == 3'b010) begin
                    mem_write   = 1'b1;
                    alu_src     = 1'b1;
                    alu_control = 3'b000;
                    imm_type    = 2'b01;
                end else begin
                    illegal_instruction = 1'b1;
                end
            end

            // B-type branch: BEQ. Subtraction sets zero when operands are equal.
            7'b1100011: begin
                if (funct3 == 3'b000) begin
                    branch      = 1'b1;
                    alu_control = 3'b001;
                    imm_type    = 2'b10;
                end else begin
                    illegal_instruction = 1'b1;
                end
            end

            default: illegal_instruction = 1'b1;
        endcase
    end

endmodule
