# SUNNYONE MM pre-dispatch guard — normative decode and implementation contract

Date: 2026-11-28 (Asia/Dhaka)
Repository: `shamiursunny/openTPU`
Branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
Status: source-derived design specification only; RTL and tests are unchanged.

## Source baseline inspected

- `opentpu/isasim.py` blob `94a02cf018719b4d2db8150a903880cbe0ed4bd1`
- `opentpu/isa.py` blob `17c81a0518bcee5284b912fcb4f08fb3bfadc158`
- `opentpu/target.py` blob `4f8b2b02c91bf7ba68cdb37804e55fff4210700c`
- `rtl/seq/otpu_seq.sv` blob `c8fbaf00f278edd883059cd9d1e4571780b7dd5e`
- `rtl/top/otpu_slice.sv` blob `92d0006245c8fd6878ead9e4f55cf676aee09b35`
- `rtl/mxu/otpu_mxu.sv` blob `3dfdec588933cdc5823d1780bd8b251aba0098e7`
- `docs/isa.md` blob `9f16646c8846d0379a47ffd3d7f5fa6d433f8bcd`
- `tests/test_quant_rtl.py` blob `ce85f5d4f37285b46a792528ab1df322611a1e26`
- `tests/test_target.py` blob `6c162e3d839d594049585a03520d351489ac85e4`

The live branch currently compares 1,239 commits ahead and 0 behind protected baseline `d84db55712aba0d40811d7762cb052f05d55b7e5`. Main remains untouched.

## Exact command decode (from `opentpu/isasim.py::_mm` and `docs/isa.md`)

Instruction is eight 32-bit words. For MM:
- `N = w4[15:0]`
- `KB = w4[23:16]`
- `k0 = w4[31:24]`
- `rs_raw = w5`
- `ors = w6[15:0]`
- `M = w6[23:16]`
- `ab = w6[31:24]`
- `srs = w7`
- `SPL = w7[31]`; for SPL, `HLD = (w7 >> 10) & ((1 << 21)-1)` and the effective scale stride field is `w7[9:0]` (confirm width against package constants before coding).
- Flags: UNIT bit0, ACC bit1, RMAX bit2, ASCALE bit3, WF bits5:4, PAIR bit6, RSC bit7.
- For WG>1, `LG = rd`, `Rg = 1 << LG`; for WG=1, `Rg=1`.
- KT is `ins.rd != 0 && (rs_raw & 1)`; effective `rs = rs_raw - 1` when KT, otherwise `rs_raw`. Preserve the original flag bit separately; do not treat the low stride bit as part of the effective byte stride.
- `D`, `WG`, `MCOLS`, `ACT_ROWS`, `ACT_BLOCKS`, `FIFO_DEPTH`, `KT`, `SPLMM` are elaboration/target values, not instruction values.

## Normative static admission checks

### A. Universal shape and ACT RAM bounds

1. Reject `N == 0` or `KB == 0`.
2. `R = PAIR ? 2*M : M`; require `M > 0` and `R <= ACT_ROWS`.
3. `n_ab = SPL ? KB-1 : KB`; require `ab + n_ab <= ACT_BLOCKS`.
4. All additions and multiplications in these predicates must be widened before operation. Do not truncate an intermediate to the field width and then compare.

### B. Output-column and PAIR legality

1. If RMAX or ASCALE is set, require `M <= MCOLS` in both WG=1 and WG>1 modes. The simulator enforces this independent of GALL; the reviewed MXU simulation assertion did not fully cover WG=1.
2. PAIR requires a 4-bit format (`WF != W8`), even `k0`, no grouped mode (`Rg == 1`), and `2*M <= MCOLS`.
3. Reject PAIR with int8 explicitly. Do not rely on datapath ignoring the flag.

### C. Format and scale flags

1. Reject RSC with NVFP4.
2. ASCALE requires both UNIT and ACC.
3. PAIR even-`k0` check is static and belongs in the sequencer guard.
4. Format codes are W8=0, W4I=1, W4F=2, WNV=3.

### D. Weight-group mode

1. If `Rg > 1`, require `Rg == WG` for int8 and `Rg == 2*WG` for packed 4-bit.
2. Grouped mode refuses PAIR.
3. GALL with WG>1 requires every MM grouped (`Rg != 1`).
4. Grouped mode refuses RMAX/ASCALE unless GALL is enabled. With GALL they are permitted, but the independent `M <= MCOLS` check still applies.
5. For grouped layout, `L = Rg/2` for 4-bit, else `L=Rg`; `P=L*D`. Require `sa % P == 0`, `rs % P == 0`, and for SPL `HLD % P == 0`.
6. The target loader derives GALL from WG>1 and target policy; sequencer parameter should receive an explicit resolved `GALL` bit or use the equivalent documented invariant. Do not infer it from a guessed constant.

### E. SPL mode

1. SPL requires target `SPLMM`; the target loader explicitly requires `SEQ_WC && WG > 1` for SPLMM. This is a target/build prerequisite, not merely an MXU datapath option.
2. SPL requires `KB in {2,3}`, grouped mode, int8 WF, RSC, `k0==0`, `HLD>0`; rejects KT, UNIT, PAIR, RMAX and ASCALE.
3. SPL reads `KB-1` ACT blocks, not KB.
4. SPL's wait-count footprint includes the low-part DRAM range; preserve the existing SEQ_WC/FOLLOW semantics.
5. Confirm `MM_HLD` width/shift and the exact `srs` mask from `opentpu/isa.py` constants before RTL implementation; the extraction above must not be coded from this note alone.

### F. KT mode

1. KT requires target `KT`, grouped mode, `k0==0`, and WF != NVFP4.
2. Require widened `rs >= (2*KB - 1)*P`.
3. KT's address end is:
   `sa + floor((ng-1)/2)*rs + (ng odd ? KB : 2*KB-1)*P`,
   where `ng = ceil(N/Rg)`.
4. The last ACT block upper-half-zero check is dynamic memory-content validation. It cannot be proven from instruction bits at decode; keep it in simulation/runtime/data-validation tests, not the static command predicate.

### G. FIFO residency (target/uarch admission, not ISA semantics)

The simulator does not model `FIFO_DEPTH`. Preserve the actual two-mode rule from the MXU source/docs:
- Natural WG=1 replay, only when `M > MCOLS`: int8 requires `KB <= FIFO_DEPTH`; packed 4-bit requires `ceil(KB/2) <= FIFO_DEPTH`.
- Grouped WG>1/GALL replay, only when `M > 1`: require `KB <= FIFO_DEPTH`.
- Do not add universal `FIFO_DEPTH >= ACT_BLOCKS`.
- Confirm the exact `DEPTH` assertion conditions in the current MXU before translating this admission predicate; a mismatch between RTL and documentation is a blocker, not a reason to pick the stricter rule arbitrarily.

### H. DRAM address and range checks

The simulator checks D-byte alignment of `sa` and effective `rs`, and computes an exclusive end address. For non-KT:
- `bpb = D` for int8, `D/2` for packed 4-bit.
- `L = Rg/2` for grouped 4-bit, else `Rg`.
- `P = L*D`.
- `nch = 1` for SPL; else `KB` for grouped; else `ceil(KB*bpb/D)` for natural mode.
- `ng = ceil(N/Rg)`.
- `end = sa + HLD + (ng-1)*rs + nch*P`.
For KT use section F's special end formula.
Require `sa % D == 0`, `rs % D == 0`, and `end <= DRAM_BYTES`. Equality is legal because end is exclusive. One byte beyond is illegal.
Implementation blocker: current `otpu_seq` receives AW but not the exact target `DRAM_BYTES`/DRAM_LOG2, while the target RTL parameter map exposes DRAM_LOG2 at a higher integration layer. Trace the exact top/board/slice propagation before claiming this guard covers simulator DRAM range semantics. At minimum, reject arithmetic overflow beyond AW; do not silently claim that this equals the configured DRAM aperture.

## Sequencer integration facts

- `otpu_slice` declares MCOLS, ACT_BLOCKS, ACT_ROWS, FIFO_DEPTH, WG, KT and MXU_SPL.
- The one inspected `u_seq` instance currently passes WG only, not those MM bounds/capability values.
- The same slice's `u_mxu` receives MCOLS, ROWS=ACT_ROWS, DEPTH=FIFO_DEPTH, WG, KT and SPL=(MXU_SPL != 0).
- Target `rtl_params()` includes MCOLS, ACT_ROWS, ACT_BLOCKS, FIFO_DEPTH and DRAM_LOG2; target validation requires SPLMM only with SEQ_WC and WG>1.
- Before module interface edits, finish a repository-wide `otpu_seq` instantiation census and all slice/top variants. This review established the single `u_seq` in the inspected `otpu_slice`, not yet every simulation or alternate top instantiation.
- Preferred minimal integration: add explicit sequencer parameters for MCOLS, ACT_ROWS, ACT_BLOCKS, FIFO_DEPTH, KT and SPLMM/GALL as needed; connect directly from `otpu_slice` parameters; derive feature booleans from resolved top parameters, never hardcode. Verify no independent sequencer instantiations require non-default compatibility.

## Raw-word test matrix required before RTL patch

Every invalid case must be loaded as a raw 8-word instruction and prove:
- sequencer sets error/halted;
- invalid command never asserts MXU start/dispatch;
- no port-B weight prefetch, port-A scale request, TMEM write or ACT write occurs for that command;
- no partial side effect occurs if malformed command is held/backpressured;
- following instruction does not execute.

Positive controls:
- WG=1 int8 legal; WG=1 packed 4-bit legal; legal natural replay at exact FIFO capacity and one below capacity.
- PAIR legal 4-bit even k0 with 2*M exactly MCOLS; reject 2*M one above.
- GALL grouped int8 and grouped 4-bit legal at exact geometry.
- SPL legal KB=2 and KB=3 for an SPLMM+SEQ_WC target.
- KT legal stride exactly `(2*KB-1)*P` and one-byte/D-aligned step below rejected.
- ACT bound equality `ab+n_ab == ACT_BLOCKS` legal; one greater rejected.
- DRAM exclusive end equality legal; one byte beyond rejected.
- For each numerical bound, include zero, maximum legal, and one-past maximum where field encoding allows.

Negative cases should isolate one reason at a time, not combine multiple malformed flags and then infer which guard fired. Keep dynamic KT ACT-memory content tests separate.

## CI containment and go/no-go

- The existing `.github/workflows/sunnyone-rtl-subsystems.yml` has a broad `rtl/**` push path and includes an MX multiply/replay group. Pushing `otpu_seq.sv` or `otpu_slice.sv` will trigger broad regressions, including tests that overlap historically passed suites.
- The separate FSUM workflow also watches sequencer and slice files, so it will trigger too.
- The connected GitHub tool surface has no exact workflow-dispatch action. A YAML `workflow_dispatch` declaration does not make it callable here.
- Therefore no RTL change is authorised by this document. First create a dedicated MM workflow and a test route whose trigger does not run on ordinary push to the existing feature branch, then obtain a safe way to dispatch it on an exact SHA. Do not disable or weaken existing CI protections just to avoid reruns.
- Preserve previous successful group evidence; no re-run of groups 3.1/3.2/4 merely for confirmation. Do not restart cancelled run 45765362426. No PPA retry, purchase or spend.
- Manufacturer handoff remains **NOT READY**.
