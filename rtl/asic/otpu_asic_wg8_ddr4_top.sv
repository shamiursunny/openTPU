// WG8 ASIC integration boundary: compute/native memory adapter + eight native-to-AXI bridges
// + four two-channel 512-bit DIMM ports. PCIe endpoint/DMA and foundry DDR PHY/controller IP are
// intentionally external; the host DMA master must be arbitrated with these four AXI ports by the
// selected memory-controller subsystem, with shared ordering and IOMMU protection.
module otpu_asic_wg8_ddr4_top #(
  parameter int AW = 36,
  parameter int NCH = 8,
  parameter int CB = 128,
  parameter int FIFO_DEPTH = 2048,
  parameter int CAW = AW - $clog2(NCH * CB),
  parameter int XSW = $clog2(FIFO_DEPTH),
  parameter int MWAIT = 8
) (
  input  logic clk,
  input  logic rst,
  input  logic aclk,
  input  logic [3:0] mem_reset,
  input  logic [3:0] mem_calib,
  input  logic mem_error,
  input  logic ecc_ded,

  // PCIe endpoint BAR0 AXI4-Lite control; endpoint itself is external.
  input  logic [11:0] s_awaddr,
  input  logic s_awvalid,
  output logic s_awready,
  input  logic [31:0] s_wdata,
  input  logic [3:0] s_wstrb,
  input  logic s_wvalid,
  output logic s_wready,
  output logic [1:0] s_bresp,
  output logic s_bvalid,
  input  logic s_bready,
  input  logic [11:0] s_araddr,
  input  logic s_arvalid,
  output logic s_arready,
  output logic [31:0] s_rdata,
  output logic [1:0] s_rresp,
  output logic s_rvalid,
  input  logic s_rready,

  // Host DMA: one 512-bit AXI4 master per DIMM, already translated to that DIMM's local map.
  input  logic [3:0] h_awvalid,
  output logic [3:0] h_awready,
  input  logic [3:0][33:0] h_awaddr,
  input  logic [3:0][7:0] h_awlen,
  input  logic [3:0] h_wvalid,
  output logic [3:0] h_wready,
  input  logic [3:0][511:0] h_wdata,
  input  logic [3:0][63:0] h_wstrb,
  input  logic [3:0] h_wlast,
  output logic [3:0] h_bvalid,
  input  logic [3:0] h_bready,
  output logic [3:0][1:0] h_bresp,
  input  logic [3:0] h_arvalid,
  output logic [3:0] h_arready,
  input  logic [3:0][33:0] h_araddr,
  input  logic [3:0][7:0] h_arlen,
  output logic [3:0] h_rvalid,
  input  logic [3:0] h_rready,
  output logic [3:0][511:0] h_rdata,
  output logic [3:0][1:0] h_rresp,
  output logic [3:0] h_rlast,

  // Four independent 8-GiB DIMM/controller ports, AXI4 512-bit, local address per DIMM.
  output logic [3:0] m_awvalid,
  input  logic [3:0] m_awready,
  output logic [3:0][3:0] m_awid,
  output logic [3:0][33:0] m_awaddr,
  output logic [3:0][7:0] m_awlen,
  output logic [3:0][2:0] m_awsize,
  output logic [3:0][1:0] m_awburst,
  output logic [3:0] m_awlock,
  output logic [3:0][3:0] m_awcache,
  output logic [3:0][2:0] m_awprot,
  output logic [3:0][3:0] m_awqos,
  output logic [3:0] m_wvalid,
  input  logic [3:0] m_wready,
  output logic [3:0][511:0] m_wdata,
  output logic [3:0][63:0] m_wstrb,
  output logic [3:0] m_wlast,
  input  logic [3:0] m_bvalid,
  output logic [3:0] m_bready,
  input  logic [3:0][3:0] m_bid,
  input  logic [3:0][1:0] m_bresp,
  output logic [3:0] m_arvalid,
  input  logic [3:0] m_arready,
  output logic [3:0][3:0] m_arid,
  output logic [3:0][33:0] m_araddr,
  output logic [3:0][7:0] m_arlen,
  output logic [3:0][2:0] m_arsize,
  output logic [3:0][1:0] m_arburst,
  output logic [3:0] m_arlock,
  output logic [3:0][3:0] m_arcache,
  output logic [3:0][2:0] m_arprot,
  output logic [3:0][3:0] m_arqos,
  input  logic [3:0] m_rvalid,
  output logic [3:0] m_rready,
  input  logic [3:0][3:0] m_rid,
  input  logic [3:0][511:0] m_rdata,
  input  logic [3:0][1:0] m_rresp,
  input  logic [3:0] m_rlast,

  output logic ld_busy,
  output logic halted,
  output logic error,
  output logic wait_to,
  output logic [31:0] icount,
  output logic [7:0] bridge_error
);
  localparam int CL = CAW + $clog2(CB); // 33 byte-address bits per virtual channel
  logic [1:0] mem_calib_groups;
  logic [7:0] n_cvalid, n_cready, n_cwe, n_wvalid, n_wready, n_rvalid, n_err;
  logic [7:0][CAW-1:0] n_caddr;
  logic [7:0][1:0] n_csrc;
  logic [7:0][XSW-1:0] n_cslot;
  logic [7:0][CB*8-1:0] n_wdata, n_rdata;
  logic [7:0][CB-1:0] n_wmask;
  logic [7:0][15:0] n_wdone;

  logic [7:0] ch_awvalid, ch_awready, ch_wvalid, ch_wready, ch_wlast;
  logic [7:0][33:0] ch_awaddr;
  logic [7:0][3:0] ch_awlen;
  logic [7:0][255:0] ch_wdata, ch_rdata;
  logic [7:0][31:0] ch_wstrb;
  logic [7:0] ch_bvalid, ch_bready, ch_arvalid, ch_arready, ch_rvalid, ch_rready, ch_rlast;
  logic [7:0][33:0] ch_araddr;
  logic [7:0][3:0] ch_arlen;
  logic [7:0][1:0] ch_bresp, ch_rresp;
  logic [3:0][1:0] pair_bresp;
  logic [3:0] p_awvalid, p_awready, p_wvalid, p_wready, p_wlast;
  logic [3:0][3:0] p_awid, p_bid, p_arid, p_rid;
  logic [3:0][33:0] p_awaddr, p_araddr;
  logic [3:0][7:0] p_awlen, p_arlen;
  logic [3:0][511:0] p_wdata, p_rdata;
  logic [3:0][63:0] p_wstrb;
  logic [3:0] p_bvalid, p_bready, p_arvalid, p_arready, p_rvalid, p_rready, p_rlast;
  logic [3:0][1:0] p_bresp, p_rresp;
  logic [3:0] dimm_rst_sync;
  logic [7:0] bridge_arst;

  // Reset crosses from the control domain into aclk: synchronise per DIMM, then
  // release each bridge one aclk later than its pair, matching the proven BCU topology.
  for (genvar d = 0; d < 4; d++) begin : g_reset_sync
    (* ASYNC_REG = "TRUE" *) logic [1:0] rsync;
    always_ff @(posedge aclk or posedge rst) begin
      if (rst) rsync <= 2'b11;
      else rsync <= {rsync[0], mem_reset[d]};
    end
    assign dimm_rst_sync[d] = rsync[1];
  end
  for (genvar ch = 0; ch < NCH; ch++) begin : g_bridge_reset
    logic bridge_rst_q;
    always_ff @(posedge aclk or posedge rst) begin
      if (rst) bridge_rst_q <= 1'b1;
      else bridge_rst_q <= dimm_rst_sync[ch/2];
    end
    assign bridge_arst[ch] = bridge_rst_q;
  end

  initial begin
    if (AW != 36 || NCH != 8 || CB != 128 || CAW != 26 || FIFO_DEPTH < 2)
      $fatal(1, "otpu_asic_wg8_ddr4_top: expected WG8 AW36/NCH8/CB128/CAW26 configuration");
  end

  // The control block exposes two calibration groups; both DIMMs in each group must pass.
  assign mem_calib_groups = {(&mem_calib[3:2]), (&mem_calib[1:0])};
  assign bridge_error = n_err;
  // The paired bridge emits 512-bit, 64-byte INCR transactions.
  assign m_awsize  = {4{3'd6}};
  assign m_awburst = {4{2'b01}};
  assign m_awlock  = '0;
  assign m_awcache = {4{4'b0011}};
  assign m_awprot  = '0;
  assign m_awqos   = '0;
  assign m_arsize  = {4{3'd6}};
  assign m_arburst = {4{2'b01}};
  assign m_arlock  = '0;
  assign m_arcache = {4{4'b0011}};
  assign m_arprot  = '0;
  assign m_arqos   = '0;

  otpu_asic_mem_top #(
    .AW(AW), .NCH(NCH), .CB(CB), .FIFO_DEPTH(FIFO_DEPTH), .WG(8)
  ) u_core (
    .clk, .rst, .mem_calib(mem_calib_groups),
    .mem_error(mem_error | (|n_err)), .ecc_ded,
    .s_awaddr, .s_awvalid, .s_awready, .s_wdata, .s_wstrb, .s_wvalid, .s_wready,
    .s_bresp, .s_bvalid, .s_bready, .s_araddr, .s_arvalid, .s_arready,
    .s_rdata, .s_rresp, .s_rvalid, .s_rready,
    .n_cvalid, .n_cready, .n_cwe, .n_caddr, .n_csrc, .n_cslot,
    .n_wvalid, .n_wready, .n_wdata, .n_wmask, .n_rvalid, .n_rdata, .n_wdone,
    .ld_busy, .halted, .error, .wait_to, .icount
  );

  for (genvar ch = 0; ch < NCH; ch++) begin : g_bridge
    otpu_hbm_ch #(
      .CB(CB), .CAW(CAW), .PC(5'd0), .OAW(34),
      .ARD(32), .CQD(32), .WDD(32), .WPOST(1'b0),
      .N(0), .WH(1'b0), .ACQ(16), .AWD(32), .RCD(64), .PST(1),
      .XSW(XSW), .RHB(1'b0), .WHB(1'b0), .BHW(0), .CPY(1'b0)
    ) u_bridge (
      .clk, .rst,
      .n_cvalid(n_cvalid[ch]), .n_cready(n_cready[ch]), .n_cwe(n_cwe[ch]),
      .n_caddr(n_caddr[ch]), .n_csrc(n_csrc[ch]), .n_cslot(n_cslot[ch]),
      .n_wvalid(n_wvalid[ch]), .n_wready(n_wready[ch]), .n_wfree(),
      .n_wdata(n_wdata[ch]), .n_wmask(n_wmask[ch]),
      .n_rvalid(n_rvalid[ch]), .n_rdata(n_rdata[ch]), .n_wdone(n_wdone[ch]),
      .n_err(n_err[ch]),
      .p_we(), .p_q(), .p_slot(), .p_d(), .p_cntg(),
      .aclk, .arst(bridge_arst[ch]), .mwait(6'(MWAIT)),
      .m_awvalid(ch_awvalid[ch]), .m_awready(ch_awready[ch]),
      .m_awaddr(ch_awaddr[ch]), .m_awlen(ch_awlen[ch]),
      .m_wvalid(ch_wvalid[ch]), .m_wready(ch_wready[ch]),
      .m_wdata(ch_wdata[ch]), .m_wstrb(ch_wstrb[ch]), .m_wlast(ch_wlast[ch]),
      .m_bvalid(ch_bvalid[ch]), .m_bready(ch_bready[ch]), .m_bresp(ch_bresp[ch]),
      .m_arvalid(ch_arvalid[ch]), .m_arready(ch_arready[ch]),
      .m_araddr(ch_araddr[ch]), .m_arlen(ch_arlen[ch]),
      .m_rvalid(ch_rvalid[ch]), .m_rready(ch_rready[ch]),
      .m_rdata(ch_rdata[ch]), .m_rresp(ch_rresp[ch]), .m_rlast(ch_rlast[ch]),
      .ev(), .ev_n()
    );
  end

  for (genvar d = 0; d < 4; d++) begin : g_dimm
    otpu_mig_pair #(.IDW(4), .RD(32), .CL(CL), .NC(2), .BHW(0), .WOC(1), .RS(1'b0)) u_pair (
      .clk(aclk), .rst(dimm_rst_sync[d]),
      .s_awvalid(ch_awvalid[2*d +: 2]), .s_awready(ch_awready[2*d +: 2]),
      .s_awaddr(ch_awaddr[2*d +: 2]), .s_awlen(ch_awlen[2*d +: 2]),
      .s_wvalid(ch_wvalid[2*d +: 2]), .s_wready(ch_wready[2*d +: 2]),
      .s_wdata(ch_wdata[2*d +: 2]), .s_wstrb(ch_wstrb[2*d +: 2]),
      .s_wlast(ch_wlast[2*d +: 2]),
      .s_bvalid(ch_bvalid[2*d +: 2]), .s_bready(ch_bready[2*d +: 2]),
      .s_bresp(pair_bresp[d]),
      .s_arvalid(ch_arvalid[2*d +: 2]), .s_arready(ch_arready[2*d +: 2]),
      .s_araddr(ch_araddr[2*d +: 2]), .s_arlen(ch_arlen[2*d +: 2]),
      .s_rvalid(ch_rvalid[2*d +: 2]), .s_rready(ch_rready[2*d +: 2]),
      .s_rdata(ch_rdata[2*d +: 2]), .s_rresp(ch_rresp[2*d +: 2]),
      .s_rlast(ch_rlast[2*d +: 2]),
      .m_awvalid(p_awvalid[d]), .m_awready(p_awready[d]), .m_awid(p_awid[d]),
      .m_awaddr(p_awaddr[d]), .m_awlen(p_awlen[d]),
      .m_wvalid(p_wvalid[d]), .m_wready(p_wready[d]), .m_wdata(p_wdata[d]),
      .m_wstrb(p_wstrb[d]), .m_wlast(p_wlast[d]),
      .m_bvalid(p_bvalid[d]), .m_bready(p_bready[d]), .m_bid(p_bid[d]), .m_bresp(p_bresp[d]),
      .m_arvalid(p_arvalid[d]), .m_arready(p_arready[d]), .m_arid(p_arid[d]),
      .m_araddr(p_araddr[d]), .m_arlen(p_arlen[d]),
      .m_rvalid(p_rvalid[d]), .m_rready(p_rready[d]), .m_rid(p_rid[d]),
      .m_rdata(p_rdata[d]), .m_rresp(p_rresp[d]), .m_rlast(p_rlast[d])
    );
    for (genvar k = 0; k < 2; k++) begin : g_bresp
      assign ch_bresp[2*d+k] = pair_bresp[d];
    end
  end

  // Reuse the proven BCU1525 arbitration/ID/W-ordering block: host ID is bit 2,
  // accelerator pair IDs occupy the remaining ID space. Host addresses are DIMM-local;
  // PCIe DMA must perform the card-to-DIMM/channel address permutation before this boundary.
  for (genvar d = 0; d < 4; d++) begin : g_host_mux
    otpu_mig_hmux #(.IDW(4), .AW(34), .HB(2)) u_hmux (
      .clk(aclk), .rst(dimm_rst_sync[d]),
      .p_awvalid(p_awvalid[d]), .p_awready(p_awready[d]), .p_awid(p_awid[d]),
      .p_awaddr(p_awaddr[d]), .p_awlen(p_awlen[d]),
      .p_wvalid(p_wvalid[d]), .p_wready(p_wready[d]), .p_wdata(p_wdata[d]),
      .p_wstrb(p_wstrb[d]), .p_wlast(p_wlast[d]),
      .p_bvalid(p_bvalid[d]), .p_bready(p_bready[d]), .p_bid(p_bid[d]), .p_bresp(p_bresp[d]),
      .p_arvalid(p_arvalid[d]), .p_arready(p_arready[d]), .p_arid(p_arid[d]),
      .p_araddr(p_araddr[d]), .p_arlen(p_arlen[d]),
      .p_rvalid(p_rvalid[d]), .p_rready(p_rready[d]), .p_rid(p_rid[d]),
      .p_rdata(p_rdata[d]), .p_rresp(p_rresp[d]), .p_rlast(p_rlast[d]),
      .h_awvalid(h_awvalid[d]), .h_awready(h_awready[d]), .h_awaddr(h_awaddr[d]), .h_awlen(h_awlen[d]),
      .h_wvalid(h_wvalid[d]), .h_wready(h_wready[d]), .h_wdata(h_wdata[d]),
      .h_wstrb(h_wstrb[d]), .h_wlast(h_wlast[d]),
      .h_bvalid(h_bvalid[d]), .h_bready(h_bready[d]), .h_bresp(h_bresp[d]),
      .h_arvalid(h_arvalid[d]), .h_arready(h_arready[d]), .h_araddr(h_araddr[d]), .h_arlen(h_arlen[d]),
      .h_rvalid(h_rvalid[d]), .h_rready(h_rready[d]), .h_rdata(h_rdata[d]),
      .h_rresp(h_rresp[d]), .h_rlast(h_rlast[d]),
      .m_awvalid(m_awvalid[d]), .m_awready(m_awready[d]), .m_awid(m_awid[d]),
      .m_awaddr(m_awaddr[d]), .m_awlen(m_awlen[d]),
      .m_wvalid(m_wvalid[d]), .m_wready(m_wready[d]), .m_wdata(m_wdata[d]),
      .m_wstrb(m_wstrb[d]), .m_wlast(m_wlast[d]),
      .m_bvalid(m_bvalid[d]), .m_bready(m_bready[d]), .m_bid(m_bid[d]), .m_bresp(m_bresp[d]),
      .m_arvalid(m_arvalid[d]), .m_arready(m_arready[d]), .m_arid(m_arid[d]),
      .m_araddr(m_araddr[d]), .m_arlen(m_arlen[d]),
      .m_rvalid(m_rvalid[d]), .m_rready(m_rready[d]), .m_rid(m_rid[d]),
      .m_rdata(m_rdata[d]), .m_rresp(m_rresp[d]), .m_rlast(m_rlast[d])
    );
  end
endmodule
