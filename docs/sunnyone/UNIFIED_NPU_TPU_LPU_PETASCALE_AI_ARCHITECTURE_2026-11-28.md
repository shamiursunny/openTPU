# SUNNYONE X — Unified NPU, Matrix TPU and Quantum-Inspired LPU Architecture
Date: 2026-11-28 (Asia/Dhaka)
Repository: `shamiursunny/openTPU`
Working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Status: logical architecture proposal; not an implemented integration, silicon specification, benchmark or capacity claim.

## 1. Decision and interpretation

Adopt a **unified heterogeneous AI accelerator / NPU platform** in which a matrix-oriented TPU-class engine, a quantum-inspired classical LPU, and vector/neural processing capabilities cooperate through shared scheduling, memory management and interconnect.

The user's "petabyte-level" ambition is interpreted as **system/cluster-scale ability to address, stream, index and process very large AI datasets and context collections**, potentially reaching petabyte-scale storage across multiple servers/accelerators. It does not mean a single chip contains petabytes of SRAM/HBM, nor that a single NPU core has petabyte capacity. Capacity, bandwidth, latency, compute throughput and context length are separate measurable properties.

"Quantum-inspired" remains a classical algorithmic research direction for language-model inference. No qubits, quantum gates, QPU, quantum speedup or quantum-computing workload is required.

## 2. Unified logical block architecture

### 2.1 Host and system control plane
- Host CPU/server handles model loading, security/tenant policy, API, orchestration, compilation, global admission and telemetry.
- Device command processor / existing sequencer handles bounded device-side execution and local dispatch.
- A hierarchical scheduler coordinates host-level jobs, accelerator-level queues and engine-local work.
- Request metadata carries model/checkpoint, tokenizer, precision, sequence/context limits, tenant, priority, deadline and memory ownership.

### 2.2 Matrix TPU-class engine (existing MXU foundation)
Primary role:
- Dense matrix multiplication and tensor projections (including Q/K/V and feed-forward projections where model shapes map).
- Tiled GEMM and operand reuse.
- Matrix portions of attention (QKᵀ and probability-times-V).
- Supported quantised matrix paths only where ISA, RTL, compiler and numerical validation confirm them.

Optimise for useful sustained MAC utilisation, data reuse, memory bytes per operation, latency and energy, not peak theoretical TOPS alone.

### 2.3 Quantum-inspired classical LPU
Primary role:
- Streamed/chunked prompt ingestion and prefill scheduling.
- Language-model attention orchestration and long-context processing.
- KV-cache page/block allocation, lookup, prefetch, lifetime, eviction and safe reuse.
- Decode scheduling, continuous batching and inter-token latency control.
- Optional speculative decoding with a compatible draft model and exact target-model verification.
- Experimental quantum-inspired scheduling, structured routing, tensor-network/low-rank methods only when validated against strong classical baselines.

The LPU is a logical subsystem proposal. Map its initial functions onto existing sequencer, MXU, VPU, TMEM, DMA, memory and host runtime before proposing dedicated silicon.

### 2.4 NPU/VPU neural and vector engine
Primary role:
- Vector and elementwise operations.
- Supported reductions, activation functions, normalisation, masking and data transforms.
- Quantise/dequantise and other formats only where implementation and correctness evidence exists.
- Non-matrix neural operators that do not efficiently map to the MXU.

The existing VPU/stream functionality is the initial implementation base. "NPU" describes the coordinated platform and workload capability; do not imply that a separate standalone NPU macro already exists.

### 2.5 Shared memory, cache and interconnect fabric
- Local SRAM/TMEM for working tiles and short-lived intermediates.
- Explicitly managed KV pages and context blocks.
- External high-bandwidth memory for active model weights and hot KV where platform economics justify it.
- Host-attached memory / coherent expansion only if the selected platform supports and verifies the protocol.
- SSD/NVMe/object storage for cold datasets, model archives and retrieval corpora; these are not substitutes for low-latency active KV memory.
- DMA engines, crossbars/NoC, bank-aware arbitration, bounded queues, backpressure, ECC and isolation.
- Hierarchical cache policies and exact cache identity keys to prevent stale or cross-tenant prefix/KV reuse.

No technology (HBM, DDR, CXL, NVMe, SRAM macro or interconnect) is selected solely by this proposal. Choose from measured workload, platform availability, cost, power, capacity, bandwidth and implementation evidence.

## 3. Dataflow and cooperation

1. Host runtime accepts and validates a request, model identity, prompt and generation policy.
2. LPU/context manager checks exact-prefix cache compatibility and allocates bounded KV pages.
3. Prompt chunks stream through DMA; embeddings/position processing use supported neural/vector resources.
4. TPU/MXU performs matrix projections and tiled attention matrix products.
5. NPU/VPU performs supported elementwise, reduction, normalisation and online-softmax stages.
6. Shared memory fabric retains/reuses intermediate and KV blocks while maintaining ownership and backpressure.
7. LPU scheduler coordinates active decode streams and continuous batches; TPU/MXU and VPU execute the corresponding per-token operations.
8. Optional speculative candidates are verified by the target model before acceptance.
9. Host receives output tokens and telemetry. All pages, queues and cache references are released safely on completion, cancellation or error.

The scheduler should dispatch operations by measured shape, precision, data locality, queue depth and engine availability. Avoid copying tensors between engines when shared-memory ownership and supported ports allow safe direct access.

## 4. Petabyte-scale data and context strategy

Petabyte scale belongs at the **system/cluster data layer**, not on-die memory:
- Store cold corpora and archives across distributed storage nodes.
- Maintain searchable indexes and application-controlled retrieval pipelines.
- Stream selected data into accelerator memory in bounded chunks.
- Keep only active model weights, hot context and active KV blocks in fast memory.
- Use distributed request routing and sharded storage/compute where workload and networking justify it.
- Separate retrieval corpus size from a model's true attention context window. Retrieving relevant passages does not mean the model has attended to every byte/token in the full corpus.
- Measure ingestion throughput, index build/update time, retrieval recall/precision, bytes transferred, network saturation, cache hit rate, time-to-first-token, end-to-end latency and cost per useful answer.

A petabyte-scale corpus may be addressable by the service while each individual inference request uses a bounded context window. Extending true context length requires model architecture/training support, positional encoding compatibility, memory capacity/bandwidth and validated attention algorithms; it cannot be obtained merely by attaching more storage.

## 5. Performance goals and evidence

Measure separately:
- Matrix engine: sustained useful operations/s, tile utilisation, bandwidth efficiency and numerical accuracy.
- NPU/VPU: supported operator throughput, occupancy, stalls and correctness.
- LPU: prefill tokens/s, time-to-first-token, decode tokens/s, inter-token latency p50/p95/p99, concurrency and context handling.
- Memory: active capacity, effective bandwidth, latency, KV bytes/token, DMA bytes/token, bank conflicts, cache hit rate and allocator fragmentation.
- System: end-to-end useful tokens/s, requests/s, tail latency, model quality, energy per useful token, total system power and cost per useful request.
- Scale-out: data ingest, storage/network throughput, retrieval quality, multi-node efficiency and failure recovery.

Every comparison must use the same model/checkpoint, tokenizer, prompt, output policy, precision and measurement boundary. Report workload and system configuration. No performance, petabyte capability, power or commercial advantage may be claimed before reproducible measurement.

## 6. Design constraints and safety

- Preserve exact/dense attention and reference execution paths.
- Approximation, compression, sparsity and speculative decoding require explicit policy and measured quality/error bounds.
- Ensure per-tenant memory isolation, cache-key correctness, ECC/error reporting, bounded allocation, cancellation cleanup and deterministic simulator behaviour.
- Prevent long prefill requests from starving decode streams; use admission control and fair scheduling.
- Do not add new silicon blocks until profiling proves a bottleneck cannot be addressed by current MXU/VPU/TMEM/DMA/scheduler resources.
- No blanket assumption that quantum-inspired algorithms improve inference; require reproducible superiority over classical baselines.
- No paid cloud/QPU, PDK/IP, PPA, fabrication or hardware activity is authorised by this document.

## 7. Staged implementation

**Stage 0 — architecture and source inventory:** map actual RTL, interfaces, parameters, memory ports, queues, compiler/runtime and tests to the three logical engine roles. Resolve terminology: existing MXU/VPU are concrete; the LPU and unified NPU are logical roles pending integration.

**Stage 1 — software/simulator model:** build deterministic heterogeneous scheduler and workload traces for prefill, attention, decode, KV allocation, memory contention, concurrency and cancellation. Compare unified scheduling with the existing execution path.

**Stage 2 — model profiling:** run representative supported models and long-context prompt suites; capture per-stage traces and exact baseline metrics. Identify whether bottlenecks are matrix compute, vector/reduction, memory bandwidth, KV capacity, scheduling or host/network.

**Stage 3 — focused implementation:** prioritise software/compiler/runtime changes and reuse existing hardware. Propose a new interface or RTL block only with measured need, capacity/area/timing estimate, error contract, formal properties and focused tests.

**Stage 4 — scale-out evaluation:** model or test distributed storage, network, retrieval and multiple accelerator nodes. Establish petabyte corpus handling as a system capability with explicit end-to-end metrics, not an on-chip memory claim.

**Stage 5 — physical qualification:** only after design/verification closure, selected technology and platform IP, PDK availability, resource approval and explicit user authorisation.

## 8. Current implementation status

This document is a design proposal. It does not establish that a unified NPU/LPU/TPU scheduler, new LPU hardware, petabyte memory, distributed fabric, or associated performance has been implemented. Existing MXU, VPU/stream, sequencer, TMEM, DMA and host infrastructure are the starting point. The immediate next engineering task is source/interface inventory and deterministic workload profiling, not speculative RTL expansion.
