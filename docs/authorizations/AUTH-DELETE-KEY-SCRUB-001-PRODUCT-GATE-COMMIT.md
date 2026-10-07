# Authorization: AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-COMMIT — 有界文档 commit

## Current Status

| Field | Value |
|---|---|
| Status | `active` |
| Consumption | 未消费。内容 commit 之后由同一分支的 SHA 回写改为 consumed。不授权 push、PR、merge、TestFlight、Release 或 Close |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：授权 Product Gate 文档提交，先不要 push。

已消费的 [`AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE`](AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE.md) 只授权写 Gate，不授权 commit。本记录只覆盖 Gate 页、该授权和对应账本。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-COMMIT",
  "record_type": "authorization",
  "title": "Scoped local commit of the delete-key Product Gate",
  "status": "active",
  "updated_at": "2026-10-07T13:26:58+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked"],
  "authorization": {
    "action": "scoped_commit_delete_key_scrub_product_gate_docs",
    "target": "DELETE-KEY-SCRUB-001",
    "artifact_bindings": [
      {"kind": "worktree", "identity": "/private/tmp/universe-keyboard-delete-key-scrub-001"},
      {"kind": "branch", "identity": "grok/delete-bubble-001"}
    ],
    "scope": "On isolated branch grok/delete-bubble-001, commit the Product Gate, AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE, this Authorization, and the matching Assignment, Active Work, Dashboard, Knowledge Index, and Reading Map lines. Include a SHA writeback commit on the same branch. Note that main run 37575560853 later succeeded and was not an input to the Gate decision. No Swift, push, PR, merge, Close, TestFlight, or Release. Do not commit Packages/RimeBridge/Vendor or AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-MERGE.",
    "exclusions": ["swift_implementation", "push", "pull_request", "merge", "assignment_close", "testflight_upload", "app_store_connect", "release_pass", "default_branch_direct_commit", "vendor_binaries"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai: 授权 Product Gate 文档提交，先不要 push",
    "issued_at": "2026-10-07T13:26:58+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

Push 需要另一份 AUTH。本记录不授予 PR、merge、Close、TestFlight 或 Release。
