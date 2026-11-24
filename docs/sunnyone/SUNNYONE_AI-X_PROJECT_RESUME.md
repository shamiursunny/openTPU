# SUNNYONE AI-X — Project Resume and Fresh-Session Continuation Guide

**Last updated:** 2026-11-24 (Asia/Dhaka)  
**Project:** SUNNYONE AI-X — commercial AI inference ASIC and custom board  
**Repository:** https://github.com/shamiursunny/openTPU  
**Active branch:** `sunnyone/commercial-profitability-architecture-2026-11-23`  
**Feature-branch checkpoint before this documentation refresh:** `0d6128d21c086d52e0c6ca3a10bfe4f2666dcccb` (verify live HEAD before every continuation)  
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
- H01–H04 and H07–H11 cover manufacturer/physical/hardware dependencies. H05 has a source-derived host DMA/descriptor interface specification at `docs/sunnyone/SUNNYONE_AI-X_HOST_DMA_AND_GLOBAL_ADDRESS_MAP_SPEC.md`; PCIe/DMA RTL, descriptor ABI and driver remain open. H06 now also has a standalone global-to-DIMM decoder and inverse-bijection testbench; ASIC/config Run `45455874266` on `d3a75f...` is queued. A combinational formal harness and pinned-Yosys SAT workflow were added. First formal Run `45456060346` failed because Yosys emitted `$check` cells not accepted by the SAT pass. The attempted `chformal -assert` change at `9c550d...` was incomplete because `-assert` selects a constraint type but does not lower `$check`; queued Run `45456545394` is superseded. Workflow commit `0d6128d21c086d52e0c6ca3a10bfe4f2666dcccb` now uses `chformal -lower`; corrected formal Run `45457143624` on `0d6128...` is queued. Neither the simulation nor formal proof has passed yet. The decoder is not integrated into a DMA engine or ASIC top, so end-to-end global routing remains open. H12 has an evidence-based profitability measurement framework at `docs/sunnyone/SUNNYONE_AI-X_COMMERCIAL_PROFITABILITY_MEASUREMENT_MODEL.md`; numeric ROI/power decisions remain blocked on measured performance, physical PPA, full-system power, manufacturer quotations and demand/pricing evidence.

Recommended order:
1. Inspect consolidated ASIC/config Run `45455874266` on exact SHA `d3a75f...` for A02 multi-beat/response/negative-address tests, A03 contention/HMUX_FORMAL assertions and H06 address-map simulation.
2. Inspect full-chip lint Run `45454389561` on exact SHA `fc3bdc...` for MODDUP/UNOPTFLAT cleanup and exposed width warnings.
3. Inspect H06 formal rerun `45457143624` on exact SHA `0d6128...` and standalone address-map simulation Run `45455874266` on `d3a75f...`; the first formal attempt failed at Yosys SAT cell conversion, the intermediate `45456545394` script is superseded, and the `chformal -lower` rerun is pending.
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

**Last known decision:** continue A01 and A04 verification first. Both corrective commits exist, but their verification runs were queued at the last confirmed poll. No paid resources have been authorised.

## 10. Document commit references at this checkpoint

- Resume guide initial creation: `3a39b5eada362f65e9882896a5ee34bea5d9760c`; this final refresh is a later commit on the same feature branch.
- Master register update adding this guide and the three-file protocol: `2b168ed918b2434347b212d7b79d700558dcc48e`; latest tracker-pointer refresh: `34c4e3bf85e4826590266a1f613bfa4abc815181`.
- Chronological tracker entry documenting the resume guide and three-file protocol: `a8e91b44dd148d77f1f5ffc56d930fefc9e4dd3b`.
- These are document-update commits, not a final project release SHA. Always query the live branch head and `main` before continuing.
