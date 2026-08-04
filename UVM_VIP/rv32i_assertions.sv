
















`ifndef RV32I_ASSERTIONS_SV
`define RV32I_ASSERTIONS_SV

`include "rv32i_defs.v"




module rv32i_assertions_bind (
    input clk,
    input rst
);






    property p_reset_pc;
        @(posedge clk) $rose(rst) |-> ##[1:2] (tb_top.dut.pc_f == 32'd0);
    endproperty
    A1_RESET_PC: assert property (p_reset_pc)
        else $error("ASSERT FAIL [A1]: PC not 0 after reset");


    property p_reset_pipeline_valid;
        @(posedge clk) (!rst) |->
            (!tb_top.dut.ifid_valid &&
             !tb_top.dut.idex_valid &&
             !tb_top.dut.exmem_valid &&
             !tb_top.dut.memwb_valid);
    endproperty
    A2_RESET_VALID: assert property (p_reset_pipeline_valid)
        else $error("ASSERT FAIL [A2]: Pipeline valid bits not cleared during reset");


    property p_x0_immutable;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.memwb_regwrite && (tb_top.dut.memwb_rd == 5'd0)) |=>
        (tb_top.dut.RF.Register[0] == 32'd0);
    endproperty
    A3_X0_IMMUTABLE: assert property (p_x0_immutable)
        else $error("ASSERT FAIL [A3]: x0 was written non-zero");






    property p_ifid_valid_reset;
        @(posedge clk) (!rst) |-> !tb_top.dut.ifid_valid;
    endproperty
    A4_IFID_RST: assert property (p_ifid_valid_reset)
        else $error("ASSERT FAIL [A4]: ifid_valid asserted during reset");


    property p_idex_valid_reset;
        @(posedge clk) (!rst) |-> !tb_top.dut.idex_valid;
    endproperty
    A5_IDEX_RST: assert property (p_idex_valid_reset)
        else $error("ASSERT FAIL [A5]: idex_valid asserted during reset");


    property p_exmem_valid_reset;
        @(posedge clk) (!rst) |-> !tb_top.dut.exmem_valid;
    endproperty
    A6_EXMEM_RST: assert property (p_exmem_valid_reset)
        else $error("ASSERT FAIL [A6]: exmem_valid asserted during reset");


    property p_redirect_flush;
        @(posedge clk) disable iff (!rst)
        tb_top.dut.redirect_now |=> (!tb_top.dut.ifid_valid && !tb_top.dut.idex_valid);
    endproperty
    A7_REDIRECT_FLUSH: assert property (p_redirect_flush)
        else $error("ASSERT FAIL [A7]: Pipeline not flushed after redirect");



    property p_idex_from_ifid;
        @(posedge clk) disable iff (!rst)
        $rose(tb_top.dut.idex_valid) |-> $past(tb_top.dut.ifid_valid);
    endproperty
    A8_IDEX_FROM_IFID: assert property (p_idex_from_ifid)
        else $error("ASSERT FAIL [A8]: idex_valid rose without prior ifid_valid");






    property p_fwdA_ex_ex;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.fwdA == 2'b10) |->
        (tb_top.dut.exmem_regwrite &&
         tb_top.dut.exmem_rd != 5'd0 &&
         tb_top.dut.exmem_rd == tb_top.dut.idex_rs1);
    endproperty
    A9_FWDA_EX_EX: assert property (p_fwdA_ex_ex)
        else $error("ASSERT FAIL [A9]: fwdA=10 but forwarding condition not met");


    property p_fwdA_mem_ex;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.fwdA == 2'b01) |->
        (tb_top.dut.memwb_regwrite &&
         tb_top.dut.memwb_rd != 5'd0 &&
         tb_top.dut.memwb_rd == tb_top.dut.idex_rs1);
    endproperty
    A10_FWDA_MEM_EX: assert property (p_fwdA_mem_ex)
        else $error("ASSERT FAIL [A10]: fwdA=01 but WB forwarding condition not met");


    property p_fwdB_ex_ex;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.fwdB == 2'b10) |->
        (tb_top.dut.exmem_regwrite &&
         tb_top.dut.exmem_rd != 5'd0 &&
         tb_top.dut.exmem_rd == tb_top.dut.idex_rs2);
    endproperty
    A11_FWDB_EX_EX: assert property (p_fwdB_ex_ex)
        else $error("ASSERT FAIL [A11]: fwdB=10 but forwarding condition not met");


    property p_fwdB_mem_ex;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.fwdB == 2'b01) |->
        (tb_top.dut.memwb_regwrite &&
         tb_top.dut.memwb_rd != 5'd0 &&
         tb_top.dut.memwb_rd == tb_top.dut.idex_rs2);
    endproperty
    A12_FWDB_MEM_EX: assert property (p_fwdB_mem_ex)
        else $error("ASSERT FAIL [A12]: fwdB=01 but WB forwarding condition not met");


    property p_no_fwd_from_x0;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.fwdA != 2'b00) |->
        ((tb_top.dut.fwdA == 2'b10) ? (tb_top.dut.exmem_rd != 5'd0) :
                                       (tb_top.dut.memwb_rd != 5'd0));
    endproperty
    A13_NO_FWD_FROM_X0: assert property (p_no_fwd_from_x0)
        else $error("ASSERT FAIL [A13]: Forwarding from x0 detected");








    property p_load_use_stall;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.idex_valid &&
         tb_top.dut.idex_memread &&
         tb_top.dut.idex_rd != 5'd0 &&
         tb_top.dut.ifid_valid &&
         ((tb_top.dut.idex_rd == tb_top.dut.ifid_instr[19:15]) ||
          (tb_top.dut.idex_rd == tb_top.dut.ifid_instr[24:20]))) |=>
        (tb_top.dut.ifid_valid);
    endproperty
    A14_LOAD_USE_STALL: assert property (p_load_use_stall)
        else $error("ASSERT FAIL [A14]: Load-use hazard not stalled");






    property p_jump_redirect;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.idex_valid && (tb_top.dut.idex_jump || tb_top.dut.idex_jalr)) |->
        tb_top.dut.redirect_now;
    endproperty
    A15_JUMP_REDIRECT: assert property (p_jump_redirect)
        else $error("ASSERT FAIL [A15]: Jump in EX but redirect_now not asserted");


    property p_jalr_lsb;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.idex_valid && tb_top.dut.idex_jalr) |->
        (tb_top.dut.jalr_target[0] == 1'b0);
    endproperty
    A16_JALR_LSB: assert property (p_jalr_lsb)
        else $error("ASSERT FAIL [A16]: JALR target LSB not cleared");


    property p_pc_plus4;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.imem_active && !tb_top.dut.redirect_now) |=>
        (tb_top.dut.pc_f == ($past(tb_top.dut.pc_f) + 32'd4));
    endproperty
    A17_PC_PLUS4: assert property (p_pc_plus4)
        else $error("ASSERT FAIL [A17]: PC did not increment by 4 on normal fetch");


    property p_pc_redirect_load;
        @(posedge clk) disable iff (!rst)
        tb_top.dut.redirect_now |=>
        (tb_top.dut.pc_f == $past(tb_top.dut.redirect_pc));
    endproperty
    A18_PC_REDIRECT: assert property (p_pc_redirect_load)
        else $error("ASSERT FAIL [A18]: PC not loaded from redirect_pc on redirect");






    property p_ecall_trap;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.idex_valid && tb_top.dut.idex_ecall) |-> tb_top.dut.ex_trap;
    endproperty
    A19_ECALL_TRAP: assert property (p_ecall_trap)
        else $error("ASSERT FAIL [A19]: ECALL did not trigger ex_trap");


    property p_ebreak_trap;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.idex_valid && tb_top.dut.idex_ebreak) |-> tb_top.dut.ex_trap;
    endproperty
    A20_EBREAK_TRAP: assert property (p_ebreak_trap)
        else $error("ASSERT FAIL [A20]: EBREAK did not trigger ex_trap");


    property p_illegal_trap;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.idex_valid && tb_top.dut.idex_illegal) |-> tb_top.dut.ex_trap;
    endproperty
    A21_ILLEGAL_TRAP: assert property (p_illegal_trap)
        else $error("ASSERT FAIL [A21]: Illegal instruction did not trigger ex_trap");


    property p_trap_redirect;
        @(posedge clk) disable iff (!rst)
        tb_top.dut.ex_trap |-> tb_top.dut.redirect_now;
    endproperty
    A22_TRAP_REDIRECT: assert property (p_trap_redirect)
        else $error("ASSERT FAIL [A22]: ex_trap asserted but redirect_now not set");


    property p_trap_target;
        @(posedge clk) disable iff (!rst)
        tb_top.dut.ex_trap |->
        (tb_top.dut.redirect_pc == tb_top.dut.csr_mtvec);
    endproperty
    A23_TRAP_TARGET: assert property (p_trap_target)
        else $error("ASSERT FAIL [A23]: Trap target not csr_mtvec");


    property p_mret_target;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.idex_valid && tb_top.dut.idex_mret) |->
        (tb_top.dut.redirect_pc == tb_top.dut.csr_mepc);
    endproperty
    A24_MRET_TARGET: assert property (p_mret_target)
        else $error("ASSERT FAIL [A24]: MRET target not mepc");






    property p_dmem_requires_valid;
        @(posedge clk) disable iff (!rst)
        tb_top.dut.dmem_active |-> tb_top.dut.exmem_valid;
    endproperty
    A25_DMEM_NEEDS_VALID: assert property (p_dmem_requires_valid)
        else $error("ASSERT FAIL [A25]: DMEM active without exmem_valid");



    property p_lw_aligned;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.exmem_valid && tb_top.dut.exmem_memread &&
         tb_top.dut.exmem_funct3 == 3'b010 && !$past(tb_top.dut.ex_trap)) |->
        (tb_top.dut.exmem_alu[1:0] == 2'b00);
    endproperty
    A26_LW_ALIGNED: assert property (p_lw_aligned)
        else $error("ASSERT FAIL [A26]: Unaligned LW reached MEM without trap");


    property p_sw_strobe_nz;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.dmem_start && tb_top.dut.dmem_write_q) |->
        (tb_top.dut.dmem_wstrb_q != 4'b0000);
    endproperty
    A27_SW_STROBE: assert property (p_sw_strobe_nz)
        else $error("ASSERT FAIL [A27]: Store with zero byte strobe");


    property p_no_imem_during_dmem;
        @(posedge clk) disable iff (!rst)
        tb_top.dut.dmem_active |-> !tb_top.dut.im_start;
    endproperty
    A28_NO_IMEM_DURING_DMEM: assert property (p_no_imem_during_dmem)
        else $error("ASSERT FAIL [A28]: IMEM fetch started during DMEM access");






    property p_wb_x0_no_write;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.memwb_regwrite && tb_top.dut.memwb_rd == 5'd0) |->
        !tb_top.dut.RF.WE3;
    endproperty
    A29_WB_X0_GUARD: assert property (p_wb_x0_no_write)
        else $error("ASSERT FAIL [A29]: WE3 asserted for x0 destination");



    property p_wb_pc4_consistent;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.memwb_valid && tb_top.dut.memwb_resultsrc == 2'b10) |->
        (tb_top.dut.memwb_wdata == tb_top.dut.memwb_pc4);
    endproperty
    A30_WB_PC4: assert property (p_wb_pc4_consistent)
        else $error("ASSERT FAIL [A30]: WB_PC4 wdata != pc4");






    property p_csr_write_at_wb;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.CSR.csr_we) |->
        (tb_top.dut.memwb_valid && tb_top.dut.memwb_csrwrite);
    endproperty
    A31_CSR_WRITE: assert property (p_csr_write_at_wb)
        else $error("ASSERT FAIL [A31]: CSR write without memwb_csrwrite");


    property p_trap_mepc_update;
        @(posedge clk) disable iff (!rst)
        tb_top.dut.trap_taken |=>
        (tb_top.dut.CSR.mepc == $past(tb_top.dut.trap_epc));
    endproperty
    A32_TRAP_MEPC: assert property (p_trap_mepc_update)
        else $error("ASSERT FAIL [A32]: mepc not updated with trap_epc on trap");


    property p_trap_mie_clear;
        @(posedge clk) disable iff (!rst)
        tb_top.dut.trap_taken |=>
        (!tb_top.dut.CSR.mstatus[3]);
    endproperty
    A33_TRAP_MIE: assert property (p_trap_mie_clear)
        else $error("ASSERT FAIL [A33]: MIE not cleared after trap");


    property p_mret_mie_restore;
        @(posedge clk) disable iff (!rst)
        tb_top.dut.mret_taken |=>
        (tb_top.dut.CSR.mstatus[3] == $past(tb_top.dut.CSR.mstatus[7]));
    endproperty
    A34_MRET_MIE: assert property (p_mret_mie_restore)
        else $error("ASSERT FAIL [A34]: MIE not restored from MPIE after MRET");






    property p_irq_requires_mie;
        @(posedge clk) disable iff (!rst)
        tb_top.dut.ex_interrupt |->
        tb_top.dut.CSR.mstatus[3];
    endproperty
    A35_IRQ_MIE: assert property (p_irq_requires_mie)
        else $error("ASSERT FAIL [A35]: Interrupt accepted with MIE=0");


    property p_irq_from_timer;
    	@(posedge clk) disable iff (!rst)
    	((tb_top.dut.ex_interrupt && (!tb_top.dut.ex_trap)) |-> tb_top.vif.timer_irq);
    endproperty
    A36_IRQ_SOURCE: assert property (p_irq_from_timer)
        else $error("ASSERT FAIL [A36]: ex_interrupt without timer_irq");








    property p_exmem_one_at_a_time;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.exmem_valid && tb_top.dut.dmem_active) |->
        (tb_top.dut.exmem_memread || tb_top.dut.exmem_memwrite);
    endproperty
    A37_EXMEM_DMEM: assert property (p_exmem_one_at_a_time)
        else $error("ASSERT FAIL [A37]: exmem_valid + dmem_active without mem op");



    property p_pipeline_advance;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.idex_valid && tb_top.dut.exmem_valid && !tb_top.dut.dmem_active) |=>
        (!tb_top.dut.idex_valid || !tb_top.dut.exmem_valid);
    endproperty
    A38_PIPELINE_ADVANCE: assert property (p_pipeline_advance)
        else $error("ASSERT FAIL [A38]: Pipeline did not advance: both idex and exmem stuck");



    property p_nop_no_write;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.memwb_valid && tb_top.dut.memwb_rd == 5'd0) |->
        (!tb_top.dut.RF.WE3);
    endproperty
    A39_NOP_NO_WRITE: assert property (p_nop_no_write)
        else $error("ASSERT FAIL [A39]: NOP-like instruction caused register write");


    property p_branch_target_align;
        @(posedge clk) disable iff (!rst)
        (tb_top.dut.idex_valid && tb_top.dut.idex_branch &&
         tb_top.dut.branch_taken_r && !tb_top.dut.ex_trap) |->
        (tb_top.dut.br_target[1:0] == 2'b00);
    endproperty
    A40_BRANCH_ALIGN: assert property (p_branch_target_align)
        else $error("ASSERT FAIL [A40]: Branch to misaligned target without trap");

endmodule : rv32i_assertions_bind




bind rv32i_pipeline_core rv32i_assertions_bind u_assert (
    .clk(clk),
    .rst(rst)
);

`endif
