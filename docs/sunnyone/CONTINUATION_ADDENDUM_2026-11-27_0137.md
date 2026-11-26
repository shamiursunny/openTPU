# SUNNYONE continuation addendum — 2026-11-27 01:37 Asia/Dhaka

This addendum supersedes earlier in-progress workflow snapshots where the run IDs below overlap. Read this after CURRENT_CONTINUATION_CHECKPOINT_2026-11-27.md and before taking further action.

## Live repository state
- Repository: `shamiursunny/openTPU`
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
- Branch search confirms the named feature branch exists.
- Live compare: feature branch is 886 commits ahead of `main`, 0 behind; merge base is the protected-by-project-rule main SHA `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- GitHub compare response does not expose the current feature HEAD SHA. Do not substitute an older checkpoint SHA as the current HEAD. Re-resolve the live branch ref before the next write.
- Main remains `d84db55712aba0d40811d7762cb052f05d55b7e5`. Prior API observation said GitHub branch protection is disabled; this is a control gap, not permission to modify main.
- No RTL, test, workflow or project source was changed in this continuation. No CI workflow was dispatched, cancelled, or rerun.

## Live Actions poll
Polled current job states directly. These are statuses, not final results:

| Workflow run | Live state at 01:37 | Notes |
|---|---|---|
| 45877786710 — WG8 PPA | IN_PROGRESS | Pinned-container SRAM probe and WG8 ORFS flow still running. Do not launch another PPA attempt. |
| 45877786754 — Qwen | IN_PROGRESS | Real-checkpoint RTL step passed; the separate eight formerly PyTorch-skipped tiny board-model cases are running. |
| 45877786742 — Board | IN_PROGRESS | Board-functional regression running. |
| 45877786699 — Subsystem/memory | PARTIAL | Quantizer, MX, QST/QSTB, instruction cache, QHL, SPLITQ, waits, stream, collective/DMA/scoreboard and FP jobs completed successfully; address-window and native DRAM/technology RAM jobs running; reset-audit job queued. |
| 45877786705 — Software/ISA | PARTIAL | Kernels, MX, VOPS, dataflow, FP, stream, ISA, quant, formats and compiler jobs completed successfully; waits running; host-runs, host-lock, WAITW and host jobs queued. |
| 45877786738 — Reset audit | SUCCESS | Dedicated reset/power-up audit job completed. |
| 45877786860 — ASIC config | SUCCESS | Integrated control/compute, native-memory and four-DIMM AXI lint; four-DIMM AXI simulation, address-map simulation and mux contention simulation all completed. |
| 45877807906 — RTL tail | SUCCESS | Selected non-experimental RTL-tail job completed. |
| 45877807985 — Isolated 128K one-copy TMEM | SUCCESS | Dedicated two-case investigation completed. |
| 45877985241 — LOOP stack guard | SUCCESS | 2 passed, 217 deselected; legal depth-four and fifth-level overflow rejection passed. |

Do not count any IN_PROGRESS or queued job as passed. Do not rerun terminal successful jobs just to reconfirm. Preserve the exclusions: never rerun RTL groups 3.1, 3.2 or 4 solely for confirmation; never restart cancelled run 45765362426.

## FSUM row-buffer safety review — design conclusion, no patch yet

Source files reviewed at the active feature branch:
- `rtl/vpu/otpu_vpu.sv` blob `394930f52079883230cea79b28c05df5ee913566`
- `rtl/seq/otpu_seq.sv` blob `a090328d66af8f3b947bd001282fed39f0ac0cbf`
- `rtl/top/otpu_slice.sv` blob `f879785be44f52fdf64580843dd5249548775717`
- `opentpu/isa.py` blob `17c81a0518bcee5284b912fcb4f08fb3bfadc158`
- `opentpu/host/board.py` blob `8d84063977eade0575aaef6b63b5f5595a4f5d73`
- FSUM-enabled targets: `targets/bcu1525-wg.toml` blob `fa4e7dc10cf01719842e523cf0a694e733119314`; `targets/bcu1525-x2.toml` blob `0fe59d6058eb1959b92c90a323c13642815dfc7f`.

Verified source facts:
1. The VPU row buffer has a 256-row bound (`NRB=256`). FSUM write/flush activity is driven by the FSUM back end; its row count is used to index buffered partial sums.
2. The synthesizable RDOT guard is not the same as FSUM protection. FSUM's `rows <= NRB` check currently appears only in an `ifndef SYNTHESIS` assertion.
3. FSUM is enabled in `bcu1525-wg` and `bcu1525-x2`.
4. `opentpu/isa.py` enforces rows 1–256, columns at least 64, and a non-scalar B mode for the EXP2SUB FSUM helper. The ISA simulator/compiler checks are not an unavoidable hardware ingress boundary.
5. `Board.load_program` accepts raw uint32 instruction words and does not perform mandatory FSUM semantic validation before loading. Thus the hardware must not rely solely on compiler or simulator checks.
6. The sequencer already has a defined invalid-operation path: set `error` and `halted`; `otpu_slice` exposes `sq_err` through its `error` output.

Most conservative candidate, not yet implemented:
- Add an effective FSUM capability parameter to `otpu_seq`, wired from the slice using the same effective condition as the VPU's `.FSUM(VPU_FSUM != 0 && HAS_SS)` configuration (and verify the VPU's C8 condition).
- Before an `OP_VOP` enters the dispatch pipeline, inspect the decoded `dcmd`. For an EXP2SUB carrying `VF_FSUM`, reject if FSUM is not actually enabled, rows are zero or exceed 256, columns are below 64, or B mode is scalar. Route rejection through the existing sequencer error/halt path before the VPU can begin or write its row buffer.
- Treat RSUM-with-FSUM (take) consistently with feature enablement; review whether any shape/order checks are needed to preserve the documented “oldest untaken FSUM” contract. Do not add unrelated ISA restrictions without evidence.
- Add focused RTL tests on an FSUM-enabled target: legal boundary (256 rows, 64 columns, non-scalar B); over-limit rows (257); too few columns (63); scalar B; disabled-feature rejection; and prove invalid commands do not issue to the VPU or write buffered sums. Keep test scope narrow.
- Do not implement while PPA run 45877786710 remains active: `otpu_seq.sv` is in its source/path scope and the PPA workflow uses cancel-in-progress concurrency. Wait for that exact run to reach a terminal state and archive its logs/telemetry first.

## Next actions, in order
1. Poll the five active/partial workflows above until terminal; inspect actual job logs and artifacts, not only summaries.
2. For PPA run 45877786710, verify immutable ORFS manifest/image identity, cgroup memory events/limits/peak and stage logs. Do not label exit 247 OOM without explicit evidence. Do not dispatch a duplicate.
3. Once PPA is terminal, correct the proven `ORFS_CPUS` propagation mismatch in `tools/asic/flow.py` (the current implementation was previously found to derive worker count from `os.cpu_count()` and ignore `ORFS_CPUS`). Add a focused test and verify effective ORFS `NUM_CORES`. This correction is separate from the FSUM RTL guard.
4. Implement and verify the minimal FSUM synthesizable bounds rejection described above.
5. Continue exact-netlist/SCC analysis of unresolved `gnt`, `sc_gl`, `pq` and `aok` UNOPTFLAT paths; retain the width-warning inventory and prove bounds before casts.
6. Continue formal/SVA, CDC/RDC, technology SRAM mapping, production PCIe/SerDes and DMA/IOMMU, DDR controller/PHY/training/ECC, DFT, PDK/package and physical signoff.
7. Keep Track A (full programmable product) separate from Track B (small demonstrator). Do not shrink Track A to fit a shuttle. No sponsor, free fabrication, sample access or shipping is confirmed. Manufacturer handoff remains NOT READY.
8. Maintain zero-spend. No paid runner, PDK/IP licence, fabrication, packaging, board, lab test or hardware purchase without explicit approval.

## Continuation command
In a new chat, the user can type: **Continue and complete the remaining tasks.**
Read the current checkpoint, this addendum, integrated plan, tracker and manufacturer readiness matrix; then re-resolve the live branch HEAD and poll the outstanding run IDs before editing anything.
