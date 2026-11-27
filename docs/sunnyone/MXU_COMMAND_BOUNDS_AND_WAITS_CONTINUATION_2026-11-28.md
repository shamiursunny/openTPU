# SUNNYONE X — MXU Command Bounds and Waits Regression Continuation
Date: 2026-11-28 (Asia/Dhaka)
Branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Status: investigation update; no RTL modification.

## 1. ISA contract
`docs/isa.md` lines 230-247 define MM's M as `w6[23:16]`, require `N >= 1`, `KB >= 1`, `0 < M <= ACT_ROWS`, and require `M <= MCOLS` for RMAX, ASCALE and PAIR; PAIR additionally requires `2*M <= MCOLS`. RMAX/ASCALE with weight groups are permitted only under GALL; PAIR is not permitted with weight groups.

## 2. RTL source trace
- `rtl/mxu/otpu_mxu.sv` parameterisation defines `MCOLS`, `ROWS`, and `MW = $clog2(MCOLS)+1`; `mx_key` is indexed by an MW-sized expression.
- The command entry builder copies `cmd.w6[23:16]` directly into `cmd_e.M` (source lines around 524-560); it derives replay group count and output masks from that untrusted field.
- The MXU accepts the command when `start` is asserted (around lines 2893-2905). The checks for `M > ROWS`, PAIR bounds, replay FIFO bounds, and RMAX/ASCALE constraints occur in a `ifndef SYNTHESIS` region (around lines 302-347). These are simulation-time assertions, not synthesised reject logic.
- In that simulation-only block, the RMAX/ASCALE `M <= MCOLS` check is conditional on `GA` (WG > 1). Thus it does not even assert that particular condition for WG=1, despite the ISA contract applying to WG=1 too.
- RMAX lane enables are derived from `mx_i + k < c_M`; the synthesizable write path indexes `mx_key[MW'(mx_i+k)]` when `mxm[k]` is set (around lines 2594-2612 and 2658-2664). This makes the ISA bound material to index safety.
- The sequencer resolves instruction fields into `dcmd` (around lines 597-635) and its current explicit raw-command rejection example is FSUM-specific (`fsum_bad`). Generic dispatch rejects unsupported unit/op combinations, but the reviewed code does not show an equivalent synthesizable MM shape validator before the MXU start.
- The ASIC top defaults `MCOLS=4`, `ACT_ROWS=MCOLS`; the ISA doc's general reference text describes MCOLS=8 as the usual reference. Therefore validation must use the elaborated target parameters, not assume one fixed width.

## 3. Finding and severity
This is a **potential malformed-program hardware bounds-safety gap**, not evidence that compiler-generated legal programs fail. Compiler/ISA simulator validation may reject invalid programs, but the physical accelerator accepts externally loaded instruction streams and the hardware trust boundary must be explicitly specified. Simulation-only `$fatal` checks cannot protect synthesised silicon.

Do not add a cast to the `mx_key` index, blanket warning suppression, or an arbitrary clamp: each could hide invalid commands or change semantics.

## 4. Required corrective design before RTL patch
1. Decide the trust boundary: are raw program images treated as untrusted? The conservative hardware contract is yes.
2. Add a synthesizable MM legality check before command issue/accept, covering at least `N>=1`, `KB>=1`, `0<M<=ROWS`, and mode-specific `M<=MCOLS` / `2*M<=MCOLS`, plus WG/PAIR/RMAX/ASCALE restrictions already defined by the ISA.
3. Ensure the check uses actual elaborated `MCOLS` and `ROWS` parameters and runs before any derived `cmd_e` state can drive an out-of-range read/write.
4. Route rejection through the existing sequencer/accelerator error and halt/status contract, rather than relying on simulation fatal tasks.
5. Add focused raw-instruction RTL tests for the exact boundary cases: M=0, M=1, M=MCOLS, M=MCOLS+1, M=ROWS, M=ROWS+1, PAIR at floor(MCOLS/2) and one above, WG=1 and WG>1, with RMAX and ASCALE combinations. Verify no TMEM/DRAM side effects after rejection.
6. Add assertions/formal properties for `mx_go -> mx_i+k < MCOLS` whenever the `mx_key` index is used, and prove the command is rejected before the condition can be violated.

This change needs a design review because the MXU module's current interface has no general error output; deciding whether validation belongs in the sequencer, MXU command interface, or wrapper must preserve all existing status semantics.

## 5. Waits test recovery
- Existing software-core run `46053311585`, source `05879ea34eafc2559c54722c6c940b2acb9ac3ee`, had 14 module jobs succeed and only `tests/test_waits.py` cancelled.
- The cancelled waits job ID is `140689717010`.
- A targeted rerun of that single cancelled job was accepted by GitHub (run attempt 2); no other module jobs were rerun. At the time of this note, the rerun is in progress, not yet a pass.
- This is the exact missing coverage, so no broad software matrix rerun is justified.

## 6. Release controls
No RTL, ISA, workflow or test source was changed. No new broad suite or historical RTL group was launched. No PPA retry, paid resource, hardware or QPU service was used. Main remains untouched. Manufacturer handoff remains NOT READY.
