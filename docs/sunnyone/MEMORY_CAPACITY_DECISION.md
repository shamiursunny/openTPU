# SUNNYONE AI-X — Maximum RAM decision (2026-11-23)

Status: architecture decision only; no hardware implementation or qualification claimed.

## Decision

Do not freeze MPFS250T as the primary device if 128 GB external RAM is a hard requirement. Microchip's MSS DDR4 controller is documented for up to 128 Gb total (16 GB) at specified memory case temperatures and a maximum 16 Gb die. Its separate fabric DDR interface needs its own device/package/IP proof; no 32 GB or 128 GB MPFS250T configuration is established here.

For a 128 GB DDR4 target, investigate AMD Versal Adaptive SoC Soft DDR4 Memory Controller IP (PG353). AMD's guide lists support for DDR4 RDIMM up to 256 GB and LRDIMM up to 256 GB, with 3DS DIMM support, and SODIMM up to 128 GB. This is controller-IP capability, not proof that every Versal device/package can support the configuration.

**Primary target for feasibility:** 128 GB ECC DDR4 RDIMM on a precisely selected Versal device/package, using the Soft DDR4 controller if the AMD Memory Interface Planning Tool and exact device/package pinout approve it.

**Upper-bound investigation:** 256 GB RDIMM/LRDIMM only after exact 3DS, rank, density, package, controller and PCB compatibility are proven. Do not call this the committed target.

## 30 W conflict

No reviewed source proves that a Versal device plus 128 GB RDIMM, regulators, storage, networking and cooling can remain below 30 W during sustained inference. 30 W remains an unverified hard requirement. Run AMD Power Design Manager with worst-case process and realistic clocks/activity, include DIMM and board power, then measure prototype input power. If the 128 GB configuration exceeds 30 W, the requirements conflict; do not claim both.

## Why MPFS250T is not the 128 GB choice

Microchip's PolarFire SoC MSS DDR4 documentation states:
- up to x32 DDR4 data width and dual rank;
- maximum total DDR4 density 128 Gb (16 GB) below the stated temperature limit, with maximum die density 16 Gb;
- lower allowed total density at higher memory case temperatures.
The standard Icicle Kit has 2 GB LPDDR4, not 32/128 GB DDR4.

MPFS250T remains a possible lower-power alternative only if its independently validated fabric-DDR capacity is sufficient and the user accepts a smaller memory target.

## Required gates before freezing the Versal part

1. Select exact device, package, speed grade and temperature grade.
2. Generate PG353 configuration for the intended DDR4 RDIMM and prove the supported 128 GB topology.
3. Confirm DIMM vendor part number, 3DS status, ranks, DRAM die density, ECC width, timing and refresh.
4. Use AMD Memory Interface Planning Tool and package pinout to verify XPIO banks, byte lanes, clocks, address/control pins and voltage rails.
5. Complete PCB signal-integrity, impedance, length matching, termination, power-integrity and thermal design.
6. Generate Vivado implementation, timing and resource reports.
7. Run memory training, full-address tests, stress, ECC/error injection and reset/recovery tests on hardware.
8. Estimate worst-case board power in Power Design Manager; later measure idle, prefill, sustained decode and stress.
9. Benchmark tokens/s, tokens/J, first-token latency, inter-token p50/p95/p99, model accuracy and 8-hour stability.

## Design architecture

- DDR4: model weights and large KV cache.
- On-chip SRAM/BRAM/URAM: hot tiles, activations, queues and DMA staging.
- Accelerator: tiled quantised matrix engine; INT8 correctness baseline, INT4 only after accuracy/overflow validation.
- Runtime: memory QoS, bounded DMA queues, watchdog, ECC/error telemetry, temperature/power monitoring and controlled recovery.
- Optimise sustained tokens/J and latency, not peak TOPS alone.

## Status

| Item | Status |
|---|---|
| 128 GB DDR4 RDIMM controller capability | Documented by AMD PG353; exact device/package not selected |
| 128 GB on selected Versal device | NOT VERIFIED |
| 256 GB option | Controller guide upper-bound; exact topology NOT VERIFIED |
| 30 W total system | NOT VERIFIED |
| RTL / synthesis / timing | NOT STARTED for Versal |
| Physical DDR training and stress | NOT STARTED |
| LLM performance and thermal stability | NOT TESTED |

## Official references

- AMD Versal Soft DDR4 SDRAM Memory Controller PG353: https://docs.amd.com/r/en-US/pg353-versal-acap-soft-ddr4-mem-ip/Features
- AMD Versal Memory overview: https://www.amd.com/en/products/adaptive-socs-and-fpgas/technologies/memory.html
- AMD Power Design Manager guidance: https://docs.amd.com/r/2024.1-English/ug1556-power-design-manager/Device-Configuration
- Microchip PolarFire SoC MSS DDR density notice DS00005474A: https://ww1.microchip.com/downloads/aemDocuments/documents/FPGA/ProductDocuments/SupportingCollateral/cia/Update_to_the_Maximum_Supported_DDR_Memory_for_the_PolarFire_SoC_MSS_DDR_Controller.pdf

This is a truthful architecture down-select, not a generated DDR controller, bitstream, validated PCB, measured 128 GB system or qualified 30 W chip.


## Commercial objective and revised power policy (2026-11-23)

The user has explicitly removed the former 30 W total-system ceiling. Power may increase when the additional throughput and revenue justify the incremental capital, electricity, cooling, maintenance and reliability costs.

**New primary objective:** maximise risk-adjusted long-term net profit and achieve the fastest realistic investment recovery, while delivering reliable, competitive AI inference. Do not maximise watts, RAM capacity, peak TOPS or chip size in isolation. No replacement wattage ceiling is approved; derive the power envelope from workload benchmarks and a full-system TCO model.

Compare at least three candidate configurations (efficient, balanced and high-throughput) using the same workloads, model quality, context lengths, concurrency and latency targets. For each, account for:
- accelerator, memory, PCB, assembly, development/NRE, depreciation and replacement reserve;
- effective memory bandwidth and capacity utilisation, not capacity alone;
- whole-system power including SoC/FPGA, DRAM, regulators, storage, network and cooling;
- electricity tariff, cooling overhead, maintenance, software and operations;
- sustained useful tokens/s, latency distribution, accuracy, uptime and real utilisation;
- realised selling price, billable utilisation, monthly revenue, fixed-cost coverage, operating cash flow, break-even utilisation and payback period.

Use cost per million useful tokens as a core comparison:
(monthly attributable TCO / monthly useful output tokens) × 1,000,000.
Vendor benchmark figures are reference claims, not SUNNYONE performance evidence. Validate with reproducible workloads and physical measurements. A larger RAM configuration is justified only when workload working-set, KV-cache, concurrency or model-serving economics support its cost. More watts are justified only when incremental contribution margin exceeds incremental total cost.

AMD UG1273 2026.1 recommends considering the integrated Versal DDR memory controller rather than automatically selecting the soft DDR4 controller. Compare the integrated NoC DDR route and PG353 soft DDR route for the exact device/package, including capacity, bandwidth, latency, pinout, power and implementation risk, before platform freeze:
https://docs.amd.com/r/en-US/2026.1/ug1273-versal-acap-design/Soft-Memory-Controllers

Required next gate: establish target customer/workload and service model, obtain real hardware and electricity quotations, build conservative/base/upside unit economics, then select device/package and power envelope. No profitability, payback, full-system power, 128 GB physical operation or silicon qualification is claimed at this stage.

Status: 30 W hard ceiling RETIRED by user; new power envelope NOT YET SELECTED; TCO, revenue, break-even and payback NOT CALCULATED; exact Versal device/package NOT SELECTED.
