# SUNNYONE continuation addendum — 2026-11-28 06:54 Asia/Dhaka

This addendum records the current continuation work. It does not close hardware or manufacturer gates.

## Repository controls
- Repository: `shamiursunny/openTPU`.
- Working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Main baseline: `d84db55712aba0d40811d7762cb052f05d55b7e5`; no main writes, merges or rebases.
- Latest live compare before this continuation's commits: 1,157 commits ahead, 0 behind main. The GitHub compare endpoint did not expose the feature HEAD SHA; re-resolve before any ref-level write.
- Zero spend; no PPA retry; preserve successful evidence; do not rerun RTL groups 3.1/3.2/4 or cancelled run 45765362426.

## Reconciled evidence
- Software-core workflow `46053311585`, attempt 3, terminal SUCCESS on tested source `05879ea34eafc2559c54722c6c940b2acb9ac3ee`; all 15 jobs successful. Waits job `140775908058`: 268 passed, 2 skipped. Artifact `15237666850`, SHA-256 `47048b1aecc1fff9f40500e11190ef4cc24a9945bd6c2c71b2551c46ca2ac554`.
- Deterministic workload/resource harness `46081103514`, job `140780031472`: 34 tests passed in 0.517s on exact tested source `0ab52a61659a4746eb3375d7e5f146f3fbf192ae`.
- Structural SCC/latch audit `45914912691`: zero SCCs and zero inferred latch cells in the three named audited elaborations only.
- Full-chip lint `46053311384`: completed with 59 width warnings (52 expansion, 7 truncation). Remaining semantic closure is open.
- Focused VPU index regression `46053471843` was the required pending gate in the last saved state; poll its exact live status before any related rerun. Do not infer pass from lint success.
- PPA remains failed/no routed report; retry unauthorised. Manufacturer handoff NOT READY.

## Work completed in this continuation
- Added deterministic synthetic workload fixture `workloads/sunnyone/W1_single_request.json` (one request, one arrival).
- Added `workloads/sunnyone/W2_mixed_concurrency.json` (four staggered requests across three synthetic tenants).
- Added `workloads/sunnyone/W3_burst_cancel_fault.json` (ten-request burst with one cancellation, one injected fault and one deadline).
- Added `tests/test_sunnyone_workload_scenarios.py` with three tests for schema validation, expected scenario shape, stable event ordering and deterministic replay.
- Commits: W1 `d82c337d130746c298d7bc4e9e9592b35beed555`; W2 `0fbef0f5bc4eb5da6bf10a75dab74679d46ba14e`; W3 `3eb81325e07c0e41a66edc69f5ee6a1bfee8f663`; scenario tests `28704f25f87179e5653188bf0cc40f43ee681168`.
- The existing isolated workload harness has a path filter for `tests/test_sunnyone_*.py`, so the test-file commit is intended to trigger that narrow suite. A new workflow run ID and terminal result have not yet been independently retrieved. Therefore the three fixture tests are committed but NOT YET VERIFIED by CI. Do not count them as passed.

## Trace-correlation finding
- Source revisions reviewed: `opentpu/hwtrace.py` blob `5e23c82954ac4c55d6c2c716658681febce61988`; `tools/tmem_trace.py` blob `c08c625130e66a63ec7626fe3083a31e8ec496d8`; `opentpu/profile.py` and source-interface specification as recorded in the repository.
- Hardware trace D/S/G/E events carry dispatch slot and unit-ready information. TMEM trace records carry cycle, port/unit and addresses; its instruction start/done records are per unit and ordered.
- There is no common request ID or dispatch slot in each TMEM access record. Temporal overlap can support unit/window aggregate correlation, but not reliable per-request TMEM attribution where operations overlap or unit ordering is ambiguous.
- Do not join by timestamp alone and claim request-level bytes/latency. First build a loss-aware interval/segment audit that reports exact matching run, slice, cycle range, instruction windows, port counters, unmatched events and ambiguity. Per-request attribution requires instrumentation carrying a stable slot/sequence tag through TMEM events or a controlled single-in-flight experiment with explicit limitations.
- The current resource-event model remains an abstract queueing model. No calibrated service profile, accelerator throughput, joules/token, power or thermal data exists.

## Next execution order
1. Poll VPU focused run `46053471843`; inspect actual job log and source SHA. No broad rerun.
2. Retrieve/inspect the new workload-harness run caused by test commit `28704f25...`; only mark W1/W2/W3 fixture tests verified after terminal success and exact log inspection.
3. Implement source-faithful RTL/TMEM trace correlation at unit/interval level with explicit ambiguity and loss detection; do not invent request mapping.
4. Run W1/W2/W3 only when matched RTL test programs and trace capture are defined; preserve workload replay hashes and exact source/configuration.
5. Continue MXU `mx_key` bounds, remaining width warnings, formal/SVA, CDC/RDC, DFT, SRAM/DDR mapping, production interfaces and physical signoff.
6. Continue Track B feasibility and sponsorship enquiries only within zero-spend controls; keep Track A full product separate.

## Release decision
Manufacturer handoff remains **NOT READY**. No physical sample, production qualification, routed signoff, full external PCIe/SerDes/DDR PHY integration, funded sponsor, packaging/test/shipping agreement or independent silicon validation is confirmed.
