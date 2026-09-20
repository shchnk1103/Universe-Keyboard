# Authorization: AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-PRODUCT-DECISION-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Assignment | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001`](../assignments/typo-correction-002-recall-remediation-core-contract-001.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| Consumer | Current Codex task, docs-only Product decision recorder |
| Purpose | Record bounded Product disposition after the remediation Architecture and Quality reviews |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-PRODUCT-DECISION-001",
  "record_type": "authorization",
  "title": "Bounded Product decision for recall core contract remediation",
  "status": "consumed",
  "updated_at": "2026-09-20T11:20:00+08:00",
  "revalidation_triggers": [
    "source_or_package_identity_changed",
    "review_snapshot_changed",
    "runtime_wiring_requested",
    "publication_requested",
    "scope_changed",
    "authority_revoked"
  ],
  "authorization": {
    "action": "record_bounded_product_decision_recall_core_contract_remediation",
    "target": "TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001",
    "scope": "Accept or reject only the pure KeyboardCore residual remediation after independent Architecture and Quality review. Preserve the open runtime group mapping residual and all non-claims.",
    "decision_source": "current task instruction: 按照建议继续进行下一步",
    "review_snapshot": {
      "worktree": "/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001",
      "branch": "codex/typo-correction-002-recall-preflight-001",
      "head": "d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "head_tree": "27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "manifest_sha256": "cc030bc0b53282f5d5b0b76928c34fc617604bd8985c8f289bca627ba58fd97d",
      "manifest_rule": "sha256 lines for the eight listed artifacts, in listed order, concatenated with newlines and hashed with SHA-256",
      "artifacts": [
        "Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift",
        "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift",
        "Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift",
        "docs/evidence/typo-correction-002-recall-remediation-core-contract-001.md",
        "docs/assignments/typo-correction-002-recall-remediation-core-contract-001.md",
        "docs/reviews/typo-correction-002-recall-remediation-core-contract-architecture-review-2026-09-20.md",
        "docs/reviews/typo-correction-002-recall-remediation-core-contract-quality-review-2026-09-20.md",
        "docs/product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-BOUNDED-DECISION-2026-09-20.md"
      ]
    },
    "allowed_external_effects": [
      "write_one_docs_only_product_decision",
      "update_core_contract_assignment_status_only"
    ],
    "required_bindings": [
      "Architecture verdict Pass with conditions",
      "Quality verdict Pass with conditions",
      "pure Core tests recorded as executor evidence",
      "runtime group mapping remains an explicit P1 residual",
      "no new Run ID"
    ],
    "exclusions": [
      "Swift_or_ObjectiveC_change",
      "test_source_change",
      "production_budget_or_controller_change",
      "runtime_scheduler_wiring",
      "RimeBridge_or_RIME_deployment_or_query",
      "schema_or_vendor_change",
      "Simulator_or_device_capture",
      "QA-001",
      "INT-003",
      "paired_performance_or_180_ms",
      "commit_or_push",
      "PR_or_merge",
      "parent_or_child_close",
      "Product_Gate",
      "Quality_Gate",
      "Release_Gate",
      "TestFlight_or_Release"
    ],
    "consumption_rule": "Record the bounded disposition against the exact manifest. Any publication, runtime wiring or wider claim needs a separate Authorization and changed-snapshot review.",
    "issuer_role": "Human Product Owner / Product Lead",
    "issued_at": "2026-09-20T11:20:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-20T11:20:00+08:00",
    "consumed_artifacts": [
      "head:d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "tree:27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "product-manifest:cc030bc0b53282f5d5b0b76928c34fc617604bd8985c8f289bca627ba58fd97d",
      "architecture:Pass with conditions",
      "quality:Pass with conditions"
    ]
  }
}
```

本授权只覆盖 Product bounded decision，不授权 runtime implementation、publication、
commit/push/PR/merge、设备/性能证据或任何 Gate Close。
