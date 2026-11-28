# SUNNYONE X — simulation-first completion and manufacturer handoff policy
Date: 2026-11-28 22:00 Asia/Dhaka

## User-confirmed delivery objective
The user's intended delivery is a fully completed, simulation-qualified design and evidence package submitted to a manufacturer. The manufacturer is expected to undertake physical implementation/validation, silicon or FPGA/board prototyping as appropriate, and volume-production assessment. The project should not attempt to self-fabricate or purchase physical hardware merely to claim readiness.

This is now the governing execution policy unless the user explicitly changes it:
- Complete all engineering tasks that can be responsibly completed with open-source tools, simulation, formal verification, synthesis, static analysis, software models, and reproducible documentation.
- Prepare a clear manufacturer integration package, design constraints, interface contracts, source/licence inventory, verification evidence and known limitations.
- Leave foundry/PDK-specific implementation, tapeout, physical silicon measurements, yield, packaging, production qualification and bulk manufacturing to a qualified manufacturer.
- Do not label a design "silicon-ready", "production-ready" or "compatible with any board" merely because simulations pass. Use "simulation-qualified" with exact scope and tool versions.

## Important correction: portability is designed, not assumed
A RISC-V instruction set does not make a hardware accelerator automatically compatible with every RISC-V CPU, SoC or development board. Board integration depends on host interface, bus protocol, address map, DMA/IOMMU, interrupt/reset/clock, memory coherency, voltage/IO, package and the manufacturer's process.

To maximise portability, the design must define and verify:
1. A processor-independent accelerator core with a documented command/descriptor interface.
2. One or more standard host integration adapters selected from interfaces actually supported by the RTL and target market (e.g. AXI4/AXI-Lite and/or TileLink; PCIe only if designed and verified).
3. A clear control/status register map, interrupt model, reset/clock contract, error handling and version/capability discovery.
4. DMA address width, alignment, burst, backpressure, ordering, coherency and IOMMU assumptions.
5. Memory interface and buffer ownership contract, including whether local SRAM/HBM/DDR is external or on-package.
6. A software driver/runtime and reference integration examples for supported host environments.
7. Parameterised wrappers and lint/simulation regressions for each supported configuration.
8. An explicit compatibility matrix. "Any RISC-V chip/board" is not a supportable claim unless each required interface and integration assumption is met.

The manufacturer may adapt the wrapper/PHY/physical implementation to a particular RISC-V SoC or board. That is distinct from changing the verified accelerator core. A generic board-level interface is not a substitute for a foundry-specific physical design.

## Simulation-first verification scope
The simulation qualification package must cover, as applicable:
- ISA decode, instruction semantics, illegal/reserved encodings and deterministic error/timeout behaviour.
- RTL unit, subsystem, integration and top-level regressions; legal and malformed command coverage.
- Scoreboards/reference models and cycle-accurate or transaction-level comparison where appropriate.
- Memory correctness: bounds, alignment, arbitration, hazards, ordering, ECC/error injection where modelled, and DMA protection assumptions.
- Interconnect protocol compliance: ready/valid, backpressure, burst boundaries, response ordering, reset and error paths.
- Concurrency, arbitration fairness, deadlock/livelock, queue overflow/underflow and same-cycle corner cases.
- Parameter/feature configurations and unsupported-feature rejection.
- Formal assertions/properties for safety invariants and bounded liveness where tractable.
- CDC/RDC structural checks and reset analysis using available open-source flows; document limits of these tools.
- Synthesis/elaboration, lint, width/sign/overflow checks, inferred-latch checks, clock/reset checks and reproducible source manifests.
- Software simulator, compiler/runtime, driver/API and representative model/workload co-simulation.
- Performance-model validation against trace fixtures; separate modelled throughput/latency/energy from measured hardware values.
- Reproducible regression commands, seeds, tool versions, exact commit SHAs, logs, coverage reports, known failures and exclusions.

Simulation does not prove analog behaviour, metastability MTBF, extracted parasitic timing, actual power/thermal behaviour, process variation, SRAM macro behaviour, package/board signal integrity, manufacturing yield or long-term reliability. Those must be explicitly marked manufacturer/physical validation gates.

## Revised handoff boundary
### Must be completed before submission (simulation/design package)
- Freeze architecture and supported configuration matrix.
- Close MM legality guard and all known RTL correctness blockers.
- Complete applicable RTL/software verification, formal properties, lint/elaboration and open-source synthesis checks.
- Complete simulation of every published host-interface adapter and representative board/SoC integration wrapper.
- Produce software API/driver/runtime, programming guide, register map and integration guide.
- Produce synthesis area estimates and timing constraints with technology assumptions clearly stated; no claim of signoff PPA without a real target library/flow.
- Produce source inventory, third-party IP/licence/SBOM review, reproducible build scripts and exact verification manifest.
- Produce a manufacturer handoff dossier with architecture, RTL, constraints, test plan, test vectors, known limitations, security assumptions and acceptance criteria.

### Manufacturer-dependent (not falsely claimed as simulation-complete)
- Select foundry/process node, PDK, standard-cell libraries and SRAM/compiler macros.
- Technology mapping, floorplan, CTS, routing, extracted STA, IR drop, EM, DRC/LVS and antenna signoff.
- Final PCIe/SerDes/DDR PHY selection and integration where hard macros are required.
- Package, substrate, IO/voltage compatibility, board SI/PI and thermal solution.
- Silicon bring-up, measured frequency, power, thermal, performance, reliability, yield and production test.
- Tapeout approval, fabrication, packaging, qualification and bulk production.

## Execution priority and count interpretation
The previously documented 14 work packages remain the high-level plan, but package 13 is reclassified: do not treat sponsorship/fabrication as a prerequisite to completing the simulation-first design package. Instead, deliver a complete, honest handoff package and then engage manufacturers for their physical stage. Track B demonstrator is optional unless a manufacturer requests it or it materially reduces risk.

The immediate critical path is:
1. MM spec/parameter propagation and guard.
2. Focused raw-command positive/negative regressions and exact-SHA CI.
3. Close remaining RTL correctness, lint and width/bounds defects.
4. Complete integration/interface contract and supported-host compatibility matrix.
5. Complete formal/SVA and available CDC/RDC checks.
6. Complete software/runtime, trace-based workload and reproducible simulation evidence.
7. Run full final regressions once against frozen release candidate; retain prior passing evidence only where source/test scope is unchanged.
8. Generate manufacturer dossier and independent checklist; no physical claims.

Do not quote a precise remaining pytest count until all test files and test collection can be enumerated from a pinned commit and all planned verification categories are converted into executable cases. Current plan estimate for the dedicated MM raw-word matrix remains approximately 30–45 parameterised scenarios; it is a plan, not a current test inventory.

## Release terminology
- "Simulation-qualified": named tests and checks passed at stated exact commit/tool versions and scope.
- "Synthesis-estimated": mapped using a named generic or target library, with assumptions; not physical PPA signoff.
- "Manufacturer handoff candidate": simulation/design evidence package complete and open blockers disclosed.
- "Silicon validated": only after measured physical silicon results.
- "Production qualified": only after manufacturer signoff, qualification and manufacturing acceptance.

## Safety and repository state
This addendum is a policy/plan update only. It does not claim RTL changes or new tests. Preserve protected main and all previous no-duplicate-regression constraints. Before the next source write, re-resolve live branch HEAD. Do not launch costly or broad workflows without a proven isolated route and explicit justification.
