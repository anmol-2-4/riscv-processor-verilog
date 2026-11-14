IVERILOG ?= iverilog
VVP      ?= vvp
GTKWAVE  ?= gtkwave

SOURCES = \
	src/alu.v \
	src/reg_file.v \
	src/program_counter.v \
	src/imm_gen.v \
	src/control_unit.v \
	src/branch_unit.v \
	src/instruction_memory.v \
	src/data_memory.v \
	src/riscv_cpu.v

TESTBENCH = tb/tb_riscv_cpu.v
SIM       = build/riscv_sim

.PHONY: all compile test wave clean

all: test

build:
	mkdir -p build

compile: build
	$(IVERILOG) -g2012 -Wall -o $(SIM) $(SOURCES) $(TESTBENCH)

test: compile
	$(VVP) $(SIM)

wave: test
	$(GTKWAVE) build/wave.vcd

clean:
	rm -rf build
