# Authorization: AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-PUSH-PR — 文档 push 并开 PR

## Current Status

| Field | Value |
|---|---|
| Status | `active` |
| Consumption | 未消费。推送并开 PR 后由本地回写改为 consumed，该回写不再次 push。不授权 merge、Close、TestFlight 或 Release |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：授权这次文档 push，并开 PR。

已消费的 [`AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-COMMIT`](AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-COMMIT.md) 只覆盖本地写作提交 `45c84a7`。本记录把该页从 `origin/main` `cee4f91` 另开文档分支发布。不把已合并的 `grok/delete-bubble-001` 再开成 PR。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-PUSH-PR",
  "record_type": "authorization",
  "title": "Push and open a docs pull request for the delete-key Product Gate",
  "status": "active",
  "updated_at": "2026-10-07T13:32:30+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "push_and_open_pr_delete_key_scrub_product_gate_docs",
    "target": "DELETE-KEY-SCRUB-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "cee4f914be03d45c6d8deae8af5427ff1587d5c1"},
      {"kind": "branch", "identity": "grok/delete-key-scrub-001-product-gate"},
      {"kind": "worktree", "identity": "/private/tmp/universe-keyboard-delete-key-scrub-001"}
    ],
    "scope": "From origin/main cee4f914be03d45c6d8deae8af5427ff1587d5c1, publish the Product Gate docs on branch grok/delete-key-scrub-001-product-gate and open one pull request into main. The diff must stay docs-only. Do not push grok/delete-bubble-001, do not push main directly, and do not merge, Close, TestFlight, or Release.",
    "exclusions": ["merge", "assignment_close", "testflight_upload", "app_store_connect", "release_pass", "force_push", "default_branch_direct_push", "swift_implementation", "vendor_binaries"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai: 授权这次文档 push，并开 PR",
    "issued_at": "2026-10-07T13:32:30+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

Merge 需要另一份 AUTH。本记录不授予 Close、TestFlight 或 Release。
