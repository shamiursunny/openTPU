# SUNNYONE X — Quantum-Inspired LPU and Long-Context Inference Architecture
Date: 2026-11-28 (Asia/Dhaka)
Repository: `shamiursunny/openTPU`
Working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Status: architecture proposal / implementation plan; no RTL, ISA, benchmark or silicon claim.

## 1. User intent and architectural decision

The requested "quantum computing" idea is for **faster classical language-model inference**, not for executing quantum-computing workloads. The target is an advanced Language Processing Unit (LPU) capability that improves:
- prefill throughput when reading large prompts and documents;
- decode throughput (useful generated tokens per second);
- time-to-first-token and inter-token latency;
- long-context attention and KV-cache efficiency;
- concurrent requests, memory efficiency and energy per useful token;
- exactness/model quality relative to the selected reference model.

Adopt a **quantum-inspired, entirely classical LPU architecture** as a research direction. "Quantum-inspired" describes optional algorithmic ideas only; it does not mean quantum states, qubits, quantum gates, quantum speedup or a physical quantum processor. Do not assume quantum-inspired methods outperform conventional algorithms. Every candidate must beat a conventional baseline in reproducible tests.

This is a logical accelerator subsystem / roadmap, not a claim that the current RTL already contains a separate LPU. First map the design onto the existing MXU, VPU/stream engine, TMEM, DMA, sequencer, memory and host runtime. Add new hardware only if profiling proves an uncovered bottleneck.

## 2. Proposed logical LPU organisation

### 2.1 Context Ingest and Prefill Engine
- Stream prompt tokens in bounded chunks; overlap tokenisation/host transfer, embedding fetch, position handling and compute where dependencies permit.
- Tile Q, K and V projections onto the existing MXU; keep intermediate tiles in local SRAM/TMEM where capacity and port constraints allow.
- Implement numerically stable online/blocked softmax and attention reductions using existing arithmetic resources where possible.
- Support causal masks, padding masks and model-specific positional encodings exactly as required by each model.
- Preserve a dense/exact attention path. Any sparse, windowed or approximate path must be explicitly selected by a model/runtime contract and validated against the reference.

### 2.2 Long-Context Memory and KV Fabric
Use a tiered, explicitly managed context hierarchy:
1. **Hot tier:** current query tile, active K/V tiles and frequently reused metadata in local SRAM/TMEM.
2. **Warm tier:** paged KV blocks in external memory, with a block allocator, free-list, request ownership, refcounts and deterministic eviction rules.
3. **Reusable tier:** immutable prefix/KV cache entries keyed by model/checkpoint, tokenizer, positional settings, precision, adapter identity and exact prefix content/hash. Never reuse across incompatible keys.
4. **Optional retrieval tier:** host/runtime retrieval for application-selected documents. Retrieval is not a substitute for exact in-context attention and must be exposed as a semantic choice, not silently applied.

Required mechanisms: page/block tables, bounded prefetch, DMA coalescing, bank-aware placement, backpressure, admission control, per-request isolation, cancellation cleanup, and protection against stale or cross-tenant KV reuse. Compression/quantisation must record format, scales and error bounds and retain a lossless/reference path.

### 2.3 Attention and Matrix Compute Engine
- Reuse MXU for QKᵀ and probability-times-V matrix operations.
- Reuse VPU for supported elementwise, reduction, masking, normalisation and online-softmax stages; verify actual operation semantics and throughput before assigning work.
- Fuse operations only where bit/numerical semantics and dependency ordering are preserved.
- Investigate grouped-query and multi-query attention according to the model architecture; do not assume every model uses them.
- Investigate block-sparse or structured attention only where the model's trained architecture permits it. Keep dense fallback.
- Schedule tiles to maximise operand reuse and minimise external-memory bytes per token, not merely peak MAC utilisation.

### 2.4 Decode and Token Throughput Engine
- Separate prefill scheduling from latency-sensitive decode scheduling; use fair admission and bounded batching so long prefill jobs do not starve active decode streams.
- Use continuous batching and paged KV where supported by runtime/model semantics.
- Investigate speculative decoding only with a compatible draft model and a verifier path that guarantees accepted output tokens match the target model's defined decoding procedure.
- Parallelise verification work where mathematically valid; do not claim arbitrary parallel token generation for an autoregressive model.
- Keep deterministic sampling/seed controls and exact stop/EOS handling.

### 2.5 Quantum-inspired algorithm research lane (classical implementation)
Only test these as optional software/compiler/runtime methods:
- tensor-network-inspired factorisation or low-rank representations for selected attention/KV structures;
- structured state compression and approximate retrieval/routing;
- combinatorial scheduling/placement optimisation inspired by annealing or quantum optimisation heuristics;
- parallel candidate exploration for cache placement, tile ordering or workload scheduling.

These are hypotheses, not guaranteed acceleration. They must not alter model semantics silently. For each candidate compare against a strong classical baseline, include preprocessing and metadata overhead, test worst-case inputs, and retain deterministic fallback. Do not add qubit-like data types, quantum instructions or quantum control circuitry.

## 3. Proposed logical data path

1. Host submits model identity, prompt, generation policy, context limits and tenant/request ID.
2. Runtime validates compatibility and checks exact-prefix cache.
3. Context manager allocates paged KV and streams prompt chunks.
4. MXU performs projections and attention matrix products; VPU performs supported reductions/elementwise work.
5. KV manager commits validated K/V blocks and tracks ownership/lifetime.
6. Decode scheduler batches active requests and feeds the attention engine with the required historical KV pages.
7. Optional speculative verifier accepts only tokens consistent with target-model decoding.
8. Output stage returns tokens and records latency, throughput, memory and quality metrics.

All queues, allocators, clocks and simulator events must remain deterministic for a fixed input/seed/configuration. Backpressure and cancellation must not leak pages or expose another request's context.

## 4. Evaluation plan and acceptance gates

Build a workload matrix across representative supported models, prompt lengths, output lengths, batch/concurrency levels and attention types. Include short prompts, long prompts, prefix reuse, cache pressure, mixed prefill/decode, cancellation and adversarial allocation patterns.

Record at minimum:
- prefill tokens/s and time-to-first-token;
- decode tokens/s and inter-token latency (median, p95, p99);
- end-to-end request latency and concurrent useful tokens/s;
- maximum supported context length and exact prompt coverage;
- KV bytes/token, cache hit/reuse rate, DMA bytes/token, bank conflicts and stalls;
- energy/token only when measured on a defined physical platform or clearly labelled model;
- output equivalence / task quality, numerical error and deterministic repeatability;
- area, timing, SRAM capacity/ports and implementation complexity for any RTL proposal.

Acceptance rules:
- compare the same model/checkpoint, tokenizer, prompt, decoding settings, precision and hardware/system boundary;
- exact path must match reference outputs where deterministic semantics require it;
- approximate methods require explicit quality/error thresholds and user-visible opt-in;
- report p50/p95/p99, not just best-case peak;
- count host, memory, prefill, cache maintenance and verification overhead;
- no performance or power claim until measured and independently reproducible.

## 5. Staged implementation plan

**Stage A — software/simulator baseline (first):**
1. Inventory current host/runtime, compiler, MXU, VPU/stream, TMEM, DMA and memory capabilities.
2. Add traceable prefill/decode workload traces and a deterministic context/KV block allocator model.
3. Add paged-KV and prefix-cache correctness tests (ownership, key compatibility, eviction, cancellation, reuse and isolation).
4. Profile existing Qwen/LFM model paths to identify actual bottlenecks and collect baseline metrics.
5. Prototype chunked prefill, continuous batching and exact attention scheduling in software/simulation.

**Stage B — algorithm experiments:**
1. Compare dense tiled attention with candidate block-sparse/low-rank/tensor-network-inspired methods on supported model shapes.
2. Evaluate KV compression only with numerical and end-to-end quality checks.
3. Evaluate speculative decoding only with a compatible draft/verifier pair.
4. Test quantum-inspired scheduling heuristics against established deterministic classical schedulers.
5. Keep a result ledger; reject candidates that do not improve end-to-end metrics.

**Stage C — hardware proposal (only after evidence):**
1. Map proven bottlenecks to existing MXU/VPU/TMEM/DMA first.
2. Specify any additional context DMA, KV page-table/cache metadata, scheduler queues or attention datapath in an interface-level design.
3. Estimate SRAM ports/capacity, bandwidth, area, clocking, timing, power and verification burden before RTL.
4. Define ISA/compiler/runtime contract, formal invariants and focused tests.
5. Implement one narrow change at a time and run only the relevant new tests plus required regression gates.

**Stage D — physical validation:** only after design review, available PDK/technology access, resource approval and explicit user authorisation. No paid service or PPA retry is authorised by this proposal.

## 6. Non-goals and safeguards

- No on-die quantum computer, qubits, cryogenic control, quantum memory or QPU connection required.
- No claim of quantum speedup or quantum advantage for LLM inference.
- No arbitrary dropping, summarising or approximating of user context without an explicit model/runtime policy.
- No reduced precision, sparsity, compression or speculative decoding without correctness/quality validation.
- No unbounded KV allocation, cross-tenant cache reuse or nondeterministic hidden eviction.
- No new RTL/ISA instruction solely because it sounds quantum-inspired.
- No replacement of the existing MXU/VPU architecture until measured evidence justifies it.

## 7. Current evidence boundary and next action

The current repository contains an MXU, VPU/stream functionality, sequencer, TMEM, DMA and host/compiler infrastructure. This proposal is intended to organise and extend those resources for language-model prefill, long-context attention and decode. It does not establish that a separate LPU, paged-KV engine, quantum-inspired datapath or any associated performance improvement has been implemented.

Next action: create a software/simulator workload and trace inventory first, then profile existing supported model paths. Keep RTL unchanged until the measurements identify a concrete bottleneck and a design review approves a minimal implementation.
