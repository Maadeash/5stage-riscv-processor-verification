`ifndef RV32I_SCOREBOARD_SV
`define RV32I_SCOREBOARD_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
import rv32i_pkg::*;

class rv32i_expected_wb;
  logic [4:0]rd;
  logic [31:0]val;
  logic [31:0]pc;
  string instr_str;
  function new(logic [4:0]r,logic [31:0]v,logic [31:0]p,string s="");
    rd=r; val=v; pc=p; instr_str=s;
  endfunction
endclass:rv32i_expected_wb

class rv32i_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(rv32i_scoreboard)
  uvm_tlm_analysis_fifo #(rv32i_obs_item) wb_fifo;
  uvm_tlm_analysis_fifo #(rv32i_obs_item) mem_fifo;
  uvm_tlm_analysis_fifo #(rv32i_obs_item) trap_fifo;

  logic [31:0]rf [0:31];
  logic [31:0]csr_mstatus;
  logic [31:0]csr_mtvec;
  logic [31:0]csr_mepc;
  logic [31:0]csr_mcause;
  logic [31:0]csr_mtval;
  logic [31:0]csr_mie;
  logic [31:0]csr_mip;
  logic [31:0]dmem [0:255];
  int unsigned pass_count;
  int unsigned fail_count;
  int unsigned wb_checked;
  int unsigned mem_checked;
  int unsigned trap_checked;
  rv32i_expected_wb exp_wb_q[$];

  function new(string name="rv32i_scoreboard",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wb_fifo=new("wb_fifo",this);
    mem_fifo=new("mem_fifo",this);
    trap_fifo=new("trap_fifo",this);
    reset_model();
  endfunction

  function void reset_model();
    for(int i=0; i<32; i++) rf[i]=32'd0;
    csr_mstatus=32'd0; csr_mtvec=32'd0;
    csr_mepc=32'd0; csr_mcause=32'd0;
    csr_mtval=32'd0; csr_mie=32'd0;
    csr_mip=32'd0;
    for(int i=0; i<256; i++) dmem[i]=32'd0;
    exp_wb_q.delete();
  endfunction

  task run_phase(uvm_phase phase);
    rv32i_obs_item obs;
    fork
      forever begin
        wb_fifo.get(obs);
        check_wb(obs);
      end
      forever begin
        mem_fifo.get(obs);
        check_mem(obs);
      end
      forever begin
        trap_fifo.get(obs);
        check_trap(obs);
      end
    join
  endtask

  task check_wb(rv32i_obs_item obs);
    wb_checked++;
    if(obs.rd_wb==5'd0) begin
      if(obs.rd_val_wb!==32'd0) begin
        `uvm_error("SB_WB",$sformatf("x0 written non-zero! got=0x%08h",obs.rd_val_wb))
        fail_count++;
      end
      return;
    end
    if(exp_wb_q.size()>0) begin
      rv32i_expected_wb exp=exp_wb_q.pop_front();
      if(obs.rd_wb!==exp.rd) begin
        `uvm_error("SB_WB",$sformatf("[cyc=%0d] RD mismatch: DUT=x%0d, EXP=x%0d (%s)",
              obs.cycle,obs.rd_wb,exp.rd,exp.instr_str))
        fail_count++;
      end else if(obs.rd_val_wb!==exp.val) begin
        `uvm_error("SB_WB",$sformatf("[cyc=%0d] x%0d VALUE mismatch: DUT=0x%08h EXP=0x%08h (%s)",
              obs.cycle,obs.rd_wb,obs.rd_val_wb,exp.val,exp.instr_str))
        fail_count++;
      end else begin
        `uvm_info("SB_WB",$sformatf("[cyc=%0d] PASS: x%0d=0x%08h (%s)",
             obs.cycle,obs.rd_wb,obs.rd_val_wb,exp.instr_str),UVM_MEDIUM)
        pass_count++;

        rf[obs.rd_wb]=obs.rd_val_wb;
      end
    end else begin
      `uvm_info("SB_WB",$sformatf("[cyc=%0d] UNMATCHED WB: x%0d=0x%08h (no exp queued)",
           obs.cycle,obs.rd_wb,obs.rd_val_wb),UVM_HIGH)
      rf[obs.rd_wb]=obs.rd_val_wb;
    end
  endtask

  task check_mem(rv32i_obs_item obs);
    mem_checked++;
    if(obs.mem_write) begin
      if(obs.mem_funct3==3'b010&&obs.mem_addr[1:0]!==2'b00) begin
        `uvm_error("SB_MEM",$sformatf("SW to misaligned addr=0x%08h",obs.mem_addr))
        fail_count++;
        return;
      end
      if(obs.mem_funct3==3'b001&&obs.mem_addr[0]!==1'b0) begin
        `uvm_error("SB_MEM",$sformatf("SH to misaligned addr=0x%08h",obs.mem_addr))
        fail_count++;
        return;
      end
      update_shadow_mem(obs.mem_addr,obs.mem_wdata,obs.mem_funct3);
      `uvm_info("SB_MEM",$sformatf("Store f3=%03b addr=0x%08h data=0x%08h — PASS",
           obs.mem_funct3,obs.mem_addr,obs.mem_wdata),UVM_HIGH)
      pass_count++;
    end
  endtask

  task check_trap(rv32i_obs_item obs);
    trap_checked++;
    `uvm_info("SB_TRAP",$sformatf("Trap detected: cause=0x%08h",obs.trap_cause_obs),UVM_MEDIUM)
    case(obs.trap_cause_obs)
      CAUSE_INSN_MISALIGNED,
      CAUSE_ILLEGAL_INSN,
      CAUSE_BREAKPOINT,
      CAUSE_LOAD_MISALIGNED,
      CAUSE_STORE_MISALIGNED,
      CAUSE_ECALL_MMODE,
      CAUSE_MTI: begin
        pass_count++;
      end
      default: begin
        `uvm_error("SB_TRAP",$sformatf("Unknown trap cause: 0x%08h",obs.trap_cause_obs))
        fail_count++;
      end
    endcase
  endtask

  function void update_shadow_mem(logic [31:0]addr,logic [31:0]wdata,logic [2:0]f3);
    int wi=addr[9:2];
    case(f3)
      3'b000: begin
        case(addr[1:0])
          2'b00: dmem[wi][7:0]=wdata[7:0];
          2'b01: dmem[wi][15:8]=wdata[7:0];
          2'b10: dmem[wi][23:16]=wdata[7:0];
          2'b11: dmem[wi][31:24]=wdata[7:0];
        endcase
      end
      3'b001: begin
        if(addr[1]) dmem[wi][31:16]=wdata[15:0];
        else dmem[wi][15:0]=wdata[15:0];
      end
      default: dmem[wi]=wdata;
    endcase
  endfunction

  function automatic logic [31:0]ref_alu(
    input logic [31:0]a,b,
    input logic [3:0]ctrl
  );
    case(ctrl)
      ALU_ADD: return a+b;
      ALU_SUB: return a-b;
      ALU_AND: return a&b;
      ALU_OR: return a|b;
      ALU_XOR: return a^b;
      ALU_SLT: return($signed(a)<$signed(b))?32'd1:32'd0;
      ALU_SLTU: return(a<b)?32'd1:32'd0;
      ALU_PASSB:return b;
      ALU_COPYA:return a;
      ALU_SLL: return a<<b[4:0];
      ALU_SRL: return a>>b[4:0];
      ALU_SRA: return $signed(a)>>>b[4:0];
      default: return 32'd0;
    endcase
  endfunction

  function void expect_wb(logic [4:0]rd,logic [31:0]val,logic [31:0]pc,string s="");
    rv32i_expected_wb e=new(rd,val,pc,s);
    exp_wb_q.push_back(e);
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SB",$sformatf("WB  checks: %0d",wb_checked),UVM_NONE)
    `uvm_info("SB",$sformatf("MEM checks: %0d",mem_checked),UVM_NONE)
    `uvm_info("SB",$sformatf("TRP checks: %0d",trap_checked),UVM_NONE)
    `uvm_info("SB",$sformatf("PASS: %0d  FAIL: %0d",pass_count,fail_count),UVM_NONE)
    if(fail_count==0)
      `uvm_info("SB","ALL CHECKS PASSED",UVM_NONE)
    else
      `uvm_error("SB",$sformatf("%0d FAILURES DETECTED",fail_count))
  endfunction
endclass:rv32i_scoreboard
`endif
