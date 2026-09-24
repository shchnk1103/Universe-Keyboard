# Authorization: AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-001 — 统一第三方方案许可下载 CTA

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | 记录产品合同并实施主 App 首次下载入口的单按钮 + 许可证 sheet。不授权 Quality / Product Gate / commit / push |

Human Product Owner, current session 2026-09-23 Asia/Shanghai: 要求检查所有第三方方案下载入口，全部改成一个按钮「查看许可并下载」；单击先弹出许可证 sheet，sheet 底部「同意并下载」才开始下载并部署。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-001",
  "record_type": "authorization",
  "title": "Unify third-party scheme license-and-download CTA",
  "status": "consumed",
  "updated_at": "2026-09-23T20:01:35+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "product_choice_changed"],
  "authorization": {
    "action": "record_and_implement_scheme_license_download_cta",
    "target": "SCHEME-LICENSE-DOWNLOAD-CTA-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "Universe Keyboard/Views/Settings/SchemaDownloadContentViews.swift"},
      {"kind": "file", "identity": "Universe Keyboard/Views/License/LicenseView.swift"},
      {"kind": "file", "identity": "docs/assignments/scheme-license-download-cta-001.md"}
    ],
    "scope": "Record PD/Assignment and implement a single first-download CTA 查看许可并下载 on every main-App third-party scheme download surface. The CTA opens SchemeLicenseView; the sheet bottom button 同意并下载 accepts the license and starts download/deploy. Isolated worktree only. Local Swift format and App+Keyboard tests are Executor evidence.",
    "exclusions": ["keyboard_extension", "download_engine_semantics", "installed_manage_grid", "app_store_connect", "testflight_upload", "product_gate", "quality_pass", "release_pass", "commit", "push", "merge", "branch_cleanup", "profile_include", "required_mode"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-23 Asia/Shanghai instruction to replace split 查看许可证 / 同意并下载 with 查看许可并下载 then sheet 同意并下载",
    "issued_at": "2026-09-23T20:01:35+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

This Authorization does not grant independent Quality, Product Gate, commit, push, merge, TestFlight, or Release.
