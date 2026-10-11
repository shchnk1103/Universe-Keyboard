# Authorization: AUTH-DELETE-KEY-SETTINGS-001-COMMIT — 有界本地 commit

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Consumption | 内容 commit `2603b0075e568c161b314ba47b8c23fb46444847`。本回写只记录 SHA。不授权 push、PR、merge、TestFlight 或 Release |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：OK，授权 commit。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SETTINGS-001-COMMIT",
  "record_type": "authorization",
  "title": "Scoped local commit of DELETE-KEY-SETTINGS-001",
  "status": "consumed",
  "updated_at": "2026-10-07T16:08:30+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "authorization": {
    "action": "scoped_commit_delete_key_settings",
    "target": "DELETE-KEY-SETTINGS-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "2603b0075e568c161b314ba47b8c23fb46444847"},
      {"kind": "worktree", "identity": "/private/tmp/universe-keyboard-delete-key-settings-001"},
      {"kind": "branch", "identity": "grok/delete-key-settings-001"}
    ],
    "scope": "On isolated branch grok/delete-key-settings-001, commit the delete-key settings page, the three hold flags, KeyboardCore policy and tests, gesture integration, CHANGELOG, assignment, product contract, architecture, quality, and both product-gate records, their authorizations, and the matching Active Work, Dashboard, Knowledge Index, and Reading Map lines. Include a SHA writeback commit on the same branch. No push, PR, merge, TestFlight, or Release.",
    "exclusions": ["push", "pull_request", "merge", "testflight_upload", "app_store_connect", "release_pass", "assignment_close", "default_branch_direct_commit", "vendor_binaries", "dirty_main_checkout"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai: OK，授权 commit",
    "issued_at": "2026-10-07T16:06:54+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

Push、PR、merge、Close、TestFlight 和 Release 需要另外的授权。不要提交 `Packages/RimeBridge/Vendor`，也不要在脏的主工作区提交。
