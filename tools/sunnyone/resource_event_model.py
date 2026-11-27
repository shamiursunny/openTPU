#!/usr/bin/env python3
"""Deterministic, profile-driven discrete-event model for SUNNYONE workload traces.

This is a queueing/resource model, not an RTL simulator or a silicon benchmark.
Every service duration and resource capacity must come from an explicit,
versioned profile. Synthetic profiles are suitable for tests only.
"""
from __future__ import annotations

import argparse
import hashlib
import heapq
import json
from collections import deque
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


def _positive_int(name: str, value: Any) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
        raise ValueError(f"{name} must be an integer > 0")
    return value


def _nonempty(name: str, value: Any) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f"{name} must be a non-empty string")
    return value


def _canonical(value: Any) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


@dataclass(frozen=True)
class StageProfile:
    name: str
    resource: str
    service_ticks_per_unit: int

    @classmethod
    def parse(cls, raw: Any) -> "StageProfile":
        if not isinstance(raw, dict) or set(raw) != {"name", "resource", "service_ticks_per_unit"}:
            raise ValueError("each stage requires exactly name, resource, service_ticks_per_unit")
        stage = cls(
            name=_nonempty("stage.name", raw["name"]),
            resource=_nonempty("stage.resource", raw["resource"]),
            service_ticks_per_unit=_positive_int("stage.service_ticks_per_unit", raw["service_ticks_per_unit"]),
        )
        return stage


@dataclass(frozen=True)
class ServiceProfile:
    profile_id: str
    version: str
    origin: str
    provenance: str
    tick_unit: str
    resources: dict[str, int]
    prefill: tuple[StageProfile, ...]
    decode: tuple[StageProfile, ...]

    @classmethod
    def from_dict(cls, raw: Any) -> "ServiceProfile":
        if not isinstance(raw, dict):
            raise ValueError("service profile must be an object")
        required = {"profile_id", "version", "origin", "provenance", "tick_unit", "resources", "prefill", "decode"}
        if set(raw) != required:
            raise ValueError(f"service profile fields mismatch; missing={sorted(required-set(raw))}, extra={sorted(set(raw)-required)}")
        origin = raw["origin"]
        if origin not in ("synthetic_fixture", "rtl_trace_calibrated", "measured_system"):
            raise ValueError("profile origin must be synthetic_fixture, rtl_trace_calibrated, or measured_system")
        resources_raw = raw["resources"]
        if not isinstance(resources_raw, dict) or not resources_raw:
            raise ValueError("resources must be a non-empty object")
        resources = {
            _nonempty("resource name", name): _positive_int(f"resources.{name}", capacity)
            for name, capacity in resources_raw.items()
        }
        phases: dict[str, tuple[StageProfile, ...]] = {}
        for phase in ("prefill", "decode"):
            stages_raw = raw[phase]
            if not isinstance(stages_raw, list) or not stages_raw:
                raise ValueError(f"{phase} must contain at least one stage")
            stages = tuple(StageProfile.parse(item) for item in stages_raw)
            for stage in stages:
                if stage.resource not in resources:
                    raise ValueError(f"stage {stage.name} references unknown resource {stage.resource}")
            phases[phase] = stages
        return cls(
            profile_id=_nonempty("profile_id", raw["profile_id"]),
            version=_nonempty("version", raw["version"]),
            origin=origin,
            provenance=_nonempty("provenance", raw["provenance"]),
            tick_unit=_nonempty("tick_unit", raw["tick_unit"]),
            resources=resources,
            prefill=phases["prefill"],
            decode=phases["decode"],
        )


@dataclass
class RequestState:
    request_id: str
    tenant_id: str
    arrival_tick: int
    prompt_tokens: int
    output_tokens: int
    phase: str = "PENDING"
    stage_index: int = 0
    unit_index: int = 0
    current_unit: int = 0
    enqueued_tick: int | None = None
    first_token_tick: int | None = None
    completion_tick: int | None = None
    deadline_missed: bool = False
    terminal_reason: str | None = None
    queue_wait_ticks: int = 0


@dataclass
class ResourceState:
    capacity: int
    waiting: deque[tuple[int, str, int, int]] = field(default_factory=deque)
    active: dict[str, tuple[int, int, int]] = field(default_factory=dict)
    busy_ticks: int = 0
    queue_wait_ticks: int = 0
    operations: int = 0


class ResourceEventModel:
    """FCFS resource model with deterministic event ordering and abort semantics."""

    def __init__(self, profile: ServiceProfile, prefill_chunk_tokens: int):
        self.profile = profile
        self.prefill_chunk_tokens = _positive_int("prefill_chunk_tokens", prefill_chunk_tokens)
        self.resources = {name: ResourceState(capacity) for name, capacity in profile.resources.items()}
        self.requests: dict[str, RequestState] = {}
        self._events: list[tuple[int, int, int, str, str, dict[str, Any]]] = []
        self._serial = 0
        self._now = 0
        self._trace_hash = ""
        self._started = False

    def _push(self, tick: int, priority: int, kind: str, request_id: str, payload: dict[str, Any]) -> None:
        heapq.heappush(self._events, (tick, priority, self._serial, kind, request_id, payload))
        self._serial += 1

    @staticmethod
    def _trace_lines(trace_text: str) -> tuple[dict[str, Any], list[dict[str, Any]]]:
        lines = [line for line in trace_text.splitlines() if line.strip()]
        if not lines:
            raise ValueError("trace is empty")
        records = [json.loads(line) for line in lines]
        header = records[0]
        if header.get("record_type") != "header" or header.get("schema_version") != 1:
            raise ValueError("unsupported workload trace header")
        if header.get("tick_unit") is None:
            raise ValueError("trace header is missing tick_unit")
        events = records[1:]
        if header.get("event_count") != len(events):
            raise ValueError("trace event_count does not match records")
        canonical_events = "".join(_canonical(event) + "\n" for event in events)
        digest = hashlib.sha256(canonical_events.encode("utf-8")).hexdigest()
        if header.get("replay_sha256") != digest:
            raise ValueError("trace replay_sha256 mismatch")
        previous: tuple[int, int] | None = None
        for index, event in enumerate(events):
            if not isinstance(event, dict):
                raise ValueError("trace event must be an object")
            tick, sequence = event.get("tick"), event.get("sequence")
            if isinstance(tick, bool) or not isinstance(tick, int) or tick < 0:
                raise ValueError("event tick must be a non-negative integer")
            if isinstance(sequence, bool) or not isinstance(sequence, int) or sequence != index:
                raise ValueError("event sequence must be contiguous from zero")
            order = (tick, sequence)
            if previous is not None and order < previous:
                raise ValueError("trace events are not ordered")
            previous = order
        return header, events

    def run(self, trace_text: str) -> dict[str, Any]:
        if self._started:
            raise RuntimeError("model instances are single-use")
        self._started = True
        header, events = self._trace_lines(trace_text)
        if header["tick_unit"] != self.profile.tick_unit:
            raise ValueError("trace and service profile tick_unit differ")
        self._trace_hash = header["replay_sha256"]
        chunk = _positive_int("trace prefill_chunk_tokens", header["prefill_chunk_tokens"])

        for event in events:
            kind = event.get("kind")
            if kind not in ("REQUEST_ARRIVAL", "REQUEST_CANCEL", "REQUEST_FAULT", "REQUEST_DEADLINE"):
                raise ValueError(f"unsupported exogenous event kind: {kind}")
            self._push(event["tick"], 10 + event["sequence"], kind, event.get("request_id", ""), event.get("payload", {}))

        while self._events:
            tick = self._events[0][0]
            self._now = tick
            batch: list[tuple[int, int, int, str, str, dict[str, Any]]] = []
            while self._events and self._events[0][0] == tick:
                batch.append(heapq.heappop(self._events))
            # Resource completions (priority 0) are handled before exogenous events.
            batch.sort(key=lambda item: (item[1], item[2]))
            for _, _, _, kind, request_id, payload in batch:
                if kind == "STAGE_COMPLETE":
                    self._complete_stage(request_id, payload)
                else:
                    self._handle_external(kind, request_id, payload, chunk)
            self._dispatch_all()

        return self._report()

    def _handle_external(self, kind: str, request_id: str, payload: dict[str, Any], chunk: int) -> None:
        if kind == "REQUEST_ARRIVAL":
            if request_id in self.requests:
                raise ValueError(f"duplicate arrival for request {request_id}")
            required = ("tenant_id", "prompt_tokens", "max_new_tokens")
            if any(name not in payload for name in required):
                raise ValueError(f"arrival payload missing one of {required}")
            prompt = _positive_int("prompt_tokens", payload["prompt_tokens"])
            output = _positive_int("max_new_tokens", payload["max_new_tokens"])
            state = RequestState(request_id, _nonempty("tenant_id", payload["tenant_id"]), self._now, prompt, output)
            self.requests[request_id] = state
            state.phase = "PREFILL"
            self._enqueue_next(state, chunk)
            return
        state = self.requests.get(request_id)
        if state is None or state.terminal_reason is not None:
            return
        if kind == "REQUEST_DEADLINE":
            state.deadline_missed = True
        elif kind in ("REQUEST_CANCEL", "REQUEST_FAULT"):
            self._abort_request(state, "cancelled" if kind == "REQUEST_CANCEL" else "faulted")

    def _phase_stages(self, state: RequestState) -> tuple[StageProfile, ...]:
        return self.profile.prefill if state.phase == "PREFILL" else self.profile.decode

    def _phase_units(self, state: RequestState, chunk: int) -> list[int]:
        if state.phase == "PREFILL":
            remaining = state.prompt_tokens - state.unit_index * chunk
            return [min(chunk, remaining)]
        return [1]

    def _enqueue_next(self, state: RequestState, chunk: int) -> None:
        if state.terminal_reason is not None:
            return
        if state.phase == "PREFILL" and state.unit_index * chunk >= state.prompt_tokens:
            state.phase, state.unit_index, state.stage_index = "DECODE", 0, 0
        elif state.phase == "DECODE" and state.unit_index >= state.output_tokens:
            state.terminal_reason = "completed"
            state.completion_tick = self._now
            return
        stages = self._phase_stages(state)
        if state.stage_index >= len(stages):
            state.stage_index = 0
            state.unit_index += 1
            self._enqueue_next(state, chunk)
            return
        units = self._phase_units(state, chunk)[0]
        stage = stages[state.stage_index]
        state.current_unit = units
        state.enqueued_tick = self._now
        resource = self.resources[stage.resource]
        resource.waiting.append((self._serial, state.request_id, units, self._now))
        self._serial += 1

    def _dispatch_all(self) -> None:
        for resource_name, resource in self.resources.items():
            while resource.waiting and len(resource.active) < resource.capacity:
                _serial, request_id, units, enqueued_tick = resource.waiting.popleft()
                state = self.requests.get(request_id)
                if state is None or state.terminal_reason is not None:
                    continue
                stage = self._phase_stages(state)[state.stage_index]
                duration = stage.service_ticks_per_unit * units
                start = self._now
                end = start + duration
                resource.active[request_id] = (end, start, units)
                resource.busy_ticks += duration
                resource.queue_wait_ticks += start - enqueued_tick
                resource.operations += 1
                state.queue_wait_ticks += start - enqueued_tick
                self._push(end, 0, "STAGE_COMPLETE", request_id, {"resource": resource_name, "stage": stage.name, "units": units})

    def _complete_stage(self, request_id: str, payload: dict[str, Any]) -> None:
        state = self.requests.get(request_id)
        resource = self.resources[payload["resource"]]
        active = resource.active.pop(request_id, None)
        if active is None or state is None or state.terminal_reason is not None:
            return
        if state.phase == "DECODE" and state.first_token_tick is None:
            state.first_token_tick = self._now
        state.stage_index += 1
        # Completion schedules the next stage/unit at the same integer tick.
        self._enqueue_next(state, self._trace_chunk)

    def _abort_request(self, state: RequestState, reason: str) -> None:
        state.terminal_reason = reason
        # Abort immediately releases any active resource and invalidates its queued completion.
        for resource in self.resources.values():
            resource.active.pop(state.request_id, None)
            if resource.waiting:
                resource.waiting = deque(item for item in resource.waiting if item[1] != state.request_id)

    def _report(self) -> dict[str, Any]:
        end_tick = max((state.completion_tick or self._now for state in self.requests.values()), default=self._now)
        request_rows = []
        for state in sorted(self.requests.values(), key=lambda item: item.request_id):
            request_rows.append({
                "request_id": state.request_id,
                "tenant_id": state.tenant_id,
                "status": state.terminal_reason or "incomplete",
                "arrival_tick": state.arrival_tick,
                "first_token_tick": state.first_token_tick,
                "completion_tick": state.completion_tick,
                "ttft_ticks": None if state.first_token_tick is None else state.first_token_tick - state.arrival_tick,
                "completion_latency_ticks": None if state.completion_tick is None else state.completion_tick - state.arrival_tick,
                "queue_wait_ticks": state.queue_wait_ticks,
                "deadline_missed": state.deadline_missed,
            })
        resource_rows = {}
        for name, resource in self.resources.items():
            denom = end_tick * resource.capacity
            resource_rows[name] = {
                "capacity": resource.capacity,
                "busy_ticks": resource.busy_ticks,
                "utilisation_fraction": None if denom == 0 else resource.busy_ticks / denom,
                "queue_wait_ticks": resource.queue_wait_ticks,
                "operations": resource.operations,
            }
        counts = {status: sum(row["status"] == status for row in request_rows) for status in ("completed", "cancelled", "faulted", "incomplete")}
        return {
            "record_type": "resource_model_report",
            "model_kind": "deterministic_profile_driven_queueing_model",
            "profile": {
                "profile_id": self.profile.profile_id,
                "version": self.profile.version,
                "origin": self.profile.origin,
                "provenance": self.profile.provenance,
                "tick_unit": self.profile.tick_unit,
            },
            "trace_replay_sha256": self._trace_hash,
            "end_tick": end_tick,
            "request_counts": counts,
            "deadline_missed_count": sum(row["deadline_missed"] for row in request_rows),
            "resources": resource_rows,
            "requests": request_rows,
            "limitations": [
                "queueing-model output, not RTL simulation or silicon measurement",
                "no power, energy, thermal, area, or manufacturing-cost inference",
                "profile service durations and capacities are explicit inputs, not inferred",
                "no preemption, batching, cache, bank-conflict, or DRAM timing model unless separately represented in a future profile/model",
            ],
        }

    @classmethod
    def from_files(cls, trace_path: str | Path, profile_path: str | Path) -> "ResourceEventModel":
        raw = json.loads(Path(profile_path).read_text(encoding="utf-8"))
        profile = ServiceProfile.from_dict(raw)
        trace_text = Path(trace_path).read_text(encoding="utf-8")
        header, _ = cls._trace_lines(trace_text)
        model = cls(profile, header["prefill_chunk_tokens"])
        model._trace_chunk = header["prefill_chunk_tokens"]
        return model

    def run_file(self, trace_path: str | Path) -> dict[str, Any]:
        return self.run(Path(trace_path).read_text(encoding="utf-8"))


def load_profile(path: str | Path) -> ServiceProfile:
    return ServiceProfile.from_dict(json.loads(Path(path).read_text(encoding="utf-8")))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("trace", help="workload trace JSONL")
    parser.add_argument("--profile", required=True, help="explicit versioned service profile JSON")
    parser.add_argument("-o", "--output", required=True, help="JSON report output")
    args = parser.parse_args(argv)
    trace_text = Path(args.trace).read_text(encoding="utf-8")
    header, _ = ResourceEventModel._trace_lines(trace_text)
    model = ResourceEventModel(load_profile(args.profile), header["prefill_chunk_tokens"])
    report = model.run(trace_text)
    Path(args.output).write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"requests={len(report['requests'])} completed={report['request_counts']['completed']} trace={report['trace_replay_sha256']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
