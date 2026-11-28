# SUNNYONE continuation addendum — 2026-11-28 15:14 Asia/Dhaka

## Repository state and controls
- Repository: `shamiursunny/openTPU`.
- Active branch: `sunnyone/commercial-profitability-architecture-2026-11-23`.
- Live branch HEAD before this documentation save: `949896622631cc8993733fdc41f82620ce770ed9`.
- Live compare: 1,173 commits ahead, 0 behind; merge base/main SHA `d84db55712aba0d40811d7762cb052f05d55b7e5`.
- GitHub reports `main.protected=false`; this is an administrative protection gap, not permission to modify main. No main write, merge or rebase.
- Zero spend. No PPA retry, paid compute, hardware purchase, fabrication, packaging or lab testing without explicit approval.
- Do not rerun successful historical RTL groups 3.1, 3.2 or 4 solely for reassurance; never restart cancelled run `45765362426`.

## Newly closed W1/W2/W3 fixture verification
- Previously missing push-triggered run located through the repository Actions API: workflow `46090474983`, job `140809944012`, terminal SUCCESS.
- Exact tested commit: `28704f25f87179e5653188bf0cc40f43ee681168`.
- Actual job log confirms **37 tests passed in 0.557 seconds**; the selected test names include:
  - `test_w1_single_request_is_valid_and_deterministic`
  - `test_w2_mixed_concurrency_has_staggered_arrivals_and_multiple_tenants`
  - `test_w3_burst_exercises_queue_pressure_and_control_events`
- The same run also re-executed the narrow `tests/test_sunnyone_*.py` harness: endpoint, resource-event model, retrieval metrics and workload-trace tests. It did not run RTL or hardware tests.
- This closes the W1/W2/W3 fixture schema/order/determinism tests only. It does not execute the fixtures against RTL or establish scheduler fairness, calibrated service times, chip throughput, power, energy, thermal behaviour or cost.
- The earlier resource-model validation remains separately recorded: run `46081103514`, job `140780031472`, 34 tests passed on exact source `0ab52a61659a4746eb3375d7e5f146f3fbf192ae`. The latest 37-test run is the exact verification for the fixture test commit.

## Live workflow reconciliation
- Latest feature-branch Actions listing was polled. W1/W2/W3 run `46090474983` is terminal SUCCESS; prior workload harness run `46081103514` SUCCESS; VPU `46053471843` SUCCESS; software-core `46053311585` SUCCESS; board, subsystem, Qwen, reset, ASIC configuration, RTL-tail and lint runs listed at their exact historical source SHAs are terminal as previously recorded.
- No new RTL, PPA or broad regression was launched in this continuation.
- Preserve each result's exact tested SHA and selection. The results are not certification of the current branch HEAD.

## MXU bounds guard — current engineering disposition
- Re-read the current branch versions of `rtl/seq/otpu_seq.sv`, `rtl/top/otpu_slice.sv`, `rtl/mxu/otpu_mxu.sv` and primary `docs/isa.md`.
- The source still confirms that sequencer `fsum_bad` is the synthesizable pre-dispatch rejection pattern; sequencer receives WG but not MCOLS/ACT_ROWS, while the slice passes those exact elaborated values to the MXU.
- The MXU's MM legality assertions remain under `ifndef SYNTHESIS`; they are diagnostics, not a hardware guard. The RMAX path indexes `mx_key[MW'(32'(mx_i) + 32'(k))]` when `mxm[k]` is asserted. Enforce the command's legal M shape before dispatch; do not narrow/cast the index or suppress the warning as a substitute for a proof.
- Primary ISA rules reconfirmed: N>=1, KB>=1, 0<M<=ACT_ROWS; RMAX/ASCALE/PAIR require M<=MCOLS; PAIR additionally requires 2*M<=MCOLS, 4-bit WF and WG=1; ASCALE requires UNIT+ACC; RSC is not legal with NVFP4; WG>1 uses grouped MM with LG matching WG (int8) or 2*WG (4-bit), and PAIR is not used with groups.
- No RTL/test/workflow patch was made. Before implementation, inspect all sequencer instantiations and workflow path filters so the focused raw-command tests do not cause unnecessary broad reruns. The next patch must pass MCOLS/ACT_ROWS from the slice, reject malformed raw MM commands before dispatch, and prove no MXU start/TMEM write/DRAM stream side effect for rejected commands. Keep legal ISA workloads unchanged.
- W1/W2/W3 remain synthetic input fixtures; no RTL/TMEM correlation adapter or calibrated hardware profile is yet available. The next trace tool must report interval-level matches, unmatched/lost records and ambiguity; do not claim per-request attribution from timestamps alone.

## Release status
Manufacturer handoff remains **NOT READY**. Formal/SVA, CDC/RDC, DFT, complete semantic width-warning closure, SRAM/DDR mapping, production PCIe/SerDes/DMA/IOMMU and memory interfaces, routed physical signoff, measured power/thermal/economic evidence, demonstrator down-select and zero-cost sponsor/sample/packaging/test/shipping commitments remain open or partial as recorded in the readiness matrix.
