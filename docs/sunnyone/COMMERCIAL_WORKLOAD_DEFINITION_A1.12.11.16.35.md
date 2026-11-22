# SUNNYONE AI-X — A1.12.11.16.35 Commercial workload definition

Date: 2026-11-23
Status: hypothesis and test-plan baseline. No customer demand, willingness-to-pay, contracted volume or production workload has yet been verified.

## 1. Objective

Identify the first revenue-generating workload(s) for SUNNYONE before freezing compute, memory, power, cooling or board architecture. The initial product should solve a repeatable customer problem with measurable quality, latency, reliability and unit economics.

The workload shortlist below is a set of hypotheses for customer discovery, not a claim that these markets are validated or that customers have been secured.

## 2. Initial customer-segment hypotheses

### Segment A — Software companies and AI-enabled SaaS providers
Problem hypothesis: recurring inference costs for support assistants, workflow automation, summarisation, classification, extraction and retrieval-augmented generation (RAG).
Potential buyer: SaaS founder, CTO, engineering lead or platform owner.
Potential purchase: API usage, dedicated capacity or managed private inference.
Validation questions: current model/provider and monthly bill; volume and token mix; model quality; peak concurrency; latency target; data handling requirements; migration effort; price at which a paid pilot is viable.
Commercial risk: strong API/cloud competition, switching cost, reliability expectations and high price transparency.

### Segment B — Business process and customer-support operators
Problem hypothesis: high-volume text classification, response drafting, multilingual support assistance, call/chat summarisation and knowledge-base retrieval.
Potential buyer: contact-centre operator, BPO, customer-service director or enterprise IT lead.
Potential purchase: per-seat, per-interaction or reserved-capacity service.
Validation questions: languages and scripts required (including Bangla and English only where confirmed); daily interactions; peak concurrency; human-review rate; response-time target; accuracy and escalation requirements; data residency/security requirements; actual cost per resolved interaction.
Commercial risk: speech recognition/telephony integration and workflow adoption may cost more than inference itself. Speech/audio workloads are not assumed to be supported by the first accelerator.

### Segment C — Document-intensive organisations
Problem hypothesis: document classification, OCR-adjacent text extraction after OCR, form understanding, summarisation, search and RAG over internal documents.
Potential buyer: financial services, insurance, logistics, legal services, education or large administrative teams.
Potential purchase: private deployment, per-document processing or managed API.
Validation questions: document types, pages/month, OCR provider, language mix, structured output schema, error tolerance, human validation cost, retention/privacy, batch windows and seasonal peaks.
Commercial risk: OCR, document parsing, integrations, auditability and domain-specific accuracy may dominate total project cost. Vision/OCR is not presumed to run on the initial text accelerator.

### Segment D — AI developers and research teams
Problem hypothesis: affordable inference for open-weight models, evaluation, prototyping, embeddings, reranking and batch generation.
Potential buyer: AI startup, developer team, research lab or independent software company.
Potential purchase: usage-based API or hourly dedicated instance.
Validation questions: exact model, context length, quantisation tolerance, tokens/day, concurrency, acceptable latency, need for model fine-tuning, willingness to move from current GPU cloud and expected committed spend.
Commercial risk: highly price-sensitive customers, bursty usage, easy switching and established GPU marketplaces.

## 3. Initial workload profiles to benchmark

The following are workload profiles, not fixed model choices. Exact models and versions are selected only after customer discovery and reproducible benchmark availability.

| ID | Workload | Typical request pattern | Main hardware pressure | Initial priority |
|---|---|---|---|---|
| W1 | Small/medium instruct model serving | Interactive, short/medium context, mixed prefill and decode, concurrent sessions | Decode throughput, latency, KV cache and memory bandwidth | Highest |
| W2 | RAG generation with embeddings/reranking | Repeated prompts, retrieval, short/medium generation, caching opportunities | Prompt processing, cache locality, memory capacity and CPU/network | High |
| W3 | Batch document/text processing | Large queues, longer prompts, batch execution, less strict latency | Sustained throughput, memory capacity/bandwidth, storage and pipeline efficiency | High |
| W4 | Long-context / large-model serving | Long prompts, larger KV cache, long decode, multiple sessions | Memory capacity, bandwidth, KV cache movement and interconnect | Research / conditional |
| W5 | Code generation and reasoning | Longer outputs, variable reasoning tokens, interactive latency | Decode throughput, model quality, memory traffic and tail latency | Conditional |

W1/W2/W3 are the first benchmark candidates because they allow an initial service to be tested without assuming that the largest model or maximum RAM configuration is commercially necessary. W4 is the main reason to investigate 128 GB and 256 GB system memory, but the business case must demonstrate that customers need those workloads and that external DDR bandwidth can sustain them.

## 4. Benchmark workload specification

For each workload capture:

- model name, exact revision/checksum, architecture and parameter count;
- tokenizer revision and chat template;
- quantisation format, calibration method and quality baseline;
- input prompt token distribution (p50/p95/p99);
- output token distribution (p50/p95/p99);
- context length and KV-cache precision;
- request arrival pattern, concurrency and batch size;
- prefill and decode throughput separately;
- time-to-first-token and inter-token latency p50/p95/p99;
- useful output acceptance, task quality and error rate;
- wall power at idle, prefill, decode and mixed load;
- thermal state, throttling, uptime, failure and recovery;
- memory capacity used, peak KV cache, bandwidth and stall counters;
- cost per accepted request and per million useful tokens.

Run identical prompts, models, precision/quality targets, context, concurrency, arrival rates and measurement boundaries on competing systems. Preserve scripts, environment, raw output and logs.

## 5. Proposed initial model tiers

Do not hardcode model names until an up-to-date model shortlist is audited for licence, commercial-use rights, architecture, supported operators, quantisation, context, quality and hardware fit.

- Tier S: compact instruct model for classification, extraction and short responses.
- Tier M: medium instruct model for RAG, assistants and summarisation.
- Tier L: larger model for long-context and more demanding reasoning, only if customer economics justify it.

The accelerator should initially target reliable execution of a narrow, commercially useful set of operators and models. Broad model compatibility is a later gate, not an unsupported launch claim.

## 6. RAM capacity decision rule

Do not equate system RAM with accelerator high-bandwidth memory or assume a 128 GB DIMM makes a large model fast. External DDR capacity can hold weights and KV cache, but effective token generation also depends on sustained bandwidth, access pattern, controller efficiency, compute throughput, quantisation, interconnect and scheduling.

Evaluate three capacity points:
- Minimum viable: smallest configuration that passes the agreed W1/W2/W3 workloads and concurrency.
- 128 GB: target only if model residency, KV cache or concurrency materially improves accepted workload throughput or product capability.
- 256 GB: stretch only if a named customer workload requires it and exact device/package/controller/DIMM/PCB feasibility plus economics are demonstrated.

For each point calculate model residency, KV-cache capacity, sessions at target context, expected bandwidth demand, stalls, power, bill of materials and incremental revenue potential. Do not freeze a capacity based only on the desire for the largest number.

## 7. Commercial validation protocol

For each segment interview at least 5 relevant potential buyers as an initial discovery sample; this is a proposed learning target, not statistically representative market research. Record anonymised role, current solution, actual monthly spend or workload volume if voluntarily shared, pain point, quality/latency requirements, procurement constraints and next action.

Seek stronger evidence in this order:
1. documented problem and current workflow;
2. quantified workload and current cost;
3. explicit technical acceptance criteria;
4. written willingness to evaluate a pilot;
5. paid pilot or signed commercial commitment.

Do not treat compliments, survey interest, website traffic or non-binding conversations as revenue validation.

## 8. Business model comparison

For each qualified segment compare:
- managed inference API;
- dedicated/private inference deployment;
- hardware sale/lease/licence with support;
- hybrid capacity plus service.

Compare realised revenue per useful workload unit, variable cost, gross contribution, customer acquisition cost, sales cycle, support/integration effort, uptime obligations, working capital, churn and payback. Avoid counting hardware revenue and service revenue from the same capacity twice.

## 9. Initial decision hypotheses

These are provisional hypotheses to test, not final choices:
- First product candidate: managed inference API or dedicated inference for a narrow W1/W2/W3 workload.
- First technical baseline: compact and medium open-weight model serving, with a clearly specified quality baseline.
- First architecture optimisation: sustained decode efficiency and memory traffic, not peak TOPS.
- Memory: size from measured model/KV working set and revenue case; 128 GB target remains conditional.
- Power: no 30 W ceiling. Select the power envelope from measured full-system cost and incremental contribution.
- Production silicon: no commitment until prototype performance, customer demand, manufacturing costs and cash-flow model justify it.

## 10. Immediate actions

1. Build an interview list across the four segments; do not assume a segment is attractive before evidence.
2. Prepare a one-page workload questionnaire and customer discovery log.
3. Obtain actual workload traces or anonymised representative prompts where customers can lawfully share them.
4. Select one W1, one W2 and one W3 benchmark set, with exact open model revisions and licences checked.
5. Build a baseline benchmark harness and competitor comparison using rented GPUs before selecting a custom accelerator device.
6. Measure prefill/decode, latency, quality, power, memory and unit cost.
7. Feed measured values into COMMERCIAL_FEASIBILITY_TCO_MODEL.md and compare conservative/base/upside economics.
8. Down-select customer segment, first product, minimum viable memory and power envelope only after G0–G2 evidence.

## 11. Evidence status

| Item | Status |
|---|---|
| Four customer-segment hypotheses | Defined for discovery; not validated |
| W1–W5 workload profiles | Defined; not yet benchmarked |
| Initial W1/W2/W3 priority | Provisional engineering hypothesis |
| Exact models and licences | Not yet selected/audited |
| Customer interviews | Not yet conducted/recorded |
| Customer workload traces | Not obtained |
| Paid pilot / contract | Not verified |
| Competitor baseline under identical workload | Not run |
| RAM sizing from measured working set | Not completed |
| First product and revenue route | Not selected |
| TCO / break-even / payback | Not calculated |

This milestone defines the next evidence-gathering procedure. It does not claim a validated market, paying customers, benchmark results, selected production hardware or profitability.
