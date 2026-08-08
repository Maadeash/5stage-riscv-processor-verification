`ifndef RV32I_MONITOR_SV
`define RV32I_MONITOR_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
import rv32i_pkg::*;
class rv32i_obs_item extends uvm_sequence_item;
  `uvm_object_utils_begin(rv32i_obs_item)
    `uvm_field_int(cycle,UVM_ALL_ON)
    `uvm_field_int(pc_wb,UVM_ALL_ON)
    `uvm_field_int(rd_wb,UVM_ALL_ON)
    `uvm_field_int(rd_val_wb,UVM_ALL_ON)
    `uvm_field_int(regwrite_wb,UVM_ALL_ON)
    `uvm_field_int(wb_src,UVM_ALL_ON)
    `uvm_field_int(mem_addr,UVM_ALL_ON)
    `uvm_field_int(mem_wdata,UVM_ALL_ON)
    `uvm_field_int(mem_write,UVM_ALL_ON)
    `uvm_field_int(mem_read,UVM_ALL_ON)
    `uvm_field_int(mem_funct3,UVM_ALL_ON)
    `uvm_field_int(trap_detected,UVM_ALL_ON)
    `uvm_field_int(trap_cause_obs,UVM_ALL_ON)
    `uvm_field_int(fwdA_obs,UVM_ALL_ON)
    `uvm_field_int(fwdB_obs,UVM_ALL_ON)
    `uvm_field_int(idex_op_obs,UVM_ALL_ON)
    `uvm_field_int(idex_funct3_obs,UVM_ALL_ON)
    `uvm_field_int(idex_aluctrl_obs,UVM_ALL_ON)
    `uvm_field_int(branch_taken,UVM_ALL_ON)
    `uvm_field_int(pc_redirect,UVM_ALL_ON)
    `uvm_field_int(redirect_target,UVM_ALL_ON)
    `uvm_field_int(memwb_csrwrite,UVM_ALL_ON)
  `uvm_object_utils_end

  longint unsigned cycle;
  logic memwb_csrwrite;
  logic [31:0]pc_wb;
  logic [4:0]rd_wb;
  logic [31:0]rd_val_wb;
  logic regwrite_wb;
  logic [1:0]wb_src;
  logic [31:0]mem_addr;
  logic [31:0]mem_wdata;
  logic mem_write;
  logic mem_read;
  logic [2:0]mem_funct3;
  logic trap_detected;
  logic [31:0]trap_cause_obs;
  logic [1:0]fwdA_obs;
  logic [1:0]fwdB_obs;
  logic [6:0]idex_op_obs;
  logic [2:0]idex_funct3_obs;
  logic [3:0]idex_aluctrl_obs;
  logic branch_taken;
  logic pc_redirect;
  logic [31:0]redirect_target;

  function new(string name="rv32i_obs_item");
    super.new(name);
  endfunction
endclass:rv32i_obs_item

class rv32i_monitor extends uvm_monitor;
  `uvm_component_utils(rv32i_monitor)
  virtual rv32i_if.MONITOR vif;
  uvm_analysis_port #(rv32i_obs_item) ap_wb;
  uvm_analysis_port #(rv32i_obs_item) ap_mem;
  uvm_analysis_port #(rv32i_obs_item) ap_trap;
  uvm_analysis_port #(rv32i_obs_item) ap_all;
  longint unsigned cycle_count;

  function new(string name="rv32i_monitor",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap_wb=new("ap_wb",this);
    ap_mem=new("ap_mem",this);
    ap_trap=new("ap_trap",this);
    ap_all=new("ap_all",this);
    if(!uvm_config_db #(virtual rv32i_if.MONITOR)::get(this,"","vif",vif))
      `uvm_fatal("CFG","rv32i_monitor: no virtual interface found")
  endfunction

  task run_phase(uvm_phase phase);
    rv32i_obs_item obs;
    cycle_count=0;
    forever begin
      @(vif.monitor_cb);
      cycle_count++;
      if(!vif.monitor_cb.rst)
        continue;
      obs=rv32i_obs_item::type_id::create("obs");
      obs.cycle=cycle_count;
      obs.fwdA_obs=vif.monitor_cb.fwdA;
      obs.fwdB_obs=vif.monitor_cb.fwdB;
      obs.idex_op_obs=vif.monitor_cb.idex_op;
      obs.idex_funct3_obs=vif.monitor_cb.idex_funct3;
      obs.idex_aluctrl_obs=vif.monitor_cb.idex_aluctrl;
      obs.trap_detected=vif.monitor_cb.ex_trap;
      obs.trap_cause_obs=vif.monitor_cb.trap_cause;
      obs.mem_addr=vif.monitor_cb.exmem_alu;
      obs.mem_wdata=vif.monitor_cb.exmem_store_data;
      obs.mem_write=vif.monitor_cb.exmem_memwrite;
      obs.mem_read=vif.monitor_cb.exmem_memread;
      obs.mem_funct3=vif.monitor_cb.exmem_funct3;
      obs.rd_wb=vif.monitor_cb.memwb_rd;
      obs.rd_val_wb=vif.monitor_cb.memwb_wdata;
      obs.regwrite_wb=vif.monitor_cb.memwb_regwrite;
      obs.wb_src=vif.monitor_cb.memwb_resultsrc;
      obs.memwb_csrwrite=vif.monitor_cb.memwb_csrwrite;
      obs.branch_taken=vif.monitor_cb.branch_taken_r;
      obs.pc_redirect=vif.monitor_cb.redirect_now;
      obs.redirect_target=vif.monitor_cb.redirect_pc;
      ap_all.write(obs);
      if(obs.regwrite_wb&&(obs.rd_wb!=5'd0)&&vif.monitor_cb.memwb_valid) begin
        `uvm_info("MON",$sformatf("[%0d] WB: x%0d = 0x%08h (src=%0d)",cycle_count,obs.rd_wb,obs.rd_val_wb,obs.wb_src),UVM_HIGH)ap_wb.write(obs);
      end
      if(vif.monitor_cb.exmem_valid&&
        (vif.monitor_cb.exmem_memread||vif.monitor_cb.exmem_memwrite)) begin
        `uvm_info("MON",$sformatf("[%0d] MEM: %s addr=0x%08h data=0x%08h f3=%03b",cycle_count,vif.monitor_cb.exmem_memwrite?"STORE":"LOAD",obs.mem_addr,obs.mem_wdata,obs.mem_funct3),UVM_HIGH)
        ap_mem.write(obs);
      end
      if(obs.trap_detected) begin
        `uvm_info("MON",$sformatf("[%0d] TRAP: cause=0x%08h",cycle_count,obs.trap_cause_obs),UVM_MEDIUM)ap_trap.write(obs);
      end
    end
  endtask
endclass:rv32i_monitor
`endif
