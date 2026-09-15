# Authorization: AUTH-APP-SWITCH-CONTRAST-001-PRODUCT-GATE — Human Product Gate

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 已记录主 App 开关对比度 Product Gate；Assignment 可关闭；不授权 Device-attested、push、PR、merge、TestFlight 或 Release |

Human Product Owner, current session `2026-09-15 Asia/Shanghai`, explicitly authorized:

> 授权 `APP-SWITCH-CONTRAST-001` 主 App 开关对比度 Product Gate；接受 iPhone 13 Pro / iOS 27 的 Human-attested 四态观察及现有 Simulator 证据；不升级为 Device-attested，不授权 push、PR、merge、TestFlight 或 Release。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-APP-SWITCH-CONTRAST-001-PRODUCT-GATE",
  "record_type": "authorization",
  "title": "Human Product Gate for APP-SWITCH-CONTRAST-001",
  "status": "consumed",
  "updated_at": "2026-09-15T20:27:33+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "contrast_contract_changed"],
  "authorization": {
    "action": "product_gate_and_close_app_switch_contrast",
    "target": "APP-SWITCH-CONTRAST-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "5d3880b13109a65b8e441ded74b82f9927ffb9b4"},
      {"kind": "commit", "identity": "3125cd371910c43093c08be35e0adef73c4dce5a"},
      {"kind": "evidence", "identity": "docs/evidence/app-switch-contrast-001-human-attested-observation-2026-09-15.md"}
    ],
    "scope": "Accept the main-App switch contrast Product Gate using the existing Simulator evidence and the SHA-bound iPhone 13 Pro / iOS 27 Human-attested four-state observation. Close the Assignment with accepted evidence conditions.",
    "exclusions": ["device_attested_upgrade", "push", "pull_request", "merge", "testflight_upload", "app_store_connect", "release"],
    "issuer_role": "Human Product Owner",
    "decision_source": "In-session 2026-09-15 Asia/Shanghai explicit Product Gate authorization",
    "issued_at": "2026-09-15T20:27:33+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

This Authorization does not authorize a new Swift change, Device-attested payload
collection, push, PR, merge, TestFlight, App Store Connect or Release action.
