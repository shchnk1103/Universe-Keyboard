# Portfolio — 任务组合目录

这是**优先级与指针索引**，不是状态权威。Work Item 的 Lifecycle 以各自的 Assignment 为准，`docs/ACTIVE_WORK.md` 只列有 Assignment 的活动项；本目录负责记录“还没有 Assignment 的意图、优先级、依赖与已做的决定”，让任何 AI 接手时不依赖对话记忆。

## 规则

1. **一行一项，不设数量上限；行内只写一句话。** 讨论多、内容长的任务写进 `docs/portfolio/<ID>.md`，本表只放链接。
2. **状态只用这些词：** `Backlog`（未开始）、`Ready`（可派发）、`In progress`、`Blocked`、`Waiting Human`（等 Human 决定）、`Done`。写不出就写 `UNKNOWN`，不要猜。
3. **每行带“核对日期”和“来源”**：来源是 PR、Assignment 或 Product 决定的路径；没有来源的行状态一律是 `UNKNOWN`。超过 30 天没核对的行视为过期，接手者先重新核实再用。
4. **Done 的行移到文末“已完成”表**，本表只保留未完成项，保持文件短小。
5. **优先级变化、依赖、Human 的决定写进“决定记录”**（日期 + 一句话 + 指针），不要散落在对话里。
6. 本目录不替代 Assignment、Authorization、Product 决定或 `docs/TECH_DEBT.md`；与它们冲突时以那些文件为准，并修正本目录。
7. **更新规则（Human 于 2026-10-22 采纳）：** 每个任务合并之后，在核对合并结果时顺带检查并更新本目录对应的行、决定记录与详情文档；发现过期行、缺来源行或状态错误时，单独起一次刷新；开工前先读本目录，对不上的先修再动手。

## 未完成（按优先级）

| ID | 优先级 | 任务 | 状态 | 下一步 / 阻塞 | 详情 / 来源 | 核对 |
|---|---|---|---|---|---|---|
| PF-001 | P0 | Main CI 失败（Run #705） | UNKNOWN | `Swift 6 Quality` 在 `e828a99`（run 39736213387）、`64385fe`（run 39747053667）与 `477c042`（run 39772862683）上均为 success（`gh run list` 核对于 2026-10-22）；#705 根因与关闭记录未核实 | 无 | 2026-10-22 |
| PF-003 | P0 | KOS 全局任务对账（生命周期收尾） | In progress | 批次 1、1b、1c 已合并（PR #223、#224、#225）；剩余：链批次其余三项、A18、A28 / A29、同链 publication 子 Assignment、B 区 | [lifecycle-closeout](portfolio/lifecycle-closeout.md) | 2026-10-22 |
| PF-004 | P1 | Dynamic Task Portfolio（完整 MVP） | UNKNOWN | 清单称“新增，待设计与立项”（Human 2026-10-22 提供，仓库内无记录）；其种子——本目录——已合并（PR #226，`b62bde1`），见 `docs/assignments/portfolio-directory-001.md`；完整 MVP 是否立项、范围与位置待 Human 决定 | `docs/assignments/portfolio-directory-001.md`（仅种子） | 2026-10-22 |
| PF-005 | P1 | UI-1 / UI-2 正式 Closeout | Blocked | UI-2 受 TD-020 约束；UI-1 的 Lifecycle 仍为 Active（PR216 post-merge sync 明确无完成 / 验收 / 独立复核声称），处置待 Human 另行决定 | `docs/ACTIVE_WORK.md` 的第 11、3 项 | 2026-10-22 |
| PF-013 | P1 | UI-4：自定义键盘高度 | Waiting Human | Spike 已完成并被 Human 接受；下一步由 Human 决定 Product Decision 的待决项（见详情）；Product Decision 与 UI-4 Assignment 尚未起草 | [ui-4-keyboard-height](portfolio/ui-4-keyboard-height.md) · [Spike 摘要](evidence/ui4-spike-001-summary.md) · [Spike Assignment](assignments/ui4-spike-001.md) | 2026-10-23 |
| PF-022 | P1 | 键盘数值核对脚本 | Backlog | 把 `docs/KEYBOARD_VALUES.md` 的数值与代码常量逐个比对，接入 `scripts/ci/run_lightweight_checks.sh`，让文档漂移在 CI 里暴露；尚未立项 | `docs/assignments/keyboard-values-doc-001.md`（评审后记录的后续候选） | 2026-10-22 |
| PF-006 | P1 | Input Reliability | In progress | 三份 `input-reliability-delivery-001/002/003.md` 的 Lifecycle 都是 Active；PR #213 `bb430f9`、#214 `d08175b`、#215 `096183c` 已合并；`docs/ACTIVE_WORK.md` 第 6 项为 Active。残项（真实 RIME T9 恢复集成、激活后 Extension 完整交互、Final Merge Gate 记录）UNKNOWN。Lifecycle 处置留给生命周期收尾批次，本行不处置 | `docs/assignments/input-reliability-delivery-001.md`、`input-reliability-delivery-002.md`、`input-reliability-delivery-003.md`；`docs/ACTIVE_WORK.md` 第 6 项 | 2026-10-23 |
| PF-007 | P1 | RIME Deploy Crash / Recovery | UNKNOWN | 不与 `RIME-DEPLOY-INTERRUPT-RECOVER-001`（Closed，PR #115）合并；是否同线 UNKNOWN | 无直接 Assignment；相关见 `docs/assignments/rime-deploy-interrupt-recover-001.md`（是否同线 UNKNOWN） | 2026-10-23 |
| PF-008 | P1 | Keyboard Wake V3 | Waiting Human | 有界发布已合并（PR #198）；三件相关 Assignment 已 Closed（`docs/ACTIVE_WORK.md` 第 45 行）；`keyboard-wake-diagnostic-v3-compatibility-gate-001` 仍为 Reviewed，父 Assignment Active，v6 合同待实现；是否关闭由 Human 决定 | `docs/ACTIVE_WORK.md` 第 45 行；`docs/assignments/keyboard-wake-diagnostic-v3-compatibility-gate-001.md` | 2026-10-23 |
| PF-009 | P1 | Real RIME T9 Batch A | UNKNOWN | 仓库内无 “Batch A” Assignment；相关线索是 real RIME T9 残项，是否同一所指 UNKNOWN | 无（仓库内无 “Batch A” Assignment；相关线索：`docs/assignments/input-reliability-delivery-003.md` 第 76 行的 real RIME T9 残项） | 2026-10-23 |
| PF-010 | P1 | Next TestFlight Release Gate | Blocked | 先决定这次 TestFlight 的范围，并逐项分类 `docs/RELEASE_CHECKLIST.md` 第 66–77 行的 TD-002 / 003 / 004 / 005；`docs/authorizations/AUTH-INPUT-RELIABILITY-DELIVERY-003-PRODUCT-PR.md` 第 10 行的真实 RIME T9 恢复集成与激活后 Extension 真实交互尚未处置；Human 打算在 UI-4 完成之后发布，无日期与候选构建（意向，不是授权） | [testflight-gates](portfolio/testflight-gates.md) | 2026-10-23 |
| PF-011 | P2 | ClipboardLab | UNKNOWN | 是否还要做：未说 | 无（仓库内无 ClipboardLab / smart-paste 记录；Human 认为与 clipboard-smart-paste-spike-001 同一件事，未经仓库核对） | 2026-10-23 |
| PF-012 | P2 | UI-3：候选字体大小 | Backlog | Human 2026-10-22 决定排在 UI-4 之后；需求与设计尚未冻结 | [ui-4-keyboard-height](portfolio/ui-4-keyboard-height.md)（同源讨论背景）；Human 本地未跟踪的 `docs/plans/keyboard-height-and-candidate-size-discussion-2026-10-08.md`（不在 `main`，内容未核实） | 2026-10-22 |
| PF-014 | P2 | KW002：Workspace Cleanup | UNKNOWN | 清单称 W1–W6 状态待核实；分支与 worktree 的清理见 PF-023 | 无（PR #53 = TD-009 `8a530a9`，与本行无关；相关规则 `AGENTS.md` 第 60–63 行） | 2026-10-23 |
| PF-015 | P2 | KTW001 / KTW002 试点 | UNKNOWN | `docs/tasks/` 下没有 KTW 目录；试点是否立项待 Human 决定 | 无（`docs/tasks/` 下没有 KTW 目录） | 2026-10-23 |
| PF-016 | P2 | AI Budget Governance | Backlog | 已落地部分为 UK-006 reviewer 范围 / 预算 / 停止条款（PR #170 `1c14ab6`，#172 收尾）；规则差异审计、轻量使用记录试点、与目录打通仍为讨论，未立项；PR #54 / `72c7379` 为错误引用 | [ai-budget-governance](portfolio/ai-budget-governance.md)；`docs/product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md` | 2026-10-23 |
| PF-017 | P3 | Branch Retention & Handoff Lifecycle | Backlog | 四种生命周期概念写在 PF-023；规则细节待定，未立项 | 无直接来源；相关既有规则 `AGENTS.md` 第 60–63 行、`docs/ASSIGNMENT_POLICY.md` 第 159 行；详情见 [branch-worktree-cleanup](portfolio/branch-worktree-cleanup.md) | 2026-10-23 |
| PF-018 | P1 | KOS 流程优化（交接、报告落盘、预检） | Backlog | 共 24 条候选（第 19 条为本目录，第 22–24 条为 2026-10-23 追加）；最先做：放行 Reviewer reports 目录、冻结 packet 前的路径扫描 | [kos-optimization](portfolio/kos-optimization.md) | 2026-10-23 |
| PF-023 | P2 | 分支与 worktree 的清理机制 | Backlog | 只读盘点已做；规则细节待定；本行不授权任何清理 | [branch-worktree-cleanup](portfolio/branch-worktree-cleanup.md) | 2026-10-23 |
| PF-024 | P2 | GitHub CI 的后续改进 | Backlog | Human 的想法：进一步拆分、更快、更易定位；只读分析认为拆分提速不是优先项；不改 CI | [ci-improvement](portfolio/ci-improvement.md) | 2026-10-23 |
| PF-025 | P2 | Release Evidence / 构建来源管理 | Backlog | Human 与 ChatGPT 的讨论，未核对；尚未立项 | 无直接来源；相关：`docs/RELEASE_CHECKLIST.md` | 2026-10-23 |
| PF-026 | P2 | RIME Sync / UI01 | UNKNOWN | Human 只留线索，之后有空再说 | 无（Human 不记得，只留线索，之后有空再说） | 2026-10-23 |
| PF-019 | P1 | Reviewer 独立性政策（按上下文隔离判断，分级 L1 到 L3） | Waiting Human | Human 已同意方向；待起草政策文本并经评审；不适用于已在进行的批次 | [kos-optimization](portfolio/kos-optimization.md) 第 17、18 条 | 2026-10-22 |

## 决定记录

| 日期 | 决定（Human Product Owner，除非另注） | 指针 |
|---|---|---|
| 2026-10-22 | 批准 D1（TYPO-CORRECTION-002 子项按批收尾）与 D7（同步记录评审后直接 Close） | [lifecycle-closeout](portfolio/lifecycle-closeout.md) |
| 2026-10-22 | 派发只指定角色，不固定 AI；报告开头声明实际运行时身份 | [kos-optimization](portfolio/kos-optimization.md) 第 10 条 |
| 2026-10-22 | Product Lead 明确 accept 批次 1c 的三处映射：J1（H4 的 detached 残项以 `…PUBLICATION-PREPARATION-001` 的 branch-identity 记录视为 `PD-B` 所要求的前置处置已满足）、J4、J5 | [lifecycle-closeout](portfolio/lifecycle-closeout.md) |
| 2026-10-22 | 同意方向：Reviewer 独立性放宽为“同一 AI 不同会话”，但按会话与加载的记忆共同判断，并分级、在报告里声明达到的级别；不改变正在进行的批次；政策文本待起草并评审 | [kos-optimization](portfolio/kos-optimization.md) 第 17、18 条 |
| 2026-10-22 | Product Lead 采纳目录更新规则：每个任务合并后顺带更新、问题触发时单独刷新、开工前先读并修；并同意在 `docs/READING_MAPS.md` 的 “Enter With Zero Context” 加必读来源 | 本文件规则 7；[portfolio-refresh-001](assignments/portfolio-refresh-001.md) |
| 2026-10-22 | 键盘数值文档（`docs/KEYBOARD_VALUES.md`）立项并合并（PR #227）；数值权威是代码，本文是带来源索引，改布局 / 高度 / 触摸 / 字号数值前先读；数值核对脚本列为后续候选（PF-022） | `docs/assignments/keyboard-values-doc-001.md` |
| 2026-10-22 | UI-4（键盘高度）先于 UI-3（候选字大小）；最高行高待模拟器实测后再定；没有完全访问时的行为待一次真机验证后再定；调节页面里键盘不能被真正按动（硬要求）；接受宿主限高时调高可能无效、横屏不能撑满屏幕（需要上限规则）；步进连续；验证用模拟器加 iPhone 13 Pro（iOS 27.0.1）；第一版功能可用即可，不追求拖动流畅度 | [ui-4-keyboard-height](portfolio/ui-4-keyboard-height.md) |
| 2026-10-22 | `PD001-ARCH-R2-F01`（PF-004 来源自指）：Product Lead accept，在本次刷新里修正 | `docs/assignments/portfolio-directory-001.md` |
| 2026-10-22 | F-04 新建 tech_debt `TYPO-CORRECTION-002-F04-OPERATION-RECEIPT-DIAGNOSTICS`，放入批次 1c | [lifecycle-closeout](portfolio/lifecycle-closeout.md) |
| 2026-10-23 | 接受 UI4-SPIKE-001 报告声明范围内的结论；补充3未经独立复核的边界保留，Close在承载记录的PR合并时生效 | [Spike Assignment](assignments/ui4-spike-001.md) · [摘要](evidence/ui4-spike-001-summary.md) |
| 2026-10-23 | UI-4 v1主App管理入口，键盘暂不放入口；调节页无用户可输入文字区域；完全访问开关均可调节，仅作建议提醒 | [UI-4详情](portfolio/ui-4-keyboard-height.md) |
| 2026-10-23 | 存储一个pt行高，按方向夹低不写回；横竖屏按屏高比例限制整块总高（含路径栏），比例待定，约50%/65%仅候选；v1不按设备算默认高度；均为方向决定、未实现 | [UI-4详情](portfolio/ui-4-keyboard-height.md) |
| 2026-10-23 | 下一次TestFlight打算在UI-4完成后发布；无具体日期、无候选构建，不是发布授权 | [UI-4详情](portfolio/ui-4-keyboard-height.md) |
| 2026-10-23 | D1–D6：PF-007 保持 UNKNOWN 且不与 `RIME-DEPLOY-INTERRUPT-RECOVER-001` 合并；PF-008 改为 Waiting Human，不移到已完成；PF-010 改为 Blocked；PF-011 保持 UNKNOWN；PF-014 保持 UNKNOWN，Cleanup Audit 未入库；PF-017 改为 Backlog | 本文件对应行；[testflight-gates](portfolio/testflight-gates.md)；[branch-worktree-cleanup](portfolio/branch-worktree-cleanup.md) |
| 2026-10-23 | PF-008 更正：三件 keyboard-wake Assignment 已 Closed、PR #198 已合并，但 `keyboard-wake-diagnostic-v3-compatibility-gate-001` 仍为 Reviewed，不移到已完成 | `docs/ACTIVE_WORK.md` 第 45 行；`docs/assignments/keyboard-wake-diagnostic-v3-compatibility-gate-001.md` |
| 2026-10-23 | PF-016 来源是 Human 与 ChatGPT 的讨论总结（仓库外，未核对）；旧总结“经 PR #54、提交 `72c7379` 合并”是错误引用，不得当证据 | [ai-budget-governance](portfolio/ai-budget-governance.md) |
| 2026-10-23 | Human 提出进一步拆分 GitHub CI；只读抽样后的发现是：最长几条 run 的主因是 TD-020 间歇失败后的重跑，拆分提速不是优先项。想法未立项 | [ci-improvement](portfolio/ci-improvement.md) |
| 2026-10-23 | Human 提出分支与 worktree 清理机制（合并 PF-014 / PF-017 的动机）；同意先做只读盘点（已由 Grok bot 完成）；规则细节待定；本次没有执行也没有授权清理 | [branch-worktree-cleanup](portfolio/branch-worktree-cleanup.md) |
| 2026-10-23 | Human 说明已不记得 PF-004 所指的那些事；这正是需要持久化任务管理系统的理由。不改变 PF-004 的行 | 本文件 PF-004 |

## 已完成

| ID | 任务 | 完成依据 |
|---|---|---|
| PF-020 | 任务组合目录（种子） | PR #226（`b62bde1`），`docs/assignments/portfolio-directory-001.md` |
| PF-021 | 键盘数值文档 | PR #227（`477c042`），`docs/assignments/keyboard-values-doc-001.md` |
| PF-002 | UI-1 合并后状态同步 | PR #221（`9f7a88a`）；UI-2 的合并后同步与 PR #222（`7953e8b`，过期事实同步）各自的范围未在本目录核实，UNKNOWN |
| UK-007 | KOS Task Workspace 采纳（UK-007） | `docs/assignments/kos-upgrade-uk-007-task-workspace.md` Closed；PR #211 `834c6af3`；产品决定 2026-10-18 Accepted，opt-in，不含自动跨平台接管。KTW 试点仍是未完成表的 PF-015（UNKNOWN） |
| UI4-SPIKE-001 | UI-4 Technical Spike（限定结论已被Human接受，Close合并时生效） | [Spike Assignment](assignments/ui4-spike-001.md)；核对 2026-10-23；不代表UI-4产品开发完成 |

## 接手须知

1. 先读 `AGENTS.md`、`docs/KNOWLEDGE_INDEX.md`，再读本文件与你要接手的行的详情文档。
2. 用到某一行之前，核对它的“来源”仍然成立；`UNKNOWN` 行要先核实再动手。
3. 改动本目录是 docs-only 变更，走与其它文档相同的评审与发布流程。
4. 开工前先读本目录；对不上的行先修（走刷新流程）再动手，不要带着过期的行工作。
