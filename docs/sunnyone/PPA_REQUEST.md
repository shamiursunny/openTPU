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

This original trigger description was incorrect and is superseded by the Trigger semantics correction below. Editing `PPA_REQUEST.md` does not trigger PPA. The actual push trigger is `docs/sunnyone/PPA_EXECUTE_REQUEST.md` together with `[RUN-PPA]` in the commit message. `workflow_dispatch` remains a separate explicit user action.


## Trigger semantics correction — 2026-11-27

This file is documentation only and is not a PPA execution trigger. The WG8 workflow now watches the dedicated `docs/sunnyone/PPA_EXECUTE_REQUEST.md` marker and requires `[RUN-PPA]` in the push commit message. Editing this file, ordinary project documentation, RTL or flow files must not run PPA. Manual workflow dispatch remains an explicit user action requiring approval of the exact source SHA. See `docs/sunnyone/PPA_TRIGGER_INCIDENT_2026-11-27.md` for the accidental trigger and cancellation record.
