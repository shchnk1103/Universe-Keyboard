# Assignment: KOS-EXTERNALIZE-001 — 把 PM 的工具、规则与状态约定写进仓库

Policy version: 1.0.0
record_id: KOS-EXTERNALIZE-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active（K1、K2、K3 已合并） |
| Current phase | K1 工具小修包 KOS-TOOLS-FIX-001：本地提交，待独立复核 |
| Material non-claims | 不代表 Product Gate；不修改 `docs/PORTFOLIO.md`、`docs/ACTIVE_WORK.md`；不代表任何外置文件（如 PM-STATE.md）的内容已被复核 |
| Next handoff / decision | PM 写 K1 工具小修包；Human 确认 PM 手册 Q1–Q6；全部完成后由 Human 决定关闭本 Assignment |
| Residuals | PM 手册 2.3 节 Q1–Q6 待 Human 确认（见 [PM 手册](../kos/pm-playbook.md)） |

---

## Authority

- **Task ID / Title:** KOS-EXTERNALIZE-001 — 把 PM 的工具、规则与状态约定写进仓库
- **Assignment Authority:** Product Lead
- **Decision Source / Date:** 2026-11-04（Asia/Shanghai）。
  - Human 对 PM 提问“我提议为「KOS 外置」整件事建一份，覆盖 K1（已合并，补记）、K2、K3……你同意吗？”选择“同意这样分配（推荐）”。
  - Human 第二次选择：Architecture Reviewer “合并进 Quality 复核（推荐）”；再做一轮窄复检“再做一轮窄复检（推荐）”。
  - 原文记录在外置任务目录 `~/.kos-work/Universe-Keyboard/KOS-PM-PLAYBOOK-001/inputs/` 下：
    - `assignment-decision.md`，SHA-256 `d5d2cd219cce91abb691977f90dac06577c7734461cbf40131d6fe99a5a8f4ce`
    - `assignment-decision-r2.md`，SHA-256 `c393ffb0a4721c41a19ad02dce42d63a17f34accad980a75fc7f0a01f43e237a`
  - 责任表以 `assignment-decision-r2.md` 第 2 节为准。Human 在派发 K2 修订包 R3 的授权消息中逐字确认：“按 assignment-decision-r2.md 第 2 节确认 KOS-EXTERNALIZE-001 责任分配”。该消息点名任务包 SHA-256 `5b5a1f443ab046013c4742f113eb4a894adde2ecb386ffd6d3847b30973d358a`，授权回执为同一任务目录的 `reports/human-authorization-k2-issued.md`（SHA-256 `240cd43731a1ae33b228acb0ca6ef5e8679aebae5fc6cec8dea2d0ff4540c7ab`）。
  - K3 范围：Human 2026-11-04 对 PM 提问“K3 范围我提议这样定……你同意吗？”选择“同意这样定（推荐）”，原文见外置任务目录 `~/.kos-work/Universe-Keyboard/KOS-PM-STATE-001/inputs/k3-decision.md`（SHA-256 `2660cf4d8216fb44d12c61eec219462e1b0b6f5a6020707121c864a7c587285e`）；派发 K3 任务包的授权消息逐字确认“按 k3-decision.md 确认 KOS-EXTERNALIZE-001 K3 范围”，并点名任务包 SHA-256（见同一任务目录 `reports/human-authorization-k3-issued.md`，SHA-256 `c1eb6ea93b742d5ad89e7b50ac9c0a7e955594064b89b72558ac599e1bc92295`）。
- **Product Approver:** Human Product Owner（Product Lead）

## Boundary

- **Scope:** 把 PM 只存在于本机的工具、工作规则和状态约定写进仓库，使任何 AI 新开会话都能接过 PM 职责。分三个阶段：
  - K1：工具进仓库（已合并，仅补记）。
  - K2：PM 手册、固定条款库与本 Assignment。
  - K3：PM 状态与交接约定：新增 [PM 状态与交接约定](../kos/pm-state-and-handoff.md)，范围由 Human 2026-11-04 确定。
- **Non-goals:** 产品代码、测试、工程文件；`docs/PORTFOLIO.md`、`docs/ACTIVE_WORK.md` 的修改；项目事实（产品方向、上线优先级）。
- **Required Inputs:** 各阶段任务包所列冻结输入及其 SHA-256（外置任务目录 `instructions/`、`inputs/`）；上述 Decision Source；各阶段基线提交。

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** 每个阶段的任务包所指定的 Executor 会话（K2 = 派发 K2 任务包的会话）；不得同时担任本阶段的预检或复核。
- **Environment Executor:** Not Applicable — 纯文档与 PM 工具，不涉及设备、构建、部署、账号或环境操作（Human 2026-11-04 所选选项说明）。
- **Human Dependency:** Human：授权派发、合并 PR。释放条件：Human 发出点名包与 SHA 的授权消息；Human 执行合并。
- **Architecture Reviewer:** 与 Quality Reviewer 由同一个独立复核会话担任，只读，重点查单一来源与规则归属（Human 2026-11-04 选择）。
- **Quality Reviewer:** 同上；须独立于该阶段的 Executor 与包作者（PM）。
- **Product Approver:** Human Product Owner（Product Lead）

## Gates

- **Entry Criteria:** 每个写仓库的阶段：
  - 先经独立只读预检；PM 自加句子再做窄范围复检。
  - Human 发出点名包与 SHA 的授权消息。
  - 冻结输入与基线核对通过。
  - 在隔离 worktree 中执行。
- **Exit Criteria:** 每个阶段：
  - 包内交付物本地提交，并有外置执行报告。
  - 独立复核出结论。
  - Human 合并后，本阶段完成。
  - 三个阶段都完成后，本 Assignment 进入 Completed，再按政策评审与关闭。
- **Stop Conditions:** 冻结输入或基线不符；需要改动包外文件；事实缺出处；写入被拒；责任字段缺失或与政策冲突；复核独立性缺失。

## Handoff

- **Handoff Target:** Product Lead（Human），用于合并与下一阶段决定。
- **Required Handoff Content:** 阶段提交 SHA、任务包与报告的 SHA-256、复核结论所在的外置报告路径。
- **Revalidation Trigger:** 范围、基线、授权、输入或责任变化。K3 范围已于 2026-11-04 确定并据此更新本 Assignment。

---

## History

| 阶段 | 记录 |
|---|---|
| K1 = KOS-TOOLS-REPO-001 | 已合并：PR #260，合并提交 `3c7859fa2d561d5993090e3fe5688850436eb66b`（2026-11-04，`git show` 核实）。当时没有 Assignment，这里仅补记历史，不倒推当时 Assignment 或 Gate 曾通过。 |
| K2 = KOS-PM-PLAYBOOK-001 | 已合并：PR #261，合并提交 `45f95060d4ea4f1b8382785ed284a82f3a6c2ae1`（2026-11-04，`git show` 核实）。新增 [PM 手册](../kos/pm-playbook.md)、[固定条款库](../kos/pm-packet-clauses.md) 与本 Assignment，并更新路由。修订轮次与报告见外置任务目录 `reports/`。 |
| K3 = KOS-PM-STATE-001 | 已合并：PR #262，合并提交 `7c21bdb36c5f24036c09d63f57f9c812c3c359d8`（2026-11-04）。新增 [PM 状态与交接约定](../kos/pm-state-and-handoff.md) 并更新路由；范围按 Human 2026-11-04 决定。修订轮次与报告见外置任务目录 `~/.kos-work/Universe-Keyboard/KOS-PM-STATE-001/reports/`。 |
| KOS-TOOLS-FIX-001 | K1 工具小修与条款库补充；报告见外置任务目录 `~/.kos-work/Universe-Keyboard/KOS-TOOLS-FIX-001/reports/`。 |
