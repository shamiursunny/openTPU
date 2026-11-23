// ASIC subsystem top: AXI4-Lite host control + openTPU compute block.
// PCIe endpoint/DMA and the external memory controller/PHY remain platform integration blocks.
module otpu_asic_chip_top
  import otpu_pkg::*;
#(
  parameter int D=128, MCOLS=4, ACT_BLOCKS=128, ACT_ROWS=8,
  parameter int TMEM_WORDS=1<<16, IMEM_WORDS=1<<15, FIFO_DEPTH=1024,
  parameter int LANES=8, WIN=16, MXU_IMPL=2, MXU_CL=16, MXU_E=4,
  parameter int VPU_CL=2, ULANES=8,
  parameter bit HAS_DSTEP=1'b1,
  parameter int TMEM_IMPL=3, RPB=64, WPB=1,
  parameter int TMEM_NSB=2, TMEM_SBP=3, TMEM_SBH=0,
  parameter bit TMEM_RPL=1'b1, TMEM_TDP=1'b1, TMEM_GST=1'b1,
  parameter int TMEM_PMP=0, TMEM_PRK=0, TMEM_SDM=-1,
  parameter bit SEQ_WC=1'b1, ICACHE=1'b0,
  parameter int IC_LINES=16, IC_PF=2,
  parameter bit COLL_GATHER=1'b0,
  parameter bit HOSTCAL=1'b0, CHASH=1'b0, PAIR=1'b1, HAS_TEMP=1'b0, HAS_I2C=1'b0,
  parameter int PQ_WIN=1024, TRACE_DEPTH=0,
  parameter int CORE_KHZ=0, DDR_MTS=0, PLATFORM=256,
  parameter logic [31:0] BUILD_ID=32'b0, ARCH_HASH=32'b0
) (
  input logic clk,
  input logic rst,
  input logic [1:0] mem_calib,
  input logic mem_error,
  input logic ecc_ded,

  // Host BAR0 AXI4-Lite control interface.
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

  // External memory-adapter interface: compute port A.
  input logic a_rdy, b_rdy, sw_rdy, wr_idle, rd_idle,
  output logic a_req, a_we,
  output logic [31:0] a_addr, a_wdata,
  output logic [3:0] a_be,
  input logic a_rvalid,
  input logic [255:0] a_rdata,

  // External memory-adapter interface: scalar writes and port B.
  output logic sw_req,
  output logic [31:0] sw_addr, sw_wdata,
  output logic [3:0] sw_be,
  output logic b_req, b_tag, b_we,
  output logic [D/4-1:0] b_wmask,
  output logic [D*8-1:0] b_wdata,
  output logic [31:0] b_addr,
  output logic b_par,
  input logic b_rvalid, b_rtag,
  input logic [D*8-1:0] b_rdata,

  output logic ld_busy,
  output logic halted, error, wait_to, a_inval,
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

  otpu_asic_ctrl #(
    .D(D), .MCOLS(MCOLS), .LANES(LANES), .ACT_BLOCKS(ACT_BLOCKS), .ACT_ROWS(ACT_ROWS),
    .TMEM_WORDS(TMEM_WORDS), .IMEM_WORDS(IMEM_WORDS), .MXU_IMPL(MXU_IMPL),
    .TMEM_IMPL(TMEM_IMPL), .VPU_CL(VPU_CL), .ULANES(ULANES), .HAS_DSTEP(HAS_DSTEP),
    .SEQ_WC(SEQ_WC), .ICACHE(ICACHE), .HOSTCAL(HOSTCAL), .CHASH(CHASH), .PAIR(PAIR),
    .HAS_TEMP(HAS_TEMP), .HAS_I2C(HAS_I2C), .PQ_WIN(PQ_WIN), .TRACE_DEPTH(TRACE_DEPTH),
    .CORE_KHZ(CORE_KHZ), .DDR_MTS(DDR_MTS),
    .PLATFORM(PLATFORM), .BUILD_ID(BUILD_ID), .ARCH_HASH(ARCH_HASH)
  ) u_ctrl (
    .clk, .rst, .mem_calib(calib_sync), .mem_error(memerr_sync), .ecc_ded(ecc_sync), .halted, .core_error(error),
    .ld_busy, .wr_idle, .wait_to, .a_inval, .icount,
    .a_req, .a_rdy, .b_req, .b_rdy, .b_we, .sw_req, .sw_rdy,
    .s_awaddr, .s_awvalid, .s_awready, .s_wdata, .s_wstrb, .s_wvalid, .s_wready,
    .s_bresp, .s_bvalid, .s_bready, .s_araddr, .s_arvalid, .s_arready,
    .s_rdata, .s_rresp, .s_rvalid, .s_rready,
    .sys_rst, .run_rst, .ld_start, .ld_addr, .ld_n, .rinit
  );

  otpu_asic_top #(
    .D(D), .MCOLS(MCOLS), .ACT_BLOCKS(ACT_BLOCKS), .ACT_ROWS(ACT_ROWS),
    .TMEM_WORDS(TMEM_WORDS), .IMEM_WORDS(IMEM_WORDS), .FIFO_DEPTH(FIFO_DEPTH),
    .LANES(LANES), .WIN(WIN), .MXU_IMPL(MXU_IMPL), .MXU_CL(MXU_CL), .MXU_E(MXU_E),
    .VPU_CL(VPU_CL), .ULANES(ULANES), .HAS_DSTEP(HAS_DSTEP),
    .TMEM_IMPL(TMEM_IMPL), .RPB(RPB), .WPB(WPB), .TMEM_NSB(TMEM_NSB),
    .TMEM_SBP(TMEM_SBP), .TMEM_SBH(TMEM_SBH), .TMEM_RPL(TMEM_RPL),
    .TMEM_TDP(TMEM_TDP), .TMEM_GST(TMEM_GST), .TMEM_PMP(TMEM_PMP),
    .TMEM_PRK(TMEM_PRK), .TMEM_SDM(TMEM_SDM), .SEQ_WC(SEQ_WC),
    .ICACHE(ICACHE), .IC_LINES(IC_LINES), .IC_PF(IC_PF), .COLL_GATHER(COLL_GATHER)
  ) u_compute (
    .clk, .sys_rst, .rst(run_rst), .rinit, .ld_start, .ld_addr, .ld_n, .ld_busy,
    .a_rdy, .b_rdy, .sw_rdy, .wr_idle, .rd_idle,
    .a_req, .a_we, .a_addr, .a_wdata, .a_be, .a_rvalid, .a_rdata,
    .sw_req, .sw_addr, .sw_wdata, .sw_be,
    .b_req, .b_tag, .b_we, .b_wmask, .b_wdata, .b_addr, .b_par,
    .b_rvalid, .b_rtag, .b_rdata,
    .halted, .error, .wait_to, .a_inval, .icount
  );
endmodule
