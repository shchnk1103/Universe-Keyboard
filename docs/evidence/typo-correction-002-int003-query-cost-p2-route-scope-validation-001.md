# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-VALIDATION-001 限定验证回执

> 当前计数记录更正：执行时的binding预估34保持为历史原件；现行[更正后binding](./typo-correction-002-int003-query-cost-p2-evidence-reconciliation-001-execution-binding-corrected.json)为33，[更正说明](./typo-correction-002-int003-query-cost-p2-evidence-reconciliation-001-correction.json)记录唯一字段差异及摘要链。下方嵌入原binding不代表更正后的预期数；本次没有重跑测试。

## 结论

Executor限定测试 Pass：一次Core 19/0/0，一次hostless Extension 33/0/0；共52 passed、0失败、0跳过。候选25路径与HEAD前后匹配。此结论不等于独立审查、全CI、实际用户route/arm成功、P2正式成本证据或Gate。父TYPO-CORRECTION-002保持Active。

## 权限与来源

Human：“授权固定候选上的 Core＋Extension 限定测试”（2026-10-10 +08:00）。[Assignment](../assignments/typo-correction-002-int003-query-cost-p2-route-scope-validation-001.md) / [独立AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-VALIDATION-001.md) 已释放、先消费、本轮耗尽；未复用实施AUTH。

- Source writer：`/Users/doubleshy0n/.codex/worktrees/int003-query-cost-memory-impl-001/Universe Keyboard`
- HEAD：`72dd21710f2a86c9f951d489f645bae89b053b58`，未提交overlay由candidate绑定。
- Candidate：`/private/tmp/uk-route-impl1/candidate.json`，SHA256 `d45bdc9be791aa1654dfde1699a261c34434cd05f68de9456d8102beebd1c2c2`。
- Xcode：`/Applications/Xcode.app/Contents/Developer`；Swift 6 strict concurrency及warnings-as-errors；DEBUG probe宏明确启用。
- Extension环境：iPhone18 Pro iOS27.0 / 24A434，405D994F-28CB-4F89-BB22-B64AD81C05A2；ready核对后仅此hostless runner，无其他模拟器操作。
- 输出：`/private/tmp/uk-route-val1`；同账户独立CoreBuild/DD/Results/tmp/cache，已有本线程SourcePackages复用，不新增外层sandbox-exec。必要自动缓存原子操作允许。

## 逐套结果

| Suite | Passed | Failed | Skipped |
|---|---:|---:|---:|
| QueryCostMemoryProbeTests | 19 | 0 | 0 |
| QueryCostArmDiagnosticTests | 8 | 0 | 0 |
| TypoCorrectionQueryCostProbeIntegrationTests | 15 | 0 | 0 |
| TypoCorrectionRecallCoordinatorIntegrationTests | 10 | 0 | 0 |

Core总耗时24.582s，Extension总耗时34.780s；最后输出实际allocated约574MiB（601415680bytes），未达到6GiB预算。Core通过后才启动Extension；两命令各执行一次，无修正/重试。源码测试方法名清单与日志passed清单逐套相等，Extension xcresult summary total33/pass33/fail0/skip0。Swift Testing附加0-test摘要不替代XCTest19/33。

## 精确命令及归档

`execution-binding.json`保留argv数组与环境，含继承参数字面值；执行不用shell解释`$(inherited)`。

```json
{
  "candidate": "/private/tmp/uk-route-impl1/candidate.json",
  "candidate_sha256": "d45bdc9be791aa1654dfde1699a261c34434cd05f68de9456d8102beebd1c2c2",
  "source_head": "72dd21710f2a86c9f951d489f645bae89b053b58",
  "writer": "/Users/doubleshy0n/.codex/worktrees/int003-query-cost-memory-impl-001/Universe Keyboard",
  "core_argv": [
    "/usr/bin/xcrun",
    "swift",
    "test",
    "--package-path",
    "Packages/KeyboardCore",
    "--scratch-path",
    "/private/tmp/uk-route-val1/CoreBuild",
    "-Xswiftc",
    "-DKEYBOARD_QUERY_COST_PROBE",
    "-Xswiftc",
    "-strict-concurrency=complete",
    "-Xswiftc",
    "-warnings-as-errors",
    "--filter",
    "QueryCostMemoryProbeTests"
  ],
  "extension_argv": [
    "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild",
    "-project",
    "Universe Keyboard.xcodeproj",
    "-scheme",
    "KeyboardExtensionTests",
    "-configuration",
    "Debug",
    "-destination",
    "platform=iOS Simulator,id=405D994F-28CB-4F89-BB22-B64AD81C05A2",
    "-parallel-testing-enabled",
    "NO",
    "-maximum-concurrent-test-simulator-destinations",
    "1",
    "-clonedSourcePackagesDirPath",
    "/private/tmp/uk-armimpl1/SourcePackages",
    "-disableAutomaticPackageResolution",
    "-skipPackageUpdates",
    "-derivedDataPath",
    "/private/tmp/uk-route-val1/DD",
    "CODE_SIGNING_ALLOWED=NO",
    "SWIFT_VERSION=6.0",
    "SWIFT_STRICT_CONCURRENCY=complete",
    "SWIFT_SUPPRESS_WARNINGS=NO",
    "SWIFT_TREAT_WARNINGS_AS_ERRORS=YES",
    "QUERY_COST_PROBE_CONDITIONS=KEYBOARD_QUERY_COST_PROBE",
    "OTHER_SWIFT_FLAGS=$(inherited) -DKEYBOARD_QUERY_COST_PROBE",
    "OTHER_CFLAGS=$(inherited) -DDEBUG=1",
    "ENABLE_CODE_COVERAGE=NO",
    "CLANG_ENABLE_CODE_COVERAGE=NO",
    "CLANG_COVERAGE_MAPPING=NO",
    "-resultBundlePath",
    "/private/tmp/uk-route-val1/Results/extension.xcresult",
    "-only-testing:KeyboardExtensionTests/QueryCostArmDiagnosticTests",
    "-only-testing:KeyboardExtensionTests/TypoCorrectionQueryCostProbeIntegrationTests",
    "-only-testing:KeyboardExtensionTests/TypoCorrectionRecallCoordinatorIntegrationTests",
    "test"
  ],
  "environment": {
    "DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer",
    "TMPDIR": "/private/tmp/uk-route-val1/tmp/",
    "SWIFTPM_MODULECACHE_OVERRIDE": "/private/tmp/uk-route-val1/Caches/SwiftPMManifestModuleCache",
    "CLANG_MODULE_CACHE_PATH": "/private/tmp/uk-route-val1/Caches/ClangModuleCache.noindex"
  },
  "timeout_each_seconds": 1200,
  "output_allocated_budget_bytes": 6442450944,
  "min_free_bytes": 4294967296,
  "expected_core_tests": 19,
  "expected_extension_tests": 34,
  "attempts_each_max": 1,
  "dependency": "Core pass before Extension; first failure stops; no fix/retry",
  "cache": "existing own uk-armimpl1/SourcePackages; normal tool-managed caches allowed; no outer sandbox-exec"
}
```

日志、receipts、coverage、final-identity及summary SHA256：

```json
{
  "execution-binding.json": "eb3b865468b9d3945b1b4d5037d6b2a22e241ba96018dbb35f6c217e5c426fdf",
  "receipts.json": "d6d9d16fe44c0f6888e4f73310a708f322f912d47968736fa03bba17dde72edd",
  "core.stdout": "15354f234069a3d09d433bbfe559de02256c1eff178f6942ae7024678f7e9fba",
  "core.stderr": "bfdfc01882ab65ecbe1259ec6edb32ff8cdc15638a898b510aa94c6389f99722",
  "extension.stdout": "270c35eb38388b6f9f1b1bd3c493f661590976390a8647885d5092ee9b1ce6fd",
  "extension.stderr": "799f9afedad92c641ac4918e340aefeaf9667b3455ca1601c60e51e664be7733",
  "extension-summary.json": "13e70f82925469ba960e2620205f701f8ca897f500928f42061617e31121c41c",
  "coverage.json": "93565a70359e29da82ab72228d720147f3bd9f5dcbf32a47aaa6d4416127d912",
  "final-identity.json": "f4fea0b0d8e0828197a4149f2625645bf23a272459c25a34e69b91af93bc72be"
}
```

原始结果包：`/private/tmp/uk-route-val1/Results/extension.xcresult`；`archive-manifest.json`记录上述文件摘要，尚未单独归档巨大结果包/不声称已完整可迁移。

## 非声明及交接

未执行完整Core suite、主App/RimeBridge suites、Release、normal App install、LLDB、手动输入、正式P2采集、独立复审或Git提交/推送/合并；均不在本轮范围。无需CHANGELOG产品更新；实现scope语义的产品补充已在前阶段记录，本轮仅验证回执。下一建议：新candidate及52个测试证据的限定独立增量复审，之后另绑定新包/实际arm和正式采集。无范围内测试blocker；P2真实运行证据仍未满足。main后续推进不会自动触发本候选重跑。
