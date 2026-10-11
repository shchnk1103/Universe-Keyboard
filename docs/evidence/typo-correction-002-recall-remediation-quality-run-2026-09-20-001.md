# TYPO-CORRECTION-002 Recall Remediation Quality Run 001

- Run ID：`TC2-RECALL-QUALITY-20260920-001`
- 时间：2026-09-20 Asia/Shanghai
- Assignment：`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`
- Authorization：[`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-QUALITY-RUN-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-QUALITY-RUN-001.md)
- Worktree：`/private/tmp/universe-keyboard-typo-correction-002-recall-publication-staging-001`
- Branch：`codex/typo-correction-002-recall-publication-staging-001`
- HEAD：`162b09fd58ba60538a944026b1902efa405c75aa`
- HEAD tree：`92c5047c5d1a6dd6a751eb5344117f8138c14ef2`
- Simulator：`iPhone 17 Pro / iOS 26.0 / 8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`
- Source manifest：[`publication staging source manifest`](typo-correction-002-recall-remediation-publication-staging-source-manifest-2026-09-20-001.txt)
- Source manifest SHA-256：`709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207`
- Vendor archive SHA-256：`d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`
- Vendor evidence：[`RIME vendor materialization 002`](typo-correction-002-recall-remediation-rime-vendor-materialization-2026-09-20-002.md)

## 结论

本 Run **Blocked — 不可进入 publication**。格式、manifest、KeyboardCore 和 RimeBridge 门禁通过；`Universe Keyboard` Debug 在测试编译阶段失败，因此 Release build 按 stop condition 未执行。该失败暴露的是 clean `origin/main` 与 allowlist 中 `RimeSettingsStoreTests.swift` 的生产契约不闭合，不能解释为 recall runtime 或产品行为结论。

## 门禁结果

| 检查 | 结果 | 记录 |
|---|---|---|
| 四个变更 Swift 文件 `swift-format lint --strict` | PASS | `ContextualTypoCorrection.swift`、`TypoCorrectionRecallPreflight.swift`、`TypoCorrectionRecallPreflightTests.swift`、`RimeSettingsStoreTests.swift` 均 exit 0；未执行 in-place format |
| Source manifest / SHA-256 | PASS | 五个条目全部匹配 `709370f8…` |
| HEAD / tree | PASS | Run 前后仍为 `162b09f / 92c5047c` |
| `git diff --check` | PASS | 无输出 |
| `swift test --package-path Packages/KeyboardCore` | PASS | `1139 tests, 0 failures`；仅保留历史 `T9PinyinPathTests.swift` optional interpolation warning |
| `RimeBridgeTests` | PASS | `81 passed, 0 failed, 20 skipped`；XcodeBuildMCP result bundle：`/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-20T06-57-00-951Z_pid25092_69128a53.xcresult` |
| `Universe Keyboard` Debug tests | BLOCKED | 发现 388 tests 后在编译阶段失败；未执行测试案例 |
| `Universe Keyboard` Release build | NOT RUN | 依据 stop condition；同一 App target 的编译契约未闭合 |

## 阻塞根因

`UniverseKeyboardTests/RimeSettingsStoreTests.swift:1359-1363`（manifest 中的第五项）构造：

- `librimeVersion: succeeded ? fixtureLibrimeVersion : nil`
- `runtimeSmokePassed: succeeded ? true : nil`

当前 clean `origin/main=162b09f` 的 `Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift:33-52` 中，`RimeDeploymentResult` initializer 只接受 `succeeded`、`diagnosticMessage`、`runtimeSmokePassed` 和 `luaRuntimeSmokePassed`，没有 `librimeVersion` 参数。因此编译器报：`extra argument 'librimeVersion' in call`（line 1362）。

这证明 canonical 五文件 allowlist 仍混入了一段依赖另一条未随 clean base 一起进入的 RIME contract/test fixture 变更。它不是可通过继续 build 规避的环境波动，也不是 recall 算法测试失败。

## 环境重试记录

第一次 SwiftPM 执行因用户级 `/Users/doubleshy0n/.cache/clang/ModuleCache` 不可写而失败；使用 `/private/tmp/universe-keyboard-typo-correction-002-recall-quality-001-*` 临时 module cache 后，沙箱又在 manifest 阶段返回 `sandbox_apply: Operation not permitted`。受控提升权限重跑后才得到上述 `1139/0` 正式结果。该过程未修改仓库源码。

## Artifacts

- RimeBridge build log：`/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-20T06-57-00-951Z_pid25092_da731df6.log`
- App Debug compile-failure log：`/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-20T06-57-39-700Z_pid25092_f85f7e41.log`
- DerivedData：`/private/tmp/universe-keyboard-typo-correction-002-recall-quality-001-rimebridge-derived`、`/private/tmp/universe-keyboard-typo-correction-002-recall-quality-001-app-derived`

## Non-claims

- 不代表 recall runtime 接线、真实 RIME 候选、设备/Simulator 产品行为、INT-003、QA-001、paired performance、180 ms 或任何 Product/Quality/Release Gate。
- 不代表 commit、push、PR、merge、TestFlight、Release 或 parent/child Close。
- `RimeBridgeTests` 通过仅说明该 target 在本环境下通过，不关闭 App target 的编译阻塞。

## 下一步边界

需要另立 bounded dependency-reconciliation/code-fix Authorization，先决定并修复以下二选一的契约边界：

1. 将 `RimeSettingsStoreTests.swift` 回收到 clean base 支持的 `RimeDeploymentResult` 构造，保持 recall allowlist 纯净；或
2. 明确把对应的 production `RimeDeploymentResult` contract 变更及其 provenance 纳入同一变更范围，并重新生成 manifest、Run ID 和全部受影响门禁证据。

在该决定和新 Authorization 之前，不得修改这段测试、补生产字段、重跑 App/Release 或申请 publication。
