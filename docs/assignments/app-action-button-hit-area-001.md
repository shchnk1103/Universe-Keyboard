# Assignment: APP-ACTION-BUTTON-HIT-AREA-001 — 主 App 操作按钮整块可点

**Policy version:** `1.0.0`
**Task ID:** `APP-ACTION-BUTTON-HIT-AREA-001`
**Decision source / date:** [`PD-APP-ACTION-BUTTON-HIT-AREA-001`](../product-decisions/APP-ACTION-BUTTON-HIT-AREA-001-authorization.md), Human Product Owner hit-area lock, `2026-09-28 Asia/Shanghai`
**Repository Change Type:** `Implementation` + `Documentation`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` |
| **Phase** | Human Product Gate **Passed with accepted evidence conditions**；残差 `AABH-01`–`AABH-05` 均 `accept` |
| **Non-claims** | 不等于无条件 Quality Pass 或 Device-attested；不授权 merge、TestFlight 或 Release |
| **Next** | 隔离分支有界 commit / push / PR 进行中；merge 另授权 |
| **Residuals** | [`quality review`](../reviews/app-action-button-hit-area-001-quality-review.md) `AABH-01`–`AABH-05` `accept`；[`Product Gate`](../product-decisions/APP-ACTION-BUTTON-HIT-AREA-001-product-gate.md) 接受 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-APP-ACTION-BUTTON-HIT-AREA-001`](../product-decisions/APP-ACTION-BUTTON-HIT-AREA-001-authorization.md), `2026-09-28 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead
- **Authorization (record slice):** [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001.md) — consumed; Decision / Assignment / status mirrors only
- **Authorization (implementation slice):** [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-IMPLEMENT`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-IMPLEMENT.md) — consumed on delivery
- **Quality review:** [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-QUALITY`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-QUALITY.md) — consumed；[`review`](../reviews/app-action-button-hit-area-001-quality-review.md) **Pass with conditions**
- **Authorization (Product Gate):** [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE.md) — consumed
- **Product Gate:** [`PD-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE`](../product-decisions/APP-ACTION-BUTTON-HIT-AREA-001-product-gate.md) — **Accepted**
- **Authorization (scoped local commit):** [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-COMMIT`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-COMMIT.md) — consumed; implementation `08f37e5e48630d68670335b888a87d1b2330cd52`
- **Authorization (push / PR):** [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PUSH-PR`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PUSH-PR.md) — active / unconsumed until delivery

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | 本任务记录命中合同并实施共享 `contentShape`，不新增证据 claim。 |
| A-01 / B-01 authorization chain and briefing | Adopted | 本 Assignment、当前 Authorization receipt、Recorded Product Decision 构成本切片权威链。 |
| P-01 publication facts | Not applicable | 未授权 push / PR / hosted CI。 |
| D-01 final-documentation receipt | Not applicable | 本地 docs 写入不构成 D-01。 |
| H-02 / W-01 | Not applicable | 超出已采用的 v0.9.0 选择性范围。 |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current docs-only record | Authorized | `record_app_action_button_hit_area_product_decision_and_assignment` for `APP-ACTION-BUTTON-HIT-AREA-001` | Consumed [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001.md) |
| Main-App implementation | Authorized | Shared `AppActionButton` hit fill + tests + style-guide amendment | Consumed [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-IMPLEMENT`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-IMPLEMENT.md) |
| Independent Quality | Authorized | Shared `AppActionButton` full-capsule hit fill — Pass with conditions | Consumed [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-QUALITY`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-QUALITY.md) → [`review`](../reviews/app-action-button-hit-area-001-quality-review.md) |
| Human Product Gate | Authorized | Main-App hit-area acceptance; Assignment Closed | Consumed [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE.md) → [`PD-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE`](../product-decisions/APP-ACTION-BUTTON-HIT-AREA-001-product-gate.md) |
| Scoped local commit | Authorized | Isolated-branch implementation `08f37e5e48630d68670335b888a87d1b2330cd52` | Consumed [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-COMMIT`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-COMMIT.md) |
| Push / PR | In progress | Push isolated branch and open PR; Human observes CI | [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PUSH-PR`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PUSH-PR.md) |
| Merge | Not authorized | Merge to default branch | New AUTH required |
| Environment or external slice | Not applicable | 无 H-01 冻结载荷；实施后 Simulator 目视为可选 Human Dependency | 真机不是 `Ready` 前置 |

This is a manual advisory opt-in for A-01/B-01 only. This Assignment, its Authorization and its Product Decision are **not** Profile-included; validator coverage does not apply. Changing `.kos/project.json` requires a separate onboarding Assignment.

## Assignment

- **Domain Owner:** 📱 App & Data Operations Maintainer
- **Executor:** Current Grok session acting as App & Data Operations Maintainer / Main App UI
- **Environment Executor:** Current Grok session for Simulator / unit-test / build evidence
- **Human Dependency:** Human Product Owner — (1) record+implement start **done**; (2) Quality **done**; (3) Product Gate **done**; (4) optional physical-device glance remains uncollected and is not Device-attested
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward — **Not Applicable** while implementation stays inside existing `AppActionButton` and adds a hit-fill `contentShape`; **required** if a second button family is proposed, Liquid Glass is dropped, or keyboard chrome is pulled in
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer — independent review **Pass with conditions**（`AABH-01`–`AABH-05` `accept`）
- **Supporting Domain:** [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)
- **Handoff Target:** None for this Assignment; future commit or Release gates are separate

## Acknowledgement And Activation

- **Product Assignment Decision:** `2026-09-28 Asia/Shanghai` — Human 确认主 App 按钮应在可见区域任意位置生效，并授权按 M-06 范围记录与实施。
- **Executor acknowledgement (record slice):** `2026-09-28 Asia/Shanghai` — Scope、Non-goals、Stop Conditions 已接受。工作在隔离 worktree `/private/tmp/universe-keyboard-app-action-button-hit-area-001`，基线 `origin/main` `b92a59b91b15073f457cbb7cd856f015117f4ac7`，不触碰主工作区脏树。
- **Executor acknowledgement (implementation):** `2026-09-28 Asia/Shanghai` — Human 同一指示授权实施；`Ready → Active`；[`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-IMPLEMENT`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-IMPLEMENT.md)。
- **Entry Criteria status:** **Met** for `Active` implementation slice.
- **Product lifecycle decision:** `Ready → Active` on Human instruction “确认 APP-ACTION-BUTTON-HIT-AREA-001，AUTH 生效，按上述范围记录并实施”, `2026-09-28 Asia/Shanghai`.

## Boundary

### Scope

1. **Shared component.** 命中形状必须只活在 `AppActionButton`（及其可测试 chrome helper）。调用点继续传 `prominence` / `disabled`，不得在页面覆写 hit testing。
2. **Full visible capsule.** `.plain` 按钮与 `ShareLink` 变体的可见圆角胶囊（含 padding 与玻璃空白）都必须可点。
3. **Shape follows chrome.** 命中形状使用现有 `AppActionButtonChrome.cornerRadius` 连续圆角；不扩大视觉尺寸，不另做看不见的更大热区。
4. **Contrast unchanged.** 不改 `PD-APP-ACTION-BUTTON-CONTRAST-001` token。
5. **Documentation (implementation slice).** 代码落地后把 [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) 写成现行命中规则。
6. **Workspace hygiene.** 实施必须在隔离 worktree / 功能分支进行。禁止改主 checkout `/Users/doubleshy0n/Dev/Universe Keyboard` 上与本任务无关的脏文件。

### Non-goals

- Keyboard Extension UI、按键、候选栏
- 改变任何按钮的绑定、同步/下载/部署语义、默认 prominence
- 修改对比度、放弃 Liquid Glass、新增第二套按钮组件
- 修改 `AppSwitch` / Toggle 合同
- commit / push / merge
- Profile include / `required` mode
- TestFlight / Release / publication actions

### Required Inputs

- [`PD-APP-ACTION-BUTTON-HIT-AREA-001`](../product-decisions/APP-ACTION-BUTTON-HIT-AREA-001-authorization.md)
- [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001.md)
- [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-IMPLEMENT`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-IMPLEMENT.md)
- [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md)
- [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)
- Existing: `Universe Keyboard/Views/Components/AppActionButton.swift` and `UniverseKeyboardTests/AppActionButtonChromeTests.swift`
- Precedent contrast: [`APP-ACTION-BUTTON-CONTRAST-001`](app-action-button-contrast-001.md)
- Baseline: `origin/main` `b92a59b91b15073f457cbb7cd856f015117f4ac7`

## Gates

### Entry Criteria

- [x] Product Decision `PD-APP-ACTION-BUTTON-HIT-AREA-001` recorded with full-capsule hit lock
- [x] Domain Owner, Executor, Environment Executor, Human Dependency, Quality Reviewer named or justified
- [x] No required Assignment field is `UNKNOWN`
- [x] Isolated worktree used from `origin/main`
- [x] Implementation Authorization exists

### Exit Criteria

**Record slice**

- [x] Decision, Authorization, Assignment and Active Work / Dashboard mirrors exist.
- [x] Hit-area contract records the full visible capsule; contrast tokens stay out of scope.
- [x] Main checkout dirty tree is untouched.

**Implementation**

- [x] One shared hit-fill owner (`AppActionButtonChrome.hitFillShape`) applied to action and ShareLink variants
- [x] Chrome tests lock the hit shape to the visible corner radius (`testHitFillShapeMatchesTheVisibleCapsule`)
- [x] App + Keyboard Debug tests on `platform=iOS Simulator,id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2` (`iPhone 17 Pro`, iOS 26.0) — **TEST SUCCEEDED**: UniverseKeyboardTests **407** executed / **10** skipped / **0** failed (includes `AppActionButtonChromeTests` 9); KeyboardTests **15** / **0** failed
- [x] Swift format `--strict` on changed `.swift` files
- [x] `UI_STYLE_GUIDE.md` and `CHANGELOG.md` amended to the landed rule
- [x] Independent Quality **Pass with conditions** — [`app-action-button-hit-area-001-quality-review.md`](../reviews/app-action-button-hit-area-001-quality-review.md)；residuals `AABH-01`–`AABH-05` `accept`
- [x] Human Product Gate for Assignment `Closed` — [`PD-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE`](../product-decisions/APP-ACTION-BUTTON-HIT-AREA-001-product-gate.md); accepted Quality conditions; no Device-attested or Release claim

### Stop Conditions

Stop and escalate if:

- Implementation only patches one call site and leaves other `AppActionButton` instances
- Contrast tokens, Liquid Glass, or button product semantics change
- A second button family is introduced
- Keyboard Extension chrome is changed
- Work is applied onto the dirty main checkout
- An unscoped commit, push / PR / merge, TestFlight or Release is requested under this record
- Required evidence is fabricated

## Handoff

- **Required Handoff Content:**
  - Isolated worktree: `/private/tmp/universe-keyboard-app-action-button-hit-area-001`
  - Branch: `grok/app-action-button-hit-area-001` tracking `origin/main` @ `b92a59b91b15073f457cbb7cd856f015117f4ac7`
  - Shared owner: `Universe Keyboard/Views/Components/AppActionButton.swift` (`AppActionButtonChrome.hitFillShape` + label/capsule `contentShape`)
  - Tests: `xcodebuild` scheme `Universe Keyboard` Debug test, destination `platform=iOS Simulator,id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2` — **TEST SUCCEEDED**（UniverseKeyboardTests 407 / 10 skipped；KeyboardTests 15）。Not run: KeyboardCore-only, RimeBridgeTests, Release `build`.
  - Docs: `UI_STYLE_GUIDE.md`, `CHANGELOG.md`, Assignment / PD / Dashboard mirrors
  - Independent Quality **Pass with conditions**（`AABH-01`–`AABH-05` `accept`）
  - Product Gate 已接受；无实现 commit
- **Handoff Target:** None for this Assignment; future commit or Release gates are separate
- **Revalidation Trigger:** Human reverses the full-capsule hit rule; a new main-App action button surface is added outside `AppActionButton`; Keyboard Extension is pulled into scope; contrast tokens are rewritten in this slice

## History

- `2026-09-28 Asia/Shanghai` — Human 确认主 App 按钮应在可见区域任意位置生效，授权 `APP-ACTION-BUTTON-HIT-AREA-001` 记录并实施。Assignment 进入 `Active`。隔离 worktree，未改主工作区。
- `2026-09-28 Asia/Shanghai` — Executor 交付 `hitFillShape`、`contentShape`、指南修订与 App+Keyboard 测试绿。`Active → Completed`。无 Quality / Gate / commit。
- `2026-09-28 Asia/Shanghai` — Human 授权独立 Quality；[`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-QUALITY`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-QUALITY.md)。独立审查 **Pass with conditions**（[`review`](../reviews/app-action-button-hit-area-001-quality-review.md)；`AABH-01`–`AABH-05` `accept`）。`Completed → Reviewed`。无 Product Gate / commit。
- `2026-09-28 Asia/Shanghai` — Human Product Owner 接受残差并授权 Product Gate（[`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-PRODUCT-GATE.md)）。Product Gate 接受既有 Quality 条件，Assignment `Reviewed → Closed`。无 Device-attested / commit / push / PR / merge / TestFlight / Release。
- `2026-09-28 Asia/Shanghai` — Human 授权隔离分支有界 commit / push / PR。实现 commit `08f37e5e48630d68670335b888a87d1b2330cd52`；本回写记录该身份。无 merge。
