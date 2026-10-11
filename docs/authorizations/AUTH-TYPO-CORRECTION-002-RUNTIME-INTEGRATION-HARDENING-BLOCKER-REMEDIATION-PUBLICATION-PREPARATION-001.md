# Authorization: AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLICATION-PREPARATION-001

| Field | Value |
|---|---|
| Status | `consumed` — local branch-identity preparation only |
| Target Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLICATION-PREPARATION-001`](../assignments/typo-correction-002-runtime-integration-hardening-blocker-remediation-publication-preparation-001.md) |
| Scope | Establish the exact reviewed snapshot's local named branch and document facts; this is not publication. |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLICATION-PREPARATION-001",
  "record_type": "authorization",
  "title": "Establish reviewed snapshot branch identity before separately authorized publication",
  "status": "consumed",
  "updated_at": "2026-09-22T15:45:00+08:00",
  "revalidation_triggers": ["snapshot_identity_changed", "branch_name_already_bound", "commit_push_PR_merge_or_release_requested"],
  "authorization": {
    "action": "establish_reviewed_snapshot_branch_identity",
    "target": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLICATION-PREPARATION-001",
    "scope": "Verify and preserve the exact uncommitted reviewed snapshot, attach its local worktree to codex/typo-correction-002-runtime-hardening-blockers, and record the preparation receipt.",
    "allowed_paths": [
      "docs/assignments/typo-correction-002-runtime-integration-hardening-blocker-remediation-publication-preparation-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLICATION-PREPARATION-001.md",
      "docs/evidence/typo-correction-002-runtime-integration-hardening-blocker-remediation-publication-preparation-001.md",
      "docs/ACTIVE_WORK.md"
    ],
    "required_evidence": ["exact HEAD and tree", "dirty-path inventory count", "tracked-diff SHA-256", "branch-name availability and result", "clear publication non-claims"],
    "exclusions": ["production_or_test_source_edit", "project_or_vendor_change", "RIME_schema_or_deployment", "test_or_build_rerun", "Simulator_or_device_capture", "QA-001", "INT-003", "paired_performance", "stage_or_commit", "push_or_fetch", "PR_create_or_update", "merge_or_rebase", "remote_state_change", "Product_or_Release_Gate", "Assignment_or_parent_close"],
    "issuer_role": "Human Product Owner / Product Lead",
    "decision_source": "current task instruction: 授权进入‘为该 Reviewed 快照建立分支身份并申请 publication’的单独车道",
    "issued_at": "2026-09-22T15:45:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-22T15:45:00+08:00",
    "consumed_by": "Current Codex task",
    "consumption_record": "docs/evidence/typo-correction-002-runtime-integration-hardening-blocker-remediation-publication-preparation-001.md"
  }
}
```
