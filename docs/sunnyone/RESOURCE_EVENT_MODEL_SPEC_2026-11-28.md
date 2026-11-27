# SUNNYONE deterministic resource event model — specification and evidence

Status date: 2026-11-28  
Repository: `shamiursunny/openTPU`  
Working branch: `sunnyone/commercial-profitability-architecture-2026-11-23`

## 1. Purpose and evidence boundary

`tools/sunnyone/resource_event_model.py` consumes the deterministic request trace emitted by `tools/sunnyone/workload_trace.py` and schedules abstract stage work on finite-capacity resources.

It is a deterministic, profile-driven queueing model. It is **not** an RTL simulator, cycle-accurate hardware model, silicon benchmark, PPA tool, or power/thermal estimator. It must not be used to claim product throughput or energy efficiency until its stage profiles have been calibrated against suitable RTL evidence and then independently validated.

No default hardware latency, bandwidth, engine count, clock, energy coefficient or thermal parameter is supplied. The model rejects missing or invalid service profiles instead of silently inventing values.

## 2. Profile contract

A service profile is a JSON object with exactly these top-level fields:

- `profile_id`, `version`: immutable profile identity.
- `origin`: one of `synthetic_fixture`, `rtl_trace_calibrated`, `measured_system`.
- `provenance`: a non-empty evidence description. For calibrated/measured profiles this must identify the source commit, trace/artifact hash, configuration, tool version and extraction procedure.
- `tick_unit`: must exactly match the workload trace header.
- `resources`: resource name to positive integer concurrency capacity.
- `prefill`, `decode`: non-empty ordered lists of stages. Each stage contains exactly `name`, `resource`, and positive integer `service_ticks_per_unit`. Each referenced resource must exist.

Example structure (illustrative schema only; values are not SUNNYONE hardware parameters):

```json
{
  "profile_id": "example-profile",
  "version": "1",
  "origin": "synthetic_fixture",
  "provenance": "unit-test only; not measured hardware data",
  "tick_unit": "sim_tick",
  "resources": {"compute_resource": 1, "memory_resource": 1},
  "prefill": [
    {"name": "prefill_compute", "resource": "compute_resource", "service_ticks_per_unit": 1},
    {"name": "prefill_memory", "resource": "memory_resource", "service_ticks_per_unit": 1}
  ],
  "decode": [
    {"name": "decode_compute", "resource": "compute_resource", "service_ticks_per_unit": 1}
  ]
}
```

The example uses toy values solely to explain field shape. It is not a recommended or measured architecture.

## 3. Execution semantics

- Integer ticks only; no floating-point event time.
- Each request's prompt is split into the trace's `prefill_chunk_tokens`; each chunk passes through the ordered prefill stages.
- Decode is one output token per unit; each token passes through the ordered decode stages.
- Each resource has a finite number of concurrent slots and an independent FIFO waiting queue.
- Service duration is `service_ticks_per_unit × units`.
- Equal-time completions are processed before exogenous events; exogenous events retain trace sequence order. Dispatch happens after all events at that tick are applied.
- Cancellation/fault removes queued work and aborts active work at the event tick. The elapsed active occupancy is counted; invalidated completion events do not advance simulation time.
- Deadline events mark the request as deadline-missed but do not implicitly cancel it.
- A request's TTFT is recorded only when all stages for its first decode token have completed.
- Positive service durations prevent zero-time stage loops. Model instances are single-use to prevent accidental state leakage between replays.

## 4. Report fields

The JSON report includes profile identity/provenance, workload replay hash, end tick, completed/cancelled/faulted/incomplete counts, deadline-miss count, per-resource capacity/busy ticks/utilisation/queue wait/operation count, and per-request TTFT/completion latency/queue wait/status.

Utilisation is a model ratio: accumulated active service ticks divided by `end_tick × capacity`. It is meaningful only within the stated model/profile. It is not a measured hardware utilisation figure.

## 5. Deliberate current limitations

Not yet represented as independent mechanisms:
- admission limits/rejection and tenant fairness policies;
- batching and continuous batching;
- cache hit/miss, KV allocation/fragmentation/pinning/eviction/restore;
- explicit DMA transfer sizes and transfer bandwidth;
- TMEM bank arbitration, read/write port conflict/replay and backpressure;
- DRAM channel/rank/burst/refresh/queue behaviour;
- NoC/interconnect arbitration, link contention and backpressure;
- preemption, clock/power states, clock gating, voltage/frequency changes;
- power, energy, temperature, cooling, area, manufacturing yield or cost.

The model can represent multiple ordered phase stages and finite-capacity resources, but doing so does not establish that the chosen abstract stages match the RTL. Add mechanisms only when their interface and semantics are grounded in source and trace evidence.

## 6. Calibration and correlation path

1. Run a deterministic W1/W2/W3 fixture with a traceable workload identity and save the replay hash.
2. Capture the matching RTL simulation source/configuration and raw `+trace` / `+tmtrace` artefacts.
3. Use `opentpu/hwtrace.py` to decode D/S/G/E and U/P/Q/H event/counter records. D is dispatch, S is ready, G is grant and E is completion; U/P/Q/H carry pressure/counter groups as defined in that decoder.
4. Use `tools/tmem_trace.py` on the matching TMEM trace to recover read/write activity, instruction intervals, per-port traffic, arbitration losses, overlap and producer/consumer flow.
5. Map only supported RTL intervals and counters to profile stages. Record how each service time/capacity was derived and its uncertainty. Do not equate aggregate counters directly to per-request latency without request/slot attribution.
6. Compare predicted and observed event ordering, stage occupancy, queueing and completion intervals on held-out fixtures. Preserve residuals and mismatches.
7. Only after independent review may a profile be marked `rtl_trace_calibrated`. Board power or temperature requires separate calibrated instrumentation and is outside this model.

## 7. CLI

Generate a trace:

```bash
python -m tools.sunnyone.workload_trace path/to/W1.json -o /tmp/W1.trace.jsonl
```

Run the resource model with an explicitly supplied profile:

```bash
python -m tools.sunnyone.resource_event_model /tmp/W1.trace.jsonl \
  --profile path/to/versioned-profile.json -o /tmp/W1.report.json
```

Do not run a model without a reviewed profile. The repository currently has no production/calibrated profile; the profiles embedded in unit tests are synthetic fixtures only.

## 8. Unit-test evidence

- `tests/test_sunnyone_resource_event_model.py` covers deterministic FIFO timing, chunked prefill, token-by-token decode, finite resource capacity, cancellation while queued/active, fault abort, deadline marking, multi-stage resource occupancy, TTFT after the final first-token stage, trace hash validation, profile validation, tick-unit matching and single-use state.
- Final targeted workflow `46080976923`, job `140779640735`, tested source `7703ff4a8bf6c8fb4e34dcf200bb259eed1ef79b`: **31 tests passed in 0.521 seconds; OK**. This includes 16 resource-model tests, 10 workload-trace tests, 3 endpoint benchmark tests and 3 retrieval-metric tests.
- Earlier intermediate failures were corrected before the final passing revision. The workflow YAML syntax issue was fixed; the final run compiled both Python modules and executed the complete 31-test deterministic harness.

## 9. Next work

1. Add trace semantic validation for per-request arrival-before-cancel/fault/deadline and malformed event payloads.
2. Build explicit admission/tenant-fairness semantics from the existing runtime scheduler before adding hardware assumptions.
3. Inspect and correlate actual RTL trace records and TMEM traces on the same workload/source/configuration.
4. Add a calibrated profile only when reproducible trace evidence supports each field. No fabricated service time, bandwidth, power or temperature values.
5. Extend W1/W2/W3 fixture coverage; enable W4 only after model/context and memory-capacity support are verified.

Manufacturer handoff remains **NOT READY**. The model milestone is software-only evidence and does not close physical implementation, formal, CDC/RDC, DFT, memory-controller, production-interface, PPA or qualification gates.
