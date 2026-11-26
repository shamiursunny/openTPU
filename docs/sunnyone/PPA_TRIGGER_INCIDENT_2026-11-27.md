# WG8 PPA trigger incident and containment — 2026-11-27

## Incident summary

An ordinary documentation update modified `docs/sunnyone/PPA_REQUEST.md`. At that moment the WG8 workflow's push path filter watched that file, so GitHub incorrectly treated the documentation-only commit as a PPA request.

- Accidental run: 45911873124
- Triggering documentation commit: 8fae330fe34342c79b5c3dac60221d660983e4c2
- Corrective workflow commit: 98335138bd73751699afc4a31ce0b206ff2720a1
- Corrective skipped run: 45911965872
- Accidental run final conclusion: CANCELLED
- Cancellation observed: 2026-11-26T23:37:04Z

## What actually ran

The cancelled run:
- Pulled the previously pinned ORFS image.
- Ran `flow.py prep`: 288 SRAM macro instances across 14 configurations, 3,538 KiB aggregate SRAM.
- Ran flow configuration.
- Entered Yosys `1_1_yosys_canonicalize` synthesis.
- Was cancelled before any recorded floorplan, macro placement, CTS, PDN or physical PPA result.

The retained artifact is 15159964408; ZIP SHA-256:
`a5a1bea55d30b1b0e5721f2eae33049bd0003a1504c7925f84aa5e676c05ccf3`.

Artifact evidence:
- No floorplan, placement, CTS or PDN logs/reports were present.
- No PPA `report.json` was produced.
- cgroup memory.max was unlimited.
- cgroup memory.peak was 894,529,536 bytes.
- cgroup memory.events: oom=0, oom_kill=0, oom_group_kill=0, max=0.
- Host MemTotal was 16,078,424 kB.

Therefore this was a partial synthesis preparation/canonicalisation attempt, not a completed PPA run and not a new OOM event. It did consume approximately 73 seconds of GitHub-hosted runner time. Exact billing/quota treatment is not visible from the available evidence; repository Actions usage should be checked if the account needs an exact cost determination. No hardware or third-party cloud resource was purchased.

## Corrective control

Commit 98335138bd73751699afc4a31ce0b206ff2720a1 changed `.github/workflows/sunnyone-asic-wg8-ppa.yml`:
- Push paths are now only `docs/sunnyone/PPA_EXECUTE_REQUEST.md` and the workflow file itself.
- A push-triggered job runs only if the commit message contains `[RUN-PPA]`.
- A workflow-file-only safety correction starts a superseding workflow run, allowing concurrency cancellation of an accidental in-progress run; the correction job is skipped by the approval condition.
- `workflow_dispatch` remains available for deliberate manual invocation.

The workflow-file correction generated run 45911965872, which completed SKIPPED and cancelled run 45911873124. This cancellation is confirmed by GitHub's run status and job log.

## Operational rule

- `PPA_REQUEST.md` is documentation only; editing it never requests PPA.
- A push PPA request requires a dedicated `PPA_EXECUTE_REQUEST.md` file and a commit message containing `[RUN-PPA]`.
- A manual dispatch is an explicit action and must still be separately approved by the user.
- Do not create or modify the execution marker unless the user has expressly approved a specific source SHA and run.
- No further PPA run is authorised by this incident report.

## Accountability

The trigger was activated by an assistant-authored documentation change. The correction is committed and the accidental run was cancelled before physical implementation. Keep this incident visible in the project record; do not describe the continuation as having used absolutely zero GitHub runner resources.
