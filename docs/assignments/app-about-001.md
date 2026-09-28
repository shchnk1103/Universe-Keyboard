# Assignment: APP-ABOUT-001 — 主 App「关于」页

**Policy version:** `1.0.0`
**Task ID:** `APP-ABOUT-001`
**Decision source / date:** [`PD-APP-ABOUT-001`](../product-decisions/APP-ABOUT-001-authorization.md), Human Product Owner About-page lock, `2026-09-28 Asia/Shanghai`
**Repository Change Type:** `Implementation` + `Documentation`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` |
| **Phase** | Human Product Gate **Passed with accepted evidence conditions**；残差 `ABOUT-01`–`ABOUT-05` 均 `accept` |
| **Non-claims** | 不等于无条件 Quality Pass 或 Device-attested；不授权 commit / push / merge、TestFlight 或 Release |
| **Next** | 隔离分支有界 commit / push / PR 进行中；merge 另授权 |
| **Residuals** | [`quality review`](../reviews/app-about-001-quality-review.md) `ABOUT-01`–`ABOUT-05` `accept`；[`Product Gate`](../product-decisions/APP-ABOUT-001-product-gate.md) 接受 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-APP-ABOUT-001`](../product-decisions/APP-ABOUT-001-authorization.md), `2026-09-28 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead
- **Authorization (record slice):** [`AUTH-APP-ABOUT-001`](../authorizations/AUTH-APP-ABOUT-001.md) — consumed; Decision / Assignment / status mirrors only
- **Authorization (implementation slice):** [`AUTH-APP-ABOUT-001-IMPLEMENT`](../authorizations/AUTH-APP-ABOUT-001-IMPLEMENT.md) — consumed on delivery
- **Quality review:** [`AUTH-APP-ABOUT-001-QUALITY`](../authorizations/AUTH-APP-ABOUT-001-QUALITY.md) — consumed；[`review`](../reviews/app-about-001-quality-review.md) **Pass with conditions**
- **Authorization (Product Gate):** [`AUTH-APP-ABOUT-001-PRODUCT-GATE`](../authorizations/AUTH-APP-ABOUT-001-PRODUCT-GATE.md) — consumed
- **Product Gate:** [`PD-APP-ABOUT-001-PRODUCT-GATE`](../product-decisions/APP-ABOUT-001-product-gate.md) — **Accepted**
- **Authorization (scoped local commit):** [`AUTH-APP-ABOUT-001-COMMIT`](../authorizations/AUTH-APP-ABOUT-001-COMMIT.md) — active / unconsumed until delivery
- **Authorization (push / PR):** [`AUTH-APP-ABOUT-001-PUSH-PR`](../authorizations/AUTH-APP-ABOUT-001-PUSH-PR.md) — active / unconsumed until delivery

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | 本切片只记录产品合同，不新增证据 claim。 |
| A-01 / B-01 authorization chain and briefing | Adopted | 本 Assignment、当前 Authorization receipt、Recorded Product Decision 构成本切片权威链。 |
| P-01 publication facts | Not applicable | 未授权 push / PR / hosted CI。 |
| D-01 final-documentation receipt | Not applicable | 本地 docs 写入不构成 D-01。 |
| H-02 / W-01 | Not applicable | 超出已采用的 v0.9.0 选择性范围。 |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current docs-only record | Authorized | `record_app_about_product_decision_and_assignment` for `APP-ABOUT-001` | Consumed [`AUTH-APP-ABOUT-001`](../authorizations/AUTH-APP-ABOUT-001.md) |
| Main-App implementation | Authorized | About page + Settings IA move + search catalog | Consumed [`AUTH-APP-ABOUT-001-IMPLEMENT`](../authorizations/AUTH-APP-ABOUT-001-IMPLEMENT.md) |
| Independent Quality | Authorized | Settings / About / mailto / 小红书 / search — Pass with conditions | Consumed [`AUTH-APP-ABOUT-001-QUALITY`](../authorizations/AUTH-APP-ABOUT-001-QUALITY.md) → [`review`](../reviews/app-about-001-quality-review.md) |
| Human Product Gate | Authorized | Main-App About acceptance; Assignment Closed | Consumed [`AUTH-APP-ABOUT-001-PRODUCT-GATE`](../authorizations/AUTH-APP-ABOUT-001-PRODUCT-GATE.md) → [`PD-APP-ABOUT-001-PRODUCT-GATE`](../product-decisions/APP-ABOUT-001-product-gate.md) |
| Scoped local commit | In progress | Isolated-branch commit + SHA writeback | [`AUTH-APP-ABOUT-001-COMMIT`](../authorizations/AUTH-APP-ABOUT-001-COMMIT.md) |
| Push / PR | In progress | Push isolated branch and open PR; Human observes CI | [`AUTH-APP-ABOUT-001-PUSH-PR`](../authorizations/AUTH-APP-ABOUT-001-PUSH-PR.md) |
| Merge | Not authorized | Merge to default branch | New AUTH required |
| Environment or external slice | Not applicable | 记录切片无设备动作 | 真机不是 `Ready` 前置 |

This is a manual advisory opt-in for A-01/B-01 only. This Assignment, its Authorization and its Product Decision are **not** Profile-included; validator coverage does not apply. Changing `.kos/project.json` requires a separate onboarding Assignment.

## Assignment

- **Domain Owner:** 📱 App & Data Operations Maintainer
- **Executor:** Current Grok session acting as App & Data Operations Maintainer / Main App UI
- **Environment Executor:** Current Grok session — App+Keyboard Debug on iPhone 17 `D3C353BE-3AA6-499B-8F87-349073D65BE4` (iOS 26.0)
- **Human Dependency:** Human Product Owner — (1) record start **done**; (2) implementation **done**; (3) Quality / Product Gate remain Human-gated
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward — **Not Applicable** while work stays in main-App Settings/About, user-tapped `mailto`/URL, and existing privacy/OSS pages; **required** if Keyboard Extension gains a contact path, or [`PRIVACY_POLICY.md`](../PRIVACY_POLICY.md) / ADR 0007 claims change
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer — independent review **Pass with conditions**（`ABOUT-01`–`ABOUT-05` `accept`）
- **Supporting Domain:** [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)
- **Handoff Target:** None for this Assignment; future commit or Release gates are separate

## Acknowledgement And Activation

- **Product Assignment Decision:** `2026-09-28 Asia/Shanghai` — Human 锁定入口、邮箱、小红书短链、邮件主题格式，并把隐私/开源入口挪进关于页；授权按 KOS 写 Assignment。
- **Executor acknowledgement (record slice):** `2026-09-28 Asia/Shanghai` — Scope、Non-goals、Stop Conditions 已接受。工作在隔离 worktree `/private/tmp/universe-keyboard-app-about-001`，基线 `origin/main` `a536dca74acc18deebe1de9b7a2c22421cba9f95`，不触碰主工作区脏树。
- **Entry Criteria status:** **Met** for `Active` implementation slice.
- **Product lifecycle decision:** Assignment `Ready` on Human instruction “请先按KOS写 Assignment”; `Ready → Active → Completed` on “确认 APP-ABOUT-001，AUTH 生效，按上述范围记录并实施”, `2026-09-28 Asia/Shanghai`.

## Boundary

### Scope

1. **Record slice (this AUTH).** 写入 PD / Assignment / AUTH，并同步 Active Work 与 Dashboard。不改 Swift。
2. **Implementation (future AUTH).** 主 App「关于」页：身份（营销版本 + Build，可复制）、联系（邮箱与小红书）、导航到现有隐私页与开源许可证页。
3. **Settings IA.** 「App 设置」只保留外观、通知与提醒、关于。隐私与开源入口从设置根列表移除，改挂在关于页。
4. **Search.** `SettingsSearchCatalog` 增加关于，并让隐私/开源可搜到且能直达。
5. **Mail.** `mailto:doubleshy0n@gmail.com`，主题 `Universe Keyboard 反馈 · {version} (Build {build})`，正文空。
6. **Xiaohongshu.** 用户点击后打开 `https://xhslink.cn/o/7lEn4EM0BtP`。
7. **Workspace hygiene.** 实施必须在隔离 worktree / 功能分支进行。禁止改主 checkout `/Users/doubleshy0n/Dev/Universe Keyboard` 上与本任务无关的脏文件。

### Non-goals

- Keyboard Extension UI 或问号启用指南改包
- Telegram / Discord / GitHub Issues / 应用内表单 / 自动附日志
- 改 `PrivacyDataView` 或许可证原文（只改入口）
- 把隐私全文或许可证列表摊进关于页
- commit / push / merge
- Profile include / `required` mode
- TestFlight / Release

### Required Inputs

- [`PD-APP-ABOUT-001`](../product-decisions/APP-ABOUT-001-authorization.md)
- [`AUTH-APP-ABOUT-001`](../authorizations/AUTH-APP-ABOUT-001.md)
- [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md)
- [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)
- Existing: `Universe Keyboard/Views/Settings/SettingsTab.swift`, `PrivacyDataView.swift`, `OpenSourceLicensesView`, `SettingsSearchCatalog.swift`
- Baseline: `origin/main` `a536dca74acc18deebe1de9b7a2c22421cba9f95`

## Gates

### Entry Criteria

- [x] Product Decision `PD-APP-ABOUT-001` recorded with entry, channels, subject, and IA move
- [x] Domain Owner, Executor, Environment Executor, Human Dependency, Quality Reviewer named or justified
- [x] No required Assignment field is `UNKNOWN`
- [x] Isolated worktree used from `origin/main`
- [x] Implementation Authorization exists

### Exit Criteria

**Record slice**

- [x] Decision, Authorization, Assignment and Active Work / Dashboard mirrors exist.
- [x] Contact channels, subject format, and Settings IA move are explicit.
- [x] Main checkout dirty tree is untouched.

**Implementation**

- [x] About page + Settings IA + search catalog land
- [x] App + Keyboard Debug tests on `platform=iOS Simulator,id=D3C353BE-3AA6-499B-8F87-349073D65BE4` (`iPhone 17`, iOS 26.0) — **TEST SUCCEEDED**: UniverseKeyboardTests **410** executed / **10** skipped / **0** failed (includes `AppAboutContactTests` 3); KeyboardTests **15** / **0** failed. CI default iPhone 17 Pro was busy; Human directed this device.
- [x] Swift format `--strict` on changed `.swift` files
- [x] `UI_STYLE_GUIDE.md` amended to the landed About rule
- [x] Independent Quality **Pass with conditions** — [`app-about-001-quality-review.md`](../reviews/app-about-001-quality-review.md)；residuals `ABOUT-01`–`ABOUT-05` `accept`
- [x] Human Product Gate for Assignment `Closed` — [`PD-APP-ABOUT-001-PRODUCT-GATE`](../product-decisions/APP-ABOUT-001-product-gate.md); accepted Quality conditions; no Device-attested or Release claim

### Stop Conditions

Stop and escalate if:

- Implementation adds Telegram / Discord / in-app forms / auto-attached logs
- Privacy or OSS page bodies are rewritten as if this Assignment owned those contracts
- Keyboard Extension gains a contact path
- Work is applied onto the dirty main checkout
- An unscoped commit, push / PR / merge, TestFlight or Release is requested under this record
- Required evidence is fabricated

## Handoff

- **Required Handoff Content:**
  - Isolated worktree: `/private/tmp/universe-keyboard-app-about-001`
  - Branch: `grok/app-about-001` tracking `origin/main` @ `a536dca74acc18deebe1de9b7a2c22421cba9f95`
  - About: `Universe Keyboard/Views/Settings/AboutSettingsView.swift`, `Universe Keyboard/Models/AppAboutContact.swift`
  - Tests: iPhone 17 `D3C353BE-3AA6-499B-8F87-349073D65BE4` — UniverseKeyboardTests 410 / 10 skipped; KeyboardTests 15
- **Handoff Target:** None for this Assignment; future commit or Release gates are separate
- **Revalidation Trigger:** Human changes channels, subject format, or whether privacy/OSS stay nested under About; Keyboard Extension is pulled into scope

## History

- `2026-09-28 Asia/Shanghai` — Human 锁定关于页入口、邮箱、小红书短链、邮件主题，并决定把隐私/开源入口挪进关于页。Assignment 进入 `Ready`。隔离 worktree，未改主工作区，无 Swift。
- `2026-09-28 Asia/Shanghai` — Human 确认实施 AUTH。Executor 交付关于页、设置 IA、搜索目录与测试绿。`Ready → Active → Completed`。无 Quality / Gate / commit。
- `2026-09-28 Asia/Shanghai` — Human 要求把 Debug 显示 Build 1、公测/正式版显示当次上传包构建号写进关于页合同与 [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md)。无 Swift 变更。
- `2026-09-28 Asia/Shanghai` — Human 授权独立 Quality。审查 **Pass with conditions**（`ABOUT-01`–`ABOUT-05` `accept`）。`Completed → Reviewed`。无 Product Gate / commit。
- `2026-09-28 Asia/Shanghai` — Human Product Owner 接受残差并授权 Product Gate。Assignment `Reviewed → Closed`。无 Device-attested / commit / push / PR / merge / TestFlight / Release。
