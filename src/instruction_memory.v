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

    // PC uses byte addresses; bits [7:2] select a 32-bit instruction word.
    assign instruction = memory[address[7:2]];

endmodule
