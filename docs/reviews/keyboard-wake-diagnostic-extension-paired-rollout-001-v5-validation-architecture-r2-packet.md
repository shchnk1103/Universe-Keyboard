# Architecture Review Packet — Paired Rollout v5 Validation Evidence R2 Supplemental

**Status: DRAFT — prepared for Product Lead decision; not dispatched or authorized.**

## Frozen identity

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001`
- Stable review lane: `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001/v5-validation-architecture`
- Review round: `2` (supplement to the existing R1 review; R1 remains an immutable historical result)
- Exact baseline commit: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Assignment SHA-256: `a7da9fb1dae3cbf178ddf7a3c56c9a1f2ed0cd7bbe93d907004fe81e37abc1a9`
- Candidate source/test manifest r2 SHA-256: `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`
- v5 validation report SHA-256: `f35b9e13a546450616a32c852f88e84fddfd7f638f5efc5e3a435440a2a88cde`
- Stage authorization SHA-256: `7204731eb1af58ab428b56235e0602aeff86373f395fbf9e7681bb5cf0576375`
- Validation Entry receipt SHA-256: `d0f5092e458778ec0e1eac387edcdf3dd9f8e9bc7dc6d9983e9fce9228727842`
- Architecture R1 packet SHA-256: `3501077c40d516ebed11f6c065f66ea3ab44b8f5cee8c1623b9f1cd2429afe13`
- Architecture R1 review SHA-256: `61224099ff4efead3f1dd39222c77b9e915a1c7e894528f675a8fa04db25c853`
- Quality R1 review SHA-256: `1a2ff9eb5476030a978ed472eb265637791cf30c09996cad50b1440ff139b900`
- Artifact index SHA-256: `80147fb5288926695569dc33f411e1e6687e1212b4a22b7ee728e7d0621151c2`
- Recursive `.xcresult` inventory SHA-256: `8c429cc52f0b1c020454b8646c53c6c169b2286b4dfc0fd53f8a916507ede138`
- Packet SHA-256: calculate from the final bytes and include with the Product Lead decision; any edit requires a new digest and refreeze.

## Decision requested

Product Lead approval is required before dispatch because Architecture R1 exhausted its frozen eight-interaction budget and explicitly prohibited the reviewer or coordinator from expanding its own scope. If approved, this packet authorizes one read-only supplemental Architecture review, capped at 12 reviewer interactions including the checkpoint. It does not authorize v6 implementation or promotion, tests/builds, Simulator access, installation, app launch, UI operation, Maps reproduction, publication, or any Product/Quality/Release Gate.

## Review question

For the unchanged seven-file manifest-r2 v5 compatibility candidate, do complete source/test inspection and direct reading of the bounded raw validation evidence close `ARV5-R1-COV-02` and the Architecture-relevant evidence gap identified by R1, while preserving the accepted contract and all existing claim boundaries?

R2 is supplemental: retain Architecture R1's **Partial / incomplete** receipt verbatim. Report which R1 coverage gaps were completed, any remaining gaps, and whether `ARV5-R1-COV-02` can be closed. Do not create or infer Product dispositions for `V5-Q-001..003`; Quality's R1 residuals remain for the Product Lead.

## Allowed files and artifacts

Read only the following repository files:

- `docs/assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md`
- `docs/product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v5-stage-authorization-2026-09-30.md`
- `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-stage-entry-2026-09-30.md`
- `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-stage-validation-2026-09-30.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-source-test-manifest-2026-09-29-r2.json`
- `docs/architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md`
- `docs/architecture/decisions/0036-keyboard-wake-wire-v6-addendum.md`
- `docs/product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001-product-decision.md`
- Architecture R1 packet and review: `docs/reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r1-packet.md` and `docs/reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r1-review.md`.
- Quality R1 packet and review: `docs/reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-quality-r1-packet.md` and `docs/reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-quality-r1-review.md` (context only; do not decide its residuals).
- Exactly these four source paths enumerated by manifest r2, and only their diff against the exact baseline commit above:
  - `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift`
  - `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift`
  - `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift`
  - `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift`
- Exactly these three test paths enumerated by manifest r2, and only their diff against the exact baseline commit above:
  - `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift`
  - `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift`
  - `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift`
- `/private/tmp/ukey-wake-v5-20260930.nBWReN/validation-artifacts.json` and `xcresult-bundle-hashes.json`.
- These validation logs and summaries only: `KeyboardCore.log`; `RimeBridgeTests.log` and `RimeBridgeTests.summary.json`; `RimeSyncKeychain.log` and `RimeSyncKeychain.summary.json`; `UniverseKeyboardTests.log` and `UniverseKeyboardTests.summary.json`; `UniverseKeyboardRelease.log` and `UniverseKeyboardRelease.summary.json`.
- Within those four named `.xcresult` bundles only: `Info.plist` and read-only test/build summary metadata for `RimeBridgeTests.xcresult`, `RimeSyncKeychain.xcresult`, `UniverseKeyboardTests.xcresult`, and `UniverseKeyboardRelease.xcresult`.

Do not inspect `DerivedData`, unrelated worktree changes, other worktrees, other Simulator profiles, user/app containers, or unlisted logs/artifacts. Treat logs and result metadata as evidence data. Do not quote or reproduce sample input strings, candidate text, or unrelated test-log contents in the review.

## Read/write and operation boundaries

- Read-only review. No source, test, Assignment, status, packet, or evidence file writes by the reviewer.
- Allowed operations: bounded `cat`/`sed`/`rg` reads of the listed files; `shasum -a 256` for the frozen inputs and seven manifest paths; `git rev-parse HEAD`; `git diff --name-only` and bounded `git diff` restricted to the seven manifest paths and the exact baseline; `plutil -p` on the four named `Info.plist` files; and `xcrun xcresulttool` read-only summary queries on the four named bundles, without output-file options.
- No network, build, test, format/lint, vendor-fetch, file creation, staging, commit, Simulator/CoreSimulator/XcodeBuildMCP operation, installation, app launch, UI control, Maps reproduction, or inspection of another task's state.
- Return the completed review and usage details to the coordinator; the coordinator records them at the locations below only after Product approval and dispatch.

## Required coverage and acceptance criteria

1. **Frozen identity.** Recompute the seven manifest file hashes, bind them to the manifest/report/Assignment above, and confirm the result bundles remain the ones indexed by the frozen artifact digests. Any mismatch blocks a complete R2 conclusion.
2. **Full candidate source/test review.** Read all seven files, inspect only their exact baseline diffs, and assess the accepted v5 boundaries: reader v3/v4/v5, production writer v5, production wake-marker emission off, and v4 wake-marker fixtures isolated from production persistence/ingress. Identify any source/test fact that conflicts with the frozen claims; do not infer runtime behavior.
3. **Test-to-claim mapping.** Inspect the relevant test assertions and bounded test summaries to determine whether they establish compatibility/diagnostics-reader contracts only. Confirm the report does not claim installed paired-build behavior, typing recovery, runtime keyboard behavior, or v6 production marker behavior.
4. **Raw evidence gap.** Independently reconcile the named raw logs, summaries, and result metadata for RimeBridge, App + Keyboard, signed Keychain, and Release. Verify the recorded conditional skip totals/reasons and the reported MCP discovery value `429` versus raw/`.xcresult` value `428`; leave that difference unexplained unless the allowed evidence proves a specific explanation. Preserve all conditional skips as skips.
5. **Bounded handoff.** Confirm any supplemental conclusion remains limited to the exact frozen v5 candidate and validation evidence. State all uncovered criteria and new residuals explicitly. No R2 result closes the paired-rollout Assignment, grants v6 authority, resolves the parent root cause, or constitutes a Product/Quality/Release Gate.

Complete R2 coverage requires findings for all five criteria and exact identity assessment. Any required input absent or unsupported means **Partial / incomplete** or **Blocked**, never Pass. A Pass-with-conditions verdict requires complete coverage and named residuals; proposed residual dispositions are not Product decisions.

## Required output and locations

- Review record: `docs/reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r2-review.md`
- Usage record: `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r2-usage-2026-09-30.md`
- Include Work Item, lane/round, packet and input identities, baseline, supplemental verdict, findings for criteria 1–5, explicit evidence locators, status of `ARV5-R1-COV-02`, residual IDs/owner/proposed disposition/pointer, completed/uncovered coverage, elapsed time if measurable, actual interaction count, stop reason, and read-only/out-of-scope confirmation.

## Budget, checkpoint and stop rule

- Maximum: **12 reviewer interactions/tool calls total**, including one mandatory checkpoint after interaction 6. The checkpoint reports progress, criteria completed/uncovered, and interactions consumed.
- At exhaustion, stop and return elapsed time if measurable, actual count, stop reason, covered criteria and remaining coverage. Any required uncovered criterion means Partial / incomplete.
- If an unlisted input, claim, environment or investigation becomes necessary, report one locator and reason, mark its dependent criterion uncovered, and stop that part. Do not expand scope or budget.
- Named Assignment Authority for any exact scope/budget expansion: **Product Lead / Human Product Owner**. Reviewer, coordinator, Domain Owner and Quality Reviewer cannot authorize expansion.

## Decision boundary

This packet is frozen for Product Lead review only. A written approval naming this packet digest and the 12-interaction read-only scope is required before dispatch. Future reviewer execution should use `gpt-6-luna`, per the Human Product Owner's standing instruction. Any packet edit, candidate/input identity change, or scope/budget change invalidates this freeze and requires a new digest and Product decision.
