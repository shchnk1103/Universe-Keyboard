# TYPO-CORRECTION-002 recall remediation publication staging 001

- Staging ID：`TC2-RECALL-PUBLICATION-STAGING-20260920-001`
- Authorization：`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-BASE-RECONCILIATION-PUBLICATION-STAGING-001`
- 时间：`2026-09-20 Asia/Shanghai`
- Source worktree：`/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001`
- Staging worktree：`/private/tmp/universe-keyboard-typo-correction-002-recall-publication-staging-001`
- Staging branch：`codex/typo-correction-002-recall-publication-staging-001`

## Identity

| 项目 | 值 |
|---|---|
| Staging HEAD | `162b09fd58ba60538a944026b1902efa405c75aa` |
| Staging HEAD tree | `92c5047c5d1a6dd6a751eb5344117f8138c14ef2` |
| Base | `origin/main=162b09fd58ba60538a944026b1902efa405c75aa` |
| Source manifest | `docs/evidence/typo-correction-002-recall-remediation-publication-staging-source-manifest-2026-09-20-001.txt` |
| Manifest SHA-256 | `709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207` |

## 已完成

1. 新 staging worktree 从精确的 `origin/main=162b09f` 创建；旧的 mixed worktree 未被清理、reset 或修改其源码。
2. 只移植 recall remediation 的 4 个源码/测试候选：
   - `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift`
   - `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift`
   - `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift`
   - `UniverseKeyboardTests/RimeSettingsStoreTests.swift`
3. 只移植 `typo-correction-002-recall-remediation` 命名空间的 Assignment、Authorization、evidence、review、Product decision 和 design records，并补齐 recall Assignment 明确列出的两个直接 provenance 输入：`typo-correction-002-file-provenance-audit-2026-09-19.md` 与 `typo-correction-002-recall-coverage-matrix-2026-09-19.md`。
4. 对 `docs/ACTIVE_WORK.md`、`docs/KNOWLEDGE_INDEX.md`、`docs/assignments/typo-correction-002.md` 只增加 recall staging 的最小可追溯镜像；未复制旧 mixed worktree 的整文件差异。
5. 五个 source-manifest 条目的 SHA-256 全部与新 manifest 一致；manifest 文件自身 SHA-256 为 `709370f8…`。
6. 对 65 个 intended Markdown 文件执行 repository-local link check，结果通过；未把 parent revalidation 的整套 receipts 递归吸收到 recall staging。

## Explicit exclusions

以下两个临时审计副本不属于最终 allowlist，不得被 staging commit 吸收；parent lane 仍以其自己的 Assignment/receipt 为准：

- `docs/assignments/typo-correction-002-parent-revalidation-002.md`
- `docs/evidence/typo-correction-002-parent-checkpoint-2026-09-19.md`

## 当前 residual / blocking boundary

初次 staging 检查发现新 worktree 缺少 12 个 RIME artifact；随后在独立 vendor materialization Authorization 下完成固定 archive fetch/verify。当前 vendor prerequisite 已满足，详见 [`vendor staging evidence`](typo-correction-002-recall-remediation-rime-vendor-materialization-2026-09-20-002.md)。

截至本 receipt，尚未执行 RimeBridgeTests、App + Keyboard Debug test 或 Release build，也没有生成新的质量 Run ID；这些必须在下一道 bounded quality Run Authorization 下进行。

## Non-claims

- 未修改生产 Swift 逻辑；本轮只是显式文件迁移和治理镜像更新。
- 未 stage、commit、push、创建/更新 PR 或 merge。
- 未产生 Simulator/device Run；不构成 INT-003、QA-001、paired-performance、180 ms、Product/Quality/Release Gate 或 parent Close 结论。

## Handoff

vendor materialization 已完成。下一步需要新的 bounded quality Run Authorization，在这个 staging worktree 内用新的 Run ID 执行适用的格式、KeyboardCore、RimeBridgeTests、App + Keyboard 和 Release 门禁，并重新绑定最终 manifest/HEAD/tree；publication 仍未授权。
