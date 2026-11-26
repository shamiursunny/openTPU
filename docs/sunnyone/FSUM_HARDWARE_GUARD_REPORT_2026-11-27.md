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


## PPA trigger incident correction — 2026-11-27

Correction to the preceding note: editing PPA_REQUEST.md itself initially triggered WG8 PPA run 45911873124. This was an assistant-authored workflow-control mistake. The run was cancelled at 23:37:04Z after approximately 73 seconds. Its retained artifact (15159964408; ZIP SHA-256 a5a1bea55d30b1b0e5721f2eae33049bd0003a1504c7925f84aa5e676c05ccf3) shows macro prep/config and Yosys 1_1_yosys_canonicalize only; no floorplan, placement, CTS, PDN or PPA report. cgroup peak was 894,529,536 bytes; OOM counters were zero. One minute of GitHub-hosted runner time was consumed; exact billing/quota cannot be established from this interface.

The corrected workflow is in commit 98335138bd73751699afc4a31ce0b206ff2720a1. Push paths are now docs/sunnyone/PPA_EXECUTE_REQUEST.md and the workflow file; a push job also requires [RUN-PPA] in the commit message. The correction run 45911965872 was SKIPPED and caused cancellation of the accidental run. PPA_REQUEST.md is documentation only. Do not create PPA_EXECUTE_REQUEST.md or use workflow_dispatch without explicit user approval of the exact source SHA.

Full incident evidence: docs/sunnyone/PPA_TRIGGER_INCIDENT_2026-11-27.md.
