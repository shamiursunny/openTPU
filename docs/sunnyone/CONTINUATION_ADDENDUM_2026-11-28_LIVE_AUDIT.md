# SUNNYONE X — live continuation audit and safe execution boundary

Date: 2026-11-28 (Asia/Dhaka)
Repository: `shamiursunny/openTPU`
Working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Protected baseline: `d84db55712aba0d40811d7762cb052f05d55b7e5`
Status: documentation-only audit; no RTL, test, workflow or PPA source changed.

## Live repository reconciliation

- GitHub compare reports the feature branch is 1,238 commits ahead and 0 behind the protected baseline.
- Main remains off-limits and unchanged.
- The governing execution plan remains `docs/sunnyone/SUNNYONE_X_FINAL_EXECUTION_MASTER_PLAN_2026-11-28.md`.
- The simulation-first handoff policy remains `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_2200_SIMULATION_FIRST_HANDOFF.md`.
- The most recent detailed MM source contract remains `docs/sunnyone/CONTINUATION_ADDENDUM_2026-11-28_2138.md`, with address/parameter mapping in `CONTINUATION_ADDENDUM_2026-11-28_2145.md`.

## New source observations

Inspected live source blobs:
- `rtl/seq/otpu_seq.sv`: blob `c8fbaf00f278edd883059cd9d1e4571780b7dd5e`
- `rtl/top/otpu_slice.sv`: blob `92d0006245c8fd6878ead9e4f55cf676aee09b35`
- `.github/workflows/sunnyone-rtl-subsystems.yml`: blob `c7d0d30df40c4da323153f12e0bc849572e9cd45`
- `.github/workflows/sunnyone-fsum-guard.yml`: blob `3b56b95c24210c3dbaaabce05fe4ada0f0942f75`
- `targets/bcu1525-wg.toml`: blob `fa4e7dc10cf01719842e523cf0a694e733119314`
- `opentpu/target.py`: blob `4f8b2b02c91bf7ba68cdb37804e55fff4210700c`
- `docs/isa.md`: blob `9f16646c8846d0379a47ffd3d7f5fa6d433f8bcd`

### Sequencer integration and reject point

- The inspected `otpu_slice` has a single `otpu_seq` instance, `u_seq`.
- It currently passes `WG`, but not `MCOLS`, `ACT_ROWS`, `ACT_BLOCKS`, `FIFO_DEPTH`, `KT` or `MXU_SPL`/SPL capability to the sequencer.
- The same slice passes matching geometry and feature parameters to `otpu_mxu`.
- `otpu_seq` already has the synthesizable `fsum_bad` predicate and the R-stage default-branch reject-before-dispatch pattern. MM guard should follow this control-flow pattern, but must use exact target parameters and widened arithmetic.
- This inspection establishes the known slice instance, not a repository-wide proof that no other top-level or testbench instantiations exist. A full instantiation census is still required before changing the module parameter list.

### CI containment finding

- `sunnyone-rtl-subsystems.yml` is a 14-group matrix, `max-parallel: 2`, with push paths including all `rtl/**` and several software/simulation files. Its `workflow_dispatch` runs the broad matrix; it is not an isolated MM test route.
- A separate narrow `sunnyone-fsum-guard.yml` exists and runs selected FSUM cases, but its push path includes `rtl/seq/otpu_seq.sv` and `rtl/top/otpu_slice.sv`. An MM guard edit to those same files would also trigger the broad RTL workflow.
- The GitHub connector exposes workflow/run inspection and rerun actions, but no safe exact-SHA workflow-dispatch action. Do not treat the existence of GitHub's YAML `workflow_dispatch` trigger as proof that this connected environment can invoke it.
- The repository contains multiple specialised RTL workflows; a complete trigger fan-out inventory is still required before any source push.

## MM guard contract retained

The guard remains OPEN and must reject malformed raw instruction words before the command enters the dispatch window. It must not reject valid supported commands.

The predicate and tests must separately cover:
1. Universal shape: nonzero N, KB, M; effective rows R = (PAIR ? 2*M : M) within ACT_ROWS.
2. ACT block range: ab + (SPL ? KB-1 : KB) within ACT_BLOCKS, with widened addition.
3. RMAX/ASCALE: M <= MCOLS in both WG=1 and grouped cases.
4. PAIR: legal packed 4-bit format, even k0, no grouped mode, and 2*M <= MCOLS.
5. RSC/NVFP4 exclusion and ASCALE UNIT+ACC prerequisites.
6. Exact WG/GALL/weight-format group-size rules.
7. SPL target capability and all documented SPL mode/format/KB/k0/HLD exclusions; SPL uses KB-1 ACT blocks.
8. KT target capability, grouped mode, format/k0 and widened pair-stride bound. KT's ACT-tail upper-half-zero is a dynamic memory-content condition, not a static instruction-field check.
9. Target-specific FIFO residency: natural WG=1 replay uses KB chunks for int8 or ceil(KB/2) for packed 4-bit; grouped WG>1/GALL replay with M>1 requires KB <= FIFO_DEPTH. Do NOT add the withdrawn universal `FIFO_DEPTH >= ACT_BLOCKS` invariant.
10. Legal positive controls for each supported configuration and proof that invalid commands halt before dispatch, MXU start, DRAM request/prefetch, TMEM write or ACT write.

## Execution decision

No RTL patch was made because:
- The dedicated raw-word MM test suite has not yet been authored.
- The existing broad RTL push filter would launch a large matrix and may repeat successful historical groups.
- No safe isolated exact-SHA dispatch is available through the connected GitHub action surface.
- A workflow-dispatch YAML entry alone does not provide a callable route from this session.

Next safe steps:
1. Finish full `otpu_seq` instantiation census and resolved target/variant parameter inventory.
2. Complete the normative MM truth table and address-range ownership, including exact equality/one-past-boundary cases.
3. Author raw-word positive/negative tests before changing RTL.
4. Design a CI containment strategy that does not trigger duplicate successful suites or silently disable required protection; inspect all relevant workflow path filters before proposing it.
5. Only after the test route is proven, implement the minimal parameterised widened-arithmetic R-stage guard and validate exact commit.
6. Reuse unaffected historical evidence; do not rerun successful RTL groups 3.1/3.2/4 solely for reassurance.

## Hard constraints

- Do not modify protected `main`.
- Do not restart cancelled workflow `45765362426`.
- Do not repeat passed RTL groups 3.1, 3.2 or 4 solely for confirmation.
- No paid PPA retry, fabrication, board purchase, licence or cloud spend.
- Preserve the zero-spend default; high-cost prototype hardware is only a candidate after engineering readiness and explicit approval.
- Manufacturer handoff remains **NOT READY**.
- The goal remains a simulation-qualified design dossier for manufacturer physical implementation; silicon, routed signoff, measured power/thermal, yield and production qualification must not be claimed before the manufacturer proves them.
