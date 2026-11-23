// ASIC control + compute subsystem. PCIe endpoint/DMA and memory controller/PHY are external.
module otpu_asic_chip_top
  import otpu_pkg::*;
#(
  parameter int D=128, MCOLS=8, ACT_BLOCKS=128, ACT_ROWS=16,
  parameter int TMEM_WORDS=1<<17, IMEM_WORDS=1<<15, FIFO_DEPTH=2048,
  parameter int LANES=8, WIN=32, MXU_IMPL=2, MXU_CL=16, MXU_E=8,
  parameter int VPU_CL=2, ULANES=8, MXU_QD=4, WG=8, PQ_WIN=1024,
  parameter int QUANT_XD=1024, QUANT_PW=2, QUANT_SWW=1,
  parameter bit QUANT_R1=1'b1, QUANT_SPLIT=1'b0, QUANT_HL=1'b0,
  parameter bit QUANT_QSTB=1'b0, QUANT_QSTHL=1'b0, QONCE=1'b0,
  parameter bit HAS_DSTEP=1'b1,
  parameter int TMEM_IMPL=3, RPB=64, WPB=1, TMEM_NCP=3,
  parameter int TMEM_NSB=2, TMEM_SBP=3, TMEM_SBH=0,
  parameter bit TMEM_RQ=1'b0, TMEM_RPL=1'b1, TMEM_TDP=1'b1, TMEM_GST=1'b1,
  parameter int TMEM_PMP=0, TMEM_PRK=0, TMEM_SDM=-1,
  parameter string TMEM_STYLE="block", IMEM_STYLE="auto", IMEM_WC_STYLE="",
  parameter string MXU_RF_STYLE="block", MXU_FIFO_STYLE="block",
  parameter bit MXU_WASK=1'b1, MXU_BRAW=1'b1, MXU_AASK=1'b1,
  parameter int MXU_RF_ROWS=0, MXU_SPL=0, MXU_PUMP=0,
  parameter int ACT_UCOLS=0, VPU_CNS=3, VPU_FSUM=0, VPU_SIG=0, VPU_MAC=0,
  parameter int VPU_OUTER1=0, SE_R=2, DMA_DEPTH=512, DMA_LDQ=1,
  parameter bit SEQ_WC=1'b1, ICACHE=1'b0, OUTER=1'b0,
  parameter int IC_LINES=64, IC_PF=2,
  parameter bit DSTEP2=1'b1, ST16S=1'b0, KT=1'b1,
  parameter int ST16=1, XQB=0,
  parameter bit XPOST=1'b0,
  parameter int NCH=8, CB=128, AW=36, WA=waw(AW), AB=(WG>1)?CB:32,
  parameter bit COLL_GATHER=1'b0,

  // v5 host-control capability/configuration fields.
  parameter bit HOSTCAL=1'b0, CHASH=1'b1, PAIR=(WG==1),
  parameter bit HAS_TEMP=1'b0, HAS_I2C=1'b0,
  parameter int TRACE_DEPTH=0, CORE_KHZ=0, DDR_MTS=0, PLATFORM=256,
  parameter logic [31:0] BUILD_ID=32'b0, ARCH_HASH=32'b0
) (
  input logic clk, rst,
  input logic [1:0] mem_calib,   // two synchronised memory groups; all physical channels must be ready
  input logic mem_error, ecc_ded,

  // PCIe BAR0 AXI4-Lite control interface (PCIe endpoint is external).
  input logic [11:0] s_awaddr,
  input logic s_awvalid,
  output logic s_awready,
  input logic [31:0] s_wdata,
  input logic [3:0] s_wstrb,
  input logic s_wvalid,
  output logic s_wready,
  output logic [1:0] s_bresp,
  output logic s_bvalid,
  input logic s_bready,
  input logic [11:0] s_araddr,
  input logic s_arvalid,
  output logic s_arready,
  output logic [31:0] s_rdata,
  output logic [1:0] s_rresp,
  output logic s_rvalid,
  input logic s_rready,

  // Core-memory adapter interface. All handshakes/data are in clk domain.
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

  // Port W: wide weight-group reads (unused when WG=1).
  input logic pw_rdy,
  output logic pw_req,
  output logic [WA-1:0] pw_addr,
  input logic [NCH-1:0] pw_bv,
  input logic [NCH*CB*8-1:0] pw_bd,
  output logic [$clog2(FIFO_DEPTH)-1:0] pw_slot,
  output logic pw_one,

  output logic ld_busy, halted, error, wait_to, a_inval,
  output logic [31:0] icount
);
  logic sys_rst, run_rst, ld_start;
  (* ASYNC_REG = "TRUE" *) logic [1:0] calib_meta, calib_sync;
  (* ASYNC_REG = "TRUE" *) logic memerr_meta, memerr_sync, ecc_meta, ecc_sync;
  always_ff @(posedge clk) begin
    if (rst) begin
      calib_meta <= '0; calib_sync <= '0;
      memerr_meta <= 1'b0; memerr_sync <= 1'b0;
      ecc_meta <= 1'b0; ecc_sync <= 1'b0;
    end else begin
      calib_meta <= mem_calib; calib_sync <= calib_meta;
      memerr_meta <= mem_error; memerr_sync <= memerr_meta;
      ecc_meta <= ecc_ded; ecc_sync <= ecc_meta;
    end
  end
  logic [31:0] ld_addr, ld_n;
  logic [7:0][31:0] rinit;

  initial if (XPOST) $fatal(1,"otpu_asic_chip_top: XPOST channel writes require an explicit posted-beat clock interface");

  otpu_asic_ctrl #(
    .D(D), .MCOLS(MCOLS), .LANES(LANES), .ACT_BLOCKS(ACT_BLOCKS), .ACT_ROWS(ACT_ROWS),
    .TMEM_WORDS(TMEM_WORDS), .IMEM_WORDS(IMEM_WORDS), .MXU_IMPL(MXU_IMPL),
    .TMEM_IMPL(TMEM_IMPL), .VPU_CL(VPU_CL), .ULANES(ULANES), .HAS_DSTEP(HAS_DSTEP),
    .SEQ_WC(SEQ_WC), .ICACHE(ICACHE), .HOSTCAL(HOSTCAL), .CHASH(CHASH), .PAIR(PAIR),
    .HAS_TEMP(HAS_TEMP), .HAS_I2C(HAS_I2C), .PQ_WIN(PQ_WIN), .TRACE_DEPTH(TRACE_DEPTH),
    .CORE_KHZ(CORE_KHZ), .DDR_MTS(DDR_MTS), .PLATFORM(PLATFORM),
    .BUILD_ID(BUILD_ID), .ARCH_HASH(ARCH_HASH)
  ) u_ctrl (
    .clk, .rst, .mem_calib(calib_sync), .mem_error(memerr_sync), .ecc_ded(ecc_sync),
    .halted, .core_error(error), .ld_busy, .wr_idle, .wait_to, .a_inval, .icount,
    .a_req, .a_we, .a_rdy, .b_req, .b_rdy, .b_we, .sw_req, .sw_rdy,
    .s_awaddr, .s_awvalid, .s_awready, .s_wdata, .s_wstrb, .s_wvalid, .s_wready,
    .s_bresp, .s_bvalid, .s_bready, .s_araddr, .s_arvalid, .s_arready,
    .s_rdata, .s_rresp, .s_rvalid, .s_rready,
    .sys_rst, .run_rst, .ld_start, .ld_addr, .ld_n, .rinit
  );

  otpu_asic_top #(
    .D(D), .MCOLS(MCOLS), .ACT_BLOCKS(ACT_BLOCKS), .ACT_ROWS(ACT_ROWS),
    .TMEM_WORDS(TMEM_WORDS), .IMEM_WORDS(IMEM_WORDS), .FIFO_DEPTH(FIFO_DEPTH),
    .LANES(LANES), .WIN(WIN), .MXU_IMPL(MXU_IMPL), .MXU_CL(MXU_CL), .MXU_E(MXU_E),
    .VPU_CL(VPU_CL), .ULANES(ULANES), .MXU_QD(MXU_QD), .WG(WG), .PQ_WIN(PQ_WIN),
    .QUANT_XD(QUANT_XD), .QUANT_PW(QUANT_PW), .QUANT_SWW(QUANT_SWW),
    .QUANT_R1(QUANT_R1), .QUANT_SPLIT(QUANT_SPLIT), .QUANT_HL(QUANT_HL),
    .QUANT_QSTB(QUANT_QSTB), .QUANT_QSTHL(QUANT_QSTHL), .QONCE(QONCE),
    .HAS_DSTEP(HAS_DSTEP), .TMEM_IMPL(TMEM_IMPL), .RPB(RPB), .WPB(WPB),
    .TMEM_NCP(TMEM_NCP), .TMEM_NSB(TMEM_NSB), .TMEM_SBP(TMEM_SBP), .TMEM_SBH(TMEM_SBH),
    .TMEM_RQ(TMEM_RQ), .TMEM_RPL(TMEM_RPL), .TMEM_TDP(TMEM_TDP), .TMEM_GST(TMEM_GST),
    .TMEM_PMP(TMEM_PMP), .TMEM_PRK(TMEM_PRK), .TMEM_SDM(TMEM_SDM), .TMEM_STYLE(TMEM_STYLE),
    .IMEM_STYLE(IMEM_STYLE), .IMEM_WC_STYLE(IMEM_WC_STYLE),
    .MXU_RF_STYLE(MXU_RF_STYLE), .MXU_FIFO_STYLE(MXU_FIFO_STYLE),
    .MXU_WASK(MXU_WASK), .MXU_BRAW(MXU_BRAW), .MXU_AASK(MXU_AASK),
    .MXU_RF_ROWS(MXU_RF_ROWS), .MXU_SPL(MXU_SPL), .MXU_PUMP(MXU_PUMP),
    .ACT_UCOLS(ACT_UCOLS), .VPU_CNS(VPU_CNS), .VPU_FSUM(VPU_FSUM),
    .VPU_SIG(VPU_SIG), .VPU_MAC(VPU_MAC), .VPU_OUTER1(VPU_OUTER1),
    .SE_R(SE_R), .DMA_DEPTH(DMA_DEPTH), .DMA_LDQ(DMA_LDQ), .SEQ_WC(SEQ_WC),
    .ICACHE(ICACHE), .OUTER(OUTER), .IC_LINES(IC_LINES), .IC_PF(IC_PF),
    .DSTEP2(DSTEP2), .ST16S(ST16S), .KT(KT), .ST16(ST16), .XQB(XQB), .XPOST(XPOST),
    .NCH(NCH), .CB(CB), .AW(AW), .WA(WA), .AB(AB), .COLL_GATHER(COLL_GATHER)
  ) u_compute (
    .clk, .sys_rst, .rst(run_rst), .rinit, .ld_start, .ld_addr, .ld_n, .ld_busy,
    .a_rdy, .b_rdy, .sw_rdy, .wr_idle, .rd_idle,
    .a_req, .a_we, .a_addr, .a_wdata, .a_be, .a_rvalid, .a_rdata,
    .sw_req, .sw_addr, .sw_wdata, .sw_be,
    .b_req, .b_tag, .b_we, .b_wmask, .b_wdata, .b_addr, .b_par,
    .b_rvalid, .b_rtag, .b_rdata,
    .pw_rdy, .pw_req, .pw_addr, .pw_bv, .pw_bd, .pw_slot, .pw_one,
    .p_clk(clk), .p_we('0), .p_q('0), .p_slot('0), .p_d('0), .p_cnt('0),
    .halted, .error, .wait_to, .a_inval, .icount
  );
endmodule
