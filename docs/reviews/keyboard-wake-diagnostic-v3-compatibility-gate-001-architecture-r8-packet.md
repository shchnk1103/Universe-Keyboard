# Architecture Review Packet — V3 Compatibility Gate 001 — Round 8

## Frozen identity

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Stable lane: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001/architecture`
- Review round: `8`; this new numbered round addresses only `AR7-COV-01` after R7 stopped incomplete.
- Reviewer role: independent Architecture & Knowledge Steward runtime; must not be the candidate Executor.
- Exact baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Assignment SHA-256: `9ff30b053cc66e690d2bbf03950a7ec2047ce7a76ae799d3b2aa2c5793a61a55`
- Product Authorization SHA-256: `600c9e0419d050912d59b8496bce592896cf75aa08ef48d07a215d28df63fe4e`
- Manifest r2 SHA-256: `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`
- Stage B validation SHA-256: `f2234eb14a5539a5beb0a1c0b904875c203259889fd2aac68f1b5d3e19644891`
- Prior Architecture R6 receipt: `docs/reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r6-review.md`
- Prior Architecture R7 receipt SHA-256: `1d4e5057e55921fe3da59bd0150350aa1e49bd71f85e9a6ce4c20365e0e324ba`
- Prior Architecture R7 usage SHA-256: `8792c47d87c52818d6143b3679d705a58228b9b86b13e3cb5752d0b28a78077d`
- Packet digest: hash this file and record the exact SHA-256 in the receipt and usage record.

## Objective

Complete the source-and-test architecture coverage left open by Architecture R7 for the exact, unchanged manifest-r2 candidate. This is evidence review only. Do not broaden the Assignment, change source/tests, or infer runtime behavior.

## Questions

1. Does the candidate read each record according to its own v3/v4/v5 schema, preserve v5 `typo_recall`, and reject unsupported versions, raw keys, malformed typed payloads, and code/payload mismatches without rewriting retained history?
2. Is the wire schema closed and validated at the strict raw-key entry point? Are duplicate JSON member detection limitations represented only as the accepted non-claim?
3. Does the reader and Main App consumer preserve `incomplete`/unsupported status across query continuations and suppress the legacy fallback except for known-complete empty v1?
4. Does the candidate add no production Extension wake-marker call site, keep the production writer at schema v5, and confine v4 marker examples to temporary or in-memory test fixtures without real App Group storage or production ingress?
5. Are diagnostics fields content-free, and is the `nonisolated` merge helper a pure `Sendable` value operation with no actor-state access?
6. Do the changed tests directly assert the compatibility, failure, continuation, fallback, v5-retention, and fixture-isolation claims above? Identify any assertion that is absent, weaker than the contract, or tests only implementation details.
7. Does the exact candidate remain the one named by manifest r2 and Stage B? Record any residual with stable ID, owner, disposition, and source/test pointer.

## Required review method

- Verify packet digest, frozen Assignment/authorization/manifest/evidence identities, base commit, and all seven manifest file hashes.
- Inspect each relevant source and test change in bounded groups. Compare tracked files against the exact frozen base; inspect the manifest-listed new validator file directly. Do not rely on truncated command output or prior review conclusions as a substitute for inspection.
- Read the accepted compatibility contract and candidate addenda in the Assignment, Proposal 0.4 addendum, ADR 0036 addendum, and ADR acceptance.
- Reconcile R7 residuals from the R7 receipt. R6/R7 identities and their incomplete verdicts are history, not approval.
- Return a complete proposed receipt and usage record. State exact coverage per question and explicitly mark any uncovered claim.

## Allowed inputs

- `docs/assignments/keyboard-wake-diagnostic-v3-compatibility-gate-001.md`
- `docs/product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001-authorization.md`
- `docs/plans/keyboard-wake-diagnostic-v3-compatibility-gate-001-addendum.md`
- `docs/architecture/decisions/0036-v3-compatibility-gate-001-addendum.md`
- `docs/architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md`
- `docs/product-decisions/ADR-0036-ACCEPT-authorization.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-source-test-manifest-2026-09-29-r2.json`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-b-validation-2026-09-29.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-b-reservation-2026-09-29.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-b-run1-compilation-failure-2026-09-29.md`
- `docs/reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r6-review.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r6-usage-2026-09-29.md`
- `docs/reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r7-review.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r7-usage-2026-09-29.md`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift`
- `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift`
- `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift`

## Boundaries

- Read-only. Do not edit files or return a proposed source patch.
- Do not run tests, builds, formatters, `xcresulttool`, Simulator/CoreDevice/UI commands, installs, vendor commands, network requests, or access another worktree.
- Do not make Product, Quality Gate, Release, runtime, or root-cause decisions. Do not authorize marker emission, publication, commit, push, PR, merge, or parent closure.
- If a frozen identity mismatches or an input is missing, name the exact locator, mark dependent claims uncovered, and stop that dependency; do not search beyond this allowlist.

## Outputs and acceptance

Return one verdict: `Pass`, `Pass with conditions`, `Partial / incomplete`, or `Block`; answers to all seven questions; a complete-coverage statement; every residual with stable ID, owner, `fix` / `accept` / `tech_debt:<ID>`, and evidence pointer; and a proposed review receipt plus usage record. Positive acceptance requires complete source-and-test coverage of every applicable contract above. A Partial round cannot be interpreted as a pass.

## Budget and stop rule

- Maximum: 8 total reviewer tool interactions or 8 active minutes, whichever occurs first.
- Checkpoint after 4 total interactions or 4 minutes; the checkpoint message counts toward the interaction budget.
- Batch independent reads and hashes. Partition diffs so no output is truncated. Continue after the checkpoint only if identity is sound and sufficient budget remains.
- On exhaustion, stop with `Partial / incomplete`; do not infer a pass or request an in-place budget extension. Any further review requires another numbered packet.
