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
