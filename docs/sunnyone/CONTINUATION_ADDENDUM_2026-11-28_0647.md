# SUNNYONE continuation addendum — 2026-11-28 06:47 Asia/Dhaka

This addendum supersedes the waits-job pending status in earlier checkpoint/tracker sections and records the governing commercial objective.

## Repository controls and live state at start
- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Live branch HEAD at start: `54848e8fc43ad88abe09379ccf1e7298d9910d64`.
- Main SHA: `d84db55712aba0d40811d7762cb052f05d55b7e5`; unchanged and untouched.
- GitHub reports `main.protected=false`; continue treating main as strictly off-limits.
- Zero-spend, no duplicate successful tests, no weakening of verification and no PPA retry remain mandatory. Cancelled run `45765362426` must not be restarted. Historical RTL groups 3.1/3.2/4 must not be repeated solely to reconfirm.

## Software-core recovery — now fully complete
Workflow `46053311585`, attempt 3, tested source `05879ea34eafc2559c54722c6c940b2acb9ac3ee`, terminal conclusion **SUCCESS**.
- The previously outstanding waits-only job `140775908058` is terminal SUCCESS.
- Actual pytest log: `tests/test_waits.py` **268 passed, 2 skipped in 1953.87s**.
- Artifact `15237666850`; ZIP SHA-256 `47048b1aecc1fff9f40500e11190ef4cc24a9945bd6c2c71b2551c46ca2ac554`.
- All 15 software-core jobs in the run are terminal SUCCESS. The other 14 jobs were not rerun by this recovery; the isolated recovery was only the waits job.
- The full run validates its exact ancestor source and configured test scopes, not later branch HEAD `54848e8fc43ad88abe09379ccf1e7298d9910d64` or subsequent commits. Preserve source-SHA qualification.

## Governing commercial objective saved
Created `docs/sunnyone/SUNNYONE_AI-X_PROFITABILITY_NORTH_STAR_2026-11-28.md` in commit `40b6f8078d2d7a424a255f1d7db716cab373b657`.

The governing objective is maximum commercial profitability through quality-qualified useful LLM tokens/s, tokens/J and tokens per total cost, while minimising energy/token, idle power, heat, manufacturing/operating cost, latency tails, failures, downtime and maintenance complexity. No unmeasured performance/power/thermal/cost claims.

Architecture direction: unified TPU/MXU matrix engine; LPU-like scheduler/KV/context/data-movement role first in existing software/runtime; NPU/VPU vector datapath; shared memory/interconnect; programmable compiler/runtime/ISA; measured power/thermal controls. Quantum-inspired classical methods are optional research only, not physical quantum hardware. No dedicated LPU silicon without measured net benefit. Track A full programmable product and Track B demonstrator remain separate. Existing one-slice ASIC top, Versal feasibility lead, 128 GB ECC DDR4 hypothesis, 256 GB stretch-only and retired 30 W hard ceiling remain unchanged.

## Next engineering sequence
1. Build exact-source correlation between RTL `hwtrace.py` D/S/G/E records and `tmem_trace.py` activity; do not invent per-request stage attribution from aggregate counters.
2. Formalise existing runtime admission semantics: FIFO new-request admission up to `max_running`, new prefill before round-robin running turns, cancellation handling, idle-save pre-emption and context save/restore. Distinguish request round-robin from tenant fairness; no tenant-fairness guarantee is currently implemented in the inspected worker.
3. Define and validate W1 single-request, W2 mixed concurrency and W3 burst/contention/cancellation/fault workloads. W4 remains conditional on supported context/KV capacity semantics.
4. Calibrate profiles only from matching source/configuration traces; keep unknown service times, bandwidth, power and energy unset.
5. Continue MXU `mx_key` bounds proof, remaining width warning semantic review, formal/SVA, CDC/RDC, DFT, SRAM/DDR technology mapping, production PCIe/SerDes/DMA/IOMMU and memory interfaces, routed physical signoff, and Track B sponsorship/feasibility gates.
6. Benchmark/tune the existing scheduler quantum/chunking and cache/context lifecycle before considering dedicated LPU silicon.

No RTL, ISA, workflow or PPA source was changed in this continuation. No new tests were launched; existing waits evidence was polled and inspected. No PPA retry, paid compute, fabrication or hardware spend. Manufacturer handoff remains **NOT READY**.


## Authoritative strategy source hierarchy

The governing user-approved source is `docs/sunnyone/SUNNYONE_X_ULTIMATE_COMMERCIAL_NORTH_STAR_2026-11-28.md`. It takes precedence over the concise supporting summary `SUNNYONE_AI-X_PROFITABILITY_NORTH_STAR_2026-11-28.md` created during this continuation. The authoritative source fixes the commercial objective while keeping implementation choices evidence-led; retain its full-system economics, quality, reliability, idle-power, thermal, scale-out and evidence requirements. The existing V1 logical design candidate and commercial profitability measurement model remain complementary, with implementation status and external interfaces qualified exactly as documented.
