# Architecture Review Packet: V3 Compatibility Gate — Round 6

## Frozen identity

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Stable lane ID: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001/architecture`
- Review round: `6` — exact integrated source/test candidate after Stage B validation on manifest r2.
- Reviewer role: independent Architecture & Knowledge Steward runtime, not the Executor.
- Exact source baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Assignment SHA-256: `149805f68eb304975b59262ba6383f2f3ec86ecf790cec437cf53847b390c49a`
- Product Authorization SHA-256: `600c9e0419d050912d59b8496bce592896cf75aa08ef48d07a215d28df63fe4e`
- Source/test manifest r2 SHA-256: `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`
- Stage B validation evidence SHA-256: `f2234eb14a5539a5beb0a1c0b904875c203259889fd2aac68f1b5d3e19644891`
- Stage B reservation SHA-256: `abc1902d0c1024526b98d7a18f993960e4cfd35972349661e8e6bc93bd1fa10b`
- Stage B r1 compile-failure receipt SHA-256: `2be2d2c3a82151fb9633f8b2cfb70b6e39927b0e1656475691825f14bb788d64`
- Proposal 0.4 SHA-256: `e501a4075c24a79de560e7381ae361708c1a085250470e69840e23c930b53c06`
- Proposal compatibility addendum SHA-256: `102707357458ff2c0e965ae3bf7b00d82c61ef218450eacd5101e437004a5024`
- ADR 0036 SHA-256: `f950e4ee62c643efb21308cd7d633844379cb373fcde2e3e5604e5988fe5959c`
- ADR 0036 compatibility addendum SHA-256: `1d78cffb211800187d8f72a22789c8a789ca72ab98f9c68a12ddc969bae8f8ce`
- ADR acceptance SHA-256: `3926918c0ae5f7aa0704f1696d75bbd32dfc1b32fd0895225bc49bcd9dc5035d`
- Prior Architecture R5 receipt SHA-256: `faa7fc6aed29daf8dbbf85e385c29e55eca1f08f6e5b28c956f134df28af2057`
- Packet digest: compute SHA-256 over this frozen packet; include it in dispatch, receipt, and usage record.

## Review questions

Review the exact manifest-r2 candidate against the accepted schema/version contract, current v5 production behavior, and this Assignment's exclusions.

1. Does the candidate interpret each persisted v3/v4/v5 event under its own version, preserve v5 `typo_recall`, and reject unsupported versions and code/payload mismatches without rewriting old records?
2. Are v4 wake-marker event types reader-compatible only, with no production marker emission path added to the Extension, `DiagnosticsJournalRuntime`, writer, or app lifecycle setup? Are test-only v4 records confined to isolated fixtures?
3. Is the new wire validator consistent with the closed event schema, including raw-key and nested-payload checks and the documented duplicate-JSON-member limitation?
4. Do malformed/unsupported records remain visibly incomplete across the reader and query aggregation, including continuations, and does only a known-complete empty v1 journal permit legacy fallback?
5. Does the candidate preserve content-free fields and existing Main App / KeyboardCore / Extension ownership boundaries? Does the Stage B `nonisolated` helper change remain a pure `Sendable` value merge without actor-state access?
6. Do the exact source/test identity and Stage B evidence refer to one r2 candidate? Is the r1 compile failure correctly excluded from final acceptance after the full r2 matrix rerun?
7. Identify any material architecture mismatch, stale identity, missing compatibility coverage, or residual that must be resolved before Assignment handoff.

## Allowed inputs

Read only these files and the exact source/test candidate contents. For tracked source files, inspect the base-to-worktree diff; for the new validator file, inspect the manifest-listed file and its exact hash. Do not inspect unrelated worktree changes.

- `docs/assignments/keyboard-wake-diagnostic-v3-compatibility-gate-001.md`
- `docs/product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001-authorization.md`
- `docs/plans/keyboard-wake-diagnostic-event-schema-proposal-001.md`
- `docs/plans/keyboard-wake-diagnostic-v3-compatibility-gate-001-addendum.md`
- `docs/architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md`
- `docs/architecture/decisions/0036-v3-compatibility-gate-001-addendum.md`
- `docs/product-decisions/ADR-0036-ACCEPT-authorization.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-pre-edit-provenance-rebind-2026-09-29-r4.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-source-test-manifest-2026-09-29-r2.json`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-a-host-validation-2026-09-29.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-a-evidence-addendum-2026-09-29-r2.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-b-reservation-2026-09-29.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-b-run1-compilation-failure-2026-09-29.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-b-validation-2026-09-29.md`
- `docs/assignments/keyboard-wake-diagnostic-runtime-record-api-001.md`
- `docs/assignments/keyboard-wake-diagnostic-reader-implementation-001.md`
- `docs/assignments/keyboard-wake-diagnostic-main-app-consumer-001.md`
- `docs/assignments/keyboard-wake-diagnostic-extension-producer-001.md`
- `docs/assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalIngress.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift`
- `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift`
- `Universe Keyboard/Services/SchemaDeliveryDiagnostics.swift`
- `Universe Keyboard/Services/RimeSyncDiagnostics.swift`
- `Universe Keyboard/App/Universe_KeyboardApp.swift`
- `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift`

## Boundaries and exclusions

- Read-only review. Do not edit any source, test, Assignment, evidence, prior review, packet, or usage file. Return the complete proposed receipt and usage record for the Coordinator to record.
- Allowed operations: read only the allowlisted files and the candidate source diff; verify named SHA-256 identities; use bounded text search within the allowlist.
- Do not run tests, formatters, builds, Simulator/UI commands, installs, runtime reproduction, or network requests. Do not access another worktree.
- Do not make a Product/Architecture decision, authorize production marker emission, claim runtime/root cause, declare a Product/Quality Gate or Release, or publish/commit/push/merge/close the parent.
- If an identity mismatches or a required input is unavailable, report one precise locator, mark dependent claims uncovered, and stop that part. Do not expand the allowlist.

## Outputs and acceptance

Return:

1. `Pass`, `Pass with conditions`, `Partial / incomplete`, or `Block` for this exact candidate architecture review.
2. A direct answer to all seven review questions, with source and test pointers.
3. A complete-coverage statement; uncovered claims cannot receive Pass or Pass with conditions.
4. Every residual with stable ID, owner, disposition (`fix`, `accept`, or `tech_debt:<ID>`), and evidence pointer.
5. An explicit statement that this is not a Product decision, Quality Gate, runtime diagnosis, or Release conclusion.
6. Proposed receipt for `docs/reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r6-review.md` and usage record for `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r6-usage-2026-09-29.md`.

The positive acceptance condition is that the exact manifest-r2 candidate preserves the accepted v3/v4/v5 compatibility contract, current v5 production semantics, content-free data boundary, and producer-off scope, with all architecture claims covered.

## Budget, checkpoint, and stop rule

- Maximum budget: **8 tool calls or 8 active minutes, whichever occurs first**.
- Checkpoint after **4 calls or 4 active minutes**: record elapsed time, calls, coverage, and remaining work.
- On exhaustion, stop and return remaining coverage as `Partial / incomplete`; do not infer a pass.
- Stop on identity mismatch, missing frozen input, out-of-scope dependency, required new Product/Architecture decision, or inability to meet the read-only boundary.
- Only the Human Product Owner acting as Product Lead may approve exact scope or budget expansion. Any approved expansion needs a revised packet and new numbered round before work resumes.
