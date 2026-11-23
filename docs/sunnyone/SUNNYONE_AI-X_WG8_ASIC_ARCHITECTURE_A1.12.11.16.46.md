# SUNNYONE AI-X — WG8 ASIC Architecture Candidate

**Revision:** A1.12.11.16.46  
**Date:** 2026-11-24  
**Status:** selected logical V1 candidate; RTL integration and verification in progress; not physical signoff  
**Supersedes:** the WG1/MCOLS4 candidate in integration contract A1.12.11.16.45 for performance-led V1 evaluation.

## 1. Why the architecture changed

The strongest existing model-inference evidence is the repository's **BCU1525-WG8** implementation, not the base two-slice BCU1525 configuration. The WG8 board target uses one wide slice, eight 128-byte virtual memory channels, 36-bit addressing and 32 GiB total memory. Its documented card runs include Qwen3.6-35B-A3B at 88.5%, Qwen3.8-27B at 90.6%, and GPT-OSS-20B at about 88% of the four DIMMs' 76.8 GB/s peak, with eight-token/logit bit-exact checks against the ISA simulator.

These are FPGA-card results, not ASIC measurements. The FPGA implementation uses features that cannot be copied blindly into an ASIC (notably pumped SRAM and posted channel writes). The ASIC candidate therefore retains the proven WG8 dataflow while disabling those FPGA-specific paths and requires fresh PPA, timing and workload validation.

## 2. Selected V1 ASIC compute configuration

| Parameter | Candidate |
|---|---:|
| Slices | 1 |
| D / MCOLS / WG | 128 / 8 / 8 |
| NCH / CB / AW | 8 / 128 bytes / 36 bits |
| Logical external memory | 32 GiB (8 × 4 GiB channels) |
| ACT blocks / rows | 128 / 16 |
| TMEM / IMEM | 128K / 32K words |
| FIFO depth / WIN | 2,048 / 32 |
| LANES / ULANES | 8 / 8 |
| MXU_IMPL / MXU_CL / MXU_E / MXU_QD | 2 / 16 / 8 / 4 |
| VPU_CL / VPU_CNS | 2 / 3 |
| TMEM | one-copy 1RW1R macro candidate (TMEM_IMPL=3), core clock only |
| DSTEP / DSTEP2 / ST16 / KT | on / on / e6m9 / on |
| OUTER / SEQ_WC / COLL_GATHER | off / on / BAR-only |
| SE_R / DMA_DEPTH | 2 / 512 |

ASIC-specific deviations: TMEM_PMP=0, MXU_PUMP=0 and XPOST=0. The external memory adapter must provide the eight-channel W-port read return. No FPGA-specific double-frequency SRAM or posted-beat path is assumed.

## 3. RTL integration delivered

- `rtl/asic/otpu_asic_top.sv` is parameterized for WG/NCH/CB/AW, wide A/SW/B addresses, channel parity, A-read width and the W-port request/data/slot interface. Its p_* posted-beat inputs remain explicit; ASIC top requires XPOST=0 for now.
- `rtl/asic/otpu_asic_chip_top.sv` now defaults to the WG8 candidate and integrates AXI4-Lite v5 control with the compute block. It exposes the A/SW/B/W memory-adapter contract. Memory-calibration, memory-error and ECC-DED status cross into the core clock through two-stage synchronizers.
- `rtl/asic/otpu_asic_mem_top.sv` integrates `otpu_native_dram` and exposes the eight native controller channels. It sets XSW=log2(FIFO_DEPTH)=11, PCW=13, uses 128-byte beats and starts with the BCU WG8 queue depths (APF8/AD16/RD16, XD64, QD16, WQD32). ASIC SW_FILL=1 read-merges partial scalar writes for ECC safety. The controller must return reads in per-channel command order, report accepted write beats in n_wdone, implement ECC-correct byte-mask writes for B-port traffic, and aggregate calibration/error/DED status.
- Added an ASIC-mode regression in `tests/test_native_dram.py`: NCH8/CB128, AB128, APF8/AD16/RD16, SW_FILL1, WPOST/XPOST/SWG off. It checks random A/SW/B/W traffic and read-merge behaviour against the native memory model; CI result pending. This is adapter-level evidence, not full chip/PHY validation.
- `targets/nangate45-wg8.toml` is the reproducible research target. `tools/asic/flow.py` now derives every supported ASIC-top parameter from the target's complete RTL parameter contract, including WG8, NCH8, CB128 and AW36. This permits a separate WG8 synthesis/PPA point instead of silently synthesizing the older WG1 point.
- The host-facing PCIe endpoint and DMA are not yet integrated. The control interface is the BAR0 AXI4-Lite boundary; the data DMA and memory adapter remain external blocks.

## 4. Chip-level memory/host contract

- A/SW/B/W handshakes and data are synchronous to the accelerator core clock inside the integrated native-memory wrapper. The external controller boundary is eight independent native channels.
- A-read return is 1,024 bits; B data is 1,024 bits; W return is eight valid bits plus 8,192 data bits. The channel selector/parity is 3 bits. A/SW/B/W addresses are 34-bit word addresses derived from AW=36 byte addressing.
- The external memory controller must implement eight 128-byte channels, channel hashing, byte/partial-write semantics, per-channel ordered read returns, outstanding-request accounting, refresh/backpressure and ECC. It must aggregate physical calibration into the two v5 status groups; all eight channels must be ready before RUN/LOAD. Scalar partial writes are read-merged by SW_FILL; B-port masked writes still require ECC-aware byte-write handling.
- PCIe endpoint/hard IP, BAR routing, host DMA descriptors, IOMMU aperture enforcement, DMA-to-memory arbitration and the external DDR controller/PHY are not part of current ASIC RTL.
- The existing YPCB Gen2 bridge's six passing tests qualify a separate two-channel, 64-byte XDMA bridge. They do **not** qualify this eight-channel WG8 memory interface or PCIe PHY.

## 5. Research PPA and verification gates

The new `nangate45-wg8` target is a research proxy only. No WG8 synthesis/place/route result has yet been produced. The prior Nangate45 WG1 results cannot be reused as WG8 area/timing/power evidence. The 32 GiB capacity is a logical target; the ASIC memory technology, ECC-capable devices, controller/PHY, package and board remain unselected.

Required next gates:
1. Compile/lint the WG8 top with the exact `nangate45-wg8` parameters.
2. Run the WG8 Yosys SRAM probe and full PPA flow; compare one-copy and banked TMEM if the one-copy macro mapping fails.
3. Extend the new WG8 native-adapter regression to cover 36-bit high addresses, controller resets, DMA/compute contention and ECC error injection; integrate a real controller model.
4. Integrate PCIe Gen3 x16 or better hard IP + DMA with a vendor/foundry-qualified controller; test host enumeration, BAR, DMA, reset/hot-reset and IOMMU isolation.
5. Complete formal, CDC/RDC, DFT, multi-corner STA, IR/EM, SI/PI, thermal, package and physical signoff using an actual manufacturable PDK.
6. Validate representative real models and whole-system economics. Choose power, memory capacity and clock from measured useful inference throughput, reliability, TCO and contribution margin.

**Decision:** WG8/32 GiB is the primary V1 architecture candidate because it has the strongest existing AI workload evidence. It is not yet a completed or tapeout-ready chip. 128 GiB is not the V1 target; revisit only after address-width, memory-channel, package and commercial feasibility are measured.
