# SUNNYONE continuation review — 2026-11-27 01:45 Asia/Dhaka

This is a docs-only continuation update. It supersedes the ORFS_CPU-propagation diagnosis in the 01:37 addendum after direct inspection of the current branch source. No RTL, test, workflow or PPA source was modified. No tests or CI runs were launched by this review.

## Live state recheck

Repository: `shamiursunny/openTPU`
Branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Main SHA / compare base: `d84db55712aba0d40811d7762cb052f05d55b7e5`
Feature branch compare: 888 commits ahead, 0 behind main. The compare endpoint did not return a current head SHA; do not infer one from an older checkpoint. Re-resolve before future code writes.

Latest workflow jobs poll:
- 45877786710 WG8 PPA: IN_PROGRESS.
- 45877786754 Qwen: IN_PROGRESS; real-checkpoint RTL step SUCCESS; eight tiny board-model cases still running.
- 45877786742 board-functional: IN_PROGRESS.
- 45877786699 subsystem/memory: 11 jobs completed SUCCESS; address-window and native DRAM/technology RAM IN_PROGRESS; reset audit QUEUED.
- 45877786705 software/ISA: 10 jobs completed SUCCESS; waits IN_PROGRESS; host-runs, host-lock, WAITW and host QUEUED.
- 45877786738 reset audit: SUCCESS.
- 45877786860 ASIC config: SUCCESS.
- 45877807906 RTL tail: SUCCESS.
- 45877807985 isolated 128K one-copy TMEM: SUCCESS.
- 45877985241 LOOP stack guard: SUCCESS (2 passed, 217 deselected).

The active PPA job is GitHub job ID 140109157212. Its steps through pinning the ORFS image and capturing the host resource baseline succeeded; the pinned-container SRAM probe and WG8 ORFS flow is still in progress. Logs were not yet downloadable (GitHub returned BlobNotFound for the active job log endpoint). Do not launch another PPA attempt.

## Important correction: ORFS_CPUS propagation

Earlier note in `INPUT_BOUNDS_AND_PPA_RESOURCE_CONTROL_REVIEW_2026-11-27.md` and the 01:37 addendum claimed the active flow ignored `ORFS_CPUS`. Direct inspection of the current branch source disproves that claim for the actual workflow invocation:
- `tools/asic/flow.py` current blob: `4154f6474e0cc03d8ee0e9398ca783e26a96acf4`.
- `main()` reads `ORFS_CPUS` and passes the parsed value to `run(point, cpus, ...)` (around lines 452–460).
- The PPA workflow current blob: `426cfcc62ac4ca1d90cf52b06a0e9009b83a1c29`; it exports `ORFS_CPUS=2` and invokes `python3 tools/asic/flow.py run nangate45-wg8`.
- `run()` then uses the explicit `cpus` argument to set ORFS `NUM_CORES` and Docker `--cpus` (around lines 336–351).
Therefore the actual PPA CLI path propagates 2. The earlier claim that the workflow invocation ignored the variable was inaccurate. The direct unit-test path calling `flow.run()` without an explicit argument still tests the native `os.cpu_count()` fallback; that is not the workflow CLI path. Do not modify `flow.py` on the basis of the stale diagnosis. If desired later, add a narrowly scoped unit test for the CLI environment-to-argument wiring, but this is lower priority than completing current PPA and safety closure.

## FSUM contract clarification from docs/isa.md

Current `docs/isa.md` blob `89a2886ab775717db26b856f267397bcbd3cb8ba` states:
- FSUM applies only to EXP2SUB with flag bit 2.
- rows are in `w4[15:0]`, contract 1..256.
- cols are in `w4[31:16]`, contract at least 64.
- B mode is not scalar: legal modes are 0, 1 or 2 (scalar mode 3 is forbidden).
- the sum address is `R[rd] + w7`; sums are one word per row.
- a matching RSUM with FSUM flag is a take, with the documented order/pending-sum contract.
This confirms the focused malformed-command guard should check rows==0 or >256, cols<64, and scalar B mode, only for EXP2SUB+FSUM. Do not invent a cols upper bound: the ISA document says cols>=64. A disabled FSUM capability check should reject both EXP2SUB and RSUM carrying the FSUM flag before dispatch, reusing the sequencer error/halt path. The separate pending-take semantic contract needs a distinct review; do not conflate it with row-buffer bounds.

Current source facts remain:
- `otpu_seq` resolves instruction fields into `dcmd` before dispatch.
- `otpu_seq` already raises `error` and `halted` on invalid operations.
- `otpu_slice` connects sequencer error to the slice's public error.
- `otpu_vpu`'s FSUM checks are simulation-only in `ifndef SYNTHESIS`.
- `Board.load_program` accepts raw uint32 instruction words without FSUM semantic validation.
- FSUM is configured on for `bcu1525-wg` and `bcu1525-x2`.
No RTL edit is made. Do not change `otpu_seq.sv` until PPA run 45877786710 is terminal.

## Next action order

1. Poll current runs; preserve completed results and do not repeat large successful suites.
2. Once PPA is terminal, inspect full job logs, resource telemetry, SRAM probe, immutable ORFS image identity and reports; no OOM assertion without explicit evidence.
3. Revisit FSUM command guard design and focused tests; do not modify unrelated datapaths.
4. Continue width-warning, latch-cell, UNOPTFLAT/SCC, formal/SVA and CDC/RDC closure.
5. Keep zero-spend, main-branch exclusion, prior RTL groups 3.1/3.2/4 exclusion, and cancelled run 45765362426 exclusion.
6. Manufacturer handoff remains NOT READY; Track A full product and Track B demonstrator remain separate.

Continuation command: **Continue and complete the remaining tasks.**
