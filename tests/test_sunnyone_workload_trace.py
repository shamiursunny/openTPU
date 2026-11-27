import hashlib
import json
import unittest

from tools.sunnyone.workload_trace import RequestSpec, WorkloadSpec, build_trace


def _request(request_id="r1", **overrides):
    values = {
        "request_id": request_id,
        "tenant_id": "tenant-a",
        "model_id": "model-x",
        "checkpoint_id": "checkpoint-sha",
        "tokenizer_id": "tokenizer-v1",
        "template_id": "chat-template-v1",
        "arrival_tick": 10,
        "prompt_tokens": 17,
        "max_new_tokens": 9,
        "quality_gate": "exact-reference-match",
        "seed": 7,
    }
    values.update(overrides)
    return RequestSpec(**values)


def _spec(*requests):
    return WorkloadSpec(
        scenario_id="W2-fixture",
        origin="synthetic_fixture",
        tick_unit="sim_tick",
        prefill_chunk_tokens=8,
        kv_page_tokens=16,
        scenario_seed=101,
        requests=tuple(requests or (_request(),)),
    )


class WorkloadTraceTests(unittest.TestCase):
    def test_trace_is_byte_deterministic_and_hash_is_replay_hash(self):
        a = build_trace(_spec(_request(), _request("r2", arrival_tick=10, prompt_tokens=5)))
        b = build_trace(_spec(_request(), _request("r2", arrival_tick=10, prompt_tokens=5)))
        self.assertEqual(a.to_jsonl(), b.to_jsonl())
        lines = a.to_jsonl().splitlines()
        header = json.loads(lines[0])
        event_body = "".join(line + "\n" for line in lines[1:])
        self.assertEqual(header["replay_sha256"], hashlib.sha256(event_body.encode()).hexdigest())
        self.assertEqual(header["event_count"], 2)

    def test_same_tick_events_have_documented_stable_order(self):
        r = _request(deadline_tick=10, cancel_tick=10, fault_tick=10, fault_kind="link_reset")
        trace = build_trace(_spec(r))
        self.assertEqual(
            [event.kind for event in trace.events],
            ["REQUEST_ARRIVAL", "REQUEST_FAULT", "REQUEST_CANCEL", "REQUEST_DEADLINE"],
        )
        self.assertEqual([event.sequence for event in trace.events], [0, 1, 2, 3])

    def test_event_order_is_stable_across_requests_at_same_tick(self):
        trace = build_trace(_spec(
            _request("first", arrival_tick=10, cancel_tick=10),
            _request("second", arrival_tick=10, cancel_tick=10),
        ))
        self.assertEqual(
            [(e.kind, e.request_id) for e in trace.events],
            [
                ("REQUEST_ARRIVAL", "first"),
                ("REQUEST_ARRIVAL", "second"),
                ("REQUEST_CANCEL", "first"),
                ("REQUEST_CANCEL", "second"),
            ],
        )

    def test_context_tokens_default_to_prompt_length(self):
        trace = build_trace(_spec(_request()))
        self.assertEqual(trace.events[0].payload["context_tokens"], 17)

    def test_trace_contains_no_invented_service_or_energy_values(self):
        trace = build_trace(_spec(_request()))
        encoded = trace.to_jsonl().lower()
        for forbidden in ("service_cycles", "bandwidth_bytes_per_tick", "joules", "watts", "temperature_c"):
            self.assertNotIn(forbidden, encoded)

    def test_duplicate_request_ids_are_rejected(self):
        with self.assertRaisesRegex(ValueError, "duplicate request_id"):
            build_trace(_spec(_request("same"), _request("same", arrival_tick=11)))

    def test_past_cancel_deadline_and_fault_events_are_rejected(self):
        for field, extra in (
            ("cancel_tick", {"cancel_tick": 9}),
            ("deadline_tick", {"deadline_tick": 9}),
            ("fault_tick", {"fault_tick": 9, "fault_kind": "timeout"}),
        ):
            with self.subTest(field=field), self.assertRaisesRegex(ValueError, field):
                build_trace(_spec(_request(**extra)))

    def test_boolean_is_not_accepted_as_integer_tick(self):
        with self.assertRaisesRegex(ValueError, "arrival_tick"):
            build_trace(_spec(_request(arrival_tick=True)))

    def test_fault_kind_requires_fault_tick(self):
        with self.assertRaisesRegex(ValueError, "fault_kind requires fault_tick"):
            build_trace(_spec(_request(fault_kind="memory_ecc")))

    def test_unknown_request_fields_are_rejected(self):
        value = {
            "request_id": "r1", "tenant_id": "t", "model_id": "m",
            "checkpoint_id": "c", "tokenizer_id": "tok", "template_id": "tpl",
            "arrival_tick": 0, "prompt_tokens": 1, "max_new_tokens": 1,
            "quality_gate": "q", "seed": 1, "fabricated_watts": 2,
        }
        with self.assertRaisesRegex(ValueError, "extra"):
            RequestSpec.from_dict(value)


if __name__ == "__main__":
    unittest.main()
