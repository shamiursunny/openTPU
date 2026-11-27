# SUNNYONE Manufacturer Handoff Readiness Matrix

Status date: 2026-11-27
Repository: `shamiursunny/openTPU`
Working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Status: **NOT READY — engineering evidence and implementation gates remain open**

## Purpose and release rule

This matrix defines the evidence required before a package may be represented as ready for a semiconductor manufacturer, ASIC implementation partner, FPGA board integrator, or foundry. It is a release-control document, not evidence that any gate has passed.

A gate is complete only when its evidence is reproducible, tied to an immutable source/configuration/tool revision, reviewed, and archived. A successful simulation, synthesis proxy, preliminary floorplan report, or software model must never be described as routed signoff, silicon validation, or production qualification.

## Evidence record convention

For every result, retain:
- repository, branch, full source commit SHA, and relevant source/configuration file hashes;
- exact command, tool name/version/container digest, scripts, constraints, target/device/package/PDK revision;
- test selection, exclusions, skips, warnings, random seeds, environment and resource limits;
- raw logs, machine-readable reports, artifacts and SHA-256 digests;
- pass/fail criteria, reviewer, date, deviations and unresolved issues.

Use only these status labels:
- **PASS** — acceptance criteria met with archived evidence.
- **PARTIAL** — useful evidence exists but required scope or acceptance criteria remain incomplete.
- **OPEN** — not demonstrated.
- **BLOCKED** — cannot be completed until an external dependency, decision, tool, licence, hardware or foundry input is available.
- **FAIL** — acceptance criterion not met.

## Release gates

| Gate | Required work and acceptance evidence | Current evidence/status |
|---|---|---|
| G0 — Product and architecture baseline | Approved product definition; target workload, performance/latency/quality envelope, power/thermal limits, memory capacity/bandwidth, host interface, security and lifecycle requirements. Freeze architecture revision and interface control document. | **PARTIAL.** Provisional programmable inference accelerator direction exists. Exact product, target workload and device/package remain unselected. |
| G1 — RTL/source integrity | Complete synthesizable RTL, dependency closure, parameter/configuration matrix, reset/clock assumptions, CDC intent, interface protocols, coding standards, reproducible source manifest and independent design review. | **PARTIAL.** Existing repository RTL and substantial tests exist; lint warnings remain and production integration is incomplete. |
| G2 — Functional verification | Requirements-to-test traceability; unit/subsystem/top-level tests; protocol corner cases; reset, backpressure, error injection, concurrency, memory ordering and negative tests. No unexplained failures; exclusions justified. | **PARTIAL.** Historical digital runs passed on source SHA `2835f1a8da6af454023caff9576f41258c66e2a8`; preserve exact selection counts/skips. This is not a full-chip signoff. |
| G3 — Lint and structural quality | All critical lint findings fixed or individually justified by elaborated/synthesis evidence; no unexplained latches, combinational loops, undriven/multiple drivers, width truncation or unsafe constructs. No blanket suppressions. | **OPEN.** The 7 LATCH diagnostics were traced to ifndef SYNTHESIS simulation-only sequencer instrumentation and are excluded by the ASIC synthesis define; a final synthesized-netlist latch-cell check remains required. The 3 UNOPTFLAT paths (gnt, sc_gl, pq) and ASIC-specific aok path have source-level triage but are not closed; the 79-warning baseline has reduced to 76 after the loop-stack index fix (52 WIDTHEXPAND, 24 WIDTHTRUNC) on source 28c36c52204fe2ec2ed36413b02eb6043506ccc4; 9 baseline instances are confirmed inside ifndef SYNTHESIS regions and marked SIM_ONLY, while 67 current warnings still require individual synthesis/configuration and semantic review. ASIC AW/AR port-width warnings remain. See WIDTH_WARNING_INVENTORY_2026-11-27.md. See LINT_AND_COMBINATIONAL_PATH_TRIAGE_2026-11-27.md. |
| G4 — Formal verification | Assertions for bus protocols, arbitration, DMA bounds/alignment/ordering, reset, memory map, security/isolation and error handling; bounded/unbounded proof as appropriate; assumptions reviewed; cover properties demonstrate reachability; proof logs archived. | **PARTIAL/OPEN.** Global address-map formal workflow exists; broader subsystem/top-level formal and SVA closure remain open. |
| G5 — CDC/RDC and clock/reset | Clock-domain inventory; synchronizer and asynchronous FIFO review; CDC/RDC tool reports; reset-domain sequencing/recovery/removal analysis; clock gating checks; waivers individually reviewed and justified. | **OPEN.** No complete CDC/RDC signoff evidence recorded. |
| G6 — Synthesis and technology mapping | Exact target library/PDK and corner; complete synthesis; mapped area/cell statistics; inferred memory mapping to real macros; clock/reset/test structures; no unsupported generic-cell assumptions. | **OPEN.** Nangate45 research synthesis is not a selected foundry implementation. SRAM macro mapping and exact technology libraries remain unresolved. |
| G7 — Physical implementation and timing | Floorplan, placement, CTS, routing, extraction, congestion, DRC, antenna, IR/EM and routed STA across required modes/corners; constraints reviewed; setup/hold closure; signoff reports and database archived. | **FAIL/PARTIAL.** WG8 ORFS flow exited 247 during floorplan/placement. Existing report is pre-route and wire-load-only. No routed STA or physical signoff. |
| G8 — Memory subsystem | Selected memory architecture and exact device/part; controller/PHY/training; ECC, refresh, rank/topology, timing, SI/PI, termination, routing, capacity and bandwidth; stress/retention/error-injection results. | **OPEN/BLOCKED.** DRAM/technology RAM digital checks passed in selected scope; production DDR controller/PHY/training/ECC and physical memory topology not implemented/qualified. |
| G9 — External interfaces and system integration | PCIe/SerDes or selected host link, DMA/IOMMU, interrupts, boot/control, reset, security, error recovery, firmware and driver integration; interoperability and compliance tests on target hardware. | **OPEN.** Research/functional models do not establish a production PCIe endpoint, SerDes PHY, IOMMU or board integration. |
| G10 — DFT and testability | Scan architecture/insertion, ATPG fault coverage, MBIST/LBIST as applicable, JTAG/boundary scan, test modes, clock/test control, diagnosis, manufacturing test time and yield-learning plan. | **OPEN.** No production DFT/ATPG evidence. |
| G11 — Power, thermal and reliability | Power intent; activity-based power estimates; vector-based dynamic/leakage reports; measured board input power; thermal simulation and instrumented measurements; voltage/temperature corners; ageing, stress, derating and reliability qualification. | **OPEN.** No calibrated physical implementation or board-level power/thermal/reliability measurements. |
| G12 — Security and safety | Threat model; secure boot/root of trust if required; key provisioning; debug lifecycle; privilege/isolation; DMA protection; fault handling; vulnerability review; applicable safety/security standards and evidence. | **OPEN.** No complete product-level security assurance package. |
| G13 — Package, PCB and BOM | Exact die/package, pinout, package substrate, stack-up, power delivery, decoupling, SI/PI, thermal solution, PCB files, BOM with lifecycle/availability/alternates and supplier quotations. | **BLOCKED.** Exact silicon, package, board and memory components not selected/validated. |
| G14 — Foundry/manufacturer data package | Foundry-approved PDK/IP versions and licences; design rules; library/LEF/Liberty/RC corners; GDS/OASIS; netlists; constraints; abstracts; DRC/LVS/ERC/antenna/IR/EM reports; waivers; mask and assembly/test requirements. | **BLOCKED.** No foundry, PDK, process node, licensed IP or manufacturer interface is selected. |
| G15 — Production qualification and commercial release | Yield targets, test coverage, qualification plan/results, reliability standards, PCN/lifecycle, manufacturing capacity/lead time/quotes, unit economics, customer acceptance, support and warranty plan. | **OPEN/BLOCKED.** No qualified silicon, manufacturing quotes, validated demand or production qualification. |

## Immediate engineering execution order

1. **PPA diagnosis instrumentation (implemented in CI definition; not yet run):** Docker CPU limit is now explicitly applied with `docker run --cpus 2`; the workflow captures host memory baseline and samples cgroup memory limit/current/peak/events during ORFS, archiving telemetry. Do not launch another PPA attempt until the updated workflow is reviewed and an approved run is justified.
2. **Lint root-cause proof:** use the exact synthesis/elaboration configuration to determine whether the seven LATCH diagnostics create actual latch cells; trace the three UNOPTFLAT dependency paths in elaborated netlists. Correct only demonstrated defects and verify handshake/functional equivalence.
3. **Width-warning triage:** map all 79 warnings to expressions and intended signedness/ranges; make explicit-width corrections only with boundary tests and no behaviour change.
4. **Formal/SVA:** expand assertions from address-map proof to DMA, AXI/AW/AR/W/B/R, arbitration, reset, memory ordering, access bounds and error handling. Prove and cover, not just compile.
5. **CDC/RDC:** inventory all clock/reset domains and run appropriate structural analysis with individually justified exceptions.
6. **Memory and interface architecture:** select actual DDR/LPDDR/controller/PHY, PCIe/SerDes, IOMMU and SRAM macro strategy only after device/package/PDK feasibility and workload evidence.
7. **Physical design:** only after exact target libraries, constraints, PDK and sufficient compute resources are available, complete place/CTS/route/extraction and signoff.
8. **Board validation:** validate power rails, clocks, reset, memory training/ECC, link interoperability, thermal, sustained workload performance and fault recovery on the selected physical board.
9. **Independent review and handoff package:** close requirement traceability, issue/waiver register, signoff reports, reproducible source manifest, BOM, test plan, known limitations and manufacturer-specific submission checklist.

## Current PPA CI instrumentation change

Workflow: `.github/workflows/sunnyone-asic-wg8-ppa.yml`.

The prior comment claimed Docker was limited to two CPUs, but only `ORFS_CPUS=2` was set inside the container. The workflow now passes `--cpus 2` to Docker, pulls immutable ORFS manifest digest `sha256:f5b2b4ac8cae150c30ad86857328300e20662cf7ff555978711ea8936f8d9539`, verifies local image ID `sha256:edbd355068b742c5ae2413a49a58578465bd52f57668cebebdd383eb4d97607d`, archives both identifiers, and records:
- runner `/proc/meminfo`, filesystem and ulimit baseline;
- container `/proc/self/cgroup` and initial/final `/proc/meminfo`;
- cgroup v2 memory.max/current/peak/events where exposed;
- cgroup v1 memory limit/usage/max-usage/failcnt where exposed;
- periodic five-second memory samples while the flow is running.

The workflow edit is not itself a PPA result. It is not configured to self-trigger on workflow-file-only changes, so it requires a separately justified manual dispatch. No retry has been launched by this change. A runner/container killed with SIGKILL may not execute the EXIT trap; periodic samples already written to the mounted workspace should still be archived if the runner survives.

## Current verified baseline

- Repository: `shamiursunny/openTPU`.
- Active feature branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Protected-by-project-rule `main` SHA: `d84db55712aba0d40811d7762cb052f05d55b7e5`; GitHub API previously reported branch protection disabled. Never push to main.
- Historical digital verification source SHA: `2835f1a8da6af454023caff9576f41258c66e2a8`.
- PPA failure: run `45845758658`, Error 247 during floorplan; root cause not confirmed.
- Lint run: `45845758782`; warnings listed above remain unresolved.
- Manufacturer handoff: **NOT READY**.

## Release decision

Do not send this project as a tapeout-ready or production-ready design. A preliminary technical discussion with a manufacturer may be possible only if explicitly labelled as an early feasibility review and accompanied by this open-gate matrix. Formal manufacturer handoff requires closure of the applicable gates above and acceptance of the exact deliverables by the selected manufacturer/foundry.


## 2026-11-27 lint triage addendum

Detailed source-level classification is recorded in docs/sunnyone/LINT_AND_COMBINATIONAL_PATH_TRIAGE_2026-11-27.md. The seven LATCH diagnostics are simulation-only and excluded by SYNTHESIS; this is not a blanket closure of G3. The gnt path remains unresolved, while sc_gl, pq and aok have plausible source-level explanations that still require elaborated-net confirmation. The 79 width warnings remain open. The immutable ORFS image pin is workflow instrumentation only and has not yet produced a new PPA result.


## 2026-11-27 width-warning inventory addendum

All 79 width diagnostics from workflow 45845758782 are preserved in docs/sunnyone/WIDTH_WARNING_INVENTORY_2026-11-27.md. Nine instances were confirmed inside ifndef SYNTHESIS code and marked SIM_ONLY; this is not a waiver. High-priority bounds proofs remain for the VPU row-sum buffer index, the four-entry sequencer loop stack, VPU one-hot function-mask indices and MXU drain/key array indices. G3 remains OPEN.


The loop-stack guard reduced the full-chip lint width-warning count from 79 to 76 (52 WIDTHEXPAND, 24 WIDTHTRUNC) in run 45877786797, source commit 28c36c52204fe2ec2ed36413b02eb6043506ccc4. Three out-of-range-width diagnostics on the four-entry sequencer stack index were removed by adding an explicit depth check and using sp[1:0]. This is not full lint closure; G3 remains OPEN.


## 2026-11-27 targeted verification update

- Sequencer LOOP stack: RTL now rejects a fifth non-zero nested loop before an out-of-range write. Dedicated workflow 45877985241 passed both maximum legal depth four and overflow error/halt tests (2 passed, 217 deselected). This closes that specific tested boundary issue, not all sequencer verification.
- Isolated 128K one-copy TMEM investigation workflow 45877807985 passed 2 tests (217 deselected).
- Full-chip lint 45877786797 passed with 76 width warnings (52 WIDTHEXPAND, 24 WIDTHTRUNC), down from 79; three sequencer stack-index warnings were removed.
- WG8 PPA diagnostic workflow 45877786710 remains in progress; no PPA closure claim. G1/G2/G3 remain partial/open according to their broader gates.


## 2026-11-27 live continuation addendum

- **G1 — RTL/source integrity remains PARTIAL:** FSUM uses the 256-row VPU row buffer. The RDOT path has a synthesizable `rows <= NRB`/stride guard, but the FSUM row-count check is simulation-only (`ifndef SYNTHESIS`). FSUM is enabled in `bcu1525-wg` and `bcu1525-x2`. Software compiler/ISA-simulator checks exist, but hardware rejection or a proven ingress-enforcement contract is not demonstrated. See `INPUT_BOUNDS_AND_PPA_RESOURCE_CONTROL_REVIEW_2026-11-27.md`.
- **G2 — Functional verification remains PARTIAL:** add a targeted negative RTL test for a 257-row FSUM command and a positive 256-row boundary test on an FSUM-enabled target after the hardware/ingress contract is decided. No such hardware-negative test is recorded yet.
- **PPA workflow run 45877786710 remains IN_PROGRESS** on source SHA `28c36c52204fe2ec2ed36413b02eb6043506ccc4`. The pinned-image and host-baseline steps passed; the container flow is still running. Do not cancel or launch a duplicate.
- **PPA CPU control defect:** `ORFS_CPUS=2` is set by the workflow but ignored by `tools/asic/flow.py`, which uses `os.cpu_count()` to set `NUM_CORES` when ORFS_HOME is present. Docker `--cpus 2` still caps CPU time, but worker oversubscription is possible. Correct after the current run terminates; this is not a proven cause of Error 247.
- Other scoped successes: reset audit 45877786738, ASIC config 45877786860, RTL tail 45877807906, isolated TMEM 45877807985, LOOP stack 45877985241 (2 passed). Qwen 45877786754 and board 45877786742 remain IN_PROGRESS; subsystem 45877786699 and software 45877786705 have queued/in-progress jobs.

Manufacturer handoff remains **NOT READY**. No RTL or workflow source changes were made; zero-spend and main-branch exclusions remain in force.


### G1/G2 FSUM ingress clarification — 2026-11-27

The board loader `Board.load_program` accepts raw uint32 instruction arrays and has no FSUM semantic row-count validation. The software compiler/ISA simulator therefore do not establish a mandatory validated ingress path. The 256-row FSUM buffer bound remains OPEN for FSUM-enabled BCU targets until a synthesizable error/halt guard or a mandatory validated loader contract is implemented and tested. Trace the existing sequencer error path before any RTL change.


### Existing error/halt path traced — candidate guard location, not yet implemented

- `otpu_seq` exposes `error` and its existing invalid decoded-operation branch sets both `error <= 1'b1` and `halted <= 1'b1` before dispatch (around lines 1702–1705).
- `otpu_slice` connects `otpu_seq.error` to `sq_err` and exposes `error = sq_err || to_err` (around lines 355–366 and 437). The VPU itself currently has no error output.
- A candidate minimal architecture is to pass the slice's `VPU_FSUM` configuration into the sequencer and validate an FSUM-bearing VOP's decoded `cmd_t` before dispatch, reusing the existing sequencer error/halt path. The exact decoded-field timing and full FSUM contract still require a focused review; this is not an approved patch.
- Do not change `otpu_seq.sv` while PPA run 45877786710 is active: that file is in the PPA workflow path filter and the workflow uses cancel-in-progress concurrency. Wait for the current run's terminal result, then implement only with targeted boundary tests and an explicitly justified CI run.


## 2026-11-27 PPA resource evidence and verification reconciliation

WG8 PPA workflow 45877786710 is terminal FAILURE. The full artifact (15152974135; SHA-256 bd93a2e68be7e2c3b782dba2e26824b67977a98867fd17cddceb1348c56a16f5) was downloaded and inspected. Immutable ORFS manifest and local image ID were verified; Docker CPU quota was 2 and OpenROAD reported two threads. Floorplan, macro placement and tap-cell insertion completed; failure occurred in 2_4_floorplan_pdn/check_placement with ORFS Error 247. The cgroup had no memory.max cap, memory.peak reached 16,155,115,520 bytes against host MemTotal 16,366,484 kB, and memory.events recorded oom_kill=1. This confirms an OOM-kill event and strongly supports host-level memory exhaustion; it does not identify the exact kernel victim. Do not rerun the same full-chip PPA on an equivalent 16 GB runner.

The earlier 01:37 claim that ORFS_CPUS was ignored is superseded by the 01:45 source review: the workflow CLI reads ORFS_CPUS and passes 2 to run(); no flow.py correction is required on that basis.

Verification reconciliation: Qwen 45877786754 SUCCESS (6 real-checkpoint RTL + 8 tiny board-model tests); board 45877786742 SUCCESS (198 passed, 8 skipped, 1 deselected); subsystem/memory 45877786699 all 14 jobs SUCCESS (385 passed, 1 skip); software/ISA 45877786705 all 15 jobs SUCCESS (825 passed, 3 skipped); reset 45877786738, ASIC config 45877786860, RTL tail 45877807906, TMEM 45877807985 and loop-stack guard 45877985241 SUCCESS. These results do not close formal, CDC/RDC, routed physical signoff, production memory PHY, PCIe/SerDes, DFT, silicon qualification or manufacturer gates.

G7 remains FAIL/PARTIAL: only early floorplan data exists; no route or signoff. G1/G2 remain OPEN/PARTIAL pending synthesizable FSUM row-bound protection for FSUM-enabled BCU targets. G3 remains OPEN for 76 width warnings and unresolved elaborated UNOPTFLAT paths. All other applicable gates remain as previously recorded. Manufacturer handoff remains NOT READY.

Full resource diagnosis: docs/sunnyone/PPA_RESOURCE_DIAGNOSIS_2026-11-27.md.

## 2026-11-27 FSUM gate update

G1/G2 FSUM bounds guard: IMPLEMENTED / TARGETED CI PASS (45911471194: 11 passed, 219 deselected). The sequencer rejects zero/>256 rows, <64 columns, scalar B, unsupported FSUM VOPs, disabled effective capability, and RSUM take with no pending producer. The pending counter is resettable and HALT with untaken sums raises error. The 256x64 legal producer/take path passed with output and row-sum checks.

Residual OPEN item: hardware does not yet retain per-producer sum destination/row metadata, so exact RSUM take matching to the oldest producer is not checked in hardware (the ISA simulator checks it). Do not mark the entire FSUM ISA contract closed.

Full-chip lint 45911470968 SUCCESS: 76 width warnings, 3 UNOPTFLAT and 7 LATCH remain. Manufacturer handoff remains NOT READY. PPA push trigger now requires docs/sunnyone/PPA_EXECUTE_REQUEST.md plus [RUN-PPA] in the commit message; no approved PPA run is authorised.


## PPA trigger incident correction — 2026-11-27

Correction to the preceding note: editing PPA_REQUEST.md itself initially triggered WG8 PPA run 45911873124. This was an assistant-authored workflow-control mistake. The run was cancelled at 23:37:04Z after approximately 73 seconds. Its retained artifact (15159964408; ZIP SHA-256 a5a1bea55d30b1b0e5721f2eae33049bd0003a1504c7925f84aa5e676c05ccf3) shows macro prep/config and Yosys 1_1_yosys_canonicalize only; no floorplan, placement, CTS, PDN or PPA report. cgroup peak was 894,529,536 bytes; OOM counters were zero. One minute of GitHub-hosted runner time was consumed; exact billing/quota cannot be established from this interface.

The corrected workflow is in commit 98335138bd73751699afc4a31ce0b206ff2720a1. Push paths are now docs/sunnyone/PPA_EXECUTE_REQUEST.md and the workflow file; a push job also requires [RUN-PPA] in the commit message. The correction run 45911965872 was SKIPPED and caused cancellation of the accidental run. PPA_REQUEST.md is documentation only. Do not create PPA_EXECUTE_REQUEST.md or use workflow_dispatch without explicit user approval of the exact source SHA.

Full incident evidence: docs/sunnyone/PPA_TRIGGER_INCIDENT_2026-11-27.md.


## 2026-11-27 structural loop/latch gate update

Generic structural SCC gate: PASS for tested configurations. Yosys/Slang runs 45913401437 and 45913488085 each show zero SCCs and zero inferred latch cells in one-copy slice and S=2 top. Generic `gnt`, `pq`, and `sc_gl` Verilator UNOPTFLAT diagnostics are not actual SCCs in those tested configurations; do not generalise to untested configurations.

ASIC `aok` UNOPTFLAT remains OPEN pending ASIC-top structural SCC analysis. ASIC-specific latch absence is not yet proven. Width gate remains OPEN: 76 generic full-chip width warnings plus additional ASIC DMA/native-DRAM/AW-AR warnings. Manufacturer handoff remains NOT READY.


## 2026-11-27 continuation evidence addendum

- FSUM bounds guard: targeted PASS (45911471194, 11 tests), but exact RSUM take matching to the oldest producer's destination and row count remains OPEN because hardware has no producer metadata FIFO.
- Generic structural SCC/latch audit: PASS for tested one-copy slice and S=2 top (45913401437, 45913488085; zero SCCs and zero inferred latch cells). ASIC-top aok SCC and ASIC-wide latch absence remain OPEN.
- Random power-up: RTL-tail run 45911471173 failed test_random_power_up[1-3] at otpu_se_tail.sv:277 (two D slots meet); this is an unresolved assertion/regression. Intended pre/post-FSUM A/B run 45913977727 was inconclusive because both jobs failed before simulation on unsupported --no-assert-case in the Ubuntu 24.04 apt Verilator.
- Width gate remains OPEN: 76 generic width warnings plus ASIC-specific DMA/native-DRAM/AW-AR warnings. WG8 PPA run 45877786710 failed with confirmed cgroup OOM-kill evidence; no routed STA/physical signoff. Do not rerun on an equivalent 16 GB runner.
- G1/G2 are improved by targeted FSUM checks but not fully closed due the RSUM metadata parity gap and the unresolved random-power-up assertion. G3 remains OPEN for ASIC-specific structural proof and width closure. G7 remains FAIL/PARTIAL. Manufacturer handoff remains NOT READY.


## 2026-11-27 corrected power-up A/B result

- Corrected deterministic A/B run 45914084753: pre-FSUM source 0d367ba1906b8e187e6e2feb2db576364d85b4fb passed test_random_power_up[1-3] (1 passed); post-FSUM-guard source ebd3e4c95d9adb027fe01b81342492e4bf7f4e9a failed at rtl/vpu/otpu_se_tail.sv:277 (kv_v=0, e2=1, e3=1). This is a reproducible regression associated with the FSUM guard snapshot, causal mechanism still open. G1/G2 must remain PARTIAL/OPEN until fixed and regression-tested; the 11 targeted FSUM passes do not supersede this failure.
- The initial A/B tool mismatch is superseded by corrected run 45914084753; the corrected run used ubuntu-latest. Do not continue describing the A/B comparison as inconclusive.
- ASIC-top SCC audit run 45914201799 remains in progress at this update; no ASIC aok closure claim yet.


## 2026-11-27 stream-tail candidate fix and live verification

- Random-power-up regression: A/B pre-FSUM passes, post-FSUM guard fails at stream init with e2/e3 valid overlap. Debug artifact 15161492847 captures textual trace/program/DRAM/sync files (no VCD).
- Candidate stream-tail correction in 024928752fef7ab774502d2a19f49111cc86b1ff flushes e2/e3/dv on rst||init. NOT YET VERIFIED. RTL-tail run 45914912747 and reset/ASIC structural run 45914912691 are in progress; preserve this gate as OPEN until both relevant regression and RTL-vs-ISA output checks pass.
- ASIC-top SCC audit attempt 45914201799 failed in the generated SRAM stub; corrected in d43fa38047b250e008e9d25b039708f621b96282 and re-running in 45914912691. No ASIC-top closure claim yet.


## 2026-11-27 stream-tail validation update

- Stream-tail init flush candidate: targeted exact seed-3 random-power-up regression PASS (45915433368, 1 passed in 40.33 s, RTL/ISA comparison complete). Broad clean RTL-tail run 45915615625 still IN PROGRESS; keep the overall stream gate PARTIAL until it passes.
- Full-chip lint 45915615693 PASS, 0 errors; 52 WIDTHEXPAND, 24 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT warnings remain open. Do not equate Verilator LATCH warnings with synthesized latch-cell counts.
- Reset/power-up audit step PASS in run 45914912691; ASIC-top flattened SCC/latch stage still IN PROGRESS. Four-DIMM WG8 host AXI integration run 45914912733 still IN PROGRESS.
- Manufacturer handoff remains NOT READY. PPA not authorised; RSUM producer metadata FIFO, ASIC proof, width, formal, CDC/RDC, DFT and physical gates remain open.


## 2026-11-27 terminal structural and reset audit update

- Reset/power-up audit 45914912691: PASS, 4/4 tests.
- Yosys/Slang structural audit artifact 15162062669: PASS, 3/3 elaborated tops. One-copy slice, S=2 two-slice `otpu_top`, and actual `otpu_asic_top` (card configuration) each show 0 SCCs and 0 inferred latch cells.
- ASIC `aok` UNOPTFLAT warning is no longer an OPEN structural-loop blocker for the tested ASIC top; classify as a Verilator dependency/partitioning over-approximation in this elaboration. Do not generalise beyond tested configuration.
- Stream-tail init flush fix is committed; exact seed-3 random power-up regression passes (45915433368, 1 passed). Broad clean RTL-tail run 45915615625 still in progress.
- Full-chip lint 45915615693 PASS, 0 errors; 76 width warnings, 7 Verilator LATCH and 3 UNOPTFLAT diagnostics remain. Synthesized latch-cell audit is zero in all three tested netlists.
- Four-DIMM WG8 host AXI integration 45914912733 remains in progress. Manufacturer handoff remains NOT READY pending width cleanup, integration, formal/SVA, CDC/RDC, DFT and physical/timing signoff.

## 2026-11-27 ASIC integration and focused regression update

- ASIC/target configuration 45914912733: PASS. Chip, memory and WG8 DDR4 lint stages passed; four-DIMM hmux contention simulation passed host/accelerator AW/AR contention, alternating grants, ordered two-beat W bursts, B/R ID routing and independent backpressure (320 ns).
- ASIC lint still reports 99 WIDTH warning occurrences and 3 UNOPTFLAT occurrences across top elaborations. Explicit zero-extension of 33-bit MIG-pair AW/AR outputs into 34-bit host mux nets remains OPEN.
- FSUM guard: 11 passed (45915615614).
- 128K one-copy TMEM: 2 passed (45915615624).
- Loop-stack boundary: 2 passed (45915615653).
- Broad RTL-tail 45915615625 remains IN PROGRESS; Qwen, board, subsystem/memory and software/ISA runs remain nonterminal.
- Structural/reset audit 45914912691 PASS: reset 4/4; one-copy, two-slice and actual ASIC top each 0 SCC / 0 latch cells.
- Manufacturer handoff NOT READY pending broad regression, width cleanup, formal/SVA, CDC/RDC, DFT and physical/timing signoff.

## 2026-11-27 explicit AW/AR extension update

- Commit 600f3aa4822e18f03ba80d06ab86fd447189c126 adds explicit zero-extension of 33-bit MIG-pair AW/AR outputs into 34-bit host-mux nets. ASIC config 45916680920 is validating it; initial ASIC control, native-memory and four-DIMM AXI lint stages pass, host AXI simulation remains in progress. Previous 99 WIDTH warnings / 3 UNOPTFLAT are not yet closed.
- Full-chip lint 45916680866 PASS, 0 errors; 52 WIDTHEXPAND, 24 WIDTHTRUNC, 7 LATCH, 3 UNOPTFLAT remain.
- No-trace power-up regression remains OPEN pending 45916680719; trace-enabled seed-3 pass is supplementary only. Reset/structural audit 45914912691 and prior ASIC integration 45914912733 are PASS.
- Manufacturer handoff remains NOT READY; PPA not authorised.
