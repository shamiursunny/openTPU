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


### FSUM ingress follow-up — 2026-11-27

- Reviewed `opentpu/host/board.py::Board.load_program`: it accepts raw uint32 instruction arrays, performs only the GATHER capability check plus basic slice/wait-entry validation, and writes the words to DRAM/IMEM. No FSUM semantic row-bound validation is present at this ingress.
- Therefore the compiler and ISA simulator checks do not establish an enforced end-to-end load contract. The FSUM bounds issue is an unclosed hardware safety risk for `bcu1525-wg` and `bcu1525-x2`, not merely a question about hypothetical raw input. Prefer a synthesizable invalid-command rejection after tracing the sequencer's existing error/halt path; do not add a second error protocol.
- Updated evidence is in `INPUT_BOUNDS_AND_PPA_RESOURCE_CONTROL_REVIEW_2026-11-27.md`. No RTL change made.


### Existing error/halt path traced — candidate guard location, not yet implemented

- `otpu_seq` exposes `error` and its existing invalid decoded-operation branch sets both `error <= 1'b1` and `halted <= 1'b1` before dispatch (around lines 1702–1705).
- `otpu_slice` connects `otpu_seq.error` to `sq_err` and exposes `error = sq_err || to_err` (around lines 355–366 and 437). The VPU itself currently has no error output.
- A candidate minimal architecture is to pass the slice's `VPU_FSUM` configuration into the sequencer and validate an FSUM-bearing VOP's decoded `cmd_t` before dispatch, reusing the existing sequencer error/halt path. The exact decoded-field timing and full FSUM contract still require a focused review; this is not an approved patch.
- Do not change `otpu_seq.sv` while PPA run 45877786710 is active: that file is in the PPA workflow path filter and the workflow uses cancel-in-progress concurrency. Wait for the current run's terminal result, then implement only with targeted boundary tests and an explicitly justified CI run.


## 18. Live verification reconciliation and PPA resource diagnosis — 2026-11-27

The live workflow poll and archived logs now supersede the earlier in-progress statuses in sections 15–17:
- Qwen 45877786754 SUCCESS: 6 real-checkpoint RTL tests passed (4 deselected) and 8 tiny board-model cases passed (199 deselected).
- Board-functional 45877786742 SUCCESS: 198 passed, 8 skipped, 1 deselected.
- Subsystem/memory 45877786699: all 14 jobs SUCCESS; 385 passed, 1 documented skip across archived per-job logs.
- Software/ISA 45877786705: all 15 jobs SUCCESS; 825 passed, 3 skipped across archived per-job logs.
- Reset 45877786738, ASIC config 45877786860, RTL tail 45877807906, isolated 128K TMEM 45877807985 and LOOP stack guard 45877985241 all SUCCESS. The focused LOOP stack guard had 2 passed / 217 deselected.
- WG8 PPA 45877786710 FAILURE and terminal; no active PPA run remains in this listed set. No workflow was relaunched during reconciliation.

The full PPA artifact is documented in docs/sunnyone/PPA_RESOURCE_DIAGNOSIS_2026-11-27.md. The immutable image digest and local ID were verified; Docker --cpus 2 was applied and OpenROAD reported two threads. Floorplan, macro placement and tap-cell insertion completed; failure occurred in 2_4_floorplan_pdn/check_placement with ORFS Error 247. The artifact's cgroup telemetry records memory.max=max, memory.peak=16,155,115,520 bytes and final oom_kill=1 (oom=0, oom_group_kill=0, max=0); host MemTotal was 16,366,484 kB. This is a confirmed OOM-kill event and strongly supports host-level memory exhaustion, but no kernel victim-selection log was archived. Do not claim a more specific kernel mechanism.

Decision: do not rerun full-chip PPA on an equivalent 16 GB runner. Consider only a justified zero-cost larger-memory runner or a technically valid staged diagnostic; no automatic retry or spend.

The 01:37 note that ORFS_CPUS was ignored is superseded by docs/sunnyone/CONTINUATION_REVIEW_2026-11-27_0145.md: the actual CLI reads ORFS_CPUS and passes the parsed value into run(), so the workflow used two workers. Do not change flow.py based on the stale diagnosis.

Remaining high-priority engineering work is FSUM synthesizable bounds rejection and boundary tests; exact elaborated-netlist/SCC analysis of UNOPTFLAT; semantic closure of the remaining 76 width warnings and ASIC AW/AR width warnings; formal/SVA, CDC/RDC and synthesized-netlist latch checks; then PDK/macro/physical/interface/DFT/board/manufacturer gates. Manufacturer handoff remains NOT READY. Track A and Track B stay separate.

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


## 19. FSUM sequencer guard and PPA trigger control — 2026-11-27

The synthesizable sequencer guard is now implemented and verified. FSUM capability is passed to the sequencer as VPU_FSUM != 0 && HAS_SS, matching the VPU. The R-stage rejects EXP2SUB+FSUM rows 0 or >256, columns <64, scalar B mode, FSUM on unrelated VOP functions, and FSUM commands when the effective capability is absent. A 32-bit pending counter tracks dispatched EXP2SUB producers and RSUM takes; an unmatched take and HALT with untaken sums now raise error. The valid RSUM+FSUM take remains accepted.

Focused CI 45911471194 SUCCESS: 11 passed, 219 deselected; legal 256x64 producer/take and output/sums passed. Full-chip lint 45911470968 SUCCESS with 76 width, 3 UNOPTFLAT and 7 LATCH warnings still open. Loop-stack and isolated 128K TMEM checks succeeded.

OPEN semantic gap: the sequencer counter does not store per-producer sum destination/row metadata. Exact RSUM take destination and row-count matching against the oldest producer remains enforced by the ISA simulator but is not independently enforced by hardware. Keep this explicit in the signoff matrix.

PPA safety: WG8 push trigger now requires docs/sunnyone/PPA_EXECUTE_REQUEST.md plus [RUN-PPA] in the commit message. Ordinary documentation/RTL/flow commits cannot auto-launch PPA; workflow_dispatch remains for deliberate approval. No PPA dispatched.

Report: docs/sunnyone/FSUM_HARDWARE_GUARD_REPORT_2026-11-27.md.


## PPA trigger incident correction — 2026-11-27

Correction to the preceding note: editing PPA_REQUEST.md itself initially triggered WG8 PPA run 45911873124. This was an assistant-authored workflow-control mistake. The run was cancelled at 23:37:04Z after approximately 73 seconds. Its retained artifact (15159964408; ZIP SHA-256 a5a1bea55d30b1b0e5721f2eae33049bd0003a1504c7925f84aa5e676c05ccf3) shows macro prep/config and Yosys 1_1_yosys_canonicalize only; no floorplan, placement, CTS, PDN or PPA report. cgroup peak was 894,529,536 bytes; OOM counters were zero. One minute of GitHub-hosted runner time was consumed; exact billing/quota cannot be established from this interface.

The corrected workflow is in commit 98335138bd73751699afc4a31ce0b206ff2720a1. Push paths are now docs/sunnyone/PPA_EXECUTE_REQUEST.md and the workflow file; a push job also requires [RUN-PPA] in the commit message. The correction run 45911965872 was SKIPPED and caused cancellation of the accidental run. PPA_REQUEST.md is documentation only. Do not create PPA_EXECUTE_REQUEST.md or use workflow_dispatch without explicit user approval of the exact source SHA.

Full incident evidence: docs/sunnyone/PPA_TRIGGER_INCIDENT_2026-11-27.md.


## 21. Structural SCC/latch results — 2026-11-27

Two Yosys/Slang flattened-netlist runs passed (45913401437 and independent repeat 45913488085). The one-copy slice and S=2 `otpu_top` each report zero SCCs and zero inferred latch cells. This closes the actual combinational-loop question for generic `gnt`, `pq`, and `sc_gl` in the tested configurations; Verilator UNOPTFLAT warnings remain emitted but are not actual SCCs in those configurations. The two-slice top blackboxes the behavioral associative-array DRAM model; the real slice/collective logic remains elaborated.

The separate ASIC `aok` UNOPTFLAT warning is not covered and remains OPEN. Generic latch absence is not an all-ASIC configuration proof. Continue with ASIC-top SCC analysis, width-warning closure (76 generic warnings plus ASIC DMA/native-DRAM/AW-AR warnings), explicit MIG address extension, formal/SVA and CDC/RDC. Report: docs/sunnyone/STRUCTURAL_SCC_AND_LATCH_AUDIT_2026-11-27.md.


## 2026-11-27 continuation reconciliation — power-up, FSUM and structural evidence

The latest live repository reconciliation is recorded in PROJECT_TRACKER.md section 116 and the current continuation checkpoint. Do not use the earlier task order without incorporating these updates.

The FSUM hardware guard has targeted evidence (run 45911471194, 11 passed), but hardware still lacks a producer metadata FIFO to enforce exact oldest-producer RSUM destination/row-count matching. Generic structural SCC/latch audits (45913401437 and 45913488085) report zero SCC and zero inferred latch cells in the tested one-copy slice and S=2 top; ASIC-top aok and ASIC-wide latch evidence remain open. Generic lint remains at 76 width warnings, with additional ASIC-specific width warnings.

A random power-up A/B workflow (45913977727) attempted the exact seed-3 test on pre-FSUM and post-FSUM snapshots, but both jobs failed before simulation because the Ubuntu 24.04 apt Verilator did not recognise --no-assert-case. This is a toolchain failure and provides no comparison. Separately, RTL-tail run 45911471173 reached simulation and failed test_random_power_up[1-3] at otpu_se_tail.sv:277 because kv_v, e2 and e3 overlapped (0,1,1). Treat this as a real unresolved assertion/regression until a compatible Verilator A/B comparison and cycle-level proof establish cause. Do not suppress the assertion or attribute it to FSUM without evidence.

The prior WG8 PPA failure has confirmed cgroup oom_kill=1 at near-host-memory peak on the 16 GB runner. No equivalent-runner retry is acceptable; PPA remains unauthorised without explicit approval. Manufacturer handoff remains NOT READY. Track A full product architecture and Track B small demonstrator remain separate; no PDK, sponsorship, fabrication, packaging, sample access or shipping is confirmed.

Immediate engineering order: (1) pin and capability-check a Verilator toolchain supporting --no-assert-case, then obtain the intended A/B evidence; (2) investigate the otpu_se_tail slot-overlap failure without weakening assertions; (3) implement exact RSUM producer metadata matching and directed tests; (4) close ASIC-top aok SCC/latch and width/AW/AR issues; (5) expand formal/SVA and CDC/RDC; (6) continue memory/interface/DFT/physical/board/manufacturer gates. Preserve zero-spend and protected-main project rules.


## 2026-11-27 A/B regression evidence — FSUM snapshot is not regression-clean

The first A/B run failed on toolchain compatibility; the corrected run 45914084753 on ubuntu-latest is valid. The pre-FSUM source snapshot passes the exact deterministic random-power-up case (1 passed); the post-FSUM-guard snapshot fails the same case at rtl/vpu/otpu_se_tail.sv:277 because kv_v/e2/e3 overlap (0/1/1). This is a reproducible regression associated with the FSUM guard snapshot, but the precise causal mechanism is not yet isolated. The FSUM targeted suite passing 11 tests does not override this failure. Do not claim the FSUM change is regression-clean, remove the assertion, or change stream scheduling without cycle-level evidence. Investigate reset/initialisation, random-state sensitivity and the stream-tail valid pipeline; produce a minimal reproducer and waveform. Preserve the pre-guard/post-guard source SHAs and retest after a minimal correction.

ASIC-top structural SCC/latch audit 45914201799 is pending at this checkpoint; do not update G3 until its ASIC-top elaboration result is terminal and inspected. The reset/power-up portion was skipped for the [SCC-ONLY] commit.


## Stream-tail reset boundary: candidate correction under regression

The corrected A/B power-up run showed that the pre-FSUM snapshot passed and post-FSUM snapshot failed at the tail's D-slot valid overlap. The follow-up diagnostic (45914665954) showed the overlap during init with rst=0, pe=1, kv_v=0, e2=1 and e3=1. The candidate correction in commit 024928752fef7ab774502d2a19f49111cc86b1ff flushes e2/e3/dv on rst||init and suppresses the assertion only on the synchronous init flush edge. This is not yet accepted: prove that it does not discard valid final outputs from the preceding stream, using RTL-vs-ISA comparisons and the current tail/reset audits (45914912747 and 45914912691).

The debug artifact contains a program, DRAM image, sync metadata and textual trace, not a VCD. Do not describe it as a waveform. ASIC-top structural audit had an infrastructure/script failure due to literal escaped newlines; corrected in d43fa38047b250e008e9d25b039708f621b96282 and re-running under 45914912691. Generic SCC results remain scoped to tested configurations until this ASIC-top audit is terminal.


## Stream-tail candidate fix — targeted pass, full regression pending

The init-flush candidate (RTL commit 024928752fef7ab774502d2a19f49111cc86b1ff) passes the exact previously failing test_random_power_up[1-3] on run 45915433368 (1 passed, 40.33 s, RTL/ISA comparison completed). This validates the deterministic seed-3 failure correction, but broad stream-tail regression run 45915615625 remains in progress. The temporary tracing and A/B harness was removed by commits 6290b360 and 425e794; the standard unique-random test remains.

Full-chip lint 45915615693 passed with zero errors but still reports 52 WIDTHEXPAND, 24 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT warnings. Reset/power-up stage passed in 45914912691; ASIC-top SCC/latch stage is still running. Four-DIMM WG8 integration 45914912733 remains open. Do not claim complete G1/G2 or manufacturer readiness until broad RTL/ISA, ASIC structural and integration evidence is terminal and reconciled.


## 23. Terminal ASIC structural audit and stream-tail reset correction

Workflow 45914912691 is terminal SUCCESS. Reset/power-up audit passed 4/4. Artifact 15162062669 confirms zero SCCs and zero inferred latch cells in all three elaborated tops: one-copy slice, S=2 two-slice `otpu_top`, and actual `otpu_asic_top` with the card configuration and SRAM macro boundaries blackboxed. The ASIC `aok` UNOPTFLAT diagnostic is therefore not a structural combinational loop in the tested ASIC netlist; it is a Verilator dependency/partitioning over-approximation for this configuration.

The stream-tail reset correction flushes `u_e2`, `u_e3` and `u_dv` on `rst || init`; the overlap assertion is suppressed only on the synchronous init edge. The exact previously failing seed-3 power-up test passes on the corrected source (45915433368, 1 passed, 40.33 s). This supports the diagnosis that stale stream-valid pipeline state survived stream init. The clean full RTL-tail suite 45915615625 remains in progress and is required before declaring the broader stream gate closed.

Full-chip lint 45915615693 passed with zero errors; 76 width warnings, 7 Verilator LATCH diagnostics and 3 UNOPTFLAT diagnostics remain. The three flattened structural netlists contain zero latch cells, but warning triage and width cleanup remain required. Four-DIMM WG8 host AXI integration 45914912733 remains in progress. No PPA rerun or spend; manufacturer handoff remains NOT READY.

## 24. ASIC integration and focused regression terminal update

ASIC/target configuration run 45914912733 completed SUCCESS. Chip, memory and WG8 DDR4 lint stages passed; the four-DIMM hmux contention simulation passed simultaneous host/accelerator AW/AR contention, alternating grants, ordered two-beat W bursts, B/R ID routing and independent backpressure (320 ns). The run still emitted 99 WIDTH warning occurrences and 3 UNOPTFLAT occurrences across ASIC top elaborations. The 33-bit `otpu_mig_pair` AW/AR outputs feeding 34-bit `p_awaddr/p_araddr` should be connected to 33-bit intermediate nets and explicitly zero-extended; this remains open.

Focused runs completed:
- FSUM guard: 11 passed, 219 deselected (45915615614).
- 128K one-copy TMEM: 2 passed, 228 deselected (45915615624).
- Loop-stack boundary: 2 passed, 228 deselected (45915615653).

The clean broad RTL-tail run 45915615625 and Qwen/board/subsystem/software runs remain nonterminal. Structural/reset audit 45914912691 passed 4/4 reset tests and 3/3 structural tops with zero SCCs and zero latch cells. Manufacturer handoff remains NOT READY; PPA remains blocked by the previously diagnosed memory limit and no retry is authorised.

## 25. Power-up validation qualification — 2026-11-27

The trace-enabled seed-3 pass 45915433368 is supplementary only because it changes Verilator instrumentation and potentially the `--x-initial unique` pattern. No-trace A/B run 45914084753 failed with the FSUM-guard source and passed with the pre-FSUM source. The stream-tail init-flush correction remains provisional until clean no-trace RTL-tail run 45915615625 and stream RTL/ISA regressions complete. Structural/reset audit 45914912691 and ASIC integration 45914912733 are terminal PASS; other run statuses are in the current checkpoint.


## Explicit 34-bit DIMM host-mux address extension

Commit 600f3aa4822e18f03ba80d06ab86fd447189c126 makes the 33-bit otpu_mig_pair AW/AR outputs explicit through PAIR_AW-width intermediate nets and zero-extends them into the 34-bit host-mux address inputs. This preserves unsigned semantics and the existing address checks. ASIC config run 45916680920 is validating the change; its integrated control/compute, native-memory and four-DIMM AXI lint stages passed, with host AXI simulation still running. Inspect the terminal warning count before closing the width issue.

No-trace seed-3 A/B still showed pre-FSUM pass / post-FSUM fail. The trace-enabled pass is not sufficient because trace instrumentation may change the unique-random initialisation pattern. Candidate tail-init flush remains provisional pending clean no-trace RTL-tail run 45916680719 and stream RTL/ISA regressions. Reset/structural audit 45914912691 and ASIC integration 45914912733 are terminal pass; new reset audit 45916680730 is in progress.


## 20. Latest live verification reconciliation — 2026-11-27

The latest polled source snapshot is `600f3aa4822e18f03ba80d06ab86fd447189c126`. ASIC config 45916680920, reset audit 45916680730, RTL-tail 45916680719 (33 passed, 1 skipped), Qwen real-checkpoint RTL (6 passed) and tiny board-model Qwen (8 passed), board-functional (198 passed, 8 skipped, 1 deselected), and full-chip lint 45916680866 (0 errors) are terminal SUCCESS for their scoped jobs. The ASIC log's `%Fatal` messages are intentional negative tests for out-of-aperture AW/AR addresses; the testbench explicitly reports both as correctly rejected. The explicit MIG pair AW/AR zero-extension has therefore passed its targeted ASIC integration workflow for the tested configuration. Width warnings remain open.

Important new blocker: subsystem/memory workflow 45916680829 has 13/14 jobs SUCCESS, but its QHL job failed 1 of 7 tests: `test_qhl_power_up_rtl[1-False]` (6 passed, 1 failed). The failure is the simulation-only stream-tail overlap assertion at `rtl/vpu/otpu_se_tail.sv:281`, with `kv_v=0,e2=1,e3=1` and `init=0`. The separate RTL-tail selection 45916680719 passed 33/33 selected tests (one skip), but does not cover away this QHL-specific failure. The stream-init flush fix is not sufficient evidence for this case because the failing cycle has init low. Investigate VPU root/root_v timing, tail e2/e3 delay schedule, and QHL's exact instruction/reset schedule before changing RTL or assertion semantics.

Software core workflow 45916680756 has one cancelled waits job; do not count it as complete. Board-functional's eight skips are PyTorch-dependent. Qwen's 6 real-checkpoint RTL and 8 tiny board-model cases passed in their separate job. No successful workflow should be rerun just to reconfirm. Preserve zero spend, no-main, cancelled-run and prior group 3.1/3.2/4 exclusions. PPA remains unauthorised after the confirmed 16-GB OOM. Manufacturer handoff remains NOT READY.


## 26. PPA artifact diagnosis and correction of the ORFS_CPUS action — 2026-11-27

PPA run 45877786710 (job 140109157212, source 28c36c52204fe2ec2ed36413b02eb6043506ccc4) failed in `2_4_floorplan_pdn` with ORFS exit 247. Artifact 15152974135 was downloaded and inspected. It records a cgroup `memory.peak` of 16,155,115,520 bytes, final `memory.events oom_kill 1`, and host MemTotal 16,366,484 kB. `memory.max=max`; therefore this is a host OOM-killer event, not a cgroup hard memory.max limit. OpenROAD's stage log reports peak memory 15,713,660 KB. Synthesis and floorplan progressed, but no completed PPA report exists; do not claim PPA metrics.

The old proposed ORFS_CPUS fix is withdrawn: the run's exact `tools/asic/flow.py` already reads the exported `ORFS_CPUS=2`, passes it to `run()`, sets `NUM_CORES=2`, and applies Docker `--cpus=2`. This was confirmed by inspecting the source snapshot and job log. Do not alter this code absent new evidence. Lower CPU count does not prevent the demonstrated memory peak. No retry is authorised; a materially different resource strategy would need separate design and approval.

The FSUM hardware ingress guard remains a candidate only, not implemented: feature-capability parameter and exact effective enable wiring must be confirmed in the actual `rtl/seq/otpu_seq.sv` / slice path before coding. Then add focused tests for enabled legal 256-row/64-column/non-scalar case and disabled feature, rows 0/257, cols 63, scalar B, verifying invalid VOP is rejected before VPU dispatch or FSUM buffer mutation. Keep existing compiler/simulator validation but do not treat it as hardware ingress protection. QHL random-power-up failure remains open separately. Manufacturer handoff NOT READY.


## 27. FSUM raw-program hardware guard status correction — 2026-11-27

The FSUM ingress guard is not merely a candidate: current `rtl/seq/otpu_seq.sv` has parameter `FSUM`, a synthesizable `fsum_bad` decode predicate, and a dispatch-time rejection before VPU issue. It checks effective capability, function (EXP2SUB producer or RSUM take), EXP2SUB row range 1..256, minimum 64 columns, non-scalar B mode, and pending producer existence for RSUM. The invalid path sets `error` and `halted`; the dispatch pipeline is not loaded. HALT with unconsumed producers reports error.

Tests in `tests/test_rtl.py` cover four invalid shape cases, disabled producer and take capability, take without pending producer, HAS_SS/effective capability gating, pending producer at HALT, invalid unrelated function, and inclusive legal 256x64 producer+take. Workflow 45915615614 job 140233980040 is terminal SUCCESS: 11 passed, 219 deselected, 153.05s. This closes the focused FSUM-ingress-guard task. Do not add duplicate implementation or rerun these tests without a relevant source change. It does not close general VPU/stream/QHL regression, formal, CDC/RDC, DFT, SRAM mapping or physical signoff.


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


## 21. QHL random-power-up diagnostic update — 2026-11-27

Latest temporary-branch diagnostic run 45967861319 (job 140400790723) is terminal FAILURE. The no-trace QHL seed-1 case reproduces the existing tail assertion with kv_v=0, e2=1, e3=1. Failure-time upstream snapshot: root_v=0, vt_q=0, cap=1, a_cap=1, q_cap=0, vt_rl=1, vt_sub=122, kq=0x66, kh=0, kt=6, sen=1, s_init=0. Artifact 15183802907; ZIP SHA-256 f0e88620f845e311a7996b1b54cf2023b73edeb2b73026ab8c7703e2c5a48926.

The snapshot does not contain the preceding valid-pulse history and therefore does not identify whether the seven-PE-cycle spacing originates in the tree, kind FIFO, or stream/grant timing. QHL remains an open functional issue. Do not weaken the assertion, mask the event, or change pipeline depth.

Next diagnostic is confined to the temporary branch: add a plusarg-gated passive per-PE-cycle text trace of existing root_v/kv_v, cap/a_cap/q_cap, vt_rl/vt_sub, kq/kh/kt, sen/s_init and e2/e3. Do not add sequential monitor state or counters, because the test uses unique-X random initialisation. Correlate each kind FIFO enqueue with each root dequeue and inspect occupancy/order around reset/init. Only a proven cause may justify a minimal RTL fix and deterministic regression.

Active engineering branch source is unchanged by this diagnostic. No new CI was launched in this continuation. PPA remains failed due confirmed host OOM and is not authorised for retry; all no-spend, no-main-write and no-duplicate-regression constraints remain. Manufacturer handoff remains NOT READY.

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
This update adds the QHL reset-qualification disposition and reconciles the automatic downstream workflows. It does not change the product architecture baseline, zero-spend policy, or manufacturer gate definitions.


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
This update adds board-functional historical evidence, real Qwen checkpoint RTL/model results, full-chip lint warning disposition, and the isolated software-stream recovery workflow.
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


## 21. 2026-11-28 continuation reconciliation and execution order

The live state and complete evidence ledger are recorded in `CONTINUATION_ADDENDUM_2026-11-28_0050.md`. This section supersedes pending snapshots in prior sections where later terminal run evidence exists.

1. Preserve latest software result: isolated STREAM regression `46037445046` passed 46 tests on its recorded source SHA. Do not rerun the other 14 software-core modules.
2. Preserve QHL results: exact seed-1 reset-qualified selection passed 1 test and the subsystem QHL job passed 7 tests. This is not exhaustive all-seed or all-configuration verification.
3. FSUM guard is already implemented and independently tested (11 passed, 219 deselected); no implementation action remains absent a new defect.
4. Preserve board evidence (198 passed, 8 skipped, 1 deselected) at its exact older SHA and Qwen real-checkpoint simulation evidence. Do not represent either as physical silicon/FPGA performance.
5. WG8 PPA run `45877786710` is terminal FAILURE with no routed report; resource diagnosis records host-memory exhaustion. PPA retry remains unauthorised.
6. First active engineering task is exact semantic lint warning triage and elaborated combinational dependency/SCC evidence, prioritising `gnt`; then resolve or prove `sc_gl`, `pq` and ASIC `aok`. Do not suppress warnings or alter arbitration without proof and focused regressions.
7. Continue formal/SVA, CDC/RDC, SRAM/DDR technology mapping, production host/DMA interfaces, DFT and routed physical/power/thermal signoff.
8. Maintain separate Track A full product and Track B demonstrator. No sponsor or no-cost sample/fabrication/testing path is confirmed.

Zero-spend, no-main-write, no-duplicate-test and evidence-qualified-claim constraints remain mandatory. Manufacturer handoff remains **NOT READY**.



## 22. 2026-11-28 — structural lint closure and VPU index-width remediation

The structural audit `45914912691` reports zero SCCs and zero inferred latch cells in the one-copy slice, two-slice top and actual ASIC card top. Treat `gnt`, `pq`, `sc_gl` and `aok` as no confirmed combinational SCC in those configurations; retain Verilator warnings as tool diagnostics and do not generalise beyond the audited elaborations.

VPU source commit `05879ea34eafc2559c54722c6c940b2acb9ac3ee` explicitly sizes the 24 function-mask indices and exact row-buffer index slices. Full-chip lint run `46053311384` passes with 59 width warnings (52 expand, 7 trunc), 17 fewer than the 76-warning baseline. The remaining five MXU index truncations and two behavioral DRAM `exists()` warnings require separate treatment; 52 expansions remain open.

The VPU-focused workflow first failed at build under Verilator 5.020 before simulation; it now pins 5.044 and run `46053471843` is the required regression gate. Do not claim functional closure until that run passes. Broad `rtl/**` workflow filters caused unintended additional suites; no further broad runs are authorised. Zero-spend and no-main-write constraints remain. Manufacturer handoff NOT READY.


## Governing AI-X profitability objective — 2026-11-28

The new governing product objective and architecture decision framework is documented in `docs/sunnyone/SUNNYONE_AI-X_PROFITABILITY_NORTH_STAR_2026-11-28.md` (creation commit `40b6f8078d2d7a424a255f1d7db716cab373b657`). It is aligned with, and does not replace, the integrated engineering/sponsored-silicon plan.

The product objective is commercially profitable, quality-qualified LLM inference: maximise useful tokens/s, tokens/J and useful tokens per total cost; minimise energy/token, idle power, heat, manufacturing/operating cost, latency tails, failure/downtime and maintenance complexity. No unmeasured throughput, power, thermal, yield, area or cost claims.

Architecture direction: unified TPU/MXU matrix engine; LPU-like scheduling/KV/context/data-movement role initially implemented in existing software/runtime; NPU/VPU vector datapath; shared, measured memory/interconnect; programmable runtime/compiler/ISA; evidence-based power/thermal control. Quantum-inspired classical methods remain optional research, not physical quantum hardware. No dedicated LPU silicon without a measured net benefit. Track A full product remains distinct from Track B demonstrator. One-slice ASIC top, Versal feasibility lead, 128 GB ECC DDR4 hypothesis, 256 GB stretch-only and retired 30 W hard ceiling remain as qualified in the governing plan.

Decision rule: add hardware only when a source-backed bottleneck and reproducible baseline demonstrate a net benefit after throughput, latency, energy, cost, area, heat, yield, reliability, software and verification trade-offs. Optimise existing resources first.
