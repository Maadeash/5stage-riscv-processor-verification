module Forwarding_Unit(
  input [4:0]Rs1E,
  input [4:0]Rs2E,
  input [4:0]RdM,
  input [4:0]RdW,
  input RegWriteM,
  input RegWriteW,
  input MemReadM,
  output reg [1:0]ForwardAE,
  output reg [1:0]ForwardBE
);
  always @* begin
    ForwardAE=2'b00;
    ForwardBE=2'b00;
    if(RegWriteM&&!MemReadM&&(RdM!=5'd0)&&(RdM==Rs1E)) ForwardAE=2'b10;
    else if(RegWriteW&&(RdW!=5'd0)&&(RdW==Rs1E)) ForwardAE=2'b01;
    if(RegWriteM&&!MemReadM&&(RdM!=5'd0)&&(RdM==Rs2E)) ForwardBE=2'b10;
    else if(RegWriteW&&(RdW!=5'd0)&&(RdW==Rs2E)) ForwardBE=2'b01;
    $display("FWD_DBG: t=%0t Rs1E=%0d Rs2E=%0d RdM=%0d RdW=%0d RWM=%0b RWW=%0b MRM=%0b -> A=%0d B=%0d",
         $time,Rs1E,Rs2E,RdM,RdW,RegWriteM,RegWriteW,MemReadM,ForwardAE,ForwardBE);
  end
endmodule
