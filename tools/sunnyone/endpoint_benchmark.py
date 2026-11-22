#!/usr/bin/env python3
"""Stdlib OpenAI-compatible endpoint benchmark. Not a wall-power or quality test."""
import argparse, concurrent.futures, datetime as dt, hashlib, json, os, time, urllib.request, uuid
from pathlib import Path

def pct(values, p):
    if not values: return None
    s=sorted(values); k=(len(s)-1)*p; lo=int(k); hi=min(lo+1,len(s)-1)
    return s[lo]+(s[hi]-s[lo])*(k-lo)

def sha(path):
    h=hashlib.sha256()
    with open(path,"rb") as f:
        for chunk in iter(lambda:f.read(1048576),b""): h.update(chunk)
    return h.hexdigest()

def request_one(args, item, index):
    payload={"model":args.model,"messages":[{"role":"user","content":item["prompt"]}],
             "temperature":args.temperature,"max_tokens":args.max_tokens,"stream":False}
    req=urllib.request.Request(args.base_url.rstrip("/")+"/chat/completions",
        data=json.dumps(payload).encode(),
        headers={"Content-Type":"application/json","Authorization":"Bearer "+args.api_key})
    start=time.perf_counter()
    try:
        with urllib.request.urlopen(req,timeout=args.timeout) as response: obj=json.loads(response.read())
        elapsed=time.perf_counter()-start
        usage=obj.get("usage") or {}; choice=(obj.get("choices") or [{}])[0]
        msg=choice.get("message") or {}
        return {"id":item.get("id",str(index)),"repeat":item.get("repeat",0),"status":"ok",
          "latency_s":elapsed,"input_tokens":usage.get("prompt_tokens"),
          "output_tokens":usage.get("completion_tokens"),"total_tokens":usage.get("total_tokens"),
          "finish_reason":choice.get("finish_reason"),"response_text":msg.get("content") or "","error":None}
    except Exception as exc:
        return {"id":item.get("id",str(index)),"repeat":item.get("repeat",0),"status":"error",
          "latency_s":time.perf_counter()-start,"input_tokens":None,"output_tokens":None,
          "total_tokens":None,"finish_reason":None,"response_text":"","error":str(exc)}

def main():
    p=argparse.ArgumentParser()
    p.add_argument("--base-url",required=True,help="OpenAI-compatible base URL, e.g. http://localhost:8000/v1")
    p.add_argument("--model",required=True); p.add_argument("--prompts",required=True)
    p.add_argument("--out",default="benchmark-run"); p.add_argument("--api-key",default=os.getenv("OPENAI_API_KEY","EMPTY"))
    p.add_argument("--concurrency",type=int,default=1); p.add_argument("--repetitions",type=int,default=3)
    p.add_argument("--max-tokens",type=int,default=256); p.add_argument("--temperature",type=float,default=0)
    p.add_argument("--timeout",type=int,default=300); p.add_argument("--metadata",default="{}")
    a=p.parse_args()
    if a.concurrency<1 or a.repetitions<1: p.error("concurrency and repetitions must be >=1")
    meta=json.loads(a.metadata)
    prompts=[json.loads(line) for line in Path(a.prompts).read_text(encoding="utf-8").splitlines() if line.strip()]
    if not prompts or any("prompt" not in row for row in prompts): p.error("JSONL rows require prompt")
    expanded=[dict(row,repeat=r) for r in range(a.repetitions) for row in prompts]
    run_id=dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")+"-"+uuid.uuid4().hex[:8]
    out=Path(a.out); out.mkdir(parents=True,exist_ok=True); start=time.perf_counter()
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.concurrency) as pool:
        rows=list(pool.map(lambda pair:request_one(a,pair[1],pair[0]),enumerate(expanded)))
    elapsed=time.perf_counter()-start; good=[r for r in rows if r["status"]=="ok"]
    lat=[r["latency_s"] for r in good]; outtok=sum(r["output_tokens"] or 0 for r in good)
    intok=sum(r["input_tokens"] or 0 for r in good)
    with (out/(run_id+".jsonl")).open("w",encoding="utf-8") as f:
        for row in rows: f.write(json.dumps(row,ensure_ascii=False)+"\n")
    summary={"run_id":run_id,"timestamp_utc":dt.datetime.now(dt.timezone.utc).isoformat(),
      "model":a.model,"prompt_sha256":sha(a.prompts),"prompt_count":len(prompts),
      "repetitions":a.repetitions,"requests":len(rows),"successes":len(good),"errors":len(rows)-len(good),
      "concurrency":a.concurrency,"elapsed_s":elapsed,"input_tokens_reported":intok,
      "output_tokens_reported":outtok,"generated_tokens_per_second_wall":outtok/elapsed if elapsed else None,
      "latency_p50_s":pct(lat,.50),"latency_p95_s":pct(lat,.95),"latency_p99_s":pct(lat,.99),
      "metadata":meta,"limitations":["No calibrated wall-power measurement","Non-streaming: no TTFT/inter-token timing",
      "No independent quality scoring","Token counts depend on server usage reporting"]}
    (out/(run_id+"-summary.json")).write_text(json.dumps(summary,indent=2),encoding="utf-8")
    print(json.dumps(summary,indent=2)); return 1 if len(good) != len(rows) else 0

if __name__=="__main__": raise SystemExit(main())
