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
- The four-DIMM host-path simulation compiled and passed the preceding target/config and three lint stages, but timed out at 200 microseconds. Timeout-only diagnostics have been added; the root cause and passing rerun remain open.
- The Nangate45 research PPA run failed with ORFS exit code 2. It enumerated 288 SRAM macro instances across 14 sizes (approximately 3,538 KiB) but yielded no verified area, timing or power result. The workflow is being corrected to archive the complete ORFS run log and reports.
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
