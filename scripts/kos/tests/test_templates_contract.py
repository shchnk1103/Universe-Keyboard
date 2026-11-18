"""Contract examples for the template upgrade; Git operations use disposable repositories.

The decision helpers below model the frozen written contract. They are not a
production CI evaluator or cleanup tool, and passing them proves neither ran.
"""
from __future__ import annotations

import shutil
import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
KOS = ROOT / "scripts/kos"
spec = importlib.util.spec_from_file_location("templates_clauses_spec", KOS / "clauses_spec.py")
clauses = importlib.util.module_from_spec(spec)
spec.loader.exec_module(clauses)
HEAVY = clauses.HEAVY_CHECKS
COMMON = clauses.COMMON_REQUIRED_CHECKS
MATRIX = clauses.CLASSIFICATION_REQUIRED_HEAVY

# Independent frozen expectations catch accidental changes to the shared matrix.
EXPECTED = {
    "docs_only": set(), "kos_tools_only": set(),
    "keyboard_ui_only": {"format-swift", "test-app-keyboard", "build-release"},
    "rimebridge_only": {"format-swift", "test-rimebridge", "test-app-keyboard", "build-release"},
    "rimebridge_sync_only": HEAVY - {"test-keyboardcore"},
    "app_only": {"format-swift", "test-app-keyboard", "build-release"},
    "app_sync_only": HEAVY - {"test-keyboardcore", "test-rimebridge"},
    "full": HEAVY,
}


def acceptable(category, checks):
    if category not in MATRIX or set(checks) != COMMON | HEAVY:
        return False
    required = COMMON | MATRIX[category]
    return all(checks[name] == "success" if name in required else
               checks[name] in {"success", "skipped"} for name in checks)


class MatrixContractTests(unittest.TestCase):
    def test_each_category_and_terminal_states(self):
        self.assertEqual(MATRIX, EXPECTED)
        self.assertEqual(COMMON, {"classify-change", "lightweight-checks", "final-quality-gate", "GitGuardian Security Checks"})
        self.assertEqual(HEAVY, {"format-swift", "test-keyboardcore", "test-rimebridge", "test-app-keyboard", "test-rime-sync-keychain", "build-release"})
        self.assertEqual(clauses.CLASSIFICATION_ALLOWED_SKIPPED,
                         {category: HEAVY - selected for category, selected in EXPECTED.items()})
        for category, selected in MATRIX.items():
            good = {name: ("success" if name in COMMON | selected else "skipped")
                    for name in COMMON | HEAVY}
            with self.subTest(category=category):
                self.assertTrue(acceptable(category, good))
                self.assertTrue(acceptable(category, {name: "success" for name in good}))
                for name in COMMON | selected:
                    for state in ("failure", "cancelled", "skipped", "skipping", "in_progress", "unknown", "not watching"):
                        bad = dict(good, **{name: state})
                        self.assertFalse(acceptable(category, bad), (name, state))
                    bad = dict(good)
                    del bad[name]
                    self.assertFalse(acceptable(category, bad), name)
                for name in HEAVY - selected:
                    for state in ("failure", "cancelled", "skipping", "in_progress", "unknown", "not watching"):
                        self.assertFalse(acceptable(category, dict(good, **{name: state})))
        self.assertFalse(acceptable("unknown", {name: "success" for name in COMMON | HEAVY}))

    def test_document_markers_match_spec(self):
        doc = (ROOT / "docs/kos/pm-packet-clauses.md").read_text(encoding="utf-8")
        markers = (clauses.CLAUSES_DOC_SYNC_MARKERS + clauses.COMMON_PACKET_MARKERS +
                   clauses.PUBLISH_PACKET_MARKERS + clauses.LAND_PACKET_MARKERS)
        for marker in markers:
            with self.subTest(marker=marker):
                self.assertIn(marker, doc)


class GeneratedTemplateTests(unittest.TestCase):
    def test_real_draft_render_contains_required_contract(self):
        # The generator and templates are external to the repository: exercise
        # copies in a temporary KOS home, never write into the real KOS home.
        source = Path.home() / ".kos-work/Universe-Keyboard"
        generator = source / "tools/kos-draft.py"
        templates = source / "templates"
        if not generator.is_file() or not (templates / "COMMANDS.md").is_file():
            self.skipTest("external kos-draft and templates unavailable")
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            shutil.copytree(templates, home / "templates")
            (home / "fixture").mkdir()
            script = (
                "import importlib.util, json, sys\n"
                "spec = importlib.util.spec_from_file_location('draft', sys.argv[1])\n"
                "m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)\n"
                "kind = sys.argv[2]\n"
                "template = m.expand_cmds(m.read(m.os.path.join(m.TPL, m.TYPES[kind][0])))\n"
                "keys, _, required = m.keys_of(template)\n"
                "p = {k: 'fixture-value' for k in required | set(m.TYPES[kind][3])}\n"
                "p.update(task='fixture', name='test')\n"
                "print(json.dumps(m.render(kind, p)[0], ensure_ascii=False))\n"
            )
            import json
            env = dict(os.environ, KOS_HOME=str(home), UK_REPO=str(ROOT))
            rendered = {}
            for kind in ("publish", "land"):
                result = subprocess.run([os.sys.executable, "-I", "-c", script, str(generator), kind],
                                        env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                rendered[kind] = json.loads(result.stdout)
                self.assertNotIn("[[cmd:", rendered[kind])
            for marker in ("O21", "--help", "files.txt", "manifest", "shasum -a 256 -c", "WARNING"):
                self.assertIn(marker, rendered["publish"])
            for marker in ("classify-change", "lightweight-checks", "final-quality-gate",
                           "GitGuardian Security Checks", "skipped", "not watching",
                           "test -L", "--ff-only", "branch -d", "already_deleted_on_origin"):
                self.assertIn(marker, rendered["land"])


class GitContractTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.repo = self.root / "main checkout"
        self.repo.mkdir()
        self.env = dict(os.environ, GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=os.devnull,
                        GIT_AUTHOR_NAME="Fixture", GIT_AUTHOR_EMAIL="fixture@example.invalid",
                        GIT_COMMITTER_NAME="Fixture", GIT_COMMITTER_EMAIL="fixture@example.invalid")
        self.git(self.repo, "init", "-q", "-b", "main")
        (self.repo / "tracked").write_text("base\n")
        self.git(self.repo, "add", "tracked")
        self.git(self.repo, "commit", "-qm", "base")
        self.git(self.repo, "branch", "candidate")
        (self.repo / "tracked").write_text("new\n")
        self.git(self.repo, "commit", "-qam", "new")
        self.target = self.git(self.repo, "rev-parse", "HEAD").stdout.strip()
        self.git(self.repo, "reset", "--hard", "candidate")

    def git(self, repo, *args, check=True):
        return subprocess.run(["git", "-C", str(repo), *args], env=self.env,
                              text=True, capture_output=True, check=check)

    def guarded_ff(self):
        old = self.git(self.repo, "rev-parse", "HEAD").stdout.strip()
        branch = self.git(self.repo, "branch", "--show-current").stdout.strip()
        dirty = self.git(self.repo, "status", "--porcelain").stdout
        ancestor = self.git(self.repo, "merge-base", "--is-ancestor", "HEAD", self.target, check=False)
        if branch != "main" or dirty or ancestor.returncode:
            return "skipped", old
        result = self.git(self.repo, "merge", "--ff-only", self.target, check=False)
        return ("success" if result.returncode == 0 else "failed"), old

    def test_clean_ancestor_fast_forwards(self):
        result, old = self.guarded_ff()
        self.assertEqual(result, "success")
        self.assertNotEqual(old, self.target)
        self.assertEqual(self.git(self.repo, "rev-parse", "HEAD").stdout.strip(), self.target)

    def test_dirty_non_main_and_non_ancestor_skip(self):
        for case in ("untracked", "modified", "non-main", "non-ancestor"):
            with self.subTest(case=case):
                if case == "untracked":
                    (self.repo / "extra").write_text("x")
                elif case == "modified":
                    (self.repo / "tracked").write_text("dirty")
                elif case == "non-main":
                    self.git(self.repo, "checkout", "-qb", "other")
                else:
                    (self.repo / "tracked").write_text("diverged")
                    self.git(self.repo, "commit", "-qam", "diverged")
                before = self.git(self.repo, "rev-parse", "HEAD").stdout.strip()
                self.assertEqual(self.guarded_ff()[0], "skipped")
                self.assertEqual(self.git(self.repo, "rev-parse", "HEAD").stdout.strip(), before)
                if case == "untracked":
                    (self.repo / "extra").unlink()
                elif case == "modified":
                    self.git(self.repo, "checkout", "--", "tracked")
                elif case == "non-main":
                    self.git(self.repo, "checkout", "-q", "main")

    def test_vendor_link_and_directory_worktree_remove(self):
        wt = self.root / "task worktree"
        self.git(self.repo, "worktree", "add", "-q", str(wt), "candidate")
        vendor = wt / "Packages/RimeBridge/Vendor"
        vendor.parent.mkdir(parents=True)
        vendor.symlink_to(self.root / "external")
        self.assertTrue(vendor.is_symlink())
        vendor.unlink()
        vendor.mkdir()
        (vendor / "keep").write_text("keep")
        self.assertFalse(vendor.is_symlink())
        failure = self.git(self.repo, "worktree", "remove", str(wt), check=False)
        self.assertNotEqual(failure.returncode, 0)
        self.assertEqual((vendor / "keep").read_text(), "keep")
        # The failed removal leaves the branch/worktree available for recovery.
        self.assertIn(str(wt), self.git(self.repo, "worktree", "list", "--porcelain").stdout)

    def test_remote_query_absence_and_error_are_distinct(self):
        remote = self.root / "remote.git"
        subprocess.run(["git", "init", "--bare", "-q", str(remote)], env=self.env, check=True)
        absent = self.git(self.repo, "ls-remote", "--exit-code", "--heads", str(remote), "refs/heads/task", check=False)
        failed = self.git(self.repo, "ls-remote", "--exit-code", "--heads", str(self.root / "missing.git"), "refs/heads/task", check=False)
        self.assertEqual(absent.returncode, 2)
        self.assertNotEqual(failed.returncode, 0)
        self.assertNotEqual(failed.returncode, absent.returncode)

    def test_safe_branch_delete_refuses_unmerged(self):
        self.git(self.repo, "checkout", "-qb", "unmerged")
        (self.repo / "tracked").write_text("unmerged")
        self.git(self.repo, "commit", "-qam", "unmerged")
        self.git(self.repo, "checkout", "-q", "main")
        result = self.git(self.repo, "branch", "-d", "unmerged", check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.git(self.repo, "show-ref", "--verify", "refs/heads/unmerged", check=False).returncode, 0)


class ManifestTests(unittest.TestCase):
    def test_space_path_and_missing_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            path = root / "file with spaces.txt"
            path.write_bytes(b"frozen contents\n")
            other = root / "another file.txt"
            other.write_bytes(b"another frozen file\n")
            frozen_list = root / "files.txt"
            frozen_list.write_text(f"{path.name}\n{other.name}\n", encoding="utf-8")
            paths = frozen_list.read_text(encoding="utf-8").splitlines()
            generated = subprocess.run(["shasum", "-a", "256", *paths], cwd=root,
                                       capture_output=True, text=True, check=True)
            manifest = root / "manifest.sha256"
            manifest.write_text(generated.stdout, encoding="utf-8")
            self.assertEqual(len(generated.stdout.splitlines()), 2)
            command = ["shasum", "-a", "256", "-c", str(manifest)]
            good = subprocess.run(command, cwd=root, capture_output=True, text=True)
            self.assertEqual(good.returncode, 0, good.stderr)
            self.assertNotIn("WARNING", good.stderr)
            path.unlink()
            missing = subprocess.run(command, cwd=root, capture_output=True, text=True)
            self.assertNotEqual(missing.returncode, 0)
            self.assertIn("WARNING", missing.stderr)


if __name__ == "__main__":
    unittest.main()
