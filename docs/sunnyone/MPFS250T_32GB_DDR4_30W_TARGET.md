# SUNNYONE AI-X — MPFS250T / 32 GB DDR4 / 30 W Target Definition

Status: **Architecture proposal / feasibility gate — NOT an implemented or qualified chip**
Date: 2026-11-23
Reference RTL: FeSens/openTPU commit `d84db55712aba0d40811d7762cb052f05d55b7e5`
Working branch: `sunnyone/mpfs250t-ddr4-30w-architecture-2026-11-23`

## 1. Objective

Evaluate a low-power, mid-range programmable AI inference device based on the Microchip PolarFire SoC MPFS250T. The system target is 32 GB DDR4 and no more than 30 W total board input power, with sustained, reproducible inference performance and controlled thermal behaviour.

The design must optimise **tokens per joule and sustained tokens per second**, not just peak arithmetic throughput. Correctness, memory integrity, deterministic recovery and thermal stability are release gates.

A 30 W ceiling and 32 GB memory are design requirements, not achieved properties. No power, thermal, performance, memory-capacity or physical reliability result is claimed by this document.

## 2. Selected candidate and hard constraints

Microchip's public product information describes MPFS250T as a mid-range, low-power SoC FPGA. The published device table lists 254K logic elements, 784 18×18 MACC math blocks, 812 LSRAM blocks, 2,352 uSRAM blocks, 17.6 Mbits total FPGA RAM, and an MSS with one E51 plus four U54 RISC-V cores. Exact package, speed grade, voltage, memory controller configuration and Libero tool support must be fixed before implementation.

| Requirement | Design target | Qualification condition |
|---|---:|---|
| SoC | MPFS250T | Exact orderable part, package and speed grade selected |
| Main memory | 32 GB DDR4 | Controller/IP, package pinout, DRAM density/ranks and timing validated |
| Total board input | <= 30 W | Measured at board input under worst sustained workload and defined ambient |
| Normal sustained power target | <= 25 W | Measured, not inferred from adapter rating |
| Thermal | No throttling or unsafe junction temperature | Thermal model plus instrumented hardware test |
| Inference | Stable autoregressive generation | Exact model, quantisation, context, batch and test protocol recorded |
| Reliability | No silent corruption, hangs or unrecovered faults | Stress, reset, ECC/error injection where supported |

### Critical memory-interface caveat

The standard MPFS-ICICLE-KIT provides 2 GB LPDDR4, not 32 GB DDR4. It is a development board, not the proposed 32 GB carrier board.

The MPFS250T product family includes an MSS DDR interface and FPGA-fabric memory interfaces, but the actual interface options depend on package and controller IP. The MPFS250T in FCVG484 must not be assumed to support a particular 32 GB DIMM topology until the official package pin assignment table (PPAT), memory-controller IP guide, supported DRAM density/rank table and timing constraints are checked together.

**Do not commit to a desktop UDIMM/SODIMM footprint yet.** First compare:
1. MSS DDR4 controller and supported bus width / density / rank limits;
2. FPGA-fabric DDR4 controller options and available HSIO pins;
3. package pin budget, byte-lane placement, VREF/VTT/termination and routing;
4. available 16 Gb / 24 Gb / 32 Gb DRAM components and controller compatibility;
5. ECC capability and usable capacity after ECC.

If the MPFS250T package/controller cannot address 32 GB reliably, escalate to a larger package/device or a different SoC/FPGA. Do not fake the capacity by counting storage as RAM.

## 3. Architecture direction

Use the existing openTPU implementation as a reference for workload semantics and software compatibility, not as a promise that the full BCU1525 design fits MPFS250T.

Proposed partition:
- MSS RISC-V cores: boot, Linux/RTOS, runtime, request scheduling, monitoring and recovery.
- FPGA fabric: a deliberately small, resource-budgeted inference datapath.
- Local SRAM: tile/activation buffers, double-buffered weight tiles, command queues and frequently reused metadata.
- DDR4: model weights, KV cache, large tensors and host-visible buffers.
- DMA: burst-based transfers with backpressure, bounded queues and explicit timeout/error reporting.
- Telemetry: counters for DRAM bytes, cache/SRAM hit rate, stalls, utilisation, queue depth, temperature and rail power.

Do not port the complete openTPU BCU1525 top-level wholesale. First select one inference kernel and implement a minimal end-to-end path.

### Workload priority

1. Quantised dense matrix-vector / matrix-matrix multiplication for autoregressive decoding and prefill.
2. Efficient attention/KV-cache movement, with a measured cache policy.
3. Elementwise, normalisation, activation and sampling operations.
4. Optional sparse/structured kernels only when model support and end-to-end benefit are demonstrated.

Use INT8 as the first correctness baseline. Evaluate INT4 only after reference numerical tests, calibration, accuracy and overflow behaviour are established. Do not assume INT4 is automatically faster or more accurate.

## 4. Performance and bandwidth reality check

For a memory-bound decoder, a first-order roofline is useful. For a hypothetical 32-bit DDR data path at 1,600 MT/s:

- Theoretical raw bandwidth = 32 bits × 1.6 GT/s ÷ 8 = **6.4 GB/s**.
- A 64-bit path at the same rate would be **12.8 GB/s**.
- These are theoretical interface rates, not measured sustained bandwidth. Protocol overhead, refresh, controller efficiency, bank conflicts and arbitration reduce usable bandwidth.

A dense 7-billion-parameter model stored at ideal 4-bit packing contains approximately 3.5 GB of raw weights. If every generated token requires one complete weight pass, a 6.4 GB/s path gives a purely theoretical bandwidth ceiling of about **1.8 tokens/s**, before scales, metadata, KV-cache traffic, runtime overhead or compute limitations. This is a roofline illustration, not a SUNNYONE performance prediction.

Consequences:
- The MPFS250T is a plausible low-power control/programmable-logic research platform, but its small fabric and DDR bandwidth may not deliver high token rates for multi-billion-parameter models.
- Optimise for small/medium models, low batch, efficient quantisation and low power first.
- Benchmark tokens/s, tokens/J, first-token latency, inter-token latency (p50/p95/p99), sustained throughput and accuracy together.
- If the target model requires materially higher bandwidth or MAC throughput, perform a documented architecture down-select before investing in a custom PCB.

## 5. Power and thermal plan

Power target:
- Normal sustained board input: <=25 W (goal).
- Absolute board input ceiling: <=30 W (hard requirement).

The power boundary must include SoC, DDR4, regulators/conversion losses, storage, networking, clocks, fans and all board peripherals. Do not use the power-adapter nameplate as consumption.

Measurement plan:
1. Measure idle, boot, model load, prefill, decode and worst-case continuous decode separately.
2. Log input voltage/current and individual rails where instrumentation permits.
3. Record ambient temperature, SoC junction/board temperatures, fan speed and throttling events.
4. Run at least a 60-minute sustained inference test after thermal equilibrium; extend to 8 hours for stability qualification.
5. Repeat with maximum supported memory traffic and concurrent I/O.
6. Reject any run with silent errors, thermal throttling, unexplained clock changes or power >30 W.

Power optimisations to test, not assume:
- Clock-gate inactive datapath regions.
- Use operand isolation and avoid toggling unused MAC lanes.
- Double-buffer tiles only where reuse outweighs SRAM/clock cost.
- Coalesce DDR bursts; reduce random reads and redundant weight movement.
- Use fixed-point widths selected by accuracy/error analysis.
- Dynamic frequency/voltage changes only where supported and validated.
- Keep thermal control deterministic, with headroom rather than running at the limit.

## 6. Verification gates

| Gate | Required evidence | Current status |
|---|---|---|
| G0 source identity | Exact source SHA and clean branch | Reference SHA known; target branch created |
| G1 package feasibility | PPAT, controller support, DRAM topology and timing | NOT STARTED |
| G2 memory architecture | 32 GB address map, ECC, training, refresh and error reporting | NOT STARTED |
| G3 minimal RTL | Synthesizable datapath and integration tests | NOT STARTED |
| G4 functional simulation | Verilator tests, reference-model comparisons and corner cases | NOT STARTED for MPFS target |
| G5 formal | Reset, FIFO, DMA, arbitration and control invariants | NOT STARTED |
| G6 synthesis | Libero synthesis resource report, warnings and timing constraints | NOT STARTED |
| G7 power estimate | Vendor power estimator with realistic activity and constraints | NOT STARTED |
| G8 physical board | DDR training, memory stress, rail power and thermal tests | NOT STARTED |
| G9 inference | Model accuracy, tokens/s, latency, tokens/J, long-run stability | NOT STARTED |

The previous BCU1525 offline lint PASS applies only to that board's defined lint target. It is not evidence that MPFS250T implementation or 32 GB DDR4 works.

## 7. Required benchmark protocol

Every result must record:
- RTL and software commit SHAs;
- exact MPFS part/package/speed grade and Libero version;
- memory part numbers, topology, speed, timing and ECC mode;
- model name/revision, parameter count, quantisation and tokenizer;
- prompt length, generated token count, batch and concurrency;
- warm-up, test duration and repeat count;
- input power, rail power if available, temperature and clock;
- tokens/s, first-token latency, inter-token latency p50/p95/p99, tokens/J;
- output correctness/accuracy and any errors, retries, resets or throttling.

Minimum benchmark suite: synthetic bandwidth, GEMV/GEMM, attention/KV-cache, elementwise kernels, end-to-end small model decode, long-context decode, memory stress, concurrent I/O and 8-hour stability.

## 8. Immediate engineering sequence

1. Obtain MPFS250T FCVG484 PPAT and exact memory-controller documentation.
2. Prove a 32 GB DDR4 topology is electrically and logically supportable. If not, stop and reselect device/package.
3. Estimate achievable bandwidth and decide whether the selected model class meets the token-rate objective.
4. Create a new MPFS-specific RTL top; keep the existing openTPU baseline unchanged.
5. Implement a small INT8 GEMV/MAC datapath and SRAM/DMA path.
6. Simulate against a software golden model, including overflow, saturation and reset/error paths.
7. Synthesize in the supported Microchip toolchain; report resource/timing/power estimates.
8. Only then design the carrier PCB and build a physical prototype.
9. Measure board power and thermal performance before claiming the 25 W/30 W goals.
10. Run sustained inference and stability qualification.

## 9. Release policy

This document is a feasibility-controlled target definition. It is not a completed RTL implementation, verified 32 GB memory design, FPGA bitstream, PCB, tapeout package or manufacturable chip. A gate can be marked PASS only when the corresponding evidence exists and is reproducible.
