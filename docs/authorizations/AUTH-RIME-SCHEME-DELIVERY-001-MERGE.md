# Authorization: AUTH-RIME-SCHEME-DELIVERY-001-MERGE — 合并 PR #83

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-RIME-SCHEME-DELIVERY-001-MERGE",
  "record_type": "authorization",
  "title": "Merge verified scheme delivery PR #83",
  "status": "consumed",
  "updated_at": "2026-08-28T21:30:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "authorization": {
    "action": "merge_pr_83",
    "target": "RIME-SCHEME-DELIVERY-001",
    "artifact_bindings": [
      {"kind": "url", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/83"},
      {"kind": "commit", "identity": "e9aea57"}
    ],
    "scope": "Merge PR #83 after hosted full-path green and Human CNB device success; record Product Gate; accept GitHub-source and endpoint acceptable-use as residuals",
    "exclusions": ["release", "testflight_upload", "testflight_external_review", "app_store_submission", "weaken_integrity", "td001_atomic_install"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-28 Asia/Shanghai confirmation to merge #83 after CI green; GitHub source and acceptable-use accepted as residuals",
    "issued_at": "2026-08-28T21:20:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | PR #83 merged `e9aea57` |

---

本收据只授权合并 PR #83 与合并后状态同步。它不是 TestFlight 上传、外部 Beta Review、
App Store 提交或 Release 的 bearer token。
