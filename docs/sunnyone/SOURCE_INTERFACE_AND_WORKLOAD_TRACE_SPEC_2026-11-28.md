# SUNNYONE X — Source Interface Map and Deterministic Workload Trace Contract
Date: 2026-11-28 (Asia/Dhaka)
Reviewed branch HEAD: `fbb5e5f601e16225712f94812a8d41b3517397e5`
Status: source inspection and workload specification; no RTL or simulator implementation changed.

## 1. Evidence and source revisions

The following files were fetched from the active feature branch. Blob IDs are recorded so later reviews can detect source drift.

| File | Blob |
|---|---|
| `rtl/asic/otpu_asic_chip_top.sv` | `149396d29d278439ae58981f644fb7d51a98cddd` |
| `rtl/asic/otpu_asic_top.sv` | `e7bafc437fa4a5a73c18ffbee8ae7aa0d764f480` |
| `rtl/top/otpu_slice.sv` | `92d0006245c8fd6878ead9e4f55cf676aee09b35` |
| `opentpu/serve/scheduler.py` | `7346daae1bfe08b1acd71965cd14e5b00d82211d` |
| `opentpu/serve/store.py` | `3eb3f2a2b591701fcd2a733b9ed60ee3dda18985` |
| `opentpu/hwtrace.py` | `5e23c82954ac4c55d6c2c716658681febce61988` |
| `tools/tmem_trace.py` | `c08c625130e66a63ec7626fe3083a31e8ec496d8` |
| `opentpu/rtlsim.py` | `08795e7d6004ee44b560b50badb140f4c8408a19` |

This is a source map, not a claim that every interface has been independently simulated or formally verified.

## 2. Physical/host boundary

### ASIC chip wrapper: `otpu_asic_chip_top`

- Exposes a 12-bit-address, 32-bit-data AXI4-Lite BAR0 control interface. The PCIe endpoint itself is explicitly external to this RTL module.
- Exposes core-memory adapter channels A, B, scalar-write SW and wide weight-group W. The external memory controller/PHY and PCIe endpoint are not implemented inside this wrapper.
- Receives two synchronised memory-calibration status groups plus memory-error and ECC-dedicated-error indications.
- Exposes `halted`, `error`, `wait_to`, `a_inval` and `icount` status.
- The wrapper synchronises `mem_calib`, `mem_error` and `ecc_ded` into the core clock domain before control logic consumes them.

### Compute top: `otpu_asic_top`

- Instantiates exactly one `otpu_slice` in this configuration, with `S(1)`.
- Instantiates a separate collective block (`otpu_coll` or `otpu_coll_bar`, selected by `COLL_GATHER`).
- Combines slice and collective errors as `error = s_error || coll_gerr`.
- Forwards the A/B/SW/W memory channels and the posted wide-beat interface to the slice.

**Important:** current ASIC top evidence is one compute slice. Do not describe multi-slice production integration as implemented merely because separate multi-slice simulation configurations exist.

## 3. Slice engine and handshake map

The slice instantiates:
- `otpu_seq`: instruction fetch/decode, dependency scoreboard, issue and completion control.
- `otpu_dma`: memory transfers, streaming setup/data path and supported load/store operations.
- `otpu_mxu`: matrix engine, activation RAM reads, scale/weight input and matrix-result writes.
- `otpu_quant`: quantisation and supported QACT/QST paths, activation-RAM writes and scalar write requests.
- `otpu_vpu`: vector, elementwise, reduction and supported composite/stream operations.
- Optional `otpu_se_eng`: a separate stream engine when `SE_OWN` is enabled by configuration.
- Shared TMEM and ACT RAM, plus the collective interface.

The sequencer-to-unit handshake is represented by the `ustart`, `urel`, `ufol`, `urdy` and `udone` vectors, with per-unit `rdy`/`done` status and DMA error signalling. The slice exposes `halted`, `error`, `wait_to`, invalidation status and instruction count. A simulator must preserve the distinction between command issue, unit acceptance/readiness, resource grant, completion and global halt.

### TMEM ports observed in the slice

Read-port identities:
- `P_MXU=0`
- `P_DMA=1`
- `P_Q=2`
- `P_VA=3`, `P_VB=4`
- `P_Q3=5`, `P_Q2=6`
- `P_COLL=7`

Write sources are DMA, MXU, VPU and collective. The slice builds read/write request arrays and applies all-or-nothing group grants with bank-conflict handling and replay/freeze behaviour. The simulator must model actual configured bank/read/write capacity and priority rather than assume unlimited parallel TMEM access.

### External memory channel roles

- **A:** MXU-side activation scale/metadata read/write path as connected by the slice.
- **B:** primary wide memory request/response path shared by DMA and MXU traffic, with return tagging and byte/word masks.
- **SW:** scalar quantizer write path (QST), byte-enabled.
- **W:** wide weight-group reads when WG > 1; posted channel beats use slot/count metadata and a separate posted-beat clock interface.

The exact controller timing, PHY training, ECC implementation, PCIe transport, DMA/IOMMU and board-level arbitration are outside the current chip-wrapper RTL boundary and remain production integration gates.

## 4. Existing software LPU foundation

`opentpu/serve/scheduler.py` is an existing host/runtime scheduler around one Engine:
- admits up to `max_running` requests;
- gives new prompt prefill priority before running decode turns;
- rotates active requests in round-robin order;
- currently defines a 32-token decode quantum and a 64-token non-polling backend chunk cap;
- checks cancellation/yield and tracks per-request timing/phases;
- saves/restores contexts through `opentpu/serve/store.py`.

`store.py` supports host-RAM and disk tiers, prefix matching, shared pages, pinning and eviction. These current defaults and mechanisms are not proven optimal and do not establish on-chip KV capacity or production-scale serving throughput.

## 5. Existing observability and simulator hooks

- `opentpu/hwtrace.py` decodes the RTL trace ring: dispatch, ready, start, grant, completion, unit pressure, window/TMEM pressure and related records.
- `tools/tmem_trace.py` analyses cycle-level TMEM reads/writes, port activity, reuse, overlap and arbitration losses from `+tmtrace` co-simulation records.
- `opentpu/rtlsim.py` builds and runs Verilator simulations with source/parameter/version-keyed build caching.
- The RTL trace and TMEM trace are the preferred evidence path for calibrating engine service profiles and memory contention. A software-only event model must not replace or contradict these measurements.

## 6. Deterministic workload contract

A request fixture must explicitly identify:
- request and tenant IDs;
- model/checkpoint, tokenizer and prompt-template identity;
- deterministic arrival tick and seed;
- prompt-token count, requested output-token limit and context/KV shape;
- priority/deadline and batch-eligibility policy;
- prefix-cache identity and expected cache-hit condition;
- optional cancellation, timeout, injected fault and recovery event;
- correctness/quality acceptance rule and reference-output identity where available.

The trace must use an integer simulation clock and a stable event sequence number. Equal-timestamp events must have deterministic ordering. Reject events scheduled in the past; guard against same-timestamp zero-progress loops; preserve a deterministic replay hash.

Required event families:
1. arrival, admission, queue wait and rejection;
2. prompt chunk/prefill and attention matrix/vector stages;
3. KV allocate, lookup, read, write, pin, unpin, page, evict and restore;
4. MXU/VPU/quantizer/DMA dispatch, resource request, grant, backpressure, completion and error;
5. TMEM bank conflict/replay and DRAM channel request/response/stall;
6. decode step, token acceptance, output completion and stop condition;
7. cancellation, timeout, fault, recovery, resource release and tenant-isolation checks.

Initial scenarios should be controlled fixtures, not customer claims:
- **W1:** single-request baseline, separating prefill from decode.
- **W2:** concurrent mixed prompt/output lengths, exposing prefill/decode fairness.
- **W3:** burst arrivals, cache sharing, memory contention, cancellation and recovery.
- **W4:** conditional long-context/KV-pressure scenario, enabled only for models and context sizes actually supported by the selected configuration.

Every fixture must preserve exact request parameters. Do not silently assign synthetic values to a product benchmark or represent fixture results as customer workload evidence.

## 7. Required outputs and measurement boundaries

Report at least:
- accepted useful tokens/s and requests/s, with the quality gate stated;
- TTFT, prefill tokens/s, decode tokens/s and inter-token latency P50/P95/P99;
- queue wait, admission rejection, fairness and starvation;
- per-engine busy/idle cycles and utilisation;
- TMEM/DRAM bytes, bank conflicts, arbitration losses, DMA traffic and stalls;
- KV bytes/token, peak allocation, fragmentation, cache hit/miss and save/restore traffic;
- cancellations, errors, recovery time and leaked-resource/invariant failures;
- deterministic replay hash and exact source/configuration.

Energy and thermal reporting are deliberately conditional:
- RTL activity counts and simulator cycles are **proxies**, not joules.
- Do not report joules/token until a calibrated power model or measured whole-system wall-power data is available.
- Do not report temperature/cooling performance until a calibrated thermal/system boundary exists.
- Keep measured, quoted, simulated, inferred and assumed values explicitly labelled.

## 8. Implementation order and stop conditions

1. Complete this source/port/handshake map against the exact selected ASIC configuration.
2. Implement a deterministic request-trace generator with integer timestamps and schema validation.
3. Implement a discrete-event resource model only with explicit, versioned service profiles; leave unknown latency/bandwidth parameters unset rather than inventing values.
4. Correlate event-model stages with existing RTL `hwtrace` and `tmem_trace` records.
5. Validate W1/W2/W3 first; enable W4 only after the supported model/context and memory-capacity contract is proven.
6. Tune the existing scheduler/cache/compiler/runtime before proposing new RTL. Any hardware proposal needs a measured bottleneck, interface/error contract, resource estimate, formal properties and focused tests.

No RTL, ISA, PPA, workflow, hardware or external service was changed or run while preparing this map. Manufacturer handoff remains NOT READY.


## 9. Trace generator implementation status — 2026-11-28

- Implemented `tools/sunnyone/workload_trace.py` (commit `3b03f52ad525f7f4c38d212dbd2ecab7a83a9353`). It validates a JSON workload specification, emits request arrival/fault/cancel/deadline events, applies deterministic integer-tick ordering and writes canonical JSONL with a SHA-256 replay hash.
- Implemented `tests/test_sunnyone_workload_trace.py` (commit `b8451c5393bc22d02512182349395bfca27c2913`) covering deterministic bytes/hash, equal-timestamp ordering, defaults, invalid ticks, duplicate IDs, invalid fault fields, unknown fields and absence of invented service/energy values.
- Updated `.github/workflows/sunnyone-workload-harness.yml` to compile the generator (commit `88e3f5636d9d1818e59e8309e7bd26fa7c07e807`). Workflow `46080190053`, job `140777139012`, completed SUCCESS on that exact head. The combined SUNNYONE deterministic harness ran **16 tests in 0.513s: OK**, including 10 workload-trace tests, 3 endpoint benchmark tests and 3 retrieval metric tests.
- Superseded harness run `46080182042` was cancelled by the workflow concurrency rule when the workflow-file update pushed the newer revision; the replacement `46080190053` is the successful evidence. No other CI suite was triggered by this targeted harness change.
- This is an exogenous request-trace generator only. It does not yet model resource service time, compute cycles, throughput, power, energy or thermal behaviour. Those remain the next separate implementation and require explicit versioned service profiles.
