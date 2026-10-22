# Portfolio — 任务组合目录（草稿）

这是**优先级与指针索引**，不是状态权威。Work Item 的 Lifecycle 以各自的 Assignment 为准，`docs/ACTIVE_WORK.md` 只列有 Assignment 的活动项；本目录负责记录“还没有 Assignment 的意图、优先级、依赖与已做的决定”，让任何 AI 接手时不依赖对话记忆。

## 规则

1. **一行一项，不设数量上限；行内只写一句话。** 讨论多、内容长的任务写进 `docs/portfolio/<ID>.md`，本表只放链接。
2. **状态只用这些词：** `Backlog`（未开始）、`Ready`（可派发）、`In progress`、`Blocked`、`Waiting Human`（等 Human 决定）、`Done`。写不出就写 `UNKNOWN`，不要猜。
3. **每行带“核对日期”和“来源”**：来源是 PR、Assignment 或 Product 决定的路径；没有来源的行状态一律是 `UNKNOWN`。超过 30 天没核对的行视为过期，接手者先重新核实再用。
4. **Done 的行移到文末“已完成”表**，本表只保留未完成项，保持文件短小。
5. **优先级变化、依赖、Human 的决定写进“决定记录”**（日期 + 一句话 + 指针），不要散落在对话里。
6. 本目录不替代 Assignment、Authorization、Product 决定或 `docs/TECH_DEBT.md`；与它们冲突时以那些文件为准，并修正本目录。

## 未完成（按优先级）

| ID | 优先级 | 任务 | 状态 | 下一步 / 阻塞 | 详情 / 来源 | 核对 |
|---|---|---|---|---|---|---|
| PF-001 | P0 | Main CI 失败（Run #705） | UNKNOWN | `Swift 6 Quality` 在 `e828a99` 上为绿（`main` 之后的 `64385fe` 上的结果未核实）；#705 根因与关闭记录未核实 | 无 | 2026-10-22 |
| PF-003 | P0 | KOS 全局任务对账（生命周期收尾） | In progress | 批次 1、1b、1c 已合并（PR #223、#224、#225）；剩余：链批次其余三项、A18、A28 / A29、同链 publication 子 Assignment、B 区 | [lifecycle-closeout](portfolio/lifecycle-closeout.md) | 2026-10-22 |
| PF-004 | P1 | Dynamic Task Portfolio（本目录是其种子） | Waiting Human | 需 Human 决定是否立项为正式 Assignment，以及目录放哪里 | [本文件](PORTFOLIO.md) | 2026-10-22 |
| PF-005 | P1 | UI-1 / UI-2 正式 Closeout | Blocked | UI-2 受 TD-020 约束；UI-1 的 Lifecycle 仍为 Active（PR216 post-merge sync 明确无完成 / 验收 / 独立复核声称），处置待 Human 另行决定 | `docs/ACTIVE_WORK.md` 的第 11、3 项 | 2026-10-22 |
| PF-006 | P1 | Input Reliability | UNKNOWN | 清单称 Batch 1–3 已合并、剩余验证待完成；`ACTIVE_WORK` 第 6 项（INPUT-RELIABILITY-DELIVERY-003）当前为 Active，其余 delivery 项的处置未在本目录核实 | `docs/ACTIVE_WORK.md` 的第 6 项 | 2026-10-22 |
| PF-007 | P1 | RIME Deploy Crash / Recovery | UNKNOWN | 清单称 Stage C / D2 等验证未闭环；未核实 | 无 | 2026-10-22 |
| PF-008 | P1 | Keyboard Wake V3 | UNKNOWN | 清单称兼容性门禁待核实 | 无 | 2026-10-22 |
| PF-009 | P1 | Real RIME T9 Batch A | UNKNOWN | 清单称 Execution Preflight BLOCKED | 无 | 2026-10-22 |
| PF-010 | P1 | Next TestFlight Release Gate | UNKNOWN | 清单称等待稳定性验收 | 无 | 2026-10-22 |
| PF-011 | P2 | ClipboardLab | UNKNOWN | 清单称签名及测试阻断待核实 | 无 | 2026-10-22 |
| PF-012 | P2 | UI-3：候选字体大小 | Backlog | 需求与设计待冻结 | `docs/plans/keyboard-height-and-candidate-size-discussion-2026-10-08.md`（Human 本地未跟踪文件，不在 `main`；内容与状态 UNKNOWN） | 2026-10-22 |
| PF-013 | P2 | UI-4：自定义键盘高度 | Backlog | 方案及约束待冻结 | 同上 | 2026-10-22 |
| PF-014 | P2 | KW002：Workspace Cleanup | UNKNOWN | 清单称 W1–W6 状态待核实 | 无 | 2026-10-22 |
| PF-015 | P2 | KTW001 / KTW002：Task Workspace | UNKNOWN | 清单称授权及环境阻断待处理 | 无 | 2026-10-22 |
| PF-016 | P2 | AI Budget Governance | UNKNOWN | 清单称已合并，待证据与集成核验 | 无 | 2026-10-22 |
| PF-017 | P3 | Branch Retention & Handoff Lifecycle | Backlog | 待差异审计 | 无 | 2026-10-22 |
| PF-018 | P1 | KOS 流程优化（交接、报告落盘、预检） | Backlog | 共 19 条候选（第 19 条即本目录）；最先做：放行 Reviewer reports 目录、冻结 packet 前的路径扫描 | [kos-optimization](portfolio/kos-optimization.md) | 2026-10-22 |
| PF-019 | P1 | Reviewer 独立性政策（按上下文隔离判断，分级 L1 到 L3） | Waiting Human | Human 已同意方向；待起草政策文本并经评审；不适用于已在进行的批次 | [kos-optimization](portfolio/kos-optimization.md) 第 17、18 条 | 2026-10-22 |

## 决定记录

| 日期 | 决定（Human Product Owner，除非另注） | 指针 |
|---|---|---|
| 2026-10-22 | 批准 D1（TYPO-CORRECTION-002 子项按批收尾）与 D7（同步记录评审后直接 Close） | [lifecycle-closeout](portfolio/lifecycle-closeout.md) |
| 2026-10-22 | 派发只指定角色，不固定 AI；报告开头声明实际运行时身份 | [kos-optimization](portfolio/kos-optimization.md) 第 10 条 |
| 2026-10-22 | Product Lead 明确 accept 批次 1c 的三处映射：J1（H4 的 detached 残项以 `…PUBLICATION-PREPARATION-001` 的 branch-identity 记录视为 `PD-B` 所要求的前置处置已满足）、J4、J5 | [lifecycle-closeout](portfolio/lifecycle-closeout.md) |
| 2026-10-22 | 同意方向：Reviewer 独立性放宽为“同一 AI 不同会话”，但按会话与加载的记忆共同判断，并分级、在报告里声明达到的级别；不改变正在进行的批次；政策文本待起草并评审 | [kos-optimization](portfolio/kos-optimization.md) 第 17、18 条 |
| 2026-10-22 | F-04 新建 tech_debt `TYPO-CORRECTION-002-F04-OPERATION-RECEIPT-DIAGNOSTICS`，放入批次 1c | [lifecycle-closeout](portfolio/lifecycle-closeout.md) |

## 已完成

| ID | 任务 | 完成依据 |
|---|---|---|
| PF-002 | UI-1 合并后状态同步 | PR #221（`9f7a88a`）；UI-2 的合并后同步与 PR #222（`7953e8b`，过期事实同步）各自的范围未在本目录核实，UNKNOWN |

## 接手须知

1. 先读 `AGENTS.md`、`docs/KNOWLEDGE_INDEX.md`，再读本文件与你要接手的行的详情文档。
2. 用到某一行之前，核对它的“来源”仍然成立；`UNKNOWN` 行要先核实再动手。
3. 改动本目录是 docs-only 变更，走与其它文档相同的评审与发布流程。
