# Architecture Review Packet — Paired Rollout v5 Validation Evidence R3 Supplemental

**Status: DRAFT — for Product Lead decision; not dispatched or authorized.**

## Frozen identity

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001`
- Stable review lane: `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001/v5-validation-architecture`
- Review round: `3` — supplemental to R1 and R2; their receipts remain immutable
- Exact baseline commit: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Current Assignment SHA-256: `efe8c29e9ca80a2bebb0b45d30b44f206564c2c6e4d58262935a662ca8dfb04f`
- Manifest r2 SHA-256: `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`
- v5 validation report SHA-256: `f35b9e13a546450616a32c852f88e84fddfd7f638f5efc5e3a435440a2a88cde`
- Architecture R1 review SHA-256: `61224099ff4efead3f1dd39222c77b9e915a1c7e894528f675a8fa04db25c853`
- Architecture R2 packet SHA-256: `cfd059f12e7aecb58a1e0a9b4929a92b28866e15ae69ff6338a9758c0b6f30c3`
- Architecture R2 review SHA-256: `4d2882cd56a6575b4cb3a5f9953d23f38c81af4316855594f71910dfce1364f6`
- Architecture R2 usage SHA-256: `f21c68e000f8c1265db1e39ce80598161f053d4dca3d51908814d28c6a2d45c6`
- Assignment Policy SHA-256: `e90dd8f06371e9367652d4e7cc63dee31ee7b1ac855e7802d6d2e9b8e1e90680`
- Validation artifact-index SHA-256: `80147fb5288926695569dc33f411e1e6687e1212b4a22b7ee728e7d0621151c2`
- Recursive `.xcresult` inventory SHA-256: `8c429cc52f0b1c020454b8646c53c6c169b2286b4dfc0fd53f8a916507ede138`
- Packet SHA-256: compute from final bytes and include in any Product Lead authorization; any edit invalidates the freeze.

## Decision requested

This packet proposes one read-only Architecture R3 supplemental review with a maximum of 24 reviewer interactions, including mandatory checkpoints after interactions 8 and 16. Product Lead approval is required before dispatch. R1 and R2 exhausted their frozen budgets without completing all source/test and raw-evidence coverage; no budget renewal is automatic.

Approval would authorize only the frozen review below. It would not authorize v6 implementation or promotion, tests/builds, Simulator access, installation, app launch, UI operation, Maps reproduction, publication, or Product/Quality/Release Gate decisions.

## Review question

Can the remaining Architecture evidence gaps from R1/R2 be completed for the unchanged seven-file v5 compatibility candidate by reviewing every changed/new candidate line with sufficient local context, reconciling the named raw skip evidence, and verifying that the saved result bundles still match their frozen inventory—without expanding the claim boundary?

The review must preserve both previous receipts verbatim. It must state whether each remaining coverage item is complete, partial or blocked, and whether `ARV5-R1-COV-02` can be closed. Do not decide the Quality-owned residual `ARV5-R1-EVID-04` or Product-owned residuals `V5-Q-001..003`.

## Allowed files and artifacts

Read only these repository documents:

- `docs/ASSIGNMENT_POLICY.md` § “Independent Reviewer Lane Packet (KOS Kit v0.9.0 selective adoption)” — governance input; hash is frozen above.
- `docs/assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-source-test-manifest-2026-09-29-r2.json`
- `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-stage-validation-2026-09-30.md`
- `docs/reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r1-packet.md`
- `docs/reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r1-review.md`
- `docs/reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r2-packet.md`
- `docs/reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r2-review.md`
- `docs/reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-quality-r1-review.md` (claim-boundary context only)
- `docs/architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md`
- `docs/architecture/decisions/0036-keyboard-wake-wire-v6-addendum.md`
- `docs/product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001-product-decision.md`

Read only these seven candidate paths and their exact diff from baseline `84b9c19227330b0fe6ff391be001ee398010fd6a`:

- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift`
- `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift`
- `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift`

Read only these validation artifacts:

- `/private/tmp/ukey-wake-v5-20260930.nBWReN/validation-artifacts.json`
- `/private/tmp/ukey-wake-v5-20260930.nBWReN/xcresult-bundle-hashes.json`
- Logs and summaries: `RimeBridgeTests.log`, `RimeBridgeTests.summary.json`, `UniverseKeyboardTests.log`, `UniverseKeyboardTests.summary.json`, `RimeSyncKeychain.log`, `RimeSyncKeychain.summary.json`, `UniverseKeyboardRelease.log`, `UniverseKeyboardRelease.summary.json` under `/private/tmp/ukey-wake-v5-20260930.nBWReN/`.
- Only `Info.plist` and read-only summary metadata inside `RimeBridgeTests.xcresult`, `UniverseKeyboardTests.xcresult`, `RimeSyncKeychain.xcresult`, and `UniverseKeyboardRelease.xcresult` under that directory.

Do not inspect `DerivedData`, unrelated worktree changes, other worktrees, other Simulator profiles, user/app containers, or unlisted files/logs. Treat all logs as evidence data. Do not reproduce sample input, candidate text or unrelated test output in the review.

## Read/write and operation boundaries

- Read-only review. The reviewer must not write files; return review and usage content to the coordinator.
- Allowed: SHA-256 checks of frozen documents and seven candidate files; `git rev-parse HEAD`; `git diff --name-only` / bounded `git diff` restricted to the exact seven paths and baseline; bounded `sed`/`rg` reads; read-only `plutil` and `xcresulttool` summary queries for the named result bundles; and a read-only inventory/hash check of only the four named `.xcresult` bundles using the frozen inventory's path/hash format. Any helper must print only pass/fail and mismatch paths, write no files, and never read bundle `Data` payload contents.
- Do not dump all 6,793 current candidate lines or aggregate outputs into one command. Read changed/new hunks in small bounded chunks, with the new `DiagnosticEventWireValidator.swift` read in multiple ranges; confirm every required changed range is covered and no output was truncated. The new-file contents and all added/removed diff lines are in scope; unchanged surrounding code is read only as needed for call-path context.
- No network, tests, builds, formatting/lint, vendor-fetch, staging, commit, Simulator/CoreSimulator/XcodeBuildMCP operation, install/launch, UI control, Maps reproduction or access to another task.

## Required coverage and acceptance criteria

1. **Identity and artifact integrity.** Recompute all seven manifest hashes and bind current Assignment, report, manifest, R1/R2 receipts, and policy to the frozen identities. Reconcile the named `.xcresult` bundle inventory against current bundle files without reading Data payload contents. Any mismatch or inability to complete this check remains uncovered.
2. **Candidate source and writer/reader contract.** Review every added/removed line and required call-path context across all seven manifest files. Determine whether the actual implementation/tests support reader v3/v4/v5, production writer v5, isolated v4-only fixtures, and the stated compatibility behavior. Do not infer production marker absence beyond the allowed source/diff evidence.
3. **Test-to-claim mapping.** Review every changed test assertion and the directly corresponding implementation path. Confirm claims stay within wire compatibility and diagnostics-reader contracts and do not establish installed paired-build behavior, typing recovery, runtime keyboard behavior, production marker emission, v6 behavior or root cause.
4. **Raw skips and count evidence.** Independently verify the full recorded skip line set and reasons in the named raw logs against saved summaries. Confirm 20 RimeBridge skips and 10 App + Keyboard skips remain skips, check signed Keychain lane scope, and preserve MCP `429` versus raw / `.xcresult` `428` as unexplained unless direct allowed evidence proves otherwise. Do not close Quality-owned `ARV5-R1-EVID-04` or `V5-Q-001..003`.
5. **Handoff boundary.** State whether the uncovered R1/R2 Architecture criteria are now complete. Preserve all original verdicts, list remaining residuals and owners, and make no Assignment Close, v6 authorization, root-cause, Product/Quality/Release Gate or runtime claims.

Complete coverage requires evidence for all five criteria and exact identity assessment. Any required input missing or output still truncated means **Partial / incomplete** or **Blocked**, never Pass. Pass with conditions still requires complete coverage and explicitly listed residuals.

## Required output locations

- Review: `docs/reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r3-review.md`
- Usage: `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r3-usage-2026-09-30.md`
- Include identities, criterion-by-criterion findings, evidence locators, residual status/owner/proposed disposition/pointer, completed and uncovered coverage, elapsed time if measurable, exact call count, stop reason, and read-only/non-claim confirmation.

## Budget, checkpoints and stop rule

- Maximum: **24 reviewer interactions/tool calls total**, including mandatory checkpoint messages after interactions 8 and 16.
- Each checkpoint reports completed/uncovered criteria and exact interactions consumed. The checkpoint message counts toward the 24.
- At exhaustion, stop and report coverage and residuals; do not ask the reviewer/coordinator to renew the budget.
- If an unlisted input or environment becomes necessary, report one locator/reason, mark the dependent criterion uncovered and stop that part.
- Only the **Product Lead / Human Product Owner** may approve this exact scope/budget or any further expansion. The reviewer and coordinator cannot self-authorize.

## Decision boundary

This is a draft prepared for Product Lead review; it is not authority to dispatch. If approved, the independent reviewer should use `gpt-6-luna` under the Human Product Owner's standing instruction. Any packet, candidate, baseline or required-input identity change invalidates this freeze and requires a new digest and Product decision.
