// This subset supports BEQ only: take the branch when the ALU says the values match.
module branch_unit (
    input  wire branch_enable,
    input  wire operands_equal,
    output wire take_branch
);
    assign take_branch = branch_enable & operands_equal;
endmodule
