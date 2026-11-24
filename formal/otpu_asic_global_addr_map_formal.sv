module otpu_asic_global_addr_map_formal;
  (* anyconst *) logic [63:0] global_addr;
  (* anyconst *) logic request_valid;
  logic addr_valid, addr_error;
  logic [1:0] dimm_sel;
  logic [33:0] dimm_addr;
  logic [34:0] inverse_addr;

  otpu_asic_global_addr_map dut (
    .request_valid, .global_addr, .addr_valid, .addr_error, .dimm_sel, .dimm_addr
  );

  always_comb begin
    inverse_addr = {dimm_sel, dimm_addr[12], dimm_addr[32:13], dimm_addr[11:0]};
    if (!request_valid) begin
      assert (!addr_valid);
      assert (!addr_error);
      assert (dimm_sel == 2'b00);
      assert (dimm_addr == 34'b0);
    end else if (|global_addr[63:35]) begin
      assert (!addr_valid);
      assert (addr_error);
      assert (dimm_sel == 2'b00);
      assert (dimm_addr == 34'b0);
    end else begin
      assert (addr_valid);
      assert (!addr_error);
      assert (dimm_sel == global_addr[34:33]);
      assert (dimm_addr == {1'b0, global_addr[31:12], global_addr[32], global_addr[11:0]});
      assert (dimm_addr[33] == 1'b0);
      // The decode is bijective over the complete 32-GiB device aperture.
      assert (inverse_addr == global_addr[34:0]);
    end
  end
endmodule
