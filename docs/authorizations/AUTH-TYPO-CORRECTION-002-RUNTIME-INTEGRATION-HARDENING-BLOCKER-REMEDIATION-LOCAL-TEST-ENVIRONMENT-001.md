# Authorization: AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-LOCAL-TEST-ENVIRONMENT-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` — temporary vendor link is permitted only for local verification |
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001`](../assignments/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md) |
| Issuer | Human Product Owner / Product Lead, `2026-09-22 Asia/Shanghai` |
| Consumer | Current Codex task |
| Target worktree | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-hardening-blockers/Universe Keyboard` |
| Immutable vendor source | `/private/tmp/universe-keyboard-typo-correction-002-runtime-integration-implementation-001/Packages/RimeBridge/Vendor` |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-LOCAL-TEST-ENVIRONMENT-001",
  "record_type": "authorization",
  "title": "Temporary verified RIME vendor link for local blocker-remediation tests",
  "status": "consumed",
  "updated_at": "2026-09-22T14:02:00+08:00",
  "revalidation_triggers": [
    "vendor_source_or_manifest_identity_changed",
    "target_worktree_identity_changed",
    "source_or_test_scope_changed",
    "runtime_capture_or_publication_requested"
  ],
  "authorization": {
    "action": "assemble_temporary_local_test_environment",
    "target": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001",
    "scope": "Create only a removable symlink at the target worktree's ignored Packages/RimeBridge/Vendor path to the already-present fixed vendor directory, run vendor verify plus RimeBridgeTests and Universe Keyboard Debug tests, then remove the symlink. Do not fetch, copy, change, publish, deploy or capture vendor/runtime bytes.",
    "allowed_paths": [
      "Packages/RimeBridge/Vendor (ignored, temporary symlink only)",
      "docs/evidence/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md",
      "docs/assignments/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md",
      "docs/ACTIVE_WORK.md"
    ],
    "required_evidence": [
      "source vendor verify result and manifest archive SHA-256",
      "target symlink target and cleanup result",
      "actual strict test results without runtime/product claims"
    ],
    "exclusions": [
      "vendor_fetch_or_download",
      "vendor_copy_or_modification",
      "schema_or_RIME_deployment_change",
      "Simulator_or_device_capture",
      "new_Run_ID",
      "QA-001",
      "INT-003",
      "paired_performance_or_180_ms",
      "commit_or_push",
      "PR_or_merge",
      "TestFlight_or_Release",
      "Product_Quality_or_Release_Gate",
      "Assignment_close"
    ],
    "issuer_role": "Human Product Owner / Product Lead",
    "decision_source": "current task instruction: 授权由你来按照你的建议继续进行下一步",
    "issued_at": "2026-09-22T14:02:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-22T14:02:00+08:00",
    "consumed_by": "Current Codex task",
    "consumption_record": "docs/evidence/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md"
  }
}
```

The source vendor directory was present and `bash scripts/ensure_rime_vendor.sh verify`
reported the expected structural inventory of 12 framework artifacts before this
Authorization was consumed. This is local build-linkage only, not RIME deployment
or runtime evidence.
