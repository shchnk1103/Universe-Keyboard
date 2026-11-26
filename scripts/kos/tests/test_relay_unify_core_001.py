"""KOS-RELAY-UNIFY-CORE-001 (O92 #2): feature relay arch gate, RS-2, kos_render, final semantics.

Stdlib only; style mirrors test_o41_relay.py.
"""
from __future__ import annotations

import hashlib
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS_DIR = Path(__file__).resolve().parent.parent
REPO_ROOT = KOS_DIR.parent.parent
sys.path.insert(0, str(KOS_DIR))

import kos_render  # noqa: E402


def _write(path: Path, text: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path


def _sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _run_py(script: str, args: list[str], env: dict[str, str] | None = None):
    merged_env = dict(os.environ)
    merged_env["PYTHONDONTWRITEBYTECODE"] = "1"
    if env:
        merged_env.update(env)
    return subprocess.run(
        [sys.executable, "-I", "-B", str(KOS_DIR / script), *args],
        capture_output=True, text=True, env=merged_env,
    )


def _load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


ARCH_BODY = "PASS\nAlex（独立 Architecture 审查）；运行时身份 Codex。\n\n结论：三项设计方向均成立。\n"

FEATURE_PACKET_TMPL = (
    "Executor（代码）；你不是 PM\n\n"
    "# 任务包：示例 feature\n\n"
    "- **包头档位**：`feature`\n"
    "- **复核重点**：\n  1. 检查一切。\n\n"
    "## 冻结输入（执行前必核）\n\n"
    "- {arch_line}\n"
)


def _feature_packet(arch_line: str) -> str:
    return FEATURE_PACKET_TMPL.format(arch_line=arch_line)


class _GitRepoMixin:
    """Minimal throwaway repo with a work commit, like RelayQualityTests."""

    def _init_repo(self, root: Path):
        repo = root / "repo"
        repo.mkdir()
        env = dict(os.environ)
        env.update({
            "GIT_AUTHOR_NAME": "Cowork 3P", "GIT_AUTHOR_EMAIL": "cowork-3p@localhost",
            "GIT_COMMITTER_NAME": "Cowork 3P", "GIT_COMMITTER_EMAIL": "cowork-3p@localhost",
            "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null",
        })

        def git(*a):
            r = subprocess.run(["git", "-C", str(repo), *a], capture_output=True, text=True, env=env)
            self.assertEqual(r.returncode, 0, r.stderr)
            return r.stdout.strip()

        git("init", "-b", "main")
        (repo / ".kos").mkdir()
        (repo / ".kos" / "project.json").write_text("{}\n", encoding="utf-8")
        (repo / "base.txt").write_text("base\n", encoding="utf-8")
        git("add", ".")
        git("commit", "-m", "base")
        base = git("rev-parse", "HEAD")
        (repo / "tool.py").write_text("x = 1\n", encoding="utf-8")
        git("add", ".")
        git("commit", "-m", "work")
        return repo, base


class FeatureRelayExecGateTests(_GitRepoMixin, unittest.TestCase):
    """feature relay-exec arch gate four states (O92 RS-2)."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.repo, self.base = self._init_repo(self.root)
        self.arch = _write(self.root / "arch-report.md", ARCH_BODY)
        self.packet = _write(self.root / "packet.md",
                             _feature_packet(f"`{self.arch}` SHA-256 `{_sha(self.arch)}`"))
        self.report = _write(self.root / "precheck.md", "PASS\nPete（Preflight）；运行时身份 Codex。\n")
        self.ok_stub = _write(self.root / "ok.py", "import sys\nsys.exit(0)\n")
        self.pick_stub = _write(self.root / "pick.py",
                                "print('PICK [Executor（代码）]: Nick（Executor（代码） | -）')\n")

    def tearDown(self):
        self.tmp.cleanup()

    def _run(self, packet=None, report=None):
        return _run_py("kos_handoff.py", [
            "relay-exec",
            "--report", str(report or self.report),
            "--packet", str(packet or self.packet),
            "--base", self.base,
            "--repo", str(self.repo),
            "--verify-tool", str(self.ok_stub),
            "--pkg-lint-tool", str(self.ok_stub),
            "--board", sys.executable,
            "--board-args", json.dumps([str(self.pick_stub)]),
        ])

    def _expect_pm(self, result, fragment=None):
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Jack", result.stdout + result.stderr)
        if fragment:
            self.assertIn(fragment, result.stdout + result.stderr)

    def test_valid_arch_gate_passes(self) -> None:
        result = self._run()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("下一位交付：Executor（代码）部门", result.stdout)
        self.assertIn("授权，直接执行", result.stdout)

    def test_missing_arch_input_falls_back(self) -> None:
        packet = _write(self.root / "no-arch.md", _feature_packet("- `nope` SHA-256 `x`"))
        self._expect_pm(self._run(packet), "feature arch gate failed")

    def test_bad_format_falls_back(self) -> None:
        # path and hash not on one backtick line -> not matched
        packet = _write(self.root / "badfmt.md",
                        _feature_packet(f"`{self.arch}` SHA-256 已知\n`{_sha(self.arch)}`"))
        self._expect_pm(self._run(packet), "feature arch gate failed")

    def test_tampered_sha_falls_back(self) -> None:
        packet = _write(self.root / "tampered.md",
                        _feature_packet(f"`{self.arch}` SHA-256 `{'0' * 64}`"))
        self._expect_pm(self._run(packet), "SHA-256 mismatch")

    def test_non_pass_first_line_falls_back(self) -> None:
        self.arch.write_text("FAIL\nAlex（独立 Architecture 审查）；身份。\n", encoding="utf-8")
        packet = _write(self.root / "fail-arch.md",
                        _feature_packet(f"`{self.arch}` SHA-256 `{_sha(self.arch)}`"))
        self._expect_pm(self._run(packet), "not PASS")

    def test_missing_arch_file_falls_back(self) -> None:
        missing = self.root / "gone" / "arch-gone.md"
        packet = _write(self.root / "gone-arch.md",
                        _feature_packet(f"`{missing}` SHA-256 `{_sha(self.arch)}`"))
        self._expect_pm(self._run(packet), "arch report file missing")


class RelayQualityRs2BypassTests(_GitRepoMixin, unittest.TestCase):
    """RS-2 negative: starting directly from relay-quality with a feature packet
    and no arch gate must be blocked."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.repo, self.base = self._init_repo(self.root)
        self.arch = _write(self.root / "arch-report.md", ARCH_BODY)
        self.report = _write(self.root / "report.md",
                             "DONE\nCole（Executor）；运行时身份 Codex。\n\n"
                             "## 下一站接力（O41）\n- next_role：Quinn（Quality）\n- next_step：复核\n\n"
                             "```text\n交回：Quinn（Quality）\n事项：复核\n```\n")
        self.pick_stub = _write(self.root / "pick.py",
                                "print('PICK [Quality]: Quinn（Quality | -）')\n")

    def tearDown(self):
        self.tmp.cleanup()

    def _run(self, packet: Path):
        return _run_py("kos_handoff.py", [
            "relay-quality",
            "--report", str(self.report),
            "--packet", str(packet),
            "--base", self.base,
            "--repo", str(self.repo),
            "--board", sys.executable,
            "--board-args", json.dumps([str(self.pick_stub)]),
        ])

    def test_feature_without_arch_falls_back(self) -> None:
        packet = _write(self.root / "packet.md",
                        "Executor（代码）；你不是 PM\n\n# 任务包：示例\n\n"
                        "- **包头档位**：`feature`\n- **复核重点**：\n  1. 检查一切。\n\n"
                        "## 冻结输入（执行前必核）\n\n- 无\n")
        result = self._run(packet)
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Jack", result.stdout + result.stderr)
        self.assertIn("feature arch gate failed", result.stdout + result.stderr)

    def test_feature_with_valid_arch_passes(self) -> None:
        packet = _write(self.root / "packet-arch.md",
                        _feature_packet(f"`{self.arch}` SHA-256 `{_sha(self.arch)}`"))
        result = self._run(packet)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Quality 部门", result.stdout)

    def test_tampered_arch_falls_back(self) -> None:
        packet = _write(self.root / "packet-bad.md",
                        _feature_packet(f"`{self.arch}` SHA-256 `{'a' * 64}`"))
        result = self._run(packet)
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("SHA-256 mismatch", result.stdout + result.stderr)


class DocGradeRegressionTests(_GitRepoMixin, unittest.TestCase):
    """doc-rule / code-fix relay behaviour unchanged (no arch gate)."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.repo, self.base = self._init_repo(self.root)
        self.ok_stub = _write(self.root / "ok.py", "import sys\nsys.exit(0)\n")
        self.pick_code = _write(self.root / "pick-code.py",
                                "print('PICK [Executor（代码）]: Nick（Executor（代码） | -）')\n")
        self.pick_doc = _write(self.root / "pick-doc.py",
                               "print('PICK [Executor（记录/文档）]: Maya（Executor（记录/文档） | -）')\n")

    def tearDown(self):
        self.tmp.cleanup()

    def _relay_exec(self, grade: str, packet: Path):
        report = _write(self.root / "precheck.md", "PASS\nPete（Preflight）；运行时身份 Codex。\n")
        return _run_py("kos_handoff.py", [
            "relay-exec",
            "--report", str(report),
            "--packet", str(packet),
            "--base", self.base,
            "--repo", str(self.repo),
            "--verify-tool", str(self.ok_stub),
            "--pkg-lint-tool", str(self.ok_stub),
            "--board", sys.executable,
            "--board-args", json.dumps([str(self.pick_code if grade == "code-fix" else self.pick_doc)]),
        ])

    def test_code_fix_without_arch_still_passes(self) -> None:
        packet = _write(self.root / "packet.md",
                        "Executor（代码）；你不是 PM\n\n# 任务包：示例\n\n"
                        "- **包头档位**：`code-fix`\n- **复核重点**：\n  1. 检查。\n\n"
                        "## 冻结输入（执行前必核）\n\n- 无 arch 输入\n")
        result = self._relay_exec("code-fix", packet)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Executor（代码）部门", result.stdout)

    def test_doc_rule_without_arch_still_passes(self) -> None:
        packet = _write(self.root / "packet-doc.md",
                        "Executor（记录/文档）；你不是 PM\n\n# 任务包：示例文档\n\n"
                        "- **包头档位**：`doc-rule`\n- **复核重点**：\n  1. 检查。\n\n"
                        "## 冻结输入（执行前必核）\n\n- 无 arch 输入\n")
        result = self._relay_exec("doc-rule", packet)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Executor（文档）部门", result.stdout)


class FeatureProfileTests(unittest.TestCase):
    """profile --grade feature output contains both relays; others unchanged."""

    def _profile(self, *args):
        return _run_py("kos_handoff.py", ["profile", "--grade", *args])

    def test_feature_lists_both_relays(self) -> None:
        result = self._profile("feature")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("relay-exec", result.stdout)
        self.assertIn("relay-quality", result.stdout)

    def test_feature_actions_allowed(self) -> None:
        for action in ("relay-exec", "relay-quality"):
            result = self._profile("feature", "--action", action)
            self.assertEqual(result.returncode, 0, f"{action}: {result.stdout}{result.stderr}")
            self.assertIn("allowed", result.stdout)

    def test_doc_light_still_forbidden(self) -> None:
        result = self._profile("doc-light", "--action", "relay-exec")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Jack", result.stdout + result.stderr)

    def test_code_fix_unchanged(self) -> None:
        result = self._profile("code-fix", "--action", "relay-quality")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


class RenderModuleTests(unittest.TestCase):
    """Three call sites produce byte-identical blocks via kos_render."""

    def test_dispatch_block_identical_across_call_sites(self) -> None:
        pack = _load("kos_pack_mod", KOS_DIR / "kos_pack.py")
        handoff = _load("kos_handoff_mod", KOS_DIR / "kos_handoff.py")
        args = ("T-1", "Quinn", "Quality", "/tmp/pkg.md", "a" * 64)
        self.assertEqual(
            kos_render.dispatch_block(args[0], args[1], args[2], args[3], args[4]),
            pack.dispatch_block(args[0], args[1], args[2], Path(args[3]), args[4]),
        )
        suggestion = handoff.dispatch_block(args[0], args[1], args[2], args[3], args[4],
                                            auth_line="授权，直接执行")
        self.assertIn("授权，直接执行", suggestion)
        # stripping the fence and auth line yields the canonical 4-line block
        canonical = kos_render.dispatch_block(args[0], args[1], args[2], args[3], args[4])
        self.assertEqual(
            suggestion.replace("\n授权，直接执行", "", 1),
            canonical,
        )

    def test_entry_block_matches_render_three_line(self) -> None:
        handoff = _load("kos_handoff_mod2", KOS_DIR / "kos_handoff.py")
        with tempfile.TemporaryDirectory() as tmp:
            report = _write(Path(tmp) / "r.md", "DONE\nLucy\n")
            entry = _write(Path(tmp) / "e.md", "# 入口\n")
            out = handoff.render_three_line(
                "PASS", "ok", "Quinn（Quality）", "复核", str(report),
                entry_path=str(entry), task_title="任务 A")
            expected = kos_render.entry_block(
                "Quinn（Quality）", "任务 A", str(Path(entry).resolve()), _sha(Path(entry)))
            self.assertIn(expected, out)

    def test_final_block_matches_render_three_line(self) -> None:
        handoff = _load("kos_handoff_mod3", KOS_DIR / "kos_handoff.py")
        with tempfile.TemporaryDirectory() as tmp:
            report = _write(Path(tmp) / "r.md", "DONE\nLucy\n")
            out = handoff.render_three_line(
                "DONE", "ok", "Jack（PM）", "复核", str(report))
            real = str(Path(report).resolve())
            expected = kos_render.final_block(
                "Jack（PM）", "复核", real, _sha(Path(report)))
            self.assertIn(expected, out)


class FinalPmSemanticsTests(unittest.TestCase):
    """cmd_final always hands back to the PM; auto-picked employee becomes a
    separate 建议派发 block."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def _report(self, next_role: str = "Quality Reviewer",
                line2: str = "Lucy（Executor（代码））；运行时身份 Codex。") -> Path:
        report = self.root / "reports" / "report.md"
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(
            f"DONE\n{line2}\n\n"
            "## 下一站接力（O41）\n"
            f"- next_role：{next_role}\n- next_step：复核\n\n"
            "```text\n"
            f"交回：{next_role}\n事项：复核\n报告：{report}\nSHA-256：{'0' * 64}\n"
            "```\n",
            encoding="utf-8")
        return report

    def _final(self, report: Path):
        stub = self.root / "pick.py"
        stub.write_text("print('PICK [Quality]: Quinn（Quality | -）')\n", encoding="utf-8")
        return _run_py("kos_handoff.py", [
            "final", "--report", str(report), "--skip-lint",
            "--board", sys.executable, "--board-args", json.dumps([str(stub)]),
        ])

    def test_final_block_is_pm_with_suggestion(self) -> None:
        report = self._report()
        result = self._final(report)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("交回：Jack（PM）", result.stdout)
        self.assertIn("## 建议派发（PM 复核后使用）", result.stdout)
        self.assertIn("角色：Quinn（Quality Reviewer）", result.stdout)
        # line 2 still names the picked employee for the PM to route
        self.assertIn("下一位交付：Quinn", result.stdout)
        # the fenced hand-back block itself must not dispatch straight to Quinn
        fenced = result.stdout.split("```text", 1)[1].split("```", 1)[0]
        self.assertIn("交回：Jack（PM）", fenced)
        self.assertNotIn("Quinn", fenced)

    def test_final_pm_only_when_no_pick(self) -> None:
        report = self._report(next_role="Jack（PM）")
        result = _run_py("kos_handoff.py", [
            "final", "--report", str(report), "--skip-lint",
            "--board", sys.executable,
            "--board-args", json.dumps(["-c", "print('PICK [x]: none')"]),
        ])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("交回：Jack（PM）", result.stdout)
        self.assertNotIn("建议派发", result.stdout)


if __name__ == "__main__":
    unittest.main()
