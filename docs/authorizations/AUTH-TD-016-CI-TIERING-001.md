# Authorization: AUTH-TD-016-CI-TIERING-001 — 实施 CI 分级

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TD-016-CI-TIERING-001",
  "record_type": "authorization",
  "title": "Implement fail-closed CI change classification",
  "status": "active",
  "updated_at": "2026-08-28T18:40:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "required_checks_changed"],
  "authorization": {
    "action": "implement_ci_tiering",
    "target": "TD-016-CI-TIERING-001",
    "artifact_bindings": [],
    "scope": "Workflow, repository-local classifier/check scripts, tests, KOS records, CI/release documentation, local validation, commit and publication on an isolated branch",
    "exclusions": ["merge", "release", "branch_protection_mutation", "required_check_mutation", "pat_or_secret_addition", "weaken_full_gate", "kos_required_mode", "pr_86_scope_expansion"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-28 Asia/Shanghai instruction to implement TD-016",
    "issued_at": "2026-08-28T18:40:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | active |

---

本收据只授权有界 CI 实现与发布，不是 merge、Release、branch protection、required-check
迁移或 secret 配置的 bearer token。
