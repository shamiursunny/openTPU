# SUNNYONE X — Final Execution Master Plan
Date: 2026-11-28 (Asia/Dhaka)
Status: **Governing execution plan approved in principle by the user; engineering completion and hardware selection gates remain open.**
Repository: `shamiursunny/openTPU`
Working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Governing product objective: `SUNNYONE_X_ULTIMATE_COMMERCIAL_NORTH_STAR_2026-11-28.md`

## 1. Executive decision

Build SUNNYONE X as a commercially competitive, programmable AI inference accelerator for data-centre workloads. Maximise risk-adjusted lifetime profitability by delivering the greatest quantity of accepted, useful inference work per unit of energy and total cost, while maintaining quality, predictable latency, reliability, stability, maintainability and a credible manufacturing path.

The agreed development strategy is:

1. Complete the software, RTL, simulation, formal, lint, synthesis-estimation and documentation work that can be done with available open-source tools and reproducible environments.
2. Do not build a custom early prototype PCB or custom processor board merely to begin hardware testing.
3. After the design passes the pre-hardware engineering gates, use commercially available, high-capability FPGA evaluation hardware and a ready RISC-V SoC development board to validate real RTL, host software and interfaces. The user accepts a higher-cost prototype platform in principle, with economical production as a later objective.
4. Use the prototype evidence to refine the product and prepare a complete manufacturer handoff. The manufacturer then owns process-specific ASIC implementation, hard PHY/macro integration, physical signoff, silicon validation, yield, qualification and production.
5. Optimise the eventual production design for low delivered cost and strong lifetime economics only after functional and workload requirements are demonstrated. Do not equate a high-end prototype BOM with the eventual production BOM.

This is a staged strategy, not approval to order any named board today. No exact purchase, quote, customs, shipping, licence or total budget has been approved. Obtain a current written quote and an explicit purchase decision before spending.

## 2. Fixed product objective and scope

### 2.1 Product
SUNNYONE X is an AI inference accelerator platform, not a general-purpose smartphone SoC and not a claim to build a CPU+GPU+multimedia SoC. The current product direction is programmable and workload-oriented, with existing openTPU RTL as the implementation baseline.

Optimisation hierarchy:
1. Correctness, safety and accepted model/task quality are hard constraints.
2. Maximise sustained useful tokens/s and requests/s on representative customer workloads.
3. Minimise joules per accepted useful token and full-system energy.
4. Minimise idle/low-load power, avoidable data movement, cooling demand and thermal throttling.
5. Minimise delivered-system cost, manufacturing risk, maintenance and support burden.
6. Preserve predictable TTFT, inter-token latency and P50/P95/P99 tails, reliability, availability and scale-out capability.
7. Maximise risk-adjusted contribution margin, NPV and realistic investment recovery.

There is no fixed 30 W system ceiling. Do not replace it with another arbitrary power target. Choose the power envelope from measured throughput, energy, thermal stability, TCO and incremental contribution margin.

### 2.2 Unified compute direction
- TPU/MXU: matrix/tensor operations and supported dense projections.
- NPU/VPU: supported vector, elementwise, reduction, activation, normalisation and streaming operations.
- LPU-like role: admission, prefill/decode scheduling, batching, KV-cache lifecycle, context movement and token-latency control. Implement and optimise this first in the software/runtime and shared resources. Do not claim a separate LPU silicon block exists or add one without measured evidence.
- Shared data plane: TMEM/local SRAM, DMA, external memory, arbitration and interconnect.
- Compiler/runtime/ISA: programmability, model/operator support, profiling and host integration.
- Quantum-inspired classical algorithms are optional research only; no QPU or quantum-speedup claim.

Do not add new hardware blocks because they sound faster. Require a source-backed bottleneck, reproducible baseline, alternative comparison, resource/area/power/heat estimate, verification plan and rollback criteria.

## 3. Architecture baseline to preserve

The existing V1 logical candidate is one WG8 compute slice with D/MCOLS/WG 128/8/8; AW35 and a 32-GiB logical DRAM map; eight native memory channels paired into four DIMM/controller ports; four 512-bit DIMM-local AXI4 interfaces; AXI4-Lite BAR0 control; 128K TMEM / 32K IMEM candidate; and existing MXU, VPU, sequencer, DMA and memory structures.

The detailed candidate remains in:
`SUNNYONE_AI-X_V1_FINAL_LOGICAL_DESIGN_CANDIDATE_A1.12.11.16.54.md`.

This is a logical candidate, not a completed host-connected ASIC. PCIe endpoint/PHY, descriptor DMA, global address translation/IOMMU, production DDR controller/PHY/training/ECC, final SRAM macros, DFT, process, package and physical implementation remain open. One slice is the evidenced ASIC integration baseline; do not claim a multi-slice production design without implementation and tests. 128 GB ECC DDR4 is conditional system-level exploration; 256 GB is stretch-only, not a V1 requirement.

## 4. Prototype hardware strategy — ready evaluation boards, no custom pre-ready board

### 4.1 Functional split
Use two different roles rather than expecting one board to be both the largest FPGA accelerator and a RISC-V host:

- **Accelerator FPGA evaluation platform:** hosts the SUNNYONE X RTL and exposes the actual interfaces we implement.
- **RISC-V host/reference platform:** boots Linux or bare metal, runs the driver/runtime and submits work through an interface physically and electrically supported by both boards.

The RISC-V ISA is not a universal board connector. Compatibility is determined by implemented bus/PCIe protocol, endpoint/root-port roles, lane width and generation, connector/cabling, address translation, DMA/IOMMU, interrupt, reset, clocks, memory coherency, voltage and software support. Do not claim universal RISC-V compatibility.

### 4.2 Leading candidates from current official documentation

**Primary practical accelerator-board candidate: AMD VCU118**
- Virtex UltraScale+ XCVU9P FPGA.
- Board guide documents two 2.5-GB DDR4 80-bit component-memory interfaces and an RLD3 interface.
- PCIe endpoint connector supports Gen1/Gen2 x16 and Gen3 x8 or x16 depending on board revision/voltage configuration; Rev. 2.0+ is required for Gen3 x16.
- AMD's current product page lists US$14,995 and a six-week lead time at the time of this review.
- Why it leads: mature, documented PCIe endpoint and DDR4 development environment that aligns better with the current logical design's PCIe/DDR direction than a RISC-V-only SoC FPGA kit.
- Limitations: it does not contain a RISC-V application host; it needs a separate host platform. It requires AMD Vivado tooling. Exact board revision, device speed/voltage, licence/tool compatibility, resource fit and availability must be checked before purchase.

**RISC-V host/reference candidate: Microchip PolarFire SoC Icicle Kit (current MPFS-ICICLE-KIT)**
- MPFS250T production-silicon kit; 1× E51 plus 4× U54 64-bit RISC-V cores.
- 254K logic elements, LPDDR4, eMMC/SD/SPI, Ethernet and PCIe Gen2 root-port connectivity.
- Use it to validate RISC-V Linux/bare-metal host software, driver/runtime, control plane and a real RISC-V-to-accelerator integration path if the physical PCIe connection and link configuration are proven.
- It is not the selected high-capacity accelerator FPGA. Its FPGA fabric is not assumed large enough for the full WG8 accelerator.
- Verify current kit revision, root-port lane configuration, connector/cable/adapter, supported PCIe mode, Libero/SoftConsole licensing and Linux driver path.

**Maximum-capacity upgrade candidate: AMD VPK180**
- Versal Premium VP1802, over 7 million logic cells, 112G PAM4 transceivers, and 12 GB 192-bit LPDDR4 on the board.
- AMD's current official page lists US$17,995 and an eight-week lead time at this review.
- It is a much larger fabric option if VCU118 synthesis proves insufficient or if high-speed system-interface work justifies it.
- It is not a RISC-V host board; the board's system controller is Zynq UltraScale+ based. Its connector/host integration is not assumed to be a drop-in PCIe accelerator card. It uses the AMD Vivado/Vitis ecosystem.
- Do not buy it merely because it is larger or more expensive. First prove that the extra fabric, interfaces and tools materially advance the actual design.

**Not selected:** VCU128 and VHK158 have attractive HBM characteristics but AMD's product pages currently mark these evaluation kits discontinued. Do not make them the baseline purchase without written confirmation of support, supply and toolchain access.

### 4.3 Hardware decision gate — no purchase yet
Before choosing the actual prototype platform, complete and archive:
1. Exact source SHA and synthesis/elaboration configuration for the candidate RTL.
2. Resource reports: LUT/logic, FF, DSP/MACC, BRAM/URAM, clock resources, I/O and memory-controller use; include realistic headroom and debug instrumentation.
3. Timing feasibility under the board's supported clocks; do not treat a constraint as achieved frequency.
4. Memory mapping: fit of current TMEM/IMEM/FIFO/ACT RAM and external memory path; distinguish FPGA block RAM from external DDR.
5. Interface fit: actual PCIe endpoint/root roles, generation, lane width, connector, cabling/adapter, DMA, BAR, interrupts, clocks, reset and address map.
6. Host software feasibility: RISC-V toolchain, Linux kernel/driver, DMA buffers, IOMMU/aperture and coherency model.
7. Toolchain/licence availability and reproducible build flow.
8. Current official/distributor quote, revision, stock, delivery to Bangladesh, shipping, customs/taxes, accessories and warranty.
9. A written user-approved total spending amount for the exact board/configuration.

If VCU118 fits with headroom, prefer it as the first accelerator prototype because its documented PCIe endpoint and DDR4 environment are closer to the existing logical interface. If it does not fit, compare VPK180 and other currently supported boards against the actual resource/interface report. The Icicle Kit remains the RISC-V host candidate only if its PCIe root-port integration can be physically and electrically demonstrated. A bridge or adapter is allowed only after compatibility is documented; do not build a custom PCB as the default first step.

### 4.4 Prototype evidence boundary
FPGA testing can demonstrate the implemented RTL on a specific FPGA board, real host software and actual interface operation. It does not establish ASIC frequency, silicon power, silicon tokens/J, production thermal behaviour, yield, package reliability or final unit cost. FPGA clocking, memory and resource architecture differ from an ASIC. Keep all measurements labelled by platform and configuration.

## 5. Staged execution roadmap and exit gates

### Stage 0 — Governance, repository and evidence baseline
- Work only on `sunnyone/commercial-profitability-architecture-2026-11-23`; never write to `main`.
- At every continuation, read this master plan, current checkpoint, integrated plan, tracker and handoff matrix; fetch live GitHub branch and workflow state.
- Preserve exact source SHA, tool versions, run IDs, artifacts, skips, warnings and test exclusions.
- Do not restart cancelled run 45765362426. Do not rerun RTL groups 3.1, 3.2 or 4 merely to reconfirm historical passes. Avoid broad duplicate CI and expensive PPA retries.
- Zero-spend remains the default until the user explicitly approves an exact expense. The user's willingness to consider high-cost prototype equipment is strategic permission to evaluate it, not a purchase order.

**Exit:** authoritative current branch/evidence snapshot and no conflicting or unexplained workflow activity.

### Stage 1 — Close critical RTL correctness blockers
- Complete the MM instruction legality contract, exact target-parameter propagation and synthesizable reject-before-dispatch guard.
- Build dedicated raw-word positive and negative MM regressions, including base and target variants, capability-enabled positive controls and disabled-capability negative controls.
- Preserve the distinction between ACT row capacity, ACT block capacity and mode-specific FIFO residency. Use widened arithmetic. Do not reinstate the withdrawn universal FIFO_DEPTH >= ACT_BLOCKS rule.
- Review every direct sequencer instantiation and resolved target configuration before editing.
- Triage width/sign/overflow warnings and prove bounds. Close actual latches/combinational paths only where elaborated/synthesised evidence shows defects.
- Do not push RTL changes into broad `rtl/**` workflows until an isolated exact-SHA verification route is confirmed.

**Exit:** all MM legality cases pass on exact SHA; no unexplained critical RTL correctness defects; targeted regressions and preserved historical evidence are traceable.

### Stage 2 — Verification, formal and structural quality
- Complete unit, subsystem, integration and top-level functional coverage, including malformed commands, resets, backpressure, arbitration, concurrency, ordering, faults, bounds, queue overflow/underflow, timeouts and recovery.
- Expand SVA/formal for DMA bounds, AXI/host interfaces, memory map, arbitration, reset, safety and error paths; include assumptions and cover properties.
- Complete clock/reset inventory and CDC/RDC structural analysis; individually justify waivers.
- Define DFT/testability requirements and test access; simulation planning is not ATPG signoff.
- Verify memory inference and candidate SRAM macro contracts; no generic RAM result equals a foundry SRAM macro qualification.
- Maintain an exact source/config/tool/test manifest. Count distinct tests carefully; don't sum overlapping workflow selections as unique tests.

**Exit:** agreed requirements-to-test traceability, reproducible regression and formal evidence, classified warnings and open limitations, reviewed CDC/RDC and testability plans.

### Stage 3 — Workload, model and performance evidence
- Establish deterministic W1 single-request, W2 mixed-concurrency and W3 burst/contention/cancellation/fault workloads. Add W4 long-context only when the capacity/KV semantics are explicitly represented.
- Use exact model/checkpoint, tokenizer/template, quantisation, prompt distribution, output policy, context length, batch/concurrency and quality criteria.
- Distinguish real checkpoint tests, tiny board-model tests, software simulator runs, RTL simulation and actual accelerator execution.
- Attribute prefill/decode, scheduler, DMA, memory, KV, queue, host and interconnect time to source-backed traces.
- Measure useful accepted tokens/s, prefill/decode rates, TTFT, inter-token latency, P50/P95/P99, requests/s, memory traffic, stalls, utilisation and error/retry rate.
- Optimise software/compiler/runtime, data reuse, batching and scheduling first. Add RTL only for measured bottlenecks.

**Exit:** reproducible baseline and optimisation comparisons with trace provenance and no fabricated service times, throughput, energy or quality.

### Stage 4 — Host portability and integration contracts
- Define a processor-independent accelerator command/descriptor model.
- Define only the host adapters we actually implement (for example AXI4/AXI-Lite and PCIe endpoint; add TileLink only if implemented and tested).
- Freeze register map, capability discovery, interrupts, reset/clock, address map, DMA alignment/burst/order/backpressure, memory ownership/coherency and IOMMU assumptions.
- Build driver/runtime and supported-host integration example.
- Validate RISC-V host support on the Icicle Kit only after root-port/endpoint/physical-link compatibility is verified.
- Publish an explicit compatibility matrix by host SoC, interface, board revision, lane/generation and software version. Never say “works with every RISC-V chip/board”.

**Exit:** one real supported host path, software integration tests and an evidence-backed compatibility statement.

### Stage 5 — FPGA board-fit and prototype readiness
- Run reproducible synthesis on the exact FPGA part/toolchain and estimate resource use with realistic headroom.
- Select the board only using Stage 4 interface contracts and Stage 5 fit reports.
- Create a pin/clock/reset/IO and memory mapping, build/bitstream flow, debug plan and rollback configuration.
- Use a ready evaluation board; do not create a custom early board unless the chosen platform physically cannot connect without one and the alternative is justified.
- Procure only after current price, availability, licence, shipping/customs and total-cost approval.

**Exit:** reproducible bitstream build and successful board bring-up plan with no unresolved electrical/interface incompatibility.

### Stage 6 — High-end FPGA/RISC-V prototype validation
- Bring up board power, clocks, reset, programming and diagnostics.
- Demonstrate host enumeration/control, BAR/register access, DMA, interrupts, bounds/error handling and reset recovery.
- Run the implemented accelerator RTL with correctness scoreboards and compare outputs against software reference.
- Run supported W1/W2/W3 workloads; record model quality, throughput, latency, memory behaviour, utilisation and sustained stability.
- Measure board input power and temperatures with calibrated instruments; report the whole platform boundary and ambient conditions.
- Test failure recovery, long runs, memory stress, contention and repeatability.

**Exit:** board-specific hardware validation report tied to exact bitstream, RTL SHA, host software, board revision, instruments, workload and raw logs. Do not call it ASIC or production signoff.

### Stage 7 — Simulation-qualified and prototype-supported manufacturer handoff
Prepare:
- architecture and logical design specifications;
- synthesizable RTL, parameter matrix, source hashes and third-party IP/licence/SBOM inventory;
- ISA/register/DMA/memory/host-interface contracts;
- software compiler/runtime/driver and supported-host compatibility matrix;
- regression/formal/lint/CDC/synthesis/FPGA evidence with exact scope;
- timing constraints and technology assumptions;
- workload benchmarks, model-quality tests, performance and measured board power/thermal reports, clearly separated by evidence class;
- DFT, security, reset/clock, memory, package and physical-design requirements;
- known limitations, waivers, open risks and acceptance criteria;
- reproducible build/test commands and manufacturer questions.

Use the release label **simulation-qualified manufacturer handoff candidate** until the required pre-handoff evidence is complete. If the FPGA prototype is completed, separately label it **FPGA-prototype validated on [exact board/revision]**. Neither label means silicon-ready or production-ready.

**Exit:** independent review accepts the package and a manufacturer confirms the scope, input files and physical work it will undertake.

### Stage 8 — Manufacturer physical implementation and low-cost production down-select
Manufacturer-specific work:
- select process/PDK, libraries, SRAM macros, IO, hard PCIe/SerDes/DDR PHY and package;
- perform floorplan, CTS, place/route, extraction, STA, DRC/LVS, IR/EM and physical verification;
- close DFT/ATPG/MBIST, package/board SI/PI, thermal and reliability;
- fabricate engineering samples, perform bring-up, measure frequency/power/thermal/performance and yield;
- quote NRE, die, package, test, board, memory, MOQ, lead time and production yield.

Then optimise the production BOM and architecture for lowest delivered cost consistent with accepted throughput, energy/token, reliability, yield, maintainability and customer requirements. Compare mature nodes, die partitioning, packaging, external memory and alternative configurations with sourced quotations and physical evidence. No process node, die size, yield, unit cost or production schedule is preselected.

**Exit:** measured silicon and qualified manufacturing evidence plus a demand-backed commercial case and user approval for production investment.

## 6. Commercial measurement contract

For each workload and platform, record:
- exact model/checkpoint/tokenizer/template/quantisation and quality acceptance;
- prompt/output distribution, context, batch, concurrency, warm-up and run duration;
- prefill tokens/s, decode tokens/s, accepted useful tokens/s, requests/s;
- TTFT, inter-token latency and completion P50/P95/P99;
- memory capacity/bandwidth/latency, KV bytes/token, cache hit/reuse, DMA/network bytes and stalls;
- board/system wall power at idle, prefill, decode, mixed load and thermal steady state;
- joules per million accepted useful tokens, temperatures, cooling/fan power and throttling;
- reliability, uptime, reset/recovery, error/retry and memory-error behaviour;
- full BOM/TCO, electricity, cooling/PUE, maintenance, warranty, logistics, tax, financing, utilisation and demand;
- revenue/price evidence, contribution margin, NPV and payback sensitivity.

Label every value **measured, quoted, simulated, inferred or assumed**. No invented figures and no extrapolation from FPGA to ASIC without a validated model and uncertainty range.

## 7. Risk register and controls

| Risk | Control / response |
|---|---|
| Existing RTL does not fit selected FPGA | Synthesis-first board-fit gate; compare supported larger board only after resource evidence. |
| RISC-V host cannot directly link to accelerator | Verify root/endpoint, lane, generation, connector and reset/clock; use documented bridge only if justified. |
| Vivado/Libero licensing or tools block builds | Confirm licence, version and reproducible flow before procurement. |
| Current logical top lacks PCIe endpoint/DMA/DDR PHY | Treat as explicit engineering/integration blocker; do not imply these are already implemented. |
| FPGA prototype gives misleading ASIC expectations | Keep FPGA measurements separate from ASIC PPA, power and thermal evidence. |
| Overdesign reduces profitability | Add blocks only for measured bottlenecks and incremental economic gain. |
| Production PDK/IP/packaging is unavailable or costly | Engage multiple qualified manufacturers after evidence package; compare total delivered cost and risk. |
| User's prototype budget becomes open-ended | Obtain exact quotation and explicit total-spend approval before each purchase. |
| Historical CI evidence is duplicated or stale | Preserve exact SHA, run IDs, test selections and artifacts; do not double-count. |
| Confidential IP/licence or publication risk | Review licence, IP ownership, export and publication terms before sharing RTL/GDS. |

## 8. Non-negotiable project controls

- Feature branch only: `sunnyone/commercial-profitability-architecture-2026-11-23`. Protected project `main` SHA historically recorded as `d84db55712aba0d40811d7762cb052f05d55b7e5`; never write to main and recheck live state.
- No invented specs, results, compatibility, test counts, prices, availability or manufacturer commitments.
- No paid hardware, cloud, licence, PDK, fabrication, shipping or service purchase without explicit approval of the exact cost.
- Preserve successful historical RTL groups 3.1, 3.2 and 4; never restart cancelled Actions run 45765362426.
- Avoid broad duplicate CI and unjustified PPA retries; use serial, source-scoped, exact-SHA verification.
- Do not confuse test-fixture success, software simulation, RTL simulation, FPGA measurement and silicon qualification.
- Update the checkpoint, tracker and handoff matrix after each material decision or completed engineering stage.
- The user's fixed commercial objective does not freeze an inferior implementation. Change technical choices when evidence shows a safer, more profitable, more manufacturable route to the same objective.

## 9. Current honest status and immediate next actions

- Product north star: **FIXED**.
- V1 logical candidate: **DEFINED, not fully implemented or qualified**.
- Existing RTL/software test evidence: **SUBSTANTIAL, historical and SHA-bounded**; exact total unique tests is not asserted.
- MM malformed-command guard: **OPEN critical blocker**.
- Formal/SVA, CDC/RDC, lint/width closure, DFT and memory macro mapping: **PARTIAL/OPEN**.
- Production PCIe/DMA/IOMMU/DDR PHY and full host integration: **OPEN**.
- FPGA platform: **candidates shortlisted, no final board selected or purchased**.
- RISC-V host platform: **Icicle Kit candidate, physical integration unproven**.
- Board fit: **not measured against exact current RTL SHA**.
- FPGA prototype: **NOT STARTED**.
- Manufacturer handoff: **NOT READY**.
- Silicon/production qualification and commercial profitability: **NOT DEMONSTRATED**.

Immediate order:
1. Re-poll live branch, checkpoint and workflow state.
2. Complete MM guard contract/parameter census and dedicated tests-first route.
3. Close critical RTL/lint/formal/CDC and integration issues without repeating protected historical tests.
4. Build and validate W1/W2/W3 trace and useful-throughput baselines.
5. Define the host interface and RISC-V compatibility contract.
6. Synthesize current RTL against VCU118 and VPK180 device targets where tool access permits; compare resources, memory, timing and interface fit.
7. Select the exact FPGA board and RISC-V host only after those reports and current licence/quote checks.
8. Proceed to hardware only after explicit purchase approval; then produce board-specific validation evidence.
9. Complete manufacturer dossier and proceed to physical ASIC implementation with a qualified manufacturer.
10. Optimise the production design and commercial model from measured silicon, quotes and customer evidence.

## 10. Source references

Official board references reviewed on 2026-11-28:
- AMD VCU118 product page: https://www.amd.com/en/products/adaptive-socs-and-fpgas/evaluation-boards/vcu118.html
- AMD VCU118 board guide: https://docs.amd.com/api/khub/documents/Uoc4S9pQd1uve6kiGiG2kA/content
- AMD VPK180 product page: https://www.amd.com/en/products/adaptive-socs-and-fpgas/evaluation-boards/vpk180.html
- AMD VPK180 product brief: https://www.amd.com/content/dam/amd/en/documents/products/adaptive-socs-and-fpgas/boards-kits/product-briefs/2504082-vpk180-product-brief.pdf
- Microchip current Icicle Kit page: https://www.microchip.com/en-us/development-tool/MPFS-ICICLE-KIT
- Microchip Icicle Kit user guide: https://www.microchip.com/content/dam/mchp/documents/FPGA/ProductDocuments/UserGuides/microchip_polarfire_soc_fpga_icicle_kit_user_guide_vb.pdf
- AMD VCU128 product page (discontinued notice): https://www.amd.com/en/products/adaptive-socs-and-fpgas/evaluation-boards/vcu128.html
- AMD VHK158 product page (discontinued notice): https://www.amd.com/en/products/adaptive-socs-and-fpgas/evaluation-boards/vhk158.html

This plan supersedes earlier ambiguity about whether to self-fabricate a demonstrator before manufacturer handoff: simulation-first completion remains mandatory; a ready-board FPGA/RISC-V prototype is the intended next validation stage when the board-fit, interface and spend gates are satisfied. It does not require a custom pre-ready PCB and does not authorise an immediate hardware purchase.
