# Typo Correction V0.3 Coverage Plan

> **Status: archived implementation plan.** V0.3 has been implemented. Current behavior and supported boundaries are defined by `docs/TYPO_BENCHMARK.md` and tests, not by this plan.

## Summary

V0.3 strengthens the existing KeyboardCore typo-correction layer. It does not use traditional RIME fuzzy pinyin, Lua advanced input, or schema-level automatic correction rules.

The goal is conservative all-position single-character adjacent-key correction:

- `bihao -> nihao -> 你好`
- `nigao -> nihao -> 你好`
- `nihap -> nihao -> 你好`

Correction candidates remain optional. The system must not autocorrect, change candidate UI, change keyboard layout, or alter RIME fuzzy pinyin behavior.

## Rules

- Generate only one-edit suggestions.
- Support adjacent-key substitution across the input when the input is long enough.
- Keep repeated-final deletion support unchanged.
- For non-final substitutions, require the original and replacement letters to stay in the same broad pinyin role, such as consonant-to-consonant or vowel-to-vowel.
- Allow existing final adjacent-key substitutions such as `nihap -> nihao`.
- Do not support omitted characters, transposed characters, broad edit distance, multi-edit corrections, or schema-level typo derive rules.
- Resolve every generated correction through the existing candidate provider / RIME flow before showing it.

## Ranking

- Existing high-confidence final substitutions may still be promoted to the first position when the normal top candidate is a longer expansion, such as `你好安排`.
- Initial and middle substitutions may be placed near the front, after the first normal candidate, but should not blindly replace normal RIME ranking.
- Repeated-final deletion remains conservative and should not be promoted aggressively.
- If normal RIME already returns the same candidate as the top candidate, the correction candidate should be suppressed.

## Benchmark Additions

Supported:

| Input | Correction | Notes |
|---|---|---|
| `bihao` | `nihao -> 你好` | Initial adjacent-key substitution |
| `nigao` | `nihao -> 你好` | Middle consonant adjacent-key substitution |
| `nihap` | `nihao -> 你好` | Existing final adjacent-key substitution |
| `zhonggup` | `zhongguo -> 中国` | Existing long pinyin final substitution |
| `woainj` | `woaini -> 我爱你` | Existing phrase final substitution |

Still unsupported:

| Input | Reason |
|---|---|
| `niho` | Omitted character |
| `nihoa` | Transposed characters |
| `nihso` | Non-final consonant/vowel cross-class replacement |
| `haop` | Short and ambiguous |
| `xianp` | Ambiguous without a validated correction candidate |

## Validation

Required commands:

```bash
git diff --check
swift test --package-path Packages/KeyboardCore
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination "generic/platform=iOS Simulator" build
```

If SwiftPM cannot run because of local cache or XCTest runner issues, record the exact failure and use the Xcode build as a secondary compile validation.
