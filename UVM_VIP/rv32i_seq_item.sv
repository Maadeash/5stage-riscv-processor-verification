`ifndef RV32I_SEQ_ITEM_SV
`define RV32I_SEQ_ITEM_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
import rv32i_pkg::*;

class rv32i_seq_item extends uvm_sequence_item;
    `uvm_object_utils_begin(rv32i_seq_item)
        `uvm_field_int(instr_word,    UVM_ALL_ON)
        `uvm_field_int(imem_addr,     UVM_ALL_ON)
        `uvm_field_int(timer_irq,     UVM_ALL_ON)
        `uvm_field_int(rst_n,         UVM_ALL_ON)
        `uvm_field_int(exp_rd,        UVM_ALL_ON)
        `uvm_field_int(exp_rd_val,    UVM_ALL_ON)
        `uvm_field_int(exp_pc_next,   UVM_ALL_ON)
        `uvm_field_int(exp_mem_addr,  UVM_ALL_ON)
        `uvm_field_int(exp_mem_wdata, UVM_ALL_ON)
        `uvm_field_int(exp_mem_write, UVM_ALL_ON)
        `uvm_field_int(exp_trap,      UVM_ALL_ON)
        `uvm_field_int(exp_trap_cause,UVM_ALL_ON)
    `uvm_object_utils_end
    
    rand logic [31:0] instr_word;
    rand logic [31:0] imem_addr;
    rand logic        timer_irq;
    rand logic        rst_n;
    logic [4:0]  exp_rd;
    logic [31:0] exp_rd_val;
    logic [31:0] exp_pc_next;
    logic [31:0] exp_mem_addr;
    logic [31:0] exp_mem_wdata;
    logic        exp_mem_write;
    logic        exp_trap;
    logic [31:0] exp_trap_cause;
    logic [6:0]  opcode;
    logic [4:0]  rs1, rs2, rd;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [31:0] imm;
    logic [11:0] csr_addr_bits;
    rv32i_pkg::instr_type_e itype;
    constraint c_timer_irq_low { timer_irq dist { 1'b0 := 90, 1'b1 := 10 }; }
    constraint c_no_random_reset { rst_n == 1'b1; }
    constraint c_imem_align { imem_addr[1:0] == 2'b00; }

    function new(string name = "rv32i_seq_item");
        super.new(name);
    endfunction
    
    function void decode();
        opcode    = instr_word[6:0];
        rd        = instr_word[11:7];
        funct3    = instr_word[14:12];
        rs1       = instr_word[19:15];
        rs2       = instr_word[24:20];
        funct7    = instr_word[31:25];
        csr_addr_bits = instr_word[31:20];

        case (opcode)
            rv32i_pkg::OPC_LUI:   begin itype = rv32i_pkg::INSTR_U;   imm = {instr_word[31:12], 12'd0}; end
            rv32i_pkg::OPC_AUIPC: begin itype = rv32i_pkg::INSTR_U;   imm = {instr_word[31:12], 12'd0}; end
            rv32i_pkg::OPC_JAL:   begin itype = rv32i_pkg::INSTR_J;
                imm = {{12{instr_word[31]}}, instr_word[19:12], instr_word[20], instr_word[30:21], 1'b0};
            end
            rv32i_pkg::OPC_JALR:  begin itype = rv32i_pkg::INSTR_I;   imm = {{20{instr_word[31]}}, instr_word[31:20]}; end
            rv32i_pkg::OPC_BRANCH:begin itype = rv32i_pkg::INSTR_B;
                imm = {{20{instr_word[31]}}, instr_word[7], instr_word[30:25], instr_word[11:8], 1'b0};
            end
            rv32i_pkg::OPC_LOAD:  begin itype = rv32i_pkg::INSTR_LOAD;imm = {{20{instr_word[31]}}, instr_word[31:20]}; end
            rv32i_pkg::OPC_STORE: begin itype = rv32i_pkg::INSTR_S;
                imm = {{20{instr_word[31]}}, instr_word[31:25], instr_word[11:7]};
            end
            rv32i_pkg::OPC_OPIMM: begin itype = rv32i_pkg::INSTR_I;   imm = {{20{instr_word[31]}}, instr_word[31:20]}; end
            rv32i_pkg::OPC_OP:    begin itype = rv32i_pkg::INSTR_R;   imm = 32'd0; end
            rv32i_pkg::OPC_SYSTEM:begin itype = rv32i_pkg::INSTR_CSR; imm = {{20{instr_word[31]}}, instr_word[31:20]}; end
            default:              begin itype = rv32i_pkg::INSTR_ILL;  imm = 32'd0; end
        endcase
    endfunction

    function void do_print(uvm_printer printer);
        super.do_print(printer);
        printer.print_field("instr_word", instr_word, 32, UVM_HEX);
        printer.print_field("imem_addr",  imem_addr,  32, UVM_DEC);
        printer.print_field("rst_n",      rst_n,       1, UVM_BIN);
        printer.print_field("timer_irq",  timer_irq,   1, UVM_BIN);
    endfunction
endclass : rv32i_seq_item
`endif
