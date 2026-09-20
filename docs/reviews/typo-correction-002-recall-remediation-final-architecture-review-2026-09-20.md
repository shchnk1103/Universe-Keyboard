# Independent Architecture Review: TYPO-CORRECTION-002 recall remediation final staging

## Verdict

**Bounded Pass with conditions — no blocking Architecture finding for the next independent Quality review.**

本 review 仅覆盖指定 final staging worktree、final manifest、四个指定代码/测试文件和
Quality Run 002 receipt。它不授权 publication、commit、push、PR、merge、runtime 接线、
设备验收或任何 Product/Quality/Release Gate。

## Exact identity and manifest

| 项目 | 独立核对结果 |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-publication-staging-001` |
| HEAD | `162b09fd58ba60538a944026b1902efa405c75aa` — 与 Authorization 一致 |
| HEAD tree | `92c5047c5d1a6dd6a751eb5344117f8138c14ef2` — 与 Authorization 一致 |
| Final manifest SHA-256 | `e2b4373c0797a0959b0b0da10c1db01cf4fa81cfe25903c7d9726942edab465c` — 与 Authorization/Quality Run 002 一致 |
| Manifest bytes | 652 bytes；5 行；LF；无 CR；最后一个字节为 `0a`；路径按字典序排列 |

五个 manifest entry 的当前文件 SHA-256 全部匹配：

| Path | SHA-256 |
|---|---|
| `Packages/KeyboardCore/Package.swift` | `9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764` |
| `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift` | `9fb3fdc9c4cb809cf08b098bd882226e74a1a74eef23a043bba261d017216b57` |
| `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift` | `e05488596a044e199b30fb3f262f72877ff31b172ba98638091b44ce7b030c9d` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift` | `9147004b425c19f2326292358f13e6db90c4d3969f2e4fb758841119991f3fd6` |
| `UniverseKeyboardTests/RimeSettingsStoreTests.swift` | `737206cf1020c35e339bf3dd2a461ce8a1d77c440a22eebe9b8741e3b444705b` |

因此本轮 source allowlist 恰好是上述五项，没有将历史 manifest 或旧 staging identity
混入当前绑定。

## Architecture boundary

- `ContextualTypoCorrection.swift` 的生产默认仍是 `productionV2` 的 12/8 contract；
  preflight 显式使用独立的 progressive budget，并默认 `substitutionOnly`。
- `TypoCorrectionRecallPreflight.swift` 只引入 Foundation，定义纯 Core 的预算、计数、
  batch/query 状态、取消、operation revision/epoch stale fence 和 fail-closed publish
  条件；没有 RIME/deployment API、持久化、网络或 UI 接口。
- `TypoCorrectionRecallPreflightTests.swift` 只引入 XCTest 并通过
  `@testable import KeyboardCore` 验证上述纯 Core 行为；未引入 parent 的生产 RIME/
  deployment contract。
- `UniverseKeyboardTests/RimeSettingsStoreTests.swift` 的当前 diff 只改动
  `StoreDeploymentService` 这个 test-only actor fixture，为成功路径补齐
  `runtimeSmokePassed` 参数；失败/取消路径没有伪造成功 provenance。没有修改生产
  RIME/deployment 实现。

结论是 recall remediation 仍保持 pure KeyboardCore；fixture alignment 属于测试层，
且落在声明的五项 manifest allowlist 内。

## Quality Run 002 boundary

Quality Run 002 receipt 记录：

- KeyboardCore：`1139 tests, 0 failures`，保留历史 optional-interpolation warning；
- RimeBridge：`81 passed, 0 failed, 20 skipped`；
- App + Keyboard：`388 discovered; 378 passed, 0 failed, 9 skipped`；
- Release：`BUILD SUCCEEDED`；
- manifest 与 HEAD/tree 记录和本 review 的 exact identity 一致。

该 receipt 正确把本地工程质量矩阵与以下 non-claims 分开：未证明 recall 已接入
production runtime、真实 RIME 候选召回、INT-003、QA-001、paired performance 或
180 ms；不构成 Product Gate、独立 Quality consolidated review、publication、commit、
push、PR、merge、TestFlight、Release 或 parent/child Close。20 个 RimeBridge skipped、
9 个 App Debug skipped 以及 `CODE_SIGNING_ALLOWED=NO` 环境/warning 边界均保留为
residual，未被当作 pass 或 runtime 证据。

## Handoff and residuals

允许将同一 exact snapshot 交给下一道独立 Quality review。下一道 review 仍需保留：

1. pure-Core 证据不等于真实 RIME/runtime wiring 或 device acceptance；
2. skipped、warnings、性能、INT-003/QA-001、180 ms 与 contextual 7/8 的边界；
3. publication、Product/Quality/Release Gate 和 parent/child lifecycle 均未由本 review
   关闭或授权。

本 review 未执行 build、test、format、vendor verify、install、deploy 或新的
Simulator/device Run；未修改 Swift、Assignment、ACTIVE_WORK、KNOWLEDGE_INDEX、
Product decision、其他 Authorization；未 commit、push、PR、merge 或 close。
