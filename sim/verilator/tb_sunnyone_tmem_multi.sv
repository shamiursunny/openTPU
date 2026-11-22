`timescale 1ns/1ps
module tb_sunnyone_tmem_multi;
  localparam int WORDS=64, LANES=4, NRP=2, NWP=2;
  logic clk=0, clk_f=0, rst=1, dump=0;
  always #5 clk=~clk;
  always #2.5 clk_f=~clk_f;
  logic [NRP-1:0][LANES-1:0] r_en='0, r_req='0, r_ben='0;
  logic [NRP-1:0][LANES-1:0][31:0] r_addr='0, r_bad='0, r_data;
  logic [NWP-1:0][LANES-1:0] w_en='0, w_req='0;
  logic [NWP-1:0] w_gnt='0;
  logic [NWP-1:0][LANES-1:0][31:0] w_addr='0, w_data='0;
  logic [NRP-1:0] blk_x, blk_s, lost, frz;

  otpu_tmem #(.WORDS(WORDS),.LANES(LANES),.NRP(NRP),.NWP(NWP),
              .GEN_R('1),.GEN_W('1),.IMPL(0)) dut (
    .clk,.clk_f,.rst,.r_en,.r_req,.r_addr,.r_ben,.r_bad,.r_data,
    .w_en,.w_req,.w_gnt,.w_addr,.w_data,.blk_x,.blk_s,.lost,.frz,.dump
  );

  initial begin
    repeat(3) @(negedge clk); rst=0;
    repeat(2) @(negedge clk);

    // Two write ports write distinct banks in the same cycle.
    @(negedge clk);
    w_en[0][0]=1; w_req[0][0]=1; w_addr[0][0]=0; w_data[0][0]=32'hA100_0000;
    w_en[1][0]=1; w_req[1][0]=1; w_addr[1][0]=1; w_data[1][0]=32'hB200_0001;
    w_gnt='1;
    @(negedge clk); w_en='0; w_req='0; w_gnt='0;
    repeat(3) @(negedge clk);

    // Both independent read ports read concurrently from their own copies.
    r_en[0][0]=1; r_req[0][0]=1; r_addr[0][0]=0;
    r_en[1][0]=1; r_req[1][0]=1; r_addr[1][0]=1;
    repeat(2) @(posedge clk); #1;
    if (r_data[0][0] !== 32'hA100_0000)
      $fatal(1,"port 0 read/copy mismatch: %h",r_data[0][0]);
    if (r_data[1][0] !== 32'hB200_0001)
      $fatal(1,"port 1 read/copy mismatch: %h",r_data[1][0]);

    // Each read port now reads both written words concurrently.
    @(negedge clk);
    for (int l=0;l<LANES;l++) begin
      r_en[0][l]=1; r_req[0][l]=1;
      r_en[1][l]=1; r_req[1][l]=1;
      r_addr[0][l]=32'(l); r_addr[1][l]=32'(l);
    end
    repeat(2) @(posedge clk); #1;
    for (int p=0;p<NRP;p++) begin
      if (r_data[p][0] !== 32'hA100_0000 ||
          r_data[p][1] !== 32'hB200_0001)
        $fatal(1,"port %0d broadcast-copy readback failed: %h %h",
               p,r_data[p][0],r_data[p][1]);
    end
    $display("TMEM_MULTI PASS: two concurrent read ports, two concurrent write ports, distinct-bank writes and broadcast-copy readback");
    $finish;
  end
endmodule
