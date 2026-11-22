> **HISTORICAL / SUPERSEDED — 2026-11-23:** This document records an earlier feasibility investigation only. The 30 W ceiling has been retired, MPFS250T is not the current primary architecture candidate, and its 32 GB target is not the governing memory target. Use `MEMORY_CAPACITY_DECISION.md` and `ARCHITECTURE_DIRECTION_AND_CHIP_SELECTION_GATE_2026-11-23.md` for current decisions. Do not treat this file as a current design selection or validated capacity claim.

# MPFS250T 32 GB DDR4 — Package and Controller Feasibility Addendum

Status: **Design decision update — feasibility still open**
Date: 2026-11-23
Applies to: `docs/sunnyone/MPFS250T_32GB_DDR4_30W_TARGET.md`

## Executive finding

Do not select MPFS250T-FCVG484 as the 32 GB DDR4 target package without a new, proven interface plan.

Microchip's PolarFire SoC package table shows:
- MPFS250T-FCVG784 has HSIO Bank 0 and HSIO Bank 8.
- MPFS250T-FCVG484 has HSIO Bank 0 but no HSIO Bank 8.
- The PolarFire SoC Video Kit DDR4 example uses HSIO Banks 0 and 8 to create a 64-bit fabric DDR4 interface.

Therefore the **provisional package candidate is MPFS250T-FCVG784**, not FCVG484, if the intended architecture is a 64-bit fabric DDR4 interface. This is a package-level direction, not a confirmed 32 GB memory implementation. Final pin mapping must use the exact MPFS250T FCVG784 PPAT and current Libero DDR configurator.

## Controller distinction — do not conflate these interfaces

### MSS DDR controller

The current PolarFire SoC Memory Controller User Guide states:
- MSS DDR4 data width can be enhanced up to x32.
- Dual-rank DDR4 is supported.
- Maximum supported total memory density for the MSS DDR controller is 128 Gb for memory case temperature below 95 °C, 32 Gb below 105 °C, and 8 Gb below 125 °C.

128 Gb is 16 GB, not 32 GB. Thus the published MSS DDR4 configuration limits do **not** establish 32 GB on the MSS DDR interface. Do not use the MSS DDR controller as the assumed path for the 32 GB requirement.

### FPGA-fabric DDR controller

Microchip documents a separate Fabric DDR subsystem comprising the soft DDR controller, training logic, hard I/O lane and PLL. It supports DDR initialization, refresh and calibration. The PolarFire SoC Video Kit demonstrates a 64-bit DDR4 fabric interface using HSIO Banks 0 and 8.

However, the sources reviewed here do not yet establish that a 32 GB non-3DS DDR4 topology is supported by the exact MPFS250T-FCVG784 + current Fabric DDR IP combination. That must be demonstrated in Libero using the exact device, package, speed grade, memory part number, rank count and timing configuration.

## Updated package decision

| Candidate | Decision | Reason |
|---|---|---|
| MPFS250T-FCVG484 | Do not freeze for 32 GB DDR4 | No HSIO Bank 8; not the demonstrated Banks 0+8 x64 fabric DDR arrangement |
| MPFS250T-FCVG784 | Provisional preferred package | Has HSIO Banks 0 and 8; package family supports the wider fabric memory interface direction |
| MPFS250T-FCG1152 | Alternate if pinout/routing/expansion needs justify it | Larger package; evaluate only if FCVG784 pin budget or routing fails |

## 32 GB DDR4 proof required before PCB design

1. Obtain the MPFS250T-FCVG784 exact PPAT and verify the DDR4 placement anchor, all DQ/DQS/DM/DBI/address/control pins, bank supplies and reserved pins.
2. In the current Libero release, instantiate Fabric DDR IP for MPFS250T-FCVG784 and confirm a 64-bit DDR4 interface is accepted for the selected speed grade.
3. Select a supported non-3DS DRAM topology that yields at least 32 GB usable capacity. Confirm density per component, device width, ranks, row/column/bank geometry, refresh and timing parameters.
4. Confirm whether ECC is supported at the chosen width and how it affects usable capacity and pin count.
5. Run IP generation, implementation, timing analysis and memory-controller simulation before schematic freeze.
6. Validate the PCB fly-by topology, impedance, length matching, VREF/VTT, termination, power integrity and thermal conditions against Microchip's layout guide and the DRAM vendor's data sheet.
7. If any step fails, reduce capacity or change to a larger device/package. Do not proceed on an assumed configuration.

## Performance implication

At a hypothetical x64 DDR4 data path:
- DDR4-1600 theoretical raw bandwidth: 12.8 GB/s.
- DDR4-2400 theoretical raw bandwidth: 19.2 GB/s.

These are arithmetic interface ceilings only. The actual MPFS250T Fabric DDR IP speed grade and memory topology must support the chosen data rate; sustained bandwidth must be measured. Do not use these figures as measured throughput or token generation claims.

## Gate status

- MPFS250T product candidate: selected for investigation.
- FCVG784 package: provisional selection for x64 fabric DDR4 investigation.
- MSS DDR4 32 GB: not supported by the published MSS maximum-density limit reviewed here.
- Fabric DDR4 32 GB: **NOT VERIFIED** for the exact MPFS250T-FCVG784 configuration.
- 30 W total board power: **NOT VERIFIED**.
- LLM token/s, latency and tokens/J: **NOT TESTED**.

## Official source documents reviewed

- Microchip PolarFire SoC packaging overview: package bank availability for MPFS250T-FCVG784 and MPFS250T-FCVG484.
- Microchip PolarFire SoC Memory Controller User Guide (DS00004154J): MSS DDR4 width, dual-rank support and maximum memory density.
- Microchip PolarFire SoC Video Kit User Guide: example 64-bit fabric DDR4 interface using HSIO Banks 0 and 8.
- Microchip PolarFire Family Memory Controller User Guide: Fabric DDR subsystem and configuration flow.

This addendum supersedes any implication in the initial target note that a 32 GB DDR4 MSS interface or an FCVG484 package was already established.
