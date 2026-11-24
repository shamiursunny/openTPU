// Source-derived 32-GiB V1 global-to-DIMM address decoder.
// This block maps a device-relative global aperture offset to one of four DIMM-local
// host AXI ports. It is not a PCIe BAR decoder, DMA engine, burst splitter or crossbar.
module otpu_asic_global_addr_map (
  input  logic        request_valid,
  input  logic [63:0] global_addr,  // device-relative byte offset after BAR/IOMMU translation
  output logic        addr_valid,
  output logic        addr_error,
  output logic [1:0]  dimm_sel,
  output logic [33:0] dimm_addr   // bit 33 is zero; [32:0] is the 8-GiB DIMM-local aperture
);
  always_comb begin
    addr_valid = 1'b0;
    addr_error = 1'b0;
    dimm_sel   = 2'b00;
    dimm_addr  = 34'b0;
    if (request_valid) begin
      if (|global_addr[63:35]) begin
        addr_error = 1'b1;
      end else begin
        // Global: {DIMM[1:0], channel[0], channel-byte-offset[31:0]}.
        // DIMM-local: {channel-byte-offset[31:12], channel, channel-byte-offset[11:0]}.
        // This inserts the channel-select bit at bit 12, preserving 4-KiB boundaries.
        dimm_sel  = global_addr[34:33];
        dimm_addr = {1'b0, global_addr[31:12], global_addr[32], global_addr[11:0]};
        addr_valid = 1'b1;
      end
    end
  end
endmodule
