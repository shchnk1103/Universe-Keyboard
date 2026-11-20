import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(REPO_ROOT / "scripts" / "ci"))

import check_keyboard_values as ckv


FIXTURE_DOC = """# 键盘数值索引

## 数值表

| 名称（符号） | 值 | 来源（基线） | 使用处 / 说明 |
|---|---|---|---|
| keySpacing | 8 | `Keyboard/Controllers/KeyboardViewController.swift:465` | 行间距 |
| T9PinyinBar.visibleHeight | 34 | `Keyboard/Views/KeyboardDesignTokens.swift:29` | 已展开可见高度 |
| CandidateFontSettings.storageKey | keyboard_candidate_font_size | `Packages/KeyboardCore/Sources/KeyboardCore/CandidateFontSettings.swift:6` | 共享档位键 |
"""

FIXTURE_CONTROLLER = """import UIKit

final class KeyboardViewController {
    let keySpacing: CGFloat = 8
}
"""

FIXTURE_TOKENS = """import UIKit

enum KeyboardDesignTokens {
    enum T9PinyinBar {
        static let visibleHeight: CGFloat = 34
    }
}
"""

FIXTURE_FONT_SETTINGS = """import Foundation

public enum CandidateFontSettings {
    public static let storageKey = "keyboard_candidate_font_size"
}
"""

SUBSET_SYMBOLS = {"keySpacing", "T9PinyinBar.visibleHeight", "CandidateFontSettings.storageKey"}


def make_fixture(root: Path, doc_text: str = FIXTURE_DOC, drop_symbol_line: bool = False) -> None:
    (root / "docs").mkdir(parents=True)
    (root / "docs" / "KEYBOARD_VALUES.md").write_text(doc_text, encoding="utf-8")
    controller_dir = root / "Keyboard" / "Controllers"
    controller_dir.mkdir(parents=True)
    (controller_dir / "KeyboardViewController.swift").write_text(FIXTURE_CONTROLLER, encoding="utf-8")
    tokens_dir = root / "Keyboard" / "Views"
    tokens_dir.mkdir(parents=True)
    (tokens_dir / "KeyboardDesignTokens.swift").write_text(FIXTURE_TOKENS, encoding="utf-8")
    font_dir = root / "Packages" / "KeyboardCore" / "Sources" / "KeyboardCore"
    font_dir.mkdir(parents=True)
    text = FIXTURE_FONT_SETTINGS if not drop_symbol_line else FIXTURE_FONT_SETTINGS.replace(
        '    public static let storageKey = "keyboard_candidate_font_size"\n', "")
    (font_dir / "CandidateFontSettings.swift").write_text(text, encoding="utf-8")


def subset_checks():
    return [check for check in ckv.CHECKS if check["symbol"] in SUBSET_SYMBOLS]


class CheckKeyboardValuesTests(unittest.TestCase):
    def testConsistentFixturePasses(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            make_fixture(root)
            self.assertEqual(ckv.collect_failures(root, subset_checks()), [])

    def testDocValueDriftFailsWithDetails(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            make_fixture(root, doc_text=FIXTURE_DOC.replace("| keySpacing | 8 |", "| keySpacing | 9 |"))
            failures = ckv.collect_failures(root, subset_checks())
            self.assertEqual(len(failures), 1, failures)
            self.assertIn("keySpacing", failures[0])
            self.assertIn("doc_value=9", failures[0])
            self.assertIn("code_value=8", failures[0])

    def testMissingDocRowFails(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            make_fixture(
                root,
                doc_text=FIXTURE_DOC.replace(
                    "| T9PinyinBar.visibleHeight | 34 | `Keyboard/Views/KeyboardDesignTokens.swift:29` | 已展开可见高度 |\n",
                    ""),
            )
            failures = ckv.collect_failures(root, subset_checks())
            self.assertEqual(len(failures), 1, failures)
            self.assertIn("MISSING_ROW", failures[0])
            self.assertIn("T9PinyinBar.visibleHeight", failures[0])

    def testMissingCodeSymbolFails(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            make_fixture(root, drop_symbol_line=True)
            failures = ckv.collect_failures(root, subset_checks())
            self.assertEqual(len(failures), 1, failures)
            self.assertIn("MISSING_SYMBOL", failures[0])
            self.assertIn("CandidateFontSettings.storageKey", failures[0])

    def testRealRepoBaselinePasses(self):
        failures = ckv.collect_failures(REPO_ROOT, ckv.CHECKS)
        self.assertEqual(failures, [], "\n".join(failures))


if __name__ == "__main__":
    unittest.main()
