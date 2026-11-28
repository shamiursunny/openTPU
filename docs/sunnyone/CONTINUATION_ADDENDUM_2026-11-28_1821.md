# SUNNYONE continuation addendum — 2026-11-28 18:21 Asia/Dhaka

This is the latest live-state reconciliation for continuation. Read it after CURRENT_CONTINUATION_CHECKPOINT_2026-11-27.md and the 2026-11-28 00:50 and MXU ISA reconciliation addenda.

## Repository state verified before this documentation save
- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Live feature ref at verification: `8c65b8b33fda16a588227f64d26be7edea4b04c2`.
- Latest commit message: `docs(sunnyone): record trace correlation RTL verification`, 2026-11-28 09:51:38 UTC.
- Parent: `3cc1ec1d0aaee797022cc355e68e8451a13c4e6b`; this latest commit is documentation-only.
- Main remains `d84db55712aba0d40811d7762cb052f05d55b7e5). GitHub reports `protected=false`; this is a repository control gap, not permission to modify main. Main remains strictly off-limits.
- All writes in this continuation are documentation-only on the feature branch. No RTL, tests, workflows or PPA settings changed.

## Live Actions reconciliation
- Queried the branch's latest 100 Actions runs. No run was IN_PROGRESS or queued in the returned page.
- Latest relevant workload harness run `46132183828`, job `140939555937`, on source `3cc1ec1d0aaee797022cc355e68e8451a13c4e6b`: terminal SUCCESS. Actual job steps all succeeded, including compile and test.
- Actual log: `Ran 47 tests in 52.079s`; final status `OK`. This includes trace-correlation parser/unit cases, one real Verilator DMA-LD trace co-simulation, W1/W2/W3 fixture tests and associated benchmark/resource/workload-trace tests.
- Several immediately preceding automatic harness runs failed while successive commits were being made; the final run above is the terminal successful run on the latest relevant source commit. Do not count those failed attempts as passes or rerun the final successful suite merely for reassurance.
- Focused VPU run `46053471843` remains terminal SUCCESS on its exact older source SHA: 31 VPU tests plus 11 selected FSUM RTL tests (219 deselected). No rerun.
- W1/W2/W3 harness run `46090474983` remains terminal SUCCESS on its exact fixture commit: 37 passed. The later 47-test run also exercises those scenario fixtures. These are deterministic fixtures and simulator integration, not hardware scheduler fairness or measured accelerator performance.
- PPA run `45877786710` remains terminal FAILURE with host OOM-killer evidence; no PPA retry is authorised.
- Protected historical RTL groups 3.1/3.2/4 remain excluded from reassurance reruns. Never restart cancelled run `45765362426`.

## Current engineering review — MXU malformed-command safety
- Re-fetched current-branch source blobs: sequencer `rtl/seq/otpu_seq.sv` = `c8fbaf00f278edd883059cd9d1e4571780b7dd5e`; slice `rtl/top/otpu_slice.sv` = `92d0006245c8fd6878ead9e4f55cf676aee09b35`; MXU and ISA source were also re-read.
- Confirmed `otpu_seq` has the existing synthesizable FSUM malformed-command guard, but no equivalent `mm_bad`/MM shape guard. The sequencer parameter list currently has WG but not MCOLS or ACT_ROWS.
- `otpu_slice` owns the exact MCOLS and ACT_ROWS elaboration values and passes them to the MXU/ACT RAM; the sequencer must receive these same values. Hard-coded 4 or 8 is not acceptable.
- Primary ISA rules remain those recorded in `CONTINUATION_ADDENDUM_2026-11-28_MXU_ISA_RECONCILIATION.md`: universal N/KB/M bounds; RMAX/ASCALE/PAIR column limits; PAIR 4-bit, 2*M bound and WG exclusion; GALL restrictions; ASCALE UNIT+ACC; RSC/WF=3 exclusion; grouped-WG constraints.
- No RTL patch was made. This is deliberate: a correct synthesizable predicate must be derived from exact resolved `dcmd` fields and all mode/flag interactions, then paired with raw-word negative RTL tests that bypass compiler validation. A partial or speculative guard could reject legal grouped MM programs or leave an unsafe path open.
- Next implementation gate: audit all `otpu_seq` instantiations and instruction field decoding; implement MCOLS/ACT_ROWS parameter propagation and a width-safe R-stage MM reject before `p_v)/dispatch; add raw MM instruction tests for legal boundaries and malformed N/KB/M, PAIR, WF/RSC, ASCALE and WG/GALL cases; prove no dispatch, TMEM mutation or external DRAM request; run only the new focused regression and exact lint/formal scope. Do not narrow `mx_key` until this gate passes.

## Other open gates
- 59 full-chip width warnings recorded after VPU index remediation: 52 expansion and 7 truncation. Five MXU index truncations and the remaining semantic/range review need closure; no blanket casts or waivers.
- Exact lint/SCC review and synthesized latch evidence remain configuration-scoped; prior zero-SCC/zero-inferred-latch audit does not replace formal, CDC/RDC or full physical signoff.
- Formal/SVA, CDC/RDC, technology SRAM/DDR mapping, production PCIe/SerDes and DMA/IOMMU, DDR controller/PHY/training/ECC, DFT, routed STA/DRC/LVS/ERC, IR/EM, power/thermal/reliability qualification remain open.
- Track A full programmable product remains separate from Track B demonstrator. No sponsor, fully funded MPW, package/test, sample custody/delivery or Bangladesh shipping arrangement is confirmed.

## Hard controls and release decision
- Zero spend; no paid runner/compute, PDK/IP licence, fabrication, packaging, board, lab test or hardware purchase without explicit approval.
- No PPA retry is authorised.
- Do not repeat successful tests absent source-affected scope or a demonstrated coverage gap.
- No main-branch writes, merges or rebases.
- Simulation and proxy data are not silicon measurements or manufacturer qualification.
- **Manufacturer handoff remains NOT READY.**

## Resume command
In any new chat, type: **Continue and complete the remaining tasks.** Read this addendum, the current checkpoint, integrated plan, tracker and manufacturer readiness matrix; re-resolve the live feature ref and Actions state before engineering writes or test dispatch.
