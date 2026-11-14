`timescale 1ns/1ps

module tb_riscv_cpu;

    reg clk;
    reg reset;

    wire [31:0] pc_debug;
    wire [31:0] instruction_debug;
    wire [31:0] alu_result_debug;
    wire [31:0] writeback_debug;
    wire        reg_write_debug;
    wire        mem_write_debug;
    wire [4:0]  destination_debug;
    wire        illegal_instruction_debug;

    integer cycle;

    riscv_cpu dut (
        .clk(clk),
        .reset(reset),
        .pc_debug(pc_debug),
        .instruction_debug(instruction_debug),
        .alu_result_debug(alu_result_debug),
        .writeback_debug(writeback_debug),
        .reg_write_debug(reg_write_debug),
        .mem_write_debug(mem_write_debug),
        .destination_debug(destination_debug),
        .illegal_instruction_debug(illegal_instruction_debug)
    );

    // 10 ns clock period: toggle every 5 ns.
    always #5 clk = ~clk;

    initial begin
        clk   = 1'b0;
        reset = 1'b1;

        $dumpfile("build/wave.vcd");
        $dumpvars(0, tb_riscv_cpu);

        // Hold reset for two rising edges.
        repeat (2) @(posedge clk);
        #1 reset = 1'b0;

        // Execute 14 instructions. The BEQ at address 24 skips address 28.
        // AND, OR and XOR execute at addresses 48, 52 and 56.
        for (cycle = 0; cycle < 14; cycle = cycle + 1) begin
            @(negedge clk);
            #1;
            $display("Cycle %0d: PC=%0d  instruction=%h  ALU=%0d",
                     cycle + 1, pc_debug, instruction_debug, alu_result_debug);
            if (illegal_instruction_debug)
                $fatal(1, "Unexpected/unsupported instruction at PC=%0d", pc_debug);
            @(posedge clk);
            #1;
        end

        // Check arithmetic and memory results.
        if (dut.register_file.regs[1] !== 32'd5)
            $fatal(1, "x1 expected 5, got %0d", dut.register_file.regs[1]);
        if (dut.register_file.regs[2] !== 32'd3)
            $fatal(1, "x2 expected 3, got %0d", dut.register_file.regs[2]);
        if (dut.register_file.regs[3] !== 32'd8)
            $fatal(1, "x3 expected 8, got %0d", dut.register_file.regs[3]);
        if (dut.register_file.regs[4] !== 32'd2)
            $fatal(1, "x4 expected 2, got %0d", dut.register_file.regs[4]);
        if (dut.register_file.regs[5] !== 32'd8)
            $fatal(1, "x5 expected 8, got %0d", dut.register_file.regs[5]);
        if (dut.register_file.regs[6] !== 32'd11)
            $fatal(1, "x6 expected 11, got %0d", dut.register_file.regs[6]);
        if (dut.register_file.regs[7] !== 32'd7)
            $fatal(1, "x7 expected 7, got %0d", dut.register_file.regs[7]);

        // The taken BEQ skips the ADDI at address 28, so x8 stays zero.
        if (dut.register_file.regs[8] !== 32'd0)
            $fatal(1, "BEQ did not skip the instruction as expected; x8=%0d",
                   dut.register_file.regs[8]);

        // Verify the three bitwise logical instructions.
        if (dut.register_file.regs[9] !== 32'd1)
            $fatal(1, "AND failed: x9 expected 1, got %0d", dut.register_file.regs[9]);
        if (dut.register_file.regs[10] !== 32'd7)
            $fatal(1, "OR failed: x10 expected 7, got %0d", dut.register_file.regs[10]);
        if (dut.register_file.regs[11] !== 32'd6)
            $fatal(1, "XOR failed: x11 expected 6, got %0d", dut.register_file.regs[11]);

        // x0 must always remain zero.
        if (dut.register_file.regs[0] !== 32'd0)
            $fatal(1, "x0 must remain zero");

        // SW stored the value 8 in data-memory word 0.
        if (dut.data_ram.memory[0] !== 32'd8)
            $fatal(1, "memory[0] expected 8, got %0d", dut.data_ram.memory[0]);

        if (pc_debug !== 32'd60)
            $fatal(1, "PC expected 60 after the test program, got %0d", pc_debug);

        $display("--------------------------------------------------");
        $display("PASS: all nine RISC-V instruction checks succeeded.");
        $display("x1=5, x2=3, x3=8, x4=2, x5=8, x6=11, x7=7");
        $display("AND: x9=1; OR: x10=7; XOR: x11=6");
        $display("memory[0]=8; taken and not-taken BEQ both checked.");
        $display("--------------------------------------------------");
        $finish;
    end

endmodule
