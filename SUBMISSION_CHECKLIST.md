# Digital Electronics Project Submission Checklist

Project title: **Design and Implementation of a 32-bit Single-Cycle RISC-V Processor Using Verilog**

## Required deliverables

- [x] Verilog design source files (`src/*.v`). The top-level processor module is `src/riscv_cpu.v`; compile it together with the other modules.
- [x] Verilog testbench (`tb/tb_riscv_cpu.v`).
- [x] Circuit/block diagram (`circuit_diagram.png` or `circuit_diagram.svg`).
- [ ] Actual simulation run on the group's machine using `make test`.
- [ ] Generated waveform file (`build/wave.vcd`) from that simulation.
- [ ] GTKWave screenshot showing the important processor signals.
- [ ] Group details and final project title on the cover page/submission form.

## How to generate simulation results

From the project root directory:

```bash
make clean
make test
```

A successful run should end with:

```text
PASS: all RISC-V processor checks succeeded.
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

Show the PC moving through the instruction addresses and the branch at address 24 skipping address 28. Save the screenshot as `waveform_screenshot.png`.

## Group details to fill in

- Group number:
- Project title:
- Member 1 name / roll number:
- Member 2 name / roll number:
- Member 3 name / roll number:
- Member 4 name / roll number:
- Course / section:

## Scope statement

This is a teaching implementation of a six-instruction subset of RV32I: `ADD`, `SUB`, `ADDI`, `LW`, `SW` and `BEQ`. It is not a complete implementation of the RV32I base ISA.

For a submission portal that accepts only one design file, use the consolidated `riscv_design.v`. Submit `tb/tb_riscv_cpu.v` separately as the testbench. The modular files under `src/` are also included for development and explanation.
