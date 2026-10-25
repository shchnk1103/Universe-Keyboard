# Assignment: RELEASE-CHECKLIST-REFRESH-001 — Build 132 之后发布检查表对齐与自动化候选盘点

Policy version: 1.0.0
record_id: RELEASE-CHECKLIST-REFRESH-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | docs-only 本地登记与一个本地提交；未 push，待后续评审 |
| Material non-claims | 检查表更新不等于任何条目已验收；不是 TestFlight 或 Release 许可；无自动化实现 / Reviewer 派发 / push / PR / merge / Apple 侧动作 |
| Next handoff / decision | Coordinator 后续冻结 packet 派发独立 Architecture / Quality Reviewer，再交 Human 决定发布 |

## Authority

- **Task ID / Title:** RELEASE-CHECKLIST-REFRESH-001 — Build 132 之后发布检查表对齐与自动化候选盘点
- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 2026-10-25 Asia/Shanghai；冻结任务包 `~/.kos-work/Universe-Keyboard/RELEASE-CHECKLIST-REFRESH-001/instructions/task-package.md`（SHA-256 `49b0d19f948c36940db0868b14d8ba5817602219b8a7bdb19ec4351c945d2df9`）；授权原文外置 `reports/human-authorization-issued.md`（SHA-256 `d0c2783f954f057932dc4ac6bda8b17a3582676da56b9d7942733048c8f10968`），不入库。Human 决定现在更新检查表；以后希望发布前有自动化检验流程，本任务仅标出可自动化项，不实现。TD-003 在同一台 iPhone 13 Pro、同一系统 / 宿主 / 方案下对照 Build 132（上一个已接受构建），判定没有无法解释的退化，不设绝对数值。
- **Product Approver:** Human Product Owner（Product Lead）

## Boundary

- **Scope:** 仅修改 [RELEASE_CHECKLIST](../RELEASE_CHECKLIST.md)、新建本 Assignment；外置 `reports/automation-candidates.md` 覆盖每个复选项；指定 worktree `~/.kos-work/Universe-Keyboard/RELEASE-CHECKLIST-REFRESH-001/worktree`、分支 `docs/release-checklist-refresh-001`；一个本地提交。
- **Non-goals:** push、PR、merge、Reviewer 派发、代码/测试/脚本、过期句清理、分支/worktree 处置、TestFlight / App Store Connect / 导出 / 上传 / 归档动作；不扩写 Human 决定。
- **Required Inputs:** 冻结任务包、Human 授权、基线 `46368d7f9ea4820112150994ef32541061b0400b`；GROK-BOT-TRIAL-019 Revision 1 / Quality / open-questions、017 / 018 外置报告（线索，摘要复算见外置报告）；CHANGELOG、UI-3 §8 / UI-4 §10 产品决定与 Assignment、UI-2 Human receipt、输入可靠性 003、PERFORMANCE_BASELINE；AGENTS、ASSIGNMENT_POLICY、AI_WORKFLOW、文档治理与 documentation-maintainer playbook。

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
| R1 | 恰两文件；检查表只改 019 指定条目 / 加注并新增一节 |
| R2 | 本记录 19 项必填字段完整、Active，评审留待后续派发 |
| R3 | 每条来源已核对，缺文档处保留 UNKNOWN；真机输入不得用坐标自动化替代 |
| R4 | 外置逐项自动化清单、范围证明、链接检查与一个本地提交可追溯，无验收通过或发布声称 |

## Gates

- **Entry Criteria:** Human 激活本包；任务包摘要匹配；fetch 后基线精确匹配；改前、编号与外置摘要一致；隔离 worktree，保留 Human 主检出。
- **Exit Criteria:** 两文件更新、一个默认身份本地提交；范围 / 条目与文件数统计、diff --check、提交后链接检查；外置逐条前后原文及来源、自动化候选清单及四类汇总、摘要、命令退出码、提交与树 SHA、偏差。
- **Stop Conditions:** origin/main 不为冻结基线、外置摘要不符、行为只能靠猜、需改范围外文件、检查表需要超出逐项与新增一节的大改；一次列全再停。

## Handoff

- **Handoff Target:** Coordinator → 后续独立 Architecture / Quality Reviewer → Human Product Owner
- **Required Handoff Content:** 基线、两文件 diff、逐项来源与 UNKNOWN、变更区间证明、自动化候选清单与汇总 / SHA-256、命令退出码、提交 / 树 SHA。
- **Revalidation Trigger:** Scope / 责任 / 基线 / 任务包 / 来源摘要变化；后续评审或发布动作开始时重新核对。

## Reports

`~/.kos-work/Universe-Keyboard/RELEASE-CHECKLIST-REFRESH-001/reports/executor-report.md`；摘要由对话交付，授权原文仅外置。

## Exit evidence

| 项 | Result |
|---|---|
| Executor 登记与本地检查 | 见外置 Executor 报告，Executor-recorded，不是 Reviewer 结论 |
| Architecture / Quality | 待后续派发，不填结论 |

## Closeout Decision

本记录依 [PORTFOLIO 决定记录 D7](../PORTFOLIO.md#决定记录)评审后 Close，进入 main 时生效；仅适用于本登记记录，不适用于发布准备 Assignment。未预填 Close 或评审结论。

## Lifecycle Status

Active
