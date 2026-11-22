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

  task automatic write_vector(input logic [31:0] addr_base, data_base);
    @(negedge clk);
    for (int l=0;l<LANES;l++) begin
      w_en[0][l]=1; w_req[0][l]=1;
      w_addr[0][l]=addr_base+32'(l); w_data[0][l]=data_base+32'(l);
    end
    w_gnt[0]=1;
    @(negedge clk);
    w_en='0; w_req='0; w_gnt='0;
    repeat(3) @(negedge clk);
  endtask

  task automatic read_vector(input logic [31:0] addr_base, data_base);
    @(negedge clk);
    for (int l=0;l<LANES;l++) begin
      r_en[0][l]=1; r_req[0][l]=1; r_addr[0][l]=addr_base+32'(l);
    end
    repeat(2) @(posedge clk); #1;
    for (int l=0;l<LANES;l++)
      if (r_data[0][l] !== data_base+32'(l))
        $fatal(1,"TMEM readback addr %0d lane %0d: got %h expected %h",addr_base,l,r_data[0][l],data_base+32'(l));
    @(negedge clk); r_en='0; r_req='0;
    repeat(2) @(posedge clk); #1;
    for (int l=0;l<LANES;l++)
      if (r_data[0][l] !== data_base+32'(l))
        $fatal(1,"TMEM hold failure lane %0d: got %h expected %h",l,r_data[0][l],data_base+32'(l));
  endtask


  task automatic simultaneous_read_write(input logic [31:0] addr_base,
                                          input logic [31:0] old_base,
                                          input logic [31:0] new_base);
    // Same-cycle read/write must return the old word (RAM read-first contract).
    @(negedge clk);
    for (int l=0;l<LANES;l++) begin
      r_en[0][l]=1; r_req[0][l]=1; r_addr[0][l]=addr_base+32'(l);
      w_en[0][l]=1; w_req[0][l]=1;
      w_addr[0][l]=addr_base+32'(l); w_data[0][l]=new_base+32'(l);
    end
    w_gnt[0]=1;
    @(posedge clk); #1;
    for (int l=0;l<LANES;l++)
      if (r_data[0][l] !== old_base+32'(l))
        $fatal(1,"TMEM same-cycle read/write lane %0d: got %h expected old %h",
               l,r_data[0][l],old_base+32'(l));

    // The write is now in pw_*; the next read cycle must receive its bypass data.
    @(negedge clk);
    w_en='0; w_req='0; w_gnt='0;
    @(posedge clk); #1;
    for (int l=0;l<LANES;l++)
      if (r_data[0][l] !== new_base+32'(l))
        $fatal(1,"TMEM staged-write bypass lane %0d: got %h expected new %h",
               l,r_data[0][l],new_base+32'(l));

    @(negedge clk); r_en='0; r_req='0;
    repeat(2) @(posedge clk); #1;
    for (int l=0;l<LANES;l++)
      if (r_data[0][l] !== new_base+32'(l))
        $fatal(1,"TMEM post-write hold lane %0d: got %h expected %h",
               l,r_data[0][l],new_base+32'(l));
  endtask

  initial begin
    repeat(3) @(negedge clk); rst=0;
    repeat(2) @(negedge clk);
    write_vector(0,32'hA500_1000);
    read_vector(0,32'hA500_1000);
    write_vector(0,32'h5A00_2000);
    read_vector(0,32'h5A00_2000);
    simultaneous_read_write(0,32'h5A00_2000,32'hD700_4000);
    write_vector(5,32'hC300_3000);
    read_vector(5,32'hC300_3000);
    $display("TMEMTEST PASS: reset, read/write ordering, staged-write bypass, four-bank readback, overwrite, wrapped mapping and read hold");
    $finish;
  end
endmodule
