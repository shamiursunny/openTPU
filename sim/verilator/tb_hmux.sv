`timescale 1ns/1ps
module tb_hmux;
  logic clk=0, rst=1;
  always #5 clk=~clk;
  logic p_awvalid=0,p_awready,p_wvalid=0,p_wready,p_bvalid,p_bready=1;
  logic [3:0] p_awid='0,p_bid;
  logic [33:0] p_awaddr='0;
  logic [7:0] p_awlen='0;
  logic [511:0] p_wdata='0;
  logic [63:0] p_wstrb='1;
  logic p_wlast=1;
  logic [1:0] p_bresp;
  logic p_arvalid=0,p_arready,p_rvalid,p_rready=1;
  logic [3:0] p_arid='0,p_rid;
  logic [33:0] p_araddr='0;
  logic [7:0] p_arlen='0;
  logic [511:0] p_rdata;
  logic [1:0] p_rresp;
  logic p_rlast;
  logic h_awvalid=0,h_awready,h_wvalid=0,h_wready,h_bvalid,h_bready=1;
  logic [33:0] h_awaddr='0;
  logic [7:0] h_awlen=0;
  logic [511:0] h_wdata='0;
  logic [63:0] h_wstrb='1;
  logic h_wlast=1;
  logic [1:0] h_bresp;
  logic h_arvalid=0,h_arready,h_rvalid,h_rready=1;
  logic [33:0] h_araddr='0;
  logic [7:0] h_arlen=0;
  logic [511:0] h_rdata;
  logic [1:0] h_rresp;
  logic h_rlast;
  logic m_awvalid,m_awready=0;
  logic [3:0] m_awid;
  logic [33:0] m_awaddr;
  logic [7:0] m_awlen;
  logic m_wvalid,m_wready=0;
  logic [511:0] m_wdata;
  logic [63:0] m_wstrb;
  logic m_wlast;
  logic m_bvalid=0,m_bready;
  logic [3:0] m_bid=0;
  logic [1:0] m_bresp=0;
  logic m_arvalid,m_arready=0;
  logic [3:0] m_arid;
  logic [33:0] m_araddr;
  logic [7:0] m_arlen;
  logic m_rvalid=0,m_rready;
  logic [3:0] m_rid=0;
  logic [511:0] m_rdata='0;
  logic [1:0] m_rresp=0;
  logic m_rlast=1;
  logic [3:0] awq[0:7], arq[0:7];
  integer aw_wp=0,aw_rp=0,ar_wp=0,ar_rp=0, writes=0,reads=0;
  integer cycle=0;
  otpu_mig_hmux #(.IDW(4),.AW(34),.HB(2)) dut(.*);
  always @(posedge clk) begin
    cycle <= cycle+1;
    if(rst) begin
      m_awready<=0; m_wready<=0; m_arready<=0; m_bvalid<=0; m_rvalid<=0;
      aw_wp<=0; aw_rp<=0; ar_wp<=0; ar_rp<=0; writes<=0; reads<=0;
    end else begin
      m_awready <= (cycle%5)!=1;
      m_wready <= (cycle%7)!=2;
      m_arready <= (cycle%4)!=1;
      if(m_awvalid && m_awready) begin awq[aw_wp]<=m_awid; aw_wp<=aw_wp+1; end
      if(m_wvalid && m_wready && m_wlast) begin
        if(m_bvalid) $fatal(1,"B response slot unexpectedly occupied");
        m_bid<=awq[aw_rp]; aw_rp<=aw_rp+1; m_bresp<=0; m_bvalid<=1; writes<=writes+1;
      end
      if(m_bvalid && m_bready) m_bvalid<=0;
      if(m_arvalid && m_arready) begin arq[ar_wp]<=m_arid; ar_wp<=ar_wp+1; end
      if(!m_rvalid && ar_rp<ar_wp) begin
        m_rid<=arq[ar_rp]; m_rdata<={16{64'h0123456789abcdef}} ^ {30'd0,ar_rp[3:0]};
        m_rresp<=0; m_rlast<=1; m_rvalid<=1; ar_rp<=ar_rp+1; reads<=reads+1;
      end else if(m_rvalid && m_rready) m_rvalid<=0;
    end
  end
  task automatic write_master(input bit host, input logic [3:0] id);
    begin
      @(negedge clk);
      if(host) begin h_awaddr<=34'h1000+id*64; h_awlen<=0; h_awvalid<=1; end
      else begin p_awaddr<=34'h2000+id*64; p_awid<=id; p_awlen<=0; p_awvalid<=1; end
      do @(posedge clk); while(host ? !h_awready : !p_awready);
      @(negedge clk); if(host) h_awvalid<=0; else p_awvalid<=0;
      if(host) begin h_wdata<={8{64'hfeed000000000001}}; h_wstrb<=64'h00ff00ff00ff00ff; h_wlast<=1; h_wvalid<=1; end
      else begin p_wdata<={8{64'hcafe000000000002}}; p_wstrb<=64'hff00ff00ff00ff00; p_wlast<=1; p_wvalid<=1; end
      do @(posedge clk); while(host ? !h_wready : !p_wready);
      @(negedge clk); if(host) h_wvalid<=0; else p_wvalid<=0;
    end
  endtask
  task automatic read_master(input bit host, input logic [3:0] id);
    begin
      @(negedge clk);
      if(host) begin h_araddr<=34'h3000+id*64; h_arlen<=0; h_arvalid<=1; end
      else begin p_araddr<=34'h4000+id*64; p_arid<=id; p_arlen<=0; p_arvalid<=1; end
      do @(posedge clk); while(host ? !h_arready : !p_arready);
      @(negedge clk); if(host) h_arvalid<=0; else p_arvalid<=0;
    end
  endtask
  initial begin
    repeat(5) @(posedge clk); rst<=0;
    fork
      write_master(0,4'h1);
      write_master(1,4'h0);
      read_master(0,4'h2);
      read_master(1,4'h0);
    join
    wait(writes==2 && reads==2);
    repeat(8) @(posedge clk);
    if(!p_bvalid || !h_bvalid) $fatal(1,"response routing incomplete");
    $display("PASS: concurrent pair/host AW-W-B and AR-R routing; writes=%0d reads=%0d cycles=%0d",writes,reads,cycle);
    $finish;
  end
  initial begin #200000; $fatal(1,"timeout"); end
endmodule
