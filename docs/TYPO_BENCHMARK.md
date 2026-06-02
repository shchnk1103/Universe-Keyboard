# Typo Correction Benchmark

## Purpose

This document is the reference for fuzzy pinyin typo-correction coverage. It records representative typo categories, the current expected behavior, and the next coverage priorities so future work is guided by measurable cases instead of intuition.

This is not runtime telemetry. It does not measure live user input, keyboard frequency, or production correction rates. It is a benchmark reference backed by `TypoCorrectionTests`, and new real-world typo cases should be added over time as they are observed.

## Current Supported Categories

- Valid input should not be disturbed. When input already maps to normal candidates, correction should stay out of the way.
- Final adjacent-key substitution is supported for conservative one-character mistakes, such as `nihap -> nihao`.
- Candidate promotion is conservative. A correction candidate may be promoted only when it is a high-confidence single-character correction and the normal top candidate appears to be a longer expansion of the corrected phrase.

## Current Unsupported Categories

- Repeated characters, for example `nihaoo -> nihao`.
- Omitted characters, for example `niho -> nihao`.
- Transposed characters, for example `nihoa -> nihao`.
- Middle-character mistakes, for example `nihso -> nihao`.
- Unsupported final mistakes, for example `nihau -> nihao`.

Unsupported cases are known limitations, not failures of the current benchmark. They should remain recorded until a future milestone intentionally adds coverage.

## Benchmark Table

| Input | Intended correction | Category | Current expected behavior | Promotion |
|---|---|---|---|---|
| `nihao` | none | valid input | not corrected; normal candidates preserved | no |
| `nihap` | `nihao -> 你好` | final adjacent-key substitution | corrected successfully | yes |
| `nihal` | `nihao -> 你好` | final adjacent-key substitution | corrected successfully | yes |
| `nihak` | `nihao -> 你好` | final adjacent-key substitution | corrected successfully | yes |
| `nihau` | `nihao -> 你好` | unsupported final mistake | not corrected | no |
| `nihaoo` | `nihao -> 你好` | repeated character | not corrected | no |
| `nihoa` | `nihao -> 你好` | transposed character | not corrected | no |
| `nihso` | `nihao -> 你好` | middle-character mistake | not corrected | no |
| `zhongguo` | none | valid input | not corrected; normal candidates preserved | no |
| `zhonggup` | `zhongguo -> 中国` | final adjacent-key substitution | corrected successfully | yes |
| `woaini` | none | valid input | not corrected; normal candidates preserved | no |
| `woainj` | `woaini -> 我爱你` | final adjacent-key substitution | corrected successfully | yes |
| `niho` | `nihao -> 你好` | omitted character | not corrected | no |
| `haop` | ambiguous | ambiguous / dangerous correction | not corrected | no |
| `xianp` | ambiguous | ambiguous / dangerous correction | not corrected | no |

## Scoring Principles

- Prefer high precision over high recall. A smaller set of reliable corrections is better than broad, noisy coverage.
- False positives are worse than missed corrections. A missed correction leaves normal typing behavior intact; a false correction can actively mislead the user.
- Unsupported cases should be recorded as known limitations so coverage gaps stay visible.
- Promotion must remain conservative. Do not blindly put correction candidates first.

## Next Recommended Milestone

The next coverage milestone should be repeated final character deletion, for example `nihaoo -> nihao`. It is common on small screens, easy to explain, and lower risk than broad edit-distance correction.

Before aggressive coverage expansion, add confidence scoring so middle-character mistakes, omitted characters, and transpositions can be evaluated without increasing false positives.

V0.3 UI work should wait until correction quality is stable enough that visual correction hints reflect trustworthy suggestions.
