# RELEASE-2026-0801-04 — Build 55 Archive ↔ 导出包关系核对回执

> **Run ID:** `RELEASE-2026-0801-04-B55-ARCHIVE-EXPORT-RECONCILIATION-20260913`
> **Status:** `Completed — code-image lineage and export-stage build provenance reconciled; Archive metadata difference retained; independent re-review returned Blocked`
> **Evidence grade:** `Executor-recorded`
> **Collected:** `2026-09-13 Asia/Shanghai`
> **Assignment:** [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md)
> **Prior classification:** [`Build 55 TD-005 classification follow-up`](release-2026-09-13-build55-td005-classification-follow-up.md)
> **Prior review:** [`Build 55 Quality/Release review`](../reviews/release-2026-09-13-build55-quality-release-review.md)
> **Independent re-review:** [`Build 55 Quality/Release re-review`](../reviews/release-2026-09-13-build55-quality-release-re-review.md)

## Scope and authority

本回执按授权只核对现有 Xcode Cloud Archive、Store/Ad Hoc 导出包、dSYM、项目版本设置和导出日志，
回答两个问题：导出包是否来自同一代码映像，以及 Build `55` 的构建号从哪一层出现。没有重新构建或重新
导出，没有访问或改变 iPhone，没有修改代码、安装、卸载、清理 App Group/RIME/user dictionary，也没有
执行 Git、上传、分发或发布动作。

日志原文只保留在本机临时审计目录；本回执只记录可复核的版本、UUID、哈希和步骤摘要，不复制日志中的
证书、路径细节或其他敏感内容。

## Inputs

| Input | Recorded value |
|---|---|
| Candidate source | `main` @ `b8175129f26f787a6c7fee0be5977ebec46edf60` |
| RC tag | `testflight-v1.0-rc2-build55` → `b8175129f26f787a6c7fee0be5977ebec46edf60` |
| Xcode Cloud workflow | `Archive Pilot (No Distribution)`; Build `55`; Build ID `8ca1634e-9139-405a-aa5c-75c3d6919908` |
| Local audit root | `/private/tmp/uk-build55-audit.DNj3jv/` (read-only; outside the repository) |
| Archive | `archive/Universe Keyboard Build 55 Archive for Universe Keyboard on iOS.xcarchive/` |
| Store export | `store/Universe Keyboard 1.0 app-store/` and extracted `ipa/Payload/Universe Keyboard.app/` |
| Ad Hoc export | `adhoc/Universe Keyboard 1.0 ad-hoc/` and extracted `adhoc-ipa/Payload/Universe Keyboard.app/` |

## Observed build-number provenance

### Source and Archive

在冻结 commit 的 `Universe Keyboard.xcodeproj/project.pbxproj` 中，App 和 Keyboard 的 Debug/Release
配置均为 `CURRENT_PROJECT_VERSION=1`、`MARKETING_VERSION=1.0`；`config/Info.plist` 使用这些变量。
归档日志中的 `xcodebuild archive` 命令没有显示 `CURRENT_PROJECT_VERSION` 覆盖，且 Archive 的 top-level、
嵌入 App/Extension 和两份 dSYM metadata 都报告 `1.0 (1)`。

这部分是 Archive 的直接事实：不能仅凭目录名“Build 55 Archive”或 Xcode Cloud workflow 名称，把该
Archive 的嵌入 `CFBundleVersion` 改称为 `55`。

### Export stage

Store 和 Ad Hoc 的 `IDEDistribution.standard.log` 都记录了导出开始时的 `buildNumber="55"`，并且
`manageAppVersionAndBuildNumber=false`。两条 `Packaging.log` 都记录了 `IDEDistributionCopyItemStep`
从 Archive 的 `Products/Applications/Universe Keyboard.app` 复制产品树，随后进入
`IDEDistributionInfoPlistStep`，最后分别导出到 Store/Ad Hoc 目录。导出后的 App/Extension 和两个
`DistributionSummary.plist` 都报告 `1.0 (55)`。

因此，当前能被证据直接支持的描述是：同一代码映像的导出阶段明确带入了 Build `55`，导出包得到
`1.0 (55)`；Archive 本身保留 `1.0 (1)`。日志没有说明内部如何应用该 build number，所以本回执
不把“导出改写机制”扩写成未经证明的 Xcode 内部根因。

## Code-image relationship

| Relationship check | Result |
|---|---|
| Archive App ↔ Store App executable UUID | `6898B44F-EF4F-3B46-93C8-BCE83668270A` — match |
| Archive Keyboard ↔ Store Keyboard executable UUID | `C6C1758B-ECA2-3784-8EFA-22AF59B6CF25` — match |
| Archive ↔ Ad Hoc App/Keyboard executable UUIDs | Both UUIDs match |
| App/Keyboard executable UUID ↔ dSYM UUID | Exact match |
| Archive/Store/Ad Hoc non-identity resource tree | `57` files, identical paths and SHA-256 manifest |
| Mach-O load-command comparison | UUID and functional load-command values match; observed differences are link-edit/code-signature size fields |

非身份资源清单比较排除了 `Info.plist`、`PkgInfo`、`embedded.mobileprovision`、`_CodeSignature` 以及
App/Keyboard 两个可执行文件；三方均为 `57` 个文件，确定性 manifest SHA-256 为
`acfd49123d1be1fa8a35098300427a0af5a2563ee38a3888bc17ba3f6da6094d`。这证明了资源和代码映像的
强关联，但不把不同签名后的二进制 SHA-256 误读为字节完全相同。

## Reconciliation result

| Dimension | Result | Claim boundary |
|---|---|---|
| Source project version setting | `confirmed` | Frozen commit defaults to `1.0 (1)` |
| Retained Archive embedded metadata | `confirmed` | Archive/dSYM metadata is `1.0 (1)` |
| Export invocation provenance | `confirmed` | Store and Ad Hoc logs explicitly carry `buildNumber=55` and copy the Archive product tree |
| Exported package identity | `confirmed` | Store/Ad Hoc App and Extension are `1.0 (55)`; summaries are `55` |
| Code-image lineage | `confirmed` | App/Keyboard UUIDs and dSYM mapping match across the retained artifacts |
| Exact Archive metadata equal to Build 55 | `not equal` | The Archive plist remains `1`; preserve this difference in receipts |
| Candidate relationship | **`conditionally reconciled`** | Same code-image lineage and explicit export-stage Build 55 provenance; no claim that Archive plist itself says `55` |
| TD-005 | **`Blocked`** | The three matching Jetsam rows still lack victim evidence and remain `unclassified` |

本核对把此前“Archive ↔ Build 55 关系未解释”的问题收窄为“代码映像链和导出阶段来源已核实，Archive
自身构建号字段与导出构建号字段有意保留差异”。这不是 TD-005 的终止分类结论；独立 Quality/Release
Reviewer 需要决定该分层证据是否足以接受候选身份，或是否仍要求真正写入 `55` 的 Archive/dSYM。

## Artifact hashes

下列哈希均来自本机临时审计目录；日志原文不进入仓库。

| Artifact | SHA-256 |
|---|---|
| Store IPA | `b178c05530b92a207eb8aaf4e701c1db803fec728c3df702424c89944ee1c6fd` |
| Ad Hoc IPA | `ec02dc4a959549d6ba2b36224a405740b4eeb7ca2cfbcdcbab5b0932ae069ebc` |
| Archive top-level `Info.plist` | `1b31d02481b9f622b4ba3462fcc943222fad0c028cedba76a9132012556ddf6f` |
| Archive embedded App `Info.plist` | `c3b5e0fb5ffaf79d06b2e91fdd11c7f434f68fdfe6e5c0e8679c6c59e0fa9779` |
| App dSYM `Contents/Info.plist` | `792ed32bb9f932086b00cb9b5169ca60dd5ad82f89b8c2706817c0cebc4768be` |
| Keyboard dSYM `Contents/Info.plist` | `033688c9e4419fe5f95e36d1fce1e7569fe5939ecf6507bfa7f5fa0cd39027ed` |
| Store `DistributionSummary.plist` | `d0c355d3164723a6eb2cb8eda6de21312d6c8e448cdf090ac7fb6d82246e15a3` |
| Store `ExportOptions.plist` | `f6a1ed438216c576b6be91ef40a1844cbaf51ee0c456675ded8223e63416a5db` |
| Ad Hoc `DistributionSummary.plist` | `9394c51cd5b52752f47a750c785ea9552bba10aaa9fde80eaad3e68540edb1b5` |
| Ad Hoc `ExportOptions.plist` | `580341a98c3219f1add000cd80b257ca9604502fc5da11d5d01ff4ea3b31b043` |
| Archive log | `b873b3c57a0456e15355ba5bb1d2ae3c8eaedc90df6be75f38a24207610a67b9` |
| Store distribution standard log | `4c183e7017bcfd13d1224b03f797994424127220cf8e84241de13d2ed96548bb` |
| Ad Hoc distribution standard log | `f80fad0dd1673426921158ef888b8a41eace66cfbeae2c547e4074009dcfa43f` |

App/Keyboard dSYM DWARF SHA-256 仍分别为 `e93313058a4983af7a8d5f5d75aff751a53899becceb3329a7a9eea9bd88d5d0`
和 `d82a1ca71fec466acf23fd7be12431fd794392e8b7b77211732cda034434ec0f`，与前一份 TD-005 回执一致。

## Handoff and independent review result

独立 Quality/Release Reviewer 已按以下三点完成只读复核：

1. 是否接受“Archive 元数据为 `1`、导出阶段明确产生 `1.0 (55)`，且代码映像 UUID/资源链一致”作为
   Build 55 候选关系的有界证据，还是要求取得嵌入构建号为 `55` 的 Archive/dSYM。
2. 无论身份结论如何，是否同意三份 Jetsam 因没有 victim 标记而继续保持 `unclassified`，不执行
   symbolication，也不把它们算作 Keyboard termination。
3. 在上述边界下，是否改变此前 **Blocked** 的 Quality/Release 结论；Reviewer 返回的结论另见独立复核回执。

本回执不授权新的设备测试、终止诱发、上传、外部分发、Beta Review 或 Release。独立复核结果为
**Blocked**：候选关系条件性接受，但 TD-003/004/005、clean App Group 和整体公测 Release Gate 仍开放；
由 Product Lead 决定是否继续补证据或调整发布范围。详见 [`Build 55 Quality/Release re-review`](../reviews/release-2026-09-13-build55-quality-release-re-review.md)。
