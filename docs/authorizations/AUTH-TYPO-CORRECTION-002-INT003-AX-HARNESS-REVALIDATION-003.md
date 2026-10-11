# Authorization: AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-003

## Current Status

| Field | Value |
|---|---|
| Status | `consumed — capture complete; INT-003 inconclusive because observed cadence did not meet <180 ms` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Case | `TC2-CASE-INT-003` / `TC2-CTR-INT-002` |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Action | Correct the test-only AX harness compile defect, then collect one internally scheduled AX-key cadence trace |
| Run ID | `TC2-SIM-20260919-181538-INT003-AX-REVAL-03` |
| Consumed at | `2026-09-19T18:15:38+08:00` |
| Predecessor | [`INT-003 AX retry 02 — compile blocked`](../evidence/typo-correction-002-sim-run-2026-09-19-int003-ax-reval-02-compile-blocked.md) |

This is a fresh retry Authorization. It does not reuse retry 02's failed
test-target compilation, package, install or Run ID.

## Authorized scope

- Keep the parent typo-correction implementation and the already-reviewed PR
  #140 AX production changes unchanged.
- Repair only the test-target Swift interpolation defect in
  `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift`
  so that the bounded skip message compiles.
- Use the existing XCTest-internal AX harness to resolve Universe Keyboard's
  independent key elements and invoke their existing UIKit `tap()` action path.
- Schedule a rapid key burst with requested inter-key gaps below the documented
  180 ms debounce boundary, followed by a post-burst pause above that boundary.
- Record content-free diagnostics, actual timestamps, operation/revision/session
  evidence and whether stale work is applied after newer input.
- Rebuild/reinstall this corrected retry snapshot and record fresh
  source/build/package/provenance hashes before capture.

The test may contain a fixed synthetic key fixture, but runtime diagnostics and
receipts must not persist raw pinyin, candidate text or host text. `typeText`,
pasteboard, host injection, `documentContext` and `setMarkedText` remain
prohibited.

## Bound execution identity

- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch: `codex/typo-correction-002-provenance-sidecar`
- Parent implementation base: `9eb83158e49218c1e8f75dbe7dd9e0390db81409` plus the bound dirty production/test snapshot.
- Testability production input: merged PR #140 at `162b09fd58ba60538a944026b1902efa405c75aa`.
- Target: iPhone 17 Pro Max / iOS 27.0 Simulator, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`.
- Host: Messages, `+1 (888) 555-1212`.
- Corrected tracked source/test diff SHA-256: `60b1e543154bc75dd2c03788fd6e0f37e6a02e98b1648f41913ea6c7abab36ce`.
- Formatting: `swift-format lint --strict --configuration .swift-format` passed for the corrected UI-test file before build.
- Derived data: `/private/tmp/universe-keyboard-typo-correction-002-int003-ax-retry-03-derived`.

Fresh package hashes, installed provenance and raw-artifact hashes must be
written into the retry 03 Run Receipt. Any further source, build, install,
schema, device or restarted-capture change requires another Authorization and
Run ID.

## Capture disposition

The XCTest-internal AX harness passed and produced 22 independent key events,
but the diagnostic journal measured 21 adjacent intervals of `526.617583` to
`880.752 ms`; none was below 180 ms. The resulting receipt is
[`INT-003 AX retry 03 — inconclusive`](../evidence/typo-correction-002-sim-run-2026-09-19-int003-ax-reval-03-inconclusive.md).
This Authorization is consumed and cannot be reused for another method.

## Explicit exclusions

- No production behavior, debounce threshold, search budget, recall setting,
  schema, vendor archive or RIME bridge change.
- No FakeCandidateProvider, old Ice directory, test-only RIME fixture or
  candidate-count inference.
- No reuse of retry 01, retry 02, the sidecar Run Receipt or the original
  INT-003 Authorization as evidence for this retry.
- No commit, push, PR, merge, TestFlight, Release, Product/Quality Gate or
  Assignment closure.
- No QA-001, paired-performance or semantic candidate-quality conclusion.

## Stop / completion

Stop with an explicit inconclusive receipt if Universe Keyboard identity,
independent AX key targets, actual cadence or stale-work boundary cannot be
proven. Completion produces one fresh INT-003 Run Receipt for independent
review only; a passing harness run does not itself close INT-003.
