# Authorization: AUTH-HELP-GUIDE-SHEET-001 — 记录引导 sheet 产品合同

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 本授权只覆盖把 F1–F3 写入 Product Decision / Assignment / 展示源；不覆盖 Swift 实施 |

Human Product Owner, current session 2026-09-14 Asia/Shanghai: locked F1 (标记 + 下次启动自动弹出), F2 (稍后再说后可点「？」或下次启动), F3 (只留导航栏「？」), and instructed to continue under KOS without code changes.

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-HELP-GUIDE-SHEET-001",
  "record_type": "authorization",
  "title": "Record guide-sheet product decision and Ready assignment",
  "status": "consumed",
  "updated_at": "2026-09-14T18:00:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "product_choice_changed"],
  "authorization": {
    "action": "record_help_guide_sheet_product_decision_and_assignment",
    "target": "HELP-GUIDE-SHEET-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/product-decisions/HELP-GUIDE-SHEET-001-authorization.md"},
      {"kind": "file", "identity": "docs/product-decisions/HELP-TIPKIT-001-authorization.md"},
      {"kind": "file", "identity": "docs/product-decisions/APP-SEARCH-001-authorization.md"},
      {"kind": "file", "identity": "docs/assignments/help-guide-sheet-001.md"},
      {"kind": "file", "identity": "docs/ONBOARDING_ACTIVATION.md"}
    ],
    "scope": "Record PD-HELP-GUIDE-SHEET-001, amend PD-HELP-TIPKIT-001 and PD-APP-SEARCH-001 presentation rules, align ONBOARDING_ACTIVATION presentation sections, and create Assignment HELP-GUIDE-SHEET-001 in Ready. No Swift, no TipKit code, no commit/push/merge.",
    "exclusions": ["swift_implementation", "uikit_swiftui_change", "tipkit_code", "keyboard_extension", "app_store_connect", "testflight_upload", "product_gate", "quality_pass", "release_pass", "commit", "push", "merge", "branch_cleanup", "profile_include", "required_mode"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-14 Asia/Shanghai F1-F3 lock and instruction to continue under KOS without code changes",
    "issued_at": "2026-09-14T18:00:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

Implementation of the guide sheet, Settings toolbar, and related tests requires a **new** Authorization whose action is implementation. This receipt does not grant it.
