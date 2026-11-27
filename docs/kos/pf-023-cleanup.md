# 合并后清理（PF-023）与 squash 双验删枝

绑定红线在 `AGENTS.md`：禁止 `--force`；**未通过下方三条硬条件前，全局禁止 `git branch -D`**；受保护对象不得删除；删除失败立即停批。本文是检查、命令、回执与快进的操作全文。

## 清理前检查与授权

- 时点与负责人：PR 合并、核对合并结果时，由该任务的 Executor 列出本任务创建的 worktree 与分支。
- 清理前检查：拉取最新远端后，确认已并入 `origin/main`、未提交改动为 0、不受保护。复查不满足的对象跳过，其余继续；任何删除命令失败或被拒，立即停止整批并保留检查点。
- 授权方式：Human 一条消息授权一批，点名清单与 SHA。
- 执行方式：安全删除（`worktree remove` 不加 `--force`、`branch -d`、`push --delete`）。禁止强制删除。PR 未合并、检查失败或远端状态无法确认时，保留本地和远端分支。
- 记录：外置回执写明对象、删前 SHA、检查结果与实际结果。
- 受保护对象：B-001 工作区与分支、`preserve/`、`local/`、`backup`、有未提交改动的、进行中任务的、其它工具目录。
- 远程分支是否在合并时自动删除，取决于 GitHub 仓库设置（由 Human 决定）。

## 主检出快进

在该任务合并清理包明确授权下，由合并清理 Executor 执行。合并并 fetch 后，若主检出在 `main`、没有本地改动或未跟踪文件、且 `HEAD` 是已 fetch 的 `origin/main` 的祖先，执行 `git merge --ff-only origin/main` 并报告新旧 SHA；任一条件不满足则不动主检出，并告诉 Human。真机装机前的 HEAD 核对见 [github-publish.md](github-publish.md)（O122-D）。

## squash 合并后双验安全删本地分支协议（O123）

PR 采用 squash merge 后，本地功能分支提交不在远端主干祖先链上，`git branch -d` 必然被拒绝。此时仅在**同时满足以下三条硬条件**后，才允许对**该单一已合并功能分支**带证据执行删除；未通过双验前，全局禁止 `git branch -D`：

1. **PR 合并可达**：`gh pr view <PR> --json state,mergeCommit` 核实状态为 `MERGED`，且拉取远端主干后确认 `mergeCommit` 可从远端主干到达；
2. **内容级零残留**：`git diff <branch> <mergeCommit> -- <本分支涉及文件清单>` 输出为空（文件清单以 PR 实际改动文件集合为界，避免合并后主干其他 PR 引入无关差异造成误判），确认无未合并增量；
3. **单支带证据删除**：受保护对象（`preserve/`、`local/`、`backup`、未提交改动、在用分支）仍严格豁免；清理回执必须记录 PR 号、`mergeCommit` SHA 及 diff 为空证据，逐支核对、逐支删除，失败立即停止整批。
