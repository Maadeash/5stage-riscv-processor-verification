`ifndef RV32I_ENV_SV
`define RV32I_ENV_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
import rv32i_pkg::*;

class rv32i_env extends uvm_env;
  `uvm_component_utils(rv32i_env)
  rv32i_agent agent;
  rv32i_scoreboard scoreboard;
  rv32i_coverage coverage;

  function new(string name="rv32i_env",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent=rv32i_agent::type_id::create("agent",this);
    scoreboard=rv32i_scoreboard::type_id::create("scoreboard",this);
    coverage=rv32i_coverage::type_id::create("coverage",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    agent.ap_wb.connect(scoreboard.wb_fifo.analysis_export);
    agent.ap_mem.connect(scoreboard.mem_fifo.analysis_export);
    agent.ap_trap.connect(scoreboard.trap_fifo.analysis_export);
    agent.ap_all.connect(coverage.analysis_export);
  endfunction

  function void expect_wb(logic [4:0]rd,logic [31:0]val,logic [31:0]pc,string s="");
    scoreboard.expect_wb(rd,val,pc,s);
  endfunction

  function void reset_reference_model();
    scoreboard.reset_model();
  endfunction
endclass:rv32i_env
`endif
