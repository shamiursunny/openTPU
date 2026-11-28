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


## Cross-source MM legality matrix — reviewed 21:20 Asia/Dhaka

### Common static fields
| Check | Contract / predicate | Current source coverage |
|---|---|---|
| N, KB, M | N >= 1, KB >= 1, M >= 1 | ISA simulator checks N/KB and 0 < M; RTL decode needs explicit guard |
| ACT rows | R = PAIR ? 2*M : M; R <= ACT_ROWS | ISA simulator; MXU simulation assertion checks M <= ROWS (PAIR separately limits 2*M <= MCOLS) |
| ACT blocks | ab + (SPL ? KB-1 : KB) <= ACT_BLOCKS | ISA simulator; sequencer lacks exact geometry params |
| PAIR | 4-bit only, even k0, 2*M <= MCOLS, no groups | ISA simulator and MXU simulation assertions |
| RSC | not NVFP4 | ISA simulator; no synthesizable sequencer guard |
| ASCALE | requires UNIT and ACC | ISA simulator; sequencer lacks this MM guard |
| Groups | exact rd exponent for WG (int8) or 2*WG (4-bit); WG>1 requires groups; no PAIR | ISA simulator and MXU simulation assertions; sequencer has WG but no MM legality guard |
| Group RMAX/ASCALE | supported only on GALL/WG>1 and M <= MCOLS | ISA simulator documents GALL rule; MXU simulation check gates M<=MCOLS under GA |
| Replay FIFO | non-group row when M>MCOLS: int8 KB, 4-bit ceil(KB/2) <= DEPTH | MXU simulation assertion only; absent from ISA simulator's Config |
| Group replay FIFO | WG>1, grouped command, M>1: KB <= DEPTH | MXU simulation assertion only |
| KT | grouped, capability KT, k0=0, not NVFP4; pair stride condition after clearing rs bit0 | ISA simulator and MXU simulation assertions |
| SPL | SPLMM capability; KB 2/3, grouped int8 RSC, k0=0, HLD>0 and P-aligned; not UNIT/PAIR/KT/RMAX/ASCALE; ACT bound uses KB-1 | ISA simulator and MXU simulation assertions; sequencer lacks SPLMM capability input |
| Group addresses | sa, rs and HLD multiples of P=WG*D | ISA simulator; sequencer guard must use resolved dcmd addresses and widened arithmetic |
| Dynamic KT data | last ACT block's upper half must be zero | ISA simulator checks memory contents; cannot be established by raw instruction decode alone |

### Material mismatches / unresolved semantics
1. The sequencer currently receives WG but not MCOLS, ACT_ROWS, ACT_BLOCKS, FIFO_DEPTH, KT or SPLMM. The slice already has these values: MCOLS, ACT_ROWS, ACT_BLOCKS, FIFO_DEPTH, WG, KT and MXU_SPL. A future guard must pass the resolved capability/geometry parameters to the sequencer; GALL is derived from WG>1 in the MXU.
2. The MXU's command-shape and FIFO assertions are under ifndef SYNTHESIS. They are useful simulation oracles, not production rejection.
3. The simulator checks ACT data/scale contents, address ranges and target feature availability; the sequencer can reject only static fields and address arithmetic available at dispatch. A design decision is required for dynamic-data failures: producer guarantees, hardware preflight, or explicit runtime error handling. Do not claim decode proves memory contents.
4. The documented MM contract says RMAX/ASCALE need M<=MCOLS. The current MXU simulation assertion explicitly checks that bound inside GA (WG>1). Reconcile whether the non-GA path is guaranteed by another path or has a missing assertion before coding; preserve simulator/ISA behavior.
5. The simulator does not currently know FIFO_DEPTH (it's a target uarch parameter rather than Config's architectural field). Decide whether to extend target-aware simulation validation or keep FIFO depth explicitly target/RTL-only, and document that split. Do not silently treat a simulator pass as proof of FIFO capacity.
6. Arithmetic for ab + KB, 2*M, ceil(KB/2), (2*KB - 1)*P and group strides must be widened before comparison. Raw fields are narrow and unsized expression promotion can otherwise truncate or overflow.

### Implementation sequence (still not executed)
A. Resolve items 4–5 and write a normative truth table with legal/illegal raw command examples.
B. Add sequencer parameters from slice and implement mm_bad in the R stage alongside fsum_bad, rejecting before p_v is asserted.
C. Add directed raw-word tests for each predicate, each boundary, and each legal mode (ordinary, replayed row, grouped, GALL, KT, SPL). Verify error, no ustart, no DRAM request and no TMEM/ACT writes.
D. Verify the test-only MXU assertions remain aligned with the new synthesized guard; add no duplicate or stronger restrictions.
E. Do not push the RTL change until a narrow, exact-SHA workflow can run the dedicated suite without re-running protected historical suites. The connected GitHub tools currently expose no workflow-dispatch action, so the implementation is paused rather than launched into broad CI.

No tests were run and no source files were changed by this matrix review.
