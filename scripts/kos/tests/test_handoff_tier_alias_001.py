#!/usr/bin/env python3
"""KOS-HANDOFF-TIER-ALIAS-001: English `Tier:` headers are aliases of `包头档位`.

Covers Observation #1 of quality-kos-english-and-relay-rule-r1:
`kos_handoff._packet_grade()` must recognize English packet headers
(`Tier: code-fix`, `- Tier: ...`, `Tier (包头档位): ...`) exactly like the
Chinese `包头档位` header, both at the parsing level and through the
relay-quality / relay-exec tier gates, without changing how the existing
Chinese headers or the per-grade relay allow-lists behave.
"""
from __future__ import annotations

import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

KOS_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOS_DIR))
sys.path.insert(0, str(Path(__file__).resolve().parent))

import _kos_pm_next_fixture  # noqa: E402
import kos_handoff  # noqa: E402

GRADES = ("code-fix", "doc-rule", "feature", "doc-light")

CHINESE_HEADER_FORMS = (
    "包头档位: {grade}",
    "- 包头档位: {grade}",
    "**包头档位**: `{grade}`",
)

ENGLISH_HEADER_FORMS = (
    "Tier: {grade}",
    "- Tier: {grade}",
    "**Tier**: {grade}",
    "Tier (`包头档位`): `{grade}`",
    "- Tier (`包头档位`): `{grade}`",
)


def _packet(header: str) -> str:
    return (
        "# Executor Code Packet: TASK-DEMO (r1)\n"
        "\n"
        f"{header}\n"
        "\n"
        "## 2. Scope\n"
        "\n"
        "**复核重点**:\n"
        "  1. Confirm the tier gate honors the packet header.\n"
    )


class PacketGradeAliasTests(unittest.TestCase):
    """Unit level: _packet_grade() parsing equivalence."""

    def test_chinese_headers_parse_all_grades(self) -> None:
        for grade in GRADES:
            for form in CHINESE_HEADER_FORMS:
                text = _packet(form.format(grade=grade))
                self.assertEqual(kos_handoff._packet_grade(text), grade, msg=form)

    def test_english_tier_headers_are_equivalent_aliases(self) -> None:
        for grade in GRADES:
            for form in ENGLISH_HEADER_FORMS:
                text = _packet(form.format(grade=grade))
                self.assertEqual(
                    kos_handoff._packet_grade(text), grade,
                    msg=f"form={form!r} grade={grade}")

    def test_packet_without_header_has_no_grade(self) -> None:
        self.assertEqual(kos_handoff._packet_grade("# packet\nno tier header here\n"), "")

    def test_bare_tier_word_does_not_yield_a_grade(self) -> None:
        self.assertEqual(kos_handoff._packet_grade("Tier 1 support line\n"), "")


class RelayTierGateEquivalenceTests(unittest.TestCase):
    """CLI level: relay-quality / relay-exec treat English headers like Chinese ones."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.stub = self.root / "stub_pass.py"
        self.stub.write_text("import sys\nsys.exit(0)\n", encoding="utf-8")
        self._name_counter = 0
        # relay-exec renders the department-pool dispatch block via the external
        # kos-pm-next.py; inject the /tmp fixture tool + roster (O207 pattern)
        # so the test never depends on the real per-user external KOS home.
        self._pm_next_saved = _kos_pm_next_fixture.install(set_roster=True)

    def tearDown(self) -> None:
        _kos_pm_next_fixture.uninstall(self._pm_next_saved)
        self.tmp.cleanup()

    def _write(self, text: str) -> Path:
        self._name_counter += 1
        path = self.root / f"fixture-{self._name_counter}.md"
        path.write_text(text, encoding="utf-8")
        return path

    def _run(self, *args: str) -> subprocess.CompletedProcess:
        env = dict(os.environ)
        env["PYTHONDONTWRITEBYTECODE"] = "1"
        return subprocess.run(
            [sys.executable, "-I", "-B", str(KOS_DIR / "kos_handoff.py"), *args],
            capture_output=True, text=True, env=env,
        )

    def _relay_quality(self, packet: Path) -> subprocess.CompletedProcess:
        report = self._write("PENDING\n\nnot done yet\n")
        return self._run(
            "relay-quality", "--packet", str(packet), "--report", str(report),
            "--base", "HEAD", "--repo", str(self.repo),
        )

    def _relay_exec(self, packet: Path) -> subprocess.CompletedProcess:
        report = self._write(
            "PASS\nQuinn（Quality 部门）\n\n跨会话独立性声明：本复核与本实现跨会话独立完成。\n")
        out = self.root / f"exec-relay-block-{self._name_counter}.txt"
        return self._run(
            "relay-exec", "--packet", str(packet), "--report", str(report),
            "--base", "HEAD", "--repo", str(self.repo),
            "--verify-tool", str(self.stub), "--pkg-lint-tool", str(self.stub),
            "--out", str(out),
        )

    # --- relay-quality ---------------------------------------------------

    def test_relay_quality_allowed_grades_pass_tier_gate_with_english_header(self) -> None:
        for grade in ("code-fix", "feature"):
            expected = "feature arch gate failed" if grade == "feature" else "report status is PENDING"
            for form in ENGLISH_HEADER_FORMS:
                zh = self._relay_quality(self._write(_packet(CHINESE_HEADER_FORMS[0].format(grade=grade))))
                en = self._relay_quality(self._write(_packet(form.format(grade=grade))))
                self.assertEqual(zh.returncode, en.returncode, msg=f"{grade}/{form}")
                self.assertEqual(zh.stderr, en.stderr, msg=f"{grade}/{form}")
                self.assertNotIn("does not allow relay-quality", en.stderr, msg=f"{grade}/{form}")
                self.assertIn(expected, en.stderr, msg=f"{grade}/{form}")

    def test_relay_quality_denied_grades_rejected_equally(self) -> None:
        for grade in ("doc-rule", "doc-light"):
            zh = self._relay_quality(self._write(_packet(CHINESE_HEADER_FORMS[0].format(grade=grade))))
            for form in ENGLISH_HEADER_FORMS:
                en = self._relay_quality(self._write(_packet(form.format(grade=grade))))
                self.assertEqual(zh.returncode, en.returncode, msg=f"{grade}/{form}")
                self.assertEqual(zh.stderr, en.stderr, msg=f"{grade}/{form}")
                self.assertIn("does not allow relay-quality", en.stderr, msg=f"{grade}/{form}")

    # --- relay-exec ------------------------------------------------------

    def test_relay_exec_allowed_grades_pass_tier_gate_with_english_header(self) -> None:
        for grade in ("code-fix", "doc-rule", "feature"):
            for form in ENGLISH_HEADER_FORMS:
                zh = self._relay_exec(self._write(_packet(CHINESE_HEADER_FORMS[0].format(grade=grade))))
                en = self._relay_exec(self._write(_packet(form.format(grade=grade))))
                self.assertEqual(zh.returncode, en.returncode, msg=f"{grade}/{form}")
                self.assertEqual(zh.stderr, en.stderr, msg=f"{grade}/{form}")
                self.assertNotIn("does not allow relay-exec", en.stderr, msg=f"{grade}/{form}")
                if grade == "feature":
                    # feature additionally enforces the frozen arch-* gate after
                    # the tier gate; it fails identically for both header languages.
                    self.assertIn("feature arch gate failed", en.stderr, msg=f"{grade}/{form}")
                else:
                    self.assertEqual(zh.returncode, 0, msg=f"{grade}/chinese-baseline: {zh.stderr}")
                    self.assertIn("PASS", en.stdout, msg=f"{grade}/{form}")

    def test_relay_exec_denied_grade_rejected_equally(self) -> None:
        zh = self._relay_exec(self._write(_packet(CHINESE_HEADER_FORMS[0].format(grade="doc-light"))))
        for form in ENGLISH_HEADER_FORMS:
            en = self._relay_exec(self._write(_packet(form.format(grade="doc-light"))))
            self.assertEqual(zh.returncode, en.returncode, msg=form)
            self.assertEqual(zh.stderr, en.stderr, msg=form)
            self.assertIn("does not allow relay-exec", en.stderr, msg=form)


if __name__ == "__main__":
    unittest.main()
