# SUNNYONE AI-X — PCIe Host Interface Contract

**Revision:** A1.12.11.16.48  
**Date:** 2026-11-24  
**Status:** interface architecture selected; endpoint/DMA RTL and verification not yet implemented  
**Applies to:** WG8 V1 ASIC candidate and BCU1525 reference platform

## 1. Selection

- V1 compatibility target: **PCIe Gen3 x16**.
- Reason: matches the BCU1525 WG8 reference, existing XDMA host path and current board-level software model; avoids selecting a higher-speed PHY before workload evidence.
- Theoretical one-direction payload ceiling before protocol overhead: approximately 15.75 GB/s (8 GT/s × 16 lanes × 128/130 ÷ 8). Actual throughput must be measured.
- Do not choose Gen4 x8 solely because its raw encoded line rate is similar; compare endpoint/PHY IP cost, power, package pins, SI/PI and real DMA throughput first.
- The ASIC requires a foundry-qualified PCIe endpoint/PHY and controller IP. This repository's XDMA simulations are not a substitute for that IP.

## 2. Logical datapath

`PCIe Gen3 x16 endpoint + DMA` → `BAR0 AXI4-Lite control` and `512-bit AXI4-MM DMA master` → `memory arbitration / address interleave` → `four 512-bit external-memory controller ports`.

The compute side remains:
`otpu_asic_mem_top` → eight 128-byte native channels → per-channel bridge → paired 512-bit controller ports.

The eight logical channels are mapped two per physical controller port, consistent with the BCU1525 WG8 reference. Host DMA and accelerator traffic must share the same memory-controller ordering/arbitration domain. A host write must become visible to a later accelerator read; host reads must not observe incomplete writes. A controller's ECC and byte-mask behaviour must cover both masters.

## 3. Host endpoint contract

- BAR0: AXI4-Lite 32-bit register access, with the ASIC v5 control block at offset 0. Preserve ID, VERSION, CTRL, STATUS, PROG_ADDR, PROG_N, ARG/RINIT, counters, CAPS/CAPS2 and CFG register semantics.
- BAR address decoding and any management/telemetry windows must not alias the accelerator register block. No SYSMON/temperature-register behaviour from the FPGA board is copied without an ASIC-safe implementation.
- DMA: endpoint provides a 512-bit AXI4 memory-mapped master to the card-memory interconnect. Use 64-bit host DMA addresses, explicit descriptor ownership/completion, bounded outstanding transactions, byte strobes, response/error propagation, and 4-KiB burst-boundary compliance.
- Support host-to-card and card-to-host transfers, MSI-X completion/error interrupts, function-level reset and hot-reset containment. The endpoint must not release compute RUN until memory calibration and initialisation are complete.
- IOMMU/DMA aperture enforcement and privileged register access are mandatory product requirements; host-supplied addresses are untrusted.
- Driver must use DMA buffers and explicit synchronisation; do not treat a BAR mapping as a coherent cache or bypass ownership fences.

## 4. Memory ordering and reset

- Per controller, arbitrate host DMA and accelerator channel traffic in one ordering domain. Define visibility at the controller acceptance/response boundary.
- A DMA write completion must not be reported before the controller confirms the write and its ECC status.
- A read-after-write from the other master must return the new data; simultaneous overlapping writes need deterministic arbitration or a documented error.
- During FLR, hot reset, link-down, or endpoint reset: stop issuing new DMA; drain or abort outstanding requests with explicit error completion; keep controller state and DRAM contents safe; clear stale descriptors; keep compute stopped until host reinitialisation.
- Cross PCIe user clock, core clock and memory-controller clocks only through qualified asynchronous FIFOs/CDC bridges. The ASIC core wrapper currently synchronises status bits only; it does not yet implement the PCIe or memory data CDC paths.

## 5. Simulation strategy (before physical hardware)

1. **Existing PCIe-side bridge:** YPCB Gen2 XDMA-facing AXI/native-memory regression, including partial beats, backpressure, 64-deep bursts, CDC skew and repeated reset. Run 45239360365 passed six scenarios; this does not test PCIe serial link training.
2. **Existing WG8 board model:** simulate the actual one-slice/eight-channel accelerator, four DIMM AXI ports, latency, jitter, bandwidth limits, stalls and out-of-order returns; compare model tokens/logits with the ISA simulator.
3. **ASIC native memory:** run the NCH=8, CB=128, AW=36 adapter regression, including SW_FILL partial-write merge and A/SW/B/W concurrency.
4. **New PCIe endpoint BFM (required):** model BAR0 AXI4-Lite, host DMA AXI4 read/write, descriptor queues, 4-KiB boundaries, partial writes, out-of-order host completions where permitted, MSI-X, IOMMU rejection, FLR/hot reset and link-down.
5. **Integrated host-to-model test (required):** host writes a model image through DMA, verifies controller visibility/ECC, programs arguments, LOADs, RUNs, reads output and compares with ISA reference.
6. **Physical board only after simulation:** enumerate PCIe, test BAR/DMA, measure link width/speed and throughput, inject reset/faults, qualify memory/ECC, thermal and wall power.

## 6. Explicit non-claims and open choices

- This contract is not a PCIe endpoint RTL implementation, PCIe PHY, DMA engine, DDR controller/PHY, package pinout or foundry PDK.
- Four 512-bit memory-controller ports are the first integration hypothesis derived from the BCU1525 WG8 reference. ASIC controller IP, DRAM type, ECC organisation, physical channel count and package must be selected using PDK/IP availability, capacity, measured workload and TCO.
- No Gen4, CXL, HBM or 128-GiB expansion is frozen.
- No board purchase or paid IP/license is authorised.
