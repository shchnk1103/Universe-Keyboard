# Authorization: AUTH-DIAGNOSTICS-VIEWER-LOAD-001 — Establish diagnostics viewer assignment

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DIAGNOSTICS-VIEWER-LOAD-001",
  "record_type": "authorization",
  "title": "Establish DIAGNOSTICS-VIEWER-LOAD-001 assignment",
  "status": "active",
  "updated_at": "2026-08-27T19:50:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "authorization": {
    "action": "establish_assignment",
    "target": "DIAGNOSTICS-VIEWER-LOAD-001",
    "artifact_bindings": [],
    "scope": "Record the bounded diagnostics-viewer load Assignment and Product Decision. Implementation remains behind a later explicit implement authorization.",
    "exclusions": ["implement", "merge", "release", "scheme_download_fix", "pr_83_merge"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session Product instruction 2026-08-27 Asia/Shanghai accepting diagnostics-first sequence",
    "issued_at": "2026-08-27T19:50:00+08:00",
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

本记录不授权改诊断代码。实现需要另一次明确的「授权实现」。
