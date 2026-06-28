# Typo Correction Benchmark

## Purpose

This document is the reference for small-screen pinyin typo-correction coverage. It records representative typo categories, the current expected behavior, and the next coverage priorities so future work is guided by measurable cases instead of intuition.

This is not runtime telemetry. It does not measure live user input, keyboard frequency, or production correction rates. It is a benchmark reference backed by `TypoCorrectionTests`, and new real-world typo cases should be added over time as they are observed.

This document does not evaluate traditional RIME fuzzy pinyin such as `zh/z`, `ch/c`, `sh/s`, or `n/l`. Those settings are implemented through RIME `speller/algebra` derive rules and are documented separately in `docs/RIME_FUZZY_PINYIN.md`.

The main App may display a local read-only evaluation of these built-in cases. That evaluation is not telemetry: it does not read arbitrary user input, store live typing data, upload results, or change keyboard behavior.

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

V0.7 adds an assessment reason summary for display and tests. The reason explains why a candidate is displayable, promotable, conservative, or rejected; it does not replace the confidence tier or RIME candidate weights.

## Experimental Edit Flags

V0.8 and V0.9 introduce default-off experimental edit flags for future validation:

- `insertion`: conservative near-final single-character insertion, for example `niho -> nihao`.
- `transposition`: one adjacent character swap, for example `nihoa -> nihao`.

These flags are available for tests and local benchmark evaluation only. They are not enabled by the production keyboard controller, are not connected to Partial Commit, and must not be used to broaden runtime behavior without a separate approval milestone.

### Device Validation Gate

Experimental edit flags may enter real-device validation only after the local flag-on audit passes all quality gates:

- Target experimental cases pass, such as `niho -> nihao -> 你好` and `nihoa -> nihao -> 你好`.
- Normal input regression remains clean for representative inputs such as `nihao`, `women`, `jintian`, `xiexie`, `shijian`, `zhongwen`, and `ceshi`.
- False positives remain `0`.
- Dangerous corrections remain `0`.
- Experimental corrections stay display-only and non-promoting.
- Production defaults remain unchanged.

Passing this gate means the feature is ready to be tested on a real device; it does not mean the feature is approved for production enablement.

### V0.8 Real-Device Finding

Flag-on device validation showed:

- `niho` safely generated corrected `nihao` candidates, but `你好`, `拟好`, and `你号` started around the 13th candidate position. This is too low to be useful in normal typing.
- `nihoa` showed `你好` as the first candidate through normal RIME behavior rather than typo correction, while the experimental typo path only surfaced `你号` much later. This makes transposition lower priority for now.
- Normal inputs such as `nihao`, `women`, `jintian`, and `xiexie` kept correct first candidates.
- Dangerous examples `haop` and `xianp` did not receive strong correction.
- Candidate tap, Delete, Space, Return, and general interaction remained normal.

Conclusion:

- V0.8 insertion is safe enough to optimize further, but not useful enough at its current candidate position.
- V0.9 transposition should stay benchmark-first because RIME already covers the primary `nihoa -> 你好` case on device.

Next work should split V0.8 into:

- V0.8a: front-display optimization for eligible near-final insertion, targeting position 2 or 3 without first-position promotion.
- V0.8b: local correction-selection learning, where repeated explicit selection can gradually improve ranking while staying separate from RIME weights and RIME user dictionaries.

V0.8a implementation keeps insertion behind the default-off experimental flag, but eligible insertion correction candidates now have near-front ranking behavior when the flag is enabled for validation. The expected behavior for `niho -> nihao -> 你好` is front-area display without first-position promotion.

V0.8b adds local selection learning for that experimental insertion path:

- Learning happens only after the user explicitly taps an insertion correction candidate.
- Stored data is limited to the original/corrected pinyin pair, selected candidate, edit kind, count, and last-selection date. Surrounding text and real typing context are not stored.
- One or two selections prioritize the learned item among near-front correction candidates.
- Three selections may allow a first-position learned correction only when it still passes assessment and does not displace a prefix-related normal candidate.
- Records are bounded and expire after 90 days; Debug builds provide a reset action.
- V0.8b itself learns insertion only. V0.9b later reuses the same bounded store for eligible adjacent transposition corrections; substitution, deletion, rejected, and multi-edit corrections remain excluded.

This learning remains separate from RIME weights and the RIME user dictionary. It only changes the merge position of an already validated typo correction candidate.

Real-device validation confirmed the V0.8b progression: after repeatedly selecting the correction candidate for `niho`, `你好` moved from the V0.8a near-front position to position 1. Existing normal-input behavior remained unchanged, and resetting the local learning records restores the V0.8a ranking baseline.

## V0.9 Transposition Preflight

The original `nihoa -> nihao` audit case is not sufficient by itself because real RIME may already return `你好` as the normal first candidate. In that situation typo correction adds no value and must suppress the whole corrected-input suggestion, including secondary candidates such as `拟好` or `你号`.

V0.9 therefore uses two complementary cases:

- `nihoa`: when normal RIME already places `你好` first, preserve normal behavior and show no transposition correction candidate.
- `zohngguo -> zhongguo -> 中国`: validate a longer adjacent swap where the correction layer may provide real recall value.

Transposition remains behind the Debug-only experiment flag and subject to the safe minimum input length. V0.9a places a useful transposition correction near-front without default first-position promotion. V0.9b records explicit transposition selections in the same bounded local store used by insertion; after three selections, conservative learned promotion may apply under the existing assessment and prefix guards.

Real-device validation confirmed both V0.9 stages: `zohngguo -> 中国` entered the front candidate area, each explicit selection increased the local selection count, and repeated choices moved `中国` to position 1. The `nihoa` case continued using normal RIME `你好` without leaking secondary transposition suggestions, and the existing normal/dangerous regression matrix remained stable.

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

The next typo-correction quality milestone should continue to be benchmark-driven. Use the V0.6-V0.9 quality-gate plan in `docs/plans/typo-correction-v0.6-v0.9-quality-gates-plan.md`: evaluate current behavior locally, explain assessment reasons, then validate default-off insertion and transposition before considering any production enablement.

Traditional RIME fuzzy pinyin expansion is a separate feature track and should not be measured with this typo benchmark.
