# SUNNYONE continuation addendum — workflow and MM guard audit (2026-11-28)

## Live state
- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Branch HEAD at audit start: `104aedc9d9d32b9a193ded4721467e5e44e20b0c`.
- Protected-main baseline: `d84db55712aba0d40811d7762cb052f05d55b7e5`; latest GitHub branch listing still reports `protected=false` for both main and the feature branch. Main remains untouched. Treat missing branch protection as a repository-control defect; do not write to main.
- Latest Actions poll: no queued, waiting, requested or in-progress runs. Most recent workload harness run `46132183828` is SUCCESS on SHA `3cc1ec1d0aaee797022cc355e68e8451a13c4e6b`; it recorded 47 passed in 52.079s. Nearby failed/cancelled attempts are not passing evidence.
- No RTL or test source was changed and no new workflow was dispatched in this continuation.

## Workflow trigger audit — all 25 current workflow files inspected
A change to either `rtl/seq/otpu_seq.sv` or `rtl/top/otpu_slice.sv` is not a narrow CI event. The exact path-filter implications found:

### Sequencer path `rtl/seq/otpu_seq.sv`
The push path matches:
- `sunnyone-asic-config.yml` — broad `rtl/**` path.
- `sunnyone-fsum-guard.yml` — exact sequencer path.
- `sunnyone-fullchip-lint.yml` — broad `rtl/**`.
- `sunnyone-loop-stack-guard.yml` — exact sequencer path.
- `sunnyone-qwen-real-rtl.yml` — broad `rtl/**` (despite its manual-gate description, it also has a push trigger).
- `sunnyone-reset-audit.yml` — broad `rtl/**`.
- `sunnyone-rtl-functional.yml` — broad `rtl/**`; the historical RTL group matrix is retired/disabled in this workflow, but board-functional job logic still needs separate review.
- `sunnyone-rtl-subsystems.yml` — broad `rtl/**`, with a multi-group matrix.
- `sunnyone-rtl-tail.yml` — broad `rtl/**`.
- `sunnyone-software-core.yml` — broad `rtl/**`.

### Slice path `rtl/top/otpu_slice.sv`
It matches the sequencer-path workflows above, plus:
- `sunnyone-board-functional-only.yml` — broad `rtl/**`.
- `sunnyone-tmem-experimental.yml` — exact slice path.
- `sunnyone-fsum-guard.yml` — exact slice path (already listed).
Other workflow filters inspected do not match these two RTL files, including the isolated PCIe bridge, virtual memory, ASIC control wrapper, HMUX, address map, ASIC PPA, VPU index-width, QHL reset-only, WAITC remainder/retry and workload harness workflows.

### CI containment plan
- Do not make a normal push-triggering RTL commit and allow all broad workflows to start. It would waste compute and risk repeating historical successful suites.
- Add a dedicated `sunnyone-mm-guard.yml` with an explicit `workflow_dispatch` gate and a narrowly scoped test selector.
- For the focused RTL commit, use GitHub's supported skip-CI commit-message convention (e.g. `[skip ci]`) so broad push-triggered workflows do not start; then manually dispatch only the dedicated MM-guard workflow against the exact commit SHA.
- Verify the workflow-dispatch tool and exact workflow inputs before use. If dispatch is unavailable, stop and report; do not substitute a broad push run.
- Keep the broad lint, reset, subsystem, board, Qwen and ASIC qualification as later, individually scheduled stages, with the previously passed RTL groups 3.1, 3.2 and 4 excluded unless a demonstrated dependency makes one necessary and the user explicitly approves it.
- A skip-CI commit is a containment measure, not evidence of qualification. It must be followed by the dedicated guard run and documented results.

## Exact MM parameter wiring confirmed
- `otpu_slice` already owns the authoritative parameters `MCOLS`, `ACT_BLOCKS`, `ACT_ROWS`, `FIFO_DEPTH`, `WG`, `KT` and `MXU_SPL`.
- The MXU instantiation passes `MCOLS`, `ROWS(ACT_ROWS)`, `DEPTH(FIFO_DEPTH)`, `WG`, `KT` and `SPL(MXU_SPL != 0)`.
- The sequencer instantiation currently passes only `WG` for MXU geometry; it does not receive `MCOLS`, `ACT_ROWS`, `ACT_BLOCKS`, `FIFO_DEPTH`, `KT` or `MXU_SPL`.
- Therefore the correct propagation path is slice -> sequencer using those existing exact slice values; do not add duplicate independent configuration knobs or hard-code defaults. `GALL` is implied by the active WG>1 grouped-MXU contract in the current RTL documentation; verify this against every supported elaboration configuration before encoding it as a predicate.

## ISA / simulator MM checks to implement and cross-check
The simulator's `Machine._mm` validates:
1. N and KB are nonzero.
2. M and PAIR-expanded ACT row count fit `ACT_ROWS`; ACT block range fits `ACT_BLOCKS` (SPL reads KB-1 ACT blocks).
3. RMAX/ASCALE require M <= MCOLS; PAIR-expanded rows also fit MCOLS.
4. PAIR requires a 4-bit format and even k0.
5. RSC is forbidden with NVFP4; ASCALE requires UNIT and ACC.
6. Group size is exact by format (int8: WG; 4-bit: 2*WG); grouped PAIR is forbidden; GALL/WG>1 forbids a natural one-row MM.
7. Grouped source, stride and HLD alignment use P = L*D, where L depends on format/group size.
8. KT requires the configured KT capability, k0=0, non-NVFP4, adequate pair stride, and a valid final ACT tail (the data-content condition is checked by the simulator; do not pretend a static sequencer guard can verify memory contents).
9. SPL requires SPLMM capability, KB 2 or 3, grouped int8 RSC, k0=0, HLD>0, and excludes UNIT, PAIR, KT, RMAX and ASCALE.
10. Streamed source rows are D-byte aligned and the full address extent fits the configured DRAM address space. Use widened arithmetic so end-address calculations cannot wrap.
11. The MXU chunk FIFO is `otpu_mxu DEPTH = FIFO_DEPTH`; inspect the RTL's actual issuer/consumer backpressure and simulator model before deciding whether KB>DEPTH is illegal or merely throttled. Do not infer a hard ISA rejection solely from the comment that a row should fit.

## Guard architecture and test plan
- Add sequencer parameters sourced directly from slice: `MCOLS`, `ACT_ROWS`, `ACT_BLOCKS`, `MXU_DEPTH` (from `FIFO_DEPTH`), `KT`, and `SPLMM` (from `MXU_SPL != 0`). Keep names unambiguous and widths explicit.
- Add an MM raw-word reject predicate evaluated in R stage before `p_v` is asserted and before instruction count advances. Preserve the existing FSUM reject pattern.
- Use widened unsigned intermediates for 2*M, ab+KB, group byte size, grouped end-address and KT pair-stride calculations. Avoid silent truncation and avoid unsized shift arithmetic.
- Respect actual feature configuration. Distinguish static shape checks from runtime data-content checks (notably KT's ACT upper-half zero condition).
- Add isolated `tests/test_mm_guard.py` with raw encoded MM words that bypass the Python encoder's semantic validation. Verify malformed words halt with error before any unit dispatch (`instructions == [0]` where the test harness exposes that counter) and that TMEM/DRAM state remains unchanged.
- Include legal boundary controls: natural MM at MCOLS boundary; grouped int8 and grouped 4-bit exact sizes; legal PAIR boundary; legal KT/SPL only under enabled capability; and legal non-advanced configuration.
- Include negative cases for zero N/KB, ACT row/block overflow, MCOLS violations, bad PAIR format/k0, RSC+NVFP4, invalid ASCALE, group mismatch, grouped PAIR, natural MM under WG>1, alignment errors, unsupported KT/SPL and SPL flag conflicts.
- Build only the narrow MM guard workflow. Use an explicit test selection, pinned toolchain, log artifact, and concurrency group. Never dispatch the full RTL matrix as a substitute.

## Work completed this continuation
- Inspected all 25 workflow files and mapped push path filters for sequencer and slice edits.
- Confirmed exact slice-to-MXU parameter values and the current missing slice-to-sequencer parameter propagation.
- Refined the MM guard contract, separating static malformed-word checks from runtime ACT memory-content checks.
- Re-polled Actions: no active or queued runs.
- No RTL patch, test, broad workflow or paid compute was started. This is an intentional safety stop, not a claim that the MM guard is implemented.

## Next steps
1. Inspect all elaboration instantiations of `otpu_slice` and all supported WG/MCOLS/ACT_ROWS/ACT_BLOCKS/KT/SPLMM configurations from the branch's actual build targets.
2. Inspect MXU FIFO acceptance logic and simulator configuration for exact `KB > FIFO_DEPTH` behavior.
3. Inspect the RTL's existing `op == OP_MM` decode, package field widths and error-state assertions before writing `mm_bad`.
4. Add the dedicated MM-guard workflow and isolated raw-word test module first.
5. Implement parameter propagation and complete width-safe pre-dispatch MM guard.
6. Commit the focused source change with skip-CI, manually dispatch the dedicated guard only, then archive exact-SHA results.
7. Only after the focused guard passes, plan broad qualification in serial order. Preserve all historical passes and avoid groups 3.1, 3.2 and 4.
8. Continue remaining formal/SVA, CDC/RDC, DFT, SRAM/DDR mapping, production PCIe/SerDes and DMA/IOMMU, routed physical/power/thermal signoff, Track B down-select and sponsorship/sample logistics.

## Fixed controls
- Protected main stays untouched. No merges or rebases.
- Zero spend without explicit user approval.
- No duplicate successful regression runs.
- No fabricated PPA, power, thermal, throughput, silicon or qualification claims.
- Track A full programmable product and Track B demonstrator remain separate.
- Simulation/proxy results are not silicon measurements.
- Manufacturer handoff remains **NOT READY**.

## Resume command
In any new chat: **Continue and complete the remaining tasks.** Read the current checkpoint, this workflow/MM audit addendum, the integrated plan, tracker and manufacturer readiness matrix; then re-resolve live GitHub state before writes.


## Follow-up target and FIFO audit (same continuation)
### Current target geometry sampled from all eight target TOMLs
- `bcu1525-s2`: MCOLS 8, WG 8, ACT_BLOCKS 128, ACT_ROWS 16, KT enabled, FIFO_DEPTH 2048.
- `bcu1525-wg`: MCOLS 8, WG 8, ACT_BLOCKS 128, ACT_ROWS 16, KT disabled, FIFO_DEPTH 2048.
- `bcu1525-x2`: MCOLS 8, WG 8, ACT_BLOCKS 128, ACT_ROWS 16, KT enabled, FIFO_DEPTH 2048.
- `bcu1525`: MCOLS 4, ACT_BLOCKS 128, ACT_ROWS 0 (slice semantics: defaults to MCOLS), FIFO_DEPTH 1024.
- `nangate45-small`: MCOLS 2, ACT_BLOCKS 32, ACT_ROWS 0, FIFO_DEPTH 64.
- `nangate45-wg8`: MCOLS 8, WG 8, ACT_BLOCKS 128, ACT_ROWS 16, KT enabled, FIFO_DEPTH 2048.
- `nangate45`: MCOLS 4, ACT_BLOCKS 128, ACT_ROWS 8, FIFO_DEPTH 1024.
- `ypcb-00338`: MCOLS 4, ACT_BLOCKS 128, ACT_ROWS 16, FIFO_DEPTH 1024.
- This matrix confirms the guard cannot assume MCOLS=8, ACT_ROWS=MCOLS, WG=1, or a single FIFO depth. The actual `ACT_ROWS=0` slice convention means ACT_ROWS defaults to MCOLS and must be propagated as an effective row count (e.g. a localparam `ACT_ROWS_E = (ACT_ROWS == 0) ? MCOLS : ACT_ROWS`) or the guard parameter must carry the already-resolved value. Check every elaboration/variant, not just target defaults.
- The sampled TOMLs did not show an enabled SPLMM entry in the reported architecture sections; still propagate the actual `MXU_SPL != 0` value rather than assuming SPLMM is universally off. Confirm all variant overrides before code changes.

### Important FIFO discrepancy resolved
- The MXU RTL documents that replayed rows/groups must fit its chunk FIFO and has explicit runtime checks for: replayed natural rows (M>MCOLS), and grouped rows (WG>1, GRP, M>1). Those checks are inside `ifndef SYNTHESIS`, use `$fatal`, and execute at MXU start; they are simulation assertions, not a synthesizable sequencer reject.
- The simulator `Config` has no `FIFO_DEPTH` field and `Machine._mm` does not model the target's physical chunk-FIFO capacity. Therefore it is incorrect to claim the ISA simulator validates this capacity. Treat the target-specific FIFO capacity as a hardware/uarch admission constraint, and encode the exact existing MXU conditions (not a blanket KB cap) in the synthesizable guard only if those checks are required to prevent deadlock/overflow.
- For natural M>MCOLS rows, the RTL assertion computes the needed chunks as KB for int8 and ceil(KB/2) for 4-bit. For grouped M>1, it requires KB <= DEPTH. The natural M<=MCOLS path does not get that assertion. Confirm the underlying FIFO flow-control invariants before turning these conditions into sequencer rejection.
- The MXU has separate runtime assertions for M<=ROWS, PAIR, group size, GALL/no PAIR, grouped RMAX/ASCALE M bound, SPL and KT. They are also under `ifndef SYNTHESIS`; a synthesizable `mm_bad` must not rely on them.
- `otpu_slice` passes exact `FIFO_DEPTH` to `otpu_mxu DEPTH`, and target TOMLs use depths 64, 1024 or 2048. The sequencer needs the exact effective depth if and only if the validated guard contract includes the FIFO admission rule.

### Revised design decision
- The ISA semantic malformed-word guard and the physical MXU admission guard should be explicitly separated in code/comments and tests. The former mirrors the ISA simulator; the latter mirrors target/uarch FIFO safety conditions and may differ by target.
- Do not label every physical FIFO admission restriction as an ISA rule. Record it as a hardware configuration constraint and test it across the target matrix.


## Target variant overrides — correction and completion
The complete TOML section scan (including `[variants.*]`, not only base `[arch]`) found these important overrides:
- `bcu1525-s2:kt`: KT enabled.
- `bcu1525-wg:kt`, `:bhw`, `:bhw16`, `:wmx`, `:bhw16fs`: KT enabled even though the base `bcu1525-wg` architecture has KT disabled.
- `bcu1525-x2:b2`: SPLMM enabled. This corrects the earlier base-section-only observation; SPLMM is enabled in at least this named target variant and must be tested.
- `ypcb-00338:m8` overrides MCOLS to 8; `:m4` keeps MCOLS 4.
- The variants retain the target's other base geometry unless explicitly overridden. Guard tests must use the resolved target configuration (base + variant), not parse only the base sections.
- `bcu1525-x2:b2` is the mandatory positive SPLMM elaboration/test case; include a disabled-SPLMM variant negative test as well.


## FIFO capacity implication across every current target
The resolved target TOML scan also shows `ACT_BLOCKS <= FIFO_DEPTH` for all eight current base targets (32<=64 for nangate45-small; 128<=1024 or 2048 for the others). Every legal MM has `ab + KB <= ACT_BLOCKS` (SPL reads KB-1 ACT blocks), hence `KB <= ACT_BLOCKS <= FIFO_DEPTH`; for 4-bit natural rows the chunk count is only ceil(KB/2). This implies the MXU's whole-row chunk prefill fits the current target FIFO for every semantically legal MM. The existing replay-specific `$fatal` checks are therefore redundant for these targets, assuming the parameter values are resolved as inspected.
- Preferred control: add/retain a target elaboration invariant `FIFO_DEPTH >= ACT_BLOCKS` in the appropriate top/target validation, and keep the ISA-level MM guard focused on ACT block bounds. If the sequencer is to independently enforce physical admission, pass FIFO_DEPTH and test it; do not duplicate the same condition without a stated reason.
- This implication must be added to target validation tests so future target variants cannot silently break it. It is a derived invariant from the current target matrix, not a universal ISA guarantee.
