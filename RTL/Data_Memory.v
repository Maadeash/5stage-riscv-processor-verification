module Data_Memory #(
  parameter INIT_FILE=""
)(
  input clk,
  input rst,
  input WE,
  input [3:0]WSTRB,
  input [31:0]A,
  input [31:0]WD,
  output reg [31:0]RD
);
  localparam MEM_WORDS=256;
  reg [31:0]ram [0:MEM_WORDS-1];
  integer i;

  initial begin
    for(i=0; i<MEM_WORDS; i=i+1)
      ram[i]=32'd0;
    if(INIT_FILE!="")
      $readmemh(INIT_FILE,ram);
  end

  always @(posedge clk or negedge rst) begin
    if(!rst) begin
      RD<=32'd0;
    end else begin
      RD<=ram[A[9:2]];
      if(WE) begin
        if(WSTRB[0]) ram[A[9:2]][7:0]<=WD[7:0];
        if(WSTRB[1]) ram[A[9:2]][15:8]<=WD[15:8];
        if(WSTRB[2]) ram[A[9:2]][23:16]<=WD[23:16];
        if(WSTRB[3]) ram[A[9:2]][31:24]<=WD[31:24];
      end
    end
  end
endmodule
