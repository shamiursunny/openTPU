"""Loss-aware correlation of the slice instruction trace and TMEM access trace.

This tool correlates only exact unit/start/opcode/completion intervals. TMEM accesses do not
carry a workload request ID or sequencer slot, so request-level attribution is deliberately
not inferred. Cycle-boundary and overlapping intervals remain unassigned/ambiguous.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import struct
import sys
from collections import defaultdict
from pathlib import Path
from typing import Iterable, Sequence

_EVENT = re.compile(r"^T(\d+) ([DSEGHUPQ]) c=(\d+)(.*)$")
_KV = re.compile(r"(\w+)=([0-9a-fA-F]+)")
_READ_PORT_UNIT = (1, 0, 2, 3, 3, 2, 2, 4)  # MXU DMA Q VPU VPU Q Q COLL
_WRITE_PORT_UNIT = (0, 1, 4, 3)             # DMA MXU COLL VPU
_LOSS_GROUP_UNIT = (0, 4, 3, 1, 2)          # DMA COLL VPU MXU QUANT
_UNIT_NAMES = ("DMA", "MXU", "QUANT", "VPU", "COLL")


def read_tmem_segments(data: bytes) -> list[list[tuple[int, int, int]]]:
    """Decode little-endian {cycle, info, value} records, split at kind-15 markers."""
    if len(data) % 12:
        raise ValueError("TMEM trace length is not a whole number of 12-byte records")
    records = list(struct.iter_unpack("<III", data))
    segments: list[list[tuple[int, int, int]]] = []
    current: list[tuple[int, int, int]] | None = None
    for row in records:
        rec = (int(row[0]), int(row[1]), int(row[2]))
        if (rec[1] & 0xF) == 15:
            if current is not None:
                segments.append(current)
            current = []
        else:
            if current is None:
                current = []
            current.append(rec)
    if current is not None:
        segments.append(current)
    return segments


def _parse_hardware_trace(trace: str, slice_id: int) -> tuple[list[dict], dict]:
    instructions: list[dict] = []
    active: dict[int, dict] = {}
    anomalies: dict[str, int] = defaultdict(int)
    event_cycles: list[int] = []
    for line_no, line in enumerate(trace.splitlines(), 1):
        match = _EVENT.match(line.strip())
        if not match:
            continue
        sid, kind, cyc_s, tail = match.groups()
        if int(sid) != slice_id or kind not in "DSEG":
            continue
        cycle = int(cyc_s)
        event_cycles.append(cycle)
        kv = dict(_KV.findall(tail))
        if kind == "D":
            try:
                slot, pc, opcode = int(kv["s"]), int(kv["pc"]), int(kv["op"], 16)
            except (KeyError, ValueError) as exc:
                raise ValueError(f"malformed hardware D event at line {line_no}") from exc
            if slot in active:
                anomalies["slot_reused_before_E"] += 1
                active.pop(slot)
            rec = {
                "hardware_id": len(instructions), "slice": slice_id, "slot": slot,
                "pc": pc, "opcode": opcode, "dispatch_cycle": cycle,
                "ready_cycle": None, "unit": None, "start_cycle": None,
                "grant_cycle": None, "done_cycle": None,
            }
            instructions.append(rec)
            active[slot] = rec
        elif kind == "S":
            try:
                slot, unit, ready = int(kv["s"]), int(kv["u"]), int(kv["r"])
            except (KeyError, ValueError) as exc:
                raise ValueError(f"malformed hardware S event at line {line_no}") from exc
            rec = active.get(slot)
            if rec is None:
                anomalies["S_without_open_D"] += 1
            elif rec["start_cycle"] is not None:
                anomalies["duplicate_S_for_slot"] += 1
            else:
                rec["unit"], rec["start_cycle"], rec["ready_cycle"] = unit, cycle, ready
        elif kind == "G":
            try:
                slot = int(kv["s"])
            except (KeyError, ValueError) as exc:
                raise ValueError(f"malformed hardware G event at line {line_no}") from exc
            rec = active.get(slot)
            if rec is None:
                anomalies["G_without_open_D"] += 1
            else:
                rec["grant_cycle"] = cycle
        else:  # E
            try:
                slot = int(kv["s"])
            except (KeyError, ValueError) as exc:
                raise ValueError(f"malformed hardware E event at line {line_no}") from exc
            rec = active.pop(slot, None)
            if rec is None:
                anomalies["E_without_open_D"] += 1
            else:
                rec["done_cycle"] = cycle
    return instructions, {
        "event_count": len(event_cycles),
        "cycle_range": [min(event_cycles), max(event_cycles)] if event_cycles else None,
        "open_slots_at_end": sorted(active),
        "anomalies": dict(sorted(anomalies.items())),
    }


def _decode_tmem(records: Sequence[Sequence[int]]) -> tuple[list[dict], list[dict], dict]:
    starts: dict[int, list[dict]] = defaultdict(list)
    dones: dict[int, list[dict]] = defaultdict(list)
    accesses: list[dict] = []
    losses: list[dict] = []
    anomalies: dict[str, int] = defaultdict(int)
    cycles: list[int] = []
    previous = None

    for index, row in enumerate(records):
        if len(row) != 3:
            raise ValueError(f"TMEM record {index} is not a three-word record")
        cycle, info, value = (int(row[0]), int(row[1]), int(row[2]))
        if any(x < 0 or x > 0xFFFFFFFF for x in (cycle, info, value)):
            raise ValueError(f"TMEM record {index} contains a non-uint32 field")
        if previous is not None and cycle < previous:
            raise ValueError("TMEM trace cycle counter moved backwards or wrapped")
        previous = cycle
        cycles.append(cycle)
        kind, port, lanes = info & 0xF, (info >> 4) & 0xF, (info >> 8) & 0xFF

        if kind == 4:
            if port >= len(_UNIT_NAMES):
                anomalies["invalid_start_unit"] += 1
                continue
            starts[port].append({
                "cycle": cycle, "unit": port, "opcode": (info >> 24) & 0xFF,
                "field_23_16": (info >> 16) & 0xFF, "flags": lanes,
                "instruction_count": value, "record_index": index,
            })
        elif kind == 5:
            if port >= len(_UNIT_NAMES):
                anomalies["invalid_done_unit"] += 1
                continue
            dones[port].append({"cycle": cycle, "unit": port, "record_index": index})
        elif kind in (0, 1, 2, 3):
            write = kind in (1, 3)
            mapping = _WRITE_PORT_UNIT if write else _READ_PORT_UNIT
            if port >= len(mapping):
                anomalies["invalid_access_port"] += 1
                continue
            if kind in (0, 1):
                lane_count = lanes.bit_count()
                if lane_count == 0:
                    anomalies["zero_lane_access"] += 1
                    continue
                word_count = lane_count
            else:
                if lanes == 0 or lanes & (lanes - 1):
                    anomalies["non_one_hot_scattered_lane"] += 1
                    continue
                word_count = 1
            accesses.append({
                "cycle": cycle, "unit": mapping[port], "port": port,
                "write": write, "kind": kind, "words": word_count,
                "address": value, "record_index": index,
            })
        elif kind == 6:
            for group in range(len(_LOSS_GROUP_UNIT)):
                if (lanes >> group) & 1:
                    losses.append({
                        "cycle": cycle, "unit": _LOSS_GROUP_UNIT[group],
                        "group": group, "record_index": index,
                    })
        elif kind != 15:
            anomalies["unknown_record_kind"] += 1

    intervals: list[dict] = []
    orphan_dones = 0
    incomplete = 0
    for unit in range(len(_UNIT_NAMES)):
        unit_starts, unit_dones = starts[unit], dones[unit]
        for i, start in enumerate(unit_starts):
            done = unit_dones[i] if i < len(unit_dones) else None
            if done is None:
                incomplete += 1
            elif done["cycle"] < start["cycle"]:
                anomalies["done_before_start"] += 1
            elif done["cycle"] == start["cycle"]:
                anomalies["zero_duration_interval"] += 1
            intervals.append({
                "tmem_id": -1, **start,
                "done_cycle": done["cycle"] if done else None,
                "done_record_index": done["record_index"] if done else None,
                "hardware_id": None, "correlation_status": "unmatched",
                "accesses": {"read_records": 0, "read_words": 0,
                             "write_records": 0, "write_words": 0},
            })
        orphan_dones += max(0, len(unit_dones) - len(unit_starts))

    intervals.sort(key=lambda x: (x["cycle"], x["record_index"], x["unit"]))
    for index, interval in enumerate(intervals):
        interval["tmem_id"] = index
    return intervals, accesses + [{"_loss": x} for x in losses], {
        "record_count": len(records),
        "start_count": sum(map(len, starts.values())),
        "done_count": sum(map(len, dones.values())),
        "access_record_count": len(accesses),
        "loss_unit_events": len(losses),
        "incomplete_intervals": incomplete,
        "orphan_done_events": orphan_dones,
        "cycle_range": [min(cycles), max(cycles)] if cycles else None,
        "anomalies": dict(sorted(anomalies.items())),
    }


def _owner(cycle: int, unit: int, intervals: Sequence[dict]) -> tuple[str, dict | None]:
    inside, boundary, open_intervals = [], [], []
    for interval in intervals:
        if interval["unit"] != unit:
            continue
        start, done = interval["cycle"], interval["done_cycle"]
        if done is None:
            if cycle == start:
                boundary.append(interval)
            elif cycle > start:
                open_intervals.append(interval)
        elif start < cycle < done:
            inside.append(interval)
        elif cycle == start or cycle == done:
            boundary.append(interval)
    if len(inside) == 1 and not boundary and not open_intervals:
        return "assigned", inside[0]
    if len(inside) > 1 or (inside and (boundary or open_intervals)):
        return "ambiguous", None
    if boundary:
        return ("boundary" if len(boundary) == 1 else "ambiguous"), None
    if open_intervals:
        return ("incomplete_interval" if len(open_intervals) == 1 else "ambiguous"), None
    return "unassigned", None


def correlate(
    hardware_trace: str,
    tmem_records: Sequence[Sequence[int]],
    *,
    source_commit: str,
    config: dict,
    slice_id: int = 0,
    segment_index: int = 0,
    hardware_trace_sha256: str | None = None,
    tmem_trace_sha256: str | None = None,
) -> dict:
    """Correlate exact instruction intervals and conservatively attribute TMEM events."""
    if not re.fullmatch(r"[0-9a-fA-F]{40}", source_commit):
        raise ValueError("source_commit must be a 40-character Git commit SHA")
    if not isinstance(config, dict) or not config:
        raise ValueError("config must be a non-empty JSON object")
    if slice_id < 0 or segment_index < 0:
        raise ValueError("slice_id and segment_index must be non-negative")

    hw, hw_meta = _parse_hardware_trace(hardware_trace, slice_id)
    intervals, events, tm_meta = _decode_tmem(tmem_records)
    starts_by_key: dict[tuple[int, int, int], list[dict]] = defaultdict(list)
    for item in hw:
        if item["unit"] is not None and item["start_cycle"] is not None:
            starts_by_key[(item["unit"], item["start_cycle"], item["opcode"])].append(item)

    matched = 0
    start_matched = 0
    unmatched_tmem = 0
    ambiguous_starts = 0
    completion_mismatches = 0
    for interval in intervals:
        key = (interval["unit"], interval["cycle"], interval["opcode"])
        candidates = starts_by_key.get(key, [])
        if len(candidates) == 1:
            candidate = candidates[0]
            interval["hardware_id"] = candidate["hardware_id"]
            start_matched += 1
            if interval["done_cycle"] is not None and candidate["done_cycle"] is not None:
                if interval["done_cycle"] == candidate["done_cycle"]:
                    interval["correlation_status"] = "matched"
                    matched += 1
                    candidate["correlation_status"] = "matched"
                else:
                    interval["correlation_status"] = "completion_cycle_mismatch"
                    candidate["correlation_status"] = "completion_cycle_mismatch"
                    completion_mismatches += 1
            else:
                interval["correlation_status"] = "incomplete_pair"
                candidate["correlation_status"] = "incomplete_pair"
        elif len(candidates) > 1:
            interval["correlation_status"] = "ambiguous_start"
            ambiguous_starts += 1
        else:
            interval["correlation_status"] = "unmatched_start"
            unmatched_tmem += 1

    matched_hardware_ids = {
        item["hardware_id"] for item in intervals
        if item["correlation_status"] in ("matched", "completion_cycle_mismatch", "incomplete_pair")
        and item["hardware_id"] is not None
    }
    unmatched_hw = sum(
        1 for item in hw
        if item["unit"] is not None and item["start_cycle"] is not None
        and item["hardware_id"] not in matched_hardware_ids
    )

    per_unit = {
        name: {
            "read_records": 0, "read_words": 0, "write_records": 0, "write_words": 0,
            "assigned_records": 0, "assigned_words": 0, "ambiguous_records": 0,
            "boundary_records": 0, "unassigned_records": 0, "lost_group_events": 0,
        }
        for name in _UNIT_NAMES
    }
    access_summary = {
        "read_records": 0, "read_words": 0, "write_records": 0, "write_words": 0,
        "assigned_records": 0, "assigned_words": 0, "ambiguous_records": 0,
        "boundary_records": 0, "incomplete_interval_records": 0, "unassigned_records": 0,
        "invalid_records": 0,
    }
    loss_summary = {
        "unit_events": 0, "assigned": 0, "ambiguous": 0, "boundary": 0,
        "incomplete_interval": 0, "unassigned": 0,
    }

    for event in events:
        if "_loss" in event:
            loss = event["_loss"]
            loss_summary["unit_events"] += 1
            status, owner = _owner(loss["cycle"], loss["unit"], intervals)
            if status == "assigned":
                loss_summary["assigned"] += 1
                per_unit[_UNIT_NAMES[loss["unit"]]]["lost_group_events"] += 1
                owner.setdefault("lost_group_events", 0)
                owner["lost_group_events"] += 1
            elif status in ("boundary", "ambiguous", "incomplete_interval"):
                loss_summary[status] += 1
            else:
                loss_summary["unassigned"] += 1
            continue

        access_summary["read_records" if not event["write"] else "write_records"] += 1
        access_summary["read_words" if not event["write"] else "write_words"] += event["words"]
        unit_name = _UNIT_NAMES[event["unit"]]
        unit_row = per_unit[unit_name]
        unit_row["read_records" if not event["write"] else "write_records"] += 1
        unit_row["read_words" if not event["write"] else "write_words"] += event["words"]
        status, owner = _owner(event["cycle"], event["unit"], intervals)
        if status == "assigned":
            access_summary["assigned_records"] += 1
            access_summary["assigned_words"] += event["words"]
            unit_row["assigned_records"] += 1
            unit_row["assigned_words"] += event["words"]
            key_records = "read_records" if not event["write"] else "write_records"
            key_words = "read_words" if not event["write"] else "write_words"
            owner["accesses"][key_records] += 1
            owner["accesses"][key_words] += event["words"]
        elif status == "ambiguous":
            access_summary["ambiguous_records"] += 1
            unit_row["ambiguous_records"] += 1
        elif status == "boundary":
            access_summary["boundary_records"] += 1
            unit_row["boundary_records"] += 1
        elif status == "incomplete_interval":
            access_summary["incomplete_interval_records"] += 1
            unit_row["unassigned_records"] += 1
        else:
            access_summary["unassigned_records"] += 1
            unit_row["unassigned_records"] += 1

    config_bytes = json.dumps(config, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode()
    return {
        "schema": "sunnyone.trace-correlation.v1",
        "provenance": {
            "source_commit": source_commit.lower(),
            "slice_id": slice_id,
            "segment_index": segment_index,
            "config": config,
            "config_sha256": hashlib.sha256(config_bytes).hexdigest(),
            "hardware_trace_sha256": hardware_trace_sha256,
            "tmem_trace_sha256": tmem_trace_sha256,
        },
        "hardware_trace": {
            **hw_meta,
            "instruction_dispatches": len(hw),
            "started_instructions": sum(x["start_cycle"] is not None for x in hw),
            "completed_instructions": sum(x["done_cycle"] is not None for x in hw),
            "incomplete_instructions": sum(x["start_cycle"] is None or x["done_cycle"] is None for x in hw),
        },
        "tmem_trace": tm_meta,
        "correlation": {
            "matched_instruction_intervals": matched,
            "start_matched_intervals": start_matched,
            "unmatched_tmem_starts": unmatched_tmem,
            "unmatched_hardware_starts": unmatched_hw,
            "ambiguous_tmem_starts": ambiguous_starts,
            "completion_cycle_mismatches": completion_mismatches,
            "instructions": [
                {
                    "tmem_id": x["tmem_id"], "hardware_id": x["hardware_id"],
                    "unit": _UNIT_NAMES[x["unit"]], "opcode": x["opcode"],
                    "start_cycle": x["cycle"], "done_cycle": x["done_cycle"],
                    "instruction_count": x["instruction_count"],
                    "field_23_16": x["field_23_16"], "flags": x["flags"],
                    "correlation_status": x["correlation_status"],
                    "accesses": x["accesses"],
                    "lost_group_events": x.get("lost_group_events", 0),
                }
                for x in intervals
            ],
        },
        "tmem_activity": {
            "accesses": access_summary,
            "lost_groups": loss_summary,
            "by_unit": per_unit,
        },
        "attribution_limits": {
            "request_level_available": False,
            "reason": (
                "TMEM records identify cycle, unit/port, opcode and a sequencer instruction count, "
                "but do not carry a workload request ID or hardware trace slot. No request-level "
                "attribution is inferred."
            ),
            "boundary_and_overlapping_accesses": "reported as boundary/ambiguous, never force-assigned",
        },
        "calibration": {
            "status": "not_calibrated",
            "profile_eligible": False,
            "reason": (
                "Exact trace correlation is a prerequisite only. Service times, capacities, "
                "throughput, power and energy require separate source-grounded extraction, "
                "held-out validation and/or calibrated measurement."
            ),
        },
    }


def _main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--hardware-trace", required=True, type=Path)
    parser.add_argument("--tmem-trace", required=True, type=Path)
    parser.add_argument("--source-commit", required=True)
    parser.add_argument("--config-json", required=True, type=Path)
    parser.add_argument("--slice-id", type=int, default=0)
    parser.add_argument("--segment-index", type=int, default=0)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args(argv)

    try:
        hw_bytes = args.hardware_trace.read_bytes()
        tm_bytes = args.tmem_trace.read_bytes()
        config = json.loads(args.config_json.read_text(encoding="utf-8"))
        segments = read_tmem_segments(tm_bytes)
        if not 0 <= args.segment_index < len(segments):
            raise ValueError(f"segment-index {args.segment_index} outside 0..{len(segments)-1}")
        report = correlate(
            hw_bytes.decode("utf-8"), segments[args.segment_index],
            source_commit=args.source_commit, config=config, slice_id=args.slice_id,
            segment_index=args.segment_index,
            hardware_trace_sha256=hashlib.sha256(hw_bytes).hexdigest(),
            tmem_trace_sha256=hashlib.sha256(tm_bytes).hexdigest(),
        )
    except (OSError, UnicodeDecodeError, json.JSONDecodeError, ValueError) as exc:
        parser.error(str(exc))
    rendered = json.dumps(report, sort_keys=True, indent=2) + "\n"
    if args.output:
        args.output.write_text(rendered, encoding="utf-8")
    else:
        sys.stdout.write(rendered)
    return 0


if __name__ == "__main__":
    raise SystemExit(_main())
