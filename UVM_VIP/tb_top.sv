












`include "uvm_macros.svh"
`include "rv32i_if.sv"
`include "rv32i_assertions.sv"

import uvm_pkg::*;
import rv32i_tb_pkg::*;
import rv32i_pkg::*;

module tb_top;




    logic clk;
    logic rst_n;


    initial clk = 1'b0;
    always #5 clk = ~clk;




    rv32i_if vif(.clk(clk));


    assign rst_n = vif.rst;

	rv32i_pipeline_core dut (
    	.clk       (clk),
    	.rst       (vif.rst),
    	.timer_irq (vif.timer_irq)
	);




    assign vif.pc_f           = dut.pc_f;
    assign vif.ifid_valid     = dut.ifid_valid;
    assign vif.ifid_pc        = dut.ifid_pc;
    assign vif.ifid_instr     = dut.ifid_instr;

    assign vif.idex_valid     = dut.idex_valid;
    assign vif.idex_pc        = dut.idex_pc;
    assign vif.idex_rs1       = dut.idex_rs1;
    assign vif.idex_rs2       = dut.idex_rs2;
    assign vif.idex_rd        = dut.idex_rd;
    assign vif.idex_regwrite  = dut.idex_regwrite;
    assign vif.idex_memread   = dut.idex_memread;
    assign vif.idex_memwrite  = dut.idex_memwrite;
    assign vif.idex_branch    = dut.idex_branch;
    assign vif.idex_jump      = dut.idex_jump;
    assign vif.idex_jalr      = dut.idex_jalr;
    assign vif.idex_resultsrc = dut.idex_resultsrc;
    assign vif.idex_rv1       = dut.idex_rv1;
    assign vif.idex_rv2       = dut.idex_rv2;
    assign vif.idex_imm       = dut.idex_imm;
    assign vif.idex_aluctrl   = dut.idex_aluctrl;
    assign vif.idex_funct3    = dut.idex_funct3;
    assign vif.idex_op        = dut.idex_op;
    assign vif.idex_ecall     = dut.idex_ecall;
    assign vif.idex_ebreak    = dut.idex_ebreak;
    assign vif.idex_illegal   = dut.idex_illegal;
    assign vif.idex_mret      = dut.idex_mret;

    assign vif.exmem_valid      = dut.exmem_valid;
    assign vif.exmem_alu        = dut.exmem_alu;
    assign vif.exmem_rd         = dut.exmem_rd;
    assign vif.exmem_regwrite   = dut.exmem_regwrite;
    assign vif.exmem_memread    = dut.exmem_memread;
    assign vif.exmem_memwrite   = dut.exmem_memwrite;
    assign vif.exmem_resultsrc  = dut.exmem_resultsrc;
    assign vif.exmem_store_data = dut.exmem_store_data;
    assign vif.exmem_funct3     = dut.exmem_funct3;

    assign vif.memwb_valid    = dut.memwb_valid;
    assign vif.memwb_rd       = dut.memwb_rd;
    assign vif.memwb_wdata    = dut.memwb_wdata;
    assign vif.memwb_regwrite = dut.memwb_regwrite;
    assign vif.memwb_resultsrc= dut.memwb_resultsrc;
    assign vif.memwb_csrcmd   = dut.memwb_csrcmd;
    assign vif.memwb_csrwrite = dut.memwb_csrwrite;
    assign vif.memwb_csr_addr = dut.memwb_csr_addr;

    assign vif.fwdA          = dut.fwdA;
    assign vif.fwdB          = dut.fwdB;

    assign vif.ex_trap        = dut.ex_trap;
    assign vif.trap_cause     = dut.trap_cause;

    assign vif.imem_active    = dut.imem_active;
    assign vif.dmem_active    = dut.dmem_active;

    assign vif.branch_taken_r = dut.branch_taken_r;
    assign vif.redirect_now   = dut.redirect_now;
    assign vif.redirect_pc    = dut.redirect_pc;




    initial begin
        uvm_config_db #(virtual rv32i_if.DRIVER) ::set(null, "uvm_test_top.env.agent.driver",
                                                        "vif", vif);
        uvm_config_db #(virtual rv32i_if.MONITOR)::set(null, "uvm_test_top.env.agent.monitor",
                                                        "vif", vif);

        uvm_config_db #(virtual rv32i_if.DRIVER) ::set(null, "*", "vif", vif);
        uvm_config_db #(virtual rv32i_if.MONITOR)::set(null, "*", "vif", vif);
    end




    initial begin
        #500000;
        `uvm_fatal("TIMEOUT", "Simulation timeout! Test took too long.")
    end




    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
    end





    initial begin
        run_test();
    end

endmodule : tb_top
