"""Regression tests for KOS-TOOLS-FIX-001. Import must not run the CLIs."""
from __future__ import annotations

import importlib.util
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


KOS = Path(__file__).resolve().parents[1]


def load(name: str, filename: str):
    spec = importlib.util.spec_from_file_location(name, KOS / filename)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


FREEZE = load("kos_freeze_fix", "freeze.py")
CLAIM = load("kos_claim_fix", "claim-check.py")
TREE = load("kos_tree_fix", "verify-tree.py")

SHELL = """**你的角色：Executor。你不是 PM。最终消息只写一句话。
写入被拒。不写 /tmp。授权原文另存 reports/r.md。
Cowork 3P <cowork-3p@localhost>
"""


class ImportGuardTests(unittest.TestCase):
    def test_modules_expose_main_without_running(self) -> None:
        self.assertTrue(callable(CLAIM.main))
        self.assertTrue(callable(TREE.main))
        self.assertTrue(callable(FREEZE.main))


class RecomputedHashTests(unittest.TestCase):
    def test_listed_hash_is_not_a_missing_source_and_default_still_reports_it(self) -> None:
        digest = "a1" * 32
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            subprocess.run(["git", "init", "-q"], cwd=root, check=True)
            subprocess.run(["git", "-C", str(root), "-c", "user.name=T", "-c", "user.email=t@localhost", "commit", "--allow-empty", "-q", "-m", "base"], check=True)
            base = subprocess.run(["git", "-C", str(root), "rev-parse", "HEAD"], check=True, capture_output=True, text=True).stdout.strip()
            (root / "note.md").write_text(f"see {digest}\n", encoding="utf-8")
            subprocess.run(["git", "-C", str(root), "add", "note.md"], check=True)
            subprocess.run(["git", "-C", str(root), "-c", "user.name=T", "-c", "user.email=t@localhost", "commit", "-q", "-m", "add"], check=True)
            head = subprocess.run(["git", "-C", str(root), "rev-parse", "HEAD"], check=True, capture_output=True, text=True).stdout.strip()
            source = root / "source.md"
            source.write_text("no hash here\n", encoding="utf-8")
            listed = root / "recomputed.txt"
            listed.write_text(digest.upper() + "\n\n", encoding="utf-8")
            script = str(KOS / "claim-check.py")
            common = [sys.executable, "-B", script, str(root), base, head, str(source)]
            missing = subprocess.run(common, capture_output=True, text=True)
            self.assertEqual(missing.returncode, 0, missing.stderr)
            self.assertIn(digest, missing.stdout)
            quiet = subprocess.run(
                [sys.executable, "-B", script, "--recomputed-hashes", str(listed), str(root), base, head, str(source)],
                capture_output=True,
                text=True,
            )
            self.assertEqual(quiet.returncode, 0, quiet.stderr)
            self.assertIn("none", quiet.stdout.split("== lexicon")[0])
            self.assertNotIn(digest, quiet.stdout.split("== lexicon")[0])


class BuildSkipFalsePositiveTests(unittest.TestCase):
    def test_explicit_denial_does_not_require_derived_data_or_skip_wording(self) -> None:
        text = SHELL + "不运行任何 Swift 或 Xcode 的构建与测试，不启动任何设备。文中提到 xcodebuild 与模拟器只是禁止。\n"
        problems = FREEZE.lint_problems(text, requires_commit=True)
        # lint_problems still treats the denial as “not a build this package runs”.
        # Rule 6 is separate: “xcodebuild” sits in the next sentence, and the shell has “只写”.
        self.assertNotIn("build output location", problems)
        self.assertNotIn("skip wording", problems)
        self.assertTrue(any("no build output location" in p for p in problems), problems)

    def test_real_build_still_requires_output_location_and_skip_wording(self) -> None:
        text = SHELL + "运行 xcodebuild，并使用模拟器。\n"
        problems = FREEZE.lint_problems(text, requires_commit=True)
        self.assertIn("build output location", problems)
        self.assertIn("skip wording", problems)

    def test_readonly_rule6_does_not_require_build_output(self) -> None:
        text = "运行 swift test\n只写 scratch"
        self.assertEqual(FREEZE.consistency(text, readonly=True), [])
        self.assertTrue(any("no build output location" in e for e in FREEZE.consistency(text)))

    def test_do_not_run_in_another_sentence_does_not_exempt_swift_test(self) -> None:
        # Old expectation treated any “不运行……构建” as a whole-package exemption.
        # Rule 6 now looks at the sentence that names the tool.
        text = "不运行构建。另有 swift test 字样。\n只写 scratch"
        self.assertTrue(any("no build output location" in e for e in FREEZE.consistency(text)))

    def test_review_counterexample_still_reports_missing_output(self) -> None:
        text = "运行 swift build。\n只写 scratch。\n不运行构建。"
        self.assertTrue(any("no build output location" in e for e in FREEZE.consistency(text)))

    def test_same_sentence_do_not_run_swift_build_is_exempt(self) -> None:
        text = "不运行 swift build。\n只写 scratch"
        self.assertEqual(FREEZE.consistency(text), [])

    def test_same_sentence_do_not_start_device_is_exempt(self) -> None:
        text = "不启动任何设备，文中的 xcodebuild 只是禁止。\n只写 scratch"
        self.assertEqual(FREEZE.consistency(text), [])


class NetworkFalsePositiveTests(unittest.TestCase):
    def test_limited_readonly_gh_does_not_conflict_with_offline(self) -> None:
        text = "不联网。联网只限（只读 `gh`）查询。"
        self.assertFalse(any("不联网" in e for e in FREEZE.consistency(text)))

    def test_readonly_network_preapproval_still_conflicts(self) -> None:
        errors = FREEZE.consistency("不联网\n允许只读联网")
        self.assertTrue(any("不联网" in e for e in errors), errors)

    def test_fullwidth_paren_network_preapproval_still_conflicts(self) -> None:
        errors = FREEZE.consistency("不联网。\n允许联网（只读查询）。")
        self.assertTrue(any("不联网" in e for e in errors), errors)


class SwiftFormatGateTests(unittest.TestCase):
    def test_docs_package_with_requires_commit_does_not_force_swift_format(self) -> None:
        text = SHELL + "包内没有 `.swift` 路径，配置文件是 .swift-format。\n见 docs/assignments/kos-externalize-001.md。\n"
        problems = FREEZE.lint_problems(text, requires_commit=True)
        self.assertNotIn("swift-format lint gate", problems)

    def test_swift_path_still_requires_lint_strict(self) -> None:
        text = SHELL + "改 App/Foo.swift。见 docs/assignments/kos-externalize-001.md。\n"
        problems = FREEZE.lint_problems(text, requires_commit=True)
        self.assertIn("swift-format lint gate", problems)


class AssignmentLintTests(unittest.TestCase):
    def test_missing_assignment_is_consistency_error_only_with_requires_commit(self) -> None:
        text = SHELL + "只提到 docs/ASSIGNMENT_POLICY.md。无 Assignment"
        problems = FREEZE.lint_problems(text, requires_commit=True)
        self.assertTrue(any("missing Assignment" in p for p in problems), problems)
        self.assertFalse(any("missing Assignment" in p for p in FREEZE.lint_problems(text)))

    def test_path_or_reason_satisfies_the_check(self) -> None:
        with_path = SHELL + "Assignment 是 docs/assignments/kos-externalize-001.md。\n"
        with_reason = SHELL + "无 Assignment：当时没有此文件，仅补记历史。\n"
        self.assertFalse(any("missing Assignment" in p for p in FREEZE.lint_problems(with_path, requires_commit=True)))
        self.assertFalse(any("missing Assignment" in p for p in FREEZE.lint_problems(with_reason, requires_commit=True)))


if __name__ == "__main__":
    unittest.main()
