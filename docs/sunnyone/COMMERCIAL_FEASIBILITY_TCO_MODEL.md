# SUNNYONE AI-X — Commercial feasibility and TCO model specification

Date: 2026-11-23
Stage: Commercial discovery and architecture economics — specification with initial public market reference points; not yet populated with verified customer demand, supplier quotations or measured hardware data.

## Purpose

Select a commercially defensible AI inference product and hardware configuration by maximising risk-adjusted long-term profit and realistic investment recovery. Compare operating an inference service, selling/licensing hardware and a hybrid route.

No numerical revenue, cost, payback or profitability forecast is asserted in this version. Populate only from traceable quotations, measured prototype data, documented customer evidence and explicitly labelled assumptions.

## A. Business-model comparison

### Route A — Operate inference service
Potential revenue units: input/output tokens, requests, reserved capacity, dedicated deployments or service-level tiers.
Required evidence: target customer segment, workload profile, expected usage, willingness to pay, latency/quality requirements, acquisition channel, churn, support burden, payment terms and utilisation ramp.

### Route B — Sell, lease or license hardware/software
Potential revenue units: hardware sale, lease, support contract, software licence, maintenance or integration.
Required evidence: bill of materials, manufacturing yield/lead time, warranty reserve, customer deployment capability, support costs, channel margin, sales cycle, payment terms and repeat demand.

### Route C — Hybrid
Use owned infrastructure for recurring API/service revenue while selling or licensing selected systems where customer economics justify it. Avoid counting the same capacity or revenue twice.

Score all three routes on gross contribution, cash conversion, capital intensity, customer acquisition, support burden, utilisation risk, scalability, defensibility and payback.

## B. Configuration comparison

Create at least three technically comparable system candidates:

1. Efficient: lowest capital and operating cost that meets defined workload/quality/latency requirements.
2. Balanced: expected best risk-adjusted contribution margin and expansion capability.
3. High-throughput: more compute, memory bandwidth/capacity, power and cooling only where extra billable output and realised price justify them.

For each candidate record exact accelerator/device/package and board revision; memory type, capacity, ECC, DIMM part number, ranks, 3DS, speed and measured bandwidth; compute resources, supported precision, sustained clocks and thermal limits; storage, network, power supply, conversion efficiency and cooling; component/PCB/assembly/test costs, development/NRE, deployment, spares and replacement reserve; measured wall power at idle, prefill, decode, mixed load and stress; measured sustained useful throughput, latency percentiles, model quality, uptime and failure rate.

Memory options must include 128 GB ECC DDR4 RDIMM feasibility and a 256 GB stretch case, but neither is presumed economically optimal or physically supported until exact device/package/controller/DIMM/PCB validation.

## C. Required input register

Every input must carry: value, unit, source/quotation URL or document, date, geography/currency, confidence (verified/quoted/assumption), owner and next verification action.

Capital expenditure: device/accelerator, development boards, RAM, PCB, power delivery, cooling, storage, network, enclosure, assembly, test equipment, engineering/NRE, compliance, deployment, initial spares and working capital.

Monthly fixed costs: facility/colo, network commitments, software licences, monitoring/security, staffing/contractors, support, insurance, administration, financing and minimum service commitments.

Variable costs: electricity and cooling, transaction/payment fees, bandwidth overage, per-request external services, consumables, usage-linked support, repairs and applicable taxes.

Commercial inputs: realised price by unit/tier, discounts, refunds/credits, bad debt, billable utilisation, ramp-up, churn, customer acquisition cost, sales cycle, contract length, payment delay and service credits.

Workload inputs: model/version, quantisation, context length, input/output ratio, batch size, concurrency, requests/hour, target latency, quality acceptance criteria, uptime and failure/retry rates.

## D. Core formulas

Let P = measured average wall/input power in kW under the representative workload; H = operating hours/month; E = electricity tariff/kWh; Ccool = separately modelled cooling energy/cost not already included in wall power; Cfixed = monthly fixed operating costs excluding electricity; Cvariable = other monthly variable costs; Rcollected = cash revenue actually collected; Nuseful = useful output tokens delivered and accepted; Kinitial = initial project investment including initial working capital.

If wall power measurement already includes cooling, do not add cooling again. Otherwise:

Electricity cost = P × H × E + Ccool.

Monthly operating cash flow = Rcollected − electricity cost − Cfixed − Cvariable − financing cash payments.

Show operating profit, depreciation, interest, tax and financing separately; do not confuse accounting profit with cash flow.

Cost per million useful tokens = (attributable monthly TCO / Nuseful) × 1,000,000.

Contribution per billable unit = realised unit price − variable cost per billable unit.

Break-even billable units = monthly fixed costs / contribution per billable unit, only when contribution is positive and the same unit definition is used throughout.

Break-even utilisation = break-even billable units / technically saleable billable units at the stated SLA.

Payback month = first month in which cumulative project net cash flow ≥ Kinitial, with ramp-up, working capital, replacement capex and cash collection delays included.

Incremental upgrade value = incremental collected revenue/contribution − incremental energy, cooling, support, depreciation/replacement and financing costs.

An upgrade is not approved merely because it increases tokens/s. Its incremental economic value must be positive under a conservative case and acceptable under downside sensitivity.

## E. Scenario analysis and sensitivities

Build conservative, base and upside cases. Explicitly vary utilisation ramp and customer acquisition; realised selling price and price erosion; model mix, context, input/output ratio and concurrency; wall power, electricity tariff and cooling overhead; useful throughput, uptime, failure/retry rate and maintenance; component price, manufacturing yield, lead time and replacement rate; financing cost, payment delays, churn and working capital.

Report monthly revenue, gross contribution, operating cash flow, break-even utilisation, cumulative cash balance, payback month (or “not achieved”), and five-year cash flow. Include a downside case with slower customer uptake and lower prices.

## F. Benchmark protocol

All candidate configurations and competitor systems must use the same model/version and prompt set; same quantisation or documented quality-equivalent setting; same context lengths and input/output token mix; same batch/concurrency and request arrival pattern; same latency/quality acceptance criteria; same wall-power measurement boundary; warm-up, steady-state duration and repeated runs; public scripts, environment versions and raw logs.

Record prefill and decode separately. Report sustained useful tokens/s, tokens/J at the wall, first-token latency, inter-token p50/p95/p99, accuracy/quality, uptime, thermal throttling and cost per useful token. Peak TOPS and short burst throughput are not substitutes for service capacity.

## G. Stage gates

G0 — Customer and workload definition: named customer segments, representative tasks and documented demand evidence.

G1 — Commercial route: compare service, hardware sale/licensing and hybrid with explicit pricing evidence and sales assumptions.

G2 — Preliminary unit economics: populate cost register, demand cases, fixed costs, variable costs, break-even and payback sensitivity. No hardware freeze before this gate.

G3 — Hardware feasibility: compare integrated Versal NoC DDR and PG353 soft DDR; exact part/package, DIMM, ECC, ranks/3DS, pinout, resource and power feasibility.

G4 — Prototype evidence: synthesis/timing/resource reports; physical memory training/stress; wall power and thermal measurement; reproducible inference benchmarks.

G5 — Pilot economics: paid pilot or equivalent documented customer validation; actual utilisation, service quality, collected revenue and support cost.

G6 — Production investment: approve only when validated demand, manufacturing quotations, reliability evidence, risk-adjusted cash flow and funding plan support the investment.

## H. Initial market reference snapshot (retrieved 2026-11-23)

These are public reference points for comparison only. They are not SUNNYONE selling prices, supplier quotes, customer demand, or a forecast. Re-check the original provider pages and conditions before investment decisions.

### API token pricing examples (USD per 1 million tokens)

- OpenAI official API pricing page: examples on the current page include GPT-6 Luna at $0.05 input / $0.25 output and GPT-6 Astra at $5 input / $25 output in the listed standard tier. Model, context, processing mode, caching and regional options change the rate. Source: https://developers.openai.com/api/docs/pricing
- Anthropic official platform pricing page: examples include Claude Haiku 4.5 at $1 input / $5 output, Sonnet 5.5 at $2 / $10, and Opus 5.5 at $4 / $20. Source: https://platform.claude.com/docs/en/about-claude/pricing
- Google Gemini Developer API pricing page includes multiple tiers and model rates; for example, the page lists Gemini 3.5 Flash-Lite at $0.30 input / $2.50 output in Standard paid pricing. Check the current model table and tier. Source: https://ai.google.dev/gemini-api/docs/pricing

Do not compare a blended SUNNYONE cost to a single output-token list price. Model the real input/output mix, caching, batch discounts, tool calls, reasoning tokens, failed requests and quality-equivalent model selection.

### GPU rental reference points

Third-party market snapshots retrieved 2026-11-23 report H100 on-demand prices varying by provider, form factor, region, minimum instance size and terms. One tracker reports a November 22 H100 median of about $3.92/GPU-hour and a low listed price of $1.80; another reports a separate November 19 low listing of $2.59/GPU-hour. These are not interchangeable quotes and may include marketplace/spot or differing hardware variants. Sources:
- https://tensorcore.si/gpu-cloud-pricing/
- https://www.nvgpu.com/gpus/h100
- https://uvik.net/blog/gpu-price-index/

Use actual provider checkout/pricing pages and confirm region, GPU variant, minimum node size, CPU/RAM/network/storage charges, interruptibility, taxes and availability before treating a rate as a competitor cost.

### Bangladesh electricity reference

A June 2026 report on revised BERC tariffs states commercial and office low-voltage rates of Tk 15.36/kWh, with peak Tk 18.43 and off-peak Tk 13.82. Source: https://www.dhakatribune.com/bangladesh/power-energy/411666/how-much-does-electricity-tariff-increase-per

This is only a preliminary tariff reference. Confirm the actual premises' consumer class, voltage, time-of-use meter, demand charge, power factor penalty, taxes, connection capacity and latest bill with the relevant utility/BERC schedule. A utility bulk purchase rate is not a customer's retail tariff. Do not use residential slab rates for a commercial data-centre model.

## I. Current evidence status (2026-11-23)

| Evidence item | Status |
|---|---|
| User priority: maximise long-term profitability and faster realistic investment recovery | Confirmed direction |
| 30 W hard ceiling | Retired |
| 128 GB DDR4 RDIMM | Feasibility target only |
| 256 GB DDR4 | Stretch investigation only |
| Exact Versal device/package | Not selected |
| Integrated DDR vs PG353 | Comparison pending |
| Public API price references | Initial research captured; not customer pricing |
| H100 rental comparisons | Initial third-party snapshots captured; provider quotes unverified |
| Bangladesh commercial tariff | Preliminary public reference; actual site tariff unverified |
| Customer segment / target workload | Not yet specified |
| Service vs hardware vs hybrid | All three to be modelled |
| Real customer willingness-to-pay evidence | Not yet obtained |
| Verified component/manufacturing quotations | Not yet obtained |
| Measured prototype wall power / tokens per second | Not available |
| TCO / break-even / payback | Not calculated |
| Paid pilot / production demand | Not verified |

## J. Immediate next actions

1. Define 2–3 initial customer segments and 3–5 representative workloads for each.
2. Verify API and GPU competitor pricing at the exact model, region, hardware variant, service tier and purchase terms.
3. Obtain local electricity, hosting, networking, component, PCB and assembly quotations; distinguish quote from estimate.
4. Build a spreadsheet implementation of the formulas and scenario inputs; leave unknown cells blank rather than fabricating values.
5. Select a minimum viable workload target before fixing memory capacity; determine whether 128 GB or 256 GB has a measurable customer/revenue use case.
6. Complete exact Versal memory-controller/device/package feasibility before choosing a part.
7. Prototype, measure, benchmark and replace assumptions with measured data.
8. Recalculate the business case before any major production capex.

## References and traceability

Technical memory/controller claims are tracked in MEMORY_CAPACITY_DECISION.md. AMD controller documentation is an IP capability reference, not a guarantee for a selected part or PCB. All market prices are dated references and must be refreshed before financial decisions.

This specification is a planning artifact. It does not establish customer demand, market price, hardware performance, profitability, payback or production readiness.
