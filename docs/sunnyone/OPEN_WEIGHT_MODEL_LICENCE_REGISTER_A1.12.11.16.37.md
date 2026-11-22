# A1.12.11.16.37 — Open-Weight Model and Licence Register

Checked: 2026-11-23
Purpose: reproducible candidate selection for W1/W2/W3 workload benchmarking.
Status: candidates are approved for controlled evaluation only; not approved for production deployment.
All Hugging Face revisions below are immutable commit SHAs observed from the Hub model API on the check date. Re-check licence and commit before every redistribution or commercial release.

## W1 / W3 generative candidate

| Field | Candidate |
|---|---|
| Repository | Qwen/Qwen3.5-4B |
| Immutable revision | `851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a` |
| Model type | Multimodal conditional generation |
| Reported parameter count | 4,659,865,088 total parameters (Hub API) |
| Checkpoint storage shown by Hub | 9.34 GB |
| Licence tag | Apache-2.0 |
| Gated | No, per Hub API at check |
| Official card | https://huggingface.co/Qwen/Qwen3.5-4B |
| Official revision API | https://huggingface.co/api/models/Qwen/Qwen3.5-4B |
| Runtime documented by model card | Transformers, vLLM and SGLang instructions are shown |
| Initial role | Primary W1/W3 evaluation candidate, not an accelerator support claim |

Important: the model card identifies `Qwen3_5ForConditionalGeneration` and multimodal inputs. Text-only W1/W3 prompts must be tested separately from vision/video. Do not assume the pinned openTPU RTL/runtime supports this exact revision just because the repository description mentions Qwen3.5. Confirm operator coverage, tokenizer/chat template, numerical correctness and end-to-end execution first.

## W2 retrieval candidates

| Role | Repository | Immutable revision | Parameters | Licence | Official card |
|---|---|---|---:|---|---|
| Embeddings | Qwen/Qwen3-Embedding-0.6B | `97b0c614be4d77ee51c0cef4e5f07c00f9eb65b3` | 0.6B | Apache-2.0 | https://huggingface.co/Qwen/Qwen3-Embedding-0.6B |
| Reranking | Qwen/Qwen3-Reranker-0.6B | `e61197ed45024b0ed8a2d74b80b4d909f1255473` | 0.6B | Apache-2.0 | https://huggingface.co/Qwen/Qwen3-Reranker-0.6B |

Official Hub APIs:
- https://huggingface.co/api/models/Qwen/Qwen3-Embedding-0.6B
- https://huggingface.co/api/models/Qwen/Qwen3-Reranker-0.6B

The embedding model card reports 32k context and output dimensions up to 1024; the reranker card reports 32k context. Treat vendor-reported specifications as model-card claims, not independent benchmark results. Evaluate retrieval Recall@k, MRR/nDCG, reranking quality, throughput, latency, memory and energy on a pinned dataset.

## Licence handling
Apache-2.0 is a permissive software/model-weight licence but does not remove obligations around notices, patents, third-party assets, trademarks, privacy, data rights, export controls or applicable law. Preserve the exact LICENSE file from each pinned revision and review its text before distribution. The model card's licence metadata alone is not a complete legal review.

Do not substitute Meta Llama or other custom community licences without a separate review. For example, Meta's Llama 4 Community License has attribution and additional commercial terms; it is not Apache-2.0.

## Benchmark controls
For each model, archive:
1. Exact Hub repository and full revision SHA.
2. LICENSE and README/model card bytes and SHA-256.
3. Config, tokenizer, processor, chat template and generation config hashes.
4. Runtime, framework, CUDA/ROCm/driver and quantisation versions.
5. Exact quantised artifact hash and quantisation recipe, if used.
6. Dataset/prompt hashes, acceptance rubric and run metadata.
7. Raw outputs, errors and independent quality scores.

## Current status
- Candidate selection for controlled W1/W3 and W2 benchmarking: DONE.
- Legal/commercial review of pinned LICENSE files: pending.
- Exact model artifact downloads and hashes in project repository: pending.
- Reproducible cloud-GPU benchmark: pending.
- OpenTPU operator and numerical-equivalence qualification for Qwen3.5-4B: pending.
- No model is yet a validated production workload or proof of SUNNYONE hardware capability.
