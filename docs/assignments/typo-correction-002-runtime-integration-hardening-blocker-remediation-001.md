# Assignment: TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001 — Architecture blocker remediation

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001",
  "record_type": "assignment",
  "title": "Repair controller-sidecar Architecture blockers before Quality review",
  "lifecycle": "reviewed",
  "current_phase": "Product accepted bounded Architecture/Quality residuals for the exact uncommitted snapshot; child is Reviewed while parent remains Active; no commit/publication/Close",
  "authorization_action": "remediate_controller_sidecar_architecture_blockers",
  "updated_at": "2026-09-22T15:20:00+08:00",
  "revalidation_triggers": [
    "review_snapshot_or_preservation_identity_changed",
    "operation_lifecycle_or_adapter_owner_contract_changed",
    "allowed_path_or_test_scope_changed",
    "runtime_capture_or_publication_requested",
    "executor_or_authority_changed"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-HANDOFF-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-EXECUTOR-REASSIGNMENT-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-INPUT-MANIFEST-CORRECTION-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-LOCAL-TEST-ENVIRONMENT-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-ARCHITECTURE-REVIEW-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-ARCHITECTURE-REVIEW-002",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-ARCHITECTURE-RECONCILE-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-QUALITY-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PRODUCT-RESIDUAL-001"
  ],
  "parent_refs": [
    "TYPO-CORRECTION-002",
    "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001",
    "PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Current Codex task",
    "environment_executor": "Current Codex task in a new isolated local worktree with local Swift format and required test toolchain only",
    "human_dependency": "Not Applicable — current Human Product Owner instruction explicitly authorizes current Codex task to start the active Authorization after entry checks; later Architecture and Quality reviews require separate Authorizations",
    "architecture_reviewer": "Independent Architecture and Knowledge Steward",
    "quality_reviewer": "Independent Quality, Performance and Release Maintainer",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Reviewed` |
| **Phase** | Product accepted the bounded [`residual decision`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-RESIDUAL-001.md). Architecture F-01/F-02/F-03 remain Closed; Quality remains `Pass with conditions`; detached / dual-gate / CandidateProvider residuals remain explicit. |
| **Next** | Preserve this uncommitted checkpoint. Any commit/push/PR needs a new AUTH plus branch-identity disposition. Parent QA-001/INT-003/capture/performance lanes need their own Assignment/Authorization and explicitly named reviewers. |
| **Non-claims** | No real RIME, capture, QA-001, INT-003, performance, commit, publication, Gate or Close. |

## Authority and inputs

- **Decision:** [`PD blocker remediation`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001.md).
- **Predecessor:** [`hardening Assignment`](typo-correction-002-runtime-integration-hardening-001.md) remains `Active` / blocked at Architecture.
- **Blocking review:** [`Architecture review`](../reviews/typo-correction-002-runtime-integration-hardening-architecture-review-2026-09-22.md).
- **Historical Grok handoff:** [`Codex → Grok handoff`](../evidence/typo-correction-002-codex-to-grok-runtime-integration-hardening-blocker-remediation-handoff-2026-09-22.md) (retained input; not an execution record).
- **Executor reassignment:** [`reassignment AUTH`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-EXECUTOR-REASSIGNMENT-001.md).
- **Input-manifest correction:** [`correction AUTH`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-INPUT-MANIFEST-CORRECTION-001.md).
- **Exact source:** retain the review worktree snapshot and independently verify
  HEAD/tree and the `003c2e00…` hardening-delta recipe before copying it into a
  new worktree.
- **Preservation boundary:** never modify the original implementation worktree
  or pure-Core checkpoint named in the Product Decision.

## Scope

After the matching Authorization is explicitly started, current Codex task may first copy the
byte-identical 16-path predecessor snapshot listed in the handoff into a new
worktree, then may only:

1. Repair canary/P3D1 invalidation ordering in
   `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`.
2. Add operation-bound yielded-callback fencing in
   `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift`, without
   `Task.detached`, a second query loop or altered first-stage budgets.
3. Make controller-owned recall lifetime authoritative across fallback/default
   wrapper timing in the existing controller/Core sidecar paths.
4. Close the default, MainActor-responsive and thread-affine adapter/no-bypass
   contract only in the existing RimeBridge sidecar-adapter surface.
5. Add focused tests for the three repaired conditions and run only the
   path-required local checks.

## Allowed source paths

- `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`
- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift`
- `Keyboard/Controllers/KeyboardViewController+TypoCorrection.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TypoCorrection.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRuntimeIntegrationTests.swift`
- `Packages/RimeBridge/Sources/RimeBridge/TypoCorrectionSidecarOwnerAdapters.swift`
- `Packages/RimeBridge/Tests/RimeBridgeTests/TypoCorrectionSidecarOwnerAdapterTests.swift`

Any other source or test path requires a new, explicit supplement before edit.

## Non-goals and stop conditions

- Do not modify production `12/8`, make `60/64` always-on, add a second
  RIME/session/query route, add host-commit/marked-text/pasteboard behavior,
  or change diagnostics/privacy retention.
- Do not use FakeCandidateProvider or old Ice material as real-RIME evidence.
- Do not capture, deploy, create a Run ID, run QA-001/INT-003/performance,
  commit, push, open a PR, merge, publish, close a Gate or close any Assignment.
- Stop if an unlisted path is needed, the preserved identities drift, a real
  RIME/device action becomes necessary, or a test failure exceeds this scope.

## Exit and handoff

- Changed Swift files must pass strict format/lint; required tests report their
  actual outcome without conflation with runtime evidence.
- Execution evidence must name the exact new snapshot, source inventory,
  callback-generation contract, invalidation order and three-route adapter
  proof, plus non-claims.
- Handoff target: a **new independent Architecture review** of the new exact
  snapshot. Quality remains blocked until that review passes.
