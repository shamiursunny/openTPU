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

**At baseline creation, the latest host arbitration and AW35 work has no verified completed CI result recorded in the tracker.** Historical queued jobs are not passes. A successful earlier commit does not qualify later RTL changes.

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
