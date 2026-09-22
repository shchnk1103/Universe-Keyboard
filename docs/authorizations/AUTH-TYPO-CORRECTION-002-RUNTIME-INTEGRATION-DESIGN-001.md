# Authorization: AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` — bounded docs-only controller/sidecar runtime design recorded |
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001`](../assignments/typo-correction-002-runtime-integration-design-001.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-21 Asia/Shanghai` |
| Consumer | Current Codex task, Input Intelligence Maintainer |
| Exact baseline/tree | `4d1050f4b677494e06448cb40a83ef2da46d7b27` / `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Exact pure-Core checkpoint diff | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001",
  "record_type": "authorization",
  "title": "Bounded docs-only controller and sidecar runtime integration design",
  "status": "consumed",
  "updated_at": "2026-09-21T20:45:16+08:00",
  "revalidation_triggers": [
    "source_or_checkpoint_identity_changed",
    "design_scope_or_operation_contract_changed",
    "sidecar_or_privacy_boundary_changed",
    "architecture_review_result_changed",
    "runtime_or_RIME_action_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "design_controller_sidecar_second_stage_recall_runtime",
    "target": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001",
    "scope": "Read the exact pure-Core checkpoint and existing controller/RimeBridge/diagnostics paths, then write a docs-only runtime integration design specifying operation ownership, scheduling/fences/cancellation, bounded sidecar lifecycle, display-only merge and privacy-safe observability. No source or runtime action is permitted.",
    "allowed_paths": [
      "docs/assignments/typo-correction-002-runtime-integration-design-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001.md",
      "docs/plans/typo-correction-002-runtime-integration-design-2026-09-21.md",
      "docs/ACTIVE_WORK.md"
    ],
    "required_evidence": [
      "exact source baseline/tree and pure-Core checkpoint diff verification",
      "current controller/RimeBridge/diagnostics ownership inspection",
      "explicit operation, fence, cancellation, resource-bound, merge and privacy contracts",
      "future code/test/real-RIME/QA/performance authorization matrix and non-claims"
    ],
    "exclusions": [
      "Swift_or_project_change",
      "controller_or_RimeBridge_implementation",
      "RIME_query_or_deployment",
      "schema_or_vendor_change",
      "Simulator_or_device_capture",
      "new_Run_ID",
      "QA-001",
      "INT-003",
      "paired_performance_or_180_ms",
      "host_text_or_clipboard_or_candidate_content",
      "FakeCandidateProvider_or_old_Ice_or_model_evidence",
      "commit_or_push",
      "PR_or_merge",
      "TestFlight_or_Release",
      "Product_Quality_or_Release_Gate",
      "Assignment_close"
    ],
    "issuer_role": "Human Product Owner / Product Lead",
    "decision_source": "current task instruction: 授权按照建议继续进行下一步",
    "issued_at": "2026-09-21T20:37:44+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-21T20:45:16+08:00",
    "consumption_record": "docs/plans/typo-correction-002-runtime-integration-design-2026-09-21.md"
  }
}
```

Consumed immediately before the permitted design record write. It does not
authorize a runtime implementation.
