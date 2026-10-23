# PF-023 — 分支与 worktree 的清理机制

本文是指针与讨论背景，**不是状态权威**。状态 `Backlog`。本任务没有执行任何清理，也没有授权清理。下面的数字来自 2026-10-23 的只读盘点，标“抽样，未经复现”；Executor 没有重跑 `du` 或 `git worktree list`。

## 仓库事实

- 已有清理规则只有 `AGENTS.md` 第 60–63 行：已推送不等于可清理；只有拉取最新远端并确认提交可从 `origin` 默认分支到达之后，才允许清理功能分支；清理须先同步默认分支再安全删除，并报告结果。这几行没有说何时该清理、由谁触发，也没有覆盖 worktree 与构建产物。
- `docs/ACTIVE_WORK.md` 第 45 行写明 keyboard-wake 的隔离 worktree `paired-rollout-preflight` 为 KEEP。盘点把该 worktree 标为保留。
- 盘点基线是当时的 `origin/main` `ce165f732c333fcd07b9a8cc950524d5e450acd1`，且注明未 fetch。本任务开工时的 `origin/main` 已是 `ba01a45472b8e52da8cdda3473c4031976d1db02`。因此“已合并”以盘点当时的本地远端引用为准，不是当前远端的复测。

## 2026-10-23 只读度量（抽样，未经复现）

来源：KOS 根 `GROK-BOT-TRIAL-006/reports/inventory.md`。摘要第九节的早期粗数（本地已合并 12、远程分支 16、磁盘占用、约 50GB）被这次逐项盘点取代；下表用盘点数字。

| 项 | 盘点值 |
|---|---|
| worktree | 28 个，分散在 `.codex`、`.grok`、`.lody`、`.claude`、`~/.kos-work` 五处 |
| 本地分支 | 37 个，其中 14 个已可从当时的 `origin/main` 到达 |
| 远端引用 | 17 个（含 `origin` 符号引用与 `origin/main`）；功能分支 15 个，其中 10 个当时已合并 |
| 候选退役 worktree | 8 个，合计 915940 KB（约 0.9GB） |
| 可再生构建产物 | `.build`、`build`、Xcode DerivedData 合计 15256384 KB；其中 DerivedData 8153660 KB。另有 Spike 的 `DerivedData-*` 约 9GB（摘要第九节；盘点未单列这一项） |

8 个候选是：`KEYBOARD-VALUES-DOC-001`、`LIFECYCLE-CLOSEOUT-BATCH-1C-001`、`PORTFOLIO-DIRECTORY-001`、`PORTFOLIO-REFRESH-001`，以及主检出 `.claude/worktrees` 下的 `active-work-stale-facts-sync-001`、`keyboard-compact-header-001-state-sync-001`、`lifecycle-closeout-batch-1-001`、`lifecycle-closeout-batch-1b-001`。盘点对它们的理由是：当时已合并、工作树干净、无未推送、对应 Assignment 读作 Closed。

关键发现：这 8 个候选加起来约 0.9GB，真正占空间的是可再生构建产物。所以分支与 worktree 清理是整洁问题，不是空间问题。

## Human 决定

- 2026-10-23：把分支与 worktree 越堆越多当作要处理的事，并与 PF-014、PF-017 的动机合并为本行。
- Human 同意先做第 1 步：只读盘点。该步已由 Grok bot 完成。
- 规则细节待定。Cleanup Audit 没有放入仓库。

## 四种生命周期概念（Human 与 ChatGPT 的讨论，未核对）

任务关闭、分支可退役、工作区可删除、证据已归档，是四件不同的事。仓库里没有把这四个词定义成一组合同。既有相关规则是 `AGENTS.md` 第 60–63 行和 [Assignment Policy](../ASSIGNMENT_POLICY.md) 第 159 行（Handoff Target）。下面的机制没有把这四个词写成已采纳定义。

## Coordinator 的建议（Human 同意先做第 1 步；规则细节待定）

建议分三类资产：可再生的构建产物；worktree 与分支（已合并可达、Assignment 已 Close、证据已归档之后才可退役，成批列清单，由 Human 一次授权）；证据（压缩归档并带 SHA-256 清单之后才谈删除）。两个触发点：Assignment 收尾加一行“退役检查”，以及定期只读盘点。不写删除脚本。这些是建议，不是已采纳的规则，也没有 Assignment。

## 待 Human 决定（盘点原文，未执行）

1. 8 个候选退役 worktree 与 8 个本地 `docs/*` 分支，须先逐个确认 Close 记录是否写 KEEP，才能再谈第二阶段。
2. 8 个已合并的远端 `docs/*` 分支，须先 fetch 确认远端仍在，再决定是否处理。
3. 不确定项：worktree #10、#13、#23，以及 `claude/ui2-pr217-ci-whitespace-001`、`lody/e155f4ee-6ff`。
4. detached 且脏的 worktree，以及其中未提交改动是否需要保存。
5. A 类构建产物、CoreSimulator、仓库 `evidence/` 的处置。
6. C 类 23 个归档候选目录的归档方式与位置。

## 治理提示

本任务只记录盘点。删除分支、worktree、构建产物或证据，都要另有 Human 授权，并遵守 `AGENTS.md` 第 60–63 行。
