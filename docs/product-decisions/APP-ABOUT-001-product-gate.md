# Product Decision: APP-ABOUT-001 — Human Product Gate

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-APP-ABOUT-001-PRODUCT-GATE",
  "record_type": "decision",
  "title": "Accept APP-ABOUT-001 main-App About page",
  "status": "accepted",
  "updated_at": "2026-09-28T20:41:30+08:00",
  "revalidation_triggers": ["scope_changed", "about_contract_changed", "contact_channel_changed"],
  "parent_refs": ["APP-ABOUT-001", "PD-APP-ABOUT-001"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "In-session 2026-09-28 Asia/Shanghai explicit Product Gate authorization: 接受残差，授权 Product Gate。",
    "scope": "Human Product Gate for the APP-ABOUT-001 main-App About page: identity, mail, Xiaohongshu, Settings IA move, search, and version-display contract. Accept the existing Quality residuals. Close the Assignment.",
    "outcome": "Human Product Gate passed with accepted evidence conditions; Assignment Closed; publication and release actions remain unauthorized",
    "expires_at": null
  }
}
```

- **Decision ID:** `PD-APP-ABOUT-001-PRODUCT-GATE`
- **Lifecycle status:** `Accepted`
- **Date / timezone:** `2026-09-28 Asia/Shanghai`
- **Assignment:** [`APP-ABOUT-001`](../assignments/app-about-001.md) — **Closed**
- **Authorization:** [`AUTH-APP-ABOUT-001-PRODUCT-GATE`](../authorizations/AUTH-APP-ABOUT-001-PRODUCT-GATE.md)
- **Contract source:** [`PD-APP-ABOUT-001`](APP-ABOUT-001-authorization.md)
- **Quality:** [`app-about-001-quality-review.md`](../reviews/app-about-001-quality-review.md) — Pass with conditions

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Phase | Human Product Gate **Passed with accepted evidence conditions**；Assignment `Closed` |
| Evidence | PR [#188](https://github.com/shchnk1103/Universe-Keyboard/pull/188) squash `a46a6abe66be065039557897a1e3adef29cc7d32`; `AboutSettingsView.swift` SHA-256 `08d6ff835b0429ba3a5734881730e9cebed4be49a65a00e5c4f315bc4695d2ec`; independent Quality App + Keyboard `UniverseKeyboardTests 410 / 10 skipped`, `KeyboardTests 15`; hosted same-head run [36426040680](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/36426040680) |
| Non-claims | Not Device-attested; not TestFlight / App Store Connect / Release |
| Next | None for this Assignment; any publication, commit or release gate requires separate authorization |

## Decision

Human Product Owner accepted the main-App About Product Gate for the locked contract:

- 入口在设置「App 设置」末行「关于」
- 展示当前安装包营销版本与 Build；本地 Debug 显示 `1.0 (1)` 符合工程默认
- 联系通道为邮箱 `doubleshy0n@gmail.com`（主题预填版本/Build）与小红书短链
- 「隐私与数据」「开源软件与内容」从设置根列表挪进关于页导航
- 搜索可命中关于、版本、邮箱、小红书、隐私、开源

The accepted evidence is bounded to:

1. Isolated dirty tree (`AboutSettingsView.swift` SHA-256 `08d6ff83…`, `AppAboutContact.swift` SHA-256 `ed68f749…`). There is no implementation commit.
2. Independent Quality Pass with conditions, including independently re-run App + Keyboard Debug **TEST SUCCEEDED** on iPhone 17 (`UniverseKeyboardTests` 410 executed, 10 skipped; `KeyboardTests` 15).
3. Human in-session Simulator glance that the About page looked correct, plus residual acceptance: 「接受残差，授权 Product Gate。」 Human-attested, not Device-attested.

## Accepted residuals and boundaries

| Residual | Gate disposition |
|---|---|
| `ABOUT-01` — no frozen implementation SHA / dirty-tree identity | `accept` — Product Gate binds the Quality-pinned working-tree SHA-256; commit remains unauthorized |
| `ABOUT-02` — Quality lane did not re-open Simulator About | `accept` — Human-attested Simulator glance plus residual acceptance is sufficient for this bounded Product Gate |
| `ABOUT-03` — activation guide still links Privacy | `accept` — out of Assignment scope; Settings root already moved |
| `ABOUT-04` — tests do not lock live Info.plist reads or mailto empty body | `accept` — existing Quality disposition remains accepted |
| `ABOUT-05` — search tests omit explicit 「版本」「邮箱」 queries | `accept` — catalog keywords exist; optional later tests |

This Gate closes only the **main-App About page product acceptance**. It does
not authorize commit, push, PR, merge, TestFlight, App Store or general Release work.
