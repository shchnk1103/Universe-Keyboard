---
name: pre-push-review
description: Verify and prepare scoped Git commits, feature-branch pushes, or PRs when the user requests those actions. Execute only the requested publication steps.
---

# Pre-Push Review

## 授权与范围

用户要求本地 commit 就只提交；push、PR、merge、Release 分别核对当前授权。
“检查能否发布”是审查请求，不自动执行发布。已明确给出的同范围授权持续有效。
根目录 `AGENTS.md` 和用户的具体范围约束是执行依据，技能不授予额外权限。

先读取 status、unstaged/staged diff 与 diff --check，确定本任务文件 allowlist。
保留其他任务的改动；发布前核对实际分支、远端、staged 路径和完整差异。禁止批量 git add -A。
仅发布当前任务已审查的功能分支；在默认分支上工作时先建立隔离的功能分支。

## 验证

merge-bound / ship / 修 CI 的本地门禁以 `AGENTS.md` 为准，路径分级以
`docs/CI_CHANGE_CLASSIFICATION.md` 为准。未知路径不能自行按 docs-only 豁免。

最终内容、基线、依赖、覆盖 target、环境、新鲜度和结果均适用时，按 `docs/AI_WORKFLOW.md`
复用已通过证据。内容变化、rebase/merge、环境/依赖变化、过期、失败、覆盖不足或用户明确要求
重跑时重新验证。单纯再次要求 merge 不使完整有效证据失效。

草稿/仅功能分支发布可如实记录缺口，但不能声明可合并。改 App/Extension 测试后不能只跑 Core。

## 审查与修复

检查新增敏感文件、备份文件、危险强制操作、文档 Source of Truth 和实际行为变化。
文档影响使用 `docs/DOCUMENTATION_GOVERNANCE.md`，无影响给出简短理由。

用户已授权修复的本任务检查失败，继续定位并修复、执行相关验证；不要只把可修问题退给用户。
未授权修复、其他任务失败或真正缺少人类决定时，保留恢复点并报告具体缺口。
需要暂停时，指出阻塞动作、精确规则文件和适用条款，区分明文要求与自身推断。

## 执行与交付

用显式文件名单 stage，复查 staged diff 后按授权提交、推功能分支、创建 PR。
不自动推当前默认分支。报告 commit、目标分支、PR（如有）、验证与未运行项。
分支清理遵循 `AGENTS.md` 的 fetch/远端默认分支可达性/安全删除门，不因 push 成功而清理。
