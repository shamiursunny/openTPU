"""Tests for conservative SUNNYONE hardware/TMEM trace correlation."""
import struct
import unittest

from tools.sunnyone.trace_correlation import correlate, read_tmem_segments


SHA = "a" * 40
CONFIG = {"S": 1, "D": 32, "MCOLS": 8}


def record(cycle, kind, port=0, lanes=0, value=0, opcode=0, field=0, flags=0):
    info = ((opcode & 0xFF) << 24) | ((field & 0xFF) << 16) | \
           ((flags & 0xFF) << 8) | ((lanes & 0xFF) << 8) | \
           ((port & 0xF) << 4) | (kind & 0xF)
    return (cycle, info, value)


def hardware(events):
    return "\n".join(events) + "\n"


class TraceCorrelationTests(unittest.TestCase):
    def test_exact_interval_and_accesses_match(self):
        hw = hardware([
            "T0 D c=2 s=3 pc=12 op=20 w1=00000000 w2=00000010 w3=00000020",
            "T0 S c=4 s=3 u=1 r=3",
            "T0 E c=9 s=3",
        ])
        tm = [
            record(4, 4, port=1, lanes=0x03, opcode=0x20, field=2, flags=0x03, value=7),
            record(5, 0, port=0, lanes=0x05, value=100),
            record(6, 1, port=1, lanes=0x01, value=200),
            record(7, 6, lanes=0x08),
            record(9, 5, port=1),
        ]
        report = correlate(hw, tm, source_commit=SHA, config=CONFIG)
        self.assertEqual(report["correlation"]["matched_instruction_intervals"], 1)
        self.assertEqual(report["correlation"]["unmatched_tmem_starts"], 0)
        self.assertEqual(report["tmem_activity"]["accesses"]["assigned_records"], 2)
        self.assertEqual(report["tmem_activity"]["accesses"]["read_words"], 2)
        self.assertEqual(report["tmem_activity"]["accesses"]["write_words"], 1)
        self.assertEqual(report["tmem_activity"]["lost_groups"]["assigned"], 1)
        inst = report["correlation"]["instructions"][0]
        self.assertEqual(inst["unit"], "MXU")
        self.assertEqual(inst["accesses"]["read_words"], 2)
        self.assertEqual(inst["accesses"]["write_words"], 1)
        self.assertFalse(report["attribution_limits"]["request_level_available"])
        self.assertFalse(report["calibration"]["profile_eligible"])

    def test_start_cycle_mismatch_is_not_force_matched(self):
        hw = hardware([
            "T0 D c=1 s=0 pc=4 op=10 w1=0 w2=0 w3=0",
            "T0 S c=2 s=0 u=0 r=2",
            "T0 E c=8 s=0",
        ])
        tm = [record(3, 4, port=0, opcode=0x10, value=1), record(8, 5, port=0)]
        report = correlate(hw, tm, source_commit=SHA, config=CONFIG)
        self.assertEqual(report["correlation"]["matched_instruction_intervals"], 0)
        self.assertEqual(report["correlation"]["unmatched_tmem_starts"], 1)
        self.assertEqual(report["correlation"]["unmatched_hardware_starts"], 1)

    def test_overlapping_same_unit_intervals_are_ambiguous(self):
        tm = [
            record(2, 4, port=1, opcode=0x20, value=1),
            record(5, 4, port=1, opcode=0x20, value=2),
            record(8, 5, port=1),
            record(10, 5, port=1),
            record(6, 0, port=0, lanes=1, value=32),
        ]
        report = correlate("", tm, source_commit=SHA, config=CONFIG)
        self.assertEqual(report["tmem_activity"]["accesses"]["ambiguous_records"], 1)
        self.assertEqual(report["tmem_activity"]["accesses"]["assigned_records"], 0)

    def test_cycle_boundary_access_is_not_force_assigned(self):
        tm = [
            record(2, 4, port=1, opcode=0x20, value=1),
            record(8, 5, port=1),
            record(2, 0, port=0, lanes=1, value=32),
        ]
        report = correlate("", tm, source_commit=SHA, config=CONFIG)
        self.assertEqual(report["tmem_activity"]["accesses"]["boundary_records"], 1)
        self.assertEqual(report["tmem_activity"]["accesses"]["assigned_records"], 0)

    def test_open_interval_access_is_not_force_assigned(self):
        tm = [
            record(2, 4, port=1, opcode=0x20, value=1),
            record(4, 0, port=0, lanes=1, value=32),
        ]
        report = correlate("", tm, source_commit=SHA, config=CONFIG)
        self.assertEqual(report["tmem_activity"]["accesses"]["incomplete_interval_records"], 1)
        self.assertEqual(report["tmem_trace"]["incomplete_intervals"], 1)

    def test_binary_segments_are_split_at_kind_15_markers(self):
        rows = [
            (0, 15, 0),
            record(1, 4, port=0, opcode=0x10, value=1),
            (0, 15, 0),
            record(2, 5, port=0),
        ]
        raw = b"".join(struct.pack("<III", *row) for row in rows)
        self.assertEqual(read_tmem_segments(raw), [[rows[1]], [rows[3]]])

    def test_cycle_wrap_is_rejected(self):
        tm = [
            record(0xFFFFFFFE, 4, port=0, opcode=0x10, value=1),
            record(1, 5, port=0),
        ]
        with self.assertRaisesRegex(ValueError, "moved backwards"):
            correlate("", tm, source_commit=SHA, config=CONFIG)

    def test_invalid_provenance_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "40-character"):
            correlate("", [], source_commit="not-a-sha", config=CONFIG)
        with self.assertRaisesRegex(ValueError, "non-empty JSON object"):
            correlate("", [], source_commit=SHA, config={})


if __name__ == "__main__":
    unittest.main()
