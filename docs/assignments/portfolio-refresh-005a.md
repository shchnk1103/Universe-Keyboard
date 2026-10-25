# Assignment: PORTFOLIO-REFRESH-005A — UI-3 / UI-4 合并与 Close 登记刷新

Policy version: 1.0.0
record_id: PORTFOLIO-REFRESH-005A

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | docs-only 本地登记与一次本地提交；未 push；本记录待后续评审 |
| Material non-claims | 无 push / PR / merge / Reviewer 派发 / 发布；不清理过期句，不处置分支或 worktree，不改 ACTIVE_WORK、代码或测试；本记录不替代产品 Gate |
| Environment Executor | Not Applicable — repository documentation only |
| Human 确认状态 | Human 2026-10-25 Asia/Shanghai 已授权 v2 取代原包，创建指定本地 worktree / 分支、登记及一次本地提交；UI-4 / UI-3 Close 是 Human 决定；回执见下 |
| Next handoff / decision | 交 Coordinator 准备后续 Architecture / Quality Reviewer 派发，随后 Human 决定发布动作；本次不派发 |

## Authority

- **Task ID / Title:** PORTFOLIO-REFRESH-005A — UI-3 / UI-4 合并与 Close 登记刷新
- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 2026-10-25 Asia/Shanghai 当次 v2 授权；`~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-005A/reports/human-authorization-005a-v2-issued.md`（SHA-256 `5ea45537ca6c609306f3b2637c4261a4411ba86284b647eec644d741f70238df`）；任务包 `~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-005A/instructions/task-package-v2.md`（SHA-256 `539fe7f7169d08d19bd02f4c50146bfeec9d5de8072205bbaba3d396814f3a0b`）
- **Product Approver:** Human Product Owner（Product Lead）

## Boundary

- **Scope:** 仅八个文件：`docs/PORTFOLIO.md` 的 PF-012 / PF-013 移入已完成、PF-029 / PF-031 指定修改、新增 PF-035 与决定记录；`docs/assignments/ui4-height-001.md`、`ui3-font-001.md` 的指定状态 / 证据 / Closeout；`docs/ENGINEERING_DASHBOARD.md` 两节；`docs/KNOWLEDGE_INDEX.md` 两行；`docs/portfolio/ui-4-keyboard-height.md` 头部状态与下一步；`docs/portfolio/kos-optimization.md` 追加 30–32；本记录。一个本地提交，分支 `docs/portfolio-refresh-005a`，worktree `~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-005A/worktree`。
- **Non-goals:** push、PR、merge、Reviewer 派发、005B 过期句清理、任何分支/worktree 处置；ACTIVE_WORK、代码、测试、脚本、产品决定、TECH_DEBT、RELEASE_CHECKLIST 与其它 Assignment；不把 Close 当作 TestFlight 或 Release 许可。
- **Required Inputs:** v2 任务包与授权回执；基线 `b8f6b6516064c4721c884a53e1437e01d83449e7`；AGENTS、KNOWLEDGE_INDEX、READING_MAPS、ASSIGNMENT_POLICY、AI_WORKFLOW、DOCUMENTATION_GOVERNANCE、KNOWLEDGE_DEPENDENCIES、documentation-maintainer playbook、KOS 2.1 ops；八文件改前与 `portfolio-refresh-004.md` 先例；任务包指定 UI3 报告、014 / 015 报告与 PM backlog-notes；PR #234 / #236 的 gh 只读事实。

## Assignment

- **Domain Owner:** Architecture and Knowledge Steward
- **Executor:** Codex（GPT-6），当前 Executor 会话；精确后端版本与 effort 未确认，不据此声明独立 review
- **Environment Executor:** Not Applicable — repository documentation only
- **Human Dependency:** Human Product Owner（后续 Reviewer 派发与任何 push / PR / merge；本轮本地范围已授权）
- **Architecture Reviewer:** 独立 Architecture Reviewer 角色，留待 Coordinator 后续冻结 packet 派发；本阶段不启动、非本 Executor 会话
- **Quality Reviewer:** 独立 Quality Reviewer 角色，留待 Coordinator 后续冻结 packet 派发；非本 Executor 或 Architecture 的同一会话
- **Product Approver:** Human Product Owner（Product Lead）

## Reviewer claim register

| ID | 声称 |
|---|---|
| R1 | 仅八文件指定行 / 段落变化，PF-035 与 30–32 无编号冲突；kos-optimization 旧字节前缀不变 |
| R2 | UI-3 / UI-4 Close 是 Human 决定，进入本记录 PR 合并时生效；不适用产品开发 D7 直接 Close |
| R3 | 所有来源摘要复算；Human 观察不是测量，真机仅覆盖 b0e0361，后续提交未验收；历史 Blocker / 失败保留，Reviewer 未重跑边界保留 |
| R4 | 本记录 19 项必填字段完整，Active；D7 仅适用于本记录评审后 Close，不自填评审结论 |
| R5 | diff --check、链接检查与范围证明记录；一次本地提交、无发布或越权改动 |

## Gates

- **Entry Criteria:** Human v2 激活；任务包 SHA-256 匹配；fetch 后 origin/main 精确匹配；改前与编号核验；外置固定摘要及 PR/CI 事实匹配；隔离 worktree，保留脏主检出。
- **Exit Criteria:** 八文件指定刷新；来源与替换前后记录；Python -I 范围证明、diff --check、提交后链接检查；一个默认身份本地提交；外置报告交付。不在评审前填写评审结论。
- **Stop Conditions:** 改前不符；origin/main 不为冻结基线；需要范围外改动；PR / CI 事实冲突；事实无出处；任何 push / PR / merge 或 Reviewer 派发请求超出现授权。

## Handoff

- **Handoff Target:** Coordinator → 后续 Architecture / Quality Reviewer（本次不派发）→ Human Product Owner
- **Required Handoff Content:** 基线、来源 SHA-256、完整替换前后、范围证明、检查退出码、提交与树 SHA、报告路径与摘要、偏差及 UNKNOWN。
- **Revalidation Trigger:** Scope / 责任 / 基线 / 任务包或来源摘要变化；Reviewer 派发或发布阶段开始时重新核对。

## Reports

`~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-005A/reports/executor-report.md`；SHA-256 由对话交付，避免循环引用。旧包停止报告保留为 `executor-report-v1-stopped.md`；授权仅外置，不入库。

## Exit evidence

| 项 | Result |
|---|---|
| Executor 登记与本地检查 | 见外置 Executor 报告（执行来源，不是 Reviewer 结论） |
| Architecture / Quality | 待后续派发，不填结论 |

## Closeout Decision

本 Assignment 为同步 / 记录类，依 [PORTFOLIO 决定记录 D7](../PORTFOLIO.md#决定记录)在评审后 Close，**Close 在进入 main 时生效**；评审完成后追加最终结果。此规则不替代 UI-3 / UI-4 的 Human 产品开发 Close 决定。

## Lifecycle Status

Active
