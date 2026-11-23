module tb_asic_ctrl;
  logic clk=0, rst=1;
  always #5 clk=~clk;
  logic [1:0] mem_calib=0;
  logic mem_error=0, ecc_ded=0, halted=0, core_error=0, ld_busy=0, wr_idle=1, wait_to=0, a_inval=0;
  logic a_req=0, a_we=0, a_rdy=1, b_req=0, b_rdy=1, b_we=0, sw_req=0, sw_rdy=1;
  logic [31:0] icount=32'h1234;
  logic [11:0] s_awaddr=0, s_araddr=0;
  logic s_awvalid=0, s_awready, s_wvalid=0, s_wready, s_bvalid, s_bready=0;
  logic [31:0] s_wdata=0, s_rdata;
  logic [3:0] s_wstrb=4'hf;
  logic [1:0] s_bresp, s_rresp;
  logic s_arvalid=0, s_arready, s_rvalid, s_rready=0;
  logic sys_rst, run_rst, ld_start;
  logic [31:0] ld_addr, ld_n;
  logic [7:0][31:0] rinit;

  integer load_count=0;
  always @(posedge clk) if (ld_start) load_count <= load_count + 1;

  otpu_asic_ctrl dut(.*);

  task automatic write_reg(input logic [11:0] addr, input logic [31:0] data,
                           input bit data_first, input logic [1:0] expected);
    begin
      if (data_first) begin
        @(negedge clk); s_wdata=data; s_wvalid=1;
        do @(posedge clk); while (!s_wready);
        @(negedge clk); s_wvalid=0; s_awaddr=addr; s_awvalid=1;
        do @(posedge clk); while (!s_awready);
        @(negedge clk); s_awvalid=0;
      end else begin
        @(negedge clk); s_awaddr=addr; s_awvalid=1;
        do @(posedge clk); while (!s_awready);
        @(negedge clk); s_awvalid=0; s_wdata=data; s_wvalid=1;
        do @(posedge clk); while (!s_wready);
        @(negedge clk); s_wvalid=0;
      end
      wait(s_bvalid);
      if (s_bresp !== expected) $fatal(1,"write %h response %b expected %b",addr,s_bresp,expected);
      @(negedge clk); s_bready=1;
      @(posedge clk);
      @(negedge clk); s_bready=0;
    end
  endtask

  task automatic read_reg(input logic [11:0] addr, input logic [31:0] expected,
                          input logic [1:0] expected_resp);
    begin
      @(negedge clk); s_araddr=addr; s_arvalid=1;
      do @(posedge clk); while (!s_arready);
      @(negedge clk); s_arvalid=0;
      wait(s_rvalid);
      if (s_rresp !== expected_resp) $fatal(1,"read %h response %b expected %b",addr,s_rresp,expected_resp);
      if (s_rdata !== expected) $fatal(1,"read %h data %h expected %h",addr,s_rdata,expected);
      @(negedge clk); s_rready=1;
      @(posedge clk);
      @(negedge clk); s_rready=0;
    end
  endtask

  initial begin
    repeat(3) @(posedge clk);
    @(negedge clk); rst=0; #1;
    if (!sys_rst || !run_rst) $fatal(1,"initial reset state");
    @(posedge clk); #1;
    if (sys_rst || !run_rst) $fatal(1,"loader reset release");
    read_reg(12'h000,32'h4f545055,2'b00);
    read_reg(12'h004,{16'd128,8'd4,8'd8},2'b00);
    read_reg(12'h03c,32'd5,2'b00);
    read_reg(12'h040,32'he70a0070,2'b00);
    read_reg(12'h05c,32'b0,2'b00);
    read_reg(12'h084,32'd65536,2'b00);
    read_reg(12'h088,32'd32768,2'b00);
    read_reg(12'h094,32'h01080232,2'b00);
    read_reg(12'h098,32'd256,2'b00);

    // AW-before-W and W-before-AW both must be accepted.
    write_reg(12'h010,32'h1000,0,2'b00);
    write_reg(12'h014,32'd64,1,2'b00);
    write_reg(12'h060,32'hfeed1234,0,2'b00);
    read_reg(12'h010,32'h1000,2'b00);
    read_reg(12'h014,32'd64,2'b00);
    read_reg(12'h060,32'hfeed1234,2'b00);

    // RUN is rejected until memory is ready; sticky control error is reported.
    write_reg(12'h008,32'h1,0,2'b10);
    if (!run_rst) $fatal(1,"RUN escaped memory-ready gate");
    read_reg(12'h00c,32'h0000000a,2'b00);
    write_reg(12'h008,32'h4,1,2'b00); // error cannot clear while memory is unavailable
    read_reg(12'h00c,32'h0000000a,2'b00);

    mem_calib=2'b11;
    write_reg(12'h008,32'h4,1,2'b00);
    read_reg(12'h00c,32'h00000068,2'b00);
    ecc_ded=1;
    write_reg(12'h008,32'h1,0,2'b10);
    if (!run_rst) $fatal(1,"RUN escaped ECC-DED gate");
    ecc_ded=0;
    write_reg(12'h008,32'h4,1,2'b00);
    wr_idle=0;
    write_reg(12'h008,32'h1,0,2'b10); // RUN waits for stopped-state writes to drain
    if (!run_rst) $fatal(1,"RUN escaped write-drain gate");
    wr_idle=1;
    write_reg(12'h008,32'h4,1,2'b00);
    write_reg(12'h008,32'h3,1,2'b10); // RUN + LOAD must be rejected atomically
    if (load_count != 0 || !run_rst) $fatal(1,"invalid CTRL command had side effects");
    write_reg(12'h008,32'h4,0,2'b00);
    wr_idle=0;
    write_reg(12'h008,32'h2,1,2'b10); // LOAD waits for accepted writes to drain
    if (load_count != 0 || !run_rst) $fatal(1,"LOAD escaped write-drain gate");
    wr_idle=1;
    write_reg(12'h008,32'h2,1,2'b00);
    if (load_count != 1 || !run_rst) $fatal(1,"LOAD pulse or stopped-state contract count=%0d",load_count);
    read_reg(12'h00c,32'h0000006c,2'b00); // LOADING remains set until busy is observed and drained
    write_reg(12'h008,32'h1,0,2'b10); // RUN is blocked while LOAD is outstanding
    if (!run_rst) $fatal(1,"RUN escaped load-inflight gate");
    write_reg(12'h008,32'h4,1,2'b00);
    ld_busy=1; @(posedge clk); @(negedge clk); ld_busy=0;
    @(posedge clk); #1;

    write_reg(12'h008,32'h1,0,2'b00);
    if (run_rst) $fatal(1,"RUN did not release core reset");
    write_reg(12'h008,32'h2,1,2'b10); // LOAD while running must be rejected
    if (run_rst || load_count != 1) $fatal(1,"LOAD while running changed state");
    write_reg(12'h008,32'h0,1,2'b00);
    if (!run_rst) $fatal(1,"STOP did not assert core reset");
    write_reg(12'h008,32'h1,0,2'b00);
    mem_calib=2'b01; @(posedge clk); #1;
    if (!run_rst) $fatal(1,"calibration loss did not stop compute");
    read_reg(12'h00c,32'h0000002a,2'b00);
    @(negedge clk); mem_calib=2'b11;
    write_reg(12'h008,32'h4,1,2'b00);
    write_reg(12'h008,32'h1,0,2'b00);
    mem_error=1; @(posedge clk); #1;
    if (!run_rst) $fatal(1,"fatal memory error did not stop compute");
    read_reg(12'h00c,32'h0000007a,2'b00);
    @(negedge clk); mem_error=0;
    write_reg(12'h008,32'h4,1,2'b00);

    // Verify memory-traffic counters are counted on accepted requests only.
    @(negedge clk); b_req=1; b_we=0;
    @(posedge clk); @(negedge clk); b_req=0;
    @(negedge clk); b_req=1; b_we=1;
    @(posedge clk); @(negedge clk); b_req=0;
    @(negedge clk); a_req=1; a_we=0;
    @(posedge clk); @(negedge clk); a_req=0;
    @(negedge clk); a_req=1; a_we=1;
    @(posedge clk); @(negedge clk); a_req=0; a_we=0;
    @(negedge clk); sw_req=1;
    @(posedge clk); @(negedge clk); sw_req=0;
    read_reg(12'h020,32'h1234,2'b00);
    read_reg(12'h024,32'd1,2'b00);
    read_reg(12'h028,32'd1,2'b00);
    read_reg(12'h02c,32'd1,2'b00);
    read_reg(12'h030,32'd1,2'b00);
    @(negedge clk); b_rdy=0; b_req=1;
    @(posedge clk); @(negedge clk); b_req=0; b_rdy=1;
    read_reg(12'h034,32'd1,2'b00);
    read_reg(12'h01c,32'b0,2'b00);
    read_reg(12'h0fc,32'b0,2'b11);
    $display("PASS: ASIC AXI-Lite control, independent AW/W, gating, load pulse, reset, register map");
    $finish;
  end
endmodule
