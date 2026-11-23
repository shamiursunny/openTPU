# SUNNYONE AI-X — Hardware and Process Selection

**Revision:** A1.12.11.16.49  
**Date:** 2026-11-24  
**Status:** WG8 logical ASIC architecture selected; physical FPGA and ASIC process remain gated by zero-spend/toolchain constraints

## 1. Decisions

| Layer | Decision | Meaning |
|---|---|---|
| AI accelerator architecture | WG8 / D128 / 8 × 128-byte logical channels / 32-GiB V1 addressable memory | Primary logical ASIC candidate; still under RTL/PPA verification |
| Performance reference | BCU1525 / VU9P / WG8 | Golden board model and workload benchmark only; not the authorised physical prototype |
| ASIC PCIe interface target | Gen3 x16 | Compatibility requirement derived from BCU1525; endpoint/PHY IP not selected |
| ASIC process / package | Not selected | Requires real PDK, SRAM compiler, PCIe PHY, memory IP, package and signoff evidence |
| Zero-cost FPGA flow | ECP5 family with Yosys + nextpnr + Project Trellis | Reduced RTL demonstrator only; cannot host the WG8 design |
| High-capacity FPGA lead | AMD Versal VC1802 / VSVD1760 | Previously investigated, but blocked by paid Vivado PRO/Enterprise requirement; no licence/evaluation authorised |

## 2. Physical FPGA reality

- BCU1525/VU9P is the correct **performance reference** because the repository has the WG8 board model, four DDR4 DIMM path and real-model comparisons. However, the repository's board instructions require a VU9P-capable Vivado licence; this conflicts with the zero-spend constraint. Do not buy or treat it as the next physical prototype unless access to an existing licensed setup is established.
- ECP5-5G Versa (LFE5UM5G-45F-VERSA-EVN) is the most defensible small open-tool demonstrator: ECP5-5G, PCIe x1 edge, one 64M ×16 DDR3 device (1-Gbit density; 128 MiB), USB programming and two Ethernet ports. Project Trellis supports a Yosys/nextpnr open-source flow and lists the ECP5-5G Versa among tested boards.
- **Critical limitation:** the open ECP5 PCIe path is not production-ready. The katsuo.pcie stack describes itself as a proof of concept, mostly Gen1 x1, with unstable SerDes initialisation, incomplete LTSSM, no retransmission and no flow control. The LitePCIe project does not list a native ECP5 PHY. Therefore ECP5-5G Versa may be used for reduced control/compute and raw SerDes experiments, but it is not a qualified PCIe DMA platform for this accelerator.
- Lattice's separate ECP5 PCI Express Development Kit is marked no longer available. Do not select it as a purchase path.
- ECP5 has at most 85K LUTs and the Versa board's 128-MiB DDR3 is orders of magnitude below WG8's 32-GiB logical memory. It cannot fit or validate the full WG8 design. It is only a reduced demonstrator.
- Earlier VC1802/VSVD1760 research proposed four DDR controllers and 128-GiB ECC memory, but those capacity/bandwidth figures were estimates, not validated implementation results. The design flow requires Vivado PRO/Enterprise; this is expressly excluded by the user's no-paid-license constraint. VC1902 remains only a higher-compute alternative, not selected.

## 3. ASIC process selection gate

Do not freeze 28 nm, 16 nm, 12 nm, or any other node from generic assumptions. Select only after:
1. A foundry PDK and permitted commercial-use terms are available.
2. SRAM compiler delivers timing, power, area, LEF, Liberty, Verilog and test views for the actual TMEM/IMEM/ACT/MXU memories.
3. PCIe Gen3 x16 endpoint/PHY IP and four memory-controller/PHY channels are available for the same process/package.
4. WG8 exact RTL completes synthesis, placement, CTS, routing, multi-corner STA, IR/EM and DRC/LVS with real macros and IO.
5. Package pins, memory topology, ECC, cooling, BOM, yield, NRE, unit cost and expected contribution margin are modelled.
6. Real-model throughput and whole-system power are measured on the chosen physical prototype or equivalent silicon-quality implementation.

Nangate45 remains a research proxy only. It is not a foundry process and cannot be taped out.

## 4. No-spend execution

- Continue RTL, simulation, formal-property development, open-source PPA and board-model verification in CI.
- Use BCU1525-WG8 simulation as the workload/performance reference; use YPCB Gen2 bridge simulation for its own AXI/native-memory cases only.
- If a zero-cost ECP5 board is already available, limit it to control registers, a reduced compute tile, memory-controller experiments and SerDes/PCIe research. Do not purchase one or claim full accelerator validation.
- Do not use paid Vivado, paid cloud compute, paid IP or board purchases without explicit user approval.
