# SUNNYONE AI-X — Host DMA and Global Memory Address Map Specification

**Status:** source-derived interface specification candidate. DMA/PCIe RTL is not implemented, and end-to-end DMA mapping is not yet simulated or formally verified.

## 1. Purpose and design boundary

Define the host-facing contract required to connect a PCIe/host DMA subsystem to the four-DIMM ASIC memory interface. The ASIC WG8 top exposes four independent 512-bit host AXI4 ports, one per DIMM. It does not currently contain a PCIe endpoint, DMA descriptor engine, global-address decoder, IOMMU, MSI-X controller or host driver.

The external DMA subsystem must convert a single device-global memory address into a DIMM selection and the DIMM-local interleaved address expected by the ASIC top. The mapping below is derived from the existing FPGA reference implementation and the ASIC V1 parameterisation; it is not a new guessed mapping.

## 2. Source evidence and V1 parameters

| Source | Relevant evidence |
|---|---|
| `rtl/asic/otpu_asic_wg8_ddr4_top.sv`, blob `d8ddf86d5eb8e63ce9196cef942346b8bd15519e` | `CL = CAW + clog2(CB)`; instantiates `otpu_mig_pair` with `NC=2`, `BHW=0`; four DIMM ports |
| `rtl/boards/bcu1525/otpu_fpga_top_bcu_wg.sv`, blob `5df6993a87b4612e6890e4ba91bc6911f46c56f3` | Reference DMA windows, `DL = CL + clog2(2*S)`, and `remap(a) = {a[CL-1:12], a[DL-1:CL], a[11:0]}` when `BHW=0` |
| `rtl/boards/bcu1525/otpu_mig_pair.sv`, blob `1ea0d45ca194d85ce079cdb161d06a7fece5e1ac` | Channel byte `o` and channel index `s` map to DIMM byte `{o[CL-1:12], s, o[11:0]}`; channel interleave occurs at 4 KiB |
| `rtl/boards/bcu1525/otpu_mig_hmux.sv`, blob `0b646fcf532e1db366af718ef57218a99d4a6900` | Host ID is `1 << HB`; for `HB=2`, host response ID is 4 |

V1 candidate values: `CAW=25`, `CB=128 bytes`, hence `CL=32`; `S=1` slice, `NC=2` channels per DIMM, hence `DL=33`; four DIMMs; `BHW=0`. Each channel has 4 GiB; each DIMM has 8 GiB; total logical memory is 32 GiB.

## 3. Global 32-GiB address map

For a 35-bit byte address (G) in the device's contiguous 32-GiB memory aperture:

- `G[34:33]` selects logical DIMM (din[0,3]);
- `G[32]` selects channel (sin[0,1]) within that DIMM;
- `G[31:0]` is the byte offset (o) within that 4-GiB channel.

The DIMM-local address expected at host AXI port (d) is:

[
A_{mathrm{DIMM}} = {G[31:12],,G[32],,G[11:0]}
]

Equivalently:

- `A_DIMM[32:13] = G[31:12]`;
- `A_DIMM[12] = G[32]` (the channel-interleave bit);
- `A_DIMM[11:0] = G[11:0]`.

The DMA routes the transaction to host AXI port (d=G[34:33]), and drives the 33-bit `A_DIMM` value zero-extended to the top's 34-bit host address input. The top requires address bit 33 to be zero; a set bit 33 is outside the 8-GiB DIMM aperture and is rejected by its simulation guard.

This is the same 4-KiB interleave described by `otpu_mig_pair`: `DIMM byte = {channel_offset[31:12], channel_index, channel_offset[11:0]}`. The FPGA reference DMA's per-DIMM window is 8 GiB at global base (d\times 2^{33}), then its `remap` function applies this permutation.

### Address examples

| Global address | DIMM | Channel | Channel offset | DIMM-local address |
|---|---:|---:|---:|---|
| `0x000000000` | 0 | 0 | `0x00000000` | `0x000000000` |
| `0x000001000` | 0 | 0 | `0x00001000` | `0x000001000` |
| `0x000100000` | 0 | 0 | `0x00100000` | `0x000100000` |
| `0x001000000` | 0 | 0 | `0x01000000` | `0x001000000` |
| `0x100000000` | 0 | 1 | `0x00000000` | `0x000001000` |
| `0x200000000` | 1 | 0 | `0x00000000` | `0x000000000` |
| `0x600000000` | 3 | 0 | `0x00000000` | `0x000000000` |
| `0x700000000` | 3 | 1 | `0x00000000` | `0x000001000` |

The examples illustrate that the channel-select bit is moved into DIMM-local bit 12. They are address arithmetic examples, not measured transactions.

## 4. Host AXI contract

The current ASIC top exposes four host interfaces with the following source-level characteristics:

- one independent host AXI4 port per DIMM;
- 512-bit write/read data paths (64-byte beats);
- 34-bit local address inputs, with bit 33 required to be zero;
- 8-bit AWLEN/ARLEN fields;
- 64-bit WSTRB;
- 2-bit BRESP/RRESP;
- no host-side ID input at this boundary; the hmux inserts its fixed host ID `HID = 1 << HB = 4` for `HB=2`.

The DMA must preserve VALID/payload until READY, keep W data in AW order, honour response codes, and not issue a burst that crosses a 4-KiB boundary. It must also split transfers at DIMM-window boundaries. The exact maximum burst length, supported AXI attributes, outstanding-transaction depth and ordering requirements must be confirmed against the controller/PHY and final integration contract before RTL is frozen.

## 5. Required DMA and descriptor capabilities (H05)

The PCIe/host subsystem must provide, or arrange for an external DMA IP to provide:

1. host-memory to device-memory and device-memory to host-memory transfers;
2. 64-bit host physical/IO virtual addresses and a 35-bit device-global address;
3. DIMM selection and the exact 4-KiB channel-interleave remap in Section 3;
4. splitting at 4-KiB and 8-GiB DIMM boundaries, including correct final-beat byte strobes;
5. descriptor submission and completion queues, with software-visible producer/consumer indices and doorbells;
6. transfer length, direction, flags, status, error reporting and completion ordering;
7. bounded outstanding transactions and backpressure without losing or reordering data;
8. interrupt/completion notification (MSI/MSI-X or a manufacturer-selected equivalent);
9. reset, abort, timeout and link-down behaviour for in-flight transactions;
10. protection/isolation using a platform IOMMU or a documented alternative; no unrestricted host physical-memory access by default.

No register offsets, descriptor bit layout, PCIe generation/width or interrupt vector map is frozen in this document. Those require a selected endpoint/DMA IP and a reviewed software ABI.

## 6. Global mapping and physical DIMM routing (H06)

The logical DIMM decode is (d=G[34:33]). Physical DIMM slot order may differ from logical order due to package, board routing or manufacturer floorplan. The FPGA reference uses a configurable `DMAP` permutation. The ASIC implementation must either:

- provide a validated logical-to-physical DIMM mapping register/configuration, or
- freeze an explicit identity mapping in the package/board specification.

Do not silently assume the FPGA board's physical slot order applies to a new ASIC package or custom board.

The channel-interleave bit is inserted at DIMM-local bit 12. With `BHW=0` in the current ASIC top, no bank-half bit swap is applied. If a future design changes BHW/BHB, the host DMA remap and accelerator `otpu_mig_pair` remap must be changed and verified together.

## 7. Required verification before implementation freeze

- Exhaustive boundary tests around every 4-KiB, 4-GiB channel and 8-GiB DIMM boundary;
- address-map bijection test for all DIMMs/channels and representative offsets;
- proof that every global address in the 32-GiB aperture maps to exactly one valid local address and no address aliases another;
- AW/AR burst splitting and WSTRB checks for unaligned byte lengths;
- multi-DIMM simultaneous traffic and per-port backpressure;
- B/R response propagation and error completion;
- descriptor queue wrap, backpressure, completion ordering and reset/abort;
- IOMMU/protection negative tests;
- formal properties for address decode, no cross-window burst and no lost/duplicated completion.

The existing A02 testbench validates the ASIC's four DIMM-local host ports and the bit-33 aperture guard. The standalone decoder has its own Verilator boundary/bijection bench and a combinational Yosys SAT harness at `formal/otpu_asic_global_addr_map_formal.sv`. The first formal Run `45456060346` failed because Yosys produced `$check` cells that the SAT pass could not model; workflow commit `9c550d41ff00a6521cf551f6ab1b08b5f87263f5` adds `chformal -assert`, and rerun `45456545394` is queued. No proof pass is claimed yet. These tests do **not** instantiate a global DMA/remap block or prove end-to-end AXI routing, burst splitting or PCIe integration.

## 8. Manufacturer decisions and open dependencies

The manufacturer/integrator must return:

- candidate PCIe endpoint and DMA IP options, licence terms and support status;
- DMA clock/reset and CDC architecture;
- descriptor/completion ABI and host driver plan;
- logical/physical DIMM mapping and package/board routing;
- memory controller/PHY and AXI attributes/outstanding-depth limits;
- IOMMU/security architecture;
- NRE, unit cost, yield, package, board, test and schedule estimates.

No paid IP, licence, hardware, fabrication or service is authorised. H05/H06 remain open until the interface is selected, implemented or contractually assigned, and the complete address/descriptor behaviour is verified.
