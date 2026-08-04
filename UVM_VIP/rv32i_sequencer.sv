



`ifndef RV32I_SEQUENCER_SV
`define RV32I_SEQUENCER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import rv32i_pkg::*;

class rv32i_sequencer extends uvm_sequencer #(rv32i_seq_item);
    `uvm_component_utils(rv32i_sequencer)

    function new(string name = "rv32i_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass : rv32i_sequencer

`endif
