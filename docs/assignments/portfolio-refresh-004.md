# Assignment: PORTFOLIO-REFRESH-004 — 任务组合目录小范围登记刷新（004a）

Policy version: 1.0.0
record_id: PORTFOLIO-REFRESH-004

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active（docs-only，在本地执行；未 push） |
| Current phase | Executor 已按定稿落地 `docs/PORTFOLIO.md`、`kos-optimization.md`、`testflight-gates.md` 与本记录。未 push |
| Material non-claims | 目录是优先级与指针索引，不是状态权威；不声称任何新事项已立项或已授权；不改 Assignment、产品决定、TECH_DEBT；不处理过期句；不处置分支或 worktree；不 push / PR / merge |
| Environment Executor | `Not Applicable — repository documentation only`（随派发确认） |
| Human 确认状态 | 范围：Human 2026-10-24 同意先做一次小范围登记刷新；派发与独立 worktree 由 Human 2026-10-24 21:29、21:37 Asia/Shanghai 当次授权（外置记录见 Exit evidence） |
| Next handoff / decision | Architecture / Quality Reviewer（双 lane）→ Human 决定 push / PR / merge |

## Authority

- **Task ID / Title:** PORTFOLIO-REFRESH-004 — 任务组合目录小范围登记刷新（004a）
- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 于 2026-10-24 Asia/Shanghai 在项目经理会话中同意先做小范围登记刷新；外置定稿 `~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-004/instructions/assignment-final.md`（SHA-256 `2c2a74ec14cfd2917ca51a837d304f9d9060847ae01e63c0c1b84b311506b7da`），内容来源 `content/row-text.md`（SHA-256 `bcbf1c4d21a853e40e835fc6bdd66f1a017122e7f9afe50b975b45ca6a263e6d`）
- **Product Approver:** Human Product Owner（Product Lead）

## Boundary

- **Scope（docs-only）：**
  1. `docs/PORTFOLIO.md`：按 `row-text.md` 第一节更新 PF-012、PF-013、PF-025、PF-029、PF-030 的指定格；第二节新增 PF-031 至 PF-034（Backlog）；第三节在“决定记录”追加 4 行。其余行逐字节不变。
  2. `docs/portfolio/kos-optimization.md`：按第四节只追加第 25–29 条。
  3. `docs/portfolio/testflight-gates.md`：追加小节“2026-10-24 外部 TestFlight 方案”，与 PF-031 一致，不改写既有句子。
  4. 本记录。
  5. 其它镜像（`ACTIVE_WORK`、`ENGINEERING_DASHBOARD`、`KNOWLEDGE_INDEX`、`CHANGELOG`、`TECH_DEBT`、`KEYBOARD_VALUES`）：不适用，不改；依据：本次只登记目录行与 Human 决定，没有 Assignment 生命周期变化、知识入口变化、发布、技术债或数值变化。
- **Non-goals:** 过期句清理；UI-4 Assignment Close；分支 / worktree 处置；任何 Swift、测试、CI 改动；改产品决定；把外置材料拷进仓库；push / PR / merge。
- **Required Inputs:** `AGENTS.md`；`docs/KNOWLEDGE_INDEX.md`；`docs/ASSIGNMENT_POLICY.md`（Required Assignment Fields、D7）；`docs/DOCUMENTATION_GOVERNANCE.md`；`docs/KNOWLEDGE_DEPENDENCIES.md`；`docs/playbooks/documentation-maintainer.md`；基线 `origin/main` `ebf7e4fa51967b58be80c2cef00f7c3e9fdd8e17` 上的 `docs/PORTFOLIO.md`、`docs/portfolio/kos-optimization.md`、`docs/portfolio/testflight-gates.md`、`docs/assignments/portfolio-refresh-003.md`；`row-text.md`。

## Assignment

- **Domain Owner:** Architecture and Knowledge Steward
- **Executor:** Executor 角色（AI 不限；本次由 Human 指定 Grok bot）
- **Environment Executor:** `Not Applicable — repository documentation only`
- **Human Dependency:** Human Product Owner（任何 push / PR / merge）
- **Architecture Reviewer:** 独立 Reviewer 会话（AI 不限）；未参与本批次实现，且不是 Quality Reviewer 的同一会话；lane `PR004-ARCH`
- **Quality Reviewer:** 同上；lane `PR004-QUAL`
- **Product Approver:** Human Product Owner（Product Lead）

## Reviewer claim register

| ID | 声称 |
|---|---|
| R1 | `docs/PORTFOLIO.md`：指定五行的指定格与 `row-text.md` 逐字一致；PF-031 至 PF-034 新增且为 Backlog、编号无冲突；决定记录追加 4 行；其它行逐字节不变 |
| R2 | `kos-optimization.md` 只追加，旧内容是新内容的字节前缀，编号接续 |
| R3 | `testflight-gates.md` 追加小节与 PF-031 一致，文件不超过 100 行，没有改写既有句子 |
| R4 | 本记录含 19 项必填字段，Lifecycle/Closeout 写法与 003 一致，没有声称合并前已 Closed |
| R5 | 没有新事项被写成已立项或已授权；没有 Human 观察被写成测量；PF-013 仍写 Close 由 Human 决定 |
| R6 | 链接检查与 `git diff --check` 通过；diff 恰为上述四个文件 |

## Gates

- **Entry Criteria:** Human 当次授权派发；基线复核；`row-text.md` SHA-256 匹配；改前文字与基线逐字一致；新编号未被占用；独立 worktree 与分支 `docs/portfolio-refresh-004`；Human 主检出不得触碰。
- **Exit Criteria:** 指定范围落地；改前改后已记录；链接检查与 `git diff --check` 已记录；一次本地提交（作者仓库默认身份，不覆盖）；报告文件已保存。
- **Stop Conditions:** 基线移动且与 `docs/PORTFOLIO.md` 重叠；`row-text.md` 的改前与基线不逐字一致（一次列全再停）；编号被占用；需要改范围外文件；任何 push / merge。

## Handoff

- **Handoff Target:** Architecture Reviewer 与 Quality Reviewer（双 lane），随后 Human Product Owner 决定 push / PR / merge。
- **Required Handoff Content:** 基线 SHA、外置来源复算结果、各文件改前改后、链接检查结果、本地提交 SHA、报告路径与 SHA-256。
- **Revalidation Trigger:** Scope / Owner / Reviewer 变化；基线漂移且与 Scope 重叠；`row-text.md` 变更；2026-10-31 前未派发。

## Reports

报告根目录 `~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-004/`。仓库内只记录路径与 SHA-256。最终对话消息要短，不复述报告。

## Exit evidence

| 项 | Result |
|---|---|
| 开工前核验 | 基线 `origin/main` `ebf7e4fa51967b58be80c2cef00f7c3e9fdd8e17` 未移动；`assignment-final.md`、`row-text.md` SHA-256 复算一致；改前文字与基线逐字一致；PF 编号止于 PF-030，新行取 PF-031 至 PF-034；`kos-optimization.md` 止于第 24 条 |
| 授权记录 | 外置 `~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-004/reports/human-authorization-refresh-004-issued.md`，SHA-256 `5d94c9a4337934d1291eb8415340527a6c7df340afeb8a5822dec2fa58631476` |
| 落地范围 | `docs/PORTFOLIO.md` 五行指定格、PF-031 至 PF-034、决定记录四行；`kos-optimization.md` 第 25–29 条；`testflight-gates.md` 追加小节；本记录 |
| 链接检查与 `git diff --check` | 见外置 Executor 报告 |
| Executor 报告路径与 SHA-256 | `~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-004/reports/executor-report.md`；SHA-256 由对话交付，避免循环引用 |

## Closeout Decision

依 D7（同步 / 记录类）在评审后直接 Close，**Close 在进入 `main` 时生效**。评审完成后在本节追加最终结果（追加式）。

## Lifecycle Status

Active
