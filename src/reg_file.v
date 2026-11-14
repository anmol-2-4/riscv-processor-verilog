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
