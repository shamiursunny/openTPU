module tb_asic_ctrl;
  logic clk=0, rst=1;
  always #5 clk=~clk;
  logic mem_ready=0, mem_error=0, halted=0, core_error=0, ld_busy=0, wr_idle=1, wait_to=0, a_inval=0;
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
    @(negedge clk); rst=0;
    @(posedge clk); #1;
    if (!sys_rst || !run_rst) $fatal(1,"initial reset state");
    @(posedge clk); #1;
    if (sys_rst || !run_rst) $fatal(1,"loader reset release");
    read_reg(12'h000,32'h4f545055,2'b00);
    read_reg(12'h004,{16'd128,8'd4,8'd8},2'b00);

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
    read_reg(12'h00c,32'h00000002,2'b00);

    mem_ready=1;
    write_reg(12'h008,32'h2,1,2'b00);
    if (!ld_start || !run_rst) $fatal(1,"LOAD pulse or stopped-state contract");
    @(posedge clk); #1;
    if (ld_start) $fatal(1,"LOAD must be a one-cycle pulse");

    write_reg(12'h008,32'h1,0,2'b00);
    if (run_rst) $fatal(1,"RUN did not release core reset");
    write_reg(12'h008,32'h0,1,2'b00);
    if (!run_rst) $fatal(1,"STOP did not assert core reset");

    read_reg(12'h018,32'h1234,2'b00);
    read_reg(12'h0fc,32'b0,2'b11);
    $display("PASS: ASIC AXI-Lite control, independent AW/W, gating, load pulse, reset, register map");
    $finish;
  end
endmodule
