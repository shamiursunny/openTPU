# SUNNYONE WG8 PPA request marker

This file is an explicit push-trigger for the long WG8 OpenROAD-flow-scripts research run.

To request a new PPA run on the feature branch:
1. Confirm the intended RTL and target configuration are committed and the relevant functional/ASIC regressions are green.
2. Update the request line below with the exact candidate commit SHA and a short reason.
3. Commit this file update to the SUNNYONE feature branch.
4. Inspect the resulting GitHub Actions run and retain the full compact evidence artifact.

Current request: NONE

Do not use this marker for ordinary RTL progress commits. The PPA workflow is intentionally excluded from broad RTL path changes to avoid repeated multi-hour runs. 

## PPA execution safety update — 2026-11-27

The WG8 PPA workflow now runs on push only when `docs/sunnyone/PPA_REQUEST.md` is explicitly changed. Normal RTL, target and flow commits do not trigger a full-chip PPA automatically. The workflow_dispatch entry remains available for a deliberate run after resource eligibility, zero-spend constraints and the exact source SHA are reviewed. This control was added after the documented 16 GB host-memory OOM-kill evidence. No PPA run was dispatched as part of the FSUM guard work.
