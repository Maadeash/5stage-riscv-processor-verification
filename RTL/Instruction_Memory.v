module Instruction_Memory #(
  parameter INIT_FILE=""
)(
  input clk,
  input rst,
  input [31:0]A,
  output reg [31:0]RD
);
  localparam MEM_WORDS=256;
  reg [31:0]rom [0:MEM_WORDS-1];
  integer i;
  initial begin
    for(i=0; i<MEM_WORDS; i=i+1)
      rom[i]=32'h00000013;
    if(INIT_FILE!="") begin
      $readmemh(INIT_FILE,rom);
    end else begin
      rom[0]=32'h00500093;
      rom[1]=32'h00700113;
      rom[2]=32'h002081B3;
      rom[3]=32'h00302023;
      rom[4]=32'h00002203;
      rom[5]=32'h00000073;
    end
  end
  always @(posedge clk or negedge rst) begin
    if(!rst)
      RD<=32'd0;
    else
      RD<=rom[A[9:2]];
  end
endmodule
