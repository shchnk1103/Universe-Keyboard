# Authorization: AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-MERGE — squash merge PR #204

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Consumption | PR #204 已 squash merge 为 `origin/main` `4c2760de56fed9261a034413f39385b60ea8f91d`。树与 `de7b425` 一致。本收据由随后的 docs-only PR 补入。未做 TestFlight 或 Release |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：授权 merge，并在 merge 后安全清理分支和 worktree。

本记录只覆盖 PR [#204](https://github.com/shchnk1103/Universe-Keyboard/pull/204)，head `de7b425bdb4d8a040f922db6f460531b2f81f507`。hosted Swift 6 Quality run [37578303530](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/37578303530) 已成功，且为 docs-only。本地未推送的 `32053db` 不进入这次 merge。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-MERGE",
  "record_type": "authorization",
  "title": "Squash-merge DELETE-KEY-SCRUB-001 Product Gate PR 204 and clean its branch",
  "status": "consumed",
  "updated_at": "2026-10-07T13:58:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "squash_merge_delete_key_scrub_product_gate_pr",
    "target": "DELETE-KEY-SCRUB-001",
    "artifact_bindings": [
      {"kind": "pull_request", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/204"},
      {"kind": "branch", "identity": "grok/delete-key-scrub-001-product-gate"},
      {"kind": "commit", "identity": "de7b425bdb4d8a040f922db6f460531b2f81f507"},
      {"kind": "ci_run", "identity": "37578303530"},
      {"kind": "commit", "identity": "4c2760de56fed9261a034413f39385b60ea8f91d"}
    ],
    "scope": "Squash-merge PR 204 into main at head de7b425. Do not push this receipt or local commit 32053db onto the PR head. After fetch, confirm the squash tree matches de7b425, then delete local and remote grok/delete-key-scrub-001-product-gate and remove worktree /private/tmp/universe-keyboard-delete-key-scrub-001. Delete grok/delete-key-scrub-001 and grok/delete-bubble-001 only when their trees are already contained in origin/main. Do not delete any other branch or worktree.",
    "exclusions": ["testflight_upload", "app_store_connect", "release_pass", "force_push", "default_branch_direct_push", "changelog", "follow_up_pr"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai: 授权 merge，并在 merge 后安全清理分支和 worktree",
    "issued_at": "2026-10-07T13:54:58+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

TestFlight 与 Release 需要另外授权。
