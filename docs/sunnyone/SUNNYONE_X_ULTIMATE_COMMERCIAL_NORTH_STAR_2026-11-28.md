# SUNNYONE X — Ultimate Commercial Product North Star
Date: 2026-11-28 (Asia/Dhaka)
Status: user-approved governing product objective. Strategic objective is fixed; implementation choices remain evidence-led.

## 1. Governing decision

The ultimate objective of SUNNYONE X is to create a commercially competitive, data-centre-friendly AI accelerator platform that maximises risk-adjusted lifetime profitability by delivering the greatest amount of accepted, useful AI inference work per unit of energy and total cost.

This is not a peak-TOPS contest. The product must jointly optimise:
- useful, quality-accepted tokens per second and per deployed dollar;
- joules per useful token and total system energy;
- idle and lightly loaded power, including aggressive safe clock/power gating of unused resources (not an unrealistic claim of literally zero leakage);
- heat, cooling demand and sustained thermal stability;
- manufacturing cost, die area, yield, packaging, test, memory and board cost;
- reliability, availability, fault containment, recovery and serviceability;
- memory, networking, storage and multi-accelerator scalability for real AI data-centre workloads;
- software maturity, model compatibility, compiler/runtime efficiency and deployment simplicity.

The north-star objective is fixed by the user. The technical route, block boundaries, process, memory technology, precision, capacity, and implementation may be changed only when evidence shows that a different choice better serves this same objective or is required for correctness, safety, manufacturability, or feasibility. Do not interpret strategic commitment as permission to preserve a technically inferior or unsafe implementation.

## 2. Unified compute strategy

Develop a cooperative heterogeneous accelerator using validated capabilities rather than duplicating engines:
- **TPU-class matrix engine / existing MXU:** dense matrix products, projections, supported tensor operations and matrix portions of attention.
- **Classical LPU role:** prefill and decode orchestration, long-context scheduling, KV-cache allocation/lifetime/paging, batching and token-latency control. Quantum-inspired methods are classical research hypotheses only; no QPU, quantum hardware or quantum-speedup assumption.
- **NPU / existing VPU and stream capabilities:** supported vector, elementwise, reduction, activation, normalisation and streaming neural operators.
- **Shared data plane:** TMEM/local SRAM, external memory, DMA, arbitration/interconnect, host interface and distributed storage/networking. Keep hot weights/KV in appropriate fast memory; use SSD/NVMe/object storage for cold corpora and archives.
- **System-scale data:** petabyte-scale corpus/storage/retrieval is a distributed system capability, not petabytes of on-chip SRAM/HBM and not a claim that every request attends to an entire corpus.

The existing MXU, VPU/stream, sequencer, TMEM, DMA, host/compiler/runtime and ASIC integration are the concrete starting point. A standalone LPU or fully integrated NPU fabric must not be described as implemented until source and tests prove it.

## 3. Commercial optimisation hierarchy

1. Correctness and accepted model quality are hard constraints.
2. Maximise useful sustained throughput under representative customer workloads.
3. Minimise joules per accepted token and total wall energy per request.
4. Minimise idle/low-load power and thermal/cooling overhead.
5. Minimise complete delivered-system cost and manufacturing risk.
6. Maximise uptime, predictable tail latency and operational simplicity.
7. Scale out only where customer demand and unit economics justify it.

A faster configuration is not automatically better. Additional power, memory, die area, packaging or specialised logic is justified only when its incremental accepted workload and contribution margin exceed incremental capital, energy, cooling, support and reliability costs.

## 4. Mandatory measurement contract

For every candidate, preserve exact model/checkpoint, tokenizer/template, quantisation, prompt distribution, output policy, context length, batch/concurrency, software revision and measurement boundary. Report:
- prefill tokens/s, time-to-first-token, decode tokens/s and inter-token latency P50/P95/P99;
- accepted useful tokens/s and requests/s with model/task quality checks;
- joules per million accepted tokens, wall power at idle/prefill/decode/mixed load and power at thermal steady state;
- temperatures, cooling power, throttling, uptime, failures and recovery;
- memory capacity/bandwidth/latency, KV bytes/token, DMA/network bytes, cache hit rate, stalls and utilisation;
- BOM, die/area/yield/packaging/test/NRE quotations or measured estimates, system TCO, cost per useful token, contribution margin and payback sensitivity.

Label each datum as measured, quoted, simulated, inferred or assumed. Never convert a simulation result into a silicon, power, thermal, cost or performance claim.

## 5. Hard engineering controls

- No invented specifications, benchmark results, PPA, silicon behaviour, customer demand or manufacturing quotes.
- No paid cloud/QPU, external spend, fabrication, PDK/IP purchase or hardware order without explicit approval.
- Keep all writes on `sunnyone/commercial-profitability-architecture-2026-11-23`; do not write to main.
- Do not rerun RTL groups 3.1, 3.2 or 4 merely for reassurance; do not restart cancelled run 45765362426; preserve historical successful evidence.
- Poll existing in-flight jobs before deciding on any recovery. Prefer one isolated missing test over broad duplicate CI.
- No new RTL block until a measured bottleneck, interface contract, resource estimate, error/recovery contract and focused verification plan exist.
- Preserve exact/dense/reference execution paths; any approximation, quantisation, sparsity, compression or speculative decoding needs explicit correctness and quality validation.
- Protect tenant isolation, memory bounds, cache identity, deterministic simulation, cancellation cleanup and error reporting.
- Manufacturer handoff remains NOT READY until the readiness matrix is satisfied, including physical implementation and independent qualification.

## 6. Execution roadmap

A. Reconcile branch, checkpoints, running workflows and existing evidence.
B. Complete RTL/software interface inventory and map actual hardware to MXU/TPU, VPU/NPU, LPU scheduling and memory roles.
C. Build deterministic workload traces and baseline simulator metrics for W1/W2/W3 first, then conditional long-context W4: prefill, decode, attention, KV lifecycle, contention, batching, cancellation and failure.
D. Profile supported model execution end-to-end; classify bottlenecks (compute, memory, interconnect, scheduler, host, software).
E. Optimise software/compiler/runtime and configuration first; use targeted RTL changes only when measurements justify them.
F. Evaluate energy, thermal, reliability and complete-system economics with reproducible methods.
G. Validate scale-out storage/retrieval/networking separately from per-request context length.
H. Close verification and manufacturer readiness gates before any physical submission.

## 7. Immediate first engineering action

The initial source inventory confirms that `otpu_asic_chip_top` exposes the PCIe BAR0 AXI4-Lite control interface and external core-memory adapter; `otpu_asic_top` instantiates one `otpu_slice`; the slice combines sequencer, DMA, MXU/ACT RAM, quantizer, VPU and TMEM. The sequencer dispatches independent unit operations using a dependency scoreboard; the MXU has a staged DRAM weight/scale path and TMEM result drain; VPU supports vector/composite and reductions; DMA supports LD/ST and streaming; TMEM is banked and arbitrated.

Next, complete the exact instance/handshake/queue/port map and then define a deterministic simulator workload contract. Do not claim a separate LPU or independent NPU macro exists.
