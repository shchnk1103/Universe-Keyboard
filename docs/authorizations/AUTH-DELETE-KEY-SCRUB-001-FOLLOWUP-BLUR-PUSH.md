# Authorization: AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-BLUR-PUSH — 气泡模糊自适应并推到 PR

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Consumption | 已推送 `origin/grok/delete-bubble-001` 至 `7c804a08b1e7161b69dbef07a7abfc7aa1534a3e`，PR [#203](https://github.com/shchnk1103/Universe-Keyboard/pull/203) head 已前进。未 merge。本回写留在本地，没有再次 push |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：授权这次小改动并推到 PR，先不要 merge。

范围只限删除键气泡在 iOS 26 以下的模糊底板，接受 PR #203 上 Codex 的那一条。已消费的 push / PR 授权不再覆盖这次追加提交。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-BLUR-PUSH",
  "record_type": "authorization",
  "title": "Push the adaptive delete-bubble blur onto PR 203",
  "status": "consumed",
  "updated_at": "2026-10-07T13:03:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "push_delete_bubble_adaptive_blur",
    "target": "DELETE-KEY-SCRUB-001",
    "artifact_bindings": [
      {"kind": "pull_request", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/203"},
      {"kind": "branch", "identity": "grok/delete-bubble-001"},
      {"kind": "commit", "identity": "7c804a08b1e7161b69dbef07a7abfc7aa1534a3e"},
      {"kind": "worktree", "identity": "/private/tmp/universe-keyboard-delete-key-scrub-001"}
    ],
    "scope": "On grok/delete-bubble-001, replace the delete bubble's fixed Light/Dark blur with adaptable systemUltraThinMaterial, update the contract assertion and UI Style Guide sentence, and push the branch to origin so PR 203 advances. The push may include the already-local receipts c1f29b1 and 4bb2f08. Do not merge, force-push, or change other keys.",
    "exclusions": ["merge", "force_push", "testflight_upload", "app_store_connect", "release_pass", "product_gate", "assignment_close", "default_branch_direct_push", "other_key_styling"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai: 授权这次小改动并推到 PR，先不要 merge",
    "issued_at": "2026-10-07T13:00:33+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

Merge 需要另一份 AUTH。本记录不授予 TestFlight 或 Release。
