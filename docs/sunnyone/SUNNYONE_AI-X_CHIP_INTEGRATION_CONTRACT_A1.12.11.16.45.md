# SUNNYONE AI-X — ASIC Chip-Level Integration Contract

**Revision:** A1.12.11.16.45  
**Date:** 2026-11-24  
**Status:** logical integration contract; not completed RTL, physical implementation, or tapeout signoff  
**Parent:** `SUNNYONE_AI-X_REFERENCE_CHIP_ARCHITECTURE_A1.12.11.16.44.md`  
**Repository:** `shamiursunny/openTPU`

## 1. Frozen product architecture

A host-controlled, programmable inference accelerator. Host CPU performs model loading, scheduling, runtime, security policy and telemetry. The accelerator has no embedded application CPU or boot ROM in V1. Existing openTPU sequencer, MXU, VPU, quantisation, DMA/stream, TMEM, ACT RAM and collective logic remain the compute foundation.

The Nangate45 `card` target is the logical compute configuration for ASIC research, not the selected manufacturing process:
- D=128, MCOLS=4, LANES=8, ULANES=8, MXU systolic implementation 2, MXU_CL=16, MXU_E=4, VPU_CL=2.
- ACT_BLOCKS=128, ACT_ROWS=8, TMEM=65,536 words, IMEM=32,768 words, FIFO_DEPTH=1,024.
- ASIC TMEM candidate: one-copy 1RW1R macro architecture, TMEM_IMPL=3, TMEM_NSB=2, replay/TDP/guest arbitration enabled, no 2x clock pump. Keep the three-copy banked implementation as correctness/PPA fallback until same-RTL comparisons settle.
- One compute slice for V1. Multi-slice scaling is a later measured option.

## 2. Required chip-level blocks

1. PCIe endpoint / hard IP and reset/link-status interface (platform-vendor IP; not present in current open RTL).
2. BAR0 AXI4-Lite slave and host register block, preserving the existing `otpu_ctrl` software-visible register semantics where applicable.
3. DMA engine / AXI4 host-data interface, including descriptor ownership, burst splitting, IDs, byte strobes, error reporting and backpressure.
4. DMA-to-accelerator memory adapter translating host AXI traffic and the compute A/SW/B memory ports without violating ordering or idle contracts.
5. openTPU compute block (`otpu_asic_top`) with run/load/status and local-memory ports.
6. External-memory controller interface and PHY (platform-specific IP), with ECC, calibration, refresh, timeout and error reporting.
7. Clock/reset/power manager, CDC/RDC isolation, watchdog and fault recovery.
8. DFT/scan, debug lifecycle and manufacturing test structures (production implementation required).

No block may be treated as implemented merely because it appears in this logical partition.

## 3. External interface contracts

| Interface | Logical contract | Current evidence / status |
|---|---|---|
| Host control | AXI4-Lite BAR0; 32-bit register access; preserve ID/VERSION/CTRL/STATUS/PROG_ADDR/PROG_N/ARG/CAPS semantics | Existing `otpu_ctrl` is in board RTL; not yet integrated with `otpu_asic_top` |
| Host data | AXI4 memory-mapped DMA; 128-bit data path is the existing YPCB XDMA reference; full INCR bursts, IDs, byte strobes, responses | Existing YPCB Gen2 x8 board path; no ASIC PCIe endpoint or ASIC DMA bridge |
| Compute memory A | 32-bit word address/write data, 4 byte enables, 256-bit aligned read return with ready/valid/idle | Implemented `otpu_asic_top` boundary |
| Compute memory SW | 32-bit scalar write address/data, 4 byte enables | Implemented `otpu_asic_top` boundary |
| Compute memory B | 32-bit address; D*8 data and D/4 write mask; tag/parity/read-valid | Implemented `otpu_asic_top` boundary; D=128 means 1,024-bit chunks |
| External DRAM | Controller-specific command/data/response plus calibration/ECC status | Not part of `otpu_asic_top`; exact memory/controller/PHY not selected |
| Management | Temperature, voltage/current monitors, ECC counters, watchdog, reset cause and build/config ID | Partial board telemetry exists; ASIC sensors/PMBus and safety path not designed |

### Host register behaviour

- Reset must leave RUN deasserted and the compute block held in reset.
- LOAD is accepted only while stopped and memory is calibrated/available; it generates a single-cycle loader request using PROG_ADDR and PROG_N.
- RUN is accepted only after memory calibration, loader completion and no fatal memory/clock error.
- RUN falling stops new compute requests; outstanding writes must drain before host memory reuse. Reads in flight are discarded only under the documented reset/abort contract.
- STATUS must expose HALTED, ERROR, LOADING, WR_IDLE, AXI/memory error, calibration, RUN, timeout and uncorrectable ECC.
- Unsupported or reserved writes return a defined AXI-Lite response; no silent aliasing.
- Host software must read immutable capability/configuration fields and reject incompatible binaries.

This register behaviour is a required compatibility contract, not a claim that the ASIC control RTL exists. A dedicated control-wrapper RTL and AXI-Lite testbench are still required.

## 4. Clock and reset domains

Minimum domains to budget:
- PCIe reference/user clock and PERST#/hot-reset/link-down.
- Accelerator core clock.
- Each external memory controller/PHY clock domain.
- Optional SRAM/DRAM maintenance or telemetry domain.

Every crossing needs an explicit synchronizer/FIFO or registered bridge, reset-release synchronisation, asynchronous assertion policy, and CDC/RDC report. PCIe reset must not accidentally reset a memory controller's CDC FIFO on only one side. The YPCB top's documented reset isolation is a useful reference, not an ASIC implementation.

Run enable is gated by PCIe/link availability where required, stable clocks, memory calibration, ECC state and completed initialisation. A clock-loss or uncorrectable-memory error must stop/contain compute and surface a sticky error.

## 5. Memory and reliability requirements

- External memory capacity and channel count are workload-derived; 128 GB/256 GB are not V1 requirements.
- ECC is mandatory for a reliability-oriented product. Correctable errors are counted/reported; uncorrectable errors prevent silent use of corrupted data and force explicit recovery.
- Validate read-after-write, partial-write merge, simultaneous DMA/compute access, ordering, burst boundaries, address isolation, reset during outstanding traffic and memory-controller backpressure.
- Host DMA addresses must be constrained by IOMMU mappings and hardware aperture checks. Per-tenant isolation and secure zeroisation are not claimed until end-to-end verified.
- Define scrub, refresh, retention, poison/error propagation and reset recovery for the selected memory technology.

## 6. Board validation platform

Primary existing performance-validation reference: BCU1525 / VU9P, PCIe Gen3 x16, four DDR4 DIMM channels, using the repository's existing WG board simulation and documented real-card model runs. It validates the accelerator's board-memory workload path, not a future ASIC PCIe endpoint.

Secondary bridge-validation reference: YPCB-00338 / Kintex-7 XC7K480T, PCIe Gen2 x8, two DDR3 channels. The new `tools/memch_test.py pcie` suite exercises its XDMA-facing AXI/memory bridge at asynchronous clock ratios. The first run failed before scenarios because Ubuntu's Verilator 5.020 could not compile a testbench queue assignment; CI was pinned to Verilator 5.044 and rerun is pending. No PCIe simulation pass is claimed.

Neither board is selected as the commercial product board. No hardware purchase or paid licence is authorised.

## 7. Physical implementation and commercial gates

The Nangate45/FreePDK45 results are research proxies only. The existing historical card point has negative setup slack and cannot be used as signoff. A real implementation requires a licensed manufacturable foundry PDK, qualified SRAM compiler/macros, PCIe and memory PHY/controller IP, DFT, multi-corner STA, CDC/RDC, IR/EM, ESD, package/substrate, SI/PI, thermal analysis and manufacturing test.

Before selecting process, package or board, benchmark representative customer workloads and measure useful tokens/s, latency percentiles, quality, uptime, wall power, cooling, host/platform cost, memory cost, BOM, manufacturing yield assumptions, support cost and contribution margin. Select the operating point by full-system TCO and risk-adjusted payback, not peak TOPS or watts.

## 8. Exit criteria

- C1: control wrapper and host register testbench pass.
- C2: DMA/memory adapter passes AXI protocol, ordering, partial-write and reset tests.
- C3: full ASIC top compiles/lints with no unexplained warnings.
- C4: formal properties cover AXI stability, FIFO safety, address bounds, reset isolation, run/load gating and memory response accounting.
- C5: selected memory controller/PHY model passes calibration, ECC injection/recovery and timing tests.
- C6: exact RTL has reproducible synthesis/place/route and timing closure in a real target PDK.
- C7: board-level PCIe, DDR, CDC/RDC, SI/PI, power and thermal validation passes.
- C8: real model workload and independent commercial/TCO evidence meet the product requirements.

**Disposition:** the compute architecture and its ASIC research parameter point are selected. The chip-level host/DMA/memory integration, target PDK/IP, physical design, package, board and production qualification are not complete. This document deliberately does not label the design final or tapeout-ready.
