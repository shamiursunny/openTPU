# SUNNYONE AI-X — Project Resume and Fresh-Session Continuation Guide

**Last updated:** 2026-11-25 (Asia/Dhaka)  
**Project:** SUNNYONE AI-X — commercial AI inference ASIC and custom board  
**Repository:** https://github.com/shamiursunny/openTPU  
**Active branch:** `sunnyone/commercial-profitability-architecture-2026-11-23`  
**Feature-branch documentation checkpoint before this resume update:** `ea95f887e310a97ed87143fc745e7d5e742f1b3e` (documentation-only commits follow; verify live branch HEAD before every continuation)  
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
- Prioritise the highest-priority unresolved task in the master register; A01's single-beat host-path scope is passed, while A02 multi-beat integration is pending a corrected exact-SHA rerun and A04/A05 PPA remain open.
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

Feature-branch checkpoint before this documentation refresh: `0d6128d21c086d52e0c6ca3a10bfe4f2666dcccb`. Main was independently re-verified unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`. Re-verify both before any work.

### A01 — four-DIMM host-path simulation (DONE — scoped single-beat integration)

Earlier diagnostic Run [45425750505](https://github.com/shamiursunny/openTPU/actions/runs/45425750505), job `138557141766`, SHA `b41669fe1d67a3f7dcb84d86a960cdb4b9167ad8`, timed out at cycle 20,000. State showed host WVALID=1111, WREADY=0000, host AWVALID=0000, controller AWVALID=0000, and no AW accepted. Source review found the bench started traffic before each DIMM's two-flop reset synchroniser released reset and used `while (!READY)`, which is unsafe for X/reset-time combinational READY.

Correction commit: `ec0fe8329df06e5204a1c082df133b62b434846b`, file `sim/verilator/tb_asic_wg8_ddr4.sv`. The bench now waits for `dut.dimm_rst_sync[d] === 1'b0` and requires READY to be exactly `1'b1` before advancing. No DUT RTL or transaction payload changed.

**Verified pass:** [45428347822](https://github.com/shamiursunny/openTPU/actions/runs/45428347822), job `138566432055`, exact SHA `ec0fe8329df06e5204a1c082df133b62b434846b`. Full job log reports: `PASS: four independent WG8 DIMM ports; host AW/W/B and AR/R routed on all four ports with independent backpressure`; Verilator finished at 210 ns. This closes only the current single-beat four-port host-path test. It does not close A02 multi-beat/protocol coverage or A03 host/accelerator contention. The integrated lint logs still contain width-expansion/truncation, UNOPTFLAT and MODDUP warnings for triage under A11.

### A04 — Nangate45 research PPA (IN PROGRESS; synthesis mapping blocker diagnosed)

The earlier Docker image-ID defect was fixed in workflow commit `e212fe714eac17e339a2cc9090bee293a8ba6c09`. Verification Run [45428370570](https://github.com/shamiursunny/openTPU/actions/runs/45428370570), job `138566505337`, exact SHA `e212fe714eac17e339a2cc9090bee293a8ba6c09`, successfully pulled and pinned ORFS image `sha256:02c90ad9cb0efb19f7881bf1bf43330dacb5323eac756af6e1604042ec60d21a`, ran the SRAM probe, enumerated 288 macro instances / 14 sizes / about 3,538 KiB, and entered ORFS/Yosys synthesis. It then failed at Yosys memory mapping: three MXU result-FIFO copies are each 64 x 672 = 43,008 bits, exceeding `SYNTH_MEMORY_MAX_BITS=16384`.

Source review confirms `otpu_ram_1r1w_ra` is intentionally asynchronous-read and write-first; substituting the existing synchronous fakeram45 macros would change semantics. The evidence-led research-flow correction therefore raises the flip-flop mapping threshold to 65,536 bits and documents that these three copies remain flip-flops in the proxy. This is a high-area mapping, not a foundry SRAM solution or a final physical architecture.

Flow correction commit: `0b67e65deb7fcc457b10bb825304db752689b3e7`, `tools/asic/flow.py`. Mapping limitation documentation commit: `c09447bafa3460d4acc74b35c4f7e6bdf40b9857`, `asic/nangate45/README.md`. Corrected-flow Run [45452183549](https://github.com/shamiursunny/openTPU/actions/runs/45452183549) remains IN_PROGRESS on exact SHA `0b67e65deb7fcc457b10bb825304db752689b3e7`. A newer-code Run [45454389335](https://github.com/shamiursunny/openTPU/actions/runs/45454389335) is QUEUED on SHA `fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc`. A04 remains open until synthesis completes and full ORFS reports are inspected. Nangate45 remains a research proxy only; no area, timing or power result is yet available.

### A02/A03 — expanded AXI protocol and four-DIMM host/accelerator contention (IN PROGRESS; exact-SHA CI pending)

**A02 host-burst coverage:** testbench commits `76f3a5ecffdef73db2eb298bf775552c5f801c12` and `141dd7857cdd76d405698e1d3dc3a61a8cdb64e0` extend `sim/verilator/tb_asic_wg8_ddr4.sv` to exercise 1-, 2-, 4- and 8-beat host writes/reads across four DIMMs, AWLEN/ARLEN, WLAST/RLAST and beat data, full/partial/zero WSTRB, independent backpressure, W-before-AW on DIMM0 and legal 8-beat bursts ending exactly at a 4-KiB boundary. Commit `4a2dd86b6b7f61b96d8cb0f2e5d5e573c85349e9` adds all four BRESP/RRESP encodings and expected-fatal host AW/AR tests for address bit 33. Workflow commit `66c676cf515e2063c6f322cd1912c94f07ec085c` runs both negative cases and checks the exact 8-GiB aperture fatal. **Latest consolidated ASIC/config Run [45455874266](https://github.com/shamiursunny/openTPU/actions/runs/45455874266)** is queued on exact SHA `d3a75fd673e0df07d0a952e06ce737211f535850`; it includes the A02 negative cases, A03 HMUX_FORMAL contention bench and H06 address-map simulation. No pass is claimed yet. Outstanding ID ordering, reset-in-flight and further negative protocol cases remain.

**A03 contention coverage:** added `sim/verilator/tb_asic_wg8_hmux_contention.sv` in commit `62c319e5eed8f902e10ceb01c7c84b2eaad9d564`, with four instances of the production `otpu_mig_hmux` configuration (IDW=4, AW=34, HB=2). It drives simultaneous host/pair AW and AR requests, checks alternating grants over two requests per source, verifies ordered two-beat W bursts, routes B/R by IDs, and varies controller/requester backpressure. The CI compile/run step and path trigger were added in workflow commit `e0fa44d99a4ba598881f6960a2196f6752550fea`. HMUX_FORMAL properties were added in commit `fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc`; the workflow compiles with `-DHMUX_FORMAL` and Verilator `--assert`. The same consolidated queued Run [45455874266](https://github.com/shamiursunny/openTPU/actions/runs/45455874266) includes both testbenches, assertion checks and the H06 global address-map bench. Inspect the full logs before closing A02/A03.

### A11 — lint warning triage and structural loop cleanup (IN PROGRESS; exact-SHA verification pending)

The A01 lint artifact showed three UNOPTFLAT cones and a MODDUP duplicate module warning. The MODDUP was caused by `rtl/mem/otpu_native_dram.sv` appearing twice in the explicit Verilator source list; the ASIC workflow now normalises and de-duplicates source paths with `Path.resolve()` and `dict.fromkeys()` (commit `4e26612323f1067acdf360ec6a556a339bab89cd`).

The two `otpu_slice.sv` warnings were false combinational-cone reports caused by independent signals being assigned in the same `always_comb` processes: `rpl_frz` and `rpl_hold`, and `cgl_m` and `gnt_m`. These processes were split without changing their Boolean expressions in commit `71496cc3d237458ff83806293d73a43de7307922`. The `otpu_tmem.sv:pq` warning came from guest ports aliasing `pq[SH_HOST]` through the same packed array; a dedicated `pq_host` vector now carries the host data and guest aliases point to that vector (commit `487fe6b93a83e4b86e5565b80de9b7f33c407436`).

Lint observability was improved: the full-chip lint workflow no longer suppresses WIDTHEXPAND/WIDTHTRUNC or unused warnings (workflow commit `1103498f9d1222ee897a510dfcf912a59fe39301`); the ASIC/config workflow no longer suppresses width warnings (commit `86bc7b57202bf4d91ea9ed7f8657db0bebb2b413`); the subsystem workflow uses pytest `-rs` to expose skip reasons (commit `ec151e9180c902c2157d84fb626121a4b81c8c1e`).

**Verification queued:** full-chip lint Run [45454389561](https://github.com/shamiursunny/openTPU/actions/runs/45454389561) on SHA `fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc`; ASIC/config Run [45454747313](https://github.com/shamiursunny/openTPU/actions/runs/45454747313) on SHA `66c676cf515e2063c6f322cd1912c94f07ec085c`. The latest lint outputs must confirm whether MODDUP/UNOPTFLAT disappeared and capture the now-visible width warnings. Remaining WIDTHEXPAND/WIDTHTRUNC in VPU, quantizer, MXU, DMA, sequencer and native DRAM need semantic review; do not silence them or make broad casts without checking bounds and signedness.

### A12 — HMUX AXI protocol assertions (PARTIAL; assertion-enabled simulation pending)

Added `HMUX_FORMAL` SVA properties to `rtl/boards/bcu1525/otpu_mig_hmux.sv` in commit `fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc`. They check AW/W/AR payload stability while the controller backpressures, B/R response stability while the selected requester backpressures, mutual exclusion of host/pair AW/AR/W ready, no W ready before an AW is queued, and B/R routing according to the host-ID bit. The A03 contention workflow compiles with `-DHMUX_FORMAL` and Verilator `--assert`; latest Run [45454747313](https://github.com/shamiursunny/openTPU/actions/runs/45454747313) is queued on exact SHA `66c676cf515e2063c6f322cd1912c94f07ec085c`.

This is assertion-enabled simulation, not a completed formal proof. A SymbiYosys/SMT proof harness, reset properties, full AXI ordering/address translation and top-level arbitration properties remain open.

### Other runs requiring reconciliation

Latest-code runs on the current RTL refactor:
- [45453893567](https://github.com/shamiursunny/openTPU/actions/runs/45453893567) — board-functional and uncovered RTL jobs `138658011213` and `138658011921` are QUEUED on SHA `487fe6b...`; earlier board retry job `138652132132` and software retry job `138652190796` remain IN_PROGRESS on SHA `ec0fe832...` and must be reconciled separately.
- [45453893412](https://github.com/shamiursunny/openTPU/actions/runs/45453893412) — latest RTL-tail job `138658011365` is QUEUED on SHA `487fe6b...`; earlier job `138566421070` succeeded but failed to upload its expected log artifact, so its exact count remains unverified.
- [45453893300](https://github.com/shamiursunny/openTPU/actions/runs/45453893300) — latest software-core job `138658009331` is QUEUED on SHA `487fe6b...`; earlier retry job `138652190796` remains IN_PROGRESS on SHA `ec0fe832...`.
- [45454026458](https://github.com/shamiursunny/openTPU/actions/runs/45454026458) — latest subsystem/memory matrix is QUEUED on SHA `ec151e...`; its workflow now uses pytest `-rs` to reveal the reason for the single skip seen in Run 45428347703 (374 passed, 1 skipped).

Older diagnostic-SHA runs [45425750624](https://github.com/shamiursunny/openTPU/actions/runs/45425750624), [45425750779](https://github.com/shamiursunny/openTPU/actions/runs/45425750779) were cancelled; [45425750818](https://github.com/shamiursunny/openTPU/actions/runs/45425750818) RTL-tail passed on its own SHA; and [45425750683](https://github.com/shamiursunny/openTPU/actions/runs/45425750683) subsystem jobs passed on their own SHA. Do not transfer those results to `ec0fe832...` or later SHAs.

## 6. Task register and next work order

The authoritative M01–M14, A01–A12 and H01–H12 task table is in Section 9 of the master handoff register. In brief:
- M01–M14 are completed or partially evidenced scoped tasks.
- A01's single-beat four-DIMM host-path simulation passes on exact SHA `ec0fe832...`. A02/A03 testbenches now include multi-beat bursts, all BRESP/RRESP codes, negative aperture cases and HMUX_FORMAL assertions; latest ASIC/config Run `45454747313` on `66c676...` is queued.
- A04 corrected-flow Run `45452183549` remains active on SHA `0b67e65...`; latest-code PPA Run `45454389335` is queued on `fc3bdc...`. No PPA metrics exist yet. A05 remains in progress.
- A06 prior 14-job matrix Run `45425750683` on SHA `b41669fe...` completed 377 passed, 1 skipped, 0 failed; the single skip is explicitly justified at 64 GiB because every address is DRAM (`test_beyond_the_dram_stops_the_board_model`). The same skip condition is present on SHA `ec0fe832...`. Latest matrix Run `45454026458` uses pytest `-rs` to expose the skip reason on the newer code. A07 latest software-core Run `45453893300` / job `138658009331` is IN_PROGRESS on SHA `487fe6b...`; earlier job `138652190796` on `ec0fe832...` remains IN_PROGRESS, while older run `45425750779` was CANCELLED. A08/A09 latest Run `45453893567` jobs `138658011213` and `138658011921` are QUEUED on SHA `487fe6b...`; earlier A08 job `138652132132` remains IN_PROGRESS, A09 job `138652135885` was CANCELLED, and older run `45425750624` was cancelled. A11 structural warning fixes and A12 assertion set are committed but unverified.
- A11 lint warning closure and A12 full formal protocol properties remain partial. A10 final complete regression on one immutable release SHA is not started.
- H01–H04 and H07–H11 cover manufacturer/physical/hardware dependencies. H05 has a source-derived host DMA/descriptor interface specification at `docs/sunnyone/SUNNYONE_AI-X_HOST_DMA_AND_GLOBAL_ADDRESS_MAP_SPEC.md`; PCIe/DMA RTL, descriptor ABI and driver remain open. H06 now also has a standalone global-to-DIMM decoder and inverse-bijection testbench; ASIC/config Run `45455874266` on `d3a75f...` is queued. A combinational formal harness and pinned-Yosys SAT workflow were added. First formal Run `45456060346` failed because Yosys emitted `$check` cells not accepted by the SAT pass. The attempted `chformal -assert` change at `9c550d...` was incomplete because `-assert` selects a constraint type but does not lower `$check`; Run `45456545394` completed with `ERROR: Mode option is missing` and is superseded. Workflow commit `0d6128d21c086d52e0c6ca3a10bfe4f2666dcccb` now uses `chformal -lower`; corrected formal Run `45457143624` on `0d6128...` is queued. Neither the simulation nor formal proof has passed yet. The decoder is not integrated into a DMA engine or ASIC top, so end-to-end global routing remains open. H12 has an evidence-based profitability measurement framework at `docs/sunnyone/SUNNYONE_AI-X_COMMERCIAL_PROFITABILITY_MEASUREMENT_MODEL.md`; numeric ROI/power decisions remain blocked on measured performance, physical PPA, full-system power, manufacturer quotations and demand/pricing evidence.

Recommended order:
1. Inspect consolidated ASIC/config Run `45455874266` on exact SHA `d3a75f...` for A02 multi-beat/response/negative-address tests, A03 contention/HMUX_FORMAL assertions and H06 address-map simulation.
2. Inspect full-chip lint Run `45454389561` on exact SHA `fc3bdc...` for MODDUP/UNOPTFLAT cleanup and exposed width warnings.
3. Inspect H06 formal rerun `45457143624` on exact SHA `0d6128...` and standalone address-map simulation Run `45455874266` on `d3a75f...`; the first formal attempt failed at Yosys SAT cell conversion, the intermediate `45456545394` script failed with `Mode option is missing` and is superseded, and the `chformal -lower` rerun is pending.
4. Inspect subsystem Run `45454026458` on exact SHA `ec151e...` for pytest skip reasons and exact counts.
5. Retrieve corrected-flow PPA Run `45454389335`, latest software-core Run `45453893300`, board/uncovered Run `45453893567` and RTL-tail Run `45453893412`; reconcile older active attempts by exact SHA.
6. Complete A04/A05 research synthesis and PPA only from reproducible reports; continue A06–A09, A11 and A12 with exact-SHA evidence and add a real HMUX formal proof harness.
7. Run A10 complete regression on one immutable release SHA.

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

**Last known decision:** continue A02 verification after the testbench B-response-model correction, while separately diagnosing A04/A05 PPA. Do not change production HMUX RTL without new evidence. No paid resources have been authorised.

## 10. Document commit references at this checkpoint

- Resume guide initial creation: `3a39b5eada362f65e9882896a5ee34bea5d9760c`; this final refresh is a later commit on the same feature branch.
- Master register update adding this guide and the three-file protocol: `2b168ed918b2434347b212d7b79d700558dcc48e`; latest tracker-pointer refresh: `34c4e3bf85e4826590266a1f613bfa4abc815181`.
- Chronological tracker entry documenting the resume guide and three-file protocol: `a8e91b44dd148d77f1f5ffc56d930fefc9e4dd3b`.
- These are document-update commits, not a final project release SHA. Always query the live branch head and `main` before continuing.


## 11. Historical test-pass audit and workflow status — 2026-11-25

**Read this section first when resuming.** The historical GitHub Actions audit has now been reconciled with actual job logs and pytest summaries. There are already well over 100 verified passing test executions in the project. The strongest single-run aggregate is **377 passed, 1 intentional skip, 0 failed** across 14 subsystem/memory jobs in Run [45428347703](https://github.com/shamiursunny/openTPU/actions/runs/45428347703), exact SHA `ec0fe8329df06e5204a1c082df133b62b434846b`.

### Confirmed passes to preserve

| Area | Run | Exact SHA | Verified result |
|---|---|---|---|
| Subsystem + memory regression matrix | [45428347703](https://github.com/shamiursunny/openTPU/actions/runs/45428347703) | `ec0fe8329df06e5204a1c082df133b62b434846b` | 14 jobs; 377 passed, 1 intentional geometry skip, 0 failed |
| RTL tail | [45454717008](https://github.com/shamiursunny/openTPU/actions/runs/45454717008) | `4a2dd86b6b7f61b96d8cb0f2e5d5e573c85349e9` | 33 passed, 1 documented skip, 183 deselected |
| 128K one-copy TMEM isolated test | [45465292891](https://github.com/shamiursunny/openTPU/actions/runs/45465292891) | `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f` | 2 passed, 215 deselected |
| Reset audit | [45455745271](https://github.com/shamiursunny/openTPU/actions/runs/45455745271) | `dc34e3a51c27c01af6296015cd206ab8336d6bda` | 4 passed |
| Full-chip Verilator lint | [45455745243](https://github.com/shamiursunny/openTPU/actions/runs/45455745243) | `dc34e3a51c27c01af6296015cd206ab8336d6bda` | Workflow/job success; lint scope only |
| Four-instance HMUX directed simulation | [45454389445](https://github.com/shamiursunny/openTPU/actions/runs/45454389445) | `fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc` | 3-beat host/pair AW-W-B and AR-R, backpressure; 2 write bursts, 6 read beats, 25 cycles |
| Global-to-DIMM address-map formal | [45457143624](https://github.com/shamiursunny/openTPU/actions/runs/45457143624) | `0d6128d21c086d52e0c6ca3a10bfe4f2666dcccb` | 14 assertions, 813 variables, 2,152 clauses, SAT SUCCESS |
| ASIC AXI-Lite control | [45248945992](https://github.com/shamiursunny/openTPU/actions/runs/45248945992) | `ae997da8a993e962dd18de0fb1240f3d5656b3a2` | PASS marker: independent AW/W, gating, load pulse, reset, register map |
| Earlier selected RTL/ISA and AXI-Lite | [45217729099](https://github.com/shamiursunny/openTPU/actions/runs/45217729099) | `66c708e573671136197c371a848cc9274ae394f2` | 99 passed plus 1 separate AXI-Lite isolation test; one LDC overlap means 100 distinct selected cases, not 101 |
| Virtual DRAM/TMEM behavioural tests | [45453893286](https://github.com/shamiursunny/openTPU/actions/runs/45453893286) | `487fe6b93a83e4b86e5565b80de9b7f33c407436` | DRAMTEST, TMEMTEST and TMEM_MULTI PASS markers |

The 377 matrix breakdown is recorded in tracker section 126. It comprises: MX multiply/replay 17; quantizer modes 15; QHL 7; collective hub/DMA/scoreboard 128; floating point 8; wait-state 11; stream 14; quantizer corners/ties 8; instruction cache 23; address-window 20 plus one intentional skip; SPLITQ 5; QST/QSTB 13; reset audit 4; native DRAM/technology RAM 104.

### Workflow history — interpretation

The feature-branch GitHub Actions query returned 705 run records, including 316 with SUCCESS conclusion. These are workflow-run successes, not 316 unique test cases. They include retries, old commits and workflow-only retriggers. The successful history includes subsystem/memory, TMEM, RTL-tail, reset audit, full-chip lint, HMUX simulation, virtual DRAM, AXI-Lite, PCIe bridge, functional RTL and workload-harness workflows. The queried history had no successful workflow run for remaining RTL/board regressions, software-core or WG8 research PPA. Do not state that the whole pipeline is green.

The one skip in the 377-pass matrix is the 64-GiB address-window test whose “address beyond DRAM” condition is inapplicable because every representable address is DRAM at that geometry. Keep it as a skip, not a pass. The detailed workflow-by-workflow success/failure inventory and exact source SHAs are in tracker section 126.

### Live work at the last poll (2026-11-25)

Queued:
- ASIC/config Run `45465384680`, SHA `65f28fc09ede79581ba97845165733d1caef45b1`.
- Remaining RTL/board Run `45465292882`, SHA `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f`.
- RTL subsystem/memory Run `45465292903`, SHA `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f`.

In progress:
- Software-core Run `45465292772`, SHA `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f`.
- ASIC/config Run `45465292665`, SHA `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f`.
- RTL-tail Run `45465292944`, SHA `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f`.
- Earlier PPA Run `45455745851`, SHA `dc34e3a51c27c01af6296015cd206ab8336d6bda`, still in progress at the poll.
- Other older retries and board/RTL jobs may remain active or queued; query the live run list before assuming any state.

**Do not treat any queued/in-progress job as passed.** Fetch final job steps/logs, verify exact source SHA, and record test counts. If a log is unavailable (e.g. BlobNotFound), retry later rather than infer a result.

### Immediate next actions

1. Poll the live Actions run history and inspect the jobs for Runs 45465384680, 45465292882, 45465292903, 45465292772, 45465292665 and 45465292944, then the PPA and older board/RTL retries.
2. For ASIC/config, inspect the three integrated lint stages, four-DIMM host AXI simulation, global address-map simulation and four-DIMM HMUX contention simulation separately. Do not carry lint success from SHA 51f3b9... onto SHA 86f9... or 65f2... .
3. If the four-DIMM host test times out, inspect the timeout-only HMUX probes (AW owner enqueue and W-slice signals) before changing any synthesizable RTL. The underlying stall is not yet diagnosed.
4. Continue software-core, board, RTL-tail and subsystem tests. No successful software-core workflow was found in the historical audit; this is a priority gap.
5. Continue the Nangate45 research PPA flow. No successful WG8 PPA workflow or verified area/timing/power result exists.
6. Update the master handoff register, this resume and chronological tracker together after material changes. Tracker section 126 contains the audit method and evidence table. Re-fetch all documents after updates.
7. Before further engineering, verify live feature branch HEAD and `main`; preserve feature-branch-only changes. The last independently verified `main` SHA remains `d84db55712aba0d40811d7762cb052f05d55b7e5`, but it must be checked again before work.

### Continuation status

This project has a substantial, auditable body of passing simulation and RTL tests, including a 377-pass matrix. That does **not** mean all tests are complete, the final release SHA is fully regressed, or the design is production/tapeout/silicon ready. PCIe endpoint/PHY, DDR controller/PHY, SRAM hard macros, DFT, physical design/signoff, package, board electrical validation, real-hardware workload metrics and commercial validation remain open.


## 6. Live continuation checkpoint — 2026-11-25

**Do not resume from the older queued-run list in Section 5.** The master task register's Section 11 and tracker Section 127 supersede it.

### Current code/evidence checkpoint
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Latest diagnostic RTL/testbench-only commit: `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a`.
- That commit changes only the failure message in `sim/verilator/tb_asic_wg8_ddr4.sv` so a repeated W-channel mismatch reports actual/expected WDATA, WSTRB, WLAST, owner-FIFO and handshake state. No synthesizable RTL changed.
- Documentation synchronisation commits: tracker `99973c70b6f47507d9ff627c1dfdcd13dc592086`; master register `355b5f1b67b6cb2cd17b50618bd6a52b8b4d6e5f`. Re-fetch the live branch head after any later documentation updates.
- Main remains protected at `d84db55712aba0d40811d7762cb052f05d55b7e5`; re-verify before future edits.

### Fresh CI facts
- ASIC/config Run 45465384680 on SHA `65f28fc09ede79581ba97845165733d1caef45b1`: all three integrated ASIC lint stages passed; four-DIMM host simulation failed at 135 ns with `DIMM2 host W payload/last mismatch beat=0`. Address-map and HMUX stages were skipped by fail-fast.
- Earlier Run 45465292665 on SHA `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f` failed on the same assertion. This is repeatable across two SHAs.
- Diagnostic commit `e1f46ee...` had no associated workflow run returned by the first commit-workflow query. Check again; do not assume it triggered.
- RTL-tail Run 45465292944 passed 33 tests, with 1 parameter-inapplicable skip and 183 deselected.
- Board-functional and uncovered-RTL Run 45465292882 were still running; software-core Run 45465292772 was still running; all 14 jobs in subsystem Run 45465292903 were queued at the last poll.
- WG8 PPA Run 45454389335 on SHA `fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc` failed inside ORFS with exit 2. Artifact 14960636530 contains the detailed run evidence. Do not claim area/timing/power. Older Run 45455745851 was still running at the last poll.
- Historical 377-pass / 1 intentional-skip subsystem matrix, address-map SAT proof, and directed HMUX pass remain valid only for their exact historical SHAs.

### Next execution order
1. Check whether the exact diagnostic commit triggered the ASIC/config workflow. If no run exists, trigger the existing workflow on the active branch/commit using an approved push-trigger path; do not change synthesizable RTL just to trigger CI.
2. Inspect the detailed DIMM2 diagnostic values and identify the mismatching field and owner/handshake state.
3. Fix only the proven testbench or RTL cause. Re-run four-DIMM normal and negative-aperture scenarios.
4. Once A02 passes, run the address-map simulation and four-instance HMUX contention/assertion steps.
5. Retrieve final board, uncovered RTL, software-core and subsystem logs. Inspect PPA artifact 14960636530 and diagnose ORFS exit 2.
6. Update all three governing documents and verify exact branch/main refs.

### Strategy guardrails
The former 30 W total-system ceiling remains retired. No replacement wattage ceiling is selected. Optimise risk-adjusted long-term net profit and realistic payback through measured useful inference, full-system TCO, wall power/cooling, reliability and incremental contribution margin. Do not maximise watts, RAM or peak TOPS alone. Keep the zero-spend rule and do not claim production/tapeout readiness.


### CI trigger status — 2026-11-25
The diagnostic-only testbench commit is `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a`. A comment-only push-trigger commit to the existing ASIC/config workflow is `597f1b9af961f4e8fcde1ae9fffa013ce6bc7f54`. The immediate workflow lookup returned no associated run for either commit. Do not assume CI started; recheck Actions and record a run only when GitHub returns an exact run/job record. Tracker Section 128 records this attempt.


Latest job-state correction (2026-11-25): uncovered-RTL job `138698481369` in Run `45465292882` is **CANCELLED**, not running; board-functional job `138698482005` remains IN_PROGRESS. Software-core job `138698481416` remains IN_PROGRESS; all subsystem Run `45465292903` jobs remain QUEUED; PPA job `138664562707` remains IN_PROGRESS. A09 needs a fresh exact-SHA rerun. See PROJECT_TRACKER.md Section 129.


## 7. Latest continuation checkpoint — 2026-11-25

The first expanded W-channel diagnostic run exposed a testbench instrumentation error, not a new DUT failure. Run [45479454587](https://github.com/shamiursunny/openTPU/actions/runs/45479454587), SHA `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a`, failed before simulation because Verilator rejected a variable-index dotted hierarchy reference (`dut.g_host_mux[d].u_hmux`). No conclusion about the DIMM2 W-channel datapath can be drawn from that run.

Corrected testbench-only instrumentation is committed as `76966009274be54ce26d87e333744b5cc17f72b4`. It uses static generate-indexed probes for owner FIFO and W-channel state. No synthesizable RTL or test expectations were changed.

Six workflows were confirmed on the corrected SHA and were QUEUED at last poll:
- ASIC/config [45481815682](https://github.com/shamiursunny/openTPU/actions/runs/45481815682).
- Board-functional/uncovered RTL [45481815901](https://github.com/shamiursunny/openTPU/actions/runs/45481815901).
- Software-core [45481815819](https://github.com/shamiursunny/openTPU/actions/runs/45481815819).
- RTL tail [45481815780](https://github.com/shamiursunny/openTPU/actions/runs/45481815780).
- RTL subsystems/WG8 [45481815735](https://github.com/shamiursunny/openTPU/actions/runs/45481815735).
- Isolated 128K TMEM [45481815691](https://github.com/shamiursunny/openTPU/actions/runs/45481815691).

Older queued run [45480699954](https://github.com/shamiursunny/openTPU/actions/runs/45480699954) uses the earlier invalid diagnostic version and is not acceptable evidence for the corrected testbench. Tracker Section 130 and handoff register Section 12 carry the full details.

**Next:** poll the six corrected-SHA workflows, inspect the ASIC/config build log, then classify the exact DIMM2 W mismatch before changing RTL. Main remains untouched; do not claim four-DIMM pass or production readiness.


### Corrected-SHA live job states — 2026-11-25

On testbench commit `76966009274be54ce26d87e333744b5cc17f72b4`, the latest poll shows: ASIC/config Run 45481815682 queued; board-functional job in Run 45481815901 queued; uncovered-RTL job in that run in progress (building Verilator 5.044); software-core Run 45481815819 queued; RTL-tail Run 45481815780 in progress (installing dependencies); all 14 subsystem jobs in Run 45481815735 queued; isolated TMEM Run 45481815691 in progress. No corrected-SHA four-DIMM result exists yet. The next gate is ASIC/config compilation and the diagnostic simulation. See PROJECT_TRACKER.md Section 131.


## 11. Latest continuation update — 2026-11-25

**Current feature-branch HEAD at this update:** \`68baca1a080e952b20327c90d63a6f66c6a1ee70\`. The active branch is \`sunnyone/commercial-profitability-architecture-2026-11-23\`. Main remains unchanged at \`d84db55712aba0d40811d7762cb052f05d55b7e5\`. Recheck both refs at the beginning of the next session.

### A02 — four-DIMM multi-beat W-channel diagnostic

Corrected diagnostic ASIC/config Run [45481815682](https://github.com/shamiursunny/openTPU/actions/runs/45481815682), job \`138756664096\`, exact SHA \`76966009274be54ce26d87e333744b5cc17f72b4\`, passed 66 target/config tests and all three integrated lint stages, then failed at 135 ns on DIMM2 WDATA/WSTRB comparison.

Observed output was beat 2 (\`feed000200000002\`, full strobe) while the scoreboard expected beat 0 (\`feed000200000000\`, alternating strobe); WLAST matched. The HMUX owner FIFO was already empty at the output handshake. Source inspection identified the cause in the **testbench controller response model**, not production RTL: BVALID was generated after any W handshake, and the accepted early B response reset the W beat counter before the burst finished.

Correction commit \`68baca1a080e952b20327c90d63a6f66c6a1ee70\` changes the response condition to require either an already-completed W burst or a same-cycle accepted WLAST beat. Only \`sim/verilator/tb_asic_wg8_ddr4.sv\` changed. No synthesizable RTL, payload expectations or acceptance checks changed.

**A02 is IN PROGRESS pending exact-SHA verification.** Immediately after commit, the combined status was empty and the commit-workflow lookup returned no associated run. That lookup exposes PR-triggered runs only, and combined status is not a complete Actions run listing; push-triggered run existence is therefore UNKNOWN, not confirmed absent. Check the repository Actions history before deciding whether a manual retrigger is needed; do not assume a workflow has started or passed. The corrected multi-beat test, both negative-aperture tests and the complete ASIC/config job log must pass on the exact SHA before closing A02.

A03's four-instance host/accelerator contention and HMUX assertion stage was skipped in the preceding integrated run after A02 failed. It remains IN PROGRESS and must be checked after A02 passes. The standalone address-map SAT proof passed 14 assertions on its own historical SHA, but integrated address-map simulation remains unverified.

On the preceding diagnostic SHA \`769660...\`, RTL-tail Run \`45481815780\` passed 33 tests, 1 documented parameter-inapplicable skip and 183 deselected; isolated TMEM Run \`45481815691\` passed 2 tests, 215 deselected. These are not results for \`68baca...\`. Board-functional/uncovered RTL, software-core and subsystem jobs from the same diagnostic SHA were still running or queued at the last poll; reconcile them by exact job and SHA.

### Current next actions

1. Verify branch HEAD and main independently.
2. Find the new ASIC/config workflow triggered by \`68baca...\`; inspect its job steps and complete log.
3. If A02 passes, verify the two expected-fatal aperture cases, the integrated address-map simulation and four-instance HMUX contention/assertion stage.
4. Re-poll and reconcile board-functional, uncovered RTL, software-core and subsystem jobs from prior exact SHAs; retry cancelled coverage only on an appropriate new exact SHA.
5. Inspect the ORFS artifact/run.log for the failed PPA run separately. No area, timing, power or PPA result is currently accepted.
6. Update this resume, master register and chronological tracker together after each meaningful result.

**Readiness boundary:** the project is not simulation-ready for manufacturer feasibility review, fabrication-ready, tapeout-ready, production-board-ready or silicon-qualified. A01 is only a scoped single-beat pass. A02/A03, PPA, broader regressions, lint/formal closure and the immutable release regression remain open. Manufacturer/physical dependencies remain explicit. Zero-spend and feature-branch-only rules remain in force.



## 12. Actions run IDs confirmed for corrected W-response testbench SHA — 2026-11-25

Exact code SHA: \`68baca1a080e952b20327c90d63a6f66c6a1ee70\`. Six push-triggered workflows are confirmed:

| Workflow | Run ID | Current state |
|---|---:|---|
| ASIC/config | [45487119079](https://github.com/shamiursunny/openTPU/actions/runs/45487119079) | QUEUED |
| Board + uncovered RTL | [45487118979](https://github.com/shamiursunny/openTPU/actions/runs/45487118979) | board IN_PROGRESS; uncovered QUEUED |
| Software-core | [45487119094](https://github.com/shamiursunny/openTPU/actions/runs/45487119094) | QUEUED |
| Isolated 128K TMEM | [45487119017](https://github.com/shamiursunny/openTPU/actions/runs/45487119017) | QUEUED |
| RTL subsystems/WG8 | [45487118947](https://github.com/shamiursunny/openTPU/actions/runs/45487118947) | all 14 jobs QUEUED |
| RTL tail | [45487118908](https://github.com/shamiursunny/openTPU/actions/runs/45487118908) | QUEUED |

Critical next action: poll ASIC/config job \`138775349960\`. It must compile and pass four-DIMM 1/2/4/8-beat host write/read traffic, W-before-AW, backpressure and both negative AW/AR aperture tests. Only then check the integrated global address map and four-instance HMUX contention/ID-routing assertions. A02 and A03 are not closed.

The board-functional job \`138775349751\` has completed environment setup and is running the host-driver/board-model regression. Its log endpoint returned NOT_FOUND at the last poll; inspect job steps/state again rather than inferring a result. Other same-SHA workflows are queued as listed.

PPA remains unresolved. Run \`45455745851\` failed; artifact \`14962660456\` is 1.56 GB and should not be bulk-downloaded without a targeted extraction plan. No power, area, timing or PPA figures are accepted.

Feature-branch code checkpoint remains \`68baca...\`; documentation-only commits follow. Protected main remains \`d84db55712aba0d40811d7762cb052f05d55b7e5\`. Continue feature-branch-only, zero-spend and evidence-first.


## 13. Exact-SHA ASIC/configuration gate passed — 2026-11-25

**Code SHA under test:** `68baca1a080e952b20327c90d63a6f66c6a1ee70`.

- ASIC/config Run [45487119079](https://github.com/shamiursunny/openTPU/actions/runs/45487119079), job `138775349960`: **SUCCESS**.
- Passed steps: three integrated lint stages (ASIC control/compute, WG8 native-memory, WG8 four-DIMM AXI); four-DIMM WG8 host AXI integration simulation; global-to-DIMM address mapping simulation; four-instance host/accelerator mux contention simulation.
- Isolated 128K one-copy TMEM Run [45487119017](https://github.com/shamiursunny/openTPU/actions/runs/45487119017), job `138775350575`: **SUCCESS** on the same SHA.
- Still active at latest poll: board-functional job `138775349751` and uncovered RTL job `138775349549` (Run `45487118979`); software-core job `138775350415` (Run `45487119094`); RTL-tail job `138775349245` (Run `45487118908`). All 14 subsystem/WG8 jobs in Run `45487118947` remain queued.
- PPA remains failed/unresolved from prior Run `45455745851`; no area, timing, power or PPA claims. No production/tapeout/manufacturer readiness claim.

### Continue from here
1. Retrieve/review the complete ASIC/config job log and archived test output to capture test counts, expected-fatal aperture checks and any warnings precisely.
2. Poll board-functional and uncovered RTL; then software-core and RTL-tail; continue polling the 14 subsystem jobs. Record exact job conclusions and test counts only after logs are available.
3. Diagnose the failed WG8 PPA run separately; do not infer metrics from a failed artifact.
4. Update these three documents again after the next material result. Re-verify branch head and protected main before writes. Keep zero-spend and feature-branch-only rules.

**Readiness:** A02/A03 integrated simulation gate now passes on this exact SHA, but the overall release gate remains OPEN. Formal/CDC/RDC closure, PPA, broader regressions, production IP/PHY, package/DFT, physical signoff, board/silicon tests and commercial validation remain outstanding.



## 14. Detailed exact-SHA ASIC log findings — 2026-11-25

Reviewed full job log for [ASIC/config Run 45487119079](https://github.com/shamiursunny/openTPU/actions/runs/45487119079), job `138775349960`, exact code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`. Downloadable artifact: [sunnyone-asic-config-log](https://github.com/shamiursunny/openTPU/actions/runs/45487119079/artifacts/14964499992).

Confirmed PASS markers:
- Four-DIMM host AXI: 1/2/4/8-beat writes/reads, W-before-AW, partial/zero strobes, all BRESP/RRESP codes, 4-KiB boundary-aligned bursts, independent backpressure.
- `bad_aw` and `bad_ar`: each correctly rejected with the expected 8-GiB DIMM-aperture fatal.
- Global map: 32-GiB map, four DIMMs, two 4-GiB channels per DIMM, 4-KiB interleave, inverse bijection, out-of-aperture rejection.
- Four-DIMM HMUX contention: simultaneous host/accelerator AW/AR, alternating grants, ordered two-beat W, B/R ID routing and independent backpressure.

**New priority warning review:** Verilator reports WIDTHTRUNC in `rtl/asic/otpu_asic_wg8_ddr4_top.sv:240,245`: 34-bit selected AW/AR addresses connect to 33-bit `m_awaddr`/`m_araddr` pins. It also reports UNOPTFLAT circular combinational logic for `aok` at `rtl/top/otpu_slice.sv:906`, plus other width and unused-signal warnings. Do not suppress or dismiss these. Trace the 34-to-33-bit address contract and global map/aperture boundary; determine whether the dropped bit is provably outside the valid local address range or indicates a real truncation risk. Only edit RTL after evidence establishes the required correction. Also inspect the `aok` path structurally before changing logic.

### Next action order
1. Read `rtl/asic/otpu_asic_wg8_ddr4_top.sv` around 220–255, the host mux interface declarations, and global-to-DIMM address mapper; establish intended widths and all legal address ranges.
2. Derive a boundary table for local DIMM address maximum, AXI address width, AW35 global address and 8-GiB aperture. Add/execute tests at highest legal and first illegal addresses if missing.
3. Inspect `aok` combinational path at `otpu_slice.sv:906` and relevant handshake logic. Avoid speculative RTL edits.
4. Poll remaining exact-SHA board, uncovered RTL, software-core, RTL-tail and 14 subsystem jobs. PPA remains unresolved.

Overall release gate remains OPEN despite the A02/A03 integration simulation PASS.



## 15. Refined warning diagnosis — 2026-11-25

- Width warning source trace: `otpu_mig_pair` outputs 33-bit local addresses (`CL=32`, `NC=2`), while the intermediate mux-facing nets and `otpu_mig_hmux` are 34 bits. The top's DIMM-local contract reserves bit 33 as zero; the 33-to-34 connection is consistent with zero-extension. The bridge's 34-bit channel address is reduced to the 32-bit channel offset by `dimm()`; V1 channel size is 4 GiB and bridge PC=0. This is not a demonstrated address truncation defect, but explicit width wiring or warning-cleanup and boundary checks would make the contract clearer. Do not change RTL until needed and validated.
- UNOPTFLAT at `otpu_slice.sv:906`: `aok` is computed as a forward combinational priority chain where each group reads only lower-index grants. Source review does not show a direct cycle; this may be a packed-vector dependency warning. Keep it open for structural validation; no speculative refactor.
- No production RTL changed during this review. The integrated four-DIMM, global map, HMUX and expected-negative aperture simulations remain PASS on SHA `68baca...`.



## 16. RTL-tail exact-SHA regression completed — 2026-11-25

- Run [45487118908](https://github.com/shamiursunny/openTPU/actions/runs/45487118908), job `138775349245`, SUCCESS on code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`.
- Test summary: **33 passed, 1 skipped, 183 deselected**; duration 711.82 s. Skip reason: `PAIR needs 2M <= MCOLS; M <= ACT_ROWS`. The deselected tests were not executed in this job.
- No standalone log artifact was produced because `/tmp/sunnyone-rtl-tail.log` did not exist; job log is the available evidence.
- Still pending at latest poll: board-functional, uncovered RTL, software-core, Stream RTL, MX multiply/replay; 12 further subsystem/WG8 jobs queued.
- Continue polling exact-SHA runs. No PPA or manufacturer release conclusion changes.



## 17. Live continuation update — 2026-11-25 (post-poll)

### Verified repository state
- Feature branch: `sunnyone/commercial-profitability-architecture-2026-11-23`; live branch HEAD at the start of this update: `06766e101f5451830638705eb616291df8b4ef7b`.
- Protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5` (re-queried; unchanged).
- Compare `68baca1a080e952b20327c90d63a6f66c6a1ee70...06766e101f5451830638705eb616291df8b4ef7b`: 22 commits, all changes confined to the three SUNNYONE documentation files. No RTL/source changes occurred after the verified code SHA `68baca...`.

### Exact-SHA CI status on code SHA 68baca1a080e952b20327c90d63a6f66c6a1ee70
- ASIC/config Run [45487119079](https://github.com/shamiursunny/openTPU/actions/runs/45487119079): SUCCESS. Detailed log review confirms the four-DIMM 1/2/4/8-beat AXI cases, W-before-AW, partial/zero strobes, all BRESP/RRESP codes, 4-KiB boundary-aligned bursts, independent backpressure, both expected-fatal AW/AR aperture checks, 32-GiB global map and four-instance HMUX contention/ID routing.
- RTL-tail Run [45487118908](https://github.com/shamiursunny/openTPU/actions/runs/45487118908): SUCCESS; 33 passed, 1 parameter-inapplicable skip, 183 deselected. Deselected tests are not covered.
- Isolated 128K one-copy TMEM Run [45487119017](https://github.com/shamiursunny/openTPU/actions/runs/45487119017): SUCCESS; no verified test count recorded here.
- RTL subsystem/WG8 Run [45487118947](https://github.com/shamiursunny/openTPU/actions/runs/45487118947): 11 of 14 jobs completed SUCCESS; Address-window and Native DRAM/technology RAM remain IN_PROGRESS; Reset audit remains QUEUED. Do not call the workflow complete or infer test totals from job count.
- Remaining RTL/board Run [45487118979]: board-functional and uncovered-RTL jobs ended CANCELLED. Software-core Run [45487119094] ended CANCELLED. Their partial pytest progress is not a pass and must be rerun on a reviewed SHA with adequate runtime.

### Corrected task interpretation
- A02 four-DIMM AXI multi-beat/negative-aperture gate: PASS on exact code SHA `68baca...`.
- A03 integrated four-DIMM HMUX contention/ID-routing gate: PASS on exact code SHA `68baca...`.
- The subsystem workflow remains PARTIAL: 11 successful jobs, 2 in progress and 1 queued at the latest poll.
- The earlier short summary of “249 passing subsystem tests” is not retained as an authoritative count because a complete, reconciled per-job pytest total was not established in this continuation. Use only test counts captured from actual job logs and do not sum overlapping workflows.
- The failed PPA run [45455745851](https://github.com/shamiursunny/openTPU/actions/runs/45455745851) remains FAILED. No area, timing, power or PPA figure is accepted.

### Immediate next work
1. Poll the two remaining subsystem jobs and queued reset audit in Run 45487118947; inspect full logs and exact test summaries.
2. Re-run cancelled board-functional, uncovered-RTL and software-core suites separately or in appropriately sized jobs; avoid cancellation-driven loss of evidence.
3. Inspect the PPA failure's targeted ORFS/Yosys logs and mapping threshold behaviour; do not bulk-download the historical 1.56-GB artifact. Produce a reproducible successful research PPA flow before reporting metrics.
4. Resolve or formally disposition the WIDTHTRUNC and UNOPTFLAT warnings with explicit address-width/boundary evidence and structural analysis; do not suppress warnings.
5. Preserve feature-branch-only, zero-spend, exact-SHA evidence. Update this resume, master handoff and tracker together after each material result.

**Release decision:** simulation evidence has advanced materially, with A02/A03 passing on `68baca...`; full regression and manufacturer release gates remain OPEN. No fabrication, tapeout, physical signoff, board, silicon or commercial-performance readiness is established.


## 18. Live continuation update — 2026-11-25 (subsystem poll and PPA artifact audit)

- Subsystem workflow `45487118947`, code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`: 12/14 jobs have completed successfully. The two remaining jobs are Native DRAM and technology RAM (`138775352847`) and Reset audit (`138775353032`), both still in progress at the latest poll. Do not mark this matrix complete until both finish and their logs/test summaries are reviewed.
- PPA run `45455745851`, SHA `dc34e3a51c27c01af6296015cd206ab8336d6bda`, failed in the ORFS run step with exit code 2. The Yosys/Slang SRAM probe and preparation completed and reported 288 macros across 14 sizes, 3,538 KiB total SRAM. This is preparation evidence only, not a successful synthesis/place/route or PPA result.
- PPA artifact `14962660456` is 1,562,950,987 bytes. The available artifact-download connector rejects files above 536,870,912 bytes, so the actual `run.log` tail and detailed ORFS stage logs could not be retrieved through this route. The job log establishes only `ORFS exit 2`; exact root cause remains unverified. Do not infer a timing, congestion, mapping, memory, or tool failure without the detailed logs.
- Next: let the two remaining subsystem jobs complete and inspect their exact logs; then revise the PPA evidence collection to upload a compact failure bundle (run.log tail, failing stage logs/reports, summary and file inventory, excluding bulk result databases) before rerunning the research flow. Keep all metrics unreported until a successful reproducible run.
- Tested RTL SHA remains `68baca...`; current branch-head documentation commits are not RTL changes. Main remains protected and untouched. Release readiness remains NOT READY for fabrication/tapeout/physical signoff.


## 19. Subsystem matrix closed — exact test-summary reconciliation — 2026-11-25

- Workflow `45487118947` is now complete: all 14/14 jobs SUCCESS on RTL SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`.
- Per-job pytest summaries were extracted from all 14 job logs and reconciled: Stream 14; MX multiply/replay 17; collective hub/DMA/scoreboard 128; address-window 20 passed + 1 skipped; SPLITQ 5; wait-state 11; QST/QSTB 13; quantizer modes 15; floating point 8; quantizer corners/tie rounding 8; instruction cache 23; QHL 7; native DRAM/technology RAM 104; reset audit 4. Total: **377 passed, 1 skipped**, across these 14 distinct matrix jobs. Skip reason: 64-GiB configuration makes every address DRAM; parameter-inapplicable. No failures in this matrix.
- Three previously cancelled jobs have been requested for retry. Current latest attempt: `rtl-uncovered` in progress; `software-core` in progress; `board-functional` remains cancelled because the containing workflow attempt is active and GitHub rejected an immediate rerun. Retry board-functional after the other jobs finish. Cancellation is not a pass or test failure.
- PPA workflow diagnostics were corrected in commit `c568020d91efd045c6dd5d89dbc30ebdbac2c866`: removed full `run.log` and bulk `work/results/**` from artifact upload; retained 200-KiB run-log tail, file inventory, report copy, config/constraints, and work/logs + work/reports. Added diagnostic file-size inventory. Await the new run before deciding whether artifact size and failure cause are resolved.
- These results remain scoped to exact SHA `68baca...`; docs/CI workflow changes are not RTL verification. No PPA metric or manufacturing readiness claim.

## 20. Current continuation state — 2026-11-25

### Verified baseline
- Subsystem matrix: 14/14 jobs SUCCESS; exact summaries reconcile to 377 passed, 1 configuration-inapplicable skip, 0 failures on RTL SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`.
- A02/A03 integrated four-DIMM AXI, expected-negative aperture, global map and HMUX tests remain PASS on the same exact SHA. RTL-tail remains scoped PASS (33 passed, 1 skipped, 183 deselected). One-copy 128K TMEM job SUCCESS without an asserted count.
- Feature branch compared to tested RTL SHA is 32 commits ahead and 0 behind; changes are only the PPA workflow and project continuity docs. Protected main remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; no main-branch update was made.

### Retry state
- Board-functional job `139135578982`: IN_PROGRESS; tool installation step active, test step not yet started.
- Software-core job `139135639920`: IN_PROGRESS; tool installation step active, test step not yet started.
- Uncovered RTL latest job `139135582940`: CANCELLED; another rerun request is blocked by the active workflow attempt. Retry after board-functional completes.
- Earlier retry jobs `139003943623`, `139003968520`, and `139003945395` ended CANCELLED. These are not passes and do not establish test failures.

### PPA and warnings
- Compact evidence workflow commit: `c568020d91efd045c6dd5d89dbc30ebdbac2c866`. It excludes bulky result databases/full run.log and retains compact diagnostics. A post-repair run/result/artifact was not verified at this checkpoint. Historical run `45455745851` remains FAILED/OPEN; no PPA metrics may be stated.
- WIDTHTRUNC and UNOPTFLAT remain open for explicit width-contract and structural disposition; source review has not demonstrated a functional defect. No speculative RTL refactor was made.

### Next exact actions
1. Poll board-functional and software-core until completion; inspect full job logs and extract exact pytest summaries, failures, skips and deselections.
2. Once the board workflow is no longer active, rerun uncovered RTL and inspect its exact result.
3. Locate or dispatch the post-repair PPA workflow run; inspect artifact size, image digest, ORFS run tail, stage logs and reports. No PPA metrics until successful reproducible flow.
4. Update the three continuity documents after every material result; retain exact SHA boundaries and do not sum overlapping test jobs.
5. Keep final full regression on one immutable candidate SHA as a release gate.

**Release decision remains NOT READY** for fabrication, tapeout, physical signoff, production-board build or silicon qualification.


## 21. Latest continuation checkpoint — WG8 PPA failure diagnosis — 2026-11-25

### PPA execution and exact evidence
- The compact-evidence workflow **did execute**: [run 45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546), job `138974661431`, FAILED with ORFS exit 2. Do not confuse this with the older PPA run `45455745851`.
- Artifact `14997807086` downloaded (221,016 bytes; SHA-256 `bb087bae1049d8364d83f766279a1d77a9f289c3d2747bcb5f796a17fa75d118`). ORFS container image digest: `sha256:9d227293bf57b9d84c63aa8551faa0487d30db456b254b8f244a1e40244f66af`.
- Synthesis and floorplan completed. Failure occurred at ORFS stage `2_4_floorplan_pdn`, `check_placement -fixed -verbose`, Make error 247 / exit 2. The log says 11 setup endpoints violated and timing repair could not repair all. Preliminary floorplan JSON: setup WNS `-10.4346 ns`, setup TNS `-91.4594 ns`. The same report says no estimated parasitics and uses wire-load models. PDN logs contain repeated PDN-0110 no-via-insertion warnings between metal6 and metal7 at VDD coordinates.
- These numbers are only early floorplan diagnostics; they are **not final PPA or signoff metrics**. No global placement, CTS, detailed route, final timing or physical signoff completed. Do not report floorplan area/power estimates as chip metrics. SRAM prep still counts 288 generated/fake macros in 14 sizes (3,538 KiB), not validated foundry macros.

### Regression retry state
- Board-functional job `139135578982`: IN_PROGRESS at host driver/board-model regression step; no test result yet.
- Software-core job `139135639920`: IN_PROGRESS at core ISA/compiler/kernels/numerics/host software step; no test result yet.
- Uncovered RTL job `139135582940`: CANCELLED. Retry after the board workflow settles and GitHub permits it.
- Existing verified baseline remains 377 passed, 1 configuration-inapplicable skip, 0 failed across 14 subsystem jobs on tested RTL SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`. Keep that baseline separate from the active jobs.

### Branch / action constraints
- Feature HEAD `264a3d8de4d06c2be5ca5055dd82c2d4c9635ef9` is 35 commits ahead / 0 behind tested RTL SHA; compare confirms only `.github/workflows/sunnyone-asic-wg8-ppa.yml` and the three continuity documents changed. Main remains `d84db55712aba0d40811d7762cb052f05d55b7e5` and untouched.
- The PPA YAML contains `workflow_dispatch`, but the connected GitHub toolset has no dispatch write operation. Do not claim manual dispatch; the linked run above is the confirmed push-triggered post-repair run.

### Immediate next steps
1. Diagnose PDN `check_placement` error and the metal6/metal7 VDD via warnings using the captured stage logs/reports.
2. Review the 11 setup-critical endpoints and constraints; no speculative RTL edits.
3. Poll board-functional and software-core until terminal; extract exact test summaries and failure/skip/deselection data.
4. Retry uncovered RTL when the workflow is no longer active.
5. Rerun full PPA after evidence-backed fixes and require complete flow plus final inspectable reports before accepting PPA metrics.
6. Keep manufacturer release NOT READY until all physical, PHY, DFT, package, board, timing, power, thermal and silicon gates are independently satisfied.


## 22. CI workflow scheduling optimisation checkpoint — 2026-11-25

### Why the Actions list appeared to run in parallel and stall
- Fifteen project-specific workflow files existed. Broad push filters overlap across `rtl/**`, `opentpu/**` and `sim/verilator/**`, so one commit can trigger multiple distinct test suites. Each independently provisions tools and consumes a hosted runner.
- The subsystem matrix has 14 groups with `max-parallel: 2`, deliberately limiting concurrency. Other workflows can run simultaneously, adding queue pressure. The six-hour WG8 PPA workflow was also push-triggered by broad RTL paths, despite being an expensive physical-design investigation currently failing at floorplan PDN placement.
- Different pass/fail statuses are expected when suites exercise different components or environments. Parallel execution itself does not establish the cause of a failure.

### Changes made on the feature branch
- All 15 `.github/workflows/sunnyone-*.yml` workflows now have concurrency groups keyed by workflow name and branch, with `cancel-in-progress: true`. A newer commit cancels only an older run of that same workflow/branch.
- WG8 PPA is now `workflow_dispatch` only, removing its automatic push trigger. Dispatch manually after the functional and ASIC gates are green and the candidate SHA is frozen.
- Existing test commands, path filters, matrix groups, failure reporting and artifacts are preserved. No tests were removed, hidden or made continue-on-error.
- The matrix remains `max-parallel: 2`; increasing it without runner-capacity evidence risks more contention.

### Validation status
- Workflow source edits are committed together as one commit to avoid triggering one workflow update at a time.
- The new YAML has not yet been exercised by a subsequent GitHub Actions run. Confirm syntax and behaviour from the next push-triggered runs before considering the scheduling change fully validated.
- No quantified runtime reduction is claimed yet.

### Next
1. Verify only suites whose path filters match are triggered.
2. Confirm a newer commit cancels superseded runs of the same workflow without cancelling other suites.
3. Confirm WG8 PPA does not auto-run on ordinary RTL pushes and remains available through Actions → Run workflow.
4. Measure queue time and duration; adjust only if evidence shows a remaining bottleneck.
5. Keep functional test outcomes and PPA failure diagnosis separate from CI scheduling status.


## 23. AXI-Lite control testbench assertion correction — 2026-11-25

The post-CI-policy run `45598047228` exposed a testbench status expectation mismatch: `sim/asic/tb_asic_ctrl.sv:55` expected `0x6c`, while the DUT returned `0x6e`. Decoding `otpu_asic_ctrl.sv` shows status bit 1 is sticky `ctrl_error` and bit 2 is `ld_busy | load_inflight`. The preceding deliberately rejected LOAD while `wr_idle=0` sets the sticky error; the test later accepts LOAD without clearing that error. The RTL output is therefore consistent with the test sequence. Updated the testbench expectation to `0x6e` and clarified the comment; test-only commit `cf0d4d3c211b481ae3ade391078731d2e476877b`. Rerun `45598244519` / job `139149936465` is currently IN_PROGRESS during Icarus installation. Await the completed log before recording PASS.


## 24. AXI-Lite control rerun verified — PASS — 2026-11-25

Corrected testbench run [45598244519](https://github.com/shamiursunny/openTPU/actions/runs/45598244519), job `139149936465`, completed SUCCESS. Exact log marker: `PASS: ASIC AXI-Lite control, independent AW/W, gating, load pulse, reset, register map`. Testbench-only expected status correction `0x6c` → `0x6e` reflects the sticky control-error bit after the deliberate rejected LOAD. No RTL source changed.


## 25. WG8 PPA trigger correction — 2026-11-25

A GitHub documentation check found that `workflow_dispatch` requires the workflow file to exist on the repository's default branch. The WG8 PPA workflow is feature-branch-only and `main` is deliberately untouched, so a manual UI button cannot be relied upon. The workflow now uses a narrow push path filter for the exact Nangate45 target source set, ASIC top, target/tool configuration and `docs/sunnyone/PPA_REQUEST.md`. Broad `rtl/**` was removed, and the workflow file itself is excluded from the filter to prevent self-trigger loops. `workflow_dispatch` remains for future use when the workflow is on the default branch / repository dispatch supports it. The marker currently says NONE; update it with candidate SHA and reason only after functional/ASIC gates pass. No PPA run was triggered by creating the marker or editing the workflow because neither path was in the preceding filter.


## 26. Latest CI continuation checkpoint — 2026-11-25

### Completed
- RTL tail run [45598047232](https://github.com/shamiursunny/openTPU/actions/runs/45598047232), job `139149245841`, SUCCESS on source SHA `36104fdaacabcba39ba4a7daa74b7fb19ce31536`.
- Exact result: **33 passed, 1 skipped, 183 deselected in 742.68s (12m 22s)**. Skip reason: `PAIR needs 2M <= MCOLS; M <= ACT_ROWS`.
- In the 14-group subsystem matrix, six groups had completed SUCCESS at the latest poll: Stream RTL, Quantizer modes, Quantizer corners/tie rounding, SPLITQ, QHL, and MX multiply/replay. QST/QSTB and floating-point remained in progress; the other groups remained queued.

### CI defect identified
The RTL-tail upload-artifact step was green but the log explicitly states no file was found at `/tmp/sunnyone-rtl-tail.log`. The pytest command must write its output there. Correct after the current active runs finish, using `set -o pipefail` and `pytest ... 2>&1 | tee /tmp/sunnyone-rtl-tail.log`, then confirm a real artifact upload. Do not mistake green upload step for artifact existence.

### Still pending at this checkpoint
- Core software/ISA run `45598047393` — IN_PROGRESS.
- Remaining RTL and board run `45598047324` — both jobs IN_PROGRESS.
- Subsystem matrix `45598047338` — two jobs IN_PROGRESS and remaining groups queued.

Do not trigger a new branch commit until these runs complete unless a critical fix is required, because matching workflow path filters may cancel superseded runs. Keep PPA deferred and manufacturer readiness NOT READY.


## 27. RTL-tail log artifact fix and current Actions checkpoint — 2026-11-25

- Corrected `.github/workflows/sunnyone-rtl-tail.yml` in commit `4a1eb21ea31749fff6c2b12b51472123a2540a59`: pytest now writes its console output to `/tmp/sunnyone-rtl-tail.log` using `tee`; Bash `set -o pipefail` ensures pytest's nonzero exit is not masked by tee.
- Validation run [45604384259](https://github.com/shamiursunny/openTPU/actions/runs/45604384259) is IN_PROGRESS. Verify its final log and actual artifact before closing the issue.
- Last verified RTL-tail regression run [45598047232](https://github.com/shamiursunny/openTPU/actions/runs/45598047232): 33 passed, 1 skipped, 183 deselected in 742.68 seconds; job passed but artifact was missing.
- At latest poll, software-core `45598047393` and RTL/board `45598047324` remain IN_PROGRESS; subsystem matrix `45598047338` has six SUCCESS groups, two IN_PROGRESS and six QUEUED. These runs target SHA `36104fda` and must be assessed separately from the workflow-only logging fix.
- No RTL changes. Keep PPA deferred; manufacturer readiness NOT READY.


## CI logging repair correction — 2026-11-25

The first logging-repair validation run [45604384259](https://github.com/shamiursunny/openTPU/actions/runs/45604384259) FAILED before tests started. Exact error: `ERROR: file or directory not found: \\\\\\\\ `; the YAML continuation was over-escaped, causing pytest to interpret a literal backslash as a test path. No tests ran, and no artifact was created. This was a workflow-command quoting defect, not an RTL regression.

Corrected the step to a single-line pytest pipeline with `set -o pipefail` and `tee /tmp/sunnyone-rtl-tail.log` in commit `e0eea98ba00e65ca42b785bc6133a5679529506b`. New validation run [45604527541](https://github.com/shamiursunny/openTPU/actions/runs/45604527541) is IN_PROGRESS. Verify both pytest outcome and actual artifact upload before closing the issue. Do not treat run 45604384259 as a test result.



## 28. Latest verified continuation checkpoint — 2026-11-25

### Repository and branch (re-fetched)
- Correct repository: https://github.com/shamiursunny/openTPU (fork of https://github.com/FeSens/openTPU).
- Active feature branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Pre-documentation-update branch HEAD: `f51dc234aaf5b4e7d9b61a2e45768d315a5dcd81`.
- Protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5`; unchanged.
- This continuation is restricted to the feature branch. Do not modify main.

### New verified results
- RTL-tail artifact repair run [45604527541](https://github.com/shamiursunny/openTPU/actions/runs/45604527541), job `139171823473`, SHA `e0eea98ba00e65ca42b785bc6133a5679529506b`: SUCCESS. Downloaded artifact `sunnyone-rtl-tail-log` (ID `15018530071`) and read its log: **33 passed, 1 skipped, 183 deselected in 635.12s**. The single skip is the existing parameter guard `PAIR needs 2M <= MCOLS; M <= ACT_ROWS`. Artifact capture is now verified, not merely inferred from a green upload step.
- The first attempt [45604384259](https://github.com/shamiursunny/openTPU/actions/runs/45604384259) failed before tests because the YAML command was over-escaped. It ran zero tests; corrected by single-line pytest/tee/pipefail command in `e0eea98...`.
- AXI-Lite control run [45598244519](https://github.com/shamiursunny/openTPU/actions/runs/45598244519), job `139149936465`: SUCCESS after testbench status expectation was corrected to reflect the sticky control-error bit. No RTL changed.
- Reset/power-up audit, full-chip lint, global address-map formal, virtual DRAM, workload harness, isolated TMEM, PCIe Gen2, HMUX simulation and ASIC configuration have scoped successful runs. See PROJECT_TRACKER.md Section 150 for exact IDs and boundaries.

### Current outstanding Actions
- Subsystem/memory matrix Run [45598047338](https://github.com/shamiursunny/openTPU/actions/runs/45598047338): 13/14 jobs SUCCESS; Native DRAM/technology RAM job `139149249337` remains IN_PROGRESS at last poll. Poll and inspect this job before closing the matrix.
- Software-core Run [45598047393](https://github.com/shamiursunny/openTPU/actions/runs/45598047393): CANCELLED.
- Remaining RTL/board Run [45598047324](https://github.com/shamiursunny/openTPU/actions/runs/45598047324): CANCELLED.
- Retry software-core once, wait for terminal status, then retry remaining RTL/board once. Do not launch both broad suites together. Reuse successful suite evidence only where exact source SHA and scope match; do not transfer results across commits.
- WG8 PPA Run [45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546) failed at ORFS floorplan-PDN placement checking. PPA is deferred; no final area/timing/power result exists.

### Execution policy (keep)
Run focused checks first, then one broad suite at a time. Keep subsystem matrix max-parallel=2; per-workflow concurrency cancels only superseded runs of the same workflow/ref. PPA is a deliberate separate gate. Never weaken tests or suppress warnings to get green. Record commit SHA, run/job IDs, exact pass/skip/fail/deselected counts and artifacts.

### Next action
Poll job `139149249337` to terminal, inspect the pytest log/artifact, and update all three continuity documents with its exact result. Then execute software-core and remaining RTL/board sequentially. Manufacturer readiness remains NOT READY.



## 29. Continuation poll — Native DRAM runtime risk — 2026-11-25

The active subsystem matrix [45598047338](https://github.com/shamiursunny/openTPU/actions/runs/45598047338) still has 13/14 jobs successful; Native DRAM/technology RAM job `139149249337` remains IN_PROGRESS. Its test step is still active; no final result or artifact is available. The run has not been marked complete.

Inspection of the workflow and test harness found an aggregate-runtime risk: the Native DRAM test helper allows up to 1,800 seconds per simulator invocation, but the entire Native DRAM plus technology RAM matrix group has a 45-minute job timeout. This does not prove a hang. Wait for the current job's terminal result; do not change the active workflow mid-run.

Once terminal, partition the Native DRAM suite into smaller logical jobs and run technology RAM separately without removing or weakening tests. Then rerun cancelled software-core job `139149247780` and cancelled RTL/board jobs `139149245874` and `139149246459` sequentially, waiting for each terminal result. Keep the branch feature-only and preserve exact-SHA evidence. Manufacturer handoff remains NOT READY.


## 30. Live continuation checkpoint and next-state contract — 2026-11-25

### Repository state
- Correct repository: https://github.com/shamiursunny/openTPU.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Feature HEAD before this docs-only checkpoint: `db16fea6a7f39d29be62e4606842d3d24482520c`.
- Protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5`; unchanged. Keep all work on the feature branch.
- Active software-core and completed subsystem runs use source SHA `36104fdaacabcba39ba4a7daa74b7fb19ce31536`. A docs-only update does not alter the already-running job's source.

### Completed evidence
- Subsystem/memory matrix [45598047338](https://github.com/shamiursunny/openTPU/actions/runs/45598047338): **14/14 jobs SUCCESS**, source SHA `36104fdaacabcba39ba4a7daa74b7fb19ce31536`; reconciled total **377 passed, 1 configuration-inapplicable skip, 0 failures**.
- Native DRAM + technology RAM artifact `sunnyone-subsystems-12-log`, ID `15020003974`, downloaded and inspected: **104 passed in 1,829.20 seconds (30m29s)**.
- RTL-tail [45604527541](https://github.com/shamiursunny/openTPU/actions/runs/45604527541), SHA `e0eea98ba00e65ca42b785bc6133a5679529506b`: **33 passed, 1 skipped, 183 deselected in 635.12s**; artifact inspected.
- AXI-Lite [45598244519](https://github.com/shamiursunny/openTPU/actions/runs/45598244519): SUCCESS on its own exact testbench SHA. No RTL change for the sticky-error status expectation correction.
- Other focused successes remain bound to their recorded SHA and scope. Do not sum overlapping suites or call them one consolidated full-chip pass.

### Outstanding queue — do not skip order
1. Software-core retry [45598047393](https://github.com/shamiursunny/openTPU/actions/runs/45598047393), attempt 2, job `139201961395`: IN_PROGRESS at the core ISA/compiler/kernels/numerics/host software test step. Setup and dependency installation completed. Poll to terminal, inspect full logs/artifacts, and record exact counts.
2. Remaining RTL/board [45598047324](https://github.com/shamiursunny/openTPU/actions/runs/45598047324): prior jobs `139149245874` and `139149246459` are CANCELLED. Retry uncovered RTL first and board-functional second only after software-core settles; wait and inspect each result.
3. Classify any failure from evidence; preserve all tests/assertions and avoid broad parallel retries.
4. Update these three continuity files after terminal results, then freeze a single candidate SHA for consolidated regression.

### Next state after this queue is complete
The next durable checkpoint must contain:
- terminal outcome and exact test summary for software-core;
- terminal outcome and exact test summary for uncovered RTL;
- terminal outcome and exact test summary for board-functional;
- artifact IDs and inspected-log evidence for each applicable job;
- a reconciled candidate SHA, branch HEAD and unchanged main SHA;
- explicit list of remaining failures, warnings, exclusions and unverified requirements.

After that, move to consolidated candidate regression and formal/protocol/lint closure; then investigate the WG8 ORFS floorplan-PDN failure [45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546). No final PPA metrics are accepted. Continue PHY/IP, DDR, PCIe, DMA/IOMMU, CDC/RDC, DFT, SRAM macro, physical, package, electrical, thermal, power and silicon qualification. The end of the current CI queue is not the end of the chip-design project.

### Execution guardrails
- Feature branch only; never update `main`.
- Wait for each broad suite to finish before launching the next.
- Do not treat CANCELLED, skipped, queued, or missing artifacts as PASS.
- Preserve exact source SHA, job IDs, artifact IDs and log-derived counts.
- Never weaken tests or suppress warnings to manufacture green status.
- Zero-spend unless the user explicitly authorises expenditure.
- Manufacturer readiness remains **NOT READY**.



## 31. Latest continuation checkpoint — 2026-11-25

### Live verified state
- Repository: https://github.com/shamiursunny/openTPU.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`; feature-branch-only changes. Latest recorded pre-refresh checkpoint was `db16fea6a7f39d29be62e4606842d3d24482520c`. Protected `main` remains recorded at `d84db55712aba0d40811d7762cb052f05d55b7e5`; no main-branch write was made.
- Current broad regression source SHA: `36104fdaacabcba39ba4a7daa74b7fb19ce31536`.
- Subsystem/memory matrix [45598047338](https://github.com/shamiursunny/openTPU/actions/runs/45598047338): re-polled **14/14 jobs SUCCESS**. Reconciled result: **377 passed, 1 configuration-inapplicable skip, 0 failures**. Native DRAM + technology RAM is 104 passed and already included in 377.
- Software-core [45598047393](https://github.com/shamiursunny/openTPU/actions/runs/45598047393), job `139201961395`: still IN_PROGRESS at the main pytest step. No final count or artifact. The job uses a 45-minute timeout. Do not launch another broad suite until it is terminal.
- Previous RTL/board attempt [45598047324](https://github.com/shamiursunny/openTPU/actions/runs/45598047324): both `rtl-uncovered` and `board-functional` jobs are CANCELLED, with no usable test results.

### Required execution order
1. Poll software-core to terminal and inspect logs/artifacts; capture exact counts and tested SHA.
2. Retry RTL-uncovered once, sequentially; inspect its final evidence.
3. Retry board-functional once after RTL-uncovered settles; inspect its final evidence.
4. Diagnose any timeout/failure from logs and source. If runtime requires partitioning, split the same tests into bounded jobs without deleting or weakening tests/assertions.
5. Update this resume, the manufacturer handoff register and PROJECT_TRACKER.md with the same exact evidence.
6. Freeze one immutable candidate SHA, then perform consolidated regression and close remaining formal/protocol/lint/integration gates.

### Do not do
- Do not rerun the successful 14-job subsystem matrix without a source/environment reason.
- Do not add 104 Native DRAM tests again to the 377 total.
- Do not count cancelled, running, skipped or artifact-less jobs as passes.
- Do not overlap broad software-core, RTL-uncovered and board-functional suites.
- Do not start PPA until prerequisite functional/ASIC gates are green; the earlier ORFS floorplan-PDN failure remains unresolved.
- Do not claim manufacturer readiness. PCIe/DDR PHY, DMA/IOMMU, production SRAM, CDC/RDC, DFT, physical design/signoff, package, board electrical, power/thermal and silicon validation remain open.
- Maintain zero-spend unless the user explicitly authorises expenditure.

**Manufacturer readiness: NOT READY.** Completing this CI queue is a verification milestone, not completion of SUNNYONE AI-X.


## 32. Software-core timeout diagnosis and next execution plan — 2026-11-25

### Latest verified software-core attempt
- Run [45598047393](https://github.com/shamiursunny/openTPU/actions/runs/45598047393), job `139201961395`: terminal **CANCELLED**.
- Retrieved full job log: pytest started 12:23:46 UTC and was cancelled 13:08:28 UTC, approximately 44m42s later, during the main test step. The progress indicator had reached 43%. Setup, checkout, Verilator install and dependency install succeeded. There is no terminal pytest summary; do not infer pass/fail counts.
- This matches the 45-minute configured job budget and is treated as a runtime/scheduling failure, not an assertion failure.

### Corrective workflow change
- Commit: `38377909bf68e3aa6102efac6c56b832675d44d4`.
- File: `.github/workflows/sunnyone-software-core.yml`.
- The exact same 15 modules are now separate matrix jobs, strictly serial (`max-parallel: 1`), fail-fast disabled, with a 45-minute timeout per module, verbose pytest output and one always-uploaded log artifact per module.
- Preserved complete module selection: test_isa, test_compiler, test_kernels, test_quant, test_formats, test_vops, test_fp, test_mx, test_stream, test_dataflow, test_waits, test_waitw, test_host, test_host_lock, test_host_runs.
- No RTL, test file, test assertion or coverage selection was modified. Workflow correction is not yet validated until the newly triggered run is inspected.

### Next execution order
1. Find the push-triggered workflow run for commit `38377909bf68e3aa6102efac6c56b832675d44d4`; verify matrix jobs are executing one at a time.
2. Inspect each module's terminal conclusion, pytest summary and uploaded log. Do not mark software-core PASS until all 15 modules succeed.
3. If any single module times out, inspect its verbose log and split only that module's tests into smaller selections, preserving all tests/assertions.
4. After all software-core modules pass, run RTL-uncovered once; then board-functional once, sequentially.
5. Reconcile exact SHA, run/job/artifact IDs and counts in all continuity documents; freeze a candidate for consolidated regression.
6. Manufacturer readiness remains **NOT READY**; PPA, physical/IP/PHY and qualification gates remain outstanding.


## 33. Serial software-core retry live result — 2026-11-25

- New validation run: [45622326985](https://github.com/shamiursunny/openTPU/actions/runs/45622326985), workflow commit `38377909bf68e3aa6102efac6c56b832675d44d4`.
- 15 matrix module jobs are present. Re-poll: 1 SUCCESS, 1 IN_PROGRESS, 13 QUEUED; only one module executes at a time as configured.
- First module `tests/test_isa.py`, job `139233449899`: **18 passed in 0.13s**. Log artifact `sunnyone-software-core-0-log`, ID `15024379354`, uploaded and pytest summary inspected.
- Current active module at last poll: `tests/test_compiler.py`, job `139233450657`.
- The new workflow's serial scheduling and per-module artifact capture have passed their first live check. Do not mark software-core complete; 14 modules still need terminal evidence. Continue polling this run and record every module's exact counts and artifact ID.


## 34. Current live continuation state — 2026-11-25 (Asia/Dhaka)

### Repository
- Repository: https://github.com/shamiursunny/openTPU
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
- Protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5` (do not modify).
- Software-core workflow source commit: `38377909bf68e3aa6102efac6c56b832675d44d4`.
- Before the documentation writes in this checkpoint, the branch was six commits ahead of the workflow source commit. The checkpoint added continuity-document updates and a branch-accounting correction; all intervening changes are documentation-only. No RTL, test or workflow changes were made. Always re-check the live branch tip before the next execution.

### Current run
Open [GitHub Actions run 45622326985](https://github.com/shamiursunny/openTPU/actions/runs/45622326985).

The run has 15 serial module jobs. Latest poll: 5 SUCCESS, 1 IN_PROGRESS, 9 QUEUED. Five completed logs have been read:
- ISA: 18 passed (job `139233449899`, artifact `15024379354`)
- Compiler: 44 passed (job `139233450657`, artifact `15026211469`)
- Kernels: 46 passed (job `139233450577`, artifact `15026436432`)
- Quant: 81 passed (job `139233450565`, artifact `15027565119`)
- Formats: 13 passed (job `139233450333`, artifact `15027510239`)

Subtotal: **202 passed; 0 reported failures; 0 reported skips** across these five module logs. Current active job: VOPS `139233450456`. Its live log may return BlobNotFound until the job is terminal; do not interpret this as a failure.

### Resume protocol — follow this order
1. Poll run `45622326985`; inspect every module's terminal job status, full pytest log and artifact. Do not mark software-core complete until all 15 succeed.
2. After software-core closes, run RTL-uncovered once and inspect it.
3. Then run board-functional once and inspect it.
4. Diagnose any real failure from source and logs; preserve assertions and test selection.
5. Update all three continuity documents with exact source SHA, run/job/artifact IDs, counts, cancellations, skips and limitations.
6. Freeze a candidate SHA and complete the appropriate consolidated regression.
7. Only after functional/ASIC prerequisites close, resume the WG8 PPA diagnosis. The previous ORFS floorplan-PDN placement failure remains unresolved and no accepted PPA metrics exist.

### Current project status
The logical V1 candidate is defined, but the full design is not tapeout-ready. Manufacturer handoff remains **NOT READY**. PCIe/DDR PHY and controller IP, DMA/IOMMU, CDC/RDC, DFT, PDK/package, physical implementation, board electrical tests, real-hardware performance/power/thermal measurements, silicon qualification and commercial validation remain outstanding. Maintain zero-spend without explicit approval and never change `main`.


## 35. Current continuation checkpoint — serial software-core retry (2026-11-25, Asia/Dhaka)

Repository: [shamiursunny/openTPU](https://github.com/shamiursunny/openTPU). Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`. Do not modify protected `main` (last verified SHA `d84db55712aba0d40811d7762cb052f05d55b7e5`).

Open [Actions run 45622326985](https://github.com/shamiursunny/openTPU/actions/runs/45622326985), workflow commit `38377909bf68e3aa6102efac6c56b832675d44d4`. The 15-module software-core matrix is strictly serial. Latest poll: **10 SUCCESS, 1 IN_PROGRESS, 4 QUEUED, 0 failed/cancelled**. Active job: waits `139233450429`; queued: waitw, host-runs, host-lock and host.

Inspected completed pytest logs (all passed-only): ISA 18; compiler 44; kernels 46; quant 81; formats 13; VOPS 101; FP 12; MX 32; stream 46; dataflow 27. Total **420 passed, 0 reported failures, 0 reported skips** across ten completed modules. Artifact IDs in the same order: `15024379354`, `15026211469`, `15026436432`, `15027565119`, `15027510239`, `15030235221`, `15029541963`, `15029542120`, `15032330134`, `15029769939`. The waits module and four queued modules contribute no counts. Do not mark software-core PASS until all 15 jobs succeed and logs are inspected.

Next steps: (1) poll the existing run to terminal; (2) inspect every remaining job log and artifact; (3) run RTL-uncovered once; (4) run board-functional once after RTL-uncovered settles; (5) reconcile exact SHA/run/job/artifact/count evidence in all three documents; (6) freeze candidate and run required consolidated regression. Do not start duplicate broad workflows or touch watched RTL/test/workflow paths during this run. Zero-spend; feature branch only. Manufacturer readiness remains **NOT READY**; PPA floorplan/PDN, production PHY/IP, physical signoff, board, silicon and commercial gates remain open.


## 36. Current continuation state — software-core and WAITC retry (2026-11-25, Asia/Dhaka)

### Verified repository state
- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Protected `main` is not to be modified; recorded SHA remains `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Tracker evidence is current through commit `d7aefdf27d9aaad1e59288df3846b5153221a924`; the handoff update follows on this feature branch.
- WAITC retry workflow added at `37d2f78eef227275347f58b39fcab69916cdd60f`: `.github/workflows/sunnyone-waits-retry.yml`.

### Software-core result
Run [45622326985](https://github.com/shamiursunny/openTPU/actions/runs/45622326985) completed **14/15 module jobs successfully**. Inspected logs total **557 passed, 1 skipped, 0 reported failures** across the successful modules. The skip is `tests/test_host.py` model coverage because `models/LFM2.5-230M` was not downloaded. Exact job and artifact IDs are in tracker section 158.

WAITC job `139233450429` was cancelled at approximately 44m36s and 84% pytest progress. Its partial artifact is `15034188015`; there is no terminal pytest summary, so it contributes no test count. Do not treat it as a pass or an assertion failure.

### Next action — do not reorder
1. Verify the new WAITC retry Actions run triggered by tracker commit `d7aefdf27d9aaad1e59288df3846b5153221a924`.
2. Inspect the general group (`tests/test_waits.py -k 'not test_waitc_rtl_follow'`) and its log/artifact.
3. Inspect the RTL FOLLOW group (`tests/test_waits.py -k 'test_waitc_rtl_follow'`) and its log/artifact. It must include all four parameter cases.
4. Only if both groups pass, close software-core and run the remaining RTL-uncovered selection once.
5. After RTL-uncovered settles, run board-functional once. Inspect complete logs and artifacts.
6. Reconcile tracker, handoff and resume to the same exact tested SHA and evidence; freeze a candidate and complete consolidated regression.

### Constraints and readiness
- Do not rerun the successful subsystem matrix (14/14, 377 passed, 1 configuration-inapplicable skip) without a source/environment reason; do not double-count the 104 Native DRAM/RAM tests already included.
- Do not overlap broad suites or repeat successful modules unnecessarily.
- No tests/assertions are removed or weakened. Preserve exact-SHA evidence.
- No paid services or hardware purchases without explicit approval.
- Manufacturer readiness remains **NOT READY**. PCIe/DDR PHY/controller, DMA/IOMMU, CDC/RDC, DFT, production SRAM, PDK/package, physical signoff, board electrical, measured performance/power/thermal, silicon and commercial qualification remain open.


## 37. Latest continuation checkpoint — WAITC PASS (2026-11-25, Asia/Dhaka)

### Verified latest test evidence
- WAITC retry run: [45641472720](https://github.com/shamiursunny/openTPU/actions/runs/45641472720).
- Tested SHA: `d7aefdf27d9aaad1e59288df3846b5153221a924`.
- General WAITC job `139300967172`: 264 passed, 2 skipped, 4 deselected; artifact `15035927377`.
- RTL FOLLOW job `139307879702`: all four cases passed (`[2-sim]`, `[4-board]`, `[4-wg]`, `[4-wg_se1]`); artifact `15038143201`.
- WAITC total: **268 passed, 2 skipped, 0 failures**. Both skips are PyTorch-dependent imports in other test modules; the complete WAITC selection has no skipped WAITC tests.
- Software-core aggregate across non-overlapping evidence: **825 passed, 3 skipped, 0 reported failures**. The old run 45622326985 remains historically cancelled; WAITC is closed by the separate retry.

### Latest documentation commits
- Tracker: `702e1ce3b8bf6490bff21bec091430801027896a`.
- Manufacturer handoff: `5413456d5e7083ae47e918b68a98b1f1a2143697`.
- This resume update follows these sequentially on the same feature branch.

### Immediate next steps
1. Retry the one-line `needs: rtl-uncovered` dependency in `.github/workflows/sunnyone-rtl-functional.yml`. The previous GitHub Contents API update was rejected (HTTP 409: repository rule validation timed out); a subsequent read verified the workflow remained unchanged. Do not assume serialization is fixed.
2. After the workflow edit is committed, verify the YAML and wait for RTL-uncovered to finish. Inspect the full log, pytest terminal summary, and artifact.
3. Board-functional must run only after RTL-uncovered passes. Inspect its full log and artifact.
4. If any suite fails, classify and diagnose without removing/weakening tests. Do not proceed to consolidated regression until both sequential stages pass.
5. Update tracker, handoff and resume to the exact tested SHA and evidence; then complete the consolidated regression.
6. Keep PPA deferred until functional and ASIC prerequisites are closed.

### State and guardrails
- Software-core: PASS for observed module coverage (825 passed, 3 skipped, 0 reported failures).
- Subsystem/memory: 14/14 successful, 377 passed, 1 configuration-inapplicable skip; no rerun needed absent source/environment change.
- RTL-uncovered: PENDING.
- Board-functional: PENDING.
- Consolidated regression: PENDING.
- PPA/manufacturer readiness: NOT READY.
- Feature branch only; preserve protected main. No expenditure or hardware purchase without explicit approval. Never claim silicon/tapeout readiness from simulation-only results.


## 38. Latest continuation checkpoint — serial CI fixes (2026-11-25)

### Completed workflow fixes
1. .github/workflows/sunnyone-waits-retry.yml is now manual-dispatch only; tracker edits no longer retrigger WAITC. Commit 639e1ce7f2d590276cb979286eb7adb20eaadcb3.
2. .github/workflows/sunnyone-rtl-functional.yml now gates board-functional on rtl-uncovered. Commit ebce653e73a378adce6dde60939cb1e052077862.
3. Current RTL-tail workflow was checked: the old literal-backslash pytest invocation that caused run 45604384259 to exit 4 with no tests collected is corrected. Later retry 45604527541 succeeded.

### Live runs and evidence rules
- Active RTL/board run: 45649502094, exact SHA ebce653e73a378adce6dde60939cb1e052077862; at last poll only RTL job 139329804556 was running. Board job must wait for RTL success. Inspect terminal pytest summary and full logs before updating status.
- Accidental duplicate WAITC run: 45649007571, general job 139327989931 still in progress at last poll. Connected controls expose no cancel action. Do not count it; authoritative WAITC evidence remains run 45641472720 (268 passed, 2 skipped, 0 failures).
- Do not repeat already-passed suites without source/environment cause. Keep serial execution and exact-SHA accounting.

### Next actions
1. Poll run 45649502094; inspect RTL logs/artifact and wait for its gated board job.
2. If RTL fails, diagnose from exact log and make a minimal fix without weakening tests; rerun only the affected selection.
3. If RTL passes, inspect board logs/artifact; then plan consolidated regression.
4. Update all three continuity files only with observed results. Keep consolidated regression/PPA/manufacturer gates pending until evidenced.
5. Preserve feature branch; protected main remains untouched; no paid services or hardware purchases without approval.


## 39. Latest resume checkpoint — RTL/ISA pytest in progress (2026-11-25, Asia/Dhaka)

- Live RTL/board workflow: [run 45649502094](https://github.com/shamiursunny/openTPU/actions/runs/45649502094), exact SHA `ebce653e73a378adce6dde60939cb1e052077862`.
- RTL job `139329804556`: checkout, Python setup, pinned Verilator 5.044 build and dependency installation are SUCCESS; selected core RTL/ISA pytest step is IN_PROGRESS. No test summary or new counts are verified.
- Board-functional is serially gated behind RTL and has not started. Do not manually trigger it.
- Active log retrieval returned GitHub storage `BlobNotFound`; while the job is running this is not evidence of failure. Re-fetch logs after the job reaches a terminal state.
- Duplicate WAITC run `45649007571` remains in progress and is not authoritative. Keep the completed WAITC run `45641472720` as the sole source of WAITC evidence.
- Existing aggregate baselines remain software-core 825 passed, 3 skipped and subsystem/memory 377 passed, 1 configuration-inapplicable skip. No counts have been added.
- Next actions: poll RTL to terminal; inspect full logs and artifacts; on success verify board starts only afterward and inspect its terminal summary; on failure isolate and fix the confirmed cause without reducing tests. Then update all three files again with the actual outcome. Consolidated regression and production gates remain open; manufacturer readiness NOT READY.


## Latest continuation checkpoint — 2026-11-25 (Asia/Dhaka)

Read this section together with the latest Section 162 of `PROJECT_TRACKER.md` and the latest continuation reconciliation in `SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md`.

**Active branch:** `sunnyone/commercial-profitability-architecture-2026-11-23`. **Protected main:** `d84db55712aba0d40811d7762cb052f05d55b7e5` (re-verify before any future write; never modify main).

### Current verified regression state
- Software-core: **825 passed, 3 skipped, 0 reported failures** across 14 successful module jobs plus the separately successful complete WAITC retry. The original matrix run was globally cancelled because WAITC exceeded its job budget; do not call that historical run green.
- Subsystem/memory: **14/14 jobs SUCCESS; 377 passed, 1 configuration-inapplicable skip, 0 failures**. Native DRAM/technology RAM's 104 passes are already included.
- RTL-tail: **33 passed, 1 parameter-inapplicable skip, 183 deselected** on its own exact SHA.
- ASIC/config: run 45487119079 passed its four-DIMM host AXI, negative aperture, global address-map, four-instance HMUX contention/assertion and integrated lint scopes on exact code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`.
- Remaining RTL/board run 45649502094 was cancelled during the long RTL-uncovered selection; board-functional was skipped by its dependency. No pytest count is credited for that run.

### Latest workflow remediation
Commit `7320c187810cbd7e4f106f0280922871f6430d1b` updates `.github/workflows/sunnyone-rtl-functional.yml`: the same 18 selector families are partitioned into four disjoint, serial matrix groups (`max-parallel: 1`), each with a 45-minute timeout and a dedicated verbose log artifact. Board-functional requires all RTL groups to succeed and uploads its own log. No test, assertion or RTL was removed or weakened. Workflow content was read back and verified; the push-triggered run ID/result still must be discovered and inspected. Do not assume success.

### Immediate next actions
1. Find the Actions run triggered by commit `7320c187...`; verify four groups and serial execution.
2. Inspect every group's final pytest summary and artifact; diagnose any failures/timeouts without changing test coverage.
3. Let board-functional run only after all RTL groups pass; inspect its log and artifact.
4. Reconcile exact source SHAs and counts, then freeze one candidate and run consolidated regression.
5. Keep WG8 PPA deferred until functional/ASIC prerequisites pass; the earlier floorplan-PDN failure remains unresolved and no PPA metrics are accepted.
6. Continue open production-interface/IP, formal/CDC/RDC, DFT, SRAM, PDK/package, physical, board, thermal/power, silicon and commercial gates.

**Readiness:** logical V1 is not a complete host-connected ASIC or tapeout package. Manufacturer readiness remains **NOT READY**. Zero spend without explicit approval; feature branch only; preserve main.


### RTL partition static check — 2026-11-25
The four serial RTL groups were checked against the current `tests/test_rtl.py` source (blob `84cdfed65c2c9d3604e51080ce88d878fc71a76a`). All 18 original selectors match 18 distinct test functions, split 5/5/5/3 with no missing selectors or duplicated function matches. This does not replace runtime evidence: retrieve each group's terminal pytest log/artifact and let board-functional run only after all four succeed. See PROJECT_TRACKER.md Section 163.


### Live RTL run — 2026-11-25
The push-triggered serial workflow is [run 45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), head SHA `7320c187810cbd7e4f106f0280922871f6430d1b`. Last observed: group 1 in progress at bounded pytest selection; groups 2–4 queued, proving the intended one-at-a-time schedule. Toolchain setup and dependencies passed. No terminal test summary exists yet; board-functional remains gated. Poll this exact run and inspect all logs/artifacts before claiming completion. See PROJECT_TRACKER.md Section 164.


### Latest verified run update — 2026-11-25
Actions run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), candidate SHA `7320c187810cbd7e4f106f0280922871f6430d1b`: RTL uncovered group 1 job `139371666058` is **SUCCESS**, with retrieved terminal pytest summary **12 passed, 205 deselected, 0 failed** (24m14s). Artifact `sunnyone-rtl-uncovered-1-log`, ID `15047592555`, uploaded. At last poll group 2 (`139371665991`) was running; groups 3 (`139371665344`) and 4 (`139371666093`) queued. Next: poll run 45661335812; inspect group 2–4 logs/artifacts as each completes; inspect board-functional only after all four groups pass. Do not rerun or modify active workflow. This is not full RTL completion. Manufacturer readiness remains NOT READY.


### RTL uncovered group 2 verified — 2026-11-26
In run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), candidate SHA `7320c187810cbd7e4f106f0280922871f6430d1b`, job `139371665991` completed success. Full log summary: **24 passed, 193 deselected, 0 failed** (24m38s). Artifact `sunnyone-rtl-uncovered-2-log`, ID `15049479359`, SHA-256 `7b48507d66da85cea1eac09b76aa9c52f648cd2e87f467a4d4c2ce53f6f206d6`. Groups 1+2 = 36 verified passes across two jobs. Group 3 job `139371665344` has started toolchain build; group 4 `139371666093` queued. Poll exact run; do not duplicate or modify it. Board-functional waits for all four groups. Manufacturer readiness NOT READY.


### Saved continuation state — 2026-11-26
Continue Actions run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812) on candidate SHA `7320c187810cbd7e4f106f0280922871f6430d1b`. Group 1 job `139371666058` passed 12 tests (205 deselected); group 2 job `139371665991` passed 24 tests (193 deselected). Both full job logs and artifacts were inspected; 36 scoped passes verified, with no failures/errors/skips in these selections. Group 3 job `139371665344` remains IN_PROGRESS at bounded pytest selection; its Verilator 5.044 build and dependency installation succeeded. Group 4 job `139371666093` is QUEUED. Board-functional has not started and remains gated on all four groups. Next: poll this same run, inspect terminal logs/artifacts for groups 3 and 4, then inspect board-functional only if all four groups succeed. Do not duplicate/modify the active run or weaken coverage. Manufacturer readiness remains NOT READY; preserve main and zero-spend constraints.


## Continuation checkpoint — 2026-11-26 (Asia/Dhaka)

The prior Actions run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), candidate SHA `7320c187810cbd7e4f106f0280922871f6430d1b`, was cancelled during RTL uncovered group 3. This was an orchestration cancellation, not a reported assertion failure. The group-3 log shows multiple tests passed before cancellation but contains no terminal pytest summary; therefore **no group-3 pass count is credited**. Original run attempt 1: group 1 passed 12, group 2 passed 24, group 4 passed 5; board-functional was skipped because the RTL matrix did not complete successfully. The verified completed-group subtotal is 41 tests, not full RTL acceptance.

A targeted rerun of only the cancelled group-3 job was requested using GitHub's per-job rerun action. Run attempt 2 is now `IN_PROGRESS`; active group-3 job ID `139448997925`. The existing successful groups 1, 2 and 4 remain successful in the rerun attempt. Inspect group 3's terminal pytest summary and artifact before crediting it. Then verify whether the dependency-gated board-functional job starts; if it does, inspect its terminal log and artifact. Do not start a duplicate workflow or rerun successful groups unnecessarily.

Current evidence status: RTL uncovered OPEN; board-functional OPEN / not yet evidenced; consolidated regression pending. Keep exact-SHA evidence, feature-branch-only writes, zero-spend rule and protected `main`. Manufacturer handoff remains **NOT READY**; no PPA, physical, production-IP, hardware, silicon or commercial signoff is implied.


## Follow-up poll — 2026-11-26 (Asia/Dhaka)

Run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), attempt 2, remains **IN_PROGRESS**. Group 1 job `139448999795`, group 2 `139449077187`, and group 4 `139449080038` are all **SUCCESS**. Their attempt-2 log artifacts are present: group 1 ID `15047592555`, group 2 ID `15049479359`, group 4 ID `15054188046`. Group 3 job `139448997925` is still in the pinned Verilator 5.044 build step; a group-3 artifact ID `15053746948` is listed, but because the job is active it is not treated as a terminal pytest report and no pass count is credited. Board-functional is still absent/not started because the four-group matrix has not completed. Next: allow this single job to finish; inspect its terminal log and artifact, then verify board-functional eligibility and results. Do not create another run.


## Continuity update — 2026-11-26 (Asia/Dhaka)

- Correct working repository: `shamiursunny/openTPU`; active feature branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- RTL/board workflow under inspection: [run 45661335812, attempt 2](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), run head/tested SHA `7320c187810cbd7e4f106f0280922871f6430d1b`. The current feature-branch HEAD at documentation time is `044ba53c7861af8235a3f8828c89656f85b5f503`; the run SHA is an ancestor of the current branch tip, not the current tip. Preserve both references distinctly.
- Latest run metadata read at 2026-11-26 01:40 Asia/Dhaka reports `in_progress`. Latest jobs snapshot: RTL uncovered groups 1, 2 and 4 are `success`; group 3 is `in_progress`. Its checkout, Python 3.12 setup, pinned Verilator 5.044 build and dependency installation succeeded; bounded RTL pytest remains in progress. No terminal summary or new test count is credited for group 3.
- Board-functional has not started. The workflow file at the tested run SHA contains `board-functional.needs: rtl-uncovered`, so board execution is gated behind the complete RTL matrix. Do not trigger board-functional separately.
- Group 3 log retrieval returned GitHub storage `BlobNotFound`; this is an unavailable live log, not evidence of a test failure. Re-fetch after terminal state and inspect logs/artifacts and pytest summary.
- Do not count partial/cancelled output or add unverified counts. Previously verified baselines remain software-core **825 passed, 3 skipped**; subsystem/memory **377 passed, 1 configuration-inapplicable skip**; WAITC run `45641472720` **268 passed, 2 skipped, 0 failures**.
- Next sequence: (1) poll run `45661335812` to terminal; (2) inspect group 3 and all four group logs/artifacts, reconcile exact non-overlapping pytest totals; (3) confirm board-functional starts only after all RTL matrix jobs succeed, then inspect its terminal log/artifact; (4) run consolidated regression only after both gates pass; (5) update continuity records with exact current branch and tested SHAs plus evidence.
- Keep protected `main` unchanged. No test removal/weakening, no unapproved expenditure or hardware purchase. Consolidated regression, PPA/physical signoff, production PHY/IP, DFT, CDC/RDC, board electrical validation, real-hardware power/thermal/performance, silicon qualification and commercial readiness remain open. Manufacturer handoff remains **NOT READY**.


## 20. RTL group 3 split to prevent long-running job bottleneck (2026-11-25)

- Updated `.github/workflows/sunnyone-rtl-functional.yml` on the active branch in commit `c638a84d85429a3c3a30989acfb62ba70c36e24a`.
- Original group 3 selection was split into two independently logged matrix jobs: **3.1** runs only `gathers_through_the_hub` (the dominant long-running parametrized test); **3.2** runs `tmem_random_traffic`, `tmem_random_traffic_input_stage`, `tmem_dump_is_the_ram`, and `mlp_4bit_rtl`. Group 1, 2 and 4 selections remain unchanged.
- RTL matrix job timeout increased from 45 to 90 minutes to provide adequate headroom for the isolated hub-gather simulation and toolchain build. Board-functional remains gated on every RTL matrix job succeeding.
- New workflow run **45692968740** (run #119) was created by the workflow update and was pending/queued at checkpoint time. Original run **45661335812** (run #118, attempt 3) remained in progress at last observation; do not assume it was cancelled or completed until status is rechecked.
- The earlier attempt's groups 1, 2 and 4 had succeeded; partial group-3 output showed 36 passes before cancellation, but no terminal pytest summary. Those partial results are not promoted to a completed group result. The new split run must supply terminal evidence for both 3.1 and 3.2.
- Next: inspect run 45692968740 jobs; verify the new job names and matrix; wait for groups 1, 2, 3.1, 3.2 and 4 to finish; inspect each artifact/pytest summary; then confirm board-functional runs only after all five succeed. Keep exact pass/skip/fail counts evidence-based.
- Protected `main` remains untouched. Consolidated regression, physical/PPA, board electrical, production IP/PHY, DFT, CDC/RDC, hardware power/thermal/performance, silicon qualification and manufacturer readiness remain open. Manufacturer handoff remains **NOT READY**.


## 2026-11-26 CI efficiency correction
- Historical verification audit: run #118 (`45661335812`) completed RTL group 1 job `139481341057` and group 2 job `139481272407` with `success`.
- The `tests/test_rtl.py` blob at run #118 commit `7320c187810cbd7e4f106f0280922871f6430d1b` is byte-identical to the current branch blob (`84cdfed65c2c9d3604e51080ce88d878fc71a76a`). The exact group 1 and group 2 test selections therefore have unchanged test source. These groups are accepted as historical passes and removed from the next matrix run to avoid redundant execution.
- Group 4 was `cancelled` in run #118 (`139481274581`); do not mark it passed from that run. The older successful RTL-tail suite (#91, job `139171823473`) ran a different eight-test selection and does not establish group 4 coverage. Group 4 remains required.
- Workflow updated in commit `fd2a310b303d94226c1e65efa0e63b767ac747f4`: matrix now contains only groups 3.1, 3.2 and 4; group 1/2 historical evidence is recorded in workflow comments.
- New workflow run #120 (`45693821197`) is pending on commit `fd2a310b303d94226c1e65efa0e63b767ac747f4`. Run #119 (`45692968740`) was created from the previous matrix and is superseded; its jobs were interrupted/cancelled after the workflow change. Confirm #120 jobs and conclusions before counting new passes.
- Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5` at the last verification. Manufacturer handoff remains NOT READY; this CI correction does not close outstanding PPA, formal, CDC/RDC, integration, physical implementation, power/thermal, or commercial validation work.

## Cross-chat continuation checkpoint — 2026-11-26 (Asia/Dhaka)

Authoritative working location: repository shamiursunny/openTPU; branch sunnyone/commercial-profitability-architecture-2026-11-23. Latest branch HEAD verified immediately before this checkpoint: 40dd0643f7e386751103bfa10f0d91b658e88dba. Protected main independently listed at d84db55712aba0d40811d7762cb052f05d55b7e5; do not write to or merge into main.

Active CI: RTL functional workflow run 45693821197 (https://github.com/shamiursunny/openTPU/actions/runs/45693821197), run head fd2a310b303d94226c1e65efa0e63b767ac747f4. Live job snapshot:
- Group 3.1 job 139486043538: IN_PROGRESS, building pinned Verilator 5.044; checkout and Python setup succeeded; dependency installation and pytest have not started.
- Group 3.2 job 139486044115: QUEUED.
- Group 4 job 139486044169: QUEUED.
- Board-functional depends on the complete RTL matrix; do not start it manually. No new group-3.1/3.2/4 pass count is credited yet.

Verified historical selection evidence: Groups 1 and 2 are accepted from successful run #118 (45661335812) because current tests/test_rtl.py is byte-identical to the tested blob (SHA 84cdfed65c2c9d3604e51080ce88d878fc71a76a). Group 1 and group 2 jobs in #118 were SUCCESS. Group 4 was CANCELLED in #118 and is not a pass; the older RTL-tail run covers a different selection. Current run #120 deliberately runs only groups 3.1, 3.2 and 4. Do not duplicate groups 1/2 unless test source or environment changes.

Immediate continuation sequence for any new chat/tab:
1. Read this checkpoint plus the latest sections of all three continuity files before making changes.
2. Re-query branch HEAD and run #120 jobs; never rely on the saved in-progress status without live polling.
3. Poll group 3.1, then 3.2 and group 4; for each terminal job inspect the full log/artifact and pytest terminal summary. Credit only exact observed pass/skip/fail counts. Diagnose failures from logs and make minimal fixes without weakening/removing tests.
4. After every RTL matrix job succeeds, verify the gated board-functional job starts; inspect its full log/artifact and terminal summary. If RTL fails, board should remain gated.
5. Only after RTL and board gates pass, proceed to consolidated regression and then the remaining integration/formal/physical/PPA/IP/board/hardware/commercial gates. Keep manufacturer handoff NOT READY until evidence closes those gates.
6. After each material engineering step, update PROJECT_TRACKER, MANUFACTURER_HANDOFF_READINESS and PROJECT_RESUME on this feature branch with exact SHA, run/job IDs, logs, counts, limitations and next action. Re-check branch HEAD and main before writes.

Guardrails: serial/low-concurrency execution; no duplicate jobs without cause; no invented test counts; no test weakening; zero spend and no hardware purchase without explicit approval; no claims of tapeout/production readiness from simulation-only evidence. Continue the user's requested remaining engineering work autonomously within these constraints.




## Cross-chat resume correction — 2026-11-26 (Asia/Dhaka)

Repository: `shamiursunny/openTPU`. Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`. Active workflow: [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), tested SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`.

Live state at this checkpoint:
- Group 3.1 job `139486043538`: IN_PROGRESS at bounded pytest. Checkout, Python setup, pinned Verilator 5.044 build and dependency installation all succeeded. No terminal pytest count is credited.
- Group 3.2 job `139486044115`: QUEUED.
- Group 4 job `139486044169`: QUEUED.
- Board-functional: dependency-gated; do not start manually.

Important correction to historical evidence: group 4 job `139449080038` from run `45661335812` has a verified terminal log summary of **5 passed, 212 deselected, 0 failures**. Its tested `tests/test_rtl.py` blob (`84cdfed65c2c9d3604e51080ce88d878fc71a76a`) is identical to the source at the current run SHA. Groups 1 and 2 also have accepted historical passes. Therefore all of groups 1, 2 and 4 have prior passing evidence. The current group-4 matrix job is a redundant rerun introduced by the later cancellation reconciliation; allow the current serial workflow to finish, but do not count duplicate executions as new unique tests.

Continuation sequence:
1. Poll the same run `45693821197`; do not start another workflow.
2. Inspect terminal pytest logs and uploaded artifacts for group 3.1, then 3.2 and the duplicate group 4. Credit only exact observed counts.
3. Confirm board-functional starts only after all RTL matrix jobs succeed; inspect its full terminal log/artifact.
4. Only after RTL and board gates pass, proceed to consolidated regression. Keep PPA/physical, formal/CDC/RDC, production interface/IP/PHY, DFT, electrical board, hardware power/thermal/performance, silicon and commercial validation open until evidenced.
5. Keep manufacturer handoff NOT READY, protected `main` unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`, and zero-spend/no-hardware-purchase rules in force.


## 12. Live continuation checkpoint — 2026-11-26

**Latest verified uncovered RTL state** (supersedes earlier live-run snapshots):
- Repository: `shamiursunny/openTPU`; active branch `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Branch HEAD at checkpoint start: `6339f46aba4fa88041c38fe73cee86eac53fbde5`; protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Current uncovered RTL workflow: [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), tested candidate SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`.
- Group 3.1 job `139486043538`: SUCCESS, **8 passed, 209 deselected, 0 failed**; artifact `15062436327`.
- Group 3.2 job `139486044115`: SUCCESS, **33 passed, 184 deselected, 0 failed**; artifact `15064162074`.
- Group 4 job `139486044169`: IN_PROGRESS at latest poll. Test command running; no final count or artifact yet. Poll this exact job; do not start a duplicate run.
- Historical Groups 1 and 2 passes remain accepted on their tested source. Historical Group 4 pass is retained as historical evidence, not a substitute for the current job or additional unique coverage.
- Group 3.1 and 3.2 are not evidence of board-functional completion. Board-functional is dependency-gated pending full RTL matrix success.
- Immediate action: wait for Group 4 terminal state, inspect its full pytest log/artifact, then check the dependent board-functional job. Proceed to consolidated regression and other open integration/formal/lint/PPA/physical/IP/hardware/commercial tasks only when their prerequisites pass.
- Keep manufacturer handoff **NOT READY**. No paid resources authorised; never modify `main`; never count overlapping tests as unique.



## Live continuation checkpoint — 2026-11-26 (Asia/Dhaka)

- Repository: `shamiursunny/openTPU`; all updates remain on feature branch `sunnyone/commercial-profitability-architecture-2026-11-23`. Branch tip before this checkpoint: `5cc9b8583786bd5a529b0008363aebdc8a547360`. Protected `main` independently verified unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`; do not modify or merge into it.
- RTL workflow [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), tested SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`:
  - Group 3.1 job `139486043538`: SUCCESS; exact terminal summary **8 passed, 209 deselected, 0 failed**; artifact `15062436327`.
  - Group 3.2 job `139486044115`: SUCCESS; exact terminal summary **33 passed, 184 deselected, 0 failed**; artifact `15064162074`.
  - Group 4 job `139486044169`: SUCCESS; downloaded artifact `15062269952` and inspected complete log; exact terminal summary **5 passed, 212 deselected, 0 failed** (336.28 s).
  - Historical groups 1 and 2 remain accepted from unchanged test source: **12 passed** and **24 passed**, respectively. Do not rerun or double-count them. The newly verified group selections 3.1 + 3.2 + 4 add 46 scoped passes; the four groups 1/2/3.1/3.2/4 together have 82 scoped pass executions. This is not a claim of 82 unique lifetime tests or full RTL acceptance without selector overlap reconciliation.
- The workflow's dependency-gated board-functional job `139521841026` has started only after all three currently scheduled RTL matrix jobs succeeded. At the latest live poll it remained **IN_PROGRESS** at the host-driver and board-model regression command; setup, checkout, Python, Verilator installation and project dependencies all succeeded. Its workflow timeout is 45 minutes. No board test count is credited until its terminal log/artifact is inspected. Do not start another board job or duplicate workflow.
- Current action: poll job `139521841026`; when terminal, inspect complete log and artifact, record exact pytest counts and failures/skips. If it passes, proceed to consolidated regression only if its defined prerequisites are satisfied; then continue remaining integration/formal/lint/PPA/physical/IP/PHY/DFT/board-electrical/hardware/commercial gates. If it fails, diagnose the actual failing tests and make minimal fixes without weakening selectors.
- Manufacturer handoff remains **NOT READY**. Selected RTL simulation success is not full formal proof, CDC/RDC closure, physical signoff, production PHY/IP readiness, board electrical validation, hardware performance/power/thermal evidence, silicon qualification, or commercial validation. Maintain zero-spend/no-hardware-purchase without explicit approval.


## Continuation checkpoint — 2026-11-26 (Asia/Dhaka)

- Repository: `shamiursunny/openTPU`; active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Branch HEAD before this documentation update: `ea8c7b430bf4cd695ceff902c1f01daea7d6bfd3`. Protected `main` independently verified at `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare reports 694 commits ahead / 0 behind. Do not modify or merge into `main`.
- RTL/board workflow: [run 45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), tested SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`, attempt 3. Groups 3.1, 3.2 and 4 are SUCCESS (8, 33 and 5 selected passes respectively; no failures). Historical Groups 1 and 2 remain accepted from unchanged source (12 and 24 selected passes). These are scoped selector counts, not a claim of 82 unique lifetime tests.
- The previous board-functional execution `139559281157` was CANCELLED after approximately 83% progress. Its log records passing tests through that point, but no terminal pytest summary; five Qwen/PyTorch-dependent tests were skipped because PyTorch was unavailable. No board-functional PASS is credited.
- A single-job retry was accepted. Current retry job `139677036786` (same workflow run) is IN_PROGRESS at the host-driver and board-model regression command. Checkout, Python setup, Verilator installation and dependency installation succeeded. Poll this exact job; do not start another workflow or manually bypass its dependency gate.
- PPA audit: research run [45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546), tested SHA `c568020d91efd045c6dd5d89dbc30ebdbac2c866`, FAILED in ORFS stage `2_4_floorplan_pdn`. Synthesis and floorplanning completed; generated SRAM inventory reported 288 macros / 3,538 KiB. The PDN log contains repeated PDN-0110 no-via warnings and a PDN-1051 empty macro-grid warning; the flow then exits at `check_placement -fixed -verbose` (ORFS exit 2 / make Error 247). The available log does not establish the precise root cause, so the warnings are diagnostic leads, not a proven causal explanation. Preliminary floorplan timing was WNS -10.43 ns and TNS -91.46 ns. The report's 5.95 W power estimate is a pre-route library/activity estimate, not measured silicon or board power. No signoff PPA result exists.
- The PPA artifact `14997807086` was downloaded and inspected; logs/reports/configuration evidence retained in the workflow artifact. Do not retry the same PPA unchanged. First isolate the PDN/placement failure and review macro-grid/strap/via geometry and floorplan constraints; preserve all physical checks.
- Additional existing CI evidence audited: ASIC target/config run `45598047221` SUCCESS; full-chip Verilator lint `45598047313` SUCCESS; address-map formal proof `45598047300` SUCCESS; PCIe Gen2 bridge simulation `45598047330` SUCCESS; RTL-tail run `45598047232` SUCCESS; WAITC run `45641472720` SUCCESS. These are historical tested-SHA results, not proof that every later RTL change was retested.
- Immediate next sequence: (1) poll board retry `139677036786` to terminal and inspect full log/artifact; (2) if it passes, define and run a consolidated regression on the then-current immutable candidate SHA; if it fails, diagnose actual failures without weakening tests; (3) investigate PDN/placement failure before requesting another PPA run; (4) continue CDC/RDC, broader formal, integration/IP/PHY/DFT, board electrical, hardware power/thermal/performance, silicon and commercial gates.
- Manufacturer handoff remains **NOT READY**. No tapeout/production readiness claim. No paid resources or hardware purchase authorised; maintain zero-spend and do not weaken/remove tests.


## Live continuation poll — 2026-11-26 03:47 UTC (Asia/Dhaka)

- Latest working-branch HEAD before this note: `171474b5b0783b72c23732b7c9acba3e48ec023b`; protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5`. GitHub comparison: 697 commits ahead, 0 behind. Main remains unchanged.
- Existing workflow run [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), attempt 3, remains `in_progress`, testing SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`.
- Board-functional job `139677036786` remains `in_progress`. Latest step poll: setup, checkout, Python setup, Verilator installation and dependency installation all succeeded; step 6, “Host driver and board-model regressions (AXI-Lite isolation already verified separately)”, is still running; artifact upload has not started. GitHub job-log download returned 404/BlobNotFound while the job is active, so no fresh test output or terminal summary is available yet.
- RTL uncovered groups 3.1, 3.2 and 4 remain completed successfully in this run. Do not infer board-functional pass from elapsed time or setup success.
- No new RTL/verification source changes were made during this continuation. The only pending action is to poll the same job/run to terminal, then inspect its log and uploaded artifact. Do not dispatch duplicate workflows, cancel the job, or bypass skipped dependency-dependent tests.
- Existing PPA blocker and manufacturer-handoff NOT READY status from the prior 2026-11-26 checkpoint remain unchanged. No physical signoff, measured silicon/board power, hardware qualification, tapeout readiness, paid spend or production readiness is claimed.


## Board-functional verification result — 2026-11-26 05:59 UTC (Asia/Dhaka)

- Workflow run [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), attempt 3, tested source SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`. The board-functional job `139677036786` is now terminal with conclusion **CANCELLED**. It ran from 03:41:51 UTC to 04:27:03 UTC (about 45 minutes); GitHub log ends with “The operation was canceled.” Do not classify this as a pass or infer a specific cancellation cause beyond the recorded cancellation.
- The board-model pytest log shows the selected regression progressing through 82%. All displayed executed tests before cancellation are marked PASSED; five Tiny-Qwen/Qwen3 cases were SKIPPED because `torch` is not installed. The run ended before pytest emitted a terminal summary, so no complete pass/fail/skip totals can be claimed and the board-functional gate remains **NOT PASSED / INCOMPLETE**.
- Board log artifact uploaded successfully: [sunnyone-board-functional-log, artifact 15086344970](https://github.com/shamiursunny/openTPU/actions/runs/45693821197/artifacts/15086344970). This preserves partial logs only, not a complete test report.
- In the same run, RTL uncovered groups 3.1, 3.2 and 4 all completed SUCCESS. Group 3.2 log explicitly reports **33 passed, 184 deselected**; groups 3.1 and 4 completed successfully with their existing scoped selectors (8 and 5 selected passes respectively). These scoped selector counts are not a consolidated unique-test total.
- Current branch ref verified at `663433351457c32b0f059bf094fa2b628ff4ea9d`; protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. GitHub compare reports 700 commits ahead, 0 behind. No RTL or verification source changes were made in this continuation; only project records are being updated.
- Next action: inspect workflow configuration and board-test execution cost/runtime to determine a safe, evidence-preserving way to complete the full board-functional gate. Do not weaken, deselect, or skip required tests; do not claim success from partial progress. Keep zero-spend. Manufacturer handoff remains **NOT READY**; PPA/physical signoff and hardware qualification blockers remain open.


## Timeout correction and retry launched — 2026-11-26 06:02 UTC (Asia/Dhaka)

- Root cause of incomplete board gate is now narrowed to the workflow's explicit `timeout-minutes: 45`: job `139677036786` ran approximately 45m 12s and GitHub recorded cancellation before pytest's final summary. This is a workflow time-budget limitation, not an observed test assertion failure.
- Updated only `.github/workflows/sunnyone-rtl-functional.yml`: board-functional `timeout-minutes` increased from 45 to 90. Test command, selector, test code and assertions are unchanged. RTL uncovered job timeout remains 90.
- The workflow push automatically queued new run [45765362426](https://github.com/shamiursunny/openTPU/actions/runs/45765362426), run number 121, attempt 1, event push, tested workflow/source commit `455a03232c90b8e631a5add6cd7bebff4afdccad`. At checkpoint time it is **QUEUED**; no result is claimed. Poll this exact run. Its RTL groups will run first due to the workflow dependency graph; board-functional starts only after they succeed.
- The previous run's five Tiny-Qwen/Qwen3 skips remain documented as dependency-related (`torch` absent); do not mislabel them as passes. No test has been removed or weakened.
- Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Maintain zero-spend. Manufacturer handoff remains **NOT READY** pending full regression and outstanding physical/hardware gates.


## Qwen verification feasibility and checkpoint — 2026-11-26 06:15 UTC (Asia/Dhaka)

- Repository inspection confirms an existing Qwen verification foundation. `tests/test_qwen35.py` exercises tiny Qwen3.5 configurations against Hugging Face reference logits and the software/ISA model path, including FP4 emulation and board configuration. Its module uses `pytest.importorskip("torch")` and `pytest.importorskip("transformers")`; therefore missing dependencies can turn the module into a skip rather than a pass.
- `tests/test_models_on_board_rtl.py` is the direct real-checkpoint RTL gate. It targets Qwen3-0.6B and Qwen3.5-0.8B (alongside LFM2.5), uses FP4 weights and an INT8 LM head, exercises MCOLS=2 and 4, and compares RTL logits plus DRAM state against the ISA execution. It is marked slow and requires `--runslow`. If a model directory is absent it explicitly skips that model case.
- The current `.github/workflows/sunnyone-rtl-functional.yml` board-functional command runs `tests/test_board.py`; it does **not** invoke `tests/test_models_on_board_rtl.py`. Thus the current board-functional regression is not evidence of end-to-end Qwen inference on RTL.
- A dedicated Qwen workflow is the next recommended engineering item, but has **not yet been added or run**. Before adding it, inspect dependency pins, model-download/licensing/source integrity, checkpoint storage and runner disk/RAM/runtime. The gate must distinguish required real-checkpoint tests from optional tests; fail clearly if required checkpoint material is unavailable rather than silently green-skipping. Keep any download/cache public, reproducible and zero-spend; do not commit large model weights or secrets.
- Do not call simulated RTL execution physical-hardware validation. Actual FPGA/board Qwen execution still requires the supported board, bitstream, driver, host interface and real measurements. No zero-bug guarantee is possible; acceptance requires layered regressions and recorded evidence.
- Latest poll of workflow run [45765362426](https://github.com/shamiursunny/openTPU/actions/runs/45765362426), run 121, attempt 1, tested SHA `455a03232c90b8e631a5add6cd7bebff4afdccad`: group 3.1 job `139724851662` was **IN_PROGRESS**; groups 3.2 (`139724852016`) and 4 (`139724852036`) were **QUEUED**; run-level status still **QUEUED**, no conclusion and no artifacts yet. Do not claim completion; poll this exact run.
- Protected `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`; working branch comparison last confirmed 707 ahead / 0 behind. Manufacturer handoff remains **NOT READY**. No RTL tests or assertions were weakened.


## Qwen real-checkpoint RTL gate added — 2026-11-26

- Added `.github/workflows/sunnyone-qwen-real-rtl.yml` in commit `d68e7aa3ff651ed03fc58537c93d4d2ab1913844`. This is a separate `workflow_dispatch`-only gate; it does not rerun the already-passed general RTL groups 3.1, 3.2 or 4.
- The gate downloads the official Apache-2.0 `Qwen/Qwen3-0.6B` checkpoint at revision `c1899de289a04d12100db370d81485cdf75e47ca` and `Qwen/Qwen3.5-0.8B` at revision `2b48083dfa97c3cbf0220cf1a5e6cffe0a511157`, verifies the downloaded repository contents, checks model types and safetensors presence, and uses CPU-only PyTorch plus safetensors.
- It runs only `tests/test_models_on_board_rtl.py` cases selected by `-k "qwen3 or qwen35"` with `--runslow`: Qwen3 and Qwen3.5 real-checkpoint RTL cases across MCOLS=2 and MCOLS=4. LFM2 cases are intentionally excluded from this Qwen-only gate.
- **Status: workflow added and read-back verified; NOT YET DISPATCHED; no Qwen RTL result claimed.** A green result must show the selected real-checkpoint cases actually executed and passed. This workflow is not a physical-board validation.
- The general RTL workflow run #121 (run ID `45765362426`) was still active at the latest check: group 3.1 in progress, groups 3.2 and 4 queued. The connected GitHub action set did not expose a cancel-run operation, so cancellation could not be sent from this session. Do not describe it as cancelled. User can cancel it from the GitHub Actions run page if it remains active.
- Previously completed RTL group 3.1, 3.2 and 4 results remain historical evidence; do not repeat those tests merely to reconfirm them.
- Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Branch comparison after adding the workflow: 711 ahead, 0 behind. Manufacturer handoff remains NOT READY.


## User-authorised continuation checkpoint — 2026-11-26 12:35 Asia/Dhaka

### Live repository state
- Repository: `shamiursunny/openTPU`.
- Active working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Branch HEAD before this continuity-only update: `0470472f4cc87a998c063a34c362fcde5f416f0a` (commit message: "Record dedicated Qwen real-checkpoint RTL gate").
- Protected `main` independently verified at `d84db55712aba0d40811d7762cb052f05d55b7e5`. Do not modify, merge into, or push project work to `main`.
- All project changes remain on the active feature branch. Zero-spend rule remains in force; no hardware, paid cloud, licences, or services may be purchased without explicit user approval.

### User's explicit no-rerun instruction
The user personally cancelled workflow run [45765362426](https://github.com/shamiursunny/openTPU/actions/runs/45765362426) and specifically confirmed that groups **3.1, 3.2 and 4 had already passed earlier**. GitHub now reports the run terminal as `completed / cancelled`; its jobs 139724851662 (3.1), 139724852016 (3.2), 139724852036 (4), and 139734601872 (board-functional) are cancelled. These cancellations are not failures and do not erase prior successful evidence. **Never rerun groups 3.1, 3.2 or 4 merely to reconfirm them.** Also preserve accepted historical groups 1 and 2; do not rerun those without a specific source-change/regression reason.

Accepted earlier successful evidence from workflow run [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), attempt 3, tested source SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`:
- Group 3.1 job 139677037811: SUCCESS, 8 passed.
- Group 3.2 job 139677071195: SUCCESS, 33 passed.
- Group 4 job 139677038294: SUCCESS, 5 passed.
- Historical groups 1 and 2 remain accepted from their previously recorded unchanged-source runs (12 and 24 selected passes respectively).
These are scoped selector results; do not add them into a claim of unique lifetime tests without overlap reconciliation.

### Board-functional status
- Board-functional job 139677036786 in run 45693821197 was CANCELLED at approximately 45 minutes before pytest emitted a terminal summary. Its partial log showed tests passing through approximately 82%, with five Qwen/PyTorch-dependent cases skipped because torch was absent in that job. This is **NOT a board-functional PASS**.
- The board timeout was subsequently increased to 90 minutes in `.github/workflows/sunnyone-rtl-functional.yml`. The newer run 45765362426 was cancelled by the user while its RTL groups were queued/running; its board job did not produce a new qualifying result.
- Do not restart the whole general RTL workflow just to get to board-functional, because that would repeat already-passed groups. If board-functional is next pursued, create/use a board-only workflow/job that executes the exact board selector without depending on or rerunning the passed RTL matrix. Preserve the test selector and assertions; do not weaken or skip required tests. Record a complete terminal pytest summary.

### Dedicated Qwen real-checkpoint gate
- Workflow file `.github/workflows/sunnyone-qwen-real-rtl.yml` exists and was read back from the active branch (blob SHA `eb48070c1c371dbc6232631445383fa21c48c812`).
- Test file `tests/test_models_on_board_rtl.py` read-back SHA: `eb9e0af47ffcf372ae98b794d2ee902a4a26ef67`.
- Workflow is `workflow_dispatch` only and has **NOT YET BEEN DISPATCHED**. No Qwen real-checkpoint RTL pass is claimed.
- It pins official Qwen3-0.6B revision `c1899de289a04d12100db370d81485cdf75e47ca` and Qwen3.5-0.8B revision `2b48083dfa97c3cbf0220cf1a5e6cffe0a511157`, checks downloaded checkpoint contents/model type/safetensors, installs CPU-only PyTorch 2.15.0 (valid for Python 3.12; PyTorch 2.15 supports Python >=3.11), and selects only Qwen3/Qwen3.5 cases with `--runslow` and `-k "qwen3 or qwen35"` for MCOLS=2 and 4. LFM2 cases are excluded.
- This is simulated RTL-vs-ISA bit-exact verification using real model checkpoints, not physical FPGA/board validation. Physical Qwen inference still requires actual supported hardware, bitstream, driver and measurements.
- The available connected GitHub actions do not expose a workflow-dispatch action. Do not claim it was dispatched. Next action is to manually dispatch this specific Qwen workflow from GitHub Actions when execution is available, then inspect its exact terminal log/artifact. Do not dispatch the general RTL workflow.
- Before dispatch, confirm the current branch HEAD still contains the above workflow and test-file revisions. If either changed, inspect the diff first.

### Immediate continuation order
1. Resume by reading this section, then the latest master task register and chronological tracker.
2. Re-check live feature-branch HEAD and protected `main`; inspect latest workflow status. Never trust a stale run state.
3. Preserve groups 1, 2, 3.1, 3.2 and 4 as already passed; no duplicate reruns.
4. Complete the dedicated Qwen real-checkpoint RTL gate (manual dispatch required) and inspect full pytest summary/artifact. If it fails, diagnose the actual error and make a minimal evidence-based correction.
5. Complete board-functional using a board-only execution path, not the general RTL matrix. Do not count the cancelled partial run as a pass.
6. Continue remaining consolidated regression, shared-DIMM integration, formal/property coverage, CDC/RDC, lint, PPA/physical implementation, production PCIe/DMA and DDR controller/PHY, DFT, electrical board validation, hardware performance/power/thermal, silicon and commercial feasibility gates.
7. Investigate the already-recorded Nangate45/OpenROAD PDN/placement failure before any PPA retry; do not repeat the unchanged failing run.
8. Keep manufacturer handoff **NOT READY** until all applicable release gates have actual evidence. Never claim production/tapeout readiness or zero bugs from simulation-only evidence.
9. After each meaningful task, update this resume guide, `PROJECT_TRACKER.md`, and `SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md` with exact source SHA, run/job IDs, terminal counts, limitations and next action. Re-fetch all three after writes to verify.
10. In any new chat/tab, the user can simply say **"continue and complete the remaining tasks"**. Start from this checkpoint and current live GitHub state; do not ask the user to repeat the no-rerun instruction.



## Board-only regression isolation update — 2026-11-26 (Asia/Dhaka)

- To complete the incomplete board-functional gate without repeating already-passed RTL groups, added `.github/workflows/sunnyone-board-functional-only.yml` in commit `aedda576e489a297f9452c1cd799072014b565b0`.
- The workflow is deliberately independent of the general RTL matrix. It runs only the existing board-functional selector: `pytest -vv -ra tests/test_board.py -k "not axil_iso_resets_apart"`. No test code, assertions or selector were changed. Timeout is 90 minutes. It uploads the complete log even on failure/cancellation.
- GitHub Actions automatically started board-only run [45769498674](https://github.com/shamiursunny/openTPU/actions/runs/45769498674), tested commit `aedda576e489a297f9452c1cd799072014b565b0`. Job `139738454299` is **IN_PROGRESS**. At the latest poll checkout and Python setup succeeded; Verilator installation was running; pytest had not started. No board test result is claimed yet.
- This run does not include groups 3.1, 3.2 or 4 and must not be described as rerunning them. Do not launch another board-only run while this one is active.
- Dedicated Qwen real-checkpoint workflow remains separate and undispatched. Do not trigger the general RTL matrix.
- Current branch HEAD at the time of this note: `aedda576e489a297f9452c1cd799072014b565b0`; protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Next action: poll only run 45769498674 / job 139738454299 to terminal; inspect the full pytest summary and uploaded artifact. If it passes, record exact counts; if it fails, diagnose without weakening tests. Then proceed to the Qwen real-checkpoint gate and remaining unclosed engineering gates.


## Continuation update — 2026-11-26

The board-only regression using Ubuntu's default Verilator 5.020 failed at rtl/mxu/otpu_mxu.sv:2781 with 133 failed, 65 passed, 8 skipped and 1 deselected. This is a parser/toolchain incompatibility, not a proven RTL functional defect. The board-only workflow now builds and asserts Verilator 5.044 (commit 74ee09d865633e8d8f8cc3edaaf5cb460bf576cc). Retry run 45784404427 / job 139787424587 is in progress at the pinned tool build; no board pass is yet claimed. The dedicated Qwen gate's invalid torch==2.15.0 pin was corrected to CPU torch==2.11.0 and huggingface_hub==2.3.0 (commit 024e488befcbabdde21731f119b52baaedb9d10f); Qwen workflow remains undispatched. See the latest PROJECT_TRACKER.md section A1.12.11.16.55 and authoritative continuation baseline for exact details. Do not rerun historical RTL groups 3.1, 3.2 or 4. Protected main remains unchanged.


## New-chat resume instruction — 2026-11-26 (Asia/Dhaka)

If the user opens any new chat/tab and says “continue and complete the remaining tasks”, resume SUNNYONE X AI CHIP DESIGN from the latest authoritative checkpoint in docs/sunnyone/SUNNYONE_AI-X_AUTHORITATIVE_CONTINUATION_BASELINE_A1.12.11.16.53.md and the latest section of docs/sunnyone/PROJECT_TRACKER.md. Refresh GitHub first; do not rely on stale run states.

At checkpoint save: repo shamiursunny/openTPU; feature branch sunnyone/commercial-profitability-architecture-2026-11-23; branch HEAD 848b7f65884ae049c5a1a19fe4770b6e51d5692c before this continuity commit; protected main d84db55712aba0d40811d7762cb052f05d55b7e5 unchanged. Board-only run 45784404427 / job 139787424587 was running pytest after successful Verilator 5.044 build and dependency install. Poll it and inspect full log/artifact. Qwen-only workflow dependency pins are corrected but it is not dispatched.

Hard constraints: do not rerun historical RTL groups 3.1, 3.2 or 4; do not rerun cancelled workflow 45765362426; do not launch broad RTL matrix; do not weaken tests/assertions; never modify main. Continue serially with low concurrency and update completed/remaining tasks using verified evidence. Manufacturer handoff remains NOT READY.


## Board-functional regression completed — 2026-11-26 (Asia/Dhaka)

- Live branch before this documentation update: `sunnyone/commercial-profitability-architecture-2026-11-23`, HEAD `6bc0c781d3c58c47004f0ea35bd050c4fb8c0a66`. Protected `main` independently verified at `d84db55712aba0d40811d7762cb052f05d55b7e5`; unchanged. All updates remain on the feature branch.
- Board-only workflow run [45784404427](https://github.com/shamiursunny/openTPU/actions/runs/45784404427), job `139787424587`, tested source SHA `74ee09d865633e8d8f8cc3edaaf5cb460bf576cc`. Terminal conclusion: SUCCESS. Pinned Verilator 5.044 build and dependency installation succeeded; isolated board-functional pytest completed; log artifact upload succeeded.
- Exact pytest summary from the job log: **198 passed, 8 skipped, 1 deselected in 4158.05s (1:09:18)**. All eight skips were due to missing PyTorch (`torch` not installed), affecting torch-dependent tiny-Qwen board-model tests. The deselected test is `axil_iso_resets_apart`, excluded by the workflow's existing selector. This is a successful scoped board-model regression, not a complete test of the deselected or skipped cases and not physical-board validation.
- Artifact: `sunnyone-board-functional-only-log`, artifact ID `15104009648`, SHA-256 `fd8901eefabd4f990826abe072ca0f505f92919c1f8a9b4c59fda0915089a00a`; [download from workflow run](https://github.com/shamiursunny/openTPU/actions/runs/45784404427/artifacts/15104009648).
- Do not repeat RTL groups 3.1, 3.2 or 4; their earlier successful evidence remains accepted. Do not rerun cancelled general matrix run `45765362426`. No broad RTL matrix was launched.
- Dedicated Qwen real-checkpoint workflow `.github/workflows/sunnyone-qwen-real-rtl.yml` remains workflow_dispatch-only and undispatched; no real-checkpoint Qwen RTL result is claimed. The available GitHub integration in this session exposes no workflow-dispatch action, so manual dispatch remains outstanding. Board regression's eight PyTorch-related skips do not substitute for that gate.
- Remaining: dispatch and inspect Qwen real-checkpoint RTL gate; close the skipped/deselected test gaps deliberately; continue consolidated regression and four-DIMM shared-DIMM adversarial verification; formal properties; CDC/RDC; full-chip lint and configuration checks; WG8 PPA/physical implementation; production PCIe/DMA/IOMMU and DDR controller/PHY/ECC; DFT, board/silicon electrical and thermal/power/performance qualification; and evidence-backed commercial qualification.
- Manufacturer handoff remains **NOT READY**. This board-model simulation does not establish production PCIe, DMA, DDR PHY, formal/CDC/RDC, foundry PDK, physical signoff, silicon, measured power/performance/thermal or commercial qualification.


## Isolated AXI-Lite reset coverage queued — 2026-11-26 (Asia/Dhaka)

- The completed board-only run excluded exactly one test by its existing selector: `test_axil_iso_resets_apart`. Rather than rerunning the 198-pass board suite, added a narrow workflow `.github/workflows/sunnyone-axil-iso-reset-only.yml` to execute only this test, with pinned Verilator 5.044 and the same project/test setup. The test exercises `otpu_axil_iso` with independent master/slave resets, two seeds, and both isolation-enabled and bypass modes; it checks that responses do not cross a master reset and that each access receives the expected response.
- Workflow commit: `9af352cb36ad5599fd839cf12c8798ff8000ba92`; file read-back verified (blob `27b06f096ad0e368f1c758e4cf6aed5a5e58f054`). The workflow is configured for manual dispatch and a branch-scoped push trigger limited to its own file and relevant test/RTL dependencies. Commit status currently exposes no status checks; no run ID or test result is confirmed yet. Do not claim a pass until the actual Actions run and full log are inspected.
- The board-only regression evidence remains 198 passed, 8 skipped (all require missing PyTorch), 1 deselected. This new workflow is deliberately isolated and does not repeat completed RTL groups or the board suite.
- Qwen real-checkpoint workflow remains manual-dispatch-only and undispatched. The connected GitHub action interface has no workflow-dispatch operation; no Qwen checkpoint result is claimed.
- Current branch HEAD at this note: `9af352cb36ad5599fd839cf12c8798ff8000ba92`. Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`, unchanged. Manufacturer handoff remains **NOT READY**.


## Live continuation checkpoint — 2026-11-26 (Asia/Dhaka; latest verified branch SHA 6732bc47a7c5fd1b7c441e69e40f27a59c15a65a)

- AXI-Lite isolated test run [45806586835](https://github.com/shamiursunny/openTPU/actions/runs/45806586835), job 139863351015: checkout/Python setup passed; Verilator 5.044 build still IN_PROGRESS at latest poll; pytest not yet started.
- Qwen real-checkpoint workflow retains manual dispatch and now also has a tightly scoped push trigger for this feature branch and only its workflow/test/package/RTL/simulator/config dependencies. This was necessary because the available GitHub integration has no workflow-dispatch action. Commit 6732bc47a7c5fd1b7c441e69e40f27a59c15a65a triggered run [45807130675](https://github.com/shamiursunny/openTPU/actions/runs/45807130675), job 139865226090. Latest poll: checkout/Python setup passed; Verilator build IN_PROGRESS; dependencies, checkpoint downloads and tests not started. No test result claimed.
- Both CI jobs were simultaneously building Verilator at the last poll. Do not start further CI runs until they finish.
- Audited historical exact-SHA results: ASIC/target configuration 45598047221 SUCCESS (includes four-DIMM WG8 AXI top lint and simulation, address-map simulation, and four-DIMM HMUX contention); HMUX standalone 45598047225 SUCCESS; full-chip lint 45598047313 SUCCESS; 32-GiB address-map formal proof 45598047300 SUCCESS; RTL subsystem matrix 45598047338 SUCCESS across all listed jobs; PCIe Gen2 XDMA bridge simulation 45598047330 SUCCESS. These are bounded digital verification results, not production PCIe/DDR hardware, full-chip formal or physical signoff.
- WG8 PPA run 45545698546 failed at ORFS floorplan PDN/check_placement. Artifact 14997807086 shows process exit 247, ~15.7 GB peak memory and repeated M6-M7 via insertion warnings. Root cause is unconfirmed; PPA remains unqualified. Preserve logs and diagnose before any rerun; do not suppress PDN/placement checks.
- Preserve restrictions: do not rerun RTL groups 3.1, 3.2 or 4; do not rerun cancelled run 45765362426; no broad RTL matrix. Protected main remains d84db55712aba0d40811d7762cb052f05d55b7e5. All work on feature branch.
- Board-only run 45784404427 remains 198 passed, 8 PyTorch-dependent skips, 1 intentionally deselected. AXI-Lite isolated test is meant to cover the deselected case; Qwen checkpoint test is intended to exercise the model-dependent gate. No results from either new workflow until terminal logs are inspected.
- Outstanding: full adversarial DIMM protocol coverage beyond existing bounded four-DIMM contention tests; broader formal properties; CDC/RDC; WG8 PPA resource/root-cause and physical signoff; production PCIe endpoint/PHY and DMA/IOMMU; DDR controller/PHY/ECC; DFT; foundry PDK/macros; board/silicon qualification; measured power/performance/thermal; commercial/manufacturer qualification. Manufacturer handoff remains **NOT READY**.


### WG8 timing evidence from failed research PPA artifact — 2026-11-26
- Inspection of archived `2_floorplan_final.rpt` from PPA run 45545698546 shows core-clock floorplan WNS = **-10.43 ns**, TNS = **-91.46 ns**, and reported core-clock minimum period = **12.93 ns** (Fmax **77.31 MHz**). The project candidate SDC's 400 MHz / 2.5 ns target is therefore not met at this floorplan stage. This is pre-route research-flow timing evidence using the Nangate45/fakeram macro model, not final signoff STA or a silicon frequency measurement. No 400 MHz claim is permitted. This timing shortfall is an independent blocker from the later ORFS floorplan-PDN/check_placement failure.


### AXI-Lite independent reset test completed — 2026-11-26
- Dedicated run [45806586835](https://github.com/shamiursunny/openTPU/actions/runs/45806586835), job `139863351015`, source SHA `9af352cb36ad5599fd839cf12c8798ff8000ba92`: **SUCCESS**. Pinned Verilator 5.044 build and project/test dependency install succeeded. Exact pytest result: **1 passed, 206 deselected in 17.32s**; selected test `tests/test_board.py::test_axil_iso_resets_apart` passed. The test covers two seeds and both isolation-enabled and bypass cases for independent AXI-Lite master/slave resets. This closes the one deliberately deselected test from board-only run 45784404427; it does not mean the other 206 tests were rerun.
- Artifact `sunnyone-axil-iso-reset-only-log`, ID `15109822525`, SHA-256 `797304cbd415af26b0d2f6b624e4045e4a3ad75f70df37cd4ba104a904695a22`; [download from run](https://github.com/shamiursunny/openTPU/actions/runs/45806586835/artifacts/15109822525).
- Combined with board-only run 45784404427, the explicitly selected board test coverage now includes 198 passed + the isolated AXI-Lite reset test passed; the eight PyTorch-dependent tests remain gated by the active Qwen real-checkpoint run 45807130675 and are not yet closed.


### WG8 PPA retry resource guard prepared — 2026-11-26
- Updated `.github/workflows/sunnyone-asic-wg8-ppa.yml` to export `ORFS_CPUS=2` before the ORFS flow. `tools/asic/flow.py` explicitly maps `ORFS_CPUS` to both ORFS `NUM_CORES` and Docker `--cpus`. The prior failed run peaked at approximately 15.7 GB RSS and terminated at `check_placement`; the two-CPU limit is a resource-conscious diagnostic retry setting, not proof that memory pressure caused the failure. PDN/placement checks remain enabled and unchanged.
- Workflow update commit: `bf13801352dd7b684119b14145504314212fbb5c`. The PPA workflow intentionally excludes its own file from push triggers, so this change did not launch a new PPA run. No retry has been dispatched. Given the floorplan timing result (77.31 MHz vs 400 MHz target), further RTL timing optimization is required before treating PPA as a qualification gate.


### Clarification: eight PyTorch-dependent board skips are a separate gate
- Inspection of artifact `15104009648` confirms the eight skips are specifically: three `test_tiny_qwen3_on_board_model` format cases; two `test_tiny_qwen3_two_slices_on_board_model` cases; one `test_tiny_qwen3_generate_on_board_model`; and two `test_tiny_models_four_slices_wg_on_board_model` cases (Qwen3/Qwen3.5). All skip because `torch` is unavailable; these tests also call `pytest.importorskip("transformers")`.
- The currently active Qwen real-checkpoint workflow selects `tests/test_models_on_board_rtl.py -k "qwen3 or qwen35"`, a different test module and selection. Its eventual pass must **not** be counted as closing these eight board-test skips. A separate targeted run must install compatible CPU PyTorch and Transformers, then execute only the eight named board-test cases. Keep that as a separate follow-up gate; do not rerun the full board suite.


### Qwen checkpoint verification retry and eight tiny-model tests — 2026-11-26
- First Qwen run [45807130675](https://github.com/shamiursunny/openTPU/actions/runs/45807130675), job 139865226090, failed at `hf cache verify` after both pinned model downloads succeeded. The failure was a verifier invocation issue: `--fail-on-extra-files` treated Hugging Face's own `.cache/huggingface` metadata/lock files inside each `--local-dir` as extra model content. It was not a missing checkpoint or RTL failure.
- Corrected the checkpoint verification step to retain `--fail-on-missing-files` but omit `--fail-on-extra-files`; retained explicit model architecture, safetensors presence and total-size checks. The download/verification output is now tee'd to the artifact log. Commit `815399df0e4f8e36f3bbe80af474a3bcb5dbbf40` triggered retry run [45808346935](https://github.com/shamiursunny/openTPU/actions/runs/45808346935), job 139869385724. Latest poll: Verilator 5.044 build IN_PROGRESS; later steps not started. This run does not yet include the eight skipped board-test cases.
- A further scoped workflow update pins `transformers==4.57.3`, verifies the Qwen3 Transformers classes, and adds a separate pytest selection for exactly the eight previously skipped tiny board-model cases: `tiny_qwen3_on_board_model` (3 parameter cases), `tiny_qwen3_two_slices_on_board_model` (2), `tiny_qwen3_generate_on_board_model` (1), and `tiny_models_four_slices_wg_on_board_model` (2). It does not rerun the full board suite. Commit `b02f7de514ea1db1843864330da9d6831676a9f7` triggered queued run [45808406729](https://github.com/shamiursunny/openTPU/actions/runs/45808406729); no job has started yet at latest poll. The earlier retry is still running; the new run is queued by the workflow concurrency group.
- Do not count the Qwen real-checkpoint test selection as closing the eight tiny-model tests unless the later run's separate eight-test step completes successfully. Neither Qwen run has a terminal pass yet.


### Qwen tiny-model dependency compatibility correction — 2026-11-26
- Before the expanded tiny-model run could reach dependency installation, compatibility was rechecked: Transformers v5 requires Hugging Face Hub >=1.0.0, while the workflow pins Hub 2.3.0. Therefore the initial proposed Transformers 4.57.3 pin was incompatible and has been replaced before execution with `transformers==5.24.1`, the current stable v5 line documented by Hugging Face; the Qwen3Config/Qwen3ForCausalLM classes are present in the v5 documentation. CPU PyTorch 2.11.0 meets the documented PyTorch >=2.6 requirement.
- Workflow correction commit: `bddf9708657766951e5c0d204ef474d742e53418`. This triggers a new run and supersedes the queued/running earlier revision through the workflow's same-ref concurrency group. Do not count the earlier run as validating the tiny-model tests. Latest workflow source now pins Hub 2.3.0 + Transformers 5.24.1.


### Current Qwen comprehensive retry — 2026-11-26
- Finalized workflow revision commit `bddf9708657766951e5c0d204ef474d742e53418` pins `transformers==5.24.1` alongside CPU `torch==2.11.0` and `huggingface_hub==2.3.0`; this avoids the v4.x Hub<1.0 dependency conflict and is compatible with the Qwen3 classes used by the eight tiny-model tests. The workflow runs the real pinned Qwen3/Qwen3.5 RTL cases and then separately runs the exact eight previously skipped tiny board-model cases.
- Current run [45808551468](https://github.com/shamiursunny/openTPU/actions/runs/45808551468), job `139870207686`, source SHA `bddf9708657766951e5c0d204ef474d742e53418`: IN_PROGRESS; checkout and Python setup passed; pinned Verilator 5.044 build is running. No dependency install, model download or pytest result yet.
- Earlier run 45808346935 and queued run 45808406729 were cancelled by same-workflow supersession before their test stages. The original run 45807130675 remains a recorded failure at the false-positive extra-cache-file verification check; it did successfully download both checkpoint repositories.

## Continuation checkpoint — 2026-11-26 (Asia/Dhaka)

- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Feature-branch HEAD before this checkpoint update: `d60833aafa83f38d94c66ed610146cbcddaa3c57`.
- Protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5`; do not modify.
- Never rerun passed RTL groups 3.1, 3.2 or 4 merely to reconfirm.
- Do not restart user-cancelled workflow 45765362426.
- Existing Qwen real-checkpoint run [45808551468](https://github.com/shamiursunny/openTPU/actions/runs/45808551468), run SHA `bddf9708657766951e5c0d204ef474d742e53418`, was still running at 18:35 Asia/Dhaka. Steps 1–7 passed, real Qwen3/Qwen3.5 RTL cases at step 8 were running, eight tiny-model tests at step 9 and log upload at step 10 were pending. No Qwen result may be claimed until the run reaches a terminal state and logs are inspected.
- Immediate next action: poll that exact run; inspect pytest output/artifact; record exact pass/fail/skip counts; diagnose any failure without weakening checks or using dummy checkpoints.
- Then continue outstanding four-DIMM adversarial AXI, formal, lint, CDC/RDC, research PPA, PCIe/DMA/IOMMU, DDR4 PHY/controller/ECC, SRAM/DFT, physical/package/board, silicon and commercial validation tasks.
- All work remains zero-spend unless explicitly approved. Keep evidence tied to exact commit SHAs. Do not describe the logical design as tapeout-ready, production-ready or silicon-validated.
