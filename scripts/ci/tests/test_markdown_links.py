from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "check_markdown_links.py"
SPEC = importlib.util.spec_from_file_location("check_markdown_links", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class MarkdownLinkTests(unittest.TestCase):
    def test_external_and_anchor_links_are_ignored(self) -> None:
        self.assertIsNone(MODULE.normalize_target("https://example.com/file"))
        self.assertIsNone(MODULE.normalize_target("#section"))

    def test_percent_encoded_local_path_is_checked(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            docs = root / "docs"
            docs.mkdir()
            (docs / "My File.md").write_text("target", encoding="utf-8")
            source = docs / "source.md"
            source.write_text("[local](My%20File.md)", encoding="utf-8")
            self.assertEqual(MODULE.missing_links(source, root), [])

    def test_missing_local_link_reports_line(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source.md"
            source.write_text("first\n[missing](nope.md)\n", encoding="utf-8")
            self.assertEqual(MODULE.missing_links(source, root), [(2, "nope.md")])


if __name__ == "__main__":
    unittest.main()
