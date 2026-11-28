# SUNNYONE continuation addendum — 2026-11-28 trace correlation closeout

## Repository controls and live state
- Repository: `shamiursunny/openTPU`.
- Working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Branch HEAD before this documentation commit: `3cc1ec1d0aaee797022cc355e68e8451a13c4e6b`.
- Main HEAD: `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare: **1,184 ahead, 0 behind**.
- GitHub reports `main.protected=false`. Main remains strictly off-limits; do not merge, rebase or write to it.
- Zero spend. No PPA, paid compute, fabrication, hardware purchase, packaging, lab testing or shipping commitment without explicit approval.
- Preserve successful RTL groups 3.1, 3.2 and 4; do not rerun them solely for reassurance. Do not restart cancelled run `45765362426`.

## W1/W2/W3 fixture verification
- Run `46090474983`, job `140809944012`, exact tested commit `28704f25f87179e5653188bf0cc40f43ee681168`: SUCCESS, **37 tests passed in 0.557s**.
- The log explicitly includes W1 single-request, W2 staggered multi-tenant concurrency and W3 burst/cancel/fault/deadline fixture tests.
- These validate synthetic fixture structure and deterministic ordering only. They do not establish scheduler fairness, accelerator throughput, power, energy, thermal behaviour or per-request silicon performance.

## Trace-correlation adapter — implemented and CI-verified
- Added `tools/sunnyone/trace_correlation.py`, `tests/test_sunnyone_trace_correlation.py`, `tests/test_sunnyone_trace_correlation_rtl.py` and `docs/sunnyone/TRACE_CORRELATION_ADAPTER_SPEC_2026-11-28.md`.
- Updated `sunnyone-workload-harness.yml` to install Verilator/project dependencies, compile the adapter and run the focused tests. This is the narrow software/workload harness; no broad RTL matrix, Qwen model workflow or PPA workflow was launched by these Python/docs changes.
- Fixed retrieval benchmark test isolation: optional NumPy/sentence-transformers stubs are now restored after import, preventing a fake `numpy` module from leaking into the real RTL co-simulation test.
- Final run `46132183828`, job `140939555937`, exact tested commit `3cc1ec1d0aaee797022cc355e68e8451a13c4e6b`: **SUCCESS, 47 tests passed in 52.079s**.
- The run includes a real Verilator RTL co-simulation: a 256-word DMA `LD` program executed with both `+trace` and `+tmtrace`. The adapter matched the DMA instruction by unit/opcode sequence and assigned DMA TMEM write traffic to its unique instruction interval. It also verified provenance hashes and retained `profile_eligible=false`.
- Diagnostic run `46131630338` on the same RTL and test program exposed the distinct cycle origins: hardware trace D/S/E at cycles 5/6/53; TMEM start/done at 11/57; 32 DMA write records and 256 words. Observed offsets were +5 at start and +4 at completion, with a one-cycle duration delta. That diagnostic run failed only because the first adapter version incorrectly demanded identical cycle numbers.
- Root cause: the hardware trace uses the resettable sequencer/slice cycle counter; TMEM trace uses `tt_cyc` in `otpu_slice.sv`, which increments during reset. The adapter now matches ordered per-unit opcode sequences only when counts and opcode sequences agree and no same-cycle start-order ambiguity exists. It reports start/completion offsets and duration deltas rather than silently normalizing them.
- Accesses are attributed only when exactly one closed TMEM interval for that unit contains the access strictly between start and completion. Boundary, overlapping and incomplete intervals remain unassigned/ambiguous. Per-port, per-unit and arbitration-loss counters are reported.
- Explicit limit: TMEM records do not carry a workload request ID or hardware slot. No W1/W2/W3 request-level attribution is claimed. The adapter does not infer calibrated service times, capacities, silicon throughput, power or energy.
- The earlier intermediate failures were resolved: synthetic test records were sorted by cycle; fake optional-dependency modules were isolated; cycle-domain alignment was corrected; and the final assertion import was fixed. Do not repeat the intermediate failing runs.

## MXU malformed-command guard — next RTL blocker
- Re-read current `rtl/seq/otpu_seq.sv`, `rtl/top/otpu_slice.sv`, `rtl/mxu/otpu_mxu.sv`, `opentpu/isa.py`, `opentpu/isasim.py` and `docs/isa.md`.
- The sequencer's synthesizable pre-dispatch rejection pattern is `fsum_bad`. The sequencer currently lacks `MCOLS` and `ACT_ROWS`; the slice knows the elaborated values and passes them to MXU. MXU MM legality checks remain simulation-only under `ifndef SYNTHESIS`.
- Required guard: propagate `MCOLS` and `ACT_ROWS` into sequencer; reject zero N/KB/M, out-of-range M, mode-specific M bounds, illegal PAIR shape/weight format/grouping/k0 parity, ASCALE without UNIT+ACC, RSC with NVFP4, and invalid WG/LG grouping before dispatch. Keep legal grouped MM cases intact.
- Required negative RTL tests: raw malformed MM words must raise the documented error before MXU start and cause no TMEM write or DRAM stream side effect. Positive boundary tests must preserve legal ISA workloads.
- Do not patch RTL until the workflow blast radius is understood. Current RTL source paths trigger several broad functional, subsystem, tail, lint, ASIC-config, reset, board and Qwen workflows. The focused MM change must not accidentally rerun successful groups 3.1/3.2/4 in parallel. Plan one controlled, serial verification gate and confirm no PPA marker is present before pushing the RTL patch.
- General RTL changes do not automatically trigger the dedicated WG8 PPA workflow; that workflow uses its own explicit marker. Do not invoke it.

## Release status
Manufacturer handoff remains **NOT READY**. Formal/SVA, CDC/RDC, DFT, full semantic width-warning closure, SRAM/DDR mapping, production PCIe/SerDes/DMA/IOMMU and memory interfaces, routed physical signoff, measured power/thermal/economic evidence, demonstrator down-select and zero-cost sponsor/sample/packaging/test/shipping commitments remain open or partial in the readiness matrix.
