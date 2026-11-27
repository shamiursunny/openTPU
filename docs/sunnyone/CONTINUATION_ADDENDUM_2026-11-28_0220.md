# SUNNYONE continuation addendum — 2026-11-28 02:20 Asia/Dhaka

## Repository state and controls
- Repository: `shamiursunny/openTPU`.
- Working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Branch HEAD before this documentation update: `75a02e23bfb1b841be4805914659c4823252c370` (docs-only commit classifying behavioral DRAM lint as simulation-only).
- Protected project baseline `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Live compare at this poll: 1,072 commits ahead, 0 behind; merge base remains the stated main SHA.
- All changes in this continuation are documentation-only on the feature branch. No RTL, test or workflow source was changed. No test or workflow was launched.
- Preserve zero-spend; no PPA retry; no paid compute, PDK/IP, hardware, fabrication, packaging or lab spend without explicit approval. Do not write, merge, rebase or otherwise alter `main`.

## Focused VPU regression — now closed for its exact scope
- Workflow `46053471843`, job `140690259477`, tested source `40ce5cbd6f615215fbb8b7ee21b04aa541f451b6`: SUCCESS.
- Pinned Verilator 5.044 build and dependencies completed.
- `tests/test_se_vpu.py` selection: **31 passed in 476.99s**.
- Raw FSUM ingress / 256-row boundary selection: **11 passed, 219 deselected in 211.80s**.
- Artifact `15225689330`, `sunnyone-vpu-index-width-log.zip`; extracted log contains both exact pytest summaries.
- This verifies the targeted VPU index-width/FSUM regression on the recorded source/configuration only. It does not prove full-chip correctness or close all lint warnings.
- Earlier attempt `46053329340` remains a toolchain build failure under apt Verilator 5.020, not a functional RTL failure and not a pass. The pinned 5.044 run above is the successful replacement.

## Latest workflow reconciliation at 2026-11-28 02:20 Asia/Dhaka
All listed runs were queried from the live repository:
- Full-chip lint `46053311384`: SUCCESS on source `05879ea34eafc2559c54722c6c940b2acb9ac3ee`; 52 WIDTHEXPAND, 7 WIDTHTRUNC, 7 LATCH, 3 UNOPTFLAT. Width warnings reduced 76 -> 59. Success means lint completed, not warning-free.
- VPU focused regression `46053471843`: SUCCESS, exact counts above.
- Board-functional `46053311399`: SUCCESS (the current reconciliation confirms workflow conclusion; do not infer new test counts without inspecting its log).
- RTL subsystem/memory `46053311328`: SUCCESS.
- RTL tail `46053311551`: SUCCESS.
- Reset/power-up audit `46053311560`: SUCCESS.
- ASIC/target configuration `46053311358`: SUCCESS.
- Additional board/RTL workflow `46053311433`: SKIPPED.
- Qwen real-checkpoint workflow `46053311477`: still IN_PROGRESS at last poll. Its real Qwen3/Qwen3.5 checkpoint verification and selected RTL cases had completed successfully; its eight tiny board-model cases were still running. Do not claim the overall workflow passed.
- Core software/ISA workflow `46053311585`: still QUEUED at last poll. No conclusion or test result is claimed.
- The connector exposes no workflow-cancellation action. Do not claim these runs were cancelled; do not launch replacement or broad duplicate runs. Re-poll only to reconcile their terminal state.
- Historical RTL groups 3.1/3.2/4, prior 200+ test evidence, and earlier board evidence remain preserved. Do not rerun solely for reassurance.

## Width and structural triage
- The 24 VPU function-mask indices and VPU row-buffer read/write index slices were sized in source commit `05879ea34eafc2559c54722c6c940b2acb9ac3ee`; the focused regression now passes.
- Structural SCC/latch audit `45914912691` remains scoped evidence for one-copy slice, two-slice top and the audited ASIC card top: zero SCCs and zero inferred latch cells in those elaborations. It is not proof for every parameter/configuration.
- The seven generic LATCH diagnostics are simulation-only diagnostic/oracle code under `ifndef SYNTHESIS`; audited synthesis elaborations showed no latch cells.
- Three generic UNOPTFLAT names (`gnt`, `pq`, `sc_gl`) and ASIC `aok` have zero-SCC evidence only in the audited configurations. Keep generic warnings visible; no blanket waivers.
- Two `otpu_dram.sv` `exists()` diagnostics are simulation-model-only; the ASIC flow source list excludes `rtl/mem/otpu_dram.sv`.
- MXU review: `dlane_a` at `rtl/mxu/otpu_mxu.sv:2247` guards the index with 32-bit `j+k < MCOLS`; `MW=$clog2(MCOLS)+1`, so the guarded sum is representable and below the array bound. This is a source-level range proof for the access, but the generic width diagnostic remains until a narrow, semantics-preserving lint treatment is justified and tested.
- MXU diagnostic indices at lines 2305, 2306 and 2607 are inside `ifndef SYNTHESIS` checking code. The remaining synthesis-visible MXU access at line 2663 (`mx_key[...]`) is guarded by `mxm[k]`; complete proof still requires documenting the bound on `c_M` against `MCOLS` across supported configurations. Do not narrow or cast it before that proof.
- Remaining full-chip lint counts are not signoff. All 52 WIDTHEXPAND diagnostics and the two synthesis-visible MXU index warnings require continued expression/configuration review; the seven WIDTHTRUNC total includes simulation-only diagnostics as classified above.

## Next actions — ordered, evidence-led
1. Re-poll only the existing Qwen `46053311477` and software-core `46053311585` runs; record exact terminal outcomes and test counts. Do not rerun them merely to obtain a fresher timestamp.
2. Finish proof for `mx_key[MW'(mx_i + k)]`: establish the legal range of `c_M` relative to `MCOLS`, the `mxm` register update/reset sequence, and all supported parameter configurations. Make no speculative RTL edit.
3. Continue the 52 width-expansion diagnostics by exact expression, signedness, carry/range and synthesis relevance. Preserve warnings until proven harmless or corrected with a focused test.
4. Expand formal/SVA beyond the existing global address-map proof; archive assumptions, covers, proof logs and exact source/tool hashes.
5. Complete CDC/RDC inventory and reports; SRAM macro/technology mapping; production PCIe/SerDes, DMA/IOMMU and DDR controller/PHY/training/ECC; DFT; routed physical/timing/power/thermal signoff.
6. Keep Track A full inference-accelerator architecture separate from Track B demonstrator. No demonstrator down-select or fabrication until target, source-port feasibility, PDK, area/timing, DFT and full sponsorship/sample logistics are evidenced.
7. No PPA retry: prior WG8 run `45877786710` has documented cgroup OOM-kill / host-memory exhaustion evidence; no routed PPA result exists.

## Release decision
**Manufacturer handoff: NOT READY.** G0-G15 remain incomplete to varying degrees. Simulation and structural proxy evidence must not be represented as physical silicon, routed signoff, production performance or manufacturer acceptance.

## Resume
Read this addendum, `CURRENT_CONTINUATION_CHECKPOINT_2026-11-28.md`, the integrated plan, `PROJECT_TRACKER.md` and `MANUFACTURER_HANDOFF_READINESS_MATRIX.md`; then re-resolve the live branch HEAD and Actions states before any write or test.
