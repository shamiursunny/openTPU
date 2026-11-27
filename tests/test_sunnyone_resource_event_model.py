import json
import unittest

from tools.sunnyone.resource_event_model import ResourceEventModel, ServiceProfile
from tools.sunnyone.workload_trace import RequestSpec, WorkloadSpec, build_trace


def request(request_id, arrival=0, prompt=4, output=2, **extra):
    data = {
        "request_id": request_id,
        "tenant_id": "tenant-" + request_id,
        "model_id": "model-fixture",
        "checkpoint_id": "checkpoint-fixture",
        "tokenizer_id": "tokenizer-fixture",
        "template_id": "template-fixture",
        "arrival_tick": arrival,
        "prompt_tokens": prompt,
        "max_new_tokens": output,
        "quality_gate": "fixture-only",
        "seed": 1,
    }
    data.update(extra)
    return RequestSpec(**data)


def trace(*requests, chunk=2):
    spec = WorkloadSpec(
        scenario_id="resource-model-test",
        origin="synthetic_fixture",
        tick_unit="sim_tick",
        prefill_chunk_tokens=chunk,
        kv_page_tokens=16,
        scenario_seed=1,
        requests=tuple(requests),
    )
    return build_trace(spec).to_jsonl()


def profile(prefill_ticks=2, decode_ticks=3, capacity=1):
    return ServiceProfile.from_dict({
        "profile_id": "unit-test-profile",
        "version": "1",
        "origin": "synthetic_fixture",
        "provenance": "unit-test fixture only; not hardware measurements",
        "tick_unit": "sim_tick",
        "resources": {"shared_engine": capacity},
        "prefill": [{
            "name": "prefill_fixture",
            "resource": "shared_engine",
            "service_ticks_per_unit": prefill_ticks,
        }],
        "decode": [{
            "name": "decode_fixture",
            "resource": "shared_engine",
            "service_ticks_per_unit": decode_ticks,
        }],
    })


class ResourceEventModelTests(unittest.TestCase):
    def test_single_request_prefill_chunks_and_decode_are_sequential(self):
        report = ResourceEventModel(profile(), 2).run(trace(request("r1", prompt=4, output=2)))
        row = report["requests"][0]
        self.assertEqual(row["status"], "completed")
        self.assertEqual(row["first_token_tick"], 11)
        self.assertEqual(row["completion_tick"], 14)
        self.assertEqual(row["ttft_ticks"], 11)
        self.assertEqual(row["completion_latency_ticks"], 14)
        self.assertEqual(report["resources"]["shared_engine"]["busy_ticks"], 14)
        self.assertAlmostEqual(report["resources"]["shared_engine"]["utilisation_fraction"], 1.0)

    def test_fifo_order_is_deterministic_for_simultaneous_arrivals(self):
        report = ResourceEventModel(profile(prefill_ticks=1, decode_ticks=1), 2).run(
            trace(request("r1", prompt=2, output=1), request("r2", prompt=2, output=1))
        )
        rows = {row["request_id"]: row for row in report["requests"]}
        self.assertEqual(rows["r1"]["first_token_tick"], 5)
        self.assertEqual(rows["r2"]["first_token_tick"], 6)
        self.assertEqual(rows["r1"]["completion_tick"], 5)
        self.assertEqual(rows["r2"]["completion_tick"], 6)

    def test_cancelled_queued_request_never_uses_resource(self):
        report = ResourceEventModel(profile(prefill_ticks=5, decode_ticks=1), 2).run(
            trace(request("r1", prompt=2, output=1), request("r2", prompt=2, output=1, cancel_tick=2))
        )
        rows = {row["request_id"]: row for row in report["requests"]}
        self.assertEqual(rows["r2"]["status"], "cancelled")
        self.assertEqual(rows["r1"]["status"], "completed")
        self.assertEqual(report["resources"]["shared_engine"]["operations"], 2)

    def test_cancelled_active_operation_releases_resource_at_cancel_tick(self):
        report = ResourceEventModel(profile(prefill_ticks=5, decode_ticks=1), 2).run(
            trace(request("r1", prompt=2, output=1, cancel_tick=3))
        )
        row = report["requests"][0]
        self.assertEqual(row["status"], "cancelled")
        self.assertEqual(report["end_tick"], 3)
        self.assertEqual(report["resources"]["shared_engine"]["busy_ticks"], 3)

    def test_fault_aborts_active_request_and_is_counted(self):
        report = ResourceEventModel(profile(prefill_ticks=5), 2).run(
            trace(request("r1", prompt=2, output=1, fault_tick=2, fault_kind="link_reset"))
        )
        self.assertEqual(report["request_counts"]["faulted"], 1)
        self.assertEqual(report["resources"]["shared_engine"]["busy_ticks"], 2)

    def test_deadline_is_reported_without_implicitly_cancelling(self):
        report = ResourceEventModel(profile(prefill_ticks=1, decode_ticks=1), 2).run(
            trace(request("r1", prompt=2, output=1, deadline_tick=1))
        )
        self.assertEqual(report["request_counts"]["completed"], 1)
        self.assertEqual(report["deadline_missed_count"], 1)

    def test_resource_capacity_allows_parallel_slots(self):
        report = ResourceEventModel(profile(prefill_ticks=2, decode_ticks=2, capacity=2), 2).run(
            trace(request("r1", prompt=2, output=1), request("r2", prompt=2, output=1))
        )
        rows = {row["request_id"]: row for row in report["requests"]}
        self.assertEqual(rows["r1"]["completion_tick"], 6)
        self.assertEqual(rows["r2"]["completion_tick"], 6)

    def test_trace_hash_tampering_is_rejected(self):
        lines = trace(request("r1")).splitlines()
        header = json.loads(lines[0])
        header["replay_sha256"] = "0" * 64
        lines[0] = json.dumps(header)
        with self.assertRaisesRegex(ValueError, "replay_sha256"):
            ResourceEventModel(profile(), 2).run("\n".join(lines))

    def test_unknown_resource_is_rejected(self):
        raw = {
            "profile_id": "bad", "version": "1", "origin": "synthetic_fixture",
            "provenance": "test", "tick_unit": "sim_tick", "resources": {"mxu": 1},
            "prefill": [{"name": "p", "resource": "missing", "service_ticks_per_unit": 1}],
            "decode": [{"name": "d", "resource": "mxu", "service_ticks_per_unit": 1}],
        }
        with self.assertRaisesRegex(ValueError, "unknown resource"):
            ServiceProfile.from_dict(raw)

    def test_missing_or_zero_service_time_is_rejected(self):
        raw = {
            "profile_id": "bad", "version": "1", "origin": "synthetic_fixture",
            "provenance": "test", "tick_unit": "sim_tick", "resources": {"mxu": 1},
            "prefill": [{"name": "p", "resource": "mxu", "service_ticks_per_unit": 0}],
            "decode": [{"name": "d", "resource": "mxu", "service_ticks_per_unit": 1}],
        }
        with self.assertRaisesRegex(ValueError, "service_ticks_per_unit"):
            ServiceProfile.from_dict(raw)

    def test_tick_unit_mismatch_is_rejected(self):
        raw = profile().__dict__.copy()
        raw["tick_unit"] = "other_tick"
        with self.assertRaisesRegex(ValueError, "tick_unit differ"):
            ResourceEventModel(ServiceProfile.from_dict(raw), 2).run(trace(request("r1")))

    def test_model_instances_are_single_use(self):
        model = ResourceEventModel(profile(), 2)
        workload = trace(request("r1"))
        model.run(workload)
        with self.assertRaisesRegex(RuntimeError, "single-use"):
            model.run(workload)

    def test_report_labels_synthetic_profile_and_excludes_power_claims(self):
        report = ResourceEventModel(profile(), 2).run(trace(request("r1")))
        self.assertEqual(report["profile"]["origin"], "synthetic_fixture")
        self.assertIn("not RTL simulation", report["limitations"][0])
        self.assertNotIn("joules_per_token", report)
        self.assertNotIn("watts", report)


if __name__ == "__main__":
    unittest.main()
