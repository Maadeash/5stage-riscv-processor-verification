
`ifndef RV32I_PKG_SV
`define RV32I_PKG_SV

package rv32i_pkg;

    localparam logic [6:0] OPC_LUI    = 7'b0110111;
    localparam logic [6:0] OPC_AUIPC  = 7'b0010111;
    localparam logic [6:0] OPC_JAL    = 7'b1101111;
    localparam logic [6:0] OPC_JALR   = 7'b1100111;
    localparam logic [6:0] OPC_BRANCH = 7'b1100011;
    localparam logic [6:0] OPC_LOAD   = 7'b0000011;
    localparam logic [6:0] OPC_STORE  = 7'b0100011;
    localparam logic [6:0] OPC_OPIMM  = 7'b0010011;
    localparam logic [6:0] OPC_OP     = 7'b0110011;
    localparam logic [6:0] OPC_MISC   = 7'b0001111;
    localparam logic [6:0] OPC_SYSTEM = 7'b1110011;

    localparam logic [3:0] ALU_ADD   = 4'd0;
    localparam logic [3:0] ALU_SUB   = 4'd1;
    localparam logic [3:0] ALU_AND   = 4'd2;
    localparam logic [3:0] ALU_OR    = 4'd3;
    localparam logic [3:0] ALU_XOR   = 4'd4;
    localparam logic [3:0] ALU_SLT   = 4'd5;
    localparam logic [3:0] ALU_SLTU  = 4'd6;
    localparam logic [3:0] ALU_PASSB = 4'd7;
    localparam logic [3:0] ALU_COPYA = 4'd8;
    localparam logic [3:0] ALU_SLL   = 4'd9;
    localparam logic [3:0] ALU_SRL   = 4'd10;
    localparam logic [3:0] ALU_SRA   = 4'd11;

    localparam logic [1:0] WB_ALU = 2'd0;
    localparam logic [1:0] WB_MEM = 2'd1;
    localparam logic [1:0] WB_PC4 = 2'd2;
    localparam logic [1:0] WB_CSR = 2'd3;

    localparam logic [1:0] CSR_NONE = 2'd0;
    localparam logic [1:0] CSR_RW   = 2'd1;
    localparam logic [1:0] CSR_RS   = 2'd2;
    localparam logic [1:0] CSR_RC   = 2'd3;

    localparam logic [31:0] CAUSE_INSN_MISALIGNED  = 32'd0;
    localparam logic [31:0] CAUSE_ILLEGAL_INSN     = 32'd2;
    localparam logic [31:0] CAUSE_BREAKPOINT       = 32'd3;
    localparam logic [31:0] CAUSE_LOAD_MISALIGNED  = 32'd4;
    localparam logic [31:0] CAUSE_STORE_MISALIGNED = 32'd6;
    localparam logic [31:0] CAUSE_ECALL_MMODE      = 32'd11;
    localparam logic [31:0] CAUSE_MTI              = 32'h80000007;

    localparam logic [11:0] CSR_MSTATUS = 12'h300;
    localparam logic [11:0] CSR_MIE     = 12'h304;
    localparam logic [11:0] CSR_MTVEC   = 12'h305;
    localparam logic [11:0] CSR_MEPC    = 12'h341;
    localparam logic [11:0] CSR_MCAUSE  = 12'h342;
    localparam logic [11:0] CSR_MTVAL   = 12'h343;
    localparam logic [11:0] CSR_MIP     = 12'h344;

    typedef enum logic [3:0] {
        INSTR_R    = 4'd0,
        INSTR_I    = 4'd1,
        INSTR_S    = 4'd2,
        INSTR_B    = 4'd3,
        INSTR_U    = 4'd4,
        INSTR_J    = 4'd5,
        INSTR_CSR  = 4'd6,
        INSTR_SYS  = 4'd7,
        INSTR_LOAD = 4'd8,
        INSTR_NOP  = 4'd9,
        INSTR_ILL  = 4'd10
    } instr_type_e;

endpackage : rv32i_pkg

`endif
