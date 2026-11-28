"""One small RTL co-simulation proving the hardware/TMEM trace join."""
import hashlib
import json
import os
import shutil
import tempfile
import unittest
from pathlib import Path

import numpy as np

from opentpu import Config, isa as I, rtlsim
from tools.sunnyone.trace_correlation import correlate, read_tmem_segments


@unittest.skipUnless(shutil.which("verilator"), "Verilator is required for RTL co-simulation")
class TraceCorrelationRTLTests(unittest.TestCase):
    def test_dma_ld_trace_matches_hardware_and_tmem_intervals(self):
        cfg = Config(S=1)
        program = [I.ld(0, 0, 256), I.halt()]
        image = np.zeros(1 << 20, dtype=np.uint8)

        with tempfile.TemporaryDirectory(prefix="sunnyone-trace-") as directory:
            tmem_path = Path(directory) / "tmem.tt"
            _, _, stats = rtlsim.run(
                cfg, [program], [image], trace=True,
                plusargs=[f"+tmtrace={tmem_path}"],
            )
            hardware_trace = stats["trace"]
            raw_tmem = tmem_path.read_bytes()
            segments = read_tmem_segments(raw_tmem)
            self.assertEqual(len(segments), 1)

            report = correlate(
                hardware_trace, segments[0],
                source_commit=os.environ.get("GITHUB_SHA", "0" * 40),
                config={"S": cfg.S, "D": cfg.D, "MCOLS": cfg.MCOLS,
                        "ACT_ROWS": cfg.act_rows, "TMEM_IMPL": 0},
                slice_id=0, segment_index=0,
                hardware_trace_sha256=hashlib.sha256(hardware_trace.encode()).hexdigest(),
                tmem_trace_sha256=hashlib.sha256(raw_tmem).hexdigest(),
            )

        print("TRACE_DEBUG_HARDWARE\\n" + hardware_trace)
        print("TRACE_DEBUG_TMEM", [(c, info & 15, (info >> 4) & 15, (info >> 24) & 255, value)
                                  for c, info, value in segments[0]])
        print("TRACE_DEBUG_CORRELATION", json.dumps(report["correlation"], sort_keys=True))
        self.assertEqual(report["correlation"]["matched_instruction_intervals"], 1, json.dumps(report["correlation"], sort_keys=True))
        self.assertEqual(report["correlation"]["unmatched_tmem_starts"], 0)
        self.assertEqual(report["correlation"]["unmatched_hardware_starts"], 0)
        self.assertGreater(report["tmem_activity"]["accesses"]["write_words"], 0)
        self.assertGreater(report["tmem_activity"]["by_port"]["write"]["DMA"]["assigned_words"], 0)
        self.assertFalse(report["calibration"]["profile_eligible"])


if __name__ == "__main__":
    unittest.main()
