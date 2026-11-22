# SUNNYONE AI-X — Market reference update 2026-11-23

This addendum supersedes earlier unsourced or stale price examples in the commercial feasibility document where they conflict. Public list prices are snapshots, not actual procurement quotes or SUNNYONE revenue assumptions.

## 1. API price references

### OpenAI
The official API pricing page currently lists multiple model tiers and separate input, output, cached-input, speed/processing and regional rates. Examples shown on the retrieved page include:
- GPT-6.2 Sol: Standard $2 per million input tokens and $10 per million output tokens in the listed flagship table.
- GPT-6.2 Astra: Standard $8 input and $40 output per million tokens in that table.
- Lower-cost model tiers and special processing modes have materially different rates.

The pricing page also notes that tool calls and some tool content are billed separately, and regional processing may incur an uplift. Do not infer SUNNYONE's attainable price from these list prices. Source: https://developers.openai.com/api/docs/pricing (retrieved 2026-11-23).

### Google Gemini Developer API
The official pricing page retrieved on 2026-11-23 shows Gemini 4 Argon Standard paid pricing at $2 per million input and $10 per million output tokens through 2026-11-30, increasing to $4/$20 from 2026-12-01. Batch/Flex rates differ, and thinking tokens are included in output billing. This is a time-limited model-specific schedule, not a generic Gemini price. Source: https://ai.google.dev/gemini-api/docs/pricing (retrieved 2026-11-23).

Anthropic pricing must be refreshed directly from its official pricing page before inclusion in the comparison; no current Anthropic rate is asserted in this addendum.

## 2. GPU rental competition

Third-party comparisons retrieved 2026-11-23 show materially different results depending on providers and methodology:
- TensorCore November 22 tracker: H100 median $3.92/GPU-hour, lowest listed $1.80; H200 median $4.92; B200 median $7.84.
  Source: https://tensorcore.si/gpu-cloud-pricing/
- Uvik October 7 index: H100 SXM median $4.20/GPU-hour, H200 $5.70, B200 $8.19; H100 PCIe $2.89. It describes its methodology as on-demand list prices normalised per GPU, excluding tax.
  Source: https://uvik.net/blog/gpu-price-index/
- StackPath October 18 provider comparison: H100 median $5.33, H200 $6.30 and B200 $8.50 per GPU-hour across its selected provider sample.
  Source: https://stackpath.ie/global/gpu-prices
- Lambda's public pricing page lists H100 SXM at $4.69/GPU-hour and B200 SXM6 at $7.79/GPU-hour in the displayed instance table, plus tax.
  Source: https://lambda.com/pricing

These figures are not a single market-clearing price. GPU model/variant, host CPU/RAM, network, storage, minimum instance size, region, availability, commitment, spot/preemptibility and tax differ. For a credible competitor benchmark, select an actual provider configuration and capture its full checkout price and hardware specification.

## 3. Implication for SUNNYONE

The price spread is evidence of intense competition and different service bundles, not evidence that a custom accelerator can profitably undercut them. SUNNYONE must compare:
- delivered useful tokens and accepted task quality;
- input/output mix and model equivalence;
- sustained throughput at a stated latency and concurrency;
- complete service cost including CPU, memory, network, storage, cooling, support and idle capacity;
- utilisation and cash collection, not theoretical 100% use.

A custom accelerator business should not be approved on the basis of an H100 hourly price alone. Compare the cost of a full equivalent service, or a dedicated hardware sale with realistic warranty/support and customer integration costs.

## 4. Data status

| Input | Status |
|---|---|
| OpenAI API price list | Official public reference snapshot |
| Gemini API price list | Official public reference snapshot; model-specific scheduled price change |
| Anthropic API prices | Not refreshed in this update |
| H100/H200/B200 rental prices | Third-party indexes plus one provider page; not supplier quotations |
| Actual customer selling price | Unknown |
| Actual GPU purchase/lease quote | Unknown |
| Actual Bangladesh site tariff and demand charges | Not verified for a specific premises |
| SUNNYONE throughput, wall power and cost | Not measured |

No revenue forecast, margin, break-even or payback conclusion is supported by these market references alone.
