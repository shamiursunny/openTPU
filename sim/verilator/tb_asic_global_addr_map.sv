`timescale 1ns/1ps
module tb_asic_global_addr_map;
  logic request_valid;
  logic [63:0] global_addr;
  logic addr_valid, addr_error;
  logic [1:0] dimm_sel;
  logic [33:0] dimm_addr;

  logic [31:0] offsets [0:5];
  logic [63:0] test_addr;
  logic [34:0] inverse_addr;
  logic [1:0] expected_dimm;
  logic [33:0] expected_local;

  otpu_asic_global_addr_map dut (
    .request_valid, .global_addr, .addr_valid, .addr_error, .dimm_sel, .dimm_addr
  );

  task automatic check_address(input logic [63:0] address, input bit expected_valid);
    begin
      global_addr = address;
      request_valid = 1'b1;
      #1;
      if (expected_valid) begin
        expected_dimm = address[34:33];
        expected_local = {1'b0, address[31:12], address[32], address[11:0]};
        if (addr_valid !== 1'b1 || addr_error !== 1'b0 ||
            dimm_sel !== expected_dimm || dimm_addr !== expected_local)
          $fatal(1, "map mismatch addr=%h valid=%b error=%b dimm=%0d local=%h expected_dimm=%0d expected_local=%h",
                 address, addr_valid, addr_error, dimm_sel, dimm_addr, expected_dimm, expected_local);
        if (dimm_addr[33] !== 1'b0 || dimm_addr[11:0] !== address[11:0])
          $fatal(1, "guard/4-KiB-offset invariant failed addr=%h local=%h", address, dimm_addr);
      end else begin
        if (addr_valid !== 1'b0 || addr_error !== 1'b1 ||
            dimm_sel !== 2'b00 || dimm_addr !== 34'b0)
          $fatal(1, "out-of-aperture address not rejected addr=%h valid=%b error=%b dimm=%0d local=%h",
                 address, addr_valid, addr_error, dimm_sel, dimm_addr);
      end
    end
  endtask

  initial begin
    request_valid = 1'b0;
    global_addr = '0;
    #1;
    if (addr_valid !== 1'b0 || addr_error !== 1'b0 || dimm_sel !== 0 || dimm_addr !== 0)
      $fatal(1, "invalid request did not produce inactive zero outputs");

    // Aperture and DIMM/channel boundaries: 32 GiB is the first invalid byte.
    check_address(64'h0000000000000000, 1);
    check_address(64'h0000000000000fff, 1);
    check_address(64'h0000000000001000, 1);
    check_address(64'h00000000fffff000, 1);
    check_address(64'h00000000ffffffff, 1);
    check_address(64'h0000000100000000, 1); // DIMM0, channel1 base -> local 0x1000
    check_address(64'h00000001ffffffff, 1);
    check_address(64'h0000000200000000, 1); // DIMM1 base
    check_address(64'h00000003ffffffff, 1);
    check_address(64'h0000000400000000, 1); // DIMM2 base
    check_address(64'h00000005ffffffff, 1);
    check_address(64'h0000000600000000, 1); // DIMM3, channel1 base
    check_address(64'h00000007ffffffff, 1); // final byte in 32-GiB aperture
    check_address(64'h0000000800000000, 0); // exactly 32 GiB: invalid
    check_address(64'hffffffffffffffff, 0);

    // Sample every DIMM/channel and both sides of 4-KiB boundaries.
    offsets[0] = 32'h00000000;
    offsets[1] = 32'h00000001;
    offsets[2] = 32'h00000fff;
    offsets[3] = 32'h00001000;
    offsets[4] = 32'hfffff000;
    offsets[5] = 32'hffffffff;
    for (int d = 0; d < 4; d++) begin
      for (int s = 0; s < 2; s++) begin
        for (int k = 0; k < 6; k++) begin
          test_addr = (64'(d) << 33) | (64'(s) << 32) | 64'(offsets[k]);
          check_address(test_addr, 1);
          inverse_addr = {dimm_sel, dimm_addr[12], dimm_addr[32:13], dimm_addr[11:0]};
          if (inverse_addr !== test_addr[34:0])
            $fatal(1, "mapping not bijective d=%0d s=%0d offset=%h global=%h inverse=%h",
                   d, s, offsets[k], test_addr, inverse_addr);
        end
      end
    end

    $display("PASS: 32-GiB global map, four DIMMs, two 4-GiB channels per DIMM, 4-KiB interleave, inverse bijection and out-of-aperture rejection");
    $finish;
  end
endmodule
