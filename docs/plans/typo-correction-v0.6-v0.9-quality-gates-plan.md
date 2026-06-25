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

## V0.9: Adjacent Transposition V1

- Add experimental `transposition` edit support behind a default-off flag.
- Limit to one adjacent swap.
- Target benchmark example:
  - `nihoa -> nihao -> 你好`
- Keep behavior display-only and non-promoting.
- Do not combine with insertion or substitution into multi-edit correction.

## Acceptance Criteria

- The Main App can show local benchmark status without telemetry.
- `KeyboardCore` tests enforce zero false positives and zero dangerous corrections in the default benchmark.
- Feature-flag-off behavior preserves all current typo correction behavior.
- Feature-flag-on tests prove insertion and transposition can be evaluated without changing production runtime defaults.
- Documentation remains clear that RIME weighting and schema fuzzy pinyin are separate systems.
