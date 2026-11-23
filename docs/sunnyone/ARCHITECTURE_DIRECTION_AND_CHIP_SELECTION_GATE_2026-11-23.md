# SUNNYONE AI-X — Architecture Direction and Chip Selection Gate

Date: 2026-11-23
Status: architecture direction selected; exact FPGA/SoC part and final ASIC implementation NOT SELECTED.
Branch: sunnyone/commercial-profitability-architecture-2026-11-23
Pinned openTPU reference: FeSens/openTPU d84db55712aba0d40811d7762cb052f05d55b7e5

## Decision
Proceed with a programmable, workload-oriented inference accelerator architecture, not a fixed-function single-model engine:
- Host-server control plane for boot orchestration, scheduling, telemetry, security policy and system management. The first-version accelerator contains no on-chip RISC-V CPU or boot ROM. The board reference uses the existing sequencer and `otpu_ctrl` AXI4-Lite control/status block; integration of that host-control block into the ASIC top remains open. Add an embedded CPU only after a measured requirement justifies it.
- Tiled matrix engine for dense linear algebra and attention projections, with supported low-precision formats selected by workload evidence.
- Vector/SIMD datapath for elementwise operations, normalisation, quantisation/dequantisation, activation functions, and irregular kernels.
- Explicit local SRAM scratchpads and DMA to reduce off-chip traffic; capacity/banking are sized from measured traces.
- Coherent or well-defined high-bandwidth interconnect with isolation between host, compute, DMA and memory.
- ECC-capable external memory path; memory controller and package selection remain open until exact DIMM topology and device pinout are validated.
- Programmable kernel/runtime layer to support changing model architectures and operator fusion.

This is a direction for the accelerator architecture, not a completed RTL specification, proven PPA result, or tapeout-ready chip.

## Prototype strategy
Keep the pinned FeSens/openTPU code as a software/workload reference and keep experimental work on the current branch. Use reproducible simulation and rented accelerator systems to validate workloads before committing to a costly FPGA board or custom silicon.
The existing Chipyard/Rocket + Gemmini + Verilator/SymbiYosys/Yosys/OpenROAD reference stack remains a candidate for a small, reproducible RTL prototype. It is not evidence that a 128 GB memory configuration or commercial system has been implemented.

## Memory-controller correction from current AMD guidance
AMD UG1273 2026.1 explicitly recommends the integrated DDR memory controller rather than the soft memory controller for new Versal designs. The integrated DDR controller is accessed through the NoC; it supports DDR4 up to 4266 Mb/s and supports RDIMM/LRDIMM subject to device/package and interface constraints.
AMD PG313 1.1 memory configuration tables specify supported DIMM topology: RDIMM up to two physical ranks and two slots; LRDIMM up to four ranks in one slot or two ranks in two slots. For a 64-bit ECC DIMM interface, PG313 lists x8/x16 DDR4 and x8 DDR4 3DS components (not x4 in that interface table). AMD DS957's Versal AI Core rate table gives 2-rank RDIMM in a dual-slot configuration a maximum 2133 Mb/s, versus 2667 Mb/s for 1-rank RDIMM in dual-slot and 2933 Mb/s for 2-rank RDIMM in a single slot. These rate limits are device-family/operating-condition specific and must not be generalised to every Versal family. These tables do not establish that a particular Versal part/package can route a chosen 128 GB or 256 GB DIMM set.
Therefore:
1. Evaluate integrated NoC DDR first for a Versal candidate.
2. Keep PG353 soft DDR as a conditional option only if integrated-controller pin availability, device resources, required topology or latency/architecture justify it.
3. Do not choose a Versal part until AMD Memory Interface Planning Tool and package pinout confirm the exact controller count, DDR interface width, ECC, DIMM topology, speed bin, ranks, density, 3DS support, and remaining I/O.
4. Do not claim 128 GB/256 GB supported from controller marketing tables alone.
5. A more credible 128 GB hypothesis is four independent 64-bit ECC channels, each with one 32 GB 2-rank x8 RDIMM (4 × 32 GB). AMD lists four DDRMCs for VC1802 and VC1902. Lenovo's memory reference lists 32 GB 2Rx8 RDIMM-A part 4ZC7A15123 and 4X77A12188 as candidate module references; neither is yet proven compatible with Versal SPD/training.
6. Lead feasibility device/package: VC1802 / VSVD1760. Alternative: VC1902 / VSVD1760 for higher compute. AMD lists VC1802 with four DDRMCs, 300 AI Engine tiles and 1,600 DSP engines; VC1902 has four DDRMCs, 400 AI Engine tiles and 1,968 DSP engines. AMD AM013 lists both devices in VSVD1760. This is a lead down-select for Vivado/tool verification, not a final orderable part or purchase approval.
7. For the initial one-slot, two-rank RDIMM topology, AMD DS957 lists up to 2933 Mb/s for Versal AI Core conditions. Theoretical four-channel payload peak is 4 × 64 bits × 2.933 GT/s ÷ 8 = 93.856 GB/s decimal, before protocol/NoC/controller losses; it is not a measured bandwidth result.
5. Treat 128 GB as a conditional topology hypothesis only: e.g. two 64 GB RDIMMs in a supported dual-slot configuration would require the exact 64 GB modules to meet PG313's supported x8/3DS component and rank rules, and the exact Versal device/package to expose the required controller pins. Do not assume ordinary 64 GB 2Rx4 server DIMMs are compatible.
6. Include the data-rate penalty of dual-slot/rank choices in bandwidth modelling; capacity can increase while per-controller data rate falls.

Official references:
- AMD UG1273 2026.1, Soft Memory Controllers: https://docs.amd.com/r/2026.1-English/ug1273-versal-acap-design/Soft-Memory-Controllers
- AMD UG1273 2026.1, DDR Memory Controller: https://docs.amd.com/r/2026.1-English/ug1273-versal-acap-design/DDR-Memory-Controller-for-DDR4-LPDDR4-and-LPDDR4X
- AMD PG313 1.1, Memory Configuration Support: https://docs.amd.com/r/en-US/pg313-network-on-chip/Memory-Configuration-Support
- AMD DS957, Versal AI Core DDR4/LPDDR4 controller data rates: https://docs.amd.com/r/en-US/ds957-versal-ai-core/DDR4-and-LPDDR4/4X-Memory-Interface-Controller
- AMD PG313 1.1, DDR4 RDIMM/LRDIMM interfaces: https://docs.amd.com/r/en-US/pg313-network-on-chip/DDR4-RDIMM-and-LRDIMM-Interfaces
- AMD Versal AI Core series device resources: https://www.amd.com/en/products/adaptive-socs-and-fpgas/versal/ai-core-series.html
- AMD AM013 VC1802 package bank diagrams: https://docs.amd.com/r/en-US/am013-versal-pkg-pinout/Bank-Diagram-by-Package-for-VC1802
- AMD AM013 VSVD1760 VC1802 pin map: https://docs.amd.com/r/en-US/am013-versal-pkg-pinout/VSVD1760-Package-VC1802-Pin-Map
- Lenovo ThinkSystem Memory Reference: https://lenovopress.lenovo.com/lp1021-lenovo-thinksystem-memory-reference
- AMD PG353, Soft DDR4 Controller: https://docs.amd.com/r/en-US/pg353-versal-acap-soft-ddr4-mem-ip

## Why no exact chip/part is selected yet
A final part choice would currently be false precision. The blocking evidence is:
- No measured W1/W2/W3 workload distribution, model mix, SLA or paying-customer demand.
- No equivalent rented-GPU benchmark and no calibrated wall-power measurements.
- No measured SRAM/bandwidth requirement derived from model traces and concurrency.
- No completed Vivado memory-planning report or verified four-controller pinout for the lead VC1802 / VSVD1760 candidate.
- No verified 128 GB RDIMM BOM, supplier availability, cost, thermal and signal-integrity design.
- The new SUNNYONE benchmark-harness CI (run 45069537101) passed Python compilation and all six deterministic unit tests. The older openTPU emulator/Python qualification run 45065688493 remains stale/in_progress with no artifacts; its job logs are unavailable, so it is not a pass.
- No synthesis/PPA, timing closure, place-and-route, thermal, reliability, or physical-board validation for a SUNNYONE candidate.
- No customer commitments, paid pilot, or validated willingness-to-pay.

## Selection gates
A specific prototype part may be selected once:
1. W1/W2/W3 workload benchmark is pinned and reproducible.
2. Model licence and serving runtime are verified.
3. Minimum memory capacity/bandwidth is calculated from real traces.
4. Candidate device/package passes official memory planning and pinout checks.
5. Resource, clock, power, thermal, PCB, and tool/licensing costs are estimated from vendor tools and actual quotes.
6. Comparable rented-GPU benchmark and first unit-economics scenario show a credible path to contribution margin.
7. RTL simulation, lint, formal checks, synthesis and implementation meet stated acceptance criteria.

A final commercial chip/ASIC selection additionally requires validated customer demand, manufacturing/packaging/test quotes, risk-adjusted cash flow and an independently reviewed physical-design signoff plan.

## Current selection status
- Architecture direction: SELECTED (provisional engineering baseline).
- Versal integrated NoC DDR: FIRST ROUTE TO EVALUATE; four-channel VC1802 / VSVD1760 is the lead tool-feasibility candidate, not final silicon.
- Versal PG353 soft DDR: CONDITIONAL ALTERNATIVE.
- 128 GB DDR4 RDIMM: four-channel 4 × 32 GB 2Rx8 hypothesis, not proven.
- 256 GB: stretch investigation only.
- Exact FPGA/SoC device/package: lead candidate VC1802 / VSVD1760; final selection pending Vivado/pinout, DIMM and economic validation.
- Final ASIC/production chip: NOT SELECTED.
- Production readiness/tapeout: NOT CLAIMED.
