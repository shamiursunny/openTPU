`timescale 1ns/1ps
module tb_hmux;
  logic clk=0, rst=1;
  always #5 clk=~clk;
  logic p_awvalid=0,p_awready,p_wvalid=0,p_wready,p_bvalid,p_bready;
  logic [3:0] p_awid='0,p_bid;
  logic [33:0] p_awaddr='0;
  logic [7:0] p_awlen='0;
  logic [511:0] p_wdata='0;
  logic [63:0] p_wstrb='1;
  logic p_wlast=1;
  logic [1:0] p_bresp;
  logic p_arvalid=0,p_arready,p_rvalid,p_rready;
  logic [3:0] p_arid='0,p_rid;
  logic [33:0] p_araddr='0;
  logic [7:0] p_arlen='0;
  logic [511:0] p_rdata;
  logic [1:0] p_rresp;
  logic p_rlast;
  logic h_awvalid=0,h_awready,h_wvalid=0,h_wready,h_bvalid,h_bready;
  logic [33:0] h_awaddr='0;
  logic [7:0] h_awlen=0;
  logic [511:0] h_wdata='0;
  logic [63:0] h_wstrb='1;
  logic h_wlast=1;
  logic [1:0] h_bresp;
  logic h_arvalid=0,h_arready,h_rvalid,h_rready;
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
  logic [7:0] awlenq[0:7], arlenq[0:7];
  integer aw_wp=0,aw_rp=0,ar_wp=0,ar_rp=0, writes=0,reads=0;
  integer cycle=0, pair_b=0, host_b=0;
  logic [7:0] pair_r=0, host_r=0;
  logic [7:0] wbeat=0, rbeat=0;
  logic r_active=0;
  logic [3:0] r_active_id;
  logic [7:0] r_active_len;
  function automatic logic [511:0] write_pattern(input bit host, input logic [7:0] beat);
    logic [63:0] word;
    begin
      word = (host ? 64'hfeed000000000001 : 64'hcafe000000000002) ^ {56'd0, beat};
      write_pattern = {8{word}};
    end
  endfunction
  function automatic logic [511:0] read_pattern(input logic [7:0] beat);
    logic [63:0] word;
    begin
      word = 64'h0123456789abcdef ^ {56'd0, beat};
      read_pattern = {8{word}};
    end
  endfunction
  always_comb begin
    p_bready = (cycle % 11) != 3;
    h_bready = (cycle % 13) != 4;
    p_rready = (cycle % 7) != 2;
    h_rready = (cycle % 9) != 5;
  end
  assign m_wready = !m_bvalid && ((cycle%7)!=2) && ((aw_rp<aw_wp) || (m_awvalid && m_awready));
  otpu_mig_hmux #(.IDW(4),.AW(34),.HB(2)) dut(.*);
  always @(posedge clk) begin
    cycle <= cycle+1;
    if(rst) begin
      m_awready<=0; m_arready<=0; m_bvalid<=0; m_rvalid<=0;
      aw_wp<=0; aw_rp<=0; ar_wp<=0; ar_rp<=0; writes<=0; reads<=0;
      wbeat<=0; rbeat<=0; r_active<=0;
    end else begin
      m_awready <= (cycle%5)!=1;
      m_arready <= (cycle%4)!=1;
      if(m_awvalid && m_awready) begin
        if(m_awid==4'h4) begin
          if(m_awaddr!=34'h1000 || m_awlen!=2) $fatal(1,"host AW payload mismatch");
        end else if(m_awid==4'h1) begin
          if(m_awaddr!=34'h2040 || m_awlen!=2) $fatal(1,"pair AW payload mismatch");
        end else $fatal(1,"unexpected DIMM AWID %h",m_awid);
        awq[aw_wp]<=m_awid; awlenq[aw_wp]<=m_awlen; aw_wp<=aw_wp+1;
      end
      if(m_wvalid && m_wready) begin
        logic [3:0] owner;
        logic [7:0] burst_len;
        if(m_bvalid) $fatal(1,"W accepted while prior B response is pending");
        if(aw_rp>=aw_wp && !(m_awvalid && m_awready))
          $fatal(1,"W beat accepted without an accepted AW owner");
        // W belongs to the oldest accepted AW and remains with it through WLAST.
        owner = (aw_rp<aw_wp) ? awq[aw_rp] : m_awid;
        burst_len = (aw_rp<aw_wp) ? awlenq[aw_rp] : m_awlen;
        if(m_wlast !== (wbeat==burst_len))
          $fatal(1,"WLAST mismatch: owner=%h beat=%0d AWLEN=%0d WLAST=%b",owner,wbeat,burst_len,m_wlast);
        if(owner==4'h4) begin
          if(m_wdata !== write_pattern(1'b1,wbeat) ||
             m_wstrb !== 64'h00ff00ff00ff00ff)
            $fatal(1,"host W payload/owner mismatch at beat %0d",wbeat);
        end else if(owner==4'h1) begin
          if(m_wdata !== write_pattern(1'b0,wbeat) ||
             m_wstrb !== 64'hff00ff00ff00ff00)
            $fatal(1,"pair W payload/owner mismatch at beat %0d",wbeat);
        end else $fatal(1,"unexpected AW owner %h",owner);
        if(m_wlast) begin
          m_bid<=owner; m_bresp<=0; m_bvalid<=1;
          aw_rp<=aw_rp+1; wbeat<=0; writes<=writes+1;
        end else wbeat<=wbeat+1;
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
          if(m_araddr!=34'h3000 || m_arlen!=2) $fatal(1,"host AR payload mismatch");
        end else if(m_arid==4'h2) begin
          if(m_araddr!=34'h4080 || m_arlen!=2) $fatal(1,"pair AR payload mismatch");
        end else $fatal(1,"unexpected DIMM ARID %h",m_arid);
        arq[ar_wp]<=m_arid; arlenq[ar_wp]<=m_arlen; ar_wp<=ar_wp+1;
      end
      if(m_rvalid && m_rready) begin
        reads<=reads+1;
        m_rvalid<=0;
        if(m_rlast) r_active<=0;
        else rbeat<=rbeat+1;
      end else if(!m_rvalid && r_active) begin
        m_rid<=r_active_id; m_rdata<=read_pattern(rbeat);
        m_rresp<=0; m_rlast<=(rbeat==r_active_len); m_rvalid<=1;
      end else if(!r_active && ar_rp<ar_wp) begin
        r_active_id<=arq[ar_rp]; r_active_len<=arlenq[ar_rp];
        rbeat<=0; r_active<=1; ar_rp<=ar_rp+1;
      end
      if(p_rvalid && p_rready) begin
        if(p_rid!=4'h2 || p_rdata !== read_pattern(pair_r) ||
           p_rresp!=2'b00 || (p_rlast !== (pair_r==2)))
          $fatal(1,"pair R ID/data/response/last mismatch: id=%h beat=%0d last=%b",p_rid,pair_r,p_rlast);
        pair_r<=pair_r+1;
      end
      if(h_rvalid && h_rready) begin
        if(h_rdata !== read_pattern(host_r) || h_rresp!=2'b00 || (h_rlast !== (host_r==2)))
          $fatal(1,"host R data/response/last mismatch: beat=%0d last=%b",host_r,h_rlast);
        host_r<=host_r+1;
      end
    end
  end
  task automatic write_master(input bit host, input logic [3:0] id);
    begin
      @(negedge clk);
      if(host) begin h_awaddr=34'h1000+id*64; h_awlen=2; h_awvalid=1; end
      else begin p_awaddr=34'h2000+id*64; p_awid=id; p_awlen=2; p_awvalid=1; end
      do @(posedge clk); while(host ? !h_awready : !p_awready);
      @(negedge clk); if(host) h_awvalid=0; else p_awvalid=0;
      for (int beat=0; beat<3; beat++) begin
        @(negedge clk);
        if(host) begin h_wdata=write_pattern(1'b1,beat[7:0]); h_wstrb=64'h00ff00ff00ff00ff; h_wlast=(beat==2); h_wvalid=1; end
        else begin p_wdata=write_pattern(1'b0,beat[7:0]); p_wstrb=64'hff00ff00ff00ff00; p_wlast=(beat==2); p_wvalid=1; end
        do @(posedge clk); while(host ? !h_wready : !p_wready);
        @(negedge clk); if(host) h_wvalid=0; else p_wvalid=0;
      end
    end
  endtask
  task automatic read_master(input bit host, input logic [3:0] id);
    begin
      @(negedge clk);
      if(host) begin h_araddr=34'h3000+id*64; h_arlen=2; h_arvalid=1; end
      else begin p_araddr=34'h4000+id*64; p_arid=id; p_arlen=2; p_arvalid=1; end
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
    wait(writes==2 && reads==6 && pair_b==1 && host_b==1 && pair_r==3 && host_r==3);
    repeat(3) @(posedge clk);
    $display("PASS: concurrent pair/host 3-beat AW-W-B and AR-R bursts with response backpressure; write_bursts=%0d read_beats=%0d cycles=%0d",writes,reads,cycle);
    $finish;
  end
  initial begin #200000; $fatal(1,"timeout"); end
endmodule
