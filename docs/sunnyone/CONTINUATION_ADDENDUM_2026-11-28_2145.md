# SUNNYONE continuation addendum — 2026-11-28 21:45 Asia/Dhaka

## Live state and safety boundary
- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Live branch HEAD at review start: `8ac729eb58b1872ec8b0eaa2f39c38733219ec72`.
- Main remains `d84db55712aba0d40811d7762cb052f05d55b7e5`; no main write, merge or rebase.
- No queued or in-progress Actions run was reported in the preceding 21:38 checkpoint; the latest 20-run API page contains only completed runs. Latest relevant successful workload harness: run `46132183828`, 47 passed, exact tested source `3cc1ec1d0aaee797022cc355e68e8451a13c4e6b`.
- No RTL/test/workflow/PPA source changed and no test was launched in this continuation. This addendum and linked status updates are documentation-only.
- Zero spend; no WG8 PPA retry; no duplicate successful RTL groups 3.1, 3.2 or 4; never restart cancelled run `45765362426`.

## R-stage MM guard source audit — completed static review, implementation still OPEN
Exact source blobs re-fetched from the active branch:
- `rtl/seq/otpu_seq.sv`: `c8fbaf00f278edd883059cd9d1e4571780b7dd5e`.
- `rtl/top/otpu_slice.sv`: `92d0006245c8fd6878ead9e4f55cf676aee09b35`.
- `rtl/mxu/otpu_mxu.sv`: `3dfdec588933cdc5823d1780bd8b251aba0098e7`.
- `opentpu/isasim.py`: `94a02cf018719b4d2db8150a903880cbe0ed4bd1`.
- `opentpu/isa.py`: `17c81a0518bcee5284b912fcb4f08fb3bfadc158`.
- `docs/isa.md`: `9f16646c8846d0379a47ffd3d7f5fa6d433f8bcd`.
- `opentpu/target.py`: `4f8b2b02c91bf7ba68cdb37804e55fff4210700c`.

### Exact dispatch location and missing parameter propagation
- `otpu_seq` currently has a synthesizable `fsum_bad` reject-before-dispatch predicate. In the R-stage default instruction branch, `dunit < 0 || fsum_bad` sets `error` and `halted`; otherwise, when `r_take`, it asserts `p_v`, copies `dcmd` into `p_cmd` and advances. There is no corresponding MM malformed-command predicate.
- The direct `otpu_seq` instance reviewed is `u_seq` in `rtl/top/otpu_slice.sv`. It receives `WG`, but not the exact `MCOLS`, effective `ACT_ROWS`, `ACT_BLOCKS`, `FIFO_DEPTH`, `KT` or `MXU_SPL` values required by the MM guard.
- The same slice already passes `MCOLS`, `ACT_ROWS` as MXU `ROWS`, `FIFO_DEPTH` as `DEPTH`, `KT`, and `MXU_SPL` as `SPL` to `u_mxu`. The guard must use these resolved values; no hard-coded target defaults.
- This audit confirms the missing connection at the reviewed integration point. A full repository-wide direct-instantiation census remains a pre-patch checklist item; do not assume wrappers or test harnesses cannot instantiate the sequencer independently.

### Resolved MM command-field ownership
For the resolved `dcmd` at R stage:
- `w1`: streamed weight address `sa` (DRAM byte address, register-relative base resolved by the sequencer).
- `w2`: scale address `ssa` (DRAM byte address).
- `w3`: output base `out` (TMEM word address).
- `w4[15:0]`: N; `w4[23:16]`: KB; `w4[31:24]`: k0.
- `w5`: row stride `rs`; bit 0 carries KT in the applicable grouped mode.
- `w6[15:0]`: output row stride `ors`; `w6[23:16]`: M; `w6[31:24]`: activation block base `ab`.
- `w7`: scale row stride / SPL metadata; SPL is bit 31 and HLD occupies the defined bits 20..30 when SPL is active.
- `flags`: WF and UNIT/ACC/PAIR/RSC/RMAX/ASCALE modes; `lg` is the group exponent for WG>1.

### Address and bounds ownership
1. Activation row capacity is `ACT_ROWS`: `R = PAIR ? 2*M : M`, and require `0 < R <= ACT_ROWS`.
2. Activation block capacity is `ACT_BLOCKS`: require widened `ab + (SPL ? KB-1 : KB) <= ACT_BLOCKS`. SPL consumes KB-1 activation blocks; ordinary MM consumes KB. These are distinct from FIFO capacity.
3. RMAX/ASCALE require `M <= MCOLS` under the ISA/simulator contract; PAIR requires 4-bit WF, even k0, no groups, and `2*M <= MCOLS`.
4. Natural WG=1 replay when `M > MCOLS`: chunk FIFO residency is KB chunks for int8 or ceil(KB/2) for packed 4-bit. Grouped WG>1/GALL replay when `M > 1`: KB chunks must fit FIFO depth. Do not impose the withdrawn universal `FIFO_DEPTH >= ACT_BLOCKS` rule.
5. `sa` and `ssa` are DRAM byte addresses; `out` is TMEM word address. The ISA simulator additionally checks actual DRAM address ranges against its configured memory. Do not claim a static sequencer guard can prove runtime DRAM allocation bounds unless the relevant memory-size contract is explicitly propagated.
6. KT's last ACT block upper-half-zero condition is dynamic memory-content validation, not a raw-instruction decode predicate.
7. Widen before arithmetic: at minimum for `2*M`, `ab+KB`, SPL's `ab+KB-1`, replay chunk counts and KT pair-stride expressions. Avoid unsized arithmetic and narrowing casts before comparison.

### Remaining semantic decisions before RTL
- Reconcile the RMAX/ASCALE `M <= MCOLS` contract for WG=1 with the current MXU simulation assertion, which gates that check on grouped mode. The simulator/ISA contract is the normative reference unless a documented architectural correction is approved.
- Decide/document how target-specific FIFO admission is represented: the ISA simulator currently does not model `FIFO_DEPTH`; this is a target/uarch condition, not an ISA semantic rule.
- Define deterministic runtime handling for dynamic-data failures such as KT ACT-tail content; do not misrepresent them as statically rejectable fields.
- Complete the direct sequencer-instantiation and effective-parameter propagation census before modifying the module interface.

## Remaining work estimate — not a fabricated test count
There are **14 major work packages** remaining before a defensible manufacturer-ready handoff. This is a project planning count, not 14 individual GitHub issues and not a count of remaining pytest cases.

1. MM guard contract closure and exact target-parameter propagation.
2. Synthesizable R-stage MM reject-before-dispatch implementation.
3. Dedicated raw-word MM negative/positive regression matrix and isolated exact-SHA CI route.
4. Remaining semantic lint-width triage and bounds proof (last verified lint baseline: 59 width diagnostics: 52 WIDTHEXPAND and 7 WIDTHTRUNC; do not assume a new lint result without a run).
5. Formal/SVA properties and proof/coverage closure.
6. CDC/RDC analysis and reset-domain evidence.
7. DFT/test-access architecture and test coverage.
8. SRAM/technology-memory macro mapping and memory implementation evidence.
9. Production interfaces: PCIe/SerDes, DMA/IOMMU, DDR controller/PHY/training/ECC and host integration.
10. Routed physical implementation, timing/area and reproducible PPA signoff.
11. Measured power, thermal, reliability and sustained-workload validation.
12. Track B demonstrator source down-select, PDK compatibility, area/timing/testability specification.
13. Written zero-cost sponsor/fabrication/packaging/test/sample custody/delivery/shipping agreement.
14. Track A commercial workload, model-quality, useful-token throughput, latency, energy and TCO validation; W1/W2/W3 fixtures exist, but trace attribution and calibrated performance/economics remain distinct from passing fixture tests.

### Focused MM test plan estimate
The raw-word guard suite is not yet authored. A reasonable initial plan is approximately **30–45 parameterised scenarios**, subject to the final normative truth table:
- malformed field/shape and feature-capability rejects;
- ACT row and ACT block exact-boundary / one-past-boundary cases, including SPL's KB-1 semantics;
- PAIR, RMAX, ASCALE, RSC/NVFP4, group/GALL, KT and SPL interactions;
- natural and grouped FIFO replay boundaries by format and mode;
- legal positive controls for WG=1, replay, grouped/GALL, supported KT and supported SPL target variants;
- assertions that every invalid command halts before dispatch, MXU start, DRAM request, TMEM write or ACT write.
This is an estimate of planned scenarios, not a statement that these tests currently exist or have passed. Formal, CDC/RDC, DFT and physical test counts cannot be responsibly quantified until their property/coverage plans are written.

## How to expedite without sacrificing evidence
1. Freeze the current source/parameter truth table and direct-instantiation census; resolve the WG=1 RMAX/ASCALE and FIFO model split first.
2. Write the raw-word tests before RTL; include positive legal controls so the guard cannot silently reject supported workloads.
3. Establish an isolated test route that runs the dedicated MM suite against the exact commit without triggering broad `rtl/**` workflows. The connected GitHub tool set exposes read-only workflow inspection but no workflow-dispatch operation; do not push an RTL change into broad CI just to discover the fan-out.
4. Implement the smallest widened-arithmetic guard at the existing R-stage rejection point; keep error semantics consistent with existing sequencer `error/halted` outputs.
5. Run focused MM tests and lint first; only then schedule a serial, source-triggered broader qualification if a specific changed subsystem requires it. Reuse all unaffected successful evidence.
6. Parallelise independent document/spec reviews and workload modelling, but keep scarce CI/PPA runs serial. No paid compute or PPA retry under the zero-spend rule.
7. Keep Track A full product and Track B demonstrator separate. Start sponsor/PDK discussions only with the minimum public architecture brief; no private RTL/GDS before IP/licence/publication terms are understood.

## Release status
No new test result or RTL change is claimed. MM guard remains OPEN. Width, formal/SVA, CDC/RDC, DFT, memory mapping, production interface, routed physical, power/thermal, demonstrator and sponsorship gates remain open or incomplete. Manufacturer handoff remains **NOT READY**.
