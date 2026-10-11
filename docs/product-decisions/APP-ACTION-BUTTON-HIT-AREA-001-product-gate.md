# Product Decision: APP-ACTION-BUTTON-HIT-AREA-001 — Human Product Gate

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE",
  "record_type": "decision",
  "title": "Accept APP-ACTION-BUTTON-HIT-AREA-001 main-App action-button full-capsule hit area",
  "status": "accepted",
  "updated_at": "2026-09-28T19:24:06+08:00",
  "revalidation_triggers": ["scope_changed", "hit_area_contract_changed", "new_main_app_action_button_surface"],
  "parent_refs": ["APP-ACTION-BUTTON-HIT-AREA-001", "PD-APP-ACTION-BUTTON-HIT-AREA-001"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "In-session 2026-09-28 Asia/Shanghai explicit Product Gate authorization: 接受残差，授权 Product Gate。",
    "scope": "Human Product Gate for the APP-ACTION-BUTTON-HIT-AREA-001 main-App AppActionButton full-capsule hit contract. Accept the existing Quality residuals. Close the Assignment.",
    "outcome": "Human Product Gate passed with accepted evidence conditions; Assignment Closed; publication and release actions remain unauthorized",
    "expires_at": null
  }
}
```

- **Decision ID:** `PD-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE`
- **Lifecycle status:** `Accepted`
- **Date / timezone:** `2026-09-28 Asia/Shanghai`
- **Assignment:** [`APP-ACTION-BUTTON-HIT-AREA-001`](../assignments/app-action-button-hit-area-001.md) — **Closed**
- **Authorization:** [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE.md)
- **Contract source:** [`PD-APP-ACTION-BUTTON-HIT-AREA-001`](APP-ACTION-BUTTON-HIT-AREA-001-authorization.md)
- **Quality:** [`app-action-button-hit-area-001-quality-review.md`](../reviews/app-action-button-hit-area-001-quality-review.md) — Pass with conditions

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Phase | Human Product Gate **Passed with accepted evidence conditions**；Assignment `Closed` |
| Evidence | PR [#186](https://github.com/shchnk1103/Universe-Keyboard/pull/186) squash `e3eb27b51caa289eae734d9194d3d5ba10f75bc6`; `AppActionButton.swift` SHA-256 `1da8b39cc8f5198f2cd73606e5683c674bed1f11fb86ec711682494159738485`; independent Quality App + Keyboard `UniverseKeyboardTests 407 / 10 skipped`, `KeyboardTests 15`; hosted same-head run [36416106485](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/36416106485) |
| Non-claims | Not Device-attested; not a Quality-reverified physical-device tap; not TestFlight / App Store Connect / Release |
| Next | None for this Assignment; any publication, commit or release gate requires separate authorization |

## Decision

Human Product Owner accepted the main-App action-button full-capsule hit Product Gate for the locked contract:

- 点共享 `AppActionButton` 可见胶囊的任意部分都必须触发，包括玻璃空白、图标两侧和上下内边距
- 命中形状与现有 `cornerRadius: 16` 连续圆角对齐
- `Button` 与 `ShareLink` 变体使用同一命中规则
- 对比度、Liquid Glass、按钮语义保持 `PD-APP-ACTION-BUTTON-CONTRAST-001`
- 范围是主 App 内容操作按钮，不是 Keyboard Extension，也不是全部 `.plain` 列表/芯片

The accepted evidence is bounded to:

1. Shared `AppActionButton` / `AppActionButtonChrome.hitFillShape` on the isolated dirty tree (`AppActionButton.swift` SHA-256 `1da8b39cc8f5198f2cd73606e5683c674bed1f11fb86ec711682494159738485`). There is no implementation commit.
2. Independent Quality Pass with conditions, including independently re-run App + Keyboard Debug **TEST SUCCEEDED** (`UniverseKeyboardTests` 407 executed, 10 skipped; `KeyboardTests` 15).
3. Human Product Owner in-session residual acceptance: 「接受残差，授权 Product Gate。」 No Device-attested tap and no separate Human-attested screenshot packet.

## Accepted residuals and boundaries

| Residual | Gate disposition |
|---|---|
| `AABH-01` — named `.plain` list/chip controls outside `AppActionButton` | `accept` — out of Assignment scope; optional later slice |
| `AABH-02` — other out-of-scope `.plain` rows and system Alert/Toolbar/Form chrome | `accept` — out of Assignment scope |
| `AABH-03` — no frozen implementation SHA / dirty-tree identity | `accept` — Product Gate binds the Quality-pinned working-tree SHA-256; commit remains unauthorized |
| `AABH-04` — Quality lane did not tap empty capsule | `accept` — Human-attested residual acceptance is sufficient for this bounded Product Gate; no Device-attested claim is made |
| `AABH-05` — chrome tests lock shape, not live SwiftUI hit-testing | `accept` — existing Quality disposition remains accepted |

This Gate closes only the **main-App content action-button full-capsule hit product acceptance**. It does
not authorize commit, push, PR, merge, TestFlight, App Store or general Release work.
