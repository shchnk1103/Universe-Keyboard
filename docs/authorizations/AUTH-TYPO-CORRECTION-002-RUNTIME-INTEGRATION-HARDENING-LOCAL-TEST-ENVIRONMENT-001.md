# Authorization: AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-LOCAL-TEST-ENVIRONMENT-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` — test-only local dependency link recorded before use |
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001`](../assignments/typo-correction-002-runtime-integration-hardening-001.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-22 Asia/Shanghai` |
| Consumer | Current Codex task only |
| Relation | Supplements the source-hardening receipt only to make its existing local test dependencies resolvable |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-LOCAL-TEST-ENVIRONMENT-001",
  "record_type": "authorization",
  "title": "Test-only local RIME Vendor dependency link for hardening verification",
  "status": "consumed",
  "updated_at": "2026-09-22T09:39:00+08:00",
  "revalidation_triggers": [
    "linked_vendor_inventory_or_source_changed",
    "test_scope_or_result_changed",
    "runtime_capture_or_publication_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "prepare_local_test_dependency_environment",
    "target": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001",
    "scope": "In the isolated hardening worktree only, create a temporary ignored symbolic link at Packages/RimeBridge/Vendor to the already present Vendor directory in the preserved implementation worktree, after verifying its structural inventory. Use it only for local xcodebuild test/build resolution. The link is not a vendor fetch, schema/deployment action, fixture, source change or product-RIME evidence.",
    "activation_gate": "Verify the preserved worktree Vendor inventory and its pinned tracked-diff identity before linking; do not copy, modify, fetch or deploy the vendor contents.",
    "artifact_bindings": [
      {"kind": "preserved_implementation_tracked_diff_sha256", "identity": "d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b"},
      {"kind": "vendor_inventory", "identity": "12 structural RIME framework artifacts verified by scripts/ensure_rime_vendor.sh verify"}
    ],
    "allowed_paths": [
      "Packages/RimeBridge/Vendor (ignored symbolic link in isolated hardening worktree only)",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-LOCAL-TEST-ENVIRONMENT-001.md",
      "docs/assignments/typo-correction-002-runtime-integration-hardening-001.md",
      "docs/evidence/typo-correction-002-runtime-integration-hardening-001.md",
      "docs/ACTIVE_WORK.md"
    ],
    "path_constraints": [
      "The link target must be the preserved implementation worktree's existing Vendor directory and must not be edited.",
      "No network fetch, archive/schema deployment, App Group mutation, simulator/device installation or RIME query is permitted.",
      "The ignored link is not part of a commit, manifest, release artifact or product evidence claim."
    ],
    "required_evidence": [
      "source and Vendor inventory identity before link creation",
      "local target test/build results or exact blocked result",
      "explicit statement that no deployment, capture or real-RIME claim occurred"
    ],
    "exclusions": [
      "vendor_fetch_or_update",
      "RIME_schema_or_deployment_change",
      "real_RIME_query_or_product_candidate_proof",
      "Simulator_or_device_capture",
      "new_Run_ID",
      "QA-001",
      "INT-003",
      "paired_performance_or_180_ms",
      "commit_or_push",
      "PR_or_merge",
      "Product_Quality_or_Release_Gate",
      "parent_or_child_Assignment_close"
    ],
    "stop_conditions": [
      "the link target inventory or source identity does not match",
      "a test requires vendor modification, download, deployment, runtime capture or a Run ID",
      "the link would be included in source publication"
    ],
    "issuer_role": "Human Product Owner / Product Lead",
    "decision_source": "current task instruction: 授权由你来按照你的建议继续进行下一步; source hardening receipt excludes vendor mutation but requires path-appropriate local tests",
    "issued_at": "2026-09-22T09:39:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-22T09:39:00+08:00",
    "consumed_by": "Current Codex task",
    "consumption_record": "docs/evidence/typo-correction-002-runtime-integration-hardening-001.md"
  }
}
```

The linked directory stays ignored and test-only. It does not alter the
preserved source worktree, the vendor bytes, or the scope of product evidence.
