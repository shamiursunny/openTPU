# SUNNYONE AI-X — Memory, power and commercial architecture decision

Date: 2026-11-23
Status: planning decision only. No selected production device, validated memory topology, physical prototype, measured power, benchmark result, or profitability claim.

## 1. Commercial objective and power policy

The user has retired the former 30 W total-system ceiling. Power may increase when the additional sustained useful throughput and contribution margin justify the incremental hardware, electricity, cooling, maintenance, reliability and capital costs.

**Primary objective:** maximise risk-adjusted long-term net profit and achieve the fastest realistic recovery of initial investment, while providing reliable and competitive AI inference.

There is no replacement wattage ceiling yet. Do not maximise watts, RAM capacity, peak TOPS or chip size in isolation. Derive the system power envelope from measured workload performance and a full-system total-cost-of-ownership (TCO) model.

A higher-power configuration is accepted only when its incremental contribution margin exceeds its incremental total cost and its reliability/capital risk remains commercially acceptable.

## 2. Memory decision

Do not freeze Microchip PolarFire SoC MPFS250T as the primary device if 128 GB external RAM is a hard requirement. Microchip's MSS DDR4 controller documentation states up to 128 Gb total (16 GB) under specified temperature conditions and maximum 16 Gb die density. The separate fabric DDR route requires its own exact device/package/IP proof; no 32 GB or 128 GB MPFS250T configuration is established here.

AMD Versal PG353 Soft DDR4 controller documentation lists DDR4 RDIMM up to 256 GB and LRDIMM up to 256 GB, and SODIMM up to 128 GB, including 3DS DIMM support. This is controller-IP capability, not proof that a particular Versal device/package and board support a specific DIMM.

- Initial high-capacity feasibility target: 128 GB ECC DDR4 RDIMM.
- Stretch investigation: 256 GB RDIMM/LRDIMM, only after exact device, package, controller, DIMM topology and PCB feasibility are proven.
- Capacity is not throughput. Evaluate bandwidth, rank/3DS support, latency, memory-controller efficiency, KV-cache traffic, concurrency and cost.
- A memory size is justified only when the target workload's working set, model residency, KV cache or concurrency produces measurable economic value.

## 3. DDR architecture down-select — not yet frozen

Compare two Versal routes for the exact candidate device/package:
1. Integrated Versal NoC DDR memory controller and supported external-memory interfaces.
2. PG353 soft DDR4 SDRAM controller.

Compare achievable capacity, bandwidth, latency, ECC, supported DIMM topology, pinout, XPIO/NoC resource use, clocking, power, Vivado support, implementation complexity, PCB signal integrity and cost. Use the exact AMD Memory Interface Planning Tool output, device/package documentation and generated IP configuration. Do not assume PG353 is automatically superior because its guide lists larger DIMM capacities.

Do not name or freeze a Versal part number until both memory feasibility and resource/power economics have been checked.

## 4. Candidate commercial configurations

Evaluate at least three candidates with identical workloads, models, quantisation quality, context lengths, concurrency, latency targets and uptime assumptions:

- Efficient: minimum practical compute/memory configuration with low capital and operating cost.
- Balanced: best expected long-term contribution margin and capacity to scale.
- High-throughput: higher compute, memory bandwidth/capacity, power and cooling where incremental revenue can justify them.

For every candidate include accelerator/board, RAM, PCB, power delivery, cooling, storage, networking, assembly, development/NRE, deployment, spares and replacement reserve.

## 5. Financial model requirements

Use three demand cases: conservative, base and upside. Do not assume full utilisation or guaranteed customers.

Monthly revenue = billable useful output (or contracted capacity) × realised selling price, less discounts, credits, failed/invalid work and payment leakage.

Monthly operating cost must include:
- electricity from measured wall/input power × operating hours × actual tariff, with cooling overhead and power-conversion losses accounted for;
- hosting/site, network, storage, maintenance, support, software, monitoring, security and administration;
- depreciation/replacement reserve, spares, downtime and financing costs where applicable;
- customer acquisition, payment processing, tax and other applicable costs.

Monthly operating cash flow = collected revenue − cash operating costs − financing payments (show pre-tax and post-tax treatments separately where applicable).

Break-even utilisation = fixed monthly costs / contribution available per unit of billable utilisation, using a clearly defined workload and pricing unit. State the algebra and assumptions; do not mix gross margin with net profit.

Payback period is the first month cumulative net project cash flow recovers initial investment. Show cash-flow timing, working capital, ramp-up, replacement capex and scenario sensitivity. If payback is not achieved in the forecast horizon, state that plainly.

Core technical/economic measures:
- sustained useful tokens/s and tokens/J at the wall, not peak kernel TOPS;
- first-token latency and inter-token p50/p95/p99;
- model quality/accuracy and task completion quality;
- uptime, failure rate, thermal throttling and sustained stability;
- cost per million useful tokens = attributable total operating cost / useful output tokens × 1,000,000;
- revenue per million useful tokens and contribution margin;
- monthly fixed-cost coverage, break-even utilisation, operating cash flow and payback.

Vendor claims are comparison references, not SUNNYONE performance evidence. Benchmark against commercially available alternatives on equivalent models, precision, context, concurrency, software and service levels.

## 6. Product and revenue strategy

Evaluate both business routes in the financial model:
- Operate SUNNYONE inference infrastructure and sell API/service access.
- Sell, lease or license accelerator hardware/software to customers or infrastructure providers.

Also assess a hybrid route. Do not assume API service is automatically superior: customer acquisition, utilisation, pricing, support and working capital may make hardware licensing or a hybrid more attractive. Validate demand through interviews, letters of intent, paid pilots or other documented evidence before production-scale capex.

## 7. Architecture direction (provisional)

- External DDR: model weights and large KV cache.
- On-chip BRAM/URAM/SRAM: hot tiles, activations, queues and DMA staging.
- Tiled quantised matrix engine: INT8 correctness baseline; INT4 only after accuracy, overflow and stability tests.
- DMA with bounded queues, backpressure and observable errors.
- Memory QoS to prevent CPU, DMA, inference and telemetry starvation.
- ECC/error reporting, memory training, refresh, watchdog, reset/recovery and thermal/power telemetry.
- Model serving, batching, scheduling, quantisation and runtime optimisation are part of the product, not optional extras.

The openTPU BCU1525/VU9P design remains a software/workload and implementation reference, not a validated candidate for the new 128 GB commercial platform. The pinned upstream source baseline remains FeSens/openTPU commit d84db55712aba0d40811d7762cb052f05d55b7e5. Keep main and the reference baseline unchanged.

## 8. Next procedures and evidence gates

1. Define target customer segments and representative workloads (model families/sizes, context, concurrency, prompt/decode mix, latency and quality).
2. Compare API service, hardware sale/licensing and hybrid revenue routes; gather customer evidence and realistic price benchmarks.
3. Build the conservative/base/upside TCO and cash-flow model using sourced quotations and the actual Bangladesh operating context where relevant.
4. Define candidate system configurations and calculate the minimum memory capacity/bandwidth needed for each workload.
5. Compare integrated Versal NoC DDR and PG353 soft DDR; validate 128 GB DIMM part number, ECC, ranks, 3DS, density, timing and training.
6. Select exact Versal device/package only after Memory Interface Planning Tool, package pinout, resource and power checks.
7. Produce architecture/resource estimates, Vivado synthesis/timing reports, and AMD Power Design Manager estimates under realistic worst-case clocks/activity.
8. Design PCB SI/PI/thermal and power delivery; obtain manufacturing and component quotations.
9. Prototype and measure wall power, memory bandwidth/latency, thermals and sustained inference.
10. Benchmark identical workloads against alternatives; report tokens/s, tokens/J, latency percentiles, accuracy, uptime and cost per useful token.
11. Run long-duration tests, memory stress, ECC/error injection, reset/recovery and fault handling.
12. Recalculate unit economics using measured performance and actual costs; proceed to production investment only if customer demand and risk-adjusted returns justify it.

## 9. Current status

| Item | Status |
|---|---|
| 30 W hard ceiling | RETIRED by user |
| Replacement power envelope | NOT SELECTED; derive from economics and measurements |
| Primary objective | Risk-adjusted long-term profit and realistic investment recovery |
| 128 GB DDR4 RDIMM | Feasibility target; exact Versal support NOT VERIFIED |
| 256 GB RDIMM/LRDIMM | Stretch investigation only |
| Versal device/package | NOT SELECTED |
| Integrated DDR vs PG353 | Comparison REQUIRED |
| TCO, pricing, revenue, break-even, payback | NOT CALCULATED |
| Customer demand / paid pilot | NOT VERIFIED |
| Versal RTL, synthesis, timing, PCB | NOT STARTED |
| Physical power, thermal and inference results | NOT MEASURED |

## Official technical references

- AMD Versal Soft DDR4 SDRAM Memory Controller PG353: https://docs.amd.com/r/en-US/pg353-versal-acap-soft-ddr4-mem-ip/Features
- AMD Versal Memory overview: https://www.amd.com/en/products/adaptive-socs-and-fpgas/technologies/memory.html
- AMD Versal 2026.1 UG1273 memory controller guidance: https://docs.amd.com/r/en-US/2026.1/ug1273-versal-acap-design/Soft-Memory-Controllers
- AMD Power Design Manager guidance: https://docs.amd.com/r/2024.1-English/ug1556-power-design-manager/Device-Configuration
- Microchip PolarFire SoC MSS DDR density notice DS00005474A: https://ww1.microchip.com/downloads/aemDocuments/documents/FPGA/ProductDocuments/SupportingCollateral/cia/Update_to_the_Maximum_Supported_DDR_Memory_for_the_PolarFire_SoC_MSS_DDR_Controller.pdf

This document records a planning decision and procedure. It does not claim a generated controller, selected device, validated PCB, working 128 GB system, measured performance/power, profitability, silicon readiness or qualification.
