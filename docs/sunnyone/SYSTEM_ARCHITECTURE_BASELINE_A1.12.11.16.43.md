# SUNNYONE AI-X — System Architecture Baseline (A1.12.11.16.43)

Date: 2026-11-23  
Status: **engineering baseline only — not a frozen production design**  
Branch: `sunnyone/commercial-profitability-architecture-2026-11-23`  
Pinned compute reference: FeSens/openTPU `d84db55712aba0d40811d7762cb052f05d55b7e5`

## 1. Design objective

Build a programmable inference system whose risk-adjusted long-term net profit and investment recovery are maximised while meeting customer-accepted quality, latency, uptime and reliability. Select power, memory, compute scale and packaging from measured workload throughput and full-system TCO. There is no fixed wattage ceiling. Do not optimise peak TOPS, RAM capacity or watts in isolation.

This document defines the current system boundary and the implementation baseline. It does not claim a selected production FPGA/SoC/ASIC, completed RTL integration, physical feasibility, PPA, measured performance or commercial viability.

## 2. Proposed system partition

```
Customer applications / API
          |
Host server + service runtime + network
          |
PCIe or validated host interface [not selected]
          |
Host control registers (AXI4-Lite over PCIe BAR; implemented)
          |
Sequencer, host control/status registers, counters and trace
          |
Defined interconnect / DMA arbitration [system integration not implemented]
          |
+-------------------- programmable accelerator tile --------------------+
| Sequencer + instruction store                                          |
| MXU: tiled/systolic matrix engine                                      |
| VPU: vector, reductions, normalisation and elementwise operations      |
| Quantisation / dequantisation                                          |
| DMA + stream engine                                                    |
| Banked local TMEM + ACT RAM + FIFOs / scratch                          |
| ECC/error reporting at external-memory boundary [implementation open]  |
+-------------------------------------------------------------------------+
          |
External-memory controller / PHY [platform-specific; not in ASIC block]
          |
External memory + ECC + board power / cooling / sensors
```

The current reference is a host-controlled accelerator, not a CPU-led SoC: `otpu_board` integrates one or more slices, collective logic and `otpu_ctrl`; the host reaches the AXI4-Lite control register map through the PCIe bridge BAR. `otpu_mem_ch` arbitrates host XDMA and accelerator-native traffic into each memory controller, while `otpu_axi_split2` routes XDMA traffic across two channels by address bit 31. The board top owns clock crossings. The existing YPCB-00338 reference uses two DDR3 channels of 64-byte beats; other boards have different controller/channel topologies. No on-chip RISC-V CPU, boot ROM or secure boot chain is part of this current reference architecture. Do not add one unless a measured product requirement justifies it.

## 3. Compute-tile baseline

Use the existing openTPU ASIC/card architecture as the reference implementation, not as a claim that the full SUNNYONE SoC is complete.

Reference configuration already represented by `targets/nangate45.toml`:
- One slice; `D=128`, `MCOLS=4`, `LANES=8`, `ACT_BLOCKS=128`, `ACT_ROWS=8`.
- `TMEM_WORDS=65536`, `IMEM_WORDS=32768`, `FIFO_DEPTH=1024`.
- Systolic MXU `MXU_IMPL=2`, `MXU_CL=16`, `MXU_E=4`; VPU `VPU_CL=2`.
- Single-copy/replay TMEM configuration `TMEM_IMPL=3`, `TMEM_NSB=2`, `TMEM_RPL=true`, `TMEM_TDP=true`, `TMEM_GST=true`, `TMEM_PMP=0`.
- Stream and DSTEP support enabled in the target architecture.

These are a reproducible RTL/ASIC-flow reference point. They are not yet proven to be the commercially optimal tile dimensions, SRAM capacity, frequency or power point. Keep parameters configurable until workload traces and PPA justify a freeze.

Existing RTL provides the sequencer, MXU, VPU, quantisation, DMA/stream engine, local memories and collective logic. The MXU supports multiple low-precision weight paths; exact model/operator coverage must be validated per workload. Do not assume that a supported kernel means an entire model is supported.

## 4. Memory and data movement

- Keep local SRAM scratchpads and DMA explicit; size/bank them from measured tensor, activation, KV-cache/recurrent-state and weight traces.
- The `otpu_asic_top` boundary is a memory-port interface, not a DDR PHY/controller. The memory controller, PHY, board routing, training and ECC integration are platform responsibilities.
- Select external memory technology, channel count, width, capacity and rate only after model residency, concurrency, bandwidth, latency, reliability and cost are measured.
- Treat 128 GB and 256 GB as stretch investigations, not mandatory baseline capacity. Capacity must have demonstrated workload and economic value.
- Compare controller options only on an exact device/package and generated-IP configuration. A generic controller marketing limit is not package/pinout proof.
- Require ECC/error reporting, refresh/training validation, timeout handling, retry policy and memory fault injection before hardware qualification.

## 5. Host, interconnect, control and security

Implemented reference interfaces:
- `otpu_ctrl`: AXI4-Lite host control/status register map v5, reached through the PCIe bridge BAR. It exposes RUN/LOAD, calibration gating, halt/error/timeout/ECC status, cycles, retired instructions, memory request/stall counters, capabilities, build ID, temperature and trace controls.
- `otpu_mem_ch`: separate asynchronous command/data/read FIFOs for accelerator-native traffic and XDMA host traffic; channel arbiter; read credits/tags; per-master ordering and write batching.
- `otpu_axi_split2`: two-channel XDMA address split using address bit 31, preserving each master transaction's response ordering.
- `otpu_board`: slice/collective/control integration and board-level clock crossings. The YPCB-00338 reference uses two DDR3 channels with 64-byte beats; do not assume this topology transfers to another package or memory technology.

Qualification still required: exhaustive AXI protocol/backpressure/error tests; CDC/RDC analysis; reset and calibration-loss fault injection; starvation/fairness and queue-overflow tests; ECC uncorrectable-error recovery; memory-controller timeout handling; host-driver recovery; security review of PCIe BAR access, DMA address isolation, firmware/bitstream provenance and debug interfaces. The current register map and board logic do not establish production secure boot, tenant isolation or a complete security architecture. Do not introduce an on-chip RISC-V management CPU by assumption; the existing host-controlled sequencer/control design is the baseline.

## 6. Software and model support

Required stack: model/operator compatibility manifest; compiler or graph lowering; quantisation/calibration tools; kernel library; runtime/scheduler; memory planner; host driver/API; profiling and error reporting. Preserve immutable model/tokenizer revisions and licence records.

Initial benchmark hypotheses remain W1 generative serving, W2 embedding/reranking, W3 batch document/text processing. Qwen candidate checkpoints are workload probes, not validated customer demand or guaranteed supported models. Map each model operator to a tested kernel and record unsupported/fallback operators. Measure model quality alongside speed.

## 7. Power and commercial selection rule

Compare at least efficient, balanced and high-throughput configurations under identical model revision, quality, context, input/output mix, concurrency, SLA and uptime. Measure complete-node wall power at idle, prefill, decode, mixed load and stress; measure sustained useful output, TTFT/inter-token latency p50/p95/p99, uptime, throttling and failure rate.

Approve an upgrade only when conservative-case incremental collected contribution exceeds incremental capex recovery, electricity, cooling, support, replacement, financing and reliability risk. No tokens/s, tokens/J, cost/token, break-even, profit or payback value is currently established.

## 8. Verification ladder and release gates

| Gate | Required evidence | Current status |
|---|---|---|
| G0 — RTL regression | Reproducible RTL/ISA tests and CI logs | **Partial pass:** latest selected regression 99 passed, 118 deselected |
| G1 — Core correctness | ISA equivalence across supported operators, reset/fault/backpressure, memory arbitration and long runs | In progress; latest 99-test result is not full qualification |
| G2 — Formal/lint | Assertions and formal properties for DMA, queues, arbitration, reset, ECC/error paths; lint issues triaged | Not complete |
| G3 — Generic ASIC feasibility | Reproducible synthesis, macro mapping, floorplan, CTS, routing, timing and area in reference flow | Existing NanGate45 flow is a research proxy; current release result not established here |
| G4 — Target device | Exact orderable part/package, legal pins, resource fit, memory IP, clocking and I/O allocation | Not selected |
| G5 — Board/memory | Schematics, SI/PI, power/thermal, memory training, ECC and fault tests | Not started |
| G6 — Workload qualification | Real model serving, quality, latency, throughput, sustained wall power and repeatable raw logs | Not run |
| G7 — Commercial validation | Customer interviews, paid pilot/contract, actual BOM/quotes, tariffs, TCO and downside payback | Not validated |
| G8 — Production signoff | Foundry/PDK, SRAM compiler, DFT/scan, CDC/RDC, STA corners, IR/EM, ESD, package, reliability, security and manufacturing test | Not defined / not started |

The NanGate45 FreePDK45 flow is a research PPA proxy, not a manufacturable foundry process. Its timing or power reports must not be presented as production silicon estimates.

## 9. Decisions intentionally left open

- Exact FPGA/SoC/ASIC device, package, process node and foundry.
- One tile versus multiple tiles; tile dimensions and operating frequency.
- SRAM macro compiler, capacity, banking, ECC and physical organisation.
- External memory type, capacity, channel topology, controller and PHY.
- Host interface, PCIe/Ethernet generation and board topology.
- No on-chip RISC-V CPU is selected for the first version. Any future embedded controller and secure-boot architecture require a separately justified requirement and design review.
- Precision mix and per-model kernel coverage.
- Power envelope, cooling, BOM, selling price and deployment model.

These are evidence-gated decisions, not omissions to fill with guesses.

## 10. Next execution order

1. Finish core RTL/ISA and fault/backpressure qualification; triage all lint warnings.
2. Run the reproducible Nangate45 card-point synthesis/place-and-route flow and archive area, timing, critical paths and estimated power with explicit proxy limitations.
3. Expand benchmark harness to collect true per-token timing, quality scores and sustained-run metadata; execute only when an authorised GPU endpoint is available.
4. Derive operator, SRAM, external-memory and concurrency traces from the same representative workload.
5. Re-evaluate efficient/balanced/high-throughput configurations using measured workload and TCO inputs.
6. Only then select exact device/package and memory topology, generate vendor IP, validate pins/resources, and design a board.
7. Complete host/IOMMU/DMA security contracts and recovery design. Do not add an on-chip CPU without a demonstrated requirement; complete physical and production signoff only after device selection.

## 11. Evidence snapshot

- Run `45209168224`: **99 RTL/ISA tests + 1 AXI-Lite test passed**. Run `45217729099` completed successfully but repeated the prior selection; its separate LDC test duplicates one of the 99 cases. Run `45222828630` is executing previously unselected RTL/ISA and board tests. These are selected regressions, not complete chip qualification.
- Branch reference at this baseline: `1cf9bd914f5f104eb186fa796d6be7df0d978072`.
- Pinned FeSens/openTPU reference remains `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- `main` must remain untouched; all project changes stay on the active development branch.
- Zero-spend software-first policy remains in force. No board, licence, cloud instance, paid service or purchase is authorised.
