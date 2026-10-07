# Authorization: AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-TIMING-PUSH — 修正气泡时间并推到 PR

## Current Status

| Field | Value |
|---|---|
| Status | `active` |
| Consumption | 未消费。推送成功后由本地回写改为 consumed，该回写不再次 push。不授权 merge、Close、TestFlight 或 Release |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：授权改气泡时间并推到 PR，先不要 merge。

只改 Product Gate 的文字。实现仍是按下后 `initialDelay` 0.5 秒进入重复，再 `bubbleDelayAfterRepeatStart` 0.15 秒出气泡。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-TIMING-PUSH",
  "record_type": "authorization",
  "title": "Correct the delete-bubble timing sentence and push it to PR 204",
  "status": "active",
  "updated_at": "2026-10-07T13:39:30+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "push_delete_key_scrub_product_gate_timing_wording",
    "target": "DELETE-KEY-SCRUB-001",
    "artifact_bindings": [
      {"kind": "pull_request", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/204"},
      {"kind": "branch", "identity": "grok/delete-key-scrub-001-product-gate"},
      {"kind": "file", "identity": "docs/product-decisions/DELETE-KEY-SCRUB-001-product-gate.md"}
    ],
    "scope": "On grok/delete-key-scrub-001-product-gate, change the Product Gate sentence so the trash bubble appears about 0.15s after repeat starts, about 0.65s after press. Push so PR 204 advances. Do not change Swift timing. No merge, Close, TestFlight, or Release.",
    "exclusions": ["swift_implementation", "merge", "assignment_close", "testflight_upload", "app_store_connect", "release_pass", "force_push", "default_branch_direct_push"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai: 授权改气泡时间并推到 PR，先不要 merge",
    "issued_at": "2026-10-07T13:39:30+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

Merge 与 Close 需要另外授权。
