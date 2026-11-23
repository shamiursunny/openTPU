# SUNNYONE AI-X Project Tracker

Last updated: 2026-11-23 (Asia/Dhaka)
Repository: https://github.com/shamiursunny/openTPU
Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Protected working rule: do not modify `main`; all project work and tracker updates go to the active branch.
Latest fully verified broad RTL baseline: `24b6780d20766595f54d68f6eb19d2aa3187e6e1` (99 RTL/ISA + 1 AXI-Lite passed); subsequent targeted 128K TMEM (2 passed), full-chip lint (success, 0 PINMISSING), and reset audit (4 passed) are recorded below. Current active branch head at this tracker update: `263719d0304b8571e73a1ef2a19c5149849617bc`. `main` verified unchanged at pinned upstream `d84db55712aba0d40811d7762cb052f05d55b7e5`.

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


## 16. Experimental 128K one-copy TMEM isolation

- Dedicated isolated run [45225974726](https://github.com/shamiursunny/openTPU/actions/runs/45225974726) passed `test_one_copy_tmem_of_128k_words`: **2 passed, 215 deselected** in 120.70 s. The earlier Verilator internal elaboration error did not reproduce. This removes the test from the current exclusion list; retain one-copy TMEM as a candidate pending full regression and PPA, not as a production freeze.


## 17. ASIC top-level integration gap clarified

- The current `rtl/asic/otpu_asic_top.sv` is a compute-block boundary (one slice + collective, memory-port handshakes and run/load/status signals), not a complete PCIe/host-connected chip top.
- The board reference `otpu_board` has `otpu_ctrl` AXI4-Lite BAR control and board-specific memory/clock crossings, but that is not integrated into the ASIC top. A separate chip wrapper and platform-specific memory/host interface remain required.
- `main` was checked and remains at `d84db55712aba0d40811d7762cb052f05d55b7e5`; all current work remains on the active branch.


## 18. One-copy TMEM investigation result

- Isolated 128K one-copy test passed both parametrized cases under Verilator 5.032. Previous internal elaboration error is not reproducible in run `45225974726`.
- One-copy TMEM remains a candidate for ASIC PPA comparison; do not freeze until all relevant regressions and physical macro/timing analysis pass.


## 19. ASIC interface contract documented

- Added exact `otpu_asic_top` run/load/status and A/SW/B memory-port widths to the reference chip specification. At D=128, port B's chunk is 1,024 bits with a 32-bit byte-lane mask; this is not a DDR beat width.
- Chip wrapper, PCIe/host interface and external memory-controller integration remain open.


## 20. Dedicated synthesis-based reset audit

- Added a dedicated workflow using a pinned OSS CAD Suite release (2026-11-23) with SHA-256 verification. It installs the Yosys slang frontend and runs `tests/test_reset_audit.py` rather than silently skipping it in the ordinary Verilator-only job.
- This is a synthesis-based reset-state audit, not a formal proof of the entire chip.


## 21. Remaining RTL tail regression result

Run [45224697471](https://github.com/shamiursunny/openTPU/actions/runs/45224697471), commit `95cbec3af34c066d0a8a0e448c0c9a36b7c7e288`, passed **33 tests**, with 1 expected parameter skip and 183 deselected, in 900.01 s. Covered the remaining non-experimental test functions for random power-up, card TMEM reads, concurrent TMEM writers/replay progress, collective-vs-DMA reads, ACT-row gating, lane-count invariance and sequential LDC BIST. The single skip was the intentional invalid PAIR/ACT_ROWS parameter combination (`PAIR needs 2M <= MCOLS; M <= ACT_ROWS`), not a test failure.


## 22. CI pipeline failure propagation hardening

- Added explicit Bash `set -o pipefail` to full-chip lint and virtual-memory simulation pipelines so a failing Verilator/simulator process cannot be hidden by a successful `tee` exit code. The workflows will rerun these quick checks with correct failure propagation.


## 23. Pipefail-hardened lint and virtual-memory rerun

- Run [45227797380](https://github.com/shamiursunny/openTPU/actions/runs/45227797380): full-chip Verilator lint passed again with explicit `set -o pipefail`; the same warning classes remain.
- Run [45227797307](https://github.com/shamiursunny/openTPU/actions/runs/45227797307): DRAM, TMEM and multi-port TMEM compile/simulation/pass-marker checks all passed again with explicit pipeline failure propagation.
- These reruns confirm the earlier successful results were not hidden by `tee` masking a failing process.


## 24. Control-plane wording precision

- Clarified that `otpu_ctrl` AXI4-Lite host control is present in the board reference but is not yet integrated into `otpu_asic_top`. The ASIC chip wrapper remains an explicit implementation task.


## 25. Active verification queue at checkpoint

- Active branch head at checkpoint: `7626778b06d508501ee9ed73b66530affee9a98c`; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Run `45222828630`: previously unrun core RTL/ISA selection and board/host regressions, both still running.
- Run `45225212165`: core ISA/compiler/kernels/numerics/host software suite, running.
- Run `45225704236`: DMA/stream/quantisation/memory subsystem suite, running.
- Run `45227519645`: pinned Yosys/Slang power-up/reset synthesis audit, running.
- Do not claim these suites passed until their job conclusions and pytest summaries are inspected.


## 26. Design and verification checkpoint

- Logical architecture specification: `docs/sunnyone/SUNNYONE_AI-X_REFERENCE_CHIP_ARCHITECTURE_A1.12.11.16.44.md` is the current design reference. It defines a host-controlled programmable accelerator; it is not a tapeout-ready physical chip.
- Remaining design-critical blockers: integrate host control into the ASIC top; select exact device/package and external memory; complete macro-aware PPA/timing; verify CDC/RDC, protocol/formal properties and lint warnings; qualify actual end-to-end model workloads and measured wall power; validate BOM/TCO, customer demand and payback; complete security/production signoff.
- Current active CI runs remain: `45222828630` (uncovered RTL/ISA + board tests), `45225212165` (software core), `45225704236` (RTL subsystems), `45227519645` (Yosys/Slang reset audit). Their results are pending; inspect before claiming completion.
- Latest verified branch head is recorded at this checkpoint; `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`.


## 27. Reset audit findings and guarded-data review (2026-11-23)

- Run [45227519645](https://github.com/shamiursunny/openTPU/actions/runs/45227519645) failed after 3 tests passed and 1 failed. The failing reset-state audit reported X-valued TMEM per-bank write address payload `pa` (112/135 bits) and MXU RMAX key payload `mx_key` (320/320 bits) in the pumped-card configuration.
- Source review: TMEM `pa` is derived from `wi_addr`; its write-selection path is qualified by `wi_en` / `wi_gnt`, which are synchronously cleared by reset. MXU `mx_key` is data state, while `mx_have` is reset and tracks columns whose key has been populated. This classification is not accepted as proof until the guarded-use condition is exercised.
- Updated `tools/reset_audit.py` allowlist to classify `pa` and `mx_key` as guarded data, with the gating rationale documented. Commit: `43f77eba01abdc6e90429ad71cdc2719360d8943`. The audit rerun [45230099519](https://github.com/shamiursunny/openTPU/actions/runs/45230099519) was triggered on that commit and was still running at this checkpoint.
- Added a simulation-only MXU assertion: every active RMAX output lane must have `mx_have` set before `mx_key` is read for a TMEM write. Commit: `a535d85bbb67922a2955b7fd9cebae4c4bd1fedf`. This is a safety check, not yet verified by CI.
- Outstanding long-running suites at this checkpoint: [45222828630](https://github.com/shamiursunny/openTPU/actions/runs/45222828630) (uncovered RTL/ISA and board/host), [45225212165](https://github.com/shamiursunny/openTPU/actions/runs/45225212165) (software core), and [45225704236](https://github.com/shamiursunny/openTPU/actions/runs/45225704236) (RTL subsystems). No conclusions are claimed until their logs are inspected.
- Active branch head after the MXU assertion: `a535d85bbb67922a2955b7fd9cebae4c4bd1fedf`. `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- The ASIC compute-block is still not a complete host-connected or memory-PHY-integrated chip. Chip wrapper, physical target selection, macro-aware PPA, CDC/RDC/formal, real workload/power qualification and commercial validation remain open.


## 28. Expanded CI failures and follow-up (2026-11-23)

- Run [45222828630](https://github.com/shamiursunny/openTPU/actions/runs/45222828630), job `rtl-uncovered`, completed **failure**: 69 passed, 13 failed, 135 deselected. All 13 failures are TMEM random-traffic parameterisations that trigger a Verilator 5.032 internal error in `rtl/mem/otpu_tmem.sv` at the `ram_row` function declaration (reported as `V3Delayed.cpp:937: Multiple Write refs on LHS of NBA`). This is a simulator/elaboration failure, not an observed data-mismatch assertion. Do not call the experimental TMEM configurations qualified. The 128K one-copy end-to-end test remains separately passed (run 45225974726, 2 cases).
- Run [45227519645](https://github.com/shamiursunny/openTPU/actions/runs/45227519645), reset audit, completed **failure**: 3 passed, 1 failed. X-state findings were `otpu_tmem.pa` (112/135 bits) and `otpu_mxu.mx_key` (320/320 bits) in the pumped-card configuration. The audit allowlist was updated to classify these as guarded data; the MXU simulation assertion was added to check that every active RMAX output key has been populated before use. These changes require the rerun below; allowlisting alone is not proof.
- Reset audit rerun [45230099519] is still in progress at this checkpoint; no result assumed.
- Run [45222828630](https://github.com/shamiursunny/openTPU/actions/runs/45222828630) board-functional job, [45225212165](https://github.com/shamiursunny/openTPU/actions/runs/45225212165) software-core job, and [45225704236](https://github.com/shamiursunny/openTPU/actions/runs/45225704236) RTL-subsystems job were still running at this checkpoint; inspect their final logs before recording results.
- The RTL failure is isolated to the IMPL=3 random-traffic Verilator build matrix. Investigate the tool crash at `ram_row` with a minimal reproduction or a supported Verilator version before changing synthesizable RTL. Do not suppress or deselect the cases as if they passed. If an RTL rewrite is attempted, require the full affected matrix plus the existing 128K end-to-end test and memory regressions to pass.
- No chip-completion claim: host/PCIe and external-memory PHY integration, target/package selection, macro-aware PPA/timing, formal and CDC/RDC, full lint-warning triage, real workload/power/thermal measurements, security, BOM/TCO and production signoff remain open.


## 29. Reset audit rerun and simulator-version root cause (2026-11-23)

- Reset audit rerun [45230099519](https://github.com/shamiursunny/openTPU/actions/runs/45230099519) completed **PASS: 4 passed in 330.73 s**. The pumped-card X-state findings are now classified as guarded payload, and the MXU active-RMAX-key assertion is included in the audited source. This is a reset-state simulation audit, not whole-chip formal proof.
- The RTL failure's likely tool-version cause is now evidence-backed: the failing runner used Verilator 5.032; the official Verilator change log records in 5.044 a fix for reordering function bodies inlined on the RHS of nonblocking assignments (issue #6780), directly relevant to the internal error in `V3Delayed.cpp`. Source: https://veripool.org/guide/latest/changes.html (Verilator 5.044 section).
- Updated `.github/workflows/sunnyone-rtl-functional.yml` to build and pin Verilator v5.044 for the `rtl-uncovered` regression, with a version assertion before testing (commit `08ec7a4932b4dad5d4b2bea205f24a4e1dd356b7`). This is a simulator/toolchain correction, not an RTL waiver. The updated workflow's CI result is pending; the previous 13 Verilator 5.032 compile failures remain recorded until the affected matrix passes under 5.044.
- Software-core run [45225212165](https://github.com/shamiursunny/openTPU/actions/runs/45225212165) and RTL-subsystems run [45225704236](https://github.com/shamiursunny/openTPU/actions/runs/45225704236) were still in progress at this checkpoint. The board-functional job in run [45222828630](https://github.com/shamiursunny/openTPU/actions/runs/45222828630) was cancelled when the workflow was superseded; it must be rerun or covered by another successful run.


## 30. Latest CI and integration checkpoint (2026-11-23)

- Branch refs independently checked immediately before this tracker update: feature branch `40402b78cbb540c562ccfe87b99c83bb75f976f5`; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. No main-branch write was made.
- Full-chip Verilator lint run [45230451011](https://github.com/shamiursunny/openTPU/actions/runs/45230451011): completed **success**. Existing warning inventory remains 19 PINMISSING, 7 LATCH and 3 UNOPTFLAT; lint success does not resolve those warnings.
- Reset/power-up audit run [45230451124](https://github.com/shamiursunny/openTPU/actions/runs/45230451124): completed **success**. This remains a scoped reset audit, not whole-chip formal proof.
- RTL tail run [45230451062](https://github.com/shamiursunny/openTPU/actions/runs/45230451062), subsystem run [45230451012](https://github.com/shamiursunny/openTPU/actions/runs/45230451012), board/core RTL run [45230450987](https://github.com/shamiursunny/openTPU/actions/runs/45230450987), software-core run [45225212165](https://github.com/shamiursunny/openTPU/actions/runs/45225212165), and earlier subsystem run [45225704236](https://github.com/shamiursunny/openTPU/actions/runs/45225704236) were still reported in progress when polled. No pass/fail totals are inferred for these jobs.
- Verilator 5.044 qualification run [45231182190](https://github.com/shamiursunny/openTPU/actions/runs/45231182190), commit `08ec7a4932b4dad5d4b2bea205f24a4e1dd356b7`: board-functional job was executing its test command; uncovered RTL job was still building the pinned Verilator 5.044. The 13 prior Verilator 5.032 internal compiler failures remain unresolved until the complete affected matrix passes under the pinned toolchain.
- Reinspection of `rtl/asic/otpu_asic_top.sv` confirms it is a compute-block boundary with external memory handshakes and run/load/status ports, not a complete chip top. Reinspection of `rtl/shell/otpu_board.sv` and `rtl/shell/otpu_ctrl.sv` confirms existing host-control and board integration logic exists in the board reference, but it is tied to board-specific memory adapters, clock crossings and external PCIe/XDMA interfaces. Do not instantiate it as a generic ASIC wrapper or claim a completed PCIe/DDR chip without an explicit target-specific interface and verification.
- Current architecture disposition: logical host-controlled programmable accelerator architecture is documented; RTL compute block and reference board design exist. Chip-level host/control/data integration, selected external memory controller/PHY, formal and CDC/RDC closure, lint-warning disposition, macro-aware PPA, physical target/package, measured workload/power/thermal qualification, security, production test and commercial validation are **not complete**.
- Immediate execution order: finish and inspect all active CI jobs/logs; fix any actual functional failures without suppressions; build a target-independent integration contract and verification plan before adding a chip wrapper; then complete formal/CDC, PPA, target IP/board, workload and commercial gates. No paid services or hardware are authorised.


## 31. Lint warning triage and Verilator build correction (2026-11-23)

- Full-chip lint log from [45230451011](https://github.com/shamiursunny/openTPU/actions/runs/45230451011) confirms the 19 PINMISSING warnings originate from the single-card testbench instantiating `otpu_top` without explicit connections for optional inter-card link and collective-debug ports. Updated `sim/verilator/tb_top.sv` to explicitly tie the unused link receive inputs inactive, hold the unused link-side reset asserted, and leave unused outputs explicitly open (commit `a2ce7d939d09a4ea5718f3021f19fb8c7723b3d7`). New full-chip lint run [45232539687](https://github.com/shamiursunny/openTPU/actions/runs/45232539687) is pending; do not claim warnings cleared until its log confirms.
- Seven LATCH warnings are in `rtl/seq/otpu_seq.sv` temporary variables in combinational instruction-decode blocks (lines 1153 and 1820); three UNOPTFLAT warnings are reported in slice grant logic, collective grant logic and TMEM `pq`. They remain open pending source-level review and equivalence/regression evidence; no blanket waivers were added.
- Pinned Verilator 5.044 build attempt [45231182190](https://github.com/shamiursunny/openTPU/actions/runs/45231182190) failed before tests because the runner lacked `FlexLexer.h` while compiling `V3ParseLex.cpp`. This is a CI dependency failure, not an RTL result. Added Debian `libfl-dev` to the build dependencies in `.github/workflows/sunnyone-rtl-functional.yml` (commit `f85595c02a4e8a2948d1fc4fe146ef3fd0ba6dec`); the next run must verify the tool version and execute the complete uncovered matrix.
- The latest RTL, board, subsystem, tail, software and lint workflows triggered by the testbench update are [45232539982](https://github.com/shamiursunny/openTPU/actions/runs/45232539982), [45232539812](https://github.com/shamiursunny/openTPU/actions/runs/45232539812), [45232539683](https://github.com/shamiursunny/openTPU/actions/runs/45232539683), [45232539747](https://github.com/shamiursunny/openTPU/actions/runs/45232539747), and [45232539687](https://github.com/shamiursunny/openTPU/actions/runs/45232539687), respectively. They were in progress when recorded.


## 32. Full-chip lint warning reduction verified (2026-11-23)

- Full-chip lint rerun [45232539687](https://github.com/shamiursunny/openTPU/actions/runs/45232539687), commit `a2ce7d939d09a4ea5718f3021f19fb8c7723b3d7`: **success**. Its archived job log was inspected and warning counts are now **0 PINMISSING, 7 LATCH, 3 UNOPTFLAT**. The explicit unused-link/testbench connections removed all 19 previous PINMISSING warnings without waivers.
- Remaining seven LATCH warnings are the sequencer temporary decode variables at `rtl/seq/otpu_seq.sv:1153` and `:1820`; three UNOPTFLAT paths remain in slice grant, collective grant and TMEM `pq`. These are still open; do not suppress them without proving the intended logic and checking synthesis/functional equivalence.
- The corrected pinned-Verilator workflow run [45232660602](https://github.com/shamiursunny/openTPU/actions/runs/45232660602), commit `f85595c02a4e8a2948d1fc4fe146ef3fd0ba6dec`, is now in progress after adding `libfl-dev`; its build and test result are pending.


## 33. Archived PPA evidence recovered and correctly qualified (2026-11-23)

- Corrected the earlier blanket impression that no PPA evidence exists. The repository contains two historical Nangate45 research runs, now documented in architecture spec A1.12.11.16.44.
- ORFS `nangate45-small` archived run: source baseline 2026-10-11 / commit `596d62fa`, D=32, MCOLS=2, LANES=4, 16K TMEM, 8K IMEM, 27 fitted macros. Reported die 7.024 mm², instance area 2.471 mm², macro area 1.308 mm², setup WNS -0.428 ns at a 2.5 ns constraint, vectorless estimated power 0.790 W, zero detailed-route DRC. The README reports 422 MHz register-to-register and 341 MHz including the port budget. Timing did not meet the requested 2.5 ns.
- OpenLayout `cand2_3p3ns` archived run: 60% utilization, 2.049 mm square die, 27 macros. Global-route WNS +0.156 ns / hold +0.051 ns and zero reported DRC; vectorless power 0.555 W. Detailed extracted-parasitic setup is **-0.05 ns with 31 endpoints and TNS -0.54 ns** (hold +0.04 ns), so extracted setup timing did not close.
- Both are predictive Nangate45/FreePDK45 proxies, use fitted/abstract memory macros, are older than the current feature-branch RTL, and have vectorless—not workload-calibrated—power. They are not physical silicon, commercial PPA or production signoff. The current exact feature-branch RTL still needs a reproducible PPA rerun; the larger card point remains unqualified.


## 34. 128K TMEM qualification and latest toolchain status (2026-11-23)

- Latest isolated one-copy 128K TMEM run [45232540127](https://github.com/shamiursunny/openTPU/actions/runs/45232540127), commit `a2ce7d939d09a4ea5718f3021f19fb8c7723b3d7`: **2 passed, 215 deselected** in 82.95 s. This confirms only the isolated 128K test's two parameter cases, not the full random-traffic matrix or PPA suitability.
- Verilator 5.044 rerun [45232660602](https://github.com/shamiursunny/openTPU/actions/runs/45232660602), commit `f85595c02a4e8a2948d1fc4fe146ef3fd0ba6dec`: build job was still compiling at last poll after the `libfl-dev` dependency correction; no RTL matrix result yet.
- Board-functional, subsystem, RTL-tail and software-core jobs on commit `a2ce7d9...` remain in progress. Their exact test totals are pending logs.
- Branch head now includes the archived-PPA evidence correction and tracker update; main remains at `d84db55712aba0d40811d7762cb052f05d55b7e5`.


## 35. Python packaging metadata maintenance (2026-11-23)

- Changed `pyproject.toml` from deprecated table-form `license = { text = "Apache-2.0" }` to the SPDX string `license = "Apache-2.0"` (commit `411f7d38b149c7cccd73471a40d599670cc62e66`). This addresses the setuptools deprecation warning observed in CI; it does not change runtime behavior. The resulting package-install and test runs are pending.


## 36. Packaging fix CI checkpoint (2026-11-23)

- The SPDX-string packaging metadata change is at commit `411f7d38b149c7cccd73471a40d599670cc62e66`. It triggered fresh software-core, RTL-uncovered/board and subsystem workflows: [45233793565](https://github.com/shamiursunny/openTPU/actions/runs/45233793565), [45233793490](https://github.com/shamiursunny/openTPU/actions/runs/45233793490), and [45233793442](https://github.com/shamiursunny/openTPU/actions/runs/45233793442). All were still running when checked.
- The pinned Verilator 5.044 build in run [45232660602](https://github.com/shamiursunny/openTPU/actions/runs/45232660602) remained in its build step; the earlier attempt failed only because `FlexLexer.h` was missing. The corrected build with `libfl-dev` has not yet produced a tool-version confirmation or RTL test result.


## 37. Sequencer latch cleanup and TMEM Verilator compatibility fix (2026-11-23)

- Updated `rtl/seq/otpu_seq.sv` to initialise block-local combinational temporaries (`c2`, `r2`, `u`, `y`, `k`, `kd`, `cf`) before their conditional decode paths (commit `96e39751086ece0ffa5a76956eb6ad5f75b5b9ea`). This is intended to eliminate inferred-latch diagnostics for temporary decode variables; it is not yet verified until the new lint run completes.
- Updated `.github/workflows/sunnyone-rtl-functional.yml` to use Ubuntu 24.04 for the pinned Verilator 5.044 build and explicitly verify that `libfl-dev` supplies `/usr/include/FlexLexer.h` before compiling (commit `da2ac9541ca2aaa6b2746c9bffa7961c062b7737`). This addresses the runner-image/package ambiguity seen on Ubuntu 26.04; run [45235315326](https://github.com/shamiursunny/openTPU/actions/runs/45235315326) was still in progress.
- Updated `rtl/mem/otpu_tmem.sv` to predecode RAM write-row addresses (`pw_row0`, `pw_row1`) outside nonblocking array-write statements (commit `01e518467906930961d30ce50677df1189b07a81`). This is a source-level workaround for Verilator 5.032's internal delayed-AST multiple-write failure at `mem[ram_row(...)] <= ...`, while retaining the same row mapping. New subsystem and virtual-DRAM runs [45235689166](https://github.com/shamiursunny/openTPU/actions/runs/45235689166) and [45235689169](https://github.com/shamiursunny/openTPU/actions/runs/45235689169) were queued at the last poll.
- Lint, reset-audit, RTL-tail, subsystem, board, software and Verilator-5.044 jobs on commits `96e3975...` and `da2ac95...` remain pending/running; no pass claim is made for these changes until results are inspected.


## 38. Active qualification runs and branch integrity (2026-11-23)

- Latest branch ref verified: `dde7b1b956e2b44c46c48fda4a0ad8bb2fb6399e`; `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Current RTL qualification after TMEM row-address predecode is queued in [45235689166](https://github.com/shamiursunny/openTPU/actions/runs/45235689166) (subsystems) and [45235689169](https://github.com/shamiursunny/openTPU/actions/runs/45235689169) (virtual DRAM).
- The Ubuntu 24.04 / Flex-header-checked Verilator 5.044 build is in [45235315326](https://github.com/shamiursunny/openTPU/actions/runs/45235315326); at last poll its build step was still running. The same matrix on earlier commit `411f7d3...` [45233793490](https://github.com/shamiursunny/openTPU/actions/runs/45233793490) had progressed to the RTL test step, but its final outcome was not yet available.
- Latest sequencer temporary-default changes are under lint/reset/tail/subsystem qualification: [45235546849](https://github.com/shamiursunny/openTPU/actions/runs/45235546849), [45235546873](https://github.com/shamiursunny/openTPU/actions/runs/45235546873), [45235546857](https://github.com/shamiursunny/openTPU/actions/runs/45235546857), [45235546966](https://github.com/shamiursunny/openTPU/actions/runs/45235546966). Lint was queued; reset audit, tail and subsystem runs were in progress.
- Board-functional, core software, and broader RTL jobs from commits `411f7d3...` / `da2ac95...` were still running. Do not treat elapsed time or a running step as a pass.
- No full-chip formal proof, target-specific PCIe/DDR controller/PHY integration, current-RTL PPA, physical implementation, silicon test or commercial power/throughput measurement has been completed. These require separate verified engineering work and, for physical silicon, external foundry/board resources. No paid resources or purchases have been authorised.


## 39. PCIe board reference selection and Gen2 bridge simulation (2026-11-24)

- **Prototype reference selected (not final commercial hardware):** Inspur YPCB-00338, Kintex-7 XC7K480T, PCIe Gen2 x8 via XDMA, two DDR3-1066 channels (2 GiB each) behind LiteDRAM. This is the strongest low-risk first board path in this repository because the complete board RTL, target configuration, host driver, channel bridge, memory controller integration and historical board implementation evidence already exist. It is a reference for RTL/board-interface qualification, not a recommendation to purchase obsolete hardware or a claim of best market economics.
- The repository's targets/ypcb-00338.toml, docs/board.md, rtl/boards/ypcb-00338/otpu_native_sys.sv and rtl/boards/ypcb-00338/otpu_fpga_top_ld.sv establish the board's actual interfaces. PCIe hard IP / XDMA serial link and DDR PHY remain vendor-generated platform IP; simulation of their AXI/native interfaces does not model PCIe electrical link training, signal integrity, DDR training margins or board thermals.
- **Dedicated PCIe Gen2 simulation added:** tools/memch_test.py pcie builds the existing sim/verilator/tb_memch.sv against otpu_dma_split (registered split, XREG=1) and two otpu_mem_ch instances. The bench drives independent accelerator-native and XDMA AXI masters, three unrelated clocks at the Gen2/core/controller ratio, two-port controller models, byte-accurate scoreboards, partial writes/read-modify-write, backpressure, burst routing/order, reset interruption and CDC-skew scenarios. This tests the PCIe-facing XDMA AXI contract and memory bridge, not the PCIe serial protocol or full FPGA top.
- Added .github/workflows/sunnyone-pcie-gen2.yml to run six focused Gen2 cases: repeated XDMA reset, partial traffic, full/backpressured queues, deep 128-byte bursts, CDC-skew plus resets, and short reset under shared writes. Workflow [45237403931](https://github.com/shamiursunny/openTPU/actions/runs/45237403931) was queued at checkpoint; **no simulation result is claimed yet**.
- Commits: PCIe suite 656a7809eab62044d8711eb6c2ef1ce0ec1cac47; workflow b2bb738b4ed0b50fd3a904775b628837c5cbb516.
- Existing YPCB Gen2 model assumptions are grounded by target and RTL: XDMA AXI is 128-bit at 250 MHz; accelerator/core and controller are modelled at 133.33 MHz. The simulation's mock controller cannot validate LiteDRAM PHY, DDR3 electrical timing, PCIe hard-IP configuration, DMA driver on a physical host, or measured throughput/power.
- main rechecked unchanged at d84db55712aba0d40811d7762cb052f05d55b7e5. No hardware purchase, paid license, or paid resource used/authorised. Final ASIC device/package remains unselected; FPGA board reference does not settle ASIC process, package, or commercial BOM.


## 40. Primary performance-prototype platform decision (2026-11-24)

- **Primary performance-validation board/FPGA: BCU1525 / Xilinx Virtex UltraScale+ VU9P (xcvu9p-fsgd2104-2L-e), PCIe Gen3 x16, four DDR4 DIMM channels.** This supersedes the earlier provisional YPCB-first recommendation for performance validation. The repository documents actual card runs, two-card operation, and real-weight model validation: Qwen3.6-35B-A3B 88.5%, Qwen3.8-27B 90.6%, GPT-OSS-20B about 88.0% of the four DIMMs' 76.8 GB/s peak, with eight tokens/logits bit-exact against the ISA simulator (docs/bcu1525_wg.md; docs/bcu1525.md). This is the strongest existing evidence of useful AI inference, not merely an RTL estimate.
- **Secondary low-complexity PCIe/DDR reference: YPCB-00338 / Kintex-7 XC7K480T, PCIe Gen2 x8, two DDR3-1066 channels.** Retain it for the simpler existing otpu_mem_ch + otpu_dma_split Gen2 simulation suite and early host/driver integration. It is not the primary performance target.
- **Important BCU1525 limitations:** repository's actual card configuration uses four 8 GB DDR4-2400 UDIMMs without ECC; the ECC RDIMM configuration is described but not validated on-card. The board requires active cooling and a VU9P-capable Vivado licence/build host (32 GB+ RAM). A chipset slot may negotiate only Gen2 x4. Therefore it is a high-performance validation platform, not automatically the lowest-cost/reliability-optimal commercial product. ECC-capable DIMM/MIG path, slot topology, cooling, BOM, availability and full-system economics must be validated before any purchase or product commitment.
- BCU1525's dedicated board model is sim/verilator/tb_bcuwg.sv, exercised by tests/test_bcuwg_board.py; it models the WG8 accelerator, eight virtual channels, two channels per DIMM, DIMM AXI4 ports, latency/jitter/bandwidth/stalls and out-of-order responses. This provides functional board-memory-path simulation and ISA bit-exact comparisons, but does not simulate PCIe serial link training or electrical behaviour. The host DMA path in the BCU board model still needs explicit qualification before claiming full PCIe end-to-end coverage.
- The corrected YPCB Gen2 XDMA bridge workflow [45239360365](https://github.com/shamiursunny/openTPU/actions/runs/45239360365) later completed successfully: all six bridge scenarios passed with Verilator 5.044. It tests the XDMA-facing AXI bridge with Gen2 clock ratios, not PCIe PHY or hard-IP link training.
- No board or FPGA purchase, paid Vivado licence, or other paid resource is authorised. Primary validation platform decision is BCU1525/VU9P; final custom ASIC process/node/package remains open pending workload, ECC, power, PPA, manufacturability and TCO evidence.


## 41. PCIe Gen2 CI toolchain correction (2026-11-24)

- First PCIe simulation attempt, run 45237403931, failed at compile before any scenario ran. The workflow installed Ubuntu Verilator 5.020, which rejects the existing SystemVerilog queue assignment pattern at tb_memch.sv:720 (UNSUPPORTED / V3Width internal error). This is a simulator-version compatibility failure, not an RTL functional failure and not a passed test.
- Updated the dedicated workflow to build and verify Verilator 5.044, matching the project's existing uncovered-RTL toolchain and its required SystemVerilog support. Commit 161cddbb76cc293bdacdab3af2c7037a984f1c67. The corrected simulation passed all six scenarios.
- Corrected run [45239360365](https://github.com/shamiursunny/openTPU/actions/runs/45239360365) completed successfully. Verilator 5.044 built and all six scenarios passed: gen2xres, gen2part, gen2full, gen2deep128, gen2skewx and xresetshortsh.
- Other outstanding runs 45235689166, 45235689172, 45235689174 and 45235689146 were still in progress at the last poll. Earlier same-branch evidence remains: full-chip lint passed after sequencer temporary initialisation; reset audit and RTL-tail tests passed on their respective commits; virtual DRAM and isolated 128K TMEM tests passed.
- Architecture limitation unchanged: BCU1525/VU9P is the primary high-performance FPGA validation target, not the final ASIC. Current ASIC boundary still lacks PCIe/BAR, complete host-control integration, external memory controller/PHY, and complete chip-level reset/clock/security wrapper. Exact foundry process, package, ECC memory platform and commercial BOM remain unselected. No production/tapeout claim.


## 42. ASIC chip-level integration contract (2026-11-24)

- Added `docs/sunnyone/SUNNYONE_AI-X_CHIP_INTEGRATION_CONTRACT_A1.12.11.16.45.md`. It freezes the logical compute candidate at the existing Nangate45 `card` parameters (D128, MCOLS4, LANES8, MXU systolic, 64K TMEM, 32K IMEM, single slice) while explicitly retaining Nangate45 as a research proxy, not a manufacturable node.
- Defined required chip blocks and interfaces: PCIe endpoint/hard IP, AXI4-Lite BAR, AXI4 DMA, DMA-to-A/SW/B memory adapter, compute core, external memory controller/PHY with ECC/calibration, clock/reset/power manager, DFT/security.
- Specified run/load gating, register compatibility, reset/CDC behaviour, memory error semantics, DMA bounds and release gates. This is an integration contract, not implemented RTL; control wrapper, DMA adapter, PCIe IP, memory PHY and full-chip verification remain open.
- Primary performance validation board remains BCU1525/VU9P; YPCB-00338 remains the secondary PCIe Gen2 bridge reference. Dedicated PCIe Gen2 CI is pinned to Verilator 5.044 after the first Verilator 5.020 testbench compile failure; corrected run 45239360365 passed all six scenarios.
- Outstanding CI runs 45235689166, 45235689172, 45235689174 and 45235689146 remain in progress at last poll; no results inferred.
- main remains d84db55712aba0d40811d7762cb052f05d55b7e5. No hardware purchase or paid licence.


## 43. ASIC control + compute subsystem RTL (2026-11-24)

- Implemented `rtl/asic/otpu_asic_ctrl.sv`: AXI4-Lite v5-compatible core registers, independent AW/W acceptance, byte strobes, ID/version/status, program address/length, R8-R15, RUN/STOP and one-cycle LOAD, two-channel calibration/ECC gating, load-inflight interlock, sticky command error cleared by CTRL bit2, cycle and memory-traffic counters, CAPS/CFG fields, SLVERR/DECERR handling and atomic rejection of invalid commands.
- Implemented `rtl/asic/otpu_asic_chip_top.sv`: instantiates the selected ASIC compute block and the new control wrapper. Default parameters match the Nangate45 card research point (D128/MCOLS4/LANES8, one-copy unpumped TMEM, WAITC, BAR-only collective).
- Added `sim/asic/tb_asic_ctrl.sv` and `.github/workflows/sunnyone-asic-ctrl.yml`; test covers AW/W independence, byte-register access, reset, calibration/ECC/memory-error gating, load-inflight interlock, sticky-error clear, counter accounting, configuration registers and DECERR.
- First control test run 45240514018 failed because the test expected STATUS=0x02 and omitted WR_IDLE bit3; observed 0x0A was correct. Test expectations and scenarios were expanded. Latest full control test run 45242112410 is queued; no pass claimed.
- Updated `.github/workflows/sunnyone-asic-config.yml` to lint `otpu_asic_chip_top` using the card target's exact source list; run 45240984173 is queued. Full-chip lint run 45240983745 is queued.
- Important boundary: this is a control+compute subsystem, **not a complete PCIe chip**. PCIe endpoint/hard IP, host DMA engine, DMA-to-A/SW/B memory adapter, external DRAM controller/PHY/ECC, DFT, CDC/RDC and package/physical implementation are still not integrated. Current PPA flow still measures `otpu_asic_top` core only, not the new wrapper. No production or tapeout claim.
- main remains d84db55712aba0d40811d7762cb052f05d55b7e5. No hardware purchases or paid licences.


## 44. PCIe bridge qualification and ASIC control hardening (2026-11-24)

- **PCIe Gen2 XDMA-facing memory bridge simulation now PASS:** run [45239360365](https://github.com/shamiursunny/openTPU/actions/runs/45239360365), job 137919506712. Pinned Verilator 5.044 build passed. Six scenarios passed: repeated XDMA reset, partial traffic, full/backpressured queues, deep 128-byte bursts, CDC-skew and short reset under shared writes. This qualifies the YPCB bridge's AXI/native-memory contract only; no PCIe serial link/PHY or electrical board qualification.
- Added v5-compatible counters/configuration to the ASIC control wrapper; implemented a load-inflight interlock (RUN cannot start until ld_busy has been seen high and then low), two-channel calibration/ECC gating, fail-closed stop on calibration loss/fatal memory error, and two-stage synchronizers for memory-calibration/error/ECC status in otpu_asic_chip_top.
- Control testbench now includes register map/capability checks, traffic counters, load-inflight gating, ECC and calibration gating, fatal memory-error abort, and sticky-error recovery. Latest run [45242112410](https://github.com/shamiursunny/openTPU/actions/runs/45242112410) is queued. Integrated ASIC-top lint run [45242138796](https://github.com/shamiursunny/openTPU/actions/runs/45242138796) and full-chip lint run [45242138766](https://github.com/shamiursunny/openTPU/actions/runs/45242138766) are queued; no pass claimed.
- Older run 45235689174 (RTL-tail regression at commit 01e5184) completed successfully. Runs 45235689166 and 45235689172 remained in progress; do not treat them as passed.
- Current ASIC subsystem still excludes PCIe endpoint/hard IP, host DMA, DMA-to-memory adapter, external memory controller/PHY/ECC implementation and DFT. Nangate45 remains a research proxy. The final manufacturable process, package, board, physical closure and full-chip production design remain open.


## 45. Host register-map fidelity and current verification queue (2026-11-24)

- Corrected ASIC CAPS/CAPS2 generation to mirror the existing v5 control block's field semantics: WAITW/GEN/MX, DSTEP, ARG, ACT_ROWS, PQ window, trace depth, channel hash, PAIR, 4-bit MM, DDR rate, temperature/I2C and trace flags. CAPS2 reports the supported ICACHE flag; other board-only features remain zero. The selected ASIC defaults yield CAPS=0xE70A0070 and CAPS2=0.
- ASIC control test now checks CAPS/CAPS2, CFG sizes/uarch/platform, v5 status/counters, memory calibration/ECC/error gating, loader busy interlock and fail-closed stop on memory fault.
- Latest control simulation [45242551921](https://github.com/shamiursunny/openTPU/actions/runs/45242551921) queued; integrated ASIC-top config/lint [45242533670](https://github.com/shamiursunny/openTPU/actions/runs/45242533670) and full-chip lint [45242533290](https://github.com/shamiursunny/openTPU/actions/runs/45242533290) queued. No results claimed.
- PCIe Gen2 bridge simulation run 45239360365 remains PASS (six of six scenarios). RTL-tail run 45235689174 PASS; subsystem run 45235689166 and board/uncovered run 45235689172 remain in progress at last poll.
- main verified unchanged: d84db55712aba0d40811d7762cb052f05d55b7e5. Feature branch only. No paid resources or hardware purchases.


## 46. WG8 performance-led ASIC candidate selected (2026-11-24)

- Corrected the architecture selection: the strongest documented real-card inference evidence is specifically BCU1525-WG8, not the base BCU1525/WG1 target. New decision record: docs/sunnyone/SUNNYONE_AI-X_WG8_ASIC_ARCHITECTURE_A1.12.11.16.46.md. Earlier WG1/MCOLS4 documents .44/.45 are marked historical/superseded for the primary V1 candidate.
- Selected logical ASIC candidate: one slice, D128/MCOLS8/WG8, NCH8/CB128/AW36, 32 GiB logical memory, 128K TMEM, 32K IMEM, ACT_ROWS16, MXU_E8, MXU_QD4, WIN32, FIFO2048, SE_R2/DMA_DEPTH512, DSTEP2/ST16 e6m9/KT enabled, OUTER off, one-copy TMEM at core clock, TMEM_PMP=0, MXU_PUMP=0, XPOST=0, BAR-only collective.
- BCU1525-WG8 is a performance reference, not an ASIC equivalence claim. Its FPGA-specific pumped SRAM/posted channel path is deliberately disabled for ASIC. Fresh ASIC PPA and workload validation are mandatory.
- Parameterized rtl/asic/otpu_asic_top.sv for WG/NCH/CB/AW, wide A/SW/B addresses, 1,024-bit A/B data, 3-bit channel selector and W-port data/slot. rtl/asic/otpu_asic_chip_top.sv now defaults to WG8 and exposes the W port; XPOST is explicitly rejected until posted-beat clock/data integration exists.
- Added targets/nangate45-wg8.toml; updated tools/asic/flow.py to derive full RTL parameters from opentpu.target.rtl_params, including WG8/NCH8/CB128/AW36. Added test assertions for the WG8 parameter tuple.
- Added .github/workflows/sunnyone-asic-wg8-ppa.yml. Run [45244170656](https://github.com/shamiursunny/openTPU/actions/runs/45244170656) is queued; no synthesis/PPA result yet. ASIC configuration/test runs 45243820830 and related jobs are also queued. The PPA flow still measures otpu_asic_top core only, not PCIe, control wrapper or external memory controllers.
- The YPCB Gen2 XDMA bridge six-case simulation remains PASS (45239360365), but its two-channel/64-byte contract does not qualify the WG8 eight-channel/128-byte W-port interface. A dedicated WG8 memory-adapter simulation is still required.
- V1 logical memory target is 32 GiB; 128 GiB is not selected. PCIe endpoint/hard IP, host DMA, 8-channel memory adapter/controller/PHY/ECC, DFT, foundry PDK, package, full PPA, CDC/RDC and physical validation remain open.
- main unchanged at d84db55712aba0d40811d7762cb052f05d55b7e5. No paid resources or hardware purchases.


## 47. WG8 native-memory subsystem integration (2026-11-24)

- Added rtl/asic/otpu_asic_mem_top.sv: composes the WG8 ASIC control/compute top with rtl/mem/otpu_native_dram.sv and exposes eight native 128-byte memory-controller channels. Address width AW36, per-channel command address 26 bits, XSW=11 (matches FIFO_DEPTH2048), PCW=13, WFW6. ASIC mode uses SW_FILL=1, WPOST=0, SWG=0, XPOST=0, RHB=0 and WHB=0; native queues start from BCU WG8's APF8/AD16/RD16, XD64, QD16, WQD32. Calibration is aggregated into two v5 status groups; errors/DED are aggregated and synchronized.
- The controller boundary is synchronous to core clk and must return reads in per-channel command order, increment n_wdone for accepted writes, support byte-mask writes with ECC correctness, and provide two aggregate calibration bits. This is not a DDR PHY/controller implementation.
- Added CI lint for the integrated native-memory top in .github/workflows/sunnyone-asic-config.yml (run [45245142303](https://github.com/shamiursunny/openTPU/actions/runs/45245142303), queued at last poll).
- Added tests/test_native_dram.py ASIC-mode regression: 8 channels × 128-byte beats, AB128, APF8/AD16/RD16, SW_FILL1, no FPGA-only WPOST/XPOST/SWG. It checks randomized A/SW/B/W traffic and scalar partial-write merge against the native memory model. The subsystem run [45245112317](https://github.com/shamiursunny/openTPU/actions/runs/45245112317) was queued before this new case was added; the new case still needs a fresh CI result.
- WG8 PPA run [45245112312](https://github.com/shamiursunny/openTPU/actions/runs/45245112312) remains queued. No WG8 PPA or physical-board result is claimed. PCIe endpoint/DMA, actual ECC controller/PHY, DFT and physical signoff remain open.
- main remains unchanged at d84db55712aba0d40811d7762cb052f05d55b7e5.

## 48. FPGA/PCIe prototype platform and ASIC technology decision (2026-11-24)

- **Primary FPGA reference selected: BCU1525 / VU9P, WG8 image.** This is the only candidate with a directly supported repository build/bring-up flow, the four-DDR4-DIMM 32-GiB configuration, PCIe Gen3 x16, existing board-memory co-simulation and documented real-model inference/bit-exact comparisons. Retain this as the golden FPGA reference for workload and architecture validation. This is not a recommendation to buy one now.
- **Secondary PCIe bridge reference: YPCB-00338 / Kintex-7, Gen2 x8.** Corrected Verilator 5.044 simulation run [45239360365](https://github.com/shamiursunny/openTPU/actions/runs/45239360365) passed all six scenarios (gen2xres, gen2part, gen2full, gen2deep128, gen2skewx, xresetshortsh). This proves the simulated XDMA-facing AXI/native-memory bridge scenarios only, not PCIe PHY/link training or the WG8 8-channel memory interface.
- **Why not switch the primary prototype to U55C:** AMD specifies 16 GiB HBM2, 460 GB/s, PCIe Gen3 x16 / Gen4 x8 and 150-W maximum electrical card load. Its HBM topology and 16-GiB capacity do not match the WG8 32-GiB DDR4 reference, so it would require a new memory-controller/adapter and host software port. It is a later bandwidth experiment, not the lowest-risk first port.
- **U250 remains an alternate port target**, not selected: its documented PCIe Gen3 x16 and 64-GiB DDR4/77-GB/s configuration is interesting for capacity, but this repository has no U250 board target and it would require a fresh platform port and full regression. Compare it against BCU only after exact board revision, memory/ECC topology, availability, cooling, host compatibility and total cost are verified.
- **License constraint:** the repository's BCU1525 instructions state VU9P requires a licensed Vivado target; current AMD 2026.1 tiers place Virtex UltraScale+ in CORE or higher, not free BASIC. Alveo cards have a dedicated annual Vivado Alveo license for purchasers. No paid licence or hardware purchase is authorised. Continue simulation and open-source research PPA until access to an existing board/licence or an approved budget is established.
- **ASIC process/node/package deliberately NOT selected.** Nangate45 remains a research proxy only. A manufacturable node cannot be responsibly frozen before obtaining a foundry PDK, SRAM compiler/macro views, PCIe PHY/controller IP, memory/ECC strategy, package/IO limits, multi-corner PPA and an actual manufacturing quote. Do not equate the FPGA's VU9P device with the ASIC technology.
- Current WG8 CI runs on branch head acad738c572d6036a9a01b899b7cd2103927692b were queued at this checkpoint: ASIC configuration/integrated lint 45245713119; WG8 PPA 45245713055; uncovered RTL + board 45245713234; reset audit 45245713144; RTL subsystems/WG8 memory regression 45245713352; RTL tail 45245713131; full-chip lint 45245713175. No results inferred.
- main verified unchanged at d84db55712aba0d40811d7762cb052f05d55b7e5. No purchase or paid resource used.


## 49. PCIe host/DMA architecture and CI hardening (2026-11-24)

- Added docs/sunnyone/SUNNYONE_AI-X_PCIE_HOST_INTERFACE_A1.12.11.16.48.md.
- Selected PCIe Gen3 x16 as the V1 compatibility target, matching BCU1525 WG8/XDMA. Logical host path: endpoint + DMA, BAR0 AXI4-Lite, 512-bit AXI4-MM DMA master, memory arbitration, four 512-bit controller ports paired from eight 128-byte logical channels. Raw one-direction line-rate ceiling is ~15.75 GB/s before protocol overhead; actual DMA throughput is unmeasured.
- Defined host DMA descriptor, 64-bit address, byte-strobe, 4-KiB boundary, IOMMU, MSI-X, FLR/hot-reset, link-down and cross-master visibility requirements. This is a contract, not endpoint/DMA RTL.
- Existing PCIe Gen2 XDMA bridge run 45239360365 passed six simulation scenarios; it is explicitly not PCIe PHY/link training or WG8 end-to-end PCIe qualification.
- U55C was not selected for first port: 16-GiB HBM2 and its memory topology require a significant port from WG8's 32-GiB DDR4 reference. U250 remains an unqualified alternative. BCU1525/VU9P remains the golden FPGA board because the repository has the direct WG8 build, model and host path.
- Hardened .github/workflows/sunnyone-asic-config.yml with Bash pipefail so pytest failure cannot be masked by tee. Workflow change is committed; GitHub Actions run after this change has not yet been observed.
- ASIC endpoint/PHY/DMA RTL, memory-controller arbitration, real ECC PHY, PCIe BFM, formal/CDC, WG8 PPA, process/package and physical signoff remain open.
- Branch head at this checkpoint: a0caa468d7c6e40efe5c63411875b4941486f3b4. main remains d84db55712aba0d40811d7762cb052f05d55b7e5. No purchases or paid IP/licences.
