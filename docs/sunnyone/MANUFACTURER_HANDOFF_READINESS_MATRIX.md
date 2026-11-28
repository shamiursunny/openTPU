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


## 2026-11-27 additional regression evidence

The latest subsystem/memory workflow 45916680829 exposed a QHL random-power-up failure: `test_qhl_power_up_rtl[1-False]` failed at `rtl/vpu/otpu_se_tail.sv:281` with `kv_v=0,e2=1,e3=1`, `init=0`; six sibling QHL tests passed. Keep the general regression/readiness gate OPEN until this is explained and corrected or the assertion invariant is rigorously revised. The separate RTL-tail selection (45916680719, 33 passed/1 skipped) does not close the QHL case. The ASIC config run 45916680920 passed; the bad AW/AR aperture assertions were expected negative-test rejections and must not be misclassified as failures. Software waits job 45916680756 was cancelled. No readiness gate is upgraded solely from these results. Manufacturer handoff remains NOT READY.


## 2026-11-27 — PPA resource failure evidence

PPA run 45877786710 is FAILED at ORFS floorplan PDN (exit 247). Downloaded artifact 15152974135 confirms host OOM-killer activity: `oom_kill=1`, peak cgroup-accounted memory 16,155,115,520 bytes, host MemTotal 16,366,484 kB, while cgroup `memory.max=max`. This is not a completed PPA result and supplies no signoff area/timing/power metrics. The run had `ORFS_CPUS=2` correctly propagated to ORFS `NUM_CORES=2` and Docker `--cpus=2`; prior suspected propagation mismatch is disproven for this source. No PPA retry authorised. Physical implementation and timing/power signoff remain OPEN / BLOCKED. No handoff readiness upgrade.


## 2026-11-27 — FSUM hardware ingress guard evidence

The synthesizable raw-program FSUM guard is present in `rtl/seq/otpu_seq.sv`; focused tests in `tests/test_rtl.py` cover invalid row/column/B-mode shapes, feature-disabled producer/take, missing producer, effective HAS_SS capability, pending producer at HALT, unrelated function, and legal 256x64 producer/take. Workflow 45915615614 job 140233980040: SUCCESS, 11 passed, 219 deselected. Mark this specific FSUM guard gate PASS for its tested scope only. It does not clear QHL random-power-up, broad VPU/stream, formal, CDC/RDC, DFT, technology SRAM or physical implementation gates. Overall manufacturer handoff remains NOT READY.


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
### Readiness interpretation
- QHL seed-1 assertion/reset qualification: CLOSED for the exact tested case only.
- Reset structural audit: PASS for the three named tops/configurations and four reset tests.
- RTL subsystem/memory suite: PASS for the 14 jobs in run 46016022758, including the 7-test QHL job.
- Board-functional suite: NOT COMPLETE; run 46016022808 was cancelled.
- Software stream job: NOT RUN; dependency installation failed before pytest due to Microsoft Ubuntu repository HTTP 403. Other 14 jobs succeeded.
- Lint, formal/SVA, CDC/RDC, DFT, SRAM technology mapping, production interfaces, routed physical signoff, Track B down-select and sponsorship/sample path remain OPEN.



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


## Continuation update — board evidence reconciliation, Qwen checkpoint verification and isolated STREAM recovery
### Readiness matrix evidence update
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


## 2026-11-28 status reconciliation

This is a status update, not a gate closure. See `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_0050.md` for exact run/source/artifact references.

- Functional/software evidence now includes isolated STREAM 46/46 at its tested source SHA; this closes only that module.
- QHL seed-1 reset-qualified targeted case and the 7-test subsystem QHL selection passed; broader power-up/seed/configuration coverage is not declared closed.
- FSUM hardware-ingress guard is implemented and focused-tested (11 passed, 219 deselected); no further action absent a new defect.
- Board-functional 198 passed, 8 skipped, 1 deselected remains historical scoped evidence, not a current-SHA full board signoff. Qwen real-checkpoint runs are simulation evidence only.
- WG8 PPA remains failed with no routed PPA report; no retry authorised. No area/timing/power signoff claim.
- Lint/structural gate remains OPEN: width warnings and `gnt`/ `sc_gl`/ `pq` plus ASIC `aok` dependencies require exact elaborated evidence. Formal/SVA, CDC/RDC, DFT, real memory mapping, production interfaces, routed physical and thermal/reliability gates remain open or blocked.

**Release decision unchanged: NOT READY for manufacturer handoff.** Zero spend and protected-main exclusion remain in force.



## 2026-11-28 VPU lint remediation status

- Structural SCC/latch audit: PASS for one-copy slice, two-slice top and actual ASIC card top (run `45914912691`): zero combinational SCCs and zero inferred latch cells. The `gnt`, `pq`, `sc_gl`, `aok` warnings are not backed by SCCs in these exact elaborations; generic warnings remain.
- VPU index-width cleanup committed on feature branch (source SHA `05879ea34eafc2559c54722c6c940b2acb9ac3ee`). Full-chip lint passed (run `46053311384`) with 59 width warnings, down from 76. This is partial lint remediation, not warning-free closure.
- Focused VPU regression is not yet verified: first run failed at build on Verilator 5.020 before RTL simulation; pinned 5.044 run `46053471843` is pending/in progress.
- Five MXU index warnings, 52 width expansions, formal/SVA, CDC/RDC, DFT, technology mapping, production interfaces and physical signoff remain open.

**Release decision remains NOT READY for manufacturer handoff.**


## 2026-11-28 20:17 — MM malformed-command gate

The synthesizable MM guard remains OPEN. The ISA/simulator cross-audit confirms the guard must cover N/KB/M, ACT_ROWS/ACT_BLOCKS, MCOLS/RMAX/ASCALE, PAIR/WF/k0, RSC/NVFP4, exact WG/GALL group semantics, KT, SPLMM, alignment and MXU stream-FIFO capacity. The sequencer currently lacks several required configuration parameters. No speculative partial guard was committed. First close exact elaboration/capability propagation and narrow workflow path filters; then add raw-word tests proving pre-dispatch rejection and no TMEM/DRAM side effects while retaining legal boundary cases. See `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_2017.md`. G3/release remain OPEN; manufacturer handoff NOT READY.


## 2026-11-28 — MM guard and CI containment gate

- **MM malformed-command guard: OPEN.** Sequencer lacks the exact MCOLS, ACT_ROWS, ACT_BLOCKS, MXU FIFO depth, KT and SPLMM configuration currently held by `otpu_slice`. Do not claim pre-dispatch MM safety until those exact values are propagated and the complete simulator/ISA constraints are implemented.
- **CI containment: PLAN DEFINED, NOT EXECUTED.** All 25 workflows were inspected. Sequencer/slice RTL changes fan out into numerous broad RTL, ASIC, reset, board, Qwen and subsystem workflows. The planned focused flow is a dedicated MM raw-word workflow, a skip-CI source commit, and manual dispatch against the exact SHA. No workflow was added or dispatched in this continuation.
- Required test evidence: raw encoded malformed MM commands rejected before dispatch, no TMEM/DRAM side effects, and legal boundary controls for natural/grouped/PAIR/KT/SPL modes. Runtime memory-content checks (e.g. KT ACT tail zero) must not be misrepresented as static decode checks.
- MXU FIFO-depth rule remains under investigation; inspect actual backpressure and simulator configuration before deciding whether KB greater than FIFO depth is invalid or merely stalls.
- Full workflow mapping and exact contract: `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_WORKFLOW_MM_AUDIT.md`.
- No RTL/test/workflow changes and no new tests were launched. Manufacturer handoff remains **NOT READY**.


## Target geometry and FIFO admission audit — 2026-11-28

- Target TOMLs cover MCOLS 2/4/8, WG 1/8, ACT_ROWS default/effective 2/4/8 or explicit 8/16, ACT_BLOCKS 32/128, KT on/off and FIFO_DEPTH 64/1024/2048. A hard-coded guard is unacceptable.
- MXU replay FIFO assertions are simulation-only (`ifndef SYNTHESIS` `$fatal`) and are not the required synthesizable pre-dispatch guard. Natural replay rows use KB chunks (int8) or ceil(KB/2) (4-bit); grouped replay rows with M>1 require KB<=DEPTH. Validate the flow-control invariant before synthesizing equivalent admission logic.
- ISA simulator Config does not model FIFO_DEPTH; this physical/uarch admission constraint is separate from ISA semantic validation.
- ACT_ROWS=0 means effective ACT_ROWS=MCOLS in the slice. The sequencer must receive resolved effective geometry.
- Status: **OPEN** pending target-variant inventory, formal guard design, raw-word tests, focused CI pass and later controlled broad qualification.


## Target variant override gate — 2026-11-28

- Target variants matter: `bcu1525-s2:kt` and multiple `bcu1525-wg:*` variants enable KT; `bcu1525-x2:b2` enables SPLMM; `ypcb-00338:m8` changes MCOLS to 8. Base TOML-only review is insufficient.
- Required guard test matrix must resolve base plus variant, include positive KT and SPLMM variants, and include disabled-capability negative controls.
- Evidence and exact variant names: `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_WORKFLOW_MM_AUDIT.md`.
