# Authorization: AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLISH-001

| Field | Value |
|---|---|
| Status | `consumed` — local CI and final manifest preparation started |
| Target Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLICATION-001`](../assignments/typo-correction-002-runtime-integration-hardening-blocker-remediation-publication-001.md) |
| Scope | Full local CI, final manifest, commit, push and draft PR for the exact reviewed snapshot only |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLISH-001",
  "record_type": "authorization",
  "title": "Publish reviewed controller-sidecar blocker remediation as a draft PR",
  "status": "consumed",
  "updated_at": "2026-09-22T16:00:00+08:00",
  "revalidation_triggers": ["reviewed_snapshot_changed", "staged_scope_changed", "local_CI_failure", "branch_or_base_changed", "merge_or_release_requested"],
  "authorization": {
    "action": "publish_reviewed_controller_sidecar_blocker_remediation",
    "target": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLICATION-001",
    "scope": "Run AGENTS.md full local CI for the exact reviewed source snapshot; copy only directly supporting KOS chain records; stage and commit the final manifest; push codex/typo-correction-002-runtime-hardening-blockers; create a draft PR against main.",
    "required_evidence": ["reviewed snapshot identity", "final staged file inventory and SHA", "Swift format/lint", "KeyboardCore", "RimeBridgeTests", "App plus Keyboard tests", "Release build", "push and draft PR facts"],
    "exclusions": ["source_or_test_scope_expansion", "RIME_vendor_schema_or_deployment_change", "Simulator_or_device_capture", "QA-001", "INT-003", "paired_performance", "force_push_or_rebase", "merge", "Release_or_TestFlight", "Product_or_Release_Gate", "parent_or_child_close", "unassigned_independent_review"],
    "issuer_role": "Human Product Owner / Product Lead",
    "decision_source": "current task instruction: 授权正式把这份实现放上 GitHub",
    "issued_at": "2026-09-22T16:00:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-22T16:05:00+08:00",
    "consumed_by": "Current Codex task",
    "consumption_record": "docs/evidence/typo-correction-002-runtime-integration-hardening-blocker-remediation-publication-001.md"
  }
}
```
