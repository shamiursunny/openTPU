# SUNNYONE AI-X Project Tracker

Last updated: 2026-11-23 (Asia/Dhaka)
Repository: https://github.com/shamiursunny/openTPU
Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Protected working rule: do not modify `main`; all project work and tracker updates go to the active branch.
Latest verified RTL baseline: `24b6780d20766595f54d68f6eb19d2aa3187e6e1`. Current active branch head before this update: `def4c0961822c636d7cbb92732bd2637a059f50b`.

## 1. Product objective and decision rule

Build a commercially useful, programmable AI inference accelerator. Optimise risk-adjusted long-term net profit and fastest realistic investment recovery while maintaining reliable, competitive inference. The former 30 W total-system ceiling is retired. Select the power envelope using measured workload throughput, full-system total cost of ownership (TCO), and incremental contribution margin. Do not optimise watts, RAM capacity, or peak TOPS in isolation.

Zero-spend by default. No paid service, hardware purchase, or other expenditure without explicit user authorisation. Do not claim performance, power, thermal, cost, manufacturing, customer, revenue, or payback results without measurements/evidence.

## 2. Current stage

**Stage:** A1.12.11.16.45 — remaining RTL/board qualification and reference-chip specification.

**Latest verified baseline:** run [45209168224](https://github.com/shamiursunny/openTPU/actions/runs/45209168224): 99 RTL/ISA tests + 1 AXI-Lite test passed. Run [45217729099](https://github.com/shamiursunny/openTPU/actions/runs/45217729099) completed successfully but repeated those tests; its LDC test is a duplicate within the 99-test selection. Focused uncovered-test run [45222828630](https://github.com/shamiursunny/openTPU/actions/runs/45222828630), commit `7f29437bf26c73dac49693ca96e2b2aa60da4ae7`, is currently running; no result is assumed.

**Observed result: PASS.** Job completed with success. Both workflow steps completed successfully:
- Expanded RTL-versus-ISA tests.
- AXI-Lite isolation reset regression (`pytest -q tests/test_axil_iso.py`).

Exact log results: `tests/test_rtl.py` selection — **99 passed, 118 deselected** in 2037.95 s (0:33:57); `tests/test_axil_iso.py` — **1 passed** in 8.90 s. Total observed: 100 passed, 118 deselected across the two commands. Environment: Python 3.12.16, Verilator 5.032, Ubuntu 26.04 runner. Setup, checkout, Python, Verilator, and dependency installation succeeded. Warnings: Python packaging metadata deprecates the `project.license` TOML table (stated deadline 2027-02-18); GitHub warns checkout@v4/setup-python@v5 are targeting deprecated Node.js 20 and being forced to Node.js 24. No test failure or RTL warning appears in the captured job log. These are maintenance warnings, not evidence of functional failure. The prior run `45199414779` failed during collection because a module-level optional PyTorch skip prevented the dedicated AXI-Lite test from running; the test was isolated in `tests/test_axil_iso.py` to remove that dependency coupling.

## 3. Recent implementation / evidence

- Added standalone `tests/test_axil_iso.py`, independent of optional model-only dependencies (commit `443299c0c26b3a9c523d9dbfe6c944ab7ffbb29a`).
- Updated `.github/workflows/sunnyone-rtl-functional.yml` to run the standalone regression and include its path filter (commit `24b6780d20766595f54d68f6eb19d2aa3187e6e1`).
- AXI-Lite testbench `sim/verilator/tb_axil_iso.sv` tests random master/slave resets, response isolation, completion of accepted accesses, and expected bypass failure. It exercises seeds 1 and 2 and both bypass configurations.
- Related prior testbench improvements: randomized WSTRB and byte-enable model; B/R response stability under backpressure; expected-payload scoreboard for AW/W/WSTRB; expected transaction survives master reset and clears on slave reset.
- RTL under test: `otpu_axil_iso` in `rtl/shell/otpu_ctrl.sv`.

## 4. Immediate next actions

1. CI log audit completed: 99 RTL/ISA tests passed; 118 deselected; isolated AXI-Lite test passed (1). Warnings recorded above.
2. Expand RTL/ISA and fault/backpressure/reset regression coverage, prioritising reproducible tests and mutation checks.
3. Follow-up run `45217729099`, commit `66c708e573671136197c371a848cc9274ae394f2`: LDC host-write concurrency passed (`1 passed, 216 deselected`, 224.66 s). This test was already included in the earlier 99-test selection, so this was a duplicate execution, not a new distinct test. The run also unnecessarily repeated the 99 RTL tests and AXI-Lite test because the workflow changed without source changes; compare `24b6780...` to `66c708e...` showed only workflow/tracker files changed. The main job was still active at checkpoint.
4. Found a test-isolation defect: `tests/test_board.py` called `pytest.importorskip("torch")` and `pytest.importorskip("transformers")` at module scope (lines 671–672), causing all earlier host/board tests to be skipped when optional model dependencies were absent. Moved those imports into only the model tests/helpers.
5. Replace the broad repeat workflow with two focused jobs: unrun core RTL/ISA tests and board/host tests; omit the previously passed 99-test selection, AXI-Lite isolation test, and duplicate standalone LDC job. Experimental one-copy TMEM IMPL=3 tests remain excluded pending separate diagnosis.
6. Resolve or track the packaging license-metadata and GitHub action Node-runtime deprecation warnings; do not mix maintenance changes into functional RTL fixes.
7. Run formal checks and full lint; classify warnings and unresolved findings rather than treating lint success as functional proof.
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

**A1.12.11.16.36 — Unrun RTL/ISA and board regression coverage.**
Verified baseline remains 99 RTL/ISA tests + 1 AXI-Lite isolation test passed on run `45209168224`. LDC host-write test also passed on run `45217729099`, but it duplicates one of those 99 tests; therefore there are 100 distinct passed test cases, not 101. The main job in `45217729099` is a redundant rerun caused by workflow-only changes. New workflow now targets previously unrun core tests and board/host tests, and optional model dependencies no longer skip the entire board test module. Do not rerun completed tests unless RTL/test sources change.


## 10. Test de-duplication and newly unblocked coverage (2026-11-23)

- Distinct verified cases: 99 selected RTL/ISA tests + 1 AXI-Lite isolation test = 100. The separate LDC job passed one test already included in the 99; it is a repeat execution, not test case 101.
- Commit comparison `24b6780...` to `66c708e...` showed only workflow and tracker files changed. Thus the 99-test rerun in run `45217729099` adds no source-change validation.
- `tests/test_board.py` had module-scope optional PyTorch/Transformers skips at lines 671–672. Those skips prevented every preceding board/host test from being collected when either optional dependency was absent. Optional imports are now local to the model-only tests/helpers.
- New CI avoids repeating the passed RTL selection and AXI-Lite test; it targets previously unrun core RTL/ISA tests and the board/host suite. Experimental one-copy TMEM IMPL=3 tests remain excluded.


## 11. Reference chip architecture decision (A1.12.11.16.44)

- Created `docs/sunnyone/SUNNYONE_AI-X_REFERENCE_CHIP_ARCHITECTURE_A1.12.11.16.44.md` as the consolidated logical architecture and implementation contract.
- Resolved contradictory documents: first-version design is host-controlled, with host server runtime and the existing on-chip sequencer/`otpu_ctrl`; no on-chip RISC-V CPU or boot ROM is selected. A future embedded CPU requires a measured requirement.
- The logical architecture is defined; exact FPGA/SoC/ASIC, package, external memory, tile scale, clock, power and production implementation remain unselected.
- The current CI run `45222828630` runs previously unselected RTL/ISA tests and board tests. The prior 100 distinct passing tests are not intentionally repeated. The full-chip lint and virtual-memory workflows are also being refreshed to retain complete logs as downloadable CI artifacts.
- Remaining RTL functions found by name-level audit: `test_one_copy_tmem_of_128k_words`, `test_random_power_up`, `test_mxu_reads_on_the_card_tmem`, `test_one_copy_two_writers`, `test_one_copy_two_writes_replays_make_progress`, `test_collective_reads_held_behind_dma_reads`, `test_act_reads_follow_the_mm_rows`, `test_lane_count_does_not_change_results`, `test_ldc_sequential_is_the_card_bist`. `test_one_copy_tmem_of_128k_words` remains excluded pending the known TMEM implementation/elaboration investigation; the other eight require disposition and test execution.


## 12. Virtual-memory regression result (2026-11-23)

Run [45224358374](https://github.com/shamiursunny/openTPU/actions/runs/45224358374), commit `77a7b751b9c1f64da2d4484e41d417a70445f7b8`, completed successfully:
- Behavioural DRAM testbench: PASS marker verified; covers A/SW/B/W, byte masks, tags, ordering, latency and idle.
- Behavioural TMEM testbench: PASS marker verified; covers reset, read/write ordering, staged-write bypass, partial-lane writes, four-bank readback, overwrite, wrapped mapping and read hold.
- Multi-port TMEM testbench: PASS marker verified; covers concurrent read/write ports, distinct-bank writes, broadcast copies and external same-bank grant enforcement.
- Full logs archived as artifact [sunnyone-virtual-memory-logs](https://github.com/shamiursunny/openTPU/actions/runs/45224358374/artifacts/14841304152).
- Non-fatal warnings observed: DRAM conditional width, unused `nread`, blocking assignments in testbench/behavioral model; TMEM filename/module-name and timescale mismatch, width expansion, unused signals, and blocking assignments. These are not treated as RTL correctness proof or silently suppressed; triage is pending.


## 13. ASIC configuration checks queued (2026-11-23)

- Added a zero-ORFS test job for `tests/test_asic_flow.py`, `tests/test_target.py` and `tests/test_rtlsim_build.py`. This validates target/ASIC parameter contracts and flow generation, not actual synthesis or PPA.
- Corrected `asic/nangate45/README.md`: the small point uses banked `TMEM_IMPL=1`; the card point uses one-copy/replay `TMEM_IMPL=3`. This aligns the README with the target configuration and `test_asic_flow.py` expectations.


## 14. ASIC/target contract verification result (2026-11-23)

Run [45224916714](https://github.com/shamiursunny/openTPU/actions/runs/45224916714), commit `35193d82994a93bf48c34b2ee2f0c62e7c2a0fd6`, passed **66 tests in 3.80 s** across:
- `tests/test_asic_flow.py`: ASIC point/parameter, source and SRAM mapping/config contracts.
- `tests/test_target.py`: target loading, configuration and board/host target consistency.
- `tests/test_rtlsim_build.py`: simulator build cache/version/flags and concurrent build behaviour.

This is configuration/unit evidence only; it does not execute OpenROAD synthesis, placement, routing or PPA.


## 15. Full-chip lint result (2026-11-23)

Run [45224358388](https://github.com/shamiursunny/openTPU/actions/runs/45224358388), commit `77a7b751b9c1f64da2d4484e41d417a70445f7b8`, **passed** full-chip Verilator lint. Full log archived as [sunnyone-fullchip-lint-log](https://github.com/shamiursunny/openTPU/actions/runs/45224358388/artifacts/14842227327).

Warnings remain and are not suppressed as proven safe:
- 19 `PINMISSING`: unconnected optional multi-card/collective ports at `sim/verilator/tb_top.sv:128`.
- 7 `LATCH`: block-local temporaries in combinational logic at `rtl/seq/otpu_seq.sv:1153,1820`; inspect whether these are harmless local temporaries or actual inferred state.
- 3 `UNOPTFLAT`: combinational paths through `otpu_slice.gnt`, `otpu_top.sc_gl` and `otpu_tmem.pq`; require structural review.
Lint success with `-Wno-fatal` is not formal proof or timing closure.
