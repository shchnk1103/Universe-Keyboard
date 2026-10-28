# Assignment: KOS-DOC-UPDATE-001 — 把已定稿的 KOS 约定写入仓库文档

Policy version: 1.0.0
record_id: KOS-DOC-UPDATE-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | 阶段 B：docs-only 本地执行与提交；独立 Quality 评审待进行 |
| Material non-claims | 不含 push、PR 或 merge；不代表 Product Gate；`docs/PORTFOLIO.md` 未改 |
| Next handoff / decision | 独立 Quality Reviewer |

## Authority

- **Task ID / Title:** KOS-DOC-UPDATE-001 — 把已定稿的 KOS 约定写入仓库文档
- **Assignment Authority:** Product Lead
- **Decision Source / Date:** 2026-10-28（Asia/Shanghai）Human 对 PM 提问“四条 PM 提议（H1–H4）是否全部批准为正式 KOS 规则？”回答“全部批准”；外置阶段 B 任务包 `KOS-DOC-UPDATE-001/instructions/task-package-b.md` SHA-256 `9f30359415796d32a9f584f435e439f7e4c475c10bf8ef00e26927bc5a622fe2`；授权回执在该任务的 `reports/human-authorization-b-issued.md`，阶段 A 的授权回执为 `reports/human-authorization-issued.md`。
- **Product Approver:** Human Product Owner（Product Lead）

## Boundary

- **Scope:** 冻结编辑 E1–E4（`AGENTS.md`、`docs/ASSIGNMENT_POLICY.md`、`docs/portfolio/kos-optimization.md`）、本 Assignment、外置执行报告；一个本地提交。
- **Non-goals:** push、PR、merge；代码、测试、工程文件；构建与测试；`docs/PORTFOLIO.md` 的任何修改；删除任何分支或 worktree。
- **Required Inputs:** 外置任务目录 `instructions/` 中的冻结任务包与编辑清单，以及 `reports/` 中列出的阶段 A 报告与 Quality 评审；基线 `abd3c85a1ca731e35300c222d8a6a813f31a78b4`。

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Executor
- **Environment Executor:** Not Applicable — 仅仓库文档与本地 Git 操作
- **Human Dependency:** Human Product Owner 批准规则（已于 2026-10-28 批准）。
- **Architecture Reviewer:** Not Applicable — 仅文档，不改架构边界
- **Quality Reviewer:** Quality Reviewer
- **Product Approver:** Human Product Owner（Product Lead）

## Gates

- **Entry Criteria:** Human 激活；冻结输入哈希、基线及编辑锚点核对通过；隔离 worktree。
- **Exit Criteria:** E1–E4 与本 Assignment、差异与链接检查、被取代表述扫描、本地提交和执行报告；独立评审另行完成。
- **Stop Conditions:** 输入哈希不符；基线前进并触及范围文件；编辑锚点计数不是 1；需要改动 E1–E4 以外的仓库文字（本 Assignment 除外）；事实缺出处；写入被拒。

## Handoff

- **Handoff Target:** 独立 Quality Reviewer。
- **Required Handoff Content:** 提交 SHA、阶段 B 任务包与 `instructions/edits-b.md` 的 SHA-256、执行报告路径。
- **Revalidation Trigger:** 范围、基线、授权、输入或责任变化。

## Exit evidence

| 项 | Result |
|---|---|
| Executor | 外置任务目录 `reports/`；报告哈希由交付消息提供。 |
| Quality | 独立评审待进行；不预填结论。 |

## Closeout Decision

待独立 Quality 评审与 Human 决定；本地执行不构成 Close。
