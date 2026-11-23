// High-address decode check for the WG8 ASIC's 36-bit DRAM address contract.
// 16 GiB byte address = 2^32 word address; this must not truncate to the 32-bit legacy path.
module tb_asic_aw36;
  localparam int AW=36, WA=34, NCH=8, CB=128, CAW=26;
  logic clk=0, rst=1, a_flush=0;
  always #5 clk=~clk;

  logic a_rdy_x, a_req_x=0, a_we_x=0;
  logic [WA-1:0] a_addr_x=0;
  logic [31:0] a_wdata_x=0;
  logic [3:0] a_be_x=0;
  logic a_rvalid;
  logic [CB*8-1:0] a_rdata;

  logic sw_rdy, sw_req=0;
  logic [WA-1:0] sw_addr=0;
  logic [31:0] sw_wdata=0;
  logic [3:0] sw_be=0;

  logic b_rdy, b_req=0, b_tag=0, b_we=0;
  logic [31:0] b_wmask=0;
  logic [1023:0] b_wdata=0;
  logic [WA-1:0] b_addr=0;
  logic [$clog2(NCH)-1:0] b_par=0;
  logic b_rvalid, b_rtag;
  logic [1023:0] b_rdata;

  logic w_rdy, w_req=0;
  logic [WA-1:0] w_addr=0;
  logic [8:0] w_slot=0;
  logic w_one=0;
  logic [NCH-1:0] w_bv;
  logic [NCH*CB*8-1:0] w_bd;
  logic wr_idle, rd_idle;

  logic [NCH-1:0] n_cvalid, n_cready='1, n_cwe;
  logic [NCH-1:0][CAW-1:0] n_caddr;
  logic [NCH-1:0][1:0] n_csrc;
  logic [NCH-1:0][8:0] n_cslot;
  logic [NCH-1:0] n_wvalid, n_wready='1;
  logic [NCH-1:0][CB*8-1:0] n_wdata;
  logic [NCH-1:0][CB-1:0] n_wmask;
  logic [NCH-1:0] n_rvalid='0;
  logic [NCH-1:0][CB*8-1:0] n_rdata='0;
  logic [NCH-1:0][15:0] n_wdone='0;
  logic [NCH-1:0][5:0] n_wfree='0;
  logic [NCH-1:0][10:0] p_cntg='0, p_cnt;

  otpu_native_dram #(
    .D(128), .NCH(NCH), .CB(CB), .QD(4), .WQD(4),
    .RD(2), .AD(2), .XD(2), .APF(1), .AB(CB),
    .SW_FILL(1'b1), .WPOST(1'b0), .XPOST(1'b0), .CHASH(1'b0),
    .SWG(1'b0), .RHB(1'b0), .WHB(1'b0), .AW(AW), .WA(WA)
  ) dut (
    .clk, .rst, .a_flush,
    .a_rdy_x, .a_req_x, .a_we_x, .a_addr_x, .a_wdata_x, .a_be_x, .a_rvalid, .a_rdata,
    .sw_rdy, .sw_req, .sw_addr, .sw_wdata, .sw_be,
    .b_rdy, .b_req, .b_tag, .b_we, .b_wmask, .b_wdata, .b_addr, .b_par,
    .b_rvalid, .b_rtag, .b_rdata,
    .w_rdy, .w_req, .w_addr, .w_slot, .w_one, .w_bv, .w_bd,
    .wr_idle, .rd_idle,
    .n_cvalid, .n_cready, .n_cwe, .n_caddr, .n_csrc, .n_cslot,
    .n_wvalid, .n_wready, .n_wdata, .n_wmask, .n_rvalid, .n_rdata,
    .n_wdone, .n_wfree, .p_cntg, .p_cnt
  );

  integer cycles=0;
  always @(posedge clk) begin
    if (!rst) begin
      cycles <= cycles + 1;
      if (|n_cvalid) begin
        if (n_cvalid !== 8'b0000_0001)
          $fatal(1,"AW36 channel decode wrong: n_cvalid=%h",n_cvalid);
        if (n_caddr[0] !== 26'h1000000)
          $fatal(1,"AW36 channel address truncated: got=%h expected=1000000",n_caddr[1]);
        $display("PASS: 16-GiB byte address retained through AW36 decode; channel=0 local-beat=0x1000000");
        $finish;
      end
      if (cycles > 100) $fatal(1,"AW36 command timeout");
    end
  end

  initial begin
    repeat (3) @(posedge clk);
    @(negedge clk); rst=0;
    wait (a_rdy_x);
    @(negedge clk);
    a_addr_x = 34'h1_0000_0000; // word address 2^32 = byte address 16 GiB
    a_req_x = 1'b1;
    @(posedge clk);
    @(negedge clk); a_req_x=1'b0;
  end
endmodule
