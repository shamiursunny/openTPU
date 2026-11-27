# SUNNYONE structural SCC and synthesized-latch audit — 2026-11-27

Repository: shamiursunny/openTPU
Branch: sunnyone/commercial-profitability-architecture-2026-11-23
Primary successful run: 45913401437 (commit 2e63dc43f1ab56f2b587c854fdf1dda86f606e0e)
Independent repeat: 45913488085 (commit 0d2221e728c8201e9cb9ae5ce8ff340dea07d7f6)
Toolchain: pinned OSS CAD Suite 2026-11-23; Yosys 0.71+77 with Slang.

## Method

For each elaborated top, the audit runs:
`read_slang -D SYNTHESIS --ignore-assertions --ignore-initial`,
`hierarchy -check`, `proc`, `flatten`, `opt`, then:
- `select -list t:$dlatch t:$adlatch t:$dlatchsr`
- `scc -expect 0`

The behavioral `otpu_dram` model uses associative arrays unsupported by the synthesis frontend. In the two-slice structural check it is replaced with a blackbox matching the exact module header. This isolates the external DRAM behavior while retaining the real `otpu_top`, two `otpu_slice` instances, `otpu_coll` arbitration and internal grant/control logic.

## Results

<badge>2/2 elaborated tops PASS</badge>

| Elaborated top | Relevant logic | SCCs | Inferred latch cells |
|---|---|---:|---:|
| `otpu_xrst_top` / one-copy slice | VPU `gnt`, TMEM `pq`, slice grant paths | 0 | 0 |
| `otpu_top`, S=2 | Multi-slice collective `sc_gl` and slice grants | 0 | 0 |

Both runs report:
- `Found 0 SCCs` in the elaborated module.
- `Found and expected 0 SCCs`.
- Empty latch-cell selection files (0 bytes).

## Interpretation and scope

The Verilator `UNOPTFLAT` paths for `gnt`, `pq` and `sc_gl` do not correspond to actual combinational strongly connected components in the two tested elaborated configurations. The warnings remain in Verilator output, but the structural evidence supports classifying these three as tool dependency/partitioning over-approximations for the tested configurations, not as confirmed logic loops.

The seven generic Verilator `LATCH` diagnostics likewise did not produce inferred `$dlatch`/`$adlatch`/`$dlatchsr` cells in these two synthesis elaborations. This does not prove latch absence in every ASIC-specific configuration.

The separate ASIC configuration lint also reported an `aok` UNOPTFLAT diagnostic. `otpu_asic_top` was not one of the two tops in this audit; the `aok` path remains OPEN and must not be classified as a false positive yet.

The two-slice audit blackboxes the behavioral DRAM model. It proves the selected internal collective/grant paths without claiming to analyze the model's associative-array behavior. It is a structural SCC check, not formal equivalence, timing closure or CDC/RDC signoff.

## Reproducible evidence

- Run 45913401437: 2/2 tops pass, artifact 15160673532.
- Run 45913488085: independent repeat, 2/2 tops pass.
- Artifact 15160673532 includes both Yosys logs, the generated slice harness, the exact blackbox DRAM header and empty latch selection files.
- The first attempts exposed frontend limitations: unsupported behavioral associative arrays and unsupported `$fatal` in `initial`. The audit now uses a blackboxed behavioral DRAM boundary and `--ignore-initial`; this does not suppress the combinational netlist SCC pass.

## Remaining work

1. Structural SCC check for ASIC `aok` path using the actual ASIC top and memory/technology blackboxes.
2. Width warning closure: 76 generic full-chip width warnings plus additional ASIC DMA/native-DRAM/AXI elaboration warnings.
3. Explicit zero-extension cleanup for the 33-bit per-DIMM MIG address outputs feeding the 34-bit host mux interface, with existing high-bit-zero test retained.
4. Formal/SVA and CDC/RDC verification.
5. Manufacturer handoff remains NOT READY.


## Additional ASIC-top structural result — 2026-11-27

The ASIC-top structural stage in reset/SCC workflow 45914912691 completed successfully. Artifact 15162062669 was downloaded and inspected. The audit used the actual `otpu_asic_top` source closure for the `card` configuration from `tools/asic/flow.py`, with SRAM macro boundaries blackboxed and real ASIC control/slice logic retained.

Terminal structural results:
- `otpu_xrst_top` / one-copy slice: 0 SCCs; 0 inferred latch cells.
- `otpu_top`, S=2: 0 SCCs; 0 inferred latch cells.
- `otpu_asic_top`: 0 SCCs; 0 inferred latch cells.

All three logs report `Found 0 SCCs` and `Found and expected 0 SCCs`; all three latch selection files are empty (0 bytes). This covers the ASIC `aok` warning path in the tested card configuration. The Verilator `UNOPTFLAT aok` diagnostic remains a warning, but it is not backed by a structural combinational SCC in this elaborated ASIC netlist; classify it as a dependency/partitioning over-approximation for this configuration, not as a confirmed loop.

The same workflow's reset/power-up stage passed 4/4 tests. Scope remains limited to these elaborated configurations; this is not formal equivalence, timing signoff, CDC/RDC or production qualification.

Earlier statement in this report that ASIC `aok` was OPEN is superseded by this terminal ASIC-top result.