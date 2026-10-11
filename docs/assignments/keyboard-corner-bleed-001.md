# Assignment: KEYBOARD-CORNER-BLEED-001 — 键盘顶圆角透白

**Policy version:** `1.0.0`
**Task ID:** `KEYBOARD-CORNER-BLEED-001`
**Decision source / date:** [`PD-KEYBOARD-CORNER-BLEED-001`](../product-decisions/KEYBOARD-CORNER-BLEED-001-authorization.md), Human Product Owner follow-up open, `2026-09-28 Asia/Shanghai`
**Repository Change Type:** `Implementation` + `Documentation`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` |
| **Phase** | Human 锁定保持透明；无实施 |
| **Non-claims** | 不等于填灰、Quality Pass、TestFlight 或 Release |
| **Next** | 无（本 Assignment） |
| **Residuals** | None |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-KEYBOARD-CORNER-BLEED-001`](../product-decisions/KEYBOARD-CORNER-BLEED-001-authorization.md), `2026-09-28 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead
- **Authorization (record slice):** [`AUTH-KEYBOARD-CORNER-BLEED-001`](../authorizations/AUTH-KEYBOARD-CORNER-BLEED-001.md) — consumed
- **Authorization (close):** [`AUTH-KEYBOARD-CORNER-BLEED-001-CLOSE`](../authorizations/AUTH-KEYBOARD-CORNER-BLEED-001-CLOSE.md) — consumed
- **Authorization (scoped local commit):** [`AUTH-KEYBOARD-CORNER-BLEED-001-COMMIT`](../authorizations/AUTH-KEYBOARD-CORNER-BLEED-001-COMMIT.md) — consumed; `03cee43ffd638691c4fb5c3eb715519be1c01979`
- **Authorization (push / PR):** [`AUTH-KEYBOARD-CORNER-BLEED-001-PUSH-PR`](../authorizations/AUTH-KEYBOARD-CORNER-BLEED-001-PUSH-PR.md) — consumed；PR [#192](https://github.com/shchnk1103/Universe-Keyboard/pull/192)
- **Authorization (merge):** [`AUTH-KEYBOARD-CORNER-BLEED-001-MERGE`](../authorizations/AUTH-KEYBOARD-CORNER-BLEED-001-MERGE.md) — consumed；squash `72dd21710f2a86c9f951d489f645bae89b053b58`
- **Parent:** Closed [`CANDIDATE-BAR-IDLE-DISMISS-001`](candidate-bar-idle-dismiss-001.md) residual `CBID-CORNER`

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 | Not applicable | 记录切片不新增证据 claim。 |
| A-01 / B-01 | Adopted | 本 Assignment、AUTH、PD 构成本切片权威链。 |
| P-01 | Not applicable | 未授权 push / PR。 |
| D-01 | Not applicable | 本地 docs 写入不构成 D-01。 |
| H-02 / W-01 | Not applicable | 超出已采用的 v0.9.0 选择性范围。 |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current docs-only record | Authorized | `record_keyboard_corner_bleed_product_decision_and_assignment` | Consumed [`AUTH-KEYBOARD-CORNER-BLEED-001`](../authorizations/AUTH-KEYBOARD-CORNER-BLEED-001.md) |
| Keyboard UI implementation | Not authorized | Filling gray is rejected; keep transparent | Closed without implementation |
| Independent Quality | Not authorized | Light-mode top corners vs dark regression | New AUTH required |
| Human Product Gate | Not authorized | Corner-bleed acceptance | New AUTH required |
| Scoped local commit | Authorized | Isolated-branch docs `03cee43ffd638691c4fb5c3eb715519be1c01979` | Consumed [`AUTH-KEYBOARD-CORNER-BLEED-001-COMMIT`](../authorizations/AUTH-KEYBOARD-CORNER-BLEED-001-COMMIT.md) |
| Push / PR | Authorized | Push `grok/keyboard-corner-bleed-001` and open PR [#192](https://github.com/shchnk1103/Universe-Keyboard/pull/192); Human observes CI | Consumed [`AUTH-KEYBOARD-CORNER-BLEED-001-PUSH-PR`](../authorizations/AUTH-KEYBOARD-CORNER-BLEED-001-PUSH-PR.md) |
| Merge | Authorized | Squash-merge PR [#192](https://github.com/shchnk1103/Universe-Keyboard/pull/192) as `72dd21710f2a86c9f951d489f645bae89b053b58` | Consumed [`AUTH-KEYBOARD-CORNER-BLEED-001-MERGE`](../authorizations/AUTH-KEYBOARD-CORNER-BLEED-001-MERGE.md) |
| Environment or external slice | Not applicable | 记录切片无设备动作 | 真机不是 `Ready` 前置 |

This is a manual advisory opt-in for A-01/B-01 only. Not Profile-included.

## Assignment

- **Domain Owner:** ⌨️ Keyboard Experience Maintainer
- **Executor:** Current Grok session acting as Keyboard Experience Maintainer / Keyboard UI
- **Environment Executor:** Not Applicable for this record slice
- **Human Dependency:** Human Product Owner — (1) record start **done**; (2) implementation AUTH still required; (3) later Quality / Product Gate remain Human-gated；light 模式目视顶角
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward — **Not Applicable** while only filling the rectangular backing without a second rounded chrome; **required** if a second `cornerRadius` frame or glass restyle is proposed
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer — **Not authorized** until a later AUTH
- **Supporting Domain:** [`playbooks/keyboard-ui.md`](../playbooks/keyboard-ui.md)
- **Handoff Target:** None for this Assignment

## Acknowledgement And Activation

- **Product Assignment Decision:** `2026-09-28 Asia/Shanghai` — Human 授权开 `CBID-CORNER` 跟进切片。
- **Executor acknowledgement (record slice):** `2026-09-28 Asia/Shanghai` — Scope、Non-goals、Stop Conditions 已接受。隔离 worktree `/private/tmp/universe-keyboard-keyboard-corner-bleed-001`，基线 `origin/main` `5710d340e9ec2df4acedc06eeb429e9fd5f97bff`，不触碰主工作区脏树。
- **Entry Criteria status:** **Met** for `Ready` record slice.
- **Product lifecycle decision:** Assignment `Ready` on “授权开键盘顶圆角透白跟进切片。”; `Ready → Closed` on “关掉本切片，透明就是目标。”, `2026-09-28 Asia/Shanghai`.

## Boundary

### Scope

1. **Record slice (this AUTH).** 写入 PD / Assignment / AUTH，并同步 Active Work 与 Dashboard。不改 Swift。
2. **Implementation (future AUTH).** 用现有 `keyboardBackgroundColor` 填满输入视图矩形 backing，使系统圆角顶左右不再透出宿主白。不自设第二层 `cornerRadius`。不改关闭键。
3. **Docs (implementation).** 落地后修订 [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) 键盘表面规则。
4. **Workspace hygiene.** 实施必须在隔离 worktree 进行。

### Non-goals

- 第二套圆角玻璃框、切底角
- 改关闭/展开双模、候选栏、按键配色
- KeyboardCore / RimeBridge / 主 App
- commit / push / merge / TestFlight / Release

### Required Inputs

- [`PD-KEYBOARD-CORNER-BLEED-001`](../product-decisions/KEYBOARD-CORNER-BLEED-001-authorization.md)
- [`AUTH-KEYBOARD-CORNER-BLEED-001`](../authorizations/AUTH-KEYBOARD-CORNER-BLEED-001.md)
- Parent Gate residual `CBID-CORNER`
- `KeyboardViewController+Presentation.swift`, `KeyboardViewController+KeyStyle.swift`
- Baseline: `origin/main` `5710d340e9ec2df4acedc06eeb429e9fd5f97bff`

## Gates

### Entry Criteria

- [x] Product Decision recorded with fill-backing / no second rounded frame
- [x] Domain Owner, Executor, Environment Executor, Human Dependency, Quality Reviewer named or justified
- [x] No required Assignment field is `UNKNOWN`
- [x] Isolated worktree used from `origin/main`
- [x] Implementation Authorization — **not issued; slice Closed without Swift**

### Exit Criteria

**Record slice**

- [x] Decision, Authorization, Assignment and Active Work / Dashboard mirrors exist.
- [x] Parent `CBID-CORNER` is the named residual this Assignment owns.
- [x] Main checkout dirty tree is untouched.

**Implementation**

- [ ] Light-mode top-left/right fillets no longer show host white
- [ ] Dark mode has no new light halo
- [ ] Idle dismiss control unchanged
- [ ] Swift format `--strict` on changed `.swift` files
- [ ] App+Keyboard Debug tests
- [ ] Independent Quality — **not in this AUTH**
- [ ] Human Product Gate — **not in this AUTH**

### Stop Conditions

Stop and escalate if:

- A second rounded chrome frame is required
- Filling the backing does not cover the white because it sits outside the input view
- Idle dismiss behavior or candidate-bar layout changes
- Work is applied onto the dirty main checkout
- Unscoped commit / push / merge / TestFlight / Release is requested
- Required evidence is fabricated

## Handoff

- **Required Handoff Content:**
  - Isolated worktree: `/private/tmp/universe-keyboard-keyboard-corner-bleed-001`
  - Branch: `grok/keyboard-corner-bleed-001` tracking `origin/main` @ `5710d340e9ec2df4acedc06eeb429e9fd5f97bff`
  - Locked contract: [`PD-KEYBOARD-CORNER-BLEED-001`](../product-decisions/KEYBOARD-CORNER-BLEED-001-authorization.md)
- **Handoff Target:** None for this Assignment
- **Revalidation Trigger:** Human changes fill vs second-frame; white proven outside input view

## History

- `2026-09-28 Asia/Shanghai` — Human 授权开键盘顶圆角透白跟进（parent `CBID-CORNER`）。Assignment 进入 `Ready`。隔离 worktree，未改主工作区，无 Swift。
- `2026-09-28 Asia/Shanghai` — Human 关闭切片：透明就是目标，不填灰。`Ready → Closed`。无实施 / commit。
- `2026-09-28 Asia/Shanghai` — Human 授权 docs-only commit / push / PR。实现 commit `03cee43ffd638691c4fb5c3eb715519be1c01979`；SHA 回写 `6a126082f226cb9ad4a08d8ca69bd93dd747f70a`。无 merge。
- `2026-09-28 Asia/Shanghai` — 已推送隔离分支并开 PR [#192](https://github.com/shchnk1103/Universe-Keyboard/pull/192)。Executor 不 merge。Human 观察 hosted CI。
- `2026-09-28 Asia/Shanghai` — Human 授权 merge 与收尾。PR [#192](https://github.com/shchnk1103/Universe-Keyboard/pull/192) squash-merged `72dd21710f2a86c9f951d489f645bae89b053b58`（same-head docs_only CI run 36439127888）。远端功能分支已删。无 TestFlight / Release。
