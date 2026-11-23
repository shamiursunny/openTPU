# SUNNYONE AI-X — WG8 DDR4 Integration Boundary

**Revision:** A1.12.11.16.50  
**Date:** 2026-11-24  
**Status:** RTL integration boundary added; lint/CI pending; not a complete PCIe/DDR ASIC

## Selected V1 logical configuration

- WG8 compute slice: D=128, NCH=8, CB=128 bytes, AW=36 byte-address bits, CAW=26 beat-address bits per virtual channel.
- Addressable memory target: 32 GiB across four 8-GiB DIMM/controller ports. This is an address-space target; DRAM device, ECC organisation, controller IP, PHY and package remain unselected.
- Each native 128-byte channel is bridged by `otpu_hbm_ch` to a 256-bit AXI3 channel.
- Each pair of channels is combined by `otpu_mig_pair` into one 512-bit AXI4 DIMM port. Four pairs expose four 512-bit ports.
- Each 512-bit port uses 64-byte INCR transactions (AxSIZE=6, AxBURST=INCR); attributes are fixed in the wrapper. The two 256-bit channel halves are interleaved by the pair logic at 4-KiB boundaries.
- Per-channel bridge error is sticky and is ORed into the ASIC memory-fatal input. All four calibration inputs are grouped into two status groups; RUN requires both groups ready, therefore all four DIMMs calibrated.

## RTL hierarchy

`otpu_asic_wg8_ddr4_top`
→ `otpu_asic_mem_top` (control + compute + native memory adapter)
→ 8 × `otpu_hbm_ch` (native 128-byte channel → AXI3 256-bit)
→ 4 × `otpu_mig_pair` (two AXI3 channels → AXI4 512-bit)
→ four external DIMM/controller ports.

## Exact boundary and non-claims

This wrapper is a significant integration step, but it does **not** yet instantiate:
1. PCIe Gen3 x16 endpoint/PHY or host DMA engine.
2. The host-DMA/accelerator AXI arbitration/interconnect and shared ordering domain.
3. DDR controller IP, PHY, calibration implementation, ECC datapath or DRAM electrical interface.
4. IOMMU/DMA address aperture, MSI-X, FLR/hot-reset logic or full endpoint reset containment.
5. Foundry PDK cells, SRAM macros, DFT, package, power grid or physical signoff.

The four AXI4 ports are accelerator-side controller interfaces. A production SoC must integrate a host DMA master into the same controller/interconnect domain; the host and accelerator must observe write visibility and read-after-write ordering. Do not connect host DMA to an unrelated memory path.

## Verification gates

- Verilator lint of the complete wrapper hierarchy using the BCU1525 WG8 generic RTL source set.
- Functional bridge/pair simulation with two masters and four independent DIMM models; check address mapping, 4-KiB bursts, partial writes, backpressure, response routing, reset and error propagation.
- End-to-end DMA-to-model execution and ISA comparison after endpoint/DMA RTL exists.
- CDC/RDC and formal checks across core/aclk/controller domains.
- Synthesis/PPA with real SRAM and controller IP, then multi-corner STA, IR/EM, DRC/LVS and package/thermal qualification.

## Platform and cost

BCU1525/VU9P remains the WG8 performance reference, not an authorised purchase. Its current Vivado licence constraint conflicts with zero-spend. ECP5-5G Versa remains a reduced open-tool demonstrator only and cannot host WG8 or qualify PCIe DMA. No FPGA, IP, software licence or cloud service purchase is authorised.
