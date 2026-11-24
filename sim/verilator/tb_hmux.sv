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
  integer cycle=0, pair_b=0, host_b=0, pair_r=0, host_r=0;
  assign m_wready = !m_bvalid && ((cycle%7)!=2) && ((aw_rp<aw_wp) || (m_awvalid && m_awready));
  otpu_mig_hmux #(.IDW(4),.AW(34),.HB(2)) dut(.*);
  always @(posedge clk) begin
    cycle <= cycle+1;
    if(rst) begin
      m_awready<=0; m_arready<=0; m_bvalid<=0; m_rvalid<=0;
      aw_wp<=0; aw_rp<=0; ar_wp<=0; ar_rp<=0; writes<=0; reads<=0;
    end else begin
      m_awready <= (cycle%5)!=1;
      m_arready <= (cycle%4)!=1;
      if(m_awvalid && m_awready) begin
        if(m_awid==4'h4) begin
          if(m_awaddr!=34'h1000 || m_awlen!=0) $fatal(1,"host AW payload mismatch");
        end else if(m_awid==4'h1) begin
          if(m_awaddr!=34'h2040 || m_awlen!=0) $fatal(1,"pair AW payload mismatch");
        end else $fatal(1,"unexpected DIMM AWID %h",m_awid);
        awq[aw_wp]<=m_awid; aw_wp<=aw_wp+1;
      end
      if(m_wvalid && m_wready && m_wlast) begin
        if(m_bvalid) $fatal(1,"B response slot unexpectedly occupied");
        if(aw_rp>=aw_wp && !(m_awvalid && m_awready))
          $fatal(1,"W beat accepted without an accepted AW owner");
        // W belongs to the oldest accepted AW, not a newer AW accepted in this cycle.
        if(aw_rp<aw_wp) begin
          if(awq[aw_rp]==4'h4) begin
            if(m_wdata !== {8{64'hfeed000000000001}} ||
               m_wstrb !== 64'h00ff00ff00ff00ff || !m_wlast)
              $fatal(1,"host W payload/owner mismatch");
          end else if(awq[aw_rp]==4'h1) begin
            if(m_wdata !== {8{64'hcafe000000000002}} ||
               m_wstrb !== 64'hff00ff00ff00ff00 || !m_wlast)
              $fatal(1,"pair W payload/owner mismatch");
          end else $fatal(1,"unexpected queued AW owner %h",awq[aw_rp]);
        end else if(m_awid==4'h4) begin
          if(m_wdata !== {8{64'hfeed000000000001}} ||
             m_wstrb !== 64'h00ff00ff00ff00ff || !m_wlast)
            $fatal(1,"same-cycle host W payload/owner mismatch");
        end else if(m_awid==4'h1) begin
          if(m_wdata !== {8{64'hcafe000000000002}} ||
             m_wstrb !== 64'hff00ff00ff00ff00 || !m_wlast)
            $fatal(1,"same-cycle pair W payload/owner mismatch");
        end
        m_bid <= (aw_rp<aw_wp) ? awq[aw_rp] : m_awid;
        aw_rp<=aw_rp+1; m_bresp<=0; m_bvalid<=1; writes<=writes+1;
      end
      if(m_bvalid && m_bready) m_bvalid<=0;
      if(p_bvalid && p_bready) begin
        if(p_bid!=4'h1) $fatal(1,"pair BID mismatch: %h",p_bid);
        if(p_bresp!=2'b00) $fatal(1,"pair BRESP mismatch: %b",p_bresp);
        pair_b<=pair_b+1;
      end
      if(h_bvalid && h_bready) begin
        if(h_bresp!=2'b00) $fatal(1,"host BRESP mismatch: %b",h_bresp);
        host_b<=host_b+1;
      end
      if(m_arvalid && m_arready) begin
        if(m_arid==4'h4) begin
          if(m_araddr!=34'h3000 || m_arlen!=0) $fatal(1,"host AR payload mismatch");
        end else if(m_arid==4'h2) begin
          if(m_araddr!=34'h4080 || m_arlen!=0) $fatal(1,"pair AR payload mismatch");
        end else $fatal(1,"unexpected DIMM ARID %h",m_arid);
        arq[ar_wp]<=m_arid; ar_wp<=ar_wp+1;
      end
      if(!m_rvalid && ar_rp<ar_wp) begin
        m_rid<=arq[ar_rp]; m_rdata<={8{64'h0123456789abcdef}} ^ {508'd0,ar_rp[3:0]};
        m_rresp<=0; m_rlast<=1; m_rvalid<=1; ar_rp<=ar_rp+1; reads<=reads+1;
      end else if(m_rvalid && m_rready) m_rvalid<=0;
      if(p_rvalid && p_rready) begin
        if(p_rid!=4'h2 || p_rdata !== ({8{64'h0123456789abcdef}} ^ 512'd1) ||
           p_rresp!=2'b00 || !p_rlast)
          $fatal(1,"pair R ID/data/response/last mismatch: %h",p_rid);
        pair_r<=pair_r+1;
      end
      if(h_rvalid && h_rready) begin
        if(h_rdata !== {8{64'h0123456789abcdef}} || h_rresp!=2'b00 || !h_rlast)
          $fatal(1,"host R data/response/last mismatch");
        host_r<=host_r+1;
      end
    end
  end
  task automatic write_master(input bit host, input logic [3:0] id);
    begin
      @(negedge clk);
      if(host) begin h_awaddr=34'h1000+id*64; h_awlen=0; h_awvalid=1; end
      else begin p_awaddr=34'h2000+id*64; p_awid=id; p_awlen=0; p_awvalid=1; end
      do @(posedge clk); while(host ? !h_awready : !p_awready);
      @(negedge clk); if(host) h_awvalid=0; else p_awvalid=0;
      if(host) begin h_wdata={8{64'hfeed000000000001}}; h_wstrb=64'h00ff00ff00ff00ff; h_wlast=1; h_wvalid=1; end
      else begin p_wdata={8{64'hcafe000000000002}}; p_wstrb=64'hff00ff00ff00ff00; p_wlast=1; p_wvalid=1; end
      do @(posedge clk); while(host ? !h_wready : !p_wready);
      @(negedge clk); if(host) h_wvalid=0; else p_wvalid=0;
    end
  endtask
  task automatic read_master(input bit host, input logic [3:0] id);
    begin
      @(negedge clk);
      if(host) begin h_araddr=34'h3000+id*64; h_arlen=0; h_arvalid=1; end
      else begin p_araddr=34'h4000+id*64; p_arid=id; p_arlen=0; p_arvalid=1; end
      do @(posedge clk); while(host ? !h_arready : !p_arready);
      @(negedge clk); if(host) h_arvalid=0; else p_arvalid=0;
    end
  endtask
  initial begin
    repeat(5) @(posedge clk); @(negedge clk); rst=0;
    fork
      write_master(0,4'h1);
      write_master(1,4'h0);
      read_master(0,4'h2);
      read_master(1,4'h0);
    join
    wait(writes==2 && reads==2);
    repeat(8) @(posedge clk);
    if(pair_b!=1 || host_b!=1 || pair_r!=1 || host_r!=1) $fatal(1,"response routing mismatch: B pair/host=%0d/%0d R pair/host=%0d/%0d",pair_b,host_b,pair_r,host_r);
    $display("PASS: concurrent pair/host AW-W-B and AR-R routing; writes=%0d reads=%0d cycles=%0d",writes,reads,cycle);
    $finish;
  end
  initial begin #200000; $fatal(1,"timeout"); end
endmodule
