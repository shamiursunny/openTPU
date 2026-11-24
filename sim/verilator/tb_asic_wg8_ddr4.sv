`timescale 1ns/1ps
module tb_asic_wg8_ddr4;
  logic clk=0, aclk=0, rst=1;
  always #5 clk=~clk;
  always #5 aclk=~aclk;

  logic [3:0] mem_reset='0, mem_calib=4'hf;
  logic mem_error=0, ecc_ded=0;

  logic [11:0] s_awaddr='0, s_araddr='0;
  logic s_awvalid=0, s_wvalid=0, s_bready=1, s_arvalid=0, s_rready=1;
  logic [31:0] s_wdata='0;
  logic [3:0] s_wstrb='0;
  logic s_awready, s_wready, s_bvalid, s_arready, s_rvalid;
  logic [1:0] s_bresp, s_rresp;
  logic [31:0] s_rdata;

  logic [3:0] h_awvalid='0, h_awready, h_wvalid='0, h_wready;
  logic [3:0][33:0] h_awaddr='0;
  logic [3:0][7:0] h_awlen='0;
  logic [3:0][511:0] h_wdata='0;
  logic [3:0][63:0] h_wstrb='1;
  logic [3:0] h_wlast='1, h_bvalid, h_bready;
  logic [3:0][1:0] h_bresp;
  logic [3:0] h_arvalid='0, h_arready, h_rvalid, h_rready;
  logic [3:0][33:0] h_araddr='0;
  logic [3:0][7:0] h_arlen='0;
  logic [3:0][511:0] h_rdata;
  logic [3:0][1:0] h_rresp;
  logic [3:0] h_rlast;

  logic [3:0] m_awvalid, m_awready, m_wvalid, m_wready, m_wlast;
  logic [3:0][3:0] m_awid, m_bid='0;
  logic [3:0][33:0] m_awaddr;
  logic [3:0][7:0] m_awlen;
  logic [3:0][2:0] m_awsize;
  logic [3:0][1:0] m_awburst;
  logic [3:0] m_awlock;
  logic [3:0][3:0] m_awcache;
  logic [3:0][2:0] m_awprot;
  logic [3:0][3:0] m_awqos;
  logic [3:0][511:0] m_wdata;
  logic [3:0][63:0] m_wstrb;
  logic [3:0] m_bvalid='0, m_bready;
  logic [3:0][1:0] m_bresp='0;
  logic [3:0] m_arvalid, m_arready, m_rvalid='0, m_rready;
  logic [3:0][3:0] m_arid, m_rid='0;
  logic [3:0][33:0] m_araddr;
  logic [3:0][7:0] m_arlen;
  logic [3:0][2:0] m_arsize;
  logic [3:0][1:0] m_arburst;
  logic [3:0] m_arlock;
  logic [3:0][3:0] m_arcache;
  logic [3:0][2:0] m_arprot;
  logic [3:0][3:0] m_arqos;
  logic [3:0][511:0] m_rdata='0;
  logic [3:0][1:0] m_rresp='0;
  logic [3:0] m_rlast='0;

  logic ld_busy, halted, error, wait_to;
  logic [31:0] icount;
  logic [7:0] bridge_error;

  integer cycle=0;
  logic [3:0] aw_accepted='0, w_complete='0, r_active='0;
  logic [3:0][3:0] awid_hold='0, arid_hold='0;
  logic [3:0] b_seen='0, r_seen='0;

  function automatic logic [511:0] host_write_pattern(input integer d);
    logic [63:0] word;
    begin word=64'hfeed000000000001 ^ d; host_write_pattern={8{word}}; end
  endfunction
  function automatic logic [511:0] controller_read_pattern(input integer d);
    logic [63:0] word;
    begin word=64'h0123456789abcdef ^ d; controller_read_pattern={8{word}}; end
  endfunction

  always_comb begin
    for (int d=0; d<4; d++) begin
      m_awready[d] = ((cycle+d)%5)!=1;
      m_wready[d]  = ((cycle+2*d)%7)!=2;
      m_arready[d] = ((cycle+3*d)%4)!=1;
      h_bready[d]  = ((cycle+d)%9)!=3;
      h_rready[d]  = ((cycle+2*d)%7)!=2;
    end
  end

  otpu_asic_wg8_ddr4_top dut(.*);

  always_ff @(posedge aclk) begin
    cycle <= cycle+1;
    if (rst) begin
      m_bvalid<='0; m_rvalid<='0;
      aw_accepted<='0; w_complete<='0; r_active<='0;
      awid_hold<='0; arid_hold<='0;
      b_seen<='0; r_seen<='0;
    end else begin
      for (int d=0; d<4; d++) begin
        if (m_awvalid[d] && m_awready[d]) begin
          if (m_awid[d]!=4'h4 || m_awlen[d]!=0 ||
              m_awaddr[d] !== h_awaddr[d] || m_awaddr[d][33] ||
              m_awsize[d]!=3'd6 || m_awburst[d]!=2'b01)
            $fatal(1,"DIMM%0d host AW routing/attributes mismatch id=%h addr=%h len=%0d",d,m_awid[d],m_awaddr[d],m_awlen[d]);
          aw_accepted[d]<=1'b1;
          awid_hold[d]<=m_awid[d];
        end
        if (m_wvalid[d] && m_wready[d]) begin
          if (m_wdata[d] !== host_write_pattern(d) || m_wstrb[d] !== 64'hffffffffffffffff || !m_wlast[d])
            $fatal(1,"DIMM%0d host W payload mismatch",d);
          w_complete[d]<=1'b1;
        end
        if (!m_bvalid[d] &&
            (aw_accepted[d] || (m_awvalid[d] && m_awready[d])) &&
            (w_complete[d] || (m_wvalid[d] && m_wready[d]))) begin
          m_bvalid[d]<=1'b1;
          m_bid[d] <= (m_awvalid[d] && m_awready[d]) ? m_awid[d] : awid_hold[d];
          m_bresp[d]<=2'b00;
        end else if (m_bvalid[d] && m_bready[d]) begin
          m_bvalid[d]<=1'b0;
          aw_accepted[d]<=1'b0;
          w_complete[d]<=1'b0;
        end
        if (m_arvalid[d] && m_arready[d]) begin
          if (m_arid[d]!=4'h4 || m_arlen[d]!=0 ||
              m_araddr[d] !== h_araddr[d] || m_araddr[d][33] ||
              m_arsize[d]!=3'd6 || m_arburst[d]!=2'b01)
            $fatal(1,"DIMM%0d host AR routing/attributes mismatch id=%h addr=%h len=%0d",d,m_arid[d],m_araddr[d],m_arlen[d]);
          arid_hold[d]<=m_arid[d];
          r_active[d]<=1'b1;
        end
        if (m_rvalid[d] && m_rready[d]) begin
          m_rvalid[d]<=1'b0;
          r_active[d]<=1'b0;
        end else if (r_active[d] && !m_rvalid[d]) begin
          m_rvalid[d]<=1'b1;
          m_rid[d]<=arid_hold[d];
          m_rdata[d]<=controller_read_pattern(d);
          m_rresp[d]<=2'b00;
          m_rlast[d]<=1'b1;
        end
        if (h_bvalid[d] && h_bready[d]) begin
          if (h_bresp[d]!=2'b00) $fatal(1,"DIMM%0d host BRESP mismatch",d);
          b_seen[d]<=1'b1;
        end
        if (h_rvalid[d] && h_rready[d]) begin
          if (h_rdata[d] !== controller_read_pattern(d) ||
              h_rresp[d]!=2'b00 || h_rlast[d]!==1'b1)
            $fatal(1,"DIMM%0d host R payload/response mismatch",d);
          r_seen[d]<=1'b1;
        end
      end
    end
  end

  task automatic drive_port(input integer d);
    begin
      @(negedge aclk);
      h_awaddr[d]=34'h1000+d*64; h_awlen[d]=0; h_awvalid[d]=1;
      do @(posedge aclk); while(!h_awready[d]);
      @(negedge aclk); h_awvalid[d]=0;

      h_wdata[d]=host_write_pattern(d); h_wstrb[d]='1; h_wlast[d]=1; h_wvalid[d]=1;
      do @(posedge aclk); while(!h_wready[d]);
      @(negedge aclk); h_wvalid[d]=0;

      h_araddr[d]=34'h3000+d*64; h_arlen[d]=0; h_arvalid[d]=1;
      do @(posedge aclk); while(!h_arready[d]);
      @(negedge aclk); h_arvalid[d]=0;
    end
  endtask

  initial begin
    repeat(6) @(posedge aclk);
    @(negedge aclk); rst=0;
    fork
      drive_port(0);
      drive_port(1);
      drive_port(2);
      drive_port(3);
    join
    wait(b_seen==4'hf && r_seen==4'hf);
    repeat(5) @(posedge aclk);
    if (bridge_error!='0) $fatal(1,"unexpected bridge error: %h",bridge_error);
    $display("PASS: four independent WG8 DIMM ports; host AW/W/B and AR/R routed on all four ports with independent backpressure");
    $finish;
  end

  initial begin #200000; $fatal(1,"four-DIMM host-path timeout"); end
endmodule
