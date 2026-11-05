from __future__ import annotations

import importlib.util
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "classify_changes.py"
SPEC = importlib.util.spec_from_file_location("classify_changes", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


def workflow_kos_references(repo_root: Path) -> list[str]:
    workflows = repo_root / ".github" / "workflows"
    if not workflows.is_dir():
        raise FileNotFoundError(workflows)
    return [
        str(path.relative_to(repo_root))
        for path in workflows.rglob("*")
        if path.is_file() and "scripts/kos" in path.read_text(encoding="utf-8")
    ]


class ClassifyPathsTests(unittest.TestCase):
    def test_root_markdown_is_lightweight(self) -> None:
        result = MODULE.classify_paths(["README.md", "AGENTS.md"])
        self.assertEqual(result.name, "docs_only")
        self.assertFalse(result.requires_full)

    def test_docs_and_kos_are_lightweight(self) -> None:
        result = MODULE.classify_paths(
            ["docs/assignments/example.md", "docs/evidence/image.png", ".kos/project.json"]
        )
        self.assertEqual(result.name, "docs_only")

    def test_nested_markdown_outside_docs_is_full(self) -> None:
        result = MODULE.classify_paths(["Packages/KeyboardCore/README.md"])
        self.assertTrue(result.requires_full)
        self.assertEqual(result.full_required_paths, ("Packages/KeyboardCore/README.md",))

    def test_sensitive_paths_are_full(self) -> None:
        paths = [
            ".github/workflows/swift6-quality.yml",
            "Keyboard/Controller.swift",
            "Packages/KeyboardCore/Package.swift",
            "Universe Keyboard.xcodeproj/project.pbxproj",
            "scripts/ensure_rime_vendor.sh",
        ]
        result = MODULE.classify_paths(paths)
        self.assertEqual(result.name, "full")
        self.assertEqual(set(result.full_required_paths), set(paths))

    def test_unknown_path_is_full(self) -> None:
        result = MODULE.classify_paths(["new-build-input.dat"])
        self.assertTrue(result.requires_full)
        self.assertEqual(result.reason, "sensitive_or_unknown_path")

    def test_empty_diff_is_full(self) -> None:
        result = MODULE.classify_paths([])
        self.assertTrue(result.requires_full)
        self.assertEqual(result.reason, "empty_diff_fails_closed")

    def test_unsafe_relative_path_is_full(self) -> None:
        self.assertFalse(MODULE.is_lightweight_path("docs/../Keyboard/File.swift"))

    def test_invalid_base_head_and_non_commit_references_fail_closed(self) -> None:
        original_directory = Path.cwd()
        with tempfile.TemporaryDirectory() as directory:
            repository = Path(directory)
            subprocess.run(["git", "init", "-q"], cwd=repository, check=True)
            subprocess.run(
                ["git", "config", "user.email", "ci-test@example.invalid"],
                cwd=repository,
                check=True,
            )
            subprocess.run(
                ["git", "config", "user.name", "CI Test"], cwd=repository, check=True
            )
            source = repository / "README.md"
            source.write_text("fixture\n", encoding="utf-8")
            subprocess.run(["git", "add", "README.md"], cwd=repository, check=True)
            subprocess.run(["git", "commit", "-qm", "base"], cwd=repository, check=True)
            commit = subprocess.check_output(
                ["git", "rev-parse", "HEAD"], cwd=repository, text=True
            ).strip()
            blob = subprocess.check_output(
                ["git", "hash-object", "README.md"], cwd=repository, text=True
            ).strip()

            try:
                os.chdir(repository)
                invalid_pairs = [
                    ("missing-base", commit),
                    (commit, "missing-head"),
                    (blob, commit),
                    (commit, blob),
                ]
                for base, head in invalid_pairs:
                    with self.subTest(base=base, head=head):
                        with self.assertRaises(ValueError):
                            MODULE.changed_paths(base, head)
            finally:
                os.chdir(original_directory)

    def test_source_to_docs_rename_keeps_old_sensitive_path(self) -> None:
        original_directory = Path.cwd()
        with tempfile.TemporaryDirectory() as directory:
            repository = Path(directory)
            subprocess.run(["git", "init", "-q"], cwd=repository, check=True)
            subprocess.run(
                ["git", "config", "user.email", "ci-test@example.invalid"],
                cwd=repository,
                check=True,
            )
            subprocess.run(
                ["git", "config", "user.name", "CI Test"], cwd=repository, check=True
            )
            (repository / "Source.swift").write_text("let value = 1\n", encoding="utf-8")
            subprocess.run(["git", "add", "Source.swift"], cwd=repository, check=True)
            subprocess.run(["git", "commit", "-qm", "base"], cwd=repository, check=True)
            base = subprocess.check_output(
                ["git", "rev-parse", "HEAD"], cwd=repository, text=True
            ).strip()

            (repository / "docs").mkdir()
            subprocess.run(
                ["git", "mv", "Source.swift", "docs/Source.md"],
                cwd=repository,
                check=True,
            )
            subprocess.run(["git", "commit", "-qm", "rename"], cwd=repository, check=True)
            head = subprocess.check_output(
                ["git", "rev-parse", "HEAD"], cwd=repository, text=True
            ).strip()

            try:
                os.chdir(repository)
                paths = MODULE.changed_paths(base, head)
            finally:
                os.chdir(original_directory)

        self.assertEqual(set(paths), {"Source.swift", "docs/Source.md"})
        self.assertTrue(MODULE.classify_paths(paths).requires_full)

    def test_kos_tools_only_skips_full_gate(self) -> None:
        result = MODULE.classify_paths(["scripts/kos/pr_flow.py"])
        self.assertEqual(result.name, "kos_tools_only")
        self.assertFalse(result.requires_full)

    def test_kos_tools_with_docs_stay_lightweight(self) -> None:
        result = MODULE.classify_paths(["scripts/kos/pr_flow.py", "docs/CI_CHANGE_CLASSIFICATION.md"])
        self.assertEqual(result.name, "kos_tools_only")
        self.assertFalse(result.requires_full)

    def test_kos_tools_with_ci_scripts_are_full(self) -> None:
        result = MODULE.classify_paths(["scripts/kos/pr_flow.py", "scripts/ci/classify_changes.py"])
        self.assertEqual(result.name, "full")
        self.assertTrue(result.requires_full)

    def test_kos_tools_with_workflow_are_full(self) -> None:
        result = MODULE.classify_paths(
            ["scripts/kos/pr_flow.py", ".github/workflows/swift6-quality.yml"]
        )
        self.assertEqual(result.name, "full")
        self.assertTrue(result.requires_full)

    def test_kos_tools_with_swift_source_are_full(self) -> None:
        result = MODULE.classify_paths(["scripts/kos/pr_flow.py", "Keyboard/Controller.swift"])
        self.assertEqual(result.name, "full")
        self.assertTrue(result.requires_full)

    def test_kos_prefix_lookalike_is_full(self) -> None:
        result = MODULE.classify_paths(["scripts/kosx/foo.py"])
        self.assertEqual(result.name, "full")
        self.assertTrue(result.requires_full)

    def test_keyboard_swift_rename_into_kos_tools_is_full(self) -> None:
        original_directory = Path.cwd()
        with tempfile.TemporaryDirectory() as directory:
            repository = Path(directory)
            subprocess.run(["git", "init", "-q"], cwd=repository, check=True)
            subprocess.run(
                ["git", "config", "user.email", "ci-test@example.invalid"],
                cwd=repository,
                check=True,
            )
            subprocess.run(
                ["git", "config", "user.name", "CI Test"], cwd=repository, check=True
            )
            (repository / "Keyboard").mkdir()
            (repository / "Keyboard" / "Controller.swift").write_text(
                "let value = 1\n", encoding="utf-8"
            )
            subprocess.run(["git", "add", "Keyboard/Controller.swift"], cwd=repository, check=True)
            subprocess.run(["git", "commit", "-qm", "base"], cwd=repository, check=True)
            base = subprocess.check_output(
                ["git", "rev-parse", "HEAD"], cwd=repository, text=True
            ).strip()
            (repository / "scripts" / "kos").mkdir(parents=True)
            subprocess.run(
                ["git", "mv", "Keyboard/Controller.swift", "scripts/kos/Controller.swift"],
                cwd=repository,
                check=True,
            )
            subprocess.run(["git", "commit", "-qm", "rename"], cwd=repository, check=True)
            head = subprocess.check_output(
                ["git", "rev-parse", "HEAD"], cwd=repository, text=True
            ).strip()
            try:
                os.chdir(repository)
                paths = MODULE.changed_paths(base, head)
            finally:
                os.chdir(original_directory)

        self.assertEqual(set(paths), {"Keyboard/Controller.swift", "scripts/kos/Controller.swift"})
        result = MODULE.classify_paths(paths)
        self.assertEqual(result.name, "full")
        self.assertTrue(result.requires_full)

    def test_workflows_do_not_reference_kos_tools(self) -> None:
        root = Path(__file__).resolve().parents[3]
        self.assertEqual(workflow_kos_references(root), [])

    def test_workflow_kos_reference_is_detected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            workflows = root / ".github" / "workflows"
            workflows.mkdir(parents=True)
            (workflows / "ci.yml").write_text("scripts/kos/pr_flow.py", encoding="utf-8")
            self.assertEqual(workflow_kos_references(root), [".github/workflows/ci.yml"])

    def test_workflow_without_kos_reference_is_clear(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            workflows = root / ".github" / "workflows"
            workflows.mkdir(parents=True)
            (workflows / "ci.yml").write_text("ordinary workflow", encoding="utf-8")
            self.assertEqual(workflow_kos_references(root), [])

    def test_missing_workflows_directory_fails(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(FileNotFoundError):
                workflow_kos_references(Path(directory))



if __name__ == "__main__":
    unittest.main()
