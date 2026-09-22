# Codex → Grok handoff: runtime-integration hardening blocker remediation

## Authority and role

- **Assignment:** [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001`](../assignments/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md).
- **Historical status:** this handoff was prepared for Grok. Before execution,
  Human Product Owner reassigned the still-unconsumed Authorization to current
  Codex task; see the Assignment’s executor-reassignment receipt. This
  document remains a precise implementation input, not an execution record.
- **This document:** created under a separate docs-only handoff receipt. It is
  not an execution receipt.

## Read first

1. Repository `AGENTS.md`, `docs/KNOWLEDGE_INDEX.md`, `docs/ACTIVE_WORK.md`,
   `docs/READING_MAPS.md`, the blocker Assignment and implementation
   Authorization above.
2. [`Blocker Architecture review`](../reviews/typo-correction-002-runtime-integration-hardening-architecture-review-2026-09-22.md).
3. `docs/architecture/input-pipeline-and-marked-text.md`,
   `docs/architecture/shared-container-and-rime-lifecycle.md`, ADR 0004 and
   `docs/architecture/swift6-migration.md`.

## Exact inputs and preservation boundary

| Item | Required value |
|---|---|
| Source review snapshot | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-integration-hardening-001/Universe Keyboard` |
| HEAD / tree | `4d1050f4b677494e06448cb40a83ef2da46d7b27` / `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Current tracked `git diff HEAD` observation | `7eb4b6714c27230c212ec9b7ad398b9dc419291c9aaf4303cdb12b4532a68d95` |
| Hardening delta from preserved implementation | `003c2e004764f96a83fa437262ac49e1b34952a13e523aa2ee9d7fe6d595a319` |
| Preserved implementation worktree | `/private/tmp/universe-keyboard-typo-correction-002-runtime-integration-implementation-001`; diff `d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b` |
| Pure-Core checkpoint | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-preflight-implementation-001/Universe Keyboard`; diff `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` |

Never modify either preserved worktree. Create a **new** isolated worktree at
the pinned HEAD. Before adding remediation edits, copy the following exact
predecessor snapshot paths byte-for-byte from the source review snapshot and
compare each target with its source. If any source file is absent or differs
after the copy, stop and report the identity failure.

1. `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`
2. `Keyboard/Controllers/KeyboardViewController+ModeActions.swift`
3. `Keyboard/Controllers/KeyboardViewController+TypoCorrection.swift`
4. `Keyboard/Controllers/KeyboardViewController.swift`
5. `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift`
6. `KeyboardTests/TypoCorrectionRecallRuntimeTests.swift`
7. `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift`
8. `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TypoCorrection.swift`
9. `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift`
10. `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift`
11. `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift`
12. `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift`
13. `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRuntimeIntegrationTests.swift`
14. `Packages/RimeBridge/Sources/RimeBridge/TypoCorrectionSidecarOwnerAdapters.swift`
15. `Packages/RimeBridge/Tests/RimeBridgeTests/TypoCorrectionSidecarOwnerAdapterTests.swift`
16. `docs/evidence/typo-correction-002-runtime-integration-implementation-001.md`

**Manifest correction:** before implementation Authorization consumption, the
read-only pre-copy check found the originally listed
`docs/evidence/typo-correction-002-runtime-integration-hardening-001.md`
absent from the source review snapshot. The path above exists there and is the
actual inherited predecessor evidence. This correction is recorded by
[`input-manifest correction AUTH`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-INPUT-MANIFEST-CORRECTION-001.md);
it is not a source edit or implementation-Authorization consumption.

Then independently reproduce the six-file hardening delta `003c2e00…` with
the review’s stable-label `diff -u` recipe before remediation edits. The
six-file order is: coordinator, view-controller typo correction, mode actions,
Core sidecar owner, Core controller typo correction, Core runtime-integration
test. Do not substitute a different aggregate hash recipe.

## Required changes

1. **Canary/P3D1 order:** invalidate the controller recall operation before
   responsive/thread-affine route flags or bootstrap state change.
2. **Yield ownership:** bind every RunLoop continuation to the scheduling
   operation/generation. A continuation that no longer matches must be a
   no-op; MainActor isolation alone is insufficient. Do not use `Task.detached`
   or create another query/commit route.
3. **Single writer/lifetime:** prevent legacy `state.typoCorrection` mutation
   for the whole controller-owned recall lifetime, including the timing before
   a fallback/default wrapper is installed. The result must not rely on a
   wrapper that might not yet exist.
4. **Three-route no-bypass:** prove, in the existing adapter surface, that
   default, MainActor-responsive and thread-affine routes each use the intended
   sidecar owner/facade without a raw-engine, second session or serial-owner
   bypass.

## Allowed implementation surface

Use only the eight source/test paths in the implementation Authorization,
plus the sixteen paths above **only for byte-identical predecessor bootstrap**.
An additional path requires a new Authorization supplement before editing.

## Required local verification

- `swift-format format` then strict lint for every changed Swift file.
- `swift test --package-path Packages/KeyboardCore`.
- RimeBridgeTests and App + Keyboard test targets with the repository’s strict
  Swift 6 / warnings-as-errors configuration and an explicitly recorded
  available Simulator destination.
- `git diff --check`.

If the ignored RimeBridge Vendor dependency is absent, do not fetch, update or
copy vendor bytes. Stop for a separate local-test-environment authorization.

## Hard stops and non-claims

Do not deploy/query RIME, use FakeCandidateProvider or old Ice as real RIME,
capture a Simulator/device, create a Run ID, run QA-001/INT-003/performance,
or commit/push/PR/merge. Do not change first-stage `12/8`, make `60/64`
always-on, alter diagnostics retention, touch host text/marked text/pasteboard,
or close any Gate/Assignment.

Your final handback must contain: new worktree/branch, pre-copy and
post-bootstrap identity checks, modified file inventory, each blocker’s source
disposition, actual verification output summary, residuals, and non-claims.
The next actor is a newly authorized independent Architecture reviewer, not
Quality.
