# Authorization: AUTH-CI-HEAVY-JOB-SPLIT-001-IMPLEMENT — 实施 heavy job 拆分

## Current Status

| Field | Value |
|---|---|
| Status | active |
| Consumption | 实施进行中；未授权 commit / push / merge / hosted fixture / required-check |

Human Product Owner, current session `2026-09-15 Asia/Shanghai`: 「接受这份 Assignment 并开始实施吧」

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-CI-HEAVY-JOB-SPLIT-001-IMPLEMENT",
  "record_type": "authorization",
  "title": "Implement bounded CI heavy-job split without new skip rules",
  "status": "active",
  "updated_at": "2026-09-15T10:29:15+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "skip_rule_requested", "required_checks_changed"],
  "authorization": {
    "action": "implement_ci_heavy_job_split",
    "target": "CI-HEAVY-JOB-SPLIT-001",
    "artifact_bindings": [
      {"kind": "file", "identity": ".github/workflows/swift6-quality.yml"},
      {"kind": "file", "identity": "scripts/ci/verify_final_gate.sh"},
      {"kind": "file", "identity": "scripts/ci/tests/test_verify_final_gate.sh"},
      {"kind": "file", "identity": "docs/CI_CHANGE_CLASSIFICATION.md"},
      {"kind": "file", "identity": "docs/architecture/decisions/0031-fail-closed-ci-change-classification.md"},
      {"kind": "file", "identity": "AGENTS.md"}
    ],
    "scope": "Split the full-path Swift 6 heavy job into parallel named jobs, drop the redundant Debug build after Debug test, rewrite the final-quality-gate result matrix, and align CI/ADR/local-gate documentation. Do not add skip rules or change docs_only/full classification.",
    "exclusions": ["commit", "push", "merge", "branch_protection_mutation", "required_check_mutation", "paths_ignore", "add_path_skip", "pat_or_secret_addition", "kos_required_mode", "release", "weaken_full_gate", "keyboardcore_only_hosted_skip", "main_only_release_build"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-15 Asia/Shanghai instruction: 接受这份 Assignment 并开始实施吧",
    "issued_at": "2026-09-15T10:29:15+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "active"
  }
}
```

本收据不授权 commit、push、PR、hosted fixture 观察、merge、Release 或 required-check 迁移。
