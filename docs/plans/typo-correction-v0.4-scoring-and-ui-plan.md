# Typo Correction V0.4 Scoring And UI Plan

> **Status: archived implementation plan.** V0.4 has been implemented. Current behavior and supported boundaries are defined by `docs/TYPO_BENCHMARK.md` and tests, not by this plan.

## Summary

V0.4 strengthens the existing typo-correction layer by making confidence decisions explicit and visible. It does not expand typo coverage to omitted characters, transpositions, multi-edit corrections, or intermediate-syllable correction.

The core boundary is:

- RIME ranks candidates for the same input code.
- Typo correction decides whether a corrected input code should contribute an optional side-channel candidate.

The main app should show current capability and benchmark coverage, but it must not collect runtime telemetry or expose a new behavior switch in this phase.

## Implementation Scope

- Add a pure `TypoCorrectionAssessment` model with confidence tier, score, display eligibility, promotion eligibility, and reject reason.
- Use the assessment model from typo suggestion filtering and candidate ranking so display and promotion rules do not drift.
- Add a read-only main-app `智能纠错` page under Settings -> 输入体验.
- Keep typo correction Partial Commit feature flag off by default.
- Keep RIME fuzzy pinyin, RIME user dictionary learning, and RIME candidate weighting independent from typo correction scoring.

## Scoring Rules

- High-confidence final adjacent-key substitution can be promoted when the normal top candidate is a longer expansion.
- Initial and middle adjacent-key substitution can appear near the front, but should not blindly replace the normal top candidate.
- Repeated-final deletion can be displayed conservatively, but should not be promoted aggressively.
- Candidates must be verified through the existing RIME/candidate-provider flow before display.
- Very short input, unsafe replacements, missing corrected candidates, repeated normal-candidate conflicts, and overly long correction text should be rejected.

## UI Requirements

- The main app page is informational only.
- It should show supported examples, unsupported boundaries, and the relationship between typo scoring and RIME weighting.
- Benchmark examples are representative, not a hardcoded allowlist. The page should say so explicitly.
- Known recall gaps, such as `zhonghuo -> zhongguo` missing the bounded lookup window, should be documented as future suggestion-prioritization work.
- It must not include an input box, telemetry, App Group settings, deployment controls, or feature toggles.
- It should reuse existing main-app grouped surfaces and compact badges.

## Validation

Required checks:

```bash
git diff --check
swift test --package-path Packages/KeyboardCore
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination "generic/platform=iOS Simulator" build
```
