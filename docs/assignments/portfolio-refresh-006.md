# Assignment: PORTFOLIO-REFRESH-006 — 任务目录整合与 2026-10-25 决定登记

Policy version: 1.0.0
record_id: PORTFOLIO-REFRESH-006

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | docs-only 本地登记与一次本地提交；未 push；本记录待后续评审 |
| Material non-claims | 无 push / PR / merge / 发布；不处置分支或 worktree，不改代码、测试、脚本或产品决定；新建行均为 Backlog，不代表立项；PF-031 移入已完成不代表发布准备 Assignment Close；本记录不替代产品 Gate |
| Environment Executor | Not Applicable — repository documentation only |
| Human 确认状态 | Human 2026-10-25 Asia/Shanghai 授权 GROK-BOT-TRIAL-024（创建指定本地 worktree / 分支、编辑允许文件、一次本地提交，不 push）；10 题答复 1A 2B 3A 4A 5A 6A 7A 8B 9A 10A；回执外置，不入库 |
| Next handoff / decision | 交 Grok bot「Quality Reviewer」（不同会话）评审；发布前是否另加独立评审及任何 push / PR / merge 由 Human 决定 |

## Authority

- **Task ID / Title:** PORTFOLIO-REFRESH-006 — 任务目录整合与 2026-10-25 决定登记
- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 2026-10-25 Asia/Shanghai 当次授权；外置 ~/.kos-work/Universe-Keyboard/GROK-BOT-TRIAL-024/reports/authorization-issued.md（SHA-256 04233e2dabd22d146a4ccfe16af94cb0f0d33b1c9cd008dee4a04243e2de5521）；任务包 ~/.kos-work/Universe-Keyboard/GROK-BOT-TRIAL-024/instructions/task-package.md（SHA-256 bc97cad86f2524953dc4aa9a0d2bf551d255ef6e5ebcc6d3099c2a54e01dd8c1）
- **Product Approver:** Human Product Owner（Product Lead）

## Boundary

- **Scope:** docs/PORTFOLIO.md 的指定行、新建行 PF-037 至 PF-051、已完成表与决定记录；新建 docs/portfolio/roadmap-2026-10.md；本记录。一个本地提交，分支 docs/portfolio-refresh-006，worktree ~/.kos-work/Universe-Keyboard/GROK-BOT-TRIAL-024/worktree。CHANGELOG.md 不改（AGENTS.md 与 CHANGELOG.md 未要求目录变更记条目）。
- **Non-goals:** push、PR、merge、Reviewer 以外的派发、代码 / 测试 / 脚本修改、删除文件或分支或 worktree、TestFlight / App Store Connect、产品决定起草、ACTIVE_WORK 与其它 Assignment 修改。
- **Required Inputs:** 任务包与授权回执；基线 3962cae109a42b9fcdfa4a6214fd08cf6d276533；外置 GROK-BOT-TRIAL-023 提案（SHA-256 aff1f118…cf9）、quality-review（afb0295e…7ca）、pm-human-questions（63d67a01…63b）；暂存清单 backlog-notes（5804d3d5…1f0，含 B28、B29）；发布决定记录（972ede33…ba8）；docs/assignments/portfolio-refresh-005a.md 先例。

## Assignment

- **Domain Owner:** Architecture and Knowledge Steward
- **Executor:** Grok bot「Executor」；运行时身份 Grok Bot，底层模型 UNKNOWN
- **Environment Executor:** Not Applicable — repository documentation only
- **Human Dependency:** Human Product Owner（评审后的 push / PR / merge 与是否另加独立评审）
- **Architecture Reviewer:** 未指派；是否需要由 Human 决定
- **Quality Reviewer:** Grok bot「Quality Reviewer」（不同会话）；发布前是否另加独立评审，由 Human 决定
- **Product Approver:** Human Product Owner（Product Lead）

## Reviewer claim register

| ID | 声称 |
|---|---|
| R1 | 10 题答复逐项落到目录指定行；未改动行字节不变 |
| R2 | 新建行 15 个，PF-037 至 PF-051 连续且登记前未占用，状态均为 Backlog |
| R3 | 不把未决定事项写成决定：B10、B20、B21、B23 不作为决定记录 |
| R4 | 本记录必填字段完整，Active；不自填评审结论 |
| R5 | git diff --check 与链接目标存在性记录；一次本地提交，无发布或越权改动 |

## Gates

- **Entry Criteria:** Human 授权激活；任务包与冻结输入 SHA-256 匹配；fetch 后 origin/main 精确为基线；新编号未占用；隔离 worktree。
- **Exit Criteria:** 允许文件指定刷新；diff --check 通过；链接目标存在；一个默认身份本地提交；外置 Executor 报告交付。不在评审前填写评审结论。
- **Stop Conditions:** 冻结输入不符；基线出现触及目录或代码的新提交；需要范围外改动；事实无出处；新编号已被占用。

## Handoff

- **Handoff Target:** Grok bot「Quality Reviewer」→ Human Product Owner
- **Required Handoff Content:** 基线、来源 SHA-256、各文件 diff 摘要、新编号表、10 题落点行号、检查结果、提交与树 SHA、偏差及 UNKNOWN。
- **Revalidation Trigger:** Scope / 责任 / 基线 / 任务包或来源摘要变化；发布阶段开始时重新核对。

## Reports

~/.kos-work/Universe-Keyboard/GROK-BOT-TRIAL-024/reports/executor-report.md；SHA-256 由对话交付，避免循环引用。授权仅外置，不入库。

## Exit evidence

| 项 | Result |
|---|---|
| Executor 登记与本地检查 | 见外置 Executor 报告（执行来源，不是 Reviewer 结论） |
| Quality | 待评审，不填结论 |

## Closeout Decision

本 Assignment 为同步 / 记录类，依 [任务目录](../PORTFOLIO.md) 决定记录 D7 在评审后 Close，Close 在进入 main 时生效；评审完成后追加最终结果。

## Lifecycle Status

Active
