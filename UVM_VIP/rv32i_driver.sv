`ifndef RV32I_DRIVER_SV
`define RV32I_DRIVER_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
import rv32i_pkg::*;

class rv32i_imem_loader;
  static task load_word(input int unsigned word_idx,
             input logic [31:0]word);
    string path;
    path=$sformatf("tb_top.dut.IMEM.rom[%0d]",word_idx);

    if(!uvm_hdl_deposit(path,word)) begin
      `uvm_error("IMEM",
           $sformatf("Failed to deposit 0x%08h into %s",word,path))
    end
  endtask
endclass:rv32i_imem_loader

class rv32i_driver extends uvm_driver #(rv32i_seq_item);
  `uvm_component_utils(rv32i_driver)
  virtual rv32i_if.DRIVER vif;
  function new(string name="rv32i_driver",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual rv32i_if.DRIVER)::get(this,"","vif",vif))
      `uvm_fatal("CFG","rv32i_driver: no virtual interface found in config db")
  endfunction

  task run_phase(uvm_phase phase);
    rv32i_seq_item item;
    vif.driver_cb.rst<=1'b0;
    vif.driver_cb.timer_irq<=1'b0;
    repeat(3)@(vif.driver_cb);
    forever begin
      seq_item_port.get_next_item(item);
      drive_item(item);
      seq_item_port.item_done();
    end
  endtask

  task drive_item(rv32i_seq_item item);
    int unsigned word_idx;
    if(!item.rst_n) begin
      vif.driver_cb.rst<=1'b0;
      vif.driver_cb.timer_irq<=1'b0;
      repeat(5)@(vif.driver_cb);
      `uvm_info("DRV","Reset asserted",UVM_MEDIUM)
      return;
    end
    word_idx=item.imem_addr>>2;
  `uvm_info("DRV_LOAD",
     $sformatf("Loading IMEM[%0d] = %08h",
          word_idx,
          item.instr_word),
     UVM_NONE)
    rv32i_imem_loader::load_word(word_idx,item.instr_word);
    vif.driver_cb.rst<=1'b1;
    vif.driver_cb.timer_irq<=item.timer_irq;
    @(vif.driver_cb);
    `uvm_info("DRV",
         $sformatf("Drove instr=0x%08h @ addr=0x%08h irq=%b",
              item.instr_word,item.imem_addr,item.timer_irq),
         UVM_HIGH)
  endtask

  task do_reset(int cycles=5);
    vif.driver_cb.rst<=1'b0;
    repeat(cycles)@(vif.driver_cb);
    vif.driver_cb.rst<=1'b1;
    @(vif.driver_cb);
    `uvm_info("DRV","Reset de-asserted",UVM_MEDIUM)
  endtask
endclass:rv32i_driver
`endif
