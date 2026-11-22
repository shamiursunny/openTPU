# A1.12.11.16.36 — Reproducible Workload Benchmark Protocol

Status: protocol and harness definition; no accelerator performance result is claimed.
Date: 2026-11-23
Pinned software reference: FeSens/openTPU commit d84db55712aba0d40811d7762cb052f05d55b7e5

## Objective
Measure whether a candidate serving system delivers customer-accepted useful work at lower risk-adjusted total cost than comparable rented GPU systems. Do not select an FPGA/SoC from TOPS, memory capacity, or peak throughput alone.

## Initial workloads (hypotheses, not validated demand)
- W1: small/medium instruction model serving.
- W2: retrieval pipeline: embedding + reranking; report each stage separately.
- W3: batch document/text processing.
W4 long-context/large-model serving and W5 code/reasoning remain secondary until interviews establish demand.

## Freeze each run
Record workload ID; timestamp; host/provider/region; full CPU/GPU/FPGA/SoC model and count; accelerator memory; system RAM type/capacity/channels; storage; network; driver/runtime/compiler versions; serving engine/version; model repository and immutable revision; model licence URL/revision; tokenizer revision; chat-template hash; quantisation format/calibration; context length; input/output token distribution; prompt dataset hash; request-arrival schedule; concurrency; batch policy; sampling parameters; warm-up and measured request counts; random seed; power meter and measurement boundary; tariff; ambient/inlet temperature; cooling boundary; software commit.

Never compare different model revisions, tokenizers, prompts, quantisation, output limits, or service boundaries as if equivalent.

## Required measurements
- Quality: blinded human or independently validated task rubric; accepted/rejected output count; task completion and factuality/error categories.
- Latency: TTFT and inter-token latency p50/p95/p99; end-to-end request latency p50/p95/p99.
- Throughput: input tokens/s, generated tokens/s, accepted useful output tokens/s, completed tasks/hour.
- Efficiency: wall joules per accepted useful token and per accepted task, measured at complete system boundary.
- Stability: thermal state, throttling, errors, OOM, retries, crashes, uptime and run duration.
- Memory: peak allocated/committed memory, KV cache, bandwidth counters if available, memory stalls, paging/swapping.
- Economics: actual checkout invoice or quote, included resources, taxes, idle/billed time, storage/network/egress, support and electricity.

Do not infer wall power from chip TDP. Without a calibrated wall meter, mark power and energy efficiency NOT MEASURED.

## Run design
1. Verify model licence and immutable model/tokenizer revisions before download.
2. Run smoke test, then warm up until the stated steady-state rule is met.
3. Execute at least 3 independent measured repetitions per configuration; randomise configuration order where practical.
4. Use the same prompt set and request-arrival trace for each comparison.
5. Use fixed-concurrency and fixed-arrival-rate tests. Do not hide queueing or saturation.
6. Capture raw per-request records. Report percentiles and confidence intervals; never report only the best run.
7. Run long enough to expose thermal/power throttling and memory pressure; state exact duration.
8. Independently score output quality. Throughput is not useful if acceptance quality falls below the agreed threshold.

## Model selection
Choose only after checking official model card, licence, immutable model/tokenizer revisions, supported serving runtime, context, architecture and quantisation compatibility. Record commercial-use rights separately from research-only rights. No model or licence is pre-approved here.

## Architecture gates
- Calculate weights + runtime + KV cache + scratch/workspace + safety margin for each model and concurrency target.
- Derive bandwidth demand from measured traces; capacity alone is not a bandwidth proof.
- Compare Versal integrated DDR via NoC first, consistent with AMD UG1273 guidance; compare PG353 soft DDR only when exact device/package pinout, bank availability, IP, resources and board routing are proven.
- AMD PG313 supports specific DIMM configurations, but a 128 GB or 256 GB populated configuration must be demonstrated for an exact part/package and DIMM part number. Controller-family support is not a board-level capacity guarantee.
- 128 GB remains a feasibility target; 256 GB remains stretch-only. Select the minimum economically sufficient memory.
- No exact Versal device/package is selected by this protocol.

## Decision rule
A candidate advances only if (a) quality and reliability meet workload SLA, (b) measured useful throughput and latency are competitive, (c) measured total cost per accepted useful task/token is lower or creates defensible customer value, and (d) conservative cash flow supports investment and payback. Record failed gates and uncertainty. No production capex from simulated-only evidence.

## Evidence status
At creation: no customer workload validated; no rented-GPU benchmark attached; no calibrated wall-power measurement; no Versal device/package or DIMM configuration has passed board-level feasibility.
