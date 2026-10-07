# Authorization: AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-PUSH — 只推功能分支

## Current Status

| Field | Value |
|---|---|
| Status | `active` |
| Consumption | 未消费。推送成功后由本地回写改为 consumed，该回写不再次 push。不授权开 PR、merge、TestFlight 或 Release |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：授权这次 push，先不要开 PR。

已消费的 [`AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-PUSH`](AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-PUSH.md) 只覆盖 `grok/delete-key-scrub-001` 的 `6cae5b2`。本记录只覆盖 `grok/delete-bubble-001` 上尚未推送的跟进提交。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-PUSH",
  "record_type": "authorization",
  "title": "Push the delete-key follow-up branch without a pull request",
  "status": "active",
  "updated_at": "2026-10-07T12:48:30+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "push_delete_key_scrub_followup_branch",
    "target": "DELETE-KEY-SCRUB-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "252d72666070372b7d92b473d75aea3a156071ee"},
      {"kind": "commit", "identity": "f94a8a773a2957c4fad2e96fca6980baeb019697"},
      {"kind": "commit", "identity": "39badbc612b91b74fd2180f5de41457eace421b1"},
      {"kind": "commit", "identity": "9e8b6cfaa111521d23f132cfb8a290b05d403044"},
      {"kind": "branch", "identity": "grok/delete-bubble-001"},
      {"kind": "worktree", "identity": "/private/tmp/universe-keyboard-delete-key-scrub-001"}
    ],
    "scope": "From worktree /private/tmp/universe-keyboard-delete-key-scrub-001, push branch grok/delete-bubble-001 to origin, including this Authorization commit. Do not push main. Do not open a pull request. No merge, TestFlight, or Release. Do not push Packages/RimeBridge/Vendor or AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-MERGE.",
    "exclusions": ["pull_request", "merge", "undraft_merge", "testflight_upload", "app_store_connect", "release_pass", "default_branch_direct_push", "branch_cleanup", "force_push", "vendor_binaries"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai: 授权这次 push，先不要开 PR",
    "issued_at": "2026-10-07T12:48:30+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

PR 需要另一份 AUTH。本记录不授予 merge、TestFlight 或 Release。
