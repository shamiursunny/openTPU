"""Schema and determinism checks for the committed W1/W2/W3 workload fixtures."""
import json
import unittest
from pathlib import Path

from tools.sunnyone.workload_trace import WorkloadSpec, build_trace

FIXTURES = Path(__file__).resolve().parents[1] / "workloads" / "sunnyone"


class SunnyoneWorkloadScenarioTests(unittest.TestCase):
    def _load(self, name):
        raw = json.loads((FIXTURES / name).read_text(encoding="utf-8"))
        spec = WorkloadSpec.from_dict(raw)
        return spec, build_trace(spec)

    def test_w1_single_request_is_valid_and_deterministic(self):
        spec, trace = self._load("W1_single_request.json")
        self.assertEqual(spec.scenario_id, "W1_single_request")
        self.assertEqual(len(spec.requests), 1)
        self.assertEqual([event.kind for event in trace.events], ["REQUEST_ARRIVAL"])
        self.assertEqual(trace.to_jsonl(), build_trace(spec).to_jsonl())

    def test_w2_mixed_concurrency_has_staggered_arrivals_and_multiple_tenants(self):
        spec, trace = self._load("W2_mixed_concurrency.json")
        self.assertEqual(spec.scenario_id, "W2_mixed_concurrency")
        self.assertEqual(len(spec.requests), 4)
        self.assertEqual([event.tick for event in trace.events], [0, 4, 8, 12])
        self.assertEqual(len({request.tenant_id for request in spec.requests}), 3)
        self.assertEqual(trace.to_jsonl(), build_trace(spec).to_jsonl())

    def test_w3_burst_exercises_queue_pressure_and_control_events(self):
        spec, trace = self._load("W3_burst_cancel_fault.json")
        self.assertEqual(spec.scenario_id, "W3_burst_cancel_fault")
        self.assertEqual(len(spec.requests), 10)
        self.assertEqual(sum(event.kind == "REQUEST_CANCEL" for event in trace.events), 1)
        self.assertEqual(sum(event.kind == "REQUEST_FAULT" for event in trace.events), 1)
        self.assertEqual(sum(event.kind == "REQUEST_DEADLINE" for event in trace.events), 1)
        arrivals = [event for event in trace.events if event.kind == "REQUEST_ARRIVAL"]
        self.assertEqual([event.sequence for event in arrivals], list(range(10)))
        self.assertEqual(trace.to_jsonl(), build_trace(spec).to_jsonl())


if __name__ == "__main__":
    unittest.main()
