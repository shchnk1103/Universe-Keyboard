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
| PF-006 | P1 | Input Reliability | UNKNOWN | 清单称 Batch 1–3 已合并、剩余验证待完成；`ACTIVE_WORK` 第 6 项（INPUT-RELIABILITY-DELIVERY-003）当前为 Active，其余 delivery 项的处置未在本目录核实 | `docs/ACTIVE_WORK.md` 的第 6 项 | 2026-10-22 |
| PF-007 | P1 | RIME Deploy Crash / Recovery | UNKNOWN | 清单称 Stage C / D2 等验证未闭环；未核实 | 无 | 2026-10-22 |
| PF-008 | P1 | Keyboard Wake V3 | UNKNOWN | 清单称兼容性门禁待核实 | 无 | 2026-10-22 |
| PF-009 | P1 | Real RIME T9 Batch A | UNKNOWN | 清单称 Execution Preflight BLOCKED | 无 | 2026-10-22 |
| PF-010 | P1 | Next TestFlight Release Gate | UNKNOWN | 清单称等待稳定性验收 | 无 | 2026-10-22 |
| PF-011 | P2 | ClipboardLab | UNKNOWN | 清单称签名及测试阻断待核实 | 无 | 2026-10-22 |
| PF-012 | P2 | UI-3：候选字体大小 | Backlog | Human 2026-10-22 决定排在 UI-4 之后；需求与设计尚未冻结 | [ui-4-keyboard-height](portfolio/ui-4-keyboard-height.md)（同源讨论背景）；Human 本地未跟踪的 `docs/plans/keyboard-height-and-candidate-size-discussion-2026-10-08.md`（不在 `main`，内容未核实） | 2026-10-22 |
| PF-014 | P2 | KW002：Workspace Cleanup | UNKNOWN | 清单称 W1–W6 状态待核实 | 无 | 2026-10-22 |
| PF-015 | P2 | KTW001 / KTW002：Task Workspace | UNKNOWN | 清单称授权及环境阻断待处理 | 无 | 2026-10-22 |
| PF-016 | P2 | AI Budget Governance | UNKNOWN | 清单称已合并，待证据与集成核验 | 无 | 2026-10-22 |
| PF-017 | P3 | Branch Retention & Handoff Lifecycle | UNKNOWN | 清单称 BACKLOG、待差异审计；仓库内无对应来源 | 无 | 2026-10-22 |
| PF-018 | P1 | KOS 流程优化（交接、报告落盘、预检） | Backlog | 共 21 条候选（第 19 条为本目录，第 20、21 条为后续新增）；最先做：放行 Reviewer reports 目录、冻结 packet 前的路径扫描 | [kos-optimization](portfolio/kos-optimization.md) | 2026-10-22 |
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

## 已完成

| ID | 任务 | 完成依据 |
|---|---|---|
| PF-020 | 任务组合目录（种子） | PR #226（`b62bde1`），`docs/assignments/portfolio-directory-001.md` |
| PF-021 | 键盘数值文档 | PR #227（`477c042`），`docs/assignments/keyboard-values-doc-001.md` |
| PF-002 | UI-1 合并后状态同步 | PR #221（`9f7a88a`）；UI-2 的合并后同步与 PR #222（`7953e8b`，过期事实同步）各自的范围未在本目录核实，UNKNOWN |
| UI4-SPIKE-001 | UI-4 Technical Spike（限定结论已被Human接受，Close合并时生效） | [Spike Assignment](assignments/ui4-spike-001.md)；核对 2026-10-23；不代表UI-4产品开发完成 |

## 接手须知

1. 先读 `AGENTS.md`、`docs/KNOWLEDGE_INDEX.md`，再读本文件与你要接手的行的详情文档。
2. 用到某一行之前，核对它的“来源”仍然成立；`UNKNOWN` 行要先核实再动手。
3. 改动本目录是 docs-only 变更，走与其它文档相同的评审与发布流程。
4. 开工前先读本目录；对不上的行先修（走刷新流程）再动手，不要带着过期的行工作。
