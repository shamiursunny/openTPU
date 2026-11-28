# SUNNYONE continuation addendum — 2026-11-28 20:17 Asia/Dhaka

## Live repository and Actions state
- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Live branch HEAD before this documentation save: `8c46dee94e90f1072d4571fb3a1260ee6efd61b2`.
- The preceding continuation addendum recorded `8c65b8b33fda16a588227f64d26be7edea4b04c2`; live compare shows exactly three documentation-only commits since then. No RTL, test, workflow or PPA source changed in those three commits.
- Protected-main baseline remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; GitHub reports `protected=false`. This is a control gap, not permission to write main. Main remains untouched and strictly off-limits.
- Re-polled the latest 30 Actions runs: all returned runs are terminal; no queued or in-progress run appeared. Final workload harness run `46132183828` on source `3cc1ec1d0aaee797022cc355e68e8451a13c4e6b` is SUCCESS; actual log previously recorded 47 passed in 52.079s. Earlier automatic attempts include failures/cancellations and must not be counted as passes.
- Preserve all previously validated evidence. Do not rerun successful RTL groups 3.1/3.2/4, board suite, VPU focused suite, STREAM suite or workload harness merely for reassurance. Never restart cancelled run `45765362426`.

## MXU malformed-MM guard: source/ISA cross-audit
Re-fetched exact active-branch sources:
- `rtl/seq/otpu_seq.sv`: blob `c8fbaf00f278edd883059cd9d1e4571780b7dd5e`.
- `rtl/top/otpu_slice.sv`: blob `92d0006245c8fd6878ead9e4f55cf676aee09b35`.
- `docs/isa.md`: blob `89a2886ab775717db26b856f267397bcbd3cb8ba`.
- `opentpu/isasim.py`: blob `94a02cf018719b4d2db8150a903880cbe0ed4bd1`.
- `opentpu/isa.py`: blob `17c81a0518bcee5284b912fcb4f08fb3bfadc158`.
- `opentpu/compiler.py`: blob `916ff011154ea65bf4c26ef8fc44eeaecddd07ea`.

Confirmed: sequencer currently has the synthesizable FSUM reject but no corresponding MM malformed-command reject. It receives WG but not MCOLS or ACT_ROWS. Slice owns the exact MCOLS/ACT_ROWS values and currently passes neither to the sequencer. Existing R-stage default reject is before setting `p_v`, so the established safe insertion point is confirmed.

The ISA simulator's MM validation is broader than a simple M/N/KB guard. It checks:
1. N and KB nonzero.
2. M and PAIR-expanded ACT row count within ACT_ROWS; ACT block range within ACT_BLOCKS.
3. RMAX/ASCALE column limits, with grouped GALL exceptions.
4. PAIR requires 4-bit weights, even k0 and 2*M <= MCOLS.
5. RSC is forbidden with NVFP4; ASCALE requires UNIT and ACC.
6. Group size must exactly match the format-specific machine group (WG rows for int8, 2*WG for 4-bit); grouped PAIR is forbidden; grouped RMAX/ASCALE require GALL; GALL at WG>1 rejects natural one-row MM.
7. Grouped source/stride/HLD alignment and grouped chunk layout constraints.
8. KT capability and shape/stride/tail constraints.
9. SPLMM capability and its separate restrictions (KB 2/3, grouped int8 RSC, k0=0, no UNIT/PAIR/KT/RMAX/ASCALE, valid HLD and srs).
10. Streamed-row chunk FIFO capacity and address/scale-layout constraints.

The current sequencer has no explicit MCOLS, ACT_ROWS, ACT_BLOCKS, KT, SPLMM or MXU stream-FIFO capacity contract. Do not add an incomplete predicate that silently accepts unsafe commands or rejects valid grouped/experimental modes. Exact capability propagation and complete supported-mode audit are prerequisites. The MM raw-word tests must bypass `I.mm()` compiler checks and prove error before dispatch (`instructions == [0]`) plus unchanged TMEM/DRAM for invalid shapes; legal boundary cases must still execute.

## Work performed in this continuation
- Reconciled live branch ref and recent Actions state.
- Compared ISA text, ISA instruction encoder, simulator validation, compiler mode decisions, sequencer decode and slice parameter wiring.
- Confirmed the precise pre-dispatch insertion point and the missing parameter contract.
- No RTL/test/workflow source was changed and no test was dispatched. This was a deliberate safety stop: a partial guard would be less safe than leaving the defect explicitly open.
- The full workflow path-filter audit still must be completed before any RTL write, because a sequencer/slice change may trigger broad duplicate RTL/board/Qwen suites. CI must be narrowed to a dedicated MM-guard job without rerunning previously passed protected groups.

## Next actions (ordered)
1. Inspect every `.github/workflows/*.yml` push/pull_request path filter that can match sequencer, slice, test or workflow changes; design a serial, narrow MM-guard CI route first.
2. Inventory every `otpu_seq` instantiation and all elaboration variants; propagate exact MCOLS, ACT_ROWS, ACT_BLOCKS and only genuinely supported capability/FIFO parameters.
3. Reconcile RTL support against simulator checks for KT, SPLMM, GALL, PAIR and row FIFO capacity. Decide explicitly which unsupported features are rejected in hardware and which are valid.
4. Implement complete width-safe `mm_bad` at R stage, before `p_v`/dispatch. Do not narrow `mx_key` before this is verified.
5. Add raw-word negative tests and legal boundary tests at MCOLS=4 and another supported configuration; verify zero dispatch and no TMEM/DRAM side effects.
6. Run only the dedicated MM-guard test/lint/formal scope. Do not rerun prior successful groups.
7. Continue 59-warning semantic closure, formal/SVA, CDC/RDC, DFT, SRAM/DDR mapping, production PCIe/SerDes and DMA/IOMMU, routed physical/power/thermal signoff, Track B down-select and full-sponsorship/sample logistics.

## Fixed controls and release decision
- Zero spend; no paid compute, PPA retry, PDK/IP licence, fabrication, packaging, lab test, board, hardware or shipping expenditure without explicit approval.
- No main writes, merges or rebases.
- Preserve historical test evidence; no duplicate passed tests.
- Track A full programmable product and Track B demonstrator remain separate.
- Simulation/proxy results are not silicon measurements or qualification.
- Manufacturer handoff remains **NOT READY**.

## Resume command
In any new chat: **Continue and complete the remaining tasks.** Read this addendum after the current checkpoint, then the integrated plan, tracker and manufacturer readiness matrix. Re-resolve live branch HEAD and Actions before engineering writes.
