# SUNNYONE AI-X — A1.12.11.16.37–.38 Progress and Evidence Ledger

Date: 2026-11-23
Branch: sunnyone/commercial-profitability-architecture-2026-11-23
Current branch head at report creation: 87fdc8df265af6dea61dbe0e14671fa91f869c42
Pinned upstream reference unchanged: FeSens/openTPU d84db55712aba0d40811d7762cb052f05d55b7e5

## Completed in this continuation
- Added streaming OpenAI-compatible chat benchmark harness with request latency, TTFT, inter-chunk timing, token usage when returned, raw JSONL and metadata.
- Added local SSE and non-streaming HTTP fixture tests.
- Added Qwen3 embedding/reranker retrieval benchmark with Recall@k, MRR@k and nDCG@k.
- Added labelled retrieval smoke dataset (four queries only; not representative).
- Added exact model revision/licence register for three Apache-2.0 Qwen checkpoints.
- Added model-to-accelerator workload mapping and execution runbook.
- Added AMD PG313/DS957 constraints: integrated DDR dual-slot/rank speed penalties, x8/x16 interface constraints, and the need to verify exact DIMM/device/package.
- Corrected earlier retrieval test fixture after CI exposed a wrong expected nDCG result.

## CI evidence
- Harness-only CI run 45069446616: SUCCESS (endpoint harness syntax + local HTTP stream/non-stream tests; before retrieval metrics were added).
- Combined harness/retrieval CI run 45069537101: SUCCESS, Python 3.12; compiled both scripts and passed all 6 deterministic tests (3 chat harness tests + 3 retrieval metric tests). The run tested commit 749677442edc7e1d560e56b2a3695bd102f5b008; subsequent commit 87fdc8df265af6dea61dbe0e14671fa91f869c42 only changed workflow display name.
- Earlier emulator/Python CI run 45065688493: still reported in_progress with last update 2026-11-22T20:18:33Z; no artifacts; log download returns BlobNotFound. Treat as stale/unresolved, not a pass.

## Model candidate register
- Qwen3.5-4B: `851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a`, Apache-2.0 metadata, W1/W3 evaluation candidate.
- Qwen3-Embedding-0.6B: `97b0c614be4d77ee51c0cef4e5f07c00f9eb65b3`, Apache-2.0 metadata, W2 embedding candidate.
- Qwen3-Reranker-0.6B: `e61197ed45024b0ed8a2d74b80b4d909f1255473`, Apache-2.0 metadata, W2 reranking candidate.
- Exact licence files still need archival/hash and legal review before distribution or commercial deployment.

## Not completed / not evidenced
- No cloud GPU or physical accelerator benchmark.
- No independently measured model quality, useful throughput, TTFT distribution on a real serving endpoint, wall power, tokens/J or sustained thermals.
- No customer dataset or representative workload validation.
- No verified Versal part/package or exact 128 GB DIMM BOM.
- No RTL synthesis, timing closure, place-and-route, PCB, physical board or silicon qualification.
- No actual costs, customer contracts, break-even, profit or payback calculation.

## Current design decision
Programmable accelerator architecture direction remains selected provisionally: RISC-V control plane, tiled matrix engine, vector/SIMD, local SRAM, DMA, defined interconnect, ECC external memory and programmable runtime. Exact chip/FPGA/SoC part and production ASIC are NOT SELECTED. No production readiness claim.

## A1.12.11.16.39 — Versal device/memory down-select
- Lead feasibility candidate: AMD Versal AI Core VC1802 / VSVD1760.
- Higher-compute alternative: VC1902 / VSVD1760.
- Rationale: AMD lists four integrated DDRMCs on VC1802/VC1902. A plausible 128 GB target is four independent ECC 64-bit DDR4 channels, one 32 GB 2-rank x8 RDIMM per controller.
- Reference DIMM SKUs from Lenovo's published memory reference: 4ZC7A15123 and 4X77A12188, both listed as 32 GB 2Rx8 DDR4 RDIMM-A. These are candidate references only, not validated Versal-compatible modules.
- AMD DS957 lists up to 2933 Mb/s for a 2-rank, single-slot RDIMM topology under Versal AI Core conditions. Four-channel theoretical payload ceiling = 93.856 GB/s decimal, before overhead; not measured.
- Exact VC1802 VSVD1760 pinout, all four DDRMC availability, Vivado memory planner, SPD/training, PCB, price, power and thermal gates remain open.
- Detailed down-select: VERSAL_DEVICE_AND_128GB_MEMORY_TOPOLOGY_DOWNSELECT_A1.12.11.16.39.md.

## Current branch and CI
- The deterministic benchmark CI run 45069537101 passed all six unit tests and Python compilation for both benchmark scripts.
- The older BCU1525 emulator/Python run 45065688493 remains stale/in_progress with no artifacts and unavailable logs.
- Current branch has since advanced beyond the CI-tested commit through documentation-only device/memory decisions; the benchmark scripts and tests were unchanged after that successful run.
