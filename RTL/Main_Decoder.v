`include "rv32i_defs.v"
module Main_Decoder(
  input [6:0]Op,
  output reg RegWrite,
  output reg [2:0]ImmSrc,
  output reg ALUSrc,
  output reg MemWrite,
  output reg MemRead,
  output reg [1:0]ResultSrc,
  output reg Branch,
  output reg Jump,
  output reg JALR,
  output reg [1:0]ALUOp
);
  always @* begin
    RegWrite=1'b0;
    ImmSrc=3'b000;
    ALUSrc=1'b0;
    MemWrite=1'b0;
    MemRead=1'b0;
    ResultSrc=`WB_ALU;
    Branch=1'b0;
    Jump=1'b0;
    JALR=1'b0;
    ALUOp=2'b00;
    case(Op)
      `OPC_LUI: begin RegWrite=1'b1; ImmSrc=3'b011; ALUSrc=1'b1; ResultSrc=`WB_ALU; end
      `OPC_AUIPC: begin RegWrite=1'b1; ImmSrc=3'b011; ALUSrc=1'b1; ResultSrc=`WB_ALU; end
      `OPC_JAL: begin RegWrite=1'b1; ImmSrc=3'b100; Jump=1'b1; ResultSrc=`WB_PC4; end
      `OPC_JALR: begin RegWrite=1'b1; ImmSrc=3'b000; JALR=1'b1; ALUSrc=1'b1; ResultSrc=`WB_PC4; end
      `OPC_BRANCH: begin ImmSrc=3'b010; Branch=1'b1; ALUOp=2'b01; end
      `OPC_LOAD: begin RegWrite=1'b1; ImmSrc=3'b000; ALUSrc=1'b1; MemRead=1'b1; ResultSrc=`WB_MEM; end
      `OPC_STORE: begin ImmSrc=3'b001; ALUSrc=1'b1; MemWrite=1'b1; end
      `OPC_OPIMM: begin RegWrite=1'b1; ImmSrc=3'b000; ALUSrc=1'b1; ALUOp=2'b11; end
      `OPC_OP: begin RegWrite=1'b1; ALUOp=2'b10; end
      default: begin end
    endcase
  end
endmodule
