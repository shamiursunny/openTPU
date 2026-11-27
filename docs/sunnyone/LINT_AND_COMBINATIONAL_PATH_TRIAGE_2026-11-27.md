# SUNNYONE — Lint and Combinational-Path Triage

**Date:** 2026-11-27  
**Repository:** shamiursunny/openTPU  
**Reference full-chip lint run:** 45845758782  
**Reference ASIC-config run:** 45845758681  
**Status:** Source-level triage only; no RTL changes and no warning closure claimed.

## 1. Seven LATCH warnings — classified as simulation-only

The full-chip Verilator workflow runs the simulation top tb_top without defining SYNTHESIS. Its seven LATCH diagnostics in rtl/seq/otpu_seq.sv are:
- c2 and r2 in the WAITC / +hz_ino diagnostic branch around lines 1195–1216.
- u, y, k, kd and nested cf in the +hz_wc dependency-oracle block around lines 1714–1988.

Both diagnostic branches are enclosed by ifndef SYNTHESIS. The ASIC synthesis flow in tools/asic/flow.py invokes Yosys/Slang with -D SYNTHESIS, excluding these variables and blocks from the synthesized hardware.

**Conclusion:** These seven warnings are simulation-only diagnostic code and are not evidence of hardware latches in the ASIC synthesis configuration. Do not modify functional RTL to silence them. The simulation lint may retain them as testbench/diagnostic warnings, or a separately justified cleanup may be considered later.

**Remaining check:** Inspect the synthesized netlist for actual latch primitives after a successful synthesis stage. This independent netlist check is still required; the source guard alone does not prove that no other latch exists.

## 2. UNOPTFLAT: pq — source-level aliasing explanation

Verilator path from full-chip lint:
- rtl/mem/otpu_tmem.sv:297 signal pq
- rtl/mem/otpu_tmem.sv:1074 assignment pq[p] = pq[host_of(p)]

The generate structure creates g_copy only when IMPL != 3 and host_of(p) == p. The g_guest branch is used only for non-host ports and aliases their pq element to the selected host port. host_of is:
- IMPL 0: SH_HOST for ports selected by SH_MASK; otherwise the port itself.
- Other non-IMPL-3 configurations: the first port q with CPY[q] == CPY[p], or p if no earlier matching port exists.

Thus the intended mapping is a one-way alias from guest to a host port; the host port owns the RAM/data path. The packed multidimensional pq array can cause Verilator to model the whole array as one dependency and report a self-cycle even though the selected element mapping is acyclic.

**Assessment:** likely an array-granularity / alias-analysis false positive, supported by source structure. Not formally closed.

**Required confirmation:** inspect elaborated connectivity or Yosys JSON/netlist for each generated port and prove that host_of(p) points to a g_copy host, never a guest cycle. Preserve IMPL/CPY/SH_MASK parameter values for the exact lint and ASIC configurations.

## 3. UNOPTFLAT: sc_gl — process-granularity explanation

Verilator path:
- rtl/top/otpu_top.sv:156 sc_gl
- rtl/top/otpu_slice.sv:1047 always_comb
- rtl/top/otpu_slice.sv:898 cgl_c
- rtl/top/otpu_slice.sv:963 always_comb
- back to sc_gl

The slice's cgl_c is computed from read/write request masks, bank counters, q_blk, q3_blk and coll_blk. In the same always_comb process, gnt_c[G_COLL] is assigned from the incoming coll_gnt. The cgl_c calculation itself does not read coll_gnt, but process-level dependency analysis can conservatively treat every output of the process as dependent on every input read by that process. The separate cgl_m assignment around lines 957–959 already documents the design intent that local collective availability is independent of global coll_gnt.

**Assessment:** probable process-granularity false positive; the equations suggest cgl_c is independent of coll_gnt, but the complete elaborated graph has not been proven.

**Required confirmation:** derive cgl_c and gnt_c separately in an elaborated net graph or equivalence-preserving temporary lint experiment. If splitting the process is considered, first preserve the current equations and run the exact functional/collective arbitration regressions. Do not change grant timing or protocol semantics.

## 4. UNOPTFLAT: gnt — unresolved VPU grant/enable path

Verilator path:
- rtl/top/otpu_slice.sv:611 gnt
- rtl/vpu/otpu_se_comp.sv:640 u_k.en (en_l[l])
- rtl/vpu/otpu_fpipe.sv:15 otpu_delay input en
- rtl/top/otpu_slice.sv:963 always_comb
- back to gnt

The VPU's direct write mode computes en = gnt && f_ok and en_l replicates en. The VPU read and write request vectors are assembled from ta_en/tb_en/tw_en and related signals; some are registered and the write buffer has distinct direct/buffered implementations. The warning's example path reaches a sequential enable pin, but that alone does not establish a combinational return path through the delay element. It may be a Verilator dependency over-approximation or a real path elsewhere in the VPU/TMEM arbitration logic.

**Assessment:** OPEN. Do not classify as false positive yet.

**Required confirmation:**
1. Resolve the exact elaborated parameters for the failing tb_top configuration (WBUF, TMEM_IMPL, SL, SE_OWN, VPU pipeline and arbitration options).
2. Trace gnt -> en_l -> all VPU combinational outputs -> rq_en/wq_en -> arbiter gnt, explicitly marking sequential boundaries.
3. Check whether any output feeding gnt depends combinationally on en_l; distinguish registered ta_en/tb_en/tw_en from combinational cw_en/f_ok/hold paths.
4. Generate a machine-readable netlist/dependency graph and run SCC analysis; inspect any SCC containing gnt.
5. Only if a real combinational cycle is proven, propose a minimal handshake-preserving correction and verify with equivalence and concurrency/backpressure tests.

No register insertion or grant-path restructuring is authorised from the warning alone.

## 5. Additional ASIC-config UNOPTFLAT: aok

The ASIC configuration compile reported an additional warning on aok in rtl/top/otpu_slice.sv around line 906. The source grant loop initializes each aok[g] and only reads aok[h] for h < g when suppressing a conflicting lower-priority group. The dependency is intended to be a strict lower-index-to-higher-index priority chain, not a mathematical cycle. Verilator may treat the packed aok vector as one signal.

**Assessment:** likely vector-granularity false positive, not formally closed. Confirm from elaborated per-bit dependencies. Do not change priority/arbitration behaviour to silence the warning.

## 6. Current lint status and policy

- Seven LATCH warnings: classified as simulation-only and excluded by SYNTHESIS; no hardware latch conclusion from these warnings.
- pq: probable alias-analysis false positive; confirm at elaborated-net level.
- sc_gl: probable process-granularity false positive; confirm at elaborated-net level.
- gnt: unresolved; highest-priority structural path.
- aok: probable vector-granularity false positive; confirm at elaborated-net level.
- 79 width warnings remain (52 WIDTHEXPAND, 27 WIDTHTRUNC), plus ASIC-specific 34-bit to 33-bit AW/AR port-connection warnings from the ASIC configuration compile.

No blanket waivers, warning suppressions, speculative RTL edits or timing/functional claims are permitted. A warning is closed only with source/configuration evidence, elaborated/synthesized evidence where appropriate, and regression/proof results.



## 2026-11-28 superseding structural evidence and VPU width remediation

See `LINT_TRIAGE_UPDATE_2026-11-28.md` for the complete evidence ledger. The earlier OPEN classifications of `gnt`, `pq`, `sc_gl` and `aok` are superseded for the exact audited configurations: reset/SCC workflow `45914912691` completed successfully with zero SCCs and zero inferred latch cells on the one-copy slice, two-slice top and actual ASIC card top. These warning names are not confirmed combinational cycles in those elaborations; Verilator warnings remain. This is not a blanket proof across all configurations.

The seven generic LATCH diagnostics are in `ifndef SYNTHESIS` diagnostic/oracle code. Three synthesis elaborations found no latch cells. Keep simulation diagnostics distinct from ASIC hardware latch signoff.

VPU source commit `05879ea34eafc2559c54722c6c940b2acb9ac3ee` explicitly sized all 24 VPU function-mask bit indices to five bits and changed row-buffer indices to the exact `RBW` width. Full-chip lint run `46053311384` passed with 52 WIDTHEXPAND, 7 WIDTHTRUNC, 7 LATCH and 3 UNOPTFLAT diagnostics: 17 fewer width warnings than the 76-warning baseline. Five MXU index warnings and two behavioral-DRAM `exists()` warnings remain in WIDTHTRUNC. All 52 WIDTHEXPAND warnings remain open.

The first dedicated VPU regression attempt `46053329340` failed before RTL simulation because Verilator 5.020 rejected an existing `otpu_se_tail.sv` instantiation. The focused workflow is now pinned to Verilator 5.044; run `46053471843` is the valid regression attempt and must pass before the source change is marked regression-verified.

Do not suppress warnings or infer functional closure from lint success. Manufacturer handoff remains NOT READY.
