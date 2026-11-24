// Lint-only black boxes for the ASIC SRAM macro leaves. These declarations let
// the lint tool elaborates the ASIC technology wrappers without pretending that macro
// functionality, timing, or physical implementation has been verified.
(* blackbox *)
module otpu_sram_1r1w #(
  parameter int W = 1,
  parameter int N = 2
) (
  input logic clk, re, we,
  input logic [$clog2(N)-1:0] ra, wa,
  input logic [W-1:0] wd, wm,
  output logic [W-1:0] rd
);
endmodule

(* blackbox *)
module otpu_sram_1rw #(
  parameter int W = 1,
  parameter int N = 2
) (
  input logic clk, en, we,
  input logic [$clog2(N)-1:0] a,
  input logic [W-1:0] wd, wm,
  output logic [W-1:0] rd
);
endmodule

(* blackbox *)
module otpu_sram_1rw1r #(
  parameter int W = 1,
  parameter int N = 2
) (
  input logic clk, ena, wea, enb,
  input logic [$clog2(N)-1:0] aa, ab,
  input logic [W-1:0] wd, wm,
  output logic [W-1:0] rda, rdb
);
endmodule
