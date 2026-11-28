# SUNNYONE — Current Continuation Checkpoint
Last updated: 2026-11-27 (Asia/Dhaka)

## Start here in every new chat

Read this file first, then:
1. docs/sunnyone/INTEGRATED_ENGINEERING_AND_SPONSORED_SILICON_PLAN_2026-11-27.md
2. docs/sunnyone/PROJECT_TRACKER.md
3. docs/sunnyone/MANUFACTURER_HANDOFF_READINESS_MATRIX.md

Then verify live branch HEAD, main SHA/protection metadata and current workflow states before acting.

**User continuation command:** “Continue and complete the remaining tasks.”

## Repository and branch controls

- Repository: shamiursunny/openTPU
- Active branch: sunnyone/commercial-profitability-architecture-2026-11-23
- Branch HEAD at start of this continuation: ee5eafecd38e82d99c62cd83f5f981230d522171
- Main SHA at start: d84db55712aba0d40811d7762cb052f05d55b7e5 — never modify.
- Plan document commit: 86162c5113da62ad3069d6ef8eff1233390d27f5
- Main branch protection was previously observed by GitHub API as disabled; this is a control gap, not permission to touch main. Recheck metadata when possible.
- Zero-spend default. No paid services, hardware, foundry, IP licence, cloud runner or packaging/test expenditure without explicit user approval.
- User cancelled Actions run 45765362426; never restart it.
- RTL groups 3.1, 3.2 and 4 already passed historically; do not rerun solely to reconfirm.

## New governing plan

docs/sunnyone/INTEGRATED_ENGINEERING_AND_SPONSORED_SILICON_PLAN_2026-11-27.md

This is now the governing integrated engineering/manufacturing strategy. It preserves two linked tracks:
- Track A: the full programmable SUNNYONE inference-accelerator product architecture.
- Track B: a separate, small first-silicon demonstrator derived from proven existing RTL only after source, PDK, area, timing, testability and sponsorship feasibility review.

Do not silently shrink or replace Track A to fit an MPW shuttle. The first demonstrator is not the complete product and cannot be used to claim full-product silicon validation.

The current architecture baseline remains:
- host-server control plane (no on-chip CPU/boot ROM in current first-version baseline);
- tiled matrix engine;
- vector/SIMD datapath;
- local SRAM scratchpads and DMA;
- defined host/compute/memory interconnect;
- external ECC-capable memory path, with production controller/PHY/training still open;
- programmable runtime/kernel layer.

The Versal VC1802/VSVD1760 is a separate feasibility lead, not the IHP ASIC target or selected production part. 128 GB ECC DDR4 remains a hypothesis; 256 GB remains stretch-only. User retired the former 30 W hard ceiling; derive power from measured performance and economics.

## Verification results independently re-polled 2026-11-27

All listed workflow jobs are terminal. Actual job logs were inspected for selected summaries. No new CI run was launched.

### Subsystem/memory — workflow 45845758545 SUCCESS

All 14 jobs terminal SUCCESS; actual totals:
- MX multiply/replay: 17 passed
- Quantizer corners/tie rounding: 8 passed
- Quantizer modes: 15 passed
- Collective hub/DMA/scoreboard: 128 passed
- QST/QSTB: 13 passed
- SPLITQ: 5 passed
- Instruction cache: 23 passed
- Address-window: 20 passed, 1 documented skip
- FP RTL: 8 passed
- QHL: 7 passed
- Stream RTL: 14 passed
- Wait-state RTL: 11 passed
- Reset audit: 4 passed
- Native DRAM/technology RAM: 104 passed
Combined selected-job total: 377 passed, 1 documented skip.

### Software/ISA/host — workflow 45845758659 SUCCESS

All 15 jobs terminal SUCCESS; actual pytest totals: 825 passed, 3 skipped:
FP 12; MX 32; compiler 44; ISA 18; kernels 46; VOPS 101; waits 268 passed/2 skipped; stream 46; formats 13; quant 81; dataflow 27; WAITW 6; host 108 passed/1 skipped; host-runs 18; host-lock 5.

### Board / RTL tail / ASIC / Qwen

- Board-functional workflow 45845758677 SUCCESS: 198 passed, 8 skipped, 1 deselected. Artifact 15137400985; SHA-256 d0adc900e0ef37ecec1f2715a555e0e822306a79b01bb562b1bbfa23d4f8f9d8.
- RTL-tail workflow 45845758636 SUCCESS: 33 passed, 1 intentional skip, 183 deselected. Artifact 15132004314.
- ASIC/four-DIMM workflow 45845758681 SUCCESS. Logs show four-DIMM host/accelerator AW/AR contention, arbitration, W ordering, B/R ID routing, backpressure, 1/2/4/8-beat reads/writes, partial/zero strobes, response codes, 4-KiB boundaries, out-of-aperture rejection and global address-map checks passing. Artifact 15130743611; SHA-256 dc0a587493b7b9ca44355fbeb312798b3ef853e2f39e4fecb4ef35c345251863.
- Qwen workflow 45845758847 SUCCESS. Official Qwen3-0.6B/Qwen3.5-0.8B checkpoints and checksums verified; real-checkpoint RTL tests 6 passed/4 deselected; tiny board-model tests 8 passed/199 deselected. Artifact 15136893309; SHA-256 223804db48d7010633764082a0814e4237a36055aab652f22d5c2f4d069ac7d2.

### Lint — workflow 45845758782 SUCCESS, warnings remain

Verilator 5.032 full-chip lint completed. Open warnings:
- 52 WIDTHEXPAND
- 27 WIDTHTRUNC
- 7 LATCH
- 3 UNOPTFLAT

LATCH warnings are in conditional local temporaries in rtl/seq/otpu_seq.sv; actual latch-cell presence/absence not proven. UNOPTFLAT paths involve gnt, sc_gl and pq. Separate ASIC compile reported an additional aok combinational-cycle warning in rtl/top/otpu_slice.sv around line 906. No blanket warning suppressions. Artifact 15130078429; SHA-256 6a1f1639094cfe3d8c800d4f9bd923375fa4dc613b0cb6c1e4f5c9244c6b8d75.

### PPA — workflow 45845758658 FAILURE

Pinned ORFS image sha256:edbd355068b742c5ae2413a49a58578465bd52f57668cebebdd383eb4d97607d. Synthesis and preliminary floorplan timing reporting completed; OpenROAD exited code 247 during 2_1_floorplan. Peak RSS 15,191,368 KB. Root cause is not confirmed; do not assert OOM. Artifact 15137952036; SHA-256 66d8e83e4f5da5ee5b11be80e851ecfe04f6b801857ef9ee3d786246af47f560.

Pre-route wire-load report: WNS 0.00 ns, TNS 0.00 ns, worst slack +0.46 ns, minimum period 2.04 ns / 489.55 MHz. Not routed STA/signoff. Synthesis proxy area 30,786,988.162 µm², not die area. Earlier baseline 45545698546 had WNS -10.43 ns, TNS -91.46 ns, 12.93 ns / 77.31 MHz and also failed later in physical flow. No timing closure or single-change attribution claim.

### DMA experiment and prior exclusions

Source SHA 2835f1a8da6af454023caff9576f41258c66e2a8 contains six SRX stream-setup constant-divisor rewrites. Exhaustive mathematical checks covered su_ns 0–63, both selector states and SPC 1,2,4,8,16,32. Not formal RTL equivalence; timing improvement not established.

Preserve historical successful groups 3.1, 3.2 and 4. Do not restart user-cancelled run 45765362426.

## PPA workflow instrumentation

Workflow .github/workflows/sunnyone-asic-wg8-ppa.yml was changed in commit 783dc91d835b66279fc69ca0dd82ee3a9c403785 (blob 9d6025838eb01dc7ae93d7f7671e7b5be066ec33):
- Docker CPU quota explicitly set with --cpus 2 plus ORFS_CPUS=2.
- Host resource baseline and periodic cgroup v1/v2 memory telemetry added.
- Telemetry archived with PPA artifact.

This is instrumentation only; no diagnostic PPA rerun has been launched. Review syntax and artifact/cleanup behaviour first, then dispatch only if justified.

## Manufacturer/sponsorship strategy — important correction

IHP remains the first technical organisation to approach for a **written fully sponsored research collaboration**, but free fabrication is NOT confirmed:
- Historical FMD-QNC free MPW documentation lists runs through September 2025 and says continuation for open-source community was to be worked out.
- Published 2026 IHP SG13G2 (29 Sep, registration 21 Sep) and SG13CMOS5L (9 Nov, registration 26 Oct) dates are past.
- Current IHP low-cost route lists approx. EUR 2,800/mm² SG13G2 and EUR 1,500/mm² SG13CMOS5L; 20 bare dies basic offer; packaging extra; approx. 8/6 months processing. Not authorised under zero-spend rule.
- IHP open SG13G2 PDK is Early Access/alpha; SG13CMOS5L is preview; neither is represented as production-ready.
- A university/research institute may be the eligible sponsor/lead applicant, but no affiliation or eligibility is assumed.

A zero-cost agreement must explicitly cover MPW area/fabrication, dicing, packaging, board/fixture, physical testing, report/data, sample custody/delivery to Bangladesh, shipping/customs/taxes and all other fees. Historical IHP documentation described samples being retained for joint evaluation/rental, so physical sample access and shipping are mandatory questions. Do not assume free fabrication includes packaging/testing/shipping.

No private RTL/GDS or confidential data should be shared before licence, publication, IP and export-control terms are understood.

## Immediate next actions

1. Update PROJECT_TRACKER.md with this plan and evidence re-poll.
2. Re-fetch this checkpoint, plan, tracker and readiness matrix; record exact blob SHAs and final branch HEAD.
3. Review PPA workflow syntax and artifact/cleanup behaviour; no retry until justified.
4. Prove actual latch-cell presence/absence and trace full-chip/ASIC UNOPTFLAT paths.
5. Triage all 79 width warnings, including the ASIC AW/AR 34-bit to 33-bit port connection warnings.
6. Expand formal/SVA and CDC/RDC evidence.
7. Inventory existing RTL and down-select a compact first-silicon demonstrator without changing Track A.
8. Verify IHP PDK compatibility and ask IHP/university partners about eligibility, next intake, full sponsorship, physical test, sample access and shipping.
9. Only create a dedicated demonstrator integration/port after source, PDK, area, timing, test and sponsor feasibility gates.
10. Continue the full product architecture and manufacturer G0–G15 readiness gates.

Manufacturer handoff remains **NOT READY**. No RTL was changed and no tests were rerun in this continuation. All results above are bounded historical evidence on their recorded source/configuration and do not establish formal/CDC closure, routed physical signoff, production interfaces, measured silicon performance or qualification.


## Documentation save confirmation — 2026-11-27

- Integrated plan file was created in commit 86162c5113da62ad3069d6ef8eff1233390d27f5.
- This checkpoint file was created in commit 20520d921edc8c3b1e46426ba7b674f70322695e.
- PROJECT_TRACKER.md section 104 was appended in commit ea61fc2c16ae3d77df65927d846bc8b0ce51450c.
- Latest tracker blob after section 104: e567d08e2e350d937a56d7e87018b14960f56552.
- The final checkpoint/tracker/plan blobs and live branch HEAD must be re-fetched after this save and recorded in the next continuation entry.


## Final repository verification for this save

Re-fetched all saved documents from the active branch after the tracker update:
- Integrated plan blob: 4a031101b9c6a295e1c78a4a54cac401ab5d7ffa.
- This checkpoint blob before this final metadata append: 64232b271fa373a2142550938bd273da0b2d081b.
- Project tracker blob after section 104: e567d08e2e350d937a56d7e87018b14960f56552.
- Manufacturer handoff matrix blob: 1adb9b22b4037c60e6dc89c6127a2b1762c369c3.
- Live feature branch HEAD at the verification poll: e7d68d2618fa5008856472a288a443fddee779dc.
- Live main remains d84db55712aba0d40811d7762cb052f05d55b7e5.

The plan, checkpoint and tracker are present on the feature branch. No RTL/test/workflow source was changed in this documentation save. No tests were relaunched. The latest branch HEAD must be re-polled at the beginning of the next continuation.


## Latest engineering continuation — immutable PPA toolchain pin

- Reviewed the failed PPA workflow job log. The old workflow pulled openroad/orfs:latest, then captured local image ID sha256:edbd355068b742c5ae2413a49a58578465bd52f57668cebebdd383eb4d97607d. The registry manifest digest resolved in that run was sha256:f5b2b4ac8cae150c30ad86857328300e20662cf7ff555978711ea8936f8d9539.
- Corrected .github/workflows/sunnyone-asic-wg8-ppa.yml in commit e2d96d5364af47503d67cb70635bf3485cbe9b33 (blob 426cfcc62ac4ca1d90cf52b06a0e9009b83a1c29). It now pulls the immutable manifest digest, verifies the resolved image ID exactly, and archives both the image reference and ID. Docker --cpus 2 and cgroup telemetry remain.
- Updated the integrated plan with this correction in commit 57772f70dd335ec519f38e6f3ed75e392122bd61 (blob 7b826a30775e51e5f80ef567713213d8f4ec414c).
- No PPA diagnostic run has been dispatched. The change improves reproducibility but does not resolve the prior Error 247 or establish OOM. Next review the exact updated workflow, then decide whether a single diagnostic dispatch is justified.


## Latest lint triage — 2026-11-27

- Created docs/sunnyone/LINT_AND_COMBINATIONAL_PATH_TRIAGE_2026-11-27.md in commit e18c5715f11146b0795642251f958d71b9ff1229.
- Source review confirms all seven LATCH diagnostics in rtl/seq/otpu_seq.sv occur inside ifndef SYNTHESIS diagnostic code; the ASIC synthesis flow defines SYNTHESIS. They are simulation-only and not evidence of hardware latches. Do not change functional RTL to silence them. A synthesized-netlist latch-cell check remains open.
- pq: likely guest-to-host aliasing false positive; generated g_copy/g_guest mapping and host_of(p) function imply one-way guest-to-owner mapping. Confirm in elaborated netlist.
- sc_gl: likely process-level dependency over-approximation; cgl_c calculation itself does not read coll_gnt, although the same always_comb process assigns gnt_c[G_COLL] from coll_gnt. Confirm in elaborated graph before splitting.
- aok: likely vector-level dependency over-approximation; priority logic reads only earlier indices h<g. Confirm per-bit graph.
- gnt: remains unresolved and highest priority. The Verilator example path reaches the VPU delay enable, but the actual combinational return path has not been proven. Resolve exact parameters and SCC/netlist graph; no register insertion or grant restructuring without proof.
- Updated MANUFACTURER_HANDOFF_READINESS_MATRIX.md G3 notes in commit 0a3f947610157359f28531f6d0bb6d9ede6b145f; G3 remains OPEN due UNOPTFLAT and width-warning work.
- Updated integrated plan with source-level lint triage in commit 8ba5ded36e6eb52dde43b7f6f25ee7641a694e10.
- No RTL changes and no new tests launched. Existing functional evidence remains unchanged.


## Latest width-warning inventory and risk triage — 2026-11-27

- Created docs/sunnyone/WIDTH_WARNING_INVENTORY_2026-11-27.md in commit c198c07a2896c307b7af4c9f52975442516b86b7. It contains all 79 raw width warnings from full-chip lint run 45845758782, grouped by source file and exact line/column.
- Cross-checked source ifndef SYNTHESIS regions: nine warning instances are in simulation-only code and marked SIM_ONLY; they are not ASIC hardware-width defects. They remain in the simulation lint inventory, not waived.
- The other 70 remain OPEN pending semantic and exact-synthesis-source review. The two otpu_dram exists() warnings are in the simulation DRAM model and need confirmation against the exact ASIC source list before classification.
- High-priority possible bounds risks recorded:
  1. VPU row-sum buffer rb[NRB/LANES] indexed by rows_done[15:LW] and fl[15:LW]; prove every write/read is within 0..NRB-1 and final-cycle behaviour. RDOT has rows<=NRB gate; FSUM validation currently appears simulation-only and needs hardware input-contract review.
  2. Sequencer four-entry LOOP stack uses 3-bit sp; ISA says nesting depth 4, but push site has no visible sp<4 guard. Prove host/program validation or add safe overflow/error behaviour.
  3. VPU 24-bit one-hot function mask uses wider VOP indices; prove all enum indices are 0..23 before narrowing.
  4. MXU drain/key arrays use wider indices; prove bounds before narrowing.
- Updated MANUFACTURER_HANDOFF_READINESS_MATRIX.md G3 and width-warning note in commit 7bbf853230f591e314ec9307d0f1277be4ac996f. Updated integrated plan in commit 95230c32013be1780a6980eaaac717123a3d562d.
- No RTL changes, no new tests. Width warning closure is not claimed; G3 remains OPEN.


## Active RTL correction and CI status — 2026-11-27

### Sequencer LOOP stack guard
- Found that docs/isa.md specifies maximum nested LOOP depth 4 and opentpu/isasim.py rejects a fifth non-zero nested loop with SimError("loop stack overflow"), but rtl/seq/otpu_seq.sv had no visible push-site guard before indexing four-entry arrays with 3-bit sp.
- Added sp >= 3'd4 error/halt guard and used sp[1:0] for the legal array index in commit 28c36c52204fe2ec2ed36413b02eb6043506ccc4.
- Added two RTL tests in tests/test_rtl.py in commit c22c9b1be497b62253693e817d7d3b5fdca1c79f: maximum legal depth four and fifth-level overflow rejection.
- Added dedicated workflow .github/workflows/sunnyone-loop-stack-guard.yml in commit 275728cd1484fb3b409ba59b9b409f29160c8f7e. Run 45877985241 is IN_PROGRESS. Do not call the fix verified until both tests pass in the archived log.

### Lint delta
- Full-chip lint run 45877786797 SUCCESS on source SHA 28c36c52204fe2ec2ed36413b02eb6043506ccc4.
- Actual log has 76 width warnings: 52 WIDTHEXPAND and 24 WIDTHTRUNC, down from the 79 baseline. Three WIDTHTRUNC diagnostics on the sequencer stack index were removed by the guard and sp[1:0] indexing.
- Seven simulation-only LATCH diagnostics and three UNOPTFLAT diagnostics remain. G3 stays OPEN.
- Updated width inventory in commit 0d661732a6c2308dc6cab3bb1ad9294290a8707c; updated manufacturer matrix in commit 2e9483051738ea09ab494b4c5217e1c6972e56ad; updated integrated plan in commit f93dfdd58dfcf7e07035ba7afa3de62517631e2b.

### Source-triggered workflow set
- WG8 PPA run 45877786710 IN_PROGRESS on source SHA 28c36c52204fe2ec2ed36413b02eb6043506ccc4; it should use the immutable ORFS digest and cgroup telemetry. Verify logs/artifacts after completion. No second PPA run while active.
- Reset audit 45877786738, Qwen RTL 45877786754, board functional 45877786742, subsystem/memory 45877786699, software/ISA 45877786705 and ASIC config 45877786860 are IN_PROGRESS or queued on the same source SHA.
- Tail run 45877787004 was cancelled by the newer test commit; replacement run 45877807906 is IN_PROGRESS on c22c9b1be497b62253693e817d7d3b5fdca1c79f.
- Separate 128K one-copy TMEM investigation run 45877807985 is IN_PROGRESS on c22c9b1be497b62253693e817d7d3b5fdca1c79f.
- Do not restart cancelled historical run 45765362426. No additional duplicate runs should be launched while these are active.


## Completed targeted verification — 2026-11-27

- Loop-stack guard workflow 45877985241 completed SUCCESS on commit 275728cd1484fb3b409ba59b9b409f29160c8f7e. Actual log: 2 passed, 217 deselected, 47.52 seconds. Both test_loop_stack_maximum_legal_depth_four_rtl and test_loop_stack_overflow_reports_error_before_out_of_range_rtl passed. Artifact 15146995084; ZIP SHA-256 bc7202d01bf896453a2fdd8e3f752d34e719e85db9ddc582ebcba0196380b7ff.
- This verifies the legal four-level stack and fifth-level overflow error/halt under the targeted RTL simulation. It does not establish all sequencer behaviour or full design signoff.
- Isolated 128K one-copy TMEM workflow 45877807985 completed SUCCESS on commit c22c9b1be497b62253693e817d7d3b5fdca1c79f. Actual log: 2 passed, 217 deselected, 75.03 seconds.
- Full-chip lint 45877786797 SUCCESS on RTL source 28c36c52204fe2ec2ed36413b02eb6043506ccc4; 76 width warnings remain (52 expand, 24 truncation), down from 79.
- PPA run 45877786710 remains IN_PROGRESS on source 28c36c52204fe2ec2ed36413b02eb6043506ccc4. It is the single diagnostic run with immutable ORFS manifest pin and telemetry. Do not start a second PPA run.
- Plan updated with these results in commit d79f7592703a2706a74cd8438e2671f2d4944aab.


## Final saved-document inventory and current CI snapshot — 2026-11-27

Latest document blobs fetched from the working branch before this checkpoint update:
- Integrated plan: 90c656cb735655c38f7ab6e96a7edaa29d273d05
- Project tracker (sections 104–110): 0f8e552a7946280e37e4a35fd1a3c2edb8d8a751
- Manufacturer readiness matrix: 8e7470cbaf9d4d96ba9c41e161f2bf417f47810b
- Width warning inventory: 4fd253d55c329e3faab17f74b1dc15299b38337a
- Lint/combinational-path triage: c2298f2f5683b03d8cf7e115906d5aa22ba4d055
- Immutable ORFS PPA workflow: 426cfcc62ac4ca1d90cf52b06a0e9009b83a1c29
- Dedicated loop-stack workflow: fa13f1a7b8984c21006a8a24c279209985812024
- Prior checkpoint blob before this inventory append: f2d82f0d13f41404daa4bb97d72f19d3917f1988

Current key CI evidence:
- Loop-stack guard run 45877985241 SUCCESS: 2 passed, 217 deselected; artifact 15146995084.
- Isolated 128K one-copy TMEM run 45877807985 SUCCESS: 2 passed, 217 deselected.
- Full-chip lint run 45877786797 SUCCESS on source 28c36c52204fe2ec2ed36413b02eb6043506ccc4: 76 width warnings (52 expand, 24 truncation), 7 simulation-only LATCH, 3 UNOPTFLAT.
- WG8 PPA run 45877786710 remains IN_PROGRESS on source 28c36c52204fe2ec2ed36413b02eb6043506ccc4. It is the only active diagnostic PPA attempt; verify immutable image and telemetry from its final logs/artifact.
- Reset audit 45877786738, Qwen 45877786754, board 45877786742, subsystem/memory 45877786699, software/ISA 45877786705, ASIC config 45877786860 and RTL-tail 45877807906 remain IN_PROGRESS or queued at last poll. The 128K TMEM and loop-stack focused runs are complete.
- Main remains d84db55712aba0d40811d7762cb052f05d55b7e5. No main modifications.

No additional RTL changes are planned until active workflows are reconciled and the VPU row-buffer bounds, remaining width warnings and gnt structural path are reviewed. Manufacturer handoff remains NOT READY.


## 17. Bounds-contract and PPA CPU propagation review — 2026-11-27

### FSUM row-buffer bound: OPEN for hardware protection

- Source review of `rtl/vpu/otpu_vpu.sv` confirms the row buffer is `rb[NRB / LANES]` with `NRB = 256`; write and flush indices use `rows_done[15:LW]` and `fl[15:LW]` (around lines 1441–1462).
- RDOT has a synthesizable selection guard: `rdb_i` is true only for `V_RDOT && rows <= NRB && drs == 1` (around lines 1860–1870); larger/non-unit-stride RDOT sums bypass the buffer.
- FSUM's `rows <= NRB` rejection is in the `ifndef SYNTHESIS` assertion block (around lines 2073–2078). It is not a hardware guard. The FSUM back-end buffers every FSUM row while `fs_b` is active, so an out-of-contract row count could exceed the 256-row buffer.
- This is relevant to enabled configurations: `targets/bcu1525-wg.toml` and `targets/bcu1525-x2.toml` explicitly set `FSUM = true`. Other current target files omit FSUM, whose default in `opentpu/target.py` is false.
- Software checks exist: `opentpu/isa.py` defines `FSUM_MAX_ROWS = 256`; `opentpu/isasim.py::_fsum_check` rejects larger rows; `opentpu/compiler.py::fuse_exp2_rowsum` and `isa.exp2sub_sum` enforce the shape. These checks do not constitute synthesizable protection against an invalid/raw program reaching the RTL.
- No functional RTL change is made in this review. Acceptance requires either (a) a synthesizable invalid-FSUM rejection using the design's established error/halt protocol, with a targeted RTL negative test on an FSUM-enabled target, or (b) a documented and independently enforced program-ingress contract that makes malformed FSUM instructions impossible. Do not rely only on `ifndef SYNTHESIS` assertions. Keep G1/G2 OPEN until resolved.

### PPA workflow CPU propagation mismatch: correction required after current run

- The PPA workflow at source SHA `28c36c52204fe2ec2ed36413b02eb6043506ccc4` sets `ORFS_CPUS=2` inside its pinned container and calls `python3 tools/asic/flow.py run nangate45-wg8`.
- The exact `tools/asic/flow.py` blob at that source SHA is `4154f6474e0cc03d8ee0e9398ca783e26a96acf4`. Its `run()` chooses `cpus = cpus or (os.cpu_count() if orfs else 6)` and passes `NUM_CORES={cpus}` to ORFS. It does not read `ORFS_CPUS`.
- Docker's `--cpus 2` still caps actual container CPU consumption, but ORFS's configured worker count may exceed two; therefore the claimed two-worker scheduler configuration is not established and oversubscription is possible. This is not evidence that it caused the previous Error 247.
- Current diagnostic run `45877786710` remains IN_PROGRESS on source SHA `28c36c52204fe2ec2ed36413b02eb6043506ccc4`. Its immutable image pin and host baseline steps passed; the pinned-container SRAM/ORFS step is still running. Do not cancel, supersede or start another PPA run. Wait for terminal status and archive the existing telemetry/artifact first.
- After the current run is terminal, correct CPU propagation by making `flow.py` consume and validate `ORFS_CPUS` (or passing an explicit `cpus` argument), add a focused test for the selected worker count, and verify the workflow's effective `NUM_CORES`. Any subsequent PPA dispatch requires a separate justification; do not automatically rerun.

### Live workflow reconciliation at this review

- `45877786738` reset/power-up audit: SUCCESS.
- `45877786860` ASIC/target configuration: SUCCESS.
- `45877807906` RTL tail: SUCCESS.
- `45877807985` isolated 128K one-copy TMEM: SUCCESS.
- `45877985241` sequencer LOOP stack guard: SUCCESS, 2 passed / 217 deselected.
- `45877786710` PPA: IN_PROGRESS; no artifact available yet.
- `45877786754` Qwen real-checkpoint RTL: IN_PROGRESS.
- `45877786742` board-functional: IN_PROGRESS.
- `45877786699` subsystem/memory: partially complete; several jobs remain queued or in progress.
- `45877786705` software/ISA: partially complete; several jobs remain queued or in progress.

No RTL was modified and no new workflow was launched during this review. Main remains untouched. Manufacturer handoff remains NOT READY.


## Latest live repository reconciliation — 2026-11-27

- Current branch HEAD before this documentation update: `50607be9d53a3e99aa5b90f8eb564e0e37df6930`.
- Protected-by-project-rule main SHA remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; GitHub API reports `protected: false`, so protection is a repository control gap. Do not modify main.
- Latest saved plan/checkpoint/tracker/matrix blobs before this update: plan `90c656cb735655c38f7ab6e96a7edaa29d273d05`; checkpoint `83f3b11ffdde4dff173e572439b88930108b786a`; tracker `0f8e552a7946280e37e4a35fd1a3c2edb8d8a751`; matrix `8e7470cbaf9d4d96ba9c41e161f2bf417f47810b`.
- New findings and the exact acceptance/closure steps are recorded in `INPUT_BOUNDS_AND_PPA_RESOURCE_CONTROL_REVIEW_2026-11-27.md` and section 111 of the tracker.
- No RTL changes or new workflows launched. Wait for the active PPA/Qwen/board and remaining matrix jobs; do not cancel or duplicate them. Correct `ORFS_CPUS` propagation only after run 45877786710 terminates.
- FSUM hardware bounds remain OPEN for the two FSUM-enabled BCU target configurations. Manufacturer handoff remains NOT READY.


### FSUM ingress follow-up — 2026-11-27

- `Board.load_program` in `opentpu/host/board.py` accepts raw uint32 program arrays and does not perform FSUM semantic validation before writing the program to DRAM/IMEM. The existing compiler and ISA-simulator checks are not a mandatory load-time validator.
- The FSUM bounds issue is therefore an unclosed end-to-end hardware safety risk on the two FSUM-enabled BCU targets. Trace `otpu_seq.error` and the established slice error/halt path before proposing a synthesizable rejection; `otpu_vpu` has no existing error output. No RTL changes made.


### Existing error/halt path traced — candidate guard location, not yet implemented

- `otpu_seq` exposes `error` and its existing invalid decoded-operation branch sets both `error <= 1'b1` and `halted <= 1'b1` before dispatch (around lines 1702–1705).
- `otpu_slice` connects `otpu_seq.error` to `sq_err` and exposes `error = sq_err || to_err` (around lines 355–366 and 437). The VPU itself currently has no error output.
- A candidate minimal architecture is to pass the slice's `VPU_FSUM` configuration into the sequencer and validate an FSUM-bearing VOP's decoded `cmd_t` before dispatch, reusing the existing sequencer error/halt path. The exact decoded-field timing and full FSUM contract still require a focused review; this is not an approved patch.
- Do not change `otpu_seq.sv` while PPA run 45877786710 is active: that file is in the PPA workflow path filter and the workflow uses cancel-in-progress concurrency. Wait for the current run's terminal result, then implement only with targeted boundary tests and an explicitly justified CI run.

## Latest live continuation addendum

Read `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-27_0137.md` immediately after this checkpoint. It contains the 01:37 Asia/Dhaka live workflow poll, FSUM hardware-bounds source review, and the exact next-action order. This addendum supersedes older in-progress workflow snapshots where run IDs overlap. Do not edit `otpu_seq.sv` until PPA run 45877786710 is terminal.


## Latest continuation review — 2026-11-27

Read `docs/sunnyone/CONTINUATION_REVIEW_2026-11-27_0145.md` after the 01:37 addendum. It corrects the stale ORFS_CPUS diagnosis after checking the current CLI path and records the latest live workflow poll and clarified FSUM ISA bounds. This is a documentation-only update; no RTL or tests were changed.


## Latest live reconciliation — 2026-11-27 05:17 Asia/Dhaka

### Live refs at the start of this documentation update
- Feature branch HEAD: f2594c3f34e21da99ef0192bb53668f7027e8939
- Main HEAD: d84db55712aba0d40811d7762cb052f05d55b7e5 (unchanged; never modify).
- GitHub API reports main protection disabled. The project rule remains strict: do not modify main.
- Latest document blobs before this checkpoint append: [{"path":"docs/sunnyone/PROJECT_TRACKER.md","sha":"beccbab00df3ec53ab0299849af9cb8007567e41"},{"path":"docs/sunnyone/INTEGRATED_ENGINEERING_AND_SPONSORED_SILICON_PLAN_2026-11-27.md","sha":"ae5761005df7b3ecd9dcb03942fae6874b3e9857"},{"path":"docs/sunnyone/MANUFACTURER_HANDOFF_READINESS_MATRIX.md","sha":"96445f264dbb5b56da16b2f64ffaa525651f6da7"},{"path":"docs/sunnyone/PPA_RESOURCE_DIAGNOSIS_2026-11-27.md","sha":"9b161716449e4a90227ce9b328d82be3de34fc20"}].

### Terminal workflow reconciliation
- PPA 45877786710: FAILURE; artifact 15152974135 inspected. Floorplan, macro placement and tap-cell insertion completed; failure occurred in 2_4_floorplan_pdn/check_placement. cgroup memory.max=max, peak 16,155,115,520 bytes, oom_kill=1, oom=0, oom_group_kill=0; host MemTotal 16,366,484 kB. This is a confirmed OOM-kill event and strongly supports host memory exhaustion, without an archived kernel victim-selection record. Do not repeat full-chip PPA on an equivalent 16 GB runner.
- Qwen 45877786754 SUCCESS: 6 real-checkpoint RTL tests passed (4 deselected) and 8 tiny board-model tests passed (199 deselected).
- Board 45877786742 SUCCESS: 198 passed, 8 skipped, 1 deselected.
- Subsystem/memory 45877786699: all 14 jobs SUCCESS; archived logs total 385 passed, 1 skip.
- Software/ISA 45877786705: all 15 jobs SUCCESS; archived logs total 825 passed, 3 skips.
- Reset 45877786738, ASIC config 45877786860, RTL tail 45877807906, isolated 128K TMEM 45877807985 and loop-stack guard 45877985241 SUCCESS. Loop-stack guard: 2 passed, 217 deselected.
- No new workflows launched, no workflow reruns, no RTL or test source changed.

### Corrections and remaining tasks
- The 01:37 ORFS_CPUS mismatch claim was corrected in the 01:45 review: the actual CLI reads ORFS_CPUS and passes 2 to run(); do not modify flow.py on that stale basis.
- Next engineering priority: synthesizable FSUM bounds guard and focused boundary tests. ISA contract: EXP2SUB+FSUM rows 1..256, cols >=64, B mode 0/1/2; scalar mode 3 forbidden; reject FSUM operations when the effective capability is disabled. Review RSUM take ordering separately.
- Then prove exact elaborated UNOPTFLAT/SCC paths; triage 76 width warnings and ASIC AW/AR width warnings; expand formal/SVA, CDC/RDC and synthesized-netlist latch checks; continue Track A and Track B separately.
- No spend. No main. No cancelled workflow restart. Do not repeat historical successful groups 3.1, 3.2 or 4.
- Manufacturer handoff remains NOT READY.

Full PPA evidence: docs/sunnyone/PPA_RESOURCE_DIAGNOSIS_2026-11-27.md.


### FSUM guard source review refinement — 2026-11-27

Current source review confirms the guard can be placed at the R-stage dispatch decision, before the existing `p_v <= 1'b1; p_cmd <= dcmd` handoff. The resolved `dcmd` fields are available combinationally before dispatch:
- `dcmd.op` is the opcode; FSUM applies only to `OP_VOP`.
- `dcmd.flags[2]` is `VF_FSUM`.
- `dcmd.w4[15:0]` is rows and `dcmd.w4[31:16]` is cols.
- `dcmd.w6[23:16]` is VOP func and `dcmd.w6[25:24]` is B mode.
- Package constants are `V_EXP2SUB=14`, `V_RSUM=16`, and `B_SCALAR=3`.
- The VPU's effective feature enable is exactly `VPU_FSUM != 0 && HAS_SS`; pass this same effective value into a new sequencer parameter, not the raw config bit.

Proposed R-stage rejection before dispatch:
1. For an OP_VOP with VF_FSUM set, accept only func EXP2SUB or RSUM; flag bit 2 is not defined for other VOP functions.
2. Reject both EXP2SUB+FSUM and RSUM+FSUM if the effective FSUM capability is disabled.
3. For EXP2SUB+FSUM, reject rows==0, rows>256, cols<64, or B mode==3. ISA has no upper cols bound beyond the 16-bit field; do not invent one.
4. Route every rejection through the existing `error <= 1'b1; halted <= 1'b1` branch and ensure it does not assert `p_v` or dispatch to the VPU.
5. Keep RSUM take ordering/pending-sum semantics as a separate review; do not add unsupported shape restrictions to the take.

Existing `tests/test_rtl.py::test_attention_decode_fsum_rtl` provides valid functional FSUM coverage, but not the malformed raw-command negative/boundary tests required here. Add focused RTL tests for legal 256x64/non-scalar, 257 rows, 63 cols, scalar B, FSUM-disabled EXP2SUB, FSUM-disabled RSUM, and flag-on-other-function; prove invalid commands halt with error before VPU dispatch. No source/test changes or tests were run by this review.


## 2026-11-27 continuation — FSUM hardware guard implemented and verified

Live branch HEAD before this documentation commit: ebd3e4c95d9adb027fe01b81342492e4bf7f4e9a. Protected main reference remains d84db55712aba0d40811d7762cb052f05d55b7e5 and was not modified. GitHub API currently reports main protection disabled; do not modify main.

### FSUM guard implementation
- New sequencer parameter FSUM is wired as VPU_FSUM != 0 && HAS_SS, matching the VPU's effective feature gate.
- R-stage guard rejects EXP2SUB+FSUM rows 0 or >256, cols <64, scalar B, unsupported FSUM-flagged VOP functions, disabled effective capability, and RSUM+FSUM take when no producer is pending.
- Synthesizable fsum_pending counter increments on EXP2SUB+FSUM dispatch and decrements on RSUM+FSUM take dispatch. It resets with the sequencer. HALT with nonzero pending count raises error and uses the stopping path.
- Valid RSUM+FSUM remains the take operation.
- Focused workflow 45911471194 SUCCESS: 11 passed, 219 deselected. It covered rows 0/257, cols 63, scalar B, disabled capability, HAS_SS false (LANES=4), unsupported function, unmatched take, HALT with pending sums, and legal 256x64 producer/take with output and sums checked.
- Full-chip Verilator lint 45911470968 SUCCESS: 76 width warnings (52 expand, 24 truncation), 3 UNOPTFLAT, 7 LATCH. Loop-stack boundary 45911470960 SUCCESS. Isolated 128K one-copy TMEM 45911470982 SUCCESS.
- Full report: docs/sunnyone/FSUM_HARDWARE_GUARD_REPORT_2026-11-27.md.

### Explicit remaining semantic gap
The sequencer counter validates pending-take count and HALT state, but does not yet store a FIFO of producer sum destinations and row counts. It therefore does not independently verify that every take matches the oldest producer's exact sum address and row count. ISA simulator does check the exact destination/row-count match. Keep this as OPEN hardware-vs-ISA parity work.

### PPA safety correction
The WG8 PPA workflow now requires a dedicated docs/sunnyone/PPA_EXECUTE_REQUEST.md marker and [RUN-PPA] in the push commit message; ordinary documentation, RTL and flow commits do not launch PPA. Manual workflow_dispatch remains available only as a deliberate, separately approved user action. No PPA run was launched. Previous OOM evidence remains authoritative.

### Current run set
On source commit ebd3e4c95d9adb027fe01b81342492e4bf7f4e9a: FSUM guard, full-chip lint, loop-stack and isolated 128K TMEM are terminal SUCCESS. Board-functional, Qwen, reset/power-up, ASIC configuration, RTL tail, subsystem/memory and core software/ISA workflows were still pending or in progress at the time of this checkpoint. Do not claim their outcomes until polled. The explicitly excluded RTL groups 3.1, 3.2 and 4 were not rerun.

### Next order
1. Width-warning fixes with explicit semantic/range proofs.
2. Structural SCC/netlist proof for gnt, sc_gl and pq.
3. ASIC AW/AR width warning closure.
4. Formal/SVA, CDC/RDC and mapped-latch checks.
5. PDK/macro/physical/DFT/board/manufacturer gates. Manufacturer handoff remains NOT READY.

No paid compute or hardware spending. No main changes. No PPA dispatch.


## PPA trigger incident correction — 2026-11-27

Correction to the preceding note: editing PPA_REQUEST.md itself initially triggered WG8 PPA run 45911873124. This was an assistant-authored workflow-control mistake. The run was cancelled at 23:37:04Z after approximately 73 seconds. Its retained artifact (15159964408; ZIP SHA-256 a5a1bea55d30b1b0e5721f2eae33049bd0003a1504c7925f84aa5e676c05ccf3) shows macro prep/config and Yosys 1_1_yosys_canonicalize only; no floorplan, placement, CTS, PDN or PPA report. cgroup peak was 894,529,536 bytes; OOM counters were zero. One minute of GitHub-hosted runner time was consumed; exact billing/quota cannot be established from this interface.

The corrected workflow is in commit 98335138bd73751699afc4a31ce0b206ff2720a1. Push paths are now docs/sunnyone/PPA_EXECUTE_REQUEST.md and the workflow file; a push job also requires [RUN-PPA] in the commit message. The correction run 45911965872 was SKIPPED and caused cancellation of the accidental run. PPA_REQUEST.md is documentation only. Do not create PPA_EXECUTE_REQUEST.md or use workflow_dispatch without explicit user approval of the exact source SHA.

Full incident evidence: docs/sunnyone/PPA_TRIGGER_INCIDENT_2026-11-27.md.


## Continuation state refresh — 2026-11-27 05:54 Asia/Dhaka

- Re-read this checkpoint, CONTINUATION_ADDENDUM_2026-11-27_0137.md, CONTINUATION_REVIEW_2026-11-27_0145.md, integrated plan, tracker, manufacturer readiness matrix, FSUM report and PPA trigger incident report from the active feature branch.
- Live compare before this documentation save: feature branch 917 commits ahead / 0 behind main; merge base and main SHA d84db55712aba0d40811d7762cb052f05d55b7e5. The compare response did not expose feature HEAD. Tracker update commit 18ebfc9e967b58cc85c766bb2e21cc1b032d5d5d is now the known branch tip immediately before this checkpoint update.
- Tracker was updated in commit 18ebfc9e967b58cc85c766bb2e21cc1b032d5d5d; resulting tracker blob 96b9c4fc49153096b3166f32c66ff79238ce9b93.
- Current source review confirms FSUM guard targeted workflow 45911471194 passed 11 tests, but exact RSUM take matching by producer destination/row count remains OPEN because hardware tracks only a pending count, not a producer metadata FIFO.
- Prior workflow successes and the PPA OOM-kill diagnosis remain bounded historical evidence. This continuation did not launch, cancel or rerun CI; no RTL, test or workflow source was changed.
- PPA remains unauthorised. Do not create docs/sunnyone/PPA_EXECUTE_REQUEST.md or invoke workflow_dispatch without explicit approval of the exact source SHA. Preserve the incident record for cancelled partial run 45911873124.
- Next: obtain a true live Actions status poll if an available endpoint permits; then address RSUM producer metadata parity and remaining width/UNOPTFLAT/formal/CDC/mapped-latch/physical/manufacturer gates in dependency order. Manufacturer handoff remains NOT READY.
- Hard controls: do not modify main; do not restart cancelled run 45765362426; do not rerun groups 3.1, 3.2 or 4 solely to reconfirm; zero spend; keep Track A full product separate from Track B demonstrator.
- This is a documentation-only save and does not claim that all engineering or tapeout tasks are complete.


## 2026-11-27 live CI reconciliation — structural SCC and latch audit

This section supplements the 05:54 documentation-only checkpoint refresh. The following live GitHub Actions evidence was obtained in this continuation:
- Structural SCC/latch audit run 45913401437 SUCCESS; independent repeat 45913488085 SUCCESS.
- Yosys/Slang flattened one-copy slice: 0 SCC and 0 inferred latch cells.
- Yosys/Slang flattened two-slice `otpu_top` (S=2): 0 SCC and 0 inferred latch cells.
- Therefore generic Verilator UNOPTFLAT paths `gnt`, `pq`, and `sc_gl` are not actual combinational SCCs in these tested configurations. The Verilator warnings remain emitted; do not generalise to all configurations.
- The seven generic Verilator LATCH diagnostics did not produce inferred latch cells in these two synthesis elaborations. ASIC-wide latch absence is not established.
- ASIC-specific `aok` UNOPTFLAT remains OPEN; `otpu_asic_top` was not part of the structural audit.
- Full evidence: docs/sunnyone/STRUCTURAL_SCC_AND_LATCH_AUDIT_2026-11-27.md; artifact 15160673532.

Other verified results retained from earlier runs: FSUM guard 11/11 targeted tests; full-chip lint SUCCESS (76 width warnings); ASIC configuration SUCCESS (additional ASIC DMA/native-DRAM/AW-AR width warnings); reset audit 4 tests passed; loop-stack, isolated 128K TMEM and Qwen/board/subsystem/software runs have their own run-specific states. Do not claim pending workflows as complete.

Next: ASIC-top SCC proof for `aok`; width warning closure; explicit 33-to-34-bit MIG address extension with existing testbench high-bit-zero assertions; formal/SVA, CDC/RDC and remaining physical/manufacturer gates. Manufacturer handoff remains NOT READY.


## 2026-11-27 06:00 Asia/Dhaka — latest continuation addendum

Live feature branch HEAD before this documentation update: 18493ca5f681d44051eaeb960b89d496ac0968e1. Main remains d84db55712aba0d40811d7762cb052f05d55b7e5; GitHub reports branch protection disabled, but the project rule remains do not modify main.

Latest tracker update is section 116 in docs/sunnyone/PROJECT_TRACKER.md. Read it before further action. Key new finding: the random power-up A/B workflow 45913977727 failed on both pre-FSUM and post-FSUM jobs before simulation because Ubuntu 24.04's apt Verilator does not support --no-assert-case. The comparison is inconclusive. Separately, RTL-tail run 45911471173 on the FSUM-guard source failed test_random_power_up[1-3] at rtl/vpu/otpu_se_tail.sv:277 (two rows' D slots meet; kv_v=0, e2=1, e3=1), while 32 other selected tests passed and 1 skipped. Preserve this as an unresolved regression; do not attribute it to FSUM until a valid A/B run is available.

Verified improvements remain: FSUM bounds targeted CI 11/11 passed; generic one-copy and S=2 structural SCC/latch audits each report zero SCC and zero inferred latch cells. ASIC aok, ASIC-wide latches, RSUM producer destination/row FIFO parity, 76 generic width warnings plus ASIC-specific widths, formal/SVA, CDC/RDC and physical/manufacturer gates remain open. PPA 45877786710 is terminal failure with confirmed OOM-kill evidence; no retry authorised. Manufacturer handoff NOT READY.

No RTL/test/workflow changes or CI dispatches in this documentation reconciliation. Continue zero-spend, do not touch main, do not restart 45765362426, and do not rerun historical groups 3.1, 3.2 or 4 merely to reconfirm. Track A and Track B remain separate.


## 2026-11-27 — corrected power-up A/B result and next blocker

Correction to the preceding A/B note: workflow 45913977727 failed on both jobs due to an unsupported Verilator option. A corrected workflow on ubuntu-latest (commit 7ce1d8a21a0f01a8ee05043d66c666fd1b9c3416) completed run 45914084753: pre-FSUM snapshot 0d367ba1906b8e187e6e2feb2db576364d85b4fb PASSED test_random_power_up[1-3] (1 passed, 44.40 s); post-FSUM snapshot ebd3e4c95d9adb027fe01b81342492e4bf7f4e9a FAILED at rtl/vpu/otpu_se_tail.sv:277 (kv_v=0, e2=1, e3=1). This is a real reproducible regression associated with the FSUM guard snapshot; the exact causal mechanism is not yet proven. Do not suppress the assertion or assume the counter alone is responsible. See PROJECT_TRACKER.md section 117.

ASIC-top SCC/latch audit run 45914201799 (source commit 2a8228c957d94ff443638dbf2b6e3d901336ef63) is in progress; its reset/power-up test step was intentionally skipped by [SCC-ONLY]. Poll the SCC job and inspect its artifact before updating G3. Manufacturer handoff remains NOT READY.


## 2026-11-27 — stream-tail diagnosis and candidate correction

Latest source commit at this checkpoint: 024928752fef7ab774502d2a19f49111cc86b1ff. Read PROJECT_TRACKER.md section 118 for full run IDs and evidence.

The corrected A/B comparison established pre-FSUM pass / post-FSUM-guard fail for test_random_power_up[1-3]. Debug run 45914665954 showed the failure at stream init with rst=0, pe=1, init=1, kv_v=0, e2=1, e3=1, rv=102, rr=102. Its artifact contains program/DRAM/sync/text logs, not a VCD. Candidate commit 024928 resets e2/e3/dv valid delay lines on rst||init and gates the overlap assertion during init. It is not yet accepted: current RTL-tail run 45914912747 and reset/power-up plus ASIC structural audit 45914912691 are still running. Confirm the previous stream's final outputs are preserved by RTL-vs-ISA comparison.

The ASIC-top SCC attempt 45914201799 failed due to literal escaped newlines in generated macro stubs; tools/scc_audit.py was corrected in d43fa38047b250e008e9d25b039708f621b96282. The corrected audit is included in run 45914912691 and remains pending. Full-chip lint 45914912719 passed. Targeted FSUM 45914592880, loop-stack 45914592843 and isolated 128K TMEM 45914592827 passed.

Main remains d84db55712aba0d40811d7762cb052f05d55b7e5 and untouched. Keep no-spend, no-PPA, no cancelled-run restart, and no unnecessary reruns of groups 3.1/3.2/4. Manufacturer handoff NOT READY.


## 2026-11-27 — targeted stream-tail regression passes; broad verification pending

Latest tracker section 119 records the current evidence. Exact previously failing test_random_power_up[1-3] now PASSES on source f2559a3bead2f2058808f81890ae0a9b91d074a0 (run 45915433368, 1 passed in 40.33 s) after the init flush in RTL commit 024928752fef7ab774502d2a19f49111cc86b1ff. The RTL-vs-ISA memory comparison completed. Temporary tracing/workflow instrumentation was removed by 6290b360 and 425e794; the normal test harness again defaults to unique random power-up.

Full-chip lint run 45915615693 passes on commit 6290b360 with 0 errors; warning counts remain 52 WIDTHEXPAND, 24 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT. The clean full RTL-tail suite 45915615625 remains in progress. Reset audit run 45914912691 has passed its power-up/reset stage; its ASIC structural SCC/latch stage remains in progress. Four-DIMM WG8 ASIC integration run 45914912733 remains in progress. See tracker section 119 for all active run IDs.

Main is still d84db55712aba0d40811d7762cb052f05d55b7e5 and untouched. Preserve no-spend/no-PPA, no cancelled-run restart, and no unnecessary repeats of groups 3.1/3.2/4. Manufacturer handoff NOT READY.


## 2026-11-27 ASIC structural audit terminal update

- Workflow 45914912691 completed SUCCESS. Reset/power-up audit: 4/4 tests passed.
- Structural audit artifact 15162062669 independently inspected: copy slice, S=2 two-slice top and actual `otpu_asic_top` (card config) each have 0 SCCs and 0 inferred latch cells. All three Yosys logs report 0 SCCs; all three latch selection files are empty.
- This closes the tested ASIC `aok` combinational-loop question. Verilator `UNOPTFLAT aok` remains a warning but is not a structural SCC in the tested ASIC top; treat as a dependency over-approximation for this configuration.
- Exact seed-3 random power-up test passes after stream-tail init flush (45915433368, 1 passed, 40.33 s). The clean full RTL-tail suite 45915615625 remains in progress at this checkpoint.
- Full-chip lint 45915615693 passed with 0 errors; 52 WIDTHEXPAND, 24 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT diagnostics remain to triage. Do not equate the 7 Verilator LATCH warnings with inferred synthesized latch cells: the three audited elaborations contain zero latch cells.
- Four-DIMM WG8 host AXI integration 45914912733 and the clean full RTL-tail suite remain in progress. No PPA rerun; prior OOM diagnosis remains.
- Manufacturer handoff remains NOT READY. Width closure, full RTL-tail result, four-DIMM integration, formal/SVA, CDC/RDC, DFT and physical/timing gates remain open.

## 2026-11-27 integration and focused regression terminal update

- ASIC/target configuration workflow 45914912733: SUCCESS. Chip, memory and WG8 DDR4 top lint stages completed; four-DIMM host/accelerator AXI contention simulation passed. Evidence: four DIMM hmuxes; simultaneous host/accelerator AW/AR contention; alternating grants; ordered two-beat W bursts; B/R ID routing; independent backpressure. Simulation finished at 320 ns.
- ASIC config lint emitted 99 WIDTH warning occurrences and 3 UNOPTFLAT occurrences across its top elaborations. These are not cleared by the structural SCC result; width cleanup remains open. The two MIG-pair AW/AR port width mismatches (33-bit pair output into 34-bit host mux signal) need explicit zero-extension via 33-bit intermediate nets, preserving the existing 34-bit address checks.
- FSUM guard focused workflow 45915615614: 11 passed, 219 deselected (153.05 s).
- Isolated 128K one-copy TMEM workflow 45915615624: 2 passed, 228 deselected (118.59 s).
- Sequencer loop-stack boundary workflow 45915615653: 2 passed, 228 deselected (51.10 s).
- Clean broad RTL-tail workflow 45915615625 remains IN PROGRESS. Qwen, board-functional, subsystem/memory and software/ISA workflows also remain queued/in progress as separately listed in GitHub. Do not mark their gates complete until terminal logs are inspected.
- Structural audit 45914912691 remains PASS: reset 4/4; one-copy, two-slice and actual ASIC top each 0 SCC / 0 latch cells.
- No PPA rerun. Manufacturer handoff remains NOT READY.

## 2026-11-27 correction — trace-enabled seed-3 result is supplementary only

The prior wording that the exact seed-3 power-up case “passes” refers specifically to trace-enabled run 45915433368 (1 passed in 40.33 s, with RTL/ISA memory comparison). That run sets `OTPU_TRACE_POWERUP=1`; tracing changes Verilator instrumentation and can change the `--x-initial unique` pattern. It is not sufficient to close the no-trace failure.

The no-trace A/B run 45914084753 reproduced `test_random_power_up[1-3]`: the FSUM-guard source failed and the pre-FSUM source passed. The candidate tail-init flush fix must therefore remain PROVISIONAL until clean non-trace broad RTL-tail run 45915615625 and the stream RTL/ISA suite complete. Do not state that seed-3 is closed before inspecting those terminal logs.

The temporary `tb_top.sv` hierarchical monitor, trace test helper and temporary A/B workflow were removed/restored in commits 6290b360 and 425e794. A failure-only `$display` diagnostic remains inside the simulation-only tail assertion in `rtl/vpu/otpu_se_tail.sv`; it does not affect synthesis. Structural/reset audit 45914912691 is terminal PASS (reset 4/4; three tops 0 SCC/0 inferred latches), and ASIC integration 45914912733 is terminal PASS. See the current checkpoint for all other run states.


## 2026-11-27 — current ASIC width fix and no-trace verification state

Latest source commit: 600f3aa4822e18f03ba80d06ab86fd447189c126. It explicitly zero-extends 33-bit otpu_mig_pair AW/AR outputs into 34-bit host-mux nets through PAIR_AW intermediate signals. ASIC config run 45916680920 is validating the change; control/compute, native-memory and four-DIMM AXI lint stages passed, host AXI simulation is running. Full-chip lint 45916680866 passed with 0 errors but the 76 width, 7 LATCH and 3 UNOPTFLAT warnings remain in the generic full-chip lint set.

Critical power-up qualification: trace-enabled seed-3 pass 45915433368 is supplementary only. No-trace A/B 45914084753 still showed pre-FSUM pass / post-FSUM failure. Candidate init-flush fix remains provisional until clean no-trace broad RTL-tail run 45916680719 and stream RTL/ISA suite finish. Earlier no-trace run 45915615625 was cancelled during its test step by a subsequent commit; it is inconclusive.

Reset audit 45914912691 and ASIC integration 45914912733 are terminal PASS; new reset audit 45916680730 is running on the current AW/AR fix. Focused FSUM 11/11, loop-stack 2/2 and isolated 128K TMEM 2/2 passed on commit 6290b360. Qwen, software, subsystem/WG8 and board runs are pending/queued under 45916680844, 45916680756, 45916680829 and 45916680721. See tracker section 120 for full evidence. Main remains untouched; PPA not authorised; manufacturer handoff NOT READY.


## Latest continuation update — 2026-11-27, 13:00 Asia/Dhaka

Source snapshot: `600f3aa4822e18f03ba80d06ab86fd447189c126`; five later commits on this branch are documentation-only. Live compare: feature branch 967 commits ahead / 0 behind `main`, merge base `d84db55712aba0d40811d7762cb052f05d55b7e5`. No source RTL/test/workflow changes were made in this continuation.

Latest workflow reconciliation is recorded in PROJECT_TRACKER.md section 121 and integrated plan section 20. Key results: ASIC config 45916680920 SUCCESS (bad AW/AR `%Fatal` logs are expected negative tests and both testbench cases report PASS); RTL-tail 45916680719 SUCCESS (33 passed, 1 skipped); reset 45916680730 SUCCESS; Qwen real RTL 6 passed and tiny board-model 8 passed; board-functional 198 passed, 8 skipped, 1 deselected; full-chip lint 45916680866 SUCCESS with warnings still open. Software workflow 45916680756 has a CANCELLED waits job, so that part is incomplete.

New regression blocker: subsystem/memory 45916680829 has 13/14 jobs SUCCESS, QHL job FAILED with 6 passed and 1 failed. Failing test `test_qhl_power_up_rtl[1-False]` reaches the DUT and trips the simulation assertion at `rtl/vpu/otpu_se_tail.sv:281`: `kv_v=0,e2=1,e3=1`, with `rst=0, pe=1, init=0, in_v=1, cfg=6f8069, ns=32, jn=14, rv=51, rr=51`. This is a QHL random-power-up failure and is not closed by the separate 33-pass RTL-tail selection. Since init is low, the prior init-flush change does not by itself explain it. Root cause remains unproven; inspect VPU root/root_v and tail valid spacing against the QHL program/reset schedule before any RTL or assertion change.

Keep G3 width warnings and formal/CDC/RDC/DFT/physical gates open. PPA remains unauthorised after confirmed OOM on the equivalent 16-GB runner. Manufacturer handoff NOT READY. Do not rerun successful jobs solely to reconfirm; do not restart 45765362426 or historical RTL groups 3.1/3.2/4; do not modify main or incur spend.


## 2026-11-27 continuation update — PPA artifact reviewed

PPA run 45877786710 / job 140109157212 is terminal FAILURE at ORFS `2_4_floorplan_pdn` (exit 247). Artifact 15152974135 was downloaded and inspected. It proves host OOM-killer activity: cgroup `oom_kill=1`, peak `memory.peak=16,155,115,520` bytes, host MemTotal 16,366,484 kB; cgroup `memory.max=max`. ORFS stage log reports 15,713,660 KB peak. No final PPA report or valid PPA metrics. `ORFS_CPUS=2` was correctly propagated through `tools/asic/flow.py` to `NUM_CORES=2` and Docker `--cpus=2`; the addendum's stale proposal to fix ORFS_CPUS propagation is withdrawn. No PPA retry is authorised.

Continue with QHL random-power-up failure diagnosis and review the FSUM synthesizable guard candidate in the real `rtl/seq/otpu_seq.sv` path. Do not claim either fixed without focused verification. Keep formal/SVA, CDC/RDC, DFT, SRAM technology mapping and physical signoff open. Main untouched, no spend, manufacturer handoff NOT READY.


## 2026-11-27 continuation update — FSUM guard verified as already implemented

Source review found the FSUM hardware-ingress guard already present in `rtl/seq/otpu_seq.sv`; no implementation change is needed. It checks effective `FSUM` capability (including HAS_SS), permitted EXP2SUB/RSUM functions, EXP2SUB rows 1..256, columns >=64, non-scalar B mode, and pending producer before RSUM take. Invalid commands set error/halted before VPU dispatch; HALT with pending producers reports error. Tests in `tests/test_rtl.py` are verified by workflow 45915615614 job 140233980040: 11 passed, 219 deselected. The addendum's proposed guard implementation is closed as already implemented and focused RTL-pass.

Do not rerun this focused suite without relevant source changes. Keep QHL power-up failure from 45916680829, broader stream/VPU regression, software waits, width warning closure, formal/SVA, CDC/RDC, DFT, technology SRAM mapping and physical signoff open. PPA run 45877786710 is confirmed host OOM; no retry authorised. Main untouched; no spend; manufacturer handoff NOT READY.


## 2026-11-27 latest terminal run-state reconciliation

All previously listed workflows have now been polled to terminal state. The older broad RTL-tail run 45915615625 is CANCELLED (not a pass). The replacement scoped RTL-tail run 45916680719 is SUCCESS with 33 passed and 1 documented skip; 196 tests were deselected, so this is not a complete full-suite pass. Reset audit 45916680730 and ASIC config 45916680920 are SUCCESS. Qwen real-checkpoint RTL run 45916680844 is SUCCESS (6 passed in the selected checkpoint cases; companion tiny board-model selection 8 passed). Board-functional 45916680721 is SUCCESS (198 passed, 8 skipped, 1 deselected). Full-chip lint 45916680866 is SUCCESS with zero errors but warnings remain. Subsystem/memory run 45916680829 remains partially failed: 13 of 14 jobs SUCCESS; QHL job failed its random-power-up case as previously recorded. Software core run 45916680756 has 13 jobs SUCCESS and `tests/test_waits.py` CANCELLED; the waits test is not complete.

No active run remains among this listed batch. Do not rerun successful jobs merely to refresh status. Focus next on a deterministic, cycle-accurate diagnosis of the QHL power-up valid overlap; preserve the cancelled waits job as incomplete; continue warning/formal/CDC/RDC/DFT/physical gates. No PPA retry, no paid resources, no main modifications. Manufacturer handoff remains NOT READY.


## 2026-11-27 continuation — QHL overlap timing decomposition

A further source-level timing review was completed without changing RTL. In `otpu_se_tail.sv`, `SL = 1 + LM + LA = 1 + 2 + 4 = 7` pe cycles and, for LANES=8, `RL = 64 / LANES = 8` pe cycles. The row-slot valid pipeline is therefore: `e2 = kv_v delayed 7 pe cycles`, `e3 = kv_v delayed 14 pe cycles`. The failed assertion's simultaneous `e2=1,e3=1,kv_v=0` mathematically proves that two accepted `kv_v` pulses entered that tail exactly 7 pe cycles apart (one now 7 cycles old, one 14 cycles old). It is not explained by an uninitialised first-cycle value alone: both valid delay lines are reset by `rst || init`, and the observed failure has `rst=0, init=0`.

The architecture comments and parameter guard require A-row roots delivered to the tail to be spaced by multiples of RL=8; 7-cycle separation violates that contract. The relevant upstream path is `otpu_vpu.sv`: shared `otpu_vtree.root_v`, Q/A classification via `vt_q` and `kq[kh]`, then `kv_v = root_v && !vt_q`. The tree also multiplexes A and Q partial windows. The next diagnostic must therefore record, cycle-by-cycle, `root_v`, `vt_q`, `cap`, `a_cap`, `q_cap`, `vt_rl`, `vt_sub`, `ss_act`, `sen`, `s_init`, `kv_v`, `e2`, and `e3`, with the QHL seed-1 no-trace setup. Determine whether the bad 7-cycle A-root spacing originates in tree input scheduling, the Q/A-kind FIFO enqueue/dequeue alignment, or stream grant/reset phasing. Do not change the assertion, mask the event, or adjust pipeline depth until that trace establishes the source.

This narrows the QHL failure but does not close it. No RTL changed and no CI rerun was launched. Keep the focused FSUM guard, Qwen, board-functional, scoped RTL-tail, reset audit and ASIC-config results at their exact tested scopes; keep the QHL random-power-up failure, cancelled software waits, lint warnings, formal/SVA, CDC/RDC, DFT, SRAM mapping and physical signoff open. PPA remains unauthorised after confirmed host OOM. No spend; protected main untouched; manufacturer handoff NOT READY.


## 2026-11-27 continuation — full-chip lint warning inventory

The full-chip lint job `45916680866` / job `140237471700` was inspected directly. It completed successfully with zero lint errors, but emitted 86 warnings: 52 `WIDTHEXPAND`, 24 `WIDTHTRUNC`, 7 `LATCH`, and 3 `UNOPTFLAT`. The seven LATCH warnings are local combinational temporaries in `rtl/seq/otpu_seq.sv` at lines 1165 and 1854 (names include `c2`, `r2`, `u`, `y`, `k`, `kd`, `cf`). The three UNOPTFLAT warnings are combinational-loop reports at `rtl/top/otpu_slice.sv:612` (`gnt`), `rtl/top/otpu_top.sv:156` (`sc_gl`), and `rtl/mem/otpu_tmem.sv:297` (`pq`). Width warnings include array-index truncation/bit-select cases in `otpu_vpu.sv` and `otpu_mxu.sv`, as well as expression sizing in package, quantizer, and datapath RTL. These require individual range/intent review; do not bulk-cast or suppress warnings without proving index bounds and arithmetic semantics.

The existing Yosys structural audit's zero inferred latch-cell result does not automatically explain away Verilator's local temporary warnings; reconcile the exact elaborated procedural temporaries and synthesis treatment. Likewise, UNOPTFLAT warnings need path-level SCC review even though the prior structural SCC audit passed its selected tops/configurations. Keep the lint-warning gate OPEN until each warning is classified and either corrected or justified with a reproducible proof. Do not rerun the successful lint job solely to reconfirm. No RTL change or new CI run was made in this continuation.
 
## 2026-11-27 continuation — WAITC remainder verification and QHL diagnostic isolation

- Active engineering branch: `sunnyone/commercial-profitability-architecture-2026-11-23`; feature-branch HEAD at this update: `54577bcd7aca4bf004aac9b7d2f286f57a3c96a7`. Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare is 996 ahead / 0 behind. The branch-protection API endpoint returned 403 to this integration, so current protection metadata could not be independently re-read. No main write was made.
- WAITC remainder workflow added at `.github/workflows/sunnyone-waits-remainder.yml` in commit `54577bcd7aca4bf004aac9b7d2f286f57a3c96a7`. Run `45963867548` is terminal SUCCESS across all three jobs: unfinished hazard cases 3 passed (seeds 1–2), 2 passed (seed 3), and remaining window/MX/host-entry cases 28 passed / 1 skipped. The skip is the optional torch-dependent prebuild case (`torch` was not installed). The original job `45916680756` / `140237552767` was cancelled after about 87% with no test failure in its log; the last completed hazard case `[1-16]` passed. Combined original and remainder logs cover the module's test cases except the documented optional skip. Do not describe the cancelled original job as a standalone full-module PASS.
- QHL diagnosis is isolated on temporary branch `sunnyone/qhl-seed1-diagnostic-2026-11-27`; do not merge its instrumentation. The first instrumented pass `45964405350` was inconclusive because the added counter could perturb unique-X initialisation and emitted no trace. Runs `45965156322`, `45965732887`, and `45966389125` reproduced the original seed-1 assertion, but parent-level trace text was not preserved before fatal termination. A subsequent diagnostic compile `45967519265` exposed an unclosed preprocessor guard in the temporary branch; it was corrected there only. Run `45967861319` is validating the next diagnostic: upstream root/FIFO/classification context is passed into the tail assertion and flushed at the failure site. No result from this run is available yet.
- The QHL functional failure remains OPEN. No assertion weakening, pipeline-depth change, reset masking or production RTL fix is authorised until the cycle-level root/FIFO evidence identifies the cause. No diagnostic RTL edits were made on the active engineering branch.
- No PPA retry, paid resources, manufacturer commitment or main-branch modification. Manufacturer handoff remains NOT READY.


## Latest continuation — QHL diagnostic terminal failure and passive-trace plan

- Live feature branch HEAD before this documentation update: 59d10a3878d5ed2188520222bbc1a9cc90187b0c; live compare to main was 1,001 ahead / 0 behind. Main remains d84db55712aba0d40811d7762cb052f05d55b7e5. GitHub API currently reports protection disabled on both branches; this does not alter the project rule to leave main untouched.
- Re-polled latest QHL temporary-branch diagnostic run 45967861319: terminal FAILURE, job 140400790723, artifact 15183802907 (ZIP SHA-256 f0e88620f845e311a7996b1b54cf2023b73edeb2b73026ab8c7703e2c5a48926). The exact no-trace seed-1 QHL test reproduced the assertion: kv_v=0, e2=1, e3=1.
- Failure-time snapshot includes root_v=0, vt_q=0, cap=1, a_cap=1, q_cap=0, vt_rl=1, vt_sub=122, kq=0x66, kh=0, kt=6, sen=1, s_init=0. This is only a same-cycle snapshot, not the preceding root/valid history. Root cause remains unproven.
- Keep temporary diagnostic branch isolated; do not merge it. Next diagnostic: plusarg-gated passive per-PE-cycle $display of existing root_v/kv_v, kind FIFO enqueue/dequeue and e2/e3 signals. Do not add sequential monitor state/counters that can perturb unique-X initialisation. Compare root pulses against kind FIFO occupancy and reset/init timing. Do not weaken the assertion or alter pipeline depth before evidence.
- Tracker section 124 records the full finding and next diagnostic. Tracker update commit: 29e915b40fb5b90d73a6aaba16f7e9a5fd44a252; tracker blob: 54d78974704e0b00648021233bc19d6c07830363.
- No RTL/test/workflow source changes and no CI dispatch in this continuation. No PPA retry (confirmed host OOM), no paid resources, no main modification, no rerun of already successful regressions. Manufacturer handoff remains NOT READY.

### Resume order
1. Read this checkpoint, CONTINUATION_ADDENDUM_2026-11-27_0137.md, INTEGRATED_ENGINEERING_AND_SPONSORED_SILICON_PLAN_2026-11-27.md, PROJECT_TRACKER.md and MANUFACTURER_HANDOFF_READINESS_MATRIX.md.
2. Re-resolve live feature HEAD and main SHA before any write; latest documentation commits may have advanced the branch beyond the source HEAD recorded above.
3. Continue the isolated QHL passive trace only; preserve the no-main/no-spend/no-duplicate-regression constraints.
4. Continue semantic width-warning triage, RSUM producer-metadata parity, formal/SVA, CDC/RDC, DFT, SRAM mapping, production interfaces and demonstrator/sponsor gates.

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


## Continuation review — 2026-11-27 18:30 Asia/Dhaka

### Live repository poll
- Active branch HEAD before this documentation-only update: 1537765f5b85a6050c4ee50735af537b8c019da4.
- Protected-main baseline remains d84db55712aba0d40811d7762cb052f05d55b7e5. GitHub branch listing currently reports main protected=false. Treat this as a governance gap; do not write to main.
- Isolated diagnostic branch HEAD: 64943951e89f1fe91ac20d56f34fddea66c05923, commit message: "debug(qhl): capture flushed root and FIFO event history". Parent is 35dce2e57d0448988411ba98e5f931f420b8463f.
- The latest diagnostic branch commit adds a stateless, non-SYNTHESIS, per-cycle QHLTRACE $display with $fflush() in rtl/vpu/otpu_se_tail.sv. It observes existing root_v/kv_v, e2/e3, PE enable, stream/init and kind FIFO state; it adds no sequential monitor counter/register. This is consistent with the passive-trace requirement on source inspection.
- Important distinction: failed run 45967861319 tested parent commit 35dce2e..., before the new stateless event-history trace commit 64943951. Its failure therefore does not test or invalidate the new trace.
- The isolated workflow .github/workflows/sunnyone-qhl-diagnostic.yml has workflow_dispatch and a narrowly scoped exact seed-1 pytest command. Current connected GitHub actions tools expose run/job inspection but no workflow-dispatch action; no run was launched. Do not claim trace completion or a result until the diagnostic workflow is dispatched and its log/artifact inspected.

### Current engineering disposition
- QHL remains OPEN; root scheduling vs FIFO alignment vs grant/reset phasing is not yet classified. No production RTL change is justified.
- The diagnostic branch remains isolated; do not merge its debug ports/instrumentation into the active engineering branch.
- No RTL/test/workflow source was changed on the active branch. No tests were rerun or dispatched in this continuation.
- Existing successful regression evidence remains preserved; do not rerun it merely for confirmation. Do not restart cancelled workflow 45765362426 or repeat successful RTL groups 3.1, 3.2 and 4.
- PPA retry remains unauthorised after the recorded host OOM. Zero spend remains mandatory.
- Manufacturer handoff remains NOT READY. Formal/SVA, CDC/RDC, DFT, semantic width-warning closure, structural cycle confirmation, SRAM technology mapping, production host/memory interfaces, routed physical signoff and zero-cost sponsorship/sample-access arrangements remain open.

### Next exact action
Dispatch .github/workflows/sunnyone-qhl-diagnostic.yml on branch sunnyone/qhl-seed1-diagnostic-2026-11-27 at commit 64943951e89f1fe91ac20d56f34fddea66c05923; inspect the complete QHLTRACE history and correlate root_v dequeue events against cap/vt_rl kind FIFO enqueues and kq[kh] classification. Do not change functional RTL until the trace demonstrates the defect. After the diagnostic, update this checkpoint, tracker, integrated plan and readiness matrix with the exact run ID, commit, artifact hash and evidence-based conclusion.


## Workflow recheck — 2026-11-27 18:45 Asia/Dhaka

- Re-polled the latest 100 Actions runs. The newest run for .github/workflows/sunnyone-qhl-diagnostic.yml remains run 45967861319 (run #7), completed FAILURE, branch sunnyone/qhl-seed1-diagnostic-2026-11-27, tested SHA 35dce2e57d0448988411ba98e5f931f420b8463f.
- Inspected its only job (140400790723) and full decoded log. It failed exactly at the previously known tail assertion: kv_v=0, e2=1, e3=1. This run used the pre-trace commit; no QHLTRACE lines appear. Artifact 15183802907 exists (5,221 bytes; SHA-256 zip digest f0e88620f845e311a7996b1b54cf2023b73edeb2b73026ab8c7703e2c5a48926), but it is the old no-trace log and adds no root-cause history.
- Verified the current diagnostic branch HEAD is 64943951e89f1fe91ac20d56f34fddea66c05923. The latest trace commit changed rtl/vpu/otpu_se_tail.sv only. The workflow's push trigger is path-filtered to .github/workflows/sunnyone-qhl-diagnostic.yml; therefore that RTL-only commit did not trigger another run. No workflow_dispatch run appears in the latest 100 Actions runs.
- Therefore the passive QHLTRACE implementation has still NOT been executed. The previous conclusion that the GitHub connection lacks a dispatch action remains: available actions support run/job/artifact inspection and rerun operations, but no workflow dispatch operation was found. Do not rerun the older failed run; it would replay the old SHA. User must use Actions -> SUNNYONE QHL seed-1 no-trace diagnostic -> Run workflow, select branch sunnyone/qhl-seed1-diagnostic-2026-11-27, and start the manual run.
- QHL remains OPEN; no functional root-cause conclusion or RTL fix. No production branch source changes and no main writes. Manufacturer handoff NOT READY.


## 2026-11-27 continuation — QHL trace workflow correction

- Re-inspected run 45967861319 (job 140400790723; artifact 15183802907). It tested SHA 35dce2e57d0448988411ba98e5f931f420b8463f, the pre-trace parent, and failed again at rtl/vpu/otpu_se_tail.sv:299 with kv_v=0, e2=1, e3=1. The 5,221-byte artifact has ZIP SHA-256 f0e88620f845e311a7996b1b54cf2023b73edeb2b73026ab8c7703e2c5a48926 and contains no QHLTRACE history. It is not a trace test result.
- Source inspection at diagnostic branch commit 64943951e89f1fe91ac20d56f34fddea66c05923 confirms a stateless, non-SYNTHESIS event-filtered QHLTRACE display and flush. Correction to prior wording: the trace is NOT plusarg-gated; it is gated by reset and existing event signals. It adds no sequential trace counter/register. Keep it isolated on the diagnostic branch.
- The workflow previously retained stale “no-trace” labels despite invoking the exact QHL seed-1 case against the trace-instrumented branch. Corrected only the temporary diagnostic workflow labels, comments and artifact filename in commit 60e3c03a47620f077f84fc01b7c0d9d78999a2e2. The workflow's existing push path filter matches this workflow-file change, so this commit should trigger the narrowly scoped diagnostic job automatically. It still runs only tests/test_quant_rtl.py::test_qhl_power_up_rtl[1-False].
- This workflow-only change does not alter RTL or test logic. Await the new run and inspect its exact tested SHA, QHLTRACE event sequence and artifact. If no run appears, use the workflow_dispatch UI on branch sunnyone/qhl-seed1-diagnostic-2026-11-27.
- QHL remains OPEN; no root cause or production fix. Do not merge diagnostic instrumentation. No successful historical tests rerun, no PPA retry, no paid resources and no main writes. Manufacturer handoff remains NOT READY.


## 2026-11-27 18:45+ Asia/Dhaka — targeted trace run launched

- Workflow-only correction commit `60e3c03a47620f077f84fc01b7c0d9d78999a2e2` on the isolated diagnostic branch triggered Actions run `46001085532` (run #8), event `push`, exact tested SHA `60e3c03a47620f077f84fc01b7c0d9d78999a2e2`. The run is the event-trace diagnostic, not the previous no-trace test.
- Job `140512599407` entered the exact pytest step `tests/test_quant_rtl.py::test_qhl_power_up_rtl[1-False]`. At last poll it remained IN_PROGRESS; dependency installation and Verilator setup had completed. No final test conclusion or log artifact was yet available. Do not infer pass/fail from an in-progress job.
- No production RTL or test logic was changed. The only diagnostic-branch change since trace commit `64943951e89f1fe91ac20d56f34fddea66c05923` is workflow naming/log-artifact metadata. Active engineering branch changes are documentation-only. Protected main untouched; no paid resources, no PPA retry, no historical successful regression reruns.
- Next: poll run `46001085532`; once terminal, fetch job log and artifact, extract all QHLTRACE lines, correlate cap&&vt_rl enqueue events with root_v dequeue and kv_v classification, then record the evidence-based root cause (or state that it remains unresolved). QHL OPEN; manufacturer handoff NOT READY.


## 2026-11-27 continuation — QHL trace-capture correction and rerun

- Live active engineering branch at start of this update: `3c68d11ba5647c66b2466538fca81e85617fa09d`. Protected-main baseline remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; no main write.
- Diagnostic run `46001085532` (job `140512599407`) tested the stateless event-trace branch at `60e3c03a47620f077f84fc01b7c0d9d78999a2e2` and failed at the same QHL tail overlap assertion. QHLTRACE was executing, but only the final trace line was retained in the pytest traceback because `opentpu/rtlsim.py` raised with `out[-3000:]`. Therefore the run did not provide the event history needed for root-cause classification.
- Corrected only the temporary diagnostic branch: commit `e2dc582705dc70c29104448d443149e3e3066056` changes the simulation-failure exception to retain the complete simulator output; workflow metadata commit `f421ebacbc455bcc815a7531595a31a5da8f7430` triggers the path-filtered exact-case workflow. No production RTL or test logic changed.
- New targeted run `46014477752`, run #9, tests exact SHA `f421ebacbc455bcc815a7531595a31a5da8f7430`, job `140557974695`, exact selection `tests/test_quant_rtl.py::test_qhl_power_up_rtl[1-False]`. At this documentation update it is IN_PROGRESS; no pass/fail or trace conclusion is available.
- Trace implementation is stateless, non-SYNTHESIS, event-filtered and flushed; it is NOT plusarg-gated. It remains isolated on `sunnyone/qhl-seed1-diagnostic-2026-11-27`; never merge diagnostic instrumentation into the active engineering branch.
- QHL remains OPEN. Do not change functional RTL, assertion semantics, reset behaviour or pipeline depth until complete history identifies the failure mechanism. Preserve prior successful regression evidence; no duplicate completed-group reruns, no PPA retry, no spend, no main writes. Manufacturer handoff remains NOT READY.
- Next: poll run `46014477752`; if terminal, inspect the complete log and artifact, extract every QHLTRACE line, correlate `cap && vt_rl` FIFO enqueue events with `root_v`/ `kv_v` events and `kq[kh]` classification. If the output still does not expose the needed queue events, add only passive trace visibility on the diagnostic branch and repeat this one case.


## 2026-11-27 continuation — reset-qualified QHL assertion experiment

- Event-trace run `46014477752` on diagnostic SHA `f421ebacbc455bcc815a7531595a31a5da8f7430` failed at the original tail assertion. Full simulator output was preserved, but it contained only one QHLTRACE event: `time=5, rst=0, pe=1, in_v=1, cap=1, root_v=0, kv_v=0, e2=1, e3=1`. The trace condition did not truncate earlier lines; there were no additional QHLTRACE lines in the captured simulator output.
- Source review found the testbench begins with `rst=1` and `sys_rst=1`, while `otpu_slice.sv` distributes unit reset through uninitialised two-stage registers (`rst_dma`, `rst_vpu`, etc.) loaded from `srst` on clock edges. The stream-tail overlap assertion checked arbitrary internal valids before qualifying that the local reset had propagated. The same tail module already had a `rst_seen` guard for d-FIFO assertions; `otpu_vtree` and `otpu_slice` also qualify assertions after reset has been observed on two edges. This makes a pre-reset assertion false positive the leading hypothesis, not yet a proven conclusion about the functional QHL path.
- First isolated guard edit run `46015378969` failed at compile only because the new `rst_p/rst_seen` declaration duplicated the existing tail declaration. No simulation occurred. Corrected diagnostic-only commit `0875b167a642c51fee259c6ee2fa49bf6134f6b3` moves the single existing reset qualification before the overlap check and reuses it for both overlap and d-FIFO assertions; the assertion remains active after two reset edges. This is a reset-qualification correction, not an assertion removal or datapath change.
- Workflow trigger commit `1bbcd1ade3ce9b2707af2e4ceb82a5ecc501da77` launched run `46015574176`, job `140561704888`, testing the exact single selection `tests/test_quant_rtl.py::test_qhl_power_up_rtl[1-False]` on diagnostic branch SHA `1bbcd1ade3ce9b2707af2e4ceb82a5ecc501da77`. At this update the job is IN_PROGRESS in the simulation step. Do not infer a result.
- All reset-guard and trace changes remain on the temporary diagnostic branch only. The active engineering branch has documentation-only updates; no functional RTL or test logic changed there. Protected main remains untouched. No PPA retry, paid resources, duplicate successful regression reruns or cancelled-run restarts.
- QHL remains OPEN until run `46015574176` completes and its complete log is inspected. If it passes, record the exact test scope and then apply the reset-qualified assertion correction on the active branch only after reviewing the diff; if it fails after reset, use its complete QHLTRACE history to isolate the actual cause. Manufacturer handoff remains NOT READY.


## 2026-11-27 continuation — QHL reset-qualification result and active-branch correction

- Diagnostic run `46015574176`, job `140561704888`, completed SUCCESS on temporary diagnostic branch SHA `1bbcd1ade3ce9b2707af2e4ceb82a5ecc501da77`. Exact test `tests/test_quant_rtl.py::test_qhl_power_up_rtl[1-False]`: **1 passed in 92.45s**. The run used the stateless trace instrumentation, full simulator-output capture and reset-qualified overlap assertion. No assertion failure or additional QHLTRACE event was emitted; the complete QHL seed-1 RTL simulation and its Python-vs-RTL memory comparisons passed under that diagnostic configuration. Artifact `15205847584`, ZIP digest `sha256:076ea696000e14ef98811b1ba74a4db8db595aa75d1e6048cf4ed0486cd2b020`.
- Source review supports the reset-phase explanation: the testbench starts with slice reset asserted; unit reset is distributed through two-stage local registers; the overlap assertion previously evaluated before its local reset was known to have propagated. The tail already had a two-edge `rst_seen` qualification for d-FIFO checks. The diagnostic fix reused that same guard for the overlap assertion. This is a simulation-only assertion qualification under `ifndef SYNTHESIS`, not a datapath change, reset masking or removal of the post-reset check.
- Reviewed the minimal diff and applied the same correction on the active engineering branch in commit `672a4fc13f9f708582f4fca0462a32363654ff93`: moved the existing `rst_p/rst_seen` qualification before the overlap assertion and reused it for the d-FIFO assertion. No diagnostic trace ports or instrumentation were copied to the active branch.
- Added an isolated active-branch regression workflow `.github/workflows/sunnyone-qhl-reset-guard.yml` in commit `e123b331582495e12e7f32f81472011f0929c2cb`. Run `46016087510`, job `140563454048`, tests the exact seed-1 selection on the active branch; at this update its pytest step remains IN_PROGRESS. Do not call the active-branch fix verified until this run is terminal and its log is inspected.
- The RTL source push also automatically triggered existing broad workflows on source SHA `672a4fc13f9f708582f4fca0462a32363654ff93`: run `46016022824` (reset/power-up synthesis audit), `46016022808` (board-functional), `46016022758` (subsystems/WG8 memory), and `46016022887` (software/ISA). These were automatic push-triggered workflows, not separately dispatched by this continuation. Preserve their exact scopes and inspect terminal outcomes; avoid launching any additional duplicate jobs.
- QHL is improved but remains OPEN pending the active-branch targeted run. Do not infer broad seed/configuration closure from this one case. Main baseline remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; no main writes. No PPA retry, spend or cancelled-run restart. Manufacturer handoff remains NOT READY.


## 2026-11-27 continuation — active-branch QHL seed-1 verification passed

- Active-branch targeted workflow `46016087510`, job `140563454048`, completed SUCCESS on tested commit `e123b331582495e12e7f32f81472011f0929c2cb`. Exact selection `tests/test_quant_rtl.py::test_qhl_power_up_rtl[1-False]`: **1 passed in 81.93s**. Artifact `15205448777`, ZIP digest `sha256:d90ee7f6f3a184e085c675a7f99c86da982e6fd75b2779ca6508438f346e5390`.
- Together with diagnostic-branch run `46015574176` (1 passed in 92.45s), this verifies the reset-qualified assertion change under the exact failing seed/configuration on both the isolated diagnostic branch and the active engineering branch.
- Root-cause disposition for this specific failure: the old simulation-only overlap assertion could evaluate arbitrary power-up valids before the two-stage unit reset replica had propagated. The two-edge `rst_seen` guard is consistent with existing tail d-FIFO and vtree/slice reset-qualified checks. The overlap assertion remains active after reset propagation. No QHL datapath, scheduling, FIFO, valid-delay or reset hardware logic was changed.
- The seed-1 failure is resolved at its demonstrated assertion/reset-qualification cause. Do not overstate this as a full QHL-suite or all-seed pass: the second parameterized power-up case, full QHL regression matrix and subsystem/memory workflow remain separately scoped evidence.
- Active branch documentation updates are saved and re-verified. Current main SHA remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; no main writes. Manufacturer handoff remains NOT READY pending remaining lint, formal, CDC/RDC, DFT, SRAM, interface, physical and sponsorship gates.


## Final continuation save — 2026-11-27

- The active-branch QHL reset-qualification correction is committed as `672a4fc13f9f708582f4fca0462a32363654ff93`. Reviewed commit diff confirms the only RTL change is under `ifndef SYNTHESIS`: the existing two-edge `rst_seen` guard is moved before the overlap assertion and shared with the d-FIFO assertion. No datapath, pipeline, reset hardware, functional test or assertion threshold was changed.
- Active-branch targeted QHL seed-1 workflow `46016087510` is terminal SUCCESS: 1 passed in 81.93s, artifact `15205448777`, ZIP SHA-256 `d90ee7f6f3a184e085c675a7f99c86da982e6fd75b2779ca6508438f346e5390`.
- The following automatic push-triggered workflows are not yet terminal at this save: reset/power-up audit `46016022824` IN_PROGRESS; board-functional `46016022808` IN_PROGRESS; RTL subsystems/WG8 memory `46016022758` QUEUED overall (some jobs already running); software/ISA `46016022887` QUEUED overall (some jobs already completed or running). No further workflow was manually dispatched. Inspect exact job scopes and terminal logs before updating evidence; do not start duplicate runs.
- Live main SHA: `d84db55712aba0d40811d7762cb052f05d55b7e5`, unchanged. GitHub branch listing reports `protected=false`; record this as a branch-governance gap. No main write or merge.
- Documentation updates in this save include this checkpoint, project tracker, integrated engineering/sponsored-silicon plan and manufacturer readiness matrix. The final live feature-branch HEAD and final document blob SHAs must be re-polled after the last documentation commit.
- QHL seed-1 assertion/reset-qualification issue is resolved for the exact tested case. Broader QHL configurations, lint-warning closure, formal/SVA, CDC/RDC, DFT, SRAM technology mapping, production host/memory interfaces, routed physical signoff, demonstrator down-select and fully funded sample/fabrication/testing access remain open. Manufacturer handoff remains **NOT READY**.


## 2026-11-27 continuation update — QHL reset qualification and downstream workflow reconciliation
This checkpoint supersedes earlier pending QHL diagnostic states. The 45967861319 failure is superseded by the full-output diagnostic and reset-qualified active-branch regression evidence below.


### Live repository state at this update
- Active engineering branch: `sunnyone/commercial-profitability-architecture-2026-11-23`; live HEAD before this documentation update: `b3fc28fdab1551fa23d59eb6e4f531f8b7899dd4`.
- `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare reports feature branch 1,038 commits ahead and 0 behind. No main write, merge or rebase was performed in this continuation.
- Keep all engineering/documentation work on the active feature branch. Zero spend remains mandatory. No PPA retry or physical fabrication/test spend is authorised.

### QHL diagnostic disposition
- Run `45967861319` completed FAILURE on the temporary diagnostic branch. It reproduced the assertion with `kv_v=0,e2=1,e3=1` and the same-cycle upstream snapshot, but the wrapper included only the last 3,000 simulator-output characters. Treat it as a reproduced assertion, not as proof of the functional root cause.
- Follow-on full-output diagnostic run `46014477752` preserved complete simulator output and showed only one QHLTRACE event at time 5 while reset was still propagating. Source inspection found the tail overlap assertion was evaluated before its two-stage local reset replica had been observed. The tail already used a two-edge `rst_seen` qualification for its d-FIFO assertion; vtree/slice assertions follow the same reset-qualified pattern.
- Diagnostic-only correction commit `0875b167a642c51fee259c6ee2fa49bf6134f6b3` reused the existing two-edge reset qualification for the overlap assertion. Diagnostic run `46015574176` on temporary branch commit `1bbcd1ade3ce9b2707af2e4ceb82a5ecc501da77` passed the exact selection `tests/test_quant_rtl.py::test_qhl_power_up_rtl[1-False]`: 1 passed in 92.45s; artifact `15205847584`, ZIP SHA-256 `076ea696000e14ef98811b1ba74a4db8db595aa75d1e6048cf4ed0486cd2b020`.
- Reviewed and applied only the same simulation-assertion qualification correction to active-branch RTL in commit `672a4fc13f9f708582f4fca0462a32363654ff93`. It is under `ifndef SYNTHESIS`; no datapath, reset hardware, FIFO, scheduling, pipeline or assertion threshold was changed. Diagnostic trace ports/instrumentation were not copied to the active branch.
- Active-branch exact regression run `46016087510`, job `140563454048`, passed: 1 passed in 81.93s on tested commit `e123b331582495e12e7f32f81472011f0929c2cb`; artifact `15205448777`, ZIP SHA-256 `d90ee7f6f3a184e085c675a7f99c86da982e6fd75b2779ca6508438f346e5390`.
- The original seed-1 false-positive assertion is resolved for the exact tested case. Do not claim all-seed, all-QHL or broad power-up closure from this targeted result alone.

### Automatically triggered workflow reconciliation on source commit 672a4fc13f9f708582f4fca0462a32363654ff93
- Reset/power-up structural audit run `46016022824`: terminal SUCCESS. Actual log: reset/power-up tests 4 passed; `copy_slice`, `two_slice_top`, and `asic_top` each reported zero combinational SCCs and zero inferred latch cells in the audited configurations (SRAM leaves remain blackboxed). Artifact `15205214662`. This is scoped structural evidence, not complete CDC/RDC/formal closure.
- RTL subsystem/memory run `46016022758`: terminal SUCCESS, all 14 jobs successful. QHL job `140563230730`: 7 passed in 502.86s. This adds the subsystem QHL suite evidence on the corrected assertion source; preserve the exact run/job scope and do not infer exhaustive power-up coverage.
- Board-functional run `46016022808`: terminal CANCELLED. No board-functional PASS may be claimed from this run; do not automatically restart it or duplicate successful tests. Determine the missing board coverage from the current evidence ledger before proposing a targeted replacement.
- Software/ISA run `46016022887`: terminal FAILURE only because the stream job's Verilator installation step could not fetch the Microsoft Ubuntu package repository (HTTP 403; repository reported unsigned). The stream pytest step never ran. The other 14 software-core jobs completed SUCCESS. This is an environment/setup failure, not a stream test failure. Do not mark stream tests passed or failed; retain as NOT RUN due dependency-install failure.
- No new broad workflow was dispatched in this continuation. Preserve earlier successful results and cancelled-run restrictions.

### Open engineering gates and next actions
1. Poll any newer active-branch workflows before starting additional work; reconcile automatic cancellations and avoid duplicate successful runs.
2. Resolve the cancelled board-functional coverage with a minimal, isolated replacement only after checking current concurrency and the exact missing test scope.
3. Repair the reproducibility of Verilator installation in the software stream job (e.g. use the Ubuntu archive package or pinned trusted binary/source) only after reviewing the workflow; run only the affected stream job/test scope, not the entire software matrix.
4. Continue semantic width-warning triage and UNOPTFLAT path analysis; retain exact warning counts and prove every narrowing/bounds assumption. Structural SCC success does not by itself clear Verilator UNOPTFLAT warnings.
5. Continue formal/SVA, CDC/RDC, DFT, SRAM technology mapping, production PCIe/SerDes and DMA/IOMMU, DDR controller/PHY/training/ECC, routed physical signoff, and demonstrator down-select.
6. Keep Track A full product separate from Track B demonstrator. Manufacturer handoff remains **NOT READY**; no sponsor, free fabrication, package/test, custody, delivery or shipping arrangement is confirmed.


## Final verification for this continuation save
- Live active-branch HEAD immediately before this final checkpoint metadata commit: `8f626607a2529f40f137552257f9bb59d0d00651`.
- Live main SHA: `d84db55712aba0d40811d7762cb052f05d55b7e5` (expected unchanged protected baseline `d84db55712aba0d40811d7762cb052f05d55b7e5`).
- Integrated plan blob: `4baa2a2de90c9908ef6aadb9c7092959ad6954c3`.
- Project tracker blob: `e3cd288024b5d42d3e047effc6c3e300d32c97c1`.
- Manufacturer handoff matrix blob: `f3c6dafa4c105e1e001d811a5a5bd2fefe27682b`.
- This checkpoint blob before final metadata append: `39cce7fe065f19cb34c6eb9fde7b366677e94a8d`.
- The final metadata-only checkpoint commit is recorded by the commit returned for this update. Re-fetch the checkpoint and both branch refs after this commit to confirm the final saved state.
- No RTL, test logic, workflow source or production branch behaviour was changed in this documentation save. No new CI was dispatched. The QHL correction itself remains the separately verified simulation-assertion qualification change documented above.


## Continuation update — board evidence reconciliation, Qwen checkpoint verification and isolated STREAM recovery
This update reconciles the cancelled board run against earlier successful board evidence, records the real-checkpoint Qwen test results, interprets lint PASS correctly, and records the isolated STREAM recovery run as pending.
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


## Final verification for this continuation update
- Feature branch HEAD before this final checkpoint metadata update: `b893b8331416d4a7d06932fe73902d456341b902`.
- Protected main SHA: `d84db55712aba0d40811d7762cb052f05d55b7e5`; expected unchanged baseline `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Isolated STREAM workflow run `46037445046`: status `in_progress`, conclusion `pending`, tested commit `5ef0c28bdbbb1e8b2b7219b5d37d24e0d6d8a942`. At last job inspection, job `140636330408` was still building pinned Verilator; no STREAM pytest result is yet available.
- Documentation updates in this continuation: checkpoint, 0137 addendum, integrated plan, project tracker and manufacturer readiness matrix. Their latest blob SHAs are verified after update in the next re-fetch.
- No main-branch write, merge, rebase, paid compute, PPA, fabrication or physical test booking was performed. The only new workflow dispatched was the isolated STREAM software regression, automatically triggered by its workflow-file commit.


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


## 2026-11-28 continuation — live reconciliation and next engineering gates

Read `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_0050.md` for the full run ledger and ordered plan. Live HEAD at this save: `4f26ec9d280f601587f474a4dd535c24f2945e39` before this documentation update; the 28-Nov addendum itself is committed on the active feature branch. Compare before this save: 1,055 ahead / 0 behind; main baseline remains `d84db55712aba0d40811d7762cb052f05d55b7e5`.

The isolated STREAM regression is terminal SUCCESS: 46 passed in 1183.29s on source `5ef0c28bdbbb1e8b2b7219b5d37d24e0d6d8a942`, run `46037445046`. The active-branch QHL exact seed-1 reset-qualified selection passed 1 test; subsystem QHL job passed 7 tests. These are scoped results, not all-seed closure. FSUM guard is already implemented and focused-tested: 11 passed, 219 deselected in run `45915615614`; no further patch or repeat is required without source change. Board and Qwen evidence remain at their exact earlier SHAs/scopes as documented in the addendum.

WG8 PPA run `45877786710` is terminal FAILURE; no routed PPA report or signoff metrics. Existing resource diagnosis records host-memory exhaustion. No PPA retry is authorised. Latest Actions reconciliation found no active run. Preserve all successful evidence and do not rerun historical RTL groups 3.1/3.2/4 or the long board suite solely to reconfirm.

Remaining priority: (1) exact semantic width-warning triage and elaborated `gnt` dependency/SCC analysis, then `sc_gl`, `pq`, ASIC `aok`; (2) formal/SVA; (3) CDC/RDC; (4) real SRAM/DDR technology mapping and production memory controller/PHY/ECC; (5) production PCIe/SerDes and DMA/IOMMU; (6) DFT; (7) routed physical/power/thermal signoff; (8) Track B demonstrator down-select and verified sponsorship/sample logistics. Keep Track A and Track B distinct.

Hard constraints unchanged: zero spend, no PPA retry, no protected-main writes, no duplicate passed tests, no unsupported physical/silicon claims. Manufacturer handoff remains **NOT READY**.



## 2026-11-28 VPU width remediation continuation

Read `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_VPU_WIDTH_REMEDIATION.md` and `docs/sunnyone/LINT_TRIAGE_UPDATE_2026-11-28.md` after the earlier 0050 addendum. Source commit `05879ea34eafc2559c54722c6c940b2acb9ac3ee` sizes VPU function-mask indices and row-buffer indices. Full-chip lint run `46053311384` succeeded with 59 width warnings (52 WIDTHEXPAND, 7 WIDTHTRUNC), down from 76; 7 LATCH and 3 UNOPTFLAT remain. Structural SCC run `45914912691` found zero SCCs and zero inferred latch cells in the one-copy slice, two-slice top and actual ASIC card top, resolving `gnt`, `pq`, `sc_gl`, `aok` only for those exact configurations.

The first focused VPU run `46053329340` failed at build with old Verilator 5.020 before tests executed; workflow is pinned to 5.044 and run `46053471843` is the valid regression attempt. Do not mark the RTL correction regression-verified until that run passes.

Broad existing `rtl/**` push filters unintentionally triggered additional board, Qwen, software-core and RTL workflows. These were not intentionally requested; no workflow cancellation operation is available through the current GitHub connection. Do not initiate further broad reruns. Preserve exact prior test evidence and reconcile only relevant terminal results. Manufacturer handoff remains NOT READY; protected main and zero-spend constraints remain unchanged.


## 2026-11-28 06:47 continuation — waits recovery and profitability north star

Read `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_0647.md` first, then `docs/sunnyone/SUNNYONE_AI-X_PROFITABILITY_NORTH_STAR_2026-11-28.md`, the integrated plan, tracker, source/interface spec and resource-model spec.

- Live branch HEAD at start of this continuation: `54848e8fc43ad88abe09379ccf1e7298d9910d64`; active branch remains `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Main SHA remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; no main write. GitHub reports `protected=false`; maintain strict no-write rule.
- Software-core workflow `46053311585` attempt 3 is now terminal SUCCESS. Waits-only job `140775908058`: **268 passed, 2 skipped in 1953.87s**. All 15 jobs succeeded. Artifact `15237666850`, ZIP SHA-256 `47048b1aecc1fff9f40500e11190ef4cc24a9945bd6c2c71b2551c46ca2ac554`. Exact tested source `05879ea34eafc2559c54722c6c940b2acb9ac3ee`; do not describe it as current-HEAD validation.
- The commercial north star is now saved in `SUNNYONE_AI-X_PROFITABILITY_NORTH_STAR_2026-11-28.md` and linked from the integrated plan. Preserve the combined TPU/MXU + software-first LPU-like scheduler/KV role + NPU/VPU + shared measured memory/interconnect + programmable software architecture. No dedicated LPU silicon absent measured net benefit. Quantum-inspired classical research only; no quantum hardware. Track A and Track B remain distinct.
- Immediate next task: exact-source correlation of RTL trace and TMEM activity; then formalise existing scheduler admission/round-robin/context/cancel semantics and distinguish from tenant fairness; create W1/W2/W3 workloads and only calibrate with matching traces.
- Continue remaining MXU bounds, width-warning, formal/SVA, CDC/RDC, DFT, SRAM/DDR, production interfaces, routed physical and sponsorship gates. No PPA retry, paid compute, hardware spend, duplicate passed tests or unsupported claims. Manufacturer handoff remains **NOT READY**.

Documentation save sequence: north-star doc commit `40b6f8078d2d7a424a255f1d7db716cab373b657`; addendum and updated plan/tracker/checkpoint commits are to be verified by re-fetching live branch HEAD and blob SHAs after this update.


## Latest continuation pointer — 2026-11-28 18:21 Asia/Dhaka

Read `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_1821.md` after this checkpoint. It records the live branch ref `8c65b8b33fda16a588227f64d26be7edea4b04c2`, latest Actions reconciliation (no active/queued run; final workload harness run 46132183828: 47 passed), current MXU malformed-command guard review, exact remaining work and release controls. The addendum and tracker were saved on the feature branch. Re-resolve the live ref before the next write. Manufacturer handoff remains NOT READY.


## Latest continuation pointer — 2026-11-28 20:17 Asia/Dhaka

Read `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_2017.md` after this checkpoint. It records live branch reconciliation (HEAD before documentation save `8c46dee94e90f1072d4571fb3a1260ee6efd61b2`), latest Actions state (no active/queued runs; workload harness run `46132183828` SUCCESS, 47 passed), the exact MM ISA/simulator/RTL parameter audit, why no speculative RTL patch was made, and the ordered narrow-CI/guard implementation gate. Manufacturer handoff remains NOT READY. Protected main and zero-spend/no-duplicate-test controls remain mandatory.
