`ifndef RV32I_AGENT_SV
`define RV32I_AGENT_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
import rv32i_pkg::*;

class rv32i_agent extends uvm_agent;
  `uvm_component_utils(rv32i_agent)
  rv32i_sequencer sequencer;
  rv32i_driver driver;
  rv32i_monitor monitor;
  uvm_analysis_port #(rv32i_obs_item) ap_wb;
  uvm_analysis_port #(rv32i_obs_item) ap_mem;
  uvm_analysis_port #(rv32i_obs_item) ap_trap;
  uvm_analysis_port #(rv32i_obs_item) ap_all;

  function new(string name="rv32i_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer=rv32i_sequencer::type_id::create("sequencer",this);
    driver=rv32i_driver::type_id::create("driver",this);
    monitor=rv32i_monitor::type_id::create("monitor",this);
    ap_wb=new("ap_wb",this);
    ap_mem=new("ap_mem",this);
    ap_trap=new("ap_trap",this);
    ap_all=new("ap_all",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
    monitor.ap_wb.connect(ap_wb);
    monitor.ap_mem.connect(ap_mem);
    monitor.ap_trap.connect(ap_trap);
    monitor.ap_all.connect(ap_all);
  endfunction
endclass:rv32i_agent
`endif
