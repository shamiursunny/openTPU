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

## 2026-11-28 — unified NPU / TPU / LPU architecture direction

Read `docs/sunnyone/UNIFIED_NPU_TPU_LPU_PETASCALE_AI_ARCHITECTURE_2026-11-28.md` and tracker section 133.

- User wants matrix TPU acceleration, quantum-inspired classical LPU and NPU technology combined to share their strongest capabilities for AI inference.
- Proposed organisation: TPU/MXU for matrix projections and attention GEMMs; LPU for chunked prefill, long-context attention/KV management and decode scheduling; NPU/VPU for supported vector, elementwise, reduction and neural operators; shared scheduler, memory/context fabric, DMA and interconnect.
- "Petabyte-level" is interpreted as distributed system/cluster-scale storage and data/context corpus processing, not petabytes of on-chip memory or a single request attending to an entire petabyte. Capacity, bandwidth, latency, compute throughput and model context length must be measured separately.
- Unified architecture proposal created in `UNIFIED_NPU_TPU_LPU_PETASCALE_AI_ARCHITECTURE_2026-11-28.md` (commit `dfb9f96bd14b77404afbdc66c14d7715c23d181d`). It is documentation only. Existing MXU/VPU/TMEM/DMA/sequencer/host runtime are concrete foundations; integrated NPU/LPU fabric is not yet implemented.
- Next engineering step: source/interface inventory, deterministic heterogeneous scheduling and long-context workload traces, then profile supported model paths. No speculative RTL, benchmark claim, PPA, paid compute or hardware. Main remains untouched; manufacturer handoff NOT READY.


## 2026-11-28 — ultimate commercial north star and work resumed

- Governing objective: maximise risk-adjusted lifetime commercial profitability by delivering the greatest amount of accepted useful AI inference per watt and per dollar, while minimising idle power, heat/cooling, manufacturing and operating cost, instability, failures and deployment complexity. The strategic objective is fixed; implementation remains evidence-led and may change only to better meet it or satisfy correctness, safety, feasibility and manufacturability.
- Authoritative plan: `docs/sunnyone/SUNNYONE_X_ULTIMATE_COMMERCIAL_NORTH_STAR_2026-11-28.md`.
- Initial source/interface inventory: `docs/sunnyone/SOURCE_INTERFACE_INVENTORY_2026-11-28.md`.
- Live source findings: `otpu_asic_chip_top` wraps host control and external memory adapter; `otpu_asic_top` instantiates one `otpu_slice`; slice combines sequencer/scoreboard, DMA, MXU + ACT RAM, quantizer, VPU/stream and TMEM. Existing MXU is matrix engine foundation; VPU/stream is vector/neural foundation; sequencer/host runtime is initial LPU scheduling foundation. No separate LPU or standalone NPU macro is claimed implemented.
- Next: finish precise source instance/handshake/queue/error map; locate simulator trace hooks; implement deterministic AI workload traces for prefill, decode, attention, KV lifecycle, contention, batching, cancellation and failures; establish operation/memory baselines before power model; profile supported model paths; optimise existing software/configuration before RTL.
- Current branch head observed before these commits: `5be983d46a1caca5d715ca08064c5d81b1eabf9f`. Documentation commits: north star `a2f091f0436f1960dac0a90789d5087fb9ca0a6b`; source inventory `6c80d0acfee9f4236ceac830321fff5e056977a4`. Main baseline remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; no main write.
- Important workflow caveat: software-core run `46053311585` was launched from `05879ea34eafc2559c54722c6c940b2acb9ac3ee`, not the currently observed branch HEAD. Attempt 2 has 14 module jobs SUCCESS and only waits job `140738728795` still IN_PROGRESS. Do not call matrix green or attribute it to current HEAD without ancestry reconciliation. Qwen run `46053311477` previously recorded SUCCESS; re-poll before relying on it.
- No tests rerun, no RTL/ISA changes, no PPA, spend, hardware or QPU action. Do not rerun previously passed RTL groups 3.1/3.2/4 or cancelled run `45765362426`. Zero spend. Manufacturer handoff NOT READY.


## 2026-11-28 — existing LLM serving and profiling infrastructure mapped

- Additional source inspection: `opentpu/serve/scheduler.py` already has bounded concurrent request admission, prompt-first scheduling, round-robin active decode, token quantum (default 32), non-polling backend chunk cap (default 64), cancellation/yield checks, and card/host decode paths. `opentpu/serve/store.py` supports host RAM/disk KV context persistence, prefix matching, pinning and tiered eviction.
- `tests/test_serve_scheduler.py` covers multi-request correctness, shared prefix, stop/max_new/cancel, disk persistence and stateful conversation continuation; not executed in this inspection.
- Trace/profiling foundation: `opentpu/hwtrace.py`, `tools/tmem_trace.py`, `opentpu/rtlsim.py`, `opentpu/isasim.py`. Endpoint benchmark captures TTFT/latency and server usage, not wall power or independent quality. Retrieval benchmark measures ranking quality and embedding/rerank timing on labelled data.
- Strategic consequence: build the initial LPU as measured runtime/scheduler capability around existing engines; tune existing queue, prefill/decode fairness, cache, memory and DMA paths before proposing a new hardware block. Default 32/64 token values are baselines, not optimised recommendations.
- Inventory addendum commit: `1f30da07c54dcaa93287ef92057a0b40130305d4`.
- Software-core run `46053311585`: last job poll still has only waits job `140738728795` IN_PROGRESS; other 14 jobs SUCCESS. Qwen run `46053311477` was rechecked in this session (see tracker update for state).
- No new tests, RTL changes, PPA, spend or hardware actions. Historical exclusions and main no-write rule unchanged.


## Final live reconciliation — 2026-11-28

- Branch HEAD: `696bd657500a0cfbf2ea42e38afa7fb6adc0e888`.
- Compare: current branch is 1,103 commits ahead / 0 behind main baseline `d84db55712aba0d40811d7762cb052f05d55b7e5`; main untouched.
- Workflow source `05879ea34eafc2559c54722c6c940b2acb9ac3ee` is an ancestor of current branch (42 commits behind HEAD, 0 ahead). Existing CI evidence therefore covers that ancestor only, not later commits or new docs.
- Qwen run `46053311477` is terminal SUCCESS on the ancestor source, limited to its configured RTL/model-checkpoint scope.
- Software-core run `46053311585` attempt 2 remains IN_PROGRESS only for waits job `140738728795`; other 14 module jobs are SUCCESS. Poll this exact job; no duplicate CI.


## 2026-11-28 04:57 Asia/Dhaka — continuation refresh

Read first on the next continuation:
1. `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_0457.md`
2. `docs/sunnyone/SOURCE_INTERFACE_AND_WORKLOAD_TRACE_SPEC_2026-11-28.md`
3. `docs/sunnyone/INTEGRATED_ENGINEERING_AND_SPONSORED_SILICON_PLAN_2026-11-27.md`
4. `docs/sunnyone/PROJECT_TRACKER.md`
5. `docs/sunnyone/MANUFACTURER_HANDOFF_READINESS_MATRIX.md`

### Live state and constraints
- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Feature branch HEAD at the start of this refresh: `fbb5e5f601e16225712f94812a8d41b3517397e5`; documentation commits in this refresh: source/workload spec `53012371e598c8ce546e91770caaff93f8cf0063`, inventory link `986d54c0fccfa57a2c5c566c7c483f7551427811`, tracker update `a2463c647e70aee5d571ea13de7814d30ca05d77`. Re-poll the live branch ref after the final checkpoint/addendum commits.
- Main remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare before this checkpoint update: 1,107 ahead / 0 behind. GitHub API reports main branch protection disabled (`protected=false)); never write to main regardless.
- Zero spend. No PPA retry, no paid compute/PDK/IP, no fabrication, packaging, hardware or lab expenditure without explicit approval. Do not rerun historical RTL groups 3.1/3.2/4 or cancelled run `45765362426`.

### Latest test reconciliation
- VPU focused workflow `46053471843`: SUCCESS; 31 `test_se_vpu.py` tests plus 11 raw FSUM ingress/boundary tests passed (219 deselected), source `40ce5cbd6f615215fbb8b7ee21b04aa541f451b6`, artifact `15225689330`.
- Qwen workflow `46053311477`: SUCCESS on source `05879ea34eafc2559c54722c6c940b2acb9ac3ee`; real Qwen3/Qwen3.5 checkpoints, selected RTL tests and eight tiny board-model tests completed. Simulation only.
- Board, subsystem/memory, tail, reset audit, ASIC config and full-chip lint runs `46053311399`, `46053311328`, `46053311551`, `46053311560`, `46053311358`, `46053311384` are terminal SUCCESS on the same ancestor source `05879ea...`. Lint is not warning-free: 52 WIDTHEXPAND, 7 WIDTHTRUNC, 7 LATCH diagnostics and 3 UNOPTFLAT remain.
- Software-core run `46053311585`: 14 module jobs succeeded. Only waits module job was cancelled at about 85%; attempt 3 retry of that single job is job `140775908058`, IN_PROGRESS at last poll. Poll this job only; do not rerun other modules.
- Tested source ancestry: VPU source `40ce5cbd...` is 42 commits behind current branch at the ancestry check; software/Qwen source `05879ea...` is 44 commits behind. Preserve this limitation.

### New source/workload map
- New document: `SOURCE_INTERFACE_AND_WORKLOAD_TRACE_SPEC_2026-11-28.md`. It records source blob IDs and verified ASIC wrapper/compute/slice, unit handshake, TMEM, memory-channel and software LPU boundaries.
- W1 single-request, W2 concurrent mixed, W3 burst/contention/cancel/fault, and conditional W4 long-context/KV pressure are defined as deterministic fixture classes. The next implementation is a request-trace generator and explicit-profile event model. Unknown service times must remain unset; no fabricated cycle, bandwidth, power or energy values.
- Existing software scheduler defaults (32-token quantum, 64-token non-polling chunk cap) are baselines, not optimised values. Correlate scheduler/event traces with `opentpu/hwtrace.py` and `tools/tmem_trace.py` before considering RTL changes.

### Remaining engineering gates
1. Finish the isolated waits-only job and archive exact pytest summary.
2. Implement and test deterministic workload trace schema/generator; then build the resource event model using explicit, versioned service profiles only.
3. Prove MXU `mx_key` command bounds for all supported configurations; design synthesizable rejection only if malformed raw programs can reach the path.
4. Continue semantic width-warning review, formal/SVA, CDC/RDC, DFT, SRAM technology mapping, production PCIe/SerDes, DMA/IOMMU, DDR controller/PHY/training/ECC, routed physical/timing/power/thermal qualification.
5. Keep Track A full accelerator separate from Track B demonstrator. No down-select/fabrication until technical, PDK, area/timing, DFT and full sponsorship/sample logistics are evidenced.

Manufacturer handoff remains **NOT READY**. This refresh changed documentation only; no RTL, ISA, test or workflow source was modified and no new test was launched except the previously accepted waits-only job rerun.


## Final save metadata — 2026-11-28

- Latest continuation addendum: `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_0457.md`, commit `52dd39718a0c17a133619e43e48b7b3699aa9bc1`, blob `ef7c59dc813d81dbadd73e789327b250197cb948`.
- Source/interface/workload spec blob: `d224ab00f35871a9c9fdd8e423b508ff245800c8`.
- Source inventory blob: `18c055222993e8c022e0b5191ba4999acebb1493`.
- Project tracker update commit: `5b462819f6013f6c09cb68b06e23a62ebb784fca`, blob `56a0caa5261e80abd3ebd2df12e36142b41777ee`.
- The final branch HEAD and checkpoint blob must be re-polled after this commit. Do not infer a final HEAD from this note's parent commit.
- Only outstanding CI recovery at the last poll: waits job `140775908058` in workflow `46053311585`; all other listed module jobs were successful and must not be rerun.


## 2026-11-28 — deterministic workload trace generator progress

- Implemented `tools/sunnyone/workload_trace.py` (commit `3b03f52ad525f7f4c38d212dbd2ecab7a83a9353`) and 10 focused tests in `tests/test_sunnyone_workload_trace.py` (commit `b8451c5393bc22d02512182349395bfca27c2913`). It emits canonical JSONL request arrival/fault/cancel/deadline events with integer timestamps, stable ordering and replay SHA-256. It contains no assumed hardware service times, performance or power.
- Updated isolated harness compile workflow (commit `88e3f5636d9d1818e59e8309e7bd26fa7c07e807`). Run `46080190053`, job `140777139012`, SUCCESS on that exact head. Combined SUNNYONE unit harness: **16 tests in 0.513s, OK**. Superseded run `46080182042` was cancelled by concurrency and replaced by the successful run.
- Updated source/workload spec in commit `ca4df9a19bb2f62d71d169ce368a52a58b438b7c`; continuation addendum in commit `6bf9a5479093abde62c49053eaa84a0784913349`; tracker in commit `31d64191b35df1a7d31a61bbe98ad92a8dbcf003`.
- Next: implement and test the separate discrete-event resource model using only explicit, versioned service profiles, then correlate model events with RTL `hwtrace` and `tmem_trace`. Do not claim throughput, joules/token or thermal values until validated/calibrated evidence exists.
- The isolated waits-only recovery job `140775908058` from run `46053311585` remained IN_PROGRESS at the last poll. Poll this one job; do not rerun the other 14 successful software modules.


## 2026-11-28 05:12 Asia/Dhaka — latest continuation checkpoint

### Current working state
- Repository: `shamiursunny/openTPU`.
- Branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Main baseline must remain untouched: `d84db55712aba0d40811d7762cb052f05d55b7e5`. Never merge/write to main without explicit approval. GitHub API reports main protection false; treat as governance risk, not permission.
- Latest implemented source/test commits: resource model `ef9eeb8ff929ae2dd6cee4e6c8c6a0197895d673`; expanded model tests `0ab52a61659a4746eb3375d7e5f146f3fbf192ae`; final passing harness run tested exactly `0ab52a61659a4746eb3375d7e5f146f3fbf192ae`.
- Latest passing workflow `46081103514`, job `140780031472`: **SUCCESS, 34 tests in 0.517s, OK**. Breakdown: 18 resource event model, 10 workload trace, 3 endpoint benchmark, 3 retrieval metrics.
- The final model harness compiles `resource_event_model.py`, runs all SUNNYONE deterministic unit tests, and has a valid YAML workflow path filter. Superseded runs include failures/cancellations; use only final successful run as current evidence.

### Newly implemented modules
- `tools/sunnyone/workload_trace.py`: deterministic validated JSONL exogenous request trace generator with replay SHA-256.
- `tools/sunnyone/resource_event_model.py`: deterministic integer-tick queue model with mandatory explicit profile, ordered prefill/decode stages, finite resource capacities, FIFO queues, cancellation/fault abort, deadline marking, TTFT and resource occupancy.
- Trace semantic validation covers exact event schema, hash/count/sequence/order, required arrival metadata, positive token counts, arrival-before-control, duplicate controls and valid fault payload.
- Model specification: `docs/sunnyone/RESOURCE_EVENT_MODEL_SPEC_2026-11-28.md`. No production/RTL-calibrated profile exists; unit tests use synthetic fixture profiles only. No accelerator throughput, power, energy, thermal or manufacturing-cost claim.

### Current CI recovery
- Software-core workflow `46053311585`, attempt 3. Only waits module job `140775908058` remains IN_PROGRESS at last poll; attempt started 2026-11-27T22:58:36Z and workflow timeout is 45 minutes. Check the exact job state/log and elapsed time. Do not rerun the other 14 successful module jobs. If the waits-only job exceeds its configured timeout or is demonstrably stuck, cancel/retry only that job, preserving all 14 successful module results.
- Do not rerun RTL groups 3.1/3.2/4 or cancelled workflow `45765362426` merely to reconfirm historical passes.

### Next work sequence
1. Poll and resolve the waits-only recovery job.
2. Implement source-grounded trace correlation between `opentpu/hwtrace.py` D/S/G/E/U/P/Q/H records and `tools/tmem_trace.py` access/instruction/producer-consumer records. Use identical source/config/workload; no aggregate-to-request attribution guesses.
3. Model scheduler admission and tenant fairness from existing runtime source; add W1/W2/W3 fixtures. W4 only after context/KV capacity support is verified.
4. Continue MXU `mx_key` bounds proof, semantic width-warning triage, formal/SVA, CDC/RDC, DFT, SRAM technology mapping, production PCIe/SerDes, DMA/IOMMU, DDR controller/PHY/ECC and routed physical signoff.
5. Preserve Track A full accelerator versus Track B demonstrator separation; no down-select/fabrication without target workload, PDK, area/timing, DFT, supplier quotes and funded sample/package/test/shipping plan.

### Latest documentation
- `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_0457.md`
- `docs/sunnyone/RESOURCE_EVENT_MODEL_SPEC_2026-11-28.md`
- `docs/sunnyone/SOURCE_INTERFACE_AND_WORKLOAD_TRACE_SPEC_2026-11-28.md`
- `docs/sunnyone/PROJECT_TRACKER.md`
- `docs/sunnyone/MANUFACTURER_HANDOFF_READINESS_MATRIX.md`

Zero spend. No PPA retry, no paid compute/PDK/IP, no fabrication, packaging, board or lab expenditure. Manufacturer handoff remains **NOT READY**.
