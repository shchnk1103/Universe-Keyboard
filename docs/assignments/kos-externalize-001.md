# Assignment: KOS-EXTERNALIZE-001 — 把 PM 的工具、规则与状态约定写进仓库

Policy version: 1.0.0
record_id: KOS-EXTERNALIZE-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active（K2 已按授权开始执行） |
| Current phase | K2 = KOS-PM-PLAYBOOK-001：PM 手册、固定条款库与本 Assignment 本地提交；待独立复核 |
| Material non-claims | 不含 push、PR 或 merge；不代表 Product Gate；不修改 `docs/PORTFOLIO.md`、`docs/ACTIVE_WORK.md`；K3 范围未决，不作为已批准实现 |
| Next handoff / decision | 独立复核会话（Quality 与 Architecture 合并）复核 K2；Human 决定发布与合并 |
| Residuals | None |

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
- **Product Approver:** Human Product Owner（Product Lead）

## Boundary

- **Scope:** 把 PM 只存在于本机的工具、工作规则和状态约定写进仓库，使任何 AI 新开会话都能接过 PM 职责。分三个阶段：
  - K1：工具进仓库（已合并，仅补记）。
  - K2：PM 手册、固定条款库与本 Assignment。
  - K3：PM 状态与交接约定（计划中）。
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
- **Revalidation Trigger:** 范围、基线、授权、输入或责任变化；K3 范围确定时须重新核对本 Assignment。

---

## History

| 阶段 | 记录 |
|---|---|
| K1 = KOS-TOOLS-REPO-001 | 已合并：PR #260，合并提交 `3c7859fa2d561d5993090e3fe5688850436eb66b`（2026-11-04，`git show` 核实）。当时没有 Assignment，这里仅补记历史，不倒推当时 Assignment 或 Gate 曾通过。 |
| K2 = KOS-PM-PLAYBOOK-001 | 当前阶段：新增 [PM 手册](../kos/pm-playbook.md)、[固定条款库](../kos/pm-packet-clauses.md) 与本 Assignment，并更新路由。修订轮次与报告见外置任务目录 `reports/`。 |
| K3 = PM 状态与交接约定 | 计划中，范围未决，不作为已批准实现。 |
