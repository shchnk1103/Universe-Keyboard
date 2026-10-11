# Authorization: AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Assignment | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001`](../assignments/typo-correction-002-recall-remediation-core-contract-001.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| Consumer | Current Codex Executor, bounded pure KeyboardCore residual remediation |
| Purpose | Fix the three accepted Architecture residuals before any production/publication decision |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001",
  "record_type": "authorization",
  "title": "Bounded pure KeyboardCore recall contract residual remediation",
  "status": "consumed",
  "updated_at": "2026-09-20T10:36:00+08:00",
  "revalidation_triggers": [
    "source_or_package_identity_changed",
    "origin_main_changed",
    "scope_changed",
    "production_wiring_requested",
    "new_run_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "execute_bounded_keyboardcore_recall_contract_residual_remediation",
    "target": "TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001",
    "scope": "Modify only the pure KeyboardCore preflight policy/ledger contract and its focused tests; add the corresponding docs-only evidence and Assignment status. Keep production engine/controller behavior unchanged.",
    "decision_source": "Product bounded decision PD-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-BOUNDED-2026-09-20",
    "source_snapshot": {
      "worktree": "/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001",
      "branch": "codex/typo-correction-002-recall-preflight-001",
      "head": "d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "head_tree": "27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "package_swift_git_blob_id": "1a06a522f12089f3dbb2ad774d13fe9f56193d04",
      "package_swift_sha256": "9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764",
      "contextual_typo_correction_sha256": "b54478969c127b17450a2504a3c3ffa5ed43a8ff1614aa18a826873ede1a21a3",
      "preflight_source_sha256": "9a4eae729c28cc30ecc819de270e082b2a2f2d2c75fd06e67fce8d2288f7dab9",
      "preflight_tests_sha256": "4f71cd924d4463c674fafd0320a4b86ed80d5d49c08a4ad781d0afe88df28d7f",
      "product_decision_sha256": "fcdf456454bc0b063dc5e278c9c447e59cd99290e385818bf5a8d2eeb064e610"
    },
    "allowed_paths": [
      "Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift",
      "Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift",
      "docs/assignments/typo-correction-002-recall-remediation-core-contract-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001.md",
      "docs/evidence/typo-correction-002-recall-remediation-core-contract-001.md"
    ],
    "allowed_external_effects": [
      "modify_pure_keyboardcore_preflight_code_only",
      "modify_keyboardcore_focused_tests_only",
      "run_swift_format_lint",
      "run_local_keyboardcore_tests_with_writable_temp_cache",
      "write_docs_only_evidence_and_assignment_status"
    ],
    "required_changes": [
      "preflight_default_is_fail_closed_substitution_only",
      "resolved_group_identity_is_explicit_and_deduplicated",
      "focused_batch_cap_resolved_group_cap_and_session_epoch_tests_are_independent"
    ],
    "exclusions": [
      "production_12_8_budget_change",
      "production_controller_or_keyboard_extension_wiring",
      "RimeBridge_or_RIME_deployment_or_query",
      "schema_or_vendor_change",
      "local_or_cloud_model",
      "host_text_or_document_context",
      "clipboard_or_network",
      "FakeCandidateProvider_or_old_Ice_directory",
      "Simulator_or_device_capture",
      "new_Run_ID",
      "QA-001",
      "INT-003",
      "paired_performance_or_180_ms",
      "Product_or_Quality_or_Release_Gate",
      "commit_or_push",
      "PR_or_merge",
      "TestFlight_or_Release",
      "parent_or_preflight_assignment_close"
    ],
    "consumption_rule": "Consume before the first code change. Bind all results to this exact source/package snapshot. Any production path, source identity, budget, evidence or scope change invalidates this Authorization and requires a new one.",
    "issuer_role": "Human Product Owner / Product Lead",
    "issued_at": "2026-09-20T10:34:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-20T10:36:00+08:00",
    "consumed_artifacts": [
      "head:d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "tree:27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "Package.swift:sha256:9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764",
      "preflight-source:sha256:b54478969c127b17450a2504a3c3ffa5ed43a8ff1614aa18a826873ede1a21a3",
      "preflight-ledger:sha256:9a4eae729c28cc30ecc819de270e082b2a2f2d2c75fd06e67fce8d2288f7dab9",
      "preflight-tests:sha256:4f71cd924d4463c674fafd0320a4b86ed80d5d49c08a4ad781d0afe88df28d7f"
    ]
  }
}
```

本授权是实现前置的 bounded remediation，不是 production implementation 或 publication
授权；完成后必须重新进行独立 Architecture/Quality review。
