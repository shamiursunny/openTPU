import importlib.util
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "sunnyone" / "retrieval_benchmark.py"
spec = importlib.util.spec_from_file_location("sunnyone_retrieval_benchmark", SCRIPT)
module = importlib.util.module_from_spec(spec)
# The script's pure metric functions are tested without loading optional ML packages.
import sys
class Fake:
    def __getattr__(self, name):
        return object
_MISSING = object()
_numpy_before = sys.modules.get("numpy", _MISSING)
_sentence_before = sys.modules.get("sentence_transformers", _MISSING)
sys.modules.setdefault("numpy", Fake())
sys.modules.setdefault("sentence_transformers", Fake())
try:
    spec.loader.exec_module(module)
finally:
    # Keep these optional-dependency stubs local to this import. Other tests may need real NumPy.
    if _numpy_before is _MISSING:
        sys.modules.pop("numpy", None)
    else:
        sys.modules["numpy"] = _numpy_before
    if _sentence_before is _MISSING:
        sys.modules.pop("sentence_transformers", None)
    else:
        sys.modules["sentence_transformers"] = _sentence_before

class RetrievalMetricTests(unittest.TestCase):
    # Metrics are unit-tested without downloading model weights.
    def test_perfect_ranking(self):
        result = module.ranking_metrics(["a", "c", "b"], ["a", "c"])
        self.assertEqual(result["recall@3"], 1.0)
        self.assertEqual(result["mrr@3"], 1.0)
        self.assertAlmostEqual(result["ndcg@3"], 1.0)

    def test_missed_relevant_document(self):
        result = module.ranking_metrics(["x", "a", "b"], ["a", "c"])
        self.assertEqual(result["recall@1"], 0.0)
        self.assertAlmostEqual(result["mrr@3"], 0.5)
        self.assertGreater(result["ndcg@3"], 0.0)

    def test_empty_relevant_set(self):
        result = module.ranking_metrics(["a"], [])
        self.assertEqual(result["recall@1"], 0.0)
        self.assertEqual(result["mrr@1"], 0.0)
        self.assertEqual(result["ndcg@1"], 0.0)

if __name__ == "__main__":
    unittest.main()
