# SUNNYONE AI-X — Authoritative Continuation Baseline

**Baseline revision:** A1.12.11.16.53  
**Date:** 2026-11-24  
**Purpose:** Single durable hand-off for future engineering sessions. Read this file first, then the linked architecture, integration and project-tracker documents.  
**Status:** Engineering in progress. This is not a production, tapeout or silicon-readiness declaration.

## 1. Source of truth and update discipline

- Repository: `shamiursunny/openTPU`.
- Active work branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Baseline commit at creation: `c9559974b3e8b323e491a8d35e81be90609bcd74`.
- Protected working rule: do not modify `main`; all project changes go to the active feature branch unless the owner explicitly changes this instruction.
- Primary tracker: [PROJECT_TRACKER.md](PROJECT_TRACKER.md). Append a dated, numbered section after each meaningful engineering stage. Never erase historical findings; append explicit corrections when a previous conclusion was wrong.
- Architecture: [WG8 ASIC architecture candidate](SUNNYONE_AI-X_WG8_ASIC_ARCHITECTURE_A1.12.11.16.46.md), content revision A1.12.11.16.48.
- Memory integration: [WG8 DDR4 integration boundary](SUNNYONE_AI-X_WG8_DDR4_INTEGRATION_A1.12.11.16.50.md), content revision A1.12.11.16.52.
- Keep filenames stable unless there is a compelling repository convention reason; update the revision inside the document and tracker.
- This baseline is a navigational and decision record, not a replacement for detailed RTL specifications, source code, tests or CI logs.

## 2. Mission and commercial decision rule

Build a genuine, programmable, commercially useful AI inference accelerator/ASIC from Bangladesh, using a rigorous evidence-led, zero-spend development path.

Optimise for risk-adjusted long-term net profit and fastest realistic investment recovery while delivering reliable, competitive useful inference. Do not optimise peak TOPS, clock, RAM capacity or watts in isolation. Select power, memory capacity and performance from measured workload throughput, full-system total cost of ownership (TCO), reliability, customer demand and incremental contribution margin. The former 30 W total-system ceiling is retired; no replacement wattage ceiling has been approved.

Zero-spend constraint: do not purchase hardware, paid cloud, software licences, foundry access, IP, services or subscriptions without explicit user approval. Prefer existing open-source RTL, free tools and GitHub Actions where available. Do not assume free CI capacity is available indefinitely.

## 3. Current architecture decision

**Primary logical V1 candidate: WG8 host-controlled programmable AI accelerator, one compute slice, 32 GiB logical memory map.**

| Parameter | Current candidate |
|---|---:|
| Slices | 1 |
| D / MCOLS / WG | 128 / 8 / 8 |
| NCH / CB | 8 / 128 bytes |
| ASIC byte address AW | 35 bits |
| Native channel beat address CAW | 25 bits |
| Word address WA | 33 bits |
| Logical DRAM map | 32 GiB |
| DIMM/controller ports | 4 × 8 GiB |
| Channels per DIMM | 2 × 4 GiB |
| AXI DIMM data width | 512 bits |
| AXI DIMM interface address width | 34 bits; bit 33 unused and guarded |
| ACT blocks / rows | 128 / 16 |
| TMEM / IMEM | 128K / 32K words |
| FIFO depth / WIN | 2,048 / 32 |
| LANES / ULANES | 8 / 8 |
| MXU_IMPL / MXU_CL / MXU_E / MXU_QD | 2 / 16 / 8 / 4 |
| VPU_CL / VPU_CNS | 2 / 3 |
| TMEM implementation candidate | one-copy 1RW1R macro (TMEM_IMPL=3), core clock only |

ASIC-specific deviations from FPGA reference: TMEM_PMP=0, MXU_PUMP=0, XPOST=0. The external memory adapter must provide the eight-channel W-port read return. The design uses a host-controlled accelerator; V1 does not include an on-chip RISC-V CPU or boot ROM.

### Address-width correction — do not regress this conclusion

The BCU1525-WG8 FPGA reference uses AW=36 and a separate DRAM_BYTES=32 GiB capacity limit. AW=36 does not itself imply a 64-GiB physical map. The ASIC candidate's AW=35/CAW=25 is a deliberate minimum-width implementation for its 32-GiB map, not a fix for a proven AW36 capacity defect. Existing DIMM AXI interfaces remain 34 bits wide for RTL compatibility; bit 33 is unused and is guarded against assertion. Preserve the correction recorded in tracker sections 56–57.

## 4. Integration implemented in RTL (not yet fully qualified)

- `rtl/asic/otpu_asic_top.sv`: compute-block boundary; it is not a complete ASIC top.
- `rtl/asic/otpu_asic_chip_top.sv`: WG8 compute/control integration with AXI4-Lite v5 control and memory-adapter contract.
- `rtl/asic/otpu_asic_mem_top.sv`: native memory adapter and eight native channels.
- `rtl/asic/otpu_asic_wg8_ddr4_top.sv`: four DIMM-facing 512-bit AXI4 interfaces; eight `otpu_hbm_ch` bridges and four `otpu_mig_pair` adapters.
- Four instances of existing `rtl/boards/bcu1525/otpu_mig_hmux.sv` converge one host 512-bit AXI master and the accelerator pair on each DIMM's shared AXI path. The mux's write-owner FIFO and response routing are reused. This is a shared memory-path arbitration boundary, not a PCIe DMA implementation.
- Per-DIMM reset synchronisers release the pair and channel bridges in staged order. This is not full CDC/RDC qualification.
- AXI DIMM transfers use 64-byte beats (AxSIZE=6), INCR bursts, and the pair logic interleaves channel halves at 4-KiB boundaries.
- Memory calibration/error/ECC-DED status is integrated into fail-closed compute-control gating. The actual controller, PHY, calibration engine and ECC datapath are not implemented.
- ASIC control review corrected A_RD accounting so writes are not counted as reads, rejects LOAD during active compute, and gates STOP-to-RUN on drained writes. Regression additions exist; current CI result must be checked before claiming qualification.

Host address inputs at the current mux boundary are DIMM-local. A future DMA/address-translation block must map card-global addresses to DIMM/channel addresses consistently with the accelerator mapping. IOMMU/aperture enforcement is still absent.

## 5. Platform references and limits

### Primary performance-validation reference: BCU1525 / VU9P

- PCIe Gen3 x16, four DDR4 DIMM channels, WG8 performance reference.
- Repository documents historical on-card model runs and bit-exact simulator checks. Examples reported by repository documentation include Qwen3.6-35B-A3B 88.5%, Qwen3.8-27B 90.6%, and GPT-OSS-20B around 88% of four DIMMs' 76.8 GB/s peak. These are repository-reported FPGA results, not independently remeasured results and not ASIC projections.
- Four 8-GB DDR4-2400 UDIMMs in the reported card configuration; no ECC in that actual card configuration. ECC RDIMM setup is described but not established as validated on-card.
- Vivado/VU9P-capable environment and board purchase are not authorised under zero-spend. Do not imply the user owns this hardware or licence.

### Secondary integration reference: YPCB-00338 / Kintex-7 XC7K480T

- PCIe Gen2 x8 via XDMA; two DDR3-1066 channels (2 GiB each) behind LiteDRAM.
- Useful for simpler PCIe/XDMA-facing AXI integration and historical host-driver/channel-bridge evidence. It is not the WG8 performance target.

### Simulation boundary

Existing Verilator benches can validate RTL protocols, memory models, address routing, stalls, ordering, scoreboards and ISA-level functional equivalence. They cannot validate PCIe serial electrical link training, signal integrity, DDR PHY training, DRAM electrical timing, package, thermal behaviour or actual wall power. Label every result by the exact boundary tested.

## 6. Implemented PCIe Gen2 bridge simulation — limited scope

A `tools/memch_test.py pcie` suite and `.github/workflows/sunnyone-pcie-gen2.yml` were added for the YPCB/XDMA-facing AXI memory bridge. Six scenarios are documented: `gen2xres`, `gen2part`, `gen2full`, `gen2deep128`, `gen2skewx`, `gen2resetshortsh` (verify exact current scenario spelling from source before relying on this list). Historical run 45239360365 reported six scenarios passed. This qualifies the simulated XDMA-facing AXI/memory bridge contract only, not the PCIe serial protocol, hard IP, link training, full board or WG8 DMA path.

A Verilator 5.020 incompatibility was previously observed at `sim/verilator/tb_memch.sv:720` involving a queue assignment pattern. Confirm whether the current branch has corrected it; do not assume the issue is resolved.

## 7. CI and evidence discipline

**At the latest documented checkpoint (tracker section 61), host arbitration and AW35 work still has no verified completed CI result. The latest seven-workflow batch against RTL commit `b0caca731bf81506bae80c5c386de143aab774fd` is queued (run IDs in tracker section 61).** Historical queued jobs are not passes. A successful earlier commit does not qualify later RTL changes.

Known historical run IDs and exact scope are recorded in PROJECT_TRACKER.md. In particular:
- 45239360365: six YPCB PCIe Gen2 AXI bridge scenarios reported passed; limited scope as above.
- 45227797380: historical full-chip lint passed with 19 PINMISSING, 7 LATCH, 3 UNOPTFLAT warnings at that time.
- 45232539687: historical full-chip lint passed with 0 PINMISSING, 7 LATCH, 3 UNOPTFLAT warnings at that time.
- 45230099519 and 45230451124: historical reset-audit reruns passed after a reset-related correction.
- 45235689169: historical virtual DRAM run passed after Verilator-compatible TMEM write predecode.
- Historical Nangate45 PPA is a WG1/research proxy and must not be presented as WG8 PPA or foundry signoff.

Before every engineering decision that depends on test status:
1. Inspect current feature-branch HEAD and compare it with the commit tested by each workflow run.
2. List active, queued, cancelled, failed and completed workflow runs; inspect job conclusions and logs.
3. Record run ID, workflow, tested commit, exact tests/scenarios, counts, warnings, failures and whether the result is current for the relevant source.
4. Reproduce or fix failures on the feature branch; never waive, skip or weaken a failing test just to obtain a green workflow.
5. If the runner queue prevents completion, state that explicitly and continue only with tasks that do not depend on claiming unverified test success.
6. Update this baseline and PROJECT_TRACKER.md after meaningful changes.

## 8. Known historical verification findings (retain as history)

- Earlier reset audit exposed uninitialised/unknown payload state in `otpu_tmem.pa` and `otpu_mxu.mx_key`; later historical reset-audit reruns passed after guarded-payload/assertion treatment. Recheck current RTL and logs.
- An expanded RTL matrix previously exposed 13 TMEM random-traffic parameter failures caused by a Verilator 5.032 internal compiler error in `otpu_tmem.sv`'s `ram_row` function, not reported data mismatches. A predecode workaround was committed; verify current regression coverage.
- Verilator 5.044 pinned build previously failed because runner lacked `FlexLexer.h`; workflow runner setup was changed to Ubuntu 24.04 and `libfl-dev`. Verify the current workflow.
- Sequencer combinational temporary initialisation was added to address lint latches. Historical lint still reported 7 LATCH and 3 UNOPTFLAT warnings at one checkpoint; inspect the current exact lint output.
- Do not treat any of these historical outcomes as proof of current branch health.

## 9. Historical PPA — explicitly not signoff

Archived Nangate45/FreePDK45 and OpenROAD research proxy results are not foundry PDK, silicon, real workload power or commercial PPA. One historical point had setup WNS -0.428 ns against 2.5 ns. Another OpenLayout candidate had global-route WNS +0.156 ns but extracted-parasitic setup WNS -0.05 ns, 31 violating endpoints and TNS -0.54 ns. Neither closes all timing. Historical vectorless power estimates are not workload power. WG8 requires a fresh exact-RTL synthesis/place/route run with documented constraints and realistic SRAM/controller assumptions.

## 10. Prioritised remaining engineering work

### Gate A — establish current reproducible baseline
1. Poll all relevant GitHub Actions runs and jobs; identify which commits they test and collect logs.
2. Verify feature branch HEAD and verify `main` remains unchanged.
3. Re-run/fix AW35 native-memory regression (`tb_asic_aw35`), WG8 wrapper lint, target/config tests, ASIC control tests, full-chip lint, subsystem tests and reset audit.
4. Check `targets/nangate45-wg8.toml` and `tools/asic/flow.py` parameter derivation; prove the PPA flow really elaborates the intended WG8/AW35 configuration.
5. Verify the top's source list includes `otpu_mig_hmux` exactly once and no duplicate module compilation.

### Gate B — adversarial host/accelerator shared-DIMM verification
Build a four-DIMM dual-master testbench, using real RTL mux/pair/bridge modules and independent host/accelerator agents. Cover:
- Simultaneous independent AW/AR and sustained contention on all four DIMMs.
- AW/W owner FIFO correctness, interleaved master write traffic, WLAST and B response ownership.
- AR/R ID routing, reserved host-ID bit handling and ID collision/alias rejection.
- Same-address read/write and overlapping writes from both masters; define and test visibility/ordering semantics rather than assuming coherence.
- Byte strobes and partial writes, read-modify-write interactions and ECC-compatible semantics.
- Backpressure independently on AW, W, B, AR and R; fairness/starvation bounds.
- 4-KiB burst boundaries, maximum burst lengths, unaligned/illegal attributes and address overflow.
- DIMM-local to channel mapping, card-global address translation test vectors and invalid aperture rejection at the future translation boundary.
- Reset during outstanding transactions, error injection, sticky error propagation, calibration loss and recovery.
- Scoreboards must check data, byte lanes, response IDs, transaction completion and no duplication/loss. Do not claim DMA correctness before end-to-end DMA RTL exists.

### Gate C — host/PCIe subsystem
Implement or integrate, with open and legally usable IP only:
- PCIe Gen3 x16 endpoint/PHY or a justified alternative; BAR0 AXI-Lite control.
- DMA descriptor engine, card-global-to-DIMM/channel mapping, bounds checking, IOMMU/aperture protection, MSI-X/interrupt handling and host driver.
- FLR, hot-reset, link-down and error containment.
- End-to-end host-to-memory and memory-to-host DMA tests, then host-to-model execution and ISA comparison.
- Vendor hard IP/PHY may be unavoidable for a real board/ASIC; do not pretend a behavioural model implements the physical interface.

### Gate D — external memory subsystem
- Select a realistic controller architecture and interface contract for eight 128-byte native channels.
- Implement/obtain legally usable DDR controller, PHY, calibration, refresh, training and ECC datapath. Keep IP cost/licensing explicit.
- Verify ECC byte writes for B-port masked writes, SW_FILL read merges, corrected/uncorrectable error handling, DED fail-closed control, refresh, backpressure and reset.
- Verify controller read-return ordering and accepted-write accounting.
- Simulate controller protocol; distinguish it from electrical DDR validation.

### Gate E — correctness and implementation assurance
- Formal properties for AXI protocol, arbitration, owner FIFO, response routing, address bounds, control-state transitions, no lost/duplicated transactions and fail-closed errors.
- Complete CDC/RDC analysis for core, AXI and controller clocks; reset assertion/deassertion, asynchronous faults and recovery.
- DFT/scan/BIST, SRAM test strategy and repair assumptions.
- Reproducible synthesis and PPA with exact RTL, pinned tools, timing constraints, realistic SRAM macros and memory/controller models. Compare one-copy and banked TMEM if macro mapping fails.
- Multi-corner STA, clock/reset analysis, floorplan, placement, CTS, route, extracted parasitics, DRC/LVS, IR/EM, SI/PI, thermal and package signoff using an actual manufacturable PDK.

### Gate F — product and commercial qualification
- Benchmark representative real models and production-like workloads; record useful tokens/s, latency percentiles, quality/accuracy, batch/concurrency, memory use, availability and failures.
- Measure full-system wall power and cooling, tokens/J, cost per useful token/inference, BOM, board/server/network costs, utilisation, maintenance and support.
- Build demand-backed pricing, gross margin, contribution margin, cash-flow, payback and downside-risk scenarios. No invented customers or revenue.
- Select memory capacity, clock, power envelope, node, package and board only from measured requirements, foundry/IP availability, supply-chain and economic evidence. 128/256 GiB remain stretch investigations, not V1 requirements.

## 11. Explicit non-claims and open blockers

As of this baseline, the project does **not** have verified evidence of:
- A complete PCIe endpoint/PHY or production DMA engine.
- Global DMA address translation, IOMMU, descriptor validation or MSI-X.
- A complete DDR controller, PHY, calibration implementation, ECC datapath or DRAM electrical interface.
- Fully qualified host/accelerator dual-master ordering and concurrency.
- Completed full-chip formal verification or CDC/RDC signoff.
- WG8 ASIC PPA closure, foundry PDK, SRAM macro qualification, DFT, package, DRC/LVS, IR/EM, thermal or tapeout signoff.
- Hardware measurements of ASIC power, tokens/J, throughput or reliability.
- Validated manufacturing cost, customer demand, revenue, contribution margin or payback.

Therefore do not describe the design as production-ready, tapeout-ready, physically validated or commercially proven.

## 12. Session-start and session-end protocol

At the start of each continuation:
1. Read this file and the latest tracker sections.
2. Fetch active branch HEAD and confirm the correct branch.
3. Inspect recent commits, relevant workflows and current source files; do not rely on conversation summaries alone.
4. Select the highest-priority task whose prerequisites and evidence are available.
5. Make a small, reviewable change; run the narrowest meaningful test and the relevant broader CI.
6. Inspect completed logs before reporting results.
7. Update the tracker and this baseline with commit SHA, run IDs, test counts, failures, warnings, pending work and corrected assumptions.
8. Leave `main` unchanged and avoid paid resources absent explicit authorisation.

**Operating principle:** engineering progress is code plus reproducible evidence. A planned test is not a test result; a passing simulation is not physical validation; a logical architecture is not a manufacturable chip.


## 13. Consolidated V1 logical design candidate

The consolidated logical architecture and interface contract is now recorded in `docs/sunnyone/SUNNYONE_AI-X_V1_FINAL_LOGICAL_DESIGN_CANDIDATE_A1.12.11.16.54.md`. It selects WG8 / one slice / AW35 / 32-GiB logical memory / four 512-bit DIMM-local AXI ports / four per-DIMM host-pair muxes / AXI4-Lite control, while explicitly retaining PCIe endpoint/PHY, DMA/IOMMU, DDR controller/PHY, production PDK, package, DFT, physical signoff, board and silicon validation as open blockers. This is a logical V1 candidate, not a tapeout or production-ready specification. Use the new document together with this baseline and the WG8/DDR integration documents; do not infer physical completion from the consolidated design.


## 11. CI history audit and current continuation checkpoint (2026-11-25)

The repository's historical GitHub Actions run history for the active feature branch was audited across 705 returned run records; 316 had a SUCCESS conclusion. These are workflow-run records, including retries and repeated commits, not 314 unique tests. The actual job logs were reconciled for the principal pass evidence. The clearest broad result is Run [45428347703](https://github.com/shamiursunny/openTPU/actions/runs/45428347703), exact SHA `ec0fe8329df06e5204a1c082df133b62b434846b`: 14 successful subsystem/memory jobs totalling **377 passed, 1 intentional 64-GiB geometry skip, 0 failed**. Per-job counts and the broader workflow inventory are in [PROJECT_TRACKER.md, section 126](PROJECT_TRACKER.md).

Additional verified results include:
- RTL-tail Run [45454717008](https://github.com/shamiursunny/openTPU/actions/runs/45454717008), SHA `4a2dd86b6b7f61b96d8cb0f2e5d5e573c85349e9`: 33 passed, 1 documented skip, 183 deselected.
- Isolated one-copy 128K TMEM Run [45465292891](https://github.com/shamiursunny/openTPU/actions/runs/45465292891), SHA `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9`: 2 passed, 215 deselected.
- Reset audit Run [45455745271](https://github.com/shamiursunny/openTPU/actions/runs/45455745271), SHA `dc34e3a51c27c01af6296015cd206ab8336d6bda`: 4 passed.
- Four-instance HMUX directed simulation Run [45454389445](https://github.com/shamiursunny/openTPU/actions/runs/45454389445), SHA `fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc`: 3-beat host/pair write/read bursts with backpressure passed (2 write bursts, 6 read beats, 25 cycles).
- Global address-map SAT Run [45457143624](https://github.com/shamiursunny/openTPU/actions/runs/45457143624), SHA `0d6128d21c086d52e0c6ca3a10bfe4f2666dcccb`: 14 assertions, 813 variables, 2,152 clauses, SAT SUCCESS.
- Full-chip lint Run [45455745243](https://github.com/shamiursunny/openTPU/actions/runs/45455745243) and AXI-Lite control Run [45248945992](https://github.com/shamiursunny/openTPU/actions/runs/45248945992) completed successfully on their respective SHAs.

**Critical interpretation:** no single final immutable release SHA has yet passed the entire regression suite. The queried history had no successful workflow run for remaining RTL/board, software-core or WG8 research PPA. A prior HMUX directed simulation pass does not close the separate four-DIMM host-path stall. A selected address-map SAT proof is not whole-chip formal signoff. The 128K TMEM test does not establish foundry SRAM macro feasibility.

At the last poll, current queued/running runs included ASIC/config `45465384680`, remaining RTL/board `45465292882`, subsystem/memory `45465292903`, software-core `45465292772`, ASIC/config `45465292665`, RTL-tail `45465292944`, and PPA `45455745851`. Always query current GitHub Actions state before acting; none of these states should be presumed unchanged.

The three continuation documents were synchronised after this audit:
1. `SUNNYONE_AI-X_PROJECT_RESUME.md` — fresh-session quick start and live work order.
2. `SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md` — task acceptance and manufacturer/release boundaries.
3. `PROJECT_TRACKER.md` — detailed historical evidence, workflow counts and chronology (section 126).

Continue feature-branch-only work. Verify live feature branch and `main` before further changes. Keep zero-spend approval, exact-SHA evidence, explicit skips and failures, and the distinction between RTL simulation, physical implementation, silicon validation and commercial readiness. No production PPA, production DDR/PCIe PHY, DFT, package, board electrical or silicon qualification is claimed.


## 14. Live continuation addendum — 2026-11-25

This section supersedes the run-status snapshot in Section 11. Preserve all earlier historical results and their exact-SHA scope.

### Live refs
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Latest diagnostic-only testbench commit: `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a`.
- Latest documentation sync commit at this update: `f135674341694fd5d0a57ce6615e0ee3081ff8fb`.
- Main was independently fetched as `d84db55712aba0d40811d7762cb052f05d55b7e5` and remains unchanged. Feature branch is 515 commits ahead, 0 behind; do not merge or modify main without explicit direction.
- Former 30 W total-system ceiling remains retired; no replacement power ceiling is selected.

### Four-DIMM A02 failure and diagnostic action
- ASIC/config Run [45465384680](https://github.com/shamiursunny/openTPU/actions/runs/45465384680), SHA `65f28fc09ede79581ba97845165733d1caef45b1`, failed at 135 ns on `DIMM2 host W payload/last mismatch beat=0`. All three integrated ASIC lint stages passed first. The global address-map and HMUX contention steps were skipped because the workflow stopped at the four-DIMM bench.
- Prior ASIC/config Run [45465292665](https://github.com/shamiursunny/openTPU/actions/runs/45465292665), SHA `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f`, failed on the same assertion.
- Commit `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a` modifies only the testbench failure diagnostic to print actual/expected WDATA, WSTRB, WLAST, owner-FIFO and handshake state. No synthesizable RTL changed. The first commit-workflow lookup returned no associated run; verify whether the push-triggered workflow appears before any further code correction.
- Do not assume the DUT is at fault until the diagnostic identifies which field and handshake condition diverges. Do not alter test expectations to suppress the failure.

### Other live CI
- RTL-tail Run [45465292944](https://github.com/shamiursunny/openTPU/actions/runs/45465292944): SUCCESS, 33 passed, 1 parameter-inapplicable skip, 183 deselected.
- Board-functional and uncovered-RTL jobs in Run `45465292882`: IN_PROGRESS at the last poll.
- Software-core Run `45465292772`: IN_PROGRESS at the last poll.
- Subsystem/memory Run `45465292903`: 14 jobs QUEUED at the last poll.
- WG8 PPA Run [45454389335](https://github.com/shamiursunny/openTPU/actions/runs/45454389335), SHA `fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc`: FAILURE inside ORFS, exit code 2. Artifact `14960636530` contains the 432-MB detailed evidence. Inspect `run.log` to identify the precise failed ORFS stage; no PPA metrics are accepted.
- Older WG8 PPA Run `45455745851` remained IN_PROGRESS at the last poll.
- Historical subsystem 377-pass/1-skip matrix, address-map SAT proof and directed HMUX pass remain valid only for their own SHAs.

### Ordered continuation
1. Verify whether CI was triggered for `e1f46ee...`; if absent, retrigger the existing ASIC/config workflow on the active branch without modifying synthesizable RTL.
2. Inspect the DIMM2 mismatch details; classify WDATA vs WSTRB vs WLAST vs owner FIFO vs register-slice handshake.
3. Make the smallest evidence-supported testbench or RTL correction and rerun the full four-DIMM multi-beat and negative-aperture tests.
4. After A02 passes, execute address-map simulation and four-instance HMUX contention/assertions.
5. Collect final board, uncovered RTL, software-core and subsystem logs; inspect the ORFS artifact and older in-progress PPA run.
6. Keep the master handoff register, project resume and chronological tracker synchronised.

This remains engineering-in-progress. The design is not tapeout-ready, physically signed off, silicon-validated or commercially proven.


## 15. Workflow retrigger status — 2026-11-25

- Diagnostic testbench commit: `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a`.
- Comment-only push-trigger commit: `597f1b9af961f4e8fcde1ae9fffa013ce6bc7f54`.
- The immediate commit-workflow lookups returned no associated runs. There is no diagnostic result yet. Recheck Actions before claiming execution; if no run appears, leave the task blocked on workflow execution rather than guessing.
- The latest chronological record is PROJECT_TRACKER.md Section 128. The main branch remains untouched.


## 16. Latest regression status correction — 2026-11-25

The latest poll supersedes the prior status snapshot: uncovered-RTL job `138698481369` in Run `45465292882` is CANCELLED; board-functional job `138698482005` remains IN_PROGRESS; software-core job `138698481416` remains IN_PROGRESS; subsystem Run `45465292903` has 14 QUEUED jobs; PPA job `138664562707` in Run `45455745851` remains IN_PROGRESS. The cancelled uncovered-RTL suite requires a new exact-SHA run. See PROJECT_TRACKER.md Section 129.


## 17. Corrected HMUX diagnostic instrumentation — 2026-11-25

- Run [45479454587](https://github.com/shamiursunny/openTPU/actions/runs/45479454587), SHA `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a`, failed before simulation because Verilator rejected variable-index hierarchical references in the testbench diagnostic expression. This is an instrumentation compile defect, not a new DUT W-channel failure.
- Commit `76966009274be54ce26d87e333744b5cc17f72b4` fixes the testbench using static generate-indexed HMUX debug probes (`wo_h`, `wo_rv`, `w_v`, `w_r`). No synthesizable RTL or expected data/handshake criteria changed.
- Corrected-SHA workflows all confirmed QUEUED at last poll: ASIC/config Run 45481815682; board/uncovered RTL 45481815901; software-core 45481815819; RTL tail 45481815780; subsystem/WG8 45481815735; isolated TMEM 45481815691. Older Run 45480699954 is queued against the earlier invalid diagnostic source and must not be used as qualification evidence.
- The next evidence gate is the corrected ASIC/config run. If compile succeeds, inspect the actual DIMM2 W mismatch values and mux owner/handshake state. No RTL fix is justified before that diagnosis.
- Full workflow/run/job IDs and previous statuses are maintained in PROJECT_TRACKER.md Section 130 and handoff register Section 12.


## 18. Corrected-SHA live workflow state — 2026-11-25

For corrected diagnostic commit `76966009274be54ce26d87e333744b5cc17f72b4`, latest statuses are:
- ASIC/config Run 45481815682: QUEUED.
- Board/uncovered Run 45481815901: board-functional QUEUED; uncovered RTL IN_PROGRESS (Verilator 5.044 build).
- Software-core Run 45481815819: QUEUED.
- RTL-tail Run 45481815780: IN_PROGRESS (dependency installation).
- Subsystems/WG8 Run 45481815735: all 14 jobs QUEUED.
- Isolated TMEM Run 45481815691: IN_PROGRESS.
No corrected-SHA ASIC/config simulation result is available. This status supersedes the initial all-QUEUED snapshot in Section 17. See PROJECT_TRACKER.md Section 131.


## Board-only regression and Qwen gate dependency checkpoint — 2026-11-26 (Asia/Dhaka)

- Latest board-only run 45769498674 / job 139738454299 failed because the workflow installed Verilator 5.020. Pytest summary: 133 failed, 65 passed, 8 skipped, 1 deselected. The repeated compile failure was at rtl/mxu/otpu_mxu.sv:2781, where Verilator 5.020 rejected bit-selecting bk_ad(rq_ad, rq_en)[b]. Do not treat this as an RTL functional mismatch or weaken the assertion.
- Board-only workflow corrected to build and assert Verilator 5.044 in commit 74ee09d865633e8d8f8cc3edaaf5cb460bf576cc. Dedicated board-only retry run 45784404427 / job 139787424587 tests that commit. At the time of this checkpoint it remains IN PROGRESS at the Verilator 5.044 build step; pytest has not started. Poll this exact run. It does not execute the passed RTL groups.
- The dedicated Qwen real-checkpoint workflow had an invalid PyTorch pin (2.15.0). Corrected to CPU-only torch 2.11.0 and huggingface_hub 2.3.0 in commit 024e488befcbabdde21731f119b52baaedb9d10f. PyTorch's official previous-version page lists the 2.11.0 CPU wheel command: https://pytorch.org/get-started/previous-versions/ . Safetensors remains pinned at 0.8.0.
- The Qwen workflow remains manual workflow_dispatch only and is not yet dispatched. The connected GitHub actions currently available in this session do not expose a workflow-dispatch operation. Do not claim Qwen real-checkpoint RTL validation until a run has been dispatched and its exact pytest log confirms the selected tests executed and passed.
- Current active branch HEAD after the tracker update: 0ee09e6b8fc6cedb4e1b504f8771c272d858d299. Protected main remains d84db55712aba0d40811d7762cb052f05d55b7e5; no main changes. Manufacturer handoff remains NOT READY.
- Immediate order: finish board-only run 45784404427; then dispatch Qwen-only gate through an available workflow-dispatch route; continue remaining formal/property, CDC/RDC, shared-DIMM, consolidated regression, PPA/physical and product qualification. Preserve all historical RTL group passes; never rerun groups 3.1, 3.2 or 4 merely to reconfirm.


## Cross-chat continuation checkpoint — 2026-11-26 (Asia/Dhaka), latest

Resume trigger: when the user types “continue and complete the remaining tasks” in any new chat/tab, continue this exact SUNNYONE X AI CHIP DESIGN / openTPU work. First refresh GitHub branch HEAD and the status/logs/artifacts of workflow 45784404427; then reconcile this checkpoint with actual current evidence and update the completed/remaining task list. Do not ask the user to repeat project context.

Current source state at checkpoint save:
- Repo shamiursunny/openTPU; branch sunnyone/commercial-profitability-architecture-2026-11-23.
- HEAD at save time: 848b7f65884ae049c5a1a19fe4770b6e51d5692c.
- Protected main: d84db55712aba0d40811d7762cb052f05d55b7e5 (unchanged; do not modify).
- Latest continuity updates were committed to PROJECT_TRACKER.md, this baseline, PROJECT_RESUME.md and MANUFACTURER_HANDOFF_READINESS.md. Since this baseline update itself changes the branch, refresh HEAD before any subsequent action.

Non-negotiable constraints:
1. Never rerun completed RTL groups 3.1, 3.2 or 4 merely for confirmation; retain the prior successful evidence.
2. Do not rerun user-cancelled workflow 45765362426.
3. Do not launch the broad RTL workflow/matrix to work on the remaining tasks.
4. Do not weaken/remove tests/assertions or conceal failures.
5. Work on the feature branch only; preserve protected main.
6. Use serial/low-concurrency workflow execution and distinguish toolchain/environment failures from design defects.

Exact current run:
- Board-only workflow run 45784404427, job 139787424587, source SHA 74ee09d865633e8d8f8cc3edaaf5cb460bf576cc.
- Latest observed step states: Verilator 5.044 build SUCCESS; Python/project dependency install SUCCESS; board-functional pytest IN PROGRESS; artifact upload pending.
- No terminal result or board pass is established. Poll the exact run, then inspect pytest summary and uploaded log/artifact.
- Previous run 45769498674 failed with Verilator 5.020: 133 failed, 65 passed, 8 skipped, 1 deselected, parser failure at rtl/mxu/otpu_mxu.sv:2781. Board-only workflow was corrected to build/assert Verilator 5.044 in commit 74ee09d865633e8d8f8cc3edaaf5cb460bf576cc.

Qwen gate:
- .github/workflows/sunnyone-qwen-real-rtl.yml has corrected CPU torch 2.11.0, huggingface_hub 2.3.0 and safetensors 0.8.0; workflow correction commit 024e488befcbabdde21731f119b52baaedb9d10f.
- Workflow is workflow_dispatch only and NOT DISPATCHED. No real-checkpoint Qwen RTL pass exists. Dispatch this dedicated workflow only when a valid dispatch action is available; never substitute the broad RTL matrix.

Remaining tasks (update statuses from fresh evidence, don't assume):
A. Board-only regression terminal result and diagnosis.
B. Dedicated Qwen3/Qwen3.5 real-checkpoint RTL run.
C. Shared-DIMM/adversarial and remaining integration validation.
D. Consolidated regression.
E. Formal/property verification.
F. CDC/RDC.
G. Full-chip lint.
H. PPA and physical design closure.
I. Production PCIe endpoint/PHY, DMA/IOMMU, DDR controller/PHY/ECC integration.
J. DFT, board electrical, silicon, measured power/performance/thermal and product qualification.
K. Commercial/manufacturer evidence and handoff readiness.

Manufacturer handoff: NOT READY. No production readiness claim. Keep the distinction between RTL/board-model evidence and actual silicon/product qualification explicit.


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
