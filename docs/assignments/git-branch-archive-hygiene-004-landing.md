# Assignment: GIT-BRANCH-ARCHIVE-HYGIENE-004-LANDING — 登记合并后清理 Assignment 与 AGENTS 规则

Policy version: 1.0.0
record_id: GIT-BRANCH-ARCHIVE-HYGIENE-004-LANDING

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | 本地文档交付 |
| Material non-claims | 不执行分支或 worktree 删除；不改 GitHub 设置；不声称 Product Gate、TestFlight 或 Release；不声称 GIT-BRANCH-ARCHIVE-HYGIENE-004 已开始执行 |
| Next handoff / decision | Human 决定是否发布本记录 |

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner，2026-10-26 Asia/Shanghai。任务包 `~/.kos-work/Universe-Keyboard/GIT-BRANCH-ARCHIVE-HYGIENE-004-LANDING/instructions/task-package.md`，SHA-256 `f885c20a4229af9dff6819e1d37d69ef65a620f305edaa3f06ea6eb2b31b4086`。Human 决定原文 `1A 2A 3A 4A 5A 6A 7B`。
- **Product Approver:** Human Product Owner（Product Lead）

## Boundary

- **Scope:** 新建 [GIT-BRANCH-ARCHIVE-HYGIENE-004](git-branch-archive-hygiene-004.md)；新建本记录；在 `AGENTS.md`「GitHub 发布与分支清理」末尾追加「合并后清理（PF-023）」。恰好这三份文件。
- **Non-goals:** 删除任何分支或 worktree；push、PR、merge；GitHub 仓库设置；修改代码、测试或其它文档；6A；7B。
- **Required Inputs:** 任务包（SHA 见上）；外置盘点 `~/.kos-work/Universe-Keyboard/GROK-BOT-TRIAL-026/reports/branch-worktree-inventory.md` SHA-256 `1c6ff10aa3802e8ab62893b381ff8e4c8bf374a3b338b92ce39dafdf4c712dbb`；外置 Quality `GROK-BOT-TRIAL-026/reports/quality-review.md` SHA-256 `52a3cd964e10c7041ffd90723b0e88f53295f1ef3014bf5ae3637a046f40fede`；[GIT-BRANCH-ARCHIVE-HYGIENE-003](git-branch-archive-hygiene-003.md)；[D7](../portfolio/lifecycle-closeout.md)。
- **Baseline:** `origin/main` = `eda15a52dad30f6bac08f09c0f9356526763e208`（PR #244 合并）。开工时该提交之后没有触及本任务三份文件的新提交。

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward（出处：[docs/VIRTUAL_ENGINEERING_TEAM.md](../VIRTUAL_ENGINEERING_TEAM.md)；与 [GIT-BRANCH-ARCHIVE-HYGIENE-003](git-branch-archive-hygiene-003.md) 相同写法）
- **Executor:** Grok bot（本任务包点名执行）
- **Environment Executor:** Not Applicable — repository documentation only
- **Human Dependency:** Human Product Owner（任何 push / PR / merge；6A 与 7B）
- **Architecture Reviewer:** Not Applicable — 只涉及 git 引用卫生与文档登记，不涉及产品或架构
- **Quality Reviewer:** 独立 Quality，负责复核本记录与 `AGENTS.md` 追加
- **Handoff Target:** Human Product Owner

## Gates 与 Handoff

- **Entry Criteria:** Human 点名任务包与 SHA-256 授权；基线为 `eda15a52dad30f6bac08f09c0f9356526763e208`；独立 worktree、分支 `docs/git-branch-archive-hygiene-004`；不碰 Human 主检出。
- **Exit Criteria:** `git diff --stat origin/main` 恰为这三份文件；`git diff --check` 通过；`AGENTS.md` 仅在指定节末尾新增行；链接检查通过；一个本地提交；外置执行报告。
- **Stop Conditions:** 需要改这三份文件之外的内容；`AGENTS.md` 现有规则与草案冲突；外置依据 SHA 不一致；事实没有出处。
- **Revalidation Trigger:** Scope、Owner、基线或外置盘点 SHA 变更。

## Exit evidence

（执行时填）

## Closeout Decision

依 [D7](../portfolio/lifecycle-closeout.md)，同步 / 记录类评审后直接 Close，且在承载记录的 PR 进入 main 时生效。

## Closeout Decision — 结果

2026-10-26：本地文档交付。独立评审与发布尚未发生。顶部 Lifecycle 为 Active；Close 在评审后、且承载记录的 PR 进入 main 时生效。
