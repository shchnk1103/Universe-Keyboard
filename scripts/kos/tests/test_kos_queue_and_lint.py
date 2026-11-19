"""KOS-QUEUE-LINT-001: report byte tiers, kos-q inbox de-dup, kos-block gate."""
import json
import os
import subprocess
import tempfile
import time
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
KOS = ROOT / "scripts" / "kos"
LINT = KOS / "kos-report-lint.py"
QUEUE = KOS / "kos-q.py"
BLOCK = KOS / "kos-block.sh"


def run(cmd, env=None):
    merged = os.environ.copy()
    merged.pop("KOS_Q_GATE", None)
    if env:
        merged.update(env)
    return subprocess.run(cmd, capture_output=True, text=True, env=merged)


def report(path: Path, name: str, size: int) -> None:
    body = "DONE\n" + ("x" * max(0, size - 5))
    path.joinpath(name).write_bytes(body.encode()[:size])


class ReportTierTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def lint(self, name, size, extra=()):
        report(self.dir, name, size)
        return run(["python3", "-I", "-B", str(LINT), str(self.dir / name), *extra])

    def test_design_and_arch_tiers(self):
        for name in ("design-a.md", "arch-review-a.md"):
            self.assertEqual(self.lint(name, 13 * 1024).returncode, 0, name)
            self.assertEqual(self.lint(name, 13 * 1024).stdout.strip(), "OK", name)
            warned = self.lint(name, 18 * 1024)
            self.assertEqual(warned.returncode, 0, name)
            self.assertIn("提示", warned.stdout, name)
            self.assertNotEqual(self.lint(name, 25 * 1024).returncode, 0, name)

    def test_plain_report_stays_strict(self):
        self.assertNotEqual(self.lint("code-a.md", 13 * 1024).returncode, 0)

    def test_explicit_max_bytes_wins(self):
        result = self.lint("design-a.md", 13 * 1024, ("--max-bytes", "10000"))
        self.assertNotEqual(result.returncode, 0)


class QueueTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.home = Path(self.tmp.name) / "home"
        self.root = Path(self.tmp.name) / "root"
        (self.home / "Proj").mkdir(parents=True)
        self.root.mkdir()

    def tearDown(self):
        self.tmp.cleanup()

    def q(self, *args, env=None):
        return run(["python3", "-I", "-B", str(QUEUE), *args], env=env)

    def test_home_project_and_explicit_root(self):
        added = self.q("add", "TASK-A", "--title", "one",
                       env={"KOS_HOME": str(self.home), "KOS_PROJECT": "Proj"})
        self.assertEqual(added.returncode, 0, added.stderr)
        self.assertTrue((self.home / "Proj" / "QUEUE.json").is_file())
        added = self.q("add", "TASK-B", "--title", "two",
                       env={"KOS_QUEUE_ROOT": str(self.root)})
        self.assertEqual(added.returncode, 0, added.stderr)
        self.assertTrue((self.root / "QUEUE.json").is_file())

    def test_state_rank_done_and_gate(self):
        env = {"KOS_QUEUE_ROOT": str(self.root)}
        self.assertEqual(self.q("add", "FIRST", "--title", "first", "--rank", "1", env=env).returncode, 0)
        self.assertEqual(self.q("add", "SECOND", "--title", "second", "--rank", "2", env=env).returncode, 0)
        self.assertEqual(self.q("set", "SECOND", "--state", "ready", env=env).returncode, 0)
        self.assertEqual(self.q("rank", "SECOND", "1", env=env).returncode, 0)
        data = json.loads((self.root / "QUEUE.json").read_text(encoding="utf-8"))
        for item in data["items"]:
            if item["id"] == "SECOND":
                item["touched"] = "2000-01-01"
        (self.root / "QUEUE.json").write_text(json.dumps(data), encoding="utf-8")
        missing = self.q("gate", "UNKNOWN", env=env)
        self.assertEqual(missing.returncode, 2)
        jump = self.q("gate", "FIRST", env=env)
        self.assertEqual(jump.returncode, 3)
        why = self.q("gate", "FIRST", "--why", "human asked", env=env)
        self.assertEqual(why.returncode, 0, why.stderr)
        self.assertEqual(self.q("done", "FIRST", "-m", "finished", env=env).returncode, 0)

    def test_add_creates_missing_queue_root(self):
        nested = Path(self.tmp.name) / "deep" / "root"
        result = self.q("add", "TASK-C", "--title", "three", env={"KOS_QUEUE_ROOT": str(nested)})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((nested / "QUEUE.json").is_file())

    def test_same_day_jump_is_blocked_without_reason(self):
        env = {"KOS_QUEUE_ROOT": str(self.root)}
        self.assertEqual(self.q("add", "FIRST", "--title", "first", "--rank", "1", env=env).returncode, 0)
        self.assertEqual(self.q("add", "SECOND", "--title", "second", "--rank", "2", env=env).returncode, 0)
        jump = self.q("gate", "SECOND", env=env)
        self.assertEqual(jump.returncode, 3)
        allowed = self.q("gate", "SECOND", "--why", "human asked", env=env)
        self.assertEqual(allowed.returncode, 0, allowed.stderr)

    def test_inbox_same_second_is_unique(self):
        env = {"KOS_QUEUE_ROOT": str(self.root)}
        ids = []
        base = ""
        for _ in range(6):
            stamp = time.strftime("%m%d%H%M%S")
            base = "INBOX-" + stamp
            preset = {
                "focus": "",
                "items": [{
                    "id": base,
                    "zone": "inbox",
                    "rank": 0,
                    "title": "preset",
                    "state": "",
                    "next": "",
                    "owner": "",
                    "hold": "",
                    "touched": "2000-01-01",
                }],
            }
            (self.root / "QUEUE.json").write_text(json.dumps(preset), encoding="utf-8")
            if time.strftime("%m%d%H%M%S") != stamp:
                continue
            ids = []
            crossed = False
            for suffix in ("-2", "-3"):
                if time.strftime("%m%d%H%M%S") != stamp:
                    crossed = True
                    break
                result = self.q("inbox", "captured", env=env)
                self.assertEqual(result.returncode, 0, result.stderr)
                got = result.stdout.strip()
                if time.strftime("%m%d%H%M%S") != stamp or got != base + suffix:
                    crossed = True
                    break
                ids.append(got)
            if not crossed:
                break
        else:
            self.fail("could not keep one clock second across the preset and both suffixes")
        self.assertEqual(ids, [base + "-2", base + "-3"])

    def test_render_banner_points_at_repo_script(self):
        result = self.q("render", env={"KOS_QUEUE_ROOT": str(self.root)})
        self.assertEqual(result.returncode, 0, result.stderr)
        text = (self.root / "PRIORITY.md").read_text(encoding="utf-8")
        self.assertIn("scripts/kos/kos-q.py", text)
        self.assertIn("`python3 -I -B scripts/kos/kos-q.py digest`", text)
        self.assertNotIn("tools/kos-q.py", text)


class BlockGateTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self.tmp.name)
        self.pkg = self.dir / "packet.md"
        self.pkg.write_text("packet\n", encoding="utf-8")

    def tearDown(self):
        self.tmp.cleanup()

    def block(self, *extra, env=None):
        params = self.dir / f"params-{len(list(self.dir.iterdir()))}.txt"
        block = self.dir / f"block-{len(list(self.dir.iterdir()))}.txt"
        result = run(["bash", str(BLOCK), "Cole", "step", str(self.pkg), str(params), str(block), *extra], env=env)
        return result, params, block

    def seed(self, root: Path):
        env = {"KOS_QUEUE_ROOT": str(root)}
        self.assertEqual(run(["python3", "-I", "-B", str(QUEUE), "add", "HEAD", "--title", "head", "--rank", "1"], env=env).returncode, 0)
        self.assertEqual(run(["python3", "-I", "-B", str(QUEUE), "add", "LATER", "--title", "later", "--rank", "2"], env=env).returncode, 0)
        data = json.loads((root / "QUEUE.json").read_text(encoding="utf-8"))
        for item in data["items"]:
            if item["id"] == "HEAD":
                item["touched"] = "2000-01-01"
        (root / "QUEUE.json").write_text(json.dumps(data), encoding="utf-8")

    def test_without_queue_id_needs_no_queue(self):
        result, params, block = self.block()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(params.is_file() and block.is_file())

    def test_missing_queue_id_fails_before_writing(self):
        root = self.dir / "queue"
        root.mkdir()
        result, params, block = self.block("--queue-id", "UNKNOWN", env={"KOS_QUEUE_ROOT": str(root)})
        self.assertEqual(result.returncode, 2)
        self.assertFalse(params.exists() or block.exists())

    def test_registered_head_passes(self):
        root = self.dir / "queue"
        root.mkdir()
        self.seed(root)
        result, params, block = self.block("--queue-id", "HEAD", env={"KOS_QUEUE_ROOT": str(root)})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(params.is_file() and block.is_file())

    def test_jump_without_reason_fails_and_reason_passes(self):
        root = self.dir / "queue"
        root.mkdir()
        self.seed(root)
        result, params, block = self.block("--queue-id", "LATER", env={"KOS_QUEUE_ROOT": str(root)})
        self.assertEqual(result.returncode, 3)
        self.assertFalse(params.exists() or block.exists())
        result, params, block = self.block("--queue-id", "LATER", "--queue-why", "explicit", env={"KOS_QUEUE_ROOT": str(root)})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(params.is_file() and block.is_file())

    def test_task_id_gate_skips_files_until_reason_or_gate_off(self):
        root = self.dir / "queue"
        root.mkdir()
        self.seed(root)
        queued = {"KOS_QUEUE_ROOT": str(root)}
        blocked, params, block = self.block("--task-id", "LATER", env={**queued, "KOS_Q_GATE": "1"})
        self.assertEqual(blocked.returncode, 3)
        self.assertFalse(params.exists() or block.exists())
        allowed, params, block = self.block(
            "--task-id", "LATER", "--queue-why", "explicit", env={**queued, "KOS_Q_GATE": "1"})
        self.assertEqual(allowed.returncode, 0, allowed.stderr)
        self.assertTrue(params.is_file() and block.is_file())
        ungated, params, block = self.block("--task-id", "LATER", env=queued)
        self.assertEqual(ungated.returncode, 0, ungated.stderr)
        self.assertTrue(params.is_file() and block.is_file())


if __name__ == "__main__":
    unittest.main()
