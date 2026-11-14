// Consolidated design file for submission.
// Contains the nine synthesizable/simulation design modules.
// Compile this file together with tb/tb_riscv_cpu.v.

// ===== BEGIN src/alu.v =====
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

// ===== END src/alu.v =====

// ===== BEGIN src/reg_file.v =====
// 32 general-purpose registers, each 32 bits wide.
// Two asynchronous read ports and one synchronous write port.
module reg_file (
    input  wire        clk,
    input  wire        reset,
    input  wire [4:0]  read_addr1,
    input  wire [4:0]  read_addr2,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2,
    input  wire        reg_write,
    input  wire [4:0]  write_addr,
    input  wire [31:0] write_data
);

    reg [31:0] regs [0:31];
    integer i;

    // Register values change only on the rising clock edge.
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else if (reg_write && (write_addr != 5'd0)) begin
            regs[write_addr] <= write_data;
        end
    end

    // x0 is hardwired to zero, regardless of its stored array value.
    assign read_data1 = (read_addr1 == 5'd0) ? 32'b0 : regs[read_addr1];
    assign read_data2 = (read_addr2 == 5'd0) ? 32'b0 : regs[read_addr2];

endmodule

// ===== END src/reg_file.v =====

// ===== BEGIN src/program_counter.v =====
// Stores the address of the instruction currently being executed.
module program_counter (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);

    always @(posedge clk) begin
        if (reset)
            pc <= 32'b0;
        else
            pc <= next_pc;
    end

endmodule

// ===== END src/program_counter.v =====

// ===== BEGIN src/imm_gen.v =====
// Immediate generator for the I, S and B instruction formats used here.
// imm_type: 2'b00 = I-type, 2'b01 = S-type, 2'b10 = B-type.
module imm_gen (
    input  wire [31:0] instruction,
    input  wire [1:0]  imm_type,
    output reg  [31:0] immediate
);

    always @(*) begin
        case (imm_type)
            // ADDI and LW
            2'b00: immediate = {{20{instruction[31]}}, instruction[31:20]};

            // SW: immediate bits are split between instruction[31:25] and [11:7].
            2'b01: immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

            // BEQ: branch offsets are multiples of two bytes; bit 0 is zero.
            2'b10: immediate = {{19{instruction[31]}}, instruction[31], instruction[7],
                                instruction[30:25], instruction[11:8], 1'b0};

            default: immediate = 32'b0;
        endcase
    end

endmodule

// ===== END src/imm_gen.v =====

// ===== BEGIN src/control_unit.v =====
// Main decoder for the six supported instructions:
// ADD, SUB, ADDI, LW, SW and BEQ.
module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        reg_write,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        alu_src,
    output reg        branch,
    output reg [1:0]  alu_control,
    output reg [1:0]  imm_type,
    output reg        illegal_instruction
);

    always @(*) begin
        // Safe defaults: an unsupported instruction changes no register or memory.
        reg_write           = 1'b0;
        mem_write           = 1'b0;
        mem_to_reg          = 1'b0;
        alu_src             = 1'b0;
        branch              = 1'b0;
        alu_control         = 2'b00;
        imm_type            = 2'b00;
        illegal_instruction = 1'b0;

        case (opcode)
            // R-type: ADD and SUB
            7'b0110011: begin
                if (funct3 == 3'b000 && funct7 == 7'b0000000) begin
                    reg_write   = 1'b1;
                    alu_control = 2'b00; // ADD
                end else if (funct3 == 3'b000 && funct7 == 7'b0100000) begin
                    reg_write   = 1'b1;
                    alu_control = 2'b01; // SUB
                end else begin
                    illegal_instruction = 1'b1;
                end
            end

            // I-type: ADDI
            7'b0010011: begin
                if (funct3 == 3'b000) begin
                    reg_write   = 1'b1;
                    alu_src     = 1'b1;
                    alu_control = 2'b00;
                    imm_type    = 2'b00;
                end else begin
                    illegal_instruction = 1'b1;
                end
            end

            // I-type load: LW
            7'b0000011: begin
                if (funct3 == 3'b010) begin
                    reg_write   = 1'b1;
                    mem_to_reg  = 1'b1;
                    alu_src     = 1'b1;
                    alu_control = 2'b00;
                    imm_type    = 2'b00;
                end else begin
                    illegal_instruction = 1'b1;
                end
            end

            // S-type store: SW
            7'b0100011: begin
                if (funct3 == 3'b010) begin
                    mem_write  = 1'b1;
                    alu_src    = 1'b1;
                    alu_control = 2'b00;
                    imm_type   = 2'b01;
                end else begin
                    illegal_instruction = 1'b1;
                end
            end

            // B-type branch: BEQ
            7'b1100011: begin
                if (funct3 == 3'b000) begin
                    branch      = 1'b1;
                    alu_control = 2'b01; // subtract to compare the two registers
                    imm_type    = 2'b10;
                end else begin
                    illegal_instruction = 1'b1;
                end
            end

            default: illegal_instruction = 1'b1;
        endcase
    end

endmodule

// ===== END src/control_unit.v =====

// ===== BEGIN src/branch_unit.v =====
// This subset supports BEQ only: take the branch when the ALU says the values match.
module branch_unit (
    input  wire branch_enable,
    input  wire operands_equal,
    output wire take_branch
);
    assign take_branch = branch_enable & operands_equal;
endmodule

// ===== END src/branch_unit.v =====

// ===== BEGIN src/instruction_memory.v =====
// Read-only instruction memory for simulation.
// It loads 32-bit machine instructions from program.hex at simulation start.
module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:63];
    integer i;

    initial begin
        // Fill unused locations with NOP = ADDI x0, x0, 0.
        for (i = 0; i < 64; i = i + 1)
            memory[i] = 32'h00000013;
        $readmemh("program.hex", memory);
    end

    // This simple teaching memory is word-addressed using byte addresses.
    assign instruction = memory[address[7:2]];

endmodule

// ===== END src/instruction_memory.v =====

// ===== BEGIN src/data_memory.v =====
// Simple 64-word data memory.
// This teaching version supports aligned 32-bit LW and SW operations only.
module data_memory (
    input  wire        clk,
    input  wire        reset,
    input  wire        write_enable,
    input  wire [31:0] address,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);

    reg [31:0] memory [0:63];
    integer i;

    // Asynchronous read: data is available from the selected memory word.
    assign read_data = memory[address[7:2]];

    // Store happens on the rising clock edge.
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 64; i = i + 1)
                memory[i] <= 32'b0;
        end else if (write_enable && (address[1:0] == 2'b00)) begin
            memory[address[7:2]] <= write_data;
        end
    end

endmodule

// ===== END src/data_memory.v =====

// ===== BEGIN src/riscv_cpu.v =====
// Top-level single-cycle processor implementing a small RV32I subset.
// Supported instructions: ADD, SUB, ADDI, LW, SW and BEQ.
module riscv_cpu (
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] pc_debug,
    output wire [31:0] instruction_debug,
    output wire [31:0] alu_result_debug,
    output wire [31:0] writeback_debug,
    output wire        reg_write_debug,
    output wire        mem_write_debug,
    output wire [4:0]  destination_debug,
    output wire        illegal_instruction_debug
);

    wire [31:0] pc_current;
    wire [31:0] next_pc;
    wire [31:0] instruction;
    wire [31:0] pc_plus_4;

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] immediate;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire        alu_zero;
    wire [31:0] memory_read_data;
    wire [31:0] writeback_data;

    wire        reg_write;
    wire        mem_write;
    wire        mem_to_reg;
    wire        alu_src;
    wire        branch;
    wire [1:0]  alu_control;
    wire [1:0]  imm_type;
    wire        take_branch;

    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd  = instruction[11:7];

    // 1. Program Counter and instruction fetch.
    program_counter pc_register (
        .clk(clk), .reset(reset), .next_pc(next_pc), .pc(pc_current)
    );

    instruction_memory instruction_rom (
        .address(pc_current), .instruction(instruction)
    );

    // 2. Decode the instruction and generate control signals.
    control_unit decoder (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .alu_control(alu_control),
        .imm_type(imm_type),
        .illegal_instruction(illegal_instruction_debug)
    );

    // 3. Read source registers and generate the immediate constant.
    reg_file register_file (
        .clk(clk), .reset(reset),
        .read_addr1(rs1), .read_addr2(rs2),
        .read_data1(read_data1), .read_data2(read_data2),
        .reg_write(reg_write), .write_addr(rd), .write_data(writeback_data)
    );

    imm_gen immediate_generator (
        .instruction(instruction), .imm_type(imm_type), .immediate(immediate)
    );

    // 4. Execute: the second ALU input is either a register or an immediate.
    assign alu_operand_b = (alu_src) ? immediate : read_data2;

    alu arithmetic_logic_unit (
        .a(read_data1), .b(alu_operand_b),
        .alu_control(alu_control), .result(alu_result), .zero(alu_zero)
    );

    // BEQ uses the ALU subtraction result to test whether the registers are equal.
    branch_unit branch_checker (
        .branch_enable(branch), .operands_equal(alu_zero), .take_branch(take_branch)
    );

    // 5. Memory access and write-back.
    data_memory data_ram (
        .clk(clk), .reset(reset), .write_enable(mem_write),
        .address(alu_result), .write_data(read_data2), .read_data(memory_read_data)
    );

    assign writeback_data = (mem_to_reg) ? memory_read_data : alu_result;

    // Choose the next instruction address.
    assign pc_plus_4 = pc_current + 32'd4;
    assign next_pc = (take_branch) ? (pc_current + immediate) : pc_plus_4;

    // Debug outputs make it easier to inspect the processor in a waveform viewer.
    assign pc_debug                    = pc_current;
    assign instruction_debug           = instruction;
    assign alu_result_debug            = alu_result;
    assign writeback_debug             = writeback_data;
    assign reg_write_debug             = reg_write;
    assign mem_write_debug             = mem_write;
    assign destination_debug           = rd;

endmodule

// ===== END src/riscv_cpu.v =====

