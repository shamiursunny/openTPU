# SUNNYONE continuation addendum — 2026-11-28 VPU width remediation

Read after `CONTINUATION_ADDENDUM_2026-11-28_0050.md` and `LINT_TRIAGE_UPDATE_2026-11-28.md`.

## Live engineering result
- VPU RTL source commit: `05879ea34eafc2559c54722c6c940b2acb9ac3ee`.
- Focused lint result run `46053311384`: SUCCESS; 52 WIDTHEXPAND, 7 WIDTHTRUNC, 7 simulation-only LATCH diagnostics and 3 UNOPTFLAT diagnostics. Width-warning count fell from 76 to 59 (17 fewer).
- Source change in `rtl/vpu/otpu_vpu.sv`: explicitly 5-bit sized all 24 VPU function-mask indices (package op constants range 0..23), and sized the row-buffer indices using `RBW = $clog2(NRB/LANES)`. This preserves selected bit/address semantics and does not add clamping.
- FSUM buffer bounds are guarded in synthesizable sequencer logic; legal producer rows are 1..256, cols >=64 and B mode is non-scalar. RDOT row buffering is enabled only for <=256 rows and unit stride. Existing tests cover the maximum legal 256-row shape and reject 257 rows.
- Structural SCC/latch evidence: run `45914912691` successfully audited one-copy slice, two-slice top and actual ASIC card top with zero combinational SCCs and zero inferred latch cells. This resolves the warning paths `gnt`, `pq`, `sc_gl`, `aok` for those exact elaborated configurations only.

## Focused regression disposition
- Workflow `46053329340` failed at simulator build because apt Verilator 5.020 rejects an existing `otpu_se_tail.sv` instantiation; 31 parameterised test cases did not reach RTL simulation. Do not treat this as a functional RTL failure or as a pass.
- Workflow `.github/workflows/sunnyone-vpu-index-width.yml` was corrected to build pinned Verilator 5.044.
- Workflow run `46053471843` is the pinned-toolchain VPU/FSUM regression attempt. It must complete `tests/test_se_vpu.py` and the eight selected raw-FSUM ingress/boundary tests before the VPU patch is marked regression-verified.

## Remaining lint items
- Five MXU index warnings at `rtl/mxu/otpu_mxu.sv:2247,2305,2306,2607,2663` remain open pending precise index bounds proofs.
- Two `exists()` width warnings at `rtl/mem/otpu_dram.sv:72,80` belong to the behavioral associative-array DRAM model; confirm ASIC source exclusion, do not alter model semantics solely to silence lint.
- All 52 WIDTHEXPAND warnings remain open pending semantic width/range review.
- Seven LATCH diagnostics are in `ifndef SYNTHESIS` diagnostic code and the audited synthesis tops have zero latch cells. Three generic UNOPTFLAT diagnostics remain textually present but are not supported by SCCs in the audited configurations.

## CI operations note
The RTL commit matched broad existing `rtl/**` path filters and triggered additional suites (board, Qwen, software-core, RTL subsystem/tail, reset and ASIC configuration). These broad reruns were unintended and are not required for the VPU change. The available GitHub connection has no workflow-cancellation operation; do not claim cancellation. No further broad regression runs are authorised. Preserve prior evidence and reconcile exact terminal statuses only.

## Release decision and constraints
- Manufacturer handoff remains **NOT READY**.
- No PPA retry, paid compute, PDK/IP licence, hardware purchase, fabrication, packaging or lab spend without explicit approval.
- Protected `main` remains untouched.
- Do not rerun historical passed groups solely for reassurance; no unsupported physical or silicon claims.
