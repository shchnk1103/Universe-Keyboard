# Typo Correction Benchmark

## Purpose

This document is the reference for small-screen pinyin typo-correction coverage. It records representative typo categories, the current expected behavior, and the next coverage priorities so future work is guided by measurable cases instead of intuition.

This is not runtime telemetry. It does not measure live user input, keyboard frequency, or production correction rates. It is a benchmark reference backed by `TypoCorrectionTests`, and new real-world typo cases should be added over time as they are observed.

This document does not evaluate traditional RIME fuzzy pinyin such as `zh/z`, `ch/c`, `sh/s`, or `n/l`. Those settings are implemented through RIME `speller/algebra` derive rules and are documented separately in `docs/RIME_FUZZY_PINYIN.md`.

## Segmented RIME Preedit

Real librime preedit text may contain display-oriented segmentation spaces even when the user typed one continuous pinyin key sequence. For example:

- `ni h a p -> nihap`
- `ni hap -> nihap`

The correction pipeline normalizes segmented preedit by removing whitespace before typo matching and corrected-candidate lookup. This normalization is limited to typo correction; the original RIME composition and preedit display remain unchanged.

## Current Supported Categories

- Valid input should not be disturbed. When input already maps to normal candidates, correction should stay out of the way.
- Adjacent-key substitution is supported for conservative one-character mistakes, such as `nihap -> nihao`, `bihao -> nihao`, and `nigao -> nihao`.
- Non-final adjacent-key substitution is limited to same-class letters, such as consonant-to-consonant `g -> h`, to avoid broad middle-character noise.
- Repeated final-character deletion is supported for conservative end-of-input duplicates, such as `nihaoo -> nihao`.
- Candidate promotion is conservative. A correction candidate may be promoted only when it is a high-confidence single-character correction and the normal top candidate appears to be a longer expansion of the corrected phrase.

## Current Unsupported Categories

- Omitted characters, for example `niho -> nihao`.
- Transposed characters, for example `nihoa -> nihao`.
- Unsafe middle-character mistakes, for example non-final consonant/vowel cross-class `nihso -> nihao`.
- Unsupported final mistakes, for example `nihau -> nihao`.

Unsupported cases are known limitations, not failures of the current benchmark. They should remain recorded until a future milestone intentionally adds coverage.

## Benchmark Table

| Input | Intended correction | Category | Current expected behavior | Promotion |
|---|---|---|---|---|
| `nihao` | none | valid input | not corrected; normal candidates preserved | no |
| `nihap` | `nihao -> 你好` | final adjacent-key substitution | corrected successfully | yes |
| `bihao` | `nihao -> 你好` | initial adjacent-key substitution | corrected successfully | near-front only |
| `nigao` | `nihao -> 你好` | middle adjacent-key substitution | corrected successfully | near-front only |
| `nihal` | `nihao -> 你好` | final adjacent-key substitution | corrected successfully | yes |
| `nihak` | `nihao -> 你好` | final adjacent-key substitution | corrected successfully | yes |
| `nihau` | `nihao -> 你好` | unsupported final mistake | not corrected | no |
| `nihaoo` | `nihao -> 你好` | repeated final character | corrected successfully | no |
| `nihoa` | `nihao -> 你好` | transposed character | not corrected | no |
| `nihso` | `nihao -> 你好` | unsafe middle-character mistake | not corrected | no |
| `zhongguo` | none | valid input | not corrected; normal candidates preserved | no |
| `zhonggup` | `zhongguo -> 中国` | final adjacent-key substitution | corrected successfully | yes |
| `zhonghuo` | `zhongguo -> 中国` | middle adjacent-key substitution | corrected successfully | near-front only |
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
- Full-position typo correction is limited to a single adjacent-key substitution. Non-final replacements must keep the same broad pinyin role, such as consonant-to-consonant or vowel-to-vowel.
- Very short inputs remain conservative; inputs shorter than the typo engine's safe substitution length do not receive broad adjacent-key substitution.

## Assessment Model

V0.4 records confidence as an explicit assessment instead of scattering boolean checks across filtering and ranking:

| Tier | Meaning | Candidate behavior |
|---|---|---|
| High | Safe single-character adjacent-key substitution with a short verified RIME candidate | May be displayed; final-position cases may be promoted when the normal top candidate is a longer expansion |
| Medium | Conservative correction such as repeated-final deletion | May be displayed, but should not aggressively replace normal RIME order |
| Low | Plausible but not strong enough for the current benchmark | Do not show unless a future milestone explicitly adds coverage |
| Rejected | Unsafe, unsupported, or conflicting correction | Do not show |

Common reject reasons:

- Input too short.
- Replacement is not a safe adjacent-key edit.
- Corrected input has no verified candidate.
- Normal RIME top candidate already matches the correction text.
- Corrected candidate text is too long for the current conservative front-row behavior.

Benchmark examples are representative samples, not a hardcoded allowlist. V0.5 keeps the bounded lookup window but prioritizes safe one-edit descriptors so long-pinyin back-half mistakes such as `zhonghuo -> zhongguo` (`h -> g`) are verified before lower-value middle edits. This is a recall-priority fix inside the existing safe rule set, not a move toward broad edit distance or unsafe multi-edit correction.

## RIME Weighting Boundary

RIME's weighting system ranks candidates for the same input code. For example, repeated user selection can make `你好` appear earlier for `nihao`.

Typo correction scoring does not replace or rewrite RIME weights. It decides whether a different corrected input code should contribute an optional side-channel candidate. For example:

- RIME ranks `nihao -> [你好, 拟好, 你号...]`.
- Typo correction decides whether `bihao` is likely enough to query `nihao` and show `你好` as an optional correction candidate.

Candidate merging must respect this boundary. Typo correction candidates should not blindly override normal RIME candidates, especially when the original input already has a strong normal candidate.

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

The next typo-correction quality milestone should continue to be benchmark-driven. Prefer adding more real-world safe one-edit examples and measuring false positives before expanding coverage to omitted characters, transpositions, multi-edit corrections, or non-final consonant/vowel cross-class mistakes.

Traditional RIME fuzzy pinyin expansion is a separate feature track and should not be measured with this typo benchmark.
