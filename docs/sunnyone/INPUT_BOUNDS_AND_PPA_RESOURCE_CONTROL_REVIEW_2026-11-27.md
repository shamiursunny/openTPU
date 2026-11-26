# SUNNYONE — Input Bounds and PPA Resource-Control Review

**Date:** 2026-11-27 (Asia/Dhaka)  
**Repository:** `shamiursunny/openTPU`  
**Branch:** `sunnyone/commercial-profitability-architecture-2026-11-23`  
**Review status:** Findings documented; no RTL or workflow source changes made.

## 1. FSUM row-buffer safety

The VPU's row-sum buffer has 256 entries distributed across the lanes. Its read and write indices are derived from row counters. The ordinary RDOT path has a synthesizable hardware qualification: buffering is selected only when the operation is RDOT, row count is no greater than 256, and row stride is one. Otherwise the result is written directly.

FSUM is different. The check rejecting more than 256 rows is located in a `ifndef SYNTHESIS` block. The actual FSUM backend still buffers row sums while `fs_b` is asserted. Consequently, a malformed FSUM instruction with a row count above the software contract could index beyond the declared row buffer in hardware. This is a concrete bounds-protection gap for configurations that enable FSUM; it is not proof that valid compiler-generated programs currently trigger an overflow.

### Configuration and software evidence

- FSUM is enabled in `targets/bcu1525-wg.toml` and `targets/bcu1525-x2.toml`.
- Other current target files omit FSUM; `opentpu/target.py` defaults it to false.
- `opentpu/isa.py` defines `FSUM_MAX_ROWS = 256`.
- `opentpu/isasim.py::_fsum_check`, `opentpu/compiler.py::fuse_exp2_rowsum`, and `opentpu/isa.py::exp2sub_sum` enforce the software-side row/column contract.
- The synthesizable RTL does not currently demonstrate equivalent rejection of an invalid FSUM row count.

### Required closure

1. Trace the command-ingress and invalid-instruction error/halt protocol.
2. Decide whether hardware must reject malformed FSUM commands (recommended for a robust RTL contract) or whether a separately enforced ingress validator is part of the trusted system boundary.
3. If adding a hardware guard, preserve legal FSUM timing and use the established error/halt mechanism; do not silently clamp the row count.
4. Add targeted RTL tests for 256 legal rows and 257 rejected rows on an FSUM-enabled configuration, plus existing FSUM functional tests.
5. Re-run only the focused tests and required regression selection on the resulting immutable SHA.

**Status: OPEN.** No RTL fix is authorised by this review alone.

## 2. PPA CPU-count propagation

The active PPA workflow uses Docker `--cpus 2` and sets `ORFS_CPUS=2`, then invokes the Python flow runner. At the exact PPA source SHA `28c36c52204fe2ec2ed36413b02eb6043506ccc4`, `tools/asic/flow.py` selects its ORFS worker count from `os.cpu_count()` when `ORFS_HOME` is available and passes that value as `NUM_CORES`. It never reads `ORFS_CPUS`.

Docker still limits actual CPU time to two CPUs, but ORFS may be configured with more workers than the quota. This can cause scheduling oversubscription. It is a reproducibility/resource-control defect, not a proven cause of the earlier OpenROAD exit code 247.

**Required correction after the current PPA run terminates:** consume and validate `ORFS_CPUS` in `flow.py` or pass an explicit `cpus` argument, add a focused test, and confirm the emitted `NUM_CORES` value. Do not modify the source while run 45877786710 is active because the PPA workflow has cancel-in-progress concurrency.

## 3. Live run status

| Run | Scope | Status at review |
|---|---|---|
| 45877786710 | WG8 PPA diagnostic | IN_PROGRESS |
| 45877786754 | Qwen3/Qwen3.5 real-checkpoint RTL | IN_PROGRESS |
| 45877786742 | Board-functional | IN_PROGRESS |
| 45877786699 | Subsystem/memory matrix | Partially complete; jobs queued/in progress |
| 45877786705 | Software/ISA matrix | Partially complete; jobs queued/in progress |
| 45877786738 | Reset/power-up audit | SUCCESS |
| 45877786860 | ASIC/target configuration | SUCCESS |
| 45877807906 | RTL tail | SUCCESS |
| 45877807985 | Isolated 128K one-copy TMEM | SUCCESS |
| 45877985241 | LOOP stack boundary tests | SUCCESS; 2 passed, 217 deselected |

The in-progress jobs must be allowed to reach terminal states or be reconciled through their actual GitHub status. Do not infer success from a workflow's existence or stale job timestamps. Do not restart cancelled runs or launch duplicate matrices.

## 4. Controls

- Keep the working branch separate from `main`; do not modify `main`.
- Preserve the zero-spend rule.
- Do not rerun historical RTL groups 3.1, 3.2 or 4 solely to reconfirm them.
- Do not restart user-cancelled run 45765362426.
- Do not weaken tests, hide failures, or claim full-chip/manufacturer readiness.
- Manufacturer handoff remains **NOT READY**.
