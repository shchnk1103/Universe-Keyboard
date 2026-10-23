# Assignment: PORTFOLIO-REFRESH-003 — 任务组合目录第三次刷新

Policy version: 1.0.0
record_id: PORTFOLIO-REFRESH-003

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active（docs-only，在本地执行；未 push） |
| Current phase | Executor 已按定稿落地 M1–M3、目录行与本记录。未 push |
| Material non-claims | 目录是优先级与指针索引，不是状态权威；不声称任何新事项已立项或已授权；不处置、不判断任何分支或 worktree 的去留；不改代码、测试、CI、数值或其它 Assignment 的既有结论；不 push / PR / merge |
| Next handoff / decision | Architecture / Quality Reviewer（双 lane）→ Human 决定 push / PR / merge |

## Authority

- **Task ID / Title:** PORTFOLIO-REFRESH-003 — 任务组合目录第三次刷新
- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 于 2026-10-23 22:48 与 22:51 Asia/Shanghai 在项目经理会话中指示：M1–M3 列为必做；退役清理只指向结果、不处置；TRIAL-011 Q-01 与 3 条"不确定"项不纳入、保留。外置来源：`PORTFOLIO-REFRESH-003/content/pending-from-trials-011-012.md`（SHA-256 `648674c2199ab3e171ca76b814474f32767514a8ff3f30ca7638ef3b73c21a74`）、`review-report-hashes.md`（SHA-256 `aa921795c62d4be772c20d8d858f74fc6a9f9aa1150b27df29d595e8f23df712`）、`backlog-notes.md`、`replacement-text.md`（SHA-256 `05fa941ec931c376d37fa415db6f8d1f39baaf92e0e66d10fb7c33817f2b0397`，九处过时句的精确替换与决定记录追加行）。
- **Product Approver:** Human Product Owner（Product Lead）

## Boundary

- **Scope（docs-only）——必做：**
  - **M1** `docs/assignments/portfolio-refresh-002.md`：Lifecycle 仍为 `Active`，但 PR #230（`2c60a0b`）已合并、评审已完成。按 D7 走完 Close（结果节只追加，不回写）。第 10、11、14 行过时句按 `replacement-text.md` 第一节第 1–3 条精确替换；第 4 条追加 `### Close 披露（PORTFOLIO-REFRESH-003）`。须如实写明：该记录的评审后修订提交当时**没有再经独立 Reviewer 复核**，仅由 Coordinator 只读核验并已在原记录披露。
  - **M2** `docs/assignments/ui3-pd-landing-001.md`：追加"评审结果"节（追加式），报告路径与 SHA-256 以 `review-report-hashes.md` 的 UI3 表为准：Architecture R1（Pass with conditions，F01）、Quality R1（Partial，U01/P01）、Architecture R2（Pass）、Quality R2（Pass）、Human 确认产品决定 v2 与残项处置、Human 授权发布记录；写明 U01 登记为自述、P01 披露、UI-3 的 v2 与 F01 处置。第 11、12、14 行过时句按 `replacement-text.md` 第二节第 1–3 条精确替换（PR #232，`ed01fc5`）。
  - **M3** `docs/assignments/ui4-pd-landing-001.md`：追加"评审结果"节，以 `review-report-hashes.md` 的 UI4 表为准。须如实写明：Architecture 与 Quality 的 Round 1 均为 **Partial**，没有独立 Round 2；收尾依靠 **Coordinator 缺口核对（非独立复核）加 Human 采纳**，并列出 Executor 报告 v2 与 Human 授权发布记录。第 11、12、14 行过时句按 `replacement-text.md` 第三节第 1–3 条精确替换（PR #231，`871f273`）。
  - 九处过时句的精确替换以 `~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-003/content/replacement-text.md`（SHA-256 `05fa941ec931c376d37fa415db6f8d1f39baaf92e0e66d10fb7c33817f2b0397`）为准：第一节 3 处、第二节 3 处、第三节 3 处。只替换表中列出的片段，其余字节不变。
- **Scope——其它：**
  - `docs/PORTFOLIO.md`：PF-012 下一步补"入库记录已随 PR #232 进入 main"；决定记录追加一行；状态仍为 Waiting Human。决定记录再按 `replacement-text.md` 第四节追加一行（在上述原有追加之外）：`| 2026-10-23 | 退役候选核对结果（GROK-BOT-TRIAL-012）先保存、暂不判断；这些分支与 worktree 是否仍有会话在使用尚未确认，合适时机再判断；实际清理前须按 `AGENTS.md` 先拉取最新远端状态 | 本文件 PF-023 |`。
  - `docs/PORTFOLIO.md`：PF-023 状态不变，"下一步"只指向外置结果 `GROK-BOT-TRIAL-012/reports/retirement-check.md`（路径与 SHA-256），不处置、不列删除清单。
  - 新目录候选"PM 会话日志（试行）"，状态 Backlog，ID 取下一个未占用编号（入库时核对）。
- **Non-goals：** 删除、移动或判断任何分支 / worktree 的去留；改带日期的历史记录（含 TRIAL-011 Q-01 涉及的 `ACTIVE_WORK.md` 与 `ENGINEERING_DASHBOARD.md` 顶部带日期句）；改 TRIAL-011 的 3 条"不确定"项；改两条 `Closed — effective on merge…`；改写已合并 Assignment 的既有事实或结论；改 `UI3-FONT-001` / `UI4-HEIGHT-001`；授权任何实现；把试运行报告、评审报告或 PM 日志正文放进仓库；push / PR / merge。
- **Required Inputs:** `AGENTS.md`；Knowledge Index；`docs/ASSIGNMENT_POLICY.md`（Required Assignment Fields、D7）；`DOCUMENTATION_GOVERNANCE.md`；上述外置来源（含 `replacement-text.md`，SHA-256 `05fa941ec931c376d37fa415db6f8d1f39baaf92e0e66d10fb7c33817f2b0397`）；`GROK-BOT-TRIAL-011/reports/stale-sentences.md`、`GROK-BOT-TRIAL-012/reports/retirement-check.md`；基线 `origin/main` `ed01fc5947fa0eca21fca347945375bba2ebd9d8`（开工时复核）。

## Assignment

- **Domain Owner:** Architecture and Knowledge Steward
- **Executor:** Executor 角色（AI 不限）
- **Environment Executor:** `Not Applicable — repository documentation only`
- **Human Dependency:** Human Product Owner（任何 push / PR / merge）
- **Architecture Reviewer:** 独立 Reviewer 会话（AI 不限）；未参与本批次实现，且不是 Quality Reviewer 的同一会话；lane `PR003-ARCH`
- **Quality Reviewer:** 同上；lane `PR003-QUAL`
- **Product Approver:** Human Product Owner（Product Lead）

## Reviewer claim register

| ID | 声称 |
|---|---|
| R1 | M1：Close 符合 D7，只追加结果；"修订未经独立复核"已如实写明 |
| R2 | M2 / M3：报告路径与 SHA-256 与 `review-report-hashes.md` 一致且可复算；U01、P01、F01 及 UI4 Partial 收尾方式表述与原报告一致 |
| R3 | 第 11、12、14 行共九处按替换表改动，其余历史与未列入项未改 |
| R4 | PF-023 只加指针，没有任何删除建议或处置表述 |
| R5 | `PORTFOLIO.md` 只改指定行并追加；其它行逐字节不变 |
| R6 | 链接检查与 `git diff --check` 通过；diff 只含 Scope 内文件 |

## Gates

- **Entry Criteria:** 基线复核；外置来源（含 `replacement-text.md`）SHA-256 匹配；改前文字与基线逐字一致，否则停下；`review-report-hashes.md` 中 11 份报告的 SHA-256 由 Executor 开工前**逐份复算**一致；独立 worktree 与分支 `docs/portfolio-refresh-003`；Human 本地 main 的 dirty 文件不得触碰。
- **Exit Criteria:** M1–M3 与其它 Scope 项落地；改前改后已记录；链接检查与 `git diff --check` 已记录；本地提交；报告文件已保存。
- **Stop Conditions:** 基线移动且与 Scope 重叠；任何外置来源或报告 SHA-256 不符；需要改 Scope 外文件；任何涉及分支 / worktree 处置的动作；任何 push / merge。

## Handoff

- **Handoff Target:** Architecture Reviewer 与 Quality Reviewer（双 lane），随后 Human Product Owner 决定 push / PR / merge。
- **Required Handoff Content:** 基线 SHA、外置来源与 11 份报告的复算结果、各文件改前改后、链接检查结果、本地提交 SHA、报告路径与 SHA-256。
- **Revalidation Trigger:** Scope / Owner / Reviewer 变化；基线漂移且与 Scope 重叠；外置来源或报告文件变更；2026-10-31 前未派发。

## Reports

报告根目录 `~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-003/`。仓库内只记录路径与 SHA-256。最终对话消息要短，不复述报告。

## Exit evidence

| 项 | Result |
|---|---|
| 开工前核验 | 基线 `origin/main` `ed01fc5947fa0eca21fca347945375bba2ebd9d8` 未移动；`assignment-final.md` SHA-256 `a58fe80aad1606841afdcd947867f45111975c0b208a6620a168b8cab37bed29`；`replacement-text.md` SHA-256 `05fa941ec931c376d37fa415db6f8d1f39baaf92e0e66d10fb7c33817f2b0397`；11 份报告 SHA-256 复算一致；九处改前文字与基线逐字一致；PF 编号止于 PF-029，新行取 PF-030 |
| 落地范围 | M1–M3 的九处精确替换与追加节；`docs/PORTFOLIO.md` 的 PF-012 下一步、PF-023 指针、PF-030、决定记录三行；本记录 |
| 链接检查与 `git diff --check` | 见外置 Executor 报告 |
| Executor 报告路径与 SHA-256 | `~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-003/reports/executor-report.md`；SHA-256 由对话交付，避免循环引用 |
| Round 1 残项处置（2026-10-23，Human） | 外置记录 `~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-003/reports/human-decision-residuals-1.md`，SHA-256 `3c921011041dbc94aea3594af008162bf2e19254b28886c3e437a7bce8cb76af`。本提交不是独立复核 |

## Closeout Decision

依 D7（同步 / 记录类）在评审后直接 Close，**Close 在进入 `main` 时生效**。评审完成后在本节追加最终结果（追加式）。

## Lifecycle Status

Active
