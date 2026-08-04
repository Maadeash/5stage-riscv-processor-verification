
`include "rv32i_defs.v"
module Control_Unit_Top(
    input  [31:0] InstrD,
    output RegWrite,
    output [2:0] ImmSrc,
    output ALUSrc,
    output MemWrite,
    output MemRead,
    output [1:0] ResultSrc,
    output Branch,
    output Jump,
    output JALR,
    output [3:0] ALUControl,
    output [1:0] CSRCmd,
    output CSRWrite,
    output Mret,
    output Ecall,
    output Ebreak,
    output Illegal,
    output [2:0] Funct3,
    output [6:0] Op
);
    wire main_RegWrite, main_ALUSrc, main_MemWrite, main_MemRead, main_Branch, main_Jump, main_JALR;
    wire [2:0] main_ImmSrc;
    wire [1:0] main_ResultSrc, main_ALUOp;
    wire [3:0] alu_ctl;
    wire [6:0] funct7 = InstrD[31:25];
    assign Funct3 = InstrD[14:12];
    assign Op = InstrD[6:0];

    Main_Decoder u_dec(
        .Op(Op), .RegWrite(main_RegWrite), .ImmSrc(main_ImmSrc), .ALUSrc(main_ALUSrc), .MemWrite(main_MemWrite),
        .MemRead(main_MemRead), .ResultSrc(main_ResultSrc), .Branch(main_Branch), .Jump(main_Jump), .JALR(main_JALR), .ALUOp(main_ALUOp)
    );
    ALU_Decoder u_alu(
        .ALUOp(main_ALUOp), .funct3(Funct3), .funct7(funct7), .op(Op), .ALUControl(alu_ctl)
    );

    reg csr_we_r, ecall_r, ebreak_r, mret_r, illegal_r;
    reg [1:0] csr_cmd_r;
    always @* begin
        csr_we_r = 1'b0;
        csr_cmd_r = `CSR_NONE;
        ecall_r = 1'b0;
        ebreak_r = 1'b0;
        mret_r = 1'b0;
        illegal_r = 1'b0;
        if (Op == `OPC_SYSTEM) begin
            case (Funct3)
                `F3_PRIV: begin
                    case (InstrD[31:20])
                        12'h000: ecall_r = 1'b1;
                        12'h001: ebreak_r = 1'b1;
                        12'h302: mret_r = 1'b1;
                        default: illegal_r = 1'b1;
                    endcase
                end
                `F3_CSRRW, `F3_CSRRWI: begin csr_we_r = 1'b1; csr_cmd_r = `CSR_RW; end
                `F3_CSRRS, `F3_CSRRSI: begin csr_we_r = 1'b1; csr_cmd_r = `CSR_RS; end
                `F3_CSRRC, `F3_CSRRCI: begin csr_we_r = 1'b1; csr_cmd_r = `CSR_RC; end
                default: illegal_r = 1'b1;
            endcase
        end else if (!(Op == `OPC_LUI || Op == `OPC_AUIPC || Op == `OPC_JAL || Op == `OPC_JALR ||
                       Op == `OPC_BRANCH || Op == `OPC_LOAD || Op == `OPC_STORE || Op == `OPC_OPIMM || Op == `OPC_OP || Op == `OPC_MISC)) begin
            illegal_r = 1'b1;
        end

        if (Op == `OPC_OPIMM) begin
            if (!(Funct3 == 3'b000 || Funct3 == 3'b010 || Funct3 == 3'b011 || Funct3 == 3'b100 || Funct3 == 3'b110 || Funct3 == 3'b111 || Funct3 == 3'b001 || Funct3 == 3'b101)) illegal_r = 1'b1;
        end
        if (Op == `OPC_OP) begin
            if (!(Funct3 == 3'b000 || Funct3 == 3'b111 || Funct3 == 3'b110 || Funct3 == 3'b100 || Funct3 == 3'b010 || Funct3 == 3'b011 || Funct3 == 3'b001 || Funct3 == 3'b101)) illegal_r = 1'b1;
        end
    end

    assign RegWrite  = main_RegWrite | csr_we_r;
    assign ImmSrc    = main_ImmSrc;
    assign ALUSrc    = main_ALUSrc;
    assign MemWrite  = main_MemWrite;
    assign MemRead   = main_MemRead;
    assign ResultSrc = (Op == `OPC_SYSTEM && Funct3 != `F3_PRIV) ? `WB_CSR : main_ResultSrc;
    assign Branch    = main_Branch;
    assign Jump      = main_Jump;
    assign JALR      = main_JALR;
    assign ALUControl= (Op == `OPC_LUI) ? `ALU_PASSB : (Op == `OPC_AUIPC) ? `ALU_ADD : alu_ctl;
    assign CSRCmd    = csr_cmd_r;
    assign CSRWrite  = csr_we_r;
    assign Mret      = mret_r;
    assign Ecall     = ecall_r;
    assign Ebreak    = ebreak_r;
    assign Illegal   = illegal_r;
endmodule
