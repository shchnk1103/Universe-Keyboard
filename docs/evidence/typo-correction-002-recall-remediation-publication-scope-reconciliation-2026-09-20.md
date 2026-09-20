# TYPO-CORRECTION-002 recall remediation publication scope reconciliation

- Reconciliation ID：`TC2-RECALL-PUBLICATION-SCOPE-20260920-001`
- Authorization：`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-SCOPE-RECONCILIATION-001`
- 时间：`2026-09-20T14:23:13+08:00`
- Worktree：`/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001`
- Branch：`codex/typo-correction-002-recall-preflight-001`

## 结论

本次只读对账**完成，但不能直接进入 publication staging**。原因不是本轮代码门禁失败，而是当前工作树的提交基线已经落后于 `origin/main`，且 working tree 同时包含 recall remediation、既有 parent/sidecar/testability 记录以及共享镜像文件。直接从当前目录执行 `git add -A` 会把不同工作车道混在同一个提交中，因此不满足 Product decision 要求的“最终文件范围与最终 identity 重新绑定”。

## 精确身份

| 项目 | 值 |
|---|---|
| 当前 HEAD | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| 当前 HEAD tree | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| `origin/main` | `162b09fd58ba60538a944026b1902efa405c75aa` |
| `origin/main` tree | `92c5047c5d1a6dd6a751eb5344117f8138c14ef2` |
| merge-base | `9eb83158e49218c1e8f75dbe7dd9e0390db81409` |
| 分叉计数 | `origin/main` 独有 3 个提交；当前分支独有 13 个提交 |

`origin/main` 独有的 3 个提交是 PR #140 的 AX testability 合并链：`bf460ea`、`9403a84`、`162b09f`。当前分支仍建立在旧的 `9eb8315` 基线上。当前分支独有的 13 个提交包含 parent sidecar/testability 历史记录以及 recall remediation 记录；它们不能被当作一个只含 recall 的新 publication diff。

## 当前 working tree 的分类

### A. Recall remediation 的源码/测试候选

以下是本次 preflight 之后发生 working-tree source drift、或新增的 recall 相关测试文件；它们是**后续干净 staging 的候选**，不是本 Authorization 的提交对象：

| 路径 | 当前身份 | 当前 SHA-256 |
|---|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift` | tracked modified | `d51da03539025cbd5aecd6862dcbfcef6c01b151` |
| `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift` | untracked | `8328fdad2d9a1de58eb89816842ddbf1016118d9` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift` | untracked | `b56ef0c65b67ea18847d5c8e788c83559f58b6e2` |
| `UniverseKeyboardTests/RimeSettingsStoreTests.swift` | tracked modified | `45c571adff9169331b8e43df7a900f5b8d613fa9` |

`Packages/KeyboardCore/Package.swift` 当前未改动；它的 SHA-256 仍为 `1a06a522f12089f3dbb2ad774d13fe9f56193d04`，只作为 package identity anchor，不应因为出现在 source manifest 中就被误报为改动文件。

### B. Recall remediation 的治理记录候选

后续 publication scope 可以从以下明确命名空间中选择并逐个绑定，而不是按整个 `docs/` 目录收集：

- `docs/assignments/typo-correction-002-recall-remediation-*.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-*.md`
- `docs/evidence/typo-correction-002-recall-remediation-*.md`
- `docs/product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-*.md`
- `docs/reviews/typo-correction-002-recall-remediation-*.md`
- `docs/plans/typo-correction-002-recall-remediation-design-2026-09-19.md`

其中包括 core contract、implementation preflight、test-contract/environment、vendor materialization、manifest reconciliation 和 publication-preflight 的历史记录。已消费的 Authorization、失败/被 superseded 的 receipt 以及 review 也属于可追溯记录；它们不能被删除或改写成成功结论。

### C. 共享镜像，不能整文件自动带入

下列路径同时承载其他工作车道或 parent 状态，当前版本不能直接作为 recall-only publication 的最终文件：

- `docs/ACTIVE_WORK.md`
- `docs/KNOWLEDGE_INDEX.md`
- `docs/assignments/typo-correction-002.md`
- `docs/TYPO_BENCHMARK_REGISTRY_V2.md`

它们若确实需要更新，必须在以 `origin/main` 为基线的干净工作树中做最小、可追溯的镜像变更；本次 working-tree 的整文件差异不自动属于 recall lane。

### D. 不应从当前旧基线直接 staging 的内容

当前 `git diff origin/main HEAD` 有 125 个路径差异，包含 sidecar observability、AX/testability、parent revalidation、历史 Simulator receipts 及其治理记录。它们是当前分支历史或其他车道的差异，不等于本次 recall remediation 的最终 publication scope。尤其不能用当前旧基线来重新发布已经合并到 `origin/main` 的 PR #140 内容。

## Provenance 边界

- canonical source manifest：`docs/evidence/typo-correction-002-recall-remediation-publication-preflight-source-manifest-2026-09-20-002.txt`
- canonical manifest SHA-256：`709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207`
- 历史 aggregate manifest：`bcbabcb7c7870b90691422ab7fd65f028f348921e64fc39ebaf5db94038d2e3e`，状态为 `superseded_not_reproducible`，不得重新使用。

上述 manifest 绑定的是旧 working-tree source snapshot，不是未来 commit 的证明。任何基线同步、冲突解决、源码字节变化或最终文件范围变化，都必须在后续 publication lane 重新生成 manifest，并重新绑定最终 commit/tree。

## 下一道授权边界

建议下一步建立新的 bounded **base-reconciliation / publication-staging Authorization**，允许：

1. 从当前 `origin/main=162b09f` 创建新的干净 worktree，不触碰本旧 worktree；
2. 只移植 A 类源码/测试候选与 B 类 recall 治理记录；
3. 对 C 类共享镜像做最小差异审计；
4. 重新计算最终文件清单、source manifest、HEAD/tree 和所有文件哈希；
5. 如果最终 Swift/source 字节或目标基线发生变化，按 KOS 规则建立新的 Run ID 并重跑适用质量门。

在上述步骤完成前，不应 commit、push、创建 PR，也不应把本对账结果当作 Product/Quality/Release Gate 或 parent Close。
