# Architecture review packet — Entry identity freeze — Wire-Version Reconciliation 001 — Round 3

## Frozen identity

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001`
- Stable lane: `KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001/architecture`
- Round: `3` (new frozen packet after R2 stopped on an ambiguous locator; no R2 scope or budget is reused)
- Reviewer role: independent Architecture & Knowledge Steward; not the Assignment Executor.
- Baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`.
- Current Assignment SHA-256: `d43baef8e0f06e34b623cf43222ee887b0c05ea6c3cc9931ee657cf57a68660d`.
- Reviewed scope SHA-256 before status-only writeback: `edf450b3dbfbe621849d0fbf6bc641518cbc22e992fde6239034d05d2e7729c6`.
- Establishment authorization SHA-256: `2870e8d75abf66142ea86d2dfc4ba719e24654e837bb12e0a7f1c176052f8afe`.
- **Entry identity packet exact path:** `docs/evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-entry-identity-2026-09-30.md`.
- Entry identity packet SHA-256: `3a0a27291fe653daf02191622fa1392522d17b648bd5cdf74e5f13155000179b`.
- Scope prerequisite identities: `docs/evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-scope-ack-2026-09-30.md` SHA `afa6375bf802d18889c917cbcd200f80eb429929eb688b49f3273d7808595cf4`; `docs/reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-architecture-r1-review.md` SHA `b2f1ee644ab0e48ec45693574f301907d5ace96f74195262aa3521d425245e48`; `docs/reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-quality-r1-review.md` SHA `1c0ab4ca1d50e80c048aceff2d6292f0ee189dcdf580b5938f73303f327f5889`.
- Packet digest: coordinator computes SHA-256 after freeze and records it in the review and usage receipts.

## Claims and questions

Review whether this exact Entry identity packet is accurate and complete enough to satisfy the identity-freeze portion of Entry without starting substantive schema analysis:

1. Does it enumerate every Required Input in the current Assignment, plus the exact relevant current source/test paths needed for later document-only analysis?
2. Do all 21 document hashes and statuses, all 17 current source/test hashes and statuses, and all source baseline hashes match? Does v3 manifest r2 match all seven current bytes?
3. Does the packet clearly distinguish the pinned base, current uncommitted local candidate, clean-at-base Extension paths, and archived Runtime API predecessor without implying cross-candidate integration or accepted behavior?
4. Is `ENTRY-ID-DRIFT-01` accurately reported and bounded? The frozen pre-edit receipt has a one-character different hash for `DiagnosticEventTests.swift`; the direct worktree hash and v3 r2 manifest agree. Can the bad historical cell be excluded while retaining the correct direct identity, or does this prevent Ready until a separate owner corrects/rebinds the record?
5. Is the absent historical `DiagnosticsJournalV4WriterTests.swift` path correctly excluded from the current input set, because only its old manifest is Required Input?
6. Is any Required Input, owner decision, or path missing such that the identity packet cannot be accepted? Record residual IDs, owners, disposition, and evidence pointers.

## Exact allowlist

Read the Entry identity packet **in full** at the exact path and SHA above. That packet contains the expected SHA/status/baseline values for the following 21 documents and 17 source/test files. Recompute hashes and scoped Git status only; do not inspect content except where explicitly allowed below.

### Required documents

- `docs/assignments/keyboard-wake-diagnostic-wire-version-reconciliation-001.md`
- `docs/product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001-authorization.md`
- `docs/plans/keyboard-wake-diagnostic-event-schema-proposal-001.md`
- `docs/architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md`
- `docs/product-decisions/ADR-0036-ACCEPT-authorization.md`
- `docs/plans/keyboard-wake-diagnostic-extension-writer-version-reconciliation-001.md`
- `docs/assignments/keyboard-wake-diagnostic-v3-compatibility-gate-001.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-source-test-manifest-2026-09-29-r2.json`
- `docs/assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md`
- `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-pre-edit-entry-2026-09-30.md`
- `docs/assignments/keyboard-wake-diagnostic-runtime-record-api-001.md`
- `docs/evidence/keyboard-wake-diagnostic-runtime-record-api-001-source-test-manifest-2026-09-29.json`
- `docs/assignments/keyboard-wake-lifecycle-diagnostics-001.md`
- `docs/ASSIGNMENT_POLICY.md`
- `docs/VIRTUAL_ENGINEERING_TEAM.md`
- `docs/AI_WORKFLOW.md`
- `docs/architecture/decisions/0027-enterprise-local-diagnostic-observability.md`
- `docs/playbooks/keyboard-core.md`
- `docs/playbooks/keyboard-ui.md`
- `docs/playbooks/main-app-ui.md`
- `docs/playbooks/test-release.md`
- `docs/evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-scope-ack-2026-09-30.md`
- `docs/reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-architecture-r1-review.md`
- `docs/reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-quality-r1-review.md`

### Current source/test paths — hashes only

- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift`
- `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift`
- `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift`
- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift`
- `Keyboard/Controllers/KeyboardViewController.swift`
- `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`
- `Keyboard/Services/UITextDocumentProxyAdapter.swift`
- `KeyboardTests/ResponsiveRimeCanaryLifecycleTests.swift`
- `KeyboardTests/TypoCorrectionRecallRuntimeTests.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalIngress.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalIngressTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalRuntimeTests.swift`

### Limited content reads

- Read the current Assignment's `Required Inputs` list to verify exact coverage.
- Read the seven path/hash entries of v3 manifest r2; do not inspect source/test content.
- Read only the one `DiagnosticEventTests.swift` hash row in the paired-rollout pre-edit Entry receipt to confirm the noted typo.
- Read the Identity packet and its tables to compare all recorded expected values.

Permitted operations: verify the fixed Assignment/auth/ACK/review/identity-packet hashes; hash the 21 documents, three named scope-review prerequisite records, and 17 source/test paths; `git status --short -- <listed path>` for those paths only; compute source/test baseline SHA-256 via the pinned commit; check existence of the single historical-only test path named in the identity packet. No broad repository status, diff, or file discovery.

Excluded: all other files/worktrees, all source/test content reads or output, source semantics, protocol analysis, builds, tests, formatters, Simulator/CoreDevice/UI, installation, network, file edits, behavior/root-cause conclusions.

## Required output and acceptance

Return `Pass`, `Pass with conditions`, `Revise`, or `Block`; verify packet, Assignment, authorization, ACK/review and Entry identity hashes; answer all six questions; report coverage; give each residual an ID, owner, disposition and pointer. `Pass with conditions` requires complete review coverage and a dispositioned residual; otherwise use `Revise` or `Block`.

The coordinator records the result at `docs/reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-architecture-r3-entry-review.md` and usage at `docs/evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-architecture-r3-usage-2026-09-30.md`.

## Budget and stop rule

- Maximum 6 reviewer tool interactions or 8 active minutes, whichever occurs first.
- Send checkpoint after interaction 3 or 4 active minutes; the checkpoint counts toward the limit.
- If a frozen identity/path is missing, mismatches, requires out-of-scope access, or the budget is exhausted, stop affected claims and report `Block` or `Partial / incomplete`; do not inspect outside this packet.
- Only the Human Product Owner / Product Lead may authorize additional inputs, out-of-scope record correction, or a changed Assignment boundary.
