# SUNNYONE — Integrated Engineering, Silicon Demonstrator and Manufacturer-Sponsorship Plan

**Plan date:** 2026-11-27 (Asia/Dhaka)  
**Repository:** shamiursunny/openTPU  
**Working branch:** sunnyone/commercial-profitability-architecture-2026-11-23  
**Starting verified branch HEAD:** ee5eafecd38e82d99c62cd83f5f981230d522171  
**Protected project main SHA:** d84db55712aba0d40811d7762cb052f05d55b7e5  
**Status:** Integrated plan established; engineering and manufacturer handoff remain NOT READY.

## 1. Executive decision

The project now has two linked but separate deliverables:

1. **Full SUNNYONE inference-accelerator product architecture:** continue the existing programmable accelerator design and its system-level roadmap. Do not discard, silently shrink, or replace the current design to fit a low-cost shuttle.
2. **First-silicon demonstrator:** derive a small, testable compute/control block from the existing design only after source-level down-selection, technology-port feasibility, area/timing estimates, and manufacturer feedback. This demonstrator is a learning and physical-characterisation vehicle; it is not the complete SUNNYONE product.

The preferred funding route is a **written, fully sponsored research/education fabrication collaboration** with IHP or a university/research partner that can allocate fabrication, packaging, test access and sample delivery at no charge to the user. IHP is the first technical partnership target because it maintains an open 130 nm PDK ecosystem and open-silicon MPW activity. However, no currently available zero-cost IHP allocation, package, physical test service, or delivery entitlement has been verified. The historical FMD-QNC free-MPW records cover 2024–2025; continuation for 2026 was described as under development. Published 2026 IHP Open-Silicon MPW dates have already passed by this plan date. The current low-cost IHP MPW route is paid and is NOT authorised.

**Zero-spend rule:** no paid tapeout, area reservation, packaging, board, test, licence, cloud runner or hardware purchase without the user's explicit approval. If no written sponsor covers all required costs, pause fabrication and continue simulation/verification at no cost.

## 2. Scope and architecture baseline to preserve

The current architecture direction, recorded in ARCHITECTURE_DIRECTION_AND_CHIP_SELECTION_GATE_2026-11-23.md, is a programmable workload-oriented inference accelerator:

- Host-server control plane for boot orchestration, scheduling, telemetry, security policy and system management. The first-version accelerator does not currently contain an on-chip RISC-V CPU or boot ROM.
- Tiled matrix engine for dense linear algebra and attention projections.
- Vector/SIMD datapath for elementwise operations, normalisation, quantisation/dequantisation, activations and irregular kernels.
- Explicit local SRAM scratchpads and DMA to reduce off-chip traffic.
- Defined host/compute/DMA/memory interconnect and arbitration.
- External memory path with ECC intent; production controller, PHY, training and physical topology remain open.
- Programmable kernel/runtime layer to support multiple model families and operator fusion.

This is not yet a complete smartphone-class CPU/GPU/NPU/multimedia SoC. It is the current selected AI inference-accelerator direction. Do not claim otherwise or add an embedded CPU, GPU, multimedia or secure-boot subsystem without a requirements decision and implementation evidence.

The existing openTPU repository is the implementation and verification baseline. The Nangate45 WG8 ASIC target is a research implementation configuration, not the final selected manufacturing process. The Versal VC1802 / VSVD1760 remains a separate FPGA feasibility lead from the commercial platform study; it is not the IHP ASIC target and is not a selected production part.

### Memory and commercial constraints retained

- The 30 W total-system hard ceiling was retired by the user. There is no replacement wattage ceiling yet. Power must be selected from measured sustained useful throughput, thermal/reliability evidence and risk-adjusted total cost of ownership.
- 128 GB ECC DDR4 RDIMM remains a conditional system-level feasibility target, not a demonstrated implementation.
- The four-channel 4 × 32 GB 2Rx8 hypothesis and VC1802 / VSVD1760 lead require exact AMD Memory Interface Planning Tool, pinout, SPD/training, module and board verification.
- 256 GB is a stretch investigation only.
- The first small IHP demonstrator must not attempt to integrate a production DDR controller/PHY, 128 GB DIMM subsystem, PCIe/Serdes or a full server host interface unless the selected process, padframe, IP, package and area are independently proven. Use a compact, testable interface selected against the actual IHP I/O library and evaluation-board capability.
- Continue W1/W2/W3 workload and customer-economics evidence work. Do not freeze product memory, compute size, power envelope or commercial configuration from assumed demand.

## 3. Existing verification evidence — preserved and independently re-polled

All runs below are historical evidence tied to their recorded source SHA and selections. The latest major functional suite used source SHA 2835f1a8da6af454023caff9576f41258c66e2a8 unless otherwise stated. The current documentation/CI-instrumentation branch HEAD is later; that does not retroactively change the source SHA of these results.

### 3.1 Functional RTL, subsystem and memory

**Workflow 45845758545 — subsystem/memory matrix: SUCCESS; all 14 jobs terminal SUCCESS on 2026-11-27 re-poll.**

Actual pytest/log summaries inspected:

| Job | Result |
|---|---:|
| MX multiply/replay RTL | 17 passed |
| Quantizer corners/tie rounding | 8 passed |
| Quantizer modes | 15 passed |
| Collective hub, DMA and scoreboard | 128 passed |
| QST/QSTB RTL | 13 passed |
| SPLITQ RTL | 5 passed |
| Instruction cache RTL | 23 passed |
| Address-window RTL | 20 passed, 1 skipped (documented 64-GiB configuration makes every address DRAM) |
| Floating-point RTL | 8 passed |
| QHL RTL | 7 passed |
| Stream RTL | 14 passed |
| Wait-state RTL | 11 passed |
| Reset audit | 4 passed |
| Native DRAM and technology RAM | 104 passed |

Combined selected-job total: **377 passed, 1 intentional/documented skip**. Do not interpret this as all repository tests or full-chip signoff.

Relevant artifacts include:
- Native DRAM/technology RAM artifact 15139026052, SHA-256 9f18856ca1a5d114705645bc6fb541a0e940723356ef0dbdb7842d76e933e50d.
- Stream RTL artifact 15132346982, SHA-256 f8175ca55e63471deab21903454650631e82e372aed70d4fbc96ed69dd0362f8.
- Quantizer modes artifact 15132302427, SHA-256 387665baf7c670e1329c14d4e9ddc09e8027d6c33be559817d23ff91fe7db1ca.

### 3.2 Software, ISA, compiler and host

**Workflow 45845758659 — SUCCESS; all 15 jobs terminal SUCCESS on 2026-11-27 re-poll.**

Actual pytest summaries inspected; totals are **825 passed, 3 skipped** across:
- FP 12
- MX 32
- Compiler 44
- ISA 18
- Kernels 46
- VOPS 101
- Waits 268 passed, 2 skipped
- Stream 46
- Formats 13
- Quantisation 81
- Dataflow 27
- WAITW 6
- Host 108 passed, 1 skipped
- Host runs 18
- Host lock 5

These are the selected software test modules and do not establish production firmware, driver, security or system qualification.

### 3.3 Board and top-level functional evidence

- **Workflow 45845758677 — SUCCESS:** board-functional/host-model suite 198 passed, 8 skipped, 1 deselected. Artifact 15137400985, SHA-256 d0adc900e0ef37ecec1f2715a555e0e822306a79b01bb562b1bbfa23d4f8f9d8.
- **Workflow 45845758636 — SUCCESS:** RTL tail 33 passed, 1 intentional skip, 183 deselected. Artifact 15132004314.
- **Workflow 45845758681 — SUCCESS:** ASIC/target configuration. Actual logs show four-DIMM simulation PASS for concurrent host/accelerator AW/AR contention, alternating arbitration, ordered two-beat W bursts, B/R ID routing and independent backpressure. It also checked four-DIMM ports, 1/2/4/8-beat reads/writes, W-before-AW, partial/zero strobes, BRESP/RRESP codes, 4-KiB boundaries and backpressure. Out-of-aperture AW/AR rejection tests printed PASS. Global map check printed PASS for the 32-GiB map, four DIMMs, two 4-GiB channels per DIMM, 4-KiB interleave and inverse bijection. Artifact 15130743611, SHA-256 dc0a587493b7b9ca44355fbeb312798b3ef853e2f39e4fecb4ef35c345251863.
- **Workflow 45845758847 — SUCCESS:** official Qwen3-0.6B and Qwen3.5-0.8B checkpoint presence, architecture and checksum checks; real-checkpoint RTL pytest 6 passed, 4 deselected; separate tiny board-model selection 8 passed, 199 deselected. Artifact 15136893309, SHA-256 223804db48d7010633764082a0814e4237a36055aab652f22d5c2f4d069ac7d2.

### 3.4 Lint and structural quality

**Workflow 45845758782 — SUCCESS** using Verilator 5.032. The workflow's success means lint completed under its configured warning policy; it does not mean warning-free RTL.

Outstanding full-chip warning inventory:
- 52 WIDTHEXPAND
- 27 WIDTHTRUNC
- 7 LATCH
- 3 UNOPTFLAT

The 7 LATCH diagnostics are local temporaries in conditional branches of rtl/seq/otpu_seq.sv (around lines 1153 and 1823). Actual inferred latch-cell presence/absence has not been proven. The three full-chip UNOPTFLAT paths involve:
- gnt through VPU compression/grant logic in otpu_slice;
- sc_gl through collective request/grant logic in otpu_top/otpu_slice;
- pq through TMEM bank-data/bypass logic.

A separate ASIC configuration compile also reported an UNOPTFLAT circular dependency involving aok in otpu_slice.sv around line 906. Track this separately from the three-warning full-chip inventory. No blanket suppressions or waivers are accepted. Artifact 15130078429, SHA-256 6a1f1639094cfe3d8c800d4f9bd923375fa4dc613b0cb6c1e4f5c9244c6b8d75.

### 3.5 DMA timing experiment

Commit/source SHA 2835f1a8da6af454023caff9576f41258c66e2a8 rewrote six SRX stream-setup expressions in rtl/dma/otpu_dma.sv to select between constant-divisor calculations. Mathematical equivalence was exhaustively checked for su_ns 0–63, both selector states and representative positive SPC values 1, 2, 4, 8, 16 and 32. This is not formal RTL equivalence and does not establish a timing improvement.

### 3.6 PPA / physical implementation — unresolved failure

**Workflow 45845758658 — FAILURE**, exact source SHA 2835f1a8da6af454023caff9576f41258c66e2a8. Pinned ORFS image digest:
sha256:edbd355068b742c5ae2413a49a58578465bd52f57668cebebdd383eb4d97607d

- Synthesis and preliminary floorplan timing reporting completed; OpenROAD exited with code 247 during 2_1_floorplan.
- Peak RSS in archived log: 15,191,368 KB.
- No definitive OOM/cgroup/kernel kill evidence in the archived report. Root cause remains unconfirmed.
- Artifact 15137952036, SHA-256 66d8e83e4f5da5ee5b11be80e851ecfe04f6b801857ef9ee3d786246af47f560.
- Preliminary report: WNS 0.00 ns, TNS 0.00 ns, worst reported slack +0.46 ns, core-clock minimum period 2.04 ns / 489.55 MHz. It uses wire-load estimates and no estimated parasitics; it is pre-route, not routed STA or signoff.
- Synthesis proxy cell area 30,786,988.162 µm²; not die area or a foundry area estimate.
- Earlier baseline run 45545698546 reported WNS -10.43 ns, TNS -91.46 ns, minimum period 12.93 ns / 77.31 MHz, proxy area 30,794,339.338 µm², and also failed later in the physical flow. The two source revisions and ORFS image digests differ; no single-change attribution or timing-closure claim is permitted.
- Recurrence of Error 247 around 15.2–15.7 GB strengthens a resource-ceiling hypothesis but does not prove it.

### 3.7 Prior historical groups and workflow exclusions

- RTL groups 3.1, 3.2 and 4 had already passed in earlier recorded runs. Preserve that evidence; do not rerun them merely to reconfirm.
- User explicitly cancelled workflow 45765362426. Never restart it.
- No replacement run is justified solely to create a newer green badge where successful exact-scope evidence already exists.

## 4. Updated PPA diagnosis procedure

The workflow .github/workflows/sunnyone-asic-wg8-ppa.yml was updated in commit 783dc91d835b66279fc69ca0dd82ee3a9c403785 (blob 9d6025838eb01dc7ae93d7f7671e7b5be066ec33):
- Docker now receives --cpus 2 as well as ORFS_CPUS=2.
- Host memory/filesystem/ulimit baseline is captured.
- Container cgroup v1/v2 memory limit/current/peak/events and periodic five-second memory samples are captured where exposed.
- Telemetry is uploaded with the PPA artifact.

This is instrumentation, not PPA evidence. It has not yet been exercised. Review workflow syntax, failure/cleanup behaviour and artifact paths before any manual diagnostic dispatch. Keep the pinned image, exact source SHA and two-CPU setup fixed during the first diagnostic. Do not retry repeatedly or infer OOM without counters/kernel evidence.

## 5. Manufacturer and zero-cost fabrication strategy

### 5.1 IHP: first sponsored-collaboration target, not a confirmed free service

IHP's official Open Source Design Enablement page describes SG13G2 (130 nm SiGe BiCMOS) and SG13CMOS5L, open-source EDA flows, digital standard cells, I/O cells, some fixed-size SRAM macros, DRC/LVS resources and LibreLane integration. It describes the open PDK as Early Access/alpha for SG13G2 and preview for SG13CMOS5L; the open PDK is not currently designated production-ready.

IHP's historic FMD-QNC free-MPW documentation lists tape-ins through September 2025 and says free fabrication funding was for non-commercial research/education, with a continuation for the open-source community to be worked out. This does not establish a 2026 free allocation.

Published 2026 IHP open-silicon dates:
- SG13G2 run 29 September 2026; registration deadline 21 September 2026.
- SG13CMOS5L run 9 November 2026; registration deadline 26 October 2026.
Both are past as of 27 November 2026.

IHP's current low-cost open-MPW information lists indicative area prices of approximately EUR 2,800/mm² for SG13G2 and EUR 1,500/mm² for SG13CMOS5L, a basic offer of 20 bare dies, packaging on request at additional cost, and approximate processing times of 8 months for SG13G2 and 6 months for SG13CMOS. Therefore this paid route does not meet the user's zero-cost requirement and is not authorised.

IHP remains the first organisation to ask about:
1. a new fully sponsored non-commercial/educational research allocation;
2. whether a Bangladesh-based independent designer can participate directly or must be hosted by a university/research partner;
3. whether a university can act as eligible lead applicant and provide a research collaborator;
4. whether fabrication, dicing, packaging, board/test access, sample custody/delivery and physical characterisation can all be covered;
5. what open-source licence, export-control, IP ownership, publication, confidentiality and sample-sharing conditions apply;
6. the next open-silicon intake and the exact supported PDK/tool/IO/memory/test requirements.

Do not send private RTL, GDS, customer data or confidential IP before understanding the programme terms and publication/licensing requirements.

### 5.2 University/research partner route

In parallel, seek a university or research institute that can sponsor the project as an academic/research collaboration and provide a named faculty/IC-design supervisor, lab access, programme eligibility and a grant/shuttle allocation. The partnership must be real and documented; do not misrepresent the user's status, institutional affiliation or research credentials.

A zero-cost outcome is accepted only if the written agreement confirms all user-facing costs are zero, including:
- fabrication/MPW area and mask/shuttle charges;
- dicing and sample allocation;
- packaging and bonding;
- test board or adapter requirements;
- physical electrical/functional characterisation;
- test report and raw data access;
- sample custody, loan/ownership and delivery to the user;
- shipping, customs, taxes and any return charges.

If any cost remains, label it clearly and stop before commitment. Do not assume “free fabrication” includes package, test or shipping.

### 5.3 Manufacturer test and sample access

The user requires a physical sample tested by the manufacturer or an agreed research partner. Obtain written confirmation of:
- what tests are performed and what are excluded;
- whether bare die or packaged devices are supplied;
- number of samples and whether samples can be shipped to Bangladesh;
- whether test fixtures/board are included;
- electrical limits, test vectors, clock/power conditions and environmental conditions;
- raw measurements, failure analysis and reproducible test procedure;
- who owns/retains the samples and whether joint evaluation or rental is required.

A published historical IHP programme describes samples retained in an Open Chip Depot for joint evaluation/rental. Therefore sample delivery and custody cannot be assumed; they are mandatory negotiation items.

## 6. Two-track silicon plan

### Track A — Full product architecture

Continue the existing accelerator and system roadmap. Close design correctness, performance, memory, interface, security, software/runtime, power and commercial workload gates. Keep full product scope intact. The first physical demonstrator does not close this track.

### Track B — First-silicon demonstrator

After the current source inventory and PDK compatibility review, identify the smallest meaningful compute/control block already present in the repository. Candidate content may include a reduced matrix/vector datapath, local register/scratchpad structure, control/status interface, bounded input/output path, counters and test observability. Exact dimensions and block selection are NOT yet frozen.

The demonstrator should:
- preserve representative arithmetic/precision behaviour of the main accelerator;
- have deterministic host-controlled test vectors and self-checking on-chip or external test support;
- expose enough status and observability to diagnose failures;
- use only memory macros and I/O cells actually available in the selected PDK;
- include a manufacturer-reviewed testability/DFT plan;
- avoid production DDR PHY, PCIe/Serdes, large external DRAM, CPU/GPU/multimedia integration and unproven IP in the first small MPW unless the process and area feasibility are demonstrated;
- have a standalone specification, test plan, area/timing/power budgets and requirements-to-tests traceability.

Do not choose a 4×4/8×8 array, precision set, pad count, SRAM size, SPI/JTAG interface or die area by guess. Select these from the actual source blocks, PDK libraries, padframe, available macro dimensions, area estimates, test needs and sponsor/manufacturer feedback.

The demonstrator is a separate derivative/branch or isolated integration target. It must not overwrite the full product baseline or cause the current functional test suite to lose coverage.

## 7. Engineering execution sequence and acceptance gates

### E0 — Baseline and evidence integrity
- Freeze current branch/source SHA and exact test evidence.
- Keep main untouched and preserve all previous run artifacts/checksums.
- Create a reproducible source/configuration manifest and requirements-to-test matrix.
- Record known issues and exclusions.

### E1 — Functional and protocol closure
- Map each existing RTL block to its specification and tests.
- Expand AXI AW/AR/W/B/R, arbitration, backpressure, ordering, reset, memory boundary, DMA bounds/alignment, errors and concurrent host/accelerator scenarios.
- Keep tests tied to exact source SHA, tool version, seeds, test selection and artifacts.
- No unexplained failure or unjustified skip.

### E2 — Lint and structural proof
- Prove actual inferred latch-cell presence/absence using exact synthesis/elaboration settings.
- Trace the three full-chip UNOPTFLAT paths and separate ASIC aok path at elaborated-net level.
- Triage every width warning for signedness, intended range, index bounds and truncation.
- Correct only demonstrated defects; add boundary tests and equivalence checks.
- No blanket warning suppressions.

### E3 — Formal/SVA and CDC/RDC
- Expand assertions and proof for bus protocols, DMA bounds/alignment/ordering, arbitration fairness, reset, memory map, isolation and error handling.
- Include covers/reachability and review assumptions.
- Inventory clock/reset domains; run structural CDC/RDC and reset sequencing analysis; justify every exception individually.

### E4 — PPA diagnosis and synthesis quality
- Review updated telemetry workflow.
- Conduct at most a justified diagnostic run with pinned image and exact source SHA.
- Determine resource failure cause from cgroup events, host/runner evidence and stage logs; do not infer.
- Establish a stable synthesis baseline and separate synthesis area, floorplan estimates and routed results.
- No timing-closure claim until complete routed STA across required corners/modes.

### E5 — PDK and demonstrator feasibility
- Compare IHP SG13G2 and SG13CMOS5L only against current PDK status, supported standard cells, I/O/padframe, SRAM macros, clock/reset/test cells, LibreLane flow, DRC/LVS and sponsor constraints.
- Pin exact PDK commit and tool/container versions.
- Port a minimal source block; run lint, simulation, synthesis, floorplan and DRC/LVS checks in the selected technology.
- Establish area, pad count, power and clock feasibility before submitting a proposal.
- If the open PDK's alpha/preview status or unsupported macro/IP blocks prevent reliable work, report the blocker and seek an IHP-supported research/industrial design flow through the sponsor rather than presenting an experimental flow as production signoff.

### E6 — DFT, package and board/test plan
- Agree scan/test strategy, MBIST/LBIST where applicable, JTAG or alternative test access, boundary/IO testing, clock/test controls and fault diagnosis with the manufacturer.
- Select package, pinout, PCB/test fixture and supply/clock requirements only from the manufacturer's process and package information.
- Confirm test-vector ownership, test access, sample quantity and physical test report.

### E7 — First-silicon tapeout submission
- Only after sponsor and manufacturer confirm acceptance and zero cost in writing.
- Complete RTL-to-GDS for the exact target PDK, DRC/LVS, ERC/antenna and applicable physical checks, STA, power integrity and package requirements.
- Freeze a signed manifest with RTL, netlist, constraints, scripts, PDK revision, tool versions, GDS/OASIS, reports, checksums, licences and known limitations.
- Obtain human approval before final tape-in.

### E8 — Physical evaluation and learning loop
- Manufacturer/research partner fabricates, packages (if agreed), and tests the sample.
- Compare measured silicon against simulation and implementation estimates.
- Record functional, electrical, timing, power, thermal, reliability and failure-analysis results with conditions and raw data.
- Feed verified findings back into Track A; do not generalise a small demonstrator's results to the full product.

### E9 — Full manufacturer handoff and production qualification
- Use MANUFACTURER_HANDOFF_READINESS_MATRIX.md G0–G15 as the controlling release matrix.
- Complete target PDK, libraries/IP licences, RTL/formal/CDC, physical design, DFT, memory/interface, package/PCB/BOM, board validation, qualification and commercial evidence.
- Manufacturer may perform its own implementation/signoff, but our submission must be reproducible, complete for the agreed engagement and explicit about all open items.
- Tapeout-ready, production-ready and silicon-validated claims require their own actual evidence.

## 8. Current priority queue

1. Preserve and publish this integrated plan and new continuation checkpoint.
2. Review the PPA telemetry workflow for correctness and archive behaviour; no retry until justified.
3. Prove/disprove actual latch cells and elaborate the full-chip and ASIC-specific UNOPTFLAT paths.
4. Triage all 79 width warnings, including DMA and native DRAM address/size expressions; note ASIC-target compile warning on 34-bit-to-33-bit AW/AR port connections for focused review.
5. Expand formal/SVA and CDC/RDC evidence.
6. Inventory existing accelerator RTL blocks and select a first-silicon candidate without changing the full architecture.
7. Establish IHP PDK/LibreLane compatibility for the candidate and obtain written sponsorship/eligibility/cost/sample-test answers.
8. Only then create a dedicated demonstrator integration target and begin technology-specific porting.
9. Continue full-product workload, memory, host-interface, DFT, power, thermal and TCO feasibility.
10. Update checkpoint, tracker and readiness matrix after every material result.

## 9. Manufacturer handoff status

Current status remains **NOT READY**. Functional simulation evidence is substantial, but lint debt, formal/SVA scope, CDC/RDC, PPA failure, technology mapping, external memory PHY, production interfaces, DFT, physical implementation, package/board, silicon testing and qualification remain open or blocked.

An early feasibility conversation is permissible if clearly labelled as preliminary and accompanied by the open-gate matrix. Do not submit the current Nangate45 research flow as foundry-ready GDS or claim that the whole chip has passed every test.

## 10. Governing controls

- Work only on sunnyone/commercial-profitability-architecture-2026-11-23; never modify main.
- Zero-spend default. No paid services, foundry, hardware, licences or runners without explicit approval.
- Never restart cancelled run 45765362426.
- Do not rerun RTL groups 3.1, 3.2 or 4 solely to reconfirm historical success.
- Preserve all passing and failing evidence; no test-result inflation or duplicate aggregate totals.
- No broad warning suppressions, speculative RTL changes, fabricated metrics or readiness claims.
- Keep the full product architecture and the first-silicon demonstrator as separate, traceable deliverables.
- The user is the final decision-maker and final tape-in approver.

## 11. Public programme references checked 2026-11-27

1. IHP Open Source Design Enablement: https://www.ihp-microelectronics.com/services/research-and-prototyping-service/open-source-design-enablement
2. IHP low-cost open-source MPW access and current price/sample terms: https://www.ihp-microelectronics.com/services/research-and-prototyping-service/mpw-prototyping-service/low-cost-open-source-mpw-access-1
3. IHP MPW and prototyping service: https://www.ihp-microelectronics.com/services/research-and-prototyping-service/mpw-prototyping-service
4. Historical IHP Free MPW documentation and 2024–2025 schedule: https://ihp-open-ip.readthedocs.io/en/latest/index.html
5. IHP Open-Silicon MPW repository and submission process: https://github.com/IHP-GmbH/Open-Silicon-MPW
6. IHP Open PDK repository and status: https://github.com/IHP-GmbH/IHP-Open-PDK

This plan is an engineering and funding strategy. It is not a fabrication reservation, sponsor acceptance, PDK signoff, tapeout approval, or guarantee of free samples.


## 12. PPA workflow reproducibility correction — 2026-11-27

A review of the failed run 45845758658 logs found that the workflow pulled the mutable tag openroad/orfs:latest and then captured the resolved local image ID. The failed run's registry manifest digest was sha256:f5b2b4ac8cae150c30ad86857328300e20662cf7ff555978711ea8936f8d9539 and its local image ID was sha256:edbd355068b742c5ae2413a49a58578465bd52f57668cebebdd383eb4d97607d.

The workflow was corrected in commit e2d96d5364af47503d67cb70635bf3485cbe9b33:
- Pull the immutable manifest reference openroad/orfs@sha256:f5b2b4ac8cae150c30ad86857328300e20662cf7ff555978711ea8936f8d9539.
- Verify the resolved local image ID exactly equals sha256:edbd355068b742c5ae2413a49a58578465bd52f57668cebebdd383eb4d97607d.
- Archive both the manifest reference and resolved image ID with the PPA artifact.
- Keep the existing two-CPU Docker limit and cgroup resource telemetry.

This closes the mutable-image-tag reproducibility gap for the next diagnostic. It is a workflow-only change, not PPA evidence. No PPA run has been dispatched by this correction. Review the resulting workflow on the branch before deciding whether to dispatch the one diagnostic attempt. The pinned image is the same image used by the failed reference run; the run's resource cause remains unconfirmed.


## 13. Lint and combinational-path source triage — 2026-11-27

Detailed evidence is recorded in docs/sunnyone/LINT_AND_COMBINATIONAL_PATH_TRIAGE_2026-11-27.md and reflected in the manufacturer matrix.

- All seven LATCH diagnostics in rtl/seq/otpu_seq.sv are within ifndef SYNTHESIS diagnostic branches. The ASIC flow defines SYNTHESIS, so these seven variables are excluded from hardware synthesis. Do not change functional RTL to silence them. A final synthesized-netlist latch-cell check remains required.
- pq aliasing is likely a Verilator packed-array granularity false positive: guest ports alias a selected host_of(p) port, while only host_of(p)==p creates the owning g_copy. Confirm the generated graph.
- sc_gl is likely a process-granularity false positive: cgl_c is calculated from request/conflict state in a process that also assigns gnt_c[G_COLL] from coll_gnt; cgl_c itself does not read coll_gnt. Confirm the elaborated graph before any process split.
- aok is likely a packed-vector granularity false positive: the priority loop only depends on lower-index aok[h] values for h<g. Confirm per-bit dependency.
- gnt remains OPEN and is the highest-priority structural path. Trace the exact parameterized VPU/TMEM request/grant graph and sequential boundaries; do not insert a register or change handshake semantics based on the warning alone.
- The 79 width warnings and ASIC-specific AW/AR port-width warnings remain open.

The manufacturer handoff matrix G3 remains OPEN. Source-level triage is not equivalent to a clean lint or a synthesized-netlist proof.


## 14. Width-warning inventory and preliminary risk triage — 2026-11-27

Created docs/sunnyone/WIDTH_WARNING_INVENTORY_2026-11-27.md. It preserves all 79 exact Verilator diagnostics (52 WIDTHEXPAND, 27 WIDTHTRUNC) from workflow 45845758782, tied to source SHA 2835f1a8da6af454023caff9576f41258c66e2a8.

Nine warning instances are confirmed inside ifndef SYNTHESIS regions and are marked SIM_ONLY in the inventory:
- otpu_vpu.sv:1454
- otpu_mxu.sv:2305, 2306, 2607
- otpu_seq.sv:678, 681, 762, 1838, 1839

The remaining 70 are still OPEN for individual source/configuration and semantic review; do not assume all are hardware defects or harmless extensions. otpu_dram.sv exists() diagnostics are in the simulation DRAM model but need confirmation against the exact ASIC source list before being labelled non-hardware.

Highest-priority bounds checks:
1. VPU row-sum buffer rb[NRB/LANES] uses rows_done[15:LW] and fl[15:LW] (13-bit indices into a 32-entry array for the common LANES=8 configuration). Prove row-count bounds and final-cycle behaviour. RDOT rdb_i is gated by rows<=NRB; FSUM shape validation currently appears in simulation-only code and must be reconciled with the hardware input contract.
2. Sequencer LOOP stack writes four-entry arrays using three-bit sp. ISA docs specify maximum loop nesting depth 4, but the push site has no visible sp<4 guard. Prove all input programs are validated; add a hardware-safe overflow/error response if malformed commands can reach the sequencer.
3. VPU 24-bit one-hot function masks are indexed by wider VOP enum/op values. Prove all function indices are 0–23 before applying a sized index.
4. MXU drain and key arrays are indexed with wider values. The drain helper includes an explicit bounds conditional; prove the computed index is within MCOLS. Prove mxm/mx_i bounds before narrowing mx_key indices.
5. Review remaining arithmetic/shift/constant warnings for expression sizing, signedness, carry/borrow and parameter ranges. Use explicit casts only after proof.

No RTL changes were made. The inventory and source-guard classification are evidence organisation, not lint closure. G3 remains OPEN and the manufacturer handoff remains NOT READY.


## 15. Sequencer LOOP stack overflow guard — implementation and verification pending

Source review found a real robustness gap: the ISA simulator rejects a fifth non-zero nested LOOP with SimError("loop stack overflow"), and docs/isa.md specifies maximum nesting depth 4. The RTL sequencer had a four-entry stack indexed by three-bit sp but did not visibly guard the push site.

Implemented in rtl/seq/otpu_seq.sv, commit 28c36c52204fe2ec2ed36413b02eb6043506ccc4:
- Before a non-zero loop push, test sp >= 3'd4.
- On overflow, set error and halted instead of writing outside the stack.
- For legal depths, use sp[1:0] after the guard.
- Legal four-level behaviour is unchanged by construction; it still requires regression evidence.

Added two RTL tests in tests/test_rtl.py, commit c22c9b1be497b62253693e817d7d3b5fdca1c79f:
- test_loop_stack_maximum_legal_depth_four_rtl
- test_loop_stack_overflow_reports_error_before_out_of_range_rtl

Added a dedicated workflow .github/workflows/sunnyone-loop-stack-guard.yml in commit 275728cd1484fb3b409ba59b9b409f29160c8f7e. Workflow run 45877985241 is IN_PROGRESS; do not claim the tests pass until its archived log and final status are inspected.

The source commit automatically started the normal suites. Full-chip lint workflow 45877786797 completed SUCCESS on source 28c36c52204fe2ec2ed36413b02eb6043506ccc4. Its log contains 76 width warnings (52 WIDTHEXPAND, 24 WIDTHTRUNC), down from 79; the three removed diagnostics were the direct 3-bit loop-stack indices. The seven simulation-only LATCH diagnostics and three UNOPTFLAT diagnostics remain. This is a measured lint improvement, not lint closure.

WG8 PPA workflow 45877786710 is IN_PROGRESS on source 28c36c52204fe2ec2ed36413b02eb6043506ccc4 after the RTL change. The workflow now uses the immutable ORFS manifest digest and resource telemetry. Verify its logs, archived telemetry and final status before interpreting the result. No second PPA run should be launched while this one is active.

Other source-triggered workflows on the same source SHA are in progress or queued: reset audit 45877786738, Qwen RTL 45877786754, board functional 45877786742, subsystem/memory 45877786699, software/ISA 45877786705 and ASIC config 45877786860. The tail run 45877787004 was cancelled by the newer commit; the replacement tail run 45877807906 is in progress on the test commit. The separate 128K one-copy TMEM investigation 45877807985 is also in progress. Do not restart the explicitly cancelled historical run 45765362426.


## 16. Loop-stack and isolated TMEM verification results — 2026-11-27

**Loop-stack guard workflow 45877985241 — SUCCESS**, source commit 275728cd1484fb3b409ba59b9b409f29160c8f7e:
- test_loop_stack_maximum_legal_depth_four_rtl passed.
- test_loop_stack_overflow_reports_error_before_out_of_range_rtl passed.
- Total: 2 passed, 217 deselected, 47.52 seconds.
- Artifact 15146995084; uploaded ZIP SHA-256 bc7202d01bf896453a2fdd8e3f752d34e719e85db9ddc582ebcba0196380b7ff.
This verifies the legal depth-four case and the fifth-level overflow error/halt path under the targeted RTL simulation. It does not prove all sequencer behaviour or full design signoff.

**Isolated 128K one-copy TMEM investigation 45877807985 — SUCCESS**, source commit c22c9b1be497b62253693e817d7d3b5fdca1c79f:
- test selection: tests/test_rtl.py -k one_copy_tmem_of_128k_words
- Total: 2 passed, 217 deselected, 75.03 seconds.
This is separate from the loop-stack guard tests.

Full-chip lint 45877786797 also succeeded on RTL source commit 28c36c52204fe2ec2ed36413b02eb6043506ccc4, with width warnings reduced to 76 (52 expand, 24 truncation). PPA run 45877786710 remains IN_PROGRESS on the same source commit; it is the single diagnostic run using the immutable ORFS manifest digest and memory telemetry. No duplicate PPA run.


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
