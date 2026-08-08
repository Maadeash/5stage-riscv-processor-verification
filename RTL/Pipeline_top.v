module Pipeline_top(
  input clk,
  input rst,
  input timer_irq
);
  rv32i_pipeline_core core(.clk(clk),.rst(rst),.timer_irq(timer_irq));
endmodule
