# SUNNYONE continuation addendum — 2026-11-28 21:10 Asia/Dhaka
## MM FIFO constraint correction and pre-dispatch guard contract

### Correction to the 20:35 addendum
The proposed target-wide invariant `FIFO_DEPTH >= ACT_BLOCKS` is **rejected** and must not be implemented. It was an overgeneralisation from the relationship between legal MM K ranges and FIFO prefill capacity. `FIFO_DEPTH` is the MXU's chunk FIFO depth; `ACT_BLOCKS` is the activation RAM's K-block capacity. They are distinct resources and do not require a universal one-to-one capacity relationship.

No code or target configuration was changed to add this invariant. The 20:35 addendum's claim that it was sufficient as a target-wide safety invariant is superseded by this correction.

### Evidence from current sources
- `rtl/top/otpu_slice.sv`: `FIFO_DEPTH` is passed to `otpu_mxu.DEPTH`; `ACT_BLOCKS` and `ACT_ROWS` are separate geometry parameters.
- `rtl/mxu/otpu_mxu.sv`: the FIFO checks are command-dependent:
  - Replayed row: if `M > MCOLS`, the chunk count is `KB` for int8 and `ceil(KB/2)` for 4-bit; it must not exceed DEPTH.
  - Replayed group: when `WG > 1`, the command is grouped, and `M > 1`, `KB <= DEPTH`.
  - The source's explanatory comments say a replayed row/group must fit the FIFO; ordinary non-replayed rows do not get a blanket `ACT_BLOCKS <= DEPTH` restriction.
- `docs/isa.md` MM contract separately bounds `M` by ACT_ROWS, `ab + KB` by ACT_BLOCKS (SPL uses KB-1 activation blocks), and imposes a chunk-FIFO bound only for replayed rows.
- `opentpu/isasim.py::_mm` checks ISA shape, capability, address alignment/ranges and ACT RAM bounds, but does not currently model the target-specific FIFO depth. This is a simulator/RTL contract gap to resolve deliberately, not a reason to invent a target-wide restriction.
- The RTL's current FIFO-bound checks are under `ifndef SYNTHESIS` in `otpu_mxu.sv`; therefore they are simulation assertions, not synthesizable rejection. A sequencer pre-dispatch guard is still needed if malformed raw MM words must be rejected before the MXU starts streaming.

### Pre-dispatch guard contract to complete
The sequencer receives resolved instruction words in `dcmd` before setting `p_v`; the existing FSUM guard demonstrates the reject-before-dispatch pattern. A correct MM guard must distinguish:
1. ISA/architecture legality: nonzero N and KB; M nonzero; PAIR legality and doubled row count; activation row/block bounds with SPL's KB-1 range; WF/RSC/ASCALE constraints; group-size encoding and GALL policy; KT capability/format/k0/pair-stride conditions; SPL capability and its exact flag/field constraints; grouped address alignment and HLD rules.
2. Target-specific FIFO legality: effective chunk count for the selected format and mode; reject only when the relevant replay mode requires the row/group to remain resident and the effective count exceeds DEPTH. Do not apply this condition to ordinary non-replayed commands.
3. Arithmetic safety: widen all additions, multiplications and shifts before comparison (for example, `ab + KB`, `2*M`, `(2*KB - 1)*P`); avoid truncation from 8-bit fields or parameter casts.
4. Dynamic memory-content conditions: do not pretend decode can prove ACT data/scale consistency or KT's upper-half-zero condition. Identify which are checked by preflight/producer invariants versus MXU runtime assertions, and ensure any error semantics are safe and deterministic.
5. Side effects: invalid commands must be rejected before `p_v`, `ustart`, DRAM prefetch, TMEM writes or ACT writes. Legal ordinary, replay, grouped, KT and SPL cases must retain their existing behavior.

### Validation containment
- Existing target test `test_every_variant_keeps_its_hash` covers resolved target variants for architecture hashes, but is not a FIFO contract test.
- Existing `tests/test_target.py::test_bad_target_files` is the pattern for invalid-target loader tests; no target-wide FIFO invariant should be added.
- No safe exact-SHA workflow-dispatch action is exposed in the connected GitHub tool set. Do not trigger the broad RTL workflow merely to test a sequencer/slice change. Prepare a dedicated manual workflow/test entrypoint and verify its actual path filters/dispatch permissions before any RTL push.
- Do not report tests as run. No source code, target file or workflow was modified in this continuation.

### Verified live state
- Feature branch remains `sunnyone/commercial-profitability-architecture-2026-11-23`; HEAD before this documentation update `09b23124cc8ccfbd9a97c5501677b7e76040e397`.
- Main baseline remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; no main writes.
- Latest relevant successful workload harness run remains `46132183828`, exact tested SHA `3cc1ec1d0aaee797022cc355e68e8451a13c4e6b`, 47 passed. There are no queued or in-progress branch Actions runs.
- No tests launched and no RTL/test/workflow source changed.
- Manufacturer handoff remains **NOT READY**; zero spend, no PPA retry, no duplicate successful RTL regressions.

## Resume next
**Continue and complete the remaining tasks.** Resume with a precise MM legality truth table cross-checked among ISA, simulator, compiler, sequencer and MXU. Then specify the minimal synthesizable pre-dispatch predicate and isolated raw-word tests. Do not add `FIFO_DEPTH >= ACT_BLOCKS`.
