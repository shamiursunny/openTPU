// Four DIMM-local host/accelerator arbitration instances, exercising the exact hmux
// configuration used by otpu_asic_wg8_ddr4_top. This is a focused port-level test of
// simultaneous requests, round-robin AW/AR selection, ordered W bursts, and BID/RID routing.
\`timescale 1ns/1ps
module tb_asic_wg8_hmux_contention;
  logic clk=0, rst=1;
  always #5 clk=~clk;
  integer cycle=0;

  logic [3:0] p_awvalid='0, p_awready, p_wvalid='0, p_wready, p_wlast='0;
  logic [3:0][3:0] p_awid='0, p_bid, p_arid='0, p_rid;
  logic [3:0][33:0] p_awaddr='0, p_araddr='0;
  logic [3:0][7:0] p_awlen='0, p_arlen='0;
  logic [3:0][511:0] p_wdata='0, p_rdata;
  logic [3:0][63:0] p_wstrb='0;
  logic [3:0] p_bvalid, p_bready='1, p_arvalid='0, p_arready, p_rvalid, p_rready='1, p_rlast;
  logic [3:0][1:0] p_bresp, p_rresp;

  logic [3:0] h_awvalid='0, h_awready, h_wvalid='0, h_wready, h_wlast='0;
  logic [3:0][33:0] h_awaddr='0, h_araddr='0;
  logic [3:0][7:0] h_awlen='0, h_arlen='0;
  logic [3:0][511:0] h_wdata='0, h_rdata;
  logic [3:0][63:0] h_wstrb='0;
  logic [3:0] h_bvalid, h_bready='1, h_arvalid='0, h_arready, h_rvalid, h_rready='1, h_rlast;
  logic [3:0][1:0] h_bresp, h_rresp;

  logic [3:0] m_awvalid, m_awready='1, m_wvalid, m_wready='1, m_wlast;
  logic [3:0][3:0] m_awid, m_bid='0, m_arid, m_rid='0;
  logic [3:0][33:0] m_awaddr, m_araddr;
  logic [3:0][7:0] m_awlen, m_arlen;
  logic [3:0][511:0] m_wdata, m_rdata='0;
  logic [3:0][63:0] m_wstrb;
  logic [3:0] m_bvalid='0, m_bready, m_arvalid, m_arready='1, m_rvalid='0, m_rready;
  logic [3:0][1:0] m_bresp='0, m_rresp='0;
  logic [3:0] m_rlast='0;

  logic [3:0][2:0] aw_count='0, ar_count='0;
  logic [3:0][3:0] w_count='0;
  logic [3:0][2:0] b_host_count='0, b_pair_count='0;
  logic [3:0][2:0] r_host_count='0, r_pair_count='0;

  function automatic logic [33:0] host_addr(input integer d, input integer n);
    return 34'h1000 + (34'(d) << 12) + (34'(n) << 6);
  endfunction
  function automatic logic [33:0] pair_addr(input integer d, input integer n);
    return 34'h2000 + (34'(d) << 12) + (34'(n) << 6);
  endfunction
  function automatic logic [511:0] data_pattern(input bit host, input integer d,
                                                  input integer txn, input integer beat);
    logic [63:0] word;
    word = (host ? 64'h484f535400000000 : 64'h5041495200000000)
           ^ (64'(d) << 24) ^ (64'(txn) << 8) ^ 64'(beat);
    return {8{word}};
  endfunction
  function automatic logic [63:0] strobe_pattern(input bit host, input integer txn, input integer beat);
    if (host) return (beat==0) ? 64'hffffffffffffffff : 64'h0f0f0f0f0f0f0f0f;
    return (beat==0) ? 64'h5555555555555555 : 64'h3333333333333333;
  endfunction

  always_comb begin
    for (int d=0; d<4; d++) begin
      m_awready[d] = ((cycle+d)%5)!=1;
      m_wready[d]  = ((cycle+2*d)%7)!=2;
      m_arready[d] = ((cycle+3*d)%4)!=1;
      h_bready[d]  = ((cycle+d)%6)!=2;
      p_bready[d]  = ((cycle+2*d)%7)!=3;
      h_rready[d]  = ((cycle+2*d)%5)!=1;
      p_rready[d]  = ((cycle+3*d)%6)!=2;
    end
  end

  for (genvar d=0; d<4; d++) begin : g_dimm
    otpu_mig_hmux #(.IDW(4), .AW(34), .HB(2)) dut (
      .clk, .rst,
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

  always_ff @(posedge clk) begin
    cycle <= cycle+1;
    if (rst) begin
      aw_count<='0; ar_count<='0; w_count<='0;
      b_host_count<='0; b_pair_count<='0;
      r_host_count<='0; r_pair_count<='0;
    end else begin
      for (int d=0; d<4; d++) begin
        if (m_awvalid[d] && m_awready[d]) begin
          case (aw_count[d])
            0: if (m_awid[d]!==4'h4 || m_awaddr[d]!==host_addr(d,0) || m_awlen[d]!==8'd1)
                 $fatal(1,"DIMM%0d AW0 expected host",d);
            1: if (m_awid[d]!==4'h1 || m_awaddr[d]!==pair_addr(d,0) || m_awlen[d]!==8'd1)
                 $fatal(1,"DIMM%0d AW1 expected accelerator",d);
            2: if (m_awid[d]!==4'h4 || m_awaddr[d]!==host_addr(d,1) || m_awlen[d]!==8'd1)
                 $fatal(1,"DIMM%0d AW2 expected host",d);
            3: if (m_awid[d]!==4'h1 || m_awaddr[d]!==pair_addr(d,1) || m_awlen[d]!==8'd1)
                 $fatal(1,"DIMM%0d AW3 expected accelerator",d);
            default: $fatal(1,"DIMM%0d unexpected extra AW",d);
          endcase
          aw_count[d] <= aw_count[d]+1'b1;
        end
        if (m_wvalid[d] && m_wready[d]) begin
          case (w_count[d])
            0: if (m_wdata[d]!==data_pattern(1,d,0,0) || m_wstrb[d]!==strobe_pattern(1,0,0) || m_wlast[d])
                 $fatal(1,"DIMM%0d W host txn0 beat0 mismatch",d);
            1: if (m_wdata[d]!==data_pattern(1,d,0,1) || m_wstrb[d]!==strobe_pattern(1,0,1) || !m_wlast[d])
                 $fatal(1,"DIMM%0d W host txn0 beat1 mismatch",d);
            2: if (m_wdata[d]!==data_pattern(0,d,0,0) || m_wstrb[d]!==strobe_pattern(0,0,0) || m_wlast[d])
                 $fatal(1,"DIMM%0d W pair txn0 beat0 mismatch",d);
            3: if (m_wdata[d]!==data_pattern(0,d,0,1) || m_wstrb[d]!==strobe_pattern(0,0,1) || !m_wlast[d])
                 $fatal(1,"DIMM%0d W pair txn0 beat1 mismatch",d);
            4: if (m_wdata[d]!==data_pattern(1,d,1,0) || m_wstrb[d]!==strobe_pattern(1,1,0) || m_wlast[d])
                 $fatal(1,"DIMM%0d W host txn1 beat0 mismatch",d);
            5: if (m_wdata[d]!==data_pattern(1,d,1,1) || m_wstrb[d]!==strobe_pattern(1,1,1) || !m_wlast[d])
                 $fatal(1,"DIMM%0d W host txn1 beat1 mismatch",d);
            6: if (m_wdata[d]!==data_pattern(0,d,1,0) || m_wstrb[d]!==strobe_pattern(0,1,0) || m_wlast[d])
                 $fatal(1,"DIMM%0d W pair txn1 beat0 mismatch",d);
            7: if (m_wdata[d]!==data_pattern(0,d,1,1) || m_wstrb[d]!==strobe_pattern(0,1,1) || !m_wlast[d])
                 $fatal(1,"DIMM%0d W pair txn1 beat1 mismatch",d);
            default: $fatal(1,"DIMM%0d unexpected extra W",d);
          endcase
          w_count[d] <= w_count[d]+1'b1;
        end
        if (m_bvalid[d] && m_bready[d]) begin
          if (m_bid[d]===4'h4) begin
            if (!h_bvalid[d] || p_bvalid[d] || h_bresp[d]!==m_bresp[d])
              $fatal(1,"DIMM%0d host B routing mismatch",d);
            b_host_count[d]<=b_host_count[d]+1'b1;
          end else if (m_bid[d]===4'h1) begin
            if (!p_bvalid[d] || h_bvalid[d] || p_bresp[d]!==m_bresp[d])
              $fatal(1,"DIMM%0d pair B routing mismatch",d);
            b_pair_count[d]<=b_pair_count[d]+1'b1;
          end else $fatal(1,"DIMM%0d unexpected BID %h",d,m_bid[d]);
        end
        if (m_arvalid[d] && m_arready[d]) begin
          case (ar_count[d])
            0: if (m_arid[d]!==4'h4 || m_araddr[d]!==host_addr(d,0) || m_arlen[d]!==8'd1)
                 $fatal(1,"DIMM%0d AR0 expected host",d);
            1: if (m_arid[d]!==4'h1 || m_araddr[d]!==pair_addr(d,0) || m_arlen[d]!==8'd1)
                 $fatal(1,"DIMM%0d AR1 expected accelerator",d);
            2: if (m_arid[d]!==4'h4 || m_araddr[d]!==host_addr(d,1) || m_arlen[d]!==8'd1)
                 $fatal(1,"DIMM%0d AR2 expected host",d);
            3: if (m_arid[d]!==4'h1 || m_araddr[d]!==pair_addr(d,1) || m_arlen[d]!==8'd1)
                 $fatal(1,"DIMM%0d AR3 expected accelerator",d);
            default: $fatal(1,"DIMM%0d unexpected extra AR",d);
          endcase
          ar_count[d] <= ar_count[d]+1'b1;
        end
        if (h_rvalid[d] && h_rready[d]) begin
          if (h_rresp[d]!==2'b00 || h_rlast[d] !== ((r_host_count[d]%2)==1) ||
              h_rdata[d]!==data_pattern(1,d,int'(r_host_count[d]/2),int'(r_host_count[d]%2)))
            $fatal(1,"DIMM%0d host R routing/data mismatch beat=%0d",d,r_host_count[d]);
          r_host_count[d]<=r_host_count[d]+1'b1;
        end
        if (p_rvalid[d] && p_rready[d]) begin
          if (p_rid[d]!==4'h1 || p_rresp[d]!==2'b00 ||
              p_rlast[d] !== ((r_pair_count[d]%2)==1) ||
              p_rdata[d]!==data_pattern(0,d,int'(r_pair_count[d]/2),int'(r_pair_count[d]%2)))
            $fatal(1,"DIMM%0d pair R routing/data mismatch beat=%0d",d,r_pair_count[d]);
          r_pair_count[d]<=r_pair_count[d]+1'b1;
        end
      end
    end
  end

  task automatic send_aw_host(input integer d);
    begin
      @(negedge clk); h_awvalid[d]=1;
      for (int n=0; n<2; n++) begin
        h_awaddr[d]=host_addr(d,n); h_awlen[d]=1;
        do @(posedge clk); while (h_awready[d] !== 1'b1);
        @(negedge clk);
      end
      h_awvalid[d]=0;
    end
  endtask
  task automatic send_aw_pair(input integer d);
    begin
      @(negedge clk); p_awvalid[d]=1; p_awid[d]=4'h1;
      for (int n=0; n<2; n++) begin
        p_awaddr[d]=pair_addr(d,n); p_awlen[d]=1;
        do @(posedge clk); while (p_awready[d] !== 1'b1);
        @(negedge clk);
      end
      p_awvalid[d]=0;
    end
  endtask
  task automatic send_ar_host(input integer d);
    begin
      @(negedge clk); h_arvalid[d]=1;
      for (int n=0; n<2; n++) begin
        h_araddr[d]=host_addr(d,n); h_arlen[d]=1;
        do @(posedge clk); while (h_arready[d] !== 1'b1);
        @(negedge clk);
      end
      h_arvalid[d]=0;
    end
  endtask
  task automatic send_ar_pair(input integer d);
    begin
      @(negedge clk); p_arvalid[d]=1; p_arid[d]=4'h1;
      for (int n=0; n<2; n++) begin
        p_araddr[d]=pair_addr(d,n); p_arlen[d]=1;
        do @(posedge clk); while (p_arready[d] !== 1'b1);
        @(negedge clk);
      end
      p_arvalid[d]=0;
    end
  endtask
  task automatic send_w_host(input integer d);
    begin
      for (int n=0; n<2; n++) for (int b=0; b<2; b++) begin
        @(negedge clk); h_wvalid[d]=1;
        h_wdata[d]=data_pattern(1,d,n,b); h_wstrb[d]=strobe_pattern(1,n,b); h_wlast[d]=(b==1);
        do @(posedge clk); while (h_wready[d] !== 1'b1);
        @(negedge clk); h_wvalid[d]=0;
      end
    end
  endtask
  task automatic send_w_pair(input integer d);
    begin
      for (int n=0; n<2; n++) for (int b=0; b<2; b++) begin
        @(negedge clk); p_wvalid[d]=1;
        p_wdata[d]=data_pattern(0,d,n,b); p_wstrb[d]=strobe_pattern(0,n,b); p_wlast[d]=(b==1);
        do @(posedge clk); while (p_wready[d] !== 1'b1);
        @(negedge clk); p_wvalid[d]=0;
      end
    end
  endtask

  task automatic send_b_responses(input integer d);
    begin
      wait(w_count[d]==8);
      for (int n=0; n<4; n++) begin
        @(negedge clk); m_bid[d]=(n%2==0) ? 4'h4 : 4'h1;
        m_bresp[d]=2'b00; m_bvalid[d]=1;
        do @(posedge clk); while(m_bready[d] !== 1'b1);
        @(negedge clk); m_bvalid[d]=0;
      end
    end
  endtask

  task automatic send_r_responses(input integer d);
    begin
      wait(ar_count[d]==4);
      for (int n=0; n<4; n++) begin
        for (int b=0; b<2; b++) begin
          @(negedge clk); m_rid[d]=(n%2==0) ? 4'h4 : 4'h1;
          m_rdata[d]=data_pattern((n%2)==0,d,n/2,b);
          m_rresp[d]=2'b00; m_rlast[d]=(b==1); m_rvalid[d]=1;
          do @(posedge clk); while(m_rready[d] !== 1'b1);
          @(negedge clk); m_rvalid[d]=0;
        end
      end
    end
  endtask

  initial begin
    repeat(5) @(posedge clk);
    @(negedge clk); rst=0;
    fork
      send_aw_host(0); send_aw_pair(0); send_ar_host(0); send_ar_pair(0); send_w_host(0); send_w_pair(0); send_b_responses(0); send_r_responses(0);
      send_aw_host(1); send_aw_pair(1); send_ar_host(1); send_ar_pair(1); send_w_host(1); send_w_pair(1); send_b_responses(1); send_r_responses(1);
      send_aw_host(2); send_aw_pair(2); send_ar_host(2); send_ar_pair(2); send_w_host(2); send_w_pair(2); send_b_responses(2); send_r_responses(2);
      send_aw_host(3); send_aw_pair(3); send_ar_host(3); send_ar_pair(3); send_w_host(3); send_w_pair(3); send_b_responses(3); send_r_responses(3);
    join
    wait((aw_count=={4{3'd4}}) && (ar_count=={4{3'd4}}) && (w_count=={4{4'd8}}) &&
         (b_host_count=={4{3'd2}}) && (b_pair_count=={4{3'd2}}) &&
         (r_host_count=={4{3'd4}}) && (r_pair_count=={4{3'd4}}));
    repeat(3) @(posedge clk);
    $display("PASS: four DIMM hmuxes; simultaneous host/accelerator AW/AR contention, alternating grants, ordered two-beat W bursts, B/R ID routing and independent backpressure");
    $finish;
  end

  initial begin
    #500000;
    $fatal(1,"four-DIMM host/accelerator contention timeout");
  end
endmodule
