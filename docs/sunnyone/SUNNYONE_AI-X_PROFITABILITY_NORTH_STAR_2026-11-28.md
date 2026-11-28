# SUNNYONE AI-X — Commercial Profitability North Star
Date: 2026-11-28 (Asia/Dhaka)
Status: governing product objective and architecture decision framework

## 1. Ultimate product objective

Build the most commercially profitable practical AI inference accelerator that can be supported by evidence, not the largest or most complicated chip. Optimise the complete deployed system for useful, quality-qualified LLM tokens delivered per unit of electricity and total cost, while preserving predictable latency, stability, reliability and maintainability.

The governing optimisation objectives are:
- maximise useful, quality-qualified tokens per second at the system and workload level;
- maximise useful tokens per joule and per total-cost unit;
- minimise energy per useful token, idle power, avoidable memory movement, operating cost, thermal burden, manufacturing cost, failure rate, downtime and maintenance complexity;
- maintain low and predictable TTFT, inter-token latency and tail latency under realistic mixed workloads;
- preserve reproducibility, testability, software programmability and a credible manufacturer path.

Profitability is a measured system outcome, not a claimed chip specification. Throughput, power, thermal, yield, manufacturing cost and reliability remain unknown until measured or supported by validated models and supplier evidence.

## 2. Architecture direction

The intended functional combination is:
- **Unified TPU/MXU matrix engine:** high-utilisation matrix/tensor work for prompt processing and model operations.
- **Classical LPU-like scheduling and data-movement role:** request admission, prefill/decode coordination, token scheduling, KV-cache/context lifecycle and memory movement. First implement and tune this in the existing software/runtime scheduler and shared resources. A dedicated LPU silicon block is not justified unless measured bottlenecks prove a net benefit after software/runtime optimisation.
- **NPU/VPU vector datapath:** vector operations, normalisation, reductions, elementwise operations and supported mixed workloads.
- **Shared memory and interconnect fabric:** minimise copies and contention; make capacity, bank conflicts, arbitration, bandwidth and backpressure explicit and measurable.
- **Programmable runtime/compiler/ISA:** preserve workload flexibility, efficient kernels, profiling and model portability.
- **Power/thermal-aware control:** use clock/power gating and operating-point controls only where the target technology and measurements support them; avoid adding complexity without net economic benefit.

“Quantum-inspired” is a possible classical algorithm/research technique for selected scheduling or optimisation problems only. It does not imply physical quantum hardware and is not a required silicon block.

## 3. Design decision rule

No new hardware block, memory tier, interconnect, speculative optimisation or expensive IP is accepted solely because it sounds faster. Require:
1. a source-backed workload or bottleneck;
2. a baseline from a reproducible workload and exact source/configuration;
3. an explicit alternative and its implementation/verification cost;
4. a measured or transparently modelled gain in useful throughput, latency, energy or cost;
5. assessment of area, power, heat, yield, complexity, reliability, software and schedule risks;
6. independent verification and rollback criteria.

Prefer improving existing MXU/VPU/DMA/TMEM, memory reuse, scheduling, compiler/runtime and profiling before expanding the hardware footprint. Keep uncertain quantities unknown; never fill gaps with invented service times, bandwidth, energy coefficients, die area, yield or cost.

## 4. Commercial metrics and evidence hierarchy

Report per workload and at aggregate level:
- useful output tokens/s and prompt tokens/s, with quality gate and model/checkpoint/tokenizer/template identity;
- TTFT, inter-token latency and p50/p95/p99 completion latency;
- queue wait, admission/rejection, prefill/decode service, context switch/save/restore, KV hit/reuse/pressure, memory traffic, stalls and resource utilisation;
- measured wall/system energy and idle power, enabling joules per useful token and tokens per joule;
- total cost per useful million tokens, including amortised silicon/system, memory, board, cooling, electricity, maintenance and utilisation assumptions;
- availability, error/retry rate, thermal throttling and service downtime.

Evidence labels must distinguish source inspection, unit-test fixture, software simulation, RTL simulation, FPGA/board measurement, calibrated system measurement, synthesis estimate, routed physical estimate, supplier quotation and physical-silicon measurement. Results must carry exact source SHA, toolchain, configuration, workload hash, profile provenance and limitations.

Do not claim tokens/joule, thermal behaviour or cost-effectiveness until calibrated power/thermal and cost inputs exist. Do not equate synthetic model output with RTL-calibrated performance or physical silicon.

## 5. Product tracks and non-negotiable separation

- **Track A — full programmable accelerator:** the complete product direction remains intact. Do not silently shrink or replace it to fit an early shuttle or demonstrator.
- **Track B — first-silicon demonstrator:** a separate, smaller proof vehicle derived only from proven existing RTL after source, PDK, area, timing, testability, packaging and fully funded sponsorship feasibility review. Its success cannot be represented as validation of the full Track A product.

Current ASIC top evidence is one compute slice. Do not describe multi-slice production integration as implemented. The Versal VC1802/VSVD1760 remains a separate feasibility lead, not a selected production part or the IHP ASIC target. 128 GB ECC DDR4 is a hypothesis; 256 GB is stretch-only. The former 30 W hard ceiling is retired; power must be derived from measured throughput and economics.

## 6. Cost, power and reliability principles

- Zero-spend engineering is the default. No paid compute, PDK/IP licence, foundry, hardware, packaging, lab testing or shipping expenditure without explicit user approval.
- Seek a genuinely fully sponsored research route; free fabrication is not confirmed. Written terms must cover fabrication, dicing, packaging, board/fixture, test, report/data, sample custody/access, delivery to Bangladesh, shipping, customs, taxes and every other fee.
- Prefer mature, open, inspectable and testable IP where technically suitable. Check licence, process compatibility, support and integration costs before adoption.
- Minimise data movement and idle resources; measure memory bottlenecks before adding capacity or engines.
- Reliability, deterministic behaviour, error handling, observability and maintainability are first-class product economics.
- Do not weaken verification, suppress warnings wholesale, repeat successful tests without cause, or make physical claims from simulation.

## 7. Immediate execution order

1. Preserve and reconcile the exact completed test evidence; finish only outstanding scoped jobs.
2. Build exact-source RTL/TMEM trace correlation and explicit runtime admission/fairness semantics.
3. Establish reproducible W1 single-request, W2 mixed-concurrency and W3 burst/contention/cancellation/fault workloads; enable W4 only after context/KV capacity semantics are represented.
4. Calibrate resource profiles from matching RTL traces, retaining uncertainty and residuals. Do not infer per-request service from aggregate counters without attribution.
5. Optimise scheduler quantum/chunking, prefill/decode balance, context reuse, KV store and data movement using controlled comparisons.
6. Continue MXU index-bound proofs, width-warning semantic review, formal/SVA, CDC/RDC, DFT, SRAM/DDR mapping, production PCIe/SerDes/DMA/IOMMU/memory interfaces and routed physical signoff.
7. Down-select Track B only after feasibility and full sponsorship gates; preserve Track A.
8. Approach manufacturers/research partners only with source/IP terms understood and evidence-qualified claims.

## 8. Release status

Manufacturer handoff remains **NOT READY**. The repository's software and RTL simulation evidence is valuable but does not establish complete formal/CDC/RDC/DFT closure, production host/memory interfaces, routed physical signoff, calibrated system power/thermal performance, manufacturing yield/cost or a fully funded physical sample/testing/shipping route.
