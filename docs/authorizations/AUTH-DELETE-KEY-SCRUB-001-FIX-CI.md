# Authorization: AUTH-DELETE-KEY-SCRUB-001-FIX-CI — 修复 PR #202 的两项 CI 失败

## Current Status

| Field | Value |
|---|---|
| Status | `active` |
| Consumption | 未消费。只授权修复 PR #202 上 `test-rime-sync-keychain` 找不到模拟器、以及因此失败的 `final-quality-gate`。可把修复推到现有功能分支。不授权 merge |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：GitHub CI 有两个错误，请你先修复一下。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SCRUB-001-FIX-CI",
  "record_type": "authorization",
  "title": "Fix PR 202 missing-simulator CI failures",
  "status": "active",
  "updated_at": "2026-10-07T11:40:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "authorization": {
    "action": "fix_delete_key_scrub_pr_ci",
    "target": "DELETE-KEY-SCRUB-001",
    "artifact_bindings": [
      {"kind": "pull_request", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/202"},
      {"kind": "workflow_run", "identity": "37566881496"}
    ],
    "scope": "Make the iPhone 17 Pro simulator exist before the swift6-quality simulator jobs. Push that fix to grok/delete-key-scrub-001 so PR 202 reruns. Do not merge.",
    "exclusions": ["merge", "testflight_upload", "release_pass", "default_branch_direct_push", "force_push"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai: GitHub CI 有两个错误，请你先修复一下",
    "issued_at": "2026-10-07T11:40:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```
