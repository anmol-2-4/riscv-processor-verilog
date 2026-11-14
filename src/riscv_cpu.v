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
