




























`ifndef RV32I_SEQUENCE_LIB_SV
`define RV32I_SEQUENCE_LIB_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import rv32i_pkg::*;













function automatic [31:0] rtype;
    input [6:0] funct7;
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] funct3;
    input [4:0] rd;
    input [6:0] opcode;
begin
    rtype = {funct7, rs2, rs1, funct3, rd, opcode};
end
endfunction


function automatic [31:0] itype;
    input [11:0] imm;
    input [4:0] rs1;
    input [2:0] funct3;
    input [4:0] rd;
    input [6:0] opcode;
begin
    itype = {imm, rs1, funct3, rd, opcode};
end
endfunction


function automatic [31:0] stype;
    input [11:0] imm;
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] funct3;
    input [6:0] opcode;
begin
    stype = {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
end
endfunction


function automatic [31:0] btype;
    input [12:0] imm;
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] funct3;
    input [6:0] opcode;
begin
    btype = {imm[12], imm[10:5], rs2, rs1, funct3,
             imm[4:1], imm[11], opcode};
end
endfunction


function automatic [31:0] utype;
    input [19:0] imm;
    input [4:0] rd;
    input [6:0] opcode;
begin
    utype = {imm, rd, opcode};
end
endfunction


function automatic [31:0] jtype;
    input [20:0] imm;
    input [4:0] rd;
    input [6:0] opcode;
begin
    jtype = {imm[20], imm[10:1], imm[11],
             imm[19:12], rd, opcode};
end
endfunction

function automatic [31:0] csr_reg;
    input [11:0] csr;
    input [4:0] rs1;
    input [2:0] funct3;
    input [4:0] rd;
begin
    csr_reg = {csr, rs1, funct3, rd, 7'b1110011};
end
endfunction

function automatic [31:0] csr_imm;
    input [11:0] csr;
    input [4:0] uimm;
    input [2:0] funct3;
    input [4:0] rd;
begin
    csr_imm = {csr, uimm, funct3, rd, 7'b1110011};
end
endfunction





`define NOP        32'h00000013
`define ECALL      32'h00000073
`define EBREAK     32'h00100073
`define MRET       32'h30200073
`define ILLEGAL    32'hFFFFFFFF


`define ADD(rd,rs1,rs2)    rtype(7'b0000000,rs2,rs1,3'b000,rd,7'b0110011)
`define SUB(rd,rs1,rs2)    rtype(7'b0100000,rs2,rs1,3'b000,rd,7'b0110011)
`define SLL(rd,rs1,rs2)    rtype(7'b0000000,rs2,rs1,3'b001,rd,7'b0110011)
`define SLT(rd,rs1,rs2)    rtype(7'b0000000,rs2,rs1,3'b010,rd,7'b0110011)
`define SLTU(rd,rs1,rs2)   rtype(7'b0000000,rs2,rs1,3'b011,rd,7'b0110011)
`define XOR(rd,rs1,rs2)    rtype(7'b0000000,rs2,rs1,3'b100,rd,7'b0110011)
`define SRL(rd,rs1,rs2)    rtype(7'b0000000,rs2,rs1,3'b101,rd,7'b0110011)
`define SRA(rd,rs1,rs2)    rtype(7'b0100000,rs2,rs1,3'b101,rd,7'b0110011)
`define OR(rd,rs1,rs2)     rtype(7'b0000000,rs2,rs1,3'b110,rd,7'b0110011)
`define AND(rd,rs1,rs2)    rtype(7'b0000000,rs2,rs1,3'b111,rd,7'b0110011)


`define ADDI(rd,rs1,imm)   itype(imm,rs1,3'b000,rd,7'b0010011)
`define SLTI(rd,rs1,imm)   itype(imm,rs1,3'b010,rd,7'b0010011)
`define SLTIU(rd,rs1,imm)  itype(imm,rs1,3'b011,rd,7'b0010011)
`define XORI(rd,rs1,imm)   itype(imm,rs1,3'b100,rd,7'b0010011)
`define ORI(rd,rs1,imm)    itype(imm,rs1,3'b110,rd,7'b0010011)
`define ANDI(rd,rs1,imm)   itype(imm,rs1,3'b111,rd,7'b0010011)

`define SLLI(rd,rs1,shmt)  itype({7'b0000000,shmt},rs1,3'b001,rd,7'b0010011)
`define SRLI(rd,rs1,shmt)  itype({7'b0000000,shmt},rs1,3'b101,rd,7'b0010011)
`define SRAI(rd,rs1,shmt)  itype({7'b0100000,shmt},rs1,3'b101,rd,7'b0010011)


`define LB(rd,rs1,imm)     itype(imm,rs1,3'b000,rd,7'b0000011)
`define LH(rd,rs1,imm)     itype(imm,rs1,3'b001,rd,7'b0000011)
`define LW(rd,rs1,imm)     itype(imm,rs1,3'b010,rd,7'b0000011)
`define LBU(rd,rs1,imm)    itype(imm,rs1,3'b100,rd,7'b0000011)
`define LHU(rd,rs1,imm)    itype(imm,rs1,3'b101,rd,7'b0000011)


`define SB(rs2,rs1,imm)    stype(imm,rs2,rs1,3'b000,7'b0100011)
`define SH(rs2,rs1,imm)    stype(imm,rs2,rs1,3'b001,7'b0100011)
`define SW(rs2,rs1,imm)    stype(imm,rs2,rs1,3'b010,7'b0100011)


`define BEQ(rs1,rs2,off)   btype(off,rs2,rs1,3'b000,7'b1100011)
`define BNE(rs1,rs2,off)   btype(off,rs2,rs1,3'b001,7'b1100011)
`define BLT(rs1,rs2,off)   btype(off,rs2,rs1,3'b100,7'b1100011)
`define BGE(rs1,rs2,off)   btype(off,rs2,rs1,3'b101,7'b1100011)
`define BLTU(rs1,rs2,off)  btype(off,rs2,rs1,3'b110,7'b1100011)
`define BGEU(rs1,rs2,off)  btype(off,rs2,rs1,3'b111,7'b1100011)


`define LUI(rd,imm)        utype(imm,rd,7'b0110111)
`define AUIPC(rd,imm)      utype(imm,rd,7'b0010111)


`define JAL(rd,off)        jtype(off,rd,7'b1101111)
`define JALR(rd,rs1,imm)   itype(imm,rs1,3'b000,rd,7'b1100111)

`define CSRRW(rd,csr,rs1)   csr_reg(csr,rs1,3'b001,rd)
`define CSRRS(rd,csr,rs1)   csr_reg(csr,rs1,3'b010,rd)
`define CSRRC(rd,csr,rs1)   csr_reg(csr,rs1,3'b011,rd)

`define CSRRWI(rd,csr,ui)   csr_imm(csr,ui,3'b101,rd)
`define CSRRSI(rd,csr,ui)   csr_imm(csr,ui,3'b110,rd)
`define CSRRCI(rd,csr,ui)   csr_imm(csr,ui,3'b111,rd)




class rv32i_base_seq extends uvm_sequence #(rv32i_seq_item);
    `uvm_object_utils(rv32i_base_seq)


    rv32i_env env_h;

    function new(string name = "rv32i_base_seq");
        super.new(name);
    endfunction




    task load_program(logic [31:0] prog[], int n, bit has_irq = 1'b0);
        rv32i_seq_item item;
        for (int i = 0; i < n; i++) begin
            item = rv32i_seq_item::type_id::create($sformatf("item_%0d", i));
            start_item(item);
            item.instr_word = prog[i];
            item.imem_addr  = i * 4;
            item.rst_n      = 1'b1;
            item.timer_irq  = has_irq && (i == n-2);
            finish_item(item);
        end
    endtask




    task do_reset(int hold_cycles = 5);
        rv32i_seq_item item;
        repeat(hold_cycles) begin
            item = rv32i_seq_item::type_id::create("rst_item");
            start_item(item);
            item.rst_n      = 1'b0;
            item.timer_irq  = 1'b0;
            item.instr_word = `NOP;
            item.imem_addr  = 32'd0;
            finish_item(item);
        end
        `uvm_info(get_name(), "Reset sequence complete", UVM_MEDIUM)
    endtask




    task wait_drain(int cycles = 15);
        rv32i_seq_item item;
        repeat(cycles) begin
            item = rv32i_seq_item::type_id::create("drain");
            start_item(item);
            item.instr_word = `NOP;
            item.imem_addr  = 32'd252;
            item.rst_n      = 1'b1;
            item.timer_irq  = 1'b0;
            finish_item(item);
        end
    endtask

endclass : rv32i_base_seq




class rv32i_reset_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_reset_seq)
    function new(string name = "rv32i_reset_seq"); super.new(name); endfunction

    task body();
        `uvm_info(get_name(), "=== Reset Sequence START ===", UVM_MEDIUM)
        do_reset(8);
        `uvm_info(get_name(), "=== Reset Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_reset_seq




class rv32i_smoke_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_smoke_seq)
    function new(string name = "rv32i_smoke_seq"); super.new(name); endfunction

        task body();
        rv32i_seq_item item;
        logic [31:0] prog[];


        prog = '{
		32'h0000000F,
    	`ADDI (5'd1,5'd0,12'd5),
    	`ADDI (5'd2,5'd0,12'd7),
    	`ADD  (5'd3,5'd1,5'd2),
    	`SW   (5'd3,5'd0,12'd0),
    	`LW   (5'd4,5'd0,12'd0),
    	`ECALL,
    	`NOP,
    	`NOP,
    	`NOP
	};

        `uvm_info(get_name(), "=== Smoke Sequence START ===", UVM_MEDIUM)
        do_reset(5);

        if (env_h != null) begin
            env_h.expect_wb(5'd1, 32'd5,   32'd0,  "ADDI x1=5");
            env_h.expect_wb(5'd2, 32'd7,   32'd4,  "ADDI x2=7");
            env_h.expect_wb(5'd3, 32'd12,  32'd8,  "ADD x3=12");

            env_h.expect_wb(5'd4, 32'd12,  32'd16, "LW x4=12");
        end

        load_program(prog, prog.size());
        wait_drain(20);
        `uvm_info(get_name(), "=== Smoke Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_smoke_seq




class rv32i_alu_r_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_alu_r_seq)
    function new(string name = "rv32i_alu_r_seq"); super.new(name); endfunction

    task body();

        logic [31:0] prog[];
        prog = '{
            `ADDI(5'd1, 5'd0, 12'd10),
            `ADDI(5'd2, 5'd0, 12'd3),
            `ADD (5'd3, 5'd1, 5'd2),
            `SUB (5'd4, 5'd1, 5'd2),
            `AND (5'd5, 5'd1, 5'd2),
            `OR  (5'd6, 5'd1, 5'd2),
            `XOR (5'd7, 5'd1, 5'd2),
            `SLL (5'd8, 5'd1, 5'd2),
            `SRL (5'd8, 5'd8, 5'd2),
            `SRA (5'd9, 5'd1, 5'd2),
            `SLT (5'd10, 5'd2, 5'd1),
            `SLTU(5'd11, 5'd2, 5'd1),
            `NOP, `NOP, `NOP
        };

        `uvm_info(get_name(), "=== ALU R-type Sequence START ===", UVM_MEDIUM)
        do_reset(5);

        if (env_h != null) begin
            env_h.expect_wb(5'd1,  32'd10, 32'd0,  "ADDI x1=10");
            env_h.expect_wb(5'd2,  32'd3,  32'd4,  "ADDI x2=3");
            env_h.expect_wb(5'd3,  32'd13, 32'd8,  "ADD");
            env_h.expect_wb(5'd4,  32'd7,  32'd12, "SUB");
            env_h.expect_wb(5'd5,  32'd2,  32'd16, "AND");
            env_h.expect_wb(5'd6,  32'd11, 32'd20, "OR");
            env_h.expect_wb(5'd7,  32'd9,  32'd24, "XOR");
            env_h.expect_wb(5'd8,  32'd80, 32'd28, "SLL");
            env_h.expect_wb(5'd8,  32'd10, 32'd32, "SRL");
            env_h.expect_wb(5'd9,  32'd1,  32'd36, "SRA");
            env_h.expect_wb(5'd10, 32'd1,  32'd40, "SLT");
            env_h.expect_wb(5'd11, 32'd1,  32'd44, "SLTU");
        end

        load_program(prog, prog.size());
        wait_drain(30);
        `uvm_info(get_name(), "=== ALU R-type Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_alu_r_seq




class rv32i_alu_i_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_alu_i_seq)
    function new(string name = "rv32i_alu_i_seq"); super.new(name); endfunction

    task body();
        logic [31:0] prog[];
        prog = '{
            `ADDI (5'd1, 5'd0, 12'd100),
            `ANDI (5'd2, 5'd1, 12'hF0F),
            `ORI  (5'd3, 5'd1, 12'hFF),
            `XORI (5'd4, 5'd1, 12'hFF),
            `SLTI (5'd5, 5'd1, 12'd101),
            `SLTIU(5'd6, 5'd1, 12'd99),
            `SLLI (5'd7, 5'd1, 5'd2),
            `SRLI (5'd7, 5'd7, 5'd2),
            `SRAI (5'd8, 5'd1, 5'd1),
            `NOP, `NOP, `NOP
        };

        `uvm_info(get_name(), "=== ALU I-type Sequence START ===", UVM_MEDIUM)
        do_reset(5);

        if (env_h != null) begin
            env_h.expect_wb(5'd1, 32'd100, 32'd0,  "ADDI");
            env_h.expect_wb(5'd2, 32'd4,   32'd4,  "ANDI");
            env_h.expect_wb(5'd3, 32'd255, 32'd8,  "ORI");
            env_h.expect_wb(5'd4, 32'd155, 32'd12, "XORI");
            env_h.expect_wb(5'd5, 32'd1,   32'd16, "SLTI");
            env_h.expect_wb(5'd6, 32'd0,   32'd20, "SLTIU");
            env_h.expect_wb(5'd7, 32'd400, 32'd24, "SLLI");
            env_h.expect_wb(5'd7, 32'd100, 32'd28, "SRLI");
            env_h.expect_wb(5'd8, 32'd50,  32'd32, "SRAI");
        end

        load_program(prog, prog.size());
        wait_drain(25);
        `uvm_info(get_name(), "=== ALU I-type Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_alu_i_seq




class rv32i_lui_auipc_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_lui_auipc_seq)
    function new(string name = "rv32i_lui_auipc_seq"); super.new(name); endfunction

    task body();


        logic [31:0] prog[];
        prog = '{
            `LUI  (5'd1, 20'd1),
            `AUIPC(5'd2, 20'd1),
            `NOP, `NOP, `NOP
        };

        `uvm_info(get_name(), "=== LUI/AUIPC Sequence START ===", UVM_MEDIUM)
        do_reset(5);

        if (env_h != null) begin
            env_h.expect_wb(5'd1, 32'h00001000, 32'd0, "LUI");
            env_h.expect_wb(5'd2, 32'h00001004, 32'd4, "AUIPC");
        end

        load_program(prog, prog.size());
        wait_drain(15);
        `uvm_info(get_name(), "=== LUI/AUIPC Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_lui_auipc_seq




class rv32i_branch_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_branch_seq)
    function new(string name = "rv32i_branch_seq"); super.new(name); endfunction

    task body();








        logic [31:0] prog[];
        prog = '{

            `ADDI(5'd1, 5'd0, 12'd5),
            `ADDI(5'd2, 5'd0, 12'd5),
            `ADDI(5'd3, 5'd0, 12'd10),

            `BEQ(5'd1, 5'd2, 13'd8),
            `ADDI(5'd10, 5'd0, 12'd99),
            `NOP,

            `BNE(5'd1, 5'd2, 13'd8),
            `ADDI(5'd11, 5'd0, 12'd55),
            `NOP,

            `BLT(5'd1, 5'd3, 13'd8),
            `ADDI(5'd12, 5'd0, 12'd99),
            `NOP,

            `BGE(5'd3, 5'd1, 13'd8),
            `ADDI(5'd13, 5'd0, 12'd99),
            `NOP,

            `BLTU(5'd1, 5'd3, 13'd8),
            `ADDI(5'd14, 5'd0, 12'd99),
            `NOP,

            `BGEU(5'd3, 5'd1, 13'd8),
            `ADDI(5'd15, 5'd0, 12'd99),
            `NOP,
            `NOP, `NOP, `NOP
        };

        `uvm_info(get_name(), "=== Branch Sequence START ===", UVM_MEDIUM)
        do_reset(5);

        if (env_h != null) begin
            env_h.expect_wb(5'd1,  32'd5,  32'd0,  "ADDI x1=5");
            env_h.expect_wb(5'd2,  32'd5,  32'd4,  "ADDI x2=5");
            env_h.expect_wb(5'd3,  32'd10, 32'd8,  "ADDI x3=10");

            env_h.expect_wb(5'd11, 32'd55, 32'h1C, "ADDI x11=55 (BNE fallthrough)");
        end

        load_program(prog, prog.size());
        wait_drain(50);
        `uvm_info(get_name(), "=== Branch Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_branch_seq




class rv32i_jump_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_jump_seq)
    function new(string name = "rv32i_jump_seq"); super.new(name); endfunction

    task body();



        logic [31:0] prog[];
        prog = '{
            `JAL (5'd1, 21'd8),
            `ADDI(5'd10, 5'd0, 12'd99),
            `ADDI(5'd2,  5'd0, 12'd77),
            `JALR(5'd3,  5'd1, 12'd12),
            `ADDI(5'd4,  5'd0, 12'd55),
            `NOP, `NOP, `NOP
        };

        `uvm_info(get_name(), "=== Jump Sequence START ===", UVM_MEDIUM)
        do_reset(5);

        if (env_h != null) begin
            env_h.expect_wb(5'd1, 32'd4,   32'd0,  "JAL x1=PC+4");
            env_h.expect_wb(5'd2, 32'd77,  32'd8,  "ADDI x2=77");
            env_h.expect_wb(5'd3, 32'h10,  32'hC,  "JALR x3=PC+4");
            env_h.expect_wb(5'd4, 32'd55,  32'h10, "ADDI x4=55");
        end

        load_program(prog, prog.size());
        wait_drain(20);
        `uvm_info(get_name(), "=== Jump Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_jump_seq




class rv32i_forwarding_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_forwarding_seq)
    function new(string name = "rv32i_forwarding_seq"); super.new(name); endfunction

    task body();




        logic [31:0] prog[];
        prog = '{
            `ADDI(5'd1, 5'd0, 12'd10),
            `ADD (5'd2, 5'd1, 5'd0),
            `ADDI(5'd0, 5'd0, 12'd0),
            `ADD (5'd3, 5'd2, 5'd0),

            `ADDI(5'd4, 5'd0, 12'd5),
            `ADDI(5'd5, 5'd0, 12'd3),
            `ADD (5'd6, 5'd4, 5'd5),

            `ADDI(5'd18, 5'd0, 12'd3),
            `ADD (5'd19, 5'd18, 5'd18),

            `ADDI(5'd20, 5'd0, 12'd4),
            `ADDI(5'd21, 5'd0, 12'd5),
            `ADD (5'd22, 5'd21, 5'd20),

            `ADDI(5'd23, 5'd0, 12'd6),
            `ADDI(5'd24, 5'd0, 12'd7),
            `ADD (5'd0,  5'd23, 5'd23),
            `NOP, `NOP, `NOP
        };

        `uvm_info(get_name(), "=== Forwarding Sequence START ===", UVM_MEDIUM)
        do_reset(5);

        if (env_h != null) begin
            env_h.expect_wb(5'd1, 32'd10, 32'd0,  "ADDI x1=10");
            env_h.expect_wb(5'd2, 32'd10, 32'd4,  "ADD fwd x2=10");
            env_h.expect_wb(5'd3, 32'd10, 32'hC,  "ADD fwd x3=10");
            env_h.expect_wb(5'd4, 32'd5,  32'h10, "ADDI x4=5");
            env_h.expect_wb(5'd5, 32'd3,  32'h14, "ADDI x5=3");
            env_h.expect_wb(5'd6, 32'd8,  32'h18, "ADD fwd x6=8");
        end

        load_program(prog, prog.size());
        wait_drain(25);
        `uvm_info(get_name(), "=== Forwarding Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_forwarding_seq






class rv32i_loaduse_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_loaduse_seq)
    function new(string name = "rv32i_loaduse_seq"); super.new(name); endfunction

    task body();

        logic [31:0] prog[];
        prog = '{
            `ADDI(5'd1, 5'd0, 12'd42),
            `SW  (5'd1, 5'd0, 12'd0),
            `LW  (5'd2, 5'd0, 12'd0),
            `ADD (5'd3, 5'd2, 5'd0),
            `ADD (5'd4, 5'd2, 5'd2),
            `NOP, `NOP, `NOP
        };

        `uvm_info(get_name(), "=== Load-Use Stall Sequence START ===", UVM_MEDIUM)
        do_reset(5);

        if (env_h != null) begin
            env_h.expect_wb(5'd1, 32'd42,  32'd0, "ADDI x1=42");
            env_h.expect_wb(5'd2, 32'd42,  32'd8, "LW x2=42");
            env_h.expect_wb(5'd3, 32'd42,  32'hC, "ADD x3=42 (stall)");
            env_h.expect_wb(5'd4, 32'd84,  32'h10,"ADD x4=84");
        end

        load_program(prog, prog.size());
        wait_drain(25);
        `uvm_info(get_name(), "=== Load-Use Stall Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_loaduse_seq




class rv32i_loadstore_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_loadstore_seq)
    function new(string name = "rv32i_loadstore_seq"); super.new(name); endfunction

    task body();


        logic [31:0] prog[];
        prog = '{

            `LUI  (5'd1, 20'hDEADB),
            `ADDI (5'd1, 5'd1, 12'hEEF),
            `SW   (5'd1, 5'd0, 12'd0),
            `NOP,

            `LB   (5'd2, 5'd0, 12'd0),
            `LBU  (5'd3, 5'd0, 12'd0),
            `LBU  (5'd4, 5'd0, 12'd1),
            `LBU  (5'd5, 5'd0, 12'd2),
            `LBU  (5'd6, 5'd0, 12'd3),

            `LH   (5'd7, 5'd0, 12'd0),
            `LHU  (5'd8, 5'd0, 12'd0),
            `LHU  (5'd9, 5'd0, 12'd2),

            `ADDI (5'd10, 5'd0, 12'h0AB),
            `SB   (5'd10, 5'd0, 12'd4),
            `SB   (5'd10, 5'd0, 12'd5),
            `SB   (5'd10, 5'd0, 12'd6),
            `SB   (5'd10, 5'd0, 12'd7),

            `LUI  (5'd11, 20'h1),
            `ADDI (5'd11, 5'd11, 12'h234),
            `SH   (5'd11, 5'd0, 12'd8),
            `SH   (5'd11, 5'd0, 12'd10),
            `NOP, `NOP, `NOP
        };

        `uvm_info(get_name(), "=== Load/Store Width Sequence START ===", UVM_MEDIUM)
        do_reset(5);
        load_program(prog, prog.size());
        wait_drain(40);
        `uvm_info(get_name(), "=== Load/Store Width Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_loadstore_seq




class rv32i_memcover_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_memcover_seq)

    function new(string name = "rv32i_memcover_seq");
        super.new(name);
    endfunction

    task body();
        logic [31:0] prog[];

        prog = '{

            `LUI  (5'd1, 20'h12345),
            `ADDI (5'd1, 5'd1, 12'h678),
            `SW   (5'd1, 5'd0, 12'd0),


            `LB   (5'd2, 5'd0, 12'd0),
            `LBU  (5'd3, 5'd0, 12'd1),
            `LB   (5'd4, 5'd0, 12'd2),
            `LBU  (5'd5, 5'd0, 12'd3),
            `LH   (5'd6, 5'd0, 12'd0),
            `LHU  (5'd7, 5'd0, 12'd2),
            `LW   (5'd8, 5'd0, 12'd0),


            `ADDI (5'd9, 5'd0, 12'h0AA),
            `SB   (5'd9, 5'd0, 12'd0),
            `SB   (5'd9, 5'd0, 12'd1),
            `SB   (5'd9, 5'd0, 12'd2),
            `SB   (5'd9, 5'd0, 12'd3),

            `LUI  (5'd10, 20'h00001),
            `ADDI (5'd10, 5'd10, 12'h234),
            `SH   (5'd10, 5'd0, 12'd4),
            `SH   (5'd10, 5'd0, 12'd6),

            `LUI  (5'd11, 20'hABCDE),
            `ADDI (5'd11, 5'd11, 12'h123),
            `SW   (5'd11, 5'd0, 12'd8),

            `NOP, `NOP, `NOP
        };

        `uvm_info(get_name(), "=== Mem Cover Sequence START ===", UVM_MEDIUM)
        do_reset(5);
        load_program(prog, prog.size());
        wait_drain(45);
        `uvm_info(get_name(), "=== Mem Cover Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_memcover_seq




class rv32i_csr_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_csr_seq)
    function new(string name = "rv32i_csr_seq"); super.new(name); endfunction

    task body();

        logic [31:0] prog[];
        prog = '{

            `ADDI  (5'd1, 5'd0, 12'd64),
            `CSRRW (5'd2, CSR_MTVEC, 5'd1),

            `ADDI  (5'd3, 5'd0, 12'h80),
            `CSRRS (5'd4, CSR_MIE, 5'd3),

            `CSRRC (5'd5, CSR_MIE, 5'd3),

            `CSRRWI(5'd6, CSR_MSTATUS, 5'd8),

            `CSRRSI(5'd7, CSR_MSTATUS, 5'd8),

            `CSRRCI(5'd8, CSR_MSTATUS, 5'd8),
            `NOP, `NOP, `NOP
        };

        `uvm_info(get_name(), "=== CSR Sequence START ===", UVM_MEDIUM)
        do_reset(5);

        if (env_h != null) begin
            env_h.expect_wb(5'd1, 32'd64,  32'd0,  "ADDI x1=64");
            env_h.expect_wb(5'd2, 32'd0,   32'd4,  "CSRRW mtvec=64, x2=0");
            env_h.expect_wb(5'd3, 32'h80,  32'd8,  "ADDI x3=0x80");
            env_h.expect_wb(5'd4, 32'd0,   32'hC,  "CSRRS mie|=0x80, x4=0");
            env_h.expect_wb(5'd5, 32'h80,  32'h10, "CSRRC x5=0x80");
        end

        load_program(prog, prog.size());
        wait_drain(25);
        `uvm_info(get_name(), "=== CSR Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_csr_seq




class rv32i_trap_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_trap_seq)
    function new(string name = "rv32i_trap_seq"); super.new(name); endfunction

    task body();





        logic [31:0] prog[];
        prog = '{
            `ADDI  (5'd1, 5'd0, 12'h40),
            `CSRRW (5'd0, CSR_MTVEC, 5'd1),
            `ECALL,
            `NOP,
            `EBREAK,
            `NOP,
            `ILLEGAL,
            `NOP,
            `NOP, `NOP, `NOP, `NOP, `NOP, `NOP, `NOP, `NOP,
            `CSRRS (5'd5, CSR_MEPC, 5'd0),
            `ADDI  (5'd5, 5'd5, 12'd4),
            `CSRRW (5'd0, CSR_MEPC, 5'd5),
            `MRET
        };

        `uvm_info(get_name(), "=== Trap Sequence START ===", UVM_MEDIUM)
        do_reset(5);
        load_program(prog, prog.size());
        wait_drain(40);
        `uvm_info(get_name(), "=== Trap Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_trap_seq




class rv32i_irq_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_irq_seq)
    function new(string name = "rv32i_irq_seq"); super.new(name); endfunction

    task body();

	rv32i_seq_item item;
        logic [31:0] prog[];
        prog = '{
            `ADDI  (5'd1, 5'd0, 12'h80),
            `CSRRW (5'd0, CSR_MIE,     5'd1),
            `ADDI  (5'd2, 5'd0, 12'h8),
            `CSRRW (5'd0, CSR_MSTATUS, 5'd2),
            `ADDI  (5'd3, 5'd0, 12'd0),
            `NOP,
            `NOP, `NOP, `NOP, `NOP,
            `NOP, `NOP, `NOP, `NOP, `NOP,
            `NOP, `NOP, `NOP, `NOP, `NOP,
            `NOP, `NOP, `NOP, `NOP, `NOP
        };



        `uvm_info(get_name(), "=== IRQ Sequence START ===", UVM_MEDIUM)
        do_reset(5);


        for (int i = 0; i < prog.size(); i++) begin
            item = rv32i_seq_item::type_id::create($sformatf("irq_item_%0d", i));
            start_item(item);
            item.instr_word = prog[i];
            item.imem_addr  = i * 4;
            item.rst_n      = 1'b1;



            item.timer_irq  = (i >= 4) ? 1'b1 : 1'b0;
            finish_item(item);
        end

        wait_drain(40);
        `uvm_info(get_name(), "=== IRQ Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_irq_seq




class rv32i_reset_mid_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_reset_mid_seq)
    function new(string name = "rv32i_reset_mid_seq"); super.new(name); endfunction

    task body();
        rv32i_seq_item item;
        logic [31:0] prog[];
        prog = '{
            `ADDI(5'd1, 5'd0, 12'd100),
            `ADDI(5'd2, 5'd0, 12'd200),
            `ADD (5'd3, 5'd1, 5'd2),
            `NOP, `NOP
        };

        `uvm_info(get_name(), "=== Mid-Execution Reset Sequence START ===", UVM_MEDIUM)
        do_reset(5);


        for (int i = 0; i < 3; i++) begin
            item = rv32i_seq_item::type_id::create($sformatf("item_%0d", i));
            start_item(item);
            item.instr_word = prog[i];
            item.imem_addr  = i * 4;
            item.rst_n      = 1'b1;
            item.timer_irq  = 1'b0;
            finish_item(item);
        end


        `uvm_info(get_name(), "Asserting mid-execution reset", UVM_MEDIUM)
        do_reset(3);


        begin
            logic [31:0] prog2[];
            prog2 = '{
                `ADDI(5'd5, 5'd0, 12'd7),
                `ADDI(5'd6, 5'd0, 12'd8),
                `NOP, `NOP
            };
            if (env_h != null) begin
                env_h.reset_reference_model();
                env_h.expect_wb(5'd5, 32'd7, 32'd0, "POST-RST ADDI x5=7");
                env_h.expect_wb(5'd6, 32'd8, 32'd4, "POST-RST ADDI x6=8");
            end
            load_program(prog2, prog2.size());
        end

        wait_drain(15);
        `uvm_info(get_name(), "=== Mid-Execution Reset Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_reset_mid_seq




class rv32i_misalign_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_misalign_seq)
    function new(string name = "rv32i_misalign_seq"); super.new(name); endfunction

    task body();




        logic [31:0] prog[];
        prog = '{
            `ADDI(5'd1, 5'd0, 12'd0x40),
            `CSRRW(5'd0, CSR_MTVEC, 5'd1),
            `ADDI(5'd1, 5'd0, 12'd1),
            `LW  (5'd2, 5'd1, 12'd0),
            `NOP,
            `ADDI(5'd3, 5'd0, 12'd42),
            `SW  (5'd3, 5'd1, 12'd0),
            `NOP,
            `NOP, `NOP, `NOP, `NOP, `NOP, `NOP, `NOP, `NOP,
            `CSRRS(5'd5, CSR_MEPC, 5'd0),
            `ADDI (5'd5, 5'd5, 12'd4),
            `CSRRW(5'd0, CSR_MEPC, 5'd5),
            `MRET
        };

        `uvm_info(get_name(), "=== Misalign Trap Sequence START ===", UVM_MEDIUM)
        do_reset(5);
        load_program(prog, prog.size());
        wait_drain(40);
        `uvm_info(get_name(), "=== Misalign Trap Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_misalign_seq






class rv32i_random_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_random_seq)


    rand int unsigned num_instrs;
    constraint c_num { num_instrs inside {[20:60]}; }

    function new(string name = "rv32i_random_seq"); super.new(name); endfunction

    task body();
        rv32i_seq_item item;
        `uvm_info(get_name(), $sformatf("=== Random Sequence START (%0d instrs) ===", num_instrs), UVM_MEDIUM)
        do_reset(5);

        for (int i = 0; i < num_instrs; i++) begin
            item = rv32i_seq_item::type_id::create($sformatf("rand_item_%0d", i));
            start_item(item);
            if (!item.randomize() with {
                rst_n == 1'b1;
                timer_irq dist {1'b0 := 95, 1'b1 := 5};

                instr_word[6:0] inside {
                    7'b0110111,
                    7'b0010111,
                    7'b1101111,
                    7'b1100011,
                    7'b0000011,
                    7'b0100011,
                    7'b0010011,
                    7'b0110011
                };
                imem_addr == i * 4;
            }) `uvm_error(get_name(), "Randomization failed")
            finish_item(item);
        end

        wait_drain(30);
        `uvm_info(get_name(), "=== Random Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_random_seq






class rv32i_covclose_seq extends rv32i_base_seq;
    `uvm_object_utils(rv32i_covclose_seq)
    function new(string name = "rv32i_covclose_seq"); super.new(name); endfunction

    task body();
        logic [31:0] prog[];
        prog = '{
            `ADDI(5'd9,  5'd0, 12'd5),
			`ADDI(5'd10, 5'd0, 12'd7),
			`ADD (5'd11, 5'd10, 5'd9),


            `ADDI(5'd1, 5'd0, 12'd24),
            `CSRRW(5'd0, CSR_MTVEC, 5'd1),
            `JAL(5'd0, 21'd20),
            `CSRRS(5'd2, CSR_MEPC, 5'd0),
            `ADDI (5'd2, 5'd2, 12'd4),
            `CSRRW(5'd0, CSR_MEPC, 5'd2),
            `MRET,
			`ADDI(5'd28, 5'd0, 12'd15),
            `ADDI(5'd29, 5'd0, 12'd25),
            `ADD (5'd0,  5'd29, 5'd28),
            `ILLEGAL,
            `ADDI(5'd2, 5'd0, 12'd1),
            `SW  (5'd2, 5'd2, 12'd0),
            `NOP,

			`NOP, `NOP, `NOP,
            `ADDI(5'd26, 5'd0, 12'd50),
            `ADDI(5'd27, 5'd0, 12'd60),
            `ADD (5'd0,  5'd27, 5'd26),
            `NOP,


            `ADDI(5'd1, 5'd0, 12'd5),
            `ADDI(5'd2, 5'd0, 12'd7),
            `ADDI(5'd3, 5'd0, 12'd10),
            `BEQ(5'd1, 5'd2, 13'd8),
            `ADDI(5'd20, 5'd0, 12'd111),
            `NOP,
            `BNE(5'd1, 5'd2, 13'd8),
            `ADDI(5'd21, 5'd0, 12'd222),
            `NOP,
            `BLT(5'd3, 5'd1, 13'd8),
            `ADDI(5'd22, 5'd0, 12'd111),
            `NOP,
            `BGE(5'd1, 5'd3, 13'd8),
            `ADDI(5'd23, 5'd0, 12'd111),
            `NOP,
            `BLTU(5'd3, 5'd1, 13'd8),
            `ADDI(5'd24, 5'd0, 12'd111),
            `NOP,
            `BGEU(5'd1, 5'd3, 13'd8),
            `ADDI(5'd25, 5'd0, 12'd111),
            `NOP,


            `ADDI(5'd6, 5'd0, 12'd9),
            `ADD (5'd7, 5'd0, 5'd6),
            `NOP,
            `ADD (5'd8, 5'd0, 5'd7),


            `ADDI(5'd9,  5'd0, 12'd5),
            `ADDI(5'd10, 5'd0, 12'd7),
            `ADD (5'd11, 5'd10, 5'd9),


            `ADDI(5'd12, 5'd0, 12'd11),
            `ADDI(5'd13, 5'd0, 12'd13),
            `ADD (5'd14, 5'd12, 5'd13),


            `ADDI(5'd15, 5'd0, 12'd17),
            `NOP,
            `ADD (5'd16, 5'd15, 5'd15),


            `ADDI(5'd16, 5'd0, 12'd16),
            `ADDI(5'd17, 5'd0, 12'd17),
            `ADDI(5'd18, 5'd0, 12'd18),
            `ADDI(5'd19, 5'd0, 12'd19),
            `ADDI(5'd20, 5'd0, 12'd20),
            `ADDI(5'd21, 5'd0, 12'd21),
            `ADDI(5'd22, 5'd0, 12'd22),
            `ADDI(5'd23, 5'd0, 12'd23),
            `ADDI(5'd24, 5'd0, 12'd24),
            `ADDI(5'd25, 5'd0, 12'd25),
            `ADDI(5'd26, 5'd0, 12'd26),
            `ADDI(5'd27, 5'd0, 12'd27),
            `ADDI(5'd28, 5'd0, 12'd28),
            `ADDI(5'd29, 5'd0, 12'd29),
            `ADDI(5'd30, 5'd0, 12'd30),
            `ADDI(5'd31, 5'd0, 12'd31),


            `JAL(5'd0, 21'd2),
            `NOP
        };

        `uvm_info(get_name(), "=== Coverage Closure Sequence START ===", UVM_MEDIUM)
        do_reset(5);
        load_program(prog, prog.size());
        wait_drain(250);
        `uvm_info(get_name(), "=== Coverage Closure Sequence DONE ===", UVM_MEDIUM)
    endtask
endclass : rv32i_covclose_seq




`endif
