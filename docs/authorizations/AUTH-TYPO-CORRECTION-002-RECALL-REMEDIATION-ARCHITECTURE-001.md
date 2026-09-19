# Authorization: AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-ARCHITECTURE-001

## Current Status

| Field | Value |
|---|---|
| **Status** | `active` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-001`](../assignments/typo-correction-002-recall-remediation-001.md) |
| **Issuer** | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| **Consumer** | Independent Architecture reviewer |
| **Purpose** | Read-only review of the bounded coverage-aware second-stage recall design and its explicit UNKNOWN fields |
| **Exact review tip** | `15887247040fd2dcef43a906b14525f6f48d71ef` |
| **Source implementation freeze** | `fb27b24ff85c48302e85309e834dbbe9a777871e` |
| **Origin context** | `origin/main` at `162b09fd58ba60538a944026b1902efa405c75aa` |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-ARCHITECTURE-001",
  "record_type": "authorization",
  "title": "Independent Architecture review of bounded recall design",
  "status": "active",
  "updated_at": "2026-09-19T22:38:14+08:00",
  "revalidation_triggers": [
    "review_tip_changed",
    "source_baseline_changed",
    "origin_main_changed",
    "scope_changed",
    "new_run_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "independent_architecture_read_only_review",
    "target_assignment": "TYPO-CORRECTION-002-RECALL-REMEDIATION-001",
    "review_inputs": [
      "docs/plans/typo-correction-002-recall-remediation-design-2026-09-19.md",
      "docs/evidence/typo-correction-002-recall-coverage-matrix-2026-09-19.md",
      "docs/evidence/typo-correction-002-file-provenance-audit-2026-09-19.md",
      "Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TypoCorrection.swift"
    ],
    "allowed_external_effects": [
      "read_only_source_review",
      "docs_only_architecture_review_record"
    ],
    "required_bindings": [
      "review tip 15887247040fd2dcef43a906b14525f6f48d71ef",
      "source implementation freeze fb27b24ff85c48302e85309e834dbbe9a777871e",
      "no new Run ID",
      "no production implementation"
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
      "RIME_deployment_or_query",
      "F-01_lane",
      "INT-003",
      "QA-001",
      "paired_performance",
      "Product_or_Quality_Gate",
      "PR",
      "merge",
      "parent_close",
      "Release",
      "commit_or_push_by_reviewer"
    ],
    "consumption_rule": "The reviewer must bind the verdict to the exact review tip, preserve UNKNOWN and non-claims, and consume this authorization only after the review record is complete. Any source, scope or evidence change invalidates this authorization."
  }
}
```

## Required review questions

1. Does the proposed coverage-aware second-stage recall pass preserve the
   separation between pure recall, real-RIME sidecar querying and Product
   candidate acceptance?
2. Are the production `12/8` contract, preflight `60/64/8` contract, query
   limit `3` and resolved-group limit `4` kept distinct rather than silently
   multiplied into a runtime promise?
3. Does the matrix correctly retain `UNKNOWN` for production frontier rank and
   the smallest admitting expansion, instead of treating preflight rank `55`
   as production proof?
4. Are privacy, cancellation, marked-text ownership and hot-path constraints
   sufficient for a later implementation Authorization?

## Non-claims

This review is not a Product decision, Quality Gate, implementation approval,
performance result, QA-001 result, INT-003 result, RIME result, PR approval,
merge approval or parent Assignment closure. A later implementation requires a
new Authorization with a new source/package identity and focused tests.
