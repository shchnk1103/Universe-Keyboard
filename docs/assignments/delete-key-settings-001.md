# Assignment: DELETE-KEY-SETTINGS-001 — 删除键设置页

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Reviewed` |
| **Phase** | 第二次独立 Product Gate 为 Pass。digest `bb87845b`。第一次 Gate 仍是 Partial / incomplete。本地 commit 已授权，SHA 由随后回写记录 |
| **Non-claims** | Reviewed 不等于 Close、TestFlight 或 Release。本地 commit 不等于 push。不重开已 Closed 的 `DELETE-KEY-SCRUB-001` |
| **Next** | push、PR、merge 仍未授权 |
| **Residuals** | 第二次 Gate 无新开放残留。第一次 Partial 不升成 Pass，其审查页保持原样。Quality 未留开放残留。`R-DELETE-KEY-SETTINGS-001-ARCH-1` 的修补已含在本次 Gate 字节里。DKS-CLOSE-01 / DKS-CLOSE-02 在对应开关为开时保持原行为 |

---

- **Task ID:** `DELETE-KEY-SETTINGS-001`
- **Date / timezone:** `2026-10-07 Asia/Shanghai`
- **Repository Change Type:** `Feature` + `Implementation`
- **Product Decision source:** [`PD-DELETE-KEY-SETTINGS-001`](../product-decisions/DELETE-KEY-SETTINGS-001-product-contract.md)

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner 当前会话，`2026-10-07 Asia/Shanghai`，「授权你按照远程main分支最新的KOS设定，开始这项工作吧」
- Product Approver: Human Product Owner / 当前 Product 线程
- Authorization (implementation): [`AUTH-DELETE-KEY-SETTINGS-001-IMPLEMENT`](../authorizations/AUTH-DELETE-KEY-SETTINGS-001-IMPLEMENT.md) — active，直到本 commit 回写绑定 SHA
- Authorization (commit): [`AUTH-DELETE-KEY-SETTINGS-001-COMMIT`](../authorizations/AUTH-DELETE-KEY-SETTINGS-001-COMMIT.md) — active / unconsumed
- Authorization (architecture): [`AUTH-DELETE-KEY-SETTINGS-001-ARCHITECTURE`](../authorizations/AUTH-DELETE-KEY-SETTINGS-001-ARCHITECTURE.md) — consumed
- Authorization (quality): [`AUTH-DELETE-KEY-SETTINGS-001-QUALITY`](../authorizations/AUTH-DELETE-KEY-SETTINGS-001-QUALITY.md) — consumed
- Authorization (product gate): [`AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE`](../authorizations/AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE.md) — consumed，Partial / incomplete
- Authorization (product gate 002): [`AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE-002`](../authorizations/AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE-002.md) — consumed，Pass

## KOS v0.9.0 optional-contract selection

项目 pin 为 [`PD-KOS-UPGRADE-UK-006`](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md) advisory。本 Assignment **未** Profile-include。E-01 / P-01 / D-01 不 opt-in。A-01/B-01 为手工 advisory。新指定的独立审查车道适用 v0.9.0 reviewer scope/budget/stop。

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | 交付用 KeyboardCore 单测与既有 KeyboardTests 源码合同 |
| A-01 / B-01 authorization chain and briefing | Adopted (advisory, not Profile-included) | 本 Assignment、IMPLEMENT 与产品合同构成本切片权威链 |
| P-01 publication facts | Not applicable | 未授权 commit / push / PR |
| D-01 final-documentation receipt | Not applicable | 本切片不宣称 D-01 |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Settings implementation | Authorized / live | `implement_delete_key_settings` | Active [`AUTH-DELETE-KEY-SETTINGS-001-IMPLEMENT`](../authorizations/AUTH-DELETE-KEY-SETTINGS-001-IMPLEMENT.md) |
| Independent Architecture | Concluded | Conditional Accept。[`architecture-review`](../reviews/delete-key-settings-001-architecture-review.md)。digest `517c13eb`。该 AUTH 不覆盖审查后的滑回修补 | Consumed [`AUTH-DELETE-KEY-SETTINGS-001-ARCHITECTURE`](../authorizations/AUTH-DELETE-KEY-SETTINGS-001-ARCHITECTURE.md) |
| Independent Quality | Concluded | Pass。[`quality-review`](../reviews/delete-key-settings-001-quality-review.md)。digest `69b35d41`。该 AUTH 不授权 Product Gate 或 commit | Consumed [`AUTH-DELETE-KEY-SETTINGS-001-QUALITY`](../authorizations/AUTH-DELETE-KEY-SETTINGS-001-QUALITY.md) |
| Independent Product Gate | Concluded incomplete | Partial / incomplete。[`product-gate`](../reviews/delete-key-settings-001-product-gate.md)。digest `f1458883`。超过 30 次工具调用，不升成 Pass | Consumed [`AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE`](../authorizations/AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE.md) |
| Independent Product Gate 002 | Concluded | Pass。[`product-gate-002`](../reviews/delete-key-settings-001-product-gate-002.md)。digest `bb87845b`。十四条符合。无新开放残留。不授权 Close 或 commit | Consumed [`AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE-002`](../authorizations/AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE-002.md) |
| Local commit | Authorized | 隔离分支上的内容 commit 加 SHA 回写。不含 push | Active [`AUTH-DELETE-KEY-SETTINGS-001-COMMIT`](../authorizations/AUTH-DELETE-KEY-SETTINGS-001-COMMIT.md) |
| Push / PR / merge | Not authorized | 无 | 无 |

## Boundary

### Scope

1. 主 App「设置 → 输入体验」在「键盘反馈」后增加子页「删除键」。三个开关默认开：长按垃圾桶、滑动擦除、组字时左滑。
2. 点按删除和长按重复始终可用。本页不放长按开关，也不解释长按。
3. 缺省 UserDefaults 键视为开。键盘在删除键 `touchDown` 读一次，本次按住中途改开关不影响这一次。
4. 滑动关闭后，手指离开删除键即停止本次删除；垃圾桶仍开时，先穿过键与气泡之间的缝，只有走进气泡再松手才清空。滑回键上不恢复重复，松手也不再补一次点按删除。
5. 26 键、九键、英文、数字、符号共用这三个开关。发声和触感仍在「键盘反馈」。
6. 同一未提交切片写入 `CHANGELOG.md`。占用 Active Work 第 6 号空位。只写隔离 worktree `/private/tmp/universe-keyboard-delete-key-settings-001`，分支 `grok/delete-key-settings-001`，基线 `origin/main` `141bc8ebcee456cfac8f8c826da9d6ce4e9e5b4f`。

### Non-goals

- 不重开、不改写 `DELETE-KEY-SCRUB-001` 的冻结合同、Gate 或 Close
- 不改 0.5s / 0.08s / 0.15s 节奏，不改按键音和触感表
- 不把 256 字素上限或「读不到上下文就不出气泡」写进设置文案
- 不授权独立 Architecture / Quality 结论、Product Gate、commit、push、merge、TestFlight 或 Release

### Required Inputs

- 本会话已定稿的开关文案与离开按键规则
- 已在 `origin/main` 的删除键 V1 实现
- [`playbooks/keyboard-ui.md`](../playbooks/keyboard-ui.md) 与 [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)

## Assignment

- Domain Owner: ⌨️ Keyboard Experience Maintainer
- Executor: Current Grok session。Human 以「授权你……开始这项工作」指定本会话
- Environment Executor: Current Grok session — KeyboardCore `swift test`，以及 KeyboardTests 合同测跑在已启动的 iPhone 18 Pro `405D994F-28CB-4F89-BB22-B64AD81C05A2`。CI 文档默认机型仍是 iPhone 17 Pro
- Human Dependency: Human Product Owner — Product Approver。本切片不要求真机安装。第二次独立 Product Gate 为 Pass
- Architecture Reviewer: 🏛️ Architecture & Knowledge Steward — 独立 Grok 4.7 subagent，一次审查已完成。Stop：改点按/长按节奏、长按开关、改写已冻结删除键合同、`selectAll`、上传宿主文本、新 host 写入路径。禁止 git `/review` 替代
- Quality Reviewer: 🧪 Quality, Performance & Release Maintainer — 独立 Grok 4.7 subagent，一次审查已完成。Budget：一次审查，并复现 KeyboardCore 与 KeyboardTests 命令
- Product Gate reviewer: 独立 Grok 4.7 subagent。第一次 Partial / incomplete。第二次 Pass，digest `bb87845b`。禁止 git `/review` 替代
- Product Approver: Human Product Owner / 当前 Product 线程
- Supporting Domain: Keyboard UI 与 Main App UI

责任人沿用同日 Human 已接受的删除键车道（「按建议填责任人」）。本消息没有改派审查人。若 Product 不接受此沿用，把对应字段改回 `UNKNOWN` 并退出 Active。

## Acknowledgement And Activation

- **Product Assignment Decision:** `2026-10-07 Asia/Shanghai` — Human 授权按 `origin/main` 现行 KOS 开工，并指定本会话执行。
- **Executor acknowledgement:** `2026-10-07 Asia/Shanghai` — Scope、Non-goals、Stop Conditions 已接受。不触碰主工作区脏树。
- **Entry Criteria status:** **Met** for `Active` implementation。审查结论是后续 Gate，不是本次开工的前置。
- **Product lifecycle decision:** `Assignment Pending → Ready → Active` on 「授权你按照远程main分支最新的KOS设定，开始这项工作吧」.

## Product Contract

行为细节以 [`PD-DELETE-KEY-SETTINGS-001`](../product-decisions/DELETE-KEY-SETTINGS-001-product-contract.md) 为准。三个开关都开、或键不存在时，手势与现在的 V1 相同。
