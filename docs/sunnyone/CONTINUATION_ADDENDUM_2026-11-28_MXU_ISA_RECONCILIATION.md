# SUNNYONE continuation addendum — 2026-11-28 MXU ISA reconciliation

## Repository state and controls
- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Live branch HEAD at review start: `1da02135d5498572956619ffefc9368f60198a03`.
- Main / merge base: `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare: 1,170 ahead, 0 behind.
- No main writes, merges or rebases. Zero spend. No PPA retry. Do not rerun historical RTL groups 3.1/3.2/4 or cancelled run `45765362426`.

## Latest evidence re-poll
- Focused VPU workflow `46053471843`: terminal SUCCESS, tested source `40ce5cbd6f615215fbb8b7ee21b04aa541f451b6`; 31 `test_se_vpu.py` tests and 11 selected FSUM RTL tests passed (219 deselected). This is scoped evidence only.
- Software-core workflow `46053311585`, attempt 3: terminal SUCCESS, tested source `05879ea34eafc2559c54722c6c940b2acb9ac3ee`; all 15 module jobs successful; waits job 268 passed, 2 skipped.
- Deterministic resource harness `46081103514`: terminal SUCCESS, tested source `0ab52a61659a4746eb3375d7e5f146f3fbf192ae`; 34 tests passed.
- Full-chip lint `46053311384`: terminal SUCCESS as a completed lint workflow on `05879ea...`, with 59 width warnings (52 expansion, 7 truncation); not warning-free.
- W1/W2/W3 scenario test commit `28704f25f87179e5653188bf0cc40f43ee681168` remains NOT VERIFIED. The connected commit-run endpoint filters to PR-triggered runs and returned no push run. Do not infer success or blindly rerun.
- Preserve exact source-SHA scope above; these runs do not certify current branch HEAD.

## MXU ISA source reconciliation
Primary contract: `docs/isa.md`, blob `89a2886ab775717db26b856f267397bcbd3cb8ba`. Reviewed sequencer blob `c8fbaf00f278edd883059cd9d1e4571780b7dd5e`, slice blob `92d0006245c8fd6878ead9e4f55cf676aee09b35`, and MXU blob `3dfdec588933cdc5823d1780bd8b251aba0098e7`.

Confirmed ISA rules:
- Every MM: `N >= 1`, `KB >= 1`, and `0 < M <= ACT_ROWS`.
- RMAX, ASCALE and PAIR additionally require `M <= MCOLS`.
- PAIR is 4-bit only, requires `2*M <= MCOLS), and is not used with weight groups.
- RMAX and ASCALE with weight groups are legal only under GALL. GALL is the experimental WG>1 mode in which every MM is grouped; natural one-row MM is refused.
- ASCALE requires UNIT and ACC.
- RSC is not legal with WF=3 (NVFP4).
- Weight groups: WG>1 uses grouped MM data; natural one-row MM is not supported. PAIR is not taken.
- PAIR's second ACT row is `j+M`; therefore its M/2M constraints are safety-relevant to ACT RAM and column reuse, not merely throughput tuning.
- The ISA describes WF 0=int8, WF 1=int4, WF 2=FP4/E2M1, WF 3=NVFP4. WF 1/2/3 are packed 4-bit; WF3 has distinct scale layout and RSC prohibition.

RTL wiring:
- `otpu_seq` currently receives WG but not MCOLS or ACT_ROWS.
- `otpu_slice` has exact elaborated MCOLS and ACT_ROWS and passes those same parameters to MXU/ACT RAM; sequencer instantiation currently passes only WG and other controls.
- Thus a hardware guard must receive exact `MCOLS` and `ACT_ROWS` from slice. Do not hard-code 4 or 8.
- Existing `fsum_bad` is a proven source pattern for a synthesizable R-stage reject before `p_v`/dispatch. A corresponding MM predicate can be combined into the existing default-instruction rejection branch.
- MXU legality assertions are under `ifndef SYNTHESIS`; they cannot be relied upon as the hardware protection.
- No RTL or tests changed in this continuation. No guard is claimed implemented or verified.

## Next engineering actions
1. Complete a full mode/encoding audit of `docs/isa.md`, compiler and simulator checks, including WG logarithm/group-count semantics, reserved/unsupported combinations, FIFO limits and all relevant flags. Ensure the guard rejects unsupported shapes without rejecting legal programs.
2. Inspect every `otpu_seq` instantiation and ASIC elaboration to prove parameter propagation and defaults.
3. Implement a minimal synthesizable MM guard in the sequencer, using exact MCOLS/ACT_ROWS and width-safe arithmetic for `2*M`; reject before `p_v`, dispatch count, MXU start, TMEM writes or DRAM requests.
4. Add raw-word RTL negative tests bypassing compiler validation for N/KB/M boundaries, PAIR bounds, WF/RSC, ASCALE prerequisites, WG/GALL legal and illegal shapes, MCOLS=4 and another supported configuration. Prove error/halt before dispatch and no side effects.
5. Run only the new focused tests and matching lint/formal scope. Do not rerun protected successful RTL groups.
6. Resolve W1/W2/W3 CI result only from its exact push run/log.
7. Continue interval-level trace correlation with loss/ambiguity accounting; no per-request TMEM attribution without a stable tag.
8. Continue 59-warning semantic closure, formal/SVA, CDC/RDC, DFT, SRAM/DDR mapping, production interfaces, routed physical and demonstrator sponsorship gates.

## Release decision
Manufacturer handoff remains **NOT READY**. No RTL fix or test result is claimed by this addendum. No physical sample, routed signoff, foundry-ready package, sponsor, package/test/shipping agreement or independent silicon validation is confirmed.
