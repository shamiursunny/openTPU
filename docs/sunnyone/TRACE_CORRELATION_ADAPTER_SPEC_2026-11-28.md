# SUNNYONE trace correlation adapter — evidence contract

Date: 2026-11-28

## Purpose

\`tools/sunnyone/trace_correlation.py\` correlates the slice's \`+trace\` instruction events with the slice's \`+tmtrace\` TMEM event stream. It is an evidence adapter, not a hardware simulator, performance model or power estimator.

## Source-grounded record mapping

- Hardware \`D/S/G/E\` events provide dispatch PC/opcode/slot, ready/start unit, optional MXU release and completion cycle.
- TMEM kind 4 records provide unit, opcode, the command's \`w6[23:16]\` field, flags and the sequencer instruction count. Kind 5 records provide unit completion.
- TMEM kinds 0/1 are read/write port records with lane masks; kinds 2/3 are one-lane MXU read/write records. Kind 6 records encode denied groups in DMA, COLL, VPU, MXU, QUANT order.
- Both traces use the slice cycle counter. Instruction intervals are matched only when slice, unit, opcode, start cycle and completion cycle agree exactly.
- Unit read-port mapping is MXU, DMA, QUANT, VPU, VPU, QUANT, QUANT, COLL. Write-port mapping is DMA, MXU, COLL, VPU.

## Conservative access attribution

An access is assigned to a TMEM instruction only if exactly one closed interval for its unit contains the access strictly between start and completion. Accesses at either boundary, during overlapping intervals, or during an interval with no observed completion are not force-assigned; they are reported separately. This avoids claiming an instruction/request identity that the trace does not prove.

The report preserves unmatched hardware starts, unmatched TMEM starts, incomplete intervals, ambiguous matches, completion-cycle mismatches, unmatched accesses and arbitration-loss events. It hashes the supplied configuration and accepts the exact source commit and trace-file hashes as provenance.

## Explicit limits

The TMEM records do not contain a workload request ID or hardware trace slot. The tool therefore does **not** attribute traffic to W1/W2/W3 request IDs. The tool does not infer service times, calibrated resource capacity, silicon throughput, power, energy, thermal behaviour or manufacturing cost. Every report is marked \`not_calibrated\` and \`profile_eligible=false\`.

## Invocation

\`\`\`bash
python -m tools.sunnyone.trace_correlation \\
  --hardware-trace /path/to/rtl-trace.txt \\
  --tmem-trace /path/to/tmem-trace.tt \\
  --source-commit <exact-40-character-source-commit> \\
  --config-json /path/to/exact-config.json \\
  --slice-id 0 --segment-index 0 \\
  --output /path/to/correlation.json
\`\`\`

For multi-slice co-simulation, the slice trace file is the \`+tmtrace\` file with the corresponding \`.sid\` suffix. Appended simulations are selected by segment index. A trace cycle counter wrap is rejected rather than silently sorted.
