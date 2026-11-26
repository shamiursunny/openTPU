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
| G3 — Lint and structural quality | All critical lint findings fixed or individually justified by elaborated/synthesis evidence; no unexplained latches, combinational loops, undriven/multiple drivers, width truncation or unsafe constructs. No blanket suppressions. | **OPEN.** The 7 LATCH diagnostics were traced to ifndef SYNTHESIS simulation-only sequencer instrumentation and are excluded by the ASIC synthesis define; a final synthesized-netlist latch-cell check remains required. The 3 UNOPTFLAT paths (gnt, sc_gl, pq) and ASIC-specific aok path have source-level triage but are not closed; of 79 width warnings, 9 are confirmed inside ifndef SYNTHESIS regions and marked SIM_ONLY, while the remaining 70 still require individual synthesis/configuration and semantic review. ASIC AW/AR port-width warnings remain. See WIDTH_WARNING_INVENTORY_2026-11-27.md. See LINT_AND_COMBINATIONAL_PATH_TRIAGE_2026-11-27.md. |
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
