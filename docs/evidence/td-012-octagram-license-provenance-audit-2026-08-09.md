# TD-012：librime-octagram 许可证与来源审计

> **Evidence grade:** `Executor-recorded`
>
> **Scope:** 上游公开来源与许可证迁移的只读审计；不构建、链接、分发或部署任何 artifact，也不提供法律意见。
>
> **Related:** [TD-012](../TECH_DEBT.md#td-012-optional-rime-grammar-model-万象-lmdg--gram-integration)、[G1 准备计划](../plans/td-012-octagram-vendor-readiness-plan.md)、[G0 artifact audit](td-012-g0-octagram-artifact-audit-2026-08-09.md)

## 结论

截至 `2026-08-09 Asia/Shanghai`，上游 `lotem/librime-octagram` 的公开证据表明：维护者
在 PR [#8](https://github.com/lotem/librime-octagram/pull/8) 中把仓库根许可证从 GPL-3.0
改为 BSD-3-Clause，并公开征求三名记录贡献者同意；三人均回复同意，PR 已合并。GitHub
许可证 API 与根 `LICENSE` 目前也报告 BSD-3-Clause。

但 `src/grammar_module.cc` 保留的 GPLv3 文件头没有在该 PR 中同步修改。因此本审计的工程
处置是：**可以把上游 relicense 视为有来源的候选输入，但不能由 Executor 宣称法律意见或
自动批准分发。** G1 若获准，必须 pin 到该 relicense merge commit 或其后代，并由项目指定
的 Product/许可负责人确认这份公开记录满足本项目的分发阈值。

## 固定输入与观察

| 项目 | 观察 | 来源 |
|---|---|---|
| 当前根 LICENSE | GitHub API 报告 `BSD-3-Clause`；blob `f05b7c297121afc7e6115d8e4eada27d049894a1` | [license API](https://api.github.com/repos/lotem/librime-octagram/license) / [LICENSE](https://github.com/lotem/librime-octagram/blob/master/LICENSE) |
| 原始许可证 | 初始提交 `a4e5b72bda82d961cec1d4b6e3ca7bcefdb1526c` 新增完整 GPL-3.0 LICENSE 和 `grammar_module.cc` | [initial commit](https://github.com/lotem/librime-octagram/commit/a4e5b72bda82d961cec1d4b6e3ca7bcefdb1526c) |
| relicense 变更 | PR #8 仅改 `LICENSE`，从 GPL-3.0 文本替换为 BSD-3-Clause | [PR files](https://github.com/lotem/librime-octagram/pull/8/files) |
| relicense merge | merge commit `bfb168ca33d8b372596fdf2007933f3da1cf360e`，合并于 `2026-07-22` | [merge commit](https://github.com/lotem/librime-octagram/commit/bfb168ca33d8b372596fdf2007933f3da1cf360e) |
| 贡献者同意 | PR #8 中 `lotem`、`eagleoflqj`、`fangquinlan` 都发表 “I agree.”；维护者随后回复 “Merged.” | [PR conversation](https://github.com/lotem/librime-octagram/pull/8) |
| 尚未同步的文件头 | 当前 `grammar_module.cc` 仍标注 “Distributed under GPLv3” | [source](https://raw.githubusercontent.com/lotem/librime-octagram/master/src/grammar_module.cc) |

## 可复现的只读复核

在具备 GitHub API 只读权限的环境中运行：

```bash
gh api repos/lotem/librime-octagram/license
gh api repos/lotem/librime-octagram/pulls/8
gh api 'repos/lotem/librime-octagram/pulls/8/files?per_page=100'
gh api 'repos/lotem/librime-octagram/issues/8/comments?per_page=100'
gh api 'repos/lotem/librime-octagram/commits?path=LICENSE&per_page=100'
```

这些命令只能复核 GitHub 上的公开历史，不能替代适用法域的许可证分析、版权链完整性审查或
项目的分发决定。

## G1 影响

1. G1 的固定 source revision 不得早于 `bfb168ca33d8b372596fdf2007933f3da1cf360e`。
2. 因为文件头未同步，artifact notice/来源清单必须同时记录根 LICENSE、PR #8、merge commit
   和此残余，不能只写自动识别的 SPDX 值。
3. 这份来源证据移除了“未知的上游意图”这一阻塞，但不移除项目自身的许可证/分发阈值 Gate。
4. G0 的 runtime No-Go 保持不变；无带 octagram 的新 artifact 时，任何 `.gram` 落盘仍是禁止项。

## 未决交接

| 未决项 | Owner | 需要的决定 |
|---|---|---|
| 本项目能否以该公开 relicense 记录作为 G1 的分发来源基础 | Product/许可负责人 | 明确接受或拒绝；若接受，指定需要保留的 notice。 |
| G1 是否只限 vendor capability，明确不含模型文件 | Product Lead | 确认范围，避免把 `.gram` 下载偷渡进 artifact 工作。 |
| G1 的独立 Architecture / Quality reviewer | Product Lead | 命名 reviewer，满足 Assignment 的 `Ready` 前置条件。 |

在以上项目未明确前，任何新 G1 Assignment 必须保持 `Assignment Pending`，不得进入 `Ready`。
