#!/usr/bin/env python3
"""Local Qwen3 embedding + reranker retrieval benchmark.

Install: pip install sentence-transformers torch numpy
Input JSONL rows: {"id","query","documents":[{"id","text"}],"relevant_ids":[...]}
No model quality is asserted until this is run on a representative, labelled corpus.
"""
import argparse
import datetime as dt
import hashlib
import json
import statistics
import time
from pathlib import Path

import numpy as np
from sentence_transformers import SentenceTransformer, CrossEncoder

EMBED_REV = "97b0c614be4d77ee51c0cef4e5f07c00f9eb65b3"
RERANK_REV = "e61197ed45024b0ed8a2d74b80b4d909f1255473"


def dcg(relevances):
    return sum((2 ** rel - 1) / np.log2(i + 2) for i, rel in enumerate(relevances))


def ranking_metrics(ranked_ids, relevant_ids, k_values=(1, 3, 5, 10)):
    relevant = set(relevant_ids)
    out = {}
    for k in k_values:
        top = ranked_ids[:k]
        hits = [1 if item in relevant else 0 for item in top]
        recall = sum(hits) / len(relevant) if relevant else 0.0
        rr = next((1.0 / (i + 1) for i, hit in enumerate(hits) if hit), 0.0)
        ideal = [1] * min(len(relevant), k)
        ndcg = dcg(hits) / dcg(ideal) if ideal else 0.0
        out[f"recall@{k}"] = recall
        out[f"mrr@{k}"] = rr
        out[f"ndcg@{k}"] = ndcg
    return out


def sha(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1048576), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--dataset", required=True)
    p.add_argument("--out", default="retrieval-benchmark.json")
    p.add_argument("--device", default="cuda")
    p.add_argument("--batch-size", type=int, default=32)
    p.add_argument("--embedding-model", default="Qwen/Qwen3-Embedding-0.6B")
    p.add_argument("--embedding-revision", default=EMBED_REV)
    p.add_argument("--reranker-model", default="Qwen/Qwen3-Reranker-0.6B")
    p.add_argument("--reranker-revision", default=RERANK_REV)
    p.add_argument("--top-k-rerank", type=int, default=10)
    a = p.parse_args()
    if a.batch_size < 1 or a.top_k_rerank < 1:
        p.error("batch-size and top-k-rerank must be positive")
    rows = [json.loads(x) for x in Path(a.dataset).read_text(encoding="utf-8").splitlines() if x.strip()]
    if not rows:
        p.error("dataset is empty")
    for row in rows:
        if not {"query", "documents", "relevant_ids"} <= set(row):
            p.error("each row requires query, documents and relevant_ids")
        if not row["documents"] or not row["relevant_ids"]:
            p.error("each query requires documents and at least one relevant id")

    embedder = SentenceTransformer(a.embedding_model, revision=a.embedding_revision, device=a.device)
    reranker = CrossEncoder(a.reranker_model, revision=a.reranker_revision, device=a.device)
    query_texts = [r["query"] for r in rows]
    all_docs = [d["text"] for r in rows for d in r["documents"]]
    t0 = time.perf_counter()
    query_vecs = embedder.encode(query_texts, batch_size=a.batch_size, normalize_embeddings=True, show_progress_bar=False)
    doc_vecs = embedder.encode(all_docs, batch_size=a.batch_size, normalize_embeddings=True, show_progress_bar=False)
    embedding_s = time.perf_counter() - t0

    results = []
    doc_offset = 0
    rerank_pairs, rerank_owners = [], []
    for qi, row in enumerate(rows):
        docs = row["documents"]
        vectors = doc_vecs[doc_offset:doc_offset + len(docs)]
        doc_offset += len(docs)
        scores = np.asarray(vectors) @ np.asarray(query_vecs[qi])
        order = np.argsort(-scores)
        dense_ids = [docs[int(i)]["id"] for i in order]
        dense_metrics = ranking_metrics(dense_ids, row["relevant_ids"])
        selected = dense_ids[:a.top_k_rerank]
        by_id = {d["id"]: d["text"] for d in docs}
        for did in selected:
            rerank_pairs.append((row["query"], by_id[did]))
            rerank_owners.append((qi, did))
        results.append({"query_id": row.get("id", str(qi)), "dense_ranking": dense_ids,
                        "dense_metrics": dense_metrics, "reranked_ids": [], "rerank_metrics": {}})

    t1 = time.perf_counter()
    rerank_scores = reranker.predict(rerank_pairs, batch_size=a.batch_size, show_progress_bar=False)
    rerank_s = time.perf_counter() - t1
    grouped = {}
    for (qi, did), score in zip(rerank_owners, rerank_scores):
        grouped.setdefault(qi, []).append((did, float(score)))
    for qi, row in enumerate(rows):
        reranked = [did for did, _ in sorted(grouped.get(qi, []), key=lambda x: x[1], reverse=True)]
        results[qi]["reranked_ids"] = reranked
        results[qi]["rerank_metrics"] = ranking_metrics(reranked, row["relevant_ids"])

    def mean_metric(section, key):
        vals = [r[section][key] for r in results]
        return statistics.mean(vals) if vals else 0.0

    keys = [f"{metric}@{k}" for k in (1, 3, 5, 10) for metric in ("recall", "mrr", "ndcg")]
    summary = {
        "timestamp_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "dataset_sha256": sha(a.dataset),
        "query_count": len(rows),
        "document_count": len(all_docs),
        "embedding_model": a.embedding_model,
        "embedding_revision": a.embedding_revision,
        "reranker_model": a.reranker_model,
        "reranker_revision": a.reranker_revision,
        "device": a.device,
        "batch_size": a.batch_size,
        "top_k_rerank": a.top_k_rerank,
        "embedding_wall_s": embedding_s,
        "reranking_wall_s": rerank_s,
        "dense_macro_metrics": {k: mean_metric("dense_metrics", k) for k in keys},
        "reranked_macro_metrics": {k: mean_metric("rerank_metrics", k) for k in keys},
        "limitations": [
            "No wall-power or energy measurement",
            "No independent relevance-label validation",
            "Small demonstration corpus is not representative customer evidence",
            "No vector database, network or full RAG application latency included",
        ],
        "per_query": results,
    }
    Path(a.out).write_text(json.dumps(summary, indent=2), encoding="utf-8")
    print(json.dumps({k: v for k, v in summary.items() if k not in ("per_query",)}, indent=2))


if __name__ == "__main__":
    main()
