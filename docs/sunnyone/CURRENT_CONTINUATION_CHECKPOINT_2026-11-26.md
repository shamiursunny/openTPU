# SUNNYONE AI-X — Current Continuation Checkpoint
Last updated: 2026-11-26 (Asia/Dhaka)

## Start here in every new chat
Read this file first, then read `docs/sunnyone/PROJECT_TRACKER.md`. Verify the live GitHub branch HEAD, protected `main`, and the workflow IDs below before taking action. This file supplements the tracker and is the latest authoritative operational checkpoint.

**User continuation command:** “Continue and complete the remaining tasks.”

Repository: https://github.com/shamiursunny/openTPU
Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Latest verified branch HEAD: `6ca69d24f9c7dbdd960e01531b7d64454c8ccaf3`
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
