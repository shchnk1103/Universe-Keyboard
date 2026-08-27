# Authorization: AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT — Implement load UX

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT",
  "record_type": "authorization",
  "title": "Implement diagnostics viewer load versus empty states",
  "status": "active",
  "updated_at": "2026-08-27T21:30:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "authorization": {
    "action": "implement",
    "target": "DIAGNOSTICS-VIEWER-LOAD-001",
    "artifact_bindings": [],
    "scope": "Main App diagnostics viewer load/empty classification, bounded live refresh skip, and Store/UI tests. ADR 0027 budget unchanged.",
    "exclusions": ["required_mode", "merge", "release", "scheme_download_fix", "pr_83_merge", "writer_or_extension_hot_path", "raise_read_budget"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-27 Asia/Shanghai: start diagnostics load empty-state implementation under KOS 2.2",
    "issued_at": "2026-08-27T21:30:00+08:00",
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

本收据授权实现诊断查看加载态。它不授权 merge、`required`、方案下载或 PR #83。
