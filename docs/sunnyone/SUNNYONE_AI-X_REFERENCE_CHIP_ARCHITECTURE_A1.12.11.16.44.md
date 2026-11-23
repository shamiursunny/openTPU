# SUNNYONE AI-X — Reference Chip Architecture and Implementation Specification

**Revision:** A1.12.11.16.44  
**Date:** 2026-11-23  
**Status:** selected logical architecture / implementation baseline; **not tapeout-ready and not a selected physical chip**  
**Repository:** `shamiursunny/openTPU`  
**Pinned upstream compute reference:** FeSens/openTPU `d84db55712aba0d40811d7762cb052f05d55b7e5`

## 1. Product decision

Build a programmable, host-controlled AI inference accelerator around the existing openTPU compute architecture. Optimise risk-adjusted long-term net profit and fastest realistic capital recovery while meeting measured customer quality, latency, throughput, reliability and availability. There is no fixed system-watt ceiling. Choose power, compute scale, memory and cooling only from measured workload throughput, complete-system TCO and incremental contribution margin.

**First-version architecture excludes an on-chip RISC-V CPU, boot ROM and assumed secure-boot chain.** A host server runs the service runtime, scheduler, driver, management and security policy. The accelerator retains its existing sequencer and host register block. Add an embedded management CPU only if a demonstrated requirement and measured implementation benefit justify its area, power, security and verification cost.

## 2. System block diagram

```
Client applications / API / tenant authentication
                    |
Host server CPU + RAM + storage + network
  model runtime / scheduler / compiler / driver / telemetry
                    |
        PCIe host interface (generation/width TBD)
                    |
       +------------+------------------+
       |                               |
 AXI4-Lite BAR control            XDMA AXI4 data path
       |                               |
 otpu_ctrl register map v5       otpu_axi_split2
       |                         (reference 2-channel split)
       |                               |
       +---------- Accelerator card / SoC boundary --------+
                                                          |
                +-----------------------------------------+
                | otpu_board / one or more slices         |
                |                                         |
                |  Sequencer + instruction memory        |
                |       |                                 |
                |  +----+-----------------------------+  |
                |  | MXU: systolic/tiled matrix       |  |
                |  | VPU: vector/reduction/elementwise|  |
                |  | quantisation / dequantisation    |  |
                |  | DMA / stream / gather / collective| |
                |  | TMEM + ACT RAM + FIFOs            |  |
                |  +----------------------------------+  |
                |                                         |
                | otpu_mem_ch arbitration / async FIFOs   |
                +--------------------+--------------------+
                                     |
                External memory controller + PHY (platform IP)
                                     |
                  ECC external memory + board power/cooling
```

The diagram combines implemented openTPU blocks with explicitly unselected platform interfaces. It is not evidence that the whole system has been integrated into one production device.

## 3. Functional blocks and contracts

| Block | Responsibility | Evidence / implementation boundary |
|---|---|---|
| Host runtime | API, batching, scheduling, model loading, compiler, quantisation, telemetry, tenant policy | Software; host platform not selected |
| PCIe bridge / XDMA | Host data movement and BAR access | Existing board-specific integration; exact future PCIe generation/width TBD |
| `otpu_ctrl` | RUN/LOAD/RESET control, calibration gating, status, counters, capabilities, trace | AXI4-Lite register map v5 in `rtl/shell/otpu_ctrl.sv` |
| `otpu_board` | Slice integration, shared control, collective, board clock crossings | Implemented reference top; board-specific |
| Sequencer / IMEM | Execute accelerator instruction stream and coordinate units | Existing RTL/ISA; instruction and kernel coverage must be qualified |
| MXU | Matrix multiply and tiled/systolic low-precision compute | Existing `otpu_mxu`; select precision/shape from validated models |
| VPU | Vector, reductions, activation/normalisation and elementwise operations | Existing `otpu_vpu`; operator support must be tested |
| Quantisation | Quant/dequant and scaling paths | Existing `otpu_quant`; exact numerical semantics are part of ISA contract |
| DMA / stream | Move tensors and stream data between external memory and local storage | Existing DMA/stream RTL; bandwidth and arbitration require measurement |
| TMEM / ACT RAM / FIFOs | Reuse weights, activations, intermediate tensors and buffering | Existing RTL; memory banking/replication/replay implementation remains a PPA/correctness trade-off |
| External memory subsystem | Controller, PHY, training, refresh, ECC and physical routing | Platform-specific; not implemented by `otpu_asic_top` |

### Required invariants
- Host control must not release a run before all required memory channels are calibrated.
- Accepted writes must be drained/ordered before host reuse of affected memory; aborted runs must not create stale responses or corrupt later transactions.
- AXI request/response payloads remain stable under backpressure; IDs, bursts, byte strobes and response ordering must be preserved according to each interface contract.
- DMA address ranges must be validated by the host/IOMMU and by hardware boundaries where applicable; no tenant isolation claim until the complete path is proven.
- Every run must expose build ID, configuration/capability, error state, counters and reproducible software/model hashes.
- Uncorrectable ECC, timeout, illegal instruction and reset conditions must become explicit recoverable errors, not silent wrong output.

## 4. First reproducible compute configuration

Use the existing one-slice YPCB-00338 m4 architecture as the functional card reference, and the one-slice Nangate45 target as an ASIC research configuration. Do not confuse either with the final silicon target.

| Parameter | Reference value | Qualification |
|---|---:|---|
| Slices | 1 | Start single-slice; multi-slice only after scaling tests |
| D | 128 | Existing ISA/configuration dimension |
| MCOLS | 4 | Existing YPCB m4 reference |
| LANES | 8 | Existing reference |
| ACT_BLOCKS / ACT_ROWS | 128 / 16 | Card reference; Nangate45 uses 8 rows |
| TMEM_WORDS | 65,536 | Card m4 reference |
| IMEM_WORDS | 32,768 | Card reference |
| MXU_IMPL / MXU_CL / MXU_E | 2 / 16 / 4 | Existing systolic configuration |
| VPU_CL | 2 | Existing reference |
| FIFO_DEPTH | 1,024 | Existing reference |
| Core clock | 133.33 MHz | YPCB-00338 build point only; not a target ASIC frequency |
| External memory | 2 × DDR3-1066 channels | YPCB-00338 reference only |

The YPCB configuration uses `TMEM_IMPL=3` with a board-specific pumped memory implementation. The Nangate45 research target also selects one-copy/replay TMEM but uses different macro timing assumptions. The ASIC documentation describes a three-copy banked TMEM (`TMEM_IMPL=1`) with a correctness-tested alternative and a larger macro-area cost. **Do not freeze one-copy TMEM for ASIC until its current Verilator elaboration issue is resolved and the exact synthesis/PPA comparison is reproducible.** Maintain a known-correct alternative.

## 5. Memory architecture and scaling

- Treat external DRAM as a platform subsystem. The accelerator ASIC boundary is a memory-port interface, not a DDR PHY.
- Derive weights, KV/recurrent state, activation, scratch, bandwidth, concurrency and capacity from measured model traces.
- 128 GB is a conditional feasibility investigation, not the first-version requirement. 256 GB is stretch-only. Do not buy capacity without workload and economic evidence.
- For a Versal feasibility study, evaluate integrated NoC DDR first. VC1802/VSVD1760 remains only a lead candidate; VC1902/VSVD1760 is a higher-compute alternative. Exact controller pins, Vivado memory-planner output, DIMM SPD/training, ECC, board routing, cost and power remain unverified.
- The four-channel 128 GB RDIMM arrangement is a hypothesis, not a supported/validated board design. No specific RDIMM part is approved.
- ECC is required at the external-memory subsystem for a reliability-oriented product; controller ECC support, error injection, reporting and recovery must be demonstrated on the exact platform.

## 6. Host, security and reliability boundary

No secure boot, root of trust, tenant isolation, PCIe peer isolation or production security certification is claimed. Before multi-tenant deployment, define and verify: host IOMMU mapping, DMA bounds, BAR permissions, reset isolation, per-tenant memory ownership/zeroisation, firmware/bitstream provenance, debug/JTAG lifecycle, key handling, update rollback, fault containment and audit logging. Keep host-side authentication and service policy outside the chip unless a concrete on-chip security architecture is separately designed.

Board-level CDC/RDC, memory calibration loss, controller timeout, ECC correctable/uncorrectable errors, power sequencing, thermal shutdown, watchdog and recovery remain release gates. Current RTL register/status support does not alone satisfy these gates.

## 7. Software and model contract

Host software owns model parsing, graph lowering, operator scheduling, batching, memory planning, quantisation/calibration, API, monitoring and fallback. Each model release must pin:
- immutable model and tokenizer revision, template and licence;
- tensor shapes, precision, quantisation and calibration hashes;
- operator-to-kernel mapping and numerical tolerance;
- context/input/output distribution and concurrency;
- unsupported operations and CPU/GPU fallback policy.

Initial benchmark hypotheses: W1 small/medium generative inference, W2 embedding + reranking, W3 batch document/text processing. These are hypotheses, not customer-validated demand. A kernel passing in isolation does not prove end-to-end model support.

## 8. Physical implementation strategy

1. Keep portable RTL and ISA semantics as the architecture source of truth.
2. Establish functional equivalence and regression coverage before changing datapath/memory microarchitecture.
3. Run generic ASIC synthesis and the reproducible Nangate45/OpenROAD research flow. Archive exact commit, tool versions, constraints, macros, area, timing, congestion and power estimates. Nangate45 is a research proxy, not a manufacturable process or commercial silicon estimate.
4. Compare at least: known-correct multi-copy TMEM, one-copy/replay TMEM after issue resolution, and alternative tile dimensions. Use the same workload traces and constraints.
5. Select a physical device/package only after target-specific IP, pinout, memory, PCIe, clocks, thermal and licensing are verified.
6. Production ASIC requires foundry PDK, SRAM compiler, DFT/scan, CDC/RDC, multi-corner STA, IR/EM, ESD, package, reliability, security and manufacturing test. None is complete.

## 9. Explicitly unselected

- Exact FPGA, SoC, ASIC, package, process node and foundry.
- PCIe generation/width and board form factor.
- External memory type/capacity/channel count and exact DIMM.
- Final TMEM implementation and local SRAM sizes.
- Tile count, matrix dimensions, precision mix and clock frequency.
- Power envelope, cooling, BOM, selling price and deployment model.
- Customer SLA, workload distribution, demand and revenue.

These are decision gates, not values to guess.

## 10. Release acceptance gates

G0 regression: selected and uncovered RTL/ISA tests pass with logs.  
G1 correctness: supported operators bit-exact or within documented tolerances; reset, backpressure, memory arbitration and fault recovery pass.  
G2 formal/lint: critical protocol, FIFO, arbitration, reset and error properties proved; warnings classified.  
G3 research PPA: reproducible synthesis/place/route with macro and constraint audit.  
G4 device: exact part/package and generated IP pass vendor planning, pin and resource checks.  
G5 board: memory training/ECC, PCIe, CDC/RDC, SI/PI, power and thermal tests.  
G6 workload: independent quality, latency, useful throughput, stability and wall-power runs.  
G7 commercial: customer demand, quotes, full-system TCO and conservative payback validated.  
G8 production: full ASIC signoff and manufacturing qualification.

**Current disposition:** the logical accelerator architecture is defined as a host-controlled programmable MXU/VPU/DMA inference device using the existing openTPU ISA and compute blocks. The final physical chip, board and production RTL are not complete. Do not call the product tapeout-ready or commercially qualified.
