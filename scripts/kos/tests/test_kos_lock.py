"""KOS-RELAY-AUTO-001 slice 1: physical resource locks."""
import json
import os
import subprocess
import tempfile
import threading
import time
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LOCK = ROOT / "scripts" / "kos" / "kos-lock.py"


def run(args, root):
    env = os.environ.copy()
    env["KOS_QUEUE_ROOT"] = str(root)
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    return subprocess.run(
        ["python3", "-I", "-B", str(LOCK), *args],
        capture_output=True, text=True, env=env)


class LockTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name) / "queue"

    def tearDown(self):
        self.tmp.cleanup()

    def data(self):
        return json.loads((self.root / "RESOURCES.json").read_text(encoding="utf-8"))

    def test_acquire_empty_then_repeat_keeps_since(self):
        first = run(["acquire", "sim", "--task", "TASK-A", "--session", "one"], self.root)
        self.assertEqual(first.returncode, 0, first.stderr)
        since = self.data()["resources"]["sim"]["since"]
        time.sleep(0.01)
        second = run(["acquire", "sim", "--task", "TASK-A", "--session", "one"], self.root)
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(self.data()["resources"]["sim"]["since"], since)

    def test_other_holder_rejects_without_changing_bytes(self):
        self.assertEqual(run(["acquire", "sim", "--task", "TASK-A", "--session", "one"], self.root).returncode, 0)
        before = (self.root / "RESOURCES.json").read_bytes()
        other = run(["acquire", "sim", "--task", "TASK-B", "--session", "two"], self.root)
        self.assertEqual(other.returncode, 4)
        self.assertEqual((self.root / "RESOURCES.json").read_bytes(), before)

    def test_release_by_non_holder_returns_5(self):
        self.assertEqual(run(["acquire", "main", "--task", "TASK-A", "--session", "one"], self.root).returncode, 0)
        result = run(["release", "main", "--task", "TASK-B"], self.root)
        self.assertEqual(result.returncode, 5)
        self.assertEqual(self.data()["resources"]["main"]["task"], "TASK-A")

    def test_corrupt_json_returns_1(self):
        self.root.mkdir()
        (self.root / "RESOURCES.json").write_text("{", encoding="utf-8")
        self.assertEqual(run(["status"], self.root).returncode, 1)

    def test_unknown_resource_returns_2(self):
        self.assertEqual(run(["acquire", "disk", "--task", "TASK-A", "--session", "one"], self.root).returncode, 2)
        self.assertEqual(run(["release", "disk", "--task", "TASK-A"], self.root).returncode, 2)

    def test_force_release_requires_reason_and_logs_it(self):
        self.assertEqual(run(["acquire", "sim", "--task", "TASK-A", "--session", "one"], self.root).returncode, 0)
        missing = run(["force-release", "sim"], self.root)
        self.assertEqual(missing.returncode, 1)
        self.assertIsNotNone(self.data()["resources"]["sim"])
        done = run(["force-release", "sim", "--why", "holder crashed"], self.root)
        self.assertEqual(done.returncode, 0, done.stderr)
        self.assertIsNone(self.data()["resources"]["sim"])
        self.assertIn("holder crashed", (self.root / "QUEUE-LOG.md").read_text(encoding="utf-8"))

    def test_fresh_lock_with_live_pid_is_not_suspect(self):
        previous = os.environ.get("TZ")
        os.environ["TZ"] = "Asia/Shanghai"
        try:
            acquired = run(
                ["acquire", "sim", "--task", "TASK-A", "--session", "one", "--pid", str(os.getpid())],
                self.root)
            self.assertEqual(acquired.returncode, 0, acquired.stderr)
            status = run(["status"], self.root)
            self.assertEqual(status.returncode, 0, status.stderr)
            self.assertNotIn("SUSPECT", status.stdout)
        finally:
            if previous is None:
                os.environ.pop("TZ", None)
            else:
                os.environ["TZ"] = previous

    def test_status_marks_dead_pid_and_old_lock_suspect(self):
        self.assertEqual(run(["acquire", "sim", "--task", "TASK-A", "--session", "one", "--pid", "99999999"], self.root).returncode, 0)
        status = run(["status"], self.root)
        self.assertEqual(status.returncode, 0, status.stderr)
        self.assertIn("SUSPECT", status.stdout)
        data = self.data()
        data["resources"]["main"] = {"task": "TASK-B", "session": "old", "pid": os.getpid(), "since": "2000-01-01T00:00:00Z", "note": ""}
        (self.root / "RESOURCES.json").write_text(json.dumps(data), encoding="utf-8")
        status = run(["status"], self.root)
        self.assertIn("SUSPECT", status.stdout)

    def test_concurrent_acquire_has_one_winner(self):
        codes = []

        def attempt(task):
            codes.append(run(["acquire", "sim", "--task", task, "--session", "race"], self.root).returncode)

        threads = [threading.Thread(target=attempt, args=(f"TASK-RACE-{i}",)) for i in range(2)]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join()
        self.assertEqual(codes.count(0), 1)
        self.assertEqual(codes.count(4), 1)

    def test_multi_acquire_rolls_back_when_second_resource_is_held(self):
        self.assertEqual(run(["acquire", "main", "--task", "TASK-B", "--session", "other"], self.root).returncode, 0)
        before = (self.root / "RESOURCES.json").read_bytes()
        result = run(["acquire", "sim", "main", "--task", "TASK-A", "--session", "one"], self.root)
        self.assertEqual(result.returncode, 4)
        self.assertEqual((self.root / "RESOURCES.json").read_bytes(), before)
        self.assertIsNone(self.data()["resources"]["sim"])


BLOCK = ROOT / "scripts" / "kos" / "kos-block.sh"


class BlockResourceTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.base = Path(self.tmp.name)
        self.root = self.base / "queue"
        self.pkg = self.base / "pkg.md"
        self.pkg.write_text("package\n", encoding="utf-8")
        self.n = 0

    def tearDown(self):
        self.tmp.cleanup()

    def block(self, *extra):
        self.n += 1
        params = self.base / f"params-{self.n}.txt"
        block = self.base / f"block-{self.n}.txt"
        env = os.environ.copy()
        env["KOS_QUEUE_ROOT"] = str(self.root)
        env["PYTHONDONTWRITEBYTECODE"] = "1"
        env.pop("KOS_Q_GATE", None)
        env.pop("KOS_BLOCK_FORCE", None)
        result = subprocess.run(
            ["bash", str(BLOCK), "Lucy", "step", str(self.pkg), str(params), str(block), *extra],
            capture_output=True, text=True, env=env)
        return result, params, block

    def lock(self, *args):
        env = os.environ.copy()
        env["KOS_QUEUE_ROOT"] = str(self.root)
        env["PYTHONDONTWRITEBYTECODE"] = "1"
        return subprocess.run(
            ["python3", "-I", "-B", str(LOCK), *args],
            capture_output=True, text=True, env=env)

    def data(self):
        return json.loads((self.root / "RESOURCES.json").read_text(encoding="utf-8"))

    def test_without_resource_writes_dispatch_and_does_not_touch_lock_dir(self):
        result, params, block = self.block("--task-id", "TASK-A", "--role", "Lucy")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(params.is_file() and block.is_file())
        self.assertFalse(self.root.exists())

    def test_sim_resource_acquires_lock_and_writes_dispatch(self):
        result, params, block = self.block("--task-id", "TASK-A", "--role", "Lucy", "--resource", "sim")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(params.is_file() and block.is_file())
        held = self.data()["resources"]["sim"]
        self.assertEqual(held["task"], "TASK-A")
        self.assertEqual(held["session"], "Lucy")

    def test_held_sim_blocks_dispatch_without_writing_files(self):
        self.assertEqual(self.lock("acquire", "sim", "--task", "TASK-B", "--session", "other").returncode, 0)
        result, params, block = self.block("--task-id", "TASK-A", "--role", "Lucy", "--resource", "sim")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(params.exists() or block.exists())
        self.assertEqual(self.data()["resources"]["sim"]["task"], "TASK-B")

    def test_resource_without_task_id_exits_2_without_writing(self):
        result, params, block = self.block("--resource", "sim")
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertFalse(params.exists() or block.exists())
        self.assertFalse(self.root.exists())

    def test_multi_resource_conflict_leaves_no_partial_lock_or_dispatch(self):
        self.assertEqual(self.lock("acquire", "sim", "--task", "TASK-B", "--session", "other").returncode, 0)
        before = (self.root / "RESOURCES.json").read_bytes()
        result, params, block = self.block(
            "--task-id", "TASK-A", "--role", "Lucy", "--resource", "main", "--resource", "sim")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(params.exists() or block.exists())
        self.assertEqual((self.root / "RESOURCES.json").read_bytes(), before)
        self.assertIsNone(self.data()["resources"]["main"])

    def test_illegal_resource_exits_without_dispatch(self):
        result, params, block = self.block("--task-id", "TASK-A", "--role", "Lucy", "--resource", "foo")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(params.exists() or block.exists())
        self.assertFalse((self.root / "RESOURCES.json").exists())

    def test_missing_package_with_resource_exits_2_without_lock(self):
        self.pkg = self.base / "missing-pkg.md"
        result, params, block = self.block("--task-id", "TASK-A", "--role", "Lucy", "--resource", "sim")
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertFalse(params.exists() or block.exists())
        self.assertFalse((self.root / "RESOURCES.json").exists())

    def test_missing_note_path_with_resource_exits_2_without_lock(self):
        missing = self.base / "missing-note.md"
        result, params, block = self.block(
            "--task-id", "TASK-A", "--role", "Lucy", "--resource", "main", f"note_path={missing}")
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertFalse(params.exists() or block.exists())
        self.assertFalse((self.root / "RESOURCES.json").exists())


if __name__ == "__main__":
    unittest.main()
