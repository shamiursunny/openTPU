# WG8 PPA resource diagnosis — 2026-11-27

## Scope and provenance

- Repository: shamiursunny/openTPU
- Branch: sunnyone/commercial-profitability-architecture-2026-11-23
- Workflow: 45877786710 (SUNNYONE WG8 ASIC research PPA)
- Source SHA: 28c36c52204fe2ec2ed36413b02eb6043506ccc4
- Job ID: 140109157212
- Job conclusion: FAILURE
- Artifact: 15152974135
- Artifact ZIP SHA-256: bd93a2e68be7e2c3b782dba2e26824b67977a98867fd17cddceb1348c56a16f5
- ORFS manifest: sha256:f5b2b4ac8cae150c30ad86857328300e20662cf7ff555978711ea8936f8d9539
- Resolved image ID: sha256:edbd355068b742c5ae2413a49a58578465bd52f57668cebebdd383eb4d97607d

The artifact ZIP was downloaded and inspected, including the OpenROAD stage logs, ORFS run tail, host baseline and cgroup telemetry.

## Confirmed execution path

1. Immutable ORFS manifest pull and local image-ID verification succeeded.
2. Docker was invoked with --cpus 2.
3. OpenROAD reported two threads.
4. Synthesis completed and produced 4,082,641 instances in the floorplan design.
5. Initial floorplan completed.
6. Macro placement completed.
7. Tap-cell insertion completed.
8. The flow reached 2_4_floorplan_pdn and then failed during check_placement / PDN processing.
9. ORFS reported Error 247; Make reported exit 2.

## Memory evidence

- Host /proc/meminfo MemTotal: 16,366,484 kB.
- Container cgroup memory.max: max (no cgroup memory cap exposed).
- Container cgroup memory.peak: 16,155,115,520 bytes (about 15.04 GiB).
- OpenROAD 2_1_floorplan peak memory: 15,535,996 kB.
- OpenROAD 2_2_floorplan_macro peak memory: 14,883,412 kB.
- Final cgroup memory.events: oom 0; oom_kill 1; oom_group_kill 0; max 0.
- The sampled memory.current rose to approximately 16.02 GB immediately before termination and dropped to about 44.6 MB at the sample after termination.

## Interpretation

An OOM kill was recorded by the job's cgroup. Because memory.max was unlimited and the measured peak approached the runner's approximately 16.37 GB physical memory, host-level memory exhaustion is the most likely explanation for the process termination. The evidence does not identify the kernel's exact victim-selection record or prove every OS-level detail; describe this as a confirmed OOM-kill event and a strongly supported host-memory-exhaustion diagnosis, not as an independently inspected kernel log.

The ORFS Error 247 is therefore no longer an unexplained generic failure. The exact OOM-killed process is not named in the archived evidence. Do not claim the flow reached placement/routing or achieved physical timing closure.

## PPA and timing limits

The 2_1_floorplan JSON reports setup WNS 0.457299 ns, TNS 0, and fmax 489.548 MHz. These are early floorplan / wire-load estimates, not routed timing or signoff. The design area at floorplan was approximately 30.48 million square micrometres including the research-flow macro models; it is not a validated die-area or manufacturable-area result.

## Decision and next steps

- Do not repeat the same full-chip PPA job on an equivalent 16 GB runner.
- Do not dispatch another PPA job automatically.
- Before any new run, determine whether a larger-memory runner is available at zero cost, or define a technically valid staged/partitioned diagnostic that does not misrepresent full-chip signoff.
- Keep all runner, cloud, tool and hardware spending at zero unless the user explicitly approves.
- Preserve this failed run and artifact as valid resource-limit evidence.
- Manufacturer handoff remains NOT READY.
