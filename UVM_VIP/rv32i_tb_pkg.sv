`ifndef RV32I_TB_PKG_SV
`define RV32I_TB_PKG_SV
`include "uvm_macros.svh"
package rv32i_tb_pkg;
  import uvm_pkg::*;
  import rv32i_pkg::*;
  `include "rv32i_seq_item.sv"
  `include "rv32i_monitor.sv"
  `include "rv32i_sequencer.sv"
  `include "rv32i_driver.sv"
  `include "rv32i_scoreboard.sv"
  `include "rv32i_coverage.sv"
  `include "rv32i_agent.sv"
  `include "rv32i_env.sv"
  `include "rv32i_sequence_lib.sv"
  `include "rv32i_test_lib.sv"
endpackage:rv32i_tb_pkg
`endif
