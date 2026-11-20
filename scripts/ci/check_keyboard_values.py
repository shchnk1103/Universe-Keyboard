#!/usr/bin/env python3
"""Cross-check docs/KEYBOARD_VALUES.md numeric claims against Swift sources.

Symbol-based: every check locates its doc table row by name and its Swift
constant by declaration regex — no drift-prone line numbers. Uses only the
Python 3 standard library. Failures print `symbol / doc_value / code_value /
file` and exit non-zero.
"""

import argparse
import re
import sys
from pathlib import Path

FLOAT = "float"
STRING = "string"

CHECKS = [
    # --- KeyboardDesignTokens.swift -------------------------------------------
    {"symbol": "CandidateBar.totalHeight",
     "doc_regex": r"\|\s*CandidateBar\.totalHeight[^|]*\|\s*(?P<doc>\d+(?:\.\d+)?)\s*/",
     "file": "Keyboard/Views/KeyboardDesignTokens.swift",
     "code_regex": r"static let totalHeight: CGFloat = (?P<code>\d+)"},
    {"symbol": "CandidateBar.actionZoneWidth",
     "doc_regex": r"actionZoneWidth[^|]*\|\s*(?P<doc>\d+(?:\.\d+)?)\s*/\s*\d+(?:\.\d+)?",
     "file": "Keyboard/Views/KeyboardDesignTokens.swift",
     "code_regex": r"static let actionZoneWidth: CGFloat = (?P<code>\d+)"},
    {"symbol": "CandidateBar.actionSymbolSize",
     "doc_regex": r"actionZoneWidth[^|]*\|\s*\d+(?:\.\d+)?\s*/\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Keyboard/Views/KeyboardDesignTokens.swift",
     "code_regex": r"static let actionSymbolSize: CGFloat = (?P<code>\d+)"},
    {"symbol": "CandidateBar.minimumTouchSize",
     "doc_regex": r"\|\s*CandidateBar\.minimumTouchSize\s*\|\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Keyboard/Views/KeyboardDesignTokens.swift",
     "code_regex": r"static let minimumTouchSize: CGFloat = (?P<code>\d+)"},
    {"symbol": "CandidateBar.horizontalPadding",
     "doc_regex": r"horizontalPadding / trailingContentPadding\s*\|\s*(?P<doc>\d+(?:\.\d+)?)\s*/",
     "file": "Keyboard/Views/KeyboardDesignTokens.swift",
     "code_regex": r"static let horizontalPadding: CGFloat = (?P<code>\d+)"},
    {"symbol": "CandidateBar.trailingContentPadding",
     "doc_regex": r"horizontalPadding / trailingContentPadding\s*\|\s*\d+(?:\.\d+)?\s*/\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Keyboard/Views/KeyboardDesignTokens.swift",
     "code_regex": r"static let trailingContentPadding: CGFloat = (?P<code>\d+)"},
    {"symbol": "CandidateBar.actionSeparatorPixelWidth",
     "doc_regex": r"actionSeparatorPixelWidth[^|]*\|\s*(?P<doc>\d+(?:\.\d+)?)\s*/\s*\d+(?:\.\d+)?",
     "file": "Keyboard/Views/KeyboardDesignTokens.swift",
     "code_regex": r"static let actionSeparatorPixelWidth: CGFloat = (?P<code>\d+)"},
    {"symbol": "CandidateBar.actionSeparatorHeightRatio",
     "doc_regex": r"actionSeparatorPixelWidth[^|]*\|\s*\d+(?:\.\d+)?\s*/\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Keyboard/Views/KeyboardDesignTokens.swift",
     "code_regex": r"static let actionSeparatorHeightRatio: CGFloat = (?P<code>0\.\d+)"},
    {"symbol": "ExpandedCandidates.rowHeight",
     "doc_regex": r"\|\s*ExpandedCandidates\.rowHeight\s*\|\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Keyboard/Views/KeyboardDesignTokens.swift",
     "code_regex": r"enum ExpandedCandidates \{[\s\S]*?static let rowHeight: CGFloat = (?P<code>\d+)"},
    {"symbol": "ExpandedCandidates.itemSpacing",
     "doc_regex": r"\|\s*ExpandedCandidates\.itemSpacing\s*\|\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Keyboard/Views/KeyboardDesignTokens.swift",
     "code_regex": r"static let itemSpacing: CGFloat = (?P<code>\d+)"},
    {"symbol": "ExpandedCandidates.minimumReadableExtent",
     "doc_regex": r"\|\s*minimumReadableExtent / minimumReadableFraction\s*\|\s*(?P<doc>\d+(?:\.\d+)?)\s*/",
     "file": "Keyboard/Views/KeyboardDesignTokens.swift",
     "code_regex": r"static let minimumReadableExtent: CGFloat = (?P<code>\d+)"},
    {"symbol": "ExpandedCandidates.minimumReadableFraction",
     "doc_regex": r"minimumReadableExtent / minimumReadableFraction\s*\|\s*\d+(?:\.\d+)?\s*/\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Keyboard/Views/KeyboardDesignTokens.swift",
     "code_regex": r"static let minimumReadableFraction: CGFloat = (?P<code>0\.\d+)"},
    {"symbol": "T9PinyinBar.visibleHeight",
     "doc_regex": r"\|\s*T9PinyinBar\.visibleHeight\s*\|\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Keyboard/Views/KeyboardDesignTokens.swift",
     "code_regex": r"enum T9PinyinBar \{[\s\S]*?static let visibleHeight: CGFloat = (?P<code>\d+)"},
    # --- KeyboardViewController.swift -----------------------------------------
    {"symbol": "keySpacing",
     "doc_regex": r"\|\s*keySpacing\s*\|\s*(?P<doc>\d+(?:\.\d+)?)\s*\|",
     "file": "Keyboard/Controllers/KeyboardViewController.swift",
     "code_regex": r"let keySpacing: CGFloat = (?P<code>\d+)"},
    {"symbol": "keyboardGroupSpacing",
     "doc_regex": r"\|\s*keyboardGroupSpacing\s*\|\s*(?P<doc>\d+(?:\.\d+)?)\s*\|",
     "file": "Keyboard/Controllers/KeyboardViewController.swift",
     "code_regex": r"let keyboardGroupSpacing: CGFloat = (?P<code>\d+)"},
    {"symbol": "keyHorizontalSpacing",
     "doc_regex": r"keyHorizontalSpacing / thirdRowFunctionSpacing\s*\|\s*(?P<doc>\d+(?:\.\d+)?)\s*/",
     "file": "Keyboard/Controllers/KeyboardViewController.swift",
     "code_regex": r"let keyHorizontalSpacing: CGFloat = (?P<code>\d+)"},
    {"symbol": "thirdRowFunctionSpacing",
     "doc_regex": r"keyHorizontalSpacing / thirdRowFunctionSpacing\s*\|\s*\d+(?:\.\d+)?\s*/\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Keyboard/Controllers/KeyboardViewController.swift",
     "code_regex": r"let thirdRowFunctionSpacing: CGFloat = (?P<code>\d+)"},
    {"symbol": "primaryFunctionKeyWidth",
     "doc_regex": r"\|\s*primaryFunctionKeyWidth\s*\|\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Keyboard/Controllers/KeyboardViewController.swift",
     "code_regex": r"let primaryFunctionKeyWidth: CGFloat = (?P<code>\d+)"},
    {"symbol": "KeyboardViewController.appGroupID",
     "doc_regex": r"KeyboardViewController\.appGroupID[^|]*\|\s*(?P<doc>group\.[\w.-]+)",
     "file": "Keyboard/Controllers/KeyboardViewController.swift",
     "code_regex": r'static let appGroupID = "(?P<code>[^"]+)"', "type": STRING},
    # --- key factories / path bar ---------------------------------------------
    {"symbol": "makeT9KeyButton.minimumScaleFactor",
     "doc_regex": r"makeT9KeyButton 字母组 minimumScaleFactor\s*\|\s*均?\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Keyboard/Controllers/KeyboardViewController+KeyFactory.swift",
     "code_regex": r"minimumScaleFactor = (?P<code>0\.7)"},
    {"symbol": "punctuationButton.minimumScaleFactor",
     "doc_regex": r"punctuationButton / kaomojiButton minimumScaleFactor\s*\|\s*均?\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Keyboard/Controllers/KeyboardViewController+Rows.swift",
     "code_regex": r"minimumScaleFactor = (?P<code>0\.55)"},
    {"symbol": "T9PinyinPathBarCell.titlePointSize",
     "doc_regex": r"T9PinyinPathBarCell\.titlePointSize\s*\|\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Keyboard/Views/T9PinyinPathBarView.swift",
     "code_regex": r"static let titlePointSize: CGFloat = (?P<code>\d+)"},
    # --- KeyboardCore shared constants -----------------------------------------
    {"symbol": "CandidateFontSettings.storageKey",
     "doc_regex": r"CandidateFontSettings\.storageKey\s*\|\s*(?P<doc>[\w]+)",
     "file": "Packages/KeyboardCore/Sources/KeyboardCore/CandidateFontSettings.swift",
     "code_regex": r'static let storageKey = "(?P<code>[^"]+)"', "type": STRING},
    {"symbol": "KeyboardHeightSettings.defaultRowHeight",
     "doc_regex": r"KeyboardHeightSettings\.swift`：默认(?P<doc>\d+(?:\.\d+)?)、下限",
     "file": "Packages/KeyboardCore/Sources/KeyboardCore/KeyboardHeightSettings.swift",
     "code_regex": r"static let defaultRowHeight = (?P<code>\d+)"},
    {"symbol": "KeyboardHeightSettings.minimumRowHeight",
     "doc_regex": r"KeyboardHeightSettings\.swift`：默认\d+、下限(?P<doc>\d+(?:\.\d+)?)",
     "file": "Packages/KeyboardCore/Sources/KeyboardCore/KeyboardHeightSettings.swift",
     "code_regex": r"static let minimumRowHeight = (?P<code>\d+)"},
    {"symbol": "KeyboardLayoutStyle.rawValue.twentySixKey",
     "doc_regex": r"KeyboardLayoutStyle raw values[^|]*\|\s*(?P<doc>[\w]+)\s*/",
     "file": "Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift",
     "code_regex": r'case twentySixKey = "(?P<code>[^"]+)"', "type": STRING},
    {"symbol": "KeyboardLayoutStyle.rawValue.nineKey",
     "doc_regex": r"KeyboardLayoutStyle raw values[^|]*\|\s*[\w]+\s*/\s*(?P<doc>[\w]+?)；",
     "file": "Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift",
     "code_regex": r'case nineKey = "(?P<code>[^"]+)"', "type": STRING},
    {"symbol": "KeyboardLayoutSettingsKey.layoutStyle",
     "doc_regex": r"KeyboardLayoutSettingsKey\.layoutStyle\s*\|\s*(?P<doc>[\w]+)",
     "file": "Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift",
     "code_regex": r'static let layoutStyle = "(?P<code>[^"]+)"', "type": STRING},
    {"symbol": "KeyboardLayoutSettingsKey.schemeBinding26",
     "doc_regex": r"schemeBinding26 / schemeBinding9\s*\|\s*(?P<doc>[\w]+)\s*/",
     "file": "Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift",
     "code_regex": r'static let schemeBinding26 = "(?P<code>[^"]+)"', "type": STRING},
    {"symbol": "KeyboardLayoutSettingsKey.schemeBinding9",
     "doc_regex": r"schemeBinding26 / schemeBinding9\s*\|\s*[\w]+\s*/\s*(?P<doc>[\w]+)",
     "file": "Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift",
     "code_regex": r'static let schemeBinding9 = "(?P<code>[^"]+)"', "type": STRING},
    {"symbol": "RimeT9Readiness.SettingsKey.marker",
     "doc_regex": r"RimeT9Readiness\.SettingsKey\.marker / legacyReady\s*\|\s*(?P<doc>[\w]+)\s*/",
     "file": "Packages/KeyboardCore/Sources/KeyboardCore/RimeT9Readiness.swift",
     "code_regex": r'static let marker = "(?P<code>[^"]+)"', "type": STRING},
    {"symbol": "RimeT9Readiness.SettingsKey.legacyReady",
     "doc_regex": r"SettingsKey\.marker / legacyReady\s*\|\s*[\w]+\s*/\s*(?P<doc>[\w]+)",
     "file": "Packages/KeyboardCore/Sources/KeyboardCore/RimeT9Readiness.swift",
     "code_regex": r'static let legacyReady = "(?P<code>[^"]+)"', "type": STRING},
    {"symbol": "RimeT9Readiness.currentCompatibilityVersion",
     "doc_regex": r"\|\s*currentCompatibilityVersion\s*\|\s*字符串\s*(?P<doc>\d+(?:\.\d+)?)",
     "file": "Packages/KeyboardCore/Sources/KeyboardCore/RimeT9Readiness.swift",
     "code_regex": r'currentCompatibilityVersion = "(?P<code>[^"]+)"', "type": STRING},
]


def _values_equal(doc_value: str, code_value: str, kind: str) -> bool:
    doc_value = doc_value.strip()
    code_value = code_value.strip()
    if kind == STRING:
        return doc_value == code_value
    try:
        return float(doc_value) == float(code_value)
    except ValueError:
        return doc_value == code_value


def collect_failures(root: Path, checks=None) -> list[str]:
    root = Path(root)
    doc_path = root / "docs" / "KEYBOARD_VALUES.md"
    doc_text = doc_path.read_text(encoding="utf-8") if doc_path.exists() else ""
    source_cache: dict[str, str] = {}
    failures: list[str] = []
    for check in checks if checks is not None else CHECKS:
        doc_match = re.search(check["doc_regex"], doc_text)
        if not doc_match:
            failures.append(
                f"{check['symbol']} / doc_value=MISSING_ROW / code_value=? / file=docs/KEYBOARD_VALUES.md")
            continue
        doc_value = doc_match.group("doc")
        source = source_cache.get(check["file"])
        if source is None:
            path = root / check["file"]
            source = path.read_text(encoding="utf-8") if path.exists() else ""
            source_cache[check["file"]] = source
        code_match = re.search(check["code_regex"], source)
        if not code_match:
            failures.append(
                f"{check['symbol']} / doc_value={doc_value} / code_value=MISSING_SYMBOL / file={check['file']}")
            continue
        code_value = code_match.group("code")
        if not _values_equal(doc_value, code_value, check.get("type", FLOAT)):
            failures.append(
                f"{check['symbol']} / doc_value={doc_value} / code_value={code_value} / file={check['file']}")
    return failures


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--root", default=".", help="repository root (default: cwd)")
    args = parser.parse_args(argv)
    failures = collect_failures(Path(args.root))
    if failures:
        for failure in failures:
            print(failures and failure, file=sys.stderr)
        print(f"CHECK_KEYBOARD_VALUES_FAIL: {len(failures)} mismatch(es)", file=sys.stderr)
        return 1
    print(f"CHECK_KEYBOARD_VALUES_PASS: {len(CHECKS)} checks")
    return 0


if __name__ == "__main__":
    sys.exit(main())
