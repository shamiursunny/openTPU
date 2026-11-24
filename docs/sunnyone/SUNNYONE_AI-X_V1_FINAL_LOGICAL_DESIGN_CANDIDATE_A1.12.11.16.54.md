# SUNNYONE AI-X — V1 Final Logical Design Candidate

**Revision:** A1.12.11.16.54  
**Date:** 2026-11-24  
**Status:** Selected logical architecture candidate; implementation and verification remain in progress. **Not tapeout-ready, not physically signed off, and not a complete host-connected ASIC.**  
**Repository:** `shamiursunny/openTPU`  
**Branch:** `sunnyone/commercial-profitability-architecture-2026-11-23`

## 1. Product definition

SUNNYONE AI-X V1 is a programmable, memory-attached AI inference accelerator built around the repository's WG8 compute architecture. It is not a general-purpose application CPU or a complete smartphone-class SoC. A host system supplies commands, model data and DMA traffic through the external host interface; the accelerator executes supported inference workloads and accesses external memory through eight native channels.

The design objective is to maximise risk-adjusted long-term net profit and realistic investment recovery while maintaining reliable, competitive useful inference. The power envelope is not pre-set. It must be selected from measured workload throughput, whole-system power and cooling, system TCO, reliability, utilisation and incremental contribution margin. Peak TOPS, memory capacity and watts are not optimisation goals in isolation.

## 2. V1 logical architecture

```text
Host CPU / server
   |
   | PCIe endpoint + link PHY + DMA descriptors + IOMMU/aperture + MSI-X
   | [external / not yet implemented]
   v
Four 512-bit host-DMA AXI4 masters (one DIMM-local port each)
   |
   +------------------------------+
   |                              |
   v                              v
Per-DIMM otpu_mig_hmux       AXI4-Lite BAR0 control
(host / accelerator pair)    (control block)
   |
   v
Four otpu_mig_pair blocks
(two 256-bit channel bridges -> one 512-bit DIMM port each)
   |
   v
Eight otpu_hbm_ch bridges
(native 128-byte channels -> 256-bit AXI3 channel halves)
   |
   v
Eight external DDR controller / PHY channels
[external / not yet implemented]
   |
   v
32-GiB logical DRAM map: 4 DIMM ports x 8 GiB

WG8 compute:
  one accelerator slice
  8 weight groups / 8 native memory channels
  MXU + VPU + sequencer + DMA + instruction and tensor memories
```

The RTL integration boundary is `rtl/asic/otpu_asic_wg8_ddr4_top.sv`. The host AXI interfaces and four per-DIMM arbitration blocks are integrated. PCIe, DMA descriptor processing, global address translation and the physical memory controller/PHY remain external.

## 3. Frozen logical V1 parameter candidate

| Parameter | V1 candidate | Meaning / qualification |
|---|---:|---|
| Slices | 1 | One WG8 compute slice |
| D / MCOLS / WG | 128 / 8 / 8 | WG8 dataflow |
| NCH / CB | 8 / 128 bytes | Eight native channels, 128-byte channel beat |
| AW / CAW | 35 / 25 bits | 32-GiB byte map; 25-bit beat address per 128-byte channel |
| Logical DRAM | 32 GiB | Eight 4-GiB native channels |
| DIMM/controller ports | 4 x 8 GiB | Two native channels per DIMM |
| AXI DIMM width | 512 bits | 64-byte AXI beat; 64-byte INCR transactions |
| AXI DIMM address | 34 bits | Bit 33 unused; must be zero and guarded |
| ACT blocks / rows | 128 / 16 | Activation memory configuration |
| TMEM / IMEM | 128K / 32K words | One-copy TMEM candidate |
| TMEM implementation | 1RW1R macro candidate | `TMEM_IMPL=3`, core clock only |
| FIFO depth / WIN | 2,048 / 32 | Candidate queue/window sizes |
| LANES / ULANES | 8 / 8 | Eight-lane execution |
| MXU_IMPL / MXU_CL / MXU_E / MXU_QD | 2 / 16 / 8 / 4 | Candidate MXU configuration |
| VPU_CL / VPU_CNS | 2 / 3 | Candidate VPU configuration |
| SE_R / DMA_DEPTH | 2 / 512 | Sequencer/stream and DMA queue settings |
| Core clock constraint | 400 MHz | Target constraint only; not achieved or measured silicon frequency |

ASIC-specific restrictions: `TMEM_PMP=0`, `MXU_PUMP=0`, and `XPOST=0`. FPGA-specific SRAM pumping and posted-channel paths are not assumed in this ASIC candidate.

The selected logical map is 32 GiB. The 128-GiB and 256-GiB configurations are stretch investigations only, not V1 requirements.

## 4. Address and memory contract

- The ASIC's byte-address width is AW=35. (2^{35}) bytes is 32 GiB.
- Each native channel has CAW=25 beat-address bits and CB=128 bytes: (2^{25}	imes128=4) GiB per channel.
- Eight native channels provide 32 GiB.
- Two native channels are paired into each 8-GiB DIMM/controller port. Four DIMM ports provide 32 GiB.
- The four host AXI4 interfaces are 34-bit DIMM-local addresses. Only the low 33 bits are valid for an 8-GiB DIMM; bit 33 must be zero.
- The external DMA/global-address translation block must map card-global byte addresses to the correct DIMM-local address and channel permutation. This mapping is not implemented by the current top.
- The four DIMM AXI ports use 512-bit data, 64-byte INCR beats, fixed AXI attributes from the wrapper and the existing pair/mux path.
- The controller must preserve per-channel ordered read returns and accepted-write accounting.
- `SW_FILL=1` read-merges partial scalar writes at the native adapter. B-port masked writes still require ECC-aware byte-write handling in the external controller.

## 5. Host and control contract

- Four 512-bit host AXI4 masters are exposed, one per DIMM. They are already DIMM-local at this boundary.
- Four instances of `otpu_mig_hmux` arbitrate host traffic and the corresponding accelerator-pair traffic. AXI4 W ordering is preserved by the mux's write-owner queue; B/R are routed using the reserved host ID bit.
- The host ID is the reserved bit-2 ID value (ID 4 for IDW=4). Accelerator-pair IDs must not use that bit.
- The control block is exposed as a 12-bit-address, 32-bit-data AXI4-Lite BAR0 interface. The PCIe endpoint and BAR routing are not instantiated.
- No on-chip RISC-V CPU or boot ROM is included in V1.

## 6. Clock, reset and error boundaries

- Core logic uses `clk`; the DIMM AXI path uses `aclk`. The wrapper accepts both clocks.
- Per-DIMM reset inputs are synchronised into `aclk`; each native channel bridge is released one additional `aclk` cycle after its DIMM pair.
- Calibration inputs are grouped into two status groups; both groups must be ready before the core can run.
- Per-channel bridge errors are aggregated into the memory-fatal path. ECC DED is an external status input.
- This reset structure is an RTL integration mechanism, not completed CDC/RDC, asynchronous fault recovery, hot-reset or FLR signoff.

## 7. Required external subsystems — hard blockers

These are not optional details; they are required to turn the logical candidate into a host-connected physical chip.

1. **PCIe endpoint and PHY:** target PCIe Gen3 x16 or an evidence-backed alternative. The current repository has no endpoint, SerDes, PIPE/PCS implementation or link-training hardware.
2. **DMA subsystem:** descriptor fetch/validation, host-memory read/write engines, global-to-DIMM translation, bounds checking, IOMMU/aperture protection, interrupt/MSI-X handling, completion/error reporting and Linux driver.
3. **DDR controller and PHY:** eight channels, initialization/training, refresh, timing scheduler, read-return ordering, ECC datapath, byte-write semantics, calibration, error reporting and electrical interface.
4. **Physical design:** a production-usable PDK and standard-cell/IO libraries, qualified SRAM macros, clock/reset tree, DFT/BIST, multi-corner STA, floorplan/place/CTS/route, parasitic extraction, DRC/LVS, IR/EM, SI/PI, package and thermal signoff.
5. **Board and product:** power delivery, cooling, memory devices, PCIe connector/clocking, firmware/driver, system validation, reliability and supply chain.

Open-source controller projects may provide reusable digital logic, but the reviewed candidates do not supply the required qualified ASIC PHYs. FPGA PHY wrappers, behavioural models and DFI simulation models are not substitutes for physical SerDes or DDR4 PHY macros.

## 8. Verification status and evidence discipline

- Run 72 on exact SHA `d281621836d86e608ad34c4fd44d6edf339e98fe` completed with **377 passed, 1 intentional 64-GiB address-window skip, 0 reported failures**. Four reset-audit tests executed and passed with the pinned Yosys/Slang toolchain.
- The 64-GiB skip is not evidence of 64-GiB hardware. The 32-GiB AW35 test remains the applicable address-window boundary case.
- A dedicated one-DIMM host/pair mux test has demonstrated two concurrent three-beat write bursts and two three-beat read bursts with B/R backpressure on earlier commits. The latest width-cleanup revision requires its own exact-SHA log before it is accepted.
- A new four-DIMM host-path testbench instantiates the actual `otpu_asic_wg8_ddr4_top` and exercises host traffic on all four ports. Its CI run is pending; no pass is claimed yet.
- The WG8 target test was corrected to expect AW35, consistent with the target and design specification; its exact-SHA config workflow is pending.
- A WG8 Nangate45 PPA workflow is configured and pins the resolved ORFS container image ID per run. Its current run is pending. Any Nangate45 result is a research proxy, not a manufacturable-process signoff.
- Full formal verification, exhaustive AXI protocol proof, full-chip integration, complete CDC/RDC, PCIe/DDR electrical validation, physical signoff, board testing and silicon measurement remain open.

## 9. Power, performance and commercial decision policy

No fixed 30-W total-system limit remains. No replacement wattage ceiling is selected. Do not infer ASIC power or performance from FPGA peak bandwidth, simulated cycles, generic synthesis, vectorless power or Nangate45 estimates.

Select clock, power, memory size, package and process only after measuring representative model workloads and the complete system:
- useful tokens/s and latency percentiles at realistic batch/concurrency;
- model quality/accuracy and correctness;
- memory bandwidth utilisation and capacity;
- wall power, cooling and tokens/J;
- board/server/network BOM, utilisation, maintenance and support;
- cost per useful token/inference;
- demand-backed pricing, gross margin, contribution margin, cash-flow and downside risk.

## 10. Design status

**Selected:** WG8, one slice, AW35, 32-GiB logical memory map, four 512-bit DIMM-local AXI ports, per-DIMM host/pair arbitration and AXI4-Lite control boundary.

**Not selected or not implemented:** production PDK, package, PCIe/DDR PHY, DDR controller IP, DMA engine, global address translation/IOMMU, host driver, power target, final clock, foundry, memory devices, manufacturing cost.

This document is the consolidated V1 logical design candidate. It is not a tapeout specification. The design cannot be called complete, production-ready or tapeout-ready until the external subsystem, verification, physical-design and silicon evidence gates are closed.

## 11. Source documents

- `SUNNYONE_AI-X_AUTHORITATIVE_CONTINUATION_BASELINE_A1.12.11.16.53.md`
- `SUNNYONE_AI-X_WG8_ASIC_ARCHITECTURE_A1.12.11.16.46.md`
- `SUNNYONE_AI-X_WG8_DDR4_INTEGRATION_A1.12.11.16.50.md`
- `PROJECT_TRACKER.md`
