# Authorization: AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-EXECUTOR-REASSIGNMENT-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` — docs-only executor reassignment recorded before implementation starts |
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001`](../assignments/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md) |
| Issuer / consumer | Human Product Owner / Product Lead / current Codex task |
| Effect | Grok is replaced by current Codex task as the named Executor and Consumer of the still-unconsumed implementation Authorization |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-EXECUTOR-REASSIGNMENT-001",
  "record_type": "authorization",
  "title": "Docs-only executor reassignment before controller-sidecar blocker remediation",
  "status": "consumed",
  "updated_at": "2026-09-22T10:45:00+08:00",
  "revalidation_triggers": [
    "implementation_authorization_consumed",
    "executor_or_worktree_identity_changed",
    "scope_or_authority_revoked"
  ],
  "authorization": {
    "action": "reassign_unconsumed_blocker_remediation_executor",
    "target": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001",
    "scope": "Reassign the still-unconsumed implementation Authorization from Grok to the current Codex task, then update only the governing Assignment, implementation Authorization, Product Decision, handoff status and Active Work mirror. Do not consume the implementation Authorization, create a worktree, edit source, run tests, or perform any runtime, device, capture or publication action.",
    "allowed_paths": [
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-EXECUTOR-REASSIGNMENT-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001.md",
      "docs/assignments/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md",
      "docs/product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001.md",
      "docs/evidence/typo-correction-002-codex-to-grok-runtime-integration-hardening-blocker-remediation-handoff-2026-09-22.md",
      "docs/ACTIVE_WORK.md"
    ],
    "required_evidence": [
      "implementation Authorization was active and unconsumed before reassignment",
      "named current Codex task replaces Grok consistently across governing records",
      "historical Grok handoff remains retained but is not treated as execution"
    ],
    "exclusions": [
      "implementation_authorization_consumption",
      "worktree_creation",
      "Swift_or_test_source_change",
      "test_or_build_rerun",
      "RIME_query_or_deployment",
      "Simulator_or_device_capture",
      "new_Run_ID",
      "commit_or_push",
      "PR_or_merge",
      "Assignment_close"
    ],
    "issuer_role": "Human Product Owner / Product Lead",
    "decision_source": "current task instruction: 我需要你来在新的隔离 worktree 中消费 AUTH 并仅修复三个 blocker",
    "issued_at": "2026-09-22T10:45:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-22T10:45:00+08:00",
    "consumed_by": "Current Codex task",
    "consumption_record": "executor reassignment recorded in Assignment and implementation Authorization"
  }
}
```

This changes the named executor only. The implementation Authorization remains
active and unconsumed until the new worktree has passed its entry checks.
