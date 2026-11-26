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
