import importlib.util
import json
import threading
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from types import SimpleNamespace

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "sunnyone" / "endpoint_benchmark.py"
spec = importlib.util.spec_from_file_location("sunnyone_endpoint_benchmark", SCRIPT)
bench = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bench)


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", "0"))
        payload = json.loads(self.rfile.read(length))
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.end_headers()
        events = [
            {"choices": [{"delta": {"content": "hello"}, "finish_reason": None}]},
            {"choices": [{"delta": {"content": " world"}, "finish_reason": None}]},
            {"choices": [{"delta": {}, "finish_reason": "stop"}], "usage": {
                "prompt_tokens": 5, "completion_tokens": 2, "total_tokens": 7
            }},
        ]
        for event in events:
            self.wfile.write(("data: " + json.dumps(event) + "\n\n").encode())
            self.wfile.flush()
        self.wfile.write(b"data: [DONE]\n\n")
        self.wfile.flush()

    def log_message(self, *_):
        pass


class BenchmarkHarnessTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.url = "http://127.0.0.1:%d/v1" % cls.server.server_port

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join(timeout=2)

    def test_percentile(self):
        self.assertEqual(bench.pct([], 0.5), None)
        self.assertEqual(bench.pct([1, 2, 3], 0.5), 2)
        self.assertAlmostEqual(bench.pct([1, 2, 3, 4], 0.5), 2.5)

    def test_streaming_ttft_chunks_and_usage(self):
        args = SimpleNamespace(
            model="test-model", base_url=self.url, api_key="EMPTY",
            temperature=0, max_tokens=16, timeout=5, stream=True
        )
        result = bench.request_one(args, {"id": "case-1", "prompt": "hello"}, 0)
        self.assertEqual(result["status"], "ok")
        self.assertEqual(result["response_text"], "hello world")
        self.assertEqual(result["input_tokens"], 5)
        self.assertEqual(result["output_tokens"], 2)
        self.assertIsNotNone(result["ttft_s"])
        self.assertEqual(result["content_chunks"], 2)
        self.assertIsNotNone(result["inter_chunk_latency_p50_s"])

    def test_non_streaming_request(self):
        args = SimpleNamespace(
            model="test-model", base_url=self.url, api_key="EMPTY",
            temperature=0, max_tokens=16, timeout=5, stream=False
        )
        result = bench.request_one(args, {"id": "case-2", "prompt": "hello"}, 0)
        self.assertEqual(result["status"], "ok")
        self.assertEqual(result["response_text"], "hello world")


if __name__ == "__main__":
    unittest.main()
