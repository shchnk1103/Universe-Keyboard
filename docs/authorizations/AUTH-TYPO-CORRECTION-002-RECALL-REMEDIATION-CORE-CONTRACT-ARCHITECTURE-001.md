# Authorization: AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-ARCHITECTURE-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Assignment | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001`](../assignments/typo-correction-002-recall-remediation-core-contract-001.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| Consumer | Independent Architecture reviewer |
| Purpose | Read-only Architecture review of the residual-remediation snapshot |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-ARCHITECTURE-001",
  "record_type": "authorization",
  "title": "Independent Architecture review of recall core contract remediation",
  "status": "consumed",
  "updated_at": "2026-09-20T10:55:00+08:00",
  "revalidation_triggers": [
    "review_snapshot_changed",
    "source_or_package_identity_changed",
    "scope_changed",
    "new_run_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "independent_architecture_review_recall_core_contract_remediation",
    "target": "TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001",
    "scope": "Read the exact pure KeyboardCore remediation source, focused tests, new evidence and prior review context. Verify the three residual fixes without expanding claims to runtime scheduler, RIME, device, performance or production.",
    "decision_source": "current task instruction: 按照建议继续进行下一步",
    "review_snapshot": {
      "worktree": "/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001",
      "branch": "codex/typo-correction-002-recall-preflight-001",
      "head": "d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "head_tree": "27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "manifest_sha256": "d1cad034c09af7af96549bab184e7151b186d0f212d1a2f9b347941e011df4e5",
      "manifest_rule": "sha256 lines for the eight listed artifacts, in listed order, concatenated with newlines and hashed with SHA-256",
      "artifacts": [
        "Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift",
        "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift",
        "Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift",
        "docs/evidence/typo-correction-002-recall-remediation-core-contract-001.md",
        "docs/assignments/typo-correction-002-recall-remediation-core-contract-001.md",
        "docs/product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-BOUNDED-DECISION-2026-09-20.md",
        "docs/reviews/typo-correction-002-recall-remediation-implementation-preflight-architecture-review-2026-09-20.md",
        "docs/reviews/typo-correction-002-recall-remediation-implementation-preflight-quality-review-2026-09-20.md"
      ]
    },
    "allowed_external_effects": [
      "read_only_source_test_and_evidence_review",
      "write_one_docs_only_architecture_review_record"
    ],
    "required_checks": [
      "preflight_default_is_fail_closed_substitution_only",
      "group_identity_is_stable_and_deduplicated_without_raw_input_logging",
      "batch_cap_is_independent_from_global_query_attempt_cap",
      "resolved_group_cap_is_independent_from_query_attempt_cap",
      "session_epoch_and_composition_revision_stale_result_fences_hold",
      "production_12_8_engine_controller_and_RIME_boundaries_are_unchanged",
      "remediation_evidence_and_non_claims_match_the_exact_snapshot"
    ],
    "required_bindings": [
      "HEAD d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "tree 27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "remediation manifest d1cad034c09af7af96549bab184e7151b186d0f212d1a2f9b347941e011df4e5",
      "no new Run ID",
      "no production wiring"
    ],
    "exclusions": [
      "Swift_or_ObjectiveC_change",
      "test_source_change",
      "production_budget_or_controller_change",
      "RimeBridge_or_RIME_deployment_or_query",
      "schema_or_vendor_change",
      "build_or_install",
      "Simulator_or_device_capture",
      "QA-001",
      "INT-003",
      "paired_performance_or_180_ms",
      "Quality_or_Product_or_Release_Gate",
      "commit_or_push",
      "PR_or_merge",
      "parent_or_child_close",
      "TestFlight_or_Release"
    ],
    "consumption_rule": "Bind the verdict to the exact remediation manifest, preserve residuals and non-claims, and do not convert a pure Core review into production acceptance.",
    "issuer_role": "Human Product Owner / Product Lead",
    "issued_at": "2026-09-20T10:55:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-20T10:55:00+08:00",
    "consumed_artifacts": [
      "head:d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "tree:27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "remediation-manifest:d1cad034c09af7af96549bab184e7151b186d0f212d1a2f9b347941e011df4e5"
    ]
  }
}
```

本授权只允许独立 Architecture review 文档，不授权修复、构建、设备、RIME、性能、
Quality/Product/Release Gate 或 publication。
