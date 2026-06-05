# Typo Correction Benchmark

## Purpose

This document is the reference for fuzzy pinyin typo-correction coverage. It records representative typo categories, the current expected behavior, and the next coverage priorities so future work is guided by measurable cases instead of intuition.

This is not runtime telemetry. It does not measure live user input, keyboard frequency, or production correction rates. It is a benchmark reference backed by `TypoCorrectionTests`, and new real-world typo cases should be added over time as they are observed.

## Segmented RIME Preedit

Real librime preedit text may contain display-oriented segmentation spaces even when the user typed one continuous pinyin key sequence. For example:

- `ni h a p -> nihap`
- `ni hap -> nihap`

The correction pipeline normalizes segmented preedit by removing whitespace before typo matching and corrected-candidate lookup. This normalization is limited to typo correction; the original RIME composition and preedit display remain unchanged.

## Current Supported Categories

- Valid input should not be disturbed. When input already maps to normal candidates, correction should stay out of the way.
- Final adjacent-key substitution is supported for conservative one-character mistakes, such as `nihap -> nihao`.
- Repeated final-character deletion is supported for conservative end-of-input duplicates, such as `nihaoo -> nihao`.
- Candidate promotion is conservative. A correction candidate may be promoted only when it is a high-confidence single-character correction and the normal top candidate appears to be a longer expansion of the corrected phrase.

## Current Unsupported Categories

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
| `nihaoo` | `nihao -> 你好` | repeated final character | corrected successfully | no |
| `nihoa` | `nihao -> 你好` | transposed character | not corrected | no |
| `nihso` | `nihao -> 你好` | middle-character mistake | not corrected | no |
| `zhongguo` | none | valid input | not corrected; normal candidates preserved | no |
| `zhonggup` | `zhongguo -> 中国` | final adjacent-key substitution | corrected successfully | yes |
| `zhongguoo` | `zhongguo -> 中国` | repeated final character | corrected successfully | no |
| `woaini` | none | valid input | not corrected; normal candidates preserved | no |
| `woainj` | `woaini -> 我爱你` | final adjacent-key substitution | corrected successfully | yes |
| `woainii` | `woaini -> 我爱你` | repeated final character | corrected successfully | no |
| `niho` | `nihao -> 你好` | omitted character | not corrected | no |
| `haop` | ambiguous | ambiguous / dangerous correction | not corrected | no |
| `haoo` | ambiguous | very short repeated final character | not corrected | no |
| `nii` | ambiguous | very short repeated final character | not corrected | no |
| `xianp` | ambiguous | ambiguous / dangerous correction | not corrected | no |

## Scoring Principles

- Prefer high precision over high recall. A smaller set of reliable corrections is better than broad, noisy coverage.
- False positives are worse than missed corrections. A missed correction leaves normal typing behavior intact; a false correction can actively mislead the user.
- Unsupported cases should be recorded as known limitations so coverage gaps stay visible.
- Promotion must remain conservative. Do not blindly put correction candidates first.
- Typo matching must use normalized pinyin because real RIME preedit may contain segmentation spaces.

## Partial Commit Eligibility

Typo correction Partial Commit is a separate behavior gate from typo generation. A correction may only enter Partial Commit when all of these are true:

- The internal feature flag is enabled.
- The correction is a single-character substitution already produced by the current typo engine.
- Replaying `correctedInput` in a clean RIME session can select the correction candidate on the current candidate page.
- Candidate selection leaves a non-empty remaining composition.
- Delete restore can replay the exact `originalInput`.

These correction types must continue to use full commit:

- Repeated-final deletion, for example `nihaoo -> nihao`.
- Multi-edit or low-confidence corrections.
- Corrections where the corrected candidate is missing or only available outside the current page.
- Corrections that would leave no remaining composition.
- Corrections selected while another Partial Commit checkpoint is already active.

Intermediate-syllable typo correction, for example `nihapanpai -> nihaoanpai`, is not implemented by the current typo engine. It is future correction coverage work, not a Partial Commit V2 regression.

## Feature Flag Exit Criteria

The typo correction Partial Commit feature flag must remain off by default until all of these are true:

- `KeyboardCore` tests and the Xcode simulator build pass.
- Flag-off real-device regression confirms existing typo full commit, normal RIME Partial Commit, Delete, space, return, and mode switching are unchanged.
- Flag-on real-device validation covers Delete restore, continued-typing checkpoint invalidation, full-commit fallback, visibility recovery, and candidate paging.
- Repeated-final deletion, low-confidence, and multi-edit corrections remain full commit.
- No normal RIME Partial Commit regression is found.
- Real-device validation confirms no stale candidate bar state, leftover composition, or duplicate confirmed text.

## Partial Commit Milestone Decision

Phase 3 V2 completed real-device validation with the feature flag off and on. The current product decision is:

- Typo correction Partial Commit keeps Delete restore behavior for now.
- First Delete restores the exact original typo input.
- Continued typing invalidates the checkpoint and resumes normal corrected composition deletion.
- No further optimization of this Delete restore behavior is planned in the current Chinese input milestone.
- Re-evaluate this behavior later when English input mode architecture is designed or revised.

## Next Recommended Milestone

V0.2.6 adds repeated final character deletion, for example `nihaoo -> nihao`. The next quality milestone should keep this path conservative by collecting real-world examples and reviewing whether deletion suggestions need confidence scoring before they are promoted.

Before aggressive coverage expansion, add confidence scoring so middle-character mistakes, omitted characters, and transpositions can be evaluated without increasing false positives.

V0.3 UI work should wait until correction quality is stable enough that visual correction hints reflect trustworthy suggestions.
