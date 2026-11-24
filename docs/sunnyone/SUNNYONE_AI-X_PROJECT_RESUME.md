# SUNNYONE AI-X — Project Resume and Fresh-Session Continuation Guide

**Last updated:** 2026-11-24 (Asia/Dhaka)  
**Project:** SUNNYONE AI-X — commercial AI inference ASIC and custom board  
**Repository:** https://github.com/shamiursunny/openTPU  
**Active branch:** `sunnyone/commercial-profitability-architecture-2026-11-23`  
**Latest verified branch HEAD at this update:** to be confirmed on every resume  
**Main branch last independently verified:** `d84db55712aba0d40811d7762cb052f05d55b7e5` (verify again before work)

## 1. Purpose and document hierarchy

This file is the **quick-start resume guide** for a new ChatGPT window/session. Read it first, then read the other two controlling project records:

1. **Master task register and manufacturer handoff:** [SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md](SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md) — single source of truth for task IDs, statuses, release gates, manufacturer boundaries and acceptance criteria.
2. **Chronological tracker:** [PROJECT_TRACKER.md](PROJECT_TRACKER.md) — dated evidence, decisions, commits, CI run/job IDs, failures and corrections.
3. **This resume:** [SUNNYONE_AI-X_PROJECT_RESUME.md](SUNNYONE_AI-X_PROJECT_RESUME.md) — how to resume, current checkpoint, working protocol and navigation.

These three files must be maintained together. For every meaningful project task, update the resume when the continuation checkpoint or workflow changes, update the master register for task/status/acceptance changes, and append a dated tracker entry for evidence and chronology. Re-fetch all three after updates and verify their contents and commits.

## 2. User's goal and handoff boundary

The goal is a genuine AI inference accelerator ASIC and custom board, developed from Bangladesh. The user expects ChatGPT to prepare and verify as much of the design as can be done in reproducible simulation and source-level work, then provide a transparent package for an ASIC manufacturer/integrator to assess, complete, test and manufacture.

**Target milestone:** simulation-ready for manufacturer feasibility review. This is not the same as fabrication-ready, tapeout-ready, production-board-ready or silicon-qualified.

Complete locally/reproducibly where possible: RTL integration, simulation, regression, lint, assertions/formal where available, scripts, constraints, documentation, interface/address maps, reproducible logs and immutable source packaging.

Keep external dependencies explicit: foundry/PDK, licensed SRAM compiler and hard macros, DDR controller/PHY and training, PCIe endpoint/PHY, host DMA/driver and address translation, CDC/RDC, DFT/scan/MBIST/ATPG, physical implementation/signoff, package, custom board, thermal/power integrity and silicon bring-up.

The user is final decision-maker. Do not invent test results, performance, power, area, timing, readiness or manufacturer commitments.

## 3. Non-negotiable operating rules

- Zero spend unless the user explicitly authorises a specific purchase, licence, cloud service, engineering service or hardware.
- Work only on the active feature branch. Never modify `main`.
- Before each continuation, independently verify feature branch HEAD and `main`.
- Read this resume, the master register and tracker before implementation.
- Inspect existing workflows/runs before launching duplicate CI.
- Prioritise the highest-priority unresolved task in the master register; currently A01 and A04.
- Inspect source and logs before edits. Make the smallest evidence-led correction.
- Never weaken, delete, skip or relax a failing test to obtain a green result. Never suppress warnings without justified analysis and documented waiver.
- Distinguish testbench faults from DUT RTL faults; do not modify RTL based only on a timeout.
- Do not transfer results between different commit SHAs.
- Record exact commit SHA, workflow run ID, job ID, tool versions, pass/fail/skip/deselected counts, warnings, elapsed time, artifacts and limitations.
- A queued or running workflow is not a pass. Retrieve its final conclusion and logs.
- “DONE” applies only to the exact scoped task/test described; it does not mean full-chip signoff.
- Do not claim “100% ready”. State simulation and manufacturer/physical/silicon readiness separately.

## 4. Current architecture candidate (not a final physical design)

Current V1 logical candidate is documented in:
- `docs/sunnyone/SUNNYONE_AI-X_V1_FINAL_LOGICAL_DESIGN_CANDIDATE_A1.12.11.16.54.md`
- `docs/sunnyone/SUNNYONE_AI-X_AUTHORITATIVE_CONTINUATION_BASELINE_A1.12.11.16.53.md`

Candidate parameters:
- One slice; D/MCOLS/WG = 128/8/8.
- NCH/CB = 8/128 bytes; 35-bit ASIC byte address.
- 32 GiB logical DRAM: eight 4-GiB native channels, grouped into four 8-GiB DIMM/controller ports.
- Four 512-bit host AXI4 DIMM interfaces; AXI DIMM address width 34 bits, bit 33 guarded/unused.
- 128 ACT blocks / 16 rows; TMEM 128K words; IMEM 32K words.
- One-copy 1RW1R TMEM macro candidate, TMEM_IMPL=3, core clock only.
- FIFO depth 2,048; WIN 32; LANES/ULANES 8/8.
- MXU_IMPL/CL/E/QD = 2/16/8/4; VPU_CL/CNS=2/3; SE_R=2; DMA_DEPTH=512.
- 400 MHz is an SDC candidate constraint only, not an achieved or measured clock.
- ASIC restrictions: TMEM_PMP=0, MXU_PUMP=0, XPOST=0.
- No on-chip RISC-V CPU or boot ROM in V1.

Top-level integration boundary: `rtl/asic/otpu_asic_wg8_ddr4_top.sv`. It uses four host AXI masters, four muxes, four paired DIMM bridges and eight native channel bridges. PCIe endpoint/PHY, DMA descriptor engine, global translation/IOMMU, MSI-X and host driver are not implemented. External DDR controller/PHY, training/calibration, refresh, ECC datapath and electrical interface are not implemented.

No final power ceiling exists. The former 30 W system cap was explicitly retired. Optimise risk-adjusted long-term net profit, payback and cost per useful inference from measured throughput, full-system TCO, power/cooling, manufacturing cost, yield and contribution margin. Do not maximise watts, RAM capacity or peak TOPS in isolation. 128/256 GiB are stretch investigations, not V1 requirements.

## 5. Latest checkpoint and known corrections

Last verified branch HEAD before this resume-file change: `c4748c78d88e1660dc12dd6be981674dea5a962d`. Main was independently verified at `d84db55712aba0d40811d7762cb052f05d55b7e5`. Re-verify both before any work.

### A01 — four-DIMM host-path simulation (OPEN; highest priority)

Earlier diagnostic Run [45425750505](https://github.com/shamiursunny/openTPU/actions/runs/45425750505), job `138557141766`, SHA `b41669fe1d67a3f7dcb84d86a960cdb4b9167ad8`, timed out at cycle 20,000. State showed host WVALID=1111, WREADY=0000, host AWVALID=0000, controller AWVALID=0000, and no AW accepted. Source review found the bench started traffic before each DIMM's two-flop reset synchroniser released reset and used `while (!READY)`, which is unsafe for X/reset-time combinational READY.

Correction commit: `ec0fe8329df06e5204a1c082df133b62b434846b`, file `sim/verilator/tb_asic_wg8_ddr4.sv`. The bench now waits for `dut.dimm_rst_sync[d] === 1'b0` and requires READY to be exactly `1'b1` before advancing. No DUT RTL or transaction payload changed.

**Verification run:** [45428347822](https://github.com/shamiursunny/openTPU/actions/runs/45428347822), SHA `ec0fe8329df06e5204a1c082df133b62b434846b). It was QUEUED at the last poll. Retrieve status, jobs and full log. A01 remains open until four-port simulation passes and logs are inspected. If it still fails, use the actual new diagnostic state; do not assume this fix resolved it.

### A04 — Nangate45 research PPA (OPEN)

PPA Run [45426849673](https://github.com/shamiursunny/openTPU/actions/runs/45426849673), job `138561067049`, SHA `21e1d56c5c6bcafc8d45a49f5aa8920516bad068`, failed before ORFS: a literal backslash-n was written into the Docker image ID file, and Docker returned `invalid reference format`. No synthesis or PPA result was produced by this attempt.

Workflow correction commit: `e212fe714eac17e339a2cc9090bee293a8ba6c09`, file `.github/workflows/sunnyone-asic-wg8-ppa.yml`. The printf format now writes a real newline. It preserves full ORFS `run.log`, trailing diagnostic excerpt, work logs/reports/results, image ID, macro inventory and constraints/config.

**Verification run:** [45428370570](https://github.com/shamiursunny/openTPU/actions/runs/45428370570), SHA `e212fe714eac17e339a2cc9090bee293a8ba6c09`. It was QUEUED at the last poll. Retrieve its final result and artifact. If ORFS starts, inspect the complete log and reports, identify exact failing stage or report measured results. Nangate45 is a research proxy only, not production PDK evidence.

### Other runs requiring reconciliation

Runs triggered from testbench commit `ec0fe832...`:
- [45428347806](https://github.com/shamiursunny/openTPU/actions/runs/45428347806) — board-functional and uncovered RTL.
- [45428348086](https://github.com/shamiursunny/openTPU/actions/runs/45428348086) — RTL tail.
- [45428347706](https://github.com/shamiursunny/openTPU/actions/runs/45428347706) — software-core / ISA.
- [45428347703](https://github.com/shamiursunny/openTPU/actions/runs/45428347703) — subsystem and WG8 memory matrix.

These were queued at the last poll. Also reconcile older diagnostic-SHA runs:
- [45425750624](https://github.com/shamiursunny/openTPU/actions/runs/45425750624) — board/remaining RTL (previously in progress).
- [45425750818](https://github.com/shamiursunny/openTPU/actions/runs/45425750818) — RTL tail (later completed successfully; retrieve job log and exact counts).
- [45425750779](https://github.com/shamiursunny/openTPU/actions/runs/45425750779) — software-core (previously in progress).
- [45425750683](https://github.com/shamiursunny/openTPU/actions/runs/45425750683) — subsystem/memory matrix (previously queued).

Older evidence remains scoped only: Run 68 had 373 passed/5 skipped; Run 72 had 377 passed/1 intentional 64-GiB skip; target/config run 45414724190 had 66 passed; RTL-tail run 45417561286 had 33 passed/1 geometry skip/183 deselected; selected MX, quantizer and stream suites passed 17, 15, 8 and 14 tests respectively; isolated TMEM run 45417561463 had 2 passed/215 deselected. None is full regression.

## 6. Task register and next work order

The authoritative M01–M14, A01–A12 and H01–H12 task table is in Section 9 of the master handoff register. In brief:
- M01–M14 are completed or partially evidenced scoped tasks.
- A01 four-DIMM simulation and A04 PPA diagnosis remain active blockers.
- A02 expanded four-DIMM AXI protocol tests and A03 four-DIMM host/accelerator contention are not started.
- A05 research synthesis/PPA, A06 subsystem matrix, A07 software/ISA, A08 board-functional, A09 uncovered RTL, A11 lint warning closure and A12 formal protocol properties remain incomplete/partial.
- A10 final complete regression on one immutable release SHA is not started.
- H01–H12 describe external manufacturer/physical/commercial work; see master register for exact status and evidence.

Recommended order:
1. Retrieve current status and logs for A01 run 45428347822 and A04 run 45428370570.
2. Diagnose/fix A01 minimally and rerun until pass; do not hide or weaken tests.
3. Diagnose/fix A04 until the PPA workflow reliably starts and full ORFS logs/reports are available. Report proxy metrics only when sourced from actual reports.
4. Reconcile all active and older matrix runs by exact SHA, job and log. Rerun necessary failures on a later controlled SHA.
5. Add A02 expanded AXI protocol coverage and A03 contention/fairness tests after A01 passes.
6. Close remaining A05–A09, A11 and A12 with scoped evidence.
7. Run A10 complete regression on one immutable release SHA.
8. Build and checksum a reproducible manufacturer feasibility-review package, with every external dependency disclosed.
9. Only after all objective gates are met, update all three documents to final completion state. Manufacturer/physical/silicon gates remain separate and cannot be claimed complete by simulation.

## 7. Exact continuation workflow for a new ChatGPT window

At the beginning of a new session:

1. Open this file: `docs/sunnyone/SUNNYONE_AI-X_PROJECT_RESUME.md`.
2. Open and read the complete master register: `docs/sunnyone/SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md`.
3. Open and read the latest chronological entries in `docs/sunnyone/PROJECT_TRACKER.md` (and earlier sections when needed to understand a task).
4. Verify active feature branch HEAD and `main` independently through GitHub. Do not assume the SHA in this file is still current.
5. Query existing workflow runs for the active branch and the exact SHAs recorded above. Inspect job status, steps, logs and artifacts; do not create duplicate runs unnecessarily.
6. Choose the highest-priority unresolved register item and continue with evidence-led changes on the feature branch only.
7. After a meaningful task, update all three documents:
   - Resume: current branch/checkpoint, blockers, next actions and important run IDs.
   - Master register: task status, evidence and acceptance criteria.
   - Tracker: dated chronological narrative, exact commits, run/job IDs, test counts, limitations and decisions.
8. Re-fetch all three files from the feature branch, verify their content and blob/commit references, and confirm `main` is unchanged.
9. Tell the user precisely what was verified, what remains open and the next action. Never imply a queued workflow passed.

## 8. Important reference files

- Master register: `docs/sunnyone/SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md`
- Chronological tracker: `docs/sunnyone/PROJECT_TRACKER.md`
- V1 logical design candidate: `docs/sunnyone/SUNNYONE_AI-X_V1_FINAL_LOGICAL_DESIGN_CANDIDATE_A1.12.11.16.54.md`
- Authoritative continuation baseline: `docs/sunnyone/SUNNYONE_AI-X_AUTHORITATIVE_CONTINUATION_BASELINE_A1.12.11.16.53.md`
- Four-DIMM bench: `sim/verilator/tb_asic_wg8_ddr4.sv`
- ASIC/config workflow: `.github/workflows/sunnyone-asic-config.yml`
- PPA workflow: `.github/workflows/sunnyone-asic-wg8-ppa.yml`
- ASIC flow driver: `tools/asic/flow.py`
- ASIC top: `rtl/asic/otpu_asic_wg8_ddr4_top.sv`

## 9. Completion and honesty rules

The simulation-ready manufacturer feasibility-review release requires all objective gates in Section 9.4 of the master register, one immutable release SHA, reproducible logs/tool versions/checksums, and explicit external dependency disclosures.

It does **not** mean the chip is fabricated, physically signed off, packaged, board-tested or silicon-qualified. The manufacturer/foundry must complete the process-specific and hardware tasks. Never label the project finally completed until the user's intended project milestones and external handoff outcomes are actually evidenced.

**Last known decision:** continue A01 and A04 verification first. Both corrective commits exist, but their verification runs were queued at the last confirmed poll. No paid resources have been authorised.
