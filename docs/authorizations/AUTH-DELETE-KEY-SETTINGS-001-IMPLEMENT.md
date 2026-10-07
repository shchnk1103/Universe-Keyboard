# Authorization: AUTH-DELETE-KEY-SETTINGS-001-IMPLEMENT — 实施删除键设置页

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Consumption | 内容 commit `2603b0075e568c161b314ba47b8c23fb46444847` 绑定本实施。消费来自 [`AUTH-DELETE-KEY-SETTINGS-001-COMMIT`](AUTH-DELETE-KEY-SETTINGS-001-COMMIT.md)。不授权 push、PR、merge |

Human Product Owner, current session `2026-10-07 Asia/Shanghai`：按远程 main 最新 KOS 开始这项工作。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-DELETE-KEY-SETTINGS-001-IMPLEMENT",
  "record_type": "authorization",
  "title": "Implement DELETE-KEY-SETTINGS-001 delete-key settings",
  "status": "consumed",
  "updated_at": "2026-10-07T16:08:30+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "product_choice_changed"],
  "authorization": {
    "action": "implement_delete_key_settings",
    "target": "DELETE-KEY-SETTINGS-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "2603b0075e568c161b314ba47b8c23fb46444847"},
      {"kind": "base", "identity": "141bc8ebcee456cfac8f8c826da9d6ce4e9e5b4f"},
      {"kind": "file", "identity": "docs/product-decisions/DELETE-KEY-SETTINGS-001-product-contract.md"}
    ],
    "scope": "In isolated worktree /private/tmp/universe-keyboard-delete-key-settings-001 on grok/delete-key-settings-001, add the main-app Delete Key settings page and the three default-on hold flags. Read flags once at delete touchDown. Missing UserDefaults keys stay on. Scrub off stops the press when the finger leaves the delete key, except the pending gap into a visible trash bubble. Include CHANGELOG in the same uncommitted slice. Occupy Active Work slot 6. Local ignored Vendor symlink is allowed only for compile.",
    "exclusions": ["long_press_toggle", "timing_change", "sound_settings_change", "rewrite_delete_key_scrub_contract", "reopen_delete_key_scrub_001", "selectAll", "host_text_logging", "architecture_verdict", "quality_verdict", "product_gate", "commit", "push", "merge", "testflight", "release", "required_mode"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-10-07 Asia/Shanghai: 授权你按照远程main分支最新的KOS设定，开始这项工作吧",
    "issued_at": "2026-10-07T14:47:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

本实施已由 commit `2603b0075e568c161b314ba47b8c23fb46444847` 绑定。push、PR、merge、Close、TestFlight 和 Release 仍要另外授权。
