#!/usr/bin/env python3
"""Structural combinational SCC and synthesized-latch audit for slice and multi-slice paths.

Uses the same pinned Yosys+Slang frontend as tools/reset_audit.py. The netlists are flattened
before Yosys' SCC pass; sequential cells break paths. This is a structural check, not timing or
formal equivalence.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import reset_audit as R  # noqa: E402


def run_scc(name: str, script: str, work: Path) -> bool:
    log = work / f"{name}.log"
    latch_list = work / f"{name}.latches.txt"
    try:
        R._yosys(script.format(latches=latch_list), log, name)
    except RuntimeError as exc:
        print(f"FAIL {name}: {exc}", file=sys.stderr)
        if log.exists():
            print(f"--- {name} Yosys log tail ---", file=sys.stderr)
            print("\n".join(log.read_text(errors="replace").splitlines()[-100:]), file=sys.stderr)
        return False
    latches = latch_list.read_text(errors="replace").strip() if latch_list.exists() else ""
    if latches:
        print(f"FAIL {name}: synthesized latch cells found:\n{latches}", file=sys.stderr)
        return False
    print(f"PASS {name}: zero combinational SCCs and zero inferred latch cells")
    return True


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--keep", type=Path, default=Path("/tmp/sunnyone-scc"))
    a = ap.parse_args(argv)
    work = a.keep
    work.mkdir(parents=True, exist_ok=True)
    results: list[bool] = []

    # One-copy slice: includes the VPU grant and TMEM read-port vector paths.
    top = work / "copy_slice_top.sv"
    top.write_text(R.harness(R.CONFIGS["copy"]))
    files = " ".join(str(R.RTL / f) for f in R.CORE) + f" {top}"
    slice_script = (
        f"read_slang -D SYNTHESIS --ignore-assertions --top otpu_xrst_top {files}; "
        "hierarchy -check -top otpu_xrst_top; proc; flatten; opt; "
        "tee -o {latches} select -list t:$dlatch t:$adlatch t:$dlatchsr; scc -expect 0"
    )
    results.append(run_scc("copy_slice", slice_script, work))

    # Two-slice top: exercises the local collective grant (sc_gl) through the real otpu_coll
    # arbitration. AXI=0 keeps the native memory adapter out; memories remain inferred cells.
    top_files = [R.RTL / f for f in R.CORE]
    # The behavioural DRAM uses associative arrays unsupported by the Slang synthesis
    # frontend. Blackbox this external memory boundary; the collective/grant paths under test
    # are entirely inside otpu_top/otpu_slice and do not traverse the DRAM model.
    dram_src = (R.RTL / "mem/otpu_dram.sv").read_text()
    header_end = dram_src.index(");\n", dram_src.index("module otpu_dram")) + 3
    dram_stub = work / "otpu_dram_blackbox.sv"
    dram_header = dram_src[dram_src.index("module otpu_dram"):header_end]
    dram_stub.write_text("(* blackbox *) " + dram_header + "\nendmodule\n")
    top_files += [
        R.RTL / "mem/otpu_native_dram.sv",
        R.RTL / "mem/otpu_xstg.sv",
        R.RTL / "top/otpu_top.sv",
    ]
    gp = {
        "NC": 1, "S": 2, "D": 32, "MCOLS": 2, "ACT_BLOCKS": 32, "ACT_ROWS": 2,
        "TMEM_WORDS": 16384, "IMEM_WORDS": 8192, "DRAM_WORDS": 4096,
        "FIFO_DEPTH": 64, "LANES": 8, "WIN": 16, "RPB": 64, "WPB": 1,
        "MXU_IMPL": 0, "AXI": 0, "TMEM_IMPL": 0, "COLL_GATHER": 1, "COLL_HUB": 0,
    }
    params = " ".join(f"-G {k}={v}" for k, v in gp.items())
    top_files.append(dram_stub)
    files = " ".join(map(str, top_files))
    top_script = (
        f"read_slang -D SYNTHESIS --ignore-assertions --top otpu_top {files} {params}; "
        "hierarchy -check -top otpu_top; proc; flatten; opt; "
        "tee -o {latches} select -list t:$dlatch t:$adlatch t:$dlatchsr; scc -expect 0"
    )
    results.append(run_scc("two_slice_top", top_script, work))

    passed = sum(results)
    print(f"Structural SCC audit: {passed}/{len(results)} elaborated tops have zero combinational SCCs")
    return 0 if all(results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
