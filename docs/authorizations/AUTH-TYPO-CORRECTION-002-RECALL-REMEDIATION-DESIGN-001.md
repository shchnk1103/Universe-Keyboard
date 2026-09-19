# Authorization: AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DESIGN-001

## Current Status

| Field | Value |
|---|---|
| **Status** | `active` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-001`](../assignments/typo-correction-002-recall-remediation-001.md) |
| **Issuer** | Product Lead / Human Product Owner, current Codex task, `2026-09-19 Asia/Shanghai` |
| **Consumer** | Current Codex Executor |
| **Purpose** | Establish a provenance-first, read-only recall design before any production implementation is considered. |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DESIGN-001",
  "record_type": "authorization",
  "title": "Read-only bounded recall-remediation design",
  "status": "active",
  "updated_at": "2026-09-19T22:30:00+08:00",
  "revalidation_triggers": [
    "worktree_content_changed",
    "source_baseline_changed",
    "origin_main_changed",
    "scope_changed",
    "new_run_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "read_only_recall_coverage_audit_and_design",
    "target_assignment": "TYPO-CORRECTION-002-RECALL-REMEDIATION-001",
    "allowed_external_effects": [
      "docs_only_commit",
      "push_feature_branch"
    ],
    "required_bindings": [
      "clean worktree HEAD 5d55ce981adc4ef5a34046292a6edbc727db280b",
      "source implementation freeze fb27b24ff85c48302e85309e834dbbe9a777871e",
      "origin/main 162b09fd58ba60538a944026b1902efa405c75aa",
      "no new Run ID"
    ],
    "exclusions": [
      "Swift_or_ObjectiveC_change",
      "production_recall_change",
      "schema_or_vendor_change",
      "local_or_cloud_model",
      "build",
      "install",
      "Simulator_or_device_capture",
      "RIME_deployment",
      "F-01_lane",
      "PR",
      "merge",
      "parent_close",
      "Product/Quality/Release Gate",
      "TestFlight",
      "Release"
    ],
    "consumption_rule": "Consume only after the audit/design docs are staged, links and lightweight checks pass, and the docs-only commit is pushed.",
    "issuer_role": "Human Product Owner / Product Lead",
    "issued_at": "2026-09-19T22:30:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "active"
  }
}
```

## Boundary

This Authorization does not authorize changing the production 12/8 budget or
wiring the 60/64/8 preflight into production. It does not authorize any new
Simulator/device evidence. A later implementation Authorization must bind a
new source/package identity and its own focused tests before code is written.
