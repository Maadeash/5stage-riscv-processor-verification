







`ifndef RV32I_IF_SV
`define RV32I_IF_SV

interface rv32i_if (input logic clk);




    logic        rst;
    logic        timer_irq;






    logic [31:0] pc_f;
    logic        ifid_valid;
    logic [31:0] ifid_pc;
    logic [31:0] ifid_instr;


    logic        idex_valid;
    logic [31:0] idex_pc;
    logic [4:0]  idex_rs1;
    logic [4:0]  idex_rs2;
    logic [4:0]  idex_rd;
    logic        idex_regwrite;
    logic        idex_memread;
    logic        idex_memwrite;
    logic        idex_branch;
    logic        idex_jump;
    logic        idex_jalr;
    logic [1:0]  idex_resultsrc;
    logic [31:0] idex_rv1;
    logic [31:0] idex_rv2;
    logic [31:0] idex_imm;
    logic [3:0]  idex_aluctrl;
    logic [2:0]  idex_funct3;
    logic [6:0]  idex_op;
    logic        idex_ecall;
    logic        idex_ebreak;
    logic        idex_illegal;
    logic        idex_mret;


    logic        exmem_valid;
    logic [31:0] exmem_alu;
    logic [4:0]  exmem_rd;
    logic        exmem_regwrite;
    logic        exmem_memread;
    logic        exmem_memwrite;
    logic [1:0]  exmem_resultsrc;
    logic [31:0] exmem_store_data;
    logic [2:0]  exmem_funct3;


    logic        memwb_valid;
    logic [4:0]  memwb_rd;
    logic [31:0] memwb_wdata;
    logic        memwb_regwrite;
    logic [1:0]  memwb_resultsrc;
    logic [1:0]  memwb_csrcmd;
    logic        memwb_csrwrite;
    logic [11:0] memwb_csr_addr;


    logic [1:0]  fwdA;
    logic [1:0]  fwdB;


    logic        ex_trap;
    logic [31:0] trap_cause;


    logic        imem_active;
    logic        dmem_active;

    logic        branch_taken_r;
    logic        redirect_now;
    logic [31:0] redirect_pc;




    clocking driver_cb @(posedge clk);
        default input  #1step;
        default output #1;
        output rst;
        output timer_irq;
    endclocking



    clocking monitor_cb @(posedge clk);
        default input #1step;


        input rst;
        input timer_irq;


        input pc_f;
        input ifid_valid;
        input ifid_pc;
        input ifid_instr;
        input idex_valid;
        input idex_pc;
        input idex_rs1, idex_rs2, idex_rd;
        input idex_regwrite, idex_memread, idex_memwrite;
        input idex_branch, idex_jump, idex_jalr;
        input idex_resultsrc;
        input idex_rv1, idex_rv2, idex_imm;
        input idex_aluctrl, idex_funct3, idex_op;
        input idex_ecall, idex_ebreak, idex_illegal, idex_mret;

        input exmem_valid, exmem_alu, exmem_rd;
        input exmem_regwrite, exmem_memread, exmem_memwrite;
        input exmem_resultsrc, exmem_store_data, exmem_funct3;

        input memwb_valid, memwb_rd, memwb_wdata;
        input memwb_regwrite, memwb_resultsrc;
        input memwb_csrcmd, memwb_csrwrite, memwb_csr_addr;

        input fwdA, fwdB;
        input ex_trap, trap_cause;


        input branch_taken_r;
        input redirect_now;
        input redirect_pc;

        input imem_active, dmem_active;
    endclocking



    modport DRIVER  (clocking driver_cb,  input clk);
    modport MONITOR (clocking monitor_cb, input clk);

endinterface : rv32i_if

`endif
