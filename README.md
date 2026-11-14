# 32-bit RISC-V Processor (Intermediate Verilog Project)

A beginner-friendly **single-cycle processor** written in Verilog. It implements a small, clearly defined subset of the RV32I instruction set:

- `ADD` — add two registers
- `SUB` — subtract two registers
- `ADDI` — add an immediate constant
- `LW` — load one 32-bit word from data memory
- `SW` — store one 32-bit word to data memory
- `BEQ` — branch when two registers are equal

This is a teaching implementation of a subset of RV32I, not a complete RV32I processor.

## 1. What happens in one instruction?

The design uses the single-cycle idea. During one clock cycle, an instruction passes through these logical stages:

1. **Fetch:** the Program Counter (PC) selects an instruction from instruction memory.
2. **Decode:** the Control Unit reads the opcode and function fields.
3. **Read operands:** the Register File provides the source-register values; the Immediate Generator extracts a constant/offset when needed.
4. **Execute:** the ALU performs addition or subtraction. For `BEQ`, subtraction is used to test equality.
5. **Memory access:** `LW` reads data memory; `SW` writes data memory.
6. **Write-back:** the ALU result or memory result is written to the destination register when required.

The PC and register/memory state update on the rising clock edge. A normal instruction advances the PC by 4 bytes. A taken `BEQ` adds its signed branch offset to the current PC.

## 2. Folder structure

```text
riscv_intermediate_project/
├── src/
│   ├── alu.v
│   ├── branch_unit.v
│   ├── control_unit.v
│   ├── data_memory.v
│   ├── imm_gen.v
│   ├── instruction_memory.v
│   ├── riscv_cpu.v
│   ├── program_counter.v
│   └── reg_file.v
├── tb/
│   └── tb_riscv_cpu.v
├── program.asm
├── program.hex
└── Makefile
```

## 3. Tools required

- Icarus Verilog (`iverilog` and `vvp`) for compilation and simulation.
- GTKWave for viewing the waveform (optional, but useful for demonstration).

On Ubuntu, if these tools are not installed, they can usually be installed with:

```bash
sudo apt update
sudo apt install iverilog gtkwave make
```

## 4. Run the simulation

Open a terminal in this project folder, then run:

```bash
make test
```

A successful run ends with:

```text
PASS: all RISC-V processor checks succeeded.
```

To open the waveform after running the test:

```bash
make wave
```

The waveform file is `build/wave.vcd`. In GTKWave, useful signals include `pc_debug`, `instruction_debug`, `alu_result_debug`, `writeback_debug`, `reg_write_debug`, and `mem_write_debug`.

To remove generated simulation files:

```bash
make clean
```

**Important:** run `make` from the project root directory because the instruction memory reads `program.hex` using a relative path.

## 5. Demonstration program

The source-like listing is in `program.asm`; the corresponding 32-bit machine-code words are in `program.hex`.

| Address | Instruction | Purpose |
|---:|---|---|
| 0 | `ADDI x1, x0, 5` | Put 5 in x1 |
| 4 | `ADDI x2, x0, 3` | Put 3 in x2 |
| 8 | `ADD x3, x1, x2` | x3 becomes 8 |
| 12 | `SUB x4, x1, x2` | x4 becomes 2 |
| 16 | `SW x3, 0(x0)` | Store 8 at data-memory address 0 |
| 20 | `LW x5, 0(x0)` | Load 8 into x5 |
| 24 | `BEQ x3, x5, 8` | Branch is taken; skip address 28 |
| 28 | `ADDI x8, x0, 99` | Skipped; x8 stays zero |
| 32 | `ADDI x6, x0, 11` | Branch target; x6 becomes 11 |
| 36 | `BEQ x1, x2, 8` | Not taken because 5 is not 3 |
| 40 | `ADDI x7, x0, 7` | x7 becomes 7 |
| 44 | `ADDI x0, x0, 0` | NOP; x0 remains zero |

The testbench checks the register results, data memory, x0 behaviour, and both taken and not-taken `BEQ` behaviour.

## 6. Module responsibilities

| Module | Responsibility |
|---|---|
| `program_counter.v` | Holds the current instruction address |
| `instruction_memory.v` | Supplies the instruction selected by the PC |
| `control_unit.v` | Decodes supported instructions and generates control signals |
| `reg_file.v` | Holds 32 32-bit registers; x0 always reads as zero |
| `imm_gen.v` | Extracts and sign-extends I-, S- and B-type immediates |
| `alu.v` | Performs ADD and SUB operations |
| `branch_unit.v` | Takes a BEQ branch when the ALU result is zero |
| `data_memory.v` | Stores and loads aligned 32-bit words |
| `riscv_cpu.v` | Connects all the modules into the processor |
| `tb_riscv_cpu.v` | Runs a program and checks expected results |

## 7. Scope and limitations

To keep this project appropriate for learning the datapath and control logic, it intentionally does **not** implement the complete RV32I instruction set.

- Only the six instructions listed above are supported.
- Data memory supports aligned 32-bit `LW` and `SW` only; byte and halfword operations are not implemented.
- Only `BEQ` is implemented; other branch conditions are not implemented.
- There is no pipelining, interrupt handling, exception handling, or privileged architecture.
- Instruction memory and data memory are simple simulation-oriented arrays. Their implementation may need changes for a particular FPGA board or memory primitive.

## 8. Suggested explanation for a lab demonstration

"We designed a small single-cycle 32-bit RISC-V processor using Verilog. It implements six instructions: ADD, SUB, ADDI, LW, SW and BEQ. The Program Counter fetches an instruction, the Control Unit decodes it, the Register File supplies operands, and the ALU performs the required operation. Load and store instructions access data memory, and the write-back path updates the destination register. The Program Counter normally advances by four bytes, but changes to the branch target when BEQ is true. We verify the design with a Verilog testbench in Icarus Verilog and inspect signals using GTKWave."

## 9. Learning advice

Do not try to memorise every file at once. Understand the modules in this order:

1. `alu.v`
2. `reg_file.v`
3. `program_counter.v`
4. `imm_gen.v`
5. `control_unit.v`
6. `riscv_cpu.v`
7. `tb/tb_riscv_cpu.v`

For a presentation, be especially ready to explain how `ADDI x1, x0, 5` and `ADD x3, x1, x2` travel through the datapath.

## 10. Circuit diagram and submission deliverables

The processor block/datapath diagram is provided as `circuit_diagram.png` and `circuit_diagram.svg`. The editable Graphviz source is `circuit_diagram.dot`.

See `SUBMISSION_CHECKLIST.md` for the professor's deliverables checklist, steps to generate `build/wave.vcd`, recommended GTKWave signals, and group-details fields. The waveform and screenshot must be generated from an actual simulation run on the group's machine; they are not pre-generated in this archive.

## 11. Single consolidated Verilog design file

For submission systems or instructors that prefer one design `.v` file, `riscv_design.v` contains all nine design modules in one file. Keep `tb/tb_riscv_cpu.v` as the separate testbench. The original `src/*.v` files are retained for easier learning and modular development.

To compile the consolidated design and testbench directly:

```bash
mkdir -p build
iverilog -g2012 -Wall -o build/riscv_sim riscv_design.v tb/tb_riscv_cpu.v
vvp build/riscv_sim
```
