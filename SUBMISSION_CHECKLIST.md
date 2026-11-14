# Digital Electronics Project Submission Checklist

Project title: **Design and Implementation of a 32-bit Single-Cycle RISC-V Processor Using Verilog**

## Required deliverables

- [x] Verilog design source files (`src/*.v`). The top-level processor module is `src/riscv_cpu.v`; compile it together with the other modules.
- [x] Verilog testbench (`tb/tb_riscv_cpu.v`).
- [x] Circuit/block diagram (`circuit_diagram.png` or `circuit_diagram.svg`).
- [ ] Run the updated nine-instruction simulation on the group's machine using `make test`.
- [ ] Upload the generated waveform file (`build/wave.vcd`) from that simulation.
- [ ] Upload a GTKWave screenshot showing the important processor signals.
- [ ] Fill in group details and final project title on the cover page/submission form.

## How to generate simulation results

From the project root directory:

```bash
make clean
make test
```

A successful run ends with:

```text
PASS: all nine RISC-V instruction checks succeeded.
```

The testbench writes `build/wave.vcd`. Open it with:

```bash
gtkwave build/wave.vcd
```

For a useful screenshot, display these signals together where available:

- `pc_debug`
- `instruction_debug`
- `alu_result_debug`
- `writeback_debug`
- `reg_write_debug`
- `mem_write_debug`
- `destination_debug`

Show the PC moving through the instruction addresses, including the taken branch at address 24 skipping address 28, followed by the AND, OR and XOR instructions at addresses 48, 52 and 56. Save the screenshot as `waveform_screenshot.png`.

## Expected logical-operation results

The program first sets x1 = 5 and x2 = 3.

- `AND x9, x1, x2` must write 1 to x9.
- `OR x10, x1, x2` must write 7 to x10.
- `XOR x11, x1, x2` must write 6 to x11.

The testbench checks these expected register values.

## Group details to fill in

- Group number:
- Project title:
- Member 1 name / roll number:
- Member 2 name / roll number:
- Member 3 name / roll number:
- Member 4 name / roll number:
- Course / section:

## Scope statement

This is a teaching implementation of a selected nine-instruction subset of RV32I: `ADD`, `SUB`, `ADDI`, `AND`, `OR`, `XOR`, `LW`, `SW` and `BEQ`. It is not a complete implementation of the RV32I base ISA.

For a submission portal that accepts only one design file, use the consolidated `riscv_design.v`. Submit `tb/tb_riscv_cpu.v` separately as the testbench. The modular files under `src/` are also included for development and explanation.
