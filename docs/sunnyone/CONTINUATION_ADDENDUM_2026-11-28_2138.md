# SUNNYONE continuation addendum — 2026-11-28 21:38 Asia/Dhaka

## Live repository reconciliation
- Repository: `shamiursunny/openTPU`; active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Live feature HEAD at review start: `ac78a95bb59911b6d8ffa3e27ee930d6b9e5f329`.
- Main baseline: `d84db55712aba0d40811d7762cb052f05d55b7e5`; compare 1,214 ahead / 0 behind. No main writes, merge or rebase.
- GitHub reports main branch protection disabled. The no-main-write rule remains absolute.
- Actions API poll returned zero queued and zero in-progress runs repository-wide.
- No RTL, test, workflow or PPA source changed; no test launched; zero spend.
- Latest feature commit before this documentation update is `ac78a95bb59911b6d8ffa3e27ee930d6b9e5f329`, a documentation-only MM legality review.

## Exact source blobs re-fetched
- `docs/isa.md`: `89a2886ab775717db26b856f267397bcbd3cb8ba`.
- `rtl/seq/otpu_seq.sv`: `c8fbaf00f278edd883059cd9d1e4571780b7dd5e`.
- `rtl/top/otpu_slice.sv`: `92d0006245c8fd6878ead9e4f55cf676aee09b35`.
- `rtl/mxu/otpu_mxu.sv`: `3dfdec588933cdc5823d1780bd8b251aba0098e7`.
- `opentpu/isasim.py`: `94a02cf018719b4d2db8150a903880cbe0ed4bd1`.
- `opentpu/isa.py`: `17c81a0518bcee5284b912fcb4f08fb3bfadc158`.
- `opentpu/target.py`: `4f8b2b02c91bf7ba68cdb37804e55fff4210700c`.
- `tests/test_target.py`: `6c162e3d839d594049585a03520d351489ac85e4`.
- `.github/workflows/sunnyone-rtl-subsystems.yml`: `c7d0d30df40c4da323153f12e0bc849572e9cd45`.

## MM legality audit

The executable ISA simulator `opentpu/isasim.py::_mm` checks:
1. N and KB are nonzero.
2. `R = PAIR ? 2*M : M` satisfies `0 < R <= ACT_ROWS`.
3. ACT range: `ab + (SPL ? KB-1 : KB) <= ACT_BLOCKS`.
4. RMAX/ASCALE require `M <= MCOLS` for both WG=1 and WG>1.
5. PAIR requires 4-bit WF, even k0, no grouped mode, and `2*M <= MCOLS`.
6. RSC cannot use NVFP4; ASCALE requires UNIT and ACC.
7. Group LG must match the format's group size: WG rows for int8, 2*WG for packed 4-bit. WG>1 uses GALL and refuses natural one-row MM. Grouped PAIR is illegal; grouped RMAX/ASCALE are permitted under GALL, still with `M <= MCOLS`.
8. SPL requires target SPLMM support and grouped int8 RSC, KB 2 or 3, k0=0, HLD>0, and excludes UNIT/PAIR/KT/RMAX/ASCALE. SPL uses KB-1 ACT blocks. The target integration also requires the documented SEQ_WC/wait-entry support.
9. KT is grouped-only, requires KT capability, k0=0, WF other than NVFP4, and widened pair-stride bound `rs-1 >= (2*KB-1)*P`.
10. Grouped sa/rs/HLD alignment uses `P=WG*D`; natural mode uses D-byte alignment. The simulator also checks DRAM range.
11. KT's last ACT block upper-half-zero rule is dynamic memory-content validation; raw instruction decode cannot prove it.

The synthesizable pre-dispatch guard must use widened arithmetic and exact resolved target parameters. `otpu_seq` currently receives WG but not MCOLS, ACT_ROWS, ACT_BLOCKS, FIFO_DEPTH, KT or SPLMM. `otpu_slice` owns the elaborated geometry/capabilities and passes matching MCOLS/ACT_ROWS to the MXU. Do not hard-code geometry.

## MXU assertion omissions versus the simulator

The reviewed `ifndef SYNTHESIS` MXU start assertions are diagnostics, not silicon protection. The source comparison identifies these missing checks:
- RMAX/ASCALE `M <= MCOLS` is gated by GA (WG>1), whereas the simulator requires it for WG=1 too.
- PAIR+int8 is not rejected: the PAIR bounds assertion is conditional on WF!=int8, and the datapath ignores PAIR for int8. The simulator rejects the combination.
- PAIR even-k0 is not checked in the reviewed MXU start assertions.
- RSC+NVFP4 is rejected by the simulator but not by the reviewed MXU start assertions.
- ASCALE UNIT+ACC prerequisites are rejected by the simulator but not by the reviewed MXU start assertions.
- SPL requested while SPL is disabled bypasses the reviewed SPL assertion because SPE is false; the simulator rejects SPL without Config.SPLMM.
- The reviewed block does check M<=ROWS, replay FIFO bounds, grouped LG/capability, grouped PAIR, GALL column bounds, SPL when SPE is enabled, and KT when its grouped stride marker is present. These checks do not form the complete ISA contract.

These are source-review findings, not proof that compiler-generated legal programs fail. The appropriate correction is a synthesizable R-stage guard before dispatch, not a blanket cast or assertion suppression.

## FIFO residency correction

- Natural WG=1: when M>MCOLS, a streamed row is replayed. It must fit DEPTH: KB chunks for int8, ceil(KB/2) for packed 4-bit.
- Grouped WG>1/GALL: a group's KB chunks are reused across M activation rows. When M>1, KB must fit DEPTH. This follows the grouped schedule and the MXU assertion's M>1 condition.
- The ISA simulator Config does not model FIFO_DEPTH; simulator success does not prove this target-specific admission condition.
- The former universal `FIFO_DEPTH >= ACT_BLOCKS` proposal remains withdrawn and must not be implemented.

Documentation was corrected in `docs/isa.md` and `docs/weight_groups.md` to state the distinct natural/grouped replay rules and identify FIFO admission as target/uarch-specific.

## CI containment and release boundary
- `.github/workflows/sunnyone-rtl-subsystems.yml` has a broad `rtl/**` push filter. Sequencer/slice edits can trigger multiple existing RTL/ASIC/board/Qwen suites.
- The connected GitHub interface exposes no safe workflow-dispatch action. Do not push RTL until a dedicated exact-SHA raw-word route can execute without rerunning protected successful suites.
- Do not rerun historical RTL groups 3.1, 3.2 or 4 solely for reassurance; never restart cancelled run `45765362426`; do not retry WG8 PPA; no paid compute/fabrication/test.
- Next: finish the normative truth table and address-range ownership; inventory all sequencer instantiations and target feature propagation; establish isolated test dispatch; only then implement the minimal parameterised synthesizable R-stage guard. Tests must prove invalid raw words halt before dispatch, MXU start, DRAM requests or TMEM/ACT writes, while legal natural/replay/grouped/GALL/KT/SPL cases remain valid.
- Manufacturer handoff remains **NOT READY**. Physical silicon, routed signoff, production PCIe/DDR PHY, full formal/CDC/RDC/DFT closure and zero-cost sponsor/sample/package/test/shipping are not established.

## Resume
Continue with the raw-word MM legality truth table and address-range boundary ownership, then establish a safe isolated test route before any RTL patch. Preserve Track A full product, Track B demonstrator separation and the fixed commercial north star.
