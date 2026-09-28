# Authorization: AUTH-APP-ABOUT-001 — 记录主 App「关于」页产品合同

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 本授权只覆盖把「关于」页合同写入 Product Decision / Assignment，并同步 Active Work / Dashboard；不覆盖 Swift 实施 |

Human Product Owner, current session 2026-09-28 Asia/Shanghai: 入口按推荐放在设置「App 设置」末行；通道为邮箱 `doubleshy0n@gmail.com` 与小红书短链；邮件预填版本/Build 主题；「隐私与数据」和「开源软件与内容」挪进关于页；先按 KOS 写 Assignment。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-APP-ABOUT-001",
  "record_type": "authorization",
  "title": "Record main-app About page product decision and Ready assignment",
  "status": "consumed",
  "updated_at": "2026-09-28T20:10:56+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "product_choice_changed"],
  "authorization": {
    "action": "record_app_about_product_decision_and_assignment",
    "target": "APP-ABOUT-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/product-decisions/APP-ABOUT-001-authorization.md"},
      {"kind": "file", "identity": "docs/assignments/app-about-001.md"},
      {"kind": "file", "identity": "docs/authorizations/AUTH-APP-ABOUT-001.md"},
      {"kind": "file", "identity": "docs/ACTIVE_WORK.md"},
      {"kind": "file", "identity": "docs/ENGINEERING_DASHBOARD.md"}
    ],
    "scope": "Record PD-APP-ABOUT-001 and create Assignment APP-ABOUT-001 in Ready. Sync Active Work and Dashboard mirrors only. Isolated worktree from origin/main. No Swift, no UI_STYLE_GUIDE rewrite as if implemented, no commit/push/merge.",
    "exclusions": ["swift_implementation", "uikit_swiftui_change", "keyboard_extension", "app_store_connect", "testflight_upload", "product_gate", "quality_pass", "release_pass", "commit", "push", "merge", "branch_cleanup", "profile_include", "required_mode"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-28 Asia/Shanghai instruction: 先用短链接；主题格式按照建议；请先按KOS写 Assignment",
    "issued_at": "2026-09-28T20:10:56+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

Implementation of the About page, Settings IA move, search catalog, tests, and style-guide amendment requires a **new** Authorization whose action is implementation. This receipt does not grant it.
