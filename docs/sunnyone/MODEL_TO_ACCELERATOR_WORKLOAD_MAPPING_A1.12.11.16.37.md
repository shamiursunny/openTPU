# A1.12.11.16.37 — Initial Model-to-Accelerator Workload Mapping

Status: planning baseline; derived from official model cards, not measured accelerator traces.

## Candidate workloads
- W1/W3 generative inference: Qwen3.5-4B at revision `851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a`.
- W2 embeddings: Qwen3-Embedding-0.6B at revision `97b0c614be4d77ee51c0cef4e5f07c00f9eb65b3`.
- W2 reranking: Qwen3-Reranker-0.6B at revision `e61197ed45024b0ed8a2d74b80b4d909f1255473`.

## Hardware-relevant implications
1. Qwen3.5-4B checkpoint storage is listed by the Hub as 9.34 GB. That is not the final runtime RAM requirement: weights, KV cache/state, activations, multimodal processor buffers, runtime workspace, fragmentation and concurrency add memory.
2. At BF16, the Hub reports 4,659,865,088 parameters. Raw parameter storage alone is approximately 9.32 GB decimal before runtime overhead. Quantised sizes must be measured from actual exported artifacts, not inferred as exact 8-bit/4-bit memory requirements.
3. Qwen3.5-4B config declares `Qwen3_5ForConditionalGeneration`; exact operator and numerical paths must be mapped. The repository's Gated DeltaNet kernel does not by itself prove full-model support.
4. Embedding and reranking are distinct model graphs and API paths; they must not be treated as the same matrix-multiplication benchmark as autoregressive decode.
5. W2 should measure ingestion/embedding, vector search, reranking and full pipeline latency separately.
6. W1/W3 should separate prefill and decode; report request-level SLA, not just aggregate generated tokens/s.

## Required traces before memory architecture selection
- Weights by tensor and precision, exact file hashes.
- KV cache or recurrent state by layer, sequence length and concurrency.
- Peak activations and workspace by operator.
- Scratchpad hit/miss and DMA traffic.
- External memory read/write bytes and measured effective bandwidth.
- Queue depth, batch size, request arrivals and p95/p99 latency.
- Wall power at complete node boundary.

## Prohibited inference
No 128 GB or 256 GB RAM recommendation can be made from the 4B model alone. A small model may fit in far less memory. High memory capacity only becomes useful if customer workloads, model mix, KV-cache concurrency or multi-model serving justify it economically.
