# Assignment: APP-SWITCH-CONTRAST-001 — 主 App 系统开关深浅色对比度

**Policy version:** `1.0.0`
**Task ID:** `APP-SWITCH-CONTRAST-001`
**Decision source / date:** [`PD-APP-SWITCH-CONTRAST-001`](../product-decisions/APP-SWITCH-CONTRAST-001-authorization.md), Human Product Owner contrast-pair lock, `2026-09-15 Asia/Shanghai`
**Repository Change Type:** `Implementation` + `Documentation`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Reviewed` |
| **Phase** | 独立 Quality **Pass with conditions**；残差 `ASC-01`–`ASC-05` 均 `accept` |
| **Non-claims** | 不等于无条件 Quality Pass、Product Gate、push / PR / merge / TestFlight / Release；真机仅为 Human-attested |
| **Next** | 实现 SHA `5d3880b13109a65b8e441ded74b82f9927ffb9b4` 已形成并完成回写；按新身份做 Quality 增量核对，随后记录 Human-attested 观察；Product Gate 另授权 |
| **Residuals** | [`quality review`](../reviews/app-switch-contrast-001-quality-review.md) `ASC-01`–`ASC-05` `accept` |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-APP-SWITCH-CONTRAST-001`](../product-decisions/APP-SWITCH-CONTRAST-001-authorization.md), `2026-09-15 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead
- **Authorization (record slice):** [`AUTH-APP-SWITCH-CONTRAST-001`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001.md) — consumed; Decision / Assignment / status mirrors only
- **Authorization (implementation slice):** [`AUTH-APP-SWITCH-CONTRAST-001-IMPLEMENT`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-IMPLEMENT.md) — consumed (implementation delivered)
- **Authorization (Quality):** [`AUTH-APP-SWITCH-CONTRAST-001-QUALITY`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-QUALITY.md) — consumed
- **Authorization (ASC-02 local commit):** [`AUTH-APP-SWITCH-CONTRAST-001-COMMIT`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-COMMIT.md) — consumed by `5d3880b`; isolated branch, no push
- **Quality review:** [`app-switch-contrast-001-quality-review.md`](../reviews/app-switch-contrast-001-quality-review.md) — **Pass with conditions**

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | 本任务记录视觉合同，不新增证据 claim。 |
| A-01 / B-01 authorization chain and briefing | Adopted | 本 Assignment、当前 Authorization receipt、Accepted Product Decision 构成本切片权威链。 |
| P-01 publication facts | Not applicable | 未授权 push / PR / hosted CI；本地 SHA 不是 publication fact。 |
| D-01 final-documentation receipt | Not applicable | 本地 SHA 回写不构成 final-documentation receipt；不得称为 D-01。 |
| H-02 / W-01 | Not applicable | 超出已采用的 v0.8.0 范围。 |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current docs-only record | Authorized | `record_app_switch_contrast_product_decision_and_assignment` for `APP-SWITCH-CONTRAST-001` | Consumed [AUTH-APP-SWITCH-CONTRAST-001](../authorizations/AUTH-APP-SWITCH-CONTRAST-001.md) |
| Main-App implementation | Authorized | Shared switch owner + all main-App call sites + style-guide amendment | [AUTH-APP-SWITCH-CONTRAST-001-IMPLEMENT](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-IMPLEMENT.md) |
| Independent Quality | Authorized | Contrast + Form crash-contract regression — Pass with conditions | Consumed [AUTH-APP-SWITCH-CONTRAST-001-QUALITY](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-QUALITY.md) → [review](../reviews/app-switch-contrast-001-quality-review.md) |
| Human Product Gate | Not authorized | Light/dark visual acceptance | New Authorization required |
| Scoped local commit | Consumed | 实现 commit `5d3880b` + 本次 SHA 回写；不 push | [`AUTH-APP-SWITCH-CONTRAST-001-COMMIT`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-COMMIT.md) |
| Push / PR / merge | Not authorized | | New Authorization required |
| Environment or external slice | Not applicable | 无 H-01 冻结载荷；实施后 Simulator 目视即可进入 Quality，真机为可选 Human Dependency | 真机不是 `Ready` 前置 |

This is a manual advisory opt-in for A-01/B-01 only. This Assignment, its Authorization and its Product Decision are **not** Profile-included; validator coverage does not apply. Changing `.kos/project.json` requires a separate onboarding Assignment.

## Assignment

- **Domain Owner:** 📱 App & Data Operations Maintainer
- **Executor:** Current Grok session acting as App & Data Operations Maintainer / Main App UI
- **Environment Executor:** Current Grok session for Simulator / unit-test / build evidence
- **Human Dependency:** Human Product Owner — (1) implementation start instruction + matching Authorization; (2) Product Gate on light/dark 开/关对比度； (3) optional physical-device glance
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward — **Not Applicable** while implementation preserves system `UISwitch` and the Form crash contract; **required** if a custom-drawn `ToggleStyle` is proposed, if Form section topology around toggles changes, or if a new crash-contract exception is requested
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer — independent review **Pass with conditions** (`ASC-01`–`ASC-05` `accept`)
- **Supporting Domain:** [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)
- **Handoff Target:** Human Product Lead for Product Gate

## Acknowledgement And Activation

- **Product Assignment Decision:** `2026-09-15 Asia/Shanghai` — Human 认可对比度配对，要求共享组件覆盖全部主 App 开关，并授权记录 Assignment；无 Swift。
- **Executor acknowledgement (record slice):** `2026-09-15 Asia/Shanghai` — Scope、Non-goals、Stop Conditions 与对比度配对已接受；Form crash 合同保持。
- **Entry Criteria status:** **Met** for `Active` implementation slice (`AUTH-APP-SWITCH-CONTRAST-001-IMPLEMENT`).
- **Product lifecycle decision:** `Ready → Active` on Human instruction “开始实施，并允许写对应 Authorization”, `2026-09-15 Asia/Shanghai`.
- **Current phase:** Reviewed after independent Quality Pass with conditions; Product Gate not authorized.

## Boundary

### Scope

Authorize (and, **after a later implementation Authorization**, implement) a **single visual owner** for every main-App switch:

1. **Shared component.** 把开关外观抽到现有 `ToggleRow` 所在的共享层，并让所有主 App 开关走同一入口。`ToggleRow` 覆盖「标题 + 说明」行；`Form` / 列表里的裸 `Toggle` 必须使用同一 style / helper，不得在页面里单独设 thumb / track 颜色。
2. **Contrast pair.**
   - 浅色开启：黑槽 + 白点
   - 深色开启：白槽 + 黑点
   - 浅色关闭：浅槽 + 白点
   - 深色关闭：深槽 + 白点
3. **System chrome only.** 使用系统 `UISwitch` 的公开 `onTintColor` / `thumbTintColor`（或等价、按 `isOn` 与 `colorScheme` 更新的包装）。禁止 Capsule / ZStack / 自绘圆点的 `ToggleStyle`。
4. **Call-site completeness.** 实施时必须覆盖下列已知调用点（以当时仓库检索为准；漏网的主 App `Toggle` 也必须纳入，不得以截图行为完成标准）：
   - `Universe Keyboard/Views/Components/ToggleRow.swift`
   - `Universe Keyboard/Views/Settings/SettingsTab.swift`（上屏后联想、成对符号、默认简体）
   - `Universe Keyboard/Views/Settings/AppearanceSettingsView.swift`
   - `Universe Keyboard/Views/Settings/DiagnosticsSettingsView.swift`
   - `Universe Keyboard/Views/Settings/NotificationSettingsView.swift`
   - `Universe Keyboard/Views/Settings/FeedbackSettingsView.swift`
   - `Universe Keyboard/Views/Settings/TypingIntelligenceView.swift`
   - `Universe Keyboard/Views/Settings/TypoCorrectionBenchmarkView.swift`
   - `Universe Keyboard/Views/Settings/RimeFuzzyPinyinSettingsView.swift`
   - `Universe Keyboard/Views/Settings/RimeAdvancedInputSettingsView.swift`（含 `AdvancedInputFeatureToggle`）
   - `Universe Keyboard/Views/Settings/RimeUserDictionarySettingsView.swift`
   - `Universe Keyboard/Views/Settings/RimeSyncSettingsView.swift`
   - 页面级 / 根级 `.tint(.primary)`（如 `ContentView.swift` 与各 Settings 页）不得把深色开启轨道再次洗成与小圆点相同的白色
5. **Crash contract.** 保持诊断页注释与 `DEBUGGING.md`：不因主开关插拔 Form Section；不加主开关驱动的 `.animation`；不手绘 `ToggleStyle`。
6. **Documentation (implementation slice).** 代码落地后才把 [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) 中 “Page-level `.tint(.primary)` keeps on-state monochrome” 改成与对比度配对一致的现行规则。本记录切片不提前把指南写成已实现。

### Non-goals

- Keyboard Extension UI、按键、候选栏
- 改变任何开关的绑定、默认值、语义、gated-child 启用规则
- 引入品牌强调色或系统绿开启态
- 重新手绘 `ToggleStyle`
- 放宽 Form `AsyncRenderer` 合同
- 本记录切片改 Swift、改 `UI_STYLE_GUIDE.md` 现行描述、commit / push / merge
- Profile include / `required` mode
- TestFlight / Release / Product Gate

### Required Inputs

- [`PD-APP-SWITCH-CONTRAST-001`](../product-decisions/APP-SWITCH-CONTRAST-001-authorization.md)
- [`AUTH-APP-SWITCH-CONTRAST-001`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001.md)
- [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md)
- [`DEBUGGING.md`](../DEBUGGING.md) Form crash class
- [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)
- Existing: `ToggleRow.swift` and the call sites listed in Scope
- Human light/dark screenshots of 「上屏后联想」（问题样本，不是范围边界）

## Gates

### Entry Criteria

- [x] Product Decision `PD-APP-SWITCH-CONTRAST-001` recorded with contrast pair and shared-owner lock
- [x] Domain Owner, Executor, Environment Executor, Human Dependency, Quality Reviewer named or justified
- [x] No required Assignment field is `UNKNOWN`
- [x] Form crash contract remains the Stop Condition, not an exception
- [x] Implementation Authorization exists — [`AUTH-APP-SWITCH-CONTRAST-001-IMPLEMENT`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-IMPLEMENT.md)

### Exit Criteria

**Record slice (this turn)**

- Decision, Authorization, Assignment and Active Work / Dashboard mirrors exist.
- Visual contract is the contrast pair above; shared-component completeness is explicit.
- No Swift change; `UI_STYLE_GUIDE.md` is not rewritten as if implemented.

**Implementation**

- [x] One shared visual owner (`AppSwitch` / `.toggleStyle(.appSwitch)`); no remaining `.toggleStyle(.switch)` in main-App Swift.
- [x] Light/dark × on/off visual pair — Human 真机口头确认「没什么问题」（**Human-attested**，非 Device-attested；Quality 分级见审查）。
- [x] No custom-drawn `ToggleStyle` Capsule / ZStack thumb.
- [x] No new Form section insert/remove around master toggles.
- [x] App + Keyboard Debug tests on `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0` — **TEST SUCCEEDED** (UniverseKeyboardTests 373 / 9 skipped, including `AppSwitchChromeTests`; KeyboardTests 11). Swift format `--strict` on changed `.swift` files.
- [x] `UI_STYLE_GUIDE.md` and `DEBUGGING.md` amended to the landed rule.
- [x] Independent Quality **Pass with conditions** — [`app-switch-contrast-001-quality-review.md`](../reviews/app-switch-contrast-001-quality-review.md); residuals `ASC-01`–`ASC-05` `accept`.
- [x] `ASC-02` local commit `5d3880b13109a65b8e441ded74b82f9927ffb9b4` and SHA writeback on isolated branch — no push.
- [ ] Human Product Gate for Assignment `Closed` — **not authorized**.

### Stop Conditions

Stop and escalate if:

- Implementation only patches `SettingsTab` / 「上屏后联想」而留下其它主 App 开关
- A custom-drawn `ToggleStyle` is reintroduced
- Form + toggle changes correlate with `SwiftUI.AsyncRenderer` / libdispatch asserts
- Dark **off** thumb is made black (low contrast on the dark track)
- Keyboard Extension chrome is changed
- Switch product semantics, defaults, or gated-child mount rules change
- An unscoped commit, push / PR / merge, TestFlight or Release is requested under this record
- Required evidence is fabricated

## Handoff

- **Required Handoff Content:**
  - Shared owner: `Universe Keyboard/Views/Components/AppSwitch.swift` (`AppSwitchChrome` + `UISwitch` representable + `.toggleStyle(.appSwitch)`). `ContentView` and every former `.toggleStyle(.switch)` call site now use `.appSwitch`.
  - Contrast: on-tint `.label`; thumb white except dark-on black.
  - Tests: `xcodebuild` scheme `Universe Keyboard` Debug test, destination `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0` (`name=iPhone 17 Pro` without OS unmatched because latest is iOS 27), `CODE_SIGNING_ALLOWED=NO` `SWIFT_VERSION=6.0` `SWIFT_STRICT_CONCURRENCY=complete` `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES` — **TEST SUCCEEDED**. Not run: KeyboardCore-only, RimeBridgeTests, Release `build`.
  - Docs: `UI_STYLE_GUIDE.md`, `DEBUGGING.md`, `CHANGELOG.md`.
  - Independent Quality **Pass with conditions** (`ASC-01`–`ASC-05` `accept`) remains bound to the pre-commit dirty-tree identity; new-SHA incremental Quality is still required. Product Gate / push / PR / merge are not authorized.
  - Human 真机：Human-attested「没什么问题」；非 Device-attested。
- **Primary files:** `AppSwitch.swift`, `ToggleRow.swift`, Settings/Diagnostics toggle call sites, `ContentView.swift`, `AppSwitchChromeTests.swift`, `UI_STYLE_GUIDE.md`
- **Handoff Target:** Human Product Lead (Product Gate)
- **Revalidation Trigger:** Human reverses the contrast pair; Form crash-contract exception requested; brand accent color is introduced for switches; a new main-App switch surface is added outside the shared owner; Keyboard Extension is pulled into scope

## History

- `2026-09-15 Asia/Shanghai` — Human 认可对比度配对并授权记录 Assignment；要求共享组件覆盖全部主 App 开关。Assignment 进入 `Ready`；implementation not authorized.
- `2026-09-15 Asia/Shanghai` — Human 授权实施并允许写 Authorization；`Ready → Active`；[`AUTH-APP-SWITCH-CONTRAST-001-IMPLEMENT`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-IMPLEMENT.md)。
- `2026-09-15 Asia/Shanghai` — Executor 交付共享 `AppSwitch`、全部调用点迁移、指南修订与 App+Keyboard 测试绿。`Active → Completed`。无 Quality / Gate / commit。
- `2026-09-15 Asia/Shanghai` — Human 真机口头确认无问题，并授权独立 Quality。[`AUTH-APP-SWITCH-CONTRAST-001-QUALITY`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-QUALITY.md)。
- `2026-09-15 Asia/Shanghai` — 独立 Quality **Pass with conditions**（[`review`](../reviews/app-switch-contrast-001-quality-review.md)；`ASC-01`–`ASC-05` `accept`）。`Completed → Reviewed`。无 Product Gate / commit。
- `2026-09-15 Asia/Shanghai` — Human 授权 `ASC-02` 有界本地 commit（[`AUTH-APP-SWITCH-CONTRAST-001-COMMIT`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-COMMIT.md)）。隔离分支、只提交开关切片并回写 SHA；无 push / PR / merge / Product Gate。
- `2026-09-15 Asia/Shanghai` — ASC-02 实现 commit `5d3880b13109a65b8e441ded74b82f9927ffb9b4` 已形成；本回写 commit 记录该身份。Quality 旧结论不自动跟随新 SHA；待独立增量核对。
