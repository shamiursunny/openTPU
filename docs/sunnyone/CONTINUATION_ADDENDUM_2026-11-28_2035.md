# SUNNYONE continuation addendum — 2026-11-28 20:35 Asia/Dhaka

## Live repository and Actions reconciliation
- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Live feature HEAD before this documentation save: `490aa9d65d9d0e3212dca43f161dfaf5a0fe2e5a`.
- Protected-main baseline: `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare reports **1,205 ahead / 0 behind**. Main remains untouched and off-limits. GitHub previously reported branch protection disabled; treat this as a control gap, not permission to write main.
- Actions poll on the active branch: no queued, waiting, requested or in-progress runs. The latest successful relevant run remains workload harness `46132183828`, exact tested source `3cc1ec1d0aaee797022cc355e68e8451a13c4e6b`, **47 passed in 52.079s**. Later workload-harness attempts include failures/cancellations; do not count them as passes.
- No tests, RTL, ISA, workflow or PPA job were changed or launched in this continuation.

## Source review completed
- Re-read the authoritative commercial north-star hierarchy, current continuation checkpoint, integrated plan, tracker, manufacturer matrix, MM guard design note, workflow/MM audit and latest 20:17 addendum.
- Re-read `rtl/seq/otpu_seq.sv` (blob `c8fbaf00f278edd883059cd9d1e4571780b7dd5e`), `rtl/top/otpu_slice.sv` (blob `92d0006245c8fd6878ead9e4f55cf676aee09b35`), `rtl/mxu/otpu_mxu.sv` (blob `3dfdec588933cdc5823d1780bd8b251aba0098e7`), `rtl/top/otpu_pkg.sv`, `docs/isa.md` (blob `89a2886ab775717db26b856f267397bcbd3cb8ba`), `opentpu/isasim.py` (blob `94a02cf018719b4d2db8150a903880cbe0ed4bd1`), `opentpu/isa.py` (blob `17c81a0518bcee5284b912fcb4f08fb3bfadc158`), `opentpu/target.py` (blob `4f8b2b02c91bf7ba68cdb37804e55fff4210700c`), and `tests/test_target.py` (blob `6c162e3d839d594049585a03520d351489ac85e4`).

### MM guard remains OPEN
- The sequencer still has the synthesizable FSUM pre-dispatch rejection pattern but no equivalent malformed-MM guard. Its parameter list contains WG but not MCOLS/ACT_ROWS; the slice has those exact geometry values and passes them to MXU, but the current `otpu_seq` instantiation does not pass them.
- The existing R-stage invalid-instruction branch rejects before `p_v` is set, confirming the established insertion point for a future MM guard.
- ISA rules and physical target constraints must remain separate. The simulator validates ISA command shape/mode constraints; it does not model the physical chunk FIFO depth.
- The target loader resolves `ACT_ROWS=0` to MCOLS through `Target.act_rows`. However, current `opentpu/target.py` has no explicit validation that resolved `FIFO_DEPTH >= ACT_BLOCKS`, and `tests/test_target.py` has no negative test for that invariant.
- The current eight base target configurations satisfy `ACT_BLOCKS <= FIFO_DEPTH` (smallest 32<=64; others 128<=1024/2048). The all-variant audit identifies KT/SPLMM/MCOLS overrides; the FIFO invariant must be checked on the fully resolved target+variant, not inferred from base sections alone.
- For legal MMs, `ab + KB <= ACT_BLOCKS` (SPL reads KB-1 ACT blocks), so `KB <= ACT_BLOCKS`. The MXU's whole-row FIFO requirement is KB chunks for int8/grouped, or ceil(KB/2) for natural 4-bit. Therefore `FIFO_DEPTH >= ACT_BLOCKS` is a sufficient target-level invariant for the documented current-target prefill requirement. It is target/uarch safety, not a universal ISA rule.
- The target invariant should be validated in target loading and covered by a focused target test before relying on it to omit a sequencer-side FIFO predicate. Do not add a duplicate FIFO cap to MM decode without a demonstrated need.
- No source change was made: the target invariant's interaction with all resolved variants and validation/test CI containment must be completed before editing.

## Ordered next actions
1. Finish an exhaustive hierarchy inventory of every `otpu_seq` instantiation and all `otpu_slice` elaboration/variant configurations; the known slice-to-sequencer instance is confirmed, but this continuation did not complete a repository-wide source scan.
2. Add and test resolved target validation `FIFO_DEPTH >= ACT_BLOCKS`, including all base targets and variants, with a deliberately invalid temporary target proving rejection.
3. Complete the MM contract from the full ISA, compiler, simulator and RTL: static shape/mode legality, exact parameter/capability propagation (MCOLS, effective ACT_ROWS, ACT_BLOCKS, KT, SPLMM, WG/GALL), widened arithmetic, and any dynamic memory-content conditions that cannot be checked at decode.
4. Add the isolated workflow and raw-word tests before an RTL push. The existing path-filter audit shows sequencer/slice edits trigger broad suites; use the documented skip-CI + dedicated manual dispatch only if the connected tools expose a safe exact-SHA dispatch. If not, stop rather than triggering broad duplicate suites.
5. Implement the complete pre-dispatch guard only after the above; prove zero dispatch and no TMEM/DRAM side effects for invalid raw commands and preserve legal grouped, KT and SPLMM modes.
6. Continue width-warning semantics, formal/SVA, CDC/RDC, DFT, SRAM/DDR mapping, production PCIe/SerDes and DMA/IOMMU, routed physical/power/thermal signoff, Track B demonstrator and full sponsorship/sample logistics.

## Fixed controls
- Zero spend; no PPA retry, paid compute, PDK/IP, fabrication, packaging, lab test, hardware, board or shipping expenditure without explicit approval.
- No main writes, merges or rebases.
- Do not rerun successful historical RTL groups 3.1, 3.2 or 4, board, VPU, STREAM or workload suites merely for reassurance. Never restart cancelled run `45765362426`.
- Preserve exact run/SHA/selection/skips/deselections. Simulation is not silicon measurement.
- Keep Track A full AI-X product separate from Track B demonstrator.
- Manufacturer handoff remains **NOT READY**.

## Resume command
**Continue and complete the remaining tasks.** Re-read the current checkpoint, this addendum, integrated plan, tracker and manufacturer matrix; re-resolve live branch and Actions state before any write.
