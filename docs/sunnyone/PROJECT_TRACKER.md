# SUNNYONE AI-X Project Tracker

Last updated: 2026-11-23 (Asia/Dhaka)
Repository: https://github.com/shamiursunny/openTPU
Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Protected working rule: do not modify `main`; all project work and tracker updates go to the active branch.
Latest verified code baseline before this tracker commit: `24b6780d20766595f54d68f6eb19d2aa3187e6e1`.

## 1. Product objective and decision rule

Build a commercially useful, programmable AI inference accelerator. Optimise risk-adjusted long-term net profit and fastest realistic investment recovery while maintaining reliable, competitive inference. The former 30 W total-system ceiling is retired. Select the power envelope using measured workload throughput, full-system total cost of ownership (TCO), and incremental contribution margin. Do not optimise watts, RAM capacity, or peak TOPS in isolation.

Zero-spend by default. No paid service, hardware purchase, or other expenditure without explicit user authorisation. Do not claim performance, power, thermal, cost, manufacturing, customer, revenue, or payback results without measurements/evidence.

## 2. Current stage

**Stage:** A1.12.11.16.34 — reproducible RTL regression / AXI-Lite reset isolation checkpoint.

**Latest CI:** GitHub Actions run [45209168224](https://github.com/shamiursunny/openTPU/actions/runs/45209168224), commit `24b6780d20766595f54d68f6eb19d2aa3187e6e1`, job `rtl-functional` (ID `137812968373`).

**Observed result: PASS.** Job completed with success. Both workflow steps completed successfully:
- Expanded RTL-versus-ISA tests.
- AXI-Lite isolation reset regression (`pytest -q tests/test_axil_iso.py`).

Setup, checkout, Python, Verilator, and dependency installation also succeeded. Exact test counts/log details have not yet been extracted; do not invent them. The prior run `45199414779` failed during collection because a module-level optional PyTorch skip prevented the dedicated AXI-Lite test from running; the test was isolated in `tests/test_axil_iso.py` to remove that dependency coupling.

## 3. Recent implementation / evidence

- Added standalone `tests/test_axil_iso.py`, independent of optional model-only dependencies (commit `443299c0c26b3a9c523d9dbfe6c944ab7ffbb29a`).
- Updated `.github/workflows/sunnyone-rtl-functional.yml` to run the standalone regression and include its path filter (commit `24b6780d20766595f54d68f6eb19d2aa3187e6e1`).
- AXI-Lite testbench `sim/verilator/tb_axil_iso.sv` tests random master/slave resets, response isolation, completion of accepted accesses, and expected bypass failure. It exercises seeds 1 and 2 and both bypass configurations.
- Related prior testbench improvements: randomized WSTRB and byte-enable model; B/R response stability under backpressure; expected-payload scoreboard for AW/W/WSTRB; expected transaction survives master reset and clears on slave reset.
- RTL under test: `otpu_axil_iso` in `rtl/shell/otpu_ctrl.sv`.

## 4. Immediate next actions

1. Retrieve and inspect CI logs for run `45209168224`; record exact pass counts, test names, and any warnings. Preserve the distinction between workflow success and test coverage.
2. Record the resulting tracker-update commit SHA and confirm branch head; never write to `main`.
3. Expand RTL/ISA and fault/backpressure/reset regression coverage, prioritising reproducible tests and mutation checks.
4. Run formal checks and full lint; classify warnings and unresolved findings rather than treating lint success as functional proof.
5. Establish a reproducible Nangate45 research PPA flow and archive exact tool versions, constraints, scripts, and outputs. Treat it only as a research proxy, not commercial silicon validation.
6. Build workload/trace and benchmark harnesses. Measure useful throughput, latency, memory bandwidth/utilisation, reliability, energy and full-system power on actual target hardware when available.
7. Compare candidate FPGA/device/board options only after benchmark and interface evidence. No device selected and no FPGA purchase authorised.
8. Complete security, reliability, board, memory, thermal, and production-signoff plans with explicit evidence gates.
9. Validate customer demand, pricing, deployment economics, unit costs, TCO, contribution margin, cash flow, and payback. Do not claim commercial validation before evidence.

## 5. Stage gates and maturity

| Gate | Scope | Current status |
|---|---|---|
| G0 | Selected RTL regression | Partial; current RTL/ISA and AXI-Lite CI run passed |
| G1 | Core correctness | Incomplete; broaden coverage |
| G2 | Formal verification and lint | Incomplete; lint previously passed with warnings, formal incomplete |
| G3 | Nangate45 research PPA | Research proxy only; reproducibility/expansion pending |
| G4 | Target device and package | Not selected |
| G5 | Board and memory integration | Not started |
| G6 | Real workload qualification | Not run |
| G7 | Commercial validation and unit economics | Not validated |
| G8 | Production signoff | Not defined / not started |

A passing selected regression is not full-chip qualification, formal proof, physical validation, production readiness, or commercial validation.

## 6. Architecture baseline and constraints

- Host-controlled accelerator, not a CPU-led SoC. No on-chip RISC-V CPU, boot ROM, or secure-boot chain is currently established as a product requirement; do not add them without demonstrated need.
- PCIe/host control alone does not prove production secure boot, tenant isolation, or complete security.
- Architecture baseline: `docs/sunnyone/SYSTEM_ARCHITECTURE_BASELINE_A1.12.11.16.43.md`.
- Pinned FeSens/openTPU reference commit: `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Compute tile includes sequencer/instruction store, MXU, VPU, quantisation, DMA/stream, TMEM/ACT RAM/FIFOs.
- Relevant RTL: `rtl/shell/otpu_board.sv`, `rtl/shell/otpu_ctrl.sv`, `rtl/shell/otpu_mem_ch.sv`, `rtl/shell/otpu_axi_split2.sv`.
- YPCB-00338 reference has two DDR3 channels with 64-byte beats; do not generalise to all platforms.
- 128 GB / 256 GB memory options are stretch investigations, not requirements.
- AMD Versal AI Core VC1802 / VSVD1760 is a feasibility lead; VC1902 is a higher-compute alternative. Neither is selected. Versal requires Vivado PRO/Enterprise/Gold; no complete open-source replacement is established.

## 7. Known limitations / evidence gaps

- No measured physical inference throughput, tokens/J, cost/token, calibrated wall power, thermal data, manufacturing quote, customer validation, revenue, or payback.
- Full-chip lint previously passed with warnings including missing pins, inferred latches, and UNOPTFLAT; not functional simulation or physical qualification.
- Older RTL CI run `45188429921`: 99 passed, 118 deselected, 34m57s; predates current testbench patch and isolated test.
- `tools/memch_test.py` covers random traffic, partial writes, backpressure, controller stalls, clock ratios, repeated resets, long read latency, FIFO/credit stress, and mutation testing.
- `sim/verilator/tb_board.sv` includes calibration, ECC flags, and host-control reset scenarios.
- `opentpu/host/memtest.py` includes DDR data/address-pattern tests.
- Experimental TMEM IMPL=3 caused a Verilator internal elaboration error; this is not proven to be an RTL functional mismatch and remains excluded from shared CI pending diagnosis.

## 8. Mandatory update protocol

After every completed engineering stage or material decision:
1. Update this file on the active branch with date, stage, evidence, exact commit/run IDs, results, failures, limitations, and next actions.
2. Never mark a test passed unless its execution result/log is observed. Record exact test counts only from logs.
3. Keep verified facts separate from hypotheses, plans, and unverified claims.
4. Re-check branch head before writing; preserve all existing work and never modify `main`.
5. Commit the tracker update with a descriptive message. Then report the tracker path, commit SHA, and next stage.
6. At the start of a future continuation, read this tracker and verify live GitHub branch/CI state before acting; this file is the durable project checkpoint, not a substitute for live verification.

## 9. Current next milestone

**A1.12.11.16.35 — CI log audit and regression evidence capture.**
Exit criteria: logs inspected; exact test outcomes/counts and warnings recorded; tracker updated with verified evidence; active branch and latest CI state confirmed.
