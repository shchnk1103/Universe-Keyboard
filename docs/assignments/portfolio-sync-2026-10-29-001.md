# Assignment: PORTFOLIO-SYNC-2026-10-29-001 — 把已定稿的组合同步写入仓库文档

Policy version: 1.0.0
record_id: PORTFOLIO-SYNC-2026-10-29-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | 阶段 B：docs-only 本地执行与提交；独立 Quality 评审待进行 |
| Material non-claims | 不含 push、PR 或 merge；不代表 Product Gate |
| Next handoff / decision | 独立 Quality Reviewer |

## Authority

- **Task ID / Title:** PORTFOLIO-SYNC-2026-10-29-001 — 把已定稿的组合同步写入仓库文档
- **Assignment Authority:** Product Lead
- **Decision Source / Date:** 2026-10-29（Asia/Shanghai）Human 对 PF-044 的问题回答“A . 定为 P0，状态改为"进行中"吧”；Human 对“B34 和 KOS-DOC 两个已合并任务的 Assignment 现在要不要关闭？”与“新增的‘正式上线与订阅收费’（PF-059）定什么优先级？”回答“A A”；外置阶段 B 任务包 `PORTFOLIO-SYNC-2026-10-29-001/instructions/task-package-c.md` SHA-256 `7e3ea77a9076414deba79932c470c8e292bd64e1aa0f5cbab0f916ab96a3ae52`；授权回执在该任务的 `reports/human-authorization-b-issued.md`。
- **Product Approver:** Human Product Owner（Product Lead）

## Boundary

- **Scope:** 冻结编辑 E01–E17、E19（`AGENTS.md`、`docs/PORTFOLIO.md`、`docs/portfolio/kos-optimization.md`、`docs/assignments/kos-doc-update-001.md`、`docs/assignments/b34-commit-trace-001.md`）、本 Assignment、外置执行报告；一个本地提交。
- **Non-goals:** push、PR、merge；代码、测试、工程文件；构建与测试；E01–E17、E19 与本 Assignment 以外的任何文字改动；删除任何分支或 worktree；改 Human 主检出工作区。
- **Required Inputs:** 外置任务目录 `instructions/` 中的冻结任务包与编辑清单 `edits-c.json`、`items.md`，以及 `reports/` 中的阶段 A 报告与 Quality 评审；基线 `e53039339441ebe86301b1e77bcc978f244e88b4`。

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Executor
- **Environment Executor:** Not Applicable — 仅文档
- **Human Dependency:** Human Product Owner 决定 PF-044、PF-059 优先级与两个 Assignment 关闭（已于 2026-10-29 决定）。
- **Architecture Reviewer:** Not Applicable — 仅文档
- **Quality Reviewer:** Quality Reviewer
- **Product Approver:** Human Product Owner（Product Lead）

## Gates

- **Entry Criteria:** Human 激活；冻结输入哈希、基线及编辑锚点核对通过；隔离 worktree。
- **Exit Criteria:** E01–E17、E19 与本 Assignment、差异与链接检查、表格竖线计数、本地提交和执行报告；独立评审另行完成。
- **Stop Conditions:** 输入哈希不符；基线前进并触及范围文件；编辑锚点计数不是 1；需要改动 E01–E17、E19 与本 Assignment 以外的仓库文字；事实缺出处；写入被拒。

## Handoff

- **Handoff Target:** 独立 Quality Reviewer。
- **Required Handoff Content:** 提交 SHA、本任务包与 `instructions/edits-c.json` 的 SHA-256、执行报告路径。
- **Revalidation Trigger:** 范围、基线、授权、输入或责任变化。

## Exit evidence

| 项 | Result |
|---|---|
| Executor | 外置任务目录 `reports/`；报告哈希由交付消息提供。 |
| Quality | 独立评审待进行；不预填结论。 |

## Closeout Decision

待独立 Quality 评审与 Human 决定；本地执行不构成 Close。
