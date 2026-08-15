# Assignment: KEYBOARD-LAYOUT-9KEY-PUNCT-001 — 九键常用标点待确认与同键轮换

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` |
| **Phase** | Human 真机 Product Gate Passed（展开 / 组字后「你好，」/ 其余约定路径） |
| **Non-claims** | 未授权合并默认分支；未跑与 CI 等价的全套 xcodebuild |
| **Next** | 若要合入默认分支，先跑本地 CI 门禁再推功能分支 / PR |
| **Residuals** | Q2 条件仍在；真机已接受展开与组字顺序。`A2-P2-04` 未单独做撕裂矩阵 |

---

**Task ID:** `KEYBOARD-LAYOUT-9KEY-PUNCT-001`  
**Date / timezone:** `2026-08-15 Asia/Shanghai`  
**Repository Change Type:** `Product`（实现已授权 · ADR 0029）  
**Product Decision source:** [`PD-KEYBOARD-LAYOUT-9KEY-PUNCT-001`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PUNCT-001-authorization.md)

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner 当前会话 + 上述 PD，`2026-08-15 Asia/Shanghai`
- Product Approver: Human Product Owner / 当前 Product 线程

## Boundary

### Scope

Product Lead 于 `2026-08-15 Asia/Shanghai` 授权实现。范围：

1. 记录并保持与 PD 一致的九键标点合同：键面 `，。？！`；单击上屏待确认 `，`；候选栏替换；1.0 秒同键轮换 `，。？！`；候选点选后再点该键则新开逗号。
2. 实现落在：
   - KeyboardCore：pending 载荷、轮换窗、可注入时钟、候选清单、解散条件；
   - Keyboard Extension：键面文案、把该键从「只插逗号」接到 Core 动作、候选栏展示本地标点源。
3. 领域文档在实现授权后更新：`KEYBOARD_LAYOUT.md`（chrome 标签与交互）、必要时 ADR（本地标点候选源 / 新 `CandidateKind`）、相关 KeyboardCore 测试。
4. 拼音进行中先走现有「先提交首选再插符号」，再进入 pending 标点态。
5. 成对符号复用 `paired_symbol_completion_enabled`；pending 按整段载荷替换/删除，不假设长度为 1。

### Non-goals

- 系统整页标点盘、键区顶栏、`半` 角标、半角变体表
- 26 键 / 数字页 / 符号页标点改动
- 颜表情候选内容
- 修改 RIME `punctuator`、方案或 Extension 部署边界
- 九键字母 multi-tap / swipe
- 改 Path Bar、T9 拼音、post-commit continuation 合同
- 把 continuation 或 RIME 候选页直接拿来充当标点表

### Required Inputs

- [`PD-KEYBOARD-LAYOUT-9KEY-PUNCT-001`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PUNCT-001-authorization.md)
- [`KEYBOARD_LAYOUT.md`](../KEYBOARD_LAYOUT.md)（现行 chrome 仍写 `[,?!]`，以 Closed `KEYBOARD-LAYOUT-9KEY-UI-001` 为准，直到本项实现更新）
- [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) 候选栏规则
- `CandidateKind` / `CandidateBarDataSource` / `insertDirectText` 现行行为
- [`POST_COMMIT_CONTINUATION.md`](../POST_COMMIT_CONTINUATION.md)（明确不得混用）
- 系统九键参考截图（会话附件；`photos/` 若使用则保持 gitignore）

## Assignment

- Domain Owner: 🧠 Input Intelligence Maintainer（primary：pending 状态机、轮换窗、本地标点候选源）。⌨️ Keyboard Experience Maintainer 为 supporting domain（键面文案与候选栏呈现），不升格为第二 Domain Owner。
- Executor: 当前 Codex 会话（本线程）。Human Product Owner 于 `2026-08-15 Asia/Shanghai` 授权 Coordinator 完成任务级角色指定；实现仍须另一次授权。
- Environment Executor: 当前 Codex 会话 — 仅限本机 Simulator / `swift test` / `xcodebuild`。不得把 Simulator 结果写成真机 Product Gate。
- Human Dependency: Human Product Owner — 真机对照系统九键语义做 Product Gate；必要时补系统对照截图。自动化与独立 Review 不能替代这一步。
- Architecture Reviewer: 独立 Architecture reviewer subagent（🏛️ Architecture & Knowledge Steward playbook）。不得与 Executor 为同一 agent run。覆盖 ADR、候选源边界、不得并入 continuation / RIME。
- Quality Reviewer: 独立 Quality reviewer subagent（🧪 Quality, Performance & Release playbook）。不得与 Executor 或 Architecture Reviewer 为同一 agent run。覆盖测试矩阵、证据等级、热路径与门禁范围。
- Product Approver: Human Product Owner / 当前 Product 线程

角色依据：Human Product Owner 授权「必须由我操作的角色留给我，其余必要角色可分给独立 subagent」。这是 Product Lead 的 Assignment Decision，不是 Program Manager 自行推断。
长期领域边界见 [`VIRTUAL_ENGINEERING_TEAM.md`](../VIRTUAL_ENGINEERING_TEAM.md)；本指定不转移长期 ownership。

## Gates

### Entry Criteria

进入 `Ready` 之前必须全部满足：

- [x] 上表所有角色字段已由 Product Lead 授权的 Assignment Decision 指定，或写明审查过的 `Not Applicable` 理由
- [x] Product Lead 书面授权本阶段是「只写 ADR / 计划」：角色指定同时冻结下一阶段为 ADR，实现另需授权
- [x] 若实现会新增本地候选源或 `CandidateKind`，对应 ADR 至少进入可评审草稿，不得边写边发明合同 — [`0029`](../architecture/decisions/0029-t9-pending-punctuation-palette.md) `Accepted; implementation pending`
- [x] 独立 Architecture reviewer agent 已对 ADR **初稿**给出书面结论 — R1 `Pass with conditions`
- [x] 独立 Architecture reviewer agent 已对 ADR **修订稿**复审 — R2 `Pass`
- [x] Product Lead 书面授权实现阶段 — `2026-08-15 Asia/Shanghai`「授权实现」
- [x] 不占用第 11 个 Active Work 槽；进入 `Active` 时 Active Work 仍 ≤ 10

### Exit Criteria

实现若被授权，完成时至少交付：

- [ ] 键面为 `，。？！`
- [ ] 单击上屏待确认 `，`，候选栏出现 V1 本地标点表
- [ ] 候选点选替换 pending；之后再点该键新开 `，`
- [ ] 1.0 秒窗内同键按 `，。？！` 轮换并回绕；窗外同键接受并新开 `，`
- [ ] Delete 删除整段 pending 并退出；字母 / 空格 / 回车 / 切页 / 切英文接受并退出
- [ ] 拼音进行中先提交首选，再进入 pending
- [ ] 不污染 continuation，不把标点送进 RIME `selectCandidate`
- [ ] KeyboardCore 用可注入时钟覆盖：窗内轮换、窗外新开、候选替换、候选后同键新开、删除、组字中进入
- [ ] 更新 `KEYBOARD_LAYOUT.md`（以及被触达的 ADR / CHANGELOG）
- [x] Human Product Gate 对照系统九键语义（候选栏呈现允许与系统顶栏/整页盘不同）— Human `2026-08-15`：展开与组字顺序复验通过

实现相关 Exit 当前 **全部未满足**。角色指定阶段已完成。

### Stop Conditions

- 已指定角色被执行方擅自改派，或独立 Reviewer 与 Executor 合并为同一 agent run
- 跳过 ADR 直接改生产 Swift
- 未进 `Ready` 就开始改生产 Swift
- 把 pending 标点并进 continuation 或 RIME 候选页
- 把范围扩到整页标点盘、26 键或多击字母
- 轮换窗、轮换集合或「候选后同键 = 新开逗号」被实现擅自改掉
- 热路径同步持久化或无界日志
- Active Work 将超过 10 项仍被推进 `Active`

## Residuals (Q2 Quality)

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `Q2-C-01` / `A2-P2-04` | Human Product Gate | `accept` — 真机常规成对路径通过；**未做**中途撕裂矩阵 |
| `Q2-C-02` | Human Product Gate | `accept` — 真机未再复现；拆除失败 opener-only 仍无独立 Fake 用例 |
| `Q2-C-03` | Quality | `tech_debt` | 未跑 RimeBridge / 全套 App+Keyboard / Debug+Release build |
| `Q2-C-04` | Human Product Gate | `accept` — 真机已按下展开/下滑与标点键 |
| `Q-P2-02` | Input Intelligence | `tech_debt` | `ownedHostMutationGeneration` 只自增 |

## Residuals (R1 Architecture Review)

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `A-P0-01` | Executor / ADR 0029 | `fix` — 已写回 Decision §4 | [R1](keyboard-layout-9key-punct-001-architecture-review.md) · ADR 0029 修订稿 |
| `A-P0-02` | Executor / ADR 0029 | `fix` — 已写回 Decision §2 | 同上 |
| `A-P1-01` | Executor / ADR 0029 | `fix` — 已写回 Decision §5（0017 时序） | 同上 |
| `A-P1-02` | Product Lead | `accept` — 空格 = 接受后再插入空格；已补 PD | PD §6 |
| `A-P1-03` | Executor / ADR 0029 | `fix` — 已写回 Decision §3 | ADR 0029 §3 |
| `A-P2-01` | Architecture | `accept` | ADR 0029 §6 |
| `A-P2-02` | Product Lead | `accept` — 离开字母页即接受，含切 emoji；已补 PD | PD §6 |
| `A-P2-03` | Executor / ADR 0029 | `fix` — 已写回 `text == beforeCursor + afterCursor` | ADR 0029 §1 |

R1 针对修订前文本。R2 [`Pass`](keyboard-layout-9key-punct-001-architecture-rereview.md) 确认上表 P0/`fix` P1 已闭环。R2 新增观察全部 `accept`：

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `A2-P2-01` | Executor（实现时） | `accept` — 无首选组字残余态按 L1 拒绝 | [R2](keyboard-layout-9key-punct-001-architecture-rereview.md) |
| `A2-P2-02` | Executor（实现时） | `accept` — 无 span 的候选点选不得追加插入 | 同上 |
| `A2-P2-03` | Executor（实现时） | `accept` — 失权即清 pending | 同上 |
| `A2-P2-04` | Quality / Human Product Gate | `accept` — 成对手术中途撕裂不在 ADR 对账 | 同上 |


## Handoff

- Handoff Target: Executor 交付后交独立 Quality reviewer subagent。最终 Product Gate 交 Human Product Owner。
- Required Handoff Content:
  - 本 Assignment + PD 的产品合同摘要
  - ADR 草稿路径与未决架构分叉
  - 独立 Architecture / Quality 结论（开始 Review 后）
  - Simulator 证据与未执行的真机门
- Revalidation Trigger:
  - Product 改展示面、替换语义、1.0 秒、四键轮换集或候选后同键规则
  - 发现必须改 RIME punctuator 才能交付
  - Active Work 槽位冲突
  - Reviewer 独立性被破坏

## History

- `2026-08-15 Asia/Shanghai`：Product Lead 冻结合同并授权起草；本记录以 `Assignment Pending` 建立。未授权实现。
- `2026-08-15 Asia/Shanghai`：Product Lead 授权 Coordinator 指定任务角色，「只有必须由我操作的角色分配给我，其他必要角色可分给独立 subagent」。Lifecycle → `Assigned`。当前 Codex 会话接受 Executor / Environment Executor。独立 Reviewer 尚未 Acknowledge。实现仍未授权。
- `2026-08-15 Asia/Shanghai`：Executor 起草 [`ADR 0029`](../architecture/decisions/0029-t9-pending-punctuation-palette.md)（`Proposed`）。独立 Architecture Review 尚未开始。
- `2026-08-15 Asia/Shanghai`：独立 Architecture R1 = `Pass with conditions`（[`review`](keyboard-layout-9key-punct-001-architecture-review.md)）。
- `2026-08-15 Asia/Shanghai`：Product Lead 确认空格与离页规则；Executor 将 R1 的 P0 / `fix` P1 写回 ADR 0029 修订稿。实现仍未授权。
- `2026-08-15 Asia/Shanghai`：独立 Architecture R2 = `Pass`。Product Lead 接受 ADR 0029（`Accepted; implementation pending`）。R2 四条 P2 `accept`。实现仍未授权，生命周期保持 `Assigned`。
- `2026-08-15 Asia/Shanghai`：Product Lead「授权实现」。Entry Criteria 满足。Lifecycle → `Ready` → `Active`。占 Active Work 第 4 槽。
- `2026-08-15 Asia/Shanghai`：Executor 落地 pending 状态机、九键接线与 14 个 Core 用例。`swift test --package-path Packages/KeyboardCore` **1020/0**（`/tmp/keyboardcore-punct-build`）。未跑 RimeBridgeTests / App+Keyboard xcodebuild / 真机门。
- `2026-08-15 Asia/Shanghai`：独立 Quality Q1 = `Fail`（[`review`](keyboard-layout-9key-punct-001-quality-review.md)）。Executor 补齐 §7 / `A2-P2-02` / 键面接线测试；KeyboardCore 现 **1029/0**，`T9PendingPunctuationTests` 22/0。
- `2026-08-15 Asia/Shanghai`：独立 Quality Q2 = `Pass with conditions`（[`rereview`](keyboard-layout-9key-punct-001-quality-rereview.md)）。P1 三条闭合。不 Completed、不 Product Gate。
- `2026-08-15 Asia/Shanghai`：Human 反馈展开按钮缺失、组字后变成「，你好」。展开按钮复用 `.punctuationCandidate`；组字改为一次写入「词+，」。
- `2026-08-15 Asia/Shanghai`：Human 复验「都没有问题了」。Product Gate Passed。Lifecycle → `Completed`。不授权合并。
（[`rereview`](keyboard-layout-9key-punct-001-quality-rereview.md)）。P1 三条闭合。不 Completed、不 Product Gate。
