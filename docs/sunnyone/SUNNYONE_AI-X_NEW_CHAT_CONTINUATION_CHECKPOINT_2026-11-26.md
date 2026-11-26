# SUNNYONE AI-X — New-chat continuation checkpoint

**Saved:** 2026-11-26, Asia/Dhaka  
**Purpose:** Resume in a new ChatGPT chat when the user says: “Continue and complete the remaining tasks.”

## Source of truth and protected state

- Repository: `shamiursunny/openTPU`
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`
- Latest verified code/workflow source revision for the active Qwen run: `bddf9708657766951e5c0d204ef474d742e53418`
- Protected `main`: `d84db55712aba0d40811d7762cb052f05d55b7e5`; keep it untouched.
- Branch comparison: active branch is 777 commits ahead and 0 behind main at the last comparison.
- Primary detailed record: `docs/sunnyone/PROJECT_TRACKER.md`
- Engineering baseline: `docs/sunnyone/SUNNYONE_AI-X_AUTHORITATIVE_CONTINUATION_BASELINE_A1.12.11.16.53.md`
- Also consult `docs/sunnyone/SUNNYONE_AI-X_PROJECT_RESUME.md` and `docs/sunnyone/SUNNYONE_AI-X_MANUFACTURER_HANDOFF_READINESS.md`.

## Hard exclusions

- Do NOT rerun historical RTL groups 3.1, 3.2 or 4 merely to reconfirm; their successful evidence is accepted.
- Do NOT rerun cancelled general RTL matrix workflow `45765362426`.
- Do NOT launch a broad RTL matrix or weaken/remove assertions/tests to make CI green.
- Work only on the active feature branch. Never modify protected `main`.
- Work serially and with low concurrency; inspect exact logs/artifacts before making claims.

## Newly verified results

1. Board-only workflow [45784404427](https://github.com/shamiursunny/openTPU/actions/runs/45784404427), job `139787424587`, tested source `74ee09d865633e8d8f8cc3edaaf5cb460bf576cc`: terminal SUCCESS. Exact result: **198 passed, 8 skipped, 1 deselected** in 4158.05 seconds. All eight skips require PyTorch; the deselected test was `test_axil_iso_resets_apart`. Artifact `sunnyone-board-functional-only-log`, ID `15104009648`, SHA-256 `fd8901eefabd4f990826abe072ca0f505f92919c1f8a9b4c59fda0915089a00a`.
2. Isolated AXI-Lite independent-reset workflow [45806586835](https://github.com/shamiursunny/openTPU/actions/runs/45806586835), job `139863351015`, source `9af352cb36ad5599fd839cf12c8798ff8000ba92`: terminal SUCCESS, **1 passed, 206 deselected** in 17.32 seconds. This closes the one deliberately deselected board test without rerunning the board suite.
3. Board-only simulation is not physical-board validation. The eight PyTorch-dependent tiny-model cases remain unclosed until their dedicated selection passes.

## Active Qwen verification gate — poll first

- Dedicated workflow: `.github/workflows/sunnyone-qwen-real-rtl.yml`
- Current run: [45808551468](https://github.com/shamiursunny/openTPU/actions/runs/45808551468)
- Job: `139870207686`
- Source revision: `bddf9708657766951e5c0d204ef474d742e53418`
- At last poll: checkout and Python setup passed; pinned Verilator 5.044 build was IN_PROGRESS; dependency install, official checkpoint downloads/verification, real Qwen3/Qwen3.5 RTL tests and the separate eight tiny board-model tests were still pending.
- Workflow pins CPU-only PyTorch 2.11.0, safetensors 0.8.0, huggingface_hub 2.3.0 and Transformers 5.24.1. It downloads pinned Qwen3-0.6B and Qwen3.5-0.8B Apache-2.0 checkpoints and runs only the named Qwen RTL and tiny-model selections.
- No terminal result was available at this checkpoint. Poll run 45808551468, inspect job steps and full uploaded artifact/log, and record the exact pytest summaries. Do not count the real-checkpoint tests as passed unless their own step passes; do not count the eight tiny board tests as passed unless their separate step passes.
- Earlier Qwen run 45807130675 failed at the extra-cache-file verification check (a verifier invocation issue, not missing checkpoint/RTL evidence). Runs 45808346935 and 45808406729 were superseded/cancelled. Current run 45808551468 is the relevant retry.

## Other validated evidence and blockers

- Historical exact-SHA workflows recorded in PROJECT_TRACKER: ASIC/target configuration and four-DIMM WG8 AXI top tests, standalone HMUX, full-chip lint, 32-GiB address-map formal proof, RTL subsystem matrix and PCIe Gen2 XDMA-facing AXI bridge simulation passed within their stated scopes. They do not establish full-chip formal, production PCIe, DDR electrical or physical signoff.
- WG8 Nangate45 research PPA run 45545698546 failed at ORFS floorplan PDN/check_placement. Artifact evidence showed pre-route core-clock WNS -10.43 ns, TNS -91.46 ns, minimum period 12.93 ns (77.31 MHz) against a 400 MHz / 2.5 ns target. This is a research proxy, not signoff. Do not claim 400 MHz. A two-CPU resource guard was prepared; diagnose the failure and timing shortfall before any retry. Do not suppress PDN/placement checks.
- Manufacturer handoff remains **NOT READY**.

## Remaining work, in priority order

1. Finish/poll Qwen run 45808551468 and inspect all logs/artifacts. Resolve any genuine dependency, checkpoint, RTL or model-test failures with narrow fixes and rerun only the relevant scoped gate.
2. Close any remaining skipped test coverage deliberately; preserve exact selectors and results.
3. Continue adversarial four-DIMM shared-DIMM verification beyond the existing bounded contention tests: dual-master traffic, AW/W ownership, B/AR/R routing and IDs, byte strobes, backpressure/fairness, 4-KiB boundaries, address translation/aperture, reset with outstanding transactions, errors/calibration loss and scoreboard checks.
4. Expand formal properties for AXI/arbitration/owner FIFO/response routing/address bounds/control transitions/no loss or duplication/fail-closed errors.
5. Complete CDC/RDC and reset-domain analysis; full-chip lint and target/configuration checks as needed, without duplicating already passed gates.
6. Diagnose and improve WG8 timing/PPA; establish reproducible exact-RTL synthesis, placement, CTS, routing, extracted timing and realistic SRAM/controller assumptions. No timing closure claim until measured.
7. Implement or integrate legally usable production PCIe endpoint/PHY, DMA, global address mapping, bounds/IOMMU/aperture protection, interrupts and host driver; validate end-to-end.
8. Implement/integrate DDR controller, PHY, calibration, refresh, training and ECC datapath; validate digital protocol separately from electrical DDR.
9. Complete DFT/scan/BIST, SRAM test/repair strategy, foundry PDK/macro qualification, physical signoff (DRC/LVS, IR/EM, SI/PI, thermal/package) and board/silicon qualification.
10. Measure real workload quality, throughput, latency, power, thermal behaviour, tokens/J and cost per useful inference; complete evidence-backed demand, TCO, unit economics and manufacturer qualification.

## Mandatory next-chat procedure

1. Read this checkpoint, then the primary PROJECT_TRACKER, authoritative baseline, project resume and manufacturer handoff-readiness document.
2. Verify the active branch and protected main again; poll Qwen workflow 45808551468 before launching anything else.
3. Update the tracker and relevant continuity documents with terminal evidence. Keep historical records; append corrections rather than rewriting history.
4. Proceed through the remaining tasks in narrow, evidence-backed stages. Do not claim production, tapeout, silicon, physical or commercial readiness while the listed blockers remain.

**Current status:** board-only suite and isolated AXI-Lite reset test passed; Qwen real-checkpoint plus eight tiny-model tests are pending in an active workflow; major integration, formal/CDC/RDC, PPA/physical, production interface/memory, DFT and commercial gates remain open. Manufacturer handoff: **NOT READY**.
