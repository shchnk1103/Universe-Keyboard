# Authorization: AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-002

## Current Status

| Field | Value |
|---|---|
| Status | `consumed — compile blocked before runtime; retry prohibited under this receipt` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Case | `TC2-CASE-INT-003` / `TC2-CTR-INT-002` |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Action | Replace the invalid external-batch attempt with one internally scheduled AX-key cadence trace |
| Run ID | `TC2-SIM-20260919-180642-INT003-AX-REVAL-02` |
| Consumed at | `2026-09-19T18:06:42+08:00` |
| Predecessor | [`INT-003 AX attempt 01 — inconclusive`](../evidence/typo-correction-002-sim-run-2026-09-19-int003-ax-reval-01-inconclusive.md) |

This is a fresh retry Authorization. It supersedes no result and reuses no package or Run ID from attempt 01.

## Authorized scope

- Keep the parent typo-correction implementation and the already-reviewed PR #140 AX production changes.
- Add or use only a test-target XCTest entrypoint that resolves Universe Keyboard's independent AX key elements and calls their existing UIKit `tap()` action path from inside the test process.
- Schedule a rapid key burst with actual inter-tap gaps below the documented 180 ms debounce boundary, then a post-burst pause above that boundary.
- Record content-free diagnostics, actual timestamps, operation/revision/session evidence and whether stale work is applied after newer input.
- Rebuild/reinstall this retry snapshot and record fresh package/provenance hashes before capture.

The test may contain a fixed synthetic key fixture, but runtime diagnostics and receipts must not persist raw pinyin, candidate text or host text. `typeText`, pasteboard, host injection, `documentContext` and `setMarkedText` remain prohibited.

## Bound execution identity

- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch: `codex/typo-correction-002-provenance-sidecar`
- Parent implementation base: `9eb83158e49218c1e8f75dbe7dd9e0390db81409` plus the bound dirty production/test snapshot.
- Testability production input: merged PR #140 at `162b09fd58ba60538a944026b1902efa405c75aa`.
- Target: iPhone 17 Pro Max / iOS 27.0 Simulator, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`.
- Host: Messages, `+1 (888) 555-1212`.

Fresh combined source/build/package hashes must be written into the retry Run Receipt. Any source, build, install, schema, device or restarted-capture change after this point requires another Authorization and Run ID.

## Attempt disposition

The app build and installation completed, but the selected UI-test target did not
compile. The compiler stopped at
`UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift:716`
with `missing argument label 'file:' in call`; the skip message used literal
text where Swift string interpolation was intended. The failure occurred before
the test body ran, so this Authorization produced no runtime keyboard input, no
INT-003 cadence, no diagnostic capture and no raw runtime artifact.

The compile-only failure is recorded in [`INT-003 AX retry 02 — compile blocked`](../evidence/typo-correction-002-sim-run-2026-09-19-int003-ax-reval-02-compile-blocked.md).
This Authorization is consumed and cannot be reused after the test-source fix.

## Explicit exclusions

- No production behavior, debounce threshold, search budget, recall setting, schema, vendor archive or RIME bridge change.
- No FakeCandidateProvider, old Ice directory, test-only RIME fixture or candidate-count inference.
- No reuse of attempt 01, the sidecar Run Receipt, or the original INT-003 Authorization as evidence for this retry.
- No commit, push, PR, merge, TestFlight, Release, Product/Quality Gate or Assignment closure.
- No QA-001, paired-performance or semantic candidate-quality conclusion.

## Stop / completion

Stop with an explicit inconclusive receipt if Universe Keyboard identity, independent AX key targets, actual cadence or stale-work boundary cannot be proven. Completion produces one fresh INT-003 Run Receipt for independent review only.
