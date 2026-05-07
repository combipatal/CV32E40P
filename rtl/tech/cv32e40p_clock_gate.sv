module cv32e40p_clock_gate (
  input  logic clk_i,
  input  logic en_i,
  input  logic scan_cg_en_i,
  output logic clk_o
);

  CGLPPRX2_RVT u_icg (
    .CLK  (clk_i),
    .EN   (en_i),
    .SE   (scan_cg_en_i),
    .GCLK (clk_o)
  );

endmodule
