# Authorization: AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` — current Codex task started the new-worktree bootstrap |
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001`](../assignments/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md) |
| Issuer | Human Product Owner / Product Lead, `2026-09-22 Asia/Shanghai` |
| Consumer | Current Codex task (reassigned before consumption) |
| Source baseline / tree | `4d1050f4b677494e06448cb40a83ef2da46d7b27` / `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Required predecessor delta | `003c2e004764f96a83fa437262ac49e1b34952a13e523aa2ee9d7fe6d595a319`, independently reproduced before copy |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001",
  "record_type": "authorization",
  "title": "Codex-only controller-sidecar Architecture blocker remediation",
  "status": "consumed",
  "updated_at": "2026-09-22T10:58:00+08:00",
  "revalidation_triggers": [
    "source_or_preserved_checkpoint_identity_changed",
    "allowed_path_or_runtime_contract_changed",
    "Codex_executor_identity_changed",
    "runtime_or_publication_action_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "remediate_controller_sidecar_architecture_blockers",
    "target": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001",
    "scope": "In a new isolated worktree, first reproduce the byte-identical 16-path predecessor snapshot listed in the Grok handoff, then repair only the Architecture blockers recorded in the predecessor review: canary/P3D1 invalidate-first order, operation-bound yielded-continuation ownership, fallback unique writer/lifetime, and three-route adapter/no-bypass proof. Add focused tests and run the path-required local verification. Record execution evidence for a later independent Architecture review.",
    "allowed_paths": [
      "Keyboard/Controllers/KeyboardViewController+Bootstrap.swift",
      "Keyboard/Controllers/KeyboardViewController+ModeActions.swift",
      "Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift",
      "Keyboard/Controllers/KeyboardViewController+TypoCorrection.swift",
      "Keyboard/Controllers/KeyboardViewController.swift",
      "KeyboardTests/TypoCorrectionRecallRuntimeTests.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TypoCorrection.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift",
      "Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift",
      "Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRuntimeIntegrationTests.swift",
      "Packages/RimeBridge/Sources/RimeBridge/TypoCorrectionSidecarOwnerAdapters.swift",
      "Packages/RimeBridge/Tests/RimeBridgeTests/TypoCorrectionSidecarOwnerAdapterTests.swift",
      "docs/evidence/typo-correction-002-runtime-integration-implementation-001.md",
      "docs/evidence/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md",
      "docs/assignments/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001.md",
      "docs/ACTIVE_WORK.md"
    ],
    "required_evidence": [
      "new worktree identity and predecessor delta recipe verified before source edit",
      "preserved implementation and pure-Core checkpoint unchanged",
      "strict format/lint and path-required local tests with actual results",
      "source evidence for each blocker repair and explicit non-claims"
    ],
    "exclusions": [
      "unlisted_source_path",
      "RIME_query_or_deployment",
      "schema_or_vendor_change",
      "Simulator_or_device_capture",
      "new_Run_ID",
      "QA-001",
      "INT-003",
      "paired_performance_or_180_ms",
      "commit_or_push",
      "PR_or_merge",
      "TestFlight_or_Release",
      "Product_Quality_or_Release_Gate",
      "Assignment_close"
    ],
    "issuer_role": "Human Product Owner / Product Lead",
    "decision_source": "current task instruction: 授权按照你的建议继续进行下一步",
    "issued_at": "2026-09-22T10:20:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-22T10:58:00+08:00",
    "consumed_by": "Current Codex task",
    "consumption_record": "docs/evidence/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md"
  }
}
```

The Consumer was reassigned from Grok before consumption by
[`executor reassignment AUTH`](AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-EXECUTOR-REASSIGNMENT-001.md).
Its bootstrap evidence path was corrected before consumption by
[`input-manifest correction AUTH`](AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-INPUT-MANIFEST-CORRECTION-001.md).
This receipt was consumed only for the bounded local source-remediation slice.
It does not authorize any external or publication action.
