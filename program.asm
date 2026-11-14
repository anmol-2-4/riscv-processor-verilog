# Demonstration program for the nine-instruction processor.
# Supported: ADD, SUB, ADDI, LW, SW, BEQ, AND, OR and XOR.
# Matching 32-bit machine-code words are in program.hex.

ADDI x1, x0, 5       # x1 = 5
ADDI x2, x0, 3       # x2 = 3
ADD  x3, x1, x2      # x3 = 8
SUB  x4, x1, x2      # x4 = 2
SW   x3, 0(x0)       # memory[0] = 8
LW   x5, 0(x0)       # x5 = memory[0] = 8
BEQ  x3, x5, 8       # equal, skip the next instruction
ADDI x8, x0, 99      # should be skipped; x8 stays zero
ADDI x6, x0, 11      # branch target: x6 = 11
BEQ  x1, x2, 8       # not equal, so do not branch
ADDI x7, x0, 7       # x7 = 7
ADDI x0, x0, 0       # NOP (writes to x0 are ignored)
AND  x9, x1, x2      # x9 = 5 AND 3 = 1
OR   x10, x1, x2     # x10 = 5 OR 3 = 7
XOR  x11, x1, x2     # x11 = 5 XOR 3 = 6
