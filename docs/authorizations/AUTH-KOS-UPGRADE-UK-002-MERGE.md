# Authorization: AUTH-KOS-UPGRADE-UK-002-MERGE — 合并 PR #92

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KOS-UPGRADE-UK-002-MERGE",
  "record_type": "authorization",
  "title": "Merge Deferred KOS v0.6.0 check PR #92",
  "status": "issued",
  "updated_at": "2026-09-03T19:10:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "authorization": {
    "action": "merge_pr_92",
    "target": "KOS-UPGRADE-UK-002",
    "artifact_bindings": [
      {"kind": "url", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/92"}
    ],
    "scope": "Merge PR #92 to main recording kos-agent-kit v0.6.0 as Deferred; keep Adopted v0.5.0 advisory; close KOS-UPGRADE-UK-002; run M-02",
    "exclusions": ["adopt_v0.6.0", "required_mode", "release", "testflight_upload", "orchestration_enablement", "active_assignment_migration"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-03 Asia/Shanghai Product Gate answer to merge the Deferred record without adopting v0.6.0",
    "issued_at": "2026-09-03T19:10:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "issued"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | issued |
| Consumption | not consumed; merge SHA pending |

---

本收据只授权合并 PR #92 与合并后 M-02。它不是 Adopt `v0.6.0`、`required`、编排落地或 Release 的 bearer token。
