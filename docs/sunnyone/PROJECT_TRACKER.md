# SUNNYONE AI-X Project Tracker

Last updated: 2026-11-26 (Asia/Dhaka)
Repository: https://github.com/shamiursunny/openTPU
Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Protected working rule: do not modify `main`; all project work and tracker updates go to the active branch.
Latest completed broad RTL regression with Yosys+Slang reset audit: Run [45382805606](https://github.com/shamiursunny/openTPU/actions/runs/45382805606), exact SHA `d281621836d86e608ad34c4fd44d6edf339e98fe`, 377 passed, 1 intentional 64-GiB address-window skip, zero reported failures. Latest focused shared-DIMM mux burst simulation: Run [45401880965](https://github.com/shamiursunny/openTPU/actions/runs/45401880965), exact SHA `4437e1d93bf14f41377c12e0e3ea32b426d90c1a`, successful directed 3-beat host/pair AW-W-B and AR-R test with response backpressure. Current active branch head before this tracker update: `5cf5b4c40c46d2f07a6f4c30abd122032f914938`. `main` independently verified unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`.

## 1. Product objective and decision rule

Build a commercially useful, programmable AI inference accelerator. Optimise risk-adjusted long-term net profit and fastest realistic investment recovery while maintaining reliable, competitive inference. The former 30 W total-system ceiling is retired. Select the power envelope using measured workload throughput, full-system total cost of ownership (TCO), and incremental contribution margin. Do not optimise watts, RAM capacity, or peak TOPS in isolation.

Zero-spend by default. No paid service, hardware purchase, or other expenditure without explicit user authorisation. Do not claim performance, power, thermal, cost, manufacturing, customer, revenue, or payback results without measurements/evidence.

## 2. Current stage

**Stage:** A1.12.11.16.54 — consolidated V1 logical design candidate completed; remaining work is verification closure, host/memory integration, PHY/IP feasibility, physical implementation, hardware validation and commercial qualification.

**Selected logical V1 candidate:** one WG8 slice, D/MCOLS/WG 128/8/8, 32 GiB logical DRAM, AW35, eight native 4-GiB channels grouped into four 8-GiB DIMM ports, four 512-bit AXI host interfaces, 128K TMEM / 32K IMEM. Full parameter and boundary definition is in docs/sunnyone/SUNNYONE_AI-X_V1_FINAL_LOGICAL_DESIGN_CANDIDATE_A1.12.11.16.54.md. This is a logical architecture candidate only, not a complete host-connected ASIC or tapeout-ready design.

**Latest completed broad regression:** Run [45382805606](https://github.com/shamiursunny/openTPU/actions/runs/45382805606), exact SHA `d281621836d86e608ad34c4fd44d6edf339e98fe`: 377 passed, 1 intentional 64-GiB address-window skip, zero reported failures; Yosys+Slang reset audit executed and passed. This is bounded regression evidence, not full formal signoff.

**Latest focused mux result:** Run [45401880965](https://github.com/shamiursunny/openTPU/actions/runs/45401880965), exact SHA `4437e1d93bf14f41377c12e0e3ea32b426d90c1a`: directed concurrent pair/host three-beat AW-W-B and AR-R burst simulation passed with response backpressure (2 write bursts, 6 read beats, 25 cycles). Non-fatal lint warnings remain; scope limitations are documented in section 97.

**Pending exact-SHA verification:** PPA Run 45402124448, four-DIMM ASIC/config Run 45402976553, board/remaining RTL Run 45402976579, subsystem/memory Run 45402976898, RTL-tail Run 45402976724, isolated TMEM Run 45402976616 remain queued; software-core Run 45402976582 remains in progress at the last poll. No pass is assumed for these runs.

## 3. Recent implementation / evidence

- Added standalone `tests/test_axil_iso.py`, independent of optional model-only dependencies (commit `443299c0c26b3a9c523d9dbfe6c944ab7ffbb29a`).
- Updated `.github/workflows/sunnyone-rtl-functional.yml` to run the standalone regression and include its path filter (commit `24b6780d20766595f54d68f6eb19d2aa3187e6e1`).
- AXI-Lite testbench `sim/verilator/tb_axil_iso.sv` tests random master/slave resets, response isolation, completion of accepted accesses, and expected bypass failure. It exercises seeds 1 and 2 and both bypass configurations.
- Related prior testbench improvements: randomized WSTRB and byte-enable model; B/R response stability under backpressure; expected-payload scoreboard for AW/W/WSTRB; expected transaction survives master reset and clears on slave reset.
- RTL under test: `otpu_axil_iso` in `rtl/shell/otpu_ctrl.sv`.

## 4. Immediate next actions

1. Poll the exact queued/in-progress runs listed in section 97; inspect actual logs and artifacts, not only run summaries.
2. Close the four-DIMM WG8 integration gate: verify AW35 target contract, integrated lint, successful Verilator build, four-port simulation PASS marker, and all warnings on exact SHA `716fb74676e9e6cdbb8842d927d62ff2c47580b7`.
3. Close the reproducible Nangate45 research PPA run using its exact captured container image ID; archive tool versions, constraints, scripts and reports. Treat outputs as a research proxy only.
4. Extend mux tests to cover fairness/starvation bounds, sustained contention, byte-strobe effects, reset with outstanding traffic, malformed/unaligned/4-KiB-crossing requests, reserved-ID collision rejection, and simultaneous pair/host traffic on all four DIMMs.
5. Continue formal properties, protocol assertions, CDC/RDC and full lint; classify all warnings and unresolved findings. Do not convert lint success into a formal or silicon claim.
6. Resolve production PCIe endpoint/SerDes, DMA/IOMMU, DDR controller/PHY, ECC, PDK, package and DFT feasibility. The open-source candidates audited in section 94 do not provide a drop-in production PCIe Gen3 x16 plus eight-channel DDR4 ASIC subsystem.
7. Build real-workload benchmark and measurement plans. No physical throughput, latency, energy, power, thermal, reliability or cost result exists until measured on representative hardware.
8. Validate demand, pricing, manufacturing/package cost, deployment TCO, contribution margin, cash flow and payback using evidence. No commercial validation is claimed.
9. Preserve zero-spend approval, feature-branch-only changes, exact-SHA evidence, and main-branch protection.

## 5. Stage gates and maturity

| Gate | Scope | Current status |
|---|---|---|
| G0 | Selected RTL regression | Partial: broad regression Run 72 and focused mux burst test passed; newer broad runs remain pending |
| G1 | Core correctness | Partial: selected RTL/ISA and directed integration tests pass; exhaustive protocol/fault coverage incomplete |
| G2 | Formal verification and lint | Partial: reset audit and selected lint checks pass; full formal, CDC/RDC and warning closure incomplete |
| G3 | Nangate45 research PPA | Pending: corrected reproducible workflow queued; no new WG8 PPA result |
| G4 | Target device and package | Not selected; production PDK/IP/package feasibility unresolved |
| G5 | Board and memory integration | Partial: logical host/DIMM wrapper and four-DIMM host bench added; exact-SHA integration run pending; no PHY/electrical validation |
| G6 | Real workload qualification | Not run on representative hardware |
| G7 | Commercial validation and unit economics | Not validated; no measured TCO, customer demand, revenue or payback |
| G8 | Production signoff | Not ready; PCIe/DDR PHY, DMA/IOMMU, DFT, physical signoff, package and silicon evidence absent |

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

## 50. Hardware-selection correction and 36-bit address regression (2026-11-24)

- Corrected section 48's wording: **BCU1525/VU9P is the golden WG8 performance/simulation reference, not the approved physical prototype.** Its VU9P Vivado licence requirement conflicts with the user's zero-spend/no-paid-licence rule.
- Preserved the prior technology decision: VC1802/VSVD1760 was the high-capacity feasibility lead; VC1902 only the higher-compute alternative. Both are blocked for physical work because the required Vivado PRO/Enterprise licence is not authorised. Earlier 128-GiB DDR4/ECC figures remain unvalidated proposals, not design facts.
- ECP5-5G Versa (LFE5UM5G-45F-VERSA-EVN) is the small open-flow demonstrator candidate only: PCIe x1 edge, 64M x16 DDR3 (1-Gbit/128-MiB), ECP5-5G. Project Trellis/Yosys/nextpnr supports the board. The open katsuo.pcie stack is explicitly a Gen1 x1 proof of concept with incomplete LTSSM, retransmission and flow control; it is **not** a qualified DMA endpoint. It cannot host the WG8 design or validate the 32-GiB memory subsystem. No purchase authorised.
- The separate Lattice ECP5 PCI Express Development Kit is discontinued. Do not use it as a procurement recommendation.
- Added sim/asic/tb_asic_aw36.sv and test_wg8_asic_aw36_high_address_decode_rtl in tests/test_native_dram.py. It checks a 16-GiB byte address through the AW=36/NCH=8/CB=128 native adapter, observing the expected channel and 26-bit local beat address without allocating a 64-GiB model. CI run [45246583075](https://github.com/shamiursunny/openTPU/actions/runs/45246583075) is queued; no pass claimed.
- Hardened ASIC config CI with pipefail; run [45246174940](https://github.com/shamiursunny/openTPU/actions/runs/45246174940) is queued. WG8 PPA 45245713055, integrated ASIC lint 45245713119 and WG8 subsystem run 45245713352 also remain queued.
- PCIe Gen2 bridge simulation [45239360365](https://github.com/shamiursunny/openTPU/actions/runs/45239360365) remains PASS (six scenarios); it is not a full PCIe endpoint qualification.
- WG8 remains the logical ASIC candidate. PCIe Gen3 x16 remains its compatibility interface target. The manufacturable ASIC process/package remains open until real PDK, SRAM macros, PCIe PHY, memory controller/ECC IP, physical PPA and commercial economics are available.
- main remains unchanged at d84db55712aba0d40811d7762cb052f05d55b7e5. No hardware purchase, paid licence, paid IP or cloud expenditure.

## 51. ASIC control safety review and regression expansion (2026-11-24)

- Independent RTL review found two control issues: A_RD counted A writes as reads, and LOAD was not explicitly rejected while RUN was active.
- Corrected rtl/asic/otpu_asic_ctrl.sv: A_RD increments only on accepted a_req && a_rdy && !a_we; LOAD rejects when compute is running or writes are not drained; a STOP-to-RUN transition waits for wr_idle, while an idempotent RUN command during active execution remains allowed. Both commands retain calibration, busy, in-flight, memory-error and ECC-DED gates.
- Added a_we to control wrapper input and connected it from otpu_asic_chip_top; sim/asic/tb_asic_ctrl.sv now verifies LOAD-while-running rejection, RUN/LOAD write-drain gating and A read/write counter distinction.
- Hardened .github/workflows/sunnyone-asic-ctrl.yml with set -o pipefail; it is triggered by control RTL/testbench changes. CI outcome not yet observed.
- AW36 high-address regression is still awaiting run [45246583075](https://github.com/shamiursunny/openTPU/actions/runs/45246583075); WG8 ASIC config [45246174940](https://github.com/shamiursunny/openTPU/actions/runs/45246174940), research PPA [45245713055](https://github.com/shamiursunny/openTPU/actions/runs/45245713055), integrated lint [45245713119](https://github.com/shamiursunny/openTPU/actions/runs/45245713119), and WG8 subsystem run [45245713352](https://github.com/shamiursunny/openTPU/actions/runs/45245713352) were queued at last poll. Do not infer success from queued jobs.
- The control wrapper remains AXI-Lite only. PCIe endpoint, DMA, host/compute arbitration, physical memory controller/PHY, complete CDC/RDC, DFT, foundry PDK and signoff remain unimplemented/open.
- Branch head at this checkpoint: 96bb1b11bc88ffbefb42df0bb8a99782b25ff5d7. main unchanged at d84db55712aba0d40811d7762cb052f05d55b7e5.

## 52. AW36 testbench review and address-map correction (2026-11-24)

- Reviewed the high-address test against otpu_native_dram. With CHASH explicitly disabled, the 16-GiB byte address (34-bit word address 2^32) maps to channel 0, not channel 1; corrected the expected n_cvalid and n_caddr index. Expected channel-local beat address remains 26'h1000000. This was a test expectation correction, not an RTL datapath change.
- The regression compiles only otpu_tech_ram + otpu_native_dram + tb_asic_aw36, then checks the PASS marker through the existing Verilator test fixture. It still awaits CI execution; no pass claimed.
- Control RTL changes are on branch; a_we is wired from compute to the counter logic. Full-chip lint and ASIC control CI have not yet returned completed results.
- Latest branch head: 399b3709b304a80ed493ebdfc9d1ab8a7b82275a. main unchanged at d84db55712aba0d40811d7762cb052f05d55b7e5.

## 53. WG8 four-DIMM ASIC memory integration boundary (2026-11-24)

- Added rtl/asic/otpu_asic_wg8_ddr4_top.sv. It instantiates the existing ASIC core/native-memory top, eight otpu_hbm_ch native-to-AXI3 256-bit bridges, and four otpu_mig_pair 2-channel-to-AXI4 512-bit adapters.
- Exposes four 34-bit-local-address, 512-bit DIMM/controller ports. AxSIZE=6 (64 bytes), AxBURST=INCR; fixed cache/protection/QoS attributes are explicit. Four DIMM calibration signals are reduced into two fail-closed status groups; any bridge's sticky protocol error is fed back to stop compute.
- Added a Verilator lint step for otpu_asic_wg8_ddr4_top to sunnyone-asic-config.yml, using the BCU1525 WG8 generic source set plus ASIC top modules. The step is not yet confirmed because GitHub Actions jobs remain queued.
- Added docs/sunnyone/SUNNYONE_AI-X_WG8_DDR4_INTEGRATION_A1.12.11.16.50.md describing the hierarchy, port contract and outstanding integration gates.
- Critical limit: this is the accelerator-to-four-DIMM AXI integration boundary, **not** a complete SoC. PCIe endpoint/PHY, DMA engine, host/accelerator arbitration and shared ordering, IOMMU, DDR controller/PHY/ECC, foundry PDK, DFT and physical signoff remain open. The host DMA must be integrated into the same controller/interconnect ordering domain; do not attach it to a separate memory path.
- Latest CI workflow run for the wrapper lint is [45251120714](https://github.com/shamiursunny/openTPU/actions/runs/45251120714), queued. ASIC control, PPA, reset, subsystem and RTL jobs are also queued; no results are inferred.
- Latest branch head at this checkpoint: 7f9d9d5d653bf6eaa8c6d123bacb74f50c3c46ce. main unchanged at d84db55712aba0d40811d7762cb052f05d55b7e5. No hardware or paid resources used.

## 54. WG8 DDR4 wrapper reset-domain hardening (2026-11-24)

- Added per-DIMM active-high reset synchronisers into aclk in otpu_asic_wg8_ddr4_top; pair reset is released after two stages and each channel bridge one additional aclk cycle later. Core reset asynchronously asserts the synchronisers and deassertion is observed through the aclk stages.
- Updated the integration document with the reset approach and its limitation: full CDC/RDC and reset fault-injection remain unverified.
- Wrapper Verilator lint is wired into sunnyone-asic-config.yml and will elaborate the BCU1525 WG8 source set plus ASIC modules. The latest relevant run is [45251120714](https://github.com/shamiursunny/openTPU/actions/runs/45251120714), but it was queued at last poll. No lint pass claimed.
- Multiple historical CI runs (including ASIC control, WG8 memory regression, full-chip lint, PPA and reset audit) have remained queued since 2026-11-23; the GitHub Actions runner queue is currently blocking verification. Do not claim these tests passed until jobs start and finish.
- Latest source/doc commit at checkpoint: 2c8ea3acbfc17de16c516afab69aa00d01146e17. main remains d84db55712aba0d40811d7762cb052f05d55b7e5. No purchase or paid tool/IP used.


## 55. WG8 host-DMA and accelerator shared-DIMM arbitration (2026-11-24)

- Integrated four instances of the existing BCU1525 `otpu_mig_hmux` into `rtl/asic/otpu_asic_wg8_ddr4_top.sv`: one 512-bit host AXI4 master per DIMM now shares the same DIMM AXI path with that DIMM's accelerator channel pair.
- Arbitration preserves AXI4 write-data ownership/order with the existing owner FIFO, routes B/R responses using reserved host ID bit 2, and uses the existing W/R register slices. Host addresses at this boundary are 34-bit DIMM-local addresses; a PCIe DMA/address-translation block must still perform card-global-to-DIMM/channel mapping.
- Updated `sunnyone-asic-config.yml` to include `rtl/boards/bcu1525/otpu_mig_hmux.sv` in the WG8 top lint source set. Updated integration specification A1.12.11.16.51.
- This closes the previous missing RTL mux between host and accelerator at the DIMM port, but is **not** a PCIe endpoint or DMA engine. IOMMU/aperture enforcement, descriptor handling, MSI-X, global address translation, DDR controller/PHY/ECC, FLR/hot-reset, full CDC/RDC, formal, physical PPA and signoff remain open.
- New lint and adversarial dual-master simulation have not yet completed. Existing queued workflow jobs must not be treated as passes. Next verification: compile/lint this top with hmux included, then build four-DIMM dual-master tests covering AW/W order, ID routing, overlapping-address visibility, partial writes, response stalls, reset and address remap.
- No hardware, paid licence or paid IP used; `main` remains untouched.


## 56. WG8 memory-capacity/address-width correction (2026-11-24)

- Cross-check of `otpu_native_dram` address geometry found that AW=36 allocates 26 channel beat-address bits, but **does not force a 64-GiB physical map**: the separate `DRAM_BYTES=32 GiB` configuration limits valid traffic to 4 GiB per channel. The established BCU1525-WG8 target itself uses AW=36 with 32 GiB configured memory. The earlier interpretation that AW=36 necessarily over-addressed the DIMMs was incorrect.
- Kept the ASIC candidate at **AW=35** as a deliberate minimum-width optimisation for its 32-GiB map, with channel beat-address width **CAW=25**. This yields 4 GiB/channel; eight channels = 32 GiB; two channels per DIMM = 8 GiB. Word-address width is 33 bits. This is a valid narrowing choice, not a required capacity bug fix.
- Kept the existing 34-bit DIMM AXI port widths for compatibility with `otpu_hbm_ch`, `otpu_mig_pair` and `otpu_mig_hmux`; bit 33 is now explicitly unused and simulation-fatal if asserted on host or controller AW/AR. Updated the WG8 wrapper defaults/assertions, `targets/nangate45-wg8.toml`, architecture spec A1.12.11.16.47 and DDR4 integration spec A1.12.11.16.52.
- Replaced the old AW36 high-address regression with AW35/WA33/CAW25 regression `sim/asic/tb_asic_aw35.sv`, and updated `tests/test_native_dram.py`. It retains the 16-GiB address check, which is valid within the 32-GiB design. This regression has not yet been run to completion in CI.
- AW35 reduces one unused high address bit relative to the FPGA reference and should reduce address-path width slightly; it does not alter the selected memory capacity. WG8 wrapper lint, native adapter regression and synthesis/PPA must still be rerun on this AW35 candidate before accepting it.
- Shared host/accelerator arbitration remains integrated through four `otpu_mig_hmux` instances; host address translation, IOMMU, PCIe endpoint/DMA, DDR PHY/controller/ECC, formal/CDC/RDC, physical PPA and foundry signoff remain open. `main` unchanged; no paid resources used.


## 57. Address-width finding independently corrected (2026-11-24)

- Corrected the prior section 56 interpretation: `AW` is the address-interface width, while `DRAM_BYTES` independently limits the mapped capacity. The repository's BCU1525-WG8 uses AW=36 with DRAM_BYTES=32 GiB; the upper channel-address bit is simply unused for that configured map. AW=36 does **not** imply that 64 GiB of physical memory exists or is addressed.
- The ASIC candidate remains AW=35/WA=33/CAW=25 as an intentional minimum-width implementation for exactly 32 GiB. Its four DIMM AXI interfaces remain 34 bits wide for reuse of existing pair/mux RTL; the top bit is asserted zero. No claim of an original AW36 capacity defect is retained.
- Updated architecture specification A1.12.11.16.48 to distinguish the FPGA reference from the narrower ASIC implementation. The AW35 regression remains valid and is still awaiting CI.
- This correction is recorded to prevent an incorrect engineering conclusion from propagating. All new host arbitration and AW35 changes still require completed CI and PPA evidence.


## 58. Authoritative continuation baseline consolidated (2026-11-24)

- Added [SUNNYONE_AI-X_AUTHORITATIVE_CONTINUATION_BASELINE_A1.12.11.16.53.md](SUNNYONE_AI-X_AUTHORITATIVE_CONTINUATION_BASELINE_A1.12.11.16.53.md) as the single session-start hand-off for architecture, commercial objective, branch discipline, implemented RTL boundaries, evidence rules, historical verification caveats and prioritised remaining gates.
- The baseline links this tracker and the detailed WG8 architecture and DDR4 integration specifications. It preserves the AW36/32-GiB correction and explicitly separates FPGA/simulation evidence from ASIC physical validation.
- Baseline document creation commit: a244508fbf4d0a932e7c212341a7529774dd2bd5. Feature branch only; main was not targeted.
- This is documentation consolidation, not an RTL verification result. Latest host-arbitration/AW35/control CI must still be inspected by tested commit and completed job logs. No new test pass is claimed.
- Next execution priority: establish current CI status and reproducible AW35/WG8 baseline, then implement adversarial four-DIMM host/accelerator dual-master verification. Continue through PCIe/DMA/IOMMU, DDR controller/PHY/ECC, formal/CDC/RDC, exact WG8 PPA and physical/commercial qualification gates.


## 59. Continuation baseline verified; WG8 diagnostic corrected (2026-11-24)

- Verified the new authoritative continuation baseline is committed in GitHub. Added tracker section 58 and the consolidated baseline file; baseline creation commit a244508fbf4d0a932e7c212341a7529774dd2bd5, tracker update commit 42d9c18a292a3b4dc54af0ec5ce91ae69898676c.
- Re-read the live WG8 DDR4 wrapper and found a stale configuration-fatal diagnostic that still named AW36/CAW26 despite the actual accepted configuration being AW35/CAW25. Corrected the diagnostic text only; no datapath or behaviour changed. Commit bf71ecc1230b97e756ef06418cca54e446632a86.
- GitHub branch API confirmed active feature branch head before this edit was 42d9c18a292a3b4dc54af0ec5ce91ae69898676c and `main` remains d84db55712aba0d40811d7762cb052f05d55b7e5.
- Current Actions listing showed a large backlog of queued workflows; the newest listed jobs were still queued and tested older source commits (latest visible run head included a02473009179410f48c6a6528134857543a4447a). These are not completed results and do not validate the AW35/host-mux edits. After this commit, rerun/poll targeted wrapper lint, AW35 regression, config/control, full-chip lint, reset, subsystem and WG8 PPA workflows against the current branch head.
- Code review confirmed the wrapper uses four `otpu_mig_hmux` instances and 34-bit DIMM-local AXI interfaces; current wrapper guards bit 33. The existing `tb_bcuwg.sv` board bench documents that its host side is idle, so it does not validate simultaneous host-DMA and accelerator traffic. Four-DIMM dual-master adversarial verification remains the next substantive verification task.
- No CI pass is claimed from this inspection; no paid resources used; `main` untouched.


## 60. Corrected stale WG8 wrapper boundary comment (2026-11-24)

- Corrected the module header in `rtl/asic/otpu_asic_wg8_ddr4_top.sv`: it previously implied that host/accelerator arbitration was still to be performed by an external memory subsystem, contradicting the four integrated `otpu_mig_hmux` instances below. The header now accurately states that one mux per DIMM shares host DMA and accelerator traffic; PCIe endpoint/PHY, descriptor engine, global address translation/IOMMU and DDR controller/PHY/ECC remain external.
- Documentation-only RTL comment correction, commit b0caca731bf81506bae80c5c386de143aab774fd. No functional change and no test result claimed.
- Next substantive task remains a real two-master simulation of `otpu_mig_hmux` under concurrent host and accelerator transactions, including AW/W/B ordering, AR/R ID routing, backpressure, partial strobes, 4-KiB burst boundaries and reset. Then extend coverage to all four DIMMs through the WG8 wrapper.


## 61. Latest workflow batch and next verification gate (2026-11-24)

- After the AW35 diagnostic correction and wrapper boundary-comment correction, GitHub created a fresh seven-workflow batch against commit `b0caca731bf81506bae80c5c386de143aab774fd`: RTL subsystems/WG8 memory 45254175439; reset/power-up audit 45254175518; ASIC/target config 45254175452; WG8 research PPA 45254175482; RTL tail 45254175429; RTL/board regressions 45254175448; full-chip lint 45254175538.
- All seven were still `queued` at inspection. They provide no test, lint or PPA result. Earlier batch 45253612138, 45253612099, 45253612045, 45253612442, 45253611952, 45253612035 and 45253612066 also remained queued against the earlier commit `bf71ecc1230b97e756ef06418cca54e446632a86`.
- Confirmed current feature branch HEAD is `46f6109ff267a3e20c17d382910ee18a9c739e0e` after this tracker update; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. The latest seven-workflow batch tested the RTL source commit before this tracker-only commit; no RTL changed after that batch.
- Current testbench gap is confirmed in source: `sim/verilator/tb_bcuwg.sv` ties all `otpu_mig_hmux.h_*` inputs inactive, so `tests/test_bcuwg_board.py` cannot qualify host/accelerator concurrency. The next verification work must instantiate the actual mux with independent host and pair drivers and an AXI DIMM model, then integrate equivalent traffic into the four-DIMM wrapper bench.
- No functional test pass is claimed; no physical validation or tapeout readiness; no paid resources; `main` unchanged.


## 62. Dedicated host/pair DIMM mux simulation added; Actions backlog still queued (2026-11-24)

- Added `sim/verilator/tb_hmux.sv` and `.github/workflows/sunnyone-hmux-sim.yml` on the feature branch. The test instantiates the actual `otpu_mig_hmux`, `otpu_rs` and `otpu_sfifo` RTL and drives concurrent host and accelerator-pair single-beat writes and reads, DIMM-side backpressure, W ownership and B/R ID routing. The testbench was corrected to match the mux's actual single accelerator-pair port and host port.
- Added response counters/scoreboard checks for one B and one R response to each requester. The DIMM model uses a single outstanding B response slot and applies W backpressure while that slot is occupied. This is an initial focused regression, not the full adversarial qualification matrix: it does not yet cover multi-beat bursts, long sustained contention/fairness, partial-strobe memory effects, overlapping-address visibility, malformed IDs/negative tests, reset with outstanding traffic, or the four-DIMM wrapper.
- Relevant commits: initial bench 40dd3266f770694bfffc89c8b3510a80c1fb5b29; workflow e00340402d1d82063e9d98d40868117285e7b33c; single-pair interface correction 68380463f10204f7aaa4636fd35f5eab7b5f5d19; response-routing scoreboard refinement 1f52fdd3fd5f0aa3b0551fd1d8fd22f55803d079.
- Latest visible Actions batch on current feature branch head 1f52fdd3fd5f0aa3b0551fd1d8fd22f55803d079 includes mux simulation run 45256760107, RTL subsystems 45256760151, reset/related checks from earlier batches, RTL tail 45256760188, RTL/board 45256760143, software-core 45256760098 and isolated TMEM 45256760353. All observed jobs remain queued; no compile, simulation, lint or regression result is yet available. The previous mux workflow run 45256674845 is also queued.
- GitHub Actions backlog remains a platform scheduling blocker. Do not infer a pass from queued status or report the new bench as executed. Once a runner starts, inspect compile output and full logs; repair genuine failures on the feature branch, then expand to the four-DIMM wrapper and remaining adversarial cases.
- Feature branch only; `main` untouched. No paid resources used. No hardware, DDR electrical, PCIe, physical implementation, formal signoff or tapeout claim.


- Follow-up bench correction commit `306fcf584cf5352be76d7cac5f2c863f0743e9ba`: the DIMM model now withholds WREADY until its corresponding AW has been accepted (or is accepted in the same cycle), while preserving independent AW/W channel timing. This avoids assuming AW must always be accepted before W at the DIMM interface.
- The correction triggered current run `45256841999` (shared DIMM mux simulation) against `306fcf584cf5352be76d7cac5f2c863f0743e9ba`; it and the other workflows triggered by the commit were still queued at the latest poll. This is not an executed simulation result.


## 63. Host-mux testbench write-owner model hardened (2026-11-24)

- Static review found a scoreboard-model corner case: if a later AW handshakes on the same cycle as the final W beat of an older burst, the model selected the newly accepted AW ID instead of the oldest queued AW owner. Corrected the model to retire the oldest accepted AW first and use the same-cycle AW only when the queue was previously empty.
- Added a fatal check if the DIMM model accepts a WLAST without an accepted AW owner. This strengthens the testbench model; it is not evidence of an RTL defect or a passing simulation.
- Commit bfd8169668e1d9f54ae9d2d3533d9bc7fb72f685. A new targeted workflow run should be inspected against this commit. Previous six runs remain queued against 306fcf584cf5352be76d7cac5f2c863f0743e9ba; no CI result is claimed.
- Feature branch only; main unchanged; no paid resources used.


## 64. Mux testbench read-data width corrected; CI remains runner-blocked (2026-11-24)

- Static review found the DIMM read-data pattern used a 1,024-bit replication for a 512-bit AXI RDATA signal. Corrected it to eight 64-bit lanes and a width-matched 4-bit transaction variation. This is a testbench stimulus-width correction, not an RTL change or a simulation pass.
- Testbench correction commit: 891f656aee6651a06574f4a5c2546b5475338d2c.
- The latest mux workflow run against the preceding testbench commit is 45263309565 (SHA bfd8169668e1d9f54ae9d2d3533d9bc7fb72f685); it remains queued. The earlier mux run 45256841999 (SHA 306fcf584cf5352be76d7cac5f2c863f0743e9ba) and five other runs in that batch also remain queued. The six workflows triggered by bfd8169668e1d9f54ae9d2d3533d9bc7fb72f685, including mux run 45263309565, were all queued at the latest poll. No compiler, simulation, lint or regression logs are available; no pass is claimed.
- Current work is still a single-beat focused mux bench. Multi-beat traffic, fairness, byte-strobe memory effects, 4-KiB boundaries, ID-negative tests, reset under outstanding traffic, overlapping-address semantics and four-DIMM wrapper coverage remain open. CI execution is a prerequisite before extending or accepting this bench.
- Feature branch only; main unchanged; zero paid resources used.


## 65. Mux regression payload and response-ID checks strengthened (2026-11-24)

- Extended the dedicated single-beat host/pair mux bench with explicit DIMM-side AW/AR ID, address and length checks; W data/strobe/owner checks against the oldest accepted AW; and pair/host B/R response-ID checks. This validates the existing one-beat stimulus contract and catches requester cross-routing or payload corruption if the bench executes.
- Testbench commit: af37e33c8518090a34c2b68c8b61d523ea449e73. Static review only; Verilator compilation and simulation are still unverified because the GitHub Actions runner queue has not started the earlier mux jobs. Do not treat the added assertions as passed.
- Multi-beat bursts, sustained fairness, memory-side byte-effect modelling, 4-KiB boundary and malformed-transaction tests, reset with outstanding traffic, overlapping-address ordering and the four-DIMM wrapper remain unimplemented qualification work.
- Feature branch only; main unchanged; no paid resources used.


## 66. R-response checker corrected to respect buffered-channel timing (2026-11-24)

- Static review found the host R checker sampled the DIMM-side live RID at the later host response handshake. Because the mux includes an R register slice, the DIMM may already be presenting a subsequent response; live DIMM RID is not a valid proxy for the buffered host response. Replaced that check with the expected host RDATA check and added the expected pair RID/RDATA check at each requester-side handshake.
- Testbench commit: e53ad53287c56444e9f4306e78dfe83e110a0486. This fixes a testbench scoreboard assumption, not an RTL defect. No compile or simulation pass is claimed.
- GitHub Actions remains queued; the previous targeted mux run is 45265993286 against `af37e33c8518090a34c2b68c8b61d523ea449e73`. A new run for the latest bench revision must be inspected once scheduled. Multi-beat and full four-DIMM qualification remain open.
- Feature branch only; main unchanged; zero paid resources used.


## 67. Latest R-checker revision queued for focused simulation (2026-11-24)

- GitHub Actions created focused mux run [45266097205](https://github.com/shamiursunny/openTPU/actions/runs/45266097205) against testbench commit `e53ad53287c56444e9f4306e78dfe83e110a0486`. Job `hmux-sim` (138013284212) is still queued; no runner, compile output or simulation log exists. The broader workflows created on the same commit are also queued.
- Latest tracker/feature branch commit before this tracker note: `8ff684291c68b791114a0ef9dba0efb111087d48`. `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. No RTL functional change, no CI pass and no hardware qualification claim.
- Next gate: wait for run 45266097205 to execute; inspect Verilator compile warnings/errors and runtime assertions; only then extend to multi-beat/fairness and four-DIMM traffic. No paid resources used.


## 68. Host B-response checker corrected; Actions backlog still queued (2026-11-24)

- Static review found the host B-response checker sampled the live DIMM-side `m_bid` when the host's buffered response handshook. The mux host interface has no BID output; a later DIMM B transaction can change live `m_bid` before the earlier host response is consumed. Removed the invalid live-ID assertion and instead check the requester-side `h_bresp` plus the host B-response handshake/count. Pair-side BID remains checked at the pair interface.
- Testbench-only correction commit: `1ec347a8f093052582746d07df0269b8f03b6809`. This is not an RTL defect finding and is not a simulation result.
- Latest focused mux run `45266097205` targets earlier testbench SHA `e53ad53287c56444e9f4306e78dfe83e110a0486`; it remains queued with job `138013284212`, no runner and no logs. Earlier mux runs `45265993286`, `45264350657`, `45263309565` and `45256841999` are also queued. The four broad runs `45266097228`, `45266097338`, `45266097275` and the focused mux run have no conclusions; all were queued at inspection.
- The correction will trigger a new focused mux workflow on the updated testbench SHA. Inspect that run's exact SHA, compilation output and full simulation log before accepting the bench. No test pass is claimed.
- Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; zero paid resources used. Multi-beat, fairness, partial-strobe memory effects, boundary/negative tests, reset with outstanding traffic and four-DIMM wrapper qualification remain open.


## 69. Corrected host B checker has a dedicated queued Actions run (2026-11-24)

- The host B-response checker correction in testbench commit `1ec347a8f093052582746d07df0269b8f03b6809` triggered focused workflow run [45266612413](https://github.com/shamiursunny/openTPU/actions/runs/45266612413), job `hmux-sim` (`138015075353`). Exact tested SHA matches the corrected testbench commit. At inspection, run and job were still queued; no runner, logs, compilation or simulation result is available.
- Earlier focused run `45266097205` (SHA `e53ad53287c56444e9f4306e78dfe83e110a0486`) and prior runs remain queued. No pass is claimed. The tracker-only commit does not match the focused workflow's path filter and does not create another mux simulation run.
- Static review confirms the workflow compiles the required three RTL source files and the dedicated testbench, then executes `obj_dir/Vtb_hmux`; executable correctness remains unverified until the job runs.
- Feature branch only; main unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`; zero paid resources used.


## 70. Dedicated host/pair mux simulation passed (2026-11-24)

- Focused workflow run [45266612413](https://github.com/shamiursunny/openTPU/actions/runs/45266612413), job `hmux-sim` (`138015075353`), completed successfully against exact testbench SHA `1ec347a8f093052582746d07df0269b8f03b6809`. GitHub Actions checked out that exact SHA, installed Verilator 5.032, compiled the three required RTL files plus `sim/verilator/tb_hmux.sv`, and executed the generated simulation binary.
- Exact runtime PASS marker: `PASS: concurrent pair/host AW-W-B and AR-R routing; writes=2 reads=2 cycles=18`. Simulation finished at 190 ns. This verifies the current focused test's two concurrent single-beat write paths and two read paths, response routing, and modeled backpressure under the stated testbench scenario.
- Build completed successfully, but non-fatal warnings were emitted because the workflow uses `-Wno-fatal`: PINCONNECTEMPTY in `rtl/shell/otpu_mem_ch.sv`; DECLFILENAME and TIMESCALEMOD in reused RTL; UNUSEDSIGNAL for currently unused response/last signals in the testbench; BLKSEQ for the clock generator; and INITIALDLY for nonblocking assignments in initial-block stimulus (Verilator executes these as blocking assignments). These warnings remain visible and should be triaged; they were not suppressed or represented as warning-free.
- Earlier mux runs [45266097205](https://github.com/shamiursunny/openTPU/actions/runs/45266097205), [45265993286](https://github.com/shamiursunny/openTPU/actions/runs/45265993286), [45264350657](https://github.com/shamiursunny/openTPU/actions/runs/45264350657), [45263309565](https://github.com/shamiursunny/openTPU/actions/runs/45263309565) and [45256841999](https://github.com/shamiursunny/openTPU/actions/runs/45256841999) also completed successfully on their respective earlier testbench SHAs. The corrected latest SHA is validated by run 45266612413.
- The broader runs [45266097228](https://github.com/shamiursunny/openTPU/actions/runs/45266097228), [45266097338](https://github.com/shamiursunny/openTPU/actions/runs/45266097338) and [45266097275](https://github.com/shamiursunny/openTPU/actions/runs/45266097275) ended `cancelled`; they provide no subsystem, uncovered RTL/board or software regression result. Do not treat them as passes.
- This is a focused single-beat mux simulation only. Multi-beat burst sequencing, sustained contention/fairness, byte-strobe memory effects, 4-KiB boundary and malformed-transaction tests, reset with outstanding traffic, overlapping-address visibility/order, and all-four-DIMM wrapper concurrency remain open. It is not formal proof, full-chip qualification, DDR/PCIe electrical validation, physical PPA, or silicon evidence.
- Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; zero paid resources used.


## 71. Mux response-field assertions and testbench driver scheduling improved (2026-11-24)

- Follow-up review of the first successful focused run found response outputs not yet asserted: pair BRESP, pair RRESP/RLAST and host RRESP/RLAST were connected but unused. Added requester-side checks for these response fields. Host BRESP was already checked; pair BID and both requester R-data checks remain.
- Changed task-driven stimulus assignments from nonblocking to blocking assignments at falling edges, avoiding Verilator's INITIALDLY warnings and making the testbench's drive/sample phase separation explicit. Reset deassertion now occurs on a falling edge after the initial reset cycles to avoid a same-edge race.
- Testbench commit: `38b98903d16c36980fd0270273d7de14082e753d`. No RTL datapath changed. Focused mux run [45324154486](https://github.com/shamiursunny/openTPU/actions/runs/45324154486), job `hmux-sim` (`138209570057`), completed successfully on the exact SHA. Verilator 5.032 compiled and ran the test; runtime marker: `PASS: concurrent pair/host AW-W-B and AR-R routing; writes=2 reads=2 cycles=18`. The new pair BRESP and both RRESP/RLAST assertions passed.
- Warning review of the second run: all INITIALDLY warnings and unused response/last-signal warnings from the previous run disappeared. Remaining warnings are PINCONNECTEMPTY in `otpu_mem_ch.sv`, DECLFILENAME in reused RTL, TIMESCALEMOD in reused RTL, and one BLKSEQ for the testbench clock generator. The workflow uses `-Wno-fatal`; warnings remain visible and are not claimed as resolved.
- The same push triggered broader subsystem [45324154569](https://github.com/shamiursunny/openTPU/actions/runs/45324154569), remaining RTL tail [45324154545](https://github.com/shamiursunny/openTPU/actions/runs/45324154545), one-copy TMEM [45324154498](https://github.com/shamiursunny/openTPU/actions/runs/45324154498), remaining RTL/board [45324154651](https://github.com/shamiursunny/openTPU/actions/runs/45324154651), and core software/ISA [45324154732](https://github.com/shamiursunny/openTPU/actions/runs/45324154732). These broader runs were still in progress at the latest poll; no result is assumed.
- The broader workflows were triggered by the repository's existing path filters for this testbench change. Avoid further commits until these jobs complete to prevent unnecessary workflow duplication.
- Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; zero paid resources used.


## 72. Additional RTL-tail and isolated TMEM regressions completed (2026-11-24)

- On tested source SHA `38b98903d16c36980fd0270273d7de14082e753d`, remaining RTL-tail workflow [45324154545](https://github.com/shamiursunny/openTPU/actions/runs/45324154545) completed successfully. Its pytest selection reported `33 passed, 1 skipped, 183 deselected` in 984.82 seconds. This is the workflow's selected RTL-tail regression subset, not the entire test suite.
- Isolated 128K one-copy TMEM workflow [45324154498](https://github.com/shamiursunny/openTPU/actions/runs/45324154498) completed successfully. Its pytest selection reported `2 passed, 215 deselected` in 122.69 seconds. This is isolated simulation evidence only, not SRAM macro, physical, timing, power or silicon qualification.
- The broader RTL subsystems/WG8 memory workflow [45324154569](https://github.com/shamiursunny/openTPU/actions/runs/45324154569) remained in progress at the latest poll; its DMA/stream/quantisation/memory/subsystem regression step had not completed. No result is claimed for this suite.
- Workflows [45324154651](https://github.com/shamiursunny/openTPU/actions/runs/45324154651) (remaining RTL/board, two jobs) and [45324154732](https://github.com/shamiursunny/openTPU/actions/runs/45324154732) (core software/ISA) were cancelled while their main test steps were running. They provide no pass/fail evidence for those selections; cancellation is not a pass.
- Focused mux simulation remains successful in [45324154486](https://github.com/shamiursunny/openTPU/actions/runs/45324154486), exact tested SHA `38b98903d16c36980fd0270273d7de14082e753d`; see section 71 for runtime PASS marker and warning inventory.
- No RTL or software changes were made for this tracker update. Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; zero paid resources used.


## 73. Subsystem regression cancelled; no result claimed (2026-11-24)

- Subsystem/WG8 memory workflow [45324154569](https://github.com/shamiursunny/openTPU/actions/runs/45324154569), tested source SHA `38b98903d16c36980fd0270273d7de14082e753d`, has now completed with conclusion `cancelled`. Job `138209569738` completed its setup, checkout, Python, Verilator and dependency-install steps successfully; its main pytest step for `tests/test_stream_rtl.py`, `test_quant_rtl.py`, `test_fp_rtl.py`, `test_icache_rtl.py`, `test_waitw_rtl.py`, `test_aw_rtl.py`, `test_coll_hub.py`, `test_dma_lda.py`, `test_dma_ldq.py`, `test_native_dram.py`, `test_reset_audit.py`, `test_tech_ram.py` and `test_scoreboard.py` was cancelled.
- The retained job log confirms the exact pytest command began and then reports `The operation was canceled`; runner cleanup terminated pytest, Verilator and compiler processes. No pytest summary is present. Therefore this selection has **no pass/fail test result** and must not be counted as passed or failed.
- This cancellation joins the already-recorded cancelled remaining RTL/board run [45324154651](https://github.com/shamiursunny/openTPU/actions/runs/45324154651) and core software/ISA run [45324154732](https://github.com/shamiursunny/openTPU/actions/runs/45324154732). The confirmed successes remain the focused mux run [45324154486](https://github.com/shamiursunny/openTPU/actions/runs/45324154486), RTL-tail run [45324154545](https://github.com/shamiursunny/openTPU/actions/runs/45324154545), and isolated 128K TMEM run [45324154498](https://github.com/shamiursunny/openTPU/actions/runs/45324154498), as detailed in sections 71–72.
- No RTL or software source changes are made by this entry. Next step is to split the cancelled suite into bounded, independently observable test groups and run them sequentially or with controlled concurrency; inspect workflow timeouts and test durations before rerunning. Do not simply repeat the full long-running batch or weaken/remove tests.
- Feature branch only. `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Zero paid resources used. No hardware, physical PPA, formal-proof or silicon qualification claim.


## 74. Long subsystem CI split into bounded regression groups (2026-11-24)

- Following the 60-minute cancellation of subsystem run [45324154569](https://github.com/shamiursunny/openTPU/actions/runs/45324154569), updated `.github/workflows/sunnyone-rtl-subsystems.yml` in commit `adbc02d3ecff8b3e7e14aba677e5dd233df690c4`.
- The former single 13-file pytest command is now a four-entry matrix: (1) stream/quantisation/FP/instruction-cache/wait/address-window; (2) collective hub/DMA/scoreboard; (3) native DRAM/technology RAM; (4) reset audit. Each job has a 45-minute timeout; at most two matrix jobs run concurrently. `fail-fast: false` ensures other groups can complete and expose their own results if one group fails.
- Each group writes its pytest output through `tee` with `pipefail` enabled and uploads a separate log artifact even when the test step fails. No tests were removed, deselected or weakened by this workflow change; the same 13 test files remain represented.
- This is a CI orchestration change only; no RTL, software or test source was changed. The new workflow configuration was fetched back from GitHub and matches the intended four-group definition. At this checkpoint, no execution result for the new matrix has yet been inspected; no pass is claimed.
- Current active branch head after the workflow change: `adbc02d3ecff8b3e7e14aba677e5dd233df690c4`. `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Zero paid resources used.
- Next gate: inspect the newly triggered workflow run and each matrix job's exact tested SHA, conclusion, pytest summary, warnings and uploaded logs. If any group hits its 45-minute timeout, split that group further based on observed test durations; do not skip or suppress tests.


## 75. First four-group matrix: two substantive groups pass; one times out (2026-11-24)

- Workflow run [45332150862](https://github.com/shamiursunny/openTPU/actions/runs/45332150862), run number 66, tested exact source SHA `adbc02d3ecff8b3e7e14aba677e5dd233df690c4`. Overall run conclusion is `cancelled` because one matrix job was cancelled at its 45-minute job timeout.
- Collective hub/DMA/scoreboard job `138235602166`: pytest summary `128 passed in 365.62s`; job conclusion success.
- Native DRAM/technology RAM job `138235601994`: pytest summary `104 passed in 1909.09s` (31m 49s); job conclusion success.
- Reset audit job `138235602289`: pytest summary `4 skipped in 0.06s`; job conclusion success, but no reset test passed in this selection. Preserve the skips; determine their skip reasons before treating this area as covered.
- Stream/quantisation/FP/instruction-cache/wait/address-window job `138235602465`: its pytest command began, but GitHub cancelled the step at approximately 45 minutes. The log reports `The operation was canceled` and runner cleanup terminated pytest, Verilator and compiler processes. No pytest summary or test count is present. This is incomplete evidence, not a pass or a test failure.
- Thus the completed successful groups report 232 passing tests across their two selections; the reset selection reports four skips; the six-file stream/quantisation/FP/instruction-cache/wait/address-window selection remains unquantified. Do not present 232 as the full suite total or imply all 13 files passed.
- Setup and dependency installation completed in all inspected jobs. Logs show GitHub Actions Node.js 20 deprecation notices (actions forced to Node.js 24), Node `punycode`/`url.parse()` deprecations and a Python editable-install BuildBackendWarning. These are environment/tooling notices; no pytest failure is inferred from them. Warnings remain visible.
- Workflow configuration confirms all 13 original test files remain represented, with no test removal, skip-marker changes, deselection or weakened assertions in this orchestration change. The timeout demonstrates the first group is still too large for the 45-minute bound; split its six files into separately observable jobs, retaining the same timeout and test commands. Inspect the four reset-test skip reasons as a separate coverage follow-up.
- This run is regression evidence only for the two completed passing selections. It is not full-suite verification, formal proof, four-DIMM/complete AXI qualification, full-chip validation, PCIe/DDR electrical validation, physical PPA, thermal/package signoff or silicon evidence.
- Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 76. Reset-audit skip cause identified; per-file matrix rerun queued (2026-11-24)

- Follow-up inspection of `tests/test_reset_audit.py` at workflow revision `19b2bb6efa3561571cf56a2ce6f14105ddf4e3b0` identifies the exact skip gate: module-level `pytest.mark.skipif(not _slang(), reason="no yosys with slang (YOSYS)")`. The helper requires a Yosys executable with the Slang front end; the four collected cases (two direct tests plus two parametrized FPGA-init cases) were all skipped because that toolchain was unavailable in the runner environment.
- Therefore the reset-audit job's success conclusion means pytest completed with four skips, not that reset-state audit assertions executed. Coverage remains unverified. Next step is to establish a reproducible zero-cost way to install/use Yosys+Slang in CI, or clearly keep this test environment-blocked; do not remove the skip or represent it as a pass.
- After run [45332150862](https://github.com/shamiursunny/openTPU/actions/runs/45332150862) timed out its six-file group at 45 minutes, workflow file `.github/workflows/sunnyone-rtl-subsystems.yml` was changed in commit `19b2bb6efa3561571cf56a2ce6f14105ddf4e3b0` to give each of the six original files its own matrix job. All six files, the other three original groups, the 45-minute per-job timeout, `max-parallel: 2`, `fail-fast: false`, `pipefail`, and per-job log artifacts are retained. No test selection was removed or weakened.
- The change triggered workflow run [45340740422](https://github.com/shamiursunny/openTPU/actions/runs/45340740422), run number 67, on exact SHA `19b2bb6efa3561571cf56a2ce6f14105ddf4e3b0`. At latest inspection, Stream RTL and Quantisation RTL jobs were in progress; the other seven jobs were queued. No results are yet claimed for this run.
- Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Zero paid resources used.



## 77. Per-file subsystem matrix completed with 308 passes; quantisation job timed out (2026-11-24)

- Workflow run [45340740422](https://github.com/shamiursunny/openTPU/actions/runs/45340740422), run number 67, completed with overall conclusion `cancelled` on exact tested source SHA `19b2bb6efa3561571cf56a2ce6f14105ddf4e3b0`. All nine matrix jobs reached a terminal state. The overall run is not green because the Quantisation RTL job was cancelled at the 45-minute job timeout; do not report this as a successful full matrix.
- Actual pytest summaries retrieved from completed job logs:
  - Floating-point RTL: **8 passed** in 169.38s.
  - Instruction-cache RTL: **23 passed** in 964.65s.
  - Wait-state RTL: **11 passed** in 288.26s.
  - Stream RTL: **14 passed** in 616.67s.
  - Address-window RTL: **20 passed, 1 skipped** in 961.44s. The skipped case is labelled `64 GiB: every address is DRAM`; this is not a 64 GiB validation result.
  - Collective hub, DMA and scoreboard: **128 passed** in 303.51s.
  - Native DRAM and technology RAM: **104 passed** in 2098.81s (34m 58s); job conclusion success.
  - Reset audit: **4 skipped** in 0.04s. All four remain environment-blocked by the existing Yosys+Slang skip gate described in section 76; no reset-audit assertions ran.
- Verified aggregate from the seven groups with pytest summaries: **308 passed, 5 skipped**. Quantisation RTL has no final pytest summary: its command began at 06:29:09Z and GitHub cancelled it at 07:14:00Z, terminating pytest, Verilator and compiler processes. This is incomplete evidence, not a pass and not a pytest-reported failure. The workflow's other eight jobs completed with job conclusion success, but the four reset skips and one address-window skip remain skips.
- The per-file matrix achieved independent visibility and avoided the former combined six-file job obscuring all results. However, Quantisation RTL alone exceeded the 45-minute bound. Next step: inspect the quantisation test selection and its slowest cases, then split it into smaller evidence-preserving jobs or otherwise reduce only avoidable setup/compilation overhead. Do not deselect, skip, weaken or suppress tests. Preserve the 45-minute limit unless evidence justifies a different bounded design.
- Run logs also retain GitHub Actions Node.js 20 deprecation notices (actions forced onto Node.js 24), Node `punycode`/`url.parse()` deprecation notices, and Python editable-install BuildBackendWarning notices. These are tooling/environment warnings, not pytest failures. No warning-free claim is made.
- No RTL or test source change was made by this tracker entry. Feature branch head before this tracker-only update: `f165ed4514d29a466c1998612e6f10e41efa3115`; `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`. Zero paid resources used.
- This is bounded RTL regression evidence only. It does not establish complete-suite success, formal proof, full AXI/multi-beat mux qualification, full-chip validation, PCIe/DDR electrical validation, physical PPA, thermal/package signoff, or silicon readiness.



## 78. Quantisation regression split into six complete test-family jobs (2026-11-24)

- Following Run 67's Quantisation RTL job exceeding the 45-minute timeout without a final pytest summary (section 77), inspected `tests/test_quant_rtl.py` at feature branch head. The file contains 15 test functions and 65 parameterized/direct test instances. The original single-file invocation did not finish within the configured bound.
- Updated only `.github/workflows/sunnyone-rtl-subsystems.yml` in commit `6d0462a9b7b4e69a5b3f97e4a807a8d1f2d10331`. The former one-file quantisation matrix entry is replaced by six independent pytest-node selections:
  1. MX multiply and replay RTL: `test_mm_mx_rtl` and `test_mm_mx_replay_rtl` (17 instances).
  2. Quantizer modes RTL: `test_quantizer_modes_rtl` (15).
  3. Quantizer corners and tie rounding RTL: `test_rscale_once_a_row_rtl`, `test_wide_pass1_rtl`, `test_quantizer_ties_qst_rtl`, and `test_quantizer_ties_qact_rtl` (8).
  4. SPLITQ RTL: `test_splitq_rtl` (5).
  5. QHL RTL: `test_qhl_rtl`, `test_qhl_power_up_rtl`, and `test_qhl_cycles_rtl` (7).
  6. QST and QSTB RTL: `test_qst_sww_rtl`, `test_qstb_rtl`, `test_qstb_power_up_rtl`, and `test_qstb_cycles_rtl` (13).
- The six selections sum to all 65 parameterized/direct instances across all 15 test functions. They use explicit pytest node IDs, not `-k`, so each job collects only its assigned tests; no test functions or parameter cases were removed, skipped, weakened or deselected from the combined regression coverage. Existing non-quantisation groups are retained unchanged. The workflow continues to use a 45-minute per-job timeout, `max-parallel: 2`, `fail-fast: false`, `pipefail` and per-job log artifacts. Added `--durations=20` to expose slowest cases in each completed job's log.
- The updated workflow was fetched back and verified. It triggered run [45357051033](https://github.com/shamiursunny/openTPU/actions/runs/45357051033), run number 68, on exact SHA `6d0462a9b7b4e69a5b3f97e4a807a8d1f2d10331`. At first inspection, Stream RTL and MX multiply/replay RTL were in progress; the other 12 matrix jobs were queued. No Run 68 test outcome is yet claimed.
- This is CI orchestration only; no RTL, Python implementation, test function or test parameter source was changed. Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Zero paid resources used.



## 79. Run 68 full matrix success; all 65 quantisation cases executed (2026-11-24)

- Workflow run [45357051033](https://github.com/shamiursunny/openTPU/actions/runs/45357051033), run number 68, completed with overall conclusion `success` on exact tested SHA `6d0462a9b7b4e69a5b3f97e4a807a8d1f2d10331`. All 14 matrix jobs completed with job conclusion success. Every job log was retrieved and its pytest summary inspected.
- Actual pytest summaries:
  - Floating-point RTL: **8 passed** in 150.45s.
  - Collective hub, DMA and scoreboard: **128 passed** in 310.72s.
  - Address-window RTL: **20 passed, 1 skipped** in 1398.97s. The skipped case is `64 GiB: every address is DRAM`; no 64 GiB validation is claimed.
  - Stream RTL: **14 passed** in 945.01s.
  - MX multiply and replay RTL: **17 passed** in 580.50s.
  - QHL RTL: **7 passed** in 746.80s.
  - Instruction-cache RTL: **23 passed** in 879.22s.
  - Quantizer modes RTL: **15 passed** in 686.68s.
  - Quantizer corners and tie rounding RTL: **8 passed** in 643.70s.
  - SPLITQ RTL: **5 passed** in 382.26s.
  - QST and QSTB RTL: **13 passed** in 981.92s.
  - Wait-state RTL: **11 passed** in 225.07s.
  - Native DRAM and technology RAM: **104 passed** in 1696.65s.
  - Reset audit: **4 skipped** in 0.05s because Yosys+Slang is unavailable, as described in section 76; no reset-audit assertions ran.
- Quantisation coverage: the six explicit pytest-node selections produced **65 passed** across all 15 test functions and all parameter instances in `tests/test_quant_rtl.py`: MX multiply/replay 17; quantizer modes 15; quantizer corners/ties 8; SPLITQ 5; QHL 7; QST/QSTB 13. This resolves the previous Run 67 quantisation timeout without deselecting, skipping or weakening tests.
- Aggregate actual pytest summaries: **373 passed, 5 skipped**, zero reported failures. The workflow itself concluded success. Distinguish this from the five skips: one Address-window 64-GiB-labelled case and four environment-gated reset-audit cases. No reset audit pass is claimed.
- `--durations=20` was enabled for each group; slowest cases are recorded in the archived per-job logs. Longest completed group was Address-window at 1398.97s (23m 18s); Native DRAM/technology RAM completed in 1696.65s (28m 16s), both within the 45-minute job timeout. Six quantisation groups completed between 382.26s and 981.92s. Workflow retains `max-parallel: 2`, `fail-fast: false`, `pipefail` and per-job log artifacts.
- This is successful bounded RTL regression evidence for the listed tests at the exact SHA above. It is not complete formal verification, exhaustive AXI protocol proof, full-chip validation, PCIe/DDR electrical validation, physical PPA, thermal/package signoff or silicon readiness.
- No RTL or test source was modified for this run; the preceding change was CI matrix orchestration only. Tracker entry appended separately. Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Zero paid resources used.



## 80. Pinned free Yosys+Slang CI toolchain for reset audit (2026-11-24)

- Section 76 identified the reset-audit skip gate: `tests/test_reset_audit.py` requires Yosys with `read_slang`; the prior runner installed Verilator only, so all four reset-audit cases were skipped.
- Verified the official YosysHQ OSS CAD Suite documentation: the free suite includes Yosys and the Slang plugin; Linux x64 is a supported target. The official latest release at implementation time is pinned to release tag `2026-11-23`, archive `oss-cad-suite-linux-x64-20261123.tgz`, size 754,443,916 bytes, official release asset digest `sha256:c01d93f2f9091ba7eeb18540334fa0aaefa843b343cbdd627fd7669391de47ba`. The archive is downloaded only in the Reset audit matrix job, not all 14 jobs.
- Updated `.github/workflows/sunnyone-rtl-subsystems.yml` in commit `4a6d240314e569c4fdc4d4d2334b4e51dae7e238`: conditional download, SHA-256 verification before extraction, executable check, explicit probe for `read_slang` both as a loadable plugin (`-m slang`) and built-in frontend, and export of the selected binary via `YOSYS` for the existing test's `ra.yosys()` resolver. If checksum, extraction, binary or frontend checks fail, the job fails visibly; no skip suppression or test weakening was introduced.
- This is a pinned third-party toolchain dependency, not yet validated by this repository's CI until the Reset audit job reaches and completes the install step. Archive size is substantial (~754 MB), so download time and runner capacity are practical risks to monitor. The release is dated 2026-11-23; future upgrades require a new verified release digest and evidence.
- Triggered workflow run [45373649765](https://github.com/shamiursunny/openTPU/actions/runs/45373649765), run number 69, exact tested SHA `4a6d240314e569c4fdc4d4d2334b4e51dae7e238`. At tracker update time the run was active; the Reset audit job was still queued. No reset-audit pass or tool-install success is claimed yet.
- No RTL, Python audit, or test source was changed. Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Zero paid resources used.



## 81. Activate official OSS CAD Suite environment in reset-audit CI (2026-11-24)

- Follow-up review of YosysHQ's official installation instructions found that Linux users should source the extracted suite's `environment` script, not only prepend its `bin` directory. Updated the Reset audit conditional install step accordingly in workflow commit `cf4155ec1d27c48e50f69cf6314274857a28ba0f`.
- The step now sources `${RUNNER_TEMP}/oss-cad-suite/environment`, resolves Yosys from the activated PATH, checks the Slang frontend, and persists `YOSYS`, `LD_LIBRARY_PATH` and each PATH entry for the subsequent pytest step. The pinned archive digest check remains before extraction. This aligns CI setup with the suite maintainer's documented Linux installation procedure.
- Run 69 remains active on the previous workflow revision SHA `4a6d240314e569c4fdc4d4d2334b4e51dae7e238`; its Reset audit job is still queued and has not yet exercised the first installer revision.
- The environment-activation revision triggered Run 70, [45373821692](https://github.com/shamiursunny/openTPU/actions/runs/45373821692), on exact SHA `cf4155ec1d27c48e50f69cf6314274857a28ba0f`. At inspection, all 14 jobs were queued. No result is claimed for Run 70.
- The two runs temporarily duplicate the matrix while GitHub Actions processes the queue. No RTL or test source changed. Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Zero paid resources used.



## 82. Resolve the 64-GiB Address-window skip: intentional boundary case (2026-11-24)

- Inspected the full `tests/test_aw_rtl.py` source at the current feature branch. The five address-window parameter instances include one deliberate skip in `test_beyond_the_dram_stops_the_board_model`: the fixture parameter `caw=26` is the 64-GiB board model; the test explicitly skips it with reason `64 GiB: every address is DRAM`.
- This is correct for the current model parameters: the board has eight channels and each channel is `1 << (caw + 7)` bytes; at CAW 26 this is 8 GiB/channel × 8 = 64 GiB = (2^{36}) bytes. The modeled core address width is AW=36, so every representable 36-bit byte address lies within the 64-GiB DRAM range. There is no out-of-range address at bit 35 to test on that configuration.
- At CAW 25, the model is 32 GiB = (2^{35}) bytes while AW remains 36; the corresponding test injects a store at (2^{35}) and expects the board model to stop with `beyond its 2^32 bytes` (the model's diagnostic wording). That is the meaningful boundary-guard instance and remains executed.
- Therefore, do not force this 64-GiB case to run, relabel it as a pass, or treat it as evidence of 64-GiB physical hardware support. Its skip is a valid not-applicable parameter instance; the remaining four reset-audit skips are a separate toolchain issue being addressed in Sections 80–81.
- Current feature branch contains this analysis. No test or RTL changed. Runs 69 and 70 remain in progress/queued at inspection; Reset audit has not yet started, so no new reset-audit execution result is claimed.


## 83. Harden OSS CAD PATH persistence and queue a corrected CI attempt (2026-11-24)

- Review of the first two installer revisions found a shell-path persistence concern in the GITHUB_PATH loop: the tr escape was unnecessarily fragile. Replaced it in workflow commit `40b9b8efa655f203ff1ef8f1e5ce310d623bb312` with Bash's colon-delimited array split and one `printf '%s\\n'` per path entry. The suite environment is still sourced, `YOSYS` and `LD_LIBRARY_PATH` are still persisted, and the checksum/frontend gates are unchanged.
- This is a CI environment-hardening change only; no RTL or audit tests changed.
- The corrected workflow triggered Run 71, [45382421749](https://github.com/shamiursunny/openTPU/actions/runs/45382421749), exact SHA `40b9b8efa655f203ff1ef8f1e5ce310d623bb312`. At inspection the run was queued. Runs 69 and 70 also remained queued in the Actions API despite some job summaries previously showing in-progress states; no installer or reset-audit completion is evidenced by those stale/inconsistent summaries.
- Await the latest run's actual job steps and logs before treating the toolchain install or audit as verified. The pinned OSS CAD archive remains a ~754 MB download and could cause a runner queue/time cost. No claim of four reset-audit passes is made.
- Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Zero paid resources used.


## 84. Correct PATH-entry newline escaping in OSS CAD CI installer (2026-11-24)

- A second-line inspection of the committed workflow source at Run 71's SHA found that Section 83's description overstated the PATH persistence correction. The actual shell source contained two backslashes in the single-quoted printf format (printf '%s\\\\n'), which makes Bash printf emit a literal backslash-n rather than a newline. That would place multiple PATH entries into one malformed GITHUB_PATH line. The earlier statement that this was safely persisted was therefore not yet justified.
- Corrected the format string to a single backslash (printf '%s\\n') in workflow commit d281621836d86e608ad34c4fd44d6edf339e98fe. The intended result is one actual newline-terminated path entry per GITHUB_PATH line. No RTL or test source changed.
- Run 71, https://github.com/shamiursunny/openTPU/actions/runs/45382421749, was still reported queued at inspection, although two matrix jobs appeared in progress in its job listing. The Reset audit job remained queued. The corrected source commit will trigger a new workflow attempt; neither PATH persistence nor Yosys/Slang execution is yet validated by runner logs.
- This entry explicitly supersedes the inaccurate PATH-persistence claim in Section 83. Continue to inspect the exact workflow job logs, not just job-list summaries, before claiming installer success. The archive checksum, suite activation, frontend probe, environment propagation, and all four reset-audit cases remain unverified.
- Feature branch only; main remains d84db55712aba0d40811d7762cb052f05d55b7e5. Zero paid resources used.


## 85. Queue corrected PATH-persistence workflow revision (2026-11-24)

- The corrected one-backslash printf format is present in the feature-branch workflow blob `86c78cf3cd6fd81c4b32c2ce877038262b7ee8f1`. The exact commit diff for `d281621836d86e608ad34c4fd44d6edf339e98fe` confirms the previous two-backslash format was replaced with a single backslash, so Bash printf writes an actual newline after each PATH entry.
- This change triggered Run 72, [45382805606](https://github.com/shamiursunny/openTPU/actions/runs/45382805606), run number 72, on exact tested SHA `d281621836d86e608ad34c4fd44d6edf339e98fe`. At inspection, the run remained queued overall; two ordinary regression jobs showed in progress, while the Reset audit job `138405904782` remained queued. No installer step, checksum, Yosys/Slang frontend probe, or reset-audit test result is yet evidenced.
- Runs 69–72 are overlapping attempts on successive workflow revisions. GitHub's API reports queued overall states with some individual jobs completed/in progress; this is not evidence of overall run completion. Avoid interpreting queued jobs or partial matrix success as a complete regression. Prioritise the latest corrected Run 72 and inspect its Reset audit job log when it starts.
- The exact workflow source is now corrected and diff-verified, but toolchain installation and all four reset-audit assertions remain unverified. No RTL or test source changed in this correction. Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Zero paid resources used.


## 86. Run 72 completes full RTL matrix and executes reset audit (2026-11-24)

- Run 72, [45382805606](https://github.com/shamiursunny/openTPU/actions/runs/45382805606), completed with overall conclusion `success` on exact tested SHA `d281621836d86e608ad34c4fd44d6edf339e98fe`. All 14 matrix jobs have job conclusion `success`; all 14 job logs were retrieved and their pytest summaries inspected.
- Aggregate actual pytest summaries: **377 passed, 1 skipped, zero reported failures**. This supersedes Run 68's earlier 373 passed / 5 skipped summary for the new exact SHA. The sole remaining skip is the intentional 64-GiB Address-window boundary case documented in Section 82 (`64 GiB: every address is DRAM`); it is not a 64-GiB hardware qualification result.
- The four reset-audit cases, previously skipped because Yosys+Slang were unavailable, now all ran and passed: **4 passed in 360.27s (6:00)**. The Reset audit job log confirms the official pinned OSS CAD Suite archive downloaded (719.4 MB), SHA-256 verification passed for digest `c01d93f2f9091ba7eeb18540334fa0aaefa843b343cbdd627fd7669391de47ba`, the suite environment was sourced, and Yosys was found at `/home/runner/work/_temp/oss-cad-suite/bin/yosys`. Yosys version reported: `0.71+77 (git sha1 11d972c20)`. The `yosys -m slang -Q -p 'help read_slang'` frontend probe succeeded (installer step completed successfully); the persisted YOSYS path was visible in the subsequent pytest environment. No reset-audit skips remain.
- Per-job pytest summaries and runtimes:
  - QHL RTL: 7 passed, 653.44s.
  - Wait-state RTL: 11 passed, 206.70s.
  - SPLITQ RTL: 5 passed, 316.54s.
  - Floating-point RTL: 8 passed, 180.26s.
  - Quantizer modes RTL: 15 passed, 965.97s.
  - Stream RTL: 14 passed, 1089.73s.
  - MX multiply and replay RTL: 17 passed, 566.48s.
  - Address-window RTL: 20 passed, 1 skipped, 1369.48s.
  - QST and QSTB RTL: 13 passed, 1428.06s.
  - Quantizer corners and tie rounding RTL: 8 passed, 652.48s.
  - Instruction-cache RTL: 23 passed, 936.68s.
  - Collective hub, DMA and scoreboard: 128 passed, 366.54s.
  - Native DRAM and technology RAM: 104 passed, 2471.95s (41m11s; completed successfully within the 45-minute per-job timeout).
  - Reset audit: 4 passed, 360.27s.
- Quantisation selections collectively remain 65 passing tests across all 15 test functions and parameter instances. No test was removed, weakened, or skipped to obtain success.
- The reset-audit job's log also shows the actual checksum check returning `OK`, Yosys version output, successful frontend probe (the probe's stdout/stderr is intentionally redirected), and the four-test pytest summary. This validates the pinned installer and environment propagation for this runner/revision; it does not establish long-term availability of the external release asset.
- Workflow and pytest logs contain a GitHub Actions Node.js 20 deprecation warning for actions/checkout@v4, setup-python@v5 and upload-artifact@v4 (forced to Node.js 24 by the runner). Treat as CI maintenance warning, not an RTL/test failure. No warning-free claim is made.
- Run 72 is successful bounded RTL regression and reset-audit evidence only. It is not exhaustive AXI protocol proof, complete formal verification, full-chip integration, PCIe/DDR electrical validation, physical PPA, thermal/package signoff, or silicon/tapeout readiness.
- No RTL, audit-test source or regression-test source changed in this run; the tested change was the corrected workflow PATH persistence/install setup. Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Zero paid resources used.


## 87. Extend shared DIMM mux simulation to three-beat bursts and response backpressure (2026-11-24)

- Expanded `sim/verilator/tb_hmux.sv` from single-beat transactions to concurrent host/pair three-beat write and read bursts. The scoreboard checks DIMM-side AW/AR address, ID and AWLEN/ARLEN; each W beat's requester ownership, data and byte strobes; WLAST exactly on beat AWLEN; B response ID/RESP routing; and each R beat's ID, data, RESP and RLAST.
- Added intermittent independent BREADY and RREADY stalls for host and pair. The testbench models accepted AW order and retains the expected W owner through the DIMM-side WLAST handshake. The directed run covers two three-beat write bursts and two three-beat read bursts.
- Initial implementation commit `8f4d375107efaec917a22c1fee3b8e681c0aa013`, Run [45400949312](https://github.com/shamiursunny/openTPU/actions/runs/45400949312), completed successfully on that exact SHA. Actual log marker: `PASS: concurrent pair/host 3-beat AW-W-B and AR-R bursts with response backpressure; write_bursts=2 read_beats=6 cycles=25`. Verilator reported new width-expansion and MULTIDRIVEN warnings in the testbench; these were treated as testbench issues and corrected rather than accepted.
- Warning-correction commit `2dea0dff5e06548b6335b19b133d852c53604e53` removes initial declaration assignments from ready signals also driven by `always_comb`, and makes beat counters 8-bit to align comparisons with AXI LEN fields; the pattern functions now explicitly zero-extend the beat value. This is a testbench-only correction; no RTL changed.
- The exact-SHA rerun is Run [45401097587](https://github.com/shamiursunny/openTPU/actions/runs/45401097587), on `2dea0dff5e06548b6335b19b133d852c53604e53`. At this tracker update, the hmux-sim job `138469591440` is still reported in progress at the build/run step; its final log and warning list are not yet available. Do not treat the first run's pass as validation of the warning-corrected revision.
- Scope limitation: this remains a directed three-beat test with one transaction per requester in this scenario. It does not yet qualify long bursts, multiple outstanding write responses, multiple outstanding read transactions, fairness/starvation bounds, all five AXI channel backpressure combinations, reset with in-flight transactions, malformed bursts, 4-KiB boundaries, ID collision rejection, or the four-DIMM wrapper. It is not exhaustive AXI protocol verification or formal proof.
- Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 88. Re-run burst bench after driver cleanup; remove remaining beat-width warnings (2026-11-24)

- Run [45401097587](https://github.com/shamiursunny/openTPU/actions/runs/45401097587) completed successfully on exact SHA `2dea0dff5e06548b6335b19b133d852c53604e53`. The actual Verilator log again reports: `PASS: concurrent pair/host 3-beat AW-W-B and AR-R bursts with response backpressure; write_bursts=2 read_beats=6 cycles=25`.
- The four new MULTIDRIVEN warnings and earlier integer-vs-8-bit comparison warnings were removed. Log inspection found three remaining testbench WIDTHEXPAND warnings at function calls because 8-bit beat counters were passed to functions declared with integer arguments. Existing reused-RTL PINCONNECTEMPTY, DECLFILENAME and TIMESCALEMOD warnings remain, along with the testbench clock-generator BLKSEQ warning and the GitHub Actions Node.js 20 deprecation warning.
- Corrected the pattern-function beat arguments to explicit 8-bit logic and use an explicit 64-bit zero-extension for XOR data construction in commit `3456e78a1d3e9636e2b5f565c6d7f8e5b6ab0c3a`. No RTL changed.
- Exact-SHA CI Run [45401273740](https://github.com/shamiursunny/openTPU/actions/runs/45401273740) targets `3456e78a1d3e9636e2b5f565c6d7f8e5b6ab0c3a`. At this tracker update, its hmux-sim job `138470204606` remains queued; no result or warning-free claim is made for this latest revision.
- The earlier 3-beat result remains directed simulation evidence only; the warning-corrected latest revision must be inspected before the milestone is marked complete. Outstanding coverage still includes longer bursts, multiple outstanding transactions/responses, fairness/starvation bounds, all-channel independent backpressure, reset with outstanding traffic, malformed/unaligned/4-KiB-crossing requests, reserved-ID collision handling, and four-DIMM integration.
- Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Zero paid resources used.


## 89. Correct remaining burst-bench width truncations and queue exact-SHA validation (2026-11-24)

- Inspected the actual Run 45401273740 `hmux-sim` log for exact SHA `3456e78a1d3e9636e2b5f565c6d7f8e5b6ab0c3a`. It completed successfully and printed the expected directed result (two concurrent three-beat write bursts, six read beats, response backpressure, 25 cycles). However, the log still contained four `WIDTHTRUNC` warnings: two from integer pair/host read-beat counters passed to the 8-bit read-pattern function, and two from the integer loop variable passed to the 8-bit write-pattern function. Therefore, section 88's statement that the width warnings were removed was premature; the warning categories were reduced but not eliminated.
- Corrected `pair_r` and `host_r` to 8-bit logic counters and explicitly sliced the 32-bit procedural loop variable to `beat[7:0]` at the write-pattern calls. Testbench-only change; no RTL changed.
- Latest testbench commit: `4437e1d93bf14f41377c12e0e3ea32b426d90c1a`. Exact-SHA shared-DIMM mux run [45401880965](https://github.com/shamiursunny/openTPU/actions/runs/45401880965) and broader CI workflows are queued or in progress at this update. The latest commit is not yet validated; inspect its log for remaining testbench warnings and its actual PASS marker.
- Broader CI for prior testbench SHA `3456e78a...` is also active: subsystem matrix Run 45401273989, software-core Run 45401273945, RTL-tail Run 45401274009, and remaining RTL/board Run 45401273668. These do not validate the newer `4437e1d...` revision. The isolated 128K one-copy TMEM investigation Run 45401273637 completed successfully on `3456e78a...`; its scope is only that isolated investigation.
- No RTL or architectural parameter change in this step. The focused test remains a single-DIMM, two-requester, three-beat directed test, not full four-DIMM or AXI protocol qualification. Outstanding Gate B items remain those listed in the authoritative baseline.
- Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 90. Pin WG8 PPA container by immutable image ID within each CI run (2026-11-24)

- Reviewed `.github/workflows/sunnyone-asic-wg8-ppa.yml`. Previously, the workflow recorded the pulled `openroad/orfs:latest` image ID but the later `tools/asic/flow.py run` could still resolve the mutable `latest` tag. That weakened reproducibility if the tag moved between preparation and the OpenROAD run.
- Updated the workflow to pull the tag once, capture the immutable local image ID, persist it as `ORFS_IMAGE` through `GITHUB_ENV`, and use that exact image ID for the Yosys/Slang SRAM probe. The later flow script receives the same `ORFS_IMAGE` and therefore uses the same local image ID for Docker-backed OpenROAD. The image ID is archived as `/tmp/orfs-image-id.txt`.
- During review, caught and corrected a doubled-backslash printf formatting issue before accepting the workflow: the committed source now contains exactly `printf '%s\\n' "${image_id}"`, which writes a real newline.
- Corrected workflow commit: `db871f66916134769909a2c42296307b0fec7479`; workflow blob `fa2f3d2012da3b299effa0080fd1c9e78707433e`.
- PPA workflow Run [45402124448](https://github.com/shamiursunny/openTPU/actions/runs/45402124448) targets the corrected commit and remains queued at this update. Earlier Run [45402104710](https://github.com/shamiursunny/openTPU/actions/runs/45402104710) targets the intermediate workflow revision and must not be used to qualify the corrected workflow. No WG8 synthesis/PPA result exists yet.
- The workflow still uses the public mutable release tag only to select the image at the start of each run; it records and pins the resolved image ID within that run. This improves run-level reproducibility, but a future run may pull a newer tag. A stable registry digest should be pinned in the target if a reviewed digest is established.
- No RTL or target parameters changed. Nangate45 remains a research proxy, not a foundry PDK or silicon signoff. Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 91. Correct stale WG8 ASIC-flow test expectation for AW35 and queue config verification (2026-11-24)

- Cross-checked the selected target source `targets/nangate45-wg8.toml` (AW=35, DRAM_BYTES=32 GiB), the authoritative WG8 architecture specification (AW=35), and `opentpu/target.py::rtl_params` (passes the target's AW through unchanged when AW>32).
- Found a stale assertion in `tests/test_asic_flow.py::test_points_are_the_asic_targets` that expected `AW=36` for the `nangate45-wg8` target. This contradicted the selected AW35 minimum-width 32-GiB ASIC candidate and would have failed the target contract check once this workflow ran.
- Corrected only the test expectation from AW36 to AW35. No target, RTL, architecture parameter, or capacity changed. This aligns the regression with the previously documented and selected AW35 design; the BCU FPGA's separate AW36 reference remains distinct.
- Commit: `dfca4d4c1810b442083e3e767482b6f9e41456ae`; test blob `62c400fc238b6429d356cc7518e4c479c6e7d18b`.
- Exact-SHA ASIC configuration workflow Run [45402313680](https://github.com/shamiursunny/openTPU/actions/runs/45402313680) is queued at this update. Its pytest and integrated WG8 lint logs have not yet been inspected. Do not mark the correction validated until the run completes.
- The discovery does not establish an RTL defect; it establishes a stale test expectation. The chosen logical memory map remains 32 GiB, AW35, eight 4-GiB native channels, four 8-GiB DIMM ports.
- Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 92. Add four-DIMM WG8 host-path integration simulation (2026-11-24)

- Added `sim/verilator/tb_asic_wg8_ddr4.sv`, instantiating the actual `otpu_asic_wg8_ddr4_top` rather than four standalone muxes. It drives one independent host write and read through each of the four DIMM ports concurrently, with per-DIMM AW/W/AR controller backpressure and independent host B/R response backpressure.
- The controller-side behavioural model permits W to be accepted before the corresponding AW handshake (AXI channels are independent), records AW ID, waits for both AW and W completion before issuing B, and returns an R beat only after AR acceptance. It checks host ID translation to reserved ID 4, address preservation and local-aperture high bit, AW/AR length, 512-bit data, 64-byte strobes, WLAST, 512-bit read data, OKAY responses, and fixed AXI SIZE=64 bytes / INCR burst attributes.
- All four ports must independently complete B and R responses; any bridge error is fatal. This is bounded host-only full-wrapper integration evidence, not simultaneous host+accelerator pair traffic across all four DIMMs, not PCIe/DMA end-to-end, and not a complete AXI protocol proof.
- Extended `.github/workflows/sunnyone-asic-config.yml` to compile and run the new bench using the BCU1525 WG8 generic RTL source set plus the ASIC integration hierarchy. Added the bench to push path filters, archived its build log, and raised the job timeout to 45 minutes. Also corrected an existing shell pipeline formatting issue in the target-contract pytest step so the pytest output is piped to `tee` in one valid shell command.
- Testbench commit `4d5a30dc12a6bfba0529a3748e551137a8dde4ee`; declaration cleanup commit `812010e049c842beae0d98c5720e9c7839abda97`; workflow commit `22a0fbfdcb531a7982bf42cab86d4eb9c2729f60`.
- Exact-SHA ASIC/configuration run [45402825174](https://github.com/shamiursunny/openTPU/actions/runs/45402825174) is queued at this update. The testbench has not yet been compiled or run; no four-DIMM pass is claimed.
- Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 93. Strengthen four-DIMM wrapper bench against unknowns and width warnings (2026-11-24)

- Reviewed the new four-DIMM host-path bench before its first CI compile. Removed initial values from signals driven by `always_comb`, explicitly sized the DIMM-index contributions to the host address pattern, and explicitly zero-extended the data-pattern index.
- Strengthened controller-side checks to use case inequality for IDs, lengths, address high-bit, burst size/type, response codes and final bridge-error status. Unknown/X values can no longer silently pass a two-state `if` condition as if the expected value were present.
- Latest four-DIMM bench commit: `716fb74676e9e6cdbb8842d927d62ff2c47580b7`; the ASIC/config workflow is [Run 45402976553](https://github.com/shamiursunny/openTPU/actions/runs/45402976553), exact tested SHA `716fb74676e9e6cdbb8842d927d62ff2c47580b7`. At this update it is queued; no compilation or simulation result yet.
- The testbench is intended to verify the real four-DIMM wrapper's four host-facing paths, not just four isolated mux copies. It still does not exercise accelerator-pair traffic simultaneously on all DIMMs, real PCIe DMA, IOMMU, DDR controller/PHY or electrical behaviour.
- No RTL or architecture parameter changed. Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 94. External open PCIe/DDR IP and PDK feasibility audit (2026-11-24)

- Reviewed current public project documentation for candidate zero-cost/open-source host and memory IP. None is a complete drop-in for the current WG8 ASIC's required PCIe Gen3 x16 endpoint/PHY plus eight-channel DDR4 controller/PHY.
- PCIe:
  - `openCologne-PCIE` is BSD-3-Clause and exposes a portable soft protocol stack behind PIPE, leaving the SerDes/PHY as a technology-specific hard-macro problem. Its documented target is Gen1 x1; Gen2 is best-effort without automatic speed retraining; DMA is explicitly outside the deliverables (PIO only). It is a useful future Gen1 research/prototype candidate, not the required Gen3 x16 DMA endpoint. Source: https://github.com/chili-chips-ba/openCologne-PCIE
  - The 2026 OpenPCIe paper describes a synthesizable open endpoint, but the current implementation is Gen1; Gen2 is future work. Its hardware validation is FPGA-oriented and it does not provide a qualified Gen3 x16 ASIC SerDes. Source: https://www.mdpi.com/2076-3417/16/7/3409
  - LitePCIe is BSD-2-Clause and supplies endpoint/TLP, DMA and MSI-X ecosystem features, but its listed PHY implementations wrap vendor FPGA hard IP. It cannot be treated as a portable ASIC Gen3 PHY. Source: https://github.com/enjoy-digital/litepcie and https://github.com/enjoy-digital/litex/wiki/Create-a-PCIe-SoC
- DDR:
  - LiteDRAM is BSD-2-Clause and includes a configurable controller, arbitration, refresh, ECC and BIST. Its documented DDR4 PHY is for Xilinx UltraScale/UltraScale+; its generic PHY is SDR and its DDR4 DFI PHY is for simulation. It may be investigated as a controller/scheduler source, but it is not an ASIC DDR4 PHY or complete eight-channel physical subsystem. Source: https://github.com/enjoy-digital/litedram
  - UberDDR4 is GPL-3.0 and explicitly an FPGA controller+PHY with two Xilinx PHY implementations. It is not an ASIC PHY drop-in; its GPL-3.0 obligations also require separate legal review before any reuse. Source: https://github.com/AngeloJacobo/UberDDR4
- PDK:
  - The IHP official PDK repository classifies SG13G2 as early access and says the open-source PDK is not yet intended for production; SG13CMOS5L is preview-only. Source: https://github.com/IHP-GmbH/IHP-Open-PDK
  - The current Nangate45 WG8 flow is a research proxy, not a manufacturable foundry process. No production PDK, PCIe SerDes, DDR4 PHY, package or controller IP is selected.
- Decision: retain the existing WG8 compute architecture and explicit external PHY/controller boundaries. Do not integrate an FPGA-only PHY or describe any soft protocol core as a complete ASIC endpoint. A production V1 requires either (a) a legally usable, foundry-qualified PCIe/DDR PHY/controller IP path with explicit cost and licence approval, or (b) a new PHY project plus its analog/RF/IO design, verification and silicon characterization. Neither can be completed or validated by RTL-only work in the present zero-spend environment.
- This audit does not change RTL, architecture parameters or external interface contracts. It prevents unsupported IP substitution. Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 95. Consolidate V1 logical design candidate and explicit signoff boundaries (2026-11-24)

- Created `docs/sunnyone/SUNNYONE_AI-X_V1_FINAL_LOGICAL_DESIGN_CANDIDATE_A1.12.11.16.54.md` as the single consolidated logical V1 architecture/interface document. It captures the selected WG8/one-slice/AW35/32-GiB/four-DIMM candidate, memory/address calculations, host/control interfaces, clock/reset/error boundaries, parameter set, ECC obligations, commercial decision policy and verification evidence.
- The document deliberately labels itself a logical design candidate, not a completed or tapeout-ready chip. It explicitly lists the unimplemented PCIe Gen3 endpoint/PHY, DMA descriptor engine, global translation/IOMMU, DDR controller/PHY, production PDK, package, DFT, full formal/CDC/RDC, physical signoff, board and silicon gates.
- The consolidated document is linked from the authoritative continuation baseline. Source architecture and integration documents remain authoritative for detailed module-level contracts.
- Design document created in commit `666f0cec210d05653adc95c984f94970513c02bd`; baseline reference update commit `719df95326a8ed319a0532f1a9449b0d669398d2`.
- No RTL or target parameters changed. Feature branch only; `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Zero paid resources used.


## 96. Queue checkpoint after logical design consolidation (2026-11-24)

- Latest one-DIMM burst-bench width-cleanup testbench SHA remains `4437e1d93bf14f41377c12e0e3ea32b426d90c1a`; exact mux CI Run [45401880965](https://github.com/shamiursunny/openTPU/actions/runs/45401880965) is queued. The prior SHA's successful log still contains four WIDTHTRUNC warnings; no warning-clean claim is made for the latest SHA.
- Latest four-DIMM full-wrapper bench SHA is `716fb74676e9e6cdbb8842d927d62ff2c47580b7`; exact ASIC/config Run [45402976553](https://github.com/shamiursunny/openTPU/actions/runs/45402976553) is queued. The run is required to validate the AW35 config correction, integrated lint and new four-DIMM simulation.
- Latest WG8 PPA workflow correction is commit `db871f66916134769909a2c42296307b0fec7479`; exact PPA Run [45402124448](https://github.com/shamiursunny/openTPU/actions/runs/45402124448) is queued. No WG8 synthesis/PPA output is available.
- Latest broad regression set on the four-DIMM bench SHA includes Runs 45402976579 (remaining RTL/board), 45402976898 (subsystem/memory), 45402976724 (RTL tail), 45402976616 (isolated TMEM) and 45402976582 (software core). At the time of this checkpoint, the first four remain queued and software-core Run 45402976582 is in progress; its actual logs/results have not yet been retrieved.
- GitHub runner queue is preventing the new verification gates from starting. Do not infer success from queued status or older SHA results. Continue by polling exact run/job IDs, then retrieve and inspect logs before updating the design status.
- Consolidated logical design document and authoritative baseline references are committed. Current feature branch head before this tracker entry is `3cf1c6693d2a7f22f7ed88fca6b36c84475ff01c`; `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 97. Verify latest shared-DIMM mux burst simulation and recheck pending gates (2026-11-24)

- Exact-SHA mux run [45401880965](https://github.com/shamiursunny/openTPU/actions/runs/45401880965) completed successfully on testbench SHA `4437e1d93bf14f41377c12e0e3ea32b426d90c1a`. Job `hmux-sim` (job ID `138472295010`) completed with conclusion `success`.
- Retrieved and inspected the complete job log. Verilator 5.032 compiled the actual `otpu_mig_hmux` with its FIFO/AXI dependencies; the simulation printed: `PASS: concurrent pair/host 3-beat AW-W-B and AR-R bursts with response backpressure; write_bursts=2 read_beats=6 cycles=25`. Simulation finished at 260 ns. The test covers two concurrent three-beat write bursts, six read beats, and response backpressure.
- The prior four `WIDTHTRUNC` warnings are absent from this exact-SHA log. Remaining non-fatal warnings include `PINCONNECTEMPTY`, `DECLFILENAME`, `TIMESCALEMOD`, and `BLKSEQ` in the selected RTL/testbench sources. GitHub also emitted its Node.js 20 deprecation warning for `actions/checkout@v4`; this is a workflow-maintenance warning, not a simulation failure.
- Scope limitation: this is a directed single-DIMM, two-requester mux simulation. It does not establish exhaustive AXI protocol compliance, bounded fairness under arbitrary traffic, reset with outstanding transactions, reserved-ID collision handling, byte-strobe memory effects, malformed/boundary burst rejection, four-DIMM simultaneous host+accelerator traffic, PCIe/DMA end-to-end, or physical memory behaviour. Those remain open qualification items.
- Re-polled the other exact workflow jobs. PPA Run [45402124448](https://github.com/shamiursunny/openTPU/actions/runs/45402124448), four-DIMM ASIC/config Run [45402976553](https://github.com/shamiursunny/openTPU/actions/runs/45402976553), board/remaining RTL Run [45402976579](https://github.com/shamiursunny/openTPU/actions/runs/45402976579), subsystem/memory Run [45402976898](https://github.com/shamiursunny/openTPU/actions/runs/45402976898), RTL-tail Run [45402976724](https://github.com/shamiursunny/openTPU/actions/runs/45402976724), and isolated TMEM Run [45402976616](https://github.com/shamiursunny/openTPU/actions/runs/45402976616) remain queued. Software-core Run [45402976582](https://github.com/shamiursunny/openTPU/actions/runs/45402976582) remains in progress; no test summary is available yet.
- Current active branch head before this tracker update: `ec4d45fcd58be0b191e2140e64b4d63d149d69db`. `main` was independently rechecked at `d84db55712aba0d40811d7762cb052f05d55b7e5` and remains unchanged. No paid resources used.
- Next: wait for and inspect exact-SHA logs for the queued ASIC/config, PPA, broad RTL, board, memory, TMEM and software gates. Do not infer pass from queue status or substitute results from earlier SHAs. Then extend mux qualification with the outstanding directed and protocol/property cases before promoting the host-memory path maturity.


## 98. Correct tracker executive status to match completed logical candidate and verified gates (2026-11-24)

- Reconciled the tracker executive summary and stage/gate status with the later evidence recorded in sections 89–97. The previous top-level stage still said A1.12.11.16.45 and referenced older runs as current, despite section 95 documenting the consolidated A1.12.11.16.54 logical candidate and section 97 recording the successful latest mux run.
- Updated the top-level baseline to Run 45382805606 (377 passed, one intentional 64-GiB address-window skip, zero reported failures; reset audit passed) and Run 45401880965 (latest exact-SHA mux burst simulation passed). Kept the remaining queued/in-progress runs explicitly pending.
- Updated immediate actions and G0–G8 maturity to distinguish completed logical architecture, partial RTL/mux evidence, pending PPA and four-DIMM host-path verification, and the still-open production PHY/PDK/physical/hardware/commercial gates.
- This is documentation reconciliation only. No RTL, target, testbench, workflow, interface, or architecture parameters changed.
- Feature branch head before this tracker update: `5cf5b4c40c46d2f07a6f4c30abd122032f914938`. `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 99. Diagnose failed WG8 PPA and four-DIMM configuration gates; correct test and container setup (2026-11-24)

- PPA Run [45402124448](https://github.com/shamiursunny/openTPU/actions/runs/45402124448), exact SHA `db871f66916134769909a2c42296307b0fec7479`, failed before synthesis/placement. The pinned Docker image pull succeeded (image digest `sha256:620c13d94b80290ccaa6d6d7fbaef9632bdb06ba7e6aedb88da845159b840c09`; image ID `sha256:11e3e93412267b75bd9a597da46da6cb312d8c4bd7679f694f999c13e44ead7a`), but the prep container lacked Python NumPy and did not set `ORFS_HOME` / `YOSYS`, so `flow.py` could not find Yosys+Slang. OpenROAD did not run; this was a CI environment/configuration failure, not a reported RTL or PPA failure.
- Corrected `.github/workflows/sunnyone-asic-wg8-ppa.yml` to execute prep, config, run and report inside the same exact image-ID container, install the container's `python3-numpy` package, and explicitly set `/OpenROAD-flow-scripts` and its Yosys executable. Latest rerun [45413588835](https://github.com/shamiursunny/openTPU/actions/runs/45413588835), exact SHA `87a23ad63e3c0527000152137d252ea2ea16714e`, is queued; no PPA result is yet available.
- Four-DIMM ASIC/config Run [45402976553](https://github.com/shamiursunny/openTPU/actions/runs/45402976553), exact SHA `716fb74676e9e6cdbb8842d927d62ff2c47580b7`, failed in the initial target/config pytest step: **4 failed, 62 passed**; all lint and four-DIMM simulation steps were skipped. The failures were test/target-contract inconsistencies identified from the log: (1) the WG8 ASIC test's expected parameter dict included `QUANT_R1` and `QUANT_PW` but its selected-key comprehension omitted them; (2) `nangate45-wg8` and `nangate45` both used platform ID 256; (3) the target test's WG8 grouping set omitted the new ASIC WG8 target; (4) the DRAM address-width test treated the new 35-bit ASIC target as a legacy AW32 target.
- Corrected the WG8 ASIC target platform ID to 258 (unique among all current target files), added the two quantizer parameters to the ASIC test's selected-key set, and updated target tests to recognise the ASIC WG8 target as a WG target with AW=35 and 32 GiB logical DRAM. No RTL or selected architecture parameter was changed by these fixes.
- The corrected configuration suite was queued in three commits as push events; the latest full-fix run is [45413523987](https://github.com/shamiursunny/openTPU/actions/runs/45413523987), exact SHA `eb0379d428f54e8f2bd43c9fd3e990f65fbd2acd`. Earlier queued runs [45413467426](https://github.com/shamiursunny/openTPU/actions/runs/45413467426) and [45413487571](https://github.com/shamiursunny/openTPU/actions/runs/45413487571) are older intermediate SHAs and must not be used as final evidence. At the latest poll, all were queued; no corrected test result is claimed.
- On the previous integration SHA `716fb74676e9e6cdbb8842d927d62ff2c47580b7`, isolated TMEM passed **2 tests** (Run [45402976616](https://github.com/shamiursunny/openTPU/actions/runs/45402976616)); RTL-tail passed **33 tests with 1 skip** (Run [45402976724](https://github.com/shamiursunny/openTPU/actions/runs/45402976724)); stream RTL passed **14 tests** and MX multiply/replay job succeeded (Run [45402976898](https://github.com/shamiursunny/openTPU/actions/runs/45402976898)). The stream run's other matrix jobs remain queued/in progress at the latest poll. The board and uncovered-core jobs in Run [45402976579](https://github.com/shamiursunny/openTPU/actions/runs/45402976579) were still running; software-core Run [45402976582](https://github.com/shamiursunny/openTPU/actions/runs/45402976582) was cancelled, so no software-core pass is claimed.
- Current feature-branch head before this tracker entry: `87a23ad63e3c0527000152137d252ea2ea16714e`. `main` independently verified unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 100. Correct ASIC lint macro elaboration and DMA declaration order; queue exact-SHA re-verification (2026-11-24)

- Target/config test corrections are now passing in the executed suite: Run [45414724190](https://github.com/shamiursunny/openTPU/actions/runs/45414724190), exact SHA `20a07a7ec9ef4f986e3e7d3159b2027993f9d674`, reported **66 passed** before integrated lint. The remaining failure was not a test assertion: lint was elaborating simulation-only hierarchical memory initialization because the ASIC lint commands lacked `SYNTHESIS`. Added `-DSYNTHESIS` to the three hardware-top lint commands.
- The next exact-SHA lint run exposed missing leaf macro declarations: the ASIC technology wrapper instantiates generated `otpu_sram_1r1w`, `otpu_sram_1rw`, and `otpu_sram_1rw1r` leaves, which do not exist as source RTL until the PDK-specific macro generator runs. Added `sim/verilator/asic_sram_lint_stubs.sv` containing black-box declarations for those interfaces and included it only in ASIC lint elaboration. These stubs are not behavioural models, not macro implementations, and not PPA/physical evidence. Corrected a Verilator directive-comment parsing issue in the stub's introductory comment and added the file to the workflow path filter.
- ASIC/config Run [45416114876](https://github.com/shamiursunny/openTPU/actions/runs/45416114876), exact SHA `0bfbc8de57ea7b8511cade8ff7a3f78921913996`, still failed because the stub comment was parsed as an unknown Verilator directive. That comment was corrected; latest re-run [45416377735](https://github.com/shamiursunny/openTPU/actions/runs/45416377735), exact SHA `b430e8cb78bdd4daf670c94c7b7b4429771e2d18`, was queued at the latest poll. No lint or four-DIMM simulation pass is yet claimed.
- The reproducible PPA container now sources ORFS `env.sh`, installs/uses the container's NumPy, pins the exact pulled image ID, and runs prep/config/run/report in that same container. An explicit `yosys -m slang -p "help read_slang"` diagnostic was removed because the module-help invocation itself returned non-zero before the actual probe. The flow's probe diagnostics were changed to non-quiet mode and extended to retain 12,000 trailing characters.
- PPA Run [45415307359](https://github.com/shamiursunny/openTPU/actions/runs/45415307359), exact SHA `f62e468b84684f09da004688ad54cf00c4d36d45`, exposed nine real Slang front-end errors: `su_cfg`, `su_ns`, `su_src`, and `su_dst` were used in the earlier SRX generate branch before their module-scope declarations later in `rtl/dma/otpu_dma.sv`. Moved the relevant declarations ahead of the generate branch. A first edit left duplicate `su_src/su_dst` declarations; the RTL-tail regression detected this immediately (Run [45415760651](https://github.com/shamiursunny/openTPU/actions/runs/45415760651), exact SHA `51236e5b4d3e69e6030da21edf301ae46d9eeb64`). The duplicate declarations were removed in commit `0bfbc8de57ea7b8511cade8ff7a3f78921913996`. No RTL regression result on the corrected declaration order is available yet.
- Latest PPA re-run [45416114934](https://github.com/shamiursunny/openTPU/actions/runs/45416114934), exact SHA `0bfbc8de57ea7b8511cade8ff7a3f78921913996`, was queued at the latest poll. No synthesis or OpenROAD result is claimed.
- Reset audit Run [45413467381](https://github.com/shamiursunny/openTPU/actions/runs/45413467381), exact SHA `c638c4abc38922867de7ef06191224403c55f70a`, completed successfully. This is a bounded reset/power-up audit, not full formal signoff.
- The original four-DIMM configuration gate's target-contract tests have reached 66/66 pass on SHA `20a07a7...`; lint and four-DIMM host simulation remain unqualified until the latest black-box-stub run completes. Earlier independent gates on SHA `716fb746...` include the 33-pass/1-skip RTL tail, 2-pass isolated TMEM, and 14-pass stream RTL; these results do not include the later DMA declaration-order edit.
- Broad board-functional, RTL-uncovered, software-core, and subsystem/memory matrix runs are still pending or in progress at the latest poll. Their older-SHA results must not be substituted for the corrected `0bfbc8de...` SHA.
- Feature branch head before this tracker entry: `b430e8cb78bdd4daf670c94c7b7b4429771e2d18`. `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 101. Re-run ASIC integration, broad regressions and PPA after evidence-driven corrections (2026-11-24)

- The target/config suite on the corrected branch has progressed past pytest and all three integrated Verilator lint gates to the four-DIMM host-path simulation. Latest run [45417564203](https://github.com/shamiursunny/openTPU/actions/runs/45417564203), exact SHA `8df2190f2ae5c69e2c64e6b3bd1dc4cfae7a857a`, job `138527867103`: simulation is in progress at this checkpoint. No four-DIMM PASS is claimed until the job completes and its log is inspected.
- The preceding corrected configuration run [45414724190](https://github.com/shamiursunny/openTPU/actions/runs/45414724190), exact SHA `20a07a7ec9ef4f986e3e7d3159b2027993f9d674`, reported **66 passed** in the target/config pytest stage. The latest integrated run has since advanced through lint, which indicates the SYNTHESIS define and ASIC SRAM lint black-box stubs cleared those earlier blockers; the simulation result remains pending.
- The four-DIMM testbench's current scope remains one single-beat host write and one single-beat host read through each DIMM concurrently, with independent per-port backpressure and response checks. It is not yet a multi-beat four-DIMM test, nor accelerator-pair/host contention on all four ports.
- The DMA declaration-order issue found by Slang was addressed in commits `51236e5b4d3e69e6030da21edf301ae46d9eeb64` and `0bfbc8de57ea7b8511cade8ff7a3f78921913996`. Exact RTL-tail run [45415760651](https://github.com/shamiursunny/openTPU/actions/runs/45415760651) caught duplicate declarations in the intermediate SHA; the duplicate was removed. The latest RTL-tail run [45417561286](https://github.com/shamiursunny/openTPU/actions/runs/45417561286), exact SHA `8df2190f2ae5c69e2c64e6b3bd1dc4cfae7a857a`, is still running; no regression pass is claimed for the corrected DMA source yet.
- The WG8 Nangate45 PPA run [45416114934](https://github.com/shamiursunny/openTPU/actions/runs/45416114934), exact SHA `0bfbc8de57ea7b8511cade8ff7a3f78921913996`, is running the pinned-container SRAM probe and ORFS flow. The earlier Slang errors from the pre-declaration-order SHA are not evidence about this later run. No synthesis, area, timing, power or PPA result is available yet.
- Broad board/remaining RTL run [45417561817](https://github.com/shamiursunny/openTPU/actions/runs/45417561817) is in progress: board-functional job `138527855556` is running, and RTL-uncovered job `138527856301` is preparing pinned Verilator 5.044. Subsystem/memory run [45417561535](https://github.com/shamiursunny/openTPU/actions/runs/45417561535) and isolated TMEM run [45417561463](https://github.com/shamiursunny/openTPU/actions/runs/45417561463) remain queued. Software-core run [45417202615](https://github.com/shamiursunny/openTPU/actions/runs/45417202615), exact SHA `8ef09ad88da709ac8b10ec15f76950f116b440f2`, is still running; it is not the latest branch SHA.
- The latest feature-branch head before this tracker entry is `8df2190f2ae5c69e2c64e6b3bd1dc4cfae7a857a`. Independently rechecked `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5`, unchanged. No paid resources used.
- Next: retrieve completed logs for Runs 45417564203, 45417561286, 45417561817, 45416114934 and 45417202615; inspect actual simulation, pytest summaries, warnings, synthesis and physical-flow reports; then update this tracker with exact outcomes. Do not substitute results from older SHAs.


## 102. Complete isolated 128K one-copy TMEM investigation on current RTL SHA (2026-11-24)

- Isolated one-copy 128K TMEM workflow Run [45417561463](https://github.com/shamiursunny/openTPU/actions/runs/45417561463), exact source SHA `8df2190f2ae5c69e2c64e6b3bd1dc4cfae7a857a`, job `138527854199`, completed successfully.
- Retrieved and inspected its complete job log: **2 passed, 215 deselected in 97.01 seconds**. The selection is deliberately the isolated one-copy 128K investigation; it is not the full 217-test TMEM/memory suite.
- No RTL, memory architecture, or capacity changed in this test run. It supplies bounded evidence for the selected one-copy 128K TMEM configuration, not full-chip memory verification, timing closure, SRAM macro signoff or physical implementation.
- At this update, ASIC/config Run [45417564203] is still running its four-DIMM simulation; RTL-tail Run [45417561286], board/remaining RTL Run [45417561817], PPA Run [45416114934], and software-core Run [45417202615] remain in progress. Subsystem/memory Run [45417561535] remains queued. No results are inferred from those statuses.
- Tracker update commit before this entry: `b799fd132ab5597a4fde4350e24a3924fc3dbd31`; main remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 103. Instrument four-DIMM host-path timeout and reconcile exact-SHA regression evidence (2026-11-24)

- Re-polled the active feature branch. At the start of this investigation, branch HEAD was `9d7313f79c061c22a724481e90b06d04d32bdbbd`; `main` remains separately documented at `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Four-DIMM ASIC/config Run [45417564203](https://github.com/shamiursunny/openTPU/actions/runs/45417564203), tested SHA `8df2190f2ae5c69e2c64e6b3bd1dc4cfae7a857a`, job `138527867103`, completed with failure. Target/config pytest and all three integrated Verilator lint steps completed sufficiently to reach simulation; the simulation compiled, then failed at `tb_asic_wg8_ddr4.sv:188` with `four-DIMM host-path timeout` at 200 microseconds. The original testbench did not report which host handshake or response phase stalled, so the failure's root cause is not yet known. Do not classify it as an RTL defect or a testbench defect without the next diagnostic run.
- Added timeout-only diagnostics to `sim/verilator/tb_asic_wg8_ddr4.sv`: global host and controller-side VALID/READY vectors, response vectors, per-DIMM synchronised reset state, and per-port AW/W/AR and B/R progress flags. This change does not alter transaction stimulus, protocol logic, RTL or architecture. Commit: `b41669fe1d67a3f7dcb84d86a960cdb4b9167ad8`. Its exact-SHA simulation result is pending; no diagnostic conclusion or four-DIMM PASS is claimed yet.
- RTL-tail Run [45417561286](https://github.com/shamiursunny/openTPU/actions/runs/45417561286), exact SHA `8df2190f2ae5c69e2c64e6b3bd1dc4cfae7a857a`, completed successfully. Inspected job `138527853453` log: **33 passed, 1 skipped, 183 deselected in 923.81 seconds**. The skip is the documented PAIR geometry condition (`PAIR needs 2M <= MCOLS; M <= ACT_ROWS`). This is a selected RTL-tail suite, not the complete repository regression.
- Isolated one-copy 128K TMEM Run [45417561463](https://github.com/shamiursunny/openTPU/actions/runs/45417561463), exact SHA `8df2190f2ae5c69e2c64e6b3bd1dc4cfae7a857a`, completed successfully: **2 passed, 215 deselected in 97.01 seconds**. This is a narrow investigation, not the full TMEM/memory suite.
- WG8 research PPA Run [45416114934](https://github.com/shamiursunny/openTPU/actions/runs/45416114934), exact SHA `0bfbc8de57ea7b8511cade8ff7a3f78921913996`, failed with ORFS exit code 2 after SRAM inventory/elaboration. The log confirms 288 SRAM macro instances across 14 sizes, approximately 3,538 KiB total SRAM. The uploaded artifact was only 3,517 bytes and did not include `run.log`; no area, timing, power or PPA result is available. The exact OpenROAD failure remains undiagnosed until the flow archives the full run log and detailed reports.
- The successful RTL-tail and TMEM results above are from SHA `8df2190f...`, not the current diagnostic testbench commit. Do not transfer those results to the newer SHA without exact-SHA reruns.
- Next: inspect the diagnostic four-DIMM run; use its first stalled phase to isolate reset, handshake, response or scoreboard behaviour; make the smallest evidence-supported correction; then expand to multi-beat traffic, independent channel backpressure, host/accelerator contention, reset-in-flight, address/burst boundaries and ID/error cases. In parallel, fix PPA evidence collection so the full ORFS log and reports are preserved before interpreting exit code 2.
- Feature branch only; `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 104. Improve manufacturer-handoff evidence capture and reconcile latest simulation gates (2026-11-24)

- Re-inspected the four-DIMM host-path testbench and workflow. The prior failure is confirmed to be a simulation timeout after successful compile; the testbench now contains timeout diagnostics for global host/controller VALID/READY, response vectors, per-DIMM synchronised reset and per-port transaction progress. The diagnostic testbench commit is `b41669fe1d67a3f7dcb84d86a960cdb4b9167ad8`. No diagnostic run result was available through the current workflow-run lookup at this checkpoint; no root cause or PASS is claimed.
- Recovered and inspected the full failing four-DIMM job log for Run [45417564203](https://github.com/shamiursunny/openTPU/actions/runs/45417564203), SHA `8df2190f2ae5c69e2c64e6b3bd1dc4cfae7a857a`: target/config tests and all three Verilator lint steps completed; simulation then timed out at 200 microseconds. The log also contains width-expansion/truncation and UNOPTFLAT warnings; these are recorded for review and are not automatically treated as functional failures or waived.
- Retrieved the completed RTL-tail log for Run [45417561286](https://github.com/shamiursunny/openTPU/actions/runs/45417561286), SHA `8df2190f2ae5c69e2c64e6b3bd1dc4cfae7a857a`: **33 passed, 1 skipped, 183 deselected in 923.81 seconds**. The single skip is the documented PAIR geometry condition. This is a selected regression group, not a full repository regression.
- Retrieved additional completed subsystem logs from Run [45417561535](https://github.com/shamiursunny/openTPU/actions/runs/45417561535), SHA `8df2190f2ae5c69e2c64e6b3bd1dc4cfae7a857a`: MX multiply/replay **17 passed**; quantizer modes **15 passed**; quantizer corner/tie-rounding **8 passed**; stream RTL **14 passed**. Other jobs in that matrix were queued or running at the time of inspection; no overall matrix pass is claimed.
- Isolated TMEM Run [45417561463](https://github.com/shamiursunny/openTPU/actions/runs/45417561463): **2 passed, 215 deselected**; narrow one-copy 128K test only.
- PPA Run [45416114934](https://github.com/shamiursunny/openTPU/actions/runs/45416114934) failed with exit code 2. Inspection of `tools/asic/flow.py` confirmed that ORFS writes its full transcript to `build/asic/nangate45-wg8/run.log`, but the previous workflow artifact did not upload that file or the complete work logs/results. The failure cannot be diagnosed from the missing artifact.
- Corrected `.github/workflows/sunnyone-asic-wg8-ppa.yml` to preserve the full `run.log`, its trailing diagnostic excerpt, ORFS work logs/reports/results, image ID, macro inventory and generated constraints/configuration. Workflow update commit: `21e1d56c5c6bcafc8d45a49f5aa8920516bad068`. This is an evidence-collection correction only; it does not alter RTL or claim a PPA result. A new PPA run is expected from the workflow change and must be inspected before any area/timing/power claim.
- The current deliverable objective is simulation-complete, manufacturer-reviewable RTL and documentation. Manufacturer-only tasks (technology-specific PHYs, foundry PDK mapping, SRAM compiler qualification, DFT implementation, physical signoff, package and board validation) remain explicit handoff dependencies rather than being represented as completed.
- Feature branch only; `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 105. Create manufacturer handoff readiness specification (2026-11-24)

- Added `docs/sunnyone/SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md`, commit `d6d5d4816e4afa6fc5dd07d71628981dd3c4aea2`.
- The document defines the intended ASIC + custom-board product boundary, current four-DIMM WG8 logical candidate, exact known interface boundary, missing PCIe/DMA/global-address-translation/DDR4 PHY and controller/DFT/physical/package/board requirements, verification gates, manufacturer return deliverables, immutable release discipline and zero-spend rule.
- It explicitly labels the design NOT READY for fabrication or final production-board build. It permits a later feasibility review only after the digital simulation/documentation package is sufficiently closed and the manufacturer is given an immutable SHA with all open dependencies disclosed.
- The document does not claim new RTL functionality or verification results. It is a requirements and handoff-control artifact.
- The PPA evidence-collection workflow correction is recorded in section 104; its next run must include `build/asic/nangate45-wg8/run.log`, ORFS logs/reports/results and the exact image ID. No new PPA result is yet claimed.
- The diagnostic four-DIMM simulation remains a blocker. Do not promote the design to manufacturer implementation handoff until its timeout is understood and the expanded AXI integration tests pass.
- Feature branch only; `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`. No paid resources used.


## 106. Establish authoritative live manufacturer-handoff task register (2026-11-24)

- Expanded `docs/sunnyone/SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md` with Section 9, the single authoritative status register for simulation readiness and manufacturer handoff. Update commit: `ee6f8f718ee0e157aea435e633a715e05860f9c4`.
- The register separates evidence-verified completed/scoped tasks (M01–M14), failed/incomplete simulation and CI tasks (A01–A12), and manufacturer/physical dependencies (H01–H12). It defines statuses, acceptance evidence, release gates and a continuation protocol requiring the register and chronological tracker to be updated in the same work session.
- Important: “DONE” in the register is explicitly scoped to the named test or document; it does not imply full-chip verification. The four-DIMM simulation timeout and PPA exit-code-2 failure remain open. Previously running/queued matrix jobs are not promoted to complete without retrieved results.
- Current next priorities remain A01 (diagnose and pass four-DIMM host-path simulation) and A04 (retrieve full ORFS log from the next run and diagnose PPA flow). The full final-SHA regression and manufacturer package remain not complete.
- The master register is intended to prevent task/status drift across continuation chats. Before any further implementation, read it and verify current branch/commit and CI evidence. After each task, update both this register and this tracker with exact SHA/run IDs/results.
- Latest verified task-register update commit: `ee6f8f718ee0e157aea435e633a715e05860f9c4`. Feature branch remains `sunnyone/commercial-profitability-architecture-2026-11-23`; no changes to `main` and no paid resources used.



## 107. Diagnose four-DIMM reset/handshake timeout and repair PPA workflow image-ID capture (2026-11-24)

- Re-verified repository state before edits: feature branch was at `8b77c14070ae29f7f6021951aa111ce62f6af9b1`; `main` independently remained `d84db55712aba0d40811d7762cb052f05d55b7e5`. All edits are on the feature branch.
- Retrieved the diagnostic four-DIMM ASIC/config Run [45425750505](https://github.com/shamiursunny/openTPU/actions/runs/45425750505), job `138557141766`, exact SHA `b41669fe1d67a3f7dcb84d86a960cdb4b9167ad8`. Target/config and integrated lint/build stages completed, but simulation timed out at cycle 20,000. Diagnostic state: `h_awvalid=0000`, `h_wvalid=1111`, `h_wready=0000`, controller `m_awvalid=0000`, and all four per-port `aw_accepted=0`; all DIMM reset synchronisers were low at timeout. The host tasks had advanced past AW but never completed W.
- Source review found the bench started its four tasks immediately after deasserting the global reset, without waiting for each DIMM's two-flop reset synchroniser. The hmux's READY is combinational during reset; the original `while (!READY)` task loops also fail safe neither for X nor for reset-time READY. Corrected `drive_port` to wait until `dut.dimm_rst_sync[d] === 1'b0` before presenting VALID, and changed each handshake loop to continue until READY is exactly logic 1. No DUT RTL, stimulus payload, or protocol logic was changed. Testbench commit: `ec0fe8329df06e5204a1c082df133b62b434846b`.
- The exact-SHA ASIC/config rerun [45428347822](https://github.com/shamiursunny/openTPU/actions/runs/45428347822), SHA `ec0fe8329df06e5204a1c082df133b62b434846b`, was queued at this checkpoint. A01 remains open until its simulation completes and the full log confirms the four-port PASS.
- Retrieved the PPA workflow run [45426849673](https://github.com/shamiursunny/openTPU/actions/runs/45426849673), job `138561067049`, exact SHA `21e1d56c5c6bcafc8d45a49f5aa8920516bad068`. It failed before running ORFS: the workflow's `printf` format wrote a literal backslash-n into `/tmp/orfs-image-id.txt`; Docker then rejected the resulting image reference with `invalid reference format`. The artifact was only 347 bytes; no ORFS transcript, synthesis, area, timing or power result was produced by this attempt.
- Corrected the workflow to write a real newline with `printf '%s\\n'` (one backslash in the YAML shell format), commit `e212fe714eac17e339a2cc9090bee293a8ba6c09`. PPA verification Run [45428370570](https://github.com/shamiursunny/openTPU/actions/runs/45428370570) was queued at this checkpoint. A04 remains open until the container starts, the ORFS flow runs, and the complete log/artifacts are inspected.
- Broad RTL, board, software and subsystem matrix runs triggered from the testbench commit were also queued/in progress: [45428347806](https://github.com/shamiursunny/openTPU/actions/runs/45428347806), [45428348086](https://github.com/shamiursunny/openTPU/actions/runs/45428348086), [45428347706](https://github.com/shamiursunny/openTPU/actions/runs/45428347706), and [45428347703](https://github.com/shamiursunny/openTPU/actions/runs/45428347703). Older diagnostic-SHA matrix runs [45425750624](https://github.com/shamiursunny/openTPU/actions/runs/45425750624), [45425750818](https://github.com/shamiursunny/openTPU/actions/runs/45425750818), [45425750779](https://github.com/shamiursunny/openTPU/actions/runs/45425750779), and [45425750683](https://github.com/shamiursunny/openTPU/actions/runs/45425750683) remained incomplete at the latest poll. Do not transfer results across SHAs or infer completion from queued/running status.
- Updated the master manufacturer-handoff register to record both diagnoses, corrective commits, exact run/job IDs and pending verification. Register update commit: `77b44bba028de87fa38cc740fe40c2078dcf5cd0`.
- The feature branch remains the only work target. No changes to `main`; no paid resources used. The project is not yet simulation-ready for manufacturer feasibility review, and is not ready for fabrication or a production board.



## 108. Add permanent project resume guide and three-document continuation protocol (2026-11-24)

- Created `docs/sunnyone/SUNNYONE_AI-X_PROJECT_RESUME.md`, commit `3a39b5eada362f65e9882896a5ee34bea5d9760c`. This is the fresh-session quick-start document for a new ChatGPT window. It records the user's project goal and handoff boundary; zero-spend and feature-branch-only rules; architecture candidate; exact A01/A04 diagnoses, correction commits and pending run IDs; other regression run IDs; task priorities; manufacturer dependencies; key source/workflow paths; and the step-by-step resume protocol.
- The resume explicitly instructs every new session to read itself, the master handoff register and this chronological tracker; verify current feature branch HEAD and `main`; inspect current CI runs/logs/artifacts; continue the highest-priority unresolved task; and update all three documents after meaningful work.
- Updated `docs/sunnyone/SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md` to link the resume guide and formalise the three-document hierarchy/update protocol. Register update commit: `2b168ed918b2434347b212d7b79d700558dcc48e`.
- The three document roles are distinct: resume = quick-start and workflow; master register = authoritative task status, acceptance and manufacturer boundary; tracker = dated chronology and evidence. All three must be kept synchronised until project completion.
- At the beginning of this work session, feature branch HEAD was `c4748c78d88e1660dc12dd6be981674dea5a962d`; `main` was independently verified unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`. The resume and register were created/updated on the feature branch only.
- The latest confirmed A01 run `45428347822` and A04 run `45428370570` were still queued at the previous poll. Their outcomes are not assumed. Continue by retrieving both exact-SHA workflow results and logs, then reconcile the other regression matrix runs.
- No RTL was changed in this documentation task. No paid resources used. The project is not yet simulation-ready for manufacturer feasibility review and is not fabrication/production-board ready.


## 109. Pass the single-beat four-DIMM host path; diagnose and correct the Nangate45 async-memory synthesis limit (2026-11-24)

- Re-verified the feature-branch commit chain through the latest code/documentation changes. Feature branch checkpoint before this three-document refresh: `c09447bafa3460d4acc74b35c4f7e6bdf40b9857`. Independently queried the repository's latest default-branch commit: `d84db55712aba0d40811d7762cb052f05d55b7e5`; `main` remains unchanged. All changes described here are on `sunnyone/commercial-profitability-architecture-2026-11-23`.
- **A01 passed on its exact SHA.** Four-DIMM ASIC/config Run [45428347822](https://github.com/shamiursunny/openTPU/actions/runs/45428347822), job `138566432055`, tested SHA `ec0fe8329df06e5204a1c082df133b62b434846b`, completed successfully. The full job log reports: `PASS: four independent WG8 DIMM ports; host AW/W/B and AR/R routed on all four ports with independent backpressure`; Verilator finished at 210 ns. The uploaded artifact is `sunnyone-asic-config-log`, artifact ID `14939292285`, SHA256 `084a922ec104dbf38ee38137f1b10e0757650c6bea5e2d510b7c61b4fcf1c9d9`. This closes only the single-beat four-port host-path test; A02 multi-beat/protocol coverage and A03 host/accelerator contention remain open.
- The A01 lint log still contains WIDTHEXPAND/WIDTHTRUNC warnings in `otpu_seq.sv`, `otpu_dma.sv`, `otpu_tmem.sv` and `otpu_native_dram.sv`; UNOPTFLAT warnings in `otpu_slice.sv` and `otpu_tmem.sv`; and MODDUP for `otpu_native_dram.sv` in the WG8 lint stage. The final WG8 lint command suppresses two width-warning classes while earlier chip/memory lint outputs still expose them. These warnings remain for A11 triage; they are not silently waived.
- **A04 root cause is now diagnosed from the complete artifact.** PPA Run [45428370570](https://github.com/shamiursunny/openTPU/actions/runs/45428370570), job `138566505337`, exact SHA `e212fe714eac17e339a2cc9090bee293a8ba6c09`, successfully pulled and pinned ORFS image `sha256:02c90ad9cb0efb19f7881bf1bf43330dacb5323eac756af6e1604042ec60d21a`, ran the SRAM probe, enumerated 288 macro instances across 14 sizes (~3,538 KiB), and entered ORFS/Yosys synthesis. It then exited 2 because three MXU result-FIFO memories are each 64 x 672 = 43,008 bits, exceeding `SYNTH_MEMORY_MAX_BITS=16384`. This is not a Docker failure and is not a PPA result.
- Source inspection shows these three memories use `otpu_ram_1r1w_ra`, whose registered-address, asynchronous-read and write-first behaviour differs from the synchronous fakeram45 macro interface. Mapping them to the existing synchronous fake macros would change semantics. The evidence-led research-flow correction therefore keeps these copies as flip-flops by raising the synthesis threshold to 65,536 bits; it does not claim a foundry SRAM macro or a final architecture solution.
- Flow correction commit: `0b67e65deb7fcc457b10bb825304db752689b3e7`, file `tools/asic/flow.py`. Documentation commit: `c09447bafa3460d4acc74b35c4f7e6bdf40b9857`, file `asic/nangate45/README.md`. The README explicitly identifies this as a high-area research mapping and requires a real foundry macro with matching behaviour or a separately verified RTL/microarchitecture change. **No follow-up PPA run ID or successful synthesis report has yet been verified.** A04/A05 remain open.
- PPA artifact `sunnyone-nangate45-wg8-ppa`, artifact ID `14939507553`, SHA256 `8ddc0d230a0338e9e2d8d32b976eb4cd6be1dab3437c0f923cb556504d828903`, was downloaded and inspected. It includes the full `run.log`, generated config/SDC/macro inventory and Yosys logs. The decisive error is in `work/logs/nangate45/otpu_nangate45-wg8/base/1_2_yosys.log`; no `report.json`, placement, timing, area or power report was produced.
- Subsystem/memory matrix Run [45428347703](https://github.com/shamiursunny/openTPU/actions/runs/45428347703), exact SHA `ec0fe8329df06e5204a1c082df133b62b434846b`, had all 14 jobs complete successfully. Retrieved per-job summaries total **374 passed, 1 skipped, 0 failed**. The one skipped test's reason was not included in the captured pytest summary, so A06 remains PARTIAL until that skip is classified. Per-job passed counts: MX multiply/replay 17; quantizer modes 15; QHL 7; collective hub/DMA/scoreboard 128; floating-point 8; wait-state 11; stream 23; quantizer corners/ties 8; instruction cache 11; address-window 20 plus 1 skip; SPLITQ 5; QST/QSTB 13; reset audit 4; native DRAM/technology RAM 104.
- RTL-tail Run [45428348086](https://github.com/shamiursunny/openTPU/actions/runs/45428348086), job `138566421070`, completed successfully on SHA `ec0fe832...`; however its expected log artifact was not produced, so the exact pytest count is not claimed. Earlier RTL-tail results from other SHAs are not substituted.
- Software-core Run [45428347706](https://github.com/shamiursunny/openTPU/actions/runs/45428347706) and board/uncovered Run [45428347806](https://github.com/shamiursunny/openTPU/actions/runs/45428347806) had cancelled jobs. Reruns were initiated: software-core job `138652190796` is IN_PROGRESS; board-functional job `138652132132` is IN_PROGRESS. Uncovered RTL job `138652135885` remains CANCELLED; its rerun request was rejected while the workflow run was active and must be retried once the active attempt finishes. Do not count any of these as pass.
- Updated the quick-start resume and master task register to reflect the verified A01 pass, A04 synthesis failure and root cause, flow correction, subsystem matrix counts, active reruns and remaining tasks. This tracker entry completes the three-document update for this work session; re-fetch all three documents and verify their resulting commit/blob SHAs.
- Remaining priority order: find/inspect the PPA run from flow commit `0b67e65...`; retrieve software and board rerun outcomes; rerun uncovered RTL; classify the one subsystem skip and recover the RTL-tail count; implement A02/A03; close A05–A09, A11 and A12; then run A10 on one immutable SHA. H01–H12 manufacturer/physical tasks remain external or hardware-blocked. No paid resources used. The project is not yet simulation-ready for manufacturer feasibility review, fabrication or a production board.


## 110. Add expanded four-DIMM AXI burst coverage and four-port host/accelerator contention bench (2026-11-24)

- Current feature-branch code checkpoint for this work: `141dd7857cdd76d405698e1d3dc3a61a8cdb64e0`; main independently remains at `d84db55712aba0d40811d7762cb052f05d55b7e5`. The subsequent resume/register/tracker documentation commits are feature-branch-only.
- **A02 testbench extension:** `sim/verilator/tb_asic_wg8_ddr4.sv` was extended in commit `76f3a5ecffdef73db2eb298bf775552c5f801c12` to test host write/read bursts of 1, 2, 4 and 8 512-bit beats on the four independent DIMM ports. It checks AWLEN/ARLEN, each W/R data beat, WLAST/RLAST, full/partial/zero WSTRB, per-port backpressure, and an 8-beat legal burst ending exactly at a 4-KiB boundary. DIMM0 deliberately presents WVALID before AWVALID and checks that no W handshake occurs until the AW is queued. Source review caught a scoreboard issue: controller W may be accepted before controller AW, so resetting the W beat counter on AW handshake would corrupt the scoreboard. Correction commit `141dd7857cdd76d405698e1d3dc3a61a8cdb64e0` removes that reset; W beat count now starts at reset and clears after the B response. This is a testbench-only change.
- **A03 contention bench:** new `sim/verilator/tb_asic_wg8_hmux_contention.sv` created in commit `62c319e5eed8f902e10ceb01c7c84b2eaad9d564`. It instantiates four copies of the exact `otpu_mig_hmux` production configuration (IDW=4, AW=34, HB=2). For each DIMM, host and accelerator-pair sources concurrently issue two AW and two AR requests each; the scoreboard expects alternating host/pair grants (H, P, H, P), verifies four two-beat W transactions in AW order, checks B routing by BID and R routing/data/last by RID, and applies independent controller, host and pair backpressure.
- Workflow commit `e0fa44d99a4ba598881f6960a2196f6752550fea` adds the contention bench to the ASIC/config path filter, adds a Verilator compile/run step after the full-top host-path simulation, and archives the build log. The subsequent exact-SHA ASIC/config Run [45453266347](https://github.com/shamiursunny/openTPU/actions/runs/45453266347) is queued on `141dd7857cdd76d405698e1d3dc3a61a8cdb64e0` and includes both A02 and A03 testbenches. **No A02/A03 pass is claimed yet; inspect the job steps and full log once complete.**
- Corrected-flow PPA Run [45452183549](https://github.com/shamiursunny/openTPU/actions/runs/45452183549) remains IN_PROGRESS on flow SHA `0b67e65deb7fcc457b10bb825304db752689b3e7`. Its latest observed steps show the ORFS image pin succeeded and the main ORFS/Yosys flow is running. No PPA metric is yet available.
- Board-functional rerun job `138652132132` and software-core rerun job `138652190796` were still IN_PROGRESS at the last check. Uncovered RTL job `138652135885` remains CANCELLED and needs a retry after its workflow run is idle. Do not count any of these as pass.
- Updated the resume and master register to mark A02/A03 IN PROGRESS (testbenches committed, CI pending), record the exact run IDs/SHAs and update the PPA rerun status. This tracker entry records the corresponding chronology and current evidence boundary.
- Next: inspect Run 45453266347 for A02/A03; correct only evidence-backed testbench or RTL defects; inspect Run 45452183549 for synthesis completion and ORFS reports; retrieve A07/A08 reruns; rerun A09; classify A06's one skip; recover RTL-tail count; continue A05/A11/A12 and then A10 on one immutable SHA. No paid services used. Physical/manufacturer tasks H01–H12 remain external/hardware-blocked; project is not yet ready for manufacturer handoff or fabrication.


## 111. De-duplicate lint sources, split false-positive combinational cones and expose warning/skip evidence (2026-11-24)

- Code checkpoint before the workflow/documentation updates: feature branch SHA `487fe6b93a83e4b86e5565b80de9b7f33c407436`. The subsequent CI-observability workflow commits are `ec151e9180c902c2157d84fb626121a4b81c8c1e` (subsystem pytest skip reporting), `1103498f9d1222ee897a510dfcf912a59fe39301` (full-chip lint warnings exposed), and `86bc7b57202bf4d91ea9ed7f8657db0bebb2b413` (ASIC/config width warnings exposed). Main was last independently verified at `d84db55712aba0d40811d7762cb052f05d55b7e5`; verify again before the next session.
- **MODDUP source-list diagnosis/fix:** the A01 artifact showed Verilator compiling `rtl/mem/otpu_native_dram.sv` twice because the same file was supplied through target/flow source lists and explicit additions. ASIC/config workflow commit `4e26612323f1067acdf360ec6a556a339bab89cd` normalises all source paths with `Path.resolve()` and de-duplicates while preserving order in each integrated lint/simulation source list. This changes only source enumeration, not RTL.
- **UNOPTFLAT cone 1:** Verilator reported `otpu_slice.rpl_frz` through `rq_t`, TMEM request selection and `tm_bx`. Source review found `rpl_frz` and `rpl_hold` were independent outputs assigned in one `always_comb` block; `rpl_hold` uses `tm_bx`, while `rpl_frz` uses the registered `tm_frz` signal. Split them into separate combinational processes without changing expressions in commit `71496cc3d237458ff83806293d73a43de7307922`.
- **UNOPTFLAT cone 2:** `cgl_m` and `gnt_m` were assigned in one `always_comb` process; `gnt_m[G_COLL]` depends on the top-level `coll_gnt`, but `cgl_m=aok[G_COLL]` does not. Split the local-availability assignment from the grant-selection process in the same commit `71496cc3d237458ff83806293d73a43de7307922`, so Verilator can distinguish the independent dependency cones.
- **UNOPTFLAT cone 3:** `otpu_tmem.pq` guest ports referenced `pq[SH_HOST]` through the same packed array, causing Verilator to report an aggregate self-dependency. Added a standalone `pq_host` data vector; the host port drives it and shared guests alias that vector. This is intended to preserve the existing host-data selection and avoid packed-array self-reference. Change is in `rtl/mem/otpu_tmem.sv`, commit `487fe6b93a83e4b86e5565b80de9b7f33c407436`. **These warning fixes are hypotheses until exact-SHA lint/regression logs confirm them.**
- **Warning visibility:** full-chip lint previously suppressed WIDTHEXPAND/WIDTHTRUNC and unused warnings. Workflow commit `1103498f9d1222ee897a510dfcf912a59fe39301` removes those suppressions (retains `-Wno-fatal`, so warnings remain visible but nonfatal). ASIC/config workflow commit `86bc7b57202bf4d91ea9ed7f8657db0bebb2b413` removes WIDTHEXPAND/WIDTHTRUNC suppression from the integrated WG8 lint step. The existing earlier chip/memory lint stages already emitted these width warnings. The next logs must establish warning counts and whether any width warnings are functionally significant; no blanket cast or waiver is justified.
- **Skip observability:** subsystem workflow commit `ec151e9180c902c2157d84fb626121a4b81c8c1e` changes pytest invocation to `pytest -q -rs`, so skipped test reasons are included in logs. Latest matrix Run [45454026458](https://github.com/shamiursunny/openTPU/actions/runs/45454026458) is queued on that workflow SHA and includes RTL from the prior `487fe6b...` checkpoint.
- **Exact-SHA verification queued:** full-chip lint Run [45454034285](https://github.com/shamiursunny/openTPU/actions/runs/45454034285) on SHA `1103498f9d1222ee897a510dfcf912a59fe39301`; ASIC/config Run [45454051576](https://github.com/shamiursunny/openTPU/actions/runs/45454051576) on SHA `86bc7b57202bf4d91ea9ed7f8657db0bebb2b413`; subsystem Run [45454026458](https://github.com/shamiursunny/openTPU/actions/runs/45454026458) on SHA `ec151e9180c902c2157d84fb626121a4b81c8c1e`. Do not mark A11 closed or classify A06's skip until logs/artifacts are retrieved.
- Latest ASIC/config Run 45454051576 also includes the A02 expanded 1/2/4/8-beat host-burst bench and A03 four-instance host/accelerator contention bench. Latest-code PPA Run [45453893320](https://github.com/shamiursunny/openTPU/actions/runs/45453893320), board/uncovered Run [45453893567](https://github.com/shamiursunny/openTPU/actions/runs/45453893567), software Run [45453893300](https://github.com/shamiursunny/openTPU/actions/runs/45453893300), RTL-tail Run [45453893412](https://github.com/shamiursunny/openTPU/actions/runs/45453893412), and isolated TMEM Run [45453893495](https://github.com/shamiursunny/openTPU/actions/runs/45453893495) are queued on the `487fe6b...` RTL checkpoint. Corrected-flow PPA Run 45452183549 remains in progress on SHA `0b67e65...`; earlier software/board retries 138652190796 / 138652132132 remain in progress on SHA `ec0fe832...`. All statuses must be polled; queued/in-progress is not pass.
- Updated the resume and master register with the A11 diagnosis, exact commits, latest run IDs and the new warning/skip visibility. This entry records the chronological evidence. Re-fetch all three project documents and verify their blob SHAs before finishing the session.
- Next: inspect runs 45454051576, 45454034285 and 45454026458; verify A02/A03, lint loop cleanup and skip reasons; inspect PPA run 45453893320 and earlier 45452183549; retrieve A07/A08/A09/RTL-tail results; classify and fix only evidence-backed width warnings; continue A12 formal protocol properties and A10 immutable full regression. Manufacturer, PDK, physical design, DFT, package, board and silicon work remain external/hardware-blocked. No paid services used.


## 112. Add reusable HMUX AXI protocol assertions and enable them in the contention bench (2026-11-24)

- Added an `HMUX_FORMAL` assertion block to `rtl/boards/bcu1525/otpu_mig_hmux.sv` in commit `fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc`. Assertions cover:
  - controller AW/W/AR payload stability while VALID is stalled by READY low;
  - host/pair B and R response stability while the selected requester is not ready;
  - mutual exclusion of host and pair AWREADY, ARREADY and WREADY;
  - WREADY remains low while the write-order FIFO has no queued AW owner;
  - B and R response routing is mutually exclusive and follows the configured host-ID bit.
- Updated the A03 Verilator command to define `HMUX_FORMAL` while retaining `--assert`; workflow commit `bce7d311eb7c4d3ed0768ea27317c5ecf424cb00`. This causes the properties to execute in the four-instance host/accelerator contention bench. The assertions are also written in a form a formal frontend can consume if the module is compiled with `HMUX_FORMAL`.
- Latest assertion-enabled ASIC/config Run [45454398831](https://github.com/shamiursunny/openTPU/actions/runs/45454398831), job `138659833750`, exact SHA `bce7d311eb7c4d3ed0768ea27317c5ecf424cb00`, is QUEUED at this checkpoint. It includes A02 multi-beat host traffic, A03 four-DIMM contention and HMUX assertions. **No pass is claimed until the run completes and its logs are inspected.**
- The latest full-chip lint Run [45454389561](https://github.com/shamiursunny/openTPU/actions/runs/45454389561), job `138659795981`, is QUEUED on SHA `fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc`. Latest PPA Run [45454389335](https://github.com/shamiursunny/openTPU/actions/runs/45454389335), job `138659794535`, is QUEUED on the same SHA. Older corrected-flow PPA Run 45452183549 remains IN_PROGRESS on SHA `0b67e65...`.
- These properties are assertion-enabled simulation, not a formal proof. A formal harness, assumptions/constraints, cover properties and SMT proof results remain unimplemented. Keep A12 PARTIAL until a real formal proof is completed; the properties must not be described as proof or signoff.
- Updated the master register and quick-start resume to include the property list, exact commits, latest run IDs and the remaining formal-proof boundary. This tracker entry preserves the chronological detail.
- Next: poll Run 45454398831; correct any compile/property failures from the actual log; inspect full-chip lint Run 45454389561 and PPA Run 45454389335; retrieve subsystem skip reasons from Run 45454026458 and A07/A08/A09/RTL-tail results. Continue width warning triage and build a separate formal harness if the open-source formal toolchain is available without cost. No paid services used.


## 113. Add AXI response-code propagation and negative 8-GiB aperture checks (2026-11-24)

- Extended `sim/verilator/tb_asic_wg8_ddr4.sv` in commit `4a2dd86b6b7f61b96d8cb0f2e5d5e573c85349e9`. The four-DIMM normal simulation now drives all four AXI BRESP encodings across the four DIMMs and all four RRESP encodings across read beats; the host scoreboard checks that each response code is preserved. This supplements the earlier 1/2/4/8-beat burst lengths, W-before-AW, full/partial/zero strobes, WLAST/RLAST, independent backpressure and legal 4-KiB-boundary-aligned 8-beat burst.
- The same bench adds plusargs `+bad_aw` and `+bad_ar`. Each drives host address bit 33 while VALID is asserted after the relevant DIMM reset synchroniser releases. The existing top-level simulation guard in `rtl/asic/otpu_asic_wg8_ddr4_top.sv` must terminate with exact message `WG8 host DMA address exceeds 8-GiB DIMM aperture`; if it does not, the testbench deliberately fails. No RTL guard change was made.
- ASIC/config workflow commit `66c676cf515e2063c6f322cd1912c94f07ec085c` now runs the normal simulation and then both expected-fatal simulations, requiring nonzero exit and the exact guard message for each. Latest Run [45454747313](https://github.com/shamiursunny/openTPU/actions/runs/45454747313), job `138661055013` (retrieve actual job ID from the run), is QUEUED on exact SHA `66c676cf515e2063c6f322cd1912c94f07ec085c`. It also includes the A03 four-instance contention bench and `HMUX_FORMAL` assertions. **No A02/A03 pass is claimed yet.**
- The master register and project resume were updated to reflect the new test coverage, exact commit, run ID and outstanding cases. The three project-control documents must be re-fetched and their final blob SHAs verified after this tracker append.
- Remaining A02 cases include more ID/outstanding ordering, reset-in-flight and negative protocol cases; A03 remains open until the contention bench and assertion block pass. A12 remains PARTIAL until a formal harness and SMT proof are executed. Next action is to retrieve Run 45454747313, inspect the full normal and negative-case logs, and correct any evidence-backed failure without weakening the checks.


## 114. Define the evidence-based commercial profitability and power-envelope model (2026-11-24)

- Added `docs/sunnyone/SUNNYONE_AI-X_COMMERCIAL_PROFITABILITY_MEASUREMENT_MODEL.md` in commit `e5ce730e49223d0aa98ba14f5f951d02c76e27cd`. It defines workload qualification, useful throughput/latency/quality metrics, full-system wall-power and thermal measurement, complete TCO categories, contribution margin, simple payback, NPV, risk/sensitivity analysis and a decision rule for selecting the power envelope.
- The current objective is to maximise risk-adjusted long-term net profit and realistic investment recovery, not to maximise peak TOPS or watts. No fixed 30 W system cap is used. Higher power is justified only if measured incremental useful throughput and contribution margin outweigh incremental capital, electricity, cooling, reliability and thermal costs.
- The document deliberately contains no invented performance, power, unit-cost, yield, NRE, demand, pricing or ROI values. The current Nangate45 flow is a research proxy; simulation cannot establish production-process PPA, silicon power, manufacturing yield or commercial unit cost.
- Master register H12 is now IN PROGRESS (framework defined; numeric model blocked on evidence) in commit `6535aa5704f2dab28b3fc211d15f34742864e4c4`. The quick-start resume was updated in commit `9f6b76fa1dc92fe28d33454881e9ec81bbf50993`. This tracker entry records the framework and remaining evidence boundary.
- Required inputs before a numeric decision: successful reproducible synthesis/physical PPA, board-level accepted workload throughput/latency/power/thermal measurements, manufacturer NRE/die/yield/package/test/board/MOQ quotations, validated software and quality results, and sourced demand/pricing/utilisation assumptions.
- Next: keep H12 numeric economics open until these inputs exist; do not recommend a wattage or claim a payback period from unmeasured assumptions. Continue A02/A03 CI, A04/A05 PPA, A06–A09 regressions, A11 warning triage, A12 formal proof, and scoped H05/H06 interface design. No spending authorised.


## 115. Document source-derived host DMA contract and 32-GiB global DIMM mapping (2026-11-24)

- Added `docs/sunnyone/SUNNYONE_AI-X_HOST_DMA_AND_GLOBAL_ADDRESS_MAP_SPEC.md` in commit `faa0a0d6908b33b583889d98d8359ab2e05232c2`; corrected two hexadecimal boundary examples in commit `ada74f70f5e6cf161312f8555b78362d6a3d4e83` after independently checking the 4-GiB and 8-GiB values. The corrected examples use 4 GiB = `0x100000000`, 8 GiB = `0x200000000`, and 24 GiB = `0x600000000`.
- The V1 address map is source-derived, not guessed. `otpu_asic_wg8_ddr4_top.sv` uses `CL=CAW+clog2(CB)=32`, `NC=2`, `BHW=0`; `otpu_mig_pair.sv` maps channel byte (o) and channel (s) to DIMM byte `{o[31:12],s,o[11:0]}`; `otpu_fpga_top_bcu_wg.sv` uses `DL=33) for an 8-GiB per-DIMM DMA window and implements `remap(a)={a[31:12],a[32],a[11:0]}`. Thus for a 35-bit device-global address (G), DIMM (d=G[34:33]), channel (s=G[32]), channel offset (o=G[31:0]), and local DIMM address `{G[31:12],G[32],G[11:0]}`. The existing ASIC top exposes four local host ports and does not implement this global DMA/remap block.
- The specification records the host AXI contract (four 512-bit ports, 34-bit local address with bit 33 guard, 8-bit burst lengths, 64-bit strobes, 2-bit responses, fixed host ID 4 for HB=2), DMA descriptor/completion requirements, 4-KiB/8-GiB burst splitting, physical DIMM slot permutation, IOMMU/security, reset/error behaviour and verification requirements. It does not freeze a descriptor ABI, PCIe generation/width, register map or licensed IP.
- Master register H05/H06 were moved from NOT STARTED to IN PROGRESS (specification candidate only) in commit `dfcd964a7b1d43c76e13d7aaded90b3d7fb0c55c`; resume updated in commit `2d8cd4766470ec666dbb78e39e5f94d2a4181617`. DMA RTL, PCIe/DMA IP selection, global remap RTL, software driver, physical DIMM mapping and end-to-end/formal verification remain open.
- No global mapping test is claimed. The current A02 tests exercise DIMM-local host ports and bit-33 rejection only; they do not instantiate the missing global address translation. No paid IP or hardware is authorised.
- Next: decide whether to implement a small synthesizable global-to-DIMM address decoder and boundary-splitting testbench before manufacturer review, or leave it as an explicit external DMA contract. Any implementation must use the source-derived mapping above and prove bijection and boundary correctness.


## 116. Implement and test the source-derived global-to-DIMM address decoder (2026-11-24)

- Added standalone combinational RTL `rtl/asic/otpu_asic_global_addr_map.sv` in commit `dc34e3a51c27c01af6296015cd206ab8336d6bda`. It accepts a 64-bit device-relative address, rejects nonzero bits [63:35], decodes DIMM from [34:33], and emits the 34-bit DIMM-local address `{1'b0,G[31:12],G[32],G[11:0]}`. The output valid/error signals are qualified by request_valid. It is a decoder only, not a DMA engine, burst splitter, crossbar, PCIe BAR decoder or IOMMU.
- Added standalone testbench `sim/verilator/tb_asic_global_addr_map.sv` in commit `8cca146b25636135caa5a7f5e833745f1231eda3`; corrected the DIMM3 channel-base comment/test vector in commit `ebfaf87172d8457c8958bc57a519e981e91b99ab`. It checks 4 DIMM bases, 8 channel bases, 4-KiB boundary offsets, 4-GiB channel boundaries, the 32-GiB last byte and first invalid byte, high 64-bit address rejection, low-12-bit preservation and inverse reconstruction for representative offsets across every DIMM/channel.
- Independent arithmetic check caught and corrected the example for 24 GiB: `0x600000000` is DIMM3 channel0, while `0x700000000` is DIMM3 channel1. The spec table and testbench now distinguish them. This is an explicit QA correction, not a DUT failure.
- ASIC/config workflow commit `d3a75fd673e0df07d0a952e06ce737211f535850` adds a dedicated Verilator build/run with its own `obj_dir_global_addr_map` and archives the build log. Run [45455874266](https://github.com/shamiursunny/openTPU/actions/runs/45455874266) is QUEUED on exact SHA `d3a75fd673e0df07d0a952e06ce737211f535850`; no pass is claimed until its log is inspected.
- Master H06 row now records the standalone decoder/testbench and open integration boundary (commit `ca6f545eac123a429cd192dee9699d1e68c63e2e`); resume updated in commit `2a33f1edb345ce0093c4438fe23cc7aaf89c3b53`. The source-derived map specification is `docs/sunnyone/SUNNYONE_AI-X_HOST_DMA_AND_GLOBAL_ADDRESS_MAP_SPEC.md`.
- H06 remains IN PROGRESS: the decoder is not integrated into the ASIC top or a DMA engine, and no global AXI routing, burst splitting, PCIe BAR/IOMMU, physical DIMM permutation, end-to-end simulation or formal proof exists. H05 remains an interface specification only. No PCIe IP or paid resource is selected or authorised.
- Next: retrieve Run 45455874266 and verify the mapping bench. If it passes, retain H06 as a verified standalone mapping block only; then decide whether to build a multi-port burst-splitting DMA front-end or leave that integration to the selected manufacturer. Do not label the whole host DMA path complete.


## 117. Add a combinational SAT proof harness for the global DIMM address decoder (2026-11-24)

- Added `formal/otpu_asic_global_addr_map_formal.sv` in commit `55ffc66283b7b88c5ea21995cb6c7eff54faa3c4`. It treats the 64-bit global address and request-valid as arbitrary constants and asserts the complete combinational contract: inactive requests produce zero outputs; addresses with any bit [63:35] set are rejected; all addresses in the 32-GiB aperture are accepted; DIMM decode equals [34:33]; local address equals `{1'b0,G[31:12],G[32],G[11:0]}`; local guard bit 33 is zero; and inverse reconstruction exactly recovers every valid 35-bit global address.
- Added `.github/workflows/sunnyone-address-map-formal.yml` in commit `714db2c60f64907fc2ff45208e2fd92e592d449d`. It downloads the pinned YosysHQ OSS CAD Suite 2026-11-23 archive, verifies SHA256 `c01d93f2f9091ba7eeb18540334fa0aaefa843b343cbdd627fd7669391de47ba`, and runs `read_verilog -formal -sv; prep -top ... -flatten; sat -prove-asserts -verify -show-ports`. It archives the formal log.
- Formal Run [45456060346](https://github.com/shamiursunny/openTPU/actions/runs/45456060346) is QUEUED on exact SHA `714db2c60f64907fc2ff45208e2fd92e592d449d`. This is a combinational proof attempt, not a pass; retrieve the Yosys log and require successful `sat` proof before claiming H06 formal verification.
- The standalone Verilator simulation for the same decoder is in ASIC/config Run [45455874266](https://github.com/shamiursunny/openTPU/actions/runs/45455874266), QUEUED on SHA `d3a75fd673e0df07d0a952e06ce737211f535850`. It covers DIMM/channel boundaries, 4-KiB offset preservation, representative inverse bijection, 32-GiB boundary and invalid high addresses.
- Master H06 row updated in commit `92cf3a60735735a0e3472d44b1a16549258a2b3e`; resume updated in commits `6bd187a7acc869ba472339407e4fdd6e75fc7391` and `3b96c461b12426e34b87430fcfea731c837bd72a` (latest code checkpoint recorded as `714db2c60f64907fc2ff45208e2fd92e592d449d`). H06 remains IN PROGRESS; decoder is not integrated into a DMA engine or ASIC top, and end-to-end burst splitting/routing/physical DIMM mapping remain open.
- Host DMA/global map specification updated to link the formal harness and state the pending proof boundary in commit `62ea81082e66d3b8096109190df09e640564ad66`.
- Next: poll Runs 45456060346 and 45455874266, inspect full logs/artifacts, fix any formal/simulation failure from evidence, then decide whether to implement the global AXI DMA router or keep that subsystem with the manufacturer. No paid services used.


## 118. Diagnose and correct the first global-map SAT workflow failure (2026-11-24)

- Retrieved the full log for formal Run [45456060346](https://github.com/shamiursunny/openTPU/actions/runs/45456060346), job `138665682328`, exact SHA `714db2c60f64907fc2ff45208e2fd92e592d449d`. Yosys 0.71+77 successfully parsed the DUT and harness, elaborated 14 formal checks and found no structural problems, but the SAT pass failed with `ERROR: No SAT model available for cell ... ($check)`. This is a formal-cell lowering/selection issue in the proof script, not evidence of an address-map counterexample and not a pass.
- Attempted a workflow correction in commit `9c550d41ff00a6521cf551f6ab1b08b5f87263f5` by adding `chformal -assert` after `prep`; this was incomplete because `-assert` selects a cell type but does not provide the required lowering mode. Run 45456545394 later failed with `ERROR: Mode option is missing`; see entry 120.
- Rerun [45456545394](https://github.com/shamiursunny/openTPU/actions/runs/45456545394), job `138667425966`, exact SHA `9c550d41ff00a6521cf551f6ab1b08b5f87263f5`, completed with `ERROR: Mode option is missing` and is superseded. The corrected `chformal -lower` run is 45457143624 on SHA `0d6128...`.
- Updated master H06 row in commit `1ab99c9149d6f729e9a4bb865a77d573f789b53e`, resume in commit `7bd2e4b5d77dbde9de0562e2380d86efb3a62689`, and the host DMA/address-map spec in commit `a34265b21ff8ecbffcdcd7abb81e8e1ac5c2b4ff`. The tracker records the chronological diagnosis and correction.
- The standalone Verilator address-map test Run 45455874266 remains queued; no simulation pass is claimed. H06 remains IN PROGRESS, with global DMA integration and end-to-end address routing still open.
- Next: poll formal Run 45457143624 and simulation Run 45455874266; if SAT still fails, inspect the exact new Yosys error and adjust the proof script/harness only. Do not reinterpret a frontend or solver failure as a DUT failure or proof. No paid resources used.


## 119. Consolidate latest ASIC/config verification of AXI, contention and global map benches (2026-11-24)

- The ASIC/config workflow now includes the four-DIMM multi-beat host test with all BRESP/RRESP codes and expected-fatal address-bit-33 cases, the four-instance HMUX contention test with `HMUX_FORMAL` assertions, and the standalone global-to-DIMM address-map boundary/bijection test.
- Consolidated run [45455874266](https://github.com/shamiursunny/openTPU/actions/runs/45455874266), job `138665030882`, exact SHA `d3a75fd673e0df07d0a952e06ce737211f535850`, is QUEUED at this checkpoint. It is the latest single run containing all three test groups. No simulation/assertion pass is claimed until the job completes and the complete logs are inspected.
- Master register A02/A03 rows updated in commit `185d50f364d3196b9f20748ef1c16b0bf95df553`; resume updated in commits `5795b584aa2fd53722da28dde63e472a2563171f` and `12596547e662d1b6f51df26d4e9c3a00fbe500bb` (latest code/CI checkpoint recorded as `9c550d41ff00a6521cf551f6ab1b08b5f87263f5`). H06 also tracks this run for its standalone map simulation. The separate formal proof rerun remains Run 45456545394 on SHA `9c550d...`.
- Next: retrieve the consolidated run's complete step logs and artifacts; verify normal four-DIMM traffic, expected-fatal AW/AR, all response codes, HMUX SVA assertions and the global address map. If any step fails, diagnose the first actual error and make only an evidence-led correction. Keep A02/A03/H06 open until then.


## 120. Correct Yosys formal-cell conversion command for global-map SAT proof (2026-11-24)

- The first formal attempt Run [45456060346](https://github.com/shamiursunny/openTPU/actions/runs/45456060346) failed at the SAT pass because the Verilog frontend emitted `$check` cells. Yosys' command reference identifies `chformal -lower` as the mode that converts `$check` cells into `$assert`/`$assume`/`$cover` cells; `-assert` alone is a type selector, not the lowering mode. Reference: YosysHQ `chformal` implementation/help, https://github.com/YosysHQ/yosys/blob/main/passes/cmds/chformal.cc.
- The intermediate workflow commit `9c550d41ff00a6521cf551f6ab1b08b5f87263f5` used the incomplete `chformal -assert` command. Run [45456545394](https://github.com/shamiursunny/openTPU/actions/runs/45456545394) completed with `ERROR: Mode option is missing`; it is superseded and must not be counted as a valid proof attempt.
- Corrected workflow commit `0d6128d21c086d52e0c6ca3a10bfe4f2666dcccb` changes the sequence to `prep -top ... -flatten; chformal -lower; sat -prove-asserts -verify -show-ports`. Formal Run [45457143624](https://github.com/shamiursunny/openTPU/actions/runs/45457143624), job `138669549822`, completed SUCCESS on that exact SHA. The complete log confirms 14 assertions imported into SAT, 813 variables, 2,152 clauses, and `SAT proof finished - no model found: SUCCESS!`; the Yosys `$check` cells were present in pre-lowering statistics and the `chformal -lower` sequence allowed the SAT proof to run. This closes only the selected combinational global-address-map formal properties, not the full accelerator or memory subsystem.
- Master H06 row initially updated in commit `2c833a70726a5f9b989d570bb8cd3ffe98ad3588`, status refined in `e3615450ca1516ea5606a942efaec5b5c447caf9`, and intermediate-run failure recorded in `aecb4a1efd0e96375119c8f7a0c3d5be39897dec`; resume updated in commits `b606da10f03c76d703867456dfea7f96eabb7395` and `d0996b1034187bfa4f684750bd56950ef0d63f7e`; address-map specification updated in commits `5be588d3fe7b50b0b532d59ea03bd8f7fdd9dab3` and `a044cab6df3cc8a9ac30b72258763b1ac08c38c8`.
- Next: retrieve Run 45457143624's full log. Confirm that `chformal -lower` removes all `$check` cells and the SAT proof returns success; if it fails, diagnose the exact solver/property issue. Do not call either earlier attempt a proof.


## 121. Reconcile subsystem matrix and classify the 64-GiB address-window skip (2026-11-24)

- Retrieved all 14 job logs for subsystem Run [45425750683](https://github.com/shamiursunny/openTPU/actions/runs/45425750683), exact SHA `b41669fe1d67a3f7dcb84d86a960cdb4b9167ad8`. Every job completed successfully. Per-job pytest summaries aggregate to **377 passed, 1 skipped, 0 failed**.
- The one skip is in the Address-window RTL job `138557140536`, `tests/test_aw_rtl.py::test_beyond_the_dram_stops_the_board_model`: pytest reports `64 GiB: every address is DRAM`. Source lines 617–626 explain the geometry: at 32 GiB, DRAM_LOG2 35 is below AW 36, so a store at bit 35 is beyond the channels and the board model is expected to stop; at 64 GiB the full (2^{AW}) address space is DRAM, so this specific “beyond DRAM” test is not applicable. The explicit skip is correct and must not be removed or suppressed. Source: [tests/test_aw_rtl.py at SHA b41669fe](https://github.com/shamiursunny/openTPU/blob/b41669fe1d67a3f7dcb84d86a960cdb4b9167ad8/tests/test_aw_rtl.py#L617-L626).
- Confirmed the same explicit skip condition exists at SHA `ec0fe8329df06e5204a1c082df133b62b434846b`. The later Run 45428347703 on that SHA had 374 passed, 1 skipped, 0 failed. The latest matrix Run [45454026458](https://github.com/shamiursunny/openTPU/actions/runs/45454026458) on SHA `ec151e...` adds pytest `-rs` and remains queued to capture the current skip summary.
- Master A06 row updated in commit `e8cb2c4cf3a713a3ff6d01ab961748bd5cdb9bf4`; resume updated in commit `fb2ee10523bf05238a8fcb0912c2a2468c441926`. A06 remains PARTIAL pending the newer exact-SHA matrix and complete regression.
- Next: retrieve Run 45454026458; compare its test counts and skip reason with this baseline. Any changed skip must be inspected against the exact test source and geometry; do not assume it is the same.


## 122. Reconcile older board/software/RTL regression attempts (2026-11-24)

- Queried exact job states for older diagnostic and retry runs. On SHA `ec0fe8329df06e5204a1c082df133b62b434846b`, A07 software-core job `138652190796` (Run 45428347706) remains IN_PROGRESS; A08 board-functional job `138652132132` (Run 45428347806) remains IN_PROGRESS; A09 uncovered RTL job `138652135885` in the same run was CANCELLED.
- Older run 45425750779 on SHA `b41669fe1d67a3f7dcb84d86a960cdb4b9167ad8` was CANCELLED (software-core job `138557139611`). Older board/uncovered run 45425750624 on the same SHA was CANCELLED (jobs `138557141647` and `138557142665`). These cancellations are not passes.
- Latest code attempts on SHA `487fe6b93a83e4b86e5565b80de9b7f33c407436`: A07 Run 45453893300 / job `138658009331` is IN_PROGRESS; A08/A09 Run 45453893567 / jobs `138658011213` and `138658011921` are QUEUED. RTL-tail Run 45453893412 / job `138658011365` remains QUEUED.
- A prior RTL-tail run 45425750818 on SHA `b41669fe...` completed successfully, but it does not replace the latest exact-SHA RTL-tail run. A prior subsystem run 45425750683 completed 14/14 jobs and is documented in entry 121.
- Resume updated with exact old/latest states in commit `bad2efd093d4a2b43bed9f6a9a062c34729f0d9e`, then clarified the stable code/CI checkpoint and requirement to verify live branch HEAD in commit `a016155655f4db4e52bbf91beea4c24c1224337d`. Master A07–A09 statuses remain IN PROGRESS; A07 latest run status corrected to IN_PROGRESS in master commit `62506921dcd10ee346a6bb171492adf83273d11b`; no release gate is closed from a queued, cancelled or stale-SHA result.
- Next: retrieve final logs for the in-progress jobs, then the latest queued A07–A09/RTL-tail jobs when they start. Keep results separated by exact commit SHA.


## 123. Formal address-map proof closed; diagnose four-DIMM HMUX write-path stall (2026-11-25)

- Formal Run [45457143624](https://github.com/shamiursunny/openTPU/actions/runs/45457143624), exact source/workflow SHA `0d6128d21c086d52e0c6ca3a10bfe4f2666dcccb`, completed successfully. Job `138669549822`; Yosys 0.71+77; 14 assertions imported into SAT; 813 variables and 2,152 clauses; terminal output `SAT proof finished - no model found: SUCCESS!`. The corrected `chformal -lower` step converted the frontend's formal check cells into SAT-provable assertions. Scope is the combinational global-to-DIMM address map only.
- Re-polled the pending exact-SHA workflow runs. Consolidated ASIC/config Run [45455874266](https://github.com/shamiursunny/openTPU/actions/runs/45455874266), board/RTL Run [45455823181](https://github.com/shamiursunny/openTPU/actions/runs/45455823181), subsystem Run [45455823102](https://github.com/shamiursunny/openTPU/actions/runs/45455823102), isolated TMEM Run [45455823248](https://github.com/shamiursunny/openTPU/actions/runs/45455823248), RTL-tail Run [45455823151](https://github.com/shamiursunny/openTPU/actions/runs/45455823151), and software Run [45455823111](https://github.com/shamiursunny/openTPU/actions/runs/45455823111) were still queued/in progress at the last poll; no pass is inferred from those states. The PPA Run [45455745851](https://github.com/shamiursunny/openTPU/actions/runs/45455745851) was in progress, but its job-log blob was not yet available.
- To identify why the earlier four-DIMM host test stalled with host WVALID asserted and controller AW/W inactive, added timeout-only hierarchical probes for each of the four `otpu_mig_hmux` instances. Diagnostic testbench commit: `51f3b9bc5d45eeca927a36a1873df3cfd2625d38`. Probes report `aw_go`, `aw_room`, `aw_h`, `aw_last`, `wo_wr`, `wo_rv`, `wo_h`, `w_v` and `w_r`; they do not alter synthesizable RTL.
- Inspection found a malformed escaped timescale directive in `sim/verilator/tb_asic_wg8_hmux_contention.sv` (a literal backslash before the backtick). Corrected it in commit `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f`. Updated the ASIC/config workflow comment to deliberately retrigger the exact-SHA gate; workflow-trigger commit `65f28fc09ede79581ba97845165733d1caef45b1`.
- New ASIC/config Run [45465384680](https://github.com/shamiursunny/openTPU/actions/runs/45465384680), job `138698816300`, is QUEUED on exact SHA `65f28fc09ede79581ba97845165733d1caef45b1`. It must compile/run the corrected four-DIMM integration bench and the four-instance HMUX contention bench. Other runs triggered by the diagnostic/testbench commits also remain pending. Do not count any as passed until exact logs are inspected.
- Current feature-branch HEAD at this update: `65f28fc09ede79581ba97845165733d1caef45b1`. `main` remains protected and untouched. No paid resources or hardware purchases were used.
- Next: poll Run 45465384680 first. If it fails, inspect the first failing workflow step and exact HMUX timeout probes. Make the smallest evidence-led correction; do not modify HMUX RTL merely because WREADY is low until the probes distinguish missing AW-owner enqueue from W-slice backpressure. Then rerun the full four-DIMM simulation and the four-instance contention test on a new exact SHA. Continue with the pending PPA, broad RTL, board, memory, TMEM and software jobs, retaining their independent scope and statuses.


## 124. Verify diagnostic commits, corrected testbench directive and live branch state (2026-11-25)

- The four-DIMM timeout diagnostic-only probe commit is `51f3b9bc5d45eeca927a36a1873df3cfd2625d38`; the corrected four-DIMM HMUX contention testbench directive is `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f`; the ASIC/config workflow retrigger commit is `65f28fc09ede79581ba97845165733d1caef45b1`; and this tracker update is based on the subsequent tracker commit sequence. No synthesizable RTL was changed in these commits.
- Exact-SHA ASIC/config Run [45465384680](https://github.com/shamiursunny/openTPU/actions/runs/45465384680), SHA `65f28fc09ede79581ba97845165733d1caef45b1`, job `138698816300`, remains QUEUED at the latest poll. The diagnostic/testbench-triggered runs [45465123093](https://github.com/shamiursunny/openTPU/actions/runs/45465123093), [45465123016](https://github.com/shamiursunny/openTPU/actions/runs/45465123016), [45465123007](https://github.com/shamiursunny/openTPU/actions/runs/45465123007), [45465123084](https://github.com/shamiursunny/openTPU/actions/runs/45465123084), and [45465123025](https://github.com/shamiursunny/openTPU/actions/runs/45465123025) are also QUEUED. Job logs are not yet available.
- Earlier PPA Run [45455745851](https://github.com/shamiursunny/openTPU/actions/runs/45455745851) (job `138664562707`) and software Run [45455823111](https://github.com/shamiursunny/openTPU/actions/runs/45455823111) (job `138664840765`) remain IN_PROGRESS; their log downloads were not yet available at the last retrieval attempt. Do not infer their outcomes.
- Live refs independently rechecked: feature branch HEAD before this tracker update was `65f28fc09ede79581ba97845165733d1caef45b1`; `main` remains exactly `d84db55712aba0d40811d7762cb052f05d55b7e5`. The tracker update advances only the feature branch. No main-branch changes, paid resources or hardware purchases.
- Continue by polling the exact queued ASIC/config run first, then inspect its complete logs for the four-DIMM normal/negative tests and four-instance HMUX contention assertions. The write-path defect remains undiagnosed until timeout-only HMUX state is produced or the simulation passes. The production blockers in section 7 of the V1 candidate remain external and cannot be closed by RTL-only simulation.


## 125. Isolated one-copy TMEM regression passes; broad ASIC and software gates continue (2026-11-25)

- Isolated experimental 128K one-copy TMEM workflow Run [45465292891](https://github.com/shamiursunny/openTPU/actions/runs/45465292891), job `138698480849`, completed SUCCESS on exact source SHA `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f`. The executed command was `pytest -q tests/test_rtl.py -k one_copy_tmem_of_128k_words`; result: **2 passed, 215 deselected in 78.62s**. This is an isolated experimental TMEM regression only; it does not establish full ASIC SRAM macro feasibility, physical timing, area, or complete integration.
- The same isolated TMEM test also completed SUCCESS on the diagnostic-only SHA `51f3b9bc5d45eeca927a36a1873df3cfd2625d38` in Run [45465123016](https://github.com/shamiursunny/openTPU/actions/runs/45465123016). The later 86f test is the corrected-timescale testbench source checkpoint.
- ASIC/config Run [45465123021](https://github.com/shamiursunny/openTPU/actions/runs/45465123021), job `138697864685`, on SHA `51f3b9bc5d45eeca927a36a1873df3cfd2625d38`, has completed all three integrated ASIC lint steps successfully (control/compute top, native-memory top, four-DIMM AXI top). Its four-DIMM WG8 host AXI simulation is still IN_PROGRESS; global address-map and four-DIMM HMUX contention simulations have not yet run. The current 86f9 regression run is still progressing through the ASIC control lint step.
- Software-core jobs [45465292772](https://github.com/shamiursunny/openTPU/actions/runs/45465292772) and [45465123084](https://github.com/shamiursunny/openTPU/actions/runs/45465123084) remain IN_PROGRESS; no pass inferred. Board-functional and RTL-tail jobs from the earlier exact-SHA batch also remain IN_PROGRESS. The remaining RTL subsystem/tail jobs in the newer batch are queued; no pass inferred.
- Latest run [45465384680](https://github.com/shamiursunny/openTPU/actions/runs/45465384680), SHA `65f28fc09ede79581ba97845165733d1caef45b1`, remains QUEUED. The four-DIMM host-path timeout diagnosis is therefore still open. Log downloads for active jobs currently return BlobNotFound, so no unobserved diagnostic signal values are claimed.
- Preserve the distinction between isolated TMEM success, integrated ASIC lint success, and full four-DIMM functional qualification. Do not infer the latter from the former. No synthesizable RTL changes, hardware purchases, paid services, or main-branch modifications were made in this stage.


## 126. Repository-wide historical CI/test-pass audit and continuation-document synchronisation (2026-11-25)

### Audit method and interpretation

- Queried the GitHub Actions run history for the active feature branch across eight API pages: **705 workflow-run records** were returned. **316 records have conclusion SUCCESS**. These are workflow-run successes, not 314 unique tests: many are retries, repeated runs, workflow-only retriggers, or different commits. Failed, cancelled, queued and in-progress runs are not counted as passes.
- Reconciled representative successful jobs against their actual job logs and pytest summaries. Test counts below are reported only where the job log exposes the count or an explicit PASS marker. Results from different SHAs remain separate; do not add them as a deduplicated lifetime test-case total.
- The audit found that the repository already contains substantially more than 100 successful test executions. The strongest directly reconciled aggregate is the 14-job subsystem/memory matrix below: **377 passed, 1 explicitly justified skip, 0 failed** on one exact SHA. This is not a claim that 377 unique test definitions have been proven across all history.

### Reconciled broad and focused passes

| Area | Run / job | Exact source SHA | Observed result | Scope boundary |
|---|---|---|---|---|
| RTL subsystems + WG8 memory matrix | [45428347703](https://github.com/shamiursunny/openTPU/actions/runs/45428347703), 14 jobs | `ec0fe8329df06e5204a1c082df133b62b434846b` | **377 passed, 1 skipped, 0 failed** across the 14 successful jobs | One intentional address-window skip; not a final immutable release regression |
| RTL-tail selected suite | [45454717008](https://github.com/shamiursunny/openTPU/actions/runs/45454717008), job `138660957221` | `4a2dd86b6b7f61b96d8cb0f2e5d5e573c85349e9` | **33 passed, 1 skipped, 183 deselected** | Selected remaining non-experimental RTL/ISA tests only |
| Isolated one-copy 128K TMEM | [45465292891](https://github.com/shamiursunny/openTPU/actions/runs/45465292891), job `138698480849` | `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f` | **2 passed, 215 deselected**, 78.62 s | Isolated experimental TMEM test only |
| Same isolated TMEM selection | [45465123016](https://github.com/shamiursunny/openTPU/actions/runs/45465123016) | `51f3b9bc5d45eeca927a36a1873df3cfd2625d38` | Workflow SUCCESS; later corrected-timescale run is preferred evidence | Repeated execution, not two new test definitions |
| Yosys+Slang reset audit | [45455745271](https://github.com/shamiursunny/openTPU/actions/runs/45455745271), job `138664561215` | `dc34e3a51c27c01af6296015cd206ab8336d6bda` | **4 passed**, 335.10 s | Selected reset-audit tests, not CDC/RDC signoff |
| Full-chip Verilator lint | [45455745243](https://github.com/shamiursunny/openTPU/actions/runs/45455745243) | `dc34e3a51c27c01af6296015cd206ab8336d6bda` | Workflow/job SUCCESS | Lint only; review warnings and exact log before treating warning closure as complete |
| Four-instance shared-DIMM HMUX simulation | [45454389445](https://github.com/shamiursunny/openTPU/actions/runs/45454389445), job `138659794715` | `fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc` | PASS marker: concurrent host/pair 3-beat AW-W-B and AR-R bursts with response backpressure; 2 write bursts, 6 read beats, 25 cycles | Directed simulation of tested arbitration scenarios; not exhaustive AXI formal proof |
| Virtual DRAM / TMEM behavioural benches | [45453893286](https://github.com/shamiursunny/openTPU/actions/runs/45453893286), job `138658009670` | `487fe6b93a83e4b86e5565b80de9b7f33c407436` | Explicit DRAMTEST, TMEMTEST and TMEM_MULTI PASS markers | Behavioural models and stated scenarios only |
| ASIC AXI-Lite control | [45248945992](https://github.com/shamiursunny/openTPU/actions/runs/45248945992), job `137953086235` | `ae997da8a993e962dd18de0fb1240f3d5656b3a2` | PASS marker for independent AW/W, gating, load pulse, reset and register map | Scoped control-interface bench |
| ASIC global-to-DIMM address-map formal | [45457143624](https://github.com/shamiursunny/openTPU/actions/runs/45457143624), job `138669549822` | `0d6128d21c086d52e0c6ca3a10bfe4f2666dcccb` | Yosys 0.71+77; 14 assertions; 813 variables; 2,152 clauses; terminal SAT SUCCESS | Selected combinational address-map properties only |
| Earlier selected RTL/ISA + AXI-Lite isolation | [45217729099](https://github.com/shamiursunny/openTPU/actions/runs/45217729099), jobs `137843314367` and `137843313719` | `66c708e573671136197c371a848cc9274ae394f2` | **99 passed** in selected RTL/ISA job; **1 passed** in separate AXI-Lite isolation job | Tracker section 9 records that the separate LDC pass duplicated one case within the 99; count as 100 distinct selected cases, not 101 |
| RTL functional smoke | [45074722442](https://github.com/shamiursunny/openTPU/actions/runs/45074722442) | `e97608f5376726b4fcddd005168f959bc9b98aa9` | Workflow SUCCESS | Smoke scope only |
| PCIe Gen2 XDMA bridge simulation | [45239360365](https://github.com/shamiursunny/openTPU/actions/runs/45239360365), job `137919506712` | `161cddbb76cc293bdacdab3af2c7037a984f1c67` | Workflow/job SUCCESS | Simulation of the implemented bridge scope; not a production PCIe endpoint/PHY or compliance claim |
| Isolated workload harness | [45069537101](https://github.com/shamiursunny/openTPU/actions/runs/45069537101) and [45069549439](https://github.com/shamiursunny/openTPU/actions/runs/45069549439) | `749677442edc7e1d560e56b2a3695bd102f5b008`; `87fdc8df265af6dea61dbe0e14671fa91f869c42` | Both workflow runs SUCCESS | Unit/fixture checks only; no real-hardware workload benchmark or measured throughput |

The 14 subsystem matrix job-level pytest summaries were individually inspected and total 377 passed: MX multiply/replay 17; quantizer modes 15; QHL 7; collective hub/DMA/scoreboard 128; floating point 8; wait-state 11; stream 14; quantizer corners/ties 8; instruction cache 23; address-window 20 plus 1 intentional skip; SPLITQ 5; QST/QSTB 13; reset audit 4; native DRAM/technology RAM 104. The totals sum to 377 passed and 1 skipped.

The one address-window skip is the previously documented geometry case `test_beyond_the_dram_stops_the_board_model`: at a 64-GiB aperture every representable address is DRAM, so a test expecting an address beyond DRAM is inapplicable. It is not a concealed failure and must remain explicitly labelled as a skip.

### Workflow-history inventory (run records, not test counts)

Across the 705 returned branch run records, success totals by workflow were: subsystem/memory 16; isolated TMEM 34; RTL-tail 77; global-map formal 1; reset audit 58; full-chip lint 57; shared-DIMM HMUX 13; virtual DRAM 10; ASIC AXI-Lite control 19; PCIe Gen2 bridge 1; RTL functional expansion 20; RTL smoke 1; workload harness 3; workload fixture correction 1; ASIC/config 5. The following workflows had no successful run in the returned history at audit time: remaining RTL/board regressions, software-core, and WG8 ASIC research PPA. Other workflow names include 32 cancelled “additional RTL subsystem regressions”. These workflow-level counts include retries and older SHAs; they are not independent test counts or a green overall pipeline.

### Current verification state after historical audit

- The 128K TMEM isolated test is now green on SHA `86f922cc...`; do not equate it with SRAM macro qualification or full memory integration.
- The global address-map formal proof is green on SHA `0d6128d...`; it proves only the selected combinational decoder properties.
- The four-instance HMUX directed simulation passed on SHA `fc3bdcc...`; the separate four-DIMM host integration/write-path issue remains open until the current diagnostic bench passes or produces actionable probe values.
- The integrated ASIC/config workflow on SHA `51f3b9bc...` completed its three lint stages successfully, but the four-DIMM host simulation was still running at the last confirmed observation. A newer run on SHA `86f922cc...` was still in progress; do not transfer partial lint results across SHAs.
- Current runs requiring fresh polling include ASIC/config `45465384680`, board/RTL `45465292882`, subsystem `45465292903`, software `45465292772`, ASIC/config `45465292665`, RTL-tail `45465292944`, PPA `45455745851`, and other queued/in-progress retries listed in the GitHub Actions history. No queued or in-progress run is a pass.
- The latest known feature-branch code checkpoint before this documentation update was `65f28fc09ede79581ba97845165733d1caef45b1`; the tracker commit sequence then advanced the branch. Verify the live feature branch and `main` refs before further work. Never modify `main`.

### Required future audit/update rule

For each new continuation, query the live Actions history and inspect successful job logs before updating this evidence ledger. Record exact run ID, job ID, source SHA, command/test selection, counts and skip reason. Keep repeated executions separate from unique test definitions. Do not sum test counts across runs as a lifetime unique total unless test identities have been deduplicated. The feature branch remains engineering-in-progress; there is no final all-tests-on-one-release-SHA result, no completed WG8 PPA, no production DDR4/PCIe PHY, no physical signoff, and no silicon or commercial qualification claim.


## 127. Re-poll four-DIMM qualification, expose exact W mismatch, and reconcile live CI (2026-11-25)

- Recovered the live feature branch and confirmed that the current project work remains on `sunnyone/commercial-profitability-architecture-2026-11-23`. The branch HEAD before this diagnostic update was `574cb2c8c41fd747dd7f4c6a9bd41b47bdb7978f`; the main branch was independently compared with pinned baseline `d84db55712aba0d40811d7762cb052f05d55b7e5` and was identical. No main-branch modification was made.
- Exact-SHA ASIC/config Run [45465384680](https://github.com/shamiursunny/openTPU/actions/runs/45465384680), SHA `65f28fc09ede79581ba97845165733d1caef45b1`, job `138698816300`, completed FAILURE. Target/config tests and all three integrated ASIC lint stages passed. The four-DIMM host AXI simulation compiled, then failed at 135 ns on `DIMM2 host W payload/last mismatch beat=0`. The address-map and HMUX contention steps were skipped because the workflow is fail-fast. Artifact [14961526914](https://github.com/shamiursunny/openTPU/actions/runs/45465384680/artifacts/14961526914) contains the configuration logs.
- The preceding ASIC/config Run [45465292665](https://github.com/shamiursunny/openTPU/actions/runs/45465292665), exact SHA `86f922ccdbb8c0a14a3bd7961e48d1618fd17a9f`, job `138698480742`, failed on the same DIMM2 W-channel assertion after the same three integrated lint stages passed. This confirms a repeatable test failure across two source SHAs, not a one-off runner interruption. The original assertion combined WDATA, WSTRB and WLAST, so the specific mismatching field was not yet known.
- Diagnostic-only testbench commit `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a` updates `sim/verilator/tb_asic_wg8_ddr4.sv` to print actual/expected WDATA, WSTRB and WLAST, plus owner-FIFO and W-channel handshake state. No synthesizable RTL was changed. At the first post-commit query, `fetch_commit_workflow_runs` returned no associated run; check again before assuming the push-triggered workflow started. Do not infer a pass or failure for this diagnostic revision until its exact-SHA log exists.
- RTL-tail Run [45465292944](https://github.com/shamiursunny/openTPU/actions/runs/45465292944), job `138698481467`, completed SUCCESS: **33 passed, 1 skipped, 183 deselected**. The skip is `PAIR needs 2M <= MCOLS; M <= ACT_ROWS`, a parameter-inapplicable case. This is a selected RTL-tail suite only.
- At the latest poll, board-functional and uncovered-RTL jobs in Run `45465292882` were still IN_PROGRESS; software-core Run `45465292772` was IN_PROGRESS; all 14 jobs in subsystem Run `45465292903` were QUEUED. Preserve these states as pending, not passes.
- WG8 PPA Run [45454389335](https://github.com/shamiursunny/openTPU/actions/runs/45454389335), exact SHA `fc3bdcc4e36c12014e8f0f83e5f11966013fb2dc`, job `138659794535`, completed FAILURE inside `tools/asic/flow.py run nangate45-wg8` with ORFS exit code 2. The runner log confirms 288 SRAM-probe macro instances across 14 sizes (3,538 KiB inventory) and upload of the 432-MB PPA evidence artifact [14960636530](https://github.com/shamiursunny/openTPU/actions/runs/45454389335/artifacts/14960636530). The detailed ORFS run log still needs inspection to identify the failing stage and root cause; no PPA metric is claimed. A separate older PPA Run `45455745851` / job `138664562707` remained IN_PROGRESS at the latest poll.
- The previous broad subsystem evidence remains valid only for its own SHA: Run `45428347703` reported 377 passed, 1 intentional geometry skip, 0 failed across 14 jobs. The previous four-instance HMUX directed pass and address-map SAT proof also remain scoped to their exact historical SHAs; they do not replace the current failed integrated run.
- Updated next action: inspect the diagnostic W-channel log on the new commit; distinguish data, strobe, last, owner-selection, queue and register-slice handshake. Only after the mismatch is classified should the smallest appropriate testbench or RTL correction be made. Then rerun four-DIMM normal and negative-aperture cases, address-map simulation, and four-instance HMUX contention/assertions on one exact SHA. In parallel, collect final board/software/subsystem results and inspect the PPA artifact's run.log. Keep main untouched, do not weaken tests, and preserve the zero-spend rule.


## 128. Explicit ASIC/config workflow retrigger attempt (2026-11-25)

- After diagnostic commit `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a`, the first commit-workflow lookup returned no associated run.
- Added a comment-only retrigger note to `.github/workflows/sunnyone-asic-config.yml` in commit `597f1b9af961f4e8fcde1ae9fffa013ce6bc7f54`. This does not change workflow commands, RTL, test logic or expected results; it deliberately touches a configured push-trigger path so the ASIC/config workflow can execute against the diagnostic testbench.
- The immediate post-commit workflow lookup still returned an empty run list. This is **not** evidence that the workflow passed, failed or even started. Check GitHub Actions again after the event is visible; if no run appears, record the trigger as unavailable and do not manufacture a run result.
- Branch head at this check: `597f1b9af961f4e8fcde1ae9fffa013ce6bc7f54`. Main remains `d84db55712aba0d40811d7762cb052f05d55b7e5`, 0 commits behind and untouched.
- Next: obtain the diagnostic log for the exact testbench commit, then classify the DIMM2 W mismatch. No synthesizable RTL correction is authorised by the evidence so far.


## 129. Correct latest board/RTL job states after re-poll (2026-11-25)

- A final re-poll of Run `45465292882` shows uncovered-RTL job `138698481369` is now **CANCELLED**, not IN_PROGRESS as recorded in Section 127 at the earlier poll. Board-functional job `138698482005` remains **IN_PROGRESS**.
- Software-core job `138698481416` in Run `45465292772` remains **IN_PROGRESS**.
- All 14 jobs in subsystem/memory Run `45465292903` remain **QUEUED**.
- WG8 PPA job `138664562707` in Run `45455745851` remains **IN_PROGRESS**.
- This correction supersedes only the corresponding earlier status snapshot. No queued or in-progress result is a pass; the cancelled uncovered-RTL job requires a fresh exact-SHA execution.


## 130. Diagnose diagnostic-instrumentation compile failure and correct static hierarchy probes (2026-11-25)

- Recovered the push-triggered ASIC/config run directly from the repository Actions run collection: [45479454587](https://github.com/shamiursunny/openTPU/actions/runs/45479454587), exact SHA `e1f46ee26a47569aa04dfe0cf1b6b204dcc9e21a`, job `138748357284`. This run **FAILED before simulation**, at testbench compilation. Verilator reported variable `d` cannot be used in a dotted hierarchical selection at `tb_asic_wg8_ddr4.sv:129`, and could not resolve `u_hmux` through the variable-indexed generate scope. Therefore this run gives no new evidence about the actual DUT W-channel behavior.
- Root cause: the first diagnostic patch used `dut.g_host_mux[d].u_hmux.*` inside a procedural loop. Verilator requires elaboration-time constant indices for these hierarchical references.
- Corrected testbench-only instrumentation in commit `76966009274be54ce26d87e333744b5cc17f72b4`: declared four debug vectors and connected them through a static testbench generate loop (`genvar gd`) to `dut.g_host_mux[gd].u_hmux.{wo_h,wo_rv,w_v,w_r}`. The procedural fatal now reads `dbg_*[d]`. No synthesizable RTL, original mismatch predicates, or expected test values changed.
- Exact-SHA Actions lookup for corrected commit `76966009274be54ce26d87e333744b5cc17f72b4` confirms six push-triggered workflows were created. At the latest poll all were **QUEUED**:
  - ASIC/config [45481815682](https://github.com/shamiursunny/openTPU/actions/runs/45481815682), job `138756664096`.
  - Board-functional + uncovered RTL [45481815901](https://github.com/shamiursunny/openTPU/actions/runs/45481815901), jobs `138756665399` and `138756666235`.
  - Software-core [45481815819](https://github.com/shamiursunny/openTPU/actions/runs/45481815819), job `138756667852`.
  - RTL tail [45481815780](https://github.com/shamiursunny/openTPU/actions/runs/45481815780), job `138756664573`.
  - RTL subsystems/WG8 memory [45481815735](https://github.com/shamiursunny/openTPU/actions/runs/45481815735), 14 jobs `138756668374`, `138756668648`, `138756668674`, `138756668707`, `138756668810`, `138756668862`, `138756668912`, `138756668917`, `138756668920`, `138756668924`, `138756668953`, `138756668969`, `138756672042`, `138756672122`.
  - Isolated 128K TMEM [45481815691](https://github.com/shamiursunny/openTPU/actions/runs/45481815691), job `138756665688`.
- Earlier run [45480699954](https://github.com/shamiursunny/openTPU/actions/runs/45480699954), SHA `597f1b9af961f4e8fcde1ae9fffa013ce6bc7f54`, remained QUEUED at last poll. It contains the earlier non-corrected diagnostic source and must not be used to qualify the corrected instrumentation.
- Concurrent older workflows on SHA `e1f46ee...` remained open at last poll: software-core [45479454796] IN_PROGRESS; board-functional and uncovered RTL [45479454775] IN_PROGRESS; subsystem matrix [45479454701] QUEUED; RTL tail [45479454581] IN_PROGRESS. The isolated 128K TMEM run [45479454629] completed SUCCESS. The older ASIC/config run [45479454587] is a diagnostic compile failure, not a DUT simulation result.
- Next: poll all six corrected-SHA workflows; retrieve the corrected ASIC/config job log. If compilation passes, capture the exact DIMM2 W mismatch fields and classify owner/handshake state before any RTL change. Keep main untouched and preserve the four-DIMM test expectations.


## 131. Corrected-SHA workflow queue transition (2026-11-25)

Latest re-poll of the six workflows on corrected testbench SHA `76966009274be54ce26d87e333744b5cc17f72b4` supersedes Section 130's initial all-QUEUED snapshot:

- ASIC/config Run [45481815682](https://github.com/shamiursunny/openTPU/actions/runs/45481815682), job `138756664096`: **QUEUED**.
- Board-functional/uncovered RTL Run [45481815901](https://github.com/shamiursunny/openTPU/actions/runs/45481815901): board-functional job `138756665399` **QUEUED**; uncovered-RTL job `138756666235` **IN_PROGRESS**, currently building pinned Verilator 5.044.
- Software-core Run [45481815819](https://github.com/shamiursunny/openTPU/actions/runs/45481815819), job `138756667852`: **QUEUED**.
- RTL-tail Run [45481815780](https://github.com/shamiursunny/openTPU/actions/runs/45481815780), job `138756664573`: **IN_PROGRESS**, installing project/test dependencies.
- RTL subsystems/WG8 Run [45481815735](https://github.com/shamiursunny/openTPU/actions/runs/45481815735): all 14 jobs remain **QUEUED**.
- Isolated 128K TMEM Run [45481815691](https://github.com/shamiursunny/openTPU/actions/runs/45481815691), job `138756665688`: **IN_PROGRESS**, executing the isolated experimental test.
- No corrected-SHA ASIC/config simulation result exists yet. Do not treat the static generate fix as validated until Run 45481815682 compiles and its four-DIMM simulation completes.
- The branch's next step remains polling the ASIC/config run first, then capturing the DIMM2 diagnostic values if the build succeeds. Do not make any DUT RTL change before that evidence.


## 132. Diagnose and correct premature B response in four-DIMM W-channel testbench (2026-11-25)

- Re-polled corrected diagnostic ASIC/config Run [45481815682](https://github.com/shamiursunny/openTPU/actions/runs/45481815682), exact testbench SHA \`76966009274be54ce26d87e333744b5cc17f72b4\`, job \`138756664096\`. The 66 target/config tests and all three integrated ASIC lint stages passed; simulation compiled and failed at 135 ns on DIMM2 W payload comparison.
- The diagnostic values were: actual controller WDATA repeated word \`feed000200000002\` (host beat 2) versus expected \`feed000200000000\` (beat 0); actual WSTRB \`ffffffffffffffff\` versus expected \`5555555555555555\`; WLAST matched at 0. At the failing output handshake the HMUX owner FIFO was empty (\`wo_rv=0\`), W input-valid/ready were low, while the host task had advanced to beat 3. This showed the controller-side beat scoreboard had been reset early; it did not, by itself, demonstrate a DUT data-path corruption.
- Source inspection found the testbench's controller response model asserted BVALID after any accepted W beat: \`w_complete || (m_wvalid && m_wready)\`. Its B response could therefore be accepted before WLAST, and the model's B-handshake branch reset \`w_beat\` to zero while the burst was still in progress. Later beat 2 was consequently compared against beat 0. This is a testbench model defect.
- Corrected the response condition to \`w_complete || (m_wvalid && m_wready && m_wlast)\`, with an explanatory comment. Commit: \`68baca1a080e952b20327c90d63a6f66c6a1ee70\`. Commit diff confirms only \`sim/verilator/tb_asic_wg8_ddr4.sv\` changed; no synthesizable RTL or acceptance checks were modified.
- The feature branch now points exactly to \`68baca1a080e952b20327c90d63a6f66c6a1ee70\`; compare against the protected main baseline confirms main remains \`d84db55712aba0d40811d7762cb052f05d55b7e5\`, with no divergence behind main. No paid services or hardware used.
- At the latest query immediately after this commit, combined commit status was empty and the commit-workflow lookup returned no associated runs. Important limitation: this connector's commit-workflow lookup exposes PR-triggered runs only, and the combined-status endpoint is not a complete Actions run listing. These empty responses do **not** prove that a push-triggered workflow is absent. The corrected commit's push-trigger/run ID is therefore **UNKNOWN** until the repository Actions history is checked; no pass is claimed.
- On the preceding diagnostic SHA \`769660...\`, RTL-tail Run [45481815780](https://github.com/shamiursunny/openTPU/actions/runs/45481815780), job \`138756664573\`, passed **33 tests, 1 documented parameter-inapplicable skip, 183 deselected**. Isolated 128K TMEM Run [45481815691](https://github.com/shamiursunny/openTPU/actions/runs/45481815691), job \`138756665688\`, passed **2 tests, 215 deselected**. These results are scoped to SHA \`769660...\`, not the new SHA \`68baca...\`.
- Board-functional job \`138756665399\` and uncovered-RTL job \`138756666235\` in Run \`45481815901\`, software-core job \`138756667852\` in Run \`45481815819\`, and most subsystem jobs in Run \`45481815735\` were still in progress/queued at the last poll. Keep these states separate and re-poll; do not infer completion.
- A02 returns to **IN PROGRESS** pending exact-SHA rerun. A03 four-instance contention and the address-map simulation remain unverified in the integrated gate because the previous A02 failure caused those workflow steps to be skipped. Next: inspect the workflow triggered by \`68baca...\`; if it passes, verify both expected-fatal aperture tests, then inspect the global address-map and four-instance HMUX contention/assertion steps. Continue the independent board/software/subsystem jobs and inspect the outstanding PPA evidence separately. No DUT RTL change is justified by the present diagnostic.



## 133. Exact-SHA Actions discovery and A02 queued verification checkpoint (2026-11-25)

- Retrieved the repository's Actions run collection directly, resolving the prior lookup limitation. Six push-triggered workflows were confirmed for code SHA \`68baca1a080e952b20327c90d63a6f66c6a1ee70\`; all runs are currently **QUEUED**, except the board-functional job below which is **IN_PROGRESS**:
  - ASIC/config Run [45487119079](https://github.com/shamiursunny/openTPU/actions/runs/45487119079), job \`138775349960\` (**QUEUED**). This is the critical A02 gate.
  - RTL + board Run [45487118979](https://github.com/shamiursunny/openTPU/actions/runs/45487118979): uncovered RTL job \`138775349549\` (**QUEUED**); board-functional job \`138775349751\` (**IN_PROGRESS**).
  - Software-core Run [45487119094](https://github.com/shamiursunny/openTPU/actions/runs/45487119094), job \`138775350415\` (**QUEUED**).
  - Isolated 128K TMEM Run [45487119017](https://github.com/shamiursunny/openTPU/actions/runs/45487119017), job \`138775350575\` (**QUEUED**).
  - RTL subsystems/WG8 Run [45487118947](https://github.com/shamiursunny/openTPU/actions/runs/45487118947), 14 jobs \`138775349535\`, \`138775349969\`, \`138775350004\`, \`138775350051\`, \`138775350076\`, \`138775350127\`, \`138775350140\`, \`138775350174\`, \`138775350201\`, \`138775350240\`, \`138775350247\`, \`138775350368\`, \`138775352847\`, \`138775353032\` (**all QUEUED**).
  - RTL-tail Run [45487118908](https://github.com/shamiursunny/openTPU/actions/runs/45487118908), job \`138775349245\` (**QUEUED**).
- All six runs were created by push on 2026-11-24 21:03:16 UTC, exact head SHA \`68baca...\`; they have not started/completed at the latest re-poll. The board-functional job's setup, checkout, Python setup, Verilator installation and dependencies have completed; its host-driver/board-model regression step is running. Job-log download currently returns NOT_FOUND, so no individual board test outcome is asserted.
- Independent source review confirms the corrected B-response model waits for the accepted WLAST beat or an already completed W burst. The W-beat counter is reset only after a subsequent accepted B response. This is a testbench-only correction; no DUT RTL changes are warranted by the evidence.
- Reviewed the four-instance contention bench source: it drives simultaneous host/pair AW and AR requests, checks alternating grants and ordered two-beat W bursts, and checks BID/RID response routing with independent backpressure. This is a source review only; A03 remains **UNVERIFIED** until the integrated ASIC/config workflow reaches and passes its contention step.
- A02 remains **IN PROGRESS — exact-SHA CI QUEUED**. Do not make another code change merely to bypass the queue. Re-poll Run 45487119079 first; then inspect the four-DIMM simulation, negative AW/AR aperture tests, global address-map simulation and four-instance contention step in sequence.
- No new PPA result. Previous WG8 PPA Run [45455745851](https://github.com/shamiursunny/openTPU/actions/runs/45455745851) is **FAILED** (job \`138664562707\`); its artifact \`14962660456\` is 1,562,950,987 bytes. Do not download this 1.56-GB artifact without a specific targeted extraction plan. No area/timing/power values are accepted from it.
- Feature branch code checkpoint remains \`68baca...\`; documentation commits are tracked separately. Protected main remains \`d84db55712aba0d40811d7762cb052f05d55b7e5\`. Zero-spend and feature-branch-only controls remain in force.


## 134. Exact-SHA ASIC/configuration regression PASS and remaining jobs — 2026-11-25

- Critical ASIC/config Run [45487119079](https://github.com/shamiursunny/openTPU/actions/runs/45487119079), job `138775349960`, completed **SUCCESS** on exact code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`.
- All three integrated lint stages passed: ASIC control/compute top, WG8 native-memory top and WG8 four-DIMM AXI top.
- All three integrated simulations passed: four-DIMM WG8 host AXI integration, global-to-DIMM address mapping, and four-instance host/accelerator mux contention. This closes the immediate integrated A02/A03 simulation gate for this exact code SHA, subject to detailed log review and scope limits; it is not full formal or silicon signoff.
- Isolated 128K one-copy TMEM Run [45487119017](https://github.com/shamiursunny/openTPU/actions/runs/45487119017), job `138775350575`, completed **SUCCESS** on the same SHA. The job's test step passed; do not infer an unobserved test count from job summary alone.
- Remaining exact-SHA jobs at the latest poll: board-functional job `138775349751` in Run [45487118979](https://github.com/shamiursunny/openTPU/actions/runs/45487118979) **IN_PROGRESS**; uncovered RTL job `138775349549` in the same run **IN_PROGRESS**; software-core job `138775350415` in Run [45487119094](https://github.com/shamiursunny/openTPU/actions/runs/45487119094) **IN_PROGRESS**; RTL-tail job `138775349245` in Run [45487118908](https://github.com/shamiursunny/openTPU/actions/runs/45487118908) **IN_PROGRESS**; all 14 jobs in subsystem/WG8 Run [45487118947](https://github.com/shamiursunny/openTPU/actions/runs/45487118947) **QUEUED**.
- PPA remains unresolved. Previous WG8 PPA Run `45455745851` failed; no area, timing, power or PPA values are accepted.
- Code under test remains `68baca...`; the documentation commits are separate. Main remains protected and unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5` (re-verify live before future writes).
- Next: inspect full ASIC/config logs and archived outputs, then poll and reconcile the four in-progress jobs and 14 queued subsystem jobs. Keep manufacturer release gate open; no production/tapeout claim.



## 135. Detailed ASIC/config simulation markers and lint-warning triage — 2026-11-25

The complete log for Run [45487119079](https://github.com/shamiursunny/openTPU/actions/runs/45487119079), job `138775349960`, was retrieved and inspected on exact code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`:

- Four-DIMM host AXI simulation printed PASS for 1/2/4/8-beat writes and reads, W-before-AW, partial and zero strobes, all BRESP/RRESP codes, 4-KiB boundary-aligned bursts and independent backpressure.
- Negative aperture cases printed PASS for both `bad_aw` and `bad_ar`; each produced the expected fatal for an address outside the 8-GiB DIMM aperture. These are expected-failure tests, not workflow failures.
- Global map simulation printed PASS for the 32-GiB global map, four DIMMs, two 4-GiB channels per DIMM, 4-KiB interleave, inverse bijection and out-of-aperture rejection.
- Four-instance HMUX simulation printed PASS for simultaneous host/accelerator AW/AR contention, alternating grants, ordered two-beat W bursts, B/R ID routing and independent backpressure.
- Lint is green but warnings remain. Notably, the WG8 wrapper has WIDTHTRUNC warnings where 34-bit selected addresses connect to 33-bit `m_awaddr`/`m_araddr` pins (lines 240/245), plus an UNOPTFLAT circular combinational warning at `otpu_slice.sv:906` (`aok`). Numerous width expand/truncation, unused signal/parameter and timescale warnings also appear. These require triage; passing lint does not make them safe by assumption. Prioritise confirming the address-width contract and whether any high address bit can be lost before treating the wrapper as robust.
- Log artifact [sunnyone-asic-config-log](https://github.com/shamiursunny/openTPU/actions/runs/45487119079/artifacts/14964499992), 49,873 bytes, contains the main log and separate lint/build logs.

No RTL edit is made from warnings alone. Inspect address-width intent and warning context, then add directed boundary tests or fix only if a real contract defect is demonstrated. The manufacturer gate remains open.



## 136. Source trace of address-width and UNOPTFLAT warnings — 2026-11-25

Source review refined the warning assessment for exact code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`:

- The WG8 top sets `CL = CAW + clog2(CB) = 25 + 7 = 32`; `otpu_mig_pair` with `NC=2` declares its DIMM-local AXI AW/AR output width as `CL + clog2(NC) = 33` bits. The actual `p_awaddr/p_araddr` intermediate nets are 34 bits because the downstream `otpu_mig_hmux` uses AW=34. Thus the reported pair-output connection is a 33-to-34-bit width mismatch, consistent with zero-extension of the 33-bit local address into the mux's 34-bit interface; the source map and top guard reserve bit 33 as zero. It is not evidence that a meaningful 34th local address bit is being discarded. The bridge's 34-bit channel input is also intentionally reduced to its 32-bit channel offset by `otpu_mig_pair.dimm()`, whose valid channel range is 4 GiB (CL=32); the bridge uses PC=0 and channel geometry CAW25/CB128. This source-derived contract should still be made explicit or warning-cleaned in a future controlled RTL cleanup, but no functional defect is currently demonstrated.
- The `aok` UNOPTFLAT warning at `rtl/top/otpu_slice.sv:906` comes from a combinational priority calculation: each group `g` depends only on previously computed lower-index `aok[h]` entries (`h < g`) and conflict masks. The source shows a forward triangular dependency, not an obvious cycle through the same element or a register loop. Verilator reports the packed vector as a circular combinational path; this is a warning to structurally validate, not proof of a functional combinational loop. Do not refactor without a targeted equivalence/regression plan.
- No RTL was changed. A02/A03 PASS evidence remains intact. The exact-SHA board, uncovered RTL, software-core, RTL-tail and subsystem jobs are still being polled.



## 137. RTL-tail regression completed — 2026-11-25

- RTL-tail Run [45487118908](https://github.com/shamiursunny/openTPU/actions/runs/45487118908), job `138775349245`, completed **SUCCESS** on code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`.
- Exact pytest result: **33 passed, 1 skipped, 183 deselected** in 711.82 seconds. The single skip is parameter-inapplicable: `PAIR needs 2M <= MCOLS; M <= ACT_ROWS`. The skip is not a failure; the 183 deselected tests were outside this targeted job's selection and are not covered by this result.
- The workflow attempted to upload `/tmp/sunnyone-rtl-tail.log`, but that file did not exist, so no separate artifact was produced. The GitHub job log itself contains the pytest summary.
- At latest poll, board-functional, uncovered RTL and software-core remain IN_PROGRESS; Stream RTL and MX multiply/replay are IN_PROGRESS; the other 12 subsystem/WG8 jobs remain QUEUED. No outcomes inferred for these jobs.



## 138. Live continuation poll and exact-SHA reconciliation — 2026-11-25

The repository was re-queried before this update. Active feature branch `sunnyone/commercial-profitability-architecture-2026-11-23` pointed to `06766e101f5451830638705eb616291df8b4ef7b`; `main` remained `d84db55712aba0d40811d7762cb052f05d55b7e5`. Compare from code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70` to feature HEAD showed 22 commits, with changes confined to the three project documentation files. No RTL or testbench source change followed the tested code SHA.

### Exact-SHA workflow poll: code SHA 68baca...

- ASIC/config Run [45487119079](https://github.com/shamiursunny/openTPU/actions/runs/45487119079), job `138775349960`: SUCCESS. The full job log was inspected. PASS markers confirm four-DIMM 1/2/4/8-beat host reads/writes, W-before-AW, partial and zero strobes, all BRESP/RRESP codes, 4-KiB boundary-aligned bursts and independent backpressure; expected-fatal `bad_aw` and `bad_ar` aperture tests; global 32-GiB address mapping; and four-instance HMUX contention, alternating grants, ordered two-beat W bursts, B/R ID routing and independent backpressure. Artifact: [sunnyone-asic-config-log](https://github.com/shamiursunny/openTPU/actions/runs/45487119079/artifacts/14964499992).
- RTL-tail Run [45487118908](https://github.com/shamiursunny/openTPU/actions/runs/45487118908), job `138775349245`: SUCCESS, exact pytest summary **33 passed, 1 skipped, 183 deselected**. Skip is parameter-inapplicable (`PAIR needs 2M <= MCOLS; M <= ACT_ROWS`). Deselected tests were not run.
- Isolated 128K one-copy TMEM Run [45487119017](https://github.com/shamiursunny/openTPU/actions/runs/45487119017), job `138775350575`: SUCCESS. No exact count is asserted here because no verified test summary was extracted in this poll.
- RTL subsystem/WG8 Run [45487118947](https://github.com/shamiursunny/openTPU/actions/runs/45487118947): 11 jobs completed SUCCESS; Address-window job `138775350051` and Native DRAM/technology RAM job `138775352847` remained IN_PROGRESS; Reset audit job `138775353032` remained QUEUED. Therefore the 14-job workflow is not complete.
- Board/uncovered RTL Run [45487118979](https://github.com/shamiursunny/openTPU/actions/runs/45487118979): board-functional job `138775349751` and uncovered RTL job `138775349549` ended CANCELLED. Logs show partial pytest progress before cancellation; no pass is inferred.
- Software-core Run [45487119094](https://github.com/shamiursunny/openTPU/actions/runs/45487119094), job `138775350415`: CANCELLED during a long pytest suite after partial progress; no pass is inferred.
- Prior WG8 PPA Run [45455745851](https://github.com/shamiursunny/openTPU/actions/runs/45455745851), job `138664562707`, remains FAILED on older SHA `dc34e3a...`. No area, timing, power or PPA value is accepted.

### Evidence accounting correction

A prior short continuation response described 249 passing subsystem tests. This number is not carried forward as an authoritative count because this poll verified successful job conclusions but did not extract and reconcile every pytest summary. Record the exact 11 successful jobs, not a guessed or inferred case total. The older 377-pass matrix remains a separate historical result on its exact recorded SHA; never add overlapping runs to claim unique lifetime test cases.

### Task status changes

- A02 four-DIMM AXI multi-beat and negative aperture gate: PASS on exact code SHA `68baca...`.
- A03 four-instance HMUX contention/ID-routing gate: PASS on exact code SHA `68baca...`.
- RTL-tail: PASS, scoped (33 passed, 1 skipped, 183 deselected).
- Isolated one-copy 128K TMEM: workflow/job SUCCESS; count not restated.
- Subsystem/WG8 matrix: PARTIAL (11 SUCCESS, 2 IN_PROGRESS, 1 QUEUED).
- Board-functional/uncovered RTL: CANCELLED; rerun required.
- Software-core: CANCELLED; rerun required.
- PPA: FAILED/OPEN; no metrics accepted.
- WIDTHTRUNC/UNOPTFLAT lint warnings: OPEN for explicit contract and structural review; source review has not established a functional defect.

### Next actions

1. Poll and inspect the two in-progress subsystem jobs and queued reset audit; capture exact test summaries and skip reasons.
2. Rerun board-functional, uncovered RTL and software-core suites in appropriately sized jobs with adequate runtime. Cancellation is neither pass nor test failure.
3. Diagnose PPA from targeted ORFS/Yosys logs and artifact metadata; avoid bulk transfer of the 1.56-GB historical artifact. No PPA claims until a reproducible run succeeds.
4. Resolve or document the WIDTHTRUNC and UNOPTFLAT warnings with source-level address-width proof, boundary checks and structural analysis; no blanket waiver.
5. Run final regression on one immutable candidate SHA after all applicable gates close.

Release/manufacturer decision remains NOT READY for fabrication, tapeout, physical signoff, production-board build or silicon qualification. A02/A03 simulation success does not establish timing, power, thermal, PHY, DFT, package, board or silicon readiness.


## 139. Live continuation poll and PPA artifact audit — 2026-11-25

- `45487118947` subsystem matrix: 12 jobs SUCCESS; Native DRAM/technology RAM `138775352847` and Reset audit `138775353032` still IN_PROGRESS at latest poll. Exact test summaries still required.
- `45455745851` PPA: FAILED, ORFS exit 2, source SHA `dc34e3a...`. SRAM probe/prep succeeded: 288 macros, 14 sizes, 3,538 KiB. This is not a PPA result.
- Artifact `14962660456` size 1,562,950,987 bytes exceeds the artifact-download connector's 536,870,912-byte limit. Detailed ORFS failure log is therefore not yet inspected; root cause OPEN. Next rerun must upload compact diagnostic evidence and exclude bulk result databases.
- Do not report area/timing/power figures. Keep tested RTL SHA `68baca...` distinct from docs-only branch HEAD; keep main untouched. Fabrication/tapeout/physical signoff remains NOT READY.


## 140. Exact subsystem test reconciliation and PPA workflow repair — 2026-11-25

- Subsystem workflow `45487118947`: 14/14 jobs SUCCESS on code SHA `68baca...`. Parsed all 14 pytest summaries: **377 passed, 1 skipped, 0 failed**. The skip is configuration-inapplicable: 64-GiB address-window case has every address in DRAM. Job counts: 14 + 17 + 128 + 20 + 5 + 11 + 13 + 15 + 8 + 8 + 23 + 7 + 104 + 4 = 377; one separate skip.
- Cancelled-suite retries: `rtl-uncovered` and `software-core` now running under a new attempt; `board-functional` still cancelled because immediate retry was rejected while the run is active. Retry after completion.
- PPA evidence workflow updated at `c568020...` to exclude `work/results/**` and full `run.log`, preserving a 200-KiB run tail, diagnostics file-size inventory, compact report, logs/reports, config and constraints. New run still needs to be checked. Historical PPA root cause remains OPEN; no area/timing/power numbers.
- Manufacturer readiness remains NOT READY for fabrication, tapeout, physical signoff, production board or silicon qualification.

## 141. Retry poll and continuation checkpoint — 2026-11-25

- Re-polled retries from cancelled attempt. Latest retry of board-functional is job `139135578982`, currently IN_PROGRESS; setup/checkout/Python setup complete, Verilator installation in progress. Software-core latest retry is job `139135639920`, currently IN_PROGRESS; setup/checkout/Python setup complete, Verilator installation in progress. No test suite results are available yet.
- Uncovered RTL job `139135582940` in the latest attempt remains CANCELLED. A further rerun request is blocked while the same workflow run is active (GitHub 403); retry only after board-functional settles.
- Earlier retry jobs `139003943623` (uncovered RTL), `139003968520` (software-core) and `139003945395` (board-functional) all ended CANCELLED at their main regression step. Cancellation is neither a test pass nor a test failure.
- Subsystem workflow `45487118947` re-polled: all 14/14 jobs SUCCESS. Previously reconciled exact totals remain 377 passed, 1 configuration-inapplicable skip, 0 failed on RTL SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`.
- Feature branch compared against tested RTL SHA `68baca...`: 32 commits ahead, 0 behind; changes since tested SHA are limited to the PPA workflow and the three SUNNYONE project continuity documents. Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; feature branch is 567 commits ahead and 0 behind main. No RTL/testbench changes are present after the tested SHA.
- Compact PPA workflow revision is present at commit `c568020d91efd045c6dd5d89dbc30ebdbac2c866` (workflow blob `6f49d8e11cb2079c45c00a44722764de14fac87d`). It retains a 200-KiB run tail, diagnostic inventory, report JSON, config/constraints and logs/reports while excluding full run.log and bulk results. A post-repair PPA run ID/result/artifact was not discoverable in the available run-query interface during this checkpoint; do not infer that it ran or passed. Historical PPA run `45455745851` remains FAILED/OPEN, no metrics accepted.
- Manufacturer release remains NOT READY for fabrication, tapeout, physical signoff, production-board build or silicon qualification.


## 142. Compact WG8 PPA rerun diagnosis and retry poll — 2026-11-25

- Post-repair PPA workflow did run: [run 45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546), workflow revision/code context SHA `c568020d91efd045c6dd5d89dbc30ebdbac2c866`, job `138974661431`. It FAILED in the pinned-container ORFS flow with exit code 2. Compact artifact `14997807086` (221,016 bytes; SHA-256 `bb087bae1049d8364d83f766279a1d77a9f289c3d2747bcb5f796a17fa75d118`) downloaded and inspected successfully. ORFS image digest: `sha256:9d227293bf57b9d84c63aa8551faa0487d30db456b254b8f244a1e40244f66af`.
- Evidence narrows the failure stage: synthesis and floorplan completed; flow stopped in `2_4_floorplan_pdn` during `check_placement -fixed -verbose`, with Make error 247 / exit 2. The floorplan timing-repair log reports 11 setup-violating endpoints and `Unable to repair all setup violations`. The floorplan JSON reports setup WNS `-10.4346 ns`, setup TNS `-91.4594 ns`; the report explicitly says no estimated parasitics and uses wire-load models. These are preliminary floorplan diagnostics only, **not accepted PPA, final timing, area, or power results**. No global placement, clock-tree, detailed routing, or final signoff completed. PDN warnings also report many absent metal6-to-metal7 vias; these need targeted diagnosis rather than blanket assumptions.
- SRAM prep still enumerates 288 generated/fake SRAM macros across 14 sizes (3,538 KiB); this is not foundry SRAM validation. Do not use the floorplan's synthesized/floorplan area or power estimates as chip PPA.
- Retry state re-polled: board-functional `139135578982` remains IN_PROGRESS at its actual host/board regression step; software-core `139135639920` remains IN_PROGRESS at its core/compiler/kernel/numerics step. Uncovered RTL `139135582940` is CANCELLED. No test counts or conclusions are available for the two active jobs. After board workflow settles, retry uncovered RTL once.
- Workflow-dispatch YAML trigger is present, but no dispatch/write action is exposed by the connected GitHub tools. Do not claim manual dispatch was performed. Run link above is the actual post-repair PPA execution.
- Branch integrity rechecked: tested RTL SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70` to feature HEAD `264a3d8de4d06c2be5ca5055dd82c2d4c9635ef9` is 35 commits ahead / 0 behind; only the PPA workflow and three continuity documents differ. Main remains `d84db55712aba0d40811d7762cb052f05d55b7e5`, 570 commits behind the feature branch and untouched.
- Next: inspect the failed `2_4_floorplan_pdn` log around `check_placement`, classify PDN geometry/via warnings, review timing-critical endpoints and constraints, and fix only evidence-backed causes. Then rerun PPA and require the complete ORFS flow plus inspectable report before accepting any metrics. Release remains NOT READY.

## 143. Branch-head accounting correction — 2026-11-25

The preceding comparison was made at intermediate feature HEAD `264a3d8...`. After the three continuity-document commits (`a20bf0b...`, `9f1331b...`, `2302bd4...`) and immediately before this accounting-correction commit, feature HEAD was `2302bd40fc5a3ec27447e835e8cfdfa9f46c71f3`. The fresh compare at that point confirmed 38 commits ahead / 0 behind tested RTL SHA `68baca1...`, with exactly four changed paths: the WG8 PPA workflow and the three SUNNYONE continuity documents. Against protected `main` SHA `d84db55712aba0d40811d7762cb052f05d55b7e5`, that intermediate feature HEAD was 573 ahead / 0 behind. Main remains unchanged. No RTL or testbench source changes exist after the tested SHA.


## 144. GitHub Actions scheduling and duplicate-run control — 2026-11-25

### Audit finding
- Fifteen SUNNYONE workflows existed. Several broad push filters overlap on `rtl/**`, `opentpu/**`, and `sim/verilator/**`. A single RTL commit could start several independent suites together, including subsystem matrix, RTL functional/board, RTL tail, software-core, ASIC config, full-chip lint, reset audit and WG8 PPA.
- These suites are not all duplicate tests: they cover different regressions, but each independently provisions Python, Verilator and dependencies. The subsystem matrix is limited to two parallel workers. Multiple workflows compete for hosted runner capacity, increasing queueing and wall-clock time.
- WG8 PPA is a long physical-design investigation and previously failed at floorplan PDN placement checking. It should not launch automatically on every broad RTL push.

### Workflow changes applied
- Added a per-workflow/per-branch concurrency group to all 15 SUNNYONE workflow YAML files: `group: ${{ github.workflow }}-${{ github.ref }}`, `cancel-in-progress: true`. This cancels superseded runs of the same suite when a newer commit arrives, without cancelling other independent suites.
- Changed `sunnyone-asic-wg8-ppa.yml` to manual `workflow_dispatch` only. This prevents a six-hour PPA run on every RTL commit; dispatch it after functional/ASIC qualification and a deliberate candidate checkpoint.
- Kept existing regression workflows, path filters, test selections, artifacts and matrix groups. No tests were deleted, skipped or weakened. Kept subsystem matrix `fail-fast: false` and `max-parallel: 2` to preserve complete evidence and avoid excessive runner contention.
- This is scheduling optimisation, not a fix for existing RTL/PPA failures. A successful workflow run must still verify the new configuration.

### Recommended execution order
1. Fast static/formal and focused control checks for changed modules.
2. Relevant subsystem and software/RTL regression suites.
3. ASIC integration and board-level checks after relevant RTL tests pass.
4. Full WG8 PPA manually, only on a frozen candidate SHA after functional/ASIC gates pass.
5. Retry only failed/cancelled jobs after diagnosis; do not rerun already successful suites without a code or environment reason.

### Expected effect and limitations
- Reduces wasted runner time from superseded same-suite runs and removes automatic six-hour PPA contention from ordinary RTL commits.
- Independent suites still run concurrently where path filters match. This is intentional because they test different subsystems; no unsafe global concurrency lock was added.
- Hosted runner capacity, package installation, long test execution and genuine test failures can still affect duration. Measure the next relevant push before claiming quantified speed-up.


## 145. AXI-Lite control CI failure diagnosis and assertion correction — 2026-11-25

- The first post-scheduling-change AXI-Lite control run `45598047228` failed at `sim/asic/tb_asic_ctrl.sv:55`: status register read returned `0x0000006e`, while the test expected `0x0000006c`.
- RTL status layout maps bit 1 to sticky `core_error | ctrl_error`; bit 2 is `ld_busy | load_inflight`. The sequence intentionally rejects LOAD while `wr_idle=0`, setting sticky `ctrl_error`, then accepts a later LOAD without issuing the explicit CTRL error-clear command. Thus the observed `0x6e` is consistent with the documented sticky-error behaviour; this mismatch was in the testbench expectation, not evidence of a hardware RTL failure.
- Corrected the testbench expected value to `0x0000006e` and clarified the comment. Test-only change commit: `cf0d4d3c211b481ae3ade391078731d2e476877b`.
- Verification run `45598244519`, job `139149936465`, is IN_PROGRESS at the Icarus installation step. Do not mark the control test PASS until the completed run log confirms the PASS marker.


## 146. AXI-Lite control assertion rerun — PASS — 2026-11-25

- Corrected testbench rerun: [GitHub Actions 45598244519](https://github.com/shamiursunny/openTPU/actions/runs/45598244519), job `139149936465`, SUCCESS.
- Exact log marker: `PASS: ASIC AXI-Lite control, independent AW/W, gating, load pulse, reset, register map`.
- The change was testbench-only: expected status changed from `0x6c` to `0x6e` to account for the sticky control-error bit set by the intentionally rejected LOAD command. No RTL source changed.


## 147. WG8 PPA trigger refinement — 2026-11-25

Correction to Section 144: GitHub documents that `workflow_dispatch` events require the workflow file to exist on the repository's default branch. The PPA workflow file does not currently exist on protected `main`, so a feature-branch-only manual UI trigger cannot be relied upon. See [GitHub documentation](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow).

The PPA workflow is therefore configured with a narrow feature-branch push filter covering the exact Nangate45 WG8 synthesis sources, ASIC top, target/tool configuration and an explicit `docs/sunnyone/PPA_REQUEST.md` marker. The broad `rtl/**` trigger is removed. The workflow file itself is excluded from its path filter to prevent self-triggering. `workflow_dispatch` remains configured for future availability once the workflow is present on the default branch / when supported through the repository's workflow controls.

The request marker currently says `NONE`; creating it did not start a PPA run. To request PPA on the feature branch, update the marker's candidate SHA and reason only after functional/ASIC gates are green. This keeps PPA deliberate without relying on a UI control unavailable from a branch-only workflow file.


## 148. RTL tail regression completion and artifact defect — 2026-11-25

- Run [45598047232](https://github.com/shamiursunny/openTPU/actions/runs/45598047232), job `139149245841`, completed SUCCESS on tested source SHA `36104fdaacabcba39ba4a7daa74b7fb19ce31536`.
- Exact pytest result from the job log: **33 passed, 1 skipped, 183 deselected in 742.68s (12m 22s)**. The skip is configuration-specific: `PAIR needs 2M <= MCOLS; M <= ACT_ROWS`. This is a scoped selection, not a full RTL-suite total.
- Artifact step returned success but explicitly logged: `No files were found with the provided path: /tmp/sunnyone-rtl-tail.log. No artifacts will be uploaded.` The workflow's pytest command does not create that file. This is a CI observability defect, not a regression-test failure. Correct the command to tee output to the declared path with `set -o pipefail` after the current run set completes, then verify artifact upload on the next run.
- At this checkpoint, core software/ISA run `45598047393` and RTL/board run `45598047324` remain IN_PROGRESS. Subsystem matrix `45598047338`: Stream, Quantizer modes, Quantizer corners/tie rounding, SPLITQ, QHL, and MX multiply/replay jobs completed SUCCESS; QST/QSTB and floating-point jobs remain IN_PROGRESS; remaining matrix groups are queued. No outcomes are inferred for active or queued jobs.


## 149. RTL-tail artifact logging repair — 2026-11-25

- Fixed `.github/workflows/sunnyone-rtl-tail.yml` in commit `4a1eb21ea31749fff6c2b12b51472123a2540a59`: the pytest command now uses Bash `set -o pipefail` and `tee /tmp/sunnyone-rtl-tail.log`, matching the upload-artifact path while preserving pytest's exit status.
- GitHub started validation run [45604384259](https://github.com/shamiursunny/openTPU/actions/runs/45604384259) on that workflow-only commit. It is IN_PROGRESS at latest poll; artifact creation is not yet verified.
- The previous run's exact log proved the defect: 33 passed, 1 skipped, 183 deselected; artifact action said no file existed. This correction affects CI logging only, not RTL or test selection.
- Active source-regression runs on SHA `36104fda` remain in progress: software-core `45598047393`, RTL/board `45598047324`; subsystem matrix `45598047338` has 6 successful groups, 2 running, and 6 queued at latest poll. Continue polling; do not infer results.


## CI logging repair correction — 2026-11-25

The first logging-repair validation run [45604384259](https://github.com/shamiursunny/openTPU/actions/runs/45604384259) FAILED before tests started. Exact error: `ERROR: file or directory not found: \\\\\\\\ `; the YAML continuation was over-escaped, causing pytest to interpret a literal backslash as a test path. No tests ran, and no artifact was created. This was a workflow-command quoting defect, not an RTL regression.

Corrected the step to a single-line pytest pipeline with `set -o pipefail` and `tee /tmp/sunnyone-rtl-tail.log` in commit `e0eea98ba00e65ca42b785bc6133a5679529506b`. New validation run [45604527541](https://github.com/shamiursunny/openTPU/actions/runs/45604527541) is IN_PROGRESS. Verify both pytest outcome and actual artifact upload before closing the issue. Do not treat run 45604384259 as a test result.



## 150. Latest Actions reconciliation and CI artifact verification — 2026-11-25

Repository/branch verified directly: `shamiursunny/openTPU`; active feature branch `sunnyone/commercial-profitability-architecture-2026-11-23` at pre-update HEAD `f51dc234aaf5b4e7d9b61a2e45768d315a5dcd81`; protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. No main-branch changes. All results below retain their exact tested SHA; do not combine counts as one release-wide total.

### Newly reconciled runs
- RTL-tail corrected logging run [45604527541](https://github.com/shamiursunny/openTPU/actions/runs/45604527541), job `139171823473`, source SHA `e0eea98ba00e65ca42b785bc6133a5679529506b`: SUCCESS. Downloaded and inspected artifact `sunnyone-rtl-tail-log` (artifact ID `15018530071`); pytest output confirms **33 passed, 1 skipped, 183 deselected in 635.12s (10m 35s)**. Skip is the documented configuration guard: `PAIR needs 2M <= MCOLS; M <= ACT_ROWS`. This verifies the corrected tee/pipefail log-artifact path. It is a scoped RTL-tail suite, not the complete regression.
- Earlier logging-repair run [45604384259](https://github.com/shamiursunny/openTPU/actions/runs/45604384259), SHA `4a1eb21ea31749fff6c2b12b51472123a2540a59`: FAILURE before tests; over-escaped YAML command made pytest treat a backslash as a test path. Zero tests ran. Superseded by the corrected single-line command at `e0eea98...`.
- AXI-Lite control correction [45598244519](https://github.com/shamiursunny/openTPU/actions/runs/45598244519), job `139149936465`, SHA `cf0d4d3c211b481ae3ade391078731d2e476877b`: SUCCESS; log PASS marker confirms independent AW/W, gating, load pulse, reset and register map. The preceding run `45598047228` failed because the test expected `0x6c` instead of the DUT-consistent sticky-error status `0x6e`; testbench-only expectation was corrected.
- Reset/power-up audit [45598047555](https://github.com/shamiursunny/openTPU/actions/runs/45598047555): SUCCESS.
- Full-chip Verilator lint [45598047313](https://github.com/shamiursunny/openTPU/actions/runs/45598047313): SUCCESS for the workflow's stated lint scope.
- Global address-map formal [45598047300](https://github.com/shamiursunny/openTPU/actions/runs/45598047300): SUCCESS for its scoped assertions; retain the earlier 14-assertion SAT result only for its exact SHA.
- Virtual DRAM [45598047296], workload harness [45598047288], RTL tail [45598047232], isolated TMEM [45598047332], PCIe Gen2 [45598047330], HMUX simulation [45598047225], ASIC configuration [45598047221]: SUCCESS on their recorded run SHAs and respective scopes.
- Software-core [45598047393] and remaining RTL/board [45598047324]: CANCELLED. No pass/fail count can be inferred. They require a deliberate retry on a frozen, current source SHA after the active matrix finishes.
- Subsystem/memory matrix [45598047338]: 13 of 14 jobs SUCCESS; Native DRAM and technology RAM job `139149249337` was still IN_PROGRESS at the latest poll. The other 13 jobs, including Reset audit, had completed SUCCESS. Do not call the matrix complete until the last job reaches a terminal state and its log is inspected.

### CI scheduling outcome
Per-workflow/per-branch concurrency and PPA trigger refinements are present in the workflows. The latest RTL-tail run demonstrates the corrected artifact capture works. The subsystem matrix still has a 14-job structure capped at two parallel jobs; this is intentional. Cancelled software/board suites are distinct coverage and should be rerun only once, sequentially after the matrix and any active jobs settle. Do not rerun successful suites without a code/environment reason.

### Next evidence-gated actions
1. Poll Native DRAM job `139149249337` to completion; inspect its exact pytest summary and artifact/log.
2. Retry software-core once on the latest frozen RTL SHA; wait for terminal result before starting another broad suite.
3. Retry remaining RTL/board once after software-core settles; preserve exact SHA and inspect logs.
4. Keep WG8 PPA separate: latest recorded research PPA run [45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546) failed in ORFS floorplan-PDN placement checking. No accepted PPA metrics; do not launch until functional/ASIC gates are green and the candidate is frozen.
5. Reconcile all test outcomes by exact commit; only then choose a final regression candidate. Manufacturer readiness remains NOT READY.



## 151. Native DRAM matrix runtime risk and sequential retry preparation — 2026-11-25

Latest re-poll of matrix run [45598047338](https://github.com/shamiursunny/openTPU/actions/runs/45598047338): 13/14 jobs remain completed SUCCESS; Native DRAM/technology RAM job `139149249337` remains IN_PROGRESS at the latest poll. Its active step is the selected regression group; setup, Verilator install and dependency install completed. No terminal pytest result or artifact is yet available, so no result count is assigned.

Runtime review found a scheduling risk worth addressing after this run settles: `tests/test_native_dram.py::_run` permits individual simulations up to 1,800 seconds, while the matrix job timeout is 45 minutes and the Native DRAM group bundles the parameterised `test_native_dram.py` suite with `test_tech_ram.py`. This is not proof that a test is hung or failed; it means the group has insufficiently bounded aggregate runtime for reliable scheduling. Do not modify the active workflow mid-run because its concurrency policy could cancel the current matrix.

After this matrix reaches a terminal state, split Native DRAM into smaller named test groups (functional/contract, random/stage stress, throughput/half-beat, high-address) and run technology RAM independently. Keep the same tests and assertions; this is execution partitioning, not test weakening. Set explicit per-job timeout budgets and preserve per-group log artifacts. Then rerun only the cancelled software-core and RTL/board jobs sequentially, one at a time. No workflow or RTL change was made in this checkpoint.


## 152. Verified current state and post-regression next-state plan — 2026-11-25

### Repository baseline
- Repository: https://github.com/shamiursunny/openTPU.
- Active feature branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Feature branch HEAD at checkpoint preparation: `db16fea6a7f39d29be62e4606842d3d24482520c`. This documentation update is feature-branch-only.
- Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; do not modify it.
- Current verification runs below execute source SHA `36104fdaacabcba39ba4a7daa74b7fb19ce31536`. Documentation-only commits do not change the source SHA tested by those already-running jobs.

### Completed and inspected
- Subsystem/memory matrix [45598047338](https://github.com/shamiursunny/openTPU/actions/runs/45598047338): **14/14 jobs SUCCESS** on source SHA `36104fdaacabcba39ba4a7daa74b7fb19ce31536`.
- The matrix produced 14 separate per-job log artifacts. The Native DRAM + technology RAM artifact `sunnyone-subsystems-12-log` (artifact ID `15020003974`) was downloaded and inspected. Exact pytest summary: **104 passed in 1,829.20 seconds (30m 29s)**; no skips or failures in that group.
- The complete matrix's reconciled totals from its job logs are **377 passed, 1 configuration-inapplicable skip, 0 failures**. The skip is the parameter guard `PAIR needs 2M <= MCOLS; M <= ACT_ROWS`. Do not add the 104 Native DRAM/RAM tests again to the matrix total; they are already included.
- RTL-tail run [45604527541](https://github.com/shamiursunny/openTPU/actions/runs/45604527541), source SHA `e0eea98ba00e65ca42b785bc6133a5679529506b`: **33 passed, 1 skipped, 183 deselected in 635.12 seconds**; artifact was downloaded and inspected. This is a separate run/SHA and is not added to the 377 matrix total.
- AXI-Lite control run [45598244519](https://github.com/shamiursunny/openTPU/actions/runs/45598244519): SUCCESS on its own exact testbench SHA; expected sticky-error status corrected in the testbench only, no RTL change.
- Previously recorded focused lint, reset audit, address-map formal, virtual DRAM, workload harness, isolated TMEM, PCIe Gen2, HMUX and ASIC-configuration results remain scoped to their individual run SHAs and test scopes. They are not a consolidated release signoff.

### Remaining regression queue — live status at checkpoint
- Software-core retry [45598047393](https://github.com/shamiursunny/openTPU/actions/runs/45598047393), attempt 2, job `139201961395`: **IN_PROGRESS** on source SHA `36104fdaacabcba39ba4a7daa74b7fb19ce31536`. Setup, checkout, Python, Verilator and dependency installation completed; the test step “Core ISA, compiler, kernels, numerics and host software” is running. No terminal result or test count is available yet.
- Remaining RTL/board workflow [45598047324](https://github.com/shamiursunny/openTPU/actions/runs/45598047324): previous attempt is **CANCELLED**. Its jobs `139149245874` (rtl-uncovered) and `139149246459` (board-functional) have no usable regression result and must not be counted as passes or failures.
- Execution order is fixed: wait for software-core to reach terminal state and inspect its complete log/artifacts; only then retry remaining RTL/board coverage, sequentially and without overlapping broad suites.
- No source/test changes are authorised merely to obtain green status. Diagnose any genuine failure from its log and source, preserve assertions, and rerun the smallest affected scope before any broad retry.

### CI runtime/scheduling finding
- Native DRAM + technology RAM completed successfully in 30m29s of test execution within the 45-minute job budget. The earlier aggregate-runtime concern did not manifest as a timeout on this run. Keep an eye on future runtime variance; do not split the suite solely on the earlier hypothesis without new evidence.
- Keep subsystem matrix concurrency at `max-parallel: 2`, broad suites sequential, and PPA separate/manual or narrowly gated. Existing workflow concurrency groups are per workflow/ref; avoid commits touching watched RTL/test/workflow paths while a relevant run is active.

### Defined next state — after all currently outstanding regression jobs complete
The next checkpoint is reached only when:
1. Software-core retry is terminal, its complete pytest/log output and artifacts are inspected, and exact pass/skip/fail/deselected counts are recorded.
2. The remaining RTL-uncovered and board-functional jobs have each been rerun after software-core, reached terminal states, and had their logs/artifacts inspected.
3. Any failure is classified as test, RTL, environment, infrastructure or workflow issue; no cancelled or missing result is relabelled as a pass.
4. The three continuity documents are reconciled to the same exact source SHA and run/job evidence.
5. A single immutable candidate SHA is selected for consolidated regression. Any source changes reset the candidate and require the relevant tests to be rerun.

### Engineering phase after regression closure
- First close functional, lint, reset, formal/protocol and host/board integration gaps on the frozen candidate.
- Then diagnose and repair the WG8 research PPA failure from run [45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546), which stopped at ORFS floorplan-PDN placement checking. No final area/timing/power metric is accepted.
- Only after prerequisite gates are green should a reproducible PPA run be attempted and its full reports inspected.
- Continue PHY/IP feasibility, DDR controller/PHY/training/ECC, DMA/IOMMU, PCIe endpoint/SerDes, CDC/RDC, DFT, SRAM macro, package, physical signoff, board electrical, thermal/power and silicon qualification planning.
- Manufacturer readiness remains **NOT READY**. Completion of the current regression queue is a verification milestone, not completion of all chip-design, manufacturing or commercial tasks.



## 153. Live continuation re-poll — 2026-11-25

### Repository and evidence baseline
- Repository: https://github.com/shamiursunny/openTPU.
- Active feature branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Latest recorded feature-branch checkpoint before this update: `db16fea6a7f39d29be62e4606842d3d24482520c`. All changes remain feature-branch-only.
- Protected `main` is recorded at `d84db55712aba0d40811d7762cb052f05d55b7e5`; this continuation did not write to main.
- Current broad regression source SHA: `36104fdaacabcba39ba4a7daa74b7fb19ce31536`.

### Re-polled results
- Subsystem/memory matrix [45598047338](https://github.com/shamiursunny/openTPU/actions/runs/45598047338): re-polled all 14 jobs; **14/14 SUCCESS**. This confirms the terminal matrix state. Previously inspected artifact evidence remains: 377 passed, 1 configuration-inapplicable skip, 0 failures overall; Native DRAM + technology RAM 104 passed in 1,829.20 seconds. Do not double-count the 104 within the 377.
- Software-core retry [45598047393](https://github.com/shamiursunny/openTPU/actions/runs/45598047393), job `139201961395`: still **IN_PROGRESS** at the core ISA/compiler/kernels/numerics/host software test step. Setup, checkout, Python, Verilator and dependency installation are complete. No terminal result, test count or artifact is available. Job logs currently return BlobNotFound while the run is active; this is not a test failure.
- Workflow configuration sets a 45-minute job timeout. The active test step must be allowed to reach a terminal state; do not launch another broad suite or push changes to watched source/test paths while it is active.
- Previous remaining RTL/board run [45598047324](https://github.com/shamiursunny/openTPU/actions/runs/45598047324): both jobs are confirmed **CANCELLED** (`rtl-uncovered` job `139149245874`; `board-functional` job `139149246459`). They have no usable test counts and are not passes or failures.

### Next action order
1. Poll software-core run `45598047393` until terminal. Inspect complete job logs and any artifacts; record exact pass/skip/fail/deselected counts and elapsed time.
2. If software-core succeeds, run the remaining RTL-uncovered selection once; wait for terminal status and inspect its log/artifact.
3. Run board-functional once after RTL-uncovered settles; inspect its log/artifact.
4. If software-core times out or is cancelled, diagnose the actual runtime/test selection first. Partition the same tests into bounded jobs if needed; preserve all assertions and do not weaken coverage.
5. Reconcile all three continuity documents to exact tested SHAs and job evidence. Then freeze a candidate SHA for consolidated regression.
6. Keep PPA deferred until functional/ASIC prerequisites are green; the prior WG8 ORFS floorplan-PDN failure remains unresolved and no accepted PPA metrics exist.

This re-poll changes no RTL, tests, workflows or architecture. Manufacturer readiness remains **NOT READY**; the regression queue is not chip-design completion or fabrication signoff.


## 154. Software-core timeout diagnosis and serial module isolation — 2026-11-25

The software-core retry [45598047393](https://github.com/shamiursunny/openTPU/actions/runs/45598047393), job `139201961395`, reached terminal **CANCELLED**. Its job log was retrieved after termination and shows pytest began at 12:23:46 UTC and GitHub cancelled the operation at 13:08:28 UTC (approximately 44m42s), during the test step. The progress display had reached 43%; setup, checkout, Verilator installation and dependency installation had succeeded. There is no terminal pytest summary, so assign no pass/fail counts. This is consistent with the configured 45-minute job timeout, not proof of a test assertion failure.

Workflow-only correction committed as `38377909bf68e3aa6102efac6c56b832675d44d4`: `.github/workflows/sunnyone-software-core.yml` now runs the exact same 15 test modules as a GitHub Actions matrix with `max-parallel: 1`, `fail-fast: false`, one module per job, 45-minute per-module timeout, verbose pytest output, and an always-uploaded per-module log artifact. No test files, assertions or RTL were changed. The module list is unchanged and complete: ISA, compiler, kernels, quant, formats, VOPS, FP, MX, stream, dataflow, waits, waitw, host, host-lock and host-runs. This isolates any slow module and prevents concurrent heavy modules. The workflow push trigger should create a new validation run; verify the actual run/job IDs and first module result before treating the correction as validated.

Next: inspect the new workflow run; let the serial matrix proceed; if a module exceeds 45 minutes, use its verbose log to identify and split that specific module's test selection without deleting tests. Only after all 15 modules reach terminal success may software-core be marked PASS. Remaining RTL-uncovered and board-functional runs remain queued behind this sequence.


## 155. Serial software-core matrix first evidence — 2026-11-25

Push-triggered validation run [45622326985](https://github.com/shamiursunny/openTPU/actions/runs/45622326985) is confirmed queued/running on workflow commit `38377909bf68e3aa6102efac6c56b832675d44d4`. All 15 matrix jobs are present; `max-parallel: 1` is behaving as intended: one job is terminal SUCCESS, one is IN_PROGRESS and 13 remain QUEUED. First module `tests/test_isa.py`, job `139233449899`, completed **18 passed in 0.13s**; per-module log artifact `sunnyone-software-core-0-log`, ID `15024379354`, was created, and the complete pytest output was inspected. Current active module at last poll: `tests/test_compiler.py`, job `139233450657`. This validates serial scheduling and artifact capture for the first module only; software-core remains OPEN until all 15 modules succeed.


## 156. Live serial software-core matrix re-poll — 2026-11-25 (Asia/Dhaka)

### Repository and branch protection
- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Protected `main` remains pinned at `d84db55712aba0d40811d7762cb052f05d55b7e5`; this update is feature-branch-only.
- Workflow source commit: `38377909bf68e3aa6102efac6c56b832675d44d4`. Before this checkpoint's documentation writes, the active branch was six commits ahead of the workflow source commit. The checkpoint then added the three continuity-document updates and a correction to their branch accounting; all intervening changes are documentation-only. No RTL, test or workflow files changed. Re-check the live branch tip before the next execution; the software-core workflow path filter excludes these documentation paths.
- No RTL, test source, assertions or workflow definition was changed in this re-poll.

### Live run 45622326985
- URL: https://github.com/shamiursunny/openTPU/actions/runs/45622326985
- The run contains all 15 expected software-core module jobs and is configured with `max-parallel: 1`, `fail-fast: false`, verbose per-module pytest logs, and always-uploaded per-module artifacts.
- Live job poll: **5 SUCCESS, 1 IN_PROGRESS, 9 QUEUED**. The active job is `tests/test_vops.py`, job ID `139233450456`. Its logs are not yet retrievable while active (BlobNotFound); this is not a failure.
- Five completed module logs were retrieved and inspected. Exact pytest summaries:
  - `tests/test_isa.py`, job `139233449899`: **18 passed in 0.13s**; artifact `sunnyone-software-core-0-log`, ID `15024379354`.
  - `tests/test_compiler.py`, job `139233450657`: **44 passed in 4.98s**; artifact `sunnyone-software-core-1-log`, ID `15026211469`.
  - `tests/test_kernels.py`, job `139233450577`: **46 passed in 1.82s**; artifact `sunnyone-software-core-2-log`, ID `15026436432`.
  - `tests/test_quant.py`, job `139233450565`: **81 passed in 5.35s**; artifact `sunnyone-software-core-3-log`, ID `15027565119`.
  - `tests/test_formats.py`, job `139233450333`: **13 passed in 0.40s**; artifact `sunnyone-software-core-4-log`, ID `15027510239`.
- Reconciled subtotal: **202 passed, 0 reported failures, 0 reported skips** across these five module jobs. This is a partial result only; do not mark the software-core milestone complete.
- Remaining modules: VOPS (currently running), FP, MX, stream, dataflow, waits, waitw, host, host-lock and host-runs (queued).
- Prior aggregate software-core run `45598047393` ended CANCELLED at approximately 44m42s without a terminal pytest summary; it contributes no pass/fail count. The serial matrix is the controlled retry and has not yet completed.
- The earlier remaining RTL-uncovered and board-functional attempt `45598047324` was cancelled; neither job contributes a test result.

### Updated execution order
1. Continue polling run `45622326985` until all 15 module jobs are terminal. Retrieve each completed job log and artifact; record exact pass/skip/fail/deselected counts. Do not interrupt the run with source/test/workflow changes.
2. If all 15 modules pass, run the remaining RTL-uncovered selection once; wait for terminal status and inspect its complete evidence.
3. Run board-functional once after RTL-uncovered settles; inspect its complete evidence.
4. Classify any failure from its log as test, RTL, environment, infrastructure or workflow. Preserve all tests and assertions.
5. Reconcile the three continuity documents again to the exact final tested SHA, job IDs, artifact IDs and totals. Freeze one candidate SHA and run the required consolidated regression.
6. Keep WG8 PPA deferred until functional, ASIC/configuration, lint/reset/formal/protocol and host/board prerequisites are closed. Prior ORFS floorplan-PDN failure remains unresolved; no accepted PPA metrics exist.

### Stage decision
**A1.12.11.16.54 remains OPEN.** Software-core serial retry is PARTIAL (5/15 modules successful; 202 tests passed in those five modules). Manufacturer readiness remains **NOT READY**. The logical V1 design candidate is not a complete host-connected ASIC, tapeout package, physically validated device or commercially qualified product.


## 157. Serial software-core matrix live checkpoint — 2026-11-25 (Asia/Dhaka)

Run [45622326985](https://github.com/shamiursunny/openTPU/actions/runs/45622326985), workflow commit `38377909bf68e3aa6102efac6c56b832675d44d4`, is executing the complete 15-module software-core matrix with `max-parallel: 1`. Latest live poll: **10 SUCCESS, 1 IN_PROGRESS, 4 QUEUED, 0 failed/cancelled**. Active job: `tests/test_waits.py`, job `139233450429`. Queued: `test_waitw.py`, `test_host_runs.py`, `test_host_lock.py`, `test_host.py`.

All ten terminal-success job logs were retrieved and their pytest summaries inspected. Exact results:
- ISA, job `139233449899`, artifact `15024379354`: 18 passed (0.13 s).
- Compiler, job `139233450657`, artifact `15026211469`: 44 passed (4.98 s).
- Kernels, job `139233450577`, artifact `15026436432`: 46 passed (1.82 s).
- Quant, job `139233450565`, artifact `15027565119`: 81 passed (5.35 s).
- Formats, job `139233450333`, artifact `15027510239`: 13 passed (0.40 s).
- VOPS, job `139233450456`, artifact `15030235221`: 101 passed (1,688.83 s).
- FP, job `139233450380`, artifact `15029541963`: 12 passed (22.44 s).
- MX, job `139233450804`, artifact `15029542120`: 32 passed (0.24 s).
- Stream, job `139233450596`, artifact `15032330134`: 46 passed (872.79 s).
- Dataflow, job `139233450490`, artifact `15029769939`: 27 passed (0.19 s).

Verified subtotal: **420 passed, 0 reported failures, 0 reported skips** across ten completed module logs. The waits module is still executing and contributes no count. The four queued modules contribute no count. Software-core remains OPEN until all 15 modules reach terminal success and their logs/artifacts are inspected.

No RTL, test, assertion or workflow file was changed. This is a documentation-only checkpoint on the active feature branch; do not interrupt the serial run. Next order remains: finish the 15 modules, then run RTL-uncovered once, then board-functional once, then reconcile and freeze the final candidate SHA. Protected `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`. Manufacturer readiness remains **NOT READY**; PPA/physical/IP/PHY/board/silicon/commercial gates remain open.


## 158. Serial software-core matrix closure and bounded WAITC retry — 2026-11-25 (Asia/Dhaka)

### Repository and protection
- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Protected `main` remains recorded at `d84db55712aba0d40811d7762cb052f05d55b7e5`; no main-branch writes were made.
- Added a workflow-only retry partition at commit `37d2f78eef227275347f58b39fcab69916cdd60f`: `.github/workflows/sunnyone-waits-retry.yml`. No RTL, software, test source or assertions were changed.

### Software-core run 45622326985
- Workflow/source commit: `38377909bf68e3aa6102efac6c56b832675d44d4`.
- Final live state: **14 of 15 module jobs SUCCESS; 1 CANCELLED; 0 assertion failures**.
- Inspected all 14 successful module logs and pytest summaries. Reconciled exact total: **557 passed, 1 skipped, 0 reported failures**.
- Module summaries and log artifact IDs:
  - ISA: 18 passed; job `139233449899`; artifact `15024379354`.
  - Compiler: 44 passed; job `139233450657`; artifact `15026211469`.
  - Kernels: 46 passed; job `139233450577`; artifact `15026436432`.
  - Quant: 81 passed; job `139233450565`; artifact `15027565119`.
  - Formats: 13 passed; job `139233450333`; artifact `15027510239`.
  - VOPS: 101 passed; job `139233450456`; artifact `15030235221`.
  - FP: 12 passed; job `139233450380`; artifact `15029541963`.
  - MX: 32 passed; job `139233450804`; artifact `15029542120`.
  - Stream: 46 passed; job `139233450596`; artifact `15032330134`.
  - Dataflow: 27 passed; job `139233450490`; artifact `15029769939`.
  - WAITW: 6 passed; job `139233453692`; artifact `15035495039`.
  - Host: 108 passed, 1 skipped; job `139233453975`; artifact `15034339815`. The single skip is `models/LFM2.5-230M not downloaded`.
  - Host-lock: 5 passed; job `139233453876`; artifact `15035721218`.
  - Host-runs: 18 passed; job `139233453716`; artifact `15033423718`.
- WAITC module job `139233450429` was cancelled at approximately 44m36s, with pytest progress at 84%. The log shows successful execution through `test_waitc_rtl_boot_programs_of_different_lengths[2]`, but no terminal pytest summary. Therefore assign **no pass/skip/fail count** to this module. This is a job-timeout/runtime-budget issue; no assertion failure was observed. Artifact `15034188015` preserves the partial log.

### Controlled WAITC retry
- Added `.github/workflows/sunnyone-waits-retry.yml` at commit `37d2f78eef227275347f58b39fcab69916cdd60f`.
- The workflow runs the full `tests/test_waits.py` selection in two disjoint, serial groups: all tests except `test_waitc_rtl_follow` (45-minute budget), followed by all four `test_waitc_rtl_follow` parameter cases (60-minute budget).
- The second group depends on the first. Each group uploads a full log even on failure. No test or assertion is removed; this partitions the expensive four-case RTL FOLLOW block that consumed most of the prior job budget.
- The retry is triggered by this tracker update. Verify its live run ID, both job conclusions, full pytest summaries and artifacts before closing WAITC.

### Updated next-action sequence
1. Inspect and close the two-part WAITC retry on its exact tested SHA.
2. Only after WAITC is fully successful, run the remaining RTL-uncovered selection once; inspect full logs and artifacts.
3. Then run board-functional once; inspect full logs and artifacts.
4. Diagnose any failures without weakening tests/assertions; classify test, RTL, environment, infrastructure or workflow causes.
5. Reconcile tracker, manufacturer handoff and project resume to the same tested SHA and exact evidence; then freeze a candidate and run the appropriate consolidated regression.
6. Keep PPA deferred until functional/ASIC prerequisites are closed. The prior WG8 ORFS floorplan-PDN failure remains unresolved; no accepted PPA metrics exist.

### Stage and readiness
- Software-core: **PARTIAL / 14 of 15 modules successful**; 557 passed and 1 skipped across successful modules. WAITC is pending controlled retry.
- Subsystem/memory matrix: **14/14 successful**, 377 passed, 1 configuration-inapplicable skip, 0 failures; the 104 Native DRAM/technology RAM passes are included in the 377.
- Stage A1.12.11.16.54 remains OPEN. Manufacturer readiness remains **NOT READY**. Production PCIe/DDR PHY and controller IP, DMA/IOMMU, CDC/RDC, DFT, production SRAM macros, PDK/package, physical signoff, board electrical validation, real-hardware power/thermal/performance measurements, silicon qualification and commercial validation remain outstanding.
- Maintain zero-spend without explicit approval and feature-branch-only changes.


## 159. WAITC controlled retry passed; RTL/board sequencing follow-up — 2026-11-25 (Asia/Dhaka)

### WAITC retry run 45641472720
- Exact tested head SHA: `d7aefdf27d9aaad1e59288df3846b5153221a924`.
- Workflow: `.github/workflows/sunnyone-waits-retry.yml`.
- Both jobs completed SUCCESS:
  - General WAITC job `139300967172`: `tests/test_waits.py -k 'not test_waitc_rtl_follow'`; **264 passed, 2 skipped, 4 deselected**; artifact `15035927377`.
  - RTL FOLLOW job `139307879702`: `tests/test_waits.py -k 'test_waitc_rtl_follow'`; all four configurations passed: `[2-sim]`, `[4-board]`, `[4-wg]`, `[4-wg_se1]`; **4 passed, 266 deselected**; artifact `15038143201`.
- Combined complete WAITC selection: **268 passed, 2 skipped, 0 failures**. The skips are PyTorch-dependent imports from `tests/test_bcuwg_board.py` and `tests/test_autodecode.py`; no WAITC test was skipped. The four deselected tests in the general group are exactly the four RTL FOLLOW cases executed by the second job.
- WAITC is now CLOSED / PASS at this tested SHA.

### Reconciled software-core
- Prior successful module jobs: 557 passed, 1 skipped.
- WAITC retry: 268 passed, 2 skipped.
- Combined observed software-core total: **825 passed, 3 skipped, 0 reported failures**. Counts are summed from non-overlapping test selections; WAITC retry replaces, rather than adds to, the cancelled WAITC attempt.
- Prior software-core workflow 45622326985 remains globally CANCELLED because its WAITC matrix job was cancelled; do not relabel that historical workflow as success. Its 14 successful module jobs remain valid evidence, while the retry closes the outstanding module separately.

### Serial RTL then board workflow sequencing
- Existing `.github/workflows/sunnyone-rtl-functional.yml` currently defines `rtl-uncovered` and `board-functional` without a dependency, so GitHub may run them concurrently.
- Attempted to add `needs: rtl-uncovered` to `board-functional`. GitHub rejected the contents update with HTTP 409 because repository rule validation timed out. A subsequent fetch confirmed the workflow file remained unchanged. **No sequencing fix is claimed as committed.**
- Next: retry this single workflow edit after the repository rule service recovers; verify the file contents and resulting commit. Preserve the exact test selections. Do not manually start board-functional until RTL-uncovered has completed successfully.
- After the dependency is committed, the workflow push should run serially. Inspect the RTL job's complete pytest summary and artifact; only then allow board-functional to run and inspect its summary/artifact.

### Current status
- Software-core: **PASS for observed module coverage** — 825 passed, 3 skipped, 0 reported failures, with all WAITC tests accounted for.
- Subsystem/memory: 14/14 jobs successful; 377 passed, 1 configuration-inapplicable skip; previously verified and not rerun.
- RTL-uncovered: PENDING.
- Board-functional: PENDING; execution must follow RTL-uncovered.
- Consolidated regression: PENDING.
- PPA and manufacturer readiness remain open; do not claim tapeout readiness.


## 160. CI orchestration corrections and active RTL verification (2026-11-25)

- Fixed .github/workflows/sunnyone-waits-retry.yml: removed the push trigger on docs/sunnyone/PROJECT_TRACKER.md; WAITC retry is now manual-dispatch only. Documentation-only commits no longer launch the expensive WAITC suite. Commit: 639e1ce7f2d590276cb979286eb7adb20eaadcb3.
- Fixed .github/workflows/sunnyone-rtl-functional.yml: board-functional now declares needs: rtl-uncovered, so board tests cannot start before the selected RTL/ISA job succeeds. Commit: ebce653e73a378adce6dde60939cb1e052077862.
- Verified current .github/workflows/sunnyone-rtl-tail.yml no longer contains the literal-backslash pytest invocation that caused historical run 45604384259 to exit 4 with 'file or directory not found: \\' and 'no tests ran'. Later run 45604527541 succeeded; the active workflow now has a single-line pytest command.
- Accidental duplicate WAITC run 45649007571 remains in progress (general job 139327989931). No cancellation action is available in connected GitHub controls. Do not count this run as new evidence; authoritative successful WAITC result remains run 45641472720.
- New serial RTL/board run 45649502094, exact SHA ebce653e73a378adce6dde60939cb1e052077862, is in progress. At last poll only rtl-uncovered job 139329804556 had started; board job is gated on its success. No new test result is claimed yet.
- Preserve prior verified aggregates unchanged until new logs are complete. RTL-uncovered and board-functional remain pending; consolidated regression, PPA and manufacturer readiness remain pending/not ready.


## 161. RTL regression execution checkpoint — 2026-11-25 (Asia/Dhaka)

- Re-polled RTL/board run [45649502094](https://github.com/shamiursunny/openTPU/actions/runs/45649502094), exact workflow/test SHA `ebce653e73a378adce6dde60939cb1e052077862`.
- RTL job `139329804556` remains `in_progress`. Verified completed setup steps: checkout, Python 3.12 setup, pinned Verilator 5.044 build, and project/test dependency installation. The selected core RTL/ISA pytest step is actively running; no terminal pytest summary or pass/fail count is available yet.
- `board-functional` remains correctly gated by `needs: rtl-uncovered`; it has not started. Do not start it separately.
- Attempted retrieval of the active job log returned GitHub storage `BlobNotFound` while the job is still running. This is an unavailable-live-log condition, not a test failure. No artifact or test count is credited.
- Accidental duplicate WAITC run `45649007571` is still `in_progress`; exclude it from all authoritative totals. WAITC's authoritative completed evidence remains run `45641472720`.
- Existing verified totals remain unchanged: software-core 825 passed, 3 skipped; subsystem/memory 377 passed, 1 configuration-inapplicable skip. Do not add counts from either active run.
- Next: wait for RTL job terminal state; retrieve full log and artifact; inspect pytest summary. If successful, verify board job starts and completes afterward. If failed, diagnose the exact failure without weakening tests. Then update all three continuity files with terminal evidence.


## 162. RTL timeout diagnosis, serial partition and continuity checkpoint — 2026-11-25 (Asia/Dhaka)

### Live regression reconciliation
- Software-core aggregate is closed for the observed selections: **825 passed, 3 skipped, 0 reported failures**. This combines 14 successful module jobs from Run [45622326985](https://github.com/shamiursunny/openTPU/actions/runs/45622326985) with the complete WAITC retry Run [45641472720](https://github.com/shamiursunny/openTPU/actions/runs/45641472720). The original matrix remains globally CANCELLED because WAITC exceeded its 45-minute job budget; WAITC is separately closed by its two successful retry jobs (264 passed, 2 skipped, then 4 passed). The three skips are non-WAITC optional model imports; no WAITC test was skipped.
- Subsystem/memory matrix Run [45598047338](https://github.com/shamiursunny/openTPU/actions/runs/45598047338): **14/14 SUCCESS, 377 passed, 1 configuration-inapplicable skip, 0 failures** on source SHA `36104fdaacabcba39ba4a7daa74b7fb19ce31536`. Native DRAM/technology RAM contributes 104 of those 377, not an additional 104.
- RTL-tail Run [45604527541](https://github.com/shamiursunny/openTPU/actions/runs/45604527541): **33 passed, 1 parameter-inapplicable skip, 183 deselected**; exact log artifact inspected. Keep this separate from the subsystem total.
- ASIC/config Run [45487119079](https://github.com/shamiursunny/openTPU/actions/runs/45487119079), exact code SHA `68baca1a080e952b20327c90d63a6f66c6a1ee70`: four-DIMM host AXI burst/response/aperture tests, global address-map simulation, four-instance HMUX contention/assertion simulation and three integrated lint stages succeeded. Scope is exact-SHA digital simulation/lint, not full formal or silicon signoff.
- AXI-Lite control Run [45598244519](https://github.com/shamiursunny/openTPU/actions/runs/45598244519): corrected testbench expectation passed; no RTL change.

### RTL-uncovered timeout and workflow correction
- RTL/board Run [45649502094](https://github.com/shamiursunny/openTPU/actions/runs/45649502094), exact workflow/test SHA `ebce653e73a378adce6dde60939cb1e052077862`: RTL job `139329804556` ended **CANCELLED**; board-functional was correctly skipped by its `needs: rtl-uncovered` dependency. The full job log shows Verilator 5.044 and project dependencies installed successfully, then the selected 18-family pytest invocation ran from 16:01:49 UTC until GitHub cancelled it at 16:38:57 UTC. No terminal pytest summary or uploaded log artifact exists; no pass/fail count is credited. This is a runtime-budget cancellation, not an observed assertion failure.
- Workflow-only remediation committed as `7320c187810cbd7e4f106f0280922871f6430d1b` in `.github/workflows/sunnyone-rtl-functional.yml`: the unchanged 18 selector families are divided into four disjoint pytest `-k` groups, run with `max-parallel: 1`; each has a 45-minute timeout, verbose output, `pipefail`, and its own always-uploaded log artifact. Board-functional still depends on the entire RTL matrix and now also records its own log artifact. No RTL, test source, assertion or test selection was removed or weakened.
- The corrected workflow file was fetched back from the feature branch and its content/blob SHA verified (`9fb6fe3b62b6bda01af7fdea91bdfc4e8b1eb9f5`). The push-triggered run ID and exact executed SHA were not exposed by the available run-list connector at checkpoint time; therefore validation remains **PENDING** until its actual Actions jobs/logs/artifacts are retrieved. Do not infer that the workflow has passed merely because the file update committed.

### Next controlled sequence
1. Discover the push-triggered run for workflow commit `7320c187...`; verify four matrix groups exist and execute serially. Inspect each complete pytest summary and artifact. Any failed/cancelled group must be diagnosed and retried without weakening tests.
2. Allow board-functional to start only after all four RTL groups succeed; inspect its full log/artifact and exact pytest summary.
3. Reconcile exact tested SHAs and non-overlapping counts. Do not sum overlapping runs or combine results from different source SHAs into a release-wide test total.
4. Freeze one candidate SHA and run the appropriate consolidated regression after all applicable functional gates pass.
5. Diagnose the WG8 research PPA floorplan-PDN failure from compact logs; no final area/timing/power metrics are accepted. Keep PPA deliberate and separate from routine regression.
6. Continue open formal/protocol, warning, PCIe/DDR PHY/controller, DMA/IOMMU, CDC/RDC, DFT, SRAM macro, PDK/package, physical signoff, board electrical, thermal/power, silicon and commercial qualification tasks.

### Readiness and constraints
- Logical V1 remains a candidate architecture, not a complete host-connected ASIC or tapeout package.
- Manufacturer readiness remains **NOT READY**. Digital regression success does not establish production IP/PHY, physical signoff, board or silicon qualification.
- Keep all writes on the active feature branch; protected `main` is not to be modified. Zero-spend remains mandatory without explicit user approval.


## 163. Verify serial RTL selector partition integrity — 2026-11-25 (Asia/Dhaka)

- Fetched `tests/test_rtl.py` from the active feature branch; source blob SHA `84cdfed65c2c9d3604e51080ce88d878fc71a76a`.
- Independently matched every one of the 18 original pytest `-k` selector terms against the actual test-function names. The four workflow groups match 5, 5, 5 and 3 distinct test functions respectively (18 total); every selector matches at least one function, and no test function is matched by more than one group. The two overlapping-looking TMEM selectors are intentionally in the same group.
- This validates selector coverage and disjointness at the function-name level only. It does not prove all parametrized instances have executed; the new Actions logs must still provide actual collection and terminal pytest summaries for each group.
- No test source or RTL changed. The workflow-only partition remains commit `7320c187810cbd7e4f106f0280922871f6430d1b`; exact workflow blob `9fb6fe3b62b6bda01af7fdea91bdfc4e8b1eb9f5`. Its actual push-triggered run ID/result is still not available through the connected run-list/status interface; do not assume execution or success.
- Next: discover and inspect all four matrix jobs and artifacts, then board-functional after the matrix succeeds. Preserve the 45-minute per-group limit and `max-parallel: 1`; if any single group still times out, split that group by actual slow-test evidence, keeping the complete selection.


## 164. Serial RTL workflow execution observed — 2026-11-25 (Asia/Dhaka)

- Push-triggered workflow run is now identified: [Run 45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), workflow `SUNNYONE remaining RTL and board regressions`, head SHA `7320c187810cbd7e4f106f0280922871f6430d1b`, event `push`, run number 118.
- Live job state at last poll: group 1 (`139371666058`) **in_progress** at `Run bounded RTL selection`; groups 2 (`139371665991`), 3 (`139371665344`), and 4 (`139371666093`) **queued**. This confirms the serial matrix is scheduling one group at a time as intended. Build pinned Verilator 5.044 and dependency installation completed successfully for group 1.
- Group 1 has no terminal pytest summary yet; logs are not downloadable while the job is active. No test-pass count is credited for this run. Groups 2–4 and board-functional have not completed; board remains dependency-gated.
- Do not launch duplicate runs or change the partition while this run is progressing. Poll run 45661335812, retrieve each job log and artifact after completion, record exact pytest counts, then inspect board-functional only if all four groups succeed. If any group fails/cancels, diagnose its actual log and rerun only the affected scope without weakening selection.
- Manufacturer readiness remains NOT READY; PPA, consolidated regression and production qualification remain open.


## 165. RTL uncovered group 1 passed — 2026-11-25 (Asia/Dhaka)

- Run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), head SHA `7320c187810cbd7e4f106f0280922871f6430d1b`, job `139371666058` (RTL uncovered — group 1) completed with job conclusion **success**.
- Retrieved full job log. Exact pytest terminal summary: **12 passed, 205 deselected in 1454.29s (0:24:14)**. Collection was 217 items, 12 selected. No failed/error/skipped tests were reported in this group.
- Log artifact uploaded successfully: `sunnyone-rtl-uncovered-1-log`, artifact ID `15047592555`, SHA-256 `a5b5b2bd3c8bb0f523cb858b04ef65763aaf0b0c407f487291542d3b414701e3`.
- At follow-up poll, group 2 job `139371665991` was in progress; groups 3 (`139371665344`) and 4 (`139371666093`) remained queued. Board-functional remains gated. Group 1 result is a verified scoped pass, not completion of the full RTL suite.
- Continue polling this exact run, capture each terminal log/artifact, and do not alter the active workflow. Manufacturer readiness remains NOT READY.


## 166. RTL uncovered group 2 passed — 2026-11-26 (Asia/Dhaka)

- Same run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), candidate SHA `7320c187810cbd7e4f106f0280922871f6430d1b`; job `139371665991` completed **success**.
- Retrieved complete job log; exact pytest summary: **24 passed, 193 deselected in 1478.61s (0:24:38)**. Collection 217, selected 24; no failed/skipped/error tests in this selection.
- Uploaded artifact `sunnyone-rtl-uncovered-2-log`, ID `15049479359`, digest `sha256:7b48507d66da85cea1eac09b76aa9c52f648cd2e87f467a4d4c2ce53f6f206d6`.
- Groups 1 and 2 now have 36 verified passes combined (12 + 24), on the same candidate SHA but in distinct jobs. Do not treat this as full-suite completion.
- At the next poll group 3 (`139371665344`) had started toolchain build; group 4 (`139371666093`) remained queued. Board-functional remains gated behind all four groups. Continue the same run; inspect groups 3–4 and board job when complete.


## 167. RTL uncovered group 3 active; current continuation state — 2026-11-26 (Asia/Dhaka)

- Re-polled Actions run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), workflow `SUNNYONE remaining RTL and board regressions`, run #118, candidate SHA `7320c187810cbd7e4f106f0280922871f6430d1b`.
- Group 1 job `139371666058`: completed SUCCESS, exact pytest result **12 passed, 205 deselected**, 0 failures/errors/skips; artifact ID `15047592555`.
- Group 2 job `139371665991`: completed SUCCESS, exact pytest result **24 passed, 193 deselected**, 0 failures/errors/skips; artifact ID `15049479359`.
- Group 3 job `139371665344`: **IN_PROGRESS** at `Run bounded RTL selection`. Verilator 5.044 build and dependency installation completed successfully. No terminal pytest result or artifact is available yet.
- Group 4 job `139371666093`: **QUEUED**. Board-functional is not yet listed/running because it depends on all four RTL groups succeeding.
- Groups 1+2 contribute 36 verified scoped passes on this candidate SHA, in separate jobs. Do not infer group 3/4 or board results, and do not call the entire RTL regression green.
- Continue polling the same run. After each job reaches a terminal state, inspect its complete log and uploaded artifact; if any job fails/cancels, diagnose and retry only the affected scope without weakening selectors. Do not duplicate or alter the active workflow.
- Manufacturer readiness remains **NOT READY**; keep main protected and zero-spend constraints in force.


## Continuation checkpoint — 2026-11-26 (Asia/Dhaka)

The prior Actions run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), candidate SHA `7320c187810cbd7e4f106f0280922871f6430d1b`, was cancelled during RTL uncovered group 3. This was an orchestration cancellation, not a reported assertion failure. The group-3 log shows multiple tests passed before cancellation but contains no terminal pytest summary; therefore **no group-3 pass count is credited**. Original run attempt 1: group 1 passed 12, group 2 passed 24, group 4 passed 5; board-functional was skipped because the RTL matrix did not complete successfully. The verified completed-group subtotal is 41 tests, not full RTL acceptance.

A targeted rerun of only the cancelled group-3 job was requested using GitHub's per-job rerun action. Run attempt 2 is now `IN_PROGRESS`; active group-3 job ID `139448997925`. The existing successful groups 1, 2 and 4 remain successful in the rerun attempt. Inspect group 3's terminal pytest summary and artifact before crediting it. Then verify whether the dependency-gated board-functional job starts; if it does, inspect its terminal log and artifact. Do not start a duplicate workflow or rerun successful groups unnecessarily.

Current evidence status: RTL uncovered OPEN; board-functional OPEN / not yet evidenced; consolidated regression pending. Keep exact-SHA evidence, feature-branch-only writes, zero-spend rule and protected `main`. Manufacturer handoff remains **NOT READY**; no PPA, physical, production-IP, hardware, silicon or commercial signoff is implied.


## Follow-up poll — 2026-11-26 (Asia/Dhaka)

Run [45661335812](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), attempt 2, remains **IN_PROGRESS**. Group 1 job `139448999795`, group 2 `139449077187`, and group 4 `139449080038` are all **SUCCESS**. Their attempt-2 log artifacts are present: group 1 ID `15047592555`, group 2 ID `15049479359`, group 4 ID `15054188046`. Group 3 job `139448997925` is still in the pinned Verilator 5.044 build step; a group-3 artifact ID `15053746948` is listed, but because the job is active it is not treated as a terminal pytest report and no pass count is credited. Board-functional is still absent/not started because the four-group matrix has not completed. Next: allow this single job to finish; inspect its terminal log and artifact, then verify board-functional eligibility and results. Do not create another run.


## Continuity update — 2026-11-26 (Asia/Dhaka)

- Correct working repository: `shamiursunny/openTPU`; active feature branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- RTL/board workflow under inspection: [run 45661335812, attempt 2](https://github.com/shamiursunny/openTPU/actions/runs/45661335812), run head/tested SHA `7320c187810cbd7e4f106f0280922871f6430d1b`. The current feature-branch HEAD at documentation time is `044ba53c7861af8235a3f8828c89656f85b5f503`; the run SHA is an ancestor of the current branch tip, not the current tip. Preserve both references distinctly.
- Latest run metadata read at 2026-11-26 01:40 Asia/Dhaka reports `in_progress`. Latest jobs snapshot: RTL uncovered groups 1, 2 and 4 are `success`; group 3 is `in_progress`. Its checkout, Python 3.12 setup, pinned Verilator 5.044 build and dependency installation succeeded; bounded RTL pytest remains in progress. No terminal summary or new test count is credited for group 3.
- Board-functional has not started. The workflow file at the tested run SHA contains `board-functional.needs: rtl-uncovered`, so board execution is gated behind the complete RTL matrix. Do not trigger board-functional separately.
- Group 3 log retrieval returned GitHub storage `BlobNotFound`; this is an unavailable live log, not evidence of a test failure. Re-fetch after terminal state and inspect logs/artifacts and pytest summary.
- Do not count partial/cancelled output or add unverified counts. Previously verified baselines remain software-core **825 passed, 3 skipped**; subsystem/memory **377 passed, 1 configuration-inapplicable skip**; WAITC run `45641472720` **268 passed, 2 skipped, 0 failures**.
- Next sequence: (1) poll run `45661335812` to terminal; (2) inspect group 3 and all four group logs/artifacts, reconcile exact non-overlapping pytest totals; (3) confirm board-functional starts only after all RTL matrix jobs succeed, then inspect its terminal log/artifact; (4) run consolidated regression only after both gates pass; (5) update continuity records with exact current branch and tested SHAs plus evidence.
- Keep protected `main` unchanged. No test removal/weakening, no unapproved expenditure or hardware purchase. Consolidated regression, PPA/physical signoff, production PHY/IP, DFT, CDC/RDC, board electrical validation, real-hardware power/thermal/performance, silicon qualification and commercial readiness remain open. Manufacturer handoff remains **NOT READY**.


## 20. RTL group 3 split to prevent long-running job bottleneck (2026-11-25)

- Updated `.github/workflows/sunnyone-rtl-functional.yml` on the active branch in commit `c638a84d85429a3c3a30989acfb62ba70c36e24a`.
- Original group 3 selection was split into two independently logged matrix jobs: **3.1** runs only `gathers_through_the_hub` (the dominant long-running parametrized test); **3.2** runs `tmem_random_traffic`, `tmem_random_traffic_input_stage`, `tmem_dump_is_the_ram`, and `mlp_4bit_rtl`. Group 1, 2 and 4 selections remain unchanged.
- RTL matrix job timeout increased from 45 to 90 minutes to provide adequate headroom for the isolated hub-gather simulation and toolchain build. Board-functional remains gated on every RTL matrix job succeeding.
- New workflow run **45692968740** (run #119) was created by the workflow update and was pending/queued at checkpoint time. Original run **45661335812** (run #118, attempt 3) remained in progress at last observation; do not assume it was cancelled or completed until status is rechecked.
- The earlier attempt's groups 1, 2 and 4 had succeeded; partial group-3 output showed 36 passes before cancellation, but no terminal pytest summary. Those partial results are not promoted to a completed group result. The new split run must supply terminal evidence for both 3.1 and 3.2.
- Next: inspect run 45692968740 jobs; verify the new job names and matrix; wait for groups 1, 2, 3.1, 3.2 and 4 to finish; inspect each artifact/pytest summary; then confirm board-functional runs only after all five succeed. Keep exact pass/skip/fail counts evidence-based.
- Protected `main` remains untouched. Consolidated regression, physical/PPA, board electrical, production IP/PHY, DFT, CDC/RDC, hardware power/thermal/performance, silicon qualification and manufacturer readiness remain open. Manufacturer handoff remains **NOT READY**.


## 2026-11-26 CI efficiency correction
- Historical verification audit: run #118 (`45661335812`) completed RTL group 1 job `139481341057` and group 2 job `139481272407` with `success`.
- The `tests/test_rtl.py` blob at run #118 commit `7320c187810cbd7e4f106f0280922871f6430d1b` is byte-identical to the current branch blob (`84cdfed65c2c9d3604e51080ce88d878fc71a76a`). The exact group 1 and group 2 test selections therefore have unchanged test source. These groups are accepted as historical passes and removed from the next matrix run to avoid redundant execution.
- Group 4 was `cancelled` in run #118 (`139481274581`); do not mark it passed from that run. The older successful RTL-tail suite (#91, job `139171823473`) ran a different eight-test selection and does not establish group 4 coverage. Group 4 remains required.
- Workflow updated in commit `fd2a310b303d94226c1e65efa0e63b767ac747f4`: matrix now contains only groups 3.1, 3.2 and 4; group 1/2 historical evidence is recorded in workflow comments.
- New workflow run #120 (`45693821197`) is pending on commit `fd2a310b303d94226c1e65efa0e63b767ac747f4`. Run #119 (`45692968740`) was created from the previous matrix and is superseded; its jobs were interrupted/cancelled after the workflow change. Confirm #120 jobs and conclusions before counting new passes.
- Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5` at the last verification. Manufacturer handoff remains NOT READY; this CI correction does not close outstanding PPA, formal, CDC/RDC, integration, physical implementation, power/thermal, or commercial validation work.

## Cross-chat continuation checkpoint — 2026-11-26 (Asia/Dhaka)

Authoritative working location: repository shamiursunny/openTPU; branch sunnyone/commercial-profitability-architecture-2026-11-23. Latest branch HEAD verified immediately before this checkpoint: 40dd0643f7e386751103bfa10f0d91b658e88dba. Protected main independently listed at d84db55712aba0d40811d7762cb052f05d55b7e5; do not write to or merge into main.

Active CI: RTL functional workflow run 45693821197 (https://github.com/shamiursunny/openTPU/actions/runs/45693821197), run head fd2a310b303d94226c1e65efa0e63b767ac747f4. Live job snapshot:
- Group 3.1 job 139486043538: IN_PROGRESS, building pinned Verilator 5.044; checkout and Python setup succeeded; dependency installation and pytest have not started.
- Group 3.2 job 139486044115: QUEUED.
- Group 4 job 139486044169: QUEUED.
- Board-functional depends on the complete RTL matrix; do not start it manually. No new group-3.1/3.2/4 pass count is credited yet.

Verified historical selection evidence: Groups 1 and 2 are accepted from successful run #118 (45661335812) because current tests/test_rtl.py is byte-identical to the tested blob (SHA 84cdfed65c2c9d3604e51080ce88d878fc71a76a). Group 1 and group 2 jobs in #118 were SUCCESS. Group 4 was CANCELLED in #118 and is not a pass; the older RTL-tail run covers a different selection. Current run #120 deliberately runs only groups 3.1, 3.2 and 4. Do not duplicate groups 1/2 unless test source or environment changes.

Immediate continuation sequence for any new chat/tab:
1. Read this checkpoint plus the latest sections of all three continuity files before making changes.
2. Re-query branch HEAD and run #120 jobs; never rely on the saved in-progress status without live polling.
3. Poll group 3.1, then 3.2 and group 4; for each terminal job inspect the full log/artifact and pytest terminal summary. Credit only exact observed pass/skip/fail counts. Diagnose failures from logs and make minimal fixes without weakening/removing tests.
4. After every RTL matrix job succeeds, verify the gated board-functional job starts; inspect its full log/artifact and terminal summary. If RTL fails, board should remain gated.
5. Only after RTL and board gates pass, proceed to consolidated regression and then the remaining integration/formal/physical/PPA/IP/board/hardware/commercial gates. Keep manufacturer handoff NOT READY until evidence closes those gates.
6. After each material engineering step, update PROJECT_TRACKER, MANUFACTURER_HANDOFF_READINESS and PROJECT_RESUME on this feature branch with exact SHA, run/job IDs, logs, counts, limitations and next action. Re-check branch HEAD and main before writes.

Guardrails: serial/low-concurrency execution; no duplicate jobs without cause; no invented test counts; no test weakening; zero spend and no hardware purchase without explicit approval; no claims of tapeout/production readiness from simulation-only evidence. Continue the user's requested remaining engineering work autonomously within these constraints.




## Live continuation correction — 2026-11-26 (Asia/Dhaka)

- Active RTL workflow run [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), tested workflow SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`. Group 3.1 job `139486043538` is IN_PROGRESS at the bounded pytest selection; pinned Verilator 5.044 build and dependency installation succeeded. Group 3.2 job `139486044115` and group 4 job `139486044169` are QUEUED. Board-functional remains dependency-gated and must not be started manually.
- Historical group 4 evidence was rechecked directly: job `139449080038` log from run `45661335812` ends with **5 passed, 212 deselected, 0 failures**. The tested `tests/test_rtl.py` blob `84cdfed65c2c9d3604e51080ce88d878fc71a76a` is byte-identical at run SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`. This is valid historical group-4 evidence despite a later checkpoint describing the run's other attempt as cancelled. The current run's group-4 job is therefore a duplicate verification; let the already-running serial workflow finish, but do not count its passes as additional unique tests.
- Groups 1 and 2 remain accepted historical passes; their test source is unchanged. Do not rerun them absent source/environment changes.
- Current exact-SHA source check: old and current `tests/test_rtl.py` blob SHAs both equal `84cdfed65c2c9d3604e51080ce88d878fc71a76a`.
- Next: poll run `45693821197`; inspect terminal pytest logs and artifacts for 3.1, 3.2 and 4; then inspect board-functional only if all RTL jobs succeed. Reconcile unique coverage and update the three continuity files. Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; manufacturer readiness remains NOT READY.


## 130. Uncovered RTL split verification — Groups 3.1 and 3.2 passed; Group 4 still running (2026-11-26, Asia/Dhaka)

- Active feature branch HEAD at checkpoint start: `6339f46aba4fa88041c38fe73cee86eac53fbde5`. Protected `main` independently rechecked at `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Workflow [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), exact tested SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`, is still IN_PROGRESS overall.
- Group 3.1 job `139486043538`: SUCCESS. Full log confirms **8 passed, 209 deselected, 0 failed** in 1,875.28 s (31m15s). Artifact `15062436327` (`sunnyone-rtl-uncovered-3.1-log`) uploaded successfully.
- Group 3.2 job `139486044115`: SUCCESS. Full log confirms **33 passed, 184 deselected, 0 failed** in 529.45 s (8m49s). Artifact `15064162074` (`sunnyone-rtl-uncovered-3.2-log`) uploaded successfully.
- Both jobs used Python 3.12.16, pytest 9.2.0 and pinned Verilator 5.044; checkout confirms exact candidate SHA `fd2a310...`. The selected tests were `test_tmem_random_traffic`, `test_tmem_random_traffic_input_stage`, `test_tmem_dump_is_the_ram`, and `test_mlp_4bit_rtl` for Group 3.2; Group 3.1 selected its bounded uncovered RTL selection as defined by the workflow. Warnings include upstream Verilator build guidance and GitHub Actions Node 20 deprecation notices; no test failures were logged.
- Group 4 job `139486044169`: still IN_PROGRESS at the latest poll. Checkout, Python setup, Verilator build and dependency installation completed; the bounded RTL selection is running. Its log endpoint returned Azure BlobNotFound while live, so no Group 4 pytest result is inferred. Do not launch a duplicate job.
- Historical Groups 1 and 2 passes remain valid on their own tested source; historical Group 4 pass from earlier run `45661335812` remains a distinct historical record, but it does not replace the currently running Group 4 attempt. Avoid adding overlapping run counts as unique test cases.
- No board-functional completion is established by these three uncovered-RTL jobs. Board-functional remains dependency-gated until the complete RTL matrix is successful.
- Next: poll job `139486044169` to terminal; inspect its full log and artifact. Then verify the run's dependent board-functional job, followed by consolidated regression and remaining integration/formal/lint/PPA gates. Preserve zero spend and protected `main`; manufacturer handoff remains NOT READY.



## Live continuation checkpoint — 2026-11-26 (Asia/Dhaka)

- Repository: `shamiursunny/openTPU`; all updates remain on feature branch `sunnyone/commercial-profitability-architecture-2026-11-23`. Branch tip before this checkpoint: `5cc9b8583786bd5a529b0008363aebdc8a547360`. Protected `main` independently verified unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`; do not modify or merge into it.
- RTL workflow [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), tested SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`:
  - Group 3.1 job `139486043538`: SUCCESS; exact terminal summary **8 passed, 209 deselected, 0 failed**; artifact `15062436327`.
  - Group 3.2 job `139486044115`: SUCCESS; exact terminal summary **33 passed, 184 deselected, 0 failed**; artifact `15064162074`.
  - Group 4 job `139486044169`: SUCCESS; downloaded artifact `15062269952` and inspected complete log; exact terminal summary **5 passed, 212 deselected, 0 failed** (336.28 s).
  - Historical groups 1 and 2 remain accepted from unchanged test source: **12 passed** and **24 passed**, respectively. Do not rerun or double-count them. The newly verified group selections 3.1 + 3.2 + 4 add 46 scoped passes; the four groups 1/2/3.1/3.2/4 together have 82 scoped pass executions. This is not a claim of 82 unique lifetime tests or full RTL acceptance without selector overlap reconciliation.
- The workflow's dependency-gated board-functional job `139521841026` has started only after all three currently scheduled RTL matrix jobs succeeded. At the latest live poll it remained **IN_PROGRESS** at the host-driver and board-model regression command; setup, checkout, Python, Verilator installation and project dependencies all succeeded. Its workflow timeout is 45 minutes. No board test count is credited until its terminal log/artifact is inspected. Do not start another board job or duplicate workflow.
- Current action: poll job `139521841026`; when terminal, inspect complete log and artifact, record exact pytest counts and failures/skips. If it passes, proceed to consolidated regression only if its defined prerequisites are satisfied; then continue remaining integration/formal/lint/PPA/physical/IP/PHY/DFT/board-electrical/hardware/commercial gates. If it fails, diagnose the actual failing tests and make minimal fixes without weakening selectors.
- Manufacturer handoff remains **NOT READY**. Selected RTL simulation success is not full formal proof, CDC/RDC closure, physical signoff, production PHY/IP readiness, board electrical validation, hardware performance/power/thermal evidence, silicon qualification, or commercial validation. Maintain zero-spend/no-hardware-purchase without explicit approval.


## Continuation checkpoint — 2026-11-26 (Asia/Dhaka)

- Repository: `shamiursunny/openTPU`; active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Branch HEAD before this documentation update: `ea8c7b430bf4cd695ceff902c1f01daea7d6bfd3`. Protected `main` independently verified at `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare reports 694 commits ahead / 0 behind. Do not modify or merge into `main`.
- RTL/board workflow: [run 45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), tested SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`, attempt 3. Groups 3.1, 3.2 and 4 are SUCCESS (8, 33 and 5 selected passes respectively; no failures). Historical Groups 1 and 2 remain accepted from unchanged source (12 and 24 selected passes). These are scoped selector counts, not a claim of 82 unique lifetime tests.
- The previous board-functional execution `139559281157` was CANCELLED after approximately 83% progress. Its log records passing tests through that point, but no terminal pytest summary; five Qwen/PyTorch-dependent tests were skipped because PyTorch was unavailable. No board-functional PASS is credited.
- A single-job retry was accepted. Current retry job `139677036786` (same workflow run) is IN_PROGRESS at the host-driver and board-model regression command. Checkout, Python setup, Verilator installation and dependency installation succeeded. Poll this exact job; do not start another workflow or manually bypass its dependency gate.
- PPA audit: research run [45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546), tested SHA `c568020d91efd045c6dd5d89dbc30ebdbac2c866`, FAILED in ORFS stage `2_4_floorplan_pdn`. Synthesis and floorplanning completed; generated SRAM inventory reported 288 macros / 3,538 KiB. The PDN log contains repeated PDN-0110 no-via warnings and a PDN-1051 empty macro-grid warning; the flow then exits at `check_placement -fixed -verbose` (ORFS exit 2 / make Error 247). The available log does not establish the precise root cause, so the warnings are diagnostic leads, not a proven causal explanation. Preliminary floorplan timing was WNS -10.43 ns and TNS -91.46 ns. The report's 5.95 W power estimate is a pre-route library/activity estimate, not measured silicon or board power. No signoff PPA result exists.
- The PPA artifact `14997807086` was downloaded and inspected; logs/reports/configuration evidence retained in the workflow artifact. Do not retry the same PPA unchanged. First isolate the PDN/placement failure and review macro-grid/strap/via geometry and floorplan constraints; preserve all physical checks.
- Additional existing CI evidence audited: ASIC target/config run `45598047221` SUCCESS; full-chip Verilator lint `45598047313` SUCCESS; address-map formal proof `45598047300` SUCCESS; PCIe Gen2 bridge simulation `45598047330` SUCCESS; RTL-tail run `45598047232` SUCCESS; WAITC run `45641472720` SUCCESS. These are historical tested-SHA results, not proof that every later RTL change was retested.
- Immediate next sequence: (1) poll board retry `139677036786` to terminal and inspect full log/artifact; (2) if it passes, define and run a consolidated regression on the then-current immutable candidate SHA; if it fails, diagnose actual failures without weakening tests; (3) investigate PDN/placement failure before requesting another PPA run; (4) continue CDC/RDC, broader formal, integration/IP/PHY/DFT, board electrical, hardware power/thermal/performance, silicon and commercial gates.
- Manufacturer handoff remains **NOT READY**. No tapeout/production readiness claim. No paid resources or hardware purchase authorised; maintain zero-spend and do not weaken/remove tests.


## Live continuation poll — 2026-11-26 03:47 UTC (Asia/Dhaka)

- Latest working-branch HEAD before this note: `171474b5b0783b72c23732b7c9acba3e48ec023b`; protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5`. GitHub comparison: 697 commits ahead, 0 behind. Main remains unchanged.
- Existing workflow run [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), attempt 3, remains `in_progress`, testing SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`.
- Board-functional job `139677036786` remains `in_progress`. Latest step poll: setup, checkout, Python setup, Verilator installation and dependency installation all succeeded; step 6, “Host driver and board-model regressions (AXI-Lite isolation already verified separately)”, is still running; artifact upload has not started. GitHub job-log download returned 404/BlobNotFound while the job is active, so no fresh test output or terminal summary is available yet.
- RTL uncovered groups 3.1, 3.2 and 4 remain completed successfully in this run. Do not infer board-functional pass from elapsed time or setup success.
- No new RTL/verification source changes were made during this continuation. The only pending action is to poll the same job/run to terminal, then inspect its log and uploaded artifact. Do not dispatch duplicate workflows, cancel the job, or bypass skipped dependency-dependent tests.
- Existing PPA blocker and manufacturer-handoff NOT READY status from the prior 2026-11-26 checkpoint remain unchanged. No physical signoff, measured silicon/board power, hardware qualification, tapeout readiness, paid spend or production readiness is claimed.


## Board-functional verification result — 2026-11-26 05:59 UTC (Asia/Dhaka)

- Workflow run [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), attempt 3, tested source SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`. The board-functional job `139677036786` is now terminal with conclusion **CANCELLED**. It ran from 03:41:51 UTC to 04:27:03 UTC (about 45 minutes); GitHub log ends with “The operation was canceled.” Do not classify this as a pass or infer a specific cancellation cause beyond the recorded cancellation.
- The board-model pytest log shows the selected regression progressing through 82%. All displayed executed tests before cancellation are marked PASSED; five Tiny-Qwen/Qwen3 cases were SKIPPED because `torch` is not installed. The run ended before pytest emitted a terminal summary, so no complete pass/fail/skip totals can be claimed and the board-functional gate remains **NOT PASSED / INCOMPLETE**.
- Board log artifact uploaded successfully: [sunnyone-board-functional-log, artifact 15086344970](https://github.com/shamiursunny/openTPU/actions/runs/45693821197/artifacts/15086344970). This preserves partial logs only, not a complete test report.
- In the same run, RTL uncovered groups 3.1, 3.2 and 4 all completed SUCCESS. Group 3.2 log explicitly reports **33 passed, 184 deselected**; groups 3.1 and 4 completed successfully with their existing scoped selectors (8 and 5 selected passes respectively). These scoped selector counts are not a consolidated unique-test total.
- Current branch ref verified at `663433351457c32b0f059bf094fa2b628ff4ea9d`; protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. GitHub compare reports 700 commits ahead, 0 behind. No RTL or verification source changes were made in this continuation; only project records are being updated.
- Next action: inspect workflow configuration and board-test execution cost/runtime to determine a safe, evidence-preserving way to complete the full board-functional gate. Do not weaken, deselect, or skip required tests; do not claim success from partial progress. Keep zero-spend. Manufacturer handoff remains **NOT READY**; PPA/physical signoff and hardware qualification blockers remain open.


## Timeout correction and retry launched — 2026-11-26 06:02 UTC (Asia/Dhaka)

- Root cause of incomplete board gate is now narrowed to the workflow's explicit `timeout-minutes: 45`: job `139677036786` ran approximately 45m 12s and GitHub recorded cancellation before pytest's final summary. This is a workflow time-budget limitation, not an observed test assertion failure.
- Updated only `.github/workflows/sunnyone-rtl-functional.yml`: board-functional `timeout-minutes` increased from 45 to 90. Test command, selector, test code and assertions are unchanged. RTL uncovered job timeout remains 90.
- The workflow push automatically queued new run [45765362426](https://github.com/shamiursunny/openTPU/actions/runs/45765362426), run number 121, attempt 1, event push, tested workflow/source commit `455a03232c90b8e631a5add6cd7bebff4afdccad`. At checkpoint time it is **QUEUED**; no result is claimed. Poll this exact run. Its RTL groups will run first due to the workflow dependency graph; board-functional starts only after they succeed.
- The previous run's five Tiny-Qwen/Qwen3 skips remain documented as dependency-related (`torch` absent); do not mislabel them as passes. No test has been removed or weakened.
- Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Maintain zero-spend. Manufacturer handoff remains **NOT READY** pending full regression and outstanding physical/hardware gates.


## Qwen verification feasibility and checkpoint — 2026-11-26 06:15 UTC (Asia/Dhaka)

- Repository inspection confirms an existing Qwen verification foundation. `tests/test_qwen35.py` exercises tiny Qwen3.5 configurations against Hugging Face reference logits and the software/ISA model path, including FP4 emulation and board configuration. Its module uses `pytest.importorskip("torch")` and `pytest.importorskip("transformers")`; therefore missing dependencies can turn the module into a skip rather than a pass.
- `tests/test_models_on_board_rtl.py` is the direct real-checkpoint RTL gate. It targets Qwen3-0.6B and Qwen3.5-0.8B (alongside LFM2.5), uses FP4 weights and an INT8 LM head, exercises MCOLS=2 and 4, and compares RTL logits plus DRAM state against the ISA execution. It is marked slow and requires `--runslow`. If a model directory is absent it explicitly skips that model case.
- The current `.github/workflows/sunnyone-rtl-functional.yml` board-functional command runs `tests/test_board.py`; it does **not** invoke `tests/test_models_on_board_rtl.py`. Thus the current board-functional regression is not evidence of end-to-end Qwen inference on RTL.
- A dedicated Qwen workflow is the next recommended engineering item, but has **not yet been added or run**. Before adding it, inspect dependency pins, model-download/licensing/source integrity, checkpoint storage and runner disk/RAM/runtime. The gate must distinguish required real-checkpoint tests from optional tests; fail clearly if required checkpoint material is unavailable rather than silently green-skipping. Keep any download/cache public, reproducible and zero-spend; do not commit large model weights or secrets.
- Do not call simulated RTL execution physical-hardware validation. Actual FPGA/board Qwen execution still requires the supported board, bitstream, driver, host interface and real measurements. No zero-bug guarantee is possible; acceptance requires layered regressions and recorded evidence.
- Latest poll of workflow run [45765362426](https://github.com/shamiursunny/openTPU/actions/runs/45765362426), run 121, attempt 1, tested SHA `455a03232c90b8e631a5add6cd7bebff4afdccad`: group 3.1 job `139724851662` was **IN_PROGRESS**; groups 3.2 (`139724852016`) and 4 (`139724852036`) were **QUEUED**; run-level status still **QUEUED**, no conclusion and no artifacts yet. Do not claim completion; poll this exact run.
- Protected `main` remains unchanged at `d84db55712aba0d40811d7762cb052f05d55b7e5`; working branch comparison last confirmed 707 ahead / 0 behind. Manufacturer handoff remains **NOT READY**. No RTL tests or assertions were weakened.


## Qwen real-checkpoint RTL gate added — 2026-11-26

- Added `.github/workflows/sunnyone-qwen-real-rtl.yml` in commit `d68e7aa3ff651ed03fc58537c93d4d2ab1913844`. This is a separate `workflow_dispatch`-only gate; it does not rerun the already-passed general RTL groups 3.1, 3.2 or 4.
- The gate downloads the official Apache-2.0 `Qwen/Qwen3-0.6B` checkpoint at revision `c1899de289a04d12100db370d81485cdf75e47ca` and `Qwen/Qwen3.5-0.8B` at revision `2b48083dfa97c3cbf0220cf1a5e6cffe0a511157`, verifies the downloaded repository contents, checks model types and safetensors presence, and uses CPU-only PyTorch plus safetensors.
- It runs only `tests/test_models_on_board_rtl.py` cases selected by `-k "qwen3 or qwen35"` with `--runslow`: Qwen3 and Qwen3.5 real-checkpoint RTL cases across MCOLS=2 and MCOLS=4. LFM2 cases are intentionally excluded from this Qwen-only gate.
- **Status: workflow added and read-back verified; NOT YET DISPATCHED; no Qwen RTL result claimed.** A green result must show the selected real-checkpoint cases actually executed and passed. This workflow is not a physical-board validation.
- The general RTL workflow run #121 (run ID `45765362426`) was still active at the latest check: group 3.1 in progress, groups 3.2 and 4 queued. The connected GitHub action set did not expose a cancel-run operation, so cancellation could not be sent from this session. Do not describe it as cancelled. User can cancel it from the GitHub Actions run page if it remains active.
- Previously completed RTL group 3.1, 3.2 and 4 results remain historical evidence; do not repeat those tests merely to reconfirm them.
- Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Branch comparison after adding the workflow: 711 ahead, 0 behind. Manufacturer handoff remains NOT READY.


## User-authorised continuation checkpoint — 2026-11-26 12:35 Asia/Dhaka

### Live repository state
- Repository: `shamiursunny/openTPU`.
- Active working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Branch HEAD before this continuity-only update: `0470472f4cc87a998c063a34c362fcde5f416f0a` (commit message: "Record dedicated Qwen real-checkpoint RTL gate").
- Protected `main` independently verified at `d84db55712aba0d40811d7762cb052f05d55b7e5`. Do not modify, merge into, or push project work to `main`.
- All project changes remain on the active feature branch. Zero-spend rule remains in force; no hardware, paid cloud, licences, or services may be purchased without explicit user approval.

### User's explicit no-rerun instruction
The user personally cancelled workflow run [45765362426](https://github.com/shamiursunny/openTPU/actions/runs/45765362426) and specifically confirmed that groups **3.1, 3.2 and 4 had already passed earlier**. GitHub now reports the run terminal as `completed / cancelled`; its jobs 139724851662 (3.1), 139724852016 (3.2), 139724852036 (4), and 139734601872 (board-functional) are cancelled. These cancellations are not failures and do not erase prior successful evidence. **Never rerun groups 3.1, 3.2 or 4 merely to reconfirm them.** Also preserve accepted historical groups 1 and 2; do not rerun those without a specific source-change/regression reason.

Accepted earlier successful evidence from workflow run [45693821197](https://github.com/shamiursunny/openTPU/actions/runs/45693821197), attempt 3, tested source SHA `fd2a310b303d94226c1e65efa0e63b767ac747f4`:
- Group 3.1 job 139677037811: SUCCESS, 8 passed.
- Group 3.2 job 139677071195: SUCCESS, 33 passed.
- Group 4 job 139677038294: SUCCESS, 5 passed.
- Historical groups 1 and 2 remain accepted from their previously recorded unchanged-source runs (12 and 24 selected passes respectively).
These are scoped selector results; do not add them into a claim of unique lifetime tests without overlap reconciliation.

### Board-functional status
- Board-functional job 139677036786 in run 45693821197 was CANCELLED at approximately 45 minutes before pytest emitted a terminal summary. Its partial log showed tests passing through approximately 82%, with five Qwen/PyTorch-dependent cases skipped because torch was absent in that job. This is **NOT a board-functional PASS**.
- The board timeout was subsequently increased to 90 minutes in `.github/workflows/sunnyone-rtl-functional.yml`. The newer run 45765362426 was cancelled by the user while its RTL groups were queued/running; its board job did not produce a new qualifying result.
- Do not restart the whole general RTL workflow just to get to board-functional, because that would repeat already-passed groups. If board-functional is next pursued, create/use a board-only workflow/job that executes the exact board selector without depending on or rerunning the passed RTL matrix. Preserve the test selector and assertions; do not weaken or skip required tests. Record a complete terminal pytest summary.

### Dedicated Qwen real-checkpoint gate
- Workflow file `.github/workflows/sunnyone-qwen-real-rtl.yml` exists and was read back from the active branch (blob SHA `eb48070c1c371dbc6232631445383fa21c48c812`).
- Test file `tests/test_models_on_board_rtl.py` read-back SHA: `eb9e0af47ffcf372ae98b794d2ee902a4a26ef67`.
- Workflow is `workflow_dispatch` only and has **NOT YET BEEN DISPATCHED**. No Qwen real-checkpoint RTL pass is claimed.
- It pins official Qwen3-0.6B revision `c1899de289a04d12100db370d81485cdf75e47ca` and Qwen3.5-0.8B revision `2b48083dfa97c3cbf0220cf1a5e6cffe0a511157`, checks downloaded checkpoint contents/model type/safetensors, installs CPU-only PyTorch 2.15.0 (valid for Python 3.12; PyTorch 2.15 supports Python >=3.11), and selects only Qwen3/Qwen3.5 cases with `--runslow` and `-k "qwen3 or qwen35"` for MCOLS=2 and 4. LFM2 cases are excluded.
- This is simulated RTL-vs-ISA bit-exact verification using real model checkpoints, not physical FPGA/board validation. Physical Qwen inference still requires actual supported hardware, bitstream, driver and measurements.
- The available connected GitHub actions do not expose a workflow-dispatch action. Do not claim it was dispatched. Next action is to manually dispatch this specific Qwen workflow from GitHub Actions when execution is available, then inspect its exact terminal log/artifact. Do not dispatch the general RTL workflow.
- Before dispatch, confirm the current branch HEAD still contains the above workflow and test-file revisions. If either changed, inspect the diff first.

### Immediate continuation order
1. Resume by reading this section, then the latest master task register and chronological tracker.
2. Re-check live feature-branch HEAD and protected `main`; inspect latest workflow status. Never trust a stale run state.
3. Preserve groups 1, 2, 3.1, 3.2 and 4 as already passed; no duplicate reruns.
4. Complete the dedicated Qwen real-checkpoint RTL gate (manual dispatch required) and inspect full pytest summary/artifact. If it fails, diagnose the actual error and make a minimal evidence-based correction.
5. Complete board-functional using a board-only execution path, not the general RTL matrix. Do not count the cancelled partial run as a pass.
6. Continue remaining consolidated regression, shared-DIMM integration, formal/property coverage, CDC/RDC, lint, PPA/physical implementation, production PCIe/DMA and DDR controller/PHY, DFT, electrical board validation, hardware performance/power/thermal, silicon and commercial feasibility gates.
7. Investigate the already-recorded Nangate45/OpenROAD PDN/placement failure before any PPA retry; do not repeat the unchanged failing run.
8. Keep manufacturer handoff **NOT READY** until all applicable release gates have actual evidence. Never claim production/tapeout readiness or zero bugs from simulation-only evidence.
9. After each meaningful task, update this resume guide, `PROJECT_TRACKER.md`, and `SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md` with exact source SHA, run/job IDs, terminal counts, limitations and next action. Re-fetch all three after writes to verify.
10. In any new chat/tab, the user can simply say **"continue and complete the remaining tasks"**. Start from this checkpoint and current live GitHub state; do not ask the user to repeat the no-rerun instruction.



## Board-only regression isolation update — 2026-11-26 (Asia/Dhaka)

- To complete the incomplete board-functional gate without repeating already-passed RTL groups, added `.github/workflows/sunnyone-board-functional-only.yml` in commit `aedda576e489a297f9452c1cd799072014b565b0`.
- The workflow is deliberately independent of the general RTL matrix. It runs only the existing board-functional selector: `pytest -vv -ra tests/test_board.py -k "not axil_iso_resets_apart"`. No test code, assertions or selector were changed. Timeout is 90 minutes. It uploads the complete log even on failure/cancellation.
- GitHub Actions automatically started board-only run [45769498674](https://github.com/shamiursunny/openTPU/actions/runs/45769498674), tested commit `aedda576e489a297f9452c1cd799072014b565b0`. Job `139738454299` is **IN_PROGRESS**. At the latest poll checkout and Python setup succeeded; Verilator installation was running; pytest had not started. No board test result is claimed yet.
- This run does not include groups 3.1, 3.2 or 4 and must not be described as rerunning them. Do not launch another board-only run while this one is active.
- Dedicated Qwen real-checkpoint workflow remains separate and undispatched. Do not trigger the general RTL matrix.
- Current branch HEAD at the time of this note: `aedda576e489a297f9452c1cd799072014b565b0`; protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Next action: poll only run 45769498674 / job 139738454299 to terminal; inspect the full pytest summary and uploaded artifact. If it passes, record exact counts; if it fails, diagnose without weakening tests. Then proceed to the Qwen real-checkpoint gate and remaining unclosed engineering gates.


## A1.12.11.16.55 — Board-only regression toolchain correction and Qwen gate dependency audit (2026-11-26)

- Board-only run [45769498674](https://github.com/shamiursunny/openTPU/actions/runs/45769498674), job 139738454299, completed FAILURE on source SHA aedda576e489a297f9452c1cd799072014b565b0. The workflow installed Ubuntu's Verilator 5.020. The board selector reported 133 failed, 65 passed, 8 skipped, 1 deselected; failures were dominated by the parser error at rtl/mxu/otpu_mxu.sv:2781 on bit-selecting a function-call result (bk_ad(rq_ad, rq_en)[b]). This is a simulator-version/toolchain failure, not a basis to rewrite or weaken the RTL. The already-passed RTL groups remain accepted and were not run in this board-only job.
- Corrected .github/workflows/sunnyone-board-functional-only.yml to build and assert pinned Verilator 5.044, matching the successful bounded RTL workflow's toolchain. Commit: 74ee09d865633e8d8f8cc3edaaf5cb460bf576cc.
- GitHub Actions automatically started board-only run [45784404427](https://github.com/shamiursunny/openTPU/actions/runs/45784404427), job 139787424587, on source SHA 74ee09d865633e8d8f8cc3edaaf5cb460bf576cc. At the time of this entry it is IN PROGRESS in the pinned Verilator 5.044 build step; pytest has not started. No board-functional pass is claimed. Poll this exact run to terminal and inspect its full pytest summary and uploaded log.
- Audited .github/workflows/sunnyone-qwen-real-rtl.yml and found an invalid PyTorch version pin torch==2.15.0 (the official PyTorch release list identifies 2.11.0 as a current release; 2.15.0 is not a valid published release). Corrected it to CPU-only torch==2.11.0; corrected the Hugging Face Hub pin from 2.4.0 to 2.3.0 based on current documented package release evidence. Safetensors remains pinned at 0.8.0. Official PyTorch CPU install reference: https://pytorch.org/get-started/previous-versions/ . Commit: 024e488befcbabdde21731f119b52baaedb9d10f. The Qwen workflow remains workflow_dispatch only and NOT DISPATCHED; no real-checkpoint Qwen RTL result is claimed.
- Current active branch HEAD at the time of this entry: 024e488befcbabdde21731f119b52baaedb9d10f. Protected main independently rechecked at d84db55712aba0d40811d7762cb052f05d55b7e5; comparison: 723 ahead / 0 behind. No changes to main.
- Next: (1) finish and inspect board-only run 45784404427; (2) dispatch the dedicated Qwen workflow when a workflow-dispatch mechanism is available (do not run the general RTL matrix); (3) continue the remaining integration, consolidated regression, formal/CDC/RDC, lint, PPA and physical/product qualification gates. Manufacturer handoff remains NOT READY. No test assertions were weakened.


## A1.12.11.16.56 — Cross-chat continuation checkpoint (2026-11-26, Asia/Dhaka)

This section is the latest resume instruction for any new ChatGPT chat/tab. When the user says “continue and complete the remaining tasks”, resume this SUNNYONE X AI CHIP DESIGN project from this checkpoint, read the current branch state and latest workflow results first, then update completed/remaining task records. Do not restart completed work.

- Repository: shamiursunny/openTPU. Active branch: sunnyone/commercial-profitability-architecture-2026-11-23. Latest branch HEAD when saved: 848b7f65884ae049c5a1a19fe4770b6e51d5692c. Protected main: d84db55712aba0d40811d7762cb052f05d55b7e5, independently rechecked unchanged. Keep all work on the active feature branch; never modify main.
- Hard exclusions: do NOT rerun historical RTL groups 3.1, 3.2 or 4 merely to reconfirm. Their previous successful evidence is preserved. Do not rerun workflow 45765362426 (user cancelled it). Do not launch the broad RTL matrix. No weakening/removal of tests or assertions to obtain a green result.
- Board-only run 45784404427 / job 139787424587 checks out source SHA 74ee09d865633e8d8f8cc3edaaf5cb460bf576cc. Latest poll: Verilator 5.044 build SUCCESS; project/test dependency installation SUCCESS; board-functional pytest step IN PROGRESS. No final board test result exists yet. Poll this exact run and inspect its final job summary and uploaded artifact before recording a pass/fail.
- Earlier board-only run 45769498674 failed under Verilator 5.020 (133 failed, 65 passed, 8 skipped, 1 deselected; parser failure at rtl/mxu/otpu_mxu.sv:2781). This is a toolchain compatibility failure, not evidence of a functional RTL mismatch. The board-only workflow now pins Verilator 5.044.
- Dedicated Qwen real-checkpoint workflow .github/workflows/sunnyone-qwen-real-rtl.yml was corrected: CPU PyTorch 2.11.0, huggingface_hub 2.3.0, safetensors 0.8.0; commit 024e488befcbabdde21731f119b52baaedb9d10f. It is workflow_dispatch only and remains NOT DISPATCHED; no Qwen real-checkpoint RTL pass is established. Dispatch only this dedicated workflow when the GitHub action is available; never invoke the general RTL matrix.
- Continuity files updated and read-back verified: this PROJECT_TRACKER.md; docs/sunnyone/SUNNYONE_AI-X_AUTHORITATIVE_CONTINUATION_BASELINE_A1.12.11.16.53.md; docs/sunnyone/SUNNYONE_AI-X_PROJECT_RESUME.md; docs/sunnyone/SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md.
- Remaining work: finish board-only run; dispatch/run dedicated Qwen checkpoint gate; review any board-test failures as real defects versus environment/tool issues; complete remaining shared-DIMM/adversarial and integration validation; consolidated regression; formal/property verification; CDC/RDC; full-chip lint; PPA and physical design; production PCIe/DMA/IOMMU and DDR controller/PHY/ECC integration; DFT and board/silicon electrical/thermal/power/performance qualification; update commercial/manufacturer evidence. Manufacturer handoff is NOT READY.
- Operational method: work serially and with low concurrency; inspect actual workflow logs/artifacts and source before edits; make narrowly scoped fixes; preserve evidence; update this tracker and the authoritative baseline/resume/handoff docs as tasks complete. Never report pending/in-progress work as passed.


## Board-functional regression completed — 2026-11-26 (Asia/Dhaka)

- Live branch before this documentation update: `sunnyone/commercial-profitability-architecture-2026-11-23`, HEAD `6bc0c781d3c58c47004f0ea35bd050c4fb8c0a66`. Protected `main` independently verified at `d84db55712aba0d40811d7762cb052f05d55b7e5`; unchanged. All updates remain on the feature branch.
- Board-only workflow run [45784404427](https://github.com/shamiursunny/openTPU/actions/runs/45784404427), job `139787424587`, tested source SHA `74ee09d865633e8d8f8cc3edaaf5cb460bf576cc`. Terminal conclusion: SUCCESS. Pinned Verilator 5.044 build and dependency installation succeeded; isolated board-functional pytest completed; log artifact upload succeeded.
- Exact pytest summary from the job log: **198 passed, 8 skipped, 1 deselected in 4158.05s (1:09:18)**. All eight skips were due to missing PyTorch (`torch` not installed), affecting torch-dependent tiny-Qwen board-model tests. The deselected test is `axil_iso_resets_apart`, excluded by the workflow's existing selector. This is a successful scoped board-model regression, not a complete test of the deselected or skipped cases and not physical-board validation.
- Artifact: `sunnyone-board-functional-only-log`, artifact ID `15104009648`, SHA-256 `fd8901eefabd4f990826abe072ca0f505f92919c1f8a9b4c59fda0915089a00a`; [download from workflow run](https://github.com/shamiursunny/openTPU/actions/runs/45784404427/artifacts/15104009648).
- Do not repeat RTL groups 3.1, 3.2 or 4; their earlier successful evidence remains accepted. Do not rerun cancelled general matrix run `45765362426`. No broad RTL matrix was launched.
- Dedicated Qwen real-checkpoint workflow `.github/workflows/sunnyone-qwen-real-rtl.yml` remains workflow_dispatch-only and undispatched; no real-checkpoint Qwen RTL result is claimed. The available GitHub integration in this session exposes no workflow-dispatch action, so manual dispatch remains outstanding. Board regression's eight PyTorch-related skips do not substitute for that gate.
- Remaining: dispatch and inspect Qwen real-checkpoint RTL gate; close the skipped/deselected test gaps deliberately; continue consolidated regression and four-DIMM shared-DIMM adversarial verification; formal properties; CDC/RDC; full-chip lint and configuration checks; WG8 PPA/physical implementation; production PCIe/DMA/IOMMU and DDR controller/PHY/ECC; DFT, board/silicon electrical and thermal/power/performance qualification; and evidence-backed commercial qualification.
- Manufacturer handoff remains **NOT READY**. This board-model simulation does not establish production PCIe, DMA, DDR PHY, formal/CDC/RDC, foundry PDK, physical signoff, silicon, measured power/performance/thermal or commercial qualification.


## Isolated AXI-Lite reset coverage queued — 2026-11-26 (Asia/Dhaka)

- The completed board-only run excluded exactly one test by its existing selector: `test_axil_iso_resets_apart`. Rather than rerunning the 198-pass board suite, added a narrow workflow `.github/workflows/sunnyone-axil-iso-reset-only.yml` to execute only this test, with pinned Verilator 5.044 and the same project/test setup. The test exercises `otpu_axil_iso` with independent master/slave resets, two seeds, and both isolation-enabled and bypass modes; it checks that responses do not cross a master reset and that each access receives the expected response.
- Workflow commit: `9af352cb36ad5599fd839cf12c8798ff8000ba92`; file read-back verified (blob `27b06f096ad0e368f1c758e4cf6aed5a5e58f054`). The workflow is configured for manual dispatch and a branch-scoped push trigger limited to its own file and relevant test/RTL dependencies. Commit status currently exposes no status checks; no run ID or test result is confirmed yet. Do not claim a pass until the actual Actions run and full log are inspected.
- The board-only regression evidence remains 198 passed, 8 skipped (all require missing PyTorch), 1 deselected. This new workflow is deliberately isolated and does not repeat completed RTL groups or the board suite.
- Qwen real-checkpoint workflow remains manual-dispatch-only and undispatched. The connected GitHub action interface has no workflow-dispatch operation; no Qwen checkpoint result is claimed.
- Current branch HEAD at this note: `9af352cb36ad5599fd839cf12c8798ff8000ba92`. Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`, unchanged. Manufacturer handoff remains **NOT READY**.


## Live continuation checkpoint — 2026-11-26 (Asia/Dhaka; latest verified branch SHA 6732bc47a7c5fd1b7c441e69e40f27a59c15a65a)

- AXI-Lite isolated test run [45806586835](https://github.com/shamiursunny/openTPU/actions/runs/45806586835), job 139863351015: checkout/Python setup passed; Verilator 5.044 build still IN_PROGRESS at latest poll; pytest not yet started.
- Qwen real-checkpoint workflow retains manual dispatch and now also has a tightly scoped push trigger for this feature branch and only its workflow/test/package/RTL/simulator/config dependencies. This was necessary because the available GitHub integration has no workflow-dispatch action. Commit 6732bc47a7c5fd1b7c441e69e40f27a59c15a65a triggered run [45807130675](https://github.com/shamiursunny/openTPU/actions/runs/45807130675), job 139865226090. Latest poll: checkout/Python setup passed; Verilator build IN_PROGRESS; dependencies, checkpoint downloads and tests not started. No test result claimed.
- Both CI jobs were simultaneously building Verilator at the last poll. Do not start further CI runs until they finish.
- Audited historical exact-SHA results: ASIC/target configuration 45598047221 SUCCESS (includes four-DIMM WG8 AXI top lint and simulation, address-map simulation, and four-DIMM HMUX contention); HMUX standalone 45598047225 SUCCESS; full-chip lint 45598047313 SUCCESS; 32-GiB address-map formal proof 45598047300 SUCCESS; RTL subsystem matrix 45598047338 SUCCESS across all listed jobs; PCIe Gen2 XDMA bridge simulation 45598047330 SUCCESS. These are bounded digital verification results, not production PCIe/DDR hardware, full-chip formal or physical signoff.
- WG8 PPA run 45545698546 failed at ORFS floorplan PDN/check_placement. Artifact 14997807086 shows process exit 247, ~15.7 GB peak memory and repeated M6-M7 via insertion warnings. Root cause is unconfirmed; PPA remains unqualified. Preserve logs and diagnose before any rerun; do not suppress PDN/placement checks.
- Preserve restrictions: do not rerun RTL groups 3.1, 3.2 or 4; do not rerun cancelled run 45765362426; no broad RTL matrix. Protected main remains d84db55712aba0d40811d7762cb052f05d55b7e5. All work on feature branch.
- Board-only run 45784404427 remains 198 passed, 8 PyTorch-dependent skips, 1 intentionally deselected. AXI-Lite isolated test is meant to cover the deselected case; Qwen checkpoint test is intended to exercise the model-dependent gate. No results from either new workflow until terminal logs are inspected.
- Outstanding: full adversarial DIMM protocol coverage beyond existing bounded four-DIMM contention tests; broader formal properties; CDC/RDC; WG8 PPA resource/root-cause and physical signoff; production PCIe endpoint/PHY and DMA/IOMMU; DDR controller/PHY/ECC; DFT; foundry PDK/macros; board/silicon qualification; measured power/performance/thermal; commercial/manufacturer qualification. Manufacturer handoff remains **NOT READY**.


### WG8 timing evidence from failed research PPA artifact — 2026-11-26
- Inspection of archived `2_floorplan_final.rpt` from PPA run 45545698546 shows core-clock floorplan WNS = **-10.43 ns**, TNS = **-91.46 ns**, and reported core-clock minimum period = **12.93 ns** (Fmax **77.31 MHz**). The project candidate SDC's 400 MHz / 2.5 ns target is therefore not met at this floorplan stage. This is pre-route research-flow timing evidence using the Nangate45/fakeram macro model, not final signoff STA or a silicon frequency measurement. No 400 MHz claim is permitted. This timing shortfall is an independent blocker from the later ORFS floorplan-PDN/check_placement failure.


### AXI-Lite independent reset test completed — 2026-11-26
- Dedicated run [45806586835](https://github.com/shamiursunny/openTPU/actions/runs/45806586835), job `139863351015`, source SHA `9af352cb36ad5599fd839cf12c8798ff8000ba92`: **SUCCESS**. Pinned Verilator 5.044 build and project/test dependency install succeeded. Exact pytest result: **1 passed, 206 deselected in 17.32s**; selected test `tests/test_board.py::test_axil_iso_resets_apart` passed. The test covers two seeds and both isolation-enabled and bypass cases for independent AXI-Lite master/slave resets. This closes the one deliberately deselected test from board-only run 45784404427; it does not mean the other 206 tests were rerun.
- Artifact `sunnyone-axil-iso-reset-only-log`, ID `15109822525`, SHA-256 `797304cbd415af26b0d2f6b624e4045e4a3ad75f70df37cd4ba104a904695a22`; [download from run](https://github.com/shamiursunny/openTPU/actions/runs/45806586835/artifacts/15109822525).
- Combined with board-only run 45784404427, the explicitly selected board test coverage now includes 198 passed + the isolated AXI-Lite reset test passed; the eight PyTorch-dependent tests remain gated by the active Qwen real-checkpoint run 45807130675 and are not yet closed.


### WG8 PPA retry resource guard prepared — 2026-11-26
- Updated `.github/workflows/sunnyone-asic-wg8-ppa.yml` to export `ORFS_CPUS=2` before the ORFS flow. `tools/asic/flow.py` explicitly maps `ORFS_CPUS` to both ORFS `NUM_CORES` and Docker `--cpus`. The prior failed run peaked at approximately 15.7 GB RSS and terminated at `check_placement`; the two-CPU limit is a resource-conscious diagnostic retry setting, not proof that memory pressure caused the failure. PDN/placement checks remain enabled and unchanged.
- Workflow update commit: `bf13801352dd7b684119b14145504314212fbb5c`. The PPA workflow intentionally excludes its own file from push triggers, so this change did not launch a new PPA run. No retry has been dispatched. Given the floorplan timing result (77.31 MHz vs 400 MHz target), further RTL timing optimization is required before treating PPA as a qualification gate.


### Clarification: eight PyTorch-dependent board skips are a separate gate
- Inspection of artifact `15104009648` confirms the eight skips are specifically: three `test_tiny_qwen3_on_board_model` format cases; two `test_tiny_qwen3_two_slices_on_board_model` cases; one `test_tiny_qwen3_generate_on_board_model`; and two `test_tiny_models_four_slices_wg_on_board_model` cases (Qwen3/Qwen3.5). All skip because `torch` is unavailable; these tests also call `pytest.importorskip("transformers")`.
- The currently active Qwen real-checkpoint workflow selects `tests/test_models_on_board_rtl.py -k "qwen3 or qwen35"`, a different test module and selection. Its eventual pass must **not** be counted as closing these eight board-test skips. A separate targeted run must install compatible CPU PyTorch and Transformers, then execute only the eight named board-test cases. Keep that as a separate follow-up gate; do not rerun the full board suite.


### Qwen checkpoint verification retry and eight tiny-model tests — 2026-11-26
- First Qwen run [45807130675](https://github.com/shamiursunny/openTPU/actions/runs/45807130675), job 139865226090, failed at `hf cache verify` after both pinned model downloads succeeded. The failure was a verifier invocation issue: `--fail-on-extra-files` treated Hugging Face's own `.cache/huggingface` metadata/lock files inside each `--local-dir` as extra model content. It was not a missing checkpoint or RTL failure.
- Corrected the checkpoint verification step to retain `--fail-on-missing-files` but omit `--fail-on-extra-files`; retained explicit model architecture, safetensors presence and total-size checks. The download/verification output is now tee'd to the artifact log. Commit `815399df0e4f8e36f3bbe80af474a3bcb5dbbf40` triggered retry run [45808346935](https://github.com/shamiursunny/openTPU/actions/runs/45808346935), job 139869385724. Latest poll: Verilator 5.044 build IN_PROGRESS; later steps not started. This run does not yet include the eight skipped board-test cases.
- A further scoped workflow update pins `transformers==4.57.3`, verifies the Qwen3 Transformers classes, and adds a separate pytest selection for exactly the eight previously skipped tiny board-model cases: `tiny_qwen3_on_board_model` (3 parameter cases), `tiny_qwen3_two_slices_on_board_model` (2), `tiny_qwen3_generate_on_board_model` (1), and `tiny_models_four_slices_wg_on_board_model` (2). It does not rerun the full board suite. Commit `b02f7de514ea1db1843864330da9d6831676a9f7` triggered queued run [45808406729](https://github.com/shamiursunny/openTPU/actions/runs/45808406729); no job has started yet at latest poll. The earlier retry is still running; the new run is queued by the workflow concurrency group.
- Do not count the Qwen real-checkpoint test selection as closing the eight tiny-model tests unless the later run's separate eight-test step completes successfully. Neither Qwen run has a terminal pass yet.


### Qwen tiny-model dependency compatibility correction — 2026-11-26
- Before the expanded tiny-model run could reach dependency installation, compatibility was rechecked: Transformers v5 requires Hugging Face Hub >=1.0.0, while the workflow pins Hub 2.3.0. Therefore the initial proposed Transformers 4.57.3 pin was incompatible and has been replaced before execution with `transformers==5.24.1`, the current stable v5 line documented by Hugging Face; the Qwen3Config/Qwen3ForCausalLM classes are present in the v5 documentation. CPU PyTorch 2.11.0 meets the documented PyTorch >=2.6 requirement.
- Workflow correction commit: `bddf9708657766951e5c0d204ef474d742e53418`. This triggers a new run and supersedes the queued/running earlier revision through the workflow's same-ref concurrency group. Do not count the earlier run as validating the tiny-model tests. Latest workflow source now pins Hub 2.3.0 + Transformers 5.24.1.


### Current Qwen comprehensive retry — 2026-11-26
- Finalized workflow revision commit `bddf9708657766951e5c0d204ef474d742e53418` pins `transformers==5.24.1` alongside CPU `torch==2.11.0` and `huggingface_hub==2.3.0`; this avoids the v4.x Hub<1.0 dependency conflict and is compatible with the Qwen3 classes used by the eight tiny-model tests. The workflow runs the real pinned Qwen3/Qwen3.5 RTL cases and then separately runs the exact eight previously skipped tiny board-model cases.
- Current run [45808551468](https://github.com/shamiursunny/openTPU/actions/runs/45808551468), job `139870207686`, source SHA `bddf9708657766951e5c0d204ef474d742e53418`: IN_PROGRESS; checkout and Python setup passed; pinned Verilator 5.044 build is running. No dependency install, model download or pytest result yet.
- Earlier run 45808346935 and queued run 45808406729 were cancelled by same-workflow supersession before their test stages. The original run 45807130675 remains a recorded failure at the false-positive extra-cache-file verification check; it did successfully download both checkpoint repositories.

## 11. Live continuation checkpoint — 2026-11-26 (Asia/Dhaka)

**Repository/branch:** `shamiursunny/openTPU` / `sunnyone/commercial-profitability-architecture-2026-11-23`. **Feature-branch HEAD before this documentation checkpoint:** `d60833aafa83f38d94c66ed610146cbcddaa3c57` (commit message: `docs(sunnyone): refresh Qwen continuation status`). **Protected main:** `d84db55712aba0d40811d7762cb052f05d55b7e5`, independently fetched and unchanged. Keep all work on the feature branch.

**User hard constraint:** RTL groups 3.1, 3.2 and 4 were already passed in earlier exact-SHA runs. Do not rerun them merely to reconfirm. Workflow run [45765362426](https://github.com/shamiursunny/openTPU/actions/runs/45765362426) was explicitly cancelled by the user; do not restart it. Preserve its cancellation.

**Focused AXI-Lite evidence:** the isolated AXI-Lite test was recorded as passed (1 passed, 206 deselected); this is a focused result, not a full regression.

**Real-checkpoint Qwen workflow:** [Run 45808551468](https://github.com/shamiursunny/openTPU/actions/runs/45808551468), workflow `.github/workflows/sunnyone-qwen-real-rtl.yml`, run number 4, exact run SHA `bddf9708657766951e5c0d204ef474d742e53418`, was live-checked at 2026-11-26 18:35 Asia/Dhaka and remained `in_progress`. Its only job, `Qwen3 and Qwen3.5 real checkpoints on RTL`, was `in_progress`. Steps 1–7 (checkout, Python setup, pinned Verilator 5.044, CPU-only dependencies, official Apache-2.0 checkpoint download/verification, and architecture/presence enforcement) were successful. Step 8 (real Qwen3/Qwen3.5 RTL cases, MCOLS 2 and 4) was running; step 9 (eight previously PyTorch-skipped tiny board-model cases) and step 10 (log upload) were pending. No Qwen test result is claimed yet. Do not cancel or rerun this run; poll it to terminal state, inspect logs/artifacts, and diagnose any failure without weakening assertions or substituting fake checkpoints.

**Remaining ordered work:** (1) close the existing Qwen run and record exact terminal result/counts; (2) if successful, inspect uploaded verification log and close the eight tiny-model cases; (3) perform only genuinely outstanding consolidated regression selections, excluding passed groups 3.1/3.2/4; (4) extend four-DIMM host/accelerator adversarial AXI coverage (sustained contention/fairness, all ports, byte strobes, reset with outstanding traffic, malformed/unaligned/4-KiB-crossing requests, ID collision/alias and response ordering); (5) formal/assertion review and full lint warning triage; (6) CDC/RDC; (7) reproducible WG8 timing/PPA research-proxy synthesis and report review; (8) PCIe endpoint/SerDes, DMA/IOMMU/address translation, DDR4 controller/PHY/training/ECC, SRAM macro, DFT, PDK/package/physical design and board feasibility; (9) silicon/electrical/thermal/reliability and real-workload qualification; (10) commercial demand, cost, TCO and unit-economics validation. These are open tasks, not completed claims.

**Maturity statement:** the WG8 V1 logical candidate is not a complete host-connected ASIC, tapeout-ready design, production-ready product, or silicon-validated device. No measured silicon throughput, power, thermal, yield, manufacturing cost or commercial payback is established. Preserve zero-spend approval and do not buy hardware, paid tools/IP/services or fabrication without explicit user approval.

**Next action on continuation:** first poll run 45808551468 and inspect its job/step results. Then update this tracker and the three companion continuity documents with the exact terminal evidence. Before every write, verify the active feature-branch head; never write to `main`.

### Qwen real-checkpoint and previously skipped tiny board-model tests — CLOSED (2026-11-26)

- Exact workflow [45808551468](https://github.com/shamiursunny/openTPU/actions/runs/45808551468), job `139870207686`, source SHA `bddf9708657766951e5c0d204ef474d742e53418`: **SUCCESS**. Actual decoded job log inspected; all setup, Verilator 5.044 build, CPU-only dependency installation, pinned official checkpoint downloads, checksum verification, architecture/safetensors checks and artifact upload completed successfully.
- Real checkpoint RTL selection `tests/test_models_on_board_rtl.py -k "qwen3 or qwen35"`: **6 passed, 4 deselected in 5817.40s**. Passed cases: `qwen3-2`, `qwen3-4`, `qwen35-2`, `qwen35-4`, `qwen35-dstep-2`, `qwen35-dstep-4`. The two pinned model checkpoint repositories were Qwen/Qwen3-0.6B at revision `c1899de289a04d12100db370d81485cdf75e47ca` and Qwen/Qwen3.5-0.8B at revision `2b48083dfa97c3cbf0220cf1a5e6cffe0a511157`; Hub checksum verification reported all 10 and 12 remote files matched respectively. Safetensors totals were 1,503,300,328 and 1,746,942,600 bytes, with expected `qwen3` and `qwen3_5` model types.
- Separate tiny board-model selection in `tests/test_board.py`: **8 passed, 199 deselected in 3395.97s**. All eight formerly PyTorch/Transformers-skipped cases passed: three tiny Qwen3 format cases, two two-slice cases, one generation case, and four-slice WG cases for Qwen3 and Qwen3.5.
- Combined result for this dedicated run: **14 selected tests passed across the two separate pytest invocations; 203 tests deselected across those invocations (4 + 199)**. Do not add these to other run totals as if they were one full-suite regression. No failures or skips in either selected invocation.
- Uploaded artifact `sunnyone-qwen-real-rtl-log`, ID `15122919007`, SHA-256 `0e33180ae7ab23408ce4bda5266045f07ff7fe7e61bfbc0afd36fa187fe77c78`; [download from run](https://github.com/shamiursunny/openTPU/actions/runs/45808551468/artifacts/15122919007).
- This closes the previously skipped eight tiny board-model test gate and the selected real-checkpoint Qwen RTL gate. It does not prove physical FPGA/ASIC operation, host PCIe electrical behaviour, DDR PHY, silicon PPA, measured power/thermal/performance or production readiness.
- Historical earlier paragraphs describing run 45808551468 as in progress are superseded by this terminal result; retain them as timestamped history, but use this closure entry as authoritative.

## 12. DMA stream-setup timing investigation and current CI — 2026-11-26 (Asia/Dhaka)

### 12.1 Qwen and tiny board-model gates closed
- Qwen run [45808551468](https://github.com/shamiursunny/openTPU/actions/runs/45808551468), exact SHA `bddf9708657766951e5c0d204ef474d742e53418`: SUCCESS. Actual logs inspected. Real pinned-checkpoint Qwen RTL: 6 passed, 4 deselected. Separate formerly skipped tiny board-model selection: 8 passed, 199 deselected. Both pinned checkpoint repositories passed checksum verification. Artifact 15122919007, SHA-256 `0e33180ae7ab23408ce4bda5266045f07ff7fe7e61bfbc0afd36fa187fe77c78`. This closes these selected tests only.

### 12.2 PPA artifact review and critical-path diagnosis
- Retrieved and inspected archived artifact 14997807086 from failed research PPA run [45545698546](https://github.com/shamiursunny/openTPU/actions/runs/45545698546). Exact synthesized design configuration was the WG8 candidate (D=128, MCOLS=8, WG=8, SE_R=2, DMA_DEPTH=512, AW=35, TMEM 128K, FIFO_DEPTH=2048), using the Nangate45/fakeram research proxy.
- Its floorplan timing report shows WNS -10.43 ns, TNS -91.46 ns, core-clock minimum period 12.93 ns / Fmax 77.31 MHz versus the 400 MHz (2.5 ns) SDC target. Worst max path: `u_slice/u_dma/sc[254]` to `u_slice/u_dma/g_sr.cpr_w[0]`. The endpoint is assigned in `rtl/dma/otpu_dma.sv` SRX stream setup; the source expression divides `su_ns` by a runtime-selected divisor `(ds_hw ? 2 * SPC : SPC)`. This is a strong candidate for a general combinational divider and a plausible source of the long path, but the exact synthesis cell-to-expression mapping has not been proven from the available report. The report is pre-route research timing, not signoff STA or silicon frequency.
- Implemented a semantics-preserving synthesis experiment in commit `2835f1a8da6af454023caff9576f41258c66e2a8`, `rtl/dma/otpu_dma.sv`: use a conditional selection between two compile-time constant-divisor results for cpr_r/cpr_w/rcw_r/bcw_r/rcw_w/bcw_w, instead of dividing by a runtime-selected divisor. This is an optimisation hypothesis pending regression and PPA evidence; no timing gain is claimed yet.

### 12.3 Exact-SHA verification triggered by the DMA change
All following runs were automatically triggered by the `rtl/dma/otpu_dma.sv` push-path filters on SHA `2835f1a8da6af454023caff9576f41258c66e2a8`; do not start more builds until they finish:
- Full-chip Verilator lint [45845758782](https://github.com/shamiursunny/openTPU/actions/runs/45845758782): SUCCESS.
- WG8 research PPA [45845758658](https://github.com/shamiursunny/openTPU/actions/runs/45845758658): IN_PROGRESS at last poll; pinned ORFS image setup passed, flow stage running. This is the key test of whether the critical-path hypothesis improves timing; inspect floorplan/route reports and all warnings before any claim.
- ASIC/target configuration, integrated lint and four-DIMM benches [45845758681](https://github.com/shamiursunny/openTPU/actions/runs/45845758681): IN_PROGRESS.
- Board-functional-only [45845758677](https://github.com/shamiursunny/openTPU/actions/runs/45845758677): IN_PROGRESS.
- RTL tail regressions [45845758636](https://github.com/shamiursunny/openTPU/actions/runs/45845758636): IN_PROGRESS.
- RTL subsystem/memory matrix [45845758545](https://github.com/shamiursunny/openTPU/actions/runs/45845758545): QUEUED overall; Stream RTL and MX multiply/replay jobs had started, others pending. This includes the relevant `tests/test_stream_rtl.py` selection and DMA/scoreboard suites.
- Reset/power-up synthesis audit [45845758496](https://github.com/shamiursunny/openTPU/actions/runs/45845758496): IN_PROGRESS.
- Real-checkpoint Qwen rerun [45845758847](https://github.com/shamiursunny/openTPU/actions/runs/45845758847): IN_PROGRESS; checkout/setup passed, pinned Verilator build running at last poll. This rerun is relevant because the DMA RTL changed; the earlier successful Qwen result remains valid for its earlier exact SHA.
- Software/ISA unit tests [45845758659](https://github.com/shamiursunny/openTPU/actions/runs/45845758659): QUEUED overall; ISA job passed, remaining software jobs queued.

### 12.4 Preventing accidental rerun of completed groups
- The DMA RTL change also matched the legacy broad workflow, which would have rerun groups 3.1, 3.2 and 4 despite the user's explicit no-repeat instruction. Added a guard in commit `4999b964d891d02fb93cb805162d5143dfbc4cea` to skip both legacy matrix and dependent board job. Original run [45845758638](https://github.com/shamiursunny/openTPU/actions/runs/45845758638) was cancelled by same-workflow concurrency before Verilator build completed; the group 3.1 Verilator build step was cancelled, and groups 3.2/4 test steps were skipped/cancelled. No group test was executed. Replacement run [45845941442](https://github.com/shamiursunny/openTPU/actions/runs/45845941442) completed with both jobs skipped. This is a workflow guard, not test evidence.
- User-cancelled run 45765362426 remains cancelled and must never be restarted. Previously passed groups 3.1/3.2/4 remain accepted from their historical evidence and are not repeated.

### 12.5 Branch and safety
- Active branch `sunnyone/commercial-profitability-architecture-2026-11-23`; latest branch HEAD after the workflow guard commit: `4999b964d891d02fb93cb805162d5143dfbc4cea`. Protected `main` independently rechecked at `d84db55712aba0d40811d7762cb052f05d55b7e5`, unchanged.
- No additional RTL or workflow edits until the triggered verification runs finish. Preserve zero-spend. The logical WG8 candidate is not tapeout-ready, production-ready or silicon-validated.

### Live poll — 2026-11-26 21:10 Asia/Dhaka
- Feature branch latest documentation HEAD at poll: `c289c5dc94f850835f47ea4a5d936fb2b6eb3fdc`; protected main independently remains `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Run 45845758782 full-chip lint is SUCCESS. Actual log inspected: Verilator 5.032 completed lint; existing warnings include 52 WIDTHEXPAND, 27 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT. No warning specifically references `rtl/dma/otpu_dma.sv`; these warning classes still need source-by-source triage.
- Run 45845758681 ASIC/target job: target/config checks and integrated ASIC control, WG8 memory and four-DIMM AXI lint all passed; four-DIMM host AXI simulation is running.
- Run 45845758636 RTL-tail pytest selection is running. Run 45845758545 subsystem matrix: Stream RTL and MX multiply/replay are running; other groups queued. Relevant DMA/scoreboard group remains queued.
- Run 45845758496 reset/power-up audit: tool setup and Yosys+Slang frontend validation passed; audit running.
- Run 45845758677 board-functional-only and run 45845758847 Qwen real-checkpoint rerun are still in setup/build stages. Qwen is rebuilding pinned Verilator 5.044; model downloads and pytest have not begun.
- Run 45845758658 WG8 PPA: pinned ORFS image setup passed; container flow is running. No new timing, area or power result yet.
- Run 45845758659 software/ISA tests: compiler, ISA and kernels jobs passed; quant tests running; remaining jobs queued.
- Run 45845758638 broad legacy workflow is now CANCELLED. Its group 3.1 Verilator build step was cancelled before tests; groups 3.2 and 4 tests did not run. Replacement guard run 45845941442 completed with both jobs skipped. No completed RTL groups were re-executed.
- These runs were automatically triggered by the DMA RTL path filter; no further code changes or CI runs should be initiated until they reach terminal states. Inspect exact logs/artifacts, then record results and decide the next targeted work.

### Critical-path source-bit clarification
The command type `cmd_t` in `rtl/top/otpu_pkg.sv` is packed as `op[7:0]`, `flags[7:0]`, `lg[3:0]`, three address-high fields and seven 32-bit words; `AWX=4`, so total width is 256 bits. Therefore reported startpoint `sc[254]` is `sc.op[6]`, an opcode bit. The path necessarily includes opcode-dependent stream setup/decode and data selection. The variable-divisor expressions are plausible contributors in the downstream arithmetic, but the single report path does not isolate the divider's share of the 12.93 ns delay. The rewrite remains an experiment until the new timing report identifies whether the critical path moved or shortened.


## 13. Latest continuation checkpoint — 2026-11-26 (Asia/Dhaka)

The latest operational state is maintained in [CURRENT_CONTINUATION_CHECKPOINT_2026-11-26.md](CURRENT_CONTINUATION_CHECKPOINT_2026-11-26.md). Read that file at the start of every continuation, then verify live branch/main/workflow state. It records the latest verified branch SHA, protected main SHA, confirmed Qwen and lint evidence, DMA timing experiment and its limitations, live workflow IDs/statuses, and next actions. The user may resume from any new chat/tab with: **“Continue and complete the remaining tasks.”**

Latest verified branch SHA before this documentation update: `6ca69d24f9c7dbdd960e01531b7d64454c8ccaf3`. Protected `main` remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; do not modify it. Do not rerun RTL groups 3.1, 3.2 or 4 merely to reconfirm; do not restart cancelled run `45765362426`. Manufacturer handoff remains **NOT READY**.


## 14. Verification continuation update — 2026-11-26 (Asia/Dhaka)

Exact-SHA verification of the DMA stream-setup experiment (RTL source commit `2835f1a8da6af454023caff9576f41258c66e2a8`) has advanced:
- RTL-tail workflow [45845758636](https://github.com/shamiursunny/openTPU/actions/runs/45845758636), job `139998865468`: SUCCESS; actual log inspected: **33 passed, 1 intentional parameter skip, 183 deselected, 923.55 s**. The skip is the documented invalid PAIR/ACT_ROWS parameter combination.
- Reset/power-up audit [45845758496](https://github.com/shamiursunny/openTPU/actions/runs/45845758496), job `139998865142`: SUCCESS; actual log inspected: **4 passed in 322.93 s**. Pinned OSS CAD Suite archive SHA-256 was verified and Yosys+Slang frontend loaded.
- ASIC/target integration [45845758681](https://github.com/shamiursunny/openTPU/actions/runs/45845758681), job `139998864759`: SUCCESS. Actual log inspected: integrated ASIC control, WG8 memory and four-DIMM AXI lint/build completed; four-DIMM host/accelerator contention simulation printed PASS for simultaneous AW/AR contention, alternating grants, ordered two-beat W bursts, B/R ID routing and independent backpressure. Artifact `15130743611`, SHA-256 `dc0a587493b7b9ca44355fbeb312798b3ef853e2f39e4fecb4ef35c345251863`.
- Full-chip lint [45845758782](https://github.com/shamiursunny/openTPU/actions/runs/45845758782): SUCCESS, Verilator 5.032. Actual warning inventory: 52 WIDTHEXPAND, 27 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT. The seven latch warnings are local temporaries `c2/r2` in the conditional WAITC / `hz_ino` branches and `u/y/k/kd/cf` inside the `hz_wc && c_v && sv[i] && !fin[i]` branch. They are potential lint false positives due to conditional use/temporary scope, but are not waived or yet proven harmless. The three UNOPTFLAT paths are `gnt` through VPU compression enable and slice grant logic; `sc_gl` through collective request/grant logic; and TMEM `pq` through a single always block at line 1074. They require structural review; do not assume they are real functional oscillations or harmless without deeper analysis. No warning specifically references `rtl/dma/otpu_dma.sv`.
- Lint artifact `15130078429`, SHA-256 `6a1f1639094cfe3d8c800d4f9bd923375fa4dc613b0cb6c1e4f5c9244c6b8d75`.

Still active at the latest poll:
- WG8 PPA [45845758658](https://github.com/shamiursunny/openTPU/actions/runs/45845758658): ORFS pinned-container flow still running; no new PPA result or artifact yet.
- Qwen exact-SHA rerun [45845758847](https://github.com/shamiursunny/openTPU/actions/runs/45845758847): pinned Verilator build, dependencies and pinned checkpoint downloads/checksums succeeded; real Qwen RTL pytest step still running; tiny-model tests not yet started.
- Board-only regression [45845758677](https://github.com/shamiursunny/openTPU/actions/runs/45845758677): board-functional pytest step running.
- Subsystem/memory matrix [45845758545](https://github.com/shamiursunny/openTPU/actions/runs/45845758545): MX multiply/replay passed; quantizer modes and Stream RTL running; remaining jobs queued.
- Software/ISA matrix [45845758659](https://github.com/shamiursunny/openTPU/actions/runs/45845758659): compiler, ISA, kernels, formats and quant tests passed; VOPS running; other software jobs queued.
- The completed reset-audit job in [45845758496](https://github.com/shamiursunny/openTPU/actions/runs/45845758496) passed as above.

No new CI runs were launched. Do not start additional builds until the existing workflow set reaches terminal states. The PPA result is the key unresolved gate for the DMA timing experiment. Keep main unchanged, do not restart run 45765362426, and do not rerun RTL groups 3.1, 3.2 or 4.


### Stream RTL regression closed — 2026-11-26
- In subsystem/memory workflow [45845758545](https://github.com/shamiursunny/openTPU/actions/runs/45845758545), Stream RTL job `139998866364` completed SUCCESS. Actual pytest log: `tests/test_stream_rtl.py` **14 passed in 1184.62 s**, including bit-exact configurations across uarch/board settings and destination-order tests. Artifact `15132346982`, SHA-256 `f8175ca55e63471deab21903454650631e82e372aed70d4fbc96ed69dd0362f8`.
- Other jobs in that matrix remain in progress or queued; this does not close DMA/scoreboard or full subsystem coverage.
### Quantizer mode RTL regression closed — 2026-11-26
- Subsystem/memory workflow [45845758545](https://github.com/shamiursunny/openTPU/actions/runs/45845758545), Quantizer modes job `139998866077`: SUCCESS. Actual pytest output: **15 passed in 660.95 s**, `tests/test_quant_rtl.py` mode matrix. Artifact `15132302427`, SHA-256 `387665baf7c670e1329c14d4e9ddc09e8027d6c33be559817d23ff91fe7db1ca`.

### Latest live poll — 2026-11-26
- Subsystem/memory run 45845758545: MX multiply/replay and Stream RTL jobs SUCCESS; Quantizer modes SUCCESS (15 passed); Quantizer corners/tie rounding and SPLITQ running; DMA/scoreboard, QST/QSTB, instruction cache, address-window, FP, QHL, wait-state, reset-audit-in-matrix and native DRAM/technology RAM jobs remain queued.
- Software/ISA run 45845758659: compiler, ISA, kernels, formats and quant tests SUCCESS; VOPS running; FP, MX, waits, stream, dataflow, waitw and host-related jobs queued.
- PPA 45845758658 remains in its pinned-container ORFS flow; no new PPA report yet.
- Qwen 45845758847 remains in the real-checkpoint RTL pytest step; its eight tiny-model tests have not started.
- Board-only run 45845758677 remains in board-functional pytest.
- No additional CI runs were launched. Re-poll before any further action.


## 15. Live verification continuation — 2026-11-26 22:28 Asia/Dhaka

Operational checkpoint: `docs/sunnyone/CURRENT_CONTINUATION_CHECKPOINT_2026-11-26.md` (latest poll and exact workflow IDs).

Active feature branch at the start of this update was `f88e5a8d581da5710240c25a39aa8778f87b7e8f`; protected project `main` remained `d84db55712aba0d40811d7762cb052f05d55b7e5`. Branch comparison: 818 ahead, 0 behind. The RTL experiment SHA under test remains `2835f1a8da6af454023caff9576f41258c66e2a8`. No new workflows were launched. Zero-spend and all historical RTL group exclusions remain active.

### Exact-SHA terminal results inspected
- Board-functional run 45845758677: 198 passed, 8 skipped (PyTorch-dependent), 1 deselected, 4254.89 s; artifact 15137400985, SHA-256 `d0adc900e0ef37ecec1f2715a555e0e822306a79b01bb562b1bbfa23d4f8f9d8`.
- RTL tail run 45845758636: 33 passed, 1 intentional skip, 183 deselected.
- Reset/power-up audit run 45845758496: 4 passed.
- ASIC/target config run 45845758681: SUCCESS; four-DIMM contention simulation PASS for concurrent host/accelerator requests, arbitration, ordered writes, response IDs and backpressure.
- Subsystem run 45845758545: MX multiply/replay 17 passed; quantizer corners/tie rounding 8 passed; quantizer modes 15 passed; collective hub/DMA/scoreboard 128 passed; QST/QSTB 13 passed; SPLITQ 5 passed; instruction cache 23 passed; address-window 20 passed/1 expected 64-GiB skip; FP 8 passed; QHL 7 passed; Stream 14 passed; wait-state 11 passed. Reset-audit and native DRAM/technology RAM jobs were still running at poll.
- Full-chip lint run 45845758782: SUCCESS, Verilator 5.032; warning debt remains 52 WIDTHEXPAND, 27 WIDTHTRUNC, 7 LATCH, 3 UNOPTFLAT. No warning suppression/waiver has been applied. LATCH warnings at `rtl/seq/otpu_seq.sv:1153` and `:1823`; UNOPTFLAT at `rtl/top/otpu_slice.sv:611`, `rtl/top/otpu_top.sv:156`, `rtl/mem/otpu_tmem.sv:297`. Structural review remains open.

### In-progress / queued
- WG8 PPA run 45845758658: pinned ORFS job in progress; no terminal report/artifact yet. DMA constant-divisor rewrite is not accepted as timing improvement until exact report comparison with baseline 45545698546.
- Qwen run 45845758847: pinned Verilator/dependencies/checkpoint validation passed and real-checkpoint Qwen RTL step completed SUCCESS; separate eight tiny board-model cases still running at poll.
- Subsystem run 45845758545: reset-audit and native DRAM/technology RAM jobs in progress.
- Software/ISA run 45845758659: FP, MX, compiler, ISA, kernels, VOPS, stream, formats, quant and dataflow jobs completed SUCCESS; waits job in progress; waitw, host, host-runs and host-lock queued.

Do not start replacement workflows while any of these are active/queued. Do not rerun RTL groups 3.1, 3.2 or 4; do not restart cancelled run 45765362426. Preserve all exact test outcomes, skips and limitations. Manufacturer handoff remains NOT READY: timing closure, full formal, CDC/RDC, remaining verification, production PCIe/PHY/DMA/IOMMU, DDR controller/PHY/ECC, SRAM/DFT, PDK/package/physical signoff, hardware qualification and measured workload/power/thermal/commercial evidence remain open.


## 98. Continuation reconciliation — 2026-11-26 23:30 Asia/Dhaka

The live continuation checkpoint was refreshed after independently rechecking the active feature branch and protected main. Branch HEAD at the start of this reconciliation was `4aa4018e420979b4441dd59e37710cee555376ed`; main remained `d84db55712aba0d40811d7762cb052f05d55b7e5`; feature branch 822 ahead / 0 behind. Verification runs below all target exact source SHA `2835f1a8da6af454023caff9576f41258c66e2a8`.

- Qwen real checkpoints and tiny board models, run 45845758847: **6 real RTL cases passed, 4 deselected; 8 tiny board-model cases passed, 199 deselected**. Artifact 15136893309.
- Subsystem/memory run 45845758545: all jobs terminal SUCCESS; combined selected logs **377 passed, 1 intentional skip**. Native DRAM/technology RAM job: **104 passed**. Reset audit job completed successfully (4 passed in the detailed audit record). Artifacts are retained for all selected jobs.
- Software/ISA run 45845758659: all 15 jobs terminal SUCCESS; individual logs total **825 passed, 3 skipped**.
- Board-functional run 45845758677: **198 passed, 8 skipped, 1 deselected**; artifact 15137400985.
- RTL-tail run 45845758636: **33 passed, 1 intentional skip, 183 deselected**; artifact 15132004314.
- ASIC/target run 45845758681: SUCCESS; four-DIMM contention simulation PASS markers inspected; artifact 15130743611.
- Full-chip lint run 45845758782: SUCCESS, but warning debt remains 52 WIDTHEXPAND, 27 WIDTHTRUNC, 7 LATCH, 3 UNOPTFLAT. Artifact 15130078429. No warnings were suppressed or declared closed.
- WG8 PPA run 45845758658: FAILED after floorplan timing reporting; OpenROAD exit 247 during 2_1_floorplan, peak memory 15,191,368 KB, no definitive exit cause in the log. Preliminary floorplan metrics: WNS/TNS 0.00 ns, worst slack +0.46 ns, minimum period 2.04 ns / 489.55 MHz; synthesis proxy cell area 30,786,988.162 um^2. This is not routed STA or signoff and is not accepted as a proven DMA rewrite improvement. PPA artifact 15137952036. Baseline run 45545698546 reports -10.43 ns WNS, -91.46 ns TNS, 12.93 ns / 77.31 MHz at floorplan, cell area 30,794,339.338 um^2; baseline artifact 14997807086.
- No new workflow was launched during this continuation. Groups 3.1, 3.2 and 4 were not rerun; cancelled run 45765362426 was not restarted.

**Next:** diagnose the PPA exit 247 before any retry; then complete a successful comparable physical flow and routed STA. Continue warning triage and formal/CDC/RDC and production integration gates. Manufacturer handoff remains NOT READY.


## 99. NEWEST CONTINUATION HANDOFF — 2026-11-26

This section supersedes all older status snapshots, including any text above describing the four workflows as in progress. All verification runs described in checkpoint section “Continuation update — 2026-11-26 23:30” are now terminal. For the next chat, start from the newest handoff in `docs/sunnyone/CURRENT_CONTINUATION_CHECKPOINT_2026-11-26.md` and verify live GitHub state before action.

- Live state before this documentation save: feature branch `sunnyone/commercial-profitability-architecture-2026-11-23`, HEAD `a70ade8b64f7c39777ba190bf185d525fa95ae9d`; protected main `d84db55712aba0d40811d7762cb052f05d55b7e5`; comparison 824 ahead / 0 behind.
- All Qwen, subsystem/memory, software/ISA/host, board-functional, RTL-tail and ASIC/target runs listed in section 98 are successful; retain their exact test counts and artifacts. Do not relaunch them.
- WG8 PPA run 45845758658 failed with OpenROAD exit 247 at `2_1_floorplan`; preliminary timing metrics are not routed/signoff and do not prove DMA improvement. First inspect artifact 15137952036 and diagnose the exit. No blind retry.
- Lint run passed but warning inventory remains 52 WIDTHEXPAND, 27 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT. Continue source-level triage; do not suppress.
- Immediate order: diagnose PPA failure; plan narrowly scoped controlled PPA retry only when justified; source-triage latch/combinational-loop/width warnings; continue formal/SVA, CDC/RDC and production integration/physical/commercial qualification.
- Preserve main; never rerun groups 3.1, 3.2 or 4 merely to reconfirm; never restart cancelled run 45765362426; avoid redundant reruns, speculative RTL changes and spend.
- Manufacturer handoff remains **NOT READY**.


## 100. WG8 PPA artifact diagnosis — 2026-11-26

At investigation start, live feature branch HEAD was `48a741a54acc66562986bcfe698e688e72aa49b4`; protected main was `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare was 826 ahead / 0 behind. No RTL or workflow change was made.

- Downloaded and inspected current PPA artifact 15137952036 (SHA-256 `66d8e83e4f5da5ee5b11be80e851ecfe04f6b801857ef9ee3d786246af47f560`) and its GitHub job log. Current floorplan log ends after floorplan-final metric reporting; peak RSS 15,191,368 KB. No explicit OOM, kill, signal or stack trace appears. ORFS reports Error 247 at `do-2_1_floorplan`; expected floorplan ODB/SDC are absent.
- Downloaded and inspected baseline artifact 14997807086 and baseline job log. Baseline reached `2_4_floorplan_pdn`, executed `check_placement -fixed -verbose`, then failed with the same Error 247 at peak RSS 15,685,744 KB. Baseline and current ORFS image digests differ, and the failure substages differ.
- Recurrence of Error 247 during memory-intensive floorplan/placement at approximately 15.2–15.7 GB strengthens (but does not prove) a host/container resource-ceiling hypothesis. No cgroup OOM counters or kernel OOM evidence are in the retained archives. Root cause therefore remains **unconfirmed**; do not state OOM as fact. No evidence supports a report-stage defect; the floorplan report was generated before the failures.
- No PPA retry was launched. Next action is to capture cgroup memory limits/current/events and runner telemetry before/during any future OpenROAD run. Keep source, ORFS image and 2-CPU setup fixed unless evidence warrants a controlled change. Zero-spend remains mandatory; no paid runner/hardware without approval. Do not bypass placement checks or PDN.
- Current floorplan metrics remain preliminary, wire-load-only and pre-route; not routed STA, signoff, timing closure, or proven DMA improvement. Manufacturer handoff remains NOT READY.


## 101. Full-chip lint source triage — initial findings (2026-11-26)

Inspected Verilator 5.032 log from lint run 45845758782, artifact 15130078429, tied to source SHA `2835f1a8da6af454023caff9576f41258c66e2a8`. No RTL modifications or warning suppressions were made.

- Seven LATCH diagnostic instances are all block-local temporaries in `rtl/seq/otpu_seq.sv`: `c2/r2` near line 1153 in the WAITC branch, and `u/y/k/kd/cf` near line 1823 in the `hz_wc && c_v` branch. They are assigned before use within their guarded branch, while not assigned on outer paths that do not enter that branch. This points to a possible procedural local-variable/scope false positive, but latch absence is not yet demonstrated. Verify actual elaborated/synthesised latch cells and test any cleanup before closure.
- UNOPTFLAT `gnt` path crosses `otpu_se_comp.sv:640`, `otpu_fpipe.sv:15` and `otpu_slice.sv:963` back to `otpu_slice.sv:611`: grant/enable feedback through VPU compression and arbitration.
- UNOPTFLAT `sc_gl` path crosses `otpu_slice.sv:1047`, `cgl_c` at :898 and grant logic at :963 back to `otpu_top.sv:156`: collective global/local grant dependency.
- UNOPTFLAT `pq` path is reported from `otpu_tmem.sv:297` through the generated bank-data/bypass combinational logic around :1074. Generated bank-copy and guest-port aliases require elaborated driver-graph inspection before classifying as a real cycle or alias-analysis limitation.
- Width warnings remain 52 WIDTHEXPAND and 27 WIDTHTRUNC; not yet individually triaged. No warnings suppressed or waived.

Next: establish actual latch-cell presence/absence, then trace the three UNOPTFLAT paths in their elaborated configurations. Do not register or split handshake signals without protocol-equivalence evidence. PPA root cause remains unconfirmed; manufacturer handoff NOT READY.


## 102. GitHub main-branch protection metadata — 2026-11-26

The live GitHub REST response for `main` reports `protected: false` and `protection.enabled: false`; its commit remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. The project instruction still treats main as protected/do-not-touch. However, repository-side branch protection is not technically enabled according to the API observation. This is a control gap, not permission to modify main. No repository-administration setting was changed; consider enabling an appropriate ruleset only as a separately approved action.


## 103. 2026-11-27 engineering continuation — PPA telemetry and handoff matrix

- Starting live feature HEAD: `5639670d515f18778950c6ce7c1b1ae1cc94cdbc`; main SHA: `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare 832 ahead / 0 behind. GitHub API reports branch protection disabled on main; project-level do-not-touch safeguard remains mandatory.
- **PPA CI instrumentation implemented** in `.github/workflows/sunnyone-asic-wg8-ppa.yml`, commit `783dc91d835b66279fc69ca0dd82ee3a9c403785`, blob SHA `9d6025838eb01dc7ae93d7f7671e7b5be066ec33`. Corrected missing Docker CPU quota by adding `docker run --cpus 2` (in addition to `ORFS_CPUS=2`). Added host baseline and periodic cgroup v1/v2 memory telemetry, retained as PPA artifact evidence. Workflow-only change does not self-trigger. No PPA retry was launched; telemetry has not yet been exercised.
- Added `docs/sunnyone/MANUFACTURER_HANDOFF_READINESS_MATRIX.md`, commit `f6730d10c54dde125b68f4abe09b28487e244b07`. Defines G0–G15 handoff acceptance gates and current PASS/PARTIAL/OPEN/BLOCKED/FAIL evidence states. It explicitly prohibits tapeout/production-ready claims while PPA, lint, formal, CDC/RDC, physical, memory PHY, interfaces, DFT, board, package and qualification evidence remain incomplete.
- No RTL changes; no warning suppressions; no reruns of successful historical tests; no cancelled workflow restart; no paid resources or hardware spend. PPA root cause remains unconfirmed. Manufacturer handoff **NOT READY**.
- Next: review workflow syntax/behaviour; justified PPA diagnostic dispatch; prove actual latch-cell state and elaborate UNOPTFLAT paths; triage 79 width warnings; extend formal/SVA and CDC/RDC; then target-specific physical/board/manufacturer evidence. See latest continuation checkpoint for full details.


## 104. 2026-11-27 integrated manufacturer/sponsored-silicon plan and verification re-poll

- Live branch at continuation start: ee5eafecd38e82d99c62cd83f5f981230d522171; project main: d84db55712aba0d40811d7762cb052f05d55b7e5. Main was not modified.
- Created governing plan docs/sunnyone/INTEGRATED_ENGINEERING_AND_SPONSORED_SILICON_PLAN_2026-11-27.md in commit 86162c5113da62ad3069d6ef8eff1233390d27f5.
- Created new authoritative checkpoint docs/sunnyone/CURRENT_CONTINUATION_CHECKPOINT_2026-11-27.md in commit 20520d921edc8c3b1e46426ba7b674f70322695e. It supersedes the 2026-11-26 checkpoint for new continuations while preserving the earlier file.
- Plan preserves two tracks: (A) full programmable SUNNYONE inference-accelerator product architecture and (B) a separate small first-silicon demonstrator derived from existing RTL only after PDK, area, timing, testability and sponsor feasibility. Do not shrink or replace the full product to fit an MPW shuttle.
- Architecture baseline preserved: host-server control plane, tiled matrix engine, vector/SIMD datapath, local SRAM/scratchpads, DMA, host/compute/memory interconnect, external ECC-capable memory intent and programmable runtime. No on-chip CPU/boot ROM in the current first-version baseline. Versal VC1802/VSVD1760 remains a separate FPGA feasibility lead, not the IHP ASIC target or selected production part. 128 GB ECC memory remains a hypothesis; 256 GB is stretch-only; former 30 W ceiling remains retired.
- Independently re-polled all eight historical workflow job sets and inspected actual pytest/log summaries. Terminal states: 45845758545 SUCCESS (14/14 jobs), 45845758659 SUCCESS (15/15), 45845758677 SUCCESS, 45845758636 SUCCESS, 45845758681 SUCCESS, 45845758847 SUCCESS, 45845758782 SUCCESS; 45845758658 PPA FAILURE.
- Exact selected totals: subsystem/memory 377 passed, 1 documented skip; software/ISA/host 825 passed, 3 skipped; board 198 passed, 8 skipped, 1 deselected; RTL tail 33 passed, 1 skip, 183 deselected; Qwen real-checkpoint 6 passed/4 deselected and tiny board model 8 passed/199 deselected; native DRAM/technology RAM 104 passed; four-DIMM integration and address-map assertions printed PASS. These are separate selected suites; do not add them into a single grand total or describe them as full signoff.
- Full-chip lint remains with 52 WIDTHEXPAND, 27 WIDTHTRUNC, 7 LATCH, 3 UNOPTFLAT; actual latch-cell status and structural loops are not proven. Separate ASIC compile surfaced another aok UNOPTFLAT and 34-bit-to-33-bit AW/AR port connection width warnings.
- PPA run 45845758658 failed with OpenROAD exit 247 during floorplan, peak RSS 15,191,368 KB; root cause remains unconfirmed. Pre-route wire-load report is not routed STA. PPA workflow instrumentation commit 783dc91d835b66279fc69ca0dd82ee3a9c403785 adds Docker --cpus 2 and cgroup resource telemetry; no diagnostic rerun launched.
- Manufacturer funding correction: IHP is the first technical sponsorship target, not a confirmed free fabrication route. Historic FMD-QNC free-MPW evidence lists 2024–2025 runs; 2026 continuation is not confirmed. Published 2026 IHP SG13G2 (29 Sep / registration 21 Sep) and SG13CMOS5L (9 Nov / registration 26 Oct) dates have passed. Current low-cost offer is paid (indicative EUR 2,800/mm² SG13G2; EUR 1,500/mm² SG13CMOS5L; packaging extra; 20 bare dies basic offer), so no spend is authorised. Seek written IHP/university sponsorship covering fabrication, dicing, packaging, test fixture, physical characterisation, report, sample access/delivery and shipping/customs/taxes.
- IHP open PDK maturity is explicitly limited: SG13G2 Early Access/alpha and SG13CMOS5L preview; do not present either as production-ready.
- No RTL changes, no new CI run, no paid spend, no warning suppressions, no cancelled workflow restart and no repeated successful groups in this continuation. Manufacturer handoff remains NOT READY.
- Next: review telemetry workflow; prove latch-cell state and trace UNOPTFLAT paths; triage 79 width warnings plus ASIC-specific warnings; extend formal/SVA and CDC/RDC; inventory existing RTL and select a small demonstrator candidate; verify PDK flow; seek written zero-cost sponsorship; then technology port and manufacturer-specific signoff. See the integrated plan and new checkpoint for the full sequence.


## 105. 2026-11-27 WG8 PPA immutable toolchain pin

- Reviewed failed run 45845758658 logs: the old workflow used mutable openroad/orfs:latest, resolving to registry manifest digest sha256:f5b2b4ac8cae150c30ad86857328300e20662cf7ff555978711ea8936f8d9539 and local image ID sha256:edbd355068b742c5ae2413a49a58578465bd52f57668cebebdd383eb4d97607d.
- Updated .github/workflows/sunnyone-asic-wg8-ppa.yml in commit e2d96d5364af47503d67cb70635bf3485cbe9b33 (blob 426cfcc62ac4ca1d90cf52b06a0e9009b83a1c29) to pull the immutable manifest digest, verify the exact local image ID and archive both identifiers. Existing Docker --cpus 2 and cgroup v1/v2 resource telemetry remain.
- Updated integrated plan with the exact digest and rationale in commit 57772f70dd335ec519f38e6f3ed75e392122bd61 (blob 7b826a30775e51e5f80ef567713213d8f4ec414c); checkpoint addendum saved in commit d02ce0a012f4408df862ce6a8cf4ab4ef0422a31.
- No PPA rerun launched. The workflow change improves reproducibility only; it does not resolve the prior Error 247 or prove OOM. Review the resulting YAML/command behaviour and artifact paths before one justified diagnostic run.


## 106. 2026-11-27 lint and combinational-path source triage

- Created docs/sunnyone/LINT_AND_COMBINATIONAL_PATH_TRIAGE_2026-11-27.md in commit e18c5715f11146b0795642251f958d71b9ff1229.
- The seven LATCH diagnostics are within ifndef SYNTHESIS diagnostic code in rtl/seq/otpu_seq.sv; the ASIC synthesis flow defines SYNTHESIS. These are simulation-only warnings, not evidence of hardware latches. Do not modify functional RTL to silence them. A final synthesized-netlist latch-cell check remains required.
- pq is likely a packed-array alias-analysis false positive: non-host ports map to a selected host port; confirm generated connectivity.
- sc_gl is likely a process-granularity false positive because cgl_c does not read coll_gnt, although gnt_c[G_COLL] is assigned from it in the same always_comb process; confirm elaborated graph before any process split.
- aok is likely a packed-vector granularity false positive because the priority loop reads only lower indices h<g; confirm per-bit dependency.
- gnt remains unresolved and highest priority. The example path reaches a VPU sequential enable pin; actual combinational return path is not proven. Resolve exact parameters and netlist/SCC graph; no speculative register insertion or grant-path restructuring.
- Updated manufacturer matrix G3 and PPA instrumentation notes in commit 0a3f947610157359f28531f6d0bb6d9ede6b145f. G3 remains OPEN because UNOPTFLAT and width-warning evidence is not closed.
- Updated integrated plan with lint triage in commit 8ba5ded36e6eb52dde43b7f6f25ee7641a694e10. Checkpoint updated in commit fcaeec4db211a14422b12a7804ab0fa2ed1d3b5e.
- No RTL changes or new tests. Next: exact gnt path graph, then per-bit sc_gl/pq/aok confirmation and width-warning triage.


## 107. 2026-11-27 complete width-warning inventory and preliminary bounds triage

- Created docs/sunnyone/WIDTH_WARNING_INVENTORY_2026-11-27.md in commit c198c07a2896c307b7af4c9f52975442516b86b7. It preserves all 79 exact warnings from Verilator full-chip lint run 45845758782 (52 WIDTHEXPAND, 27 WIDTHTRUNC), grouped by file and line/column.
- Cross-checked source ifndef SYNTHESIS guards: 9 warning instances are in simulation-only code and marked SIM_ONLY; the other 70 remain OPEN for semantic and exact-synthesis-source review. No warning suppression/waiver.
- High-priority bounds questions:
  - VPU row-sum buffer: rows_done[15:LW] and fl[15:LW] index a 32-entry rb array; prove all legal writes/reads and final-cycle behaviour remain within NRB=256. RDOT is gated by rows<=NRB; FSUM validation currently appears simulation-only and needs review against hardware command validity.
  - Sequencer LOOP stack: four-entry arrays indexed by 3-bit sp; ISA docs specify nesting depth 4, but no visible sp<4 push guard. Prove program validation or implement safe overflow/error handling.
  - VPU 24-bit one-hot function mask indices: prove VOP enum values stay within 0..23 before narrowing.
  - MXU drain/key array indices: prove guard/mask invariants before narrowing.
- Updated MANUFACTURER_HANDOFF_READINESS_MATRIX.md in commit 7bbf853230f591e314ec9307d0f1277be4ac996f and integrated plan in commit 95230c32013be1780a6980eaaac717123a3d562d. Checkpoint updated in commit edaef098e172457939e76f21f7974c6baa665b7c.
- No RTL changes or new tests. G3 remains OPEN; lint is not closed. Next: prove VPU/loop-stack bounds and inspect exact synthesis source selection before any cast or functional change.


## 108. 2026-11-27 sequencer LOOP stack overflow guard and targeted regression

- Source-level comparison found a real boundary gap: docs/isa.md sets maximum nested LOOP depth to 4; opentpu/isasim.py rejects a fifth non-zero nested loop with SimError("loop stack overflow"); RTL rtl/seq/otpu_seq.sv had no visible guard before writing its four-entry arrays using 3-bit sp.
- Added guard sp >= 3'd4, setting error and halted before any out-of-range write; legal pushes now index with sp[1:0]. RTL commit 28c36c52204fe2ec2ed36413b02eb6043506ccc4.
- Added two tests in tests/test_rtl.py in commit c22c9b1be497b62253693e817d7d3b5fdca1c79f: legal maximum four-level nesting and fifth-level overflow error/halt.
- Added dedicated focused workflow .github/workflows/sunnyone-loop-stack-guard.yml in commit 275728cd1484fb3b409ba59b9b409f29160c8f7e. Run 45877985241 is IN_PROGRESS; do not mark fix verified until archived logs show both tests pass.
- Full-chip lint run 45877786797 SUCCESS on source 28c36c52204fe2ec2ed36413b02eb6043506ccc4; width diagnostics fell from 79 to 76 (52 WIDTHEXPAND, 24 WIDTHTRUNC), with three direct stack-index WIDTHTRUNC warnings removed. Seven simulation-only LATCH and three UNOPTFLAT remain.
- Width inventory updated in commit 0d661732a6c2308dc6cab3bb1ad9294290a8707c; matrix updated in commit 2e9483051738ea09ab494b4c5217e1c6972e56ad; integrated plan updated in commit f93dfdd58dfcf7e07035ba7afa3de62517631e2b; checkpoint updated in commit 8c130d0e2b5c7eeaec9910c8b4c2aa851f76c1f8.
- WG8 PPA run 45877786710 IN_PROGRESS on source 28c36c52204fe2ec2ed36413b02eb6043506ccc4 with immutable ORFS image pin and telemetry. No duplicate PPA attempt while active.
- Other active/queued workflows: reset audit 45877786738; Qwen RTL 45877786754; board 45877786742; subsystem/memory 45877786699; software/ISA 45877786705; ASIC config 45877786860; replacement RTL-tail 45877807906; 128K one-copy TMEM investigation 45877807985. Prior tail run 45877787004 was cancelled by the newer commit. Historical user-cancelled run 45765362426 remains cancelled and must never be restarted.
- No other RTL changes in this section. No manufacturer handoff claim; G1/G2/G3 remain PARTIAL/OPEN as appropriate.


## 109. 2026-11-27 targeted loop-stack and 128K TMEM tests passed

- Loop-stack guard workflow 45877985241 SUCCESS on commit 275728cd1484fb3b409ba59b9b409f29160c8f7e: 2 passed, 217 deselected, 47.52 s. Both maximum legal depth-four and fifth-level overflow error/halt tests passed. Artifact 15146995084; ZIP SHA-256 bc7202d01bf896453a2fdd8e3f752d34e719e85db9ddc582ebcba0196380b7ff.
- This confirms the RTL matches the ISA simulator's four-level nesting limit for the tested legal and illegal boundary cases; it is not full sequencer or chip signoff.
- Isolated 128K one-copy TMEM run 45877807985 SUCCESS on commit c22c9b1be497b62253693e817d7d3b5fdca1c79f: 2 passed, 217 deselected, 75.03 s.
- Full-chip lint run 45877786797 SUCCESS on source 28c36c52204fe2ec2ed36413b02eb6043506ccc4: 76 width warnings (52 expand, 24 truncation), down from 79; three direct stack-index truncation warnings removed.
- PPA run 45877786710 still IN_PROGRESS on source 28c36c52204fe2ec2ed36413b02eb6043506ccc4 using immutable ORFS manifest digest and cgroup telemetry. Do not dispatch another while active.
- Integrated plan updated in commit d79f7592703a2706a74cd8438e2671f2d4944aab; checkpoint updated in commit 9ddcdebab56abad10b509e0127b75354dc7eb775.


## 110. 2026-11-27 manufacturer matrix refreshed with loop-stack and lint evidence

- Updated docs/sunnyone/MANUFACTURER_HANDOFF_READINESS_MATRIX.md in commit 021f0b8c99e16d125980304602aeb51e6580acd2 (blob 8e7470cbaf9d4d96ba9c41e161f2bf417f47810b).
- Matrix now records loop-stack boundary tests 2/2 passed, isolated 128K one-copy TMEM investigation 2/2 passed, and full-chip lint warning delta 79 to 76.
- These results close only the tested loop-stack boundary and isolated TMEM cases. The broader functional, formal, CDC/RDC, lint, PPA, technology-port, physical, DFT, package and manufacturer gates remain open.
- PPA run 45877786710 remains IN_PROGRESS on source 28c36c52204fe2ec2ed36413b02eb6043506ccc4; do not dispatch a duplicate. The dedicated loop-stack workflow 45877985241 and TMEM investigation 45877807985 are SUCCESS.


## 111. 2026-11-27 FSUM bounds and PPA CPU propagation review

- Created `docs/sunnyone/INPUT_BOUNDS_AND_PPA_RESOURCE_CONTROL_REVIEW_2026-11-27.md` after reviewing the live feature branch and exact PPA source SHA.
- Confirmed the VPU row-sum buffer is 256 rows. RDOT buffer selection has a synthesizable guard (`rows <= NRB` and `drs == 1`), but FSUM's `rows <= NRB` check is inside `ifndef SYNTHESIS`. FSUM is enabled in `targets/bcu1525-wg.toml` and `targets/bcu1525-x2.toml`; software-side checks exist in `isa.py`, `isasim.py` and `compiler.py`. A malformed/raw FSUM command could exceed the hardware buffer unless the ingress contract prevents it. Status OPEN; no RTL change made.
- Found PPA CPU propagation mismatch at source SHA `28c36c52204fe2ec2ed36413b02eb6043506ccc4`: workflow sets `ORFS_CPUS=2`, but `tools/asic/flow.py` derives `NUM_CORES` from `os.cpu_count()` and ignores that environment variable. Docker `--cpus 2` still caps actual CPU use; ORFS worker oversubscription remains possible. This is not a proven cause of Error 247.
- PPA run 45877786710 remains IN_PROGRESS. Do not modify PPA source/workflow or launch a replacement while it is active; wait for its artifact and terminal result. Correct and test CPU propagation afterwards.
- Reconciled live statuses: reset 45877786738 SUCCESS; ASIC config 45877786860 SUCCESS; RTL tail 45877807906 SUCCESS; TMEM 45877807985 SUCCESS; loop-stack 45877985241 SUCCESS (2 passed); PPA 45877786710, Qwen 45877786754 and board 45877786742 still IN_PROGRESS; subsystem 45877786699 and software 45877786705 partially queued/in progress.
- No RTL or workflow source changes and no new CI runs. Main untouched; zero-spend rule retained; manufacturer handoff NOT READY.


### FSUM program-ingress confirmation — 2026-11-27

A further review of `opentpu/host/board.py::Board.load_program` found that the host loader accepts raw uint32 word arrays and does not perform FSUM semantic validation before writing instructions to DRAM/IMEM. Compiler and ISA-simulator checks therefore do not prove a mandatory validated ingress boundary. The FSUM row-buffer bounds issue remains OPEN for `bcu1525-wg` and `bcu1525-x2`. `otpu_vpu` has no current error output; `otpu_seq` does expose `error`, so any correction must trace and reuse the established slice error/halt path. No RTL edit is made pending that design review.


### Existing error/halt path traced — candidate guard location, not yet implemented

- `otpu_seq` exposes `error` and its existing invalid decoded-operation branch sets both `error <= 1'b1` and `halted <= 1'b1` before dispatch (around lines 1702–1705).
- `otpu_slice` connects `otpu_seq.error` to `sq_err` and exposes `error = sq_err || to_err` (around lines 355–366 and 437). The VPU itself currently has no error output.
- A candidate minimal architecture is to pass the slice's `VPU_FSUM` configuration into the sequencer and validate an FSUM-bearing VOP's decoded `cmd_t` before dispatch, reusing the existing sequencer error/halt path. The exact decoded-field timing and full FSUM contract still require a focused review; this is not an approved patch.
- Do not change `otpu_seq.sv` while PPA run 45877786710 is active: that file is in the PPA workflow path filter and the workflow uses cancel-in-progress concurrency. Wait for the current run's terminal result, then implement only with targeted boundary tests and an explicitly justified CI run.


## 112. 2026-11-27 live reconciliation — completed verification and PPA OOM diagnosis

Live branch ref at the start of this update: 0af11ca294d12e0f5caa3fdf88c42b402a7f099a. Project main remains d84db55712aba0d40811d7762cb052f05d55b7e5 and was not modified. GitHub API reports main protection disabled; the project rule remains do not touch main.

### Completed workflows, polled from GitHub and inspected from archived logs
- WG8 PPA 45877786710: FAILURE, terminal. Full artifact 15152974135 was downloaded and inspected; report is docs/sunnyone/PPA_RESOURCE_DIAGNOSIS_2026-11-27.md.
- Qwen 45877786754: SUCCESS. Real official Qwen checkpoint RTL tests: 6 passed, 4 deselected; tiny board-model tests: 8 passed, 199 deselected.
- Board-functional 45877786742: SUCCESS, 198 passed, 8 skipped, 1 deselected.
- Subsystem/memory 45877786699: all 14 jobs SUCCESS. Archived per-job pytest logs sum to 385 passed and 1 documented 64-GiB address-window skip. Do not combine these counts with older workflow totals.
- Software/ISA 45877786705: all 15 jobs SUCCESS. Archived per-job logs sum to 825 passed and 3 skipped.
- Reset audit 45877786738: SUCCESS.
- ASIC configuration 45877786860: SUCCESS.
- RTL tail 45877807906: SUCCESS.
- Isolated 128K one-copy TMEM 45877807985: SUCCESS, 2 passed, 217 deselected.
- LOOP stack guard 45877985241: SUCCESS, 2 passed, 217 deselected.
No workflow was rerun or dispatched during this reconciliation.

### PPA root cause evidence
- PPA source SHA: 28c36c52204fe2ec2ed36413b02eb6043506ccc4; job 140109157212.
- Immutable ORFS manifest sha256:f5b2b4ac8cae150c30ad86857328300e20662cf7ff555978711ea8936f8d9539; local image ID sha256:edbd355068b742c5ae2413a49a58578465bd52f57668cebebdd383eb4d97607d.
- Docker --cpus 2 was applied; OpenROAD log says 2 threads.
- Floorplan, macro placement and tap-cell insertion completed. Failure occurred during 2_4_floorplan_pdn/check_placement; ORFS Error 247, make exit 2.
- Host MemTotal 16,366,484 kB; cgroup memory.max was max; memory.peak 16,155,115,520 bytes; final memory.events recorded oom_kill 1, oom 0, oom_group_kill 0, max 0. OpenROAD 2_1 floorplan peak was 15,535,996 kB.
- This is a confirmed cgroup-recorded OOM-kill event and strongly supports host-level memory exhaustion because the cgroup had no memory cap and peak use approached host RAM. No kernel victim-selection record was archived; do not overstate the exact OS mechanism.
- Do not repeat this full-chip PPA on an equivalent 16 GB runner. No automatic retry. A zero-cost larger-memory runner or technically valid staged diagnostic must be justified first. No spend without explicit approval.

### Correction to stale CPU-propagation note
The 01:37 addendum's claim that the actual workflow ignored ORFS_CPUS was corrected by the 01:45 review. The current CLI reads ORFS_CPUS and passes the parsed value to run(); the active workflow therefore did use two workers. Do not modify tools/asic/flow.py based on the stale claim.

### Remaining blockers and next order
1. Resolve the FSUM 256-row hardware bounds for the two FSUM-enabled BCU targets. The existing FSUM assertion is simulation-only and Board.load_program accepts raw words. Design the narrow sequencer-side invalid-command guard using the established error/halt path, then add boundary and invalid-command RTL tests. ISA contract: EXP2SUB+FSUM rows 1..256, cols >=64, B mode 0/1/2; scalar B mode 3 forbidden. Reject FSUM-flagged operations when capability is disabled. Review RSUM take semantics separately.
2. Continue exact elaborated-netlist/SCC proof for gnt, sc_gl, pq and aok.
3. Triage the remaining 76 width warnings and ASIC-specific AW/AR port-width warnings with exact source/configuration and boundary tests.
4. Expand formal/SVA, CDC/RDC and synthesized-netlist latch-cell checks.
5. Keep Track A full product separate from Track B demonstrator. Verify IHP PDK compatibility and written sponsorship/eligibility/sample/shipping terms before any demonstrator integration.
6. Manufacturer handoff remains NOT READY. Zero-spend, no-main, no-cancelled-run, and no-repeat-successful-test controls remain active.
