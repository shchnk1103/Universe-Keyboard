# Typo Correction V0.6-V0.9: Quality Gates Before Coverage Expansion

## Summary

This roadmap keeps typo correction benchmark-driven. The next priority is not broad coverage expansion, but a repeatable local evaluation system that proves safety before any higher-risk edit type is enabled.

Defaults:

- V0.6 and V0.7 do not change keyboard runtime behavior.
- Main App may show a local read-only evaluation page.
- No real user input is collected, stored, uploaded, or used as telemetry.
- New edit types stay behind default-off feature flags.
- RIME schema, RIME weights, candidate UI, and Typo Partial Commit defaults remain unchanged.

## V0.6: Local Evaluation And Quality Gates

- Add KeyboardCore benchmark models and evaluator:
  - `TypoCorrectionBenchmarkCase`
  - `TypoCorrectionBenchmarkResult`
  - `TypoCorrectionBenchmarkEvaluator`
- Use the existing fake candidate provider and typo engine to evaluate built-in benchmark cases.
- Add Main App read-only local evaluation display under `智能纠错`.
- Gate quality with tests:
  - supported cases correct successfully;
  - unsupported cases remain uncorrected;
  - dangerous cases remain uncorrected;
  - normal inputs avoid false positives;
  - generated suggestions remain bounded.

## V0.7: Assessment Explanation

- Add a testable assessment reason summary while preserving existing confidence tiers.
- Surface the reason in the Main App evaluation display.
- Keep ranking behavior unchanged:
  - final substitution may promote only in the existing long-expansion case;
  - initial and middle substitutions remain near-front only;
  - repeated-final deletion remains conservative.

## V0.8: Conservative Insertion V1

- Add experimental `insertion` edit support behind a default-off flag.
- Limit to single-character near-final insertion.
- Target benchmark example:
  - `niho -> nihao -> 你好`
- Keep behavior display-only and non-promoting.
- Do not integrate with runtime controller until separately approved.

### V0.8a: Insertion Display-Value Optimization

Goal: make conservative near-final insertion useful enough to see on device without making it aggressive.

Real-device flag-on validation showed that `niho -> nihao` is safe but low-value in its current ranking: corrected candidates such as `你好`, `拟好`, and `你号` appeared around the 13th position. This is not a safety failure, but it is not product-useful because most users will never see the correction.

Scope:

- Keep the production insertion feature flag default off until validation completes.
- Do not add new edit types.
- Do not enable transposition.
- Do not add learning, persistence, or telemetry.
- Do not change RIME weights, schema, candidate learning, or user dictionary.
- Do not change candidate UI style.

Ranking target:

- Eligible near-final insertion corrections may enter the front candidate area.
- Default target is position 2 or 3, not position 1.
- Final high-confidence substitution behavior remains unchanged.
- Repeated-final deletion remains conservative.
- Transposition remains benchmark-only.

Eligibility rules:

- Exactly one edit.
- Edit kind is `insertion`.
- Insertion is near-final and explains a plausible pinyin completion.
- Corrected input resolves through RIME/provider.
- Corrected candidate text is short and high-quality, normally 2-4 Chinese characters.
- Original input must not already have a strong matching normal candidate.
- Dangerous examples such as `haop` and `xianp` must remain uncorrected.
- Normal inputs such as `nihao`, `women`, `jintian`, `xiexie`, `shijian`, `zhongwen`, and `ceshi` must remain undisturbed.

Implementation outline:

- Extend `TypoCorrectionAssessment` with a distinguishable "front-display eligible" state or equivalent ranking signal for conservative insertion.
- Keep `isPromotionEligible == false` for insertion.
- Teach `TypoCorrectionCandidateRanker` to place eligible insertion candidates near-front without replacing the normal top candidate.
- Keep generated suggestion and RIME lookup limits unchanged.
- Add tests for `niho -> nihao -> 你好` entering the front area and not promoting to first.

Implementation note:

- V0.8a uses the existing `conservativeInsertion` assessment reason as the near-front ranking signal.
- It does not change the production default `TypoCorrectionEngine()` feature flags.
- It only changes ordering when insertion correction candidates already exist, such as in a temporary flag-on validation build.
- Transposition remains excluded from near-front ranking.
- Debug builds expose internal-only experiment switches on the main-App `智能纠错` page, so device validation can enable insertion/transposition without temporary source edits.
- Release builds must ignore these App Group experiment keys and keep all experimental typo edits disabled by default.

Acceptance criteria:

- `niho -> 你好` appears near-front on real device, ideally position 2 or 3.
- No dangerous correction for `haop` or `xianp`.
- Normal input regression remains clean.
- `nihap`, `bihao`, `nigao`, `zhonghuo`, `zhonggup`, and repeated-final behavior do not regress.
- KeyboardCore tests and Xcode build/test pass.

### V0.8b: Local Correction Selection Learning

Goal: after V0.8a proves a conservative insertion correction is visible and safe, allow repeated user selection to gradually improve that correction's local ranking.

This is intentionally separate from V0.8a because it introduces local persistence and user-specific ranking. It must not become a second RIME weight system.

Scope:

- Learn only from explicit user selection of typo correction candidates.
- Store only compact correction-pair metadata, not full typed text context or surrounding sentence content.
- Keep all data local in App Group storage.
- Do not upload telemetry.
- Do not write to RIME user dictionaries.
- Do not modify RIME schema or RIME weights.
- Do not affect normal RIME candidate learning.

Suggested learned key:

- `originalInput`, for example `niho`
- `correctedInput`, for example `nihao`
- `candidateText`, for example `你好`
- `editKind`, for example `insertion`

Suggested learned value:

- `selectionCount`
- `lastSelectedAt`
- optional `lastShownAt` if decay or diagnostics need it later

Ranking behavior:

- 0 selections: use V0.8a default, normally position 2 or 3.
- 1-2 selections: allow stronger near-front placement, normally position 2.
- 3+ selections: may allow position 1 only if the original normal top candidate is weak and the correction remains high-quality.
- Ignoring a correction should not immediately penalize it; absence of selection is too noisy to treat as rejection.
- Stale learned preferences should decay or be resettable so old habits do not permanently affect ranking.

State and privacy requirements:

- Add a small local store dedicated to typo correction learning.
- Keep storage bounded with a maximum number of learned pairs.
- Provide a future reset path before production enablement, either inside diagnostics or the smart-correction page.
- Document that learned correction ranking is local and separate from RIME candidate learning.

Failure and fallback rules:

- If the store is unavailable, ranking falls back to V0.8a behavior.
- If learned metadata is malformed, ignore it and do not block typing.
- If the correction no longer passes assessment, learned history must not force it to display.
- Dangerous, low-confidence, multi-edit, and transposition corrections do not use learning in V0.8b.

Acceptance criteria:

- Repeatedly selecting `niho -> 你好` can move the candidate higher within conservative bounds.
- Learned ranking does not affect unrelated inputs.
- Clearing or ignoring the learning store returns behavior to V0.8a.
- Normal input, dangerous examples, Delete, Space, Return, and candidate tap behavior remain unchanged.
- App Group read/write failure does not break keyboard input.

## V0.9: Adjacent Transposition V1

- Add experimental `transposition` edit support behind a default-off flag.
- Limit to one adjacent swap.
- Target benchmark example:
  - `nihoa -> nihao -> 你好`
- Keep behavior display-only and non-promoting.
- Do not combine with insertion or substitution into multi-edit correction.

## V0.8/V0.9 Flag-On Audit

Before any real-device validation, run the default-off experimental features through a local flag-on audit:

- Enable insertion and transposition only inside the benchmark evaluator.
- Keep production `TypoCorrectionEngine()` defaults unchanged.
- Require all experimental targets to pass.
- Require normal input preservation to stay at 100%.
- Require false positives and dangerous corrections to stay at 0.
- Treat successful audit as permission to test on a device, not permission to ship.

Recommended rollout order:

1. V0.8 insertion may enter device validation first because near-final omission is easier to explain and keep display-only.
2. V0.9 transposition should remain benchmark-first until device testing proves candidate noise is acceptable.

## Acceptance Criteria

- The Main App can show local benchmark status without telemetry.
- `KeyboardCore` tests enforce zero false positives and zero dangerous corrections in the default benchmark.
- Feature-flag-off behavior preserves all current typo correction behavior.
- Feature-flag-on tests prove insertion and transposition can be evaluated without changing production runtime defaults.
- Main App shows the flag-on audit result as a read-only readiness signal, not as a runtime switch.
- Documentation remains clear that RIME weighting and schema fuzzy pinyin are separate systems.
