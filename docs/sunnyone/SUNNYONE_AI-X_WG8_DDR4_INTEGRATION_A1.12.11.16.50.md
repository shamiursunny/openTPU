# SUNNYONE AI-X — WG8 DDR4 Integration Boundary

**Revision:** A1.12.11.16.51  
**Date:** 2026-11-24  
**Status:** host/accelerator DIMM arbitration RTL integrated; CI pending; not a complete PCIe/DDR ASIC

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
→ 4 × `otpu_mig_hmux` (accelerator pair + host DMA → shared AXI4 DIMM port)
→ four external DIMM/controller ports.

## Exact boundary and non-claims

This wrapper now instantiates the repository's existing `otpu_mig_hmux` once per DIMM. Each DIMM accepts a dedicated 512-bit host-DMA AXI master alongside its accelerator pair. The mux arbitrates AR/AW, preserves AXI4 W ordering with a write-owner queue, routes B/R by reserved host ID bit 2, and inserts register slices on W/R. The four host interfaces use 34-bit **DIMM-local** addresses; the external DMA/address-translation block must perform the card-global-to-DIMM/channel permutation consistently with the accelerator mapping.

It still does **not** instantiate:
1. PCIe Gen3 x16 endpoint/PHY, XDMA-compatible DMA engine or host driver.
2. Card-global DMA address translation, IOMMU aperture enforcement, descriptor validation or MSI-X/interrupt handling.
3. DDR controller IP, PHY, calibration implementation, ECC datapath or DRAM electrical interface.
4. FLR/hot-reset containment, full CDC/RDC or reset fault-injection qualification.
5. Foundry PDK cells, SRAM macros, DFT, package, power grid or physical signoff.

The host and accelerator now converge at each DIMM's shared AXI path, rather than unrelated memory paths. End-to-end visibility/order still needs adversarial simulation with both masters active, including overlapping addresses, outstanding reads/writes, partial writes, response backpressure, reset and error injection. IOMMU and address-translation safety remain external and unimplemented.

## Verification gates

- Verilator lint of the complete wrapper hierarchy, including `otpu_mig_hmux`, using the BCU1525 WG8 generic RTL source set.
- Functional host+accelerator arbitration simulation on all four DIMMs; check AW/W owner ordering, AR/AW fairness, ID routing, 4-KiB boundaries, address permutation, partial writes, backpressure, reset and error propagation.
- End-to-end DMA-to-model execution and ISA comparison after endpoint/DMA RTL exists.
- CDC/RDC and formal checks across core/aclk/controller domains.
- Synthesis/PPA with real SRAM and controller IP, then multi-corner STA, IR/EM, DRC/LVS and package/thermal qualification.

## Platform and cost

BCU1525/VU9P remains the WG8 performance reference, not an authorised purchase. Its current Vivado licence constraint conflicts with zero-spend. ECP5-5G Versa remains a reduced open-tool demonstrator only and cannot host WG8 or qualify PCIe DMA. No FPGA, IP, software licence or cloud service purchase is authorised.

## Clock/reset handling added in RTL

The wrapper accepts one core clock and one DIMM/AXI clock. Each active-high per-DIMM reset is synchronised into the AXI clock domain using a two-stage reset synchroniser; each channel bridge is released one additional AXI-clock cycle after its DIMM pair. Core reset asynchronously asserts these synchronisers and their deassertion is observed through the AXI-clock stages. This follows the staged reset pattern in the BCU WG8 board integration. This is not a substitute for full CDC/RDC analysis or reset fault-injection verification.
