# PF-016 — AI Budget Governance（AI 调用预算治理）

**状态：`Backlog`（Human Product Owner 于 2026-10-23 派发时确认）。** 本文是指针与讨论背景，**不是状态权威**；它不是 Requirement、ADR、Product Decision 或 Assignment，也不授权任何实施。正式规则以 [Assignment Policy](../ASSIGNMENT_POLICY.md) 与 [PD-KOS-UPGRADE-UK-006](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md) 为准；本文与它们冲突时以它们为准，并修正本文。

## 1. 范围说明

- 仓库里没有以“AI Budget Governance”为名的文档、代码、提交或 PR，这个名字只出现在 [Portfolio](../PORTFOLIO.md) 的 PF-016 行。
- 本文合并记录两部分：已正式采纳的 reviewer 预算条款（UK-006，第 3 节），以及 Human 与 ChatGPT 讨论过、尚未入库的完整方案（第 5 节）。
- PF-016 与 UK-006 是否完全对应：UNKNOWN。UK-006 只是其中已落地的相关部分。

## 2. 为什么做（Human / ChatGPT 讨论，未经仓库核对）

- 触发：多 AI 协作时，Grok Bot 曾在一天内消耗约 70% 的可用额度，其中一部分没有转化为工程进展。
- 当时的问题：角色调用过多；每次接手都要重读大量上下文；没有统一的预算分配者，也没有明确的停止条件；预算与质量门禁的关系没有规定。

## 3. 已正式采纳的部分（UK-006，仓库指针）

- 内容：KOS Kit v0.9.0 的 reviewer“范围 / 预算 / 停止条款”，属于选择性采纳。
- 产品决定：[PD-KOS-UPGRADE-UK-006](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md)（第 7 行 Status Accepted；第 9 行 Effective date 2026-09-25）。
- Assignment：[kos-upgrade-uk-006-v0.9.0-adoption](../assignments/kos-upgrade-uk-006-v0.9.0-adoption.md)（第 9 行 Lifecycle Completed）。
- 收尾回执：[post-merge state sync](../evidence/kos-upgrade-uk-006-v0.9.0-post-merge-state-sync-2026-09-25.md)。
- 发布：PR #170，合并提交 `1c14ab66d628f1a291b5484da0255c40492a80be`（回执第 12 行：2026-09-25T05:56:07Z）。收尾 PR #172，合并提交 `1ee2728`；收尾提交 `a26029e`。
- 规则正文：[Assignment Policy](../ASSIGNMENT_POLICY.md) 第 206 行起 “Independent Reviewer Lane Packet”（第 226–227 行预算与耗尽处理，第 228–229 行扩大须批准，第 244–245 行耗尽即停）；[AI Workflow](../AI_WORKFLOW.md) 第 60、64 行；`AGENTS.md` 第 24 行；[升级状态](../kos/UPGRADE_STATUS.md) 第 12、69 行；[Knowledge Index](../KNOWLEDGE_INDEX.md) 第 67 行；[Dashboard](../ENGINEERING_DASHBOARD.md) 第 228–231 行。
- 生效范围：2026-09-25 起新分配的独立 reviewer lane。已有 Active Assignment 和已分配的 lane 不追溯（[Assignment Policy](../ASSIGNMENT_POLICY.md) 第 253–254 行；[升级状态](../kos/UPGRADE_STATUS.md) 第 69–71 行）。

## 4. 明确没有采纳的部分（仓库指针）

- provider / model 路由、完整的可选 orchestration 包、全局 `ORCHESTRATION_PLAN`（[Assignment Policy](../ASSIGNMENT_POLICY.md) 第 251–253 行；产品决定第 10、49–51 行）。
- 强制模式变更、历史迁移、Active Assignment 回填（产品决定第 10 行 Non-claims）。

## 5. 讨论过但未采纳或未落地的想法（Human / ChatGPT 讨论，未经仓库核对）

以下内容都**不是**已采纳的规则，也**没有**实现：

- 方向：由 Coordinator 统一管理调用预算，每次角色调用都写明目的、输入、预期交付物和停止边界。机制以“角色调用次数与阶段预算”为基础，不按 Token 精确计费。
- Coordinator 统一派发；冻结 Reviewer Packet（已被 UK-006 采纳的部分见第 3 节）；审查范围不得自行扩张。
- 预算耗尽必须停止并报告 Partial / incomplete；没检查的部分不能算作通过。
- Delta Review：修复后只审变化部分，并复用仍然有效的旧证据。前提是基线与适用范围仍然成立。
- 预算治理与质量治理互补，不互相替代。
- “四次调用”阶段预算示例（Executor 1、冷启动恢复 1、Architecture 1、Quality 1）：只是早期试点方案，**不是**已采纳的全局上限，仓库文档里也找不到它。
- 讨论中明确不做：复杂的 Token 计费系统、自动 AI Provider 路由、与 Assignment 冲突的另一套预算权威。

## 6. 历史记录勘误

旧总结说“AI Budget Governance 通过 PR #54 合并，提交 `72c7379`”，这是错误引用：`72c7379` 在仓库里不是有效对象（`git rev-parse --verify 72c7379` 失败）；PR #54 的合并提交是 `809bd06`（`feat/td-011-native-usage-copy`），与预算治理无关。这条引用不得再作为任何证明使用。另有一处同类错误：“KW002 对应 PR #53”。PR #53 的合并提交是 `8a530a9`（TD-009），与 PF-016 无关，也不得当作本行证据。

## 7. 还缺什么（Human / ChatGPT 讨论中的下一步，未立项）

1. 规则差异审计：把第 3 节与第 5 节逐项对照。
2. 轻量使用记录试点：选一个新的低风险任务，记录角色派发、预算、检查点、实际消耗和停止原因。
3. 与本任务目录打通，让 Coordinator 能按优先级、依赖和已有审查结果决定调用计划。

以上三项都没有 Assignment、Product Decision 或授权。

## 8. 来源

- 仓库事实：`origin/main` `ba01a45472b8e52da8cdda3473c4031976d1db02`。上文行号于 2026-10-23 用只读 git 复核。
- 讨论内容：Human 与 ChatGPT 的讨论总结，在仓库外，未核对。
- 状态词 `Backlog`：Human Product Owner 于 2026-10-23 派发 PORTFOLIO-REFRESH-002 时确认。
