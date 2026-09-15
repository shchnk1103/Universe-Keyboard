# Authorization: AUTH-CI-HEAVY-JOB-SPLIT-001 — 撰写 heavy job 拆分 Assignment

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 撰文切片已完成；未授权实施或发布 |

Human Product Owner, current session `2026-09-15 Asia/Shanghai`: 「可以，按照你的建议写一个 Assignment 吧。」

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-CI-HEAVY-JOB-SPLIT-001",
  "record_type": "authorization",
  "title": "Author the bounded CI heavy-job split Assignment",
  "status": "consumed",
  "updated_at": "2026-09-15T10:23:47+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "authorization": {
    "action": "author_ci_heavy_job_split_assignment",
    "target": "CI-HEAVY-JOB-SPLIT-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/assignments/ci-heavy-job-split-001.md"},
      {"kind": "file", "identity": "docs/product-decisions/CI-HEAVY-JOB-SPLIT-001-authorization.md"},
      {"kind": "file", "identity": "docs/authorizations/AUTH-CI-HEAVY-JOB-SPLIT-001.md"}
    ],
    "scope": "Author the Assignment, Product Decision and this Authorization that define a fail-closed heavy-job split without new skip rules. Update only routing documents needed to discover the Assignment.",
    "exclusions": ["implement_workflow", "edit_classifier_semantics", "add_path_skip", "paths_ignore", "commit", "push", "merge", "branch_protection_mutation", "required_check_mutation", "pat_or_secret_addition", "kos_required_mode", "release", "weaken_full_gate"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-15 Asia/Shanghai instruction: 可以，按照你的建议写一个 Assignment 吧。",
    "issued_at": "2026-09-15T10:23:47+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

本收据不是实施、hosted CI、commit、push、merge、Release 或 required-check 迁移的授权。实施需要新的 Authorization（建议 action `implement_ci_heavy_job_split`）。
