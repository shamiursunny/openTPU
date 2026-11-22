`timescale 1ns/1ps
module tb_sunnyone_tmem;
  localparam int WORDS=64, LANES=4, NRP=1, NWP=1;
  logic clk=0, clk_f=0, rst=1, dump=0;
  always #5 clk=~clk;
  always #2.5 clk_f=~clk_f;
  logic [NRP-1:0][LANES-1:0] r_en='0, r_req='0;
  logic [NRP-1:0][LANES-1:0][31:0] r_addr='0;
  logic [NRP-1:0][LANES-1:0] r_ben='0;
  logic [NRP-1:0][LANES-1:0][31:0] r_bad='0;
  logic [NRP-1:0][LANES-1:0][31:0] r_data;
  logic [NWP-1:0][LANES-1:0] w_en='0, w_req='0;
  logic [NWP-1:0] w_gnt='0;
  logic [NWP-1:0][LANES-1:0][31:0] w_addr='0, w_data='0;
  logic [NRP-1:0] blk_x, blk_s, lost, frz;

  otpu_tmem #(.WORDS(WORDS),.LANES(LANES),.NRP(NRP),.NWP(NWP),
              .GEN_R('1),.GEN_W('1),.IMPL(0)) dut (
    .clk,.clk_f,.rst,.r_en,.r_req,.r_addr,.r_ben,.r_bad,.r_data,
    .w_en,.w_req,.w_gnt,.w_addr,.w_data,.blk_x,.blk_s,.lost,.frz,.dump
  );

  task automatic write_vector(input logic [31:0] base);
    @(negedge clk);
    for (int l=0;l<LANES;l++) begin
      w_en[0][l]=1; w_req[0][l]=1;
      w_addr[0][l]=l; w_data[0][l]=base+32'(l);
    end
    w_gnt[0]=1;
    @(negedge clk);
    w_en='0; w_req='0; w_gnt='0;
    repeat(3) @(negedge clk);
  endtask

  task automatic read_vector(input logic [31:0] base);
    @(negedge clk);
    for (int l=0;l<LANES;l++) begin
      r_en[0][l]=1; r_req[0][l]=1; r_addr[0][l]=l;
    end
    repeat(2) @(posedge clk); #1;
    for (int l=0;l<LANES;l++)
      if (r_data[0][l] !== base+32'(l))
        $fatal(1,"TMEM readback lane %0d: got %h expected %h",l,r_data[0][l],base+32'(l));
    @(negedge clk); r_en='0; r_req='0;
  endtask

  initial begin
    repeat(3) @(negedge clk); rst=0;
    repeat(2) @(negedge clk);
    write_vector(32'hA500_1000);
    read_vector(32'hA500_1000);
    write_vector(32'h5A00_2000);
    read_vector(32'h5A00_2000);
    $display("TMEMTEST PASS: reset, four-bank write/readback, overwrite and lane ordering");
    $finish;
  end
endmodule
