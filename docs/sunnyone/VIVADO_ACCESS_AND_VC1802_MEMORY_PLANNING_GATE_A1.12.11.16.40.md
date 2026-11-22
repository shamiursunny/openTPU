# A1.12.11.16.40 — VC1802 Vivado Access and Memory-Planning Gate

Date: 2026-11-23  
Status: **BLOCKED — tool/licence access and device-specific implementation not verified**  
Target branch: `sunnyone/commercial-profitability-architecture-2026-11-23`

## Decision summary

The VC1802 / VSVD1760 remains a **provisional feasibility candidate only**. Do not claim that the four-DDRMC, 128 GB configuration is validated, and do not order a device, DIMMs, PCB or development board.

AMD's current 2026.1 licensing material establishes:
- Versal Adaptive SoC devices, including Versal AI Core, are not available in BASIC or CORE tiers.
- PRO, ENTERPRISE and GOLD tiers support Versal devices.
- AMD's published PRO price is USD 2,400 node-locked / USD 3,000 floating (annual subscription); confirm current quote, tax, region, terms and exact SKU with AMD before budgeting.
- AMD documents a one-time 60-day evaluation entitlement with access to all devices and features. It is a temporary feasibility route, not a sustainable free licence.
- Existing pre-2026.1 licences and release compatibility have separate rules; do not infer that a free old Standard licence can implement VC1802 merely because the old device catalogue lists it.

Official sources:
- https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/licensing-faq.html
- https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado/vivado-licensing-options.html
- https://docs.amd.com/r/2026.1-English/ug973-vivado-release-notes-install-license/Device-Availability-by-Subscription-Tier
- https://docs.amd.com/r/2025.2-English/ug973-vivado-release-notes-install-license/Supported-Devices

## Local tool-access check

A shell availability check in the current execution environment found no `vivado`, `v++` or `xsct` executable and no standard `/tools/Xilinx/Vivado*` or `/opt/Xilinx/Vivado*` installation path. This only describes the current execution environment; it does not prove that the user has no separate workstation, licence or AMD account.

No Vivado project, IP configuration, generated XDC, DRC, implementation, bitstream or package-pin validation was produced in this milestone.

## Cost-controlled route

1. **Do not purchase PRO yet.** First obtain written confirmation of the exact device support, required Vivado/Vitis versions, IP entitlements and total cost from AMD or an authorised distributor.
2. If an eligible one-time AMD 60-day evaluation is available and not previously consumed, use it only after confirming the exact VC1802 / VSVD1760 flow and required IP are included. Reserve the evaluation window for a prepared, bounded feasibility run.
3. Otherwise seek a legitimate university/AMD University Program or partner lab route only if the project genuinely qualifies; do not represent a personal commercial project as academic research to obtain a licence.
4. Compare the full PRO licence cost with access to an authorised lab/consultant. Do not upload confidential project material or credentials to an untrusted third party.
5. No licence purchase, paid lab booking or cloud spend is authorised by this document.

## Required Vivado acceptance gates

All gates must be captured as reproducible project files and logs:

- [ ] Confirm exact orderable device/package string and supported Vivado release.
- [ ] Open a clean project targeting the exact VC1802 / VSVD1760 device.
- [ ] Confirm all four integrated DDRMC instances are exposed and their complete pin groups are package-legal and non-conflicting.
- [ ] Configure each DDRMC as a 64-bit data + 8-bit ECC channel, one slot, one 32 GB 2-rank x8 DDR4 RDIMM, subject to IP support.
- [ ] Check whether the selected AMD NoC/DDRMC IP actually supports the proposed RDIMM topology, SPD fields, rank organisation, ECC/parity, DBI/DM, voltage and timing.
- [ ] Set the highest rate supported by the exact device/IP/module combination; 2933 MT/s is a planning target from DS957, not a guaranteed configuration.
- [ ] Generate IP output products and constraints; run validation, DRC and pin/clock checks. Save the complete reports.
- [ ] Check PCIe/CPM and Ethernet/GTY lane allocation together against the exact package pin map. Do not assume all interfaces can be simultaneously routed.
- [ ] Record implementation feasibility, resource utilisation, timing, power estimates and any licensing restrictions. Estimates are not physical measurements.
- [ ] Re-run after any IP, tool, package, DIMM or PCB change.

## Memory BOM status

The proposed topology remains a hypothesis:
- 4 × independent 64-bit data / 72-bit ECC channels.
- 1 × 32 GB, 2-rank x8 RDIMM per controller; one DIMM slot per controller.
- Aggregate capacity: 128 GB.
- Lenovo references 4ZC7A15123 and 4X77A12188 are candidate module references only. No supplier confirmation, full module datasheet review, SPD compatibility, AMD validation or purchase quote is recorded.

Before BOM approval, obtain the complete manufacturer datasheet and SPD details for the exact SKU/revision, confirm x8 DRAM device organisation and rank/die layout, confirm voltage/timing/ECC/parity/DBI requirements, and get a written compatibility response from AMD or the board/FPGA design authority. A Lenovo server memory listing is not proof of Versal compatibility.

## Alternatives and stop conditions

- VC1902 / VSVD1760 remains a higher-compute alternative; it is not automatically better value. Compare actual workload fit, quoted device/board cost, licence, power and implementation risk.
- If VC1802 requires an unaffordable tool licence or inaccessible design flow, pause this candidate. Do not substitute an unverified pinout or claim memory-controller feasibility.
- A cheaper FPGA family may be used for a reduced RTL/software prototype, but it cannot validate Versal-specific DDRMC, NoC, CPM or package integration.
- Do not claim 128 GB is usable until Vivado IP configuration, board-level electrical design, memory training and physical hardware tests succeed.

## Current milestone outcome

**Completed:** authoritative licensing gate researched; current shell checked for AMD tool executables; implementation blockers and cost-controlled next steps recorded.

**Not completed:** Vivado project/IP generation, exact pin validation, DIMM compatibility, supplier quote, PCIe/Ethernet pin allocation, DRC, implementation, power analysis, physical memory training or hardware qualification.
