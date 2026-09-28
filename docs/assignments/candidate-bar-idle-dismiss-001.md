# Assignment: CANDIDATE-BAR-IDLE-DISMISS-001 — 空闲候选栏关闭键盘

**Policy version:** `1.0.0`
**Task ID:** `CANDIDATE-BAR-IDLE-DISMISS-001`
**Decision source / date:** [`PD-CANDIDATE-BAR-IDLE-DISMISS-001`](../product-decisions/CANDIDATE-BAR-IDLE-DISMISS-001-authorization.md), Human Product Owner idle-dismiss lock, `2026-09-28 Asia/Shanghai`
**Repository Change Type:** `Implementation` + `Documentation`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` |
| **Phase** | Human Product Gate **Passed with accepted evidence conditions**；残差 `CBID-01`–`CBID-04`、`CBID-CORNER` 均 `accept` |
| **Non-claims** | 不等于无条件 Quality Pass 或 Device-attested；不授权 commit / push / merge、TestFlight 或 Release |
| **Next** | 隔离分支有界 commit / push / PR 进行中；merge 另授权。`CBID-CORNER` 另开 |
| **Residuals** | [`quality review`](../reviews/candidate-bar-idle-dismiss-001-quality-review.md)；[`Product Gate`](../product-decisions/CANDIDATE-BAR-IDLE-DISMISS-001-product-gate.md) 接受 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-CANDIDATE-BAR-IDLE-DISMISS-001`](../product-decisions/CANDIDATE-BAR-IDLE-DISMISS-001-authorization.md), `2026-09-28 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead
- **Authorization (record slice):** [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001.md) — consumed; Decision / Assignment / status mirrors only
- **Authorization (implementation slice):** [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-IMPLEMENT`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-IMPLEMENT.md) — consumed on delivery
- **Quality review:** [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-QUALITY`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-QUALITY.md) — consumed；[`review`](../reviews/candidate-bar-idle-dismiss-001-quality-review.md) **Pass with conditions**
- **Authorization (Product Gate):** [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE.md) — consumed
- **Product Gate:** [`PD-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE`](../product-decisions/CANDIDATE-BAR-IDLE-DISMISS-001-product-gate.md) — **Accepted**
- **Authorization (scoped local commit):** [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-COMMIT`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-COMMIT.md) — active / unconsumed until delivery
- **Authorization (push / PR):** [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PUSH-PR`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PUSH-PR.md) — active / unconsumed until delivery

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
| Current docs-only record | Authorized | `record_candidate_bar_idle_dismiss_product_decision_and_assignment` for `CANDIDATE-BAR-IDLE-DISMISS-001` | Consumed [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001.md) |
| Keyboard UI implementation | Authorized | Dual-mode expand/dismiss on existing expand button | Consumed [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-IMPLEMENT`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-IMPLEMENT.md) |
| Independent Quality | Authorized | Expand vs dismiss glyphs, AX, swipe, all layouts — Pass with conditions | Consumed [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-QUALITY`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-QUALITY.md) → [`review`](../reviews/candidate-bar-idle-dismiss-001-quality-review.md) |
| Human Product Gate | Authorized | Idle dismiss acceptance; Assignment Closed | Consumed [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE.md) → [`PD-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE`](../product-decisions/CANDIDATE-BAR-IDLE-DISMISS-001-product-gate.md) |
| Scoped local commit | In progress | Isolated-branch commit + SHA writeback | [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-COMMIT`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-COMMIT.md) |
| Push / PR | In progress | Push isolated branch and open PR; Human observes CI | [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PUSH-PR`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PUSH-PR.md) |
| Merge | Not authorized | Merge to default branch | New AUTH required |
| Environment or external slice | Not applicable | 记录切片无设备动作 | 真机不是 `Ready` 前置 |

This is a manual advisory opt-in for A-01/B-01 only. This Assignment, its Authorization and its Product Decision are **not** Profile-included.

## Assignment

- **Domain Owner:** ⌨️ Keyboard Experience Maintainer
- **Executor:** Current Grok session acting as Keyboard Experience Maintainer / Keyboard UI
- **Environment Executor:** Current Grok session — App+Keyboard Debug on iPhone 17 `D3C353BE-3AA6-499B-8F87-349073D65BE4` (iOS 26.0)
- **Human Dependency:** Human Product Owner — (1) record start **done**; (2) implementation **done**; (3) Quality / Product Gate remain Human-gated
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward — **Not Applicable** while implementation stays on the existing expand-button slot and `dismissKeyboard()`; **required** if KeyboardCore candidate/continuation semantics change, a second button is added, or swipe-down dismiss is introduced
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer — independent review **Pass with conditions**（`CBID-01`–`CBID-04`、`CBID-CORNER` `accept`）
- **Supporting Domain:** [`playbooks/keyboard-ui.md`](../playbooks/keyboard-ui.md)
- **Handoff Target:** None for this Assignment; commit and `CBID-CORNER` follow-up are separate

## Acknowledgement And Activation

- **Product Assignment Decision:** `2026-09-28 Asia/Shanghai` — Human 锁定双模展开/关闭、全布局、圆圈图标、下滑不关闭，并授权按 KOS 写 Assignment。
- **Executor acknowledgement (record slice):** `2026-09-28 Asia/Shanghai` — Scope、Non-goals、Stop Conditions 已接受。工作在隔离 worktree `/private/tmp/universe-keyboard-candidate-bar-idle-dismiss-001`，基线 `origin/main` `fbb4eb3bbbc2926ff6e248db9dcdfdf6a331f821`，不触碰主工作区脏树。
- **Entry Criteria status:** **Met** for `Active` implementation slice.
- **Product lifecycle decision:** Assignment `Ready` on “确认，请先按 KOS 写 Assignment。”; `Ready → Active → Completed` on “确认 CANDIDATE-BAR-IDLE-DISMISS-001，AUTH 生效，按上述范围记录并实施”, `2026-09-28 Asia/Shanghai`.

## Boundary

### Scope

1. **Record slice (this AUTH).** 写入 PD / Assignment / AUTH，并同步 Active Work 与 Dashboard。不改 Swift。
2. **Implementation (future AUTH).** 现有 `CandidateBarExpandButton` 双模：有可展开内容 → `chevron.down` + 展开；无 → `chevron.down.circle` + `dismissKeyboard()`。宽度与命中 outset 不变。
3. **Expandable content.** RIME 候选、组字展示、上屏后联想、待选标点/颜文字。联想存在时保持展开。
4. **Gestures.** 下滑展开仅 Expand mode。Dismiss mode 只点按。
5. **Accessibility.** 标签与 Hint 随模式切换。
6. **Layouts.** 所有本键盘页面（候选栏始终在）。
7. **Docs (implementation).** 落地后修订 [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) Candidate Bar 展开键规则。
8. **Workspace hygiene.** 实施必须在隔离 worktree / 功能分支进行。禁止改主 checkout `/Users/doubleshy0n/Dev/Universe Keyboard` 上与本任务无关的脏文件。

### Non-goals

- 第二颗键、改候选栏高度、下滑关闭、展开面板内关闭
- KeyboardCore / 联想语义 / RimeBridge
- 主 App 设置开关
- 填满系统圆角顶左右外侧的宿主白底（Close 之后另开）
- commit / push / merge
- TestFlight / Release

### Required Inputs

- [`PD-CANDIDATE-BAR-IDLE-DISMISS-001`](../product-decisions/CANDIDATE-BAR-IDLE-DISMISS-001-authorization.md)
- [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001.md)
- [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md)
- [`POST_COMMIT_CONTINUATION.md`](../POST_COMMIT_CONTINUATION.md)
- [`playbooks/keyboard-ui.md`](../playbooks/keyboard-ui.md)
- Existing: `Keyboard/Views/CandidateBar/CandidateBarView.swift`, `KeyboardViewController+CandidateBar.swift`, `KeyboardViewController+ExpandedCandidatePanel.swift`
- Baseline: `origin/main` `fbb4eb3bbbc2926ff6e248db9dcdfdf6a331f821`

## Gates

### Entry Criteria

- [x] Product Decision recorded with dual-mode glyphs, expandable-content rule, swipe, AX, all layouts
- [x] Domain Owner, Executor, Environment Executor, Human Dependency, Quality Reviewer named or justified
- [x] No required Assignment field is `UNKNOWN`
- [x] Isolated worktree used from `origin/main`
- [x] Implementation Authorization exists

### Exit Criteria

**Record slice**

- [x] Decision, Authorization, Assignment and Active Work / Dashboard mirrors exist.
- [x] Dual-mode, continuation-still-expands, and swipe-does-not-dismiss are explicit.
- [x] Main checkout dirty tree is untouched.

**Implementation**

- [x] Dual-mode expand/dismiss lands on the existing button
- [x] KeyboardCore `CandidateKindTests` + KeyboardTests `CandidateBarIdleDismissContractTests`; App+Keyboard Debug on iPhone 17 `D3C353BE…` — **TEST SUCCEEDED**: UniverseKeyboardTests **410** / **10** skipped; KeyboardTests **16** / **0** failed
- [x] Swift format `--strict` on changed `.swift` files
- [x] `UI_STYLE_GUIDE.md` amended to the landed rule
- [x] Independent Quality **Pass with conditions** — [`candidate-bar-idle-dismiss-001-quality-review.md`](../reviews/candidate-bar-idle-dismiss-001-quality-review.md)；residuals `CBID-01`–`CBID-04`、`CBID-CORNER` `accept`
- [x] Human Product Gate for Assignment `Closed` — [`PD-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE`](../product-decisions/CANDIDATE-BAR-IDLE-DISMISS-001-product-gate.md); accepted Quality conditions; no Device-attested or Release claim

### Stop Conditions

Stop and escalate if:

- A second dismiss button or height change is introduced
- Swipe-down dismisses the keyboard
- Continuation suggestions steal the slot from expand
- KeyboardCore candidate/continuation semantics change
- Work is applied onto the dirty main checkout
- An unscoped commit, push / PR / merge, TestFlight or Release is requested under this record
- Required evidence is fabricated

## Handoff

- **Required Handoff Content:**
  - Isolated worktree: `/private/tmp/universe-keyboard-candidate-bar-idle-dismiss-001`
  - Branch: `grok/candidate-bar-idle-dismiss-001` tracking `origin/main` @ `fbb4eb3bbbc2926ff6e248db9dcdfdf6a331f821`
  - Locked contract: [`PD-CANDIDATE-BAR-IDLE-DISMISS-001`](../product-decisions/CANDIDATE-BAR-IDLE-DISMISS-001-authorization.md)
- **Handoff Target:** None for this Assignment; commit and `CBID-CORNER` follow-up are separate
- **Revalidation Trigger:** Human changes idle definition, glyphs, swipe, or layout coverage; KeyboardCore semantics are pulled in

## History

- `2026-09-28 Asia/Shanghai` — Human 锁定双模展开/关闭、全布局、空心圆图标、联想仍展开、下滑不关闭。Assignment 进入 `Ready`。隔离 worktree，未改主工作区，无 Swift。
- `2026-09-28 Asia/Shanghai` — Human 确认实施 AUTH。Executor 交付双模按钮与测试绿。`Ready → Active → Completed`。无 Quality / Gate / commit。
- `2026-09-28 Asia/Shanghai` — Human 要求修掉空闲关闭键白底。去掉 `UIButton.Configuration`，改用 template `chevron.down.circle`。无 Quality / Gate / commit。
- `2026-09-28 Asia/Shanghai` — Human 确认键盘顶左右圆角透白为既有 light-mode 现象，本切片保持现状；Close 之后另开工作。授权独立 Quality。
- `2026-09-28 Asia/Shanghai` — 独立 Quality **Pass with conditions**（`CBID-01`–`CBID-04`、`CBID-CORNER` `accept`）。`Completed → Reviewed`。无 Product Gate / commit。
- `2026-09-28 Asia/Shanghai` — Human Product Owner 接受残差并授权 Product Gate。Assignment `Reviewed → Closed`。`CBID-CORNER` 另开。无 Device-attested / commit / push / PR / merge / TestFlight / Release。
