# Assignment: RELEASE-ASSIGNMENT-LANDING-001 — 外部 TestFlight 准备 Assignment 与今日决定登记

Policy version: 1.0.0
record_id: RELEASE-ASSIGNMENT-LANDING-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | docs-only 本地登记与一个本地提交；未 push，待后续评审 |
| Material non-claims | 无 Reviewer 派发 / push / PR / merge / 采集 / 归档 / 导出 / 上传；不替代 Product Gate |
| Next handoff / decision | Coordinator 后续冻结 packet 派发独立 Architecture / Quality Reviewer，再交 Human 决定发布 |

## Authority

- **Task ID / Title:** RELEASE-ASSIGNMENT-LANDING-001 — 外部 TestFlight 准备 Assignment 与今日决定登记
- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 2026-10-25 Asia/Shanghai；外置任务包 `~/.kos-work/Universe-Keyboard/RELEASE-ASSIGNMENT-LANDING-001/instructions/task-package.md`（SHA-256 `896cb2cd8e72ae5928761faa87bce75da210cac204d3c3ae72fc45fc15ff99e3`）；授权回执 `~/.kos-work/Universe-Keyboard/RELEASE-ASSIGNMENT-LANDING-001/reports/human-authorization-issued.md`（SHA-256 `be1fdb2db8deca5ed54ec9cd468f422bdf5ad9be7327af6fdc9f87c003f6611b`）；授权原文不入库。
- **Product Approver:** Human Product Owner（Product Lead）

## Boundary

- **Scope:** 仅四文件：[发布准备 Assignment](release-2026-10-external-testflight-001.md)、本记录、[PORTFOLIO](../PORTFOLIO.md) 指定行 / 决定记录、[testflight-gates](../portfolio/testflight-gates.md) 指定片段；本地 worktree `~/.kos-work/Universe-Keyboard/RELEASE-ASSIGNMENT-LANDING-001/worktree`、分支 `docs/release-assignment-landing-001`；一个本地提交。
- **Non-goals:** push、PR、merge、Reviewer 派发、代码/测试/脚本、过期句清理、分支/worktree 处置、TestFlight / App Store Connect / 导出 / 上传 / 归档动作；不扩写 Human 决定。
- **Required Inputs:** 冻结任务包、Human 授权、基线 `23601c06420b1955d141b6c9a70f1baa9f9f4013`；AGENTS、KNOWLEDGE_INDEX、ACTIVE_WORK、READING_MAPS、ASSIGNMENT_POLICY、AI_WORKFLOW、DOCUMENTATION_GOVERNANCE、KNOWLEDGE_DEPENDENCIES、KOS 2.1 ops、documentation-maintainer playbook；任务包指定外置摘要；[005A 先例](portfolio-refresh-005a.md)、[Build 94 Assignment](release-2026-09-25-build94-external-testflight.md)、[Build 94 决定](../product-decisions/RELEASE-2026-09-25-BUILD94-public-beta-decision.md)。

## Assignment

- **Domain Owner:** Architecture and Knowledge Steward
- **Executor:** Codex（GPT-6，当前 Executor 会话；精确后端版本未确认）
- **Environment Executor:** Not Applicable — repository documentation only
- **Human Dependency:** Human Product Owner；本轮本地范围已授权，后续 Reviewer 派发与任何发布动作另行授权。
- **Architecture Reviewer:** 独立 Architecture Reviewer 角色，留待 Coordinator 后续冻结 packet 派发，非 Executor 会话；本次不派发。
- **Quality Reviewer:** 独立 Quality Reviewer 角色，留待 Coordinator 后续冻结 packet 派发，非 Executor 或 Architecture 同一会话；本次不派发。

## Reviewer claim register

| ID | 声称 |
|---|---|
| R1 | 恰四文件；既有两文件改动仅落在冻结包指定行 / 片段，PF-036 无编号冲突 |
| R2 | 两份 Assignment 必需字段完整，发布准备 Assigned、登记 Active；不预填评审或证据 |
| R3 | 外置摘要已复算；Human 版本 / 设备确认不是本次设备测量，历史操作两个来源并列 UNKNOWN |
| R4 | diff --check、范围证明、提交后链接检查与一个本地提交可追溯；没有发布动作 |

## Gates

- **Entry Criteria:** Human 激活本包；任务包摘要匹配；fetch 后基线精确匹配；改前、编号与外置摘要一致；隔离 worktree，保留 Human 主检出。
- **Exit Criteria:** 四文件登记；一个默认身份本地提交；diff --check、Python -I 范围证明与提交后链接检查通过；外置报告含字段行号映射、来源摘要、替换前后、提交 / 树 SHA、偏差与 UNKNOWN；不是独立评审结论。
- **Stop Conditions:** 任一改前不符、origin/main 不为预期、需范围外文件改动、事实无出处、需要写 Apple 平台能力断言；一次列全再停。

## Handoff

- **Handoff Target:** Coordinator → 后续独立 Architecture / Quality Reviewer → Human Product Owner
- **Required Handoff Content:** 精确基线、四文件 diff、来源与授权摘要、替换前后、必需字段行号、命令 / 退出码、提交与树 SHA、外置报告及所有 UNKNOWN。
- **Revalidation Trigger:** Scope / 责任 / 基线 / 任务包 / 来源摘要变化；后续评审或发布动作开始时重新核对。

## Reports

`~/.kos-work/Universe-Keyboard/RELEASE-ASSIGNMENT-LANDING-001/reports/executor-report.md`；摘要由对话交付，授权原文仅外置。

## Exit evidence

| 项 | Result |
|---|---|
| Executor 登记与本地检查 | 见外置 Executor 报告，Executor-recorded，不是 Reviewer 结论 |
| Architecture / Quality | 待后续派发，不填结论 |

## Closeout Decision

本记录依 [PORTFOLIO 决定记录 D7](../PORTFOLIO.md#决定记录)评审后 Close，进入 main 时生效；仅适用于本登记记录，不适用于发布准备 Assignment。未预填 Close 或评审结论。

## Lifecycle Status

Active
