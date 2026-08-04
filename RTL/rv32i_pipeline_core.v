
`include "rv32i_defs.v"
module rv32i_pipeline_core(
    input clk,
    input rst,
    input timer_irq
);
    reg [31:0] pc_f;
    reg ifid_valid;
    reg [31:0] ifid_pc, ifid_pc4, ifid_instr;
    reg idex_valid;
    reg [31:0] idex_pc, idex_pc4, idex_rv1, idex_rv2, idex_imm;
    reg [4:0]  idex_rs1, idex_rs2, idex_rd;
    reg [2:0]  idex_funct3;
    reg [6:0]  idex_funct7, idex_op;
    reg        idex_regwrite, idex_alusrc, idex_memwrite, idex_memread, idex_branch, idex_jump, idex_jalr;
    reg [1:0]  idex_resultsrc, idex_csrcmd;
    reg        idex_csrwrite, idex_mret, idex_ecall, idex_ebreak, idex_illegal;
    reg [3:0]  idex_aluctrl;
    reg [11:0] idex_csr_addr;
    reg [31:0] idex_csr_wdata, idex_csr_read;
    reg exmem_valid;
    reg [31:0] exmem_pc, exmem_pc4, exmem_alu, exmem_store_data, exmem_imm;
    reg [4:0]  exmem_rd;
    reg [2:0]  exmem_funct3;
    reg [6:0]  exmem_op;
    reg        exmem_regwrite, exmem_memwrite, exmem_memread, exmem_branch, exmem_jump, exmem_jalr;
    reg [1:0]  exmem_resultsrc, exmem_csrcmd;
    reg        exmem_csrwrite, exmem_mret, exmem_ecall, exmem_ebreak, exmem_illegal;
    reg [3:0]  exmem_aluctrl;
    reg [11:0] exmem_csr_addr;
    reg [31:0] exmem_csr_wdata, exmem_csr_read;
    reg memwb_valid;
    reg [4:0]  memwb_rd;
    reg [31:0] memwb_wdata, memwb_pc4;
    reg        memwb_regwrite, memwb_csrwrite;
    reg [1:0]  memwb_resultsrc, memwb_csrcmd;
    reg [11:0] memwb_csr_addr;
    reg [31:0] memwb_csr_wdata;
    wire [31:0] ex_rs1, ex_rs2;
    reg         branch_taken_r;
    wire        irq_pending;
    wire [31:0] csr_rdata, csr_mtvec, csr_mepc, csr_mcause, csr_mtval, csr_mstatus, csr_mie, csr_mip;
    wire        ex_interrupt, ex_trap;
    wire [31:0] trap_cause, trap_tval, trap_epc;
    wire [2:0] ImmSrcD;
    wire ALUSrcD, MemWriteD, MemReadD, BranchD, JumpD, JALRD, RegWriteD, CSRWriteD, MretD, EcallD, EbreakD, IllegalD;
    wire [1:0] ResultSrcD, CSRCmdD;
    wire [3:0] ALUControlD;
    wire [2:0] Funct3D;
    wire [6:0] OpD;
    Control_Unit_Top CU(
        .InstrD(ifid_instr), .RegWrite(RegWriteD), .ImmSrc(ImmSrcD), .ALUSrc(ALUSrcD), .MemWrite(MemWriteD), .MemRead(MemReadD),
        .ResultSrc(ResultSrcD), .Branch(BranchD), .Jump(JumpD), .JALR(JALRD), .ALUControl(ALUControlD), .CSRCmd(CSRCmdD),
        .CSRWrite(CSRWriteD), .Mret(MretD), .Ecall(EcallD), .Ebreak(EbreakD), .Illegal(IllegalD), .Funct3(Funct3D), .Op(OpD)
    );
    wire [31:0] rf_rd1, rf_rd2, imm_ext;
    Register_File RF(
        .clk(clk), .rst(rst), .WE3(memwb_regwrite && (memwb_rd != 5'd0)), .A1(ifid_instr[19:15]), .A2(ifid_instr[24:20]), .A3(memwb_rd),
        .WD3(memwb_wdata), .RD1(rf_rd1), .RD2(rf_rd2)
    );
    Sign_Extend SE(.In(ifid_instr), .ImmSrc(ImmSrcD), .Imm_Ext(imm_ext));
    wire [1:0] fwdA, fwdB;
    Forwarding_Unit FU(
        .Rs1E(idex_rs1), .Rs2E(idex_rs2), .RdM(exmem_rd), .RdW(memwb_rd), .RegWriteM(exmem_regwrite), .RegWriteW(memwb_regwrite),
        .MemReadM(exmem_memread), .ForwardAE(fwdA), .ForwardBE(fwdB)
    );
    wire [31:0] br_target;
    assign br_target = idex_pc + idex_imm;
    wire [31:0] jal_target;
    assign jal_target = idex_pc + idex_imm;
    wire [31:0] jalr_target;
    assign jalr_target = (ex_rs1 + idex_imm) & 32'hFFFFFFFE;
    wire jump_taken;
    assign jump_taken = idex_valid && (idex_jump || idex_jalr);
    wire [31:0] control_target;
    assign control_target = idex_jalr ? jalr_target : jal_target;
    wire control_misaligned;
    assign control_misaligned = jump_taken ? (control_target[1:0] != 2'b00) : (branch_taken_r ? (br_target[1:0] != 2'b00) : 1'b0);
    wire [31:0] exmem_wb_value;
    assign exmem_wb_value = (exmem_resultsrc == `WB_PC4) ? exmem_pc4 :(exmem_resultsrc == `WB_CSR) ? exmem_csr_read :exmem_alu;
    assign ex_rs1 = (fwdA == 2'b10) ? exmem_wb_value :(fwdA == 2'b01) ? memwb_wdata :idex_rv1;
    assign ex_rs2 =(fwdB == 2'b10) ? exmem_wb_value :(fwdB == 2'b01) ? memwb_wdata :idex_rv2;
    wire [31:0] csr_write_operand;
    assign csr_write_operand = idex_funct3[2] ? {27'd0, idex_rs1} : ex_rs1;
    wire use_pc;
    assign use_pc = (idex_op == `OPC_AUIPC) || (idex_op == `OPC_JAL);
    wire [31:0] alu_a;
    assign alu_a = use_pc ? idex_pc : ((idex_op == `OPC_LUI) ? 32'd0 : ex_rs1);
    wire [31:0] alu_b;
    assign alu_b = idex_alusrc ? idex_imm : ex_rs2;
    wire alu_zero, alu_neg, alu_carry, alu_ovf;
    wire [31:0] alu_res;
    ALU UALU(.A(alu_a), .B(alu_b), .ALUControl(idex_aluctrl), .Result(alu_res), .Zero(alu_zero), .Negative(alu_neg), .Carry(alu_carry), .Overflow(alu_ovf));
    wire ex_misaligned_load;
    assign ex_misaligned_load = idex_valid && idex_memread  && ((idex_funct3 == 3'b001 || idex_funct3 == 3'b101) ? alu_res[0] : (idex_funct3 == 3'b010 ? |alu_res[1:0] : 1'b0));
    wire ex_misaligned_store;
    assign ex_misaligned_store = idex_valid && idex_memwrite && ((idex_funct3 == 3'b001) ? alu_res[0] : (idex_funct3 == 3'b010 ? |alu_res[1:0] : 1'b0));
    assign ex_interrupt = idex_valid && irq_pending;
    assign ex_trap = idex_valid && (idex_ecall || idex_ebreak || idex_illegal || control_misaligned || ex_misaligned_load || ex_misaligned_store || ex_interrupt);
    assign trap_cause = ex_interrupt ? `CAUSE_MTI :
                             idex_ecall ? `CAUSE_ECALL_MMODE :
                             idex_ebreak ? `CAUSE_BREAKPOINT :
                             idex_illegal ? `CAUSE_ILLEGAL_INSN :
                             ex_misaligned_load ? `CAUSE_LOAD_MISALIGNED :
                             ex_misaligned_store ? `CAUSE_STORE_MISALIGNED :
                             control_misaligned ? `CAUSE_INSN_MISALIGNED : 32'd0;
    assign trap_tval = ex_interrupt ? 32'd0 :
                            idex_ecall || idex_ebreak ? 32'd0 :
                            idex_illegal ? ifid_instr :
                            ex_misaligned_load || ex_misaligned_store ? alu_res :
                            control_misaligned ? control_target : 32'd0;
    assign trap_epc = idex_pc;
    wire redirect_now;
    wire flush_pipeline;

    assign flush_pipeline =
        ex_trap ||
        (idex_valid && idex_mret) ||
        (idex_valid && (idex_jump || idex_jalr || branch_taken_r));

    assign redirect_now =
        ex_trap ||
        (idex_valid && idex_mret) ||
        (idex_valid && (idex_jump || idex_jalr || branch_taken_r));
    wire [31:0] redirect_pc;
    assign redirect_pc = ex_trap ? csr_mtvec : (idex_mret ? csr_mepc : control_target);
    wire trap_taken;
    assign trap_taken = ex_trap;
    wire mret_taken;
    assign mret_taken = idex_valid && idex_mret;
    CSR_File CSR(
        .clk(clk), .rst(rst), .csr_we(memwb_valid && memwb_csrwrite), .csr_cmd(memwb_csrcmd), .csr_addr(memwb_csr_addr),
	.csr_raddr(ifid_instr[31:20]),
	.csr_wdata(memwb_csr_wdata),
        .trap_taken(trap_taken), .mret_taken(mret_taken), .trap_cause(trap_cause), .trap_tval(trap_tval), .trap_epc(trap_epc),
        .timer_irq(timer_irq), .csr_rdata(csr_rdata), .mtvec(csr_mtvec), .mepc(csr_mepc), .mcause(csr_mcause), .mtval(csr_mtval),
        .mstatus(csr_mstatus), .mie(csr_mie), .mip(csr_mip), .irq_pending(irq_pending)
    );
    reg imem_active;
    reg dmem_active;
    wire im_start;
    assign im_start = (!imem_active) && (!ifid_valid) && (!dmem_active) && (!redirect_now);
    wire dmem_start;
    assign dmem_start = exmem_valid && (exmem_memread || exmem_memwrite) && (!dmem_active) && !ex_trap;
    wire im_done;
    assign im_done = imem_active;
    wire [31:0] im_rdata_latched;
    Instruction_Memory IMEM(.clk(clk), .rst(rst), .A(pc_f), .RD(im_rdata_latched));
    reg [31:0] dmem_addr_q, dmem_wdata_q;
    reg [3:0] dmem_wstrb_q;
    reg dmem_write_q;
    wire dm_done;
    assign dm_done = dmem_active;
    wire [31:0] dm_rdata_latched;
    Data_Memory DMEM(
        .clk(clk), .rst(rst),
        .WE(dmem_start && dmem_write_q), .WSTRB(dmem_wstrb_q),
        .A(dmem_addr_q), .WD(dmem_wdata_q), .RD(dm_rdata_latched)
    );
	
    function [31:0] load_extract;
        input [31:0] word;
        input [31:0] addr;
        input [2:0] f3;
        reg [7:0] b;
        reg [15:0] h;
        begin
            case (f3)
                3'b000: begin
                    case (addr[1:0])
                        2'b00: b = word[7:0];
                        2'b01: b = word[15:8];
                        2'b10: b = word[23:16];
                        default: b = word[31:24];
                    endcase
                    load_extract = {{24{b[7]}}, b};
                end
                3'b100: begin
                    case (addr[1:0])
                        2'b00: b = word[7:0];
                        2'b01: b = word[15:8];
                        2'b10: b = word[23:16];
                        default: b = word[31:24];
                    endcase
                    load_extract = {24'd0, b};
                end
                3'b001: begin
                    h = addr[1] ? word[31:16] : word[15:0];
                    load_extract = {{16{h[15]}}, h};
                end
                3'b101: begin
                    h = addr[1] ? word[31:16] : word[15:0];
                    load_extract = {16'd0, h};
                end
                default: load_extract = word;
            endcase
        end
    endfunction

    function [31:0] store_align;
        input [31:0] data;
        input [31:0] addr;
        input [2:0] f3;
        begin
            case (f3)
                3'b000: store_align = {24'd0, data[7:0]} << (8*addr[1:0]);
                3'b001: store_align = {16'd0, data[15:0]} << (8*addr[1]);
                default: store_align = data;
            endcase
        end
    endfunction

    function [3:0] store_strb;
        input [31:0] addr;
        input [2:0] f3;
        begin
            case (f3)
                3'b000: store_strb = 4'b0001 << addr[1:0];
                3'b001: store_strb = addr[1] ? 4'b1100 : 4'b0011;
                default: store_strb = 4'b1111;
            endcase
        end
    endfunction

    wire branch_eq;
    assign branch_eq = (ex_rs1 == ex_rs2);
    wire branch_lt;
    assign branch_lt = ($signed(ex_rs1) < $signed(ex_rs2));
    wire branch_ltu;
    assign branch_ltu = (ex_rs1 < ex_rs2);

    always @* begin
        branch_taken_r = 1'b0;
        if (idex_valid && idex_branch) begin
            case (idex_funct3)
                `F3_BEQ:  branch_taken_r = branch_eq;
                `F3_BNE:  branch_taken_r = ~branch_eq;
                `F3_BLT:  branch_taken_r = branch_lt;
                `F3_BGE:  branch_taken_r = ~branch_lt;
                `F3_BLTU: branch_taken_r = branch_ltu;
                `F3_BGEU: branch_taken_r = ~branch_ltu;
                default:  branch_taken_r = 1'b0;
            endcase
        end
    end

    always @* begin
        dmem_addr_q  = exmem_alu & 32'hFFFFFFFC;
        dmem_wdata_q = store_align(exmem_store_data, exmem_alu, exmem_funct3);
        dmem_wstrb_q = store_strb(exmem_alu, exmem_funct3);
        dmem_write_q = exmem_memwrite;
    end

    integer i;
    wire csr_hazard;
    assign csr_hazard = (CSRWriteD && (
            (idex_valid  && idex_csrwrite  && (idex_csr_addr  == ifid_instr[31:20])) ||
            (exmem_valid && exmem_csrwrite && (exmem_csr_addr == ifid_instr[31:20])) ||
            (memwb_valid && memwb_csrwrite && (memwb_csr_addr == ifid_instr[31:20]))
        )) ||
        (MretD && (
            (idex_valid  && idex_csrwrite  && (idex_csr_addr  == `CSR_MEPC)) ||
            (exmem_valid && exmem_csrwrite && (exmem_csr_addr == `CSR_MEPC)) ||
            (memwb_valid && memwb_csrwrite && (memwb_csr_addr == `CSR_MEPC))
        ));
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
    	$display("\n========== PIPE ==========");
    	$display("TIME=%0t",$time);
    	$display("PC          = %h", pc_f);
    	$display("IFID_VALID  = %b", ifid_valid);
    	$display("IFID_INSTR  = %h", ifid_instr);
    	$display("IDEX_PC     = %h", idex_pc);
    	$display("EXMEM_RD    = %0d", exmem_rd);
    	$display("MEMWB_RD    = %0d", memwb_rd);
    	$display("WB_DATA     = %h", memwb_wdata);
    	$display("redirect    = %b", redirect_now);
    	$display("flush       = %b", flush_pipeline);
            pc_f <= 32'd0;
            ifid_valid <= 1'b0; ifid_pc <= 32'd0; ifid_pc4 <= 32'd0; ifid_instr <= 32'd0;
            idex_valid <= 1'b0; exmem_valid <= 1'b0; memwb_valid <= 1'b0;
            imem_active <= 1'b0; dmem_active <= 1'b0;
            memwb_wdata <= 32'd0; memwb_rd <= 5'd0; memwb_regwrite <= 1'b0; memwb_pc4 <= 32'd0; memwb_resultsrc <= `WB_ALU; memwb_csrwrite <= 1'b0; memwb_csrcmd <= `CSR_NONE; memwb_csr_addr <= 12'd0; memwb_csr_wdata <= 32'd0;
        end else begin
	    if (memwb_valid)
	    memwb_valid <= 1'b0;
            if (imem_active && im_done) begin
                if (!flush_pipeline) begin
                    ifid_valid <= 1'b1;
                    ifid_pc <= pc_f;
                    ifid_pc4 <= pc_f + 32'd4;
                    ifid_instr <= im_rdata_latched;
                    pc_f <= pc_f + 32'd4;
                end
                imem_active <= 1'b0;
            end
            if (flush_pipeline) begin
    		pc_f <= redirect_pc;
    		ifid_valid <= 1'b0;
    		idex_valid <= 1'b0;
	    end
            if (dmem_active && dm_done) begin
                dmem_active <= 1'b0;
                if (exmem_valid) begin
                    memwb_valid <= 1'b1;
                    memwb_rd <= exmem_rd;
                    memwb_regwrite <= exmem_regwrite;
                    memwb_pc4 <= exmem_pc4;
                    memwb_resultsrc <= exmem_resultsrc;
                    memwb_csrwrite <= exmem_csrwrite;
                    memwb_csrcmd <= exmem_csrcmd;
                    memwb_csr_addr <= exmem_csr_addr;
                    memwb_csr_wdata <= exmem_csr_wdata;
                    if (exmem_memread) memwb_wdata <= load_extract(dm_rdata_latched, exmem_alu, exmem_funct3);
                    else memwb_wdata <= exmem_alu;
                    exmem_valid <= 1'b0;
                end
            end
            if (exmem_valid && !exmem_memread && !exmem_memwrite && !dmem_active) begin
                memwb_valid <= 1'b1;
                memwb_rd <= exmem_rd;
                memwb_regwrite <= exmem_regwrite;
                memwb_pc4 <= exmem_pc4;
                memwb_resultsrc <= exmem_resultsrc;
                memwb_csrwrite <= exmem_csrwrite;
                memwb_csrcmd <= exmem_csrcmd;
                memwb_csr_addr <= exmem_csr_addr;
                memwb_csr_wdata <= exmem_csr_wdata;
                if (exmem_resultsrc == `WB_CSR) memwb_wdata <= exmem_csr_read;
                else if (exmem_resultsrc == `WB_PC4) memwb_wdata <= exmem_pc4;
                else memwb_wdata <= exmem_alu;
                exmem_valid <= 1'b0;
            end

            if (exmem_valid && (exmem_memread || exmem_memwrite) && !dmem_active && !redirect_now) begin
                dmem_active <= 1'b1;
            end

            if (idex_valid && !exmem_valid && !dmem_active) begin
                exmem_valid <= 1'b1;
                exmem_pc <= idex_pc;
                exmem_pc4 <= idex_pc4;
                exmem_alu <= alu_res;
                exmem_store_data <= ex_rs2;
                exmem_imm <= idex_imm;
                exmem_rd <= idex_rd;
                exmem_funct3 <= idex_funct3;
                exmem_op <= idex_op;
                exmem_regwrite <= idex_regwrite && !ex_trap;
                exmem_memwrite <= idex_memwrite && !ex_trap;
                exmem_memread <= idex_memread && !ex_trap;
                exmem_branch <= idex_branch;
                exmem_jump <= idex_jump;
                exmem_jalr <= idex_jalr;
                exmem_resultsrc <= idex_resultsrc;
                exmem_csrcmd <= idex_csrcmd;
                exmem_csrwrite <= idex_csrwrite;
                exmem_mret <= idex_mret;
                exmem_ecall <= idex_ecall;
                exmem_ebreak <= idex_ebreak;
                exmem_illegal <= idex_illegal;
                exmem_aluctrl <= idex_aluctrl;
                exmem_csr_addr <= idex_csr_addr;
                exmem_csr_wdata <= csr_write_operand;
                exmem_csr_read <= idex_csr_read;
                idex_valid <= 1'b0;
            end

            if (ifid_valid && !idex_valid && !dmem_active && !redirect_now && !csr_hazard) begin
                idex_valid <= 1'b1;
                idex_pc <= ifid_pc;
                idex_pc4 <= ifid_pc4;
                idex_rv1 <= rf_rd1;
                idex_rv2 <= rf_rd2;
                idex_imm <= imm_ext;
                idex_rs1 <= ifid_instr[19:15];
                idex_rs2 <= ifid_instr[24:20];
                idex_rd  <= ifid_instr[11:7];
                idex_funct3 <= ifid_instr[14:12];
                idex_funct7 <= ifid_instr[31:25];
                idex_op <= ifid_instr[6:0];
                idex_regwrite <= RegWriteD;
                idex_alusrc <= ALUSrcD;
                idex_memwrite <= MemWriteD;
                idex_memread <= MemReadD;
                idex_branch <= BranchD;
                idex_jump <= JumpD;
                idex_jalr <= JALRD;
                idex_resultsrc <= ResultSrcD;
                idex_csrcmd <= CSRCmdD;
                idex_csrwrite <= CSRWriteD;
                idex_mret <= MretD;
                idex_ecall <= EcallD;
                idex_ebreak <= EbreakD;
                idex_illegal <= IllegalD;
                idex_aluctrl <= ALUControlD;
                idex_csr_addr <= ifid_instr[31:20];
                idex_csr_wdata <= (ifid_instr[14]) ? {27'd0, ifid_instr[19:15]} : rf_rd1;
                idex_csr_read <= csr_rdata;
                ifid_valid <= 1'b0;
            end
			
            if (im_start && !imem_active) begin
                imem_active <= 1'b1;
            end

            if (memwb_valid) begin
            end
        end
    end
endmodule
