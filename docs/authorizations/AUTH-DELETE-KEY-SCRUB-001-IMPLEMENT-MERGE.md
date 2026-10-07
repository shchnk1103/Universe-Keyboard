# Authorization: AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-MERGE — squash merge PR #202

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Consumption | PR #202 已 squash merge 为 `origin/main` `1560488664f6e51450a441f14e465760c0635820`。树与 `95fd0dc` 一致。未做 TestFlight、Release、Assignment Close。收据原先留在工作区；随 PR #204 补入仓库，只为让链接可解析 |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：授权 merge，然后在指定真机上测试。本记录只覆盖 merge。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-MERGE",
  "record_type": "authorization",
  "title": "Squash-merge DELETE-KEY-SCRUB-001 PR 202",
  "status": "consumed",
  "updated_at": "2026-10-07T11:55:54+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "squash_merge_delete_key_scrub_pr",
    "target": "DELETE-KEY-SCRUB-001",
    "artifact_bindings": [
      {"kind": "pull_request", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/202"},
      {"kind": "commit", "identity": "95fd0dc07b191d8dee3c43bd58904e31d84cf781"},
      {"kind": "commit", "identity": "1560488664f6e51450a441f14e465760c0635820"}
    ],
    "scope": "Squash-merge PR 202 into main while its hosted Swift 6 Quality run on 95fd0dc is green. Do not push this receipt onto the PR head before merge. No TestFlight, Release, or Assignment Close.",
    "exclusions": ["testflight_upload", "app_store_connect", "release_pass", "assignment_close", "force_push"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai: 授权 merge，然后在 iPhone 13 Pro 00008110-000A08440198801E 上测试",
    "issued_at": "2026-10-07T12:00:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```
