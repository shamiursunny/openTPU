# SUNNYONE AI-X V1 — Manufacturer Handoff Readiness Checklist

**Purpose:** define the evidence and engineering package required before SUNNYONE AI-X V1 is sent to a chip-design house, foundry-facing ASIC integrator, FPGA/board design house, or custom-board manufacturer.

**Last reconciled:** 2026-11-25 (Asia/Dhaka). **Current status:** engineering preparation in progress; historical CI evidence has been audited, but release gates remain open. This is a manufacturer-feasibility and gap-control document, not a declaration of tapeout readiness, production readiness, or successful hardware validation.

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
| A06 | Remaining subsystem/memory matrix | PARTIAL — prior 14-job matrix passed; latest skip-reason rerun queued | Run 45425750683 on SHA b41669fe1d67a3f7dcb84d86a960cdb4b9167ad8 completed all 14 jobs: 377 passed, 1 skipped, 0 failed. The single skip is `tests/test_aw_rtl.py::test_beyond_the_dram_stops_the_board_model`, explicitly skipped at 64 GiB because the whole `2^AW` address space is DRAM; at 32 GiB, a store at bit 35 is beyond the channels and the test checks the expected board-model stop. The same explicit skip condition exists on SHA ec0fe832. Later Run 45428347703 on SHA ec0fe832 had 374 passed, 1 skipped, 0 failed. Workflow commit ec151e9180c902c2157d84fb626121a4b81c8c1e adds pytest `-rs`; latest matrix Run 45454026458 is queued on that SHA to capture the skip reason for the newer run. Do not treat the geometry-specific skip as a failure or suppress it. |
| A07 | Software-core/ISA/compiler/kernel regression | IN PROGRESS — latest code run also in progress | Earlier rerun job 138652190796 on SHA ec0fe832... remains in progress; older run 45425750779 on SHA b41669fe... was cancelled. Latest code Run 45453893300 / job 138658009331 is IN_PROGRESS on SHA 487fe6b93a83e4b86e5565b80de9b7f33c407436; retrieve its final log and counts before closure. |
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
| H06 | Global address translation / DIMM mapping | IN PROGRESS — standalone decoder/bench committed; corrected formal rerun queued | Source-derived map is in `docs/sunnyone/SUNNYONE_AI-X_HOST_DMA_AND_GLOBAL_ADDRESS_MAP_SPEC.md`. Decoder `rtl/asic/otpu_asic_global_addr_map.sv` commit `dc34e3a51c27c01af6296015cd206ab8336d6bda`; simulation bench `sim/verilator/tb_asic_global_addr_map.sv` commits `8cca146b25636135caa5a7f5e833745f1231eda3` / `ebfaf87172d8457c8958bc57a519e981e91b99ab`; ASIC/config Run `45455874266` remains queued on SHA `d3a75f...`. Formal harness `formal/otpu_asic_global_addr_map_formal.sv` commit `55ffc66283b7b88c5ea21995cb6c7eff54faa3c4`. First formal Run `45456060346` failed because Yosys emitted `$check` cells. The attempted `chformal -assert` workflow at SHA `9c550d...` was incomplete (it selects assertion types but does not lower the `$check` cells); Run `45456545394` completed with `ERROR: Mode option is missing` because `chformal -assert` omitted the required mode; it is superseded and must not be counted. Corrected workflow commit `0d6128d21c086d52e0c6ca3a10bfe4f2666dcccb` uses `chformal -lower`; formal Run `45457143624` is queued on that exact SHA. No proof or simulation pass is claimed. Decoder is not integrated into DMA/ASIC top; global AXI routing, burst splitting, physical slot mapping and end-to-end verification remain open. |
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


## 10. Historical CI evidence inventory and current release-gate interpretation (2026-11-25)

The detailed chronological evidence is maintained in [PROJECT_TRACKER.md, section 126](PROJECT_TRACKER.md). The quick-start instructions are in [SUNNYONE_AI-X_PROJECT_RESUME.md](SUNNYONE_AI-X_PROJECT_RESUME.md). The key audited facts for manufacturer review are:

### Verified test evidence

| Verification area | Exact run / SHA | Observed result | What it does not establish |
|---|---|---|---|
| RTL subsystem and WG8 memory matrix | Run [45428347703](https://github.com/shamiursunny/openTPU/actions/runs/45428347703), SHA `ec0fe8329df06e5204a1c082df133b62b434846b` | 14 successful jobs; **377 passed, 1 intentional geometry skip, 0 failed** | Not final-release-SHA regression or full ASIC signoff |
| RTL-tail selected suite | Run [45454717008](https://github.com/shamiursunny/openTPU/actions/runs/45454717008), SHA `4a2dd86b6b7f61b96d8cb0f2e5d5e573c85349e9` | **33 passed, 1 documented skip, 183 deselected** | Selected tail coverage only |
| Isolated 128K one-copy TMEM | Run [45465292891](https://github.com/shamiursunny/openTPU/actions/runs/45465292891), SHA `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f` | **2 passed, 215 deselected** | No foundry SRAM macro, PPA or complete memory-system qualification |
| Reset audit | Run [45455745271](https://github.com/shamiursunny/openTPU/actions/runs/45455745271), SHA `dc34e3a51c27c01af6296015cd206ab8336d6bda` | **4 passed** with Yosys+Slang | Not full CDC/RDC or reset signoff |
| Shared-DIMM HMUX directed simulation | Run [45454389445](https://github.com/shamiursunny/openTPU/actions/runs/45454389445), SHA `fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc` | 3-beat concurrent host/pair AW-W-B and AR-R; response backpressure; 2 write bursts, 6 read beats, 25 cycles | Not exhaustive fairness, ordering or formal AXI proof |
| Global-to-DIMM address-map SAT proof | Run [45457143624](https://github.com/shamiursunny/openTPU/actions/runs/45457143624), SHA `0d6128d21c086d52e0c6ca3a10bfe4f2666dcccb` | 14 assertions; 813 variables; 2,152 clauses; SAT SUCCESS | Selected combinational decoder properties only |
| Full-chip Verilator lint | Run [45455745243](https://github.com/shamiursunny/openTPU/actions/runs/45455745243), SHA `dc34e3a51c27c01af6296015cd206ab8336d6bda` | Workflow/job SUCCESS | Warning review and exact-SHA integration remain separate |
| ASIC AXI-Lite control | Run [45248945992](https://github.com/shamiursunny/openTPU/actions/runs/45248945992), SHA `ae997da8a993e962dd18de0fb1240f3d5656b3a2` | PASS marker for independent AW/W, gating, load pulse, reset and register map | Scoped control interface only |
| Earlier selected RTL/ISA suite | Run [45217729099](https://github.com/shamiursunny/openTPU/actions/runs/45217729099), SHA `66c708e573671136197c371a848cc9274ae394f2` | 99 passed plus separate AXI-Lite isolation test 1 passed | The LDC case duplicated one of the 99; 100 distinct selected cases, not 101 |
| Virtual DRAM/TMEM behavioural tests | Run [45453893286](https://github.com/shamiursunny/openTPU/actions/runs/45453893286), SHA `487fe6b93a83e4b86e5565b80de9b7f33c407436` | DRAMTEST, TMEMTEST and TMEM_MULTI PASS markers | Behavioural model only |

The subsystem matrix's 377 passing tests are the clearest single-run demonstration that the project has already passed well over 100 tests. The 377 is the sum of the 14 job summaries from that run. Do not add this to other run counts to claim a deduplicated lifetime total; runs overlap in test selection and source revisions.

### GitHub Actions history audit

The active feature-branch history query returned 705 workflow-run records, of which 316 had a SUCCESS conclusion at audit time. Those 314 are workflow-run records, not unique tests. Retries and workflow-only changes are included. Failed, cancelled, queued and in-progress runs must remain separately classified. In particular, the historical audit found no successful run in the queried branch history for the remaining RTL/board workflow, software-core workflow or WG8 ASIC research PPA workflow at that point. Therefore these areas remain release blockers even though other suites have passed.

### Current gate status — do not overstate

- **Selected digital tests:** substantial partial evidence; 377-pass subsystem matrix and focused suites recorded on their respective SHAs.
- **Four-DIMM host AXI integration:** not closed. A prior single-beat bench passed after a testbench reset-handshake correction, but expanded multi-beat/negative cases and the latest write-path diagnostic still require exact-SHA closure.
- **Host/accelerator contention:** one directed four-instance HMUX scenario passed; expanded current testbench and assertions must still be reconciled with the latest run.
- **Software/ISA:** no successful software-core workflow was found in the queried history; do not infer coverage from RTL or subsystem results.
- **PPA:** no successful WG8 ASIC research PPA workflow was found; there is no verified area, timing or power result.
- **Physical/manufacturing:** DDR controller/PHY, PCIe endpoint/PHY, SRAM hard macros, PDK, DFT, package, board SI/PI, physical signoff and silicon remain external/unimplemented/unvalidated.
- **Commercial qualification:** no measured representative-hardware throughput, energy, full-system TCO, customer demand, revenue or payback is established.

The 64-GiB address-window skip is intentional: at that geometry all representable addresses are within DRAM, so the specific test expecting an address beyond DRAM is inapplicable. Keep it visible as a skip, not a pass.

**Release decision remains NOT READY for fabrication or final production-board build.** The manufacturer may review the logical architecture and feasibility gaps, but the evidence must be labelled as simulation/source-level evidence and scoped by exact commit SHA. Use one immutable SHA only after all applicable final regression and release checks pass.


## 11. Live continuation addendum — 2026-11-25

This addendum supersedes any earlier “current next action” text in Sections 9–10 where the listed run IDs or statuses are older. Historical results above remain preserved.

### Live branch and evidence checkpoint
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Diagnostic-only testbench commit: `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a` (four-DIMM W-channel assertion now prints actual/expected data, strobes, WLAST, owner FIFO and handshake state).
- The previous code checkpoint before the diagnostic commit was `65f28fc09ede79581ba97845165733d1caef45b1`; main remains the protected `d84db55712aba0d40811d7762cb052f05d55b7e5`. No synthesizable RTL changed in the diagnostic commit.
- The first workflow lookup for the diagnostic commit returned no associated run. Do not assume CI triggered; verify the live run list or create an explicitly reviewed workflow retrigger if required.

### Updated task statuses
| ID | Current status | Latest evidence / next closure action |
|---|---|---|
| A01 | DONE — scoped single-beat only | Historical single-beat four-DIMM host path pass remains valid; it does not cover burst protocol. |
| A02 | FAILED — action required | Runs 45465292665 (SHA 86f922c...) and 45465384680 (SHA 65f28fc...) both failed at DIMM2 W beat 0. Three integrated lint stages passed on both SHAs. Inspect the new diagnostic commit's exact WDATA/WSTRB/WLAST and mux-state output before changing RTL. |
| A03 | IN PROGRESS — not reached in latest integrated run | Four-instance HMUX directed test passed historically on SHA fc3bdcc..., but latest ASIC/config run skipped this stage after A02 failed. Re-run after A02 is diagnosed. |
| A04 | FAILED — ORFS run diagnosis required | Run 45454389335 / job 138659794535 failed with ORFS exit 2 on SHA fc3bdcc...; artifact 14960636530 contains full evidence. Inspect run.log and identify exact failing stage. |
| A05 | IN PROGRESS | No valid WG8 PPA metrics. Older Run 45455745851 / job 138664562707 remained in progress at last poll. |
| A06 | IN PROGRESS | Latest subsystem Run 45465292903 had 14 queued jobs at last poll. Retrieve exact final job logs and reconcile skip reasons. |
| A07 | IN PROGRESS | Software-core Run 45465292772 / job 138698481416 was in progress at last poll. |
| A08 | IN PROGRESS | Board-functional Run 45465292882 / job 138698482005 was in progress at last poll. |
| A09 | IN PROGRESS | Uncovered-RTL Run 45465292882 / job 138698481369 was in progress at last poll. |
| A10 | NOT STARTED | Final immutable SHA regression cannot begin until A02–A09 and A11–A12 are resolved or explicitly accepted. |
| A11 | PARTIAL | All three integrated ASIC lint stages passed on SHA 65f28fc...; this does not close full-chip lint or all width/unused warnings. |
| A12 | PARTIAL | Historical HMUX assertion-enabled directed simulation exists, but latest integrated run skipped the HMUX stage. Formal proof remains open. |
| H06 | PARTIAL | Standalone combinational address-map SAT proof passed historically; latest integrated address-map simulation skipped because A02 failed first. DMA integration and end-to-end routing remain absent. |
| H12 | IN PROGRESS — external evidence gaps | TCO model is a specification, not populated economics. No customer demand, supplier quotations, measured full-system power or validated payback. |

### Latest run reconciliation
- Run 45465384680 / SHA 65f28fc...: FAILED at `DIMM2 host W payload/last mismatch beat=0`; three integrated lint stages passed; address-map and HMUX steps skipped.
- Run 45465292665 / SHA 86f922c...: same failure after three integrated lint stages passed.
- Run 45465292944: SUCCESS, 33 passed, 1 parameter-inapplicable skip, 183 deselected; selected RTL-tail only.
- Run 45465292882: board-functional and uncovered-RTL jobs IN_PROGRESS at last poll.
- Run 45465292772: software-core IN_PROGRESS at last poll.
- Run 45465292903: all 14 subsystem/memory jobs QUEUED at last poll.
- Run 45454389335 / SHA fc3bdcc...: WG8 ORFS PPA failed with exit 2; full artifact 14960636530 uploaded. No area/timing/power result accepted.
- Run 45455745851: older WG8 PPA attempt still IN_PROGRESS at last poll.

### Immediate ordered work
1. Verify whether commit `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a` triggered ASIC/config CI. If not, retrigger the workflow on this exact SHA without changing synthesizable RTL.
2. Retrieve the diagnostic mismatch fields. Determine whether the issue is WDATA, WSTRB, WLAST, owner FIFO, source selection, register-slice backpressure, or testbench sampling.
3. Make only the smallest evidence-supported correction; rerun four-DIMM multi-beat and negative-aperture tests.
4. Re-run the global address-map and four-instance HMUX contention/assertion stages after A02 passes.
5. Retrieve final software, board, subsystem and PPA job logs; inspect artifact 14960636530's ORFS run.log.
6. Update this register, the project resume and chronological tracker with exact SHA/run/job evidence. Never promote queued/running jobs to PASS.

The former 30 W total-system ceiling remains retired. No replacement wattage limit is approved. Hardware power, memory size and compute configuration remain evidence-led decisions based on representative workloads, full-system TCO, measured wall power and incremental contribution margin.


### Workflow retrigger addendum — 2026-11-25
- Diagnostic testbench commit: `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a`.
- Comment-only ASIC/config workflow retrigger commit: `597f1b9af961f4e8fcde1ae9fffa013ce6bc7f54`; no workflow commands or RTL changed.
- The immediate commit-workflow lookup still returned no run for either commit. No new test result exists yet. Check Actions again; do not report a run as started or passed without a run/job record.
- Current latest tracker record: Section 128. Main remains untouched at `d84db55712aba0d40811d7762cb052f05d55b7e5`.


### Latest job-state correction — 2026-11-25
The latest re-poll supersedes the earlier snapshot in this addendum: uncovered-RTL job `138698481369` in Run `45465292882` is **CANCELLED** (not IN_PROGRESS); board-functional job `138698482005` remains IN_PROGRESS. Software-core job `138698481416` remains IN_PROGRESS; all 14 jobs in subsystem Run `45465292903` remain QUEUED; PPA job `138664562707` in Run `45455745851` remains IN_PROGRESS. A09 therefore requires a fresh exact-SHA execution. See tracker Section 129.


### 12. Diagnostic instrumentation compile failure and corrected rerun — 2026-11-25

- ASIC/config Run [45479454587](https://github.com/shamiursunny/openTPU/actions/runs/45479454587), SHA `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a`, job `138748357284`, failed at testbench compilation. Verilator rejected the procedural variable-index hierarchical path `dut.g_host_mux[d].u_hmux`. The four-DIMM simulation did not execute, so this run does not qualify or further diagnose the DUT.
- Corrected testbench instrumentation commit: `76966009274be54ce26d87e333744b5cc17f72b4`. Uses static `genvar gd` probes for `wo_h`, `wo_rv`, `w_v`, `w_r`, then reads those vectors in the procedural assertion. No synthesizable RTL or assertion criteria changed.
- Six workflows are now confirmed for the corrected SHA; all were QUEUED at last poll:
  - ASIC/config Run [45481815682](https://github.com/shamiursunny/openTPU/actions/runs/45481815682), job `138756664096`.
  - Board/uncovered RTL [45481815901](https://github.com/shamiursunny/openTPU/actions/runs/45481815901).
  - Software-core [45481815819](https://github.com/shamiursunny/openTPU/actions/runs/45481815819).
  - RTL tail [45481815780](https://github.com/shamiursunny/openTPU/actions/runs/45481815780).
  - Subsystems/WG8 [45481815735](https://github.com/shamiursunny/openTPU/actions/runs/45481815735).
  - Isolated TMEM [45481815691](https://github.com/shamiursunny/openTPU/actions/runs/45481815691).
- Older ASIC retrigger Run `45480699954` on SHA `597f1b9...` remained queued; it contains the earlier invalid diagnostic expression and must not be treated as corrected-SHA evidence.
- Immediate gate: wait for and inspect the corrected-SHA ASIC/config job. If it compiles, record the DIMM2 WDATA/WSTRB/WLAST and mux-owner/handshake values. Do not alter DUT RTL until that evidence establishes the defect.
- The exact live job list and chronological detail are in PROJECT_TRACKER.md Section 130.


### 13. Corrected-SHA workflow queue transition — 2026-11-25

Latest re-poll supersedes the initial all-QUEUED snapshot in Section 12. On corrected testbench SHA `76966009274be54ce26d87e333744b5cc17f72b4`:
- ASIC/config Run 45481815682 / job 138756664096: QUEUED.
- Board/uncovered Run 45481815901: board-functional 138756665399 QUEUED; uncovered RTL 138756666235 IN_PROGRESS (building pinned Verilator 5.044).
- Software-core Run 45481815819 / job 138756667852: QUEUED.
- RTL-tail Run 45481815780 / job 138756664573: IN_PROGRESS (dependency installation).
- Subsystems/WG8 Run 45481815735: all 14 jobs QUEUED.
- Isolated TMEM Run 45481815691 / job 138756665688: IN_PROGRESS.
No corrected-SHA ASIC/config result exists yet. The static diagnostic instrumentation fix remains unvalidated until the ASIC/config job builds and the four-DIMM simulation runs. See tracker Section 131.


### 14. Four-DIMM W-channel diagnostic conclusion and corrected A02 response model — 2026-11-25

This section supersedes the A02 failure diagnosis and pending-state snapshots in Sections 12–13 and the earlier A02/A03 live-status addendum. It does not promote any verification task to DONE.

- **A02 status: IN PROGRESS — testbench model correction committed; exact-SHA rerun pending.**
- Corrected diagnostic run [45481815682](https://github.com/shamiursunny/openTPU/actions/runs/45481815682), job \`138756664096\`, exact SHA \`76966009274be54ce26d87e333744b5cc17f72b4\`, passed 66 target/config tests and all three integrated lint stages, then failed during the four-DIMM simulation at 135 ns. Actual DIMM2 WDATA was host beat 2 while the scoreboard expected beat 0; WSTRB was the beat-2 full strobe rather than beat-0's alternating strobe; WLAST matched.
- **Root cause identified in the testbench response model:** it asserted BVALID after any accepted W beat, rather than after the final WLAST beat. The early B handshake reset the testbench W beat counter during the burst, creating a false payload mismatch. No production RTL fault is established by this result.
- **Correction:** commit \`68baca1a080e952b20327c90d63a6f66c6a1ee70\` changes the B-response condition to require \`w_complete\` or a same-cycle accepted WLAST beat. The commit changes only \`sim/verilator/tb_asic_wg8_ddr4.sv\`; it does not change synthesizable RTL, test payloads, expected values or acceptance criteria.
- The feature branch was independently compared and confirmed exactly at \`68baca1a080e952b20327c90d63a6f66c6a1ee70\` immediately after the correction. Main remains unchanged at \`d84db55712aba0d40811d7762cb052f05d55b7e5\`.
- At the latest immediate post-commit query, no combined status or associated workflow run was returned. The commit-workflow lookup exposes PR-triggered runs only, and combined status is not a complete Actions run listing; empty results do not prove that a push-triggered run is absent. The exact-SHA push workflow state/run ID is UNKNOWN until the repository Actions history is checked. A02 remains pending until an exact-SHA ASIC/config run compiles and passes the multi-beat host test plus both negative-aperture cases.
- A03 remains IN PROGRESS and was skipped in the previous integrated run because the A02 step failed first. Its four-instance HMUX contention bench and assertions must be inspected on a successful A02 gate; historical directed passes do not close the current integrated task.
- On SHA \`769660...\`, RTL-tail Run \`45481815780\` passed 33 tests with one documented geometry skip and 183 deselected; isolated TMEM Run \`45481815691\` passed 2 tests with 215 deselected. These are scoped historical results and do not transfer to SHA \`68baca...\`.
- Board-functional/uncovered RTL, software-core and subsystem runs from the same prior diagnostic SHA were still in progress or queued at last poll. Reconcile each by exact run/job/SHA. The PPA tasks A04/A05 remain open; no area, timing, power or PPA claim is accepted.
- **Next ordered work:** (1) verify the push-triggered ASIC/config run for SHA \`68baca...\`; (2) inspect its full log and verify multi-beat WDATA/WSTRB/WLAST, B timing, negative AW/AR aperture cases; (3) if successful, inspect address-map simulation and four-instance HMUX contention/assertions; (4) reconcile board, uncovered RTL, software and subsystem workflows; (5) inspect full ORFS logs/reports for PPA separately. Do not modify HMUX RTL unless a new failure demonstrates a DUT defect.
- The release gate remains OPEN. A01 is only a scoped single-beat host-path pass; A02/A03, A04/A05, A06–A12 and final immutable-SHA regression remain open or partial as previously recorded. Manufacturer/physical dependencies H01–H11 remain unclosed; H12 remains evidence-input blocked. No paid resources or hardware purchases used.



### 15. Exact-SHA regression queue and remaining evidence gates — 2026-11-25

- The exact-SHA push-triggered workflow set for code commit \`68baca1a080e952b20327c90d63a6f66c6a1ee70\` is now confirmed. ASIC/config Run [45487119079](https://github.com/shamiursunny/openTPU/actions/runs/45487119079) / job \`138775349960\` is **QUEUED**. This is the gate that must validate A02 and then execute the integrated address-map and four-instance contention steps.
- Other same-SHA workflows: board-functional job \`138775349751\` in Run \`45487118979\` is **IN_PROGRESS**; uncovered RTL \`138775349549\`, software-core \`138775350415\`, isolated TMEM \`138775350575\`, all 14 subsystem jobs in Run \`45487118947\`, and RTL-tail \`138775349245\` are **QUEUED**.
- A02 remains **IN PROGRESS — exact-SHA run queued**, not passed. A03 remains **IN PROGRESS — source reviewed, integrated simulation not yet executed**. Address-map integration remains unverified until the ASIC/config workflow reaches that step.
- Independent source review of the corrected W-response model supports the testbench diagnosis: it only asserts BVALID after WLAST is accepted (or the write burst is already complete), avoiding an early B handshake and mid-burst beat-counter reset. No production RTL modification is justified.
- The 4-DIMM contention bench source contains simultaneous host/accelerator AW and AR requests, round-robin grant expectations, two-beat W ordering, response-ID routing checks and independent backpressure. Source inspection does not count as simulation evidence.
- PPA remains open: WG8 PPA Run [45455745851](https://github.com/shamiursunny/openTPU/actions/runs/45455745851) failed. Its 1.56-GB artifact is retained; no PPA values or silicon metrics are accepted. Defer bulk download until a targeted log extraction is available.
- Continue with the ASIC/config run first, then the independent same-SHA regressions. Keep all statuses SHA-scoped and do not promote queued/in-progress jobs to PASS. Main remains unchanged; no paid resources used.


### 16. Exact-SHA integrated ASIC/config gate passed — 2026-11-25

- ASIC/config Run [45487119079](https://github.com/shamiursunny/openTPU/actions/runs/45487119079), job `138775349960`, completed SUCCESS on code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`.
- Three integrated lint stages passed, covering ASIC control/compute, WG8 native-memory and WG8 four-DIMM AXI tops.
- Four-DIMM WG8 host AXI integration simulation, global-to-DIMM address-map simulation and four-instance host/accelerator mux contention simulation all completed successfully. This is meaningful scoped RTL integration evidence and closes the immediate A02/A03 run gate on this SHA; it does not replace full protocol/formal/CDC/RDC verification, physical design or silicon qualification.
- Isolated 128K one-copy TMEM job [45487119017](https://github.com/shamiursunny/openTPU/actions/runs/45487119017), job `138775350575`, also completed SUCCESS on the same code SHA.
- Same-SHA board-functional, uncovered RTL, software-core and RTL-tail jobs remain in progress; all 14 subsystem/WG8 jobs remain queued at this poll. These are not passed and must be reconciled individually.
- PPA is still open; prior WG8 PPA run failed and supplies no accepted area/timing/power result. Manufacturer release gate remains OPEN. Production PCIe/SerDes, DDR controller/PHY, macros, PDK, package, DFT, physical signoff, board electrical and measured workload evidence remain outstanding.
- Preserve zero-spend, feature-branch-only changes, exact-SHA evidence and no tapeout/manufacturing-readiness overclaim.



### 17. ASIC integration log review and unresolved warning risks — 2026-11-25

The complete ASIC/config job log and artifact [sunnyone-asic-config-log](https://github.com/shamiursunny/openTPU/actions/runs/45487119079/artifacts/14964499992) were inspected for exact code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`.

- Four-DIMM AXI simulation PASS: 1/2/4/8-beat reads and writes, W-before-AW, partial/zero strobes, all BRESP/RRESP codes, 4-KiB boundary-aligned bursts and independent backpressure.
- Both negative aperture tests PASS by observing the expected fatal: out-of-aperture AW and AR each rejected outside the 8-GiB DIMM aperture.
- Global map PASS: 32-GiB map, four DIMMs, two 4-GiB channels per DIMM, 4-KiB interleave, inverse bijection and out-of-aperture rejection.
- Four-instance HMUX PASS: simultaneous host/accelerator AW/AR contention, alternating grants, ordered two-beat W bursts, B/R ID routing and independent backpressure.
- Important lint warnings remain: 34-bit selected AW/AR addresses connect to 33-bit output pins in `otpu_asic_wg8_ddr4_top.sv:240,245` (WIDTHTRUNC); `otpu_slice.sv:906` reports UNOPTFLAT circular combinational logic on `aok`; additional width expansion/truncation and unused signal/parameter warnings exist. The address-width mismatch is a priority review item because truncation could be consequential if the discarded bit is meaningful. No defect is asserted until the address contract is traced end-to-end.
- The lint and simulation results are scoped digital verification only. No physical timing, electrical behaviour, DDR PHY, package, PDK, DFT, CDC/RDC or silicon result is established. Release gate remains OPEN.



### 18. Address-width warning source trace — 2026-11-25

The 34-bit actual `p_awaddr/p_araddr` nets connect the `otpu_mig_pair` output, whose width is `CL + clog2(NC) = 32 + 1 = 33` bits, to the 34-bit host mux interface. The source-level map defines a 33-bit DIMM-local address with bit 33 reserved zero; the mux accepts the wider 34-bit shape and the top checks that bit 33 is clear on host and controller addresses. The bridge's 34-bit channel address is reduced by `dimm()` to the 32-bit channel offset plus one channel-select bit; V1 channel capacity is 4 GiB (CL=32), and bridge PC is zero. This makes the reported connection consistent with zero-extension, not a demonstrated loss of a valid address bit. Keep the warning open for explicit width cleanup and boundary validation; do not call it a proven bug or silently suppress it.

The `aok` UNOPTFLAT warning at `otpu_slice.sv:906` is generated by a combinational lower-index priority chain over the packed `aok` vector. Static source review finds only dependencies from group `g` to lower groups `h < g`; no direct same-index cycle is evident. This remains a structural lint warning requiring targeted validation, not a proven functional loop. No RTL was modified. Manufacturer release gate remains OPEN.



### 19. RTL-tail regression result — 2026-11-25

RTL-tail Run [45487118908](https://github.com/shamiursunny/openTPU/actions/runs/45487118908), job `138775349245`, **SUCCESS** on code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`: 33 passed, 1 parameter-inapplicable skip (`PAIR needs 2M <= MCOLS; M <= ACT_ROWS`), 183 deselected. No standalone log artifact was uploaded because the configured log file was absent; the job log contains the pytest summary. This is targeted regression evidence only. Remaining board-functional, uncovered RTL, software-core and subsystem regressions are still in progress/queued. Release gate remains OPEN.



### 20. Live continuation poll — 2026-11-25

**Repository identity and source boundary**
- Active feature branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Branch HEAD before this documentation update: `06766e101f5451830638705eb616291df8b4ef7b`.
- Protected `main` re-queried at `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- A compare from code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70` to current HEAD reports 22 commits and changes only in `PROJECT_TRACKER.md`, `SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md` and `SUNNYONE_AI-X_PROJECT_RESUME.md`. Thus the verified RTL/testbench code SHA remains `68baca...`; later commits are documentation-only.

**Exact-SHA results**
| Task / workflow | Exact evidence | Current interpretation |
|---|---|---|
| A02 four-DIMM AXI | [Run 45487119079](https://github.com/shamiursunny/openTPU/actions/runs/45487119079), job 138775349960, SHA `68baca...` | PASS: 1/2/4/8-beat reads/writes, W-before-AW, partial/zero WSTRB, all BRESP/RRESP codes, 4-KiB aligned boundary bursts and independent backpressure |
| A02 negative aperture | Same job/log | PASS: bad_aw and bad_ar each produced the expected fatal outside the 8-GiB DIMM aperture |
| H06 integrated global map | Same job/log | PASS: 32-GiB global map, four DIMMs, two 4-GiB channels per DIMM, 4-KiB interleave, inverse bijection and out-of-aperture rejection |
| A03 four-instance HMUX | Same job/log | PASS: simultaneous host/accelerator AW/AR, alternating grants, ordered two-beat W, B/R ID routing and independent backpressure |
| RTL tail | [Run 45487118908](https://github.com/shamiursunny/openTPU/actions/runs/45487118908), job 138775349245, SHA `68baca...` | PASS: 33 passed, 1 parameter-inapplicable skip, 183 deselected |
| Isolated 128K one-copy TMEM | [Run 45487119017](https://github.com/shamiursunny/openTPU/actions/runs/45487119017), job 138775350575, SHA `68baca...` | Workflow/job SUCCESS; no count asserted without a verified summary |
| RTL subsystem/WG8 | [Run 45487118947](https://github.com/shamiursunny/openTPU/actions/runs/45487118947), SHA `68baca...` | 11/14 jobs SUCCESS; Address-window and Native DRAM/technology RAM IN_PROGRESS; Reset audit QUEUED |
| Board + uncovered RTL | [Run 45487118979](https://github.com/shamiursunny/openTPU/actions/runs/45487118979), SHA `68baca...` | Both jobs CANCELLED; partial output is not a passing result |
| Software-core | [Run 45487119094](https://github.com/shamiursunny/openTPU/actions/runs/45487119094), SHA `68baca...` | CANCELLED; partial pytest progress is not a pass |
| WG8 research PPA | [Run 45455745851](https://github.com/shamiursunny/openTPU/actions/runs/45455745851), older SHA `dc34e3a...` | FAILED; no accepted area/timing/power result |

**Count integrity:** Do not reuse the earlier unsubstantiated “249 passing subsystem tests” shorthand. This poll confirms 11 successful subsystem jobs but does not establish a reconciled test-case total for those 11. The historical 377-pass matrix remains valid only for its own run/SHA and must not be added to other overlapping runs to claim unique lifetime tests.

**Task register delta**
- A02: PASS — exact-SHA integrated four-DIMM multi-beat and negative-aperture checks on `68baca...`.
- A03: PASS — exact-SHA four-instance HMUX contention and response-ID routing on `68baca...`.
- RTL-tail: PASS — scoped, with explicit skip/deselection.
- Subsystem/WG8 matrix: PARTIAL — 11 successful jobs, 2 running, 1 queued.
- Board-functional and uncovered RTL: INCOMPLETE/CANCELLED; rerun required.
- Software-core: INCOMPLETE/CANCELLED; rerun required.
- PPA: FAILED/OPEN; no metrics accepted.
- Lint warnings WIDTHTRUNC and UNOPTFLAT: OPEN for explicit contract/structural disposition; prior source trace did not establish a functional defect.

**Next gate sequence**
1. Complete the remaining two subsystem jobs and reset audit; inspect exact test summaries and preserve the intentional 64-GiB geometry skip as a skip.
2. Rerun cancelled board, uncovered RTL and software-core tests with sufficient job time; record any genuine test failures separately from cancellation.
3. Diagnose PPA using targeted ORFS/Yosys log extraction; do not bulk-download the 1.56-GB historical artifact and do not report PPA figures until a successful reproducible run exists.
4. Review and disposition width and combinational-loop lint warnings without blanket waivers.
5. Perform a final full regression on one immutable candidate SHA only after the above gates are closed.

**Release decision remains NOT READY for fabrication, tapeout, physical signoff, production-board build or silicon qualification.** A02/A03 are meaningful digital simulation passes, not evidence of physical implementation, timing closure, power, thermal behaviour, DDR/PCIe PHY readiness, DFT, package integrity or commercial performance. Zero-spend and feature-branch-only constraints remain active.


## 21. Live continuation poll — 2026-11-25 (PPA evidence access limitation)

- Subsystem workflow `45487118947` has 12/14 successful jobs; Native DRAM/technology RAM (`138775352847`) and Reset audit (`138775353032`) remain in progress at latest poll. Finalize only after completion and log review.
- Historical PPA run `45455745851` failed at ORFS with exit 2 on SHA `dc34e3a...`. Prep successfully enumerated 288 SRAM macros / 14 sizes / 3,538 KiB, but no PPA metric is valid. The artifact is 1.56 GB and exceeds the connector's 512-MiB download ceiling; detailed ORFS logs therefore remain inaccessible via this artifact route. Root cause is OPEN, not diagnosed.
- Action: make the next PPA artifact failure-focused and compact (retain the ORFS run tail, failed-stage logs/reports, config, constraints, image digest and summary; exclude large `work/results` databases), then rerun. No blanket claims about timing, power, area or congestion.
- Manufacturer readiness remains NOT READY for fabrication, tapeout, physical signoff, production board or silicon qualification.


## 22. Subsystem matrix closure and retry status — 2026-11-25

- `45487118947` completed with 14/14 SUCCESS on RTL SHA `68baca...`. Extracted job summaries reconcile to **377 passed, 1 skipped, 0 failed**: 14, 17, 128, 20+1 skip, 5, 11, 13, 15, 8, 8, 23, 7, 104, 4 respectively. The one skip is explicitly configuration-inapplicable (64-GiB case: every address is DRAM). No overlap was added to any other workflow's test count.
- Retry attempts now running for `rtl-uncovered` and `software-core`. `board-functional` is still cancelled; GitHub rejected an immediate rerun while the same workflow attempt is active. Retry it after the current attempt settles.
- PPA workflow artifact was made compact in commit `c568020...`: excludes bulk results and full run.log, retains run tail, diagnostics inventory, reports, config/constraints, and stage logs. Await a new run; prior failure remains unresolved and no PPA metrics accepted.
- Fabrication/tapeout/physical signoff remains NOT READY.

### 22. Retry and release-gate checkpoint — 2026-11-25

The latest retry state was checked directly in GitHub Actions. Board-functional job `139135578982` and software-core job `139135639920` are IN_PROGRESS, both still in tool/dependency setup and not yet at their test steps. The latest uncovered-RTL job `139135582940` is CANCELLED; a further retry is blocked until the active board workflow settles. Earlier retries `139003943623`, `139003968520` and `139003945395` were also CANCELLED at their main test steps. No pass or failure count is inferred from cancelled runs.

The 14-job subsystem matrix remains fully verified at 14/14 SUCCESS and 377 passed, 1 configuration-inapplicable skip, 0 failed, on RTL SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`. The feature branch has advanced 32 commits beyond this tested code SHA, with changes confined to the PPA workflow and the three project continuity documents. Main remains at `d84db55712aba0d40811d7762cb052f05d55b7e5`; it has not been modified by this continuation.

The compact PPA evidence workflow is present at commit `c568020d91efd045c6dd5d89dbc30ebdbac2c866`, but a post-repair run and artifact were not confirmed in the available query results. The older PPA run remains failed and no area, timing, power or physical-design metric is accepted. Release readiness remains NOT READY for fabrication, tapeout, physical signoff, production board build or silicon qualification.


## 23. WG8 PPA compact rerun — failure-stage evidence — 2026-11-25

Actual post-repair run: [GitHub Actions 45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546), job `138974661431`, FAILED (ORFS exit 2). Compact evidence artifact `14997807086` is 221,016 bytes and was inspected. Pinned ORFS image digest: `sha256:9d227293bf57b9d84c63aa8551faa0487d30db456b254b8f244a1e40244f66af`.

**Observed failure point:** Yosys synthesis and floorplan completed; ORFS failed in `2_4_floorplan_pdn` at `check_placement -fixed -verbose` (Make error 247). The preceding timing-repair log found 11 setup-violating endpoints and warned that not all setup violations could be repaired. Preliminary floorplan JSON records setup WNS `-10.4346 ns` and TNS `-91.4594 ns`. It also explicitly reports no estimated parasitics / wire-load-model timing. Numerous PDN-0110 warnings state that no via was inserted between metal6 and metal7 at listed VDD coordinates.

These are **debug-only early-stage diagnostics**, not final timing closure, physical PPA, power, area signoff, or manufacturable layout. The run did not complete global placement, CTS, detailed routing, or final reports. Generated SRAM macro counts (288 macros / 14 sizes / 3,538 KiB) are a flow-preparation result and do not prove foundry SRAM availability or implementation feasibility. Do not publish floorplan estimates as product metrics.

**Required engineering closure before handoff:**
1. Diagnose why fixed-placement checking fails during PDN stage and whether the metal6/metal7 via warnings are geometry/PDN-grid configuration issues or real connectivity risks.
2. Inspect all 11 setup endpoints, clock/IO constraints, and the timing-repair sequence; resolve constraints or RTL only with a documented technical basis and regression evidence.
3. Rerun the complete ORFS flow through final timing, physical checks, and reports; preserve compact logs and machine-readable reports.
4. Independently review SRAM macro models, dimensions, ports, timing, and replacement with genuine target-process macros before any real implementation claim.

Board-functional job `139135578982` and software-core job `139135639920` remain IN_PROGRESS at their test steps; uncovered RTL job `139135582940` is CANCELLED. No result is inferred from active/cancelled jobs. The connected GitHub action set exposes no workflow-dispatch write action, so no manual dispatch is claimed.

**Manufacturer decision: NOT READY.** No tapeout, fabrication, physical signoff, production-board build, or silicon qualification. The 377-pass subsystem matrix and integrated AXI/HMUX simulations remain scoped digital verification only.

## 24. CI execution policy update — 2026-11-25

The 15 SUNNYONE GitHub Actions workflows now use per-workflow/per-branch concurrency groups with cancellation of superseded runs. This prevents an older run of the same suite consuming runner capacity after a newer commit arrives, without cancelling distinct verification suites. Existing test selections and path filters are retained.

The six-hour WG8 research PPA workflow is now manual-dispatch only. Run it against a frozen candidate SHA after functional and ASIC qualification gates pass. This avoids spending hours on every RTL commit while the floorplan-PDN failure is under investigation. No PPA pass or physical signoff is implied.

The subsystem matrix remains fail-fast disabled and capped at two parallel jobs so every group can report its outcome without excessive runner contention. No tests were removed or weakened. Measure the new policy on subsequent runs before claiming a quantified speed-up.

Manufacturer readiness remains NOT READY; this scheduling change does not close any RTL, PPA, PHY, DFT, package, physical signoff, board, thermal or silicon qualification gate.


## 25. WG8 PPA trigger refinement — 2026-11-25

The PPA workflow no longer responds to broad `rtl/**` changes. Its push filter is limited to the Nangate45 WG8 target's synthesized RTL source set, ASIC top, target/ASIC flow configuration and the explicit `docs/sunnyone/PPA_REQUEST.md` request marker. The workflow YAML itself is excluded to prevent a self-trigger. This preserves automatic PPA on relevant candidate-source changes while avoiding repeated multi-hour runs for unrelated RTL edits.

GitHub's documented `workflow_dispatch` requirement is that the workflow file must exist on the repository's default branch. This workflow currently exists only on the feature branch, while protected `main` is intentionally untouched; therefore, do not assume the manual Run workflow button is available yet. The request marker is the reliable feature-branch trigger. No PPA pass or physical signoff is implied.


## 26. RTL tail regression result and CI evidence gap — 2026-11-25

Run [45598047232](https://github.com/shamiursunny/openTPU/actions/runs/45598047232), job `139149245841`, completed SUCCESS on source SHA `36104fdaacabcba39ba4a7daa74b7fb19ce31536`. Exact pytest output: **33 passed, 1 skipped, 183 deselected in 742.68s**. The one skip is the documented configuration guard `PAIR needs 2M <= MCOLS; M <= ACT_ROWS`.

The artifact upload step did not actually produce an artifact: its log says `No files were found with the provided path: /tmp/sunnyone-rtl-tail.log`. The test command currently does not tee output to that path. Treat this as a CI logging/traceability defect; regression job itself passed. Fix logging with pipefail and verify an actual uploaded artifact on a later run.

The software-core, uncovered RTL, board-functional and several subsystem matrix jobs remain active/queued at this checkpoint. These are not handoff evidence until completed with inspectable results. Manufacturer readiness remains **NOT READY**. No change to RTL signoff or PPA status.


## 27. RTL-tail regression artifact repair — 2026-11-25

The missing RTL-tail log artifact was corrected in workflow-only commit `4a1eb21ea31749fff6c2b12b51472123a2540a59`. Pytest output now streams through `tee` to the declared artifact path with Bash `pipefail`, so test failures remain failures and a real log file should be available. Validation run [45604384259](https://github.com/shamiursunny/openTPU/actions/runs/45604384259) is IN_PROGRESS; do not consider the artifact fix validated until the log confirms upload. No hardware RTL changed. Manufacturer readiness remains **NOT READY**.


## CI logging repair correction — 2026-11-25

The first logging-repair validation run [45604384259](https://github.com/shamiursunny/openTPU/actions/runs/45604384259) FAILED before tests started. Exact error: `ERROR: file or directory not found: \\\\\\\\ `; the YAML continuation was over-escaped, causing pytest to interpret a literal backslash as a test path. No tests ran, and no artifact was created. This was a workflow-command quoting defect, not an RTL regression.

Corrected the step to a single-line pytest pipeline with `set -o pipefail` and `tee /tmp/sunnyone-rtl-tail.log` in commit `e0eea98ba00e65ca42b785bc6133a5679529506b`. New validation run [45604527541](https://github.com/shamiursunny/openTPU/actions/runs/45604527541) is IN_PROGRESS. Verify both pytest outcome and actual artifact upload before closing the issue. Do not treat run 45604384259 as a test result.



## 28. Latest Actions reconciliation — 2026-11-25

### Verified repository baseline
- Repository: https://github.com/shamiursunny/openTPU (fork of FeSens/openTPU).
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`; pre-update HEAD `f51dc234aaf5b4e7d9b61a2e45768d315a5dcd81`.
- Protected main: `d84db55712aba0d40811d7762cb052f05d55b7e5`, unchanged.
- Continue feature-branch-only. Preserve zero-spend approval and exact-SHA evidence rules.

### CI outcomes
- **RTL-tail logging repair: VERIFIED PASS.** Run [45604527541](https://github.com/shamiursunny/openTPU/actions/runs/45604527541), job `139171823473`, SHA `e0eea98ba00e65ca42b785bc6133a5679529506b`: 33 passed, 1 configuration-inapplicable skip, 183 deselected, 635.12 seconds. Artifact `sunnyone-rtl-tail-log` ID `15018530071` was downloaded and inspected; it contains the exact pytest summary. The earlier malformed-command run `45604384259` failed before tests and is not a regression result.
- **AXI-Lite control: PASS** on run [45598244519](https://github.com/shamiursunny/openTPU/actions/runs/45598244519), exact testbench commit `cf0d4d3...`; sticky error status expectation corrected from `0x6c` to `0x6e`, no RTL modification.
- **Reset/power-up audit, full-chip lint, address-map formal, virtual DRAM, workload harness, RTL-tail, isolated TMEM, PCIe Gen2, HMUX simulation and ASIC configuration** have successful scoped runs as recorded in PROJECT_TRACKER.md Section 150. Each pass applies only to its own run SHA and test scope.
- **Subsystem/memory matrix:** 13/14 jobs SUCCESS; Native DRAM/technology RAM job `139149249337` remains IN_PROGRESS at last poll. Matrix is not closed.
- **Software-core and remaining RTL/board:** latest broad runs `45598047393` and `45598047324` ended CANCELLED. They are not passes and have no usable result counts. Retry each once, sequentially, on a frozen current SHA after active matrix completion.
- **WG8 research PPA:** latest recorded run [45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546) failed in ORFS at floorplan-PDN placement checking. Preliminary WNS/TNS are debug diagnostics only; no final PPA, power, timing or area signoff is accepted.

### Release/handoff decision
**Manufacturer readiness: NOT READY.** RTL/ISA/board-level digital tests do not establish complete PCIe endpoint/PHY, production DMA/IOMMU, DDR controller/PHY/training/ECC, CDC/RDC, DFT, SRAM macro qualification, physical signoff, package, board electrical validation, thermal/power validation or silicon qualification. No tapeout/fabrication-ready claim is authorised.

### Controlled next sequence
1. Complete and inspect the active Native DRAM job.
2. Run software-core once and wait for completion.
3. Run remaining RTL/board once and wait for completion.
4. Review any failures at source/log level; make only minimal evidence-backed corrections.
5. Freeze one candidate SHA and run consolidated regression; then revisit PPA only after prerequisite gates pass.



## 29. Native DRAM runtime control — 2026-11-25

The subsystem matrix [45598047338](https://github.com/shamiursunny/openTPU/actions/runs/45598047338) remains open: 13/14 jobs are successful and Native DRAM/technology RAM job `139149249337` is still running at the latest poll. The test step has no terminal result or artifact yet.

Workflow/test review identifies an aggregate-runtime risk, not a confirmed test defect: the Native DRAM helper allows up to 1,800 seconds for an individual simulation, but the combined Native DRAM and technology RAM matrix job has a 45-minute overall timeout. After the current run settles, separate the Native DRAM suite into bounded logical groups and move technology RAM to its own job. Retain all tests, assertions and artifacts. Do not interrupt the active matrix to apply this scheduling-only change.



## 30. Current verification status and handoff sequence — 2026-11-25

### Verified state
- Feature branch: `sunnyone/commercial-profitability-architecture-2026-11-23`; branch HEAD before this documentation-only checkpoint: `db16fea6a7f39d29be62e4606842d3d24482520c`.
- Protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5`; unchanged.
- Subsystem/memory matrix [45598047338](https://github.com/shamiursunny/openTPU/actions/runs/45598047338): 14/14 jobs SUCCESS on source SHA `36104fdaacabcba39ba4a7daa74b7fb19ce31536`; reconciled matrix total **377 passed, 1 configuration-inapplicable skip, 0 failures**.
- Native DRAM + technology RAM log artifact ID `15020003974` inspected: **104 passed in 1,829.20 seconds**.
- Separate RTL-tail run [45604527541](https://github.com/shamiursunny/openTPU/actions/runs/45604527541): **33 passed, 1 skipped, 183 deselected** on SHA `e0eea98ba00e65ca42b785bc6133a5679529506b`; artifact inspected.
- AXI-Lite control [45598244519] successful on its own exact testbench SHA; testbench-only expectation correction, no RTL modification.

### Open regression items
- Software-core run [45598047393](https://github.com/shamiursunny/openTPU/actions/runs/45598047393), attempt 2, job `139201961395`: IN_PROGRESS at “Core ISA, compiler, kernels, numerics and host software”; no result count yet.
- Remaining RTL/board run [45598047324](https://github.com/shamiursunny/openTPU/actions/runs/45598047324): previous attempt CANCELLED; jobs `139149245874` and `139149246459` require a fresh sequential retry after software-core settles.
- The Native DRAM group completed within its 45-minute budget; the earlier runtime concern was not reproduced as a timeout. Do not change/split tests without evidence.

### Handoff gate after current queue
1. Inspect software-core terminal result, complete log and artifact.
2. Retry and inspect RTL-uncovered, then board-functional; do not run these broad suites concurrently.
3. Reconcile exact tested SHA and all pass/skip/fail/deselected counts in tracker, resume and this handoff.
4. Freeze one candidate SHA and complete the required consolidated regression.
5. Diagnose WG8 ORFS floorplan-PDN failure [45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546) before any accepted PPA claim; no final PPA metrics currently exist.

### Manufacturer-readiness decision
**NOT READY.** Passing digital regressions do not establish production PCIe endpoint/PHY, DMA/IOMMU, DDR controller/PHY/training/ECC, CDC/RDC, DFT, qualified SRAM macros, physical signoff, package, board electrical validation, power/thermal validation or silicon qualification. Do not describe the design as tapeout/fabrication/production ready. Regression-queue completion advances verification only; it does not close these manufacturer gates.



## 31. Live verification re-poll — 2026-11-25

- Subsystem/memory matrix [45598047338](https://github.com/shamiursunny/openTPU/actions/runs/45598047338) was re-polled: **14/14 jobs SUCCESS** on source SHA `36104fdaacabcba39ba4a7daa74b7fb19ce31536`. Reconciled matrix result remains **377 passed, 1 configuration-inapplicable skip, 0 failures**; the 104 Native DRAM/technology RAM passes are included in that total, not additional.
- Software-core retry [45598047393](https://github.com/shamiursunny/openTPU/actions/runs/45598047393), job `139201961395`, remains **IN_PROGRESS** at the core ISA/compiler/kernels/numerics/host software test step. Setup and dependency installation completed. No terminal test count or artifact is available; active-run log retrieval returns BlobNotFound and is not evidence of failure. Workflow job timeout is 45 minutes.
- Prior RTL/board retry [45598047324](https://github.com/shamiursunny/openTPU/actions/runs/45598047324) is confirmed CANCELLED for both `rtl-uncovered` (`139149245874`) and `board-functional` (`139149246459`). No results may be counted.
- Execution order remains strict: wait for software-core terminal status and inspect evidence; then run RTL-uncovered once; then board-functional once. Do not overlap broad suites. If software-core times out, partition the same test selection into bounded jobs without removing tests or assertions.
- No RTL, testbench or workflow change was made during this re-poll. Manufacturer readiness remains **NOT READY**. The outstanding queue is verification work only; PCIe/DDR hard IP, DMA/IOMMU, CDC/RDC, DFT, production SRAM macros, physical signoff, package, board and silicon qualification remain open.


## 32. Software-core timeout and controlled retry — 2026-11-25

Software-core attempt [45598047393](https://github.com/shamiursunny/openTPU/actions/runs/45598047393), job `139201961395`, ended **CANCELLED** at approximately 44m42s inside pytest. The complete job log confirms setup and dependency installation succeeded and the test step was terminated by GitHub; pytest had shown 43% progress, but produced no terminal summary. No test count is credited and this is not classified as an assertion failure.

A workflow-only isolation fix was committed: `38377909bf68e3aa6102efac6c56b832675d44d4`. The same 15 test modules are now separate matrix jobs with `max-parallel: 1`, 45-minute per-module timeout, fail-fast disabled, verbose pytest logs and per-module artifacts. No RTL or test source was changed and no test/assertion was removed. Await and inspect the automatically triggered validation run; this scheduling change is not yet validated until actual job evidence is available.

Handoff remains **NOT READY**. Complete all 15 module jobs, then rerun RTL-uncovered and board-functional sequentially, followed by consolidated regression. No PPA or manufacturing readiness claim is authorised.


## 33. Software-core serial retry first module evidence — 2026-11-25

The corrective serial matrix run [45622326985](https://github.com/shamiursunny/openTPU/actions/runs/45622326985), on workflow commit `38377909bf68e3aa6102efac6c56b832675d44d4`, is active. Re-poll shows one of 15 module jobs SUCCESS, one IN_PROGRESS and 13 QUEUED, confirming no overlapping module jobs. `tests/test_isa.py` job `139233449899`: **18 passed in 0.13s**; uploaded artifact `sunnyone-software-core-0-log` ID `15024379354` and pytest output inspected. `tests/test_compiler.py` job `139233450657` is currently IN_PROGRESS. This is only partial validation; the software-core handoff gate remains OPEN until every module passes. Manufacturer readiness remains NOT READY.


## 34. Live software-core verification checkpoint — 2026-11-25 (Asia/Dhaka)

**Handoff gate: OPEN / NOT READY.**

The serial software-core retry is live at [run 45622326985](https://github.com/shamiursunny/openTPU/actions/runs/45622326985), on workflow source commit `38377909bf68e3aa6102efac6c56b832675d44d4`. All 15 module jobs are present and serial scheduling is operating as configured.

Latest live poll:
- 5 module jobs SUCCESS.
- 1 module job IN_PROGRESS: VOPS, job `139233450456`.
- 9 module jobs QUEUED.
- Inspected module results: ISA 18 passed; compiler 44 passed; kernels 46 passed; quantisation 81 passed; formats 13 passed.
- Verified subtotal: **202 passed, 0 reported failures, 0 reported skips** across those five completed module logs. Per-module log artifacts are uploaded and the pytest summaries have been inspected.
- The active VOPS log is not yet retrievable while the job is running; this is not evidence of failure.
- The previous aggregate software-core job was cancelled at its timeout without a terminal pytest summary and contributes no test count.

No RTL, testbench, assertions or workflow definition changed in this checkpoint. All intervening changes after the workflow source commit are continuity-document-only and are outside the software-core workflow's watched path filters. Re-check the live branch tip before the next execution.

**Required handoff closure sequence**
1. All 15 software-core modules must reach terminal SUCCESS with inspected logs and artifact records.
2. Run and inspect RTL-uncovered regression.
3. Run and inspect board-functional regression after RTL-uncovered settles.
4. Reconcile exact tested source SHA, all job/run/artifact IDs, pass/skip/fail counts and limitations across the tracker, handoff and resume.
5. Freeze one candidate and complete the appropriate consolidated verification.

**Do not release to a manufacturer as a completed design.** PCIe endpoint/SerDes, DDR controller/PHY/training/ECC, DMA/IOMMU, CDC/RDC, DFT, production SRAM macros, PDK/package, physical signoff, board electrical validation, power/thermal measurements, silicon qualification and commercial validation remain open. The previous WG8 research PPA failure at ORFS floorplan-PDN placement also remains unresolved; no area, timing or power metric is accepted.


## 35. Serial software-core matrix live evidence — 2026-11-25 (Asia/Dhaka)

Run [45622326985](https://github.com/shamiursunny/openTPU/actions/runs/45622326985) on workflow commit `38377909bf68e3aa6102efac6c56b832675d44d4` is the controlled serial retry. Live state: **10/15 SUCCESS, 1 IN_PROGRESS, 4 QUEUED, 0 failed/cancelled**. Active job is `tests/test_waits.py` (`139233450429`). Queued jobs are `test_waitw.py`, `test_host_runs.py`, `test_host_lock.py` and `test_host.py`.

Ten completed job logs and their pytest summaries were retrieved and inspected. Results and artifacts: ISA 18 (`139233449899`, artifact `15024379354`); compiler 44 (`139233450657`, `15026211469`); kernels 46 (`139233450577`, `15026436432`); quant 81 (`139233450565`, `15027565119`); formats 13 (`139233450333`, `15027510239`); VOPS 101 (`139233450456`, `15030235221`); FP 12 (`139233450380`, `15029541963`); MX 32 (`139233450804`, `15029542120`); stream 46 (`139233450596`, `15032330134`); dataflow 27 (`139233450490`, `15029769939`). All ten summaries report passed-only outcomes.

Subtotal: **420 passed, 0 reported failures, 0 reported skips**. This is partial software-core evidence, not a completed gate. The active waits job and four queued jobs are not counted. Keep the matrix running without source/workflow changes. After all 15 pass, run RTL-uncovered once and then board-functional once, sequentially. Manufacturer handoff remains **NOT READY**.


## 36. Software-core live result and WAITC retry — 2026-11-25 (Asia/Dhaka)

The serial software-core workflow [45622326985](https://github.com/shamiursunny/openTPU/actions/runs/45622326985), workflow/source commit `38377909bf68e3aa6102efac6c56b832675d44d4`, reached terminal state with **14/15 module jobs SUCCESS and one WAITC job CANCELLED**. All 14 successful job logs and pytest summaries were inspected: **557 passed, 1 skipped, 0 reported failures**. The single skip is the host model test whose `models/LFM2.5-230M` weights were not downloaded. Exact per-module job/artifact evidence is recorded in `docs/sunnyone/PROJECT_TRACKER.md` section 158.

WAITC job `139233450429` was cancelled at approximately 44m36s with pytest at 84%; the log shows successful tests through `test_waitc_rtl_boot_programs_of_different_lengths[2]`, but no terminal summary. No WAITC count is credited. This is a timeout/runtime-budget issue, not an observed assertion failure. Partial log artifact: `15034188015`.

A serial, two-part retry workflow was added at commit `37d2f78eef227275347f58b39fcab69916cdd60f`: `.github/workflows/sunnyone-waits-retry.yml`. It executes every test in `tests/test_waits.py` exactly once across two disjoint groups: all tests except `test_waitc_rtl_follow` (45-minute job), followed by all four RTL FOLLOW parameter cases (60-minute job). The second job depends on the first; both upload logs even on failure. The tracker update commit `d7aefdf27d9aaad1e59288df3846b5153221a924` is the configured push trigger. Verify the resulting Actions run and exact-SHA artifacts before closing WAITC.

**Current status:** software-core PARTIAL; WAITC OPEN. Do not proceed to RTL-uncovered or board-functional until the complete WAITC retry passes. Manufacturer readiness remains **NOT READY**. No RTL/test source was changed for this retry; do not infer PPA, physical, PHY/IP, board, silicon or commercial readiness.


## 37. WAITC retry verified — 2026-11-25 (Asia/Dhaka)

WAITC is now fully verified by [GitHub Actions run 45641472720](https://github.com/shamiursunny/openTPU/actions/runs/45641472720), tested at SHA `d7aefdf27d9aaad1e59288df3846b5153221a924`. Both jobs succeeded:
- General selection: 264 passed, 2 skipped, 4 deselected (the four RTL FOLLOW cases were run separately); artifact `15035927377`.
- RTL FOLLOW: all four configurations passed; artifact `15038143201`.
- Combined WAITC selection: **268 passed, 2 skipped, 0 failures**. The two skips are PyTorch-dependent test imports, not WAITC tests.

Software-core evidence reconciles to **825 passed, 3 skipped, 0 reported failures** across the 14 successful original module jobs and the complete WAITC retry. The original run 45622326985 remains historically cancelled; its 14 successful modules are retained as evidence and WAITC is closed by the separate successful retry.

**Remaining gates:** RTL-uncovered, board-functional, consolidated regression, PPA/physical design, production interfaces/IP, DFT, CDC/RDC, SRAM macros, PDK/package, board electrical verification, real-hardware power/thermal/performance measurements, silicon qualification and commercial readiness. Manufacturer readiness remains **NOT READY**.

A sequencing correction to `.github/workflows/sunnyone-rtl-functional.yml` was attempted to make board-functional depend on rtl-uncovered. GitHub rejected the update with HTTP 409 (repository rule validation timeout); a fresh read confirmed no change. Thus the workflow still allows those jobs to run in parallel. Retry the workflow-only change when repository rule validation is healthy. Do not start board-functional until RTL-uncovered succeeds.


## 38. CI workflow sequencing and verification status (2026-11-25)

- WAITC retry workflow is now manual-dispatch only; tracker documentation changes no longer trigger a full WAITC rerun (commit 639e1ce7f2d590276cb979286eb7adb20eaadcb3).
- RTL/board workflow now enforces board-functional needs rtl-uncovered (commit ebce653e73a378adce6dde60939cb1e052077862). Current run 45649502094 at that exact SHA is in progress; only RTL-uncovered job 139329804556 had started at last poll. No pass is assumed.
- Historical RTL-tail run 45604384259 failed before test collection because its command supplied a literal backslash as a pytest argument (exit 4, no tests ran). The current RTL-tail workflow was inspected and has the corrected single-line pytest command; later run 45604527541 succeeded.
- Accidental duplicate WAITC run 45649007571 remains in progress and is not counted. Previously verified WAITC pass remains run 45641472720 (268 passed, 2 skipped, 0 failures).
- These are CI orchestration fixes only. They do not close RTL/board integration, physical design, production IP, hardware, or manufacturing signoff gates. Manufacturer readiness remains NOT READY.


## 39. RTL regression live execution checkpoint — 2026-11-25 (Asia/Dhaka)

Handoff remains **OPEN / NOT READY**. Run [45649502094](https://github.com/shamiursunny/openTPU/actions/runs/45649502094), exact tested SHA `ebce653e73a378adce6dde60939cb1e052077862`, is still active. RTL job `139329804556` has completed checkout, Python setup, Verilator 5.044 build, and dependency installation; the selected core RTL/ISA pytest step is running. No terminal summary, artifact, or new test count is available. Live log retrieval returned a temporary GitHub storage `BlobNotFound`; do not classify this as a test failure. The board-functional job remains serially gated behind RTL success and has not started. Duplicate WAITC run `45649007571` remains excluded from authoritative evidence. Existing verified software-core (825 passed, 3 skipped) and subsystem/memory (377 passed, 1 configuration-inapplicable skip) totals are unchanged. Next gate is terminal RTL evidence followed by the gated board regression. Production PHY/IP, physical signoff, hardware validation, silicon qualification and commercial validation remain outstanding.


## Latest continuation reconciliation — 2026-11-25 (Asia/Dhaka)

The latest exact evidence and immediate continuation order are recorded in [PROJECT_TRACKER.md](PROJECT_TRACKER.md), Section 162. The previous broad RTL/board run 45649502094 ended CANCELLED during the 18-family RTL selection; board-functional was correctly skipped. No test count is credited. The workflow-only correction is committed as `7320c187810cbd7e4f106f0280922871f6430d1b`: four disjoint serial RTL groups, per-group verbose logs/artifacts, and board-functional gated behind the complete matrix. Its push-triggered execution still requires live Actions verification.

Verified scoped evidence remains: software-core 825 passed / 3 skipped / 0 reported failures (14 module jobs plus separately successful WAITC retry); subsystem/memory 377 passed / 1 configuration-inapplicable skip / 0 failures; RTL-tail 33 passed / 1 parameter-inapplicable skip / 183 deselected; ASIC/config integration run 45487119079 passed on exact code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`. These totals belong to their separate runs/SHAs and must not be added into one release-wide total.

**Current acceptance:** software-core and the cited subsystem/ASIC/RTL-tail scopes have passed; remaining RTL-uncovered and board-functional gates remain OPEN. Consolidated regression remains pending. The WG8 research PPA failure remains unresolved; no accepted PPA metrics exist. Manufacturer readiness remains **NOT READY**. Production PCIe/DDR PHY/controller IP, DMA/IOMMU, formal/CDC/RDC, DFT, qualified SRAM macros, PDK/package, physical signoff, board electrical validation, real-hardware power/thermal/performance, silicon and commercial validation remain outstanding. Zero-spend and feature-branch-only rules continue.


## RTL serial partition audit — 2026-11-25

The four serial RTL selections introduced in workflow commit `7320c187810cbd7e4f106f0280922871f6430d1b` were statically checked against `tests/test_rtl.py` (blob `84cdfed65c2c9d3604e51080ce88d878fc71a76a`). All 18 original selector terms match 18 distinct test functions, distributed 5/5/5/3 across the four groups with no unmatched selectors or duplicate function matches. This is a source-level partition check, not runtime test evidence; actual per-group pytest summaries and artifacts remain required. The RTL-uncovered and board-functional acceptance gates remain OPEN pending those Actions results.


## Live RTL workflow state — 2026-11-25

The serial RTL workflow is now executing as [Actions run 45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), head SHA `7320c187810cbd7e4f106f0280922871f6430d1b`. Last observed: group 1 is running its bounded pytest selection; groups 2–4 remain queued, confirming serial scheduling. Verilator 5.044 setup and project dependency installation succeeded. No terminal pytest count is available yet, and board-functional remains gated behind all four groups. See PROJECT_TRACKER.md Section 164. Do not infer a pass. Manufacturer readiness remains NOT READY.


## RTL uncovered regression update — 2026-11-25

On candidate workflow SHA `7320c187810cbd7e4f106f0280922871f6430d1b`, Actions run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812) completed RTL uncovered group 1 (job `139371666058`) successfully. Retrieved terminal log reports **12 passed, 205 deselected, 0 failed** in 24m14s; artifact `sunnyone-rtl-uncovered-1-log` (ID `15047592555`) uploaded. Group 2 was in progress at last poll; groups 3–4 queued; board-functional is still dependency-gated. This is one scoped regression result only. RTL-uncovered acceptance remains OPEN until groups 2–4 and board-functional finish successfully and are inspected. No change to readiness decision: **NOT READY**.


## RTL uncovered group 2 result — 2026-11-26

Actions run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), candidate SHA `7320c187810cbd7e4f106f0280922871f6430d1b`: group 2 job `139371665991` completed successfully. Retrieved pytest log: **24 passed, 193 deselected, 0 failed** in 24m38s. Artifact `sunnyone-rtl-uncovered-2-log`, ID `15049479359`, digest `7b48507d66da85cea1eac09b76aa9c52f648cd2e87f467a4d4c2ce53f6f206d6`. Groups 1 and 2 together account for 36 verified tests in two separate jobs; groups 3–4 and board-functional remain pending. Acceptance remains OPEN; manufacturer readiness **NOT READY**.


## Current RTL execution checkpoint — 2026-11-26 (Asia/Dhaka)

Actions run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), candidate SHA `7320c187810cbd7e4f106f0280922871f6430d1b`: RTL uncovered group 1 (job `139371666058`) passed **12 tests** and group 2 (job `139371665991`) passed **24 tests**. Their exact logs and artifacts were inspected; there are no failures, errors or skips in either selected group. Group 3 (job `139371665344`) is still running its bounded RTL selection after successful Verilator 5.044 build and dependency installation. Group 4 (job `139371666093`) remains queued; board-functional is dependency-gated and has not started. Thus 36 scoped passes are verified, but the RTL-uncovered gate and board-functional gate remain OPEN. No consolidated regression or PPA signoff is implied. Manufacturer handoff readiness remains **NOT READY**.


## Continuation checkpoint — 2026-11-26 (Asia/Dhaka)

The prior Actions run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), candidate SHA `7320c187810cbd7e4f106f0280922871f6430d1b`, was cancelled during RTL uncovered group 3. This was an orchestration cancellation, not a reported assertion failure. The group-3 log shows multiple tests passed before cancellation but contains no terminal pytest summary; therefore **no group-3 pass count is credited**. Original run attempt 1: group 1 passed 12, group 2 passed 24, group 4 passed 5; board-functional was skipped because the RTL matrix did not complete successfully. The verified completed-group subtotal is 41 tests, not full RTL acceptance.

A targeted rerun of only the cancelled group-3 job was requested using GitHub's per-job rerun action. Run attempt 2 is now `IN_PROGRESS`; active group-3 job ID `139448997925`. The existing successful groups 1, 2 and 4 remain successful in the rerun attempt. Inspect group 3's terminal pytest summary and artifact before crediting it. Then verify whether the dependency-gated board-functional job starts; if it does, inspect its terminal log and artifact. Do not start a duplicate workflow or rerun successful groups unnecessarily.

Current evidence status: RTL uncovered OPEN; board-functional OPEN / not yet evidenced; consolidated regression pending. Keep exact-SHA evidence, feature-branch-only writes, zero-spend rule and protected `main`. Manufacturer handoff remains **NOT READY**; no PPA, physical, production-IP, hardware, silicon or commercial signoff is implied.


## Follow-up poll — 2026-11-26 (Asia/Dhaka)

Run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), attempt 2, remains **IN_PROGRESS**. Group 1 job `139448999795`, group 2 `139449077187`, and group 4 `139449080038` are all **SUCCESS**. Their attempt-2 log artifacts are present: group 1 ID `15047592555`, group 2 ID `15049479359`, group 4 ID `15054188046`. Group 3 job `139448997925` is still in the pinned Verilator 5.044 build step; a group-3 artifact ID `15053746948` is listed, but because the job is active it is not treated as a terminal pytest report and no pass count is credited. Board-functional is still absent/not started because the four-group matrix has not completed. Next: allow this single job to finish; inspect its terminal log and artifact, then verify board-functional eligibility and results. Do not create another run.


## Continuity update — 2026-11-26 (Asia/Dhaka)

- Correct working repository: `shamiursunny/openTPU`; active feature branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- RTL/board workflow under inspection: [run 45661335812, attempt 2](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), run head/tested SHA `7320c187810cbd7e4f106f0280922871f6430d1b`. The current feature-branch HEAD at documentation time is `044ba53c7861af8235a3f8828c89656f85b5f503`; the run SHA is an ancestor of the current branch tip, not the current tip. Preserve both references distinctly.
- Latest run metadata read at 2026-11-26 01:40 Asia/Dhaka reports `in_progress`. Latest jobs snapshot: RTL uncovered groups 1, 2 and 4 are `success`; group 3 is `in_progress`. Its checkout, Python 3.12 setup, pinned Verilator 5.044 build and dependency installation succeeded; bounded RTL pytest remains in progress. No terminal summary or new test count is credited for group 3.
- Board-functional has not started. The workflow file at the tested run SHA contains `board-functional.needs: rtl-uncovered`, so board execution is gated behind the complete RTL matrix. Do not trigger board-functional separately.
- Group 3 log retrieval returned GitHub storage `BlobNotFound`; this is an unavailable live log, not evidence of a test failure. Re-fetch after terminal state and inspect logs/artifacts and pytest summary.
- Do not count partial/cancelled output or add unverified counts. Previously verified baselines remain software-core **825 passed, 3 skipped**; subsystem/memory **377 passed, 1 configuration-inapplicable skip**; WAITC run `45641472720` **268 passed, 2 skipped, 0 failures**.
- Next sequence: (1) poll run `45661335812` to terminal; (2) inspect group 3 and all four group logs/artifacts, reconcile exact non-overlapping pytest totals; (3) confirm board-functional starts only after all RTL matrix jobs succeed, then inspect its terminal log/artifact; (4) run consolidated regression only after both gates pass; (5) update continuity records with exact current branch and tested SHAs plus evidence.
- Keep protected `main` unchanged. No test removal/weakening, no unapproved expenditure or hardware purchase. Consolidated regression, PPA/physical signoff, production PHY/IP, DFT, CDC/RDC, board electrical validation, real-hardware power/thermal/performance, silicon qualification and commercial readiness remain open. Manufacturer handoff remains **NOT READY**.


## 20. RTL group 3 split to prevent long-running job bottleneck (2026-11-25)

- Updated `.github/workflows/sunnyone-rtl-functional.yml` on the active branch in commit `c638a84d85429a3c3a30989acfb62ba70c36e24a`.
- Original group 3 selection was split into two independently logged matrix jobs: **3.1** runs only `gathers_through_the_hub` (the dominant long-running parametrized test); **3.2** runs `tmem_random_traffic`, `tmem_random_traffic_input_stage`, `tmem_dump_is_the_ram`, and `mlp_4bit_rtl`. Group 1, 2 and 4 selections remain unchanged.
- RTL matrix job timeout increased from 45 to 90 minutes to provide adequate headroom for the isolated hub-gather simulation and toolchain build. Board-functional remains gated on every RTL matrix job succeeding.
- New workflow run **45692968740** (run #119) was created by the workflow update and was pending/queued at checkpoint time. Original run **45661335812** (run #118, attempt 3) remained in progress at last observation; do not assume it was cancelled or completed until status is rechecked.
- The earlier attempt's groups 1, 2 and 4 had succeeded; partial group-3 output showed 36 passes before cancellation, but no terminal pytest summary. Those partial results are not promoted to a completed group result. The new split run must supply terminal evidence for both 3.1 and 3.2.
- Next: inspect run 45692968740 jobs; verify the new job names and matrix; wait for groups 1, 2, 3.1, 3.2 and 4 to finish; inspect each artifact/pytest summary; then confirm board-functional runs only after all five succeed. Keep exact pass/skip/fail counts evidence-based.
- Protected `main` remains untouched. Consolidated regression, physical/PPA, board electrical, production IP/PHY, DFT, CDC/RDC, hardware power/thermal/performance, silicon qualification and manufacturer readiness remain open. Manufacturer handoff remains **NOT READY**.


## 2026-11-26 CI efficiency correction
- Historical verification audit: run #118 (`45661335812`) completed RTL group 1 job `139481341057` and group 2 job `139481272407` with `success`.
- The `tests/test_rtl.py` blob at run #118 commit `7320c187810cbd7e4f106f0280922871f6430d1b` is byte-identical to the current branch blob (`84cdfed65c2c9d3604e51080ce88d878fc71a76a`). The exact group 1 and group 2 test selections therefore have unchanged test source. These groups are accepted as historical passes and removed from the next matrix run to avoid redundant execution.
- Group 4 was `cancelled` in run #118 (`139481274581`); do not mark it passed from that run. The older successful RTL-tail suite (#91, job `139171823473`) ran a different eight-test selection and does not establish group 4 coverage. Group 4 remains required.
- Workflow updated in commit `fd2a310b303d94226c1e65efa0e63b767ac747f4`: matrix now contains only groups 3.1, 3.2 and 4; group 1/2 historical evidence is recorded in workflow comments.
- New workflow run #120 (`45693821197`) is pending on commit `fd2a310b303d94226c1e65efa0e63b767ac747f4`. Run #119 (`45692968740`) was created from the previous matrix and is superseded; its jobs were interrupted/cancelled after the workflow change. Confirm #120 jobs and conclusions before counting new passes.
- Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5` at the last verification. Manufacturer handoff remains NOT READY; this CI correction does not close outstanding PPA, formal, CDC/RDC, integration, physical implementation, power/thermal, or commercial validation work.

## Cross-chat continuation checkpoint — 2026-11-26 (Asia/Dhaka)

Authoritative working location: repository shamiursunny/openTPU; branch sunnyone/commercial-profitability-architecture-2026-11-23. Latest branch HEAD verified immediately before this checkpoint: 40dd0643f7e386751103bfa10f0d91b658e88dba. Protected main independently listed at d84db55712aba0d40811d7762cb052f05d55b7e5; do not write to or merge into main.

Active CI: RTL functional workflow run 45693821197 (https://github.com/shamiursunny/openTPU/actions/runs/45693821197), run head fd2a310b303d94226c1e65efa0e63b767ac747f4. Live job snapshot:
- Group 3.1 job 139486043538: IN_PROGRESS, building pinned Verilator 5.044; checkout and Python setup succeeded; dependency installation and pytest have not started.
- Group 3.2 job 139486044115: QUEUED.
- Group 4 job 139486044169: QUEUED.
- Board-functional depends on the complete RTL matrix; do not start it manually. No new group-3.1/3.2/4 pass count is credited yet.

Verified historical selection evidence: Groups 1 and 2 are accepted from successful run #118 (45661335812) because current tests/test_rtl.py is byte-identical to the tested blob (SHA 84cdfed65c2c9d3604e51080ce88d878fc71a76a). Group 1 and group 2 jobs in #118 were SUCCESS. Group 4 was CANCELLED in #118 and is not a pass; the older RTL-tail run covers a different selection. Current run #120 deliberately runs only groups 3.1, 3.2 and 4. Do not duplicate groups 1/2 unless test source or environment changes.

Immediate continuation sequence for any new chat/tab:
1. Read this checkpoint plus the latest sections of all three continuity files before making changes.
2. Re-query branch HEAD and run #120 jobs; never rely on the saved in-progress status without live polling.
3. Poll group 3.1, then 3.2 and group 4; for each terminal job inspect the full log/artifact and pytest terminal summary. Credit only exact observed pass/skip/fail counts. Diagnose failures from logs and make minimal fixes without weakening/removing tests.
4. After every RTL matrix job succeeds, verify the gated board-functional job starts; inspect its full log/artifact and terminal summary. If RTL fails, board should remain gated.
5. Only after RTL and board gates pass, proceed to consolidated regression and then the remaining integration/formal/physical/PPA/IP/board/hardware/commercial gates. Keep manufacturer handoff NOT READY until evidence closes those gates.
6. After each material engineering step, update PROJECT_TRACKER, MANUFACTURER_HANDOFF_READINESS and PROJECT_RESUME on this feature branch with exact SHA, run/job IDs, logs, counts, limitations and next action. Re-check branch HEAD and main before writes.

Guardrails: serial/low-concurrency execution; no duplicate jobs without cause; no invented test counts; no test weakening; zero spend and no hardware purchase without explicit approval; no claims of tapeout/production readiness from simulation-only evidence. Continue the user's requested remaining engineering work autonomously within these constraints.




## Verification continuity correction — 2026-11-26 (Asia/Dhaka)

The active RTL run is [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), tested SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`. Group 3.1 job `139486043538` remains IN_PROGRESS at bounded pytest; pinned Verilator 5.044 build and dependencies succeeded. Group 3.2 `139486044115` and group 4 `139486044169` are queued. Board-functional is still gated on the complete RTL matrix.

Historical group 4 was independently verified from job `139449080038` in run `45661335812`: terminal pytest summary **5 passed, 212 deselected, 0 failures**. The test source blob is identical on the active run SHA (`84cdfed65c2c9d3604e51080ce88d878fc71a76a`). This corrects the prior statement that group 4 had no successful evidence; a later cancelled attempt does not erase the earlier successful execution on unchanged source. The current workflow's group-4 rerun is redundant and must not be counted as additional unique coverage. Groups 1 and 2 also retain historical passing evidence. No manufacturer gate is closed by this correction; formal, CDC/RDC, physical/PPA, production IP/PHY, board electrical, hardware, power/thermal, silicon and commercial gates remain open. **Manufacturer handoff remains NOT READY.**

Next action: finish the existing run serially, inspect terminal logs/artifacts for 3.1, 3.2 and the duplicate group-4 run, then inspect board-functional only after all RTL jobs succeed. Preserve feature-branch-only writes, zero-spend approval and protected `main` (`d84db55712aba0d40811d7762cb052f05d55b7e5`).


### 15. Uncovered RTL split verification update — 2026-11-26

This update supersedes older live-state snapshots for workflow Run [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), while preserving all historical evidence.

| Job | State | Observed test result | Artifact |
|---|---|---|---|
| Group 3.1, job 139486043538 | DONE — workflow success | 8 passed, 209 deselected, 0 failed; 1,875.28 s | 15062436327 |
| Group 3.2, job 139486044115 | DONE — workflow success | 33 passed, 184 deselected, 0 failed; 529.45 s | 15064162074 |
| Group 4, job 139486044169 | IN PROGRESS at latest poll | Test selection running; no terminal pytest summary yet | Pending |

Both completed jobs checked out candidate SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`, Python 3.12.16, pytest 9.2.0 and pinned Verilator 5.044. Group 3.2's exact selection comprised 33 parameterised cases across TMEM random traffic, input-stage traffic, RAM dump and 4-bit MLP RTL. Group 3.1's log confirms eight selected tests passed. These results close only the stated selected groups on that exact SHA; they do not constitute a complete RTL matrix, board validation, full-chip signoff or production qualification.

The overall workflow remains IN_PROGRESS because Group 4 is still executing. Its log endpoint was unavailable while live (Azure BlobNotFound); this is not a test failure or a pass. Do not rerun it while the current job remains active. Groups 1 and 2 have previously verified passes; the historical Group 4 pass remains historical evidence and must not be double-counted with the current run.

**Current release decision remains NOT READY.** After Group 4 terminates, inspect the dependent board-functional job and continue the consolidated regression, integration, formal, lint, PPA, physical/IP, hardware and commercial gates. No test count is to be treated as a deduplicated lifetime total.



## Live continuation checkpoint — 2026-11-26 (Asia/Dhaka)

- Repository: `shamiursunny/openTPU`; all updates remain on feature branch `sunnyone/commercial-profitability-architecture-2026-11-23`. Branch tip before this checkpoint: `5cc9b8583786bd5a529b0008363aebdc8a547360`. Protected `main` independently verified unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`; do not modify or merge into it.
- RTL workflow [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), tested SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`:
  - Group 3.1 job `139486043538`: SUCCESS; exact terminal summary **8 passed, 209 deselected, 0 failed**; artifact `15062436327`.
  - Group 3.2 job `139486044115`: SUCCESS; exact terminal summary **33 passed, 184 deselected, 0 failed**; artifact `15064162074`.
  - Group 4 job `139486044169`: SUCCESS; downloaded artifact `15062269952` and inspected complete log; exact terminal summary **5 passed, 212 deselected, 0 failed** (336.28 s).
  - Historical groups 1 and 2 remain accepted from unchanged test source: **12 passed** and **24 passed**, respectively. Do not rerun or double-count them. The newly verified group selections 3.1 + 3.2 + 4 add 46 scoped passes; the four groups 1/2/3.1/3.2/4 together have 82 scoped pass executions. This is not a claim of 82 unique lifetime tests or full RTL acceptance without selector overlap reconciliation.
- The workflow's dependency-gated board-functional job `139521841026` has started only after all three currently scheduled RTL matrix jobs succeeded. At the latest live poll it remained **IN_PROGRESS** at the host-driver and board-model regression command; setup, checkout, Python, Verilator installation and project dependencies all succeeded. Its workflow timeout is 45 minutes. No board test count is credited until its terminal log/artifact is inspected. Do not start another board job or duplicate workflow.
- Current action: poll job `139521841026`; when terminal, inspect complete log and artifact, record exact pytest counts and failures/skips. If it passes, proceed to consolidated regression only if its defined prerequisites are satisfied; then continue remaining integration/formal/lint/PPA/physical/IP/PHY/DFT/board-electrical/hardware/commercial gates. If it fails, diagnose the actual failing tests and make minimal fixes without weakening selectors.
- Manufacturer handoff remains **NOT READY**. Selected RTL simulation success is not full formal proof, CDC/RDC closure, physical signoff, production PHY/IP readiness, board electrical validation, hardware performance/power/thermal evidence, silicon qualification, or commercial validation. Maintain zero-spend/no-hardware-purchase without explicit approval.


## Continuation checkpoint — 2026-11-26 (Asia/Dhaka)

- Repository: `shamiursunny/openTPU`; active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Branch HEAD before this documentation update: `ea8c7b430bf4cd695ceff902c1f01daea7d6bfd3`. Protected `main` independently verified at `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare reports 694 commits ahead / 0 behind. Do not modify or merge into `main`.
- RTL/board workflow: [run 45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), tested SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`, attempt 3. Groups 3.1, 3.2 and 4 are SUCCESS (8, 33 and 5 selected passes respectively; no failures). Historical Groups 1 and 2 remain accepted from unchanged source (12 and 24 selected passes). These are scoped selector counts, not a claim of 82 unique lifetime tests.
- The previous board-functional execution `139559281157` was CANCELLED after approximately 83% progress. Its log records passing tests through that point, but no terminal pytest summary; five Qwen/PyTorch-dependent tests were skipped because PyTorch was unavailable. No board-functional PASS is credited.
- A single-job retry was accepted. Current retry job `139677036786` (same workflow run) is IN_PROGRESS at the host-driver and board-model regression command. Checkout, Python setup, Verilator installation and dependency installation succeeded. Poll this exact job; do not start another workflow or manually bypass its dependency gate.
- PPA audit: research run [45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546), tested SHA `c568020d91efd045c6dd5d89dbc30ebdbac2c866`, FAILED in ORFS stage `2_4_floorplan_pdn`. Synthesis and floorplanning completed; generated SRAM inventory reported 288 macros / 3,538 KiB. The PDN log contains repeated PDN-0110 no-via warnings and a PDN-1051 empty macro-grid warning; the flow then exits at `check_placement -fixed -verbose` (ORFS exit 2 / make Error 247). The available log does not establish the precise root cause, so the warnings are diagnostic leads, not a proven causal explanation. Preliminary floorplan timing was WNS -10.43 ns and TNS -91.46 ns. The report's 5.95 W power estimate is a pre-route library/activity estimate, not measured silicon or board power. No signoff PPA result exists.
- The PPA artifact `14997807086` was downloaded and inspected; logs/reports/configuration evidence retained in the workflow artifact. Do not retry the same PPA unchanged. First isolate the PDN/placement failure and review macro-grid/strap/via geometry and floorplan constraints; preserve all physical checks.
- Additional existing CI evidence audited: ASIC target/config run `45598047221` SUCCESS; full-chip Verilator lint `45598047313` SUCCESS; address-map formal proof `45598047300` SUCCESS; PCIe Gen2 bridge simulation `45598047330` SUCCESS; RTL-tail run `45598047232` SUCCESS; WAITC run `45641472720` SUCCESS. These are historical tested-SHA results, not proof that every later RTL change was retested.
- Immediate next sequence: (1) poll board retry `139677036786` to terminal and inspect full log/artifact; (2) if it passes, define and run a consolidated regression on the then-current immutable candidate SHA; if it fails, diagnose actual failures without weakening tests; (3) investigate PDN/placement failure before requesting another PPA run; (4) continue CDC/RDC, broader formal, integration/IP/PHY/DFT, board electrical, hardware power/thermal/performance, silicon and commercial gates.
- Manufacturer handoff remains **NOT READY**. No tapeout/production readiness claim. No paid resources or hardware purchase authorised; maintain zero-spend and do not weaken/remove tests.


## Live continuation poll — 2026-11-26 03:47 UTC (Asia/Dhaka)

- Latest working-branch HEAD before this note: `171474b5b0783b72c23732b7c9acba3e48ec023b`; protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5`. GitHub comparison: 697 commits ahead, 0 behind. Main remains unchanged.
- Existing workflow run [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), attempt 3, remains `in_progress`, testing SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`.
- Board-functional job `139677036786` remains `in_progress`. Latest step poll: setup, checkout, Python setup, Verilator installation and dependency installation all succeeded; step 6, “Host driver and board-model regressions (AXI-Lite isolation already verified separately)”, is still running; artifact upload has not started. GitHub job-log download returned 404/BlobNotFound while the job is active, so no fresh test output or terminal summary is available yet.
- RTL uncovered groups 3.1, 3.2 and 4 remain completed successfully in this run. Do not infer board-functional pass from elapsed time or setup success.
- No new RTL/verification source changes were made during this continuation. The only pending action is to poll the same job/run to terminal, then inspect its log and uploaded artifact. Do not dispatch duplicate workflows, cancel the job, or bypass skipped dependency-dependent tests.
- Existing PPA blocker and manufacturer-handoff NOT READY status from the prior 2026-11-26 checkpoint remain unchanged. No physical signoff, measured silicon/board power, hardware qualification, tapeout readiness, paid spend or production readiness is claimed.


## Board-functional verification result — 2026-11-26 05:59 UTC (Asia/Dhaka)

- Workflow run [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), attempt 3, tested source SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`. The board-functional job `139677036786` is now terminal with conclusion **CANCELLED**. It ran from 03:41:51 UTC to 04:27:03 UTC (about 45 minutes); GitHub log ends with “The operation was canceled.” Do not classify this as a pass or infer a specific cancellation cause beyond the recorded cancellation.
- The board-model pytest log shows the selected regression progressing through 82%. All displayed executed tests before cancellation are marked PASSED; five Tiny-Qwen/Qwen3 cases were SKIPPED because `torch` is not installed. The run ended before pytest emitted a terminal summary, so no complete pass/fail/skip totals can be claimed and the board-functional gate remains **NOT PASSED / INCOMPLETE**.
- Board log artifact uploaded successfully: [sunnyone-board-functional-log, artifact 15086344970](https://github.com/shamiursunny/openTPU/actions/runs/45693821197/artifacts/15086344970). This preserves partial logs only, not a complete test report.
- In the same run, RTL uncovered groups 3.1, 3.2 and 4 all completed SUCCESS. Group 3.2 log explicitly reports **33 passed, 184 deselected**; groups 3.1 and 4 completed successfully with their existing scoped selectors (8 and 5 selected passes respectively). These scoped selector counts are not a consolidated unique-test total.
- Current branch ref verified at `663433351457c32b0f059bf094fa2b628ff4ea9d`; protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. GitHub compare reports 700 commits ahead, 0 behind. No RTL or verification source changes were made in this continuation; only project records are being updated.
- Next action: inspect workflow configuration and board-test execution cost/runtime to determine a safe, evidence-preserving way to complete the full board-functional gate. Do not weaken, deselect, or skip required tests; do not claim success from partial progress. Keep zero-spend. Manufacturer handoff remains **NOT READY**; PPA/physical signoff and hardware qualification blockers remain open.


## Timeout correction and retry launched — 2026-11-26 06:02 UTC (Asia/Dhaka)

- Root cause of incomplete board gate is now narrowed to the workflow's explicit `timeout-minutes: 45`: job `139677036786` ran approximately 45m 12s and GitHub recorded cancellation before pytest's final summary. This is a workflow time-budget limitation, not an observed test assertion failure.
- Updated only `.github/workflows/sunnyone-rtl-functional.yml`: board-functional `timeout-minutes` increased from 45 to 90. Test command, selector, test code and assertions are unchanged. RTL uncovered job timeout remains 90.
- The workflow push automatically queued new run [45765362426](https://github.com/shamiursunny/openTPU/actions/runs/45765362426), run number 121, attempt 1, event push, tested workflow/source commit `455a03232c90b8e631a5add6cd7bebff4afdccad`. At checkpoint time it is **QUEUED**; no result is claimed. Poll this exact run. Its RTL groups will run first due to the workflow dependency graph; board-functional starts only after they succeed.
- The previous run's five Tiny-Qwen/Qwen3 skips remain documented as dependency-related (`torch` absent); do not mislabel them as passes. No test has been removed or weakened.
- Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Maintain zero-spend. Manufacturer handoff remains **NOT READY** pending full regression and outstanding physical/hardware gates.


## Qwen verification feasibility and checkpoint — 2026-11-26 06:15 UTC (Asia/Dhaka)

- Repository inspection confirms an existing Qwen verification foundation. `tests/test_qwen35.py` exercises tiny Qwen3.5 configurations against Hugging Face reference logits and the software/ISA model path, including FP4 emulation and board configuration. Its module uses `pytest.importorskip("torch")` and `pytest.importorskip("transformers")`; therefore missing dependencies can turn the module into a skip rather than a pass.
- `tests/test_models_on_board_rtl.py` is the direct real-checkpoint RTL gate. It targets Qwen3-0.6B and Qwen3.5-0.8B (alongside LFM2.5), uses FP4 weights and an INT8 LM head, exercises MCOLS=2 and 4, and compares RTL logits plus DRAM state against the ISA execution. It is marked slow and requires `--runslow`. If a model directory is absent it explicitly skips that model case.
- The current `.github/workflows/sunnyone-rtl-functional.yml` board-functional command runs `tests/test_board.py`; it does **not** invoke `tests/test_models_on_board_rtl.py`. Thus the current board-functional regression is not evidence of end-to-end Qwen inference on RTL.
- A dedicated Qwen workflow is the next recommended engineering item, but has **not yet been added or run**. Before adding it, inspect dependency pins, model-download/licensing/source integrity, checkpoint storage and runner disk/RAM/runtime. The gate must distinguish required real-checkpoint tests from optional tests; fail clearly if required checkpoint material is unavailable rather than silently green-skipping. Keep any download/cache public, reproducible and zero-spend; do not commit large model weights or secrets.
- Do not call simulated RTL execution physical-hardware validation. Actual FPGA/board Qwen execution still requires the supported board, bitstream, driver, host interface and real measurements. No zero-bug guarantee is possible; acceptance requires layered regressions and recorded evidence.
- Latest poll of workflow run [45765362426](https://github.com/shamiursunny/openTPU/actions/runs/45765362426), run 121, attempt 1, tested SHA `455a03232c90b8e631a5add6cd7bebff4afdccad`: group 3.1 job `139724851662` was **IN_PROGRESS**; groups 3.2 (`139724852016`) and 4 (`139724852036`) were **QUEUED**; run-level status still **QUEUED**, no conclusion and no artifacts yet. Do not claim completion; poll this exact run.
- Protected `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`; working branch comparison last confirmed 707 ahead / 0 behind. Manufacturer handoff remains **NOT READY**. No RTL tests or assertions were weakened.


## Qwen real-checkpoint RTL gate added — 2026-11-26

- Added `.github/workflows/sunnyone-qwen-real-rtl.yml` in commit `d68e7aa3ff651ed03fc58537c93d4d2ab1913844`. This is a separate `workflow_dispatch`-only gate; it does not rerun the already-passed general RTL groups 3.1, 3.2 or 4.
- The gate downloads the official Apache-2.0 `Qwen/Qwen3-0.6B` checkpoint at revision `c1899de289a04d12100db370d81485cdf75e47ca` and `Qwen/Qwen3.5-0.8B` at revision `2b48083dfa97c3cbf0220cf1a5e6cffe0a511157`, verifies the downloaded repository contents, checks model types and safetensors presence, and uses CPU-only PyTorch plus safetensors.
- It runs only `tests/test_models_on_board_rtl.py` cases selected by `-k "qwen3 or qwen35"` with `--runslow`: Qwen3 and Qwen3.5 real-checkpoint RTL cases across MCOLS=2 and MCOLS=4. LFM2 cases are intentionally excluded from this Qwen-only gate.
- **Status: workflow added and read-back verified; NOT YET DISPATCHED; no Qwen RTL result claimed.** A green result must show the selected real-checkpoint cases actually executed and passed. This workflow is not a physical-board validation.
- The general RTL workflow run #121 (run ID `45765362426`) was still active at the latest check: group 3.1 in progress, groups 3.2 and 4 queued. The connected GitHub action set did not expose a cancel-run operation, so cancellation could not be sent from this session. Do not describe it as cancelled. User can cancel it from the GitHub Actions run page if it remains active.
- Previously completed RTL group 3.1, 3.2 and 4 results remain historical evidence; do not repeat those tests merely to reconfirm them.
- Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Branch comparison after adding the workflow: 711 ahead, 0 behind. Manufacturer handoff remains NOT READY.


## User-authorised continuation checkpoint — 2026-11-26 12:35 Asia/Dhaka

### Live repository state
- Repository: `shamiursunny/openTPU`.
- Active working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Branch HEAD before this continuity-only update: `0470472f4cc87a998c063a34c362fcde5f416f0a` (commit message: "Record dedicated Qwen real-checkpoint RTL gate").
- Protected `main` independently verified at `d84db55712aba0d40811d7762cb052f05d55b7e5`. Do not modify, merge into, or push project work to `main`.
- All project changes remain on the active feature branch. Zero-spend rule remains in force; no hardware, paid cloud, licences, or services may be purchased without explicit user approval.

### User's explicit no-rerun instruction
The user personally cancelled workflow run [45765362426](https://github.com/shamiursunny/openTPU/actions/runs/45765362426) and specifically confirmed that groups **3.1, 3.2 and 4 had already passed earlier**. GitHub now reports the run terminal as `completed / cancelled`; its jobs 139724851662 (3.1), 139724852016 (3.2), 139724852036 (4), and 139734601872 (board-functional) are cancelled. These cancellations are not failures and do not erase prior successful evidence. **Never rerun groups 3.1, 3.2 or 4 merely to reconfirm them.** Also preserve accepted historical groups 1 and 2; do not rerun those without a specific source-change/regression reason.

Accepted earlier successful evidence from workflow run [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), attempt 3, tested source SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`:
- Group 3.1 job 139677037811: SUCCESS, 8 passed.
- Group 3.2 job 139677071195: SUCCESS, 33 passed.
- Group 4 job 139677038294: SUCCESS, 5 passed.
- Historical groups 1 and 2 remain accepted from their previously recorded unchanged-source runs (12 and 24 selected passes respectively).
These are scoped selector results; do not add them into a claim of unique lifetime tests without overlap reconciliation.

### Board-functional status
- Board-functional job 139677036786 in run 45693821197 was CANCELLED at approximately 45 minutes before pytest emitted a terminal summary. Its partial log showed tests passing through approximately 82%, with five Qwen/PyTorch-dependent cases skipped because torch was absent in that job. This is **NOT a board-functional PASS**.
- The board timeout was subsequently increased to 90 minutes in `.github/workflows/sunnyone-rtl-functional.yml`. The newer run 45765362426 was cancelled by the user while its RTL groups were queued/running; its board job did not produce a new qualifying result.
- Do not restart the whole general RTL workflow just to get to board-functional, because that would repeat already-passed groups. If board-functional is next pursued, create/use a board-only workflow/job that executes the exact board selector without depending on or rerunning the passed RTL matrix. Preserve the test selector and assertions; do not weaken or skip required tests. Record a complete terminal pytest summary.

### Dedicated Qwen real-checkpoint gate
- Workflow file `.github/workflows/sunnyone-qwen-real-rtl.yml` exists and was read back from the active branch (blob SHA `eb48070c1c371dbc6232631445383fa21c48c812`).
- Test file `tests/test_models_on_board_rtl.py` read-back SHA: `eb9e0af47ffcf372ae98b794d2ee902a4a26ef67`.
- Workflow is `workflow_dispatch` only and has **NOT YET BEEN DISPATCHED**. No Qwen real-checkpoint RTL pass is claimed.
- It pins official Qwen3-0.6B revision `c1899de289a04d12100db370d81485cdf75e47ca` and Qwen3.5-0.8B revision `2b48083dfa97c3cbf0220cf1a5e6cffe0a511157`, checks downloaded checkpoint contents/model type/safetensors, installs CPU-only PyTorch 2.15.0 (valid for Python 3.12; PyTorch 2.15 supports Python >=3.11), and selects only Qwen3/Qwen3.5 cases with `--runslow` and `-k "qwen3 or qwen35"` for MCOLS=2 and 4. LFM2 cases are excluded.
- This is simulated RTL-vs-ISA bit-exact verification using real model checkpoints, not physical FPGA/board validation. Physical Qwen inference still requires actual supported hardware, bitstream, driver and measurements.
- The available connected GitHub actions do not expose a workflow-dispatch action. Do not claim it was dispatched. Next action is to manually dispatch this specific Qwen workflow from GitHub Actions when execution is available, then inspect its exact terminal log/artifact. Do not dispatch the general RTL workflow.
- Before dispatch, confirm the current branch HEAD still contains the above workflow and test-file revisions. If either changed, inspect the diff first.

### Immediate continuation order
1. Resume by reading this section, then the latest master task register and chronological tracker.
2. Re-check live feature-branch HEAD and protected `main`; inspect latest workflow status. Never trust a stale run state.
3. Preserve groups 1, 2, 3.1, 3.2 and 4 as already passed; no duplicate reruns.
4. Complete the dedicated Qwen real-checkpoint RTL gate (manual dispatch required) and inspect full pytest summary/artifact. If it fails, diagnose the actual error and make a minimal evidence-based correction.
5. Complete board-functional using a board-only execution path, not the general RTL matrix. Do not count the cancelled partial run as a pass.
6. Continue remaining consolidated regression, shared-DIMM integration, formal/property coverage, CDC/RDC, lint, PPA/physical implementation, production PCIe/DMA and DDR controller/PHY, DFT, electrical board validation, hardware performance/power/thermal, silicon and commercial feasibility gates.
7. Investigate the already-recorded Nangate45/OpenROAD PDN/placement failure before any PPA retry; do not repeat the unchanged failing run.
8. Keep manufacturer handoff **NOT READY** until all applicable release gates have actual evidence. Never claim production/tapeout readiness or zero bugs from simulation-only evidence.
9. After each meaningful task, update this resume guide, `PROJECT_TRACKER.md`, and `SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md` with exact source SHA, run/job IDs, terminal counts, limitations and next action. Re-fetch all three after writes to verify.
10. In any new chat/tab, the user can simply say **"continue and complete the remaining tasks"**. Start from this checkpoint and current live GitHub state; do not ask the user to repeat the no-rerun instruction.



## Board-only regression isolation update — 2026-11-26 (Asia/Dhaka)

- To complete the incomplete board-functional gate without repeating already-passed RTL groups, added `.github/workflows/sunnyone-board-functional-only.yml` in commit `aedda576e489a297f9452c1cd799072014b565b0`.
- The workflow is deliberately independent of the general RTL matrix. It runs only the existing board-functional selector: `pytest -vv -ra tests/test_board.py -k "not axil_iso_resets_apart"`. No test code, assertions or selector were changed. Timeout is 90 minutes. It uploads the complete log even on failure/cancellation.
- GitHub Actions automatically started board-only run [45769498674](https://github.com/shamiursunny/openTPU/actions/runs/45769498674), tested commit `aedda576e489a297f9452c1cd799072014b565b0`. Job `139738454299` is **IN_PROGRESS**. At the latest poll checkout and Python setup succeeded; Verilator installation was running; pytest had not started. No board test result is claimed yet.
- This run does not include groups 3.1, 3.2 or 4 and must not be described as rerunning them. Do not launch another board-only run while this one is active.
- Dedicated Qwen real-checkpoint workflow remains separate and undispatched. Do not trigger the general RTL matrix.
- Current branch HEAD at the time of this note: `aedda576e489a297f9452c1cd799072014b565b0`; protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Next action: poll only run 45769498674 / job 139738454299 to terminal; inspect the full pytest summary and uploaded artifact. If it passes, record exact counts; if it fails, diagnose without weakening tests. Then proceed to the Qwen real-checkpoint gate and remaining unclosed engineering gates.


## Evidence update — 2026-11-26

- Board-only regression run 45769498674 failed under Verilator 5.020 with 133 failed, 65 passed, 8 skipped and 1 deselected. The compile failure is the Verilator 5.020 parser rejecting the function-call bit-select at rtl/mxu/otpu_mxu.sv:2781. This is not accepted as an RTL correctness failure or as a pass.
- Board-only workflow now pins Verilator 5.044. Retry run 45784404427 / job 139787424587 is still in progress at tool build; no board-functional qualification is available yet.
- The Qwen real-checkpoint workflow's invalid PyTorch pin was corrected to CPU torch 2.11.0 and huggingface_hub 2.3.0. It remains undispatched; no real-checkpoint RTL qualification is available.
- Historical RTL groups 3.1, 3.2 and 4 remain accepted from their earlier successful run and were not repeated. Protected main remains unchanged.
- Manufacturer handoff status: NOT READY. No production PCIe endpoint/PHY, complete DMA/IOMMU, DDR controller/PHY/ECC datapath, full formal/CDC/RDC signoff, foundry PDK, DFT, physical signoff, board electrical validation, silicon, measured power/performance/thermal, or demand-backed commercial qualification is established by this work.


## Cross-chat checkpoint status — 2026-11-26

For any new chat/tab, resume from docs/sunnyone/SUNNYONE_AI-X_AUTHORITATIVE_CONTINUATION_BASELINE_A1.12.11.16.53.md and docs/sunnyone/PROJECT_TRACKER.md when the user says “continue and complete the remaining tasks”.

At this checkpoint, board-only run 45784404427 / job 139787424587 has successfully built pinned Verilator 5.044 and installed dependencies; board pytest is still in progress. Do not claim a pass until terminal pytest results and artifacts are inspected. The dedicated Qwen real-checkpoint workflow is corrected but undispatched. Historical RTL groups 3.1, 3.2 and 4 remain passed and must not be rerun merely for confirmation. Protected main remains unchanged. Manufacturer handoff status remains NOT READY.


## Board-functional regression completed — 2026-11-26 (Asia/Dhaka)

- Live branch before this documentation update: `sunnyone/commercial-profitability-architecture-2026-11-23`, HEAD `6bc0c781d3c58c47004f0ea35bd050c4fb8c0a66`. Protected `main` independently verified at `d84db55712aba0d40811d7762cb052f05d55b7e5`; unchanged. All updates remain on the feature branch.
- Board-only workflow run [45784404427](https://github.com/shamiursunny/openTPU/actions/runs/45784404427), job `139787424587`, tested source SHA `74ee09d865633e8d8f8cc3edaaf5cb460bf576cc`. Terminal conclusion: SUCCESS. Pinned Verilator 5.044 build and dependency installation succeeded; isolated board-functional pytest completed; log artifact upload succeeded.
- Exact pytest summary from the job log: **198 passed, 8 skipped, 1 deselected in 4158.05s (1:09:18)**. All eight skips were due to missing PyTorch (`torch` not installed), affecting torch-dependent tiny-Qwen board-model tests. The deselected test is `axil_iso_resets_apart`, excluded by the workflow's existing selector. This is a successful scoped board-model regression, not a complete test of the deselected or skipped cases and not physical-board validation.
- Artifact: `sunnyone-board-functional-only-log`, artifact ID `15104009648`, SHA-256 `fd8901eefabd4f990826abe072ca0f505f92919c1f8a9b4c59fda0915089a00a`; [download from workflow run](https://github.com/shamiursunny/openTPU/actions/runs/45784404427/artifacts/15104009648).
- Do not repeat RTL groups 3.1, 3.2 or 4; their earlier successful evidence remains accepted. Do not rerun cancelled general matrix run `45765362426`. No broad RTL matrix was launched.
- Dedicated Qwen real-checkpoint workflow `.github/workflows/sunnyone-qwen-real-rtl.yml` remains workflow_dispatch-only and undispatched; no real-checkpoint Qwen RTL result is claimed. The available GitHub integration in this session exposes no workflow-dispatch action, so manual dispatch remains outstanding. Board regression's eight PyTorch-related skips do not substitute for that gate.
- Remaining: dispatch and inspect Qwen real-checkpoint RTL gate; close the skipped/deselected test gaps deliberately; continue consolidated regression and four-DIMM shared-DIMM adversarial verification; formal properties; CDC/RDC; full-chip lint and configuration checks; WG8 PPA/physical implementation; production PCIe/DMA/IOMMU and DDR controller/PHY/ECC; DFT, board/silicon electrical and thermal/power/performance qualification; and evidence-backed commercial qualification.
- Manufacturer handoff remains **NOT READY**. This board-model simulation does not establish production PCIe, DMA, DDR PHY, formal/CDC/RDC, foundry PDK, physical signoff, silicon, measured power/performance/thermal or commercial qualification.


## Isolated AXI-Lite reset coverage queued — 2026-11-26 (Asia/Dhaka)

- The completed board-only run excluded exactly one test by its existing selector: `test_axil_iso_resets_apart`. Rather than rerunning the 198-pass board suite, added a narrow workflow `.github/workflows/sunnyone-axil-iso-reset-only.yml` to execute only this test, with pinned Verilator 5.044 and the same project/test setup. The test exercises `otpu_axil_iso` with independent master/slave resets, two seeds, and both isolation-enabled and bypass modes; it checks that responses do not cross a master reset and that each access receives the expected response.
- Workflow commit: `9af352cb36ad5599fd839cf12c8798ff8000ba92`; file read-back verified (blob `27b06f096ad0e368f1c758e4cf6aed5a5e58f054`). The workflow is configured for manual dispatch and a branch-scoped push trigger limited to its own file and relevant test/RTL dependencies. Commit status currently exposes no status checks; no run ID or test result is confirmed yet. Do not claim a pass until the actual Actions run and full log are inspected.
- The board-only regression evidence remains 198 passed, 8 skipped (all require missing PyTorch), 1 deselected. This new workflow is deliberately isolated and does not repeat completed RTL groups or the board suite.
- Qwen real-checkpoint workflow remains manual-dispatch-only and undispatched. The connected GitHub action interface has no workflow-dispatch operation; no Qwen checkpoint result is claimed.
- Current branch HEAD at this note: `9af352cb36ad5599fd839cf12c8798ff8000ba92`. Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`, unchanged. Manufacturer handoff remains **NOT READY**.


## Live continuation checkpoint — 2026-11-26 (Asia/Dhaka; latest verified branch SHA 6732bc47a7c5fd1b7c441e69e40f27a59c15a65a)

- AXI-Lite isolated test run [45806586835](https://github.com/shamiursunny/openTPU/actions/runs/45806586835), job 139863351015: checkout/Python setup passed; Verilator 5.044 build still IN_PROGRESS at latest poll; pytest not yet started.
- Qwen real-checkpoint workflow retains manual dispatch and now also has a tightly scoped push trigger for this feature branch and only its workflow/test/package/RTL/simulator/config dependencies. This was necessary because the available GitHub integration has no workflow-dispatch action. Commit 6732bc47a7c5fd1b7c441e69e40f27a59c15a65a triggered run [45807130675](https://github.com/shamiursunny/openTPU/actions/runs/45807130675), job 139865226090. Latest poll: checkout/Python setup passed; Verilator build IN_PROGRESS; dependencies, checkpoint downloads and tests not started. No test result claimed.
- Both CI jobs were simultaneously building Verilator at the last poll. Do not start further CI runs until they finish.
- Audited historical exact-SHA results: ASIC/target configuration 45598047221 SUCCESS (includes four-DIMM WG8 AXI top lint and simulation, address-map simulation, and four-DIMM HMUX contention); HMUX standalone 45598047225 SUCCESS; full-chip lint 45598047313 SUCCESS; 32-GiB address-map formal proof 45598047300 SUCCESS; RTL subsystem matrix 45598047338 SUCCESS across all listed jobs; PCIe Gen2 XDMA bridge simulation 45598047330 SUCCESS. These are bounded digital verification results, not production PCIe/DDR hardware, full-chip formal or physical signoff.
- WG8 PPA run 45545698546 failed at ORFS floorplan PDN/check_placement. Artifact 14997807086 shows process exit 247, ~15.7 GB peak memory and repeated M6-M7 via insertion warnings. Root cause is unconfirmed; PPA remains unqualified. Preserve logs and diagnose before any rerun; do not suppress PDN/placement checks.
- Preserve restrictions: do not rerun RTL groups 3.1, 3.2 or 4; do not rerun cancelled run 45765362426; no broad RTL matrix. Protected main remains d84db55712aba0d40811d7762cb052f05d55b7e5. All work on feature branch.
- Board-only run 45784404427 remains 198 passed, 8 PyTorch-dependent skips, 1 intentionally deselected. AXI-Lite isolated test is meant to cover the deselected case; Qwen checkpoint test is intended to exercise the model-dependent gate. No results from either new workflow until terminal logs are inspected.
- Outstanding: full adversarial DIMM protocol coverage beyond existing bounded four-DIMM contention tests; broader formal properties; CDC/RDC; WG8 PPA resource/root-cause and physical signoff; production PCIe endpoint/PHY and DMA/IOMMU; DDR controller/PHY/ECC; DFT; foundry PDK/macros; board/silicon qualification; measured power/performance/thermal; commercial/manufacturer qualification. Manufacturer handoff remains **NOT READY**.


### WG8 timing evidence from failed research PPA artifact — 2026-11-26
- Inspection of archived `2_floorplan_final.rpt` from PPA run 45545698546 shows core-clock floorplan WNS = **-10.43 ns**, TNS = **-91.46 ns**, and reported core-clock minimum period = **12.93 ns** (Fmax **77.31 MHz**). The project candidate SDC's 400 MHz / 2.5 ns target is therefore not met at this floorplan stage. This is pre-route research-flow timing evidence using the Nangate45/fakeram macro model, not final signoff STA or a silicon frequency measurement. No 400 MHz claim is permitted. This timing shortfall is an independent blocker from the later ORFS floorplan-PDN/check_placement failure.


### AXI-Lite independent reset test completed — 2026-11-26
- Dedicated run [45806586835](https://github.com/shamiursunny/openTPU/actions/runs/45806586835), job `139863351015`, source SHA `9af352cb36ad5599fd839cf12c8798ff8000ba92`: **SUCCESS**. Pinned Verilator 5.044 build and project/test dependency install succeeded. Exact pytest result: **1 passed, 206 deselected in 17.32s**; selected test `tests/test_board.py::test_axil_iso_resets_apart` passed. The test covers two seeds and both isolation-enabled and bypass cases for independent AXI-Lite master/slave resets. This closes the one deliberately deselected test from board-only run 45784404427; it does not mean the other 206 tests were rerun.
- Artifact `sunnyone-axil-iso-reset-only-log`, ID `15109822525`, SHA-256 `797304cbd415af26b0d2f6b624e4045e4a3ad75f70df37cd4ba104a904695a22`; [download from run](https://github.com/shamiursunny/openTPU/actions/runs/45806586835/artifacts/15109822525).
- Combined with board-only run 45784404427, the explicitly selected board test coverage now includes 198 passed + the isolated AXI-Lite reset test passed; the eight PyTorch-dependent tests remain gated by the active Qwen real-checkpoint run 45807130675 and are not yet closed.


### WG8 PPA retry resource guard prepared — 2026-11-26
- Updated `.github/workflows/sunnyone-asic-wg8-ppa.yml` to export `ORFS_CPUS=2` before the ORFS flow. `tools/asic/flow.py` explicitly maps `ORFS_CPUS` to both ORFS `NUM_CORES` and Docker `--cpus`. The prior failed run peaked at approximately 15.7 GB RSS and terminated at `check_placement`; the two-CPU limit is a resource-conscious diagnostic retry setting, not proof that memory pressure caused the failure. PDN/placement checks remain enabled and unchanged.
- Workflow update commit: `bf13801352dd7b684119b14145504314212fbb5c`. The PPA workflow intentionally excludes its own file from push triggers, so this change did not launch a new PPA run. No retry has been dispatched. Given the floorplan timing result (77.31 MHz vs 400 MHz target), further RTL timing optimization is required before treating PPA as a qualification gate.


### Clarification: eight PyTorch-dependent board skips are a separate gate
- Inspection of artifact `15104009648` confirms the eight skips are specifically: three `test_tiny_qwen3_on_board_model` format cases; two `test_tiny_qwen3_two_slices_on_board_model` cases; one `test_tiny_qwen3_generate_on_board_model`; and two `test_tiny_models_four_slices_wg_on_board_model` cases (Qwen3/Qwen3.5). All skip because `torch` is unavailable; these tests also call `pytest.importorskip("transformers")`.
- The currently active Qwen real-checkpoint workflow selects `tests/test_models_on_board_rtl.py -k "qwen3 or qwen35"`, a different test module and selection. Its eventual pass must **not** be counted as closing these eight board-test skips. A separate targeted run must install compatible CPU PyTorch and Transformers, then execute only the eight named board-test cases. Keep that as a separate follow-up gate; do not rerun the full board suite.


### Qwen checkpoint verification retry and eight tiny-model tests — 2026-11-26
- First Qwen run [45807130675](https://github.com/shamiursunny/openTPU/actions/runs/45807130675), job 139865226090, failed at `hf cache verify` after both pinned model downloads succeeded. The failure was a verifier invocation issue: `--fail-on-extra-files` treated Hugging Face's own `.cache/huggingface` metadata/lock files inside each `--local-dir` as extra model content. It was not a missing checkpoint or RTL failure.
- Corrected the checkpoint verification step to retain `--fail-on-missing-files` but omit `--fail-on-extra-files`; retained explicit model architecture, safetensors presence and total-size checks. The download/verification output is now tee'd to the artifact log. Commit `815399df0e4f8e36f3bbe80af474a3bcb5dbbf40` triggered retry run [45808346935](https://github.com/shamiursunny/openTPU/actions/runs/45808346935), job 139869385724. Latest poll: Verilator 5.044 build IN_PROGRESS; later steps not started. This run does not yet include the eight skipped board-test cases.
- A further scoped workflow update pins `transformers==4.57.3`, verifies the Qwen3 Transformers classes, and adds a separate pytest selection for exactly the eight previously skipped tiny board-model cases: `tiny_qwen3_on_board_model` (3 parameter cases), `tiny_qwen3_two_slices_on_board_model` (2), `tiny_qwen3_generate_on_board_model` (1), and `tiny_models_four_slices_wg_on_board_model` (2). It does not rerun the full board suite. Commit `b02f7de514ea1db1843864330da9d6831676a9f7` triggered queued run [45808406729](https://github.com/shamiursunny/openTPU/actions/runs/45808406729); no job has started yet at latest poll. The earlier retry is still running; the new run is queued by the workflow concurrency group.
- Do not count the Qwen real-checkpoint test selection as closing the eight tiny-model tests unless the later run's separate eight-test step completes successfully. Neither Qwen run has a terminal pass yet.


### Qwen tiny-model dependency compatibility correction — 2026-11-26
- Before the expanded tiny-model run could reach dependency installation, compatibility was rechecked: Transformers v5 requires Hugging Face Hub >=1.0.0, while the workflow pins Hub 2.3.0. Therefore the initial proposed Transformers 4.57.3 pin was incompatible and has been replaced before execution with `transformers==5.24.1`, the current stable v5 line documented by Hugging Face; the Qwen3Config/Qwen3ForCausalLM classes are present in the v5 documentation. CPU PyTorch 2.11.0 meets the documented PyTorch >=2.6 requirement.
- Workflow correction commit: `bddf9708657766951e5c0d204ef474d742e53418`. This triggers a new run and supersedes the queued/running earlier revision through the workflow's same-ref concurrency group. Do not count the earlier run as validating the tiny-model tests. Latest workflow source now pins Hub 2.3.0 + Transformers 5.24.1.


### Current Qwen comprehensive retry — 2026-11-26
- Finalized workflow revision commit `bddf9708657766951e5c0d204ef474d742e53418` pins `transformers==5.24.1` alongside CPU `torch==2.11.0` and `huggingface_hub==2.3.0`; this avoids the v4.x Hub<1.0 dependency conflict and is compatible with the Qwen3 classes used by the eight tiny-model tests. The workflow runs the real pinned Qwen3/Qwen3.5 RTL cases and then separately runs the exact eight previously skipped tiny board-model cases.
- Current run [45808551468](https://github.com/shamiursunny/openTPU/actions/runs/45808551468), job `139870207686`, source SHA `bddf9708657766951e5c0d204ef474d742e53418`: IN_PROGRESS; checkout and Python setup passed; pinned Verilator 5.044 build is running. No dependency install, model download or pytest result yet.
- Earlier run 45808346935 and queued run 45808406729 were cancelled by same-workflow supersession before their test stages. The original run 45807130675 remains a recorded failure at the false-positive extra-cache-file verification check; it did successfully download both checkpoint repositories.
