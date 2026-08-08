module Hazard_unit(
  input MemReadE,
  input [4:0]RdE,
  input [4:0]Rs1D,
  input [4:0]Rs2D,
  input stall_mem,
  input redirect_flush,
  output StallF,
  output StallD,
  output FlushD,
  output FlushE
);
  wire load_use=MemReadE&&(RdE!=5'd0)&&((RdE==Rs1D)||(RdE==Rs2D));
  assign StallF=stall_mem||load_use;
  assign StallD=stall_mem||load_use;
  assign FlushD=redirect_flush;
  assign FlushE=redirect_flush||load_use;
endmodule
