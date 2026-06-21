# Typo Correction V0.5: Prioritized Safe One-Edit Recall

## Summary

V0.5 fixes safe one-character adjacent-key corrections that were previously missed because they appeared too late in the bounded suggestion window. The core acceptance example is:

- `zhonghuo -> zhongguo -> 中国`

This milestone does not add new typo categories. It keeps the engine limited to:

- single adjacent-key substitution;
- repeated final-character deletion;
- RIME/candidate-provider verification before display.

It does not implement omitted-character correction, transposition, multi-edit correction, broad edit distance, RIME schema auto-correction, RIME weight changes, candidate UI changes, or ranking expansion.

## Root Cause

The V0.3 engine already allowed all-position safe adjacent-key substitution, but generation order was:

1. final character;
2. first character;
3. middle characters from left to right.

Because `maximumSuggestions` is fixed at 16, long inputs could spend the lookup budget before reaching a likely middle correction near the end of the input. For example, `zhonghuo` needs index `5` (`h -> g`), but the previous order could exhaust the window before this edit was materialized and verified.

## Implementation Strategy

- Generate safe substitution edit descriptors before materializing suggestions.
- Sort descriptors by conservative priority:
  - final index first;
  - index `0` second;
  - remaining middle indices from right to left, so long-pinyin back-half mistakes are checked earlier;
  - for the same index, preserve the existing keyboard-neighbor order.
- Keep the public suggestion limit at `maximumSuggestions = 16`.
- Keep repeated-final deletion behavior unchanged.
- Keep `KeyboardController+TypoCorrection` resolved suggestion limits unchanged:
  - at most 2 resolved suggestions;
  - at most 3 RIME candidates per suggestion.
- Continue using `TypoCorrectionAssessment` and `TypoCorrectionCandidateRanker` for display and promotion decisions.

## Expected Behavior

Supported:

- `nihap -> nihao -> 你好`, final adjacent-key substitution, may promote.
- `zhonggup -> zhongguo -> 中国`, final adjacent-key substitution, may promote.
- `bihao -> nihao -> 你好`, initial adjacent-key substitution, near-front only.
- `nigao -> nihao -> 你好`, middle adjacent-key substitution, near-front only.
- `zhonghuo -> zhongguo -> 中国`, long-pinyin middle adjacent-key substitution, near-front only.
- `nihaoo -> nihao -> 你好`, repeated-final deletion, conservative display only.

Still unsupported:

- `niho -> nihao`, omitted character.
- `nihoa -> nihao`, transposition.
- `nihso -> nihao`, unsafe middle consonant/vowel cross-class replacement.
- `haop` and `xianp`, ambiguous or dangerous corrections.

## Validation

Required tests:

- Engine suggestions include `zhongguo` for `zhonghuo` within the 16-suggestion cap.
- Controller resolves `zhonghuo -> zhongguo -> 中国`.
- Ranker inserts `zhonghuo` correction near the front without replacing the normal top candidate.
- Existing behavior for `nihap`, `zhonggup`, `bihao`, `nigao`, repeated-final deletion, and unsupported cases remains unchanged.
- Normal inputs such as `nihao`, `women`, `jintian`, `xiexie`, `shijian`, `zhongwen`, and `ceshi` remain normal RIME/provider candidates.

Required commands:

```bash
git diff --check
swift test --package-path Packages/KeyboardCore
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination "generic/platform=iOS Simulator" build
```

## Future Work

Future typo-correction work should remain benchmark-driven. Do not expand to omitted characters, transpositions, multi-edit correction, or unsafe middle replacements until precision can be measured and the candidate UI behavior remains explainable.
