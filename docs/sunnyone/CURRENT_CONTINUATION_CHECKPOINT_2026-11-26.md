# SUNNYONE AI-X — Current Continuation Checkpoint
Last updated: 2026-11-26 (Asia/Dhaka)

## Start here in every new chat
Read this file first, then read `docs/sunnyone/PROJECT_TRACKER.md`. Verify the live GitHub branch HEAD, protected `main`, and the workflow IDs below before taking action. This file supplements the tracker and is the latest authoritative operational checkpoint.

**User continuation command:** “Continue and complete the remaining tasks.”

Repository: https://github.com/shamiursunny/openTPU
Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Latest verified branch HEAD at the start of the 2026-11-26 23:30 Asia/Dhaka continuation: `4aa4018e420979b4441dd59e37710cee555376ed`
Protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5` — do not modify.
Latest source RTL experiment: `2835f1a8da6af454023caff9576f41258c66e2a8` (DMA stream setup constant-divisor rewrite).
Latest documentation clarification commit: `6ca69d24f9c7dbdd960e01531b7d64454c8ccaf3`.

## Non-negotiable controls
- Work only on the active feature branch; never change protected `main`.
- Zero-spend by default. No paid service, hardware, foundry, or external IP spend without explicit approval.
- User explicitly cancelled Actions run `45765362426`; never restart it.
- RTL groups 3.1, 3.2 and 4 have already passed historically. Do not rerun them merely to reconfirm.
- Do not infer test success from workflow names/status alone; inspect job logs, test summaries, artifacts and exact source SHA.
- Preserve failures, warnings and limitations. Do not claim formal, physical, silicon, production or manufacturer readiness from digital simulation/lint.
- Manufacturer handoff remains **NOT READY**.

## Confirmed results since the previous checkpoint
1. **Qwen real-checkpoint + tiny board-model tests:** workflow [45808551468](https://github.com/shamiursunny/openTPU/actions/runs/45808551468), exact source SHA `bddf9708657766951e5c0d204ef474d742e53418`, SUCCESS. Actual logs inspected: six real-checkpoint Qwen3/Qwen3.5 RTL cases passed (4 deselected), and eight previously PyTorch-skipped tiny board-model cases passed (199 deselected). Pinned official checkpoints and checksums verified. Artifact ID `15122919007`, SHA-256 `0e33180ae7ab23408ce4bda5266045f07ff7fe7e61bfbc0afd36fa187fe77c78`. This closes only those selected digital/model tests.
2. **DMA timing experiment:** commit `2835f1a8da6af454023caff9576f41258c66e2a8` rewrites six SRX stream-setup expressions in `rtl/dma/otpu_dma.sv` to select between constant-divisor calculations. Mathematical equivalence was exhaustively checked for `su_ns` 0–63, both selector states, and representative positive `SPC` values 1,2,4,8,16,32. This is not formal RTL equivalence and does not prove timing improvement.
3. **Full-chip lint:** workflow [45845758782](https://github.com/shamiursunny/openTPU/actions/runs/45845758782), exact DMA-change SHA, SUCCESS. Verilator 5.032. Warning debt: 52 WIDTHEXPAND, 27 WIDTHTRUNC, 7 LATCH, 3 UNOPTFLAT. No warning line specifically referenced `rtl/dma/otpu_dma.sv`. Lint pass does not close warning triage/formal/CDC/RDC.
4. **Four-DIMM/ASIC configuration:** run [45845758681](https://github.com/shamiursunny/openTPU/actions/runs/45845758681) job `asic-config` is completed SUCCESS. At last verified job summary, integrated ASIC control, WG8 memory and four-DIMM AXI lint passed; four-DIMM simulation was still running. Inspect terminal logs before declaring simulation pass.
5. **Guard against accidental broad matrix:** commit `4999b964d891d02fb93cb805162d5143dfbc4cea` prevents the legacy broad workflow from repeating groups 3.1/3.2/4. Replacement guard run [45845941442](https://github.com/shamiursunny/openTPU/actions/runs/45845941442) completed with jobs skipped. Original accidental run [45845758638](https://github.com/shamiursunny/openTPU/actions/runs/45845758638) was cancelled before group tests executed. This is not test evidence.

## WG8 PPA and timing diagnosis
- Previous research PPA run [45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546), artifact `14997807086`, actual floorplan report: WNS -10.43 ns, TNS -91.46 ns, minimum period 12.93 ns / Fmax 77.31 MHz against 400 MHz / 2.5 ns target. Nangate45 research proxy, pre-route; not signoff STA or silicon frequency.
- Critical path startpoint `sc[254]` maps to `sc.op[6]` because `cmd_t` is a 256-bit packed struct with opcode first and `AWX=4`. The path includes opcode-dependent setup/decode and source selection. Runtime-selected stream divisor may contribute downstream, but available report does not quantify its share.
- New PPA run [45845758658](https://github.com/shamiursunny/openTPU/actions/runs/45845758658) was still IN_PROGRESS at the latest live poll. No new timing/area/power result yet. Do not claim the rewrite improved timing until the exact report is inspected.

## Live workflow poll — 2026-11-26
Latest job states verified from GitHub:
- `45845758658` WG8 PPA: IN_PROGRESS.
- `45845758847` Qwen real-checkpoint rerun on DMA-change SHA: IN_PROGRESS at last poll; earlier successful Qwen evidence remains run 45808551468.
- `45845758681` ASIC config: job completed SUCCESS.
- `45845758677` board-functional-only: IN_PROGRESS.
- `45845758636` RTL tail: IN_PROGRESS.
- `45845758545` subsystem/memory: overall not terminal; MX multiply/replay job SUCCESS; Quantizer modes and Stream RTL IN_PROGRESS; remaining listed subsystem jobs QUEUED.
- `45845758496` reset audit: job completed SUCCESS.
- `45845758659` software/ISA: overall not terminal; compiler, ISA, kernels, formats, quant jobs SUCCESS; VOPS IN_PROGRESS; FP, MX and other jobs QUEUED.

These are the last observed states, not a claim that they remain current. Re-poll before deciding next actions. Avoid starting new CI while these runs are active/queued.

## Immediate next actions
1. Read `PROJECT_TRACKER.md` and this checkpoint, then re-verify branch HEAD and `main`.
2. Poll all eight workflow IDs above. Inspect actual logs/artifacts and terminal results.
3. Compare new PPA with the old report: WNS/TNS, minimum period/Fmax, critical path endpoints, stage (floorplan vs route), area/cell counts and any power data. If no improvement, diagnose or revert/refine only with evidence.
4. Inspect the four-DIMM simulation result separately from its successful configuration/lint job.
5. Complete remaining RTL subsystem, tail, board, software and Qwen exact-SHA jobs. Do not relaunch completed tests unnecessarily.
6. Triage lint warnings, prioritising LATCH and UNOPTFLAT, then width warnings. No indiscriminate suppression.
7. Continue protocol adversarial coverage, formal properties, CDC/RDC, PCIe/DMA/IOMMU, DDR controller/PHY/ECC, SRAM macros, DFT, PDK, package and physical implementation feasibility.
8. Update continuity docs after terminal results; keep evidence and limitations explicit.

## Open gates / claims prohibited
Timing closure; full formal verification; CDC/RDC; warning closure; exhaustive AXI/DMA/fault coverage; production PCIe endpoint/SerDes and DMA/IOMMU; DDR controller/PHY/ECC; production SRAM mapping; DFT; foundry PDK/package; routed physical signoff; real hardware power/thermal/performance/reliability/yield; manufacturer and commercial qualification all remain open unless separately evidenced. No tapeout-ready, production-ready, silicon-validated, measured-power, or commercial-return claim is permitted.

## Continuation instruction
In any new ChatGPT conversation or tab, type exactly: **Continue and complete the remaining tasks.** Start by opening this checkpoint and `PROJECT_TRACKER.md`, then verify the live GitHub state. Continue from the remaining open gates without asking the user to repeat project context.


## Latest continuation poll — 2026-11-26 (verified logs)

### Newly closed exact-SHA jobs
- RTL tail [45845758636](https://github.com/shamiursunny/openTPU/actions/runs/45845758636): **33 passed, 1 intentional skip, 183 deselected in 923.55 s**; actual pytest output inspected. Artifact 15132004314.
- Reset audit [45845758496](https://github.com/shamiursunny/openTPU/actions/runs/45845758496): **4 passed in 322.93 s**; pinned OSS CAD Suite checksum and Yosys+Slang setup succeeded.
- ASIC/target config [45845758681](https://github.com/shamiursunny/openTPU/actions/runs/45845758681): SUCCESS; actual four-DIMM simulation printed PASS for concurrent host/accelerator AW/AR contention, alternating grants, ordered two-beat writes, B/R ID routing and independent backpressure. Artifact 15130743611, SHA-256 `dc0a587493b7b9ca44355fbeb312798b3ef853e2f39e4fecb4ef35c345251863`.
- Full-chip lint [45845758782](https://github.com/shamiursunny/openTPU/actions/runs/45845758782): SUCCESS; artifact 15130078429, SHA-256 `6a1f1639094cfe3d8c800d4f9bd923375fa4dc613b0cb6c1e4f5c9244c6b8d75`. Warnings: 52 WIDTHEXPAND, 27 WIDTHTRUNC, 7 LATCH, 3 UNOPTFLAT. LATCH warnings are scoped local temporaries in conditional branches of `otpu_seq.sv`; not yet proven harmless or waived. UNOPTFLAT paths: slice `gnt` through VPU compression/grant logic, top `sc_gl` through collective request/grant logic, TMEM `pq` through an always block at line 1074. Structural analysis is still required. No lint warning references the DMA RTL file.
- Previous successful Qwen evidence remains run 45808551468 on its earlier exact SHA; do not confuse it with the active rerun.

### Active runs — re-poll before action
- PPA 45845758658: ORFS pinned-container flow in progress; no report yet.
- Qwen 45845758847: real-checkpoint pytest in progress; eight tiny model tests not yet started.
- Board-only 45845758677: board-functional pytest in progress.
- Subsystem/memory 45845758545: MX multiply/replay passed; quantizer modes and Stream RTL running; remaining jobs queued.
- Software/ISA 45845758659: compiler, ISA, kernels, formats, quant tests passed; VOPS running; other jobs queued.
- Reset 45845758496, RTL-tail 45845758636 and ASIC/target 45845758681 are terminal SUCCESS.

No new workflows were launched. Continue polling these existing jobs and inspect actual logs/artifacts. Do not rerun groups 3.1, 3.2 or 4; do not restart user-cancelled run 45765362426. Protected main remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. The DMA rewrite remains unqualified until PPA and relevant RTL tests complete. Manufacturer handoff NOT READY.


### Additional poll — Stream RTL closed
- Subsystem/memory workflow [45845758545](https://github.com/shamiursunny/openTPU/actions/runs/45845758545), Stream RTL job `139998866364`: **14 passed in 1184.62 s**, actual pytest log inspected; artifact 15132346982 (SHA-256 `f8175ca55e63471deab21903454650631e82e372aed70d4fbc96ed69dd0362f8`). Includes eight bit-exact stream RTL configurations plus destination-order tests.
- At latest poll the subsystem matrix still had quantizer-corners and quantizer-modes running, DMA/scoreboard and other groups queued. Software VOPS remained running, other software groups queued. PPA, Qwen and board-only remained in progress. Continue polling; do not launch replacement jobs.
### Quantizer mode regression closed
- Run [45845758545](https://github.com/shamiursunny/openTPU/actions/runs/45845758545), job `139998866077`: **15 passed in 660.95 s**; actual pytest output inspected. Artifact 15132302427, SHA-256 `387665baf7c670e1329c14d4e9ddc09e8027d6c33be559817d23ff91fe7db1ca`.

### Latest live poll — 2026-11-26
- Subsystem/memory 45845758545: MX multiply/replay SUCCESS; Stream RTL SUCCESS (14 passed); Quantizer modes SUCCESS (15 passed); Quantizer corners/tie rounding and SPLITQ running; remaining DMA/scoreboard, QST/QSTB, instruction cache, address-window, FP, QHL, wait-state, matrix reset audit and native DRAM/technology RAM jobs queued.
- Software/ISA 45845758659: compiler, ISA, kernels, formats and quant SUCCESS; VOPS running; other software jobs queued.
- PPA 45845758658 remains in pinned-container ORFS flow, no report yet.
- Qwen 45845758847 remains in real-checkpoint RTL pytest; tiny board-model tests not yet started.
- Board-only 45845758677 remains in board-functional pytest.
- No further CI jobs were launched. Continue polling existing runs only.


## Continuation update — 2026-11-26 22:28 Asia/Dhaka (live GitHub verification)

### Branch and safety recheck
- Active branch HEAD before this checkpoint update: `f88e5a8d581da5710240c25a39aa8778f87b7e8f`.
- Protected project `main` independently rechecked: `d84db55712aba0d40811d7762cb052f05d55b7e5`, unchanged.
- Active branch is 818 commits ahead and 0 behind `main`.
- The latest branch commit before this update only refreshed this continuation checkpoint; RTL experiment source remains `2835f1a8da6af454023caff9576f41258c66e2a8`.
- Repository remains zero-spend. No new workflows were launched during this poll.

### Newly inspected terminal evidence on exact RTL experiment SHA
- Board-functional run [45845758677](https://github.com/shamiursunny/openTPU/actions/runs/45845758677), job `139998865583`: **198 passed, 8 skipped, 1 deselected in 4254.89 s**. The eight skips are the PyTorch-dependent tiny-model cases; the dedicated Qwen run below separately targets them. Artifact `15137400985`, SHA-256 `d0adc900e0ef37ecec1f2715a555e0e822306a79b01bb562b1bbfa23d4f8f9d8`.
- RTL tail [45845758636](https://github.com/shamiursunny/openTPU/actions/runs/45845758636): **33 passed, 1 intentional skip, 183 deselected**.
- Reset/power-up audit [45845758496](https://github.com/shamiursunny/openTPU/actions/runs/45845758496): **4 passed**.
- ASIC/target configuration [45845758681](https://github.com/shamiursunny/openTPU/actions/runs/45845758681): SUCCESS; four-DIMM shared-memory contention simulation printed PASS for concurrent host/accelerator AW/AR, arbitration, ordered W bursts, B/R ID routing and backpressure.
- Subsystem/memory exact-SHA jobs inspected from logs:
  - MX multiply/replay: **17 passed**.
  - Quantizer corners/tie rounding: **8 passed**.
  - Quantizer modes: **15 passed**.
  - Collective hub/DMA/scoreboard: **128 passed**.
  - QST/QSTB: **13 passed**.
  - SPLITQ: **5 passed**.
  - Instruction cache: **23 passed**.
  - Address-window: **20 passed, 1 skipped** (64-GiB configuration makes every address DRAM).
  - Floating-point RTL: **8 passed**.
  - QHL: **7 passed**.
  - Stream RTL: **14 passed**.
  - Wait-state RTL: **11 passed**.
- Full-chip lint [45845758782](https://github.com/shamiursunny/openTPU/actions/runs/45845758782): SUCCESS, Verilator 5.032. Warning inventory remains 52 WIDTHEXPAND, 27 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT. Do not waive or suppress these without source-level analysis. LATCH sites are in `rtl/seq/otpu_seq.sv` at lines 1153 and 1823; UNOPTFLAT sites are `gnt` in `rtl/top/otpu_slice.sv:611`, `sc_gl` in `rtl/top/otpu_top.sv:156`, and `pq` in `rtl/mem/otpu_tmem.sv:297`. Their complete structural impact is not yet resolved.

### Still running or queued — poll before any further CI action
- WG8 PPA [45845758658](https://github.com/shamiursunny/openTPU/actions/runs/45845758658), job `139998865525`: pinned ORFS flow still IN_PROGRESS; no final timing/area/power report or artifact available. The DMA constant-divisor rewrite is NOT accepted as a timing improvement until the report is inspected against the prior baseline.
- Qwen real-checkpoint workflow [45845758847](https://github.com/shamiursunny/openTPU/actions/runs/45845758847), job `139998866215`: Verilator 5.044, CPU-only dependencies, official checkpoint downloads/checksums and architecture checks passed; real Qwen RTL pytest step completed SUCCESS; separate eight previously skipped tiny board-model cases were IN_PROGRESS at poll. No terminal workflow result yet.
- Subsystem/memory workflow [45845758545](https://github.com/shamiursunny/openTPU/actions/runs/45845758545): all listed functional jobs above are terminal SUCCESS; reset audit job `139998869244` and native DRAM/technology RAM job `139998869342` were still IN_PROGRESS.
- Software/ISA workflow [45845758659](https://github.com/shamiursunny/openTPU/actions/runs/45845758659): FP, MX, compiler, ISA, kernels, VOPS, stream, formats, quant and dataflow jobs are terminal SUCCESS; waits job `139998866442` was IN_PROGRESS; waitw, host, host-runs and host-lock jobs were QUEUED.
- Do not start replacement workflows while these existing jobs are running or queued. Do not rerun completed groups.

### Immediate next actions
1. Poll the four non-terminal workflows above and inspect actual terminal logs/artifacts, especially Qwen tiny-model cases, native DRAM/technology RAM, remaining software/host tests and WG8 PPA.
2. Compare new PPA WNS/TNS, minimum period/Fmax, critical path, stage, area and any power data against baseline run 45545698546. Do not claim improvement without exact report evidence.
3. Continue source-level review of LATCH/UNOPTFLAT warnings and width warnings; do not change RTL solely to silence lint.
4. After the workflows are terminal, update the project tracker and this checkpoint with exact summaries, artifact IDs/checksums and any failures.
5. Continue open formal/CDC/RDC, PCIe/DMA/IOMMU, DDR controller/PHY/ECC, production SRAM/DFT, PDK/package/physical, hardware power/thermal/performance and commercial qualification gates.

Manufacturer handoff remains **NOT READY**. These results are bounded digital simulation/lint evidence only; they do not establish timing closure, full formal/CDC/RDC closure, routed physical signoff, production IP/PHY, silicon validation, measured power/thermal performance or commercial readiness.


### Documentation reconciliation — 2026-11-26
The exact-SHA verification outcomes and open workflow states above have also been appended to section 15 of `docs/sunnyone/PROJECT_TRACKER.md` in commit `bdfd076b692b55b7d4d0f8c9646fed1aff4f16d3`. This is a documentation-only change; no RTL, test, workflow or hardware configuration was altered.


## New-chat resume instruction — saved 2026-11-26

When the user opens a new chat in the SUNNYONE X AI CHIP DESIGN project and types **"continue and complete the remaining tasks"** (case-insensitive; shorter "continue" may also be used), resume from this checkpoint. Do not restart the project or repeat completed verification. First verify the live repository, active branch, protected main, latest workflow states and current checkpoint contents.

### Last confirmed state at save time
- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Latest verified branch HEAD: `9d9cb9a5adbe359ad6654a8601b45c8321194497`.
- Protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5` (must remain untouched).
- Branch comparison at save time: 821 ahead, 0 behind.
- Exact RTL experiment SHA: `2835f1a8da6af454023caff9576f41258c66e2a8`.
- Tracker reconciliation commit: `bdfd076b692b55b7d4d0f8c9646fed1aff4f16d3`.
- Latest checkpoint/tracker documentation commits: `9d9cb9a5adbe359ad6654a8601b45c8321194497` and `bdfd076b692b55b7d4d0f8c9646fed1aff4f16d3`.
- Four existing workflows still require polling; last known states:
  - WG8 PPA 45845758658: IN_PROGRESS.
  - Qwen 45845758847: IN_PROGRESS (real-checkpoint RTL step SUCCESS; eight tiny-model cases still pending).
  - Subsystem/memory 45845758545: IN_PROGRESS (reset audit and native DRAM/technology RAM pending).
  - Software/ISA 45845758659: QUEUED / jobs still outstanding (waits, waitw, host and host-related jobs).
- Do not launch replacement workflows while these existing workflows/jobs are active or queued. Poll and inspect logs/artifacts, then update this checkpoint and tracker with exact terminal evidence.
- Do not rerun RTL groups 3.1, 3.2 or 4 merely to reconfirm. Do not restart cancelled run 45765362426. Preserve previous successful evidence.
- Do not change protected `main`; keep zero-spend policy; no speculative RTL edits or warning suppression.
- Manufacturer handoff remains NOT READY. Continue formal/CDC/RDC, physical timing closure, production IP/PHY, hardware, power/thermal, reliability and commercial qualification only with evidence.
- Key outstanding engineering review: compare WG8 PPA against baseline run 45545698546 (prior research result 77.31 MHz); do not accept the DMA constant-divisor rewrite as an improvement without measured comparable reports. Review the outstanding lint LATCH/UNOPTFLAT/width warnings at source level rather than suppressing them.
- Primary files: this checkpoint and `docs/sunnyone/PROJECT_TRACKER.md`.


## Continuation update — 2026-11-26 23:30 Asia/Dhaka (live terminal reconciliation)

### Live branch safety
- Active feature branch HEAD at continuation start: `4aa4018e420979b4441dd59e37710cee555376ed`.
- Protected `main` independently fetched and remains `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Branch comparison: 822 ahead, 0 behind.
- No RTL, workflow, or hardware changes were made during this continuation; documentation reconciliation only.
- All four previously open workflows are now terminal. Their job logs and available artifacts were inspected. Workflow source SHA for the completed verification runs is `2835f1a8da6af454023caff9576f41258c66e2a8`.

### Newly closed verification evidence
1. **Qwen real-checkpoint and tiny board-model tests** — [run 45845758847](https://github.com/shamiursunny/openTPU/actions/runs/45845758847), exact source SHA above, SUCCESS. Official Qwen3-0.6B and Qwen3.5-0.8B checkpoint presence/architecture checks passed. Real RTL: **6 passed, 4 deselected**. Tiny board-model selection: **8 passed, 199 deselected**. Artifact 15136893309, SHA-256 `223804db48d7010633764082a0814e4237a36055aab652f22d5c2f4d069ac7d2`.
2. **Subsystem/memory suite** — [run 45845758545](https://github.com/shamiursunny/openTPU/actions/runs/45845758545), exact source SHA above, all jobs terminal SUCCESS. Combined job logs reviewed: **377 passed, 1 intentional address-window skip** across the selected subsystem, memory and reset-audit jobs. Native DRAM/technology RAM selection alone: **104 passed**. Reset audit completed successfully; prior detailed job result records **4 passed**. Artifacts include 15139026052 (native DRAM/technology RAM log, SHA-256 `9f18856ca1a5d114705645bc6fb541a0e940723356ef0dbdb7842d76e933e50d`) and 13 other selected-job logs, all tied to the same source SHA.
3. **Software/ISA/host suite** — [run 45845758659](https://github.com/shamiursunny/openTPU/actions/runs/45845758659), exact source SHA above, all 15 jobs terminal SUCCESS. Individual logs reviewed: **825 passed, 3 skipped** across FP, MX, compiler, ISA, kernels, VOPS, waits, stream, formats, quantisation, dataflow, waitw, host, host-runs and host-lock. Fifteen per-job log artifacts are retained and identify the same source SHA.
4. **Board functional suite** — [run 45845758677](https://github.com/shamiursunny/openTPU/actions/runs/45845758677), SUCCESS: **198 passed, 8 skipped, 1 deselected**. Artifact 15137400985, SHA-256 `d0adc900e0ef37ecec1f2715a555e0e822306a79b01bb562b1bbfa23d4f8f9d8`.
5. **RTL tail** — [run 45845758636](https://github.com/shamiursunny/openTPU/actions/runs/45845758636), SUCCESS: **33 passed, 1 intentional skip, 183 deselected**. Artifact 15132004314.
6. **ASIC/target and four-DIMM contention** — [run 45845758681](https://github.com/shamiursunny/openTPU/actions/runs/45845758681), SUCCESS. Actual simulation PASS markers cover concurrent host/accelerator AW/AR contention, alternating arbitration, ordered two-beat writes, B/R ID routing and independent backpressure. Artifact 15130743611, SHA-256 `dc0a587493b7b9ca44355fbeb312798b3ef853e2f39e4fecb4ef35c345251863`.
7. **Full-chip lint** — [run 45845758782](https://github.com/shamiursunny/openTPU/actions/runs/45845758782), SUCCESS. Warning inventory remains 52 WIDTHEXPAND, 27 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT; no waiver or closure inferred. Artifact 15130078429, SHA-256 `6a1f1639094cfe3d8c800d4f9bd923375fa4dc613b0cb6c1e4f5c9244c6b8d75`.

### WG8 Nangate45 PPA — failure diagnosed to stage boundary; timing result is preliminary
- Run [45845758658](https://github.com/shamiursunny/openTPU/actions/runs/45845758658), exact source SHA `2835f1a8da6af454023caff9576f41258c66e2a8`, FAILED. Pinned ORFS image: `sha256:edbd355068b742c5ae2413a49a58578465bd52f57668cebebdd383eb4d97607d`; ORFS configured for 2 CPUs.
- The run completed synthesis and floorplan timing reporting, then OpenROAD exited with code 247 during the `2_1_floorplan` stage. The archived log gives peak memory 15,191,368 KB and does not contain a definitive diagnostic for the exit cause. Do not label this definitively an OOM without further evidence.
- Preliminary floorplan report: WNS 0.00 ns, TNS 0.00 ns, worst reported slack +0.46 ns, core-clock minimum period 2.04 ns / 489.55 MHz. The report is pre-route, uses wire-load estimates (no estimated parasitics), and is not routed STA or signoff.
- Synthesis report area: 30,786,988.162 um^2 (Nangate45 proxy cell area, not die area or a foundry estimate).
- Baseline [run 45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546), source SHA `c568020d91efd045c6dd5d89dbc30ebdbac2c866`, floorplan report WNS -10.43 ns, TNS -91.46 ns, minimum period 12.93 ns / 77.31 MHz; synthesis area 30,794,339.338 um^2.
- The newer preliminary floorplan numbers are materially better than the archived baseline, but this comparison is not yet a controlled attribution to the DMA rewrite: the source revisions differ in more than the one DMA expression change, the run did not complete, and physical stages are incomplete. Do not call this timing closure or a proven DMA timing improvement.
- PPA artifact 15137952036, SHA-256 `66d8e83e4f5da5ee5b11be80e851ecfe04f6b801857ef9ee3d786246af47f560`; baseline artifact 14997807086, SHA-256 `bb087bae1049d8364d83f766279a1d77a9f289c3d2747bcb5f796a17fa75d118`.

### Remaining work / next actions
1. Do not rerun the failed PPA yet. Inspect the archived `2_1_floorplan.log`, OpenROAD exit 247 and runner resource telemetry; identify whether this is a process abort, resource limit, or report-stage defect before designing a targeted retry. Keep the two-CPU constraint unless evidence justifies a change.
2. Treat floorplan timing as preliminary only. A comparable successful flow through subsequent stages and routed STA is required before accepting timing closure or attributing gains to the DMA rewrite.
3. Continue source-level triage of the 7 LATCH and 3 UNOPTFLAT warnings and 79 width warnings; do not suppress them.
4. Continue formal/SVA proof, CDC/RDC, PCIe endpoint/SerDes, DMA/IOMMU, DDR controller/PHY/training/ECC, SRAM macro mapping, DFT, PDK/package, physical signoff, hardware power/thermal/reliability and commercial qualification.
5. Do not relaunch completed tests. Preserve exact-SHA evidence and the exclusions for groups 3.1, 3.2, 4 and cancelled run 45765362426.

Manufacturer handoff remains **NOT READY**. The successful runs above close only their named digital test scopes; they do not establish physical-board validation, formal closure, routed timing, power, silicon, production or commercial readiness.


## NEWEST CONTINUATION HANDOFF — 2026-11-26 (supersedes all older status snapshots above)

### Start here in the next chat
When the user says **“Continue and complete the remaining tasks”**, read this newest section first, then read the current checkpoint and tracker as needed. Verify live GitHub branch/main/workflow state before taking action. Do not ask the user to repeat project context.

### Repository and branch protection (rechecked after previous save)
- Repository: `shamiursunny/openTPU` (not upstream `FeSens/openTPU`).
- Active working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Verified branch HEAD at the beginning of this save: `a70ade8b64f7c39777ba190bf185d525fa95ae9d`.
- Protected `main` independently fetched: `d84db55712aba0d40811d7762cb052f05d55b7e5`; do not modify or merge into it.
- Compare at beginning of save: feature branch 824 ahead, 0 behind.
- Previous documentation reconciliation has been verified live: checkpoint contains the 23:30 continuation update and tracker contains section 98. This save adds the explicit newest handoff so the next chat will not mistake old in-progress notes for current state.

### Latest completed verification status (do not relaunch)
All listed workflows are terminal; evidence and detailed interpretation are recorded in the 23:30 update above and tracker section 98. Verification source SHA: `2835f1a8da6af454023caff9576f41258c66e2a8`.
- Qwen real checkpoint: 6 passed, 4 deselected; tiny board-model selection: 8 passed, 199 deselected — run 45845758847 SUCCESS.
- Subsystem/memory/reset: combined selected logs 377 passed, 1 intentional skip; native DRAM/technology RAM 104 passed; reset audit 4 passed — run 45845758545 SUCCESS.
- Software/ISA/host: 825 passed, 3 skipped across 15 successful jobs — run 45845758659 SUCCESS.
- Board functional: 198 passed, 8 skipped, 1 deselected — run 45845758677 SUCCESS.
- RTL tail: 33 passed, 1 intentional skip, 183 deselected — run 45845758636 SUCCESS.
- ASIC/target four-DIMM contention: simulation PASS — run 45845758681 SUCCESS.
- Full-chip lint: workflow SUCCESS; warnings remain 52 WIDTHEXPAND, 27 WIDTHTRUNC, 7 LATCH, 3 UNOPTFLAT — run 45845758782 SUCCESS. These warnings are unresolved debt, not accepted waivers.
- WG8 Nangate45 PPA: run 45845758658 FAILED at OpenROAD exit 247 during `2_1_floorplan` after preliminary floorplan report. Peak memory 15,191,368 KB; cause not conclusively established. Preliminary WNS/TNS 0.00 ns, worst slack +0.46 ns, minimum period 2.04 ns / 489.55 MHz; synthesis proxy cell area 30,786,988.162 um^2. Not routed STA, not signoff, and not proof of DMA rewrite benefit. Do not rerun until failure diagnosis is complete.

### Immediate remaining work — priority order
1. **PPA failure diagnosis first:** inspect archived artifact 15137952036, especially `2_1_floorplan.log`, and compare with baseline artifact 14997807086. Establish evidence for process abort vs memory/resource limit vs tool/report-stage defect. Do not label exit 247 as OOM without proof. Keep ORFS pinned image and 2-CPU constraint unless evidence supports a controlled change. Do not trigger a retry before a specific diagnosis and targeted plan.
2. **PPA completion:** once justified, execute a narrowly scoped, controlled retry on this feature branch only; retain exact source SHA, tool/container version, config, logs and artifact hashes. Require successful subsequent physical stages and routed STA before claiming timing closure. Separate source changes to attribute any DMA timing effect.
3. **Lint warning triage:** source-level investigation of 7 LATCH and 3 UNOPTFLAT warnings first, then 79 width warnings (52 WIDTHEXPAND + 27 WIDTHTRUNC). No blanket suppressions or cosmetic waivers; prove any correction does not change intended semantics.
4. Continue formal/SVA proof and CDC/RDC.
5. Continue production integration evidence: PCIe endpoint/SerDes, DMA/IOMMU, DDR controller/PHY/training/ECC, SRAM macro mapping, DFT, PDK/package and physical signoff.
6. Continue measured hardware power/thermal/performance/reliability and commercial/manufacturer qualification. No unsupported claims of silicon or production readiness.

### Hard safeguards
- Do not change protected `main`.
- Do not rerun RTL groups 3.1, 3.2 or 4 merely to repeat their prior successful evidence.
- Do not restart cancelled workflow 45765362426.
- Do not rerun the terminal successful workflows listed above merely to reconfirm.
- No speculative RTL edits, no warning suppression, no paid services or hardware purchases, and no unnecessary broad regression. Use evidence-driven, minimal, reversible changes.
- Distinguish verified results, preliminary estimates, user/project assertions and unverified assumptions. Record exact commit SHA for every result.
- Manufacturer handoff remains **NOT READY**. Passing digital tests do not establish formal closure, routed timing, physical board validation, power, thermal, silicon, production or commercial readiness.

### Documentation state at start of this save
- Prior checkpoint file SHA: `3aa45841e48818702257c38d2c30a0731b446320`.
- Prior tracker file SHA: `5b0c616dff47314e90949967a6d752c2c1b43c32`.
- The next save commit will advance the feature branch; re-fetch and record the resulting branch HEAD after both documentation commits.


## PPA failure investigation — 2026-11-26 (artifact comparison)

Live branch HEAD before this documentation update: `48a741a54acc66562986bcfe698e688e72aa49b4`; protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare: 826 ahead / 0 behind. No RTL or workflow was changed and no workflow was launched.

### Archived evidence inspected
- Current experiment: run [45845758658](https://github.com/shamiursunny/openTPU/actions/runs/45845758658), artifact 15137952036, artifact digest `sha256:66d8e83e4f5da5ee5b11be80e851ecfe04f6b801857ef9ee3d786246af47f560`. Full archive downloaded and inspected, including `2_1_floorplan.log`, `2_floorplan_final.rpt`, `run.log` tail, file inventory and GitHub Actions job log.
- Current `2_1_floorplan.log` ends after “Report metrics stage 2, floorplan final”; it records peak memory 15,191,368 KB and no explicit OpenROAD error, OOM message, `Killed`, signal diagnostic or stack trace. The ORFS wrapper reports `do-2_1_floorplan` Error 247, then make Error 2. The final floorplan report exists, but the expected `2_1_floorplan.odb` and SDC were not written.
- Baseline: run [45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546), artifact 14997807086. Its archived run log reaches the later `2_4_floorplan_pdn` stage and executes `check_placement -fixed -verbose`, then also exits with Error 247; peak memory 15,685,744 KB. The baseline did successfully write the `2_1_floorplan.odb` before failing later. Its ORFS image digest differs from the current experiment, so this is a recurrence of the same exit code under a different image and at a different floorplan substage, not a perfectly controlled tool comparison.
- The two independent runs therefore show a repeatable abrupt Error 247 in memory-intensive floorplan/placement work at roughly 15.2–15.7 GB peak RSS. This materially strengthens a resource-ceiling hypothesis (for example, host/container memory pressure), but neither archive contains cgroup OOM counters, kernel OOM-killer evidence, an explicit SIGKILL record or an OpenROAD stack trace. **Root cause remains unconfirmed; do not record “OOM confirmed”.** No evidence points to a timing-report defect: both archives contain generated floorplan reports, while the failure occurs at/after floorplan processing.
- Current report remains preliminary: estimated wire-load model only, no estimated parasitics, no routed STA. It cannot establish timing closure or attribute a gain to the DMA rewrite.

### Decision / next controlled step
- Do not blindly retry the same flow on the same resource envelope. No retry was started in this continuation.
- Before another attempt, modify only the diagnostic/runner instrumentation or establish a genuinely different, approved resource envelope; capture `/sys/fs/cgroup/memory.max`, `memory.current`, `memory.events` (and available runner memory telemetry) before and during OpenROAD. Keep the ORFS image, source SHA and 2-CPU configuration fixed unless the captured evidence justifies a controlled change. No paid runner or hardware spend without explicit user approval.
- If the memory ceiling is confirmed, choose a reproducible zero-spend mitigation based on evidence (memory-footprint reduction or a supported lower-memory implementation strategy) before running the full flow again. Do not disable placement checks, PDN, or physical stages to manufacture a pass.
- Preserve the baseline and current report metrics as non-comparable preliminary evidence. Require a complete physical flow and routed STA before any timing-closure claim; isolate source changes before attributing a DMA effect.

Manufacturer handoff remains **NOT READY**. Existing digital verification evidence remains unchanged; no completed tests were relaunched.


## Initial full-chip lint source triage — 2026-11-26

Lint artifact 15130078429 (run 45845758782; source SHA `2835f1a8da6af454023caff9576f41258c66e2a8`) was downloaded and its exact Verilator 5.032 diagnostics inspected. No RTL was edited.

- **LATCH (7 warning instances):** all point to block-local temporaries in `rtl/seq/otpu_seq.sv`: `c2` and `r2` in the WAITC branch around line 1153; `u`, `y`, `k`, `kd` and nested `cf` in the `hz_wc && c_v` branch around line 1823. Source review shows each temporary is assigned before its use within the branch that declares/uses it, but the branch is not entered on every activation of the enclosing `always_comb`. This suggests a procedural-scope/conditional-initialisation warning rather than demonstrated state storage; it is **not proven harmless or closed**. Next verify elaborated/synthesised latch cells and run narrowly scoped lint after any proposed semantics-preserving cleanup.
- **UNOPTFLAT `gnt`:** Verilator path: `rtl/top/otpu_slice.sv:611` → `rtl/vpu/otpu_se_comp.sv:640` → `rtl/vpu/otpu_fpipe.sv:15` → `rtl/top/otpu_slice.sv:963` → `gnt`. This is a grant/enable feedback path across VPU compression and arbitration; do not split or register signals without proving handshake-cycle equivalence.
- **UNOPTFLAT `sc_gl`:** path through `rtl/top/otpu_slice.sv:1047`, `cgl_c` at :898 and grant-selection logic at :963 back to `rtl/top/otpu_top.sv:156`. This is a collective global/local grant dependency; inspect combinational dependency and protocol timing before any refactor.
- **UNOPTFLAT `pq`:** `rtl/mem/otpu_tmem.sv:297` feeds the generated bank-data/bypass `always_comb` around :1074 and is reported back to `pq`. The code has separate generated bank-copy and guest-port aliases; establish the exact elaborated configuration and driver graph before deciding whether this is a real combinational cycle or an alias-analysis limitation.
- The remaining 79 width warnings (52 WIDTHEXPAND, 27 WIDTHTRUNC) have not yet been source-triaged. No warnings were suppressed and no warning was declared closed.

Next: prove or disprove latch inference with the actual synthesis/elaboration configuration, then trace the three UNOPTFLAT paths at the elaborated net level. Keep all changes narrow and regression-backed. PPA resource diagnosis remains open as recorded above. Manufacturer handoff remains **NOT READY**.
