# SUNNYONE continuation addendum — 2026-11-27 01:37 Asia/Dhaka

This addendum supersedes earlier in-progress workflow snapshots where the run IDs below overlap. Read this after CURRENT_CONTINUATION_CHECKPOINT_2026-11-27.md and before taking further action.

## Live repository state
- Repository: `shamiursunny/openTPU`
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
- Branch search confirms the named feature branch exists.
- Live compare: feature branch is 886 commits ahead of `main`, 0 behind; merge base is the protected-by-project-rule main SHA `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- GitHub compare response does not expose the current feature HEAD SHA. Do not substitute an older checkpoint SHA as the current HEAD. Re-resolve the live branch ref before the next write.
- Main remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Prior API observation said GitHub branch protection is disabled; this is a control gap, not permission to modify main.
- No RTL, test, workflow or project source was changed in this continuation. No CI workflow was dispatched, cancelled, or rerun.

## Live Actions poll
Polled current job states directly. These are statuses, not final results:

| Workflow run | Live state at 01:37 | Notes |
|---|---|---|
| 45877786710 — WG8 PPA | IN_PROGRESS | Pinned-container SRAM probe and WG8 ORFS flow still running. Do not launch another PPA attempt. |
| 45877786754 — Qwen | IN_PROGRESS | Real-checkpoint RTL step passed; the separate eight formerly PyTorch-skipped tiny board-model cases are running. |
| 45877786742 — Board | IN_PROGRESS | Board-functional regression running. |
| 45877786699 — Subsystem/memory | PARTIAL | Quantizer, MX, QST/QSTB, instruction cache, QHL, SPLITQ, waits, stream, collective/DMA/scoreboard and FP jobs completed successfully; address-window and native DRAM/technology RAM jobs running; reset-audit job queued. |
| 45877786705 — Software/ISA | PARTIAL | Kernels, MX, VOPS, dataflow, FP, stream, ISA, quant, formats and compiler jobs completed successfully; waits running; host-runs, host-lock, WAITW and host jobs queued. |
| 45877786738 — Reset audit | SUCCESS | Dedicated reset/power-up audit job completed. |
| 45877786860 — ASIC config | SUCCESS | Integrated control/compute, native-memory and four-DIMM AXI lint; four-DIMM AXI simulation, address-map simulation and mux contention simulation all completed. |
| 45877807906 — RTL tail | SUCCESS | Selected non-experimental RTL-tail job completed. |
| 45877807985 — Isolated 128K one-copy TMEM | SUCCESS | Dedicated two-case investigation completed. |
| 45877985241 — LOOP stack guard | SUCCESS | 2 passed, 217 deselected; legal depth-four and fifth-level overflow rejection passed. |

Do not count any IN_PROGRESS or queued job as passed. Do not rerun terminal successful jobs just to reconfirm. Preserve the exclusions: never rerun RTL groups 3.1, 3.2 or 4 solely for confirmation; never restart cancelled run 45765362426.

## FSUM row-buffer safety review — design conclusion, no patch yet

Source files reviewed at the active feature branch:
- `rtl/vpu/otpu_vpu.sv` blob `394930f52079883230cea79b28c05df5ee913566`
- `rtl/seq/otpu_seq.sv` blob `a090328d66af8f3b947bd001282fed39f0ac0cbf`
- `rtl/top/otpu_slice.sv` blob `f879785be44f52fdf64580843dd5249548775717`
- `opentpu/isa.py` blob `17c81a0518bcee5284b912fcb4f08fb3bfadc158`
- `opentpu/host/board.py` blob `8d84063977eade0575aaef6b63b5f5595a4f5d73`
- FSUM-enabled targets: `targets/bcu1525-wg.toml` blob `fa4e7dc10cf01719842e523cf0a694e733119314`; `targets/bcu1525-x2.toml` blob `0fe59d6058eb1959b92c90a323c13642815dfc7f`.

Verified source facts:
1. The VPU row buffer has a 256-row bound (`NRB=256`). FSUM write/flush activity is driven by the FSUM back end; its row count is used to index buffered partial sums.
2. The synthesizable RDOT guard is not the same as FSUM protection. FSUM's `rows <= NRB` check currently appears only in an `ifndef SYNTHESIS` assertion.
3. FSUM is enabled in `bcu1525-wg` and `bcu1525-x2`.
4. `opentpu/isa.py` enforces rows 1–256, columns at least 64, and a non-scalar B mode for the EXP2SUB FSUM helper. The ISA simulator/compiler checks are not an unavoidable hardware ingress boundary.
5. `Board.load_program` accepts raw uint32 instruction words and does not perform mandatory FSUM semantic validation before loading. Thus the hardware must not rely solely on compiler or simulator checks.
6. The sequencer already has a defined invalid-operation path: set `error` and `halted`; `otpu_slice` exposes `sq_err` through its `error` output.

Most conservative candidate, not yet implemented:
- Add an effective FSUM capability parameter to `otpu_seq`, wired from the slice using the same effective condition as the VPU's `.FSUM(VPU_FSUM != 0 && HAS_SS)` configuration (and verify the VPU's C8 condition).
- Before an `OP_VOP` enters the dispatch pipeline, inspect the decoded `dcmd`. For an EXP2SUB carrying `VF_FSUM`, reject if FSUM is not actually enabled, rows are zero or exceed 256, columns are below 64, or B mode is scalar. Route rejection through the existing sequencer error/halt path before the VPU can begin or write its row buffer.
- Treat RSUM-with-FSUM (take) consistently with feature enablement; review whether any shape/order checks are needed to preserve the documented “oldest untaken FSUM” contract. Do not add unrelated ISA restrictions without evidence.
- Add focused RTL tests on an FSUM-enabled target: legal boundary (256 rows, 64 columns, non-scalar B); over-limit rows (257); too few columns (63); scalar B; disabled-feature rejection; and prove invalid commands do not issue to the VPU or write buffered sums. Keep test scope narrow.
- Do not implement while PPA run 45877786710 remains active: `otpu_seq.sv` is in its source/path scope and the PPA workflow uses cancel-in-progress concurrency. Wait for that exact run to reach a terminal state and archive its logs/telemetry first.

## Next actions, in order
1. Poll the five active/partial workflows above until terminal; inspect actual job logs and artifacts, not only summaries.
2. For PPA run 45877786710, verify immutable ORFS manifest/image identity, cgroup memory events/limits/peak and stage logs. Do not label exit 247 OOM without explicit evidence. Do not dispatch a duplicate.
3. Once PPA is terminal, correct the proven `ORFS_CPUS` propagation mismatch in `tools/asic/flow.py` (the current implementation was previously found to derive worker count from `os.cpu_count()` and ignore `ORFS_CPUS`). Add a focused test and verify effective ORFS `NUM_CORES`. This correction is separate from the FSUM RTL guard.
4. Implement and verify the minimal FSUM synthesizable bounds rejection described above.
5. Continue exact-netlist/SCC analysis of unresolved `gnt`, `sc_gl`, `pq` and `aok` UNOPTFLAT paths; retain the width-warning inventory and prove bounds before casts.
6. Continue formal/SVA, CDC/RDC, technology SRAM mapping, production PCIe/SerDes and DMA/IOMMU, DDR controller/PHY/training/ECC, DFT, PDK/package and physical signoff.
7. Keep Track A (full programmable product) separate from Track B (small demonstrator). Do not shrink Track A to fit a shuttle. No sponsor, free fabrication, sample access or shipping is confirmed. Manufacturer handoff remains NOT READY.
8. Maintain zero-spend. No paid runner, PDK/IP licence, fabrication, packaging, board, lab test or hardware purchase without explicit approval.

## Continuation command
In a new chat, the user can type: **Continue and complete the remaining tasks.**
Read the current checkpoint, this addendum, integrated plan, tracker and manufacturer readiness matrix; then re-resolve the live branch HEAD and poll the outstanding run IDs before editing anything.


## 2026-11-27 continuation — seed-3 fix validated; clean regression pending

The exact prior power-up failure test_random_power_up[1-3] now passes on the stream-tail init-flush fix (run 45915433368, source f2559a3bead2f2058808f81890ae0a9b91d074a0, 1 passed in 40.33 s with RTL/ISA memory comparison). The fix is in RTL commit 024928752fef7ab774502d2a19f49111cc86b1ff; temporary diagnostic code and workflows were removed in 6290b360 and 425e794. Full clean RTL-tail regression 45915615625 is still running. Full-chip lint 45915615693 passes with 0 errors but 76 width warnings, 7 LATCH and 3 UNOPTFLAT remain. Reset audit power-up stage passed in 45914912691; structural SCC/latch stage and four-DIMM WG8 integration run 45914912733 remain pending. Manufacturer handoff NOT READY; PPA not authorised; main untouched.


## 2026-11-27 correction — structural and ASIC configuration runs are terminal

The earlier pending status above is superseded:
- Structural/reset audit 45914912691 is terminal PASS: power-up/reset 4/4; copy_slice, two_slice_top and asic_top each 0 combinational SCC and 0 inferred latch cells in the audited configurations, with SRAM leaves blackboxed.
- ASIC/target configuration run 45914912733 is terminal PASS. Chip, memory and WG8 DDR4 lint stages passed; four-DIMM host/accelerator mux contention simulation passed AW/AR contention, alternating grants, ordered two-beat W bursts, B/R ID routing and independent backpressure (320 ns).
- ASIC elaboration still reports 99 WIDTH warning occurrences and 3 UNOPTFLAT occurrences across top elaborations. In particular, 33-bit otpu_mig_pair AW/AR outputs feed 34-bit host-mux signals; use 33-bit intermediate nets and explicit zero-extension while preserving the 34-bit address checks. Width cleanup remains OPEN.
- The exact seed-3 random-power-up case passes (45915433368). FSUM (11), isolated 128K TMEM (2), and loop-stack (2) focused regressions pass. Full clean RTL-tail run 45915615625 remains in progress; Qwen real-checkpoint, board-functional, subsystem/memory and software/ISA runs remain nonterminal.
- Full-chip lint 45915615693 passes with 0 errors but still reports 52 WIDTHEXPAND, 24 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT warnings. The 7 Verilator LATCH warnings are in local combinational temporaries in otpu_seq; they must be reconciled with the zero Yosys inferred-latch-cell result, not suppressed.

Manufacturer handoff remains NOT READY. PPA remains unauthorised and must not be retried on the equivalent 16 GB runner. Main remains untouched.


## 2026-11-27 correction — trace-enabled seed-3 result is supplementary only

The prior wording that the exact seed-3 power-up case “passes” refers specifically to trace-enabled run 45915433368 (1 passed in 40.33 s, with RTL/ISA memory comparison). That run sets `OTPU_TRACE_POWERUP=1`; tracing changes Verilator instrumentation and can change the `--x-initial unique` pattern. It is not sufficient to close the no-trace failure.

The no-trace A/B run 45914084753 reproduced `test_random_power_up[1-3]`: the FSUM-guard source failed and the pre-FSUM source passed. The candidate tail-init flush fix must therefore remain PROVISIONAL until clean non-trace broad RTL-tail run 45915615625 and the stream RTL/ISA suite complete. Do not state that seed-3 is closed before inspecting those terminal logs.

The temporary `tb_top.sv` hierarchical monitor, trace test helper and temporary A/B workflow were removed/restored in commits 6290b360 and 425e794. A failure-only `$display` diagnostic remains inside the simulation-only tail assertion in `rtl/vpu/otpu_se_tail.sv`; it does not affect synthesis. Structural/reset audit 45914912691 is terminal PASS (reset 4/4; three tops 0 SCC/0 inferred latches), and ASIC integration 45914912733 is terminal PASS. See the current checkpoint for all other run states.


## 2026-11-27 current branch update — explicit MIG address extension

Commit 600f3aa4822e18f03ba80d06ab86fd447189c126 makes the MIG-pair's 33-bit AW/AR outputs explicitly zero-extended into the 34-bit host mux. ASIC config run 45916680920 is validating; initial lint stages passed and host AXI simulation is running. Full-chip lint 45916680866 passed with zero errors but 76 width, 7 LATCH and 3 UNOPTFLAT warnings remain.

Do not close the stream-tail random-power-up issue from trace-enabled run 45915433368. The no-trace A/B result still fails post-FSUM and passes pre-FSUM; clean no-trace RTL-tail run 45916680719 is pending. Structural/reset audit 45914912691 and prior ASIC integration 45914912733 are terminal PASS. PPA remains unauthorised; main untouched; manufacturer handoff NOT READY.


## 2026-11-27 superseding correction — PPA artifact and ORFS_CPUS review

This section supersedes the old Next actions item 3 proposing an ORFS_CPUS propagation fix. PPA run 45877786710 is terminal failed in `2_4_floorplan_pdn`; artifact 15152974135 confirms `oom_kill=1`, peak memory 16,155,115,520 bytes, host MemTotal 16,366,484 kB, and cgroup `memory.max=max`. This is a host OOM-killer event. The source `tools/asic/flow.py` already reads `ORFS_CPUS`, passes it into `run()`, and sets ORFS `NUM_CORES`; the job exported `ORFS_CPUS=2` and Docker used `--cpus 2`. There is no demonstrated propagation bug. Do not change the flow.py worker handling or add a test for that disproven issue. Do not retry PPA on the same resource class; no retry is authorised.

The FSUM hardware guard remains a candidate and is not yet implemented. Verify actual RTL sequencer path and effective FSUM capability wiring before modifying it. QHL power-up failure remains open; do not treat a scoped RTL-tail pass as closing it. Manufacturer handoff remains NOT READY.


## 2026-11-27 superseding correction — FSUM guard already exists and passes focused RTL

This supersedes the old Next actions item 4 proposing FSUM guard implementation. The current `rtl/seq/otpu_seq.sv` already implements the synthesizable guard via `FSUM`, `fsum_bad`, dispatch-time error/halt before VPU issue, pending producer accounting, and HALT pending-producer error handling. `tests/test_rtl.py` contains the focused test matrix. Workflow 45915615614 / job 140233980040 completed SUCCESS with 11 passed, 219 deselected in 153.05s. No duplicate implementation or test rerun is warranted without a relevant change. The specific guard task is complete for its tested scope; the QHL power-up failure and broader verification gates remain open.


## 2026-11-27 continuation — QHL overlap timing decomposition

A source-level timing review narrowed the QHL failure without changing RTL. In `otpu_se_tail.sv`, `SL = 1 + LM + LA = 7` pe cycles and, for LANES=8, `RL = 64 / LANES = 8` pe cycles. Thus `e2` is `kv_v` delayed 7 pe cycles and `e3` is `kv_v` delayed 14 pe cycles. The failed assertion with `e2=1,e3=1,kv_v=0` proves that two accepted `kv_v` pulses entered the tail exactly 7 pe cycles apart. Both valid pipelines are reset by `rst || init`; the failure occurs with `rst=0,init=0`, so an uninitialised startup bit alone is not a sufficient explanation.

For the LANES=8 stream-tail configuration, A-row roots are required to be spaced by multiples of RL=8. The observed 7-cycle spacing violates that contract. The upstream path to investigate is the shared `otpu_vtree.root_v`, Q/A classification through `vt_q = kq[kh]`, and `kv_v = root_v && !vt_q`. A deterministic trace must record `root_v, vt_q, cap, a_cap, q_cap, vt_rl, vt_sub, ss_act, sen, s_init, kv_v, e2, e3` for the QHL seed-1 no-trace case. This will distinguish a tree-input scheduling violation from Q/A FIFO alignment or stream grant/reset phasing. Do not weaken the assertion, mask the event, or change pipeline depth before the trace identifies the source.

The diagnosis is narrowed, not closed. No RTL changed and no CI rerun was launched. Preserve all prior test results at their exact scope; QHL random-power-up, cancelled software waits, lint warnings, formal/SVA, CDC/RDC, DFT, SRAM mapping and physical signoff remain open. PPA retry remains unauthorised after host OOM. No spend; protected main untouched; manufacturer handoff NOT READY.


## 2026-11-27 continuation — full-chip lint warning inventory

Direct inspection of full-chip lint run `45916680866` / job `140237471700` confirms zero lint errors and 86 warnings: 52 WIDTHEXPAND, 24 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT. LATCH warnings are local combinational temporaries in `rtl/seq/otpu_seq.sv` at lines 1165 and 1854 (`c2`, `r2`, `u`, `y`, `k`, `kd`, `cf`). UNOPTFLAT reports `gnt` at `rtl/top/otpu_slice.sv:612`, `sc_gl` at `rtl/top/otpu_top.sv:156`, and `pq` at `rtl/mem/otpu_tmem.sv:297`. Width warnings include array index truncations and expression-sizing cases across VPU, MXU, quantizer and package RTL. These are not all proven functional defects, but remain untriaged. Do not blanket-cast or suppress them; prove each bound/intent. Reconcile Verilator's local procedural LATCH warnings with the separate Yosys zero inferred-latch-cell result, and examine UNOPTFLAT paths despite prior selected structural SCC passes. Keep lint-warning closure OPEN; do not rerun the successful lint job merely to reconfirm. No RTL changed and no CI run launched.
 
## 2026-11-27 continuation — WAITC remainder verification and QHL diagnostic isolation

- Active engineering branch: `sunnyone/commercial-profitability-architecture-2026-11-23`; feature-branch HEAD at this update: `54577bcd7aca4bf004aac9b7d2f286f57a3c96a7`. Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare is 996 ahead / 0 behind. The branch-protection API endpoint returned 403 to this integration, so current protection metadata could not be independently re-read. No main write was made.
- WAITC remainder workflow added at `.github/workflows/sunnyone-waits-remainder.yml` in commit `54577bcd7aca4bf004aac9b7d2f286f57a3c96a7`. Run `45963867548` is terminal SUCCESS across all three jobs: unfinished hazard cases 3 passed (seeds 1–2), 2 passed (seed 3), and remaining window/MX/host-entry cases 28 passed / 1 skipped. The skip is the optional torch-dependent prebuild case (`torch` was not installed). The original job `45916680756` / `140237552767` was cancelled after about 87% with no test failure in its log; the last completed hazard case `[1-16]` passed. Combined original and remainder logs cover the module's test cases except the documented optional skip. Do not describe the cancelled original job as a standalone full-module PASS.
- QHL diagnosis is isolated on temporary branch `sunnyone/qhl-seed1-diagnostic-2026-11-27`; do not merge its instrumentation. The first instrumented pass `45964405350` was inconclusive because the added counter could perturb unique-X initialisation and emitted no trace. Runs `45965156322`, `45965732887`, and `45966389125` reproduced the original seed-1 assertion, but parent-level trace text was not preserved before fatal termination. A subsequent diagnostic compile `45967519265` exposed an unclosed preprocessor guard in the temporary branch; it was corrected there only. Run `45967861319` is validating the next diagnostic: upstream root/FIFO/classification context is passed into the tail assertion and flushed at the failure site. No result from this run is available yet.
- The QHL functional failure remains OPEN. No assertion weakening, pipeline-depth change, reset masking or production RTL fix is authorised until the cycle-level root/FIFO evidence identifies the cause. No diagnostic RTL edits were made on the active engineering branch.
- No PPA retry, paid resources, manufacturer commitment or main-branch modification. Manufacturer handoff remains NOT READY.


## 2026-11-27 continuation handoff — saved resume state

Resume trigger in a new chat: **“Continue and complete the remaining tasks.”**

### Verified state at handoff
- Repository: `shamiursunny/openTPU`; all documentation updates in this handoff are restricted to the active engineering branch `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Protected `main` baseline remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Do not write to, merge into, or otherwise modify `main`.
- Latest source-level investigation remains the QHL random-power-up failure. Diagnostic branch `sunnyone/qhl-seed1-diagnostic-2026-11-27` is temporary and isolated; do not merge its instrumentation.
- The no-trace seed-1 failure recurs at the stream-tail assertion with `kv_v=0,e2=1,e3=1`. The captured same-cycle upstream snapshot is `root_v=0, vt_q=0, cap=1, a_cap=1, q_cap=0, vt_rl=1, vt_sub=122, kq=0x66, kh=0, kt=6, sen=1, s_init=0`. This snapshot does not include preceding root/valid pulse history and does not establish the root cause.
- For LANES=8, the reviewed tail delays are 7 and 14 PE cycles; the observed overlap is consistent with two accepted valid events seven cycles apart, while the A-row spacing contract requires multiples of RL=8. Root scheduling, Q/A-kind FIFO alignment, and stream grant/reset phasing remain competing hypotheses, not findings.
- The next diagnostic must be passive, plusarg-gated and confined to the temporary branch. Trace existing per-cycle signals only: root_v[0], kv_v, vt_q, cap/a_cap/q_cap, vt_rl/vt_sub, kq/kh/kt, sen/s_init, e2/e3. Do not add sequential counters/registers that can perturb `--x-initial unique`. Correlate FIFO enqueue/dequeue and root-valid pulse history. Preserve/flush failure evidence. No assertion weakening, reset masking, pipeline-depth changes or production RTL fix before the cause is demonstrated.

### Preserved verification evidence and limitations
- ASIC AW/AR configuration run `45916680920`: PASS for the tested integration and expected invalid-address rejection cases; width-warning inventory remains open.
- Scoped RTL-tail run `45916680719`: 33 passed, 1 documented skip, 196 deselected; not a full-suite pass.
- Reset audit `45916680730`: PASS for its tested configurations.
- Qwen checkpoint RTL run `45916680844`: 6 passed; companion tiny board-model selection 8 passed. This is not evidence of fine-tuning or full deployment.
- Board-functional run `45916680721`: 198 passed, 8 skipped, 1 deselected; PyTorch-dependent cases were skipped.
- Full-chip lint `45916680866`: zero errors, but 86 warnings remain: 52 WIDTHEXPAND, 24 WIDTHTRUNC, 7 procedural LATCH diagnostics, 3 UNOPTFLAT.
- WAITC remainder run `45963867548`: three jobs terminal SUCCESS; combined remainder evidence records 33 passed and 1 optional torch-dependent skip. Original waits run `45916680756` was cancelled; do not label that original workflow a standalone full pass.
- Subsystem/memory run `45916680829`: 13/14 jobs successful; QHL job failed the random-power-up case. Keep QHL OPEN.
- PPA run `45877786710`: confirmed host OOM at ORFS floorplan PDN; no valid PPA metrics. No retry authorised.
- Structural/reset, formal/SVA, CDC/RDC, DFT, SRAM technology mapping, production memory/host interfaces, routed physical signoff and manufacturer G0–G15 gates remain open or scoped as documented. Manufacturer handoff is **NOT READY**.

### Non-negotiable operating constraints
- Zero spend; no paid compute, PPA, fabrication or test booking without explicit approval.
- No duplicate reruns of successful historical groups. Do not restart cancelled run `45765362426`; do not rerun historical RTL groups 3.1, 3.2 or 4 solely for confirmation.
- Preserve prior test evidence with exact run, commit, selection, skips and deselections. Never convert skipped/cancelled/deselected tests into passes.
- Do not claim that a free sample, sponsor, packaging, test coverage, custody or shipping arrangement is secured. IHP/university collaboration remains a feasibility route, not a confirmed offer.
- Keep the full AI-X architecture distinct from a compact first-silicon demonstrator; do not silently reduce the product architecture to match the demonstrator.

### Next work sequence
1. Resolve live feature-branch and main SHAs before further edits; verify no concurrent branch movement.
2. Inspect the isolated diagnostic branch and finish the passive plusarg-gated QHL trace. Run only the narrowly justified diagnostic test; do not touch the active production branch until evidence is conclusive.
3. Classify the QHL failure as tree scheduling, FIFO ordering/alignment, stream grant/reset phasing, or another evidence-supported cause. Then implement the smallest proven correction and a deterministic regression, if required.
4. Continue semantic lint-warning triage without blanket casts/suppressions; then progress RSUM producer metadata parity, formal/SVA, CDC/RDC, DFT, SRAM mapping and physical-readiness gates.
5. Update this checkpoint, addendum, integrated plan, tracker and handoff matrix with exact commit/test evidence after each meaningful milestone.
6. Keep manufacturer handoff NOT READY until all mandatory gates and a documented zero-cost fabrication/testing path are independently evidenced.

This handoff records the latest evidence available in this conversation. It does not claim that the QHL trace was completed, that any new test passed, or that RTL was changed. Documentation-only updates do not constitute engineering verification.


## Continuation update — board evidence reconciliation, Qwen checkpoint verification and isolated STREAM recovery
**Supersession notice:** The QHL diagnostic work described as pending in the original 0137 addendum was subsequently completed for the targeted seed-1 assertion case. Use the newer QHL disposition in the current checkpoint and integrated plan. This addendum now records the later board/Qwen/STREAM evidence as follows.
### Board-functional evidence reconciliation
- Earlier board-only workflow run `45916680721`, tested commit `600f3aa4822e18f03ba80d06ab86fd447189c126`, completed SUCCESS. Its exact pytest summary was `198 passed, 8 skipped, 1 deselected in 4192.79s`. Eight skips were because optional PyTorch was not installed; one test was deliberately deselected (`axil_iso_resets_apart`). Artifact `15165798436` (`sunnyone-board-functional-only-log`).
- Later run `46016022808` on `672a4fc13f9f708582f4fca0462a32363654ff93` was CANCELLED; it did not produce a new board result.
- Commit comparison `600f3aa...672a4fc` shows the only RTL source file changed in that interval was `rtl/vpu/otpu_se_tail.sv`; the change was the simulation-only reset qualification of an assertion, with no datapath/functional logic change. All other compared changes were docs/workflow files. Therefore the earlier 198-pass board evidence remains useful for the unchanged board-functional scope, but is not an exact-current-commit rerun. Do not rerun the ~70-minute board suite solely to reconfirm; retain the exact tested SHA and limitation.

### Real Qwen checkpoint evidence
- Qwen verification workflow `46016022711` completed SUCCESS on commit `672a4fc13f9f708582f4fca0462a32363654ff93`, after downloading and checksum-verifying real Qwen3-0.6B and Qwen3.5-0.8B safetensors checkpoints (1,503,300,328 and 1,746,942,600 bytes respectively).
- Board RTL selection: `tests/test_models_on_board_rtl.py -k "qwen3 or qwen35"`: 6 passed, 4 deselected.
- Board model selection: eight Qwen3 board-model cases including two-slice, generation and four-slice WG cases: 8 passed, 199 deselected.
- Artifact `15213496541`. This is evidence for the tested checkpoint/model/board-simulation configurations, not a physical FPGA measurement, silicon benchmark, model fine-tuning result, or production throughput claim.

### Full-chip lint interpretation
- Run `46016022722` completed SUCCESS for the full-chip Verilator lint command, artifact `15206381709`. The command uses `-Wno-fatal`; success means lint completed, not that warnings are cleared.
- The log retains 79 width warnings and three UNOPTFLAT warnings (`gnt`, `sc_gl`, `pq`) plus seven LATCH diagnostics in simulation-only sequencer oracle blocks. The existing lint triage classifies the seven LATCH warnings as excluded by `SYNTHESIS`; `pq` and `sc_gl` remain probable but unproven tool-dependency over-approximations; `gnt` remains unresolved/high priority. ASIC-config `aok` and AW/AR width findings remain separate open items. No blanket waiver or warning suppression is approved.
- Static source review of VPU row-sum buffer indices confirmed legal RDOT buffer use is restricted to rows <= 256 and the flush write condition bounds the active rows. The wider index diagnostics are still OPEN pending a robust hardware-side invalid-input/bounds proof and directed boundary tests; no cast/narrowing change was made.

### Isolated STREAM software recovery
- The previous software-core run `46016022887` failed only at Verilator installation on the Ubuntu 26.04 runner because the Microsoft package repository returned HTTP 403. The stream pytest module never ran; the other 14 software modules succeeded.
- Added `.github/workflows/sunnyone-stream-software-only.yml` in commit `5ef0c28bdbbb1e8b2b7219b5d37d24e0d6d8a942`. It isolates `tests/test_stream.py`, uses Ubuntu 24.04, builds pinned Verilator 5.044 from source, and deliberately does not rerun the other 14 modules or RTL matrices.
- Run `46037445046` was automatically triggered by that workflow-file-only commit. At the time of this checkpoint, its sole job `140636330408` was still IN_PROGRESS at step 4 (pinned Verilator build); the Python dependencies and STREAM pytest steps had not started. Do not claim a STREAM result until this run is terminal and its log has been inspected.

### Current gates and next actions
1. Poll run `46037445046`; if it passes the build, inspect the exact `tests/test_stream.py` pytest summary. If build fails, inspect the failing step before revising the workflow; do not rerun the 14 successful software modules.
2. Preserve the board result as `198 passed, 8 skipped, 1 deselected` at SHA `600f3aa...`; do not rerun solely because run `46016022808` was cancelled, since the intervening RTL change is assertion-only.
3. Continue unresolved `gnt` dependency graph and width/bounds triage with exact elaborated configurations; no speculative RTL edits.
4. Continue formal/SVA, CDC/RDC, DFT, SRAM technology mapping, production PCIe/SerDes and DMA/IOMMU, DDR controller/PHY/training/ECC, routed physical signoff, and demonstrator down-select.
5. Manufacturer handoff remains **NOT READY**. No sponsor, no-cost fabrication, packaging, test, custody or shipping commitment is confirmed. No paid work is authorised.


## Continuation update — isolated STREAM regression completed (2026-11-27, Asia/Dhaka)

- Isolated workflow run **46037445046** completed SUCCESS on source commit **5ef0c28bdbbb1e8b2b7219b5d37d24e0d6d8a942**; job **140636330408** completed all setup/build/test/upload steps.
- Pinned Verilator 5.044 source build succeeded on Ubuntu 24.04; project/test dependency installation succeeded.
- Actual pytest log confirms **46 passed in 1183.29 seconds** for tests/test_stream.py. This closes the previously NOT RUN STREAM software-only module for that exact source/configuration. Artifact **15220041192**, name 'sunnyone-stream-software-only-log', ZIP SHA-256 'b4f0d0ccc61f752d8a39eaaa37c40e51ef92913796058aa2ccbcab4abd58b872'.
- This isolated workflow did not rerun the other 14 successful software-core modules, any RTL regression groups, board suite, Qwen suite, or PPA. No duplicate tests were launched in this continuation.
- QHL evidence remains as previously recorded: active-branch exact seed-1 regression passed 1 test on tested commit 'e123b331582495e12e7f32f81472011f0929c2cb'; subsystem QHL job in run '46016022758' passed 7 tests. Do not extrapolate to all seeds or all power-up states.
- Board-functional evidence remains the earlier '198 passed, 8 skipped, 1 deselected' on tested commit '600f3aa4822e18f03ba80d06ab86fd447189c126'; cancelled run '46016022808' is not a pass and is not a reason to repeat the long board suite absent a specific coverage gap.
- Latest live compare confirms the feature branch is **1,050 commits ahead, 0 behind** the unchanged main baseline 'd84db55712aba0d40811d7762cb052f05d55b7e5'. The compare integration did not expose the feature HEAD SHA; do not infer it from an older checkpoint. Re-resolve the branch ref before any future write if the exact HEAD is required.
- The STREAM workflow file was reviewed: it is restricted to the active feature branch, builds pinned Verilator 5.044, and runs only tests/test_stream.py. No workflow change is required from this successful result.
- Open gates remain: semantic width-warning closure; exact UNOPTFLAT dependency analysis (especially gnt); formal/SVA, CDC/RDC, DFT, SRAM technology mapping; production PCIe/SerDes, DMA/IOMMU and DDR controller/PHY/training/ECC; routed physical signoff; Track B demonstrator down-select and verified sponsorship/sample logistics. Manufacturer handoff remains **NOT READY**.
- Zero-spend remains mandatory. No PPA retry, fabrication, packaging, lab test, paid compute, or hardware purchase is authorised. Protected main remains untouched.
