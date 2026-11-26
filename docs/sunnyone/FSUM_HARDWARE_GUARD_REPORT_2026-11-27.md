# SUNNYONE FSUM hardware guard — implementation and verification report

Date: 2026-11-27
Repository: shamiursunny/openTPU
Branch: sunnyone/commercial-profitability-architecture-2026-11-23
Implementation source commit: ebd3e4c95d9adb027fe01b81342492e4bf7f4e9a

## Implemented RTL

Files changed:
- rtl/seq/otpu_seq.sv
- rtl/top/otpu_slice.sv
- tests/test_rtl.py
- .github/workflows/sunnyone-fsum-guard.yml

The sequencer has a new FSUM parameter wired from the exact effective VPU capability, `VPU_FSUM != 0 && HAS_SS`. The sequencer's R-stage dispatch guard rejects an FSUM-flagged VOP when:
- the effective FSUM capability is disabled;
- the function is neither EXP2SUB nor RSUM;
- EXP2SUB rows are zero or exceed 256;
- EXP2SUB columns are below 64;
- EXP2SUB uses scalar B mode;
- RSUM take has no previously dispatched EXP2SUB FSUM producer pending.

A synthesizable 32-bit pending counter increments on dispatch of EXP2SUB+FSUM and decrements on dispatch of RSUM+FSUM. The counter resets with the sequencer. HALT with a nonzero pending count sets the program error and enters the existing stopping/drain path rather than silently accepting a program with untaken row sums.

Invalid FSUM commands are rejected before VPU dispatch and use the existing error/halt path. The guard preserves RSUM+FSUM as the valid take operation.

## Targeted verification

Workflow: 45911471194
Job: 140220612855
Conclusion: SUCCESS
Log: 11 passed, 219 deselected in 133.66 seconds.

Passed cases:
1. Zero-row EXP2SUB FSUM rejected.
2. 257-row EXP2SUB FSUM rejected.
3. 63-column EXP2SUB FSUM rejected.
4. Scalar B mode rejected.
5. EXP2SUB FSUM rejected when FSUM capability is disabled.
6. RSUM take rejected when FSUM capability is disabled.
7. RSUM take rejected when no producer is pending.
8. FSUM rejected when the effective HAS_SS capability is false (four lanes).
9. HALT with an untaken FSUM reports an error after the sequencer's stopping path.
10. FSUM flag on unrelated VOP function rejected.
11. Legal 256 x 64 EXP2SUB FSUM and RSUM take succeeds; output and row sums were checked.

Full-chip lint: workflow 45911470968 SUCCESS. The log still has 76 width warnings (52 WIDTHEXPAND, 24 WIDTHTRUNC), 3 UNOPTFLAT diagnostics and 7 LATCH diagnostics. The FSUM changes introduced no new width warning count.
Loop-stack boundary workflow 45911470960 SUCCESS.
Isolated 128K one-copy TMEM workflow 45911470982 SUCCESS.

## RSUM take semantic limitation

The hardware counter enforces that a take has a preceding pending producer and that no pending producer remains at HALT. It does not yet retain a FIFO of every producer's row count and sum destination, so it does not independently prove that each RSUM take's destination/row count matches the oldest producer. The ISA simulator checks this exact destination/row-count match. Preserve this as an explicit hardware-versus-ISA semantic gap; do not mark the entire RSUM take contract closed.

## PPA safety

The WG8 PPA workflow's push trigger was changed to require an explicit commit touching docs/sunnyone/PPA_REQUEST.md. Ordinary RTL, target and flow changes no longer launch full-chip PPA automatically. workflow_dispatch remains available for deliberate, separately approved runs. No PPA was dispatched in this continuation. The previous OOM artifact and diagnosis remain authoritative.

## Remaining engineering work

1. Complete the width warning inventory with proven, targeted corrections; do not blanket-cast or waive.
2. Prove the three UNOPTFLAT paths with an elaborated structural SCC/netlist analysis before deciding whether they are real loops or tool partitioning artifacts.
3. Review ASIC AW/AR width warnings and boundary coverage.
4. Expand formal/SVA and CDC/RDC checks.
5. Confirm synthesized-netlist latch-cell absence or document intentional latches with source and mapped-cell evidence.
6. Complete memory macro, physical implementation, PDK, DFT, interface and board validation gates.
7. Keep Track A product and Track B demonstrator separate; no manufacturer handoff until all gates have evidence.

No paid compute, cloud resources or hardware were used. main was not modified.
