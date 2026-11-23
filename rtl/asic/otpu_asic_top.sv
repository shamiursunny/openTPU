// Portable ASIC compute block. The external memory adapter owns controller/PHY and PCIe DMA.
module otpu_asic_top
  import otpu_pkg::*;
#(
  parameter int D=128, MCOLS=4, ACT_BLOCKS=128, ACT_ROWS=MCOLS,
  parameter int TMEM_WORDS=1<<16, IMEM_WORDS=1<<15, FIFO_DEPTH=1024,
  parameter int LANES=8, WIN=16, MXU_IMPL=2, MXU_CL=16, MXU_E=0,
  parameter int VPU_CL=2, ULANES=LANES, MXU_QD=2, WG=1, PQ_WIN=1024,
  parameter int QUANT_XD=1024, QUANT_PW=1, QUANT_SWW=1,
  parameter bit QUANT_R1=1'b0, QUANT_SPLIT=1'b0, QUANT_HL=1'b0,
  parameter bit QUANT_QSTB=1'b0, QUANT_QSTHL=1'b0, QONCE=1'b0,
  parameter bit HAS_DSTEP=1'b1,
  parameter int TMEM_IMPL=1, RPB=1, WPB=1, TMEM_NCP=3,
  parameter int TMEM_NSB=8, TMEM_SBP=3, TMEM_SBH=0,
  parameter bit TMEM_RQ=1'b0, TMEM_RPL=1'b0, TMEM_TDP=1'b0, TMEM_GST=1'b0,
  parameter int TMEM_PMP=0, TMEM_PRK=0, TMEM_SDM=-1,
  parameter string TMEM_STYLE="block", IMEM_STYLE="auto", IMEM_WC_STYLE="",
  parameter string MXU_RF_STYLE="block", MXU_FIFO_STYLE="block",
  parameter bit MXU_WASK=1'b1, MXU_BRAW=1'b1, MXU_AASK=1'b1,
  parameter int MXU_RF_ROWS=0, MXU_SPL=0, MXU_PUMP=0,
  parameter int ACT_UCOLS=0, VPU_CNS=3, VPU_FSUM=0, VPU_SIG=0, VPU_MAC=0,
  parameter int VPU_OUTER1=0, SE_R=0, DMA_DEPTH=128, DMA_LDQ=1,
  parameter bit SEQ_WC=1'b0, ICACHE=1'b0, OUTER=1'b1,
  parameter int IC_LINES=16, IC_PF=2,
  parameter bit DSTEP2=1'b0, ST16S=1'b0, KT=1'b0,
  parameter int ST16=0, XQB=0,
  parameter bit XPOST=1'b0,
  parameter int NCH=2, CB=64, AW=32, WA=waw(AW), AB=(WG>1)?CB:32,
  parameter bit COLL_GATHER=1'b1
) (
  input logic clk, sys_rst, rst,
  input logic [7:0][31:0] rinit,
  input logic ld_start,
  input logic [31:0] ld_addr, ld_n,
  output logic ld_busy,

  input logic a_rdy, b_rdy, sw_rdy, wr_idle, rd_idle,
  output logic a_req, a_we,
  output logic [WA-1:0] a_addr,
  output logic [31:0] a_wdata,
  output logic [3:0] a_be,
  input logic a_rvalid,
  input logic [AB*8-1:0] a_rdata,

  output logic sw_req,
  output logic [WA-1:0] sw_addr,
  output logic [32*QUANT_SWW-1:0] sw_wdata,
  output logic [4*QUANT_SWW-1:0] sw_be,

  output logic b_req, b_tag, b_we,
  output logic [D/4-1:0] b_wmask,
  output logic [D*8-1:0] b_wdata,
  output logic [WA-1:0] b_addr,
  output logic [$clog2(NCH)-1:0] b_par,
  input logic b_rvalid, b_rtag,
  input logic [D*8-1:0] b_rdata,

  input logic pw_rdy,
  output logic pw_req,
  output logic [WA-1:0] pw_addr,
  input logic [NCH-1:0] pw_bv,
  input logic [NCH*CB*8-1:0] pw_bd,
  output logic [$clog2(FIFO_DEPTH)-1:0] pw_slot,
  output logic pw_one,
  input logic p_clk,
  input logic [NCH-1:0] p_we,
  input logic [NCH-1:0][1:0][((XQB>0)?(1<<XQB):1)-1:0] p_q,
  input logic [NCH-1:0][4:0][$clog2(FIFO_DEPTH)-1:0] p_slot,
  input logic [NCH-1:0][(D*8 >> XQB)-1:0] p_d,
  input logic [NCH-1:0][$clog2(FIFO_DEPTH)+1:0] p_cnt,

  output logic halted, error, wait_to, a_inval,
  output logic [31:0] icount
);
  initial begin
    if (TMEM_PMP != 0) $fatal(1,"otpu_asic_top: TMEM_PMP must be 0 (no 2x SRAM clock)");
    if (MXU_PUMP != 0) $fatal(1,"otpu_asic_top: MXU_PUMP must be 0 (no 2x array clock)");
    if (WA != waw(AW) || AB != ((WG>1)?CB:32))
      $fatal(1,"otpu_asic_top: inconsistent address/data widths");
  end

  logic [31:0] rinit_a [8];
  always_comb for (int k=0;k<8;k++) rinit_a[k]=rinit[k];

  logic coll_req, coll_ack, coll_gl, coll_gerr, s_error;
  cmd_t coll_cmd [1];
  logic [0:0][LANES-1:0] coll_ren;
  logic [0:0][LANES-1:0][31:0] coll_raddr, coll_rdata;
  logic [LANES-1:0] coll_wen;
  logic [LANES-1:0][31:0] coll_waddr, coll_wdata;

  otpu_slice #(
    .SID(0), .S(1), .D(D), .MCOLS(MCOLS), .ACT_BLOCKS(ACT_BLOCKS), .ACT_ROWS(ACT_ROWS),
    .TMEM_WORDS(TMEM_WORDS), .IMEM_WORDS(IMEM_WORDS), .FIFO_DEPTH(FIFO_DEPTH),
    .LANES(LANES), .WIN(WIN), .RPB(RPB), .WPB(WPB), .MXU_IMPL(MXU_IMPL),
    .MXU_CL(MXU_CL), .MXU_E(MXU_E), .MXU_QD(MXU_QD), .WG(WG),
    .QUANT_XD(QUANT_XD), .QUANT_R1(QUANT_R1), .QUANT_PW(QUANT_PW),
    .QUANT_SPLIT(QUANT_SPLIT), .QUANT_HL(QUANT_HL), .QUANT_SWW(QUANT_SWW),
    .QUANT_QSTB(QUANT_QSTB), .QUANT_QSTHL(QUANT_QSTHL), .QONCE(QONCE),
    .VPU_CL(VPU_CL), .ULANES(ULANES), .PQ_WIN(PQ_WIN), .HAS_DSTEP(HAS_DSTEP),
    .TMEM_IMPL(TMEM_IMPL), .TMEM_RQ(TMEM_RQ), .TMEM_NCP(TMEM_NCP),
    .TMEM_NSB(TMEM_NSB), .TMEM_SBP(TMEM_SBP), .TMEM_SBH(TMEM_SBH),
    .TMEM_RPL(TMEM_RPL), .TMEM_TDP(TMEM_TDP), .TMEM_GST(TMEM_GST),
    .TMEM_PMP(TMEM_PMP), .TMEM_STYLE(TMEM_STYLE), .TMEM_PRK(TMEM_PRK), .TMEM_SDM(TMEM_SDM),
    .IMEM_STYLE(IMEM_STYLE), .IMEM_WC_STYLE(IMEM_WC_STYLE),
    .MXU_RF_STYLE(MXU_RF_STYLE), .MXU_FIFO_STYLE(MXU_FIFO_STYLE),
    .MXU_WASK(MXU_WASK), .MXU_RF_ROWS(MXU_RF_ROWS), .MXU_BRAW(MXU_BRAW),
    .MXU_AASK(MXU_AASK), .ACT_UCOLS(ACT_UCOLS), .SEQ_WC(SEQ_WC),
    .ICACHE(ICACHE), .IC_LINES(IC_LINES), .IC_PF(IC_PF),
    .VPU_FSUM(VPU_FSUM), .VPU_SIG(VPU_SIG), .VPU_MAC(VPU_MAC),
    .VPU_OUTER1(VPU_OUTER1), .VPU_CNS(VPU_CNS), .OUTER(OUTER),
    .SE_R(SE_R), .DMA_DEPTH(DMA_DEPTH), .DMA_LDQ(DMA_LDQ), .MXU_PUMP(MXU_PUMP),
    .MXU_SPL(MXU_SPL), .DSTEP2(DSTEP2), .ST16(ST16), .ST16S(ST16S), .KT(KT),
    .NCH(NCH), .CB(CB), .AW(AW), .WA(WA), .XPOST(XPOST), .XQB(XQB)
  ) u_slice (
    .clk, .clk_f(1'b0), .sys_rst, .rst, .rinit(rinit_a), .ld_start, .ld_addr, .ld_n, .ld_busy,
    .a_rdy, .b_rdy, .sw_rdy, .wr_idle, .rd_idle,
    .a_req, .a_we, .a_addr, .a_wdata, .a_be, .a_rvalid, .a_rdata,
    .sw_req, .sw_addr, .sw_wdata, .sw_be,
    .b_req, .b_tag, .b_we, .b_wmask, .b_wdata, .b_addr, .b_par, .b_rvalid, .b_rtag, .b_rdata,
    .pw_rdy, .pw_req, .pw_addr, .pw_bv, .pw_bd, .pw_slot, .pw_one,
    .p_clk, .p_we, .p_q, .p_slot, .p_d, .p_cnt,
    .coll_req, .coll_cmd(coll_cmd[0]), .coll_ack,
    .coll_ren(coll_ren[0]), .coll_raddr(coll_raddr[0]), .coll_rdata(coll_rdata[0]),
    .coll_wen, .coll_waddr, .coll_wdata, .coll_wtop(1'b1),
    .coll_gnt_local(coll_gl), .coll_gnt(coll_gl),
    .halted, .error(s_error), .wait_to, .a_inval, .icount, .pf(), .dump(1'b0)
  );

  if (COLL_GATHER) begin : g_coll
    otpu_coll #(.S(1), .LANES(LANES)) u_coll (
      .clk, .rst, .req(coll_req), .cmds(coll_cmd), .gnt(coll_gl), .ack(coll_ack),
      .r_en(coll_ren), .r_addr(coll_raddr), .r_data(coll_rdata),
      .w_en(coll_wen), .w_addr(coll_waddr), .w_data(coll_wdata));
    assign coll_gerr=1'b0;
  end else begin : g_coll_bar
    otpu_coll_bar #(.S(1), .LANES(LANES)) u_coll (
      .clk, .rst, .req(coll_req), .cmds(coll_cmd), .gnt(coll_gl), .ack(coll_ack),
      .r_en(coll_ren), .r_addr(coll_raddr), .r_data(coll_rdata),
      .w_en(coll_wen), .w_addr(coll_waddr), .w_data(coll_wdata), .gerr(coll_gerr));
  end
  assign error=s_error || coll_gerr;
endmodule
