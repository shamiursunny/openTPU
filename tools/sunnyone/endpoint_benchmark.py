#!/usr/bin/env python3
"""Stdlib OpenAI-compatible chat benchmark with SSE TTFT/chunk timing.

Measures endpoint latency and server-reported token usage. It does not measure
wall power or independently score output quality. Streaming chunk timing is not
identical to per-token latency because servers may emit multiple tokens/chunk.
"""
import argparse
import concurrent.futures
import datetime as dt
import hashlib
import json
import os
import time
import urllib.request
import uuid
from pathlib import Path


def pct(values, p):
    if not values:
        return None
    s = sorted(values)
    k = (len(s) - 1) * p
    lo = int(k)
    hi = min(lo + 1, len(s) - 1)
    return s[lo] + (s[hi] - s[lo]) * (k - lo)


def sha(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1048576), b""):
            h.update(chunk)
    return h.hexdigest()


def request_one(args, item, index):
    payload = {
        "model": args.model,
        "messages": [{"role": "user", "content": item["prompt"]}],
        "temperature": args.temperature,
        "max_tokens": args.max_tokens,
        "stream": args.stream,
    }
    if args.stream:
        payload["stream_options"] = {"include_usage": True}
    req = urllib.request.Request(
        args.base_url.rstrip("/") + "/chat/completions",
        data=json.dumps(payload).encode(),
        headers={
            "Content-Type": "application/json",
            "Authorization": "Bearer " + args.api_key,
        },
    )
    start = time.perf_counter()
    first_content_s = None
    chunk_times = []
    chunks = []
    usage = {}
    finish_reason = None
    try:
        with urllib.request.urlopen(req, timeout=args.timeout) as response:
            if args.stream:
                for raw_line in response:
                    line = raw_line.decode("utf-8", errors="replace").strip()
                    if not line.startswith("data:"):
                        continue
                    data = line[5:].strip()
                    if not data or data == "[DONE]":
                        continue
                    event = json.loads(data)
                    if event.get("usage"):
                        usage = event["usage"]
                    choices = event.get("choices") or []
                    if not choices:
                        continue
                    choice = choices[0]
                    finish_reason = choice.get("finish_reason") or finish_reason
                    delta = choice.get("delta") or {}
                    piece = delta.get("content")
                    if piece:
                        now = time.perf_counter()
                        if first_content_s is None:
                            first_content_s = now - start
                        chunk_times.append(now - start)
                        chunks.append(piece)
            else:
                obj = json.loads(response.read())
                usage = obj.get("usage") or {}
                choice = (obj.get("choices") or [{}])[0]
                finish_reason = choice.get("finish_reason")
                message = choice.get("message") or {}
                chunks = [message.get("content") or ""]
        elapsed = time.perf_counter() - start
        gaps = [b - a for a, b in zip(chunk_times, chunk_times[1:])]
        return {
            "id": item.get("id", str(index)),
            "repeat": item.get("repeat", 0),
            "status": "ok",
            "latency_s": elapsed,
            "ttft_s": first_content_s,
            "inter_chunk_latency_p50_s": pct(gaps, 0.50),
            "inter_chunk_latency_p95_s": pct(gaps, 0.95),
            "content_chunks": len(chunks),
            "input_tokens": usage.get("prompt_tokens"),
            "output_tokens": usage.get("completion_tokens"),
            "total_tokens": usage.get("total_tokens"),
            "finish_reason": finish_reason,
            "response_text": "".join(chunks),
            "error": None,
        }
    except Exception as exc:
        return {
            "id": item.get("id", str(index)),
            "repeat": item.get("repeat", 0),
            "status": "error",
            "latency_s": time.perf_counter() - start,
            "ttft_s": first_content_s,
            "inter_chunk_latency_p50_s": None,
            "inter_chunk_latency_p95_s": None,
            "content_chunks": len(chunks),
            "input_tokens": None,
            "output_tokens": None,
            "total_tokens": None,
            "finish_reason": finish_reason,
            "response_text": "".join(chunks),
            "error": str(exc),
        }


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--base-url", required=True, help="OpenAI-compatible base URL, e.g. http://localhost:8000/v1")
    p.add_argument("--model", required=True)
    p.add_argument("--prompts", required=True, help="JSONL rows with id and prompt")
    p.add_argument("--out", default="benchmark-run")
    p.add_argument("--api-key", default=os.getenv("OPENAI_API_KEY", "EMPTY"))
    p.add_argument("--concurrency", type=int, default=1)
    p.add_argument("--repetitions", type=int, default=3)
    p.add_argument("--max-tokens", type=int, default=256)
    p.add_argument("--temperature", type=float, default=0)
    p.add_argument("--timeout", type=int, default=300)
    p.add_argument("--metadata", default="{}", help="JSON metadata with immutable hardware/runtime/model details")
    p.add_argument("--no-stream", action="store_true", help="Disable SSE; TTFT will not be measured")
    a = p.parse_args()
    if a.concurrency < 1 or a.repetitions < 1:
        p.error("concurrency and repetitions must be >=1")
    meta = json.loads(a.metadata)
    prompts = [
        json.loads(line)
        for line in Path(a.prompts).read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if not prompts or any("prompt" not in row for row in prompts):
        p.error("JSONL rows require prompt")
    a.stream = not a.no_stream
    expanded = [dict(row, repeat=r) for r in range(a.repetitions) for row in prompts]
    run_id = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ") + "-" + uuid.uuid4().hex[:8]
    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    start = time.perf_counter()
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.concurrency) as pool:
        rows = list(pool.map(lambda pair: request_one(a, pair[1], pair[0]), enumerate(expanded)))
    elapsed = time.perf_counter() - start
    good = [r for r in rows if r["status"] == "ok"]
    lat = [r["latency_s"] for r in good]
    ttft = [r["ttft_s"] for r in good if r["ttft_s"] is not None]
    chunk_p50 = [r["inter_chunk_latency_p50_s"] for r in good if r["inter_chunk_latency_p50_s"] is not None]
    outtok = sum(r["output_tokens"] or 0 for r in good)
    intok = sum(r["input_tokens"] or 0 for r in good)
    with (out / (run_id + ".jsonl")).open("w", encoding="utf-8") as f:
        for row in rows:
            f.write(json.dumps(row, ensure_ascii=False) + "\n")
    summary = {
        "run_id": run_id,
        "timestamp_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "model": a.model,
        "prompt_sha256": sha(a.prompts),
        "prompt_count": len(prompts),
        "repetitions": a.repetitions,
        "requests": len(rows),
        "successes": len(good),
        "errors": len(rows) - len(good),
        "concurrency": a.concurrency,
        "streaming": a.stream,
        "elapsed_s": elapsed,
        "input_tokens_reported": intok,
        "output_tokens_reported": outtok,
        "generated_tokens_per_second_wall": outtok / elapsed if elapsed else None,
        "request_latency_p50_s": pct(lat, 0.50),
        "request_latency_p95_s": pct(lat, 0.95),
        "request_latency_p99_s": pct(lat, 0.99),
        "ttft_p50_s": pct(ttft, 0.50),
        "ttft_p95_s": pct(ttft, 0.95),
        "inter_chunk_p50_s_median_of_requests": pct(chunk_p50, 0.50),
        "metadata": meta,
        "limitations": [
            "No calibrated wall-power measurement",
            "SSE inter-chunk latency is not exact per-token latency",
            "No independent quality scoring",
            "Token counts depend on server usage reporting; some servers omit streaming usage",
            "No embedding or reranker endpoint support in this chat-completion harness",
        ],
    }
    (out / (run_id + "-summary.json")).write_text(json.dumps(summary, indent=2), encoding="utf-8")
    print(json.dumps(summary, indent=2))
    return 1 if len(good) != len(rows) else 0


if __name__ == "__main__":
    raise SystemExit(main())
