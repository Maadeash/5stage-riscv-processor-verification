
`include "rv32i_defs.v"
module ALU(
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALUControl,
    output reg [31:0] Result,
    output Zero,
    output Negative,
    output Carry,
    output Overflow
);
    reg [32:0] tmp;
    always @* begin
        tmp = 33'd0;
        case (ALUControl)
            `ALU_ADD:  begin tmp = {1'b0, A} + {1'b0, B}; Result = tmp[31:0]; end
            `ALU_SUB:  begin tmp = {1'b0, A} - {1'b0, B}; Result = tmp[31:0]; end
            `ALU_AND:  Result = A & B;
            `ALU_OR:   Result = A | B;
            `ALU_XOR:  Result = A ^ B;
            `ALU_SLT:  Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            `ALU_SLTU: Result = (A < B) ? 32'd1 : 32'd0;
            `ALU_PASSB:Result = B;
            `ALU_COPYA:Result = A;
            `ALU_SLL:  Result = A << B[4:0];
            `ALU_SRL:  Result = A >> B[4:0];
            `ALU_SRA:  Result = $signed(A) >>> B[4:0];
            default:   Result = 32'd0;
        endcase
    end
    assign Zero = (Result == 32'd0);
    assign Negative = Result[31];
    assign Carry = (ALUControl == `ALU_ADD) ? tmp[32] :
                   (ALUControl == `ALU_SUB) ? ~tmp[32] : 1'b0;
    assign Overflow = (ALUControl == `ALU_ADD) ? ((A[31] == B[31]) && (Result[31] != A[31])) :
                      (ALUControl == `ALU_SUB) ? ((A[31] != B[31]) && (Result[31] != A[31])) : 1'b0;
endmodule
