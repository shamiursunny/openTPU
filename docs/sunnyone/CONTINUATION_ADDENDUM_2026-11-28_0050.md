# SUNNYONE continuation addendum — 2026-11-28 00:50 Asia/Dhaka

This is the latest continuation record. Read it after `CURRENT_CONTINUATION_CHECKPOINT_2026-11-27.md`. It reconciles the live branch, terminal CI state and remaining engineering gates. It does not claim manufacturer readiness.

## Live repository state
- Repository: `shamiursunny/openTPU`
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
- Latest branch HEAD at this check: `4f26ec9d280f601587f474a4dd535c24f2945e39`, commit message `docs(sunnyone): record isolated STREAM regression success` (2026-11-27 17:38:19 UTC).
- Compare: feature branch 1,055 commits ahead, 0 behind `main`; merge base `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- Protected project baseline `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5`. No main write, merge or rebase.
- The latest commit is documentation-only relative to the verified engineering work; no new source/test/workflow change was identified after the STREAM workflow commit.
- All work remains on the feature branch. Do not rely on the old addendum's 886/888-commit comparison; the live compare above supersedes it.

## Latest workflow reconciliation
- Isolated STREAM software workflow `46037445046`: SUCCESS on `5ef0c28bdbbb1e8b2b7219b5d37d24e0d6d8a942`; job `140636330408`; exact `tests/test_stream.py` result: **46 passed in 1183.29s**. Artifact `15220041192`, SHA-256 `b4f0d0ccc61f752d8a39eaaa37c40e51ef92913796058aa2ccbcab4abd58b872`.
- QHL targeted reset-qualified seed-1 workflow `46016087510`: SUCCESS; exact selection **1 passed in 81.93s** on tested commit `e123b331582495e12e7f32f81472011f0929c2cb`. Artifact `15205448777`. This closes only the exact seed-1 assertion/reset-qualification case.
- RTL subsystem/memory workflow `46016022758`: SUCCESS, all 14 jobs; QHL job **7 passed**. Do not extrapolate to all seeds/configurations.
- Reset/power-up structural audit `46016022824`: SUCCESS; four reset tests passed and the three named audited tops/configurations reported zero combinational SCCs and zero inferred latch cells. SRAM leaves are blackboxed; this is scoped structural evidence, not CDC/RDC or full physical signoff.
- Qwen real-checkpoint workflow `46016022711`: SUCCESS; Qwen3-0.6B and Qwen3.5-0.8B checkpoint integrity and the selected board RTL/model simulation cases passed. This is not physical FPGA or silicon performance, fine-tuning, or production throughput evidence.
- Board-functional evidence remains **198 passed, 8 skipped, 1 deselected** on tested commit `600f3aa4822e18f03ba80d06ab86fd447189c126`. Later board run `46016022808` was cancelled. Preserve the original exact tested SHA and exclusions; do not rerun the long suite solely to refresh evidence.
- Full-chip lint `46016022722`: workflow SUCCESS means lint completed under `-Wno-fatal`, not warning-free. Recorded diagnostics: 79 width warnings, 3 UNOPTFLAT (`gnt`, `sc_gl`, `pq`) and 7 LATCH diagnostics. ASIC-specific `aok` and AW/AR width findings remain separate.
- Software/ISA workflow `46016022887`: 14 jobs succeeded; STREAM did not run because Verilator installation failed on the Ubuntu 26.04 Microsoft package feed (HTTP 403). The isolated Ubuntu 24.04 STREAM workflow above subsequently passed the 46-test module.
- WG8 PPA workflow `45877786710`: terminal FAILURE, job `140109157212`, ORFS stage exited non-zero. Artifact `15152974135`, ZIP SHA-256 `bd93a2e68be7e2c3b782dba2e26824b67977a98867fd17cddceb1348c56a16f5`. The earlier resource diagnosis records host-memory exhaustion; no valid routed PPA report or signoff metrics exist. The workflow and logs were inspected; do not retry PPA, change resource settings to force another run, or claim area/timing/power closure without explicit authorisation.
- Current Actions list showed the above latest branch runs terminal; no active job was identified in this reconciliation.

## FSUM source and test disposition
- The synthesizable guard is already present in `rtl/seq/otpu_seq.sv`; no new patch is needed.
- It checks effective FSUM capability (including HAS_SS), permitted EXP2SUB/RSUM operations, producer rows 1..256, columns >=64, non-scalar B mode, and pending producer before RSUM take. Invalid commands halt/error before VPU dispatch; HALT with pending producers reports an error after the defined drain behaviour.
- Focused workflow `45915615614`, job `140233980040`: **11 passed, 219 deselected in 153.05s**. This is targeted evidence only. Do not rerun without a relevant source change.
- The earlier addendum proposal to implement this guard is superseded and closed as already implemented and verified.

## Remaining work — ordered, evidence-led
1. **Lint and structural closure:** resolve each current width warning by exact expression, signedness, range, parameter/configuration and synthesis relevance. Do not blanket-cast or suppress. Generate/inspect exact elaborated dependency evidence for `gnt` first; retain `sc_gl`, `pq` and ASIC `aok` as open until per-bit/process dependencies are proven. Reconcile the seven diagnostic LATCH warnings against the exact synthesis configuration and retain a synthesized-netlist latch-cell check.
2. **Formal/SVA:** expand beyond the existing global address-map formal test to bus, arbitration, DMA bounds/alignment/ordering, reset, memory-map, security/isolation and error handling. Archive assumptions, covers, proof logs and exact source/tool hashes.
3. **CDC/RDC:** complete clock/reset-domain inventory, synchronizer and async-FIFO review, reset recovery/removal and clock-gating analysis with appropriate tool reports.
4. **Memory and technology mapping:** choose real SRAM macros and supported libraries/PDK; prove inferred memory mapping, controller/PHY/training/ECC, refresh and physical topology. Nangate45 is research proxy evidence only.
5. **System interfaces:** production PCIe/SerDes, DMA/IOMMU, DDR controller/PHY, firmware/driver, boot/security and board interoperability remain unimplemented or unqualified.
6. **DFT and physical signoff:** scan/ATPG, MBIST/JTAG, routed placement/CTS/route, extracted STA, DRC/LVS/ERC, antenna, IR/EM, power and thermal evidence remain open.
7. **Commercial demonstrator:** keep Track A full product separate from Track B demonstrator. Select the demonstrator only against a defined customer workload, reproducible benchmark and available legal/tooling path. No sponsor, free fabrication, package/test, custody, delivery or shipping arrangement is confirmed.

## Hard constraints and release decision
- Zero spend: no paid runner/compute, PDK/IP licence, fabrication, packaging, hardware purchase or lab test without explicit approval.
- No PPA retry is authorised.
- Do not rerun previously passed groups merely for reassurance; preserve exact evidence and run only a demonstrably missing or source-affected scope.
- Do not modify protected project `main`.
- Do not claim physical silicon, production performance, routed signoff or manufacturer acceptance from simulation/proxy evidence.
- **Manufacturer handoff: NOT READY.** G0–G15 remain incomplete to varying degrees as recorded in the readiness matrix.

## Resume instruction
On the next chat, read this addendum, the current checkpoint, integrated plan, project tracker and manufacturer readiness matrix; re-resolve the live feature-branch HEAD and Actions state before any write or test. Continue with the first open evidence gate above, without repeating passed tests.
