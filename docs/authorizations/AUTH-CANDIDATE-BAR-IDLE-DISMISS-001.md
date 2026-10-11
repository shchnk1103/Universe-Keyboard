# Authorization: AUTH-CANDIDATE-BAR-IDLE-DISMISS-001 — 记录空闲候选栏关闭键盘合同

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 本授权只覆盖把空闲关闭键盘合同写入 Product Decision / Assignment，并同步 Active Work / Dashboard；不覆盖 Swift 实施 |

Human Product Owner, current session 2026-09-28 Asia/Shanghai: 确认联想仍展开、全布局复用展开键、空闲 `chevron.down.circle` 关闭、有候选 `chevron.down` 展开、下滑不关闭；请先按 KOS 写 Assignment。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-CANDIDATE-BAR-IDLE-DISMISS-001",
  "record_type": "authorization",
  "title": "Record idle candidate-bar dismiss-keyboard product decision and Ready assignment",
  "status": "consumed",
  "updated_at": "2026-09-28T21:35:36+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "product_choice_changed"],
  "authorization": {
    "action": "record_candidate_bar_idle_dismiss_product_decision_and_assignment",
    "target": "CANDIDATE-BAR-IDLE-DISMISS-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/product-decisions/CANDIDATE-BAR-IDLE-DISMISS-001-authorization.md"},
      {"kind": "file", "identity": "docs/assignments/candidate-bar-idle-dismiss-001.md"},
      {"kind": "file", "identity": "docs/authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001.md"},
      {"kind": "file", "identity": "docs/ACTIVE_WORK.md"},
      {"kind": "file", "identity": "docs/ENGINEERING_DASHBOARD.md"}
    ],
    "scope": "Record PD-CANDIDATE-BAR-IDLE-DISMISS-001 and create Assignment CANDIDATE-BAR-IDLE-DISMISS-001 in Ready. Sync Active Work and Dashboard mirrors only. Isolated worktree from origin/main. No Swift, no UI_STYLE_GUIDE rewrite as if implemented, no commit/push/merge.",
    "exclusions": ["swift_implementation", "uikit_swiftui_change", "keyboard_core_semantics", "app_store_connect", "testflight_upload", "product_gate", "quality_pass", "release_pass", "commit", "push", "merge", "branch_cleanup", "profile_include", "required_mode"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-28 Asia/Shanghai instruction: 确认，请先按 KOS 写 Assignment。",
    "issued_at": "2026-09-28T21:35:36+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

Implementation of dual-mode expand/dismiss on the existing candidate-bar button requires a **new** Authorization whose action is implementation. This receipt does not grant it.
