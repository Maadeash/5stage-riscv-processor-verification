`ifndef RV32I_COVERAGE_SV
`define RV32I_COVERAGE_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
import rv32i_pkg::*;

class rv32i_coverage extends uvm_subscriber #(rv32i_obs_item);
    `uvm_component_utils(rv32i_coverage)
    rv32i_obs_item obs;
    covergroup cg_opcode;
        cp_opcode: coverpoint obs.idex_op_obs {
            bins LUI    = {7'b0110111};
            bins AUIPC  = {7'b0010111};
            bins JAL    = {7'b1101111};
            bins JALR   = {7'b1100111};
            bins BRANCH = {7'b1100011};
            bins LOAD   = {7'b0000011};
            bins STORE  = {7'b0100011};
            bins OPIMM  = {7'b0010011};
            bins OP     = {7'b0110011};
            bins MISC   = {7'b0001111};
            bins SYSTEM = {7'b1110011};
        }
    endgroup
    covergroup cg_alu_ctrl;
        cp_aluctrl: coverpoint obs.idex_aluctrl_obs {
            bins ADD   = {4'd0};
            bins SUB   = {4'd1};
            bins AND   = {4'd2};
            bins OR    = {4'd3};
            bins XOR   = {4'd4};
            bins SLT   = {4'd5};
            bins SLTU  = {4'd6};
            bins PASSB = {4'd7};
            ignore_bins COPYA = {4'd8};
            bins SLL   = {4'd9};
            bins SRL   = {4'd10};
            bins SRA   = {4'd11};
        }
    endgroup
    covergroup cg_branch;
        cp_branch_funct3: coverpoint obs.idex_funct3_obs
            iff (obs.idex_op_obs == OPC_BRANCH) {
            bins BEQ  = {3'b000};
            bins BNE  = {3'b001};
            bins BLT  = {3'b100};
            bins BGE  = {3'b101};
            bins BLTU = {3'b110};
            bins BGEU = {3'b111};
        }
        cp_branch_taken: coverpoint obs.branch_taken {
            bins TAKEN     = {1'b1};
            bins NOT_TAKEN = {1'b0};
        }
        cx_branch: cross cp_branch_funct3, cp_branch_taken;
    endgroup
    covergroup cg_forwarding;
        cp_fwdA: coverpoint obs.fwdA_obs {
            bins NO_FWD   = {2'b00};
            bins EX_EX    = {2'b10};
            bins MEM_EX   = {2'b01};
        }
        cp_fwdB: coverpoint obs.fwdB_obs {
            bins NO_FWD   = {2'b00};
            bins EX_EX    = {2'b10};
            bins MEM_EX   = {2'b01};
        }
        cx_fwd: cross cp_fwdA, cp_fwdB{
    ignore_bins unreachable_ex_mem = binsof(cp_fwdA) intersect {2'b10} &&
                                      binsof(cp_fwdB) intersect {2'b01};
    }
    endgroup
    covergroup cg_wb_src;
        cp_wb_src: coverpoint obs.wb_src
            iff (obs.regwrite_wb) {
            bins ALU = {WB_ALU};
            bins MEM = {WB_MEM};
            bins PC4 = {WB_PC4};
            bins CSR = {WB_CSR};
        }
    endgroup
    covergroup cg_trap_cause;
        cp_cause: coverpoint obs.trap_cause_obs
            iff (obs.trap_detected) {
            bins INSN_MISALIGNED  = {CAUSE_INSN_MISALIGNED};
            bins ILLEGAL_INSN     = {CAUSE_ILLEGAL_INSN};
            bins BREAKPOINT       = {CAUSE_BREAKPOINT};
            bins LOAD_MISALIGNED  = {CAUSE_LOAD_MISALIGNED};
            bins STORE_MISALIGNED = {CAUSE_STORE_MISALIGNED};
            bins ECALL_MMODE      = {CAUSE_ECALL_MMODE};
            bins MTI              = {CAUSE_MTI};
        }
    endgroup
    covergroup cg_load_width;
        cp_load_f3: coverpoint obs.idex_funct3_obs
            iff (obs.idex_op_obs == OPC_LOAD) {
            bins LB  = {3'b000};
            bins LH  = {3'b001};
            bins LW  = {3'b010};
            bins LBU = {3'b100};
            bins LHU = {3'b101};
        }
    endgroup
    covergroup cg_store_width;
        cp_store_f3: coverpoint obs.idex_funct3_obs
            iff (obs.idex_op_obs == OPC_STORE) {
            bins SB = {3'b000};
            bins SH = {3'b001};
            bins SW = {3'b010};
        }
    endgroup
    covergroup cg_mem_alignment;
        cp_byte_lane: coverpoint obs.mem_addr[1:0]
            iff (obs.mem_write) {
            bins LANE_0 = {2'b00};
            bins LANE_1 = {2'b01};
            bins LANE_2 = {2'b10};
            bins LANE_3 = {2'b11};
        }
    endgroup
    covergroup cg_reg_addresses;
        cp_rd_wb: coverpoint obs.rd_wb
            iff (obs.regwrite_wb) {
            bins ZERO = {5'd0};
            bins RA   = {5'd1};
            bins SP   = {5'd2};
            bins regs[] = {[5'd3:5'd31]};
        }
    endgroup
    covergroup cg_csr_ops;
        cp_csrcmd: coverpoint obs.wb_src
            iff (obs.memwb_csrwrite) {
            bins RW  = {WB_CSR};
        }
    endgroup
    covergroup cg_rtype_funct3;
        cp_rtype_f3: coverpoint obs.idex_funct3_obs
            iff (obs.idex_op_obs == OPC_OP) {
            bins ADD_SUB = {3'b000};
            bins SLL     = {3'b001};
            bins SLT     = {3'b010};
            bins SLTU    = {3'b011};
            bins XOR     = {3'b100};
            bins SRL_SRA = {3'b101};
            bins OR      = {3'b110};
            bins AND     = {3'b111};
        }
    endgroup
    covergroup cg_itype_funct3;
        cp_itype_f3: coverpoint obs.idex_funct3_obs
            iff (obs.idex_op_obs == OPC_OPIMM) {
            bins ADDI  = {3'b000};
            bins SLTI  = {3'b010};
            bins SLTIU = {3'b011};
            bins XORI  = {3'b100};
            bins ORI   = {3'b110};
            bins ANDI  = {3'b111};
            bins SLLI  = {3'b001};
            bins SRI   = {3'b101};
        }
    endgroup
    covergroup cg_control_flow;
        cp_jal:  coverpoint obs.idex_op_obs {
            bins JAL  = {OPC_JAL};
            bins JALR = {OPC_JALR};
        }
        cp_redirect: coverpoint obs.pc_redirect {
            bins REDIRECT    = {1'b1};
            bins NO_REDIRECT = {1'b0};
        }
        cx_jump_redirect: cross cp_jal, cp_redirect;
    endgroup
    covergroup cg_pipeline_valid;
        cp_ifid_v:  coverpoint obs.trap_detected { bins TRAP={1'b1}; bins NORMAL={1'b0}; }
    endgroup

    function new(string name = "rv32i_coverage", uvm_component parent = null);
        super.new(name, parent);
        cg_opcode       = new();
        cg_alu_ctrl     = new();
        cg_branch       = new();
        cg_forwarding   = new();
        cg_wb_src       = new();
        cg_trap_cause   = new();
        cg_load_width   = new();
        cg_store_width  = new();
        cg_mem_alignment= new();
        cg_reg_addresses= new();
        cg_csr_ops      = new();
        cg_rtype_funct3 = new();
        cg_itype_funct3 = new();
        cg_control_flow = new();
        cg_pipeline_valid = new();
    endfunction

    function void write(rv32i_obs_item t);
        obs = t;
        cg_opcode.sample();
        cg_alu_ctrl.sample();
        cg_branch.sample();
        cg_forwarding.sample();
        cg_wb_src.sample();
        cg_trap_cause.sample();
        cg_load_width.sample();
        cg_store_width.sample();
        cg_mem_alignment.sample();
        cg_reg_addresses.sample();
        cg_csr_ops.sample();
        cg_rtype_funct3.sample();
        cg_itype_funct3.sample();
        cg_control_flow.sample();
        cg_pipeline_valid.sample();
    endfunction
    
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV", "COVERAGE SUMMARY:", UVM_NONE)
        `uvm_info("COV", $sformatf("Opcode        : %0.1f%%", cg_opcode.get_coverage()),       UVM_NONE)
        `uvm_info("COV", $sformatf("ALU Control   : %0.1f%%", cg_alu_ctrl.get_coverage()),     UVM_NONE)
        `uvm_info("COV", $sformatf("Branch×Taken  : %0.1f%%", cg_branch.get_coverage()),       UVM_NONE)
        `uvm_info("COV", $sformatf("Forwarding    : %0.1f%%", cg_forwarding.get_coverage()),   UVM_NONE)
        `uvm_info("COV", $sformatf("WB Source     : %0.1f%%", cg_wb_src.get_coverage()),       UVM_NONE)
        `uvm_info("COV", $sformatf("Trap Cause    : %0.1f%%", cg_trap_cause.get_coverage()),   UVM_NONE)
        `uvm_info("COV", $sformatf("Load Width    : %0.1f%%", cg_load_width.get_coverage()),   UVM_NONE)
        `uvm_info("COV", $sformatf("Store Width   : %0.1f%%", cg_store_width.get_coverage()),  UVM_NONE)
        `uvm_info("COV", $sformatf("Mem Alignment : %0.1f%%", cg_mem_alignment.get_coverage()),UVM_NONE)
        `uvm_info("COV", $sformatf("Reg Addresses : %0.1f%%", cg_reg_addresses.get_coverage()),UVM_NONE)
        `uvm_info("COV", $sformatf("R-type f3     : %0.1f%%", cg_rtype_funct3.get_coverage()), UVM_NONE)
        `uvm_info("COV", $sformatf("I-type f3     : %0.1f%%", cg_itype_funct3.get_coverage()), UVM_NONE)
        `uvm_info("COV", $sformatf("Control Flow  : %0.1f%%", cg_control_flow.get_coverage()), UVM_NONE)
    endfunction
endclass : rv32i_coverage

`endif
