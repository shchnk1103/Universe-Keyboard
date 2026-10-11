# Authorization: AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-LINK-PUSH — 修复文档链接并推到 PR

## Current Status

| Field | Value |
|---|---|
| Status | `active` |
| Consumption | 未消费。推送成功后由本地回写改为 consumed，该回写不再次 push。不授权 merge、Close、TestFlight 或 Release |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：授权修这处链接并推到 PR，先不要 merge。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-LINK-PUSH",
  "record_type": "authorization",
  "title": "Publish the missing PR 202 merge receipt so the docs link resolves",
  "status": "active",
  "updated_at": "2026-10-07T13:40:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "push_delete_key_scrub_product_gate_link_fix",
    "target": "DELETE-KEY-SCRUB-001",
    "artifact_bindings": [
      {"kind": "pull_request", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/204"},
      {"kind": "branch", "identity": "grok/delete-key-scrub-001-product-gate"},
      {"kind": "file", "identity": "docs/authorizations/AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-MERGE.md"}
    ],
    "scope": "On grok/delete-key-scrub-001-product-gate, add the already-consumed PR 202 merge receipt so AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-MERGE.md no longer links to a missing file, and push the branch so PR 204 advances. The local PR 204 receipt may ride along. No Swift, merge, Close, TestFlight, or Release.",
    "exclusions": ["merge", "assignment_close", "swift_implementation", "testflight_upload", "app_store_connect", "release_pass", "force_push", "default_branch_direct_push"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai: 授权修这处链接并推到 PR，先不要 merge",
    "issued_at": "2026-10-07T13:40:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

Merge 与 Close 需要另外授权。
