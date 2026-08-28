# Authorization: AUTH-CODEX-GITHUB-AUTH-DIAG-001 — 发布认证诊断手册

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-CODEX-GITHUB-AUTH-DIAG-001",
  "record_type": "authorization",
  "title": "Publish Codex GitHub CLI authentication diagnosis runbook",
  "status": "active",
  "updated_at": "2026-08-28T18:45:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "diagnostic_behavior_changed"],
  "authorization": {
    "action": "document_codex_github_auth_diagnosis",
    "target": "CODEX-GITHUB-AUTH-DIAG-001",
    "artifact_bindings": [],
    "scope": "Docs-only KOS records, privacy-safe troubleshooting runbook, navigation, validation, commit and publication to the existing draft PR branch",
    "exclusions": ["token_disclosure", "proxy_mutation", "account_mutation", "merge", "release", "required_mode"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-28 Asia/Shanghai request to document the repeated false token-invalid diagnosis under KOS 2.2",
    "issued_at": "2026-08-28T18:45:00+08:00",
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

本收据只授权上述 docs-only 记录与现有 Draft PR 更新，不授权输出 secret、修改代理/账号、merge 或 Release。Receipt 不是 bearer token。
