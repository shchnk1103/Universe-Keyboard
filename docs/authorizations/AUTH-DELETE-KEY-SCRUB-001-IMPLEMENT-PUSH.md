# Authorization: AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-PUSH — 只推功能分支

## Current Status

| Field | Value |
|---|---|
| Status | `active` |
| Consumption | 未消费。只授权把隔离分支 `grok/delete-key-scrub-001` 推到 `origin`。不授权 PR、merge、TestFlight 或 Release |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：可以，单独授权 push，先不要 PR。

已消费的 [`AUTH-DELETE-KEY-SCRUB-001-PUSH-PR`](AUTH-DELETE-KEY-SCRUB-001-PUSH-PR.md) 只覆盖 2026-10-01 的文档框架和 PR #196。本记录是新的实现分支 push 授权。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-PUSH",
  "record_type": "authorization",
  "title": "Push DELETE-KEY-SCRUB-001 implementation branch without a pull request",
  "status": "active",
  "updated_at": "2026-10-07T11:25:03+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "push_delete_key_scrub_implementation_branch",
    "target": "DELETE-KEY-SCRUB-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "ff149ac7fe8386399f39568f88f722c768153330"},
      {"kind": "commit", "identity": "f6f5b18a9d9e56eecd2540e82c24c4329087060c"},
      {"kind": "branch", "identity": "grok/delete-key-scrub-001"}
    ],
    "scope": "From worktree /private/tmp/universe-keyboard-delete-key-scrub-001, push branch grok/delete-key-scrub-001 to origin. Do not push main. Do not open a pull request. No merge, TestFlight, or Release.",
    "exclusions": ["pull_request", "merge", "undraft_merge", "testflight_upload", "app_store_connect", "release_pass", "default_branch_direct_push", "branch_cleanup", "force_push"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai: 可以，单独授权 push，先不要 PR",
    "issued_at": "2026-10-07T11:25:03+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

PR 需要另一份 AUTH。本记录不授予 merge、TestFlight 或 Release。
