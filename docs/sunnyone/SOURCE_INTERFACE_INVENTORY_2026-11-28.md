# SUNNYONE X — RTL and Software Source/Interface Inventory (initial)
Date: 2026-11-28
Branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Evidence type: source inspection only; no performance or silicon inference.

## 1. Top-level integration

| Source | Verified role | Interface / observed boundary | Status |
|---|---|---|---|
| `rtl/asic/otpu_asic_chip_top.sv` | ASIC control + compute subsystem wrapper | PCIe BAR0 AXI4-Lite control; core-memory adapter ports; external PCIe endpoint and memory controller/PHY | Existing RTL |
| `rtl/asic/otpu_asic_top.sv` | Portable compute block | Clock/reset, register init, loader, DRAM A/B, scalar write (SW), wide weight-group port W, prefetch interface, halt/error/wait/ICount | Existing RTL |
| `rtl/top/otpu_slice.sv` | One compute slice | Instantiates sequencer, DMA, MXU + ACT RAM, quantizer, VPU and TMEM; shared arbitration | Existing RTL |

The inspected `otpu_asic_top` instantiates one `otpu_slice` with `S(1)`. The chip wrapper supplies host control and exposes memory-adapter signals; PCIe endpoint/DMA and memory controller/PHY are explicitly external to this RTL boundary.

## 2. Engine mapping

| Existing block | Logical role in target platform | Source-confirmed responsibility | Not yet established |
|---|---|---|---|
| `rtl/mxu/otpu_mxu.sv` | TPU-class matrix engine | Systolic matrix/weight processing; DRAM weight and scale streams; ACT RAM operands; result FIFO and TMEM drain; ACC/ASCALE/RMAX paths | No system-level throughput or energy result |
| `rtl/vpu/otpu_vpu.sv` | NPU/vector engine | Lane-wise fp32 vector operations, composite functions, reductions; stream engine/tail integration | No standalone separate NPU macro |
| `rtl/seq/otpu_seq.sv` | LPU-like dispatch/scheduling foundation | Instruction fetch/decode; dispatch window and dependency scoreboard; overlapping independent units; ordered MXU start/release | Not a dedicated LLM token/KV scheduler |
| `rtl/dma/otpu_dma.sv` | Data movement / stream path | LD/ST between DRAM and TMEM; chunk buffering; DSTEP/STREAM support; queued transfer behaviour | No complete distributed memory/network controller |
| `rtl/mem/otpu_tmem.sv` | Local scratchpad / shared working memory | Banked TMEM with per-port read copies/arbitration, write broadcast and bypass behaviour | Not petabyte storage or a complete external HBM controller |
| ACT RAM / quantizer / host runtime/compiler | Matrix operand preparation and execution control | Existing slice-integrated units and software stack | Exact end-to-end LLM operator mapping requires profiling |

## 3. Source-confirmed scheduling and contention

- Sequencer documentation in RTL describes a dispatch window and scoreboard tracking RAW/WAR/WAW conflicts across TMEM, DRAM and ACT RAM ranges. Independent ready operations may overlap; MXU start/release has special ordering.
- Slice comments describe all-or-nothing TMEM grants. Priority includes DMA, collective, VPU, MXU drain and quantizer; a unit not granted holds. DRAM B arbitrates DMA before MXU stream reads; DRAM A carries MXU scale reads; QST has a separate scalar write port.
- These are implementation facts from source comments and module contracts. They are not evidence that the proposed LPU scheduling policy or a commercial multi-accelerator fabric exists.

## 4. First integration questions to close

1. Enumerate all concrete slice instances, compute-engine handshakes, command queues and completion/error signals at `otpu_slice`.
2. Map instruction/command fields and memory footprints for supported matrix, vector, quantizer and stream operators.
3. Determine whether LLM prefill/attention/decode kernels are compiled to supported instruction sequences without CPU fallback; record unsupported ops and conversion overhead.
4. Identify whether current host/runtime can express continuous batching, per-request cancellation, KV page ownership, cache identity and fair prefill/decode admission.
5. Map external-memory channels, bandwidth limits, backpressure, ECC/error reporting, reset and outstanding transaction cleanup through the actual board/ASIC wrappers.
6. Locate simulator/trace hooks and existing workload harnesses; specify deterministic request arrivals, token lengths, memory timing and contention.

## 5. Immediate simulator workload contract (to implement next)

Each request trace should carry: request ID, tenant ID, model/checkpoint identity, tokenizer/template identity, input token count, output target, context/KV size, arrival timestamp, deadline/priority, batch eligibility, cache key, cancellation/failure event and expected output-quality gate.

Emit deterministic events for:
- admission and queue wait;
- chunked prefill and matrix/vector dispatch;
- attention and KV allocate/read/write/pin/unpin/evict;
- decode step and token completion;
- DMA/TMEM/DRAM service and arbitration stalls;
- batching/dispatch decisions;
- cancellation, timeout, fault, recovery and resource release.

Required baseline outputs: accepted tokens/s, prefill throughput, TTFT, decode/inter-token P50/P95/P99, joules/token once a calibrated power model exists, memory bytes/token, KV peak/fragmentation, queue wait, engine utilisation, bank conflicts, stalls, cache hit/miss, fairness, cancellation cleanup and deterministic replay hash.

Do not invent energy numbers. Until power models or measured wall-power data exist, report operation counts and memory activity as proxies, clearly labelled as such.

## 6. Initial finding and next action

The source supports a credible heterogeneous foundation: matrix MXU + vector/stream VPU + sequencer + DMA + TMEM. The LPU should initially be a software/runtime/simulator scheduling role built around these existing blocks. The immediate next work is to finish the concrete instance/handshake map and find the existing simulator workload/trace extension points before adding code or RTL.
