# SUNNYONE — Current Continuation Checkpoint
Last updated: 2026-11-27 (Asia/Dhaka)

## Start here in every new chat

Read this file first, then:
1. docs/sunnyone/INTEGRATED_ENGINEERING_AND_SPONSORED_SILICON_PLAN_2026-11-27.md
2. docs/sunnyone/PROJECT_TRACKER.md
3. docs/sunnyone/MANUFACTURER_HANDOFF_READINESS_MATRIX.md

Then verify live branch HEAD, main SHA/protection metadata and current workflow states before acting.

**User continuation command:** “Continue and complete the remaining tasks.”

## Repository and branch controls

- Repository: shamiursunny/openTPU
- Active branch: sunnyone/commercial-profitability-architecture-2026-11-23
- Branch HEAD at start of this continuation: ee5eafecd38e82d99c62cd83f5f981230d522171
- Main SHA at start: d84db55712aba0d40811d7762cb052f05d55b7e5 — never modify.
- Plan document commit: 86162c5113da62ad3069d6ef8eff1233390d27f5
- Main branch protection was previously observed by GitHub API as disabled; this is a control gap, not permission to touch main. Recheck metadata when possible.
- Zero-spend default. No paid services, hardware, foundry, IP licence, cloud runner or packaging/test expenditure without explicit user approval.
- User cancelled Actions run 45765362426; never restart it.
- RTL groups 3.1, 3.2 and 4 already passed historically; do not rerun solely to reconfirm.

## New governing plan

docs/sunnyone/INTEGRATED_ENGINEERING_AND_SPONSORED_SILICON_PLAN_2026-11-27.md

This is now the governing integrated engineering/manufacturing strategy. It preserves two linked tracks:
- Track A: the full programmable SUNNYONE inference-accelerator product architecture.
- Track B: a separate, small first-silicon demonstrator derived from proven existing RTL only after source, PDK, area, timing, testability and sponsorship feasibility review.

Do not silently shrink or replace Track A to fit an MPW shuttle. The first demonstrator is not the complete product and cannot be used to claim full-product silicon validation.

The current architecture baseline remains:
- host-server control plane (no on-chip CPU/boot ROM in current first-version baseline);
- tiled matrix engine;
- vector/SIMD datapath;
- local SRAM scratchpads and DMA;
- defined host/compute/memory interconnect;
- external ECC-capable memory path, with production controller/PHY/training still open;
- programmable runtime/kernel layer.

The Versal VC1802/VSVD1760 is a separate feasibility lead, not the IHP ASIC target or selected production part. 128 GB ECC DDR4 remains a hypothesis; 256 GB remains stretch-only. User retired the former 30 W hard ceiling; derive power from measured performance and economics.

## Verification results independently re-polled 2026-11-27

All listed workflow jobs are terminal. Actual job logs were inspected for selected summaries. No new CI run was launched.

### Subsystem/memory — workflow 45845758545 SUCCESS

All 14 jobs terminal SUCCESS; actual totals:
- MX multiply/replay: 17 passed
- Quantizer corners/tie rounding: 8 passed
- Quantizer modes: 15 passed
- Collective hub/DMA/scoreboard: 128 passed
- QST/QSTB: 13 passed
- SPLITQ: 5 passed
- Instruction cache: 23 passed
- Address-window: 20 passed, 1 documented skip
- FP RTL: 8 passed
- QHL: 7 passed
- Stream RTL: 14 passed
- Wait-state RTL: 11 passed
- Reset audit: 4 passed
- Native DRAM/technology RAM: 104 passed
Combined selected-job total: 377 passed, 1 documented skip.

### Software/ISA/host — workflow 45845758659 SUCCESS

All 15 jobs terminal SUCCESS; actual pytest totals: 825 passed, 3 skipped:
FP 12; MX 32; compiler 44; ISA 18; kernels 46; VOPS 101; waits 268 passed/2 skipped; stream 46; formats 13; quant 81; dataflow 27; WAITW 6; host 108 passed/1 skipped; host-runs 18; host-lock 5.

### Board / RTL tail / ASIC / Qwen

- Board-functional workflow 45845758677 SUCCESS: 198 passed, 8 skipped, 1 deselected. Artifact 15137400985; SHA-256 d0adc900e0ef37ecec1f2715a555e0e822306a79b01bb562b1bbfa23d4f8f9d8.
- RTL-tail workflow 45845758636 SUCCESS: 33 passed, 1 intentional skip, 183 deselected. Artifact 15132004314.
- ASIC/four-DIMM workflow 45845758681 SUCCESS. Logs show four-DIMM host/accelerator AW/AR contention, arbitration, W ordering, B/R ID routing, backpressure, 1/2/4/8-beat reads/writes, partial/zero strobes, response codes, 4-KiB boundaries, out-of-aperture rejection and global address-map checks passing. Artifact 15130743611; SHA-256 dc0a587493b7b9ca44355fbeb312798b3ef853e2f39e4fecb4ef35c345251863.
- Qwen workflow 45845758847 SUCCESS. Official Qwen3-0.6B/Qwen3.5-0.8B checkpoints and checksums verified; real-checkpoint RTL tests 6 passed/4 deselected; tiny board-model tests 8 passed/199 deselected. Artifact 15136893309; SHA-256 223804db48d7010633764082a0814e4237a36055aab652f22d5c2f4d069ac7d2.

### Lint — workflow 45845758782 SUCCESS, warnings remain

Verilator 5.032 full-chip lint completed. Open warnings:
- 52 WIDTHEXPAND
- 27 WIDTHTRUNC
- 7 LATCH
- 3 UNOPTFLAT

LATCH warnings are in conditional local temporaries in rtl/seq/otpu_seq.sv; actual latch-cell presence/absence not proven. UNOPTFLAT paths involve gnt, sc_gl and pq. Separate ASIC compile reported an additional aok combinational-cycle warning in rtl/top/otpu_slice.sv around line 906. No blanket warning suppressions. Artifact 15130078429; SHA-256 6a1f1639094cfe3d8c800d4f9bd923375fa4dc613b0cb6c1e4f5c9244c6b8d75.

### PPA — workflow 45845758658 FAILURE

Pinned ORFS image sha256:edbd355068b742c5ae2413a49a58578465bd52f57668cebebdd383eb4d97607d. Synthesis and preliminary floorplan timing reporting completed; OpenROAD exited code 247 during 2_1_floorplan. Peak RSS 15,191,368 KB. Root cause is not confirmed; do not assert OOM. Artifact 15137952036; SHA-256 66d8e83e4f5da5ee5b11be80e851ecfe04f6b801857ef9ee3d786246af47f560.

Pre-route wire-load report: WNS 0.00 ns, TNS 0.00 ns, worst slack +0.46 ns, minimum period 2.04 ns / 489.55 MHz. Not routed STA/signoff. Synthesis proxy area 30,786,988.162 µm², not die area. Earlier baseline 45545698546 had WNS -10.43 ns, TNS -91.46 ns, 12.93 ns / 77.31 MHz and also failed later in physical flow. No timing closure or single-change attribution claim.

### DMA experiment and prior exclusions

Source SHA 2835f1a8da6af454023caff9576f41258c66e2a8 contains six SRX stream-setup constant-divisor rewrites. Exhaustive mathematical checks covered su_ns 0–63, both selector states and SPC 1,2,4,8,16,32. Not formal RTL equivalence; timing improvement not established.

Preserve historical successful groups 3.1, 3.2 and 4. Do not restart user-cancelled run 45765362426.

## PPA workflow instrumentation

Workflow .github/workflows/sunnyone-asic-wg8-ppa.yml was changed in commit 783dc91d835b66279fc69ca0dd82ee3a9c403785 (blob 9d6025838eb01dc7ae93d7f7671e7b5be066ec33):
- Docker CPU quota explicitly set with --cpus 2 plus ORFS_CPUS=2.
- Host resource baseline and periodic cgroup v1/v2 memory telemetry added.
- Telemetry archived with PPA artifact.

This is instrumentation only; no diagnostic PPA rerun has been launched. Review syntax and artifact/cleanup behaviour first, then dispatch only if justified.

## Manufacturer/sponsorship strategy — important correction

IHP remains the first technical organisation to approach for a **written fully sponsored research collaboration**, but free fabrication is NOT confirmed:
- Historical FMD-QNC free MPW documentation lists runs through September 2025 and says continuation for open-source community was to be worked out.
- Published 2026 IHP SG13G2 (29 Sep, registration 21 Sep) and SG13CMOS5L (9 Nov, registration 26 Oct) dates are past.
- Current IHP low-cost route lists approx. EUR 2,800/mm² SG13G2 and EUR 1,500/mm² SG13CMOS5L; 20 bare dies basic offer; packaging extra; approx. 8/6 months processing. Not authorised under zero-spend rule.
- IHP open SG13G2 PDK is Early Access/alpha; SG13CMOS5L is preview; neither is represented as production-ready.
- A university/research institute may be the eligible sponsor/lead applicant, but no affiliation or eligibility is assumed.

A zero-cost agreement must explicitly cover MPW area/fabrication, dicing, packaging, board/fixture, physical testing, report/data, sample custody/delivery to Bangladesh, shipping/customs/taxes and all other fees. Historical IHP documentation described samples being retained for joint evaluation/rental, so physical sample access and shipping are mandatory questions. Do not assume free fabrication includes packaging/testing/shipping.

No private RTL/GDS or confidential data should be shared before licence, publication, IP and export-control terms are understood.

## Immediate next actions

1. Update PROJECT_TRACKER.md with this plan and evidence re-poll.
2. Re-fetch this checkpoint, plan, tracker and readiness matrix; record exact blob SHAs and final branch HEAD.
3. Review PPA workflow syntax and artifact/cleanup behaviour; no retry until justified.
4. Prove actual latch-cell presence/absence and trace full-chip/ASIC UNOPTFLAT paths.
5. Triage all 79 width warnings, including the ASIC AW/AR 34-bit to 33-bit port connection warnings.
6. Expand formal/SVA and CDC/RDC evidence.
7. Inventory existing RTL and down-select a compact first-silicon demonstrator without changing Track A.
8. Verify IHP PDK compatibility and ask IHP/university partners about eligibility, next intake, full sponsorship, physical test, sample access and shipping.
9. Only create a dedicated demonstrator integration/port after source, PDK, area, timing, test and sponsor feasibility gates.
10. Continue the full product architecture and manufacturer G0–G15 readiness gates.

Manufacturer handoff remains **NOT READY**. No RTL was changed and no tests were rerun in this continuation. All results above are bounded historical evidence on their recorded source/configuration and do not establish formal/CDC closure, routed physical signoff, production interfaces, measured silicon performance or qualification.


## Documentation save confirmation — 2026-11-27

- Integrated plan file was created in commit 86162c5113da62ad3069d6ef8eff1233390d27f5.
- This checkpoint file was created in commit 20520d921edc8c3b1e46426ba7b674f70322695e.
- PROJECT_TRACKER.md section 104 was appended in commit ea61fc2c16ae3d77df65927d846bc8b0ce51450c.
- Latest tracker blob after section 104: e567d08e2e350d937a56d7e87018b14960f56552.
- The final checkpoint/tracker/plan blobs and live branch HEAD must be re-fetched after this save and recorded in the next continuation entry.
