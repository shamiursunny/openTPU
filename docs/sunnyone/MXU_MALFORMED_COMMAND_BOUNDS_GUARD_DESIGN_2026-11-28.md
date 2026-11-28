# SUNNYONE X — MXU malformed-command bounds guard: implementation review

Date: 2026-11-28 (Asia/Dhaka)
Repository: `shamiursunny/openTPU`
Branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Status: source-grounded design review; no RTL change in this review.

## Finding

The MM legality rules in `docs/isa.md` are not all enforced in synthesizable logic before the MXU receives a raw command. `rtl/mxu/otpu_mxu.sv` has a substantial `ifndef SYNTHESIS` assertion block around the start handshake. It checks several conditions, but those checks do not protect fabricated hardware. The RMAX/ASCALE `M <= MCOLS` check is also conditional on `GA`, so the assertion does not cover WG=1. The synthesizable RMAX write path indexes `mx_key[MW'(mx_i + k)]` when `mxm[k]` is set; legal command shape and lane bounds must be guaranteed before this can occur.

## Exact source boundary

- `otpu_seq.sv` resolves raw instruction fields into `dcmd` in its R stage and has a synthesizable malformed-program rejection pattern, `fsum_bad`, which rejects before the command enters `p_cmd` / the dispatch window.
- `otpu_seq` currently receives `WG`, but not `MCOLS` or `ACT_ROWS`.
- `otpu_slice` already has `MCOLS` and `ACT_ROWS` parameters and instantiates both sequencer and MXU. The MXU receives `MCOLS` and `ROWS=ACT_ROWS`.
- The current ASIC wrapper passes its configured `MCOLS` and `ACT_ROWS` into the slice. The ASIC default is `MCOLS=4, ACT_ROWS=MCOLS`; the general slice default is `MCOLS=8, ACT_ROWS=MCOLS`.
- Therefore a sequencer-side guard must be parameterised with the same elaborated values as the MXU. A hard-coded 4 or 8 is incorrect.

## Recommended minimal implementation

1. Add `MCOLS` and `ACT_ROWS` parameters to `otpu_seq`, with defaults matching `otpu_slice`'s defaults, and pass the exact values from `otpu_slice`.
2. Define a synthesizable `mm_bad` combinational predicate using the already-resolved `dcmd`, effective `WG`, `MCOLS` and `ACT_ROWS`.
3. At minimum enforce the ISA's universal shape bounds before dispatch: `N >= 1`, `KB >= 1`, `0 < M <= ACT_ROWS`.
4. Enforce mode-dependent bounds before dispatch: RMAX/ASCALE require `M <= MCOLS`; PAIR requires `M <= MCOLS` and `2*M <= MCOLS`; PAIR is not allowed with WG>1; RMAX/ASCALE with WG>1 are legal only under GALL; the GALL/weight-format/group-size rules must match the existing ISA and MXU contract exactly.
5. Combine `mm_bad` with the existing invalid-instruction branch at the R stage, so a malformed MM sets `error` and `halted` before `p_v`, `icount` dispatch increment, unit start, TMEM writes or DRAM stream requests.
6. Keep simulation assertions as diagnostics if useful, but they must not be the only protection. Avoid clamps, silent truncation, blanket casts and warning suppression.

## Required directed raw-RTL tests

Use raw encoded MM instructions so compiler/ISA validation cannot mask the hardware guard. For each case, assert error/halt before MM dispatch, zero MM instruction dispatch count, no TMEM mutation and no external DRAM request/side effect.

- Universal bounds: N=0, KB=0, M=0, M=1, M=ACT_ROWS, M=ACT_ROWS+1.
- Column bounds: M=MCOLS and M=MCOLS+1 for RMAX and ASCALE, with WG=1 and WG>1 as applicable.
- PAIR: M=floor(MCOLS/2), M=floor(MCOLS/2)+1, M=MCOLS, and WG=1 versus WG>1.
- GALL: legal/illegal `lg`, WG, WF and RMAX/ASCALE combinations.
- Elaborations: the selected ASIC configuration (`MCOLS=4`) and at least one supported general configuration with a different MCOLS, if that configuration is in the declared support matrix.

Test assertions must compare against the same elaborated parameters as the DUT. Do not use a single hard-coded boundary fixture for every configuration.

## Open design questions before patch

- Confirm whether the external instruction image is formally treated as untrusted at the chip boundary. The conservative default should be yes.
- Confirm exact encodings and supported combinations for PAIR and WF_NVFP4 against the complete ISA/weight-group documents before writing the predicate.
- Confirm whether any wrapper-level command validation is already planned; no such synthesizable MM shape guard was identified in the reviewed sequencer/MXU path.
- Ensure the rejection path's status/stop semantics are compatible with the host and do not accidentally start or release a partially accepted command.

## Verification boundary

No RTL was changed and no test was run for this design note. The finding is a potential malformed-program hardware bounds-safety gap, not evidence that compiler-generated legal workloads fail. A source patch is not considered complete until the raw-command RTL tests, relevant existing MXU regressions, lint and the applicable formal properties pass on the exact resulting commit.

Manufacturer handoff remains **NOT READY**.
