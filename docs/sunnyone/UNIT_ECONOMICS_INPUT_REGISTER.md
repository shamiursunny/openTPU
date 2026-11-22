# SUNNYONE Unit Economics — Evidence Input Register

Leave unknowns blank. Every populated value requires source, date, unit, geography, confidence, and classification as measured value, quote, invoice, contract, or explicit scenario assumption.

| Input | Value | Unit | Evidence class | Source/date | Confidence | Notes |
|---|---:|---|---|---|---|---|
| Initial hardware/development capex | | USD or BDT | unknown | | | Separate R&D, prototype, board, assembly and test |
| Monthly site/hosting fixed cost | | currency/month | unknown | | | |
| Electricity tariff | | currency/kWh | unknown | | | Obtain actual premises tariff and bill |
| Average measured wall power | | kW | unknown | | | Calibrated meter, complete system boundary |
| Cooling overhead | | kWh or % | unknown | | | Avoid double-counting if wall boundary includes cooling |
| Monthly paid utilisation | | % | unknown | | | Contracted/paid usage, not theoretical maximum |
| Realised revenue per million input tokens | | currency/M tokens | unknown | | | Contracted and collected price |
| Realised revenue per million output tokens | | currency/M tokens | unknown | | | Contracted and collected price |
| Accepted useful tokens/month | | tokens | unknown | | | Quality-filtered |
| Cloud comparator cost | | currency/hour | quote/invoice | | | Match full node specification and billing |
| Network/storage/egress | | currency/month | unknown | | | |
| Support/maintenance/replacement reserve | | currency/month | unknown | | | |
| Financing cash payment | | currency/month | unknown | | | Include fees and terms |
| Customer collection delay | | days | unknown | | | Working-capital impact |

## Calculations
- Electricity = measured wall kW × operating hours × tariff; add cooling only if excluded from wall measurement.
- Variable cost per accepted unit = attributable variable costs / accepted billable units.
- Contribution per unit = realised collected price − variable cost per unit.
- Break-even units = monthly fixed costs / contribution per unit, only if contribution is positive.
- Break-even utilisation = break-even units / technically saleable units at the SLA.
- Monthly operating cash flow = collected cash revenue − operating costs − financing cash payments.
- Payback = first month cumulative net project cash flow recovers initial investment, including ramp-up, working capital, collection delays and replacement capex.

Build downside, conservative, base and upside scenarios. Never assume 100% utilisation or guaranteed customers. Keep API service, hardware sale/lease/licensing and hybrid revenue streams separate to avoid double counting. A scenario assumption is not market evidence.
