# SUNNYONE AI-X V1 — Manufacturer Handoff Readiness Checklist

**Purpose:** define the evidence and engineering package required before SUNNYONE AI-X V1 is sent to a chip-design house, foundry-facing ASIC integrator, FPGA/board design house, or custom-board manufacturer.

**Current status:** engineering preparation in progress. This is a manufacturer-feasibility and gap-control document, not a declaration of tapeout readiness, production readiness, or successful hardware validation.

**Source repository:** `shamiursunny/openTPU`  
**Active engineering branch:** `sunnyone/commercial-profitability-architecture-2026-11-23`  
**Logical architecture candidate:** `docs/sunnyone/SUNNYONE_AI-X_V1_FINAL_LOGICAL_DESIGN_CANDIDATE_A1.12.11.16.54.md`

## 1. What we are asking the manufacturer to do

The intended end product is a custom AI inference accelerator ASIC and a compatible custom board. The current engineering work is to complete and verify the reusable digital RTL, its logical interfaces, constraints, behavioural models, simulation tests, and documentation as far as can be done without a selected foundry process, qualified hard IP, or physical hardware.

The manufacturer/integrator must first perform a feasibility and design-rule review. They must not assume that the current RTL repository already contains a complete PCIe endpoint, DDR4 controller/PHY, package, board, or production-ready physical implementation.

The manufacturer should return:
- recommended and supported process/foundry options;
- a written RTL/IP/PDK compatibility assessment;
- required licensed or proprietary IP and its cost/licensing conditions;
- SRAM compiler/macro options matching the memory inventory and port semantics;
- DDR controller/PHY and PCIe endpoint/PHY options;
- package, IO, power-delivery, thermal and board constraints;
- required RTL changes and additional verification;
- physical-design, DFT, signoff and silicon-validation scope;
- itemised non-recurring engineering, masks, IP, package, board, test and production costs;
- realistic schedule, technical risks, yield assumptions and minimum order quantities.

No purchase, licence, fabrication, or paid engineering activity is authorised by this document.

## 2. Current logical design boundary

The selected V1 candidate is a single WG8 compute slice with eight native memory channels paired into four 512-bit DIMM/controller ports. The logical external-memory capacity is 32 GiB.

Implemented RTL integration boundary:
- `rtl/asic/otpu_asic_wg8_ddr4_top.sv`
- four host AXI4 master interfaces, each 512-bit data and DIMM-local address;
- four per-DIMM host/accelerator arbitration blocks;
- four two-channel pairing blocks;
- eight native-channel-to-AXI bridges;
- AXI4-Lite control interface, 12-bit address and 32-bit data;
- core clock and memory-interface clock inputs with reset synchronisation logic.

The four host AXI interfaces at this boundary are already DIMM-local. A future PCIe/DMA subsystem must translate card-global addresses into the correct DIMM-local addresses and channel permutation.

## 3. Current logical parameters — candidate, not physical signoff

| Parameter | Candidate |
|---|---:|
| Slices | 1 |
| D / MCOLS / WG | 128 / 8 / 8 |
| Native channels | 8 |
| Native channel beat | 128 bytes |
| Byte address width | 35 bits |
| Native channel beat address width | 25 bits |
| Logical DRAM map | 32 GiB |
| DIMM/controller ports | 4 × 8 GiB |
| AXI DIMM data width | 512 bits |
| AXI DIMM address width | 34 bits; bit 33 guarded/unused |
| TMEM / IMEM | 128K / 32K words |
| TMEM implementation | one-copy 1RW1R macro candidate |
| FIFO depth / WIN | 2,048 / 32 |
| LANES / ULANES | 8 / 8 |
| MXU parameters | implementation 2; CL 16; E 8; QD 4 |
| VPU parameters | CL 2; CNS 3 |
| Sequencer / DMA | SE_R 2; DMA_DEPTH 512 |
| Core clock | 400 MHz SDC candidate only; not achieved or measured |

These values must be reconciled with the selected process, SRAM compiler, controller IP, package, board topology and actual timing/power analysis before they become implementation constraints.

## 4. Major subsystems not yet implemented or qualified

The following are open integration requirements, not completed design features:

1. **PCIe endpoint and PHY:** endpoint/TLP handling, link training, PIPE/PCS/SerDes, target link width/speed, configuration space, BAR mapping, reset/FLR and error handling.
2. **Host DMA engine:** descriptor fetch and validation, host-memory read/write, completion tracking, bounds checks, address translation, interrupt/MSI-X and Linux driver.
3. **Global memory address translation:** card-global to DIMM-local mapping, channel permutation, aperture checks, alignment and boundary handling.
4. **DDR controller and PHY:** DDR4 initialisation/training, refresh, scheduling, timing, ECC datapath, byte-write semantics, calibration and electrical IO.
5. **SRAM macros:** foundry/compiler-generated macros matching each required depth, width, port count, read/write semantics, mask granularity, latency and test requirements. Current generic/fake RAM models are not production macros.
6. **Clock/reset/CDC/RDC:** clock generation/distribution, clock-domain crossing, reset-domain crossing, synchroniser review, recovery/removal and asynchronous error handling.
7. **DFT:** scan architecture, memory BIST/repair, boundary scan, test access, ATPG coverage and production test strategy.
8. **Physical implementation:** foundry PDK mapping, synthesis, floorplan, macro placement, CTS, routing, extraction, multi-corner STA, DRC, LVS, antenna, IR drop, EM, SI/PI and formal equivalence.
9. **Package and board:** package pinout/ball map, power rails, decoupling, reference clocks, PCIe routing, DDR routing/topology, thermal solution, connectors, board stack-up and SI/PI.
10. **Silicon and board qualification:** bring-up, memory training, PCIe compliance, power/thermal measurement, reliability, workload performance and production test.

## 5. Simulation and verification evidence required before handoff

All results must identify the exact source commit SHA, tool versions, command, test selection, pass/fail/skip counts, logs and known limitations.

### Digital verification gates

- [ ] Four-DIMM host AXI simulation passes, including reset release and independent backpressure.
- [ ] Multi-beat write and read bursts across all four DIMM ports.
- [ ] AW/W channel ordering permutations, including W-before-AW where protocol permits.
- [ ] Multiple outstanding transactions and response-ID routing.
- [ ] Host and accelerator-pair simultaneous contention on every DIMM.
- [ ] Bounded fairness/starvation checks under sustained contention.
- [ ] Read-return ordering and interleaving behaviour.
- [ ] Byte strobes, partial writes and ECC interaction contract.
- [ ] Burst alignment, 4-KiB boundary, address-window and illegal-address tests.
- [ ] Reserved host-ID collision/alias and malformed response tests.
- [ ] Backpressure on every address, data and response channel.
- [ ] Reset with outstanding reads/writes and recovery behaviour.
- [ ] Error propagation, timeout, calibration loss and ECC status tests.
- [ ] Full selected RTL/subsystem/software regression on the final immutable handoff SHA.
- [ ] Lint warnings triaged; no blanket warning suppression used to disguise unresolved defects.
- [ ] Assertions/formal checks for critical AXI, address, reset and arbitration properties.
- [ ] CDC/RDC analysis with identified clocks, synchronisers and waivers.
- [ ] Reproducible synthesis/elaboration and macro-inventory evidence.

### Current known simulation evidence and blockers

- A selected RTL-tail run on SHA `8df2190f2ae5c69e2c64e6b3bd1dc4cfae7a857a` reported 33 passed, 1 documented geometry skip, 183 deselected. It is not the full regression.
- A selected isolated one-copy 128K TMEM run on the same SHA reported 2 passed, 215 deselected. It is not full memory signoff.
- Selected subsystem runs on the same SHA reported MX multiply/replay 17 passed, quantizer modes 15 passed, quantizer corner/tie-rounding 8 passed, and stream RTL 14 passed. Other matrix jobs were incomplete at the recorded checkpoint.
- Four-DIMM diagnostic Run 45425750505 (job 138557141766, SHA b41669fe1d67a3f7dcb84d86a960cdb4b9167ad8) compiled after target/config and lint, then timed out. Its diagnostic vector showed all four host WVALID bits stuck high, all WREADY low, no AWVALID at the host or controller boundary, and no recorded AW acceptance. Source review identified that the bench launches traffic before per-DIMM reset synchroniser release and uses a READY loop that can treat X as completion. The bench was corrected to wait for each DIMM's reset release and require READY === 1; exact-SHA rerun 45428347822 is queued on SHA ec0fe8329df06e5204a1c082df133b62b434846b. Root-cause fix is plausible and evidence-led, but A01 remains open until the rerun passes.
- PPA Run 45426849673 (job 138561067049, SHA 21e1d56c5c6bcafc8d45a49f5aa8920516bad068) failed before ORFS because the workflow wrote a literal backslash-n into the saved Docker image ID; Docker returned "invalid reference format". No synthesis or PPA stage ran. Workflow correction commit e212fe714eac17e339a2cc9090bee293a8ba6c09 now writes a real newline; verification run 45428370570 is queued. The earlier 288-macro inventory was from a different, pre-correction run and is not a result of this failed attempt.
- The Nangate45 flow is a research proxy only. It is not a production foundry process or evidence of manufacturable PPA.

## 6. Manufacturer deliverables expected after feasibility review

The manufacturer/integrator should produce and return:
- approved top-level architecture and subsystem partition;
- signed-off interface/control/address maps;
- selected PDK, process corner set, IO library and SRAM compiler documentation;
- licensed-IP list, versions, permitted use, costs and support status;
- synthesizable RTL and technology-specific wrappers;
- macro LEF/Liberty/Verilog models and memory test/repair strategy;
- complete timing constraints and clock/reset architecture;
- DFT architecture and coverage targets;
- floorplan, placement, CTS, route and extracted physical database;
- STA, power, IR/EM, SI/PI, DRC/LVS, antenna and equivalence reports;
- package pinout/ball map, substrate and thermal analysis;
- board schematics, PCB layout, stack-up and SI/PI reports;
- manufacturing test plan, bring-up procedure and measured silicon/board results.

The deliverables and acceptance criteria must be agreed in writing before paid work begins.

## 7. Release discipline

- The manufacturer handoff must use one immutable Git commit SHA and a source archive with checksums. Do not hand over a moving branch as the release baseline.
- Include RTL, generated configuration, constraints, testbenches, scripts, documentation, licences/notices and exact regression logs.
- Exclude secrets, personal tokens, private keys and unrelated user data.
- Keep generated fake SRAM models clearly labelled as simulation/research artifacts; never present them as foundry macros.
- Keep all failing tests visible. Do not delete, skip or weaken tests merely to obtain a green status.
- Do not label the design “tapeout-ready”, “production-ready” or “fully validated” until the appropriate manufacturer and silicon gates have actually passed.
- Preserve the current zero-spend rule unless the user explicitly approves a cost.

## 8. Release decision

**Current decision: NOT READY for fabrication or a final production-board build.**

**Permitted next step:** once the digital simulation and documentation gates are closed, send the immutable source package to qualified ASIC design houses for a paid/unpaid feasibility review, clearly identifying all open hard-IP and physical-design requirements. A board manufacturer can review the eventual board requirements, but cannot replace ASIC RTL integration, foundry implementation, or chip qualification.

The immediate engineering priority remains: diagnose and pass the four-DIMM integration simulation, complete the remaining regressions, obtain reproducible synthesis/physical-proxy evidence, and build the full manufacturer package without concealing any open dependency.


## 0. Fresh-session resume guide

**Start every new ChatGPT continuation by reading** [SUNNYONE_AI-X_PROJECT_RESUME.md](SUNNYONE_AI-X_PROJECT_RESUME.md). It contains the repository/branch recovery procedure, workflow and handoff boundaries, current A01/A04 blockers, exact CI runs, task order and three-document update protocol. Then read this master register and the chronological [PROJECT_TRACKER.md](PROJECT_TRACKER.md).

The project is governed by three maintained documents:
1. `SUNNYONE_AI-X_PROJECT_RESUME.md` — quick-start context recovery and continuation workflow.
2. `SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md` — authoritative task register, acceptance criteria and manufacturer handoff boundary.
3. `PROJECT_TRACKER.md` — dated chronological evidence and decisions.

After each meaningful project task, update all three in the same work session, then re-fetch and verify all three on the feature branch. Never assume a prior-session SHA or CI status remains current.

## 9. Master task register — single source of truth (updated 2026-11-24)

**Control rule:** This section is the authoritative live task register for simulation readiness and manufacturer handoff. The separate project tracker remains the chronological engineering log. Every future engineering task must be recorded here before work begins and updated here after work, with exact commit SHA and test-run evidence. A task is not complete merely because a workflow was created or code was committed.

**Status definitions**
- **DONE — evidence verified:** implementation/documentation exists and the stated evidence was inspected.
- **PARTIAL — limited evidence:** some scoped tests or artefacts passed, but acceptance criteria remain open.
- **IN PROGRESS:** work has started; no completion claim.
- **BLOCKED — external dependency:** cannot be completed under current repository-only/zero-spend conditions.
- **NOT STARTED:** no implementation or qualifying evidence recorded.
- **FAILED — action required:** a test or flow failed and needs diagnosis; never silently convert it to skipped/pass.

### 9.1 Completed or evidenced

| ID | Task | Status | Evidence / limitation |
|---|---|---|---|
| M01 | Establish V1 logical architecture candidate | DONE — candidate baseline | Architecture candidate A1.12.11.16.54 exists. Parameters remain logical candidates, not physical signoff. |
| M02 | Establish ASIC WG8 RTL top-level integration boundary | PARTIAL | RTL top integrates four host DIMM ports, four muxes, four channel-pair blocks and eight channel bridges. PCIe/DMA/DDR PHY are absent. |
| M03 | Target/configuration parameter regression | DONE — scoped | Run 45414724190: 66 passed in target/config stage, SHA 20a07a7ec9ef4f986e3e7d3159b2027993f9d674. Not the final release SHA. |
| M04 | Reset audit with Yosys+Slang installed | DONE — scoped | Run 45382805606: 377 passed, 1 intentional 64-GiB skip; four reset-audit tests executed and passed. Not full-chip formal/CDC signoff. |
| M05 | RTL-tail selected regression | DONE — scoped | Run 45417561286, SHA 8df2190f2ae5c69e2c64e6b3bd1dc4cfae7a857a: 33 passed, 1 documented geometry skip, 183 deselected. |
| M06 | Selected MX multiply/replay tests | DONE — scoped | Run 45417561535: 17 passed, SHA 8df2190f2ae5c69e2c64e6b3bd1dc4cfae7a857a. |
| M07 | Selected quantizer mode tests | DONE — scoped | Same matrix run: 15 passed. |
| M08 | Selected quantizer corner/tie-rounding tests | DONE — scoped | Same matrix run: 8 passed. |
| M09 | Selected stream RTL tests | DONE — scoped | Same matrix run: 14 passed. |
| M10 | Isolated one-copy 128K TMEM test | DONE — scoped | Run 45417561463: 2 passed, 215 deselected. Not complete memory subsystem signoff. |
| M11 | One-DIMM host/accelerator mux bench | PARTIAL | Prior run 45324154486 passed concurrent pair/host AW-W-B and AR-R routing for 2 writes/2 reads in 18 cycles; earlier warnings and later cleanup require current-SHA rerun. |
| M12 | Manufacturer handoff requirements document | DONE — document | This file defines boundaries, gaps, verification gates, manufacturer return deliverables and release discipline. |
| M13 | PPA log/report evidence collection and research-flow corrections | PARTIAL — workflow and mapping fixes committed | Workflow now pins the Docker image and captures full ORFS logs/artifacts. Run 45428370570 reached Yosys synthesis but failed on three 64 x 672 asynchronous-read result-FIFO memories (43,008 bits each) exceeding the 16,384-bit flip-flop threshold. Flow commit 0b67e65deb7fcc457b10bb825304db752689b3e7 raises the research mapping threshold to 65,536 bits so these remain flip-flops; README commit c09447bafa3460d4acc74b35c4f7e6bdf40b9857 documents the high-area proxy limitation. No PPA result yet. |
| M14 | Project tracker chronology | DONE — maintained | docs/sunnyone/PROJECT_TRACKER.md; latest tracker update commit a8e91b44dd148d77f1f5ffc56d930fefc9e4dd3b. Resume guide: docs/sunnyone/SUNNYONE_AI-X_PROJECT_RESUME.md. |

### 9.2 Failed or incomplete — active priorities

| ID | Task | Status | Required closure evidence |
|---|---|---|---|
| A01 | Four-DIMM host-path simulation | DONE — scoped single-beat integration | Diagnostic Run 45425750505 exposed traffic starting before per-DIMM reset synchroniser release. Testbench-only correction commit ec0fe8329df06e5204a1c082df133b62b434846b waits for each reset synchroniser and requires READY === 1. Exact-SHA Run 45428347822 / job 138566432055 passed: all four independent WG8 DIMM ports routed host AW/W/B and AR/R with independent backpressure; Verilator finished at 210 ns. This does not cover multi-beat protocol cases or host/accelerator contention (A02/A03). Lint warnings remain under A11. |
| A02 | Complete four-DIMM AXI protocol coverage | IN PROGRESS — multi-beat, response-code and negative-aperture tests committed; exact-SHA CI queued | Testbench commits 76f3a5ecffdef73db2eb298bf775552c5f801c12 and 141dd7857cdd76d405698e1d3dc3a61a8cdb64e0 cover 1/2/4/8-beat host read/write bursts, W-before-AW, full/partial/zero WSTRB, legal 4-KiB-boundary-aligned bursts, AWLEN/ARLEN and WLAST/RLAST/data. Commit 4a2dd86b6b7f61b96d8cb0f2e5d5e573c85349e9 adds all four BRESP/RRESP encodings and expected-fatal host AW/AR tests for address bit 33. Workflow commit 66c676cf515e2063c6f322cd1912c94f07ec085c runs the normal bench and verifies both expected fatal messages. Latest consolidated ASIC/config Run 45455874266 is queued on exact SHA d3a75f...; it includes the A02 negative cases, A03 HMUX_FORMAL contention bench and H06 address-map simulation. No pass yet. Outstanding ID ordering, reset-in-flight and further negative protocol cases remain. |
| A03 | Four-DIMM host/accelerator contention | IN PROGRESS — dedicated hmux bench and assertions committed; latest exact-SHA CI queued | New sim/verilator/tb_asic_wg8_hmux_contention.sv (commit 62c319e5eed8f902e10ceb01c7c84b2eaad9d564) instantiates four production otpu_mig_hmux blocks (IDW=4, AW=34, HB=2), drives simultaneous host/pair AW and AR, checks H/P/H/P grant alternation over two transactions per source, ordered two-beat W bursts, BID/RID routing and independent backpressure. Workflow step added in e0fa44d99a4ba598881f6960a2196f6752550fea. HMUX_FORMAL assertions are in commit fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc and compiled with -DHMUX_FORMAL/--assert. Latest consolidated ASIC/config Run 45455874266 on SHA d3a75f... is queued and includes this bench; no pass until logs are inspected. |
| A04 | PPA research flow diagnosis | IN PROGRESS — synthesis blocker diagnosed; corrected-flow attempts queued/running | Run 45428370570 / job 138566505337 on SHA e212fe714eac17e339a2cc9090bee293a8ba6c09 reached Yosys and failed because three 64 x 672 asynchronous-read result-FIFO memories (43,008 bits each) exceeded SYNTH_MEMORY_MAX_BITS=16384. otpu_ram_1r1w_ra is asynchronous-read/write-first, so synchronous fakeram45 substitution changes semantics. Flow commit 0b67e65deb7fcc457b10bb825304db752689b3e7 raises the FF mapping threshold to 65,536 bits; README commit c09447bafa3460d4acc74b35c4f7e6bdf40b9857 documents the high-area proxy limitation. Corrected-flow Run 45452183549 remains IN_PROGRESS on SHA 0b67e65...; latest code PPA Run 45454389335 is QUEUED on SHA fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc. No PPA metrics yet. |
| A05 | Reproducible research synthesis/area/timing | IN PROGRESS | Corrected-flow Run 45452183549 remains active on SHA 0b67e65...; latest-code Run 45454389335 is queued on SHA fc3bdcc... after the TMEM and mux assertion work. Verify Yosys synthesis completes, collect exact container/tool versions, synthesis statistics, placement/CTS/route reports and timing. Nangate45 is proxy only; no power/area/timing claim until measured reports exist. |
| A06 | Remaining subsystem/memory matrix | PARTIAL — latest rerun will expose skip reasons | Run 45428347703 on SHA ec0fe832... had 14 successful jobs, 374 passed, 1 skipped, 0 failed; skip reason was absent from its captured summary. Workflow change adds pytest -rs in commit ec151e9180c902c2157d84fb626121a4b81c8c1e; latest matrix Run 45454026458 is queued on that SHA so the skip reason is captured. |
| A07 | Software-core/ISA/compiler/kernel regression | IN PROGRESS | Earlier rerun job 138652190796 on SHA ec0fe832... remains in progress. Latest code Run 45453893300 / job 138658009331 is queued on SHA 487fe6b93a83e4b86e5565b80de9b7f33c407436; use the latest exact-SHA result for closure. |
| A08 | Board-functional regression | IN PROGRESS | Earlier rerun job 138652132132 on SHA ec0fe832... remains in progress. Latest code Run 45453893567 / job 138658011213 is queued on SHA 487fe6b93a83e4b86e5565b80de9b7f33c407436; use the latest exact-SHA result for closure. |
| A09 | Uncovered RTL regression | IN PROGRESS — latest run queued | Earlier job 138652135885 on SHA ec0fe832... was cancelled. Latest code Run 45453893567 / job 138658011921 is queued on SHA 487fe6b93a83e4b86e5565b80de9b7f33c407436. |
| A10 | Final complete regression on immutable release SHA | NOT STARTED | One frozen SHA must pass all required test groups; all exceptions, skips and limitations documented. |
| A11 | Lint warning closure | IN PROGRESS — structural loop and duplicate-source cleanup committed; latest lint queued | A01 artifact showed MODDUP for otpu_native_dram.sv due duplicate source inclusion, addressed by Path.resolve/dict de-dup in ASIC workflow commit 4e26612323f1067acdf360ec6a556a339bab89cd. UNOPTFLAT cones were traced: rpl_frz/rpl_hold and cgl_m/gnt_m shared always_comb processes; these were split in rtl/top/otpu_slice.sv commit 71496cc3d237458ff83806293d73a43de7307922. The pq warning came from guest alias pq[p]=pq[SH_HOST] through one packed array; an explicit pq_host vector now replaces that aggregate self-alias in rtl/mem/otpu_tmem.sv commit 487fe6b93a83e4b86e5565b80de9b7f33c407436. Workflow commits ec151e9180c902c2157d84fb626121a4b81c8c1e, 1103498f9d1222ee897a510dfcf912a59fe39301 and 86bc7b57202bf4d91ea9ed7f8657db0bebb2b413 add pytest skip-reason reporting and expose width/unused warnings rather than suppress them. Full-chip lint Run 45454389561 is queued on SHA fc3bdcc...; ASIC/config Run 45454398831 is queued on SHA bce7d3... . Do not claim the loop/MODDUP warnings are closed until exact logs verify. Width warnings across VPU/quantizer/MXU/DMA/sequence/native-DRAM remain for semantic triage. |
| A12 | Assertions/formal protocol properties | PARTIAL — HMUX SVA added; formal proof still open | HMUX_FORMAL properties in rtl/boards/bcu1525/otpu_mig_hmux.sv (commit fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc) check AW/W/AR payload stability under controller backpressure, B/R response stability, host/pair ready mutual exclusion, no W ready without a queued AW, and BID/RID routing. The A03 contention bench compiles with -DHMUX_FORMAL and Verilator --assert; latest ASIC/config Run 45454747313 on exact SHA 66c676cf515e2063c6f322cd1912c94f07ec085c is queued. This is assertion-enabled simulation, not a formal proof. SymbiYosys harness, assumptions, covers, reset/address/top-level properties and SMT proof results remain open. |

### 9.3 Manufacturer / physical dependencies

| ID | Task | Status | Closure owner / evidence |
|---|---|---|---|
| H01 | Select foundry/process/PDK and process corners | BLOCKED — external | Manufacturer/foundry selection and written PDK access/licensing. |
| H02 | Qualify SRAM compiler macros | BLOCKED — external | Foundry/compiler macros, Liberty/LEF/Verilog, port semantics, timing, test/repair and physical characterization. |
| H03 | DDR controller and PHY | BLOCKED — external | Selected DDR generation/device/topology and licensed/qualified controller + PHY, training and electrical validation. |
| H04 | PCIe endpoint and PHY | BLOCKED — external | Selected PCIe generation/width and qualified endpoint + PCS/SerDes PHY, link and compliance evidence. |
| H05 | Host DMA, descriptors, interrupts and driver | IN PROGRESS — interface requirements documented; RTL/driver not implemented | `docs/sunnyone/SUNNYONE_AI-X_HOST_DMA_AND_GLOBAL_ADDRESS_MAP_SPEC.md` defines required DMA capabilities, descriptor/completion queues, interrupts, reset/error handling, IOMMU/security and manufacturer decisions. PCIe/DMA IP, descriptor ABI, RTL, driver and end-to-end tests remain open; no interface register map or implementation is claimed. |
| H06 | Global address translation / DIMM mapping | IN PROGRESS — standalone decoder/bench committed; formal proof script under correction | Source-derived map is in `docs/sunnyone/SUNNYONE_AI-X_HOST_DMA_AND_GLOBAL_ADDRESS_MAP_SPEC.md`. Decoder `rtl/asic/otpu_asic_global_addr_map.sv` commit `dc34e3a51c27c01af6296015cd206ab8336d6bda`; simulation bench `sim/verilator/tb_asic_global_addr_map.sv` commits `8cca146b25636135caa5a7f5e833745f1231eda3` / `ebfaf87172d8457c8958bc57a519e981e91b99ab`; ASIC/config Run `45455874266` remains queued on SHA `d3a75f...`. Formal harness `formal/otpu_asic_global_addr_map_formal.sv` commit `55ffc66283b7b88c5ea21995cb6c7eff54faa3c4`. First formal Run `45456060346` failed because Yosys emitted `$check` cells. The attempted `chformal -assert` workflow at SHA `9c550d...` was incomplete (it selects assertion types but does not lower the `$check` cells); queued Run `45456545394` is superseded and must not be counted. Corrected workflow commit `0d6128d21c086d52e0c6ca3a10bfe4f2666dcccb` uses `chformal -lower`; formal Run `45457143624` is queued on that exact SHA. No proof or simulation pass is claimed. Decoder is not integrated into DMA/ASIC top; global AXI routing, burst splitting, physical slot mapping and end-to-end verification remain open. |
| H07 | Clock/reset/CDC/RDC signoff | NOT STARTED | Complete clock-domain inventory, CDC/RDC analysis, synchroniser review, waiver rationale and timing constraints. |
| H08 | DFT / scan / MBIST / ATPG | BLOCKED — external | Manufacturer/foundry DFT flow, memory test strategy, scan insertion and coverage reports. |
| H09 | Physical implementation and signoff | BLOCKED — external | Floorplan, CTS, route, extraction, MCMM STA, DRC/LVS, antenna, IR/EM, SI/PI, equivalence and power reports. |
| H10 | Package and custom board design | BLOCKED — external | Package/ball map, IO and power plan, board schematics/layout, stack-up, PCIe/DDR SI/PI and thermal design. |
| H11 | Silicon/board bring-up and qualification | BLOCKED — hardware | Fabricated samples and measured power, clocks, memory training, PCIe, thermals, workload throughput and reliability. |
| H12 | Commercial feasibility and cost model | IN PROGRESS — evidence model defined; numeric model blocked on measured/quoted inputs | Added `docs/sunnyone/SUNNYONE_AI-X_COMMERCIAL_PROFITABILITY_MEASUREMENT_MODEL.md`: useful-throughput/quality gates, full-system TCO, energy and thermal measurements, contribution margin, payback, NPV, power-envelope decision rule and sensitivity analysis. No numeric ROI or power recommendation is made. Manufacturer quotations, physical PPA, board measurements, yield/MOQ, operating costs and demand/pricing evidence remain missing. No spending authorised. |

### 9.4 Release gate — objective acceptance conditions

The source package may be labelled **SIMULATION-READY FOR MANUFACTURER FEASIBILITY REVIEW** only when all applicable A-series tasks are closed or explicitly accepted as manufacturer-owned with written agreement, and the following are true:

1. Four-DIMM testbench passes on the exact frozen release SHA.
2. Expanded AXI, contention, reset, address-boundary and error tests pass.
3. Required subsystem, memory, software, board-model and uncovered RTL regressions have recorded final results.
4. All failures are fixed or transparently documented as accepted limitations; no test was weakened to manufacture a green result.
5. Lint, elaboration, assertions/formal and CDC/RDC results have documented scope and waivers.
6. Research synthesis/PPA logs are reproducible and accurately labelled as proxy results; no unsupported physical claims.
7. RTL, testbenches, scripts, configs, constraints, interface/address maps, tool versions, logs, licences/notices and checksums are packaged against one immutable SHA.
8. Every H-series external dependency is prominently listed in the manufacturer request for feasibility review.

This release gate is **not** a tapeout or production-ready gate. The manufacturer/foundry and silicon gates in H01–H11 remain necessary for fabrication and board qualification.

### 9.5 Continuation protocol — prevent status drift

For every future continuation:
1. Read this master register and the project tracker before changing code.
2. Verify current feature-branch HEAD and main independently.
3. Check existing CI runs before launching duplicate jobs.
4. Select one highest-priority failing/incomplete task; inspect source and logs before edits.
5. Make the smallest evidence-led change. Do not change RTL merely to hide a testbench timeout.
6. Run targeted tests, then relevant regression; record exact SHA, run/job IDs, versions, counts and logs.
7. Update this register and the chronological tracker in the same work session.
8. Re-fetch both updated files and verify the commit. If any status cannot be verified, leave it IN PROGRESS or UNKNOWN rather than marking DONE.
9. Never claim “100% ready”. Report simulation readiness and manufacturer/physical readiness as separate gates.

**Current next action:** inspect latest ASIC/config Run 45454747313 on SHA 66c676... for A02 multi-beat/response/negative-address tests, A03 contention and HMUX_FORMAL assertions. Inspect full-chip lint Run 45454389561 on SHA fc3bdc... for MODDUP/UNOPTFLAT cleanup and exposed width warnings. Inspect subsystem Run 45454026458 on SHA ec151e... for pytest skip reasons. Retrieve corrected-flow PPA Run 45454389335, latest software-core Run 45453893300, board/uncovered Run 45453893567 and RTL-tail Run 45453893412; reconcile older active attempts by exact SHA. A01's scoped single-beat host path is passed; A02/A03 testbenches and A12 assertions are committed but unverified; A04/A05, A06 skip classification, A07–A09, A11/A12 and A10 remain open. Do not advance the release gate until all applicable criteria are evidenced.
