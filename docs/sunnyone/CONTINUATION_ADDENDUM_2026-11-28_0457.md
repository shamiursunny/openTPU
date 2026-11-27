# SUNNYONE continuation addendum — 2026-11-28 04:57 Asia/Dhaka

This addendum supersedes earlier workflow snapshots for the specific runs polled below. It does not close the manufacturer readiness gate.

## 1. Repository and branch controls

- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Feature branch HEAD at the start of the documentation refresh: `fbb5e5f601e16225712f94812a8d41b3517397e5`.
- Documentation commits in this refresh: source/workload specification `53012371e598c8ce546e91770caaff93f8cf0063`; inventory link `986d54c0fccfa57a2c5c566c7c483f7551427811`; tracker update `a2463c647e70aee5d571ea13de7814d30ca05d77`; checkpoint update `ce96fe746d86ceb551fd72b626937245e732d559`. Re-fetch branch HEAD and all document blobs after this addendum commit.
- Main baseline: `d84db55712aba0d40811d7762cb052f05d55b7e5`; live compare before this refresh was 1,105 ahead / 0 behind, and after the tracker update 1,107 ahead / 0 behind. Main remains unchanged.
- GitHub API currently reports `main.protected=false`. Treat this as a branch-governance gap. The user's no-write instruction remains absolute; do not modify, merge, rebase or push to main.
- Zero-spend remains mandatory. No PPA retry, paid compute, PDK/IP, fabrication, packaging, hardware purchase or lab test without explicit approval. Never restart cancelled workflow `45765362426`; do not rerun historical RTL groups 3.1/3.2/4 solely to reconfirm.

## 2. VPU focused regression — terminal success

Workflow `46053471843`, job `140690259477`, source `40ce5cbd6f615215fbb8b7ee21b04aa541f451b6`:
- pinned Verilator 5.044 build and dependencies succeeded;
- `tests/test_se_vpu.py`: **31 passed in 476.99s**;
- raw FSUM ingress / 256-row boundary selection: **11 passed, 219 deselected in 211.80s**;
- artifact `15225689330`, ZIP SHA-256 `8c528b19d9a69e5d7a0053fb5bddd931072e33ec9cee4dfc539ef6a91b7187bd`.

The 42 focused tests passed on the recorded source/configuration. This does not establish full-chip correctness or warning-free lint.

## 3. Qwen and other workflow reconciliation

- Qwen real-checkpoint workflow `46053311477`: terminal SUCCESS on source `05879ea34eafc2559c54722c6c940b2acb9ac3ee`. Official Qwen3-0.6B and Qwen3.5-0.8B checkpoint checks, selected real-checkpoint RTL tests and eight tiny board-model cases all completed. This is CPU/RTL/model simulation evidence only, not silicon performance, fine-tuning or power evidence.
- Board-functional `46053311399`, RTL subsystem/memory `46053311328`, RTL tail `46053311551`, reset/power-up audit `46053311560`, ASIC/target config `46053311358` and full-chip lint `46053311384`: terminal SUCCESS on the same source `05879ea...`. Do not infer that every later branch commit was covered.
- Full-chip lint `46053311384`: lint command completed with 52 WIDTHEXPAND, 7 WIDTHTRUNC, 7 LATCH diagnostics and 3 UNOPTFLAT diagnostics. This is not warning-free closure. Existing structural SCC/latch audit remains scoped to its exact elaborations.
- Additional run `46053311433`: SKIPPED; no pass claim.

## 4. Software waits recovery

- Software-core run `46053311585`: 14 module jobs succeeded. The waits-only job was cancelled during attempt 2 at approximately 85% of its pytest output. The log showed `test_boot_entries_follow_the_longest_program[4]` and `test_waitc_rtl_boot_programs_of_different_lengths[2]` as passed before cancellation; the full waits module did not complete.
- An isolated rerun of only the waits job was accepted. Latest job ID `140775908058` was **IN_PROGRESS** at the 04:57 poll; setup, checkout, Python, Verilator and dependency installation had succeeded, and the pytest step was still running.
- Poll only this job until terminal, inspect the exact pytest summary and archive artifact. Do not rerun the other 14 successful module jobs. No full software matrix pass claim until waits completes.

## 5. Workflow ancestry

- Compare confirms VPU tested source `40ce5cbd...` is an ancestor of the active branch (42 commits behind at the ancestry check).
- Software/Qwen source `05879ea...` is an ancestor of the active branch (44 commits behind at the ancestry check).
- These workflows validate their exact ancestor revisions and configured selections, not the later branch changes. Record source SHA for every result; never label a workflow as testing current HEAD when it did not.

## 6. Source/interface map and architecture consequence

Created `docs/sunnyone/SOURCE_INTERFACE_AND_WORKLOAD_TRACE_SPEC_2026-11-28.md` (commit `53012371e598c8ce546e91770caaff93f8cf0063`) and linked it from `SOURCE_INTERFACE_INVENTORY_2026-11-28.md` (commit `986d54c0fccfa57a2c5c566c7c483f7551427811`).

The source-level map records:
- ASIC chip wrapper's BAR0 AXI4-Lite and external A/B/SW/W memory-adapter boundaries;
- compute top's single `otpu_slice` instance and separate collective block;
- sequencer/unit handshakes and DMA/MXU/quantizer/VPU/optional stream roles;
- eight TMEM read ports and DMA/MXU/VPU/collective write sources;
- existing host software scheduler, KV store, RTL trace decoder, TMEM trace parser and Verilator simulator.

The current LPU is a software/runtime scheduling role, not a separate RTL block. Existing 32-token decode quantum and 64-token non-polling chunk cap are current defaults, not optimised values. First tune and measure existing scheduler/cache/compiler/runtime and resource use before proposing dedicated LPU hardware.

## 7. Next engineering sequence

1. Finish the waits-only rerun and save its exact result.
2. Implement deterministic request trace schema/generator with integer simulation time, stable same-timestamp ordering, validation, cancellation/fault/recovery and replay hash.
3. Build a discrete-event resource model only with explicit, versioned service profiles. Unknown service times, bandwidths and energy coefficients must remain unset; do not invent them.
4. Use W1 single-request, W2 concurrent mixed, W3 burst/contention/cancellation/fault and conditional W4 long-context/KV-pressure fixtures.
5. Correlate model events against `opentpu/hwtrace.py` and `tools/tmem_trace.py`; report utilisation, memory traffic, queue wait, TTFT, decode latency, KV pressure and stalls.
6. Do not report joules/token or thermal results until calibrated whole-system power/thermal data exists.
7. Continue MXU `mx_key` malformed-command bounds proof, width-warning review, formal/SVA, CDC/RDC, DFT, SRAM mapping, production interfaces and routed physical signoff.
8. Keep Track A full accelerator separate from Track B demonstrator. No down-select or fabrication until target workload, source-port feasibility, PDK, area/timing, testability and fully funded sample/package/test/custody/shipping terms are evidenced.

## 8. Release decision

**Manufacturer handoff: NOT READY.** No routed physical signoff, production memory/host interface qualification, complete formal/CDC/RDC/DFT closure, calibrated power/thermal result or fully funded fabrication and sample logistics are established.

This refresh changed documentation only. No RTL, ISA, PPA, hardware or paid service changed or ran. The only test action was the previously accepted isolated waits-job rerun.


## 9. Deterministic workload trace generator — implemented and tested

- Added `tools/sunnyone/workload_trace.py` in commit `3b03f52ad525f7f4c38d212dbd2ecab7a83a9353`. It validates workload/request identity, model/checkpoint/tokenizer/template metadata, integer arrival/deadline/cancel/fault ticks, prompt/output/context lengths, priority and deterministic seeds. It emits canonical JSONL request events with stable same-timestamp ordering and a replay SHA-256.
- Added `tests/test_sunnyone_workload_trace.py` in commit `b8451c5393bc22d02512182349395bfca27c2913`. The 10 tests cover deterministic serialization/hash, same-tick ordering, context default, duplicate IDs, past events, bool-vs-int rejection, fault contract, unknown fields and no invented service/power fields.
- Updated `.github/workflows/sunnyone-workload-harness.yml` in commit `88e3f5636d9d1818e59e8309e7bd26fa7c07e807` to compile the new generator.
- Targeted workflow `46080190053`, job `140777139012`, tested head `88e3f5636d9d1818e59e8309e7bd26fa7c07e807`: **SUCCESS**. The combined deterministic SUNNYONE harness ran **16 tests in 0.513s, OK** (10 workload-trace, 3 endpoint benchmark, 3 retrieval metric tests). Superseded run `46080182042` was cancelled by the workflow concurrency rule after the subsequent workflow-file update; the replacement run passed.
- This closes only the deterministic exogenous request-trace generator and its unit tests. It does not simulate MXU/VPU/DMA/TMEM/DRAM service, cycle counts, throughput, energy, power or thermal behaviour. Do not report any accelerator performance result from it.
- Next implementation: a separate integer-time discrete-event resource model that consumes the validated trace and requires explicit, versioned stage service profiles. Unknown service time/bandwidth/power values must remain unset. Validate model-level queue/resource invariants and correlate with actual `hwtrace`/`tmem_trace` outputs before using it to rank architectural alternatives.


## 10. Resource event model and semantic trace validation — 2026-11-28 05:12 Asia/Dhaka

### Implemented files
- `tools/sunnyone/resource_event_model.py`: deterministic integer-time, profile-driven resource queue model.
- `tests/test_sunnyone_resource_event_model.py`: model timing, FIFO, finite capacity, multi-stage resources, TTFT, cancellation, fault, deadline, trace integrity and profile validation.
- `.github/workflows/sunnyone-workload-harness.yml`: compiles the resource model and includes its source path in the isolated deterministic harness.
- `docs/sunnyone/RESOURCE_EVENT_MODEL_SPEC_2026-11-28.md`: profile contract, semantics, CLI, limitations and calibration procedure.

### Final passing evidence
- Workflow `46081103514`, job `140780031472`, exact tested source `0ab52a61659a4746eb3375d7e5f146f3fbf192ae`: **SUCCESS; 34 tests passed in 0.517s; OK**.
- Breakdown: 18 resource event model tests, 10 deterministic workload trace tests, 3 endpoint benchmark tests, 3 retrieval metric tests. The job log confirms all test groups and terminal OK.
- The earlier model-only revision `7703ff4a8bf6c8fb4e34dcf200bb259eed1ef79b` passed 31 tests; subsequent semantic validation added three more tests. Superseded/cancelled harness runs were not counted as passes.
- During development, intermediate runs exposed a missing trace-chunk state, incorrect active-cancellation occupancy accounting, a malformed tick-unit test fixture and a YAML syntax error. These were corrected. The final tested commit passes the complete harness; do not hide the earlier failures when describing history.

### Model semantics and limits
- Profile is mandatory and explicit: identity/version, origin, provenance, tick unit, resource capacities and per-stage service ticks per unit. No default hardware service times or capacities.
- Model supports sequential ordered stages in prefill and decode, FIFO resource queues, finite concurrency, prompt chunking, one-token decode units, cancellation/fault abort, deadline marking, TTFT after final stage of first decode token, and resource occupancy/queue-wait reports.
- Trace input is validated for schema, event count/hash, contiguous sequence, integer ordered ticks, unique arrival, required metadata, positive token counts, arrival-before-control, unique controls and valid fault payload.
- No production or RTL-calibrated profile exists yet. Test profiles are synthetic fixtures only. The model does not infer chip throughput, power, energy, temperature, area or manufacturing cost. Admission/fairness, batching, KV/cache, explicit DMA byte timing, TMEM arbitration, DRAM, NoC and preemption are not yet represented as independent mechanisms.
- RTL calibration path inspected: `opentpu/hwtrace.py` decodes D/S/G/E and U/P/Q/H records; `tools/tmem_trace.py` parses TMEM access, instruction and producer/consumer flow. Correlation adapter/profile extraction is not yet implemented.

### Outstanding work
1. Finish the existing waits-only recovery job `140775908058` in software-core workflow `46053311585`. It remains IN_PROGRESS on attempt 3; all other 14 module jobs were already successful and must not be rerun. Workflow timeout is 45 minutes; check elapsed/start time and exact job status before any action. Do not cancel unless it has exceeded timeout or become demonstrably stuck, and never rerun the other modules.
2. Implement correlation tooling for `hwtrace.py` and `tmem_trace.py` using exact same-source/configuration traces; do not guess per-request stage attribution from aggregate counters.
3. Add explicit admission and tenant-fairness semantics from existing runtime scheduler source, then add W1/W2/W3 controlled fixtures. W4 remains conditional on supported context/KV capacity.
4. Continue MXU `mx_key` proof, width-warning semantic triage, formal/SVA, CDC/RDC, DFT, SRAM mapping, production interfaces, routed physical signoff and evidence-based cost/thermal gates.

Manufacturer handoff remains **NOT READY**. No RTL or ISA change, no PPA retry, no paid compute, no fabrication or hardware spend was made in this milestone.
