# Authorization: AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-MERGE — squash merge PR #203

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Consumption | PR #203 已 squash merge 为 `origin/main` `cee4f914be03d45c6d8deae8af5427ff1587d5c1`。树与 `7c804a0` 一致。未做 TestFlight、Release、Product Gate 或 Assignment Close。本回写未推送 |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：授权 merge。

已消费的 [`AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-MERGE`](AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-MERGE.md) 只覆盖 PR #202。本记录只覆盖 PR #203，head `7c804a08b1e7161b69dbef07a7abfc7aa1534a3e`。hosted Swift 6 Quality run [37574313596](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/37574313596) 已全绿。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-MERGE",
  "record_type": "authorization",
  "title": "Squash-merge DELETE-KEY-SCRUB-001 follow-up PR 203",
  "status": "consumed",
  "updated_at": "2026-10-07T13:18:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "head_changed"],
  "authorization": {
    "action": "squash_merge_delete_key_scrub_followup_pr",
    "target": "DELETE-KEY-SCRUB-001",
    "artifact_bindings": [
      {"kind": "pull_request", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/203"},
      {"kind": "commit", "identity": "7c804a08b1e7161b69dbef07a7abfc7aa1534a3e"},
      {"kind": "commit", "identity": "cee4f914be03d45c6d8deae8af5427ff1587d5c1"}
    ],
    "scope": "Squash-merge PR 203 into main. Do not push this receipt onto the PR head before merge. Do not delete the feature branch. No TestFlight, Release, Product Gate, or Assignment Close.",
    "exclusions": ["testflight_upload", "app_store_connect", "release_pass", "assignment_close", "product_gate", "force_push", "branch_cleanup"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai: 授权 merge",
    "issued_at": "2026-10-07T13:16:27+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

TestFlight、Release 与 Assignment Close 需要另外授权。
