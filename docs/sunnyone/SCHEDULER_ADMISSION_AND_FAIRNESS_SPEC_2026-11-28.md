# SUNNYONE AI-X — Existing Runtime Admission and Fairness Semantics
Date: 2026-11-28 (Asia/Dhaka)
Status: source inspection; no scheduler implementation change

## 1. Reviewed source

- `opentpu/serve/scheduler.py`, blob `7346daae1bfe08b1acd71965cd14e5b00d82211d`.
- Relevant implementation: `Worker.__init__`, `Worker.submit`, `Worker._pick`, `Worker._others`, `Worker._turn`, `Worker._idle`, `Worker._preempts`.
- This document describes the inspected source revision. Re-fetch and compare the source blob before relying on these semantics after code changes.

## 2. Admission and turn selection

1. `submit(request)` validates non-empty prompt, context capacity, image support and token/image consistency, assigns a request ID if absent, clamps requested output to remaining context capacity, stamps submission time and appends the request to `waiting` under the worker condition lock.
2. The default worker `max_running` is 8, but it is a constructor parameter. The default decode `quantum` is 32 tokens. The non-polling backend chunk cap `CHUNK` is 64 tokens. These are software defaults, not measured optimal values or hardware capabilities.
3. `_pick()` first ends cancelled requests in both waiting and running lists.
4. If the waiting queue is non-empty and `len(running) < max_running`, it removes `waiting[0]`, appends it to `running`, and returns it immediately. This admits FIFO by queue order and gives a newly admitted request its turn before the next running-request round-robin selection.
5. If no request is running, selection returns none. Otherwise the round-robin cursor advances modulo the current running-list length and selects that running request.
6. If exactly one request is running and it is the current device owner, it continues without unnecessary turn switching.
7. `_others(request)` is true when another request is waiting or more than one request is running. Decode uses this signal to yield/stop after the in-flight token where the backend supports polling. A lone request can run continuously until completion.

## 3. Fairness classification

- **FIFO admission:** present for the waiting queue.
- **Request-level round-robin:** present among admitted running requests when more than one is active.
- **Prefill priority:** newly admitted requests are selected before the next running-request turn while admission capacity remains. This can affect decode latency under arrival bursts.
- **Tenant fairness / weighted fair queuing / per-tenant quotas:** not established by the inspected worker. The Request dataclass and Worker selection path do not expose a tenant identity or per-tenant accounting in this source revision. Do not describe request round-robin as tenant fairness.
- **Starvation bound:** not established by this source review. Queue arrivals, continuous admission, request duration, cancellation and turn behaviour need controlled tests before any bound is claimed.

## 4. Context, cancellation and idle-save implications

- Running and waiting cancellations are pruned by `_pick()` and ended as aborts.
- The worker saves/restores contexts through its KV/prefix store when switching device context; active request entries can be pinned.
- When the queue becomes empty, `_idle()` can persist the device context. A new request that continues the exact context being saved can pre-empt the idle save; other requests wait for that save to complete.
- A link-recovery path can reset the link/device context and resume a request from its prompt and generated output so far, subject to the code's one-recovery guard.
- These are host/runtime mechanisms. They do not prove that the current ASIC has an independent LPU, on-chip KV manager, hardware multi-tenant scheduler or production context-switch engine.

## 5. Required controlled evaluation

Use deterministic workload traces and exact source/configuration identifiers.

- **W1 — single request:** verify prompt admission, prefill, decode, TTFT, inter-token latency, completion and idle transition.
- **W2 — mixed concurrency:** stagger arrivals while one or more requests are decoding; measure prefill interference, request-level round-robin order, context save/restore, queue wait and tail latency.
- **W3 — burst/contention/fault:** queue beyond `max_running`, vary prompt/output lengths, cancel waiting and running requests, inject supported faults/deadlines, and record admission/abort/recovery ordering.
- **Tenant fairness experiment:** requires explicit tenant identity, policy definition and per-tenant metrics before it can be claimed or modelled. Do not silently add a fairness policy to the current model and call it source-faithful.
- **W4 long context/KV pressure:** conditional on verified context capacity, KV allocation/lifetime and store semantics.

## 6. Model integration rules

The current resource-event model supports profile-driven resource queues but does not yet encode the full scheduler lifecycle above. Before adding admission/fairness behaviour:
- preserve FIFO waiting and `max_running` as configurable, source-grounded semantics;
- model prefill-first admission separately from round-robin running turns;
- represent cancellation and idle-save pre-emption only with explicit state transitions;
- keep tenant fairness disabled/unspecified until a separate policy is defined;
- add deterministic tests for ordering, cancellation, saturation and no-starvation claims only when a precise property is specified;
- do not infer service times, memory bandwidth, energy or power from scheduler source code.

## 7. Decision

Tune the existing software scheduler and context/KV lifecycle before proposing dedicated LPU hardware. Any LPU silicon proposal requires a measured bottleneck and net gain in accepted useful throughput, latency, energy, total cost and reliability.
