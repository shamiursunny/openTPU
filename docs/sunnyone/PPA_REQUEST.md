# SUNNYONE WG8 PPA request marker

This file is an explicit push-trigger for the long WG8 OpenROAD-flow-scripts research run.

To request a new PPA run on the feature branch:
1. Confirm the intended RTL and target configuration are committed and the relevant functional/ASIC regressions are green.
2. Update the request line below with the exact candidate commit SHA and a short reason.
3. Commit this file update to the SUNNYONE feature branch.
4. Inspect the resulting GitHub Actions run and retain the full compact evidence artifact.

Current request: NONE

Do not use this marker for ordinary RTL progress commits. The PPA workflow is intentionally excluded from broad RTL path changes to avoid repeated multi-hour runs. 