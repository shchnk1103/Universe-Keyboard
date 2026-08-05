# T9-RESPONSIVE-PIPELINE-001 / P1-D2 Amendment B evidence

**Date:** 2026-08-01 Asia/Shanghai  
**Scope:** Product-selected P1-D2 Amendment B — visual shadow anchor, stable stale
Candidate/Path chrome and fail-closed interactions  
**Status:** Bounded slice complete with independent Architecture/Quality
Pass-with-conditions reviews; four P2 evidence debts remain  
**Authority:**
[`Product Decision`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md),
[`Assignment`](../assignments/t9-responsive-rime-pipeline-001.md),
[`Proposed ADR 0025 Amendment B`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md#13-proposed-amendment-b--p1-d2-visual-shadow-anchor-and-stable-stale-chrome)

## Contract exercised

- L1 is presentation-only: the latest host-visible L2 marked text is retained as
  a stable prefix and each pending accepted T9 slot contributes one `·`.
- With no stable L2 text, the host presentation is `·`×N. Internal T9 digits are
  never written through the composition projection boundary.
- L1 does not call RIME, `replaceInput`, `insertText` or commit the placeholder.
- Candidate, correction-candidate, candidate-page, Path, Space and partial
  selection affordances fail closed while the visual shadow is ahead.
- A live L2 snapshot atomically replaces the shadow and clears pending slots;
  reset/epoch barriers clear the retained stable prefix as well.
- The responsive and thread-affine gates remain default-off; no production
  Extension/RimeEngineImpl wiring changed.

## Changed surfaces

- `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveProvisionalComposition.swift`
  — stable prefix and pending-dot mirror/builder.
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift`
  — L2 stable snapshot capture, presentation-only L1 paint, pending-ledger
  alignment and unified ordered-output stable-shadow refresh.
- `Keyboard/Controllers/KeyboardViewController+CandidatePaging.swift`
  — UI candidate prefetch fail-closed while the visual shadow is ahead.
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+Candidates.swift`
  — fail-closed candidate, correction and page interactions.
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveProvisionalCompositionTests.swift`
  — stable-prefix, atomic replacement, no-digit, stale-action and ordered
  Delete-to-next-key regressions.
- Proposed Amendment/design, Assignment, Product Decision and plan records were
  updated; ADR 0025 remains Proposed.

## Verification

Commands were run from the repository root:

```text
swift test --package-path Packages/KeyboardCore --filter ResponsiveProvisional
  16 tests, 0 failures

swift test --package-path Packages/KeyboardCore
  858 tests, 0 failures

git diff --check
  passed
```

The full package run completed on the current worktree after the candidate
prefetch guard and ordered-action stable-shadow refresh were present. The package emitted an existing
optional-interpolation warning in `T9PinyinPathTests.swift`; it did not fail the
run.

## Independent review disposition

- [Architecture final re-review](../assignments/t9-responsive-pipeline-001-p1-d2-amendment-b-architecture-rereview-2.md)
  — bounded Amendment B **Pass with conditions**, P0/P1/P2/P3 = 0/0/4/1;
  P1-1 and P1-2 closed.
- [Quality final re-review](../assignments/t9-responsive-pipeline-001-p1-d2-amendment-b-quality-rereview-2.md)
  — bounded Amendment B **Pass with conditions**, P0/P1/P2/P3 = 0/0/4/0;
  focused 16/0, full 858/0, vendor verify passed.

The remaining P2 items are UI prefetch no-op evidence, the broader stale-action/
chrome matrix, direct epoch/abandon marked-text-history proof, and real-device /
Release performance evidence. They remain outside this bounded implementation
slice and do not authorize R6, ADR 0025 acceptance, Product Gate or default-on.

## Evidence boundary

This record proves only pure KeyboardCore behavior and the default-off gate
contract. It does not prove real librime latency, Extension scheduling,
third-party keyboard host behavior, iOS 26.0/Release behavior, jetsam safety,
or a subjective “不卡顿” claim. No real-device run, Release wiring, ADR 0025
acceptance, R6 or Product Gate was executed or implied by this evidence.

## Handoff

Hand off to independent:

- Architecture & Knowledge Steward — isolation, authority, lifecycle and ADR
  consistency.
- Quality, Performance & Release Maintainer — regression completeness,
  performance-risk framing and release-boundary honesty.

The work item remains `Active` with the bounded Amendment B slice recorded as
Pass with conditions; “tests green” is not a Product Gate or Release
authorization. Product Lead owns the next decision on the P2 debts or a later
R6/real-device authorization.
