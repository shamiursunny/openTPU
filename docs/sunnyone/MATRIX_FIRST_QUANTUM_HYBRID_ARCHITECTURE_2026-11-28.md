# SUNNYONE X — Matrix-First and Quantum-Hybrid Architecture Research Addendum
Date: 2026-11-28 (Asia/Dhaka)
Repository: `shamiursunny/openTPU`
Working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Status: architecture proposal only; no RTL, ISA, PPA or silicon claim.

## 1. Decision

Adopt a **matrix-first classical accelerator roadmap** and a **separate quantum-hybrid research interface**.

- Matrix computing is directly relevant to transformer inference, dense layers, attention projections, convolution and batched linear algebra. It belongs in the core accelerator roadmap.
- Quantum computing is not a practical replacement for the classical MXU/VPU or a cost-effective on-die inference engine today. Do not place qubits, cryogenic control, quantum gates or quantum memory on the SUNNYONE X silicon die.
- Keep the existing programmable openTPU implementation as the baseline. This addendum does not authorise an RTL redesign, new ISA operation, extra die area, PDK/IP purchase, PPA run or hardware expense.

## 2. Matrix-engine improvements to investigate

The current design already contains an MXU matrix datapath, VPU, quantisation paths, TMEM/local storage, DMA/streaming and a programmable sequencer. The improvement is to make these a better-coordinated matrix-compute subsystem rather than assume a new accelerator is required.

### 2.1 Dataflow and tiling
- Preserve the existing tiled/systolic MXU dataflow as the starting point.
- Profile representative transformer workloads to determine useful M/N/K tile shapes, batch sizes, sequence lengths and tail utilisation.
- Investigate weight-stationary, output-stationary and row/activation-stationary schedules only where the current datapath and local memories can support them efficiently.
- Add a software/compiler tile planner before adding hardware complexity. Measure padding waste, reuse, occupancy and SRAM traffic.

### 2.2 Precision roadmap
Evaluate, in order and only with exact numerical tests:
1. Existing integer/fixed-point and quantisation modes as the baseline.
2. INT8 and lower-bit inference formats, including packed INT4 where accumulator range and unpack cost justify it.
3. BF16/FP16 input paths with wider accumulation if model accuracy and area/power evidence justify them.
4. FP8 only as a later research option with explicit scaling, saturation, exceptional-value and calibration semantics.

Do not claim that any format is supported by the current RTL until the ISA, compiler, arithmetic units, rounding, saturation and end-to-end tests prove it. Keep accumulation width mathematically sufficient for the maximum supported K, input range and scale.

### 2.3 Data movement and memory hierarchy
- Prioritise operand reuse in TMEM/local SRAM and avoid unnecessary external-memory round trips.
- Profile DMA burst efficiency, bank conflicts, read/write arbitration, replay, queue occupancy and stalls.
- Investigate double-buffered or multi-buffered tile staging only after proving SRAM port/area costs and deadlock-free scheduling.
- Keep ECC external-memory intent and the production controller/PHY as separate integration gates.
- Evaluate fusion of adjacent operations (for example projection plus bias/activation or quantise/dequantise boundaries) only when numerical equivalence is demonstrated.

### 2.4 Sparse and structured workloads
Treat sparsity as an optional later optimisation. First benchmark dense kernels. Any sparse path must include metadata bandwidth, decoding overhead, load balance, deterministic handling and a dense fallback. Do not assume theoretical sparsity translates to throughput or energy gains.

### 2.5 Acceptance metrics
Compare each candidate against the current baseline using identical workloads, checkpoints, compiler settings, precision/quality thresholds and system boundaries:
- useful tokens/s and requests/s, not peak MAC/s alone;
- time-to-first-token and inter-token latency distributions;
- model quality/error versus reference;
- sustained throughput under concurrency;
- bytes transferred per token and external-memory utilisation;
- local-memory hit/reuse, bank conflicts and DMA stall cycles;
- measured or consistently modelled energy per token and complete-system power;
- area/timing/resource cost and implementation complexity.

No numerical performance or energy improvement is asserted by this proposal.

## 3. Quantum-hybrid research path

### 3.1 Recommended boundary
Keep quantum execution off-die and optional. If a credible quantum workload emerges, a host-side runtime may submit selected jobs to an external QPU service or research system over a standard network/API. SUNNYONE remains the classical accelerator for neural-network inference and preprocessing/postprocessing.

Potential research domains include selected combinatorial optimisation, sampling and quantum-chemistry workloads. These are exploratory use cases, not evidence that a QPU accelerates LLM inference.

### 3.2 Interface concept (future software contract, not current RTL)
A future host runtime could define a provider-neutral job interface:
- job type and versioned problem representation;
- bounded input dimensions and validation;
- queue, timeout, cancellation and retry policy;
- provider/device capability discovery;
- result schema, confidence/statistical metadata and provenance;
- secure transport, tenant isolation and audit logging;
- deterministic classical fallback and reproducible baseline.

No custom quantum interconnect, qubit controller, cryogenic interface or quantum instruction extension is proposed for the first silicon.

### 3.3 Evidence gate before investment
For each candidate workload, compare:
1. Best available classical algorithm on CPU/GPU/SUNNYONE.
2. Quantum or hybrid method on a real accessible QPU, including queue and data-transfer overhead.
3. Solution quality, success probability, repetitions/shots and total wall-clock time.
4. Full economic and energy boundary, including remote service and orchestration costs.

Proceed only if independently reproducible results show a practical advantage on the target problem. A theoretical speedup, simulator result or vendor marketing claim is insufficient.

## 4. Integration and release controls

- Track A remains the full programmable inference accelerator; Track B remains a separately scoped first-silicon demonstrator.
- Matrix enhancements enter the RTL only after workload evidence, architecture review, ISA/compiler specification, resource estimates, formal properties and focused regression plan.
- Quantum stays a host-level research adapter until a concrete workload and measured advantage exist.
- Do not rerun historical successful RTL groups 3.1, 3.2 or 4, the long board suite, or cancelled workflow 45765362426 for reassurance.
- Preserve zero-spend. No PPA retry, paid QPU, paid cloud, IP, PDK, fabrication, packaging, board or lab test without explicit approval.
- Manufacturer handoff remains NOT READY. This addendum is not a design freeze, product claim, tapeout package or qualification evidence.

## 5. Next technical work

1. Finish the current MXU malformed-command bounds investigation: trace raw command ingress, legality checks, `h.M/c_M`, `mxm` state and all supported `MCOLS/LANES/WG` parameter combinations. Do not narrow the `mx_key` index until legal and malformed-command behaviour is proven.
2. Reconcile the existing Qwen run and the software-core run; isolate only a genuinely missing test scope, not a broad suite.
3. Build a workload-to-MXU profiling table for representative transformer shapes and current ISA operations.
4. Map candidate precision modes to actual RTL/compiler support and quantify required changes before proposing implementation.
5. Continue width warning triage, formal/SVA, CDC/RDC, SRAM/technology mapping, production PCIe/DMA/IOMMU and DDR PHY work.
6. Keep PPA and manufacturer gates closed until resource, target PDK and sponsorship conditions are independently satisfied.

## 6. Evidence boundary

The repository currently demonstrates selected functional RTL/software simulations and selected real-checkpoint Qwen simulation. Those results do not demonstrate physical QPU integration, physical silicon, production throughput, power/thermal efficiency, routed timing closure or manufacturer qualification.
