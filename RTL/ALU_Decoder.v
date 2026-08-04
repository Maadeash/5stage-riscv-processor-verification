
`include "rv32i_defs.v"
module ALU_Decoder(
    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input  [6:0] funct7,
    input  [6:0] op,
    output reg [3:0] ALUControl
);
    always @* begin
        case (ALUOp)
            2'b00: ALUControl = `ALU_ADD;
            2'b01: ALUControl = `ALU_SUB;
            2'b10: begin
                case (funct3)
                    3'b000: ALUControl = (funct7[5] && op == `OPC_OP) ? `ALU_SUB : `ALU_ADD;
                    3'b111: ALUControl = `ALU_AND;
                    3'b110: ALUControl = `ALU_OR;
                    3'b100: ALUControl = `ALU_XOR;
                    3'b010: ALUControl = `ALU_SLT;
                    3'b011: ALUControl = `ALU_SLTU;
                    3'b001: ALUControl = `ALU_SLL;
                    3'b101: ALUControl = funct7[5] ? `ALU_SRA : `ALU_SRL;
                    default: ALUControl = `ALU_ADD;
                endcase
            end
            2'b11: begin
                case (funct3)
                    3'b000: ALUControl = (funct7[5]) ? `ALU_SUB : `ALU_ADD;
                    3'b111: ALUControl = `ALU_AND;
                    3'b110: ALUControl = `ALU_OR;
                    3'b100: ALUControl = `ALU_XOR;
                    3'b010: ALUControl = `ALU_SLT;
                    3'b011: ALUControl = `ALU_SLTU;
                    3'b001: ALUControl = `ALU_SLL;
                    3'b101: ALUControl = funct7[5] ? `ALU_SRA : `ALU_SRL;
                    default: ALUControl = `ALU_ADD;
                endcase
            end
            default: ALUControl = `ALU_ADD;
        endcase
    end
endmodule
