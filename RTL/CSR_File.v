
`include "rv32i_defs.v"
module CSR_File(
  input clk,
  input rst,
  input csr_we,
  input [1:0]csr_cmd,
  input [11:0]csr_addr,
  input [11:0]csr_raddr,
  input [31:0]csr_wdata,
  input trap_taken,
  input mret_taken,
  input [31:0]trap_cause,
  input [31:0]trap_tval,
  input [31:0]trap_epc,
  input timer_irq,
  output reg [31:0]csr_rdata,
  output reg [31:0]mtvec,
  output reg [31:0]mepc,
  output reg [31:0]mcause,
  output reg [31:0]mtval,
  output reg [31:0]mstatus,
  output reg [31:0]mie,
  output reg [31:0]mip,
  output irq_pending
);
  wire mie_global=mstatus[3];
  wire mie_mtimer=mie[7];
  assign irq_pending=timer_irq&mie_global&mie_mtimer;

  function [31:0]csr_read;
    input [11:0]a;
    begin
      case(a)
        `CSR_MSTATUS: csr_read=mstatus;
        `CSR_MIE: csr_read=mie;
        `CSR_MTVEC: csr_read=mtvec;
        `CSR_MEPC: csr_read=mepc;
        `CSR_MCAUSE: csr_read=mcause;
        `CSR_MTVAL: csr_read=mtval;
        `CSR_MIP: csr_read=mip;
        default: csr_read=32'd0;
      endcase
    end
  endfunction

  function [31:0]csr_apply;
    input [31:0]oldv;
    input [31:0]w;
    input [1:0]cmd;
    begin
      case(cmd)
        `CSR_RW: csr_apply=w;
        `CSR_RS: csr_apply=oldv|w;
        `CSR_RC: csr_apply=oldv&~w;
        default: csr_apply=oldv;
      endcase
    end
  endfunction

  always @(csr_raddr or mstatus or mie or mtvec or mepc or mcause or mtval or mip) begin
    csr_rdata=csr_read(csr_raddr);
  end

  always @(posedge clk or negedge rst) begin
    if(!rst) begin
      mstatus<=32'd0;
      mtvec<=32'd0;
      mepc<=32'd0;
      mcause<=32'd0;
      mtval<=32'd0;
      mie<=32'd0;
      mip<=32'd0;
    end else begin
      mip[7]<=timer_irq;
      if(csr_we) begin
        case(csr_addr)
          `CSR_MSTATUS: mstatus<=csr_apply(mstatus,csr_wdata,csr_cmd);
          `CSR_MIE: mie<=csr_apply(mie,csr_wdata,csr_cmd);
          `CSR_MTVEC: mtvec<=csr_apply(mtvec,csr_wdata,csr_cmd);
          `CSR_MEPC: mepc<=csr_apply(mepc,csr_wdata,csr_cmd);
          `CSR_MCAUSE: mcause<=csr_apply(mcause,csr_wdata,csr_cmd);
          `CSR_MTVAL: mtval<=csr_apply(mtval,csr_wdata,csr_cmd);
          `CSR_MIP: mip<=csr_apply(mip,csr_wdata,csr_cmd);
          default:;
        endcase
      end
      if(trap_taken) begin
        mepc<=trap_epc;
        mcause<=trap_cause;
        mtval<=trap_tval;
        mstatus[7]<=mstatus[3];
        mstatus[3]<=1'b0;
        mstatus[12:11]<=2'b11;
      end
      if(mret_taken) begin
        mstatus[3]<=mstatus[7];
        mstatus[7]<=1'b1;
        mstatus[12:11]<=2'b00;
      end
    end
  end
endmodule
