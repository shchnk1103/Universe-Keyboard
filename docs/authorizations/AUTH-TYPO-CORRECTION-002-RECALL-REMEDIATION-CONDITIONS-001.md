# Authorization: AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CONDITIONS-001

## Current Status

| Field | Value |
|---|---|
| **Status** | `active` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-001`](../assignments/typo-correction-002-recall-remediation-001.md) |
| **Issuer** | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| **Consumer** | Current Codex Executor, docs-only |
| **Purpose** | Reconcile Architecture conditions B1–B3 before any implementation Authorization |
| **Review input** | [`Independent Architecture review`](../reviews/typo-correction-002-recall-remediation-architecture-review-2026-09-20.md) |
| **Source implementation freeze** | `fb27b24ff85c48302e85309e834dbbe9a777871e` |
| **Current docs tip at issuance** | `c38578231baa05cf76821e0db5c4bd7d68b3acfb` |
| **Origin context** | `origin/main` at `162b09fd58ba60538a944026b1902efa405c75aa` |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CONDITIONS-001",
  "record_type": "authorization",
  "title": "Docs-only reconciliation of bounded recall Architecture conditions",
  "status": "active",
  "updated_at": "2026-09-20T08:33:52+08:00",
  "revalidation_triggers": [
    "source_baseline_changed",
    "origin_main_changed",
    "scope_changed",
    "new_run_requested",
    "implementation_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "docs_only_reconcile_recall_architecture_conditions",
    "target_assignment": "TYPO-CORRECTION-002-RECALL-REMEDIATION-001",
    "allowed_external_effects": [
      "update_design_note",
      "update_coverage_matrix",
      "update_assignment_and_index",
      "docs_only_commit",
      "push_feature_branch"
    ],
    "required_conditions": [
      "separate_N_generated_N_query_attempts_N_resolved_groups_N_candidates_returned",
      "define_total_maxQueryAttempts_as_a_required_future_binding_without_inventing_a_runtime_value",
      "define_batch_and_per_query_cancellation_revision_epoch_and_publish_fences",
      "retain_7_8_contextual_boundary_as_UNKNOWN_unless_exact_evidence_exists",
      "record_substitution_only_as_the_recommended_first_implementation_slice",
      "keep_production_12_8_unchanged_and_preflight_60_64_8_default_off"
    ],
    "exclusions": [
      "Swift_or_ObjectiveC_change",
      "test_source_change",
      "production_budget_change",
      "production_controller_or_UI_wiring",
      "local_or_cloud_model",
      "schema_or_vendor_change",
      "build",
      "install",
      "Simulator_or_device_capture",
      "new_Run_ID",
      "RIME_deployment_or_query",
      "F-01_lane",
      "INT-003",
      "QA-001",
      "paired_performance",
      "Product_or_Quality_Gate",
      "PR",
      "merge",
      "parent_close",
      "Release"
    ],
    "consumption_rule": "Consume only after the condition reconciliation is written, linked, checked and pushed. A fresh independent Architecture re-review requires a new Authorization."
  }
}
```

## Non-claims

This Authorization does not authorize implementation, a numeric production
budget, a runtime query schedule, a performance claim, a real-RIME result, a
QA-001 result, a Product decision or closure of any parent/child Assignment.
