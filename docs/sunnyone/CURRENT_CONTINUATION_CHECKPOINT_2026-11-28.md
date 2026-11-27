# SUNNYONE — Current Continuation Checkpoint
Last updated: 2026-11-28 02:20 Asia/Dhaka

## Start here in every new chat
Read this file, then:
1. `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_0220.md`
2. `docs/sunnyone/INTEGRATED_ENGINEERING_AND_SPONSORED_SILICON_PLAN_2026-11-27.md`
3. `docs/sunnyone/PROJECT_TRACKER.md`
4. `docs/sunnyone/MANUFACTURER_HANDOFF_READINESS_MATRIX.md`

Before any code write or test, re-resolve the live branch HEAD, compare against main and current Actions states.

User continuation command: **Continue and complete the remaining tasks.**

## Repository and controls
- Repository: `shamiursunny/openTPU`.
- Working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Branch HEAD before this checkpoint save: `75a02e23bfb1b841be4805914659c4823252c370`.
- Main baseline: `d84db55712aba0d40811d7762cb052f05d55b7e5`; do not modify main.
- Live compare at 02:20 poll: 1,072 ahead, 0 behind.
- Zero spend. No PPA retry, paid runner/compute, PDK/IP purchase, hardware, fabrication, packaging or lab test without explicit approval.
- Never rerun historical RTL groups 3.1, 3.2 and 4 solely for reassurance. Preserve all historical pass evidence and exclusions, including cancelled run `45765362426`.

## Latest verified engineering
- VPU source fix commit: `05879ea34eafc2559c54722c6c940b2acb9ac3ee`.
- Focused VPU workflow `46053471843`: SUCCESS on `40ce5cbd6f615215fbb8b7ee21b04aa541f451b6`; 31 VPU tests passed and 11 raw FSUM ingress/boundary tests passed (219 deselected). Artifact `15225689330`.
- Full-chip lint `46053311384`: SUCCESS as a completed lint job, not warning-free; 52 WIDTHEXPAND, 7 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT. Width warnings reduced from 76 to 59.
- Structural audit `45914912691`: zero combinational SCCs and zero inferred latch cells in the three exact audited elaborations; scope-limited.
- Two behavioral DRAM `exists()` diagnostics are simulation-only because the ASIC source list excludes the behavioral DRAM model.
- MXU `dlane_a` index has a source-level range guard; MXU `mx_key` access at line 2663 still needs full `c_M <= MCOLS` proof before any narrowing.
- Remaining 52 expansion warnings require semantic review. Formal/SVA, CDC/RDC, DFT, technology mapping, production interfaces, DDR PHY, routed physical signoff and measured power/thermal remain open.

## Current workflow state at last poll
- Qwen run `46053311477`: IN_PROGRESS; real checkpoint and selected RTL stage passed, eight tiny board-model cases still running. Overall workflow is not a pass yet.
- Software/ISA run `46053311585`: QUEUED; no result.
- Board `46053311399`, subsystem `46053311328`, RTL tail `46053311551`, reset audit `46053311560` and ASIC config `46053311358`: SUCCESS.
- Run `46053311433`: SKIPPED.
- No workflow cancellation action is available through the current connector. Do not claim cancellation; re-poll existing runs without dispatching duplicates.

## Physical / manufacturer status
- WG8 PPA `45877786710`: FAILURE with cgroup OOM-kill / host-memory exhaustion evidence; no routed PPA/signoff. Do not retry.
- Manufacturer handoff: **NOT READY**. G0-G15 remain open/partial/blocked as recorded in the readiness matrix.
- Track A full programmable inference accelerator and Track B first-silicon demonstrator remain separate.
- No zero-cost fabrication, sponsor, package/test, sample custody or shipping arrangement is confirmed.

## Next work
1. Re-poll only existing Qwen and software-core runs for terminal status and exact counts.
2. Prove the MXU `mx_key` index range across supported parameter configurations.
3. Continue width-expression semantic review without blanket casts or suppressions.
4. Continue formal/SVA, CDC/RDC, DFT, SRAM/DDR mapping, production interfaces and demonstrator feasibility.
5. Keep manufacturer release gate closed until every required evidence and external dependency is satisfied.

No RTL, test or workflow source was changed in the 02:20 continuation. Documentation-only updates are recorded in the continuation addendum and tracker.


## Additional MXU safety finding (2026-11-28)
ISA documentation requires `M <= MCOLS` for RMAX/ASCALE/PAIR. The MXU stores `h.M` directly from the command's `w6[23:16]`, and the RMAX key array has depth `MCOLS`. The current RTL review did not find explicit hardware rejection of malformed RMAX/ASCALE/PAIR shapes. This is an open malformed-command bounds-safety question, not a failure for legal ISA programs. Trace loader validation and parameter wiring before deciding whether a synthesizable guard is required. Do not narrow the `mx_key` index until this is resolved.


## 2026-11-28 — matrix-first and quantum-hybrid continuation

Read `MATRIX_FIRST_QUANTUM_HYBRID_ARCHITECTURE_2026-11-28.md` and tracker section 129.

- Matrix computing is prioritised as a core classical architecture improvement using the existing MXU, VPU, TMEM/local storage, DMA and compiler/runtime. Proposed investigations: tile/dataflow selection, precision semantics, operand reuse, memory traffic, fusion and optional sparsity. No unsupported precision or performance claim is made.
- Quantum computing remains an optional host-side adapter to an external QPU for workload-specific research. It is not integrated into the silicon die and is not a substitute for the MXU/VPU.
- Live branch at the start of this update: `965ebd0d50f7bf942af1d7bf5365a98d614397ca`; compare 1,079 ahead / 0 behind main `d84db55712aba0d40811d7762cb052f05d55b7e5`. All documentation writes are restricted to the feature branch.
- Qwen workflow `46053311477` is now terminal SUCCESS. Software-core run `46053311585` has a CANCELLED waits job; all other listed module jobs concluded SUCCESS. The software matrix is not wholly green; inspect only missing waits scope.
- MXU malformed-command bounds investigation remains the next source-level priority. Do not cast/narrow `mx_key` before proving command validation and `c_M <= MCOLS` for every supported configuration.
- Zero spend; no PPA retry; no historical successful-suite reruns; no main writes. Manufacturer handoff remains NOT READY.


## Final live verification — 2026-11-28

- Matrix/quantum architecture addendum: `MATRIX_FIRST_QUANTUM_HYBRID_ARCHITECTURE_2026-11-28.md`; its creation commit is `8d8800c6b3cdadb966c008f73b98d5dd27c7415b`.
- Post-update live verification at this checkpoint revision: branch HEAD `86940ff75b03852f113ad167aef9e6fda893ce96`, 1,082 ahead / 0 behind main `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- GitHub API reports main `protected=false`; treat this as an administrative protection gap, not permission to write to main. Keep all work on the feature branch.
- Qwen run `46053311477` SUCCESS. Software-core run `46053311585` CANCELLED overall because its waits job was cancelled; remaining listed module jobs succeeded. Full software matrix is not green.
- The architecture and tracking changes are documentation-only. No RTL/test/workflow/PPA run, no spend and no hardware/QPU action. Manufacturer handoff NOT READY.


## 2026-11-28 — MXU bounds investigation and waits job recovery

Read `MXU_COMMAND_BOUNDS_AND_WAITS_CONTINUATION_2026-11-28.md` and tracker section 131.

- Confirmed the MXU command shape checks are simulation-only (`ifndef SYNTHESIS`). The ISA requires `0<M<=ACT_ROWS`, and RMAX/ASCALE/PAIR require `M<=MCOLS`; PAIR also requires `2*M<=MCOLS`. `cmd_e.M` is copied directly from raw command bits; no generic synthesizable MM legality guard was found in the reviewed sequencer dispatch. Potential malformed-program hardware bounds-safety gap; legal-program failure not established.
- RMAX `mx_key` write index depends on the lane mask and command M. Do not cast, clamp or suppress the warning. Design a synthesizable reject path and focused raw-command tests first.
- Only cancelled waits module job `140689717010` from run `46053311585` was targeted for rerun; GitHub accepted attempt 2. Pending at checkpoint note creation. Other 14 module jobs were already successful and were not rerun.
- No RTL change, broad tests, main write, PPA retry or spending. Manufacturer handoff NOT READY.


- Follow-up poll after documentation save: software-core run `46053311585` is on attempt 2, overall IN_PROGRESS. The only rerun job is now job ID `140738728795` (`tests/test_waits.py`); setup, checkout, Python, Verilator and dependency installation succeeded, and the selected pytest step is still running. No conclusion or test count is available yet.


## 2026-11-28 — user-directed quantum-inspired LPU architecture

Read `docs/sunnyone/QUANTUM_INSPIRED_LPU_LONG_CONTEXT_ARCHITECTURE_2026-11-28.md` and tracker section 132.

- Clarification: the user wants quantum-computing ideas used as inspiration for **classical language-model inference acceleration**, not quantum-computing workloads. Target is higher prompt/prefill throughput, faster long-context reading/attention, faster decode tokens/s, improved concurrency and lower memory traffic/energy per useful token.
- Proposal uses existing MXU/VPU/stream engine/TMEM/DMA/sequencer/host runtime: chunked prefill; tiled QKᵀ and PV; stable online softmax where supported; tiered/paged KV with exact prefix reuse and isolation; continuous batching; optional verified speculative decoding.
- Quantum-inspired low-rank/tensor-network, structured routing and scheduling ideas remain experimental software/compiler hypotheses, not quantum hardware or guaranteed speedups. Dense/exact fallback and quality/equivalence checks are mandatory.
- New design note created at `QUANTUM_INSPIRED_LPU_LONG_CONTEXT_ARCHITECTURE_2026-11-28.md`; matrix/quantum addendum and tracker updated. Documentation-only commits: LPU note `42cd44e4a1c97d74501fbbbb604927d629d7a448`, architecture clarification `08424b3dd64fa78bec5e7019e52c436963e0f1aa`, tracker `f23acf9a8cf464677fd38daf24db78c0fc8ef7f0`.
- No RTL/ISA/workflow change or performance claim. Next engineering step is deterministic workload/trace inventory and profiling of existing supported model paths; do not create a new hardware block until a measured bottleneck and verification plan justify it.
- The targeted waits job `140738728795` in run `46053311585` was still IN_PROGRESS at the last poll; re-poll before claiming a result.
- Continue feature branch only; no main writes, no PPA retry, no paid service or spend. Manufacturer handoff remains NOT READY.
