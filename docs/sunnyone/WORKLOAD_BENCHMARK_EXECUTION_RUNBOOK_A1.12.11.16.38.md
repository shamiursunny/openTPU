# A1.12.11.16.38 — Workload Benchmark Execution Runbook

Status: executable procedure; no cloud GPU was rented and no customer/model benchmark is claimed.
Pinned model revisions are recorded in OPEN_WEIGHT_MODEL_LICENCE_REGISTER_A1.12.11.16.37.md.

## 1. Prepare a clean benchmark host
Use a rented GPU instance or a local GPU with a documented full system specification. Do not buy hardware for this test. Capture provider, region, instance SKU, GPU model/count/VRAM, CPU, RAM, storage, network, driver, CUDA/ROCm, power boundary and actual checkout price.

Create a clean environment:
```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install vllm sentence-transformers torch numpy
```
Record exact package versions using `python -m pip freeze`. Do not update packages between paired comparisons.

## 2. W1/W3 generative serving
Pinned candidate: `Qwen/Qwen3.5-4B`, revision `851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a`.

Verify the exact revision and licence before launch. The model card documents vLLM serving. Example launch:
```bash
vllm serve Qwen/Qwen3.5-4B \
  --revision 851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a \
  --host 0.0.0.0 --port 8000
```
If the installed vLLM build does not support the model/revision, stop and record the incompatibility; do not silently substitute a newer checkpoint or runtime.

Run the chat harness:
```bash
python tools/sunnyone/endpoint_benchmark.py \
  --base-url http://127.0.0.1:8000/v1 \
  --model Qwen/Qwen3.5-4B \
  --prompts docs/sunnyone/benchmark_prompts_v1.jsonl \
  --repetitions 3 --concurrency 1 \
  --metadata '{"workload":"W1-W3-smoke","model_revision":"851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a"}'
```
Repeat at concurrency 2, 4 and 8 only if the system remains stable. Record raw JSONL and summary files. This runner measures request latency and streaming TTFT/inter-chunk timing; inter-chunk timing is not exact per-token latency. It does not measure wall power or independently score quality.

## 3. W2 retrieval
Pinned models:
- Embedding: `Qwen/Qwen3-Embedding-0.6B`, revision `97b0c614be4d77ee51c0cef4e5f07c00f9eb65b3`.
- Reranker: `Qwen/Qwen3-Reranker-0.6B`, revision `e61197ed45024b0ed8a2d74b80b4d909f1255473`.

Run:
```bash
python tools/sunnyone/retrieval_benchmark.py \
  --dataset docs/sunnyone/retrieval_demo_v1.jsonl \
  --out retrieval-demo-results.json \
  --device cuda --batch-size 32 --top-k-rerank 3
```
This smoke dataset contains only four short labelled queries and is not representative. Replace it with a customer-approved, de-identified, labelled corpus before making any quality or product claim. Report Recall@k, MRR@k and nDCG@k before and after reranking. Also capture vector database, storage, network and full-pipeline latency separately; the script measures model inference stages only.

## 4. Quality and stability
For W1/W3, independently score each output against a task-specific rubric. Include exact extraction, numerical correctness, instruction following, factuality, completeness, refusal/unsafe behaviour where relevant, and customer acceptance. Do not score model output using the same model as the sole evaluator.

For W2, validate relevance labels and measure retrieval quality against held-out queries. Split train/development/test by customer or source document to avoid leakage. A four-query demo is only a smoke test.

Run at least three measured repetitions per configuration after warm-up. Capture failure rate, OOM, retries, thermal throttling, clocks, sustained temperature and exact run duration. Report p50/p95/p99, not only means or best runs.

## 5. Power and economics
Measure at the complete node wall boundary with a calibrated meter. Include host, GPU, RAM, storage, network and cooling where practicable. Record meter model, calibration status, sample interval and boundary. Do not substitute GPU TDP for wall power.

Capture actual provider invoice/checkout amount and included CPU/RAM/storage/network/egress/tax/billing increments. Populate UNIT_ECONOMICS_INPUT_REGISTER.md with evidence source, date and confidence. Until then, leave financial inputs blank.

## 6. Current execution blockers
- No GPU endpoint credentials or rented instance was supplied/authorised in this session.
- No customer-approved representative dataset or quality rubric has been supplied.
- No calibrated wall meter or actual Bangladesh site tariff/bill is attached.
- No customer interviews, LOIs, paid pilot or contracts are evidenced.
- No model download/serving benchmark has been executed; only harness CI tests have passed.
