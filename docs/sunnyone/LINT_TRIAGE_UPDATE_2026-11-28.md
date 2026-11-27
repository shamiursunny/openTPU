# SUNNYONE lint and VPU width remediation — 2026-11-28

Repository: `shamiursunny/openTPU`
Branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5` (untouched)

## 1. Structural warning reconciliation

The prior source-level triage is superseded by the successful structural SCC/latch audit recorded in `STRUCTURAL_SCC_AND_LATCH_AUDIT_2026-11-27.md`:
- Run `45914912691`, tested source `024928752fef7ab774502d2a19f49111cc86b1ff`, completed SUCCESS.
- One-copy slice, two-slice top and actual `otpu_asic_top` card configuration each reported zero combinational SCCs and zero inferred latch cells.
- This covers the Verilator warning names `gnt`, `pq`, `sc_gl` and ASIC `aok` in those tested elaborations. Treat them as dependency/partitioning over-approximations for those configurations, not as confirmed combinational cycles. The generic Verilator warnings remain visible.
- Seven generic `LATCH` warnings in the simulation lint point to `ifndef SYNTHESIS` diagnostic/oracle code. The synthesis elaborations reported no latch primitives in the three audited tops. This is scoped structural evidence, not a proof for every possible configuration.

## 2. Baseline lint evidence and remediation

Baseline full-chip lint:
- Run `46016022722`, tested source `672a4fc13f9f708582f4fca0462a32363654ff93`, completed SUCCESS.
- 52 WIDTHEXPAND, 24 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT diagnostics.

Targeted RTL correction:
- Source commit `05879ea34eafc2559c54722c6c940b2acb9ac3ee`.
- File: `rtl/vpu/otpu_vpu.sv`.
- All 24 VPU function-mask bit-select expressions now explicitly cast their package function constants to 5-bit indices. The package constants are bounded from `V_ADD=0` through `V_MAC=23`, so the 5-bit select preserves the original bit selected.
- Added `RBW = $clog2(NRB / LANES)` and use `rows_done[LW +: RBW]` and `fl[LW +: RBW]` for the row-buffer write/read. This selects exactly the index bits required by the declared `rb [NRB/LANES]` array; it does not wrap or clamp an out-of-range value.
- Bounds are enforced at hardware ingress: FSUM EXP2SUB rejects rows 0 and >256, columns <64 and scalar B mode; RDOT enables the row buffer only for at most 256 rows with unit stride. `rows_done` resets at begin and the row-buffer access uses its pre-increment zero-based row index. The flush starts at zero and advances by LANES, with the final valid group starting no later than row 255. Existing tests include 256-row legal operation and reject the 257-row FSUM case.
- This is an index-width clarification only; no arithmetic, datapath, scheduling, pipeline, memory protocol or ISA behaviour was intentionally changed.

Latest full-chip lint after this source commit:
- Run `46053311384`, tested source `05879ea34eafc2559c54722c6c940b2acb9ac3ee`, completed SUCCESS.
- 52 WIDTHEXPAND, 7 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT.
- Width warnings reduced from 76 to 59: 17 WIDTHTRUNC diagnostics removed. The remaining seven truncation warnings are five MXU array-index diagnostics and two `exists()` diagnostics in the behavioral DRAM model.
- The two DRAM diagnostics are simulation-model constructs, not the ASIC synthesis memory implementation. The five MXU indices remain open pending per-index bound proofs and exact-width cleanup. All 52 expansion warnings remain open pending semantic review.
- Lint workflow success is not warning-free signoff.

## 3. Focused VPU regression

A dedicated workflow `.github/workflows/sunnyone-vpu-index-width.yml` was added to run:
1. `tests/test_se_vpu.py` (VOPs, reductions, stream interaction and FSUM differential coverage).
2. The eight focused raw-FSUM ingress and 256-row boundary selections in `tests/test_rtl.py`.

First attempt:
- Run `46053329340` failed before simulation because Ubuntu's apt Verilator 5.020 rejected an existing `otpu_se_tail.sv` instantiation (`Non-interface used as an interface`). All 31 parameterised test cases failed at simulator build; the FSUM step was skipped. This is a toolchain/harness incompatibility, not a functional RTL test failure.
- The workflow was updated to build pinned Verilator 5.044, matching the project's known-good RTL test toolchain.
- Pinned-toolchain attempt `46053471843` is queued/in progress at this report's creation. Do not call the VPU correction regression-verified until this run's pytest steps pass.

## 4. CI trigger side effect

The RTL source commit matched existing broad `rtl/**` push filters. It automatically triggered unrelated workflow suites, including board, Qwen, software-core and multiple RTL groups. These were not intentionally requested as part of the narrow VPU change and repeat some previously recorded scopes. The available GitHub connection exposes read and rerun operations but no workflow-cancellation operation; no claim is made that those runs were cancelled. No further broad regression runs are to be initiated. Reconcile their terminal status and preserve prior test evidence; do not use these runs to overwrite older results unless their exact test scope and source SHA are relevant.

## 5. Remaining width work

1. Five MXU array-index truncation warnings at `rtl/mxu/otpu_mxu.sv:2247, 2305, 2306, 2607, 2663`. The source contains loop/range guards and one-hot lane-valid guards, but each index needs an explicit proof against `MCOLS`, `c_Mn`, `mxm`, and the declared array bound before narrowing.
2. Two `rtl/mem/otpu_dram.sv` warnings arise from associative-array `exists()` methods in the behavioral simulation DRAM model. Confirm the exact ASIC source closure excludes this model; do not modify simulation semantics just to silence the generic lint.
3. 52 WIDTHEXPAND warnings remain across VPU/quantizer/MXU/package/TMEM/sequencer. Review each expression's signedness, context width, range and carry/truncation intent. Do not blanket-cast.
4. Preserve the structural SCC result for the tested elaborations; keep formal/SVA, CDC/RDC and physical signoff as separate open gates.

## 6. Release constraints

- No PPA retry, paid compute, PDK/IP purchase, hardware purchase, fabrication, packaging or lab spend without explicit approval.
- Do not write protected `main`.
- Do not rerun historical groups solely to reconfirm passed evidence.
- No physical silicon, production performance, routed signoff or manufacturer acceptance claim.
- Manufacturer handoff remains **NOT READY**.



## Source-closure confirmation for behavioral DRAM warnings

The two `otpu_dram.sv` `exists()` diagnostics are confirmed SIM_ONLY for ASIC synthesis: `tools/asic/flow.py:sources()` uses `opentpu.target.sources()`; its `CORE` list contains the synthesizable TMEM/ACTRAM/sequencer/VPU/DMA/MXU/slice core but not `rtl/mem/otpu_dram.sv`. The behavioral associative-array model is therefore not in the ASIC source closure. Keep these two generic full-chip simulation-lint diagnostics visible, but do not classify them as ASIC hardware-width defects or alter simulation-model behaviour to silence them.


## 2026-11-28 focused VPU regression final result

The pinned-toolchain regression described in section 3 is now complete. Workflow `46053471843` / job `140690259477` succeeded on source `40ce5cbd6f615215fbb8b7ee21b04aa541f451b6`: `tests/test_se_vpu.py` reported **31 passed in 476.99s**; raw FSUM ingress and 256-row boundary tests reported **11 passed, 219 deselected in 211.80s**. Artifact `15225689330` contains both summaries. This closes the focused regression gate for the recorded VPU change only; it does not close full-chip lint or broader functional signoff. The earlier apt Verilator 5.020 build failure `46053329340` remains a toolchain failure, not a functional RTL failure.
