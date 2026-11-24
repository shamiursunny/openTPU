# SUNNYONE AI-X — Commercial Profitability Measurement Model

**Status:** decision framework and blank evidence model; no numeric profitability or power claim is made.

## 1. Decision objective

Select the accelerator configuration that maximises risk-adjusted long-term net profit and achieves the fastest realistic investment recovery, subject to functional correctness, model quality, reliability, compatibility and service-level requirements.

Do not maximise peak TOPS, clock rate, memory capacity or board power in isolation. There is no fixed 30 W system ceiling in the current project baseline. The power envelope is an empirical decision derived from measured workload throughput, complete-system TCO and incremental contribution margin.

## 2. Mandatory workload qualification

Compare configurations using the same model revision, weights, tokenizer, quantisation, prompt/context distribution, batch size, concurrency, output length, sampling policy and quality acceptance criteria.

At minimum, record separately:

- LLM prefill and decode;
- short-context and long-context decode;
- batch-1 latency and throughput at realistic concurrency;
- embeddings and reranking, where supported;
- vision or multimodal workloads only when the implementation is validated;
- cold start, model load, warm-up and steady-state behaviour.

A throughput result is valid only when the output passes the workload's correctness/quality checks. Record unsupported operators, CPU fallbacks, memory spills, retries and failed requests.

## 3. Required measurements

For each exact hardware/software configuration and workload, record:

| Metric | Required evidence |
|---|---|
| Useful throughput | Correctly completed tokens/s, requests/s or items/s |
| Latency | First-token, inter-token and end-to-end P50/P95/P99 |
| Energy efficiency | Joules per million useful tokens or per useful request |
| Power | Board and full-system wall power at idle, load and thermal steady state |
| Thermal behaviour | Component temperatures, throttling, fan/cooling power and stability |
| Reliability | Error rate, reset/recovery, uptime, memory errors and sustained run duration |
| Utilisation | Accelerator, memory, host, network and storage utilisation |
| Quality | Model/task-specific accuracy and output acceptance rate |
| Capacity | Usable model/KV-cache capacity under the tested configuration |

Record the measurement method, instrument, calibration, sample count, run duration, ambient conditions, software versions, source commit SHA and raw log/artifact location.

## 4. Full-system total cost of ownership

Include every cost needed to deliver the same accepted workload:

- ASIC NRE, masks, engineering, verification and IP licences;
- wafer, die yield, packaging, test and production scrap;
- board, power delivery, cooling, memory, storage and host system;
- networking, rack/chassis, deployment and facility costs;
- electricity, cooling overhead/PUE, maintenance and replacement;
- software development, runtime, drivers, monitoring and support;
- warranty, logistics, import duties, taxes, financing and working capital;
- manufacturing minimum order quantity, lead time and inventory risk.

Separate one-time engineering/deployment costs, per-unit capital costs and recurring operating costs. Do not omit host CPU, DRAM, network or cooling simply because the accelerator chip itself does not consume that power.

## 5. Financial equations

Use consistent currency, time period and tax treatment.

Let:

- (Q) = accepted useful workload volume per period;
- (p) = realised revenue per unit of accepted workload;
- (v) = variable operating cost per accepted unit;
- (F) = fixed operating cost per period;
- (K) = initial deployed capital and engineering cash outlay.

Then:

[
	ext{Revenue}=Qp
]

[
	ext{Contribution margin}=Q(p-v)
]

[
	ext{Operating cash flow}=Q(p-v)-F
]

[
	ext{Simple payback periods}=
rac{K}{	ext{positive operating cash flow per period}}
]

For a multi-period investment, calculate NPV using sourced cash flows and an explicitly justified discount rate:

[
	ext{NPV}=-K+sum_{t=1}^{T}
rac{	ext{Net cash flow}_t}{(1+r)^t}
]

If operating cash flow is non-positive, simple payback is not achieved. Do not report a payback period by dividing by a negative or zero cash flow.

For a service deployment, include utilisation, customer demand, price realisation, churn, service credits, availability and capacity-reservation assumptions. For internal cost savings, compare the accelerator with the actual alternative service or hardware cost for the same accepted workload.

## 6. Choosing the power envelope

For each candidate power point, measure:

- full-system power at the wall, including host, memory, fans and power conversion;
- accepted useful throughput and quality at sustained thermal equilibrium;
- energy per useful output;
- total system cost and incremental deployment cost;
- revenue or cost savings achievable at the measured throughput;
- cooling, reliability and operating-cost consequences.

Compare the incremental contribution from a higher-power configuration with its incremental capital and operating costs. Choose the point with the strongest risk-adjusted economics while meeting reliability and service requirements. More watts are justified only when the measured incremental useful capacity produces sufficient additional contribution margin and does not create unacceptable thermal, reliability or capital risk.

## 7. Scenario and sensitivity analysis

Maintain at least pessimistic, base and optimistic scenarios. Do not assign probabilities or numeric values without evidence.

Vary, at minimum:

- utilisation and demand ramp;
- useful throughput and quality pass rate;
- electricity tariff and facility PUE;
- chip yield, unit cost, packaging and MOQ;
- NRE and schedule delay;
- memory/host/network requirements;
- realised selling price, customer concentration and churn;
- failure rate, warranty and replacement cost.

Report break-even utilisation, break-even price, maximum affordable unit cost and payback sensitivity. Keep assumptions separate from measured inputs.

## 8. Evidence gate and current missing inputs

No commercial return, energy-efficiency or power-envelope conclusion can be made until the following are measured or contractually quoted:

- reproducible RTL/ORFS synthesis and timing reports;
- process-specific physical PPA and SRAM macro solution;
- board-level throughput, latency, wall power and thermal measurements;
- manufacturer quotations for NRE, die, yield, package, test, board and MOQ;
- verified software support and workload-quality results;
- sourced demand, pricing, utilisation and service-cost assumptions.

The current Nangate45 flow is a research proxy, not a production process. Simulation results do not establish silicon power, physical timing, manufacturing yield or unit cost. All future figures must identify their source, date, configuration and exact evidence reference.

## 9. Decision rule

A configuration is commercially preferred only when it:

1. meets correctness, quality, compatibility, reliability and service-level gates;
2. has reproducible useful-throughput, latency, power and thermal measurements;
3. has a complete and auditable TCO;
4. produces positive contribution margin under defensible operating assumptions;
5. has acceptable risk-adjusted NPV and investment recovery relative to the measured alternative.

Until those conditions are evidenced, the output is a decision framework—not a business-case result or investment recommendation.
