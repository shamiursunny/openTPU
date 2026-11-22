# SUNNYONE AI-X — Open-Toolchain FPGA Platform Down-Select (A1.12.11.16.41)

Date: 2026-11-23
Status: architecture decision / desk research only; no board purchase authorised.

## Decision

**Do not buy an FPGA board yet.** Continue RTL simulation, formal verification and workload-harness development on the existing free environment. No currently evidenced open-toolchain-compatible board is remotely close to the project's provisional 128 GB external-memory target or proven commercial inference requirements.

If a later, explicitly approved low-cost hardware-learning prototype is justified, prefer an **ECP5 board with documented external DDR3** for the most mature open-source bitstream flow. Consider Gowin GW2A only where a very small, low-cost control/dataflow demonstrator is the objective. Neither is a substitute for the Versal VC1802 target.

## Evidence-based comparison

| Platform | Open flow status | Memory / practical limitation | SUNNYONE suitability |
|---|---|---|---|
| Lattice ECP5 | Project Trellis + Yosys + nextpnr-ecp5: mature | Board-specific DDR3; vendor ECP5 Versa page lists DDR3 components and says ECP5 supports up to 800 Mb/s. Example hobby boards may have only tens to hundreds of MB; verify exact board BOM. | Best open-flow physical prototype path for DMA, streaming, controller, small matrix-engine and memory-interface experiments. Not an LLM-capacity platform. |
| Gowin GW2A / GW2AR | Apicula + Yosys + nextpnr-himbaechel: usable for supported GW2A devices | Tang Nano 20K includes 64 Mbit SDR SDRAM (8 MB) per current board references; in-package memory is far below model-serving needs. | Cheap small-logic demonstrator; insufficient memory for meaningful model serving. |
| Gowin GW5A / GW5AST | Apicula support is uneven: GW5A-25A supported; larger GW5AT/GW5AST still early/basic per current project notes | Exact board memory and hard-IP coverage must be checked per part. | Do not select as the first reproducible hardware target until exact device and flow are proven. |
| AMD 7-Series | Project X-Ray/openXC7: experimental/partial; transceivers and PCIe limitations remain | Board-specific DDR3 possible, but hard blocks/timing/SerDes support incomplete. | Not preferred over mature ECP5 for an open-flow prototype. |
| AMD Versal VC1802 | No complete open-source implementation/bitstream flow | Requires supported AMD Vivado/Vitis access for device-specific implementation and DDRMC/NoC integration. | Retain as long-term feasibility candidate only; currently blocked by licensing and unverified memory topology. |
| iCE40 | IceStorm + Yosys + nextpnr: mature | Small fabric and limited on-chip memory; not an external-memory AI accelerator platform. | Controller, peripheral and tiny RTL exercises only. |

## Evidence and limits

- FPGA Guide's 13 Nov 2026 open-source toolchain overview reports mature ECP5 Trellis support, usable GW1N/GW2A Apicula support, GW5A support still developing, and experimental AMD 7-Series support: https://www.fpgaguide.com/topics/open-source-toolchains/
- Apicula's own repository lists supported boards including Tang Nano 20K (GW2AR), Tang Primer 20K (GW2A), Tang Primer 25K and larger GW5A boards; its device notes distinguish supported parts from early/incomplete variants: https://github.com/YosysHQ/apicula
- Lattice's ECP5 Versa page lists DDR3 memory components, Ethernet and PCIe x1, but states ECP5 DDR3 support up to 800 Mb/s. This is board-specific and not a claim about all ECP5 boards: https://www.latticesemi.com/products/developmentboardsandkits/ecp5versadevelopmentkit
- Public board listings show materially different memory configurations and indicative prices; prices/availability are not supplier quotes and must be rechecked before any purchase: https://boards.fpgadeveloper.com/list-of-fpga-dev-boards-by-device/

## Quantitative guardrails

- Tang Nano 20K's cited 64 Mbit SDR SDRAM = 8 MB decimal, not 64 MB or 64 GB.
- Even a 256 MB ECP5 board (if verified for the exact SKU) is 512 times smaller than 128 GB. It cannot validate the target model capacity.
- External DDR bandwidth, capacity and controller support are board-specific; do not infer them from FPGA LUT/DSP counts.
- Open-source place-and-route support does not guarantee vendor hard-IP support, DDR training, timing closure, SerDes, PCIe, or production reliability.

## Work permitted now without spending

1. Keep the pinned FeSens/openTPU source baseline unchanged.
2. Continue portable RTL modules and tests: DMA descriptor/control logic, AXI-stream adapters, SRAM banking, arbitration, ECC test logic, tiled MAC datapath, backpressure and reset/error handling.
3. Use Verilator for simulation/lint, SymbiYosys for formal properties, Yosys for generic synthesis estimates, and CI for reproducibility.
4. Add an ECP5 generic synthesis/constraint target only after checking the exact board/device and primitive mapping. Do not claim bitstream support until a clean nextpnr build succeeds for that target.
5. Keep all model serving and commercial performance claims blocked until a real endpoint benchmark, representative quality set, calibrated wall-power measurement and repeatable sustained test exist.

## Purchase gate

A board may be proposed only after:
- a specific SKU and exact FPGA part are pinned;
- manufacturer schematic/BOM confirms external memory type, capacity, width and topology;
- the chosen open flow demonstrably builds and programs that exact board;
- the planned test can answer a stated engineering question that simulation cannot;
- total landed cost, shipping, tax, programmer, power and replacement risk are quoted;
- the user explicitly approves the spend.

## Final disposition

**Current route: software-first, zero-spend.** ECP5 is the preferred *future* open-flow prototype family, not a selected product. Versal remains the higher-capacity long-term path subject to Vivado access and memory-planner validation. No FPGA, accelerator, memory configuration, commercial performance or production design is physically qualified by this milestone.
