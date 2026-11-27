#!/usr/bin/env python3
"""Deterministic exogenous request traces for SUNNYONE inference workload experiments.

This module records workload inputs only. It does not estimate hardware service times,
performance, power, energy, temperature or customer demand. Those require separate,
versioned profiles and evidence.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

SCHEMA_VERSION = 1
_EVENT_ORDER = {
    "REQUEST_ARRIVAL": 0,
    "REQUEST_FAULT": 1,
    "REQUEST_CANCEL": 2,
    "REQUEST_DEADLINE": 3,
}


def _integer(name: str, value: Any, minimum: int = 0) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < minimum:
        raise ValueError(f"{name} must be an integer >= {minimum}")
    return value


def _text(name: str, value: Any) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f"{name} must be a non-empty string")
    return value


@dataclass(frozen=True)
class RequestSpec:
    request_id: str
    tenant_id: str
    model_id: str
    checkpoint_id: str
    tokenizer_id: str
    template_id: str
    arrival_tick: int
    prompt_tokens: int
    max_new_tokens: int
    quality_gate: str
    seed: int
    context_tokens: int | None = None
    priority: int = 0
    deadline_tick: int | None = None
    cancel_tick: int | None = None
    fault_tick: int | None = None
    fault_kind: str | None = None
    batch_key: str | None = None
    cache_key: str | None = None

    def validate(self) -> None:
        for name in ("request_id", "tenant_id", "model_id", "checkpoint_id",
                     "tokenizer_id", "template_id", "quality_gate"):
            _text(name, getattr(self, name))
        _integer("arrival_tick", self.arrival_tick)
        _integer("prompt_tokens", self.prompt_tokens, 1)
        _integer("max_new_tokens", self.max_new_tokens, 1)
        _integer("seed", self.seed)
        if isinstance(self.priority, bool) or not isinstance(self.priority, int):
            raise ValueError("priority must be an integer")
        if self.context_tokens is not None:
            _integer("context_tokens", self.context_tokens, 1)
        for name in ("deadline_tick", "cancel_tick", "fault_tick"):
            value = getattr(self, name)
            if value is not None:
                _integer(name, value)
                if value < self.arrival_tick:
                    raise ValueError(f"{name} cannot precede arrival_tick")
        if self.fault_tick is None and self.fault_kind is not None:
            raise ValueError("fault_kind requires fault_tick")
        if self.fault_tick is not None:
            _text("fault_kind", self.fault_kind)
        for name in ("batch_key", "cache_key"):
            value = getattr(self, name)
            if value is not None:
                _text(name, value)

    @classmethod
    def from_dict(cls, value: dict[str, Any]) -> "RequestSpec":
        if not isinstance(value, dict):
            raise ValueError("each request must be an object")
        allowed = set(cls.__dataclass_fields__)
        extra = set(value) - allowed
        missing = {"request_id", "tenant_id", "model_id", "checkpoint_id",
                   "tokenizer_id", "template_id", "arrival_tick", "prompt_tokens",
                   "max_new_tokens", "quality_gate", "seed"} - set(value)
        if extra or missing:
            raise ValueError(f"request fields invalid; missing={sorted(missing)}, extra={sorted(extra)}")
        request = cls(**value)
        request.validate()
        return request


@dataclass(frozen=True)
class WorkloadSpec:
    scenario_id: str
    origin: str
    tick_unit: str
    prefill_chunk_tokens: int
    kv_page_tokens: int
    scenario_seed: int
    requests: tuple[RequestSpec, ...]

    def validate(self) -> None:
        _text("scenario_id", self.scenario_id)
        if self.origin not in ("synthetic_fixture", "anonymised_customer_trace", "benchmark_trace"):
            raise ValueError("origin must identify a synthetic fixture, anonymised customer trace, or benchmark trace")
        _text("tick_unit", self.tick_unit)
        _integer("prefill_chunk_tokens", self.prefill_chunk_tokens, 1)
        _integer("kv_page_tokens", self.kv_page_tokens, 1)
        _integer("scenario_seed", self.scenario_seed)
        if not self.requests:
            raise ValueError("workload must contain at least one request")
        seen: set[str] = set()
        for request in self.requests:
            request.validate()
            if request.request_id in seen:
                raise ValueError(f"duplicate request_id: {request.request_id}")
            seen.add(request.request_id)

    @classmethod
    def from_dict(cls, value: dict[str, Any]) -> "WorkloadSpec":
        if not isinstance(value, dict):
            raise ValueError("workload must be an object")
        allowed = {"scenario_id", "origin", "tick_unit", "prefill_chunk_tokens",
                   "kv_page_tokens", "scenario_seed", "requests"}
        extra = set(value) - allowed
        missing = allowed - set(value)
        if extra or missing:
            raise ValueError(f"workload fields invalid; missing={sorted(missing)}, extra={sorted(extra)}")
        requests = value["requests"]
        if not isinstance(requests, list):
            raise ValueError("requests must be a list")
        spec = cls(
            scenario_id=value["scenario_id"],
            origin=value["origin"],
            tick_unit=value["tick_unit"],
            prefill_chunk_tokens=value["prefill_chunk_tokens"],
            kv_page_tokens=value["kv_page_tokens"],
            scenario_seed=value["scenario_seed"],
            requests=tuple(RequestSpec.from_dict(item) for item in requests),
        )
        spec.validate()
        return spec


@dataclass(frozen=True)
class TraceEvent:
    tick: int
    sequence: int
    kind: str
    request_id: str
    payload: dict[str, Any]


@dataclass(frozen=True)
class WorkloadTrace:
    header: dict[str, Any]
    events: tuple[TraceEvent, ...]

    @property
    def replay_sha256(self) -> str:
        body = "".join(_canonical(asdict(event)) + "\n" for event in self.events)
        return hashlib.sha256(body.encode("utf-8")).hexdigest()

    def to_jsonl(self) -> str:
        header = dict(self.header)
        header["replay_sha256"] = self.replay_sha256
        lines = [_canonical(header)]
        lines.extend(_canonical(asdict(event)) for event in self.events)
        return "\n".join(lines) + "\n"

    def write(self, path: str | Path) -> None:
        Path(path).write_text(self.to_jsonl(), encoding="utf-8")


def _canonical(value: Any) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def build_trace(spec: WorkloadSpec) -> WorkloadTrace:
    """Expand request-level exogenous events with stable same-timestamp ordering."""
    spec.validate()
    pending: list[tuple[int, int, int, str, str, dict[str, Any]]] = []
    for request_order, request in enumerate(spec.requests):
        request_payload = asdict(request)
        if request.context_tokens is None:
            request_payload["context_tokens"] = request.prompt_tokens
        pending.append((request.arrival_tick, _EVENT_ORDER["REQUEST_ARRIVAL"],
                        request_order, "REQUEST_ARRIVAL", request.request_id, request_payload))
        if request.fault_tick is not None:
            pending.append((request.fault_tick, _EVENT_ORDER["REQUEST_FAULT"],
                            request_order, "REQUEST_FAULT", request.request_id,
                            {"fault_kind": request.fault_kind}))
        if request.cancel_tick is not None:
            pending.append((request.cancel_tick, _EVENT_ORDER["REQUEST_CANCEL"],
                            request_order, "REQUEST_CANCEL", request.request_id, {}))
        if request.deadline_tick is not None:
            pending.append((request.deadline_tick, _EVENT_ORDER["REQUEST_DEADLINE"],
                            request_order, "REQUEST_DEADLINE", request.request_id, {}))

    pending.sort(key=lambda item: item[:3] + (item[1],))
    events = tuple(
        TraceEvent(tick=tick, sequence=sequence, kind=kind, request_id=request_id, payload=payload)
        for sequence, (tick, _priority, _request_order, kind, request_id, payload)
        in enumerate(pending)
    )
    header = {
        "record_type": "header",
        "schema_version": SCHEMA_VERSION,
        "scenario_id": spec.scenario_id,
        "origin": spec.origin,
        "tick_unit": spec.tick_unit,
        "scenario_seed": spec.scenario_seed,
        "prefill_chunk_tokens": spec.prefill_chunk_tokens,
        "kv_page_tokens": spec.kv_page_tokens,
        "request_count": len(spec.requests),
        "event_count": len(events),
        "event_order": ["tick", "kind_priority", "request_input_order", "sequence"],
    }
    return WorkloadTrace(header=header, events=events)


def load_spec(path: str | Path) -> WorkloadSpec:
    return WorkloadSpec.from_dict(json.loads(Path(path).read_text(encoding="utf-8")))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("spec", help="JSON workload specification")
    parser.add_argument("-o", "--output", required=True, help="output JSONL trace")
    args = parser.parse_args(argv)
    trace = build_trace(load_spec(args.spec))
    trace.write(args.output)
    print(f"events={len(trace.events)} replay_sha256={trace.replay_sha256}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
