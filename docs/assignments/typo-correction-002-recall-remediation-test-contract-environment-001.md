# Assignment: TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-001

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Reviewed with conditions` |
| **Phase** | test-only deployment fixture 已补齐 `librimeVersion` 与 builtin `runtimeSmokePassed`；App + Keyboard Debug 通过；独立 Architecture/Quality 均为 bounded Pass with conditions。 |
| **Non-claims** | 不代表生产逻辑正确、RIME 部署正确、设备 Run、180 ms、QA-001、INT-003、Product/Quality/Release Gate、publication、commit、push、PR、merge 或 parent Close。 |
| **Next** | 申请新的 publication-preflight Authorization，绑定 parent 的完整 source allowlist 与已对账的 `388 total / 379 passed / 9 skipped / 0 failed`，再重跑完整门禁。 |
| **Residuals** | production `SchemaManager+Deployment` 的 provenance fail-closed 保持不变；`CODE_SIGNING_ALLOWED=NO` 造成的 107 条 App Group warning 未关闭；权威执行计数已对账为 `388 total / 379 passed / 9 skipped / 0 failed`，外层 `389 discovered` 仅保留为历史 wrapper 摘要；当前没有新产品 Run ID。 |

## Authority

- **Assignment Authority:** Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai`。
- **Executor:** Current Codex Executor, isolated remediation worktree。
- **Domain Owner:** Keyboard Experience（仅测试契约 / 测试环境边界）。
- **Independent Architecture:** Required after any test-source change; read-only review only。
- **Independent Quality:** Required after the relevant Debug gate is green or residual is explicitly retained。
- **Parent Assignment:** [`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`](typo-correction-002-recall-remediation-publication-preflight-001.md)。
- **Decision Source / Date:** [`publication preflight evidence`](../evidence/typo-correction-002-recall-remediation-publication-preflight-2026-09-20.md), `2026-09-20 Asia/Shanghai`。
- **Matching Authorization:** [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-001.md)。

## Boundary

### Scope

1. 只读核对七个失败的 `RimeSettingsStoreTests`、测试专属 deployment fixture、`RimeDeploymentResult.librimeVersion` provenance contract、`SchemaManager+Deployment` fail-closed 分支，以及测试运行时 App Group entitlement 警告。
2. 只读核对已确认测试 fixture contract 不满足现有 production contract；可修改测试源或 test-only fixture，使其提供确定、非空且可审计的测试 provenance；不得改变 production fail-closed 语义。
3. 可使用独立 DerivedData/cache 和既定 Simulator 运行 App + Keyboard Debug tests；记录失败/通过、日志、result bundle、source identity 和 non-claims。
4. 仅在当前 Assignment 范围内更新治理文档与 evidence；不把测试通过升级为 Product/Quality/Release Gate。

### Non-goals

- 不修改 production `SchemaManager+Deployment`、KeyboardCore、RimeBridge、RIME schema/vendor、部署流程、App Group canonical mapping 或运行时 controller。
- 不修改 checked-in entitlements、Xcode target signing 配置或生产 App Group；若测试 lane 必须改变这些配置，停止并申请新的专门 Authorization。
- 不创建或重跑 INT-003、QA-001、paired-performance、180 ms、真机或新的产品 Run。
- 不使用 FakeCandidateProvider、旧 Ice 目录、clipboard、pasteboard、host documentContext、网络或合成产品行为证据。
- 不执行 commit、push、PR、merge、TestFlight、Release 或关闭 parent/既有 preflight Assignment。

## Frozen Identity

| Field | Value |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| Source HEAD | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| Source tree before ignored Vendor | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| `Packages/KeyboardCore/Package.swift` SHA-256 | `9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764` |
| Pinned vendor archive SHA-256 | `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9` |
| Materialized vendor tree SHA-256 | `d446b0a4cdd40d42f53359ba8a7677d625ac8461c60ecfe92f90ca73e8df14fd` |
| Failing fixture blob | `UniverseKeyboardTests/RimeSettingsStoreTests.swift:55bd3e697da246ec2455deebb4c63dc364b40baa` |
| Simulator | `iPhone 17 Pro / iOS 26.0 / 8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2` |

## Gates and Handoff

- **Entry:** current publication-preflight evidence and this matching Authorization are present; Authorization was consumed before the test-source change.
- **Exit:** root cause is classified as fixture contract, test environment, or unresolved; any test-source change is formatted, tested and recorded; production source and checked-in entitlements remain unchanged.
- **Handoff:** Independent Architecture review → Independent Quality review → update the parent preflight decision. A green Debug gate is necessary but does not itself authorize publication.
- **Stop:** source/package identity drift, need to alter production behavior or entitlements, inability to provide provenance-safe fixture data, any new device/product evidence request, or a request to publish.

## History

- `2026-09-20 Asia/Shanghai`：Human Product Owner 授权建立本 bounded child，针对 publication preflight 的 App + Keyboard Debug 红门禁进行测试契约 / 测试环境核对；尚未修改代码、未消费 Authorization、未发布。
- `2026-09-20 Asia/Shanghai`：只读核对确认 `StoreDeploymentService` 成功结果缺少 `librimeVersion`；App Group warning 与 `CODE_SIGNING_ALLOWED=NO` 测试环境并列记录，未修改 entitlements。
- `2026-09-20 Asia/Shanghai`：消费 matching Authorization；允许的下一步仅为 test-only fixture provenance 修复与 App + Keyboard Debug 验证。
- `2026-09-20 Asia/Shanghai`：第一次仅补 `librimeVersion` 的重跑仍为 `372/7/9`；进一步核对确认 builtin receipt 还要求 `runtimeSmokePassed=true`。
- `2026-09-20 Asia/Shanghai`：补齐两个 test-only provenance 字段后，swift-format strict lint 通过，App + Keyboard Debug `379/0/9` 通过；保留 107 条 entitlement warning 为独立 residual，等待 Architecture/Quality 复核。
- `2026-09-20 Asia/Shanghai`：独立 Architecture 与 Quality 均返回 `Pass with conditions`。两者确认 fixture 修复未改变生产 fail-closed 或 signing/entitlement 边界；对账发现外层 `389 discovered` 与 xcresult `388 total` 不一致，publication-preflight 前必须固定权威计数与 manifest。Lifecycle → `Reviewed with conditions`，未关闭。
- `2026-09-20 Asia/Shanghai`：消费 docs-only reconciliation Authorization；补充 count/hash/scope reconciliation receipt。权威执行计数固定为 `388 total / 379 passed / 9 skipped / 0 failed`；当前 Git blob 与文件 SHA-256 分开记录；child manifest 不替代 parent publication manifest。
