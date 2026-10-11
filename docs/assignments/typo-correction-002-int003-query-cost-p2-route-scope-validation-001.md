# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-VALIDATION-001

Policy version 1.0.0

## Current Status

Completed；Core19＋Extension33通过，0失败/跳过，AUTH consumed / exhausted；父Active。

```kos-record
{
  "schema_version": {
    "major": 1,
    "minor": 0
  },
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-VALIDATION-001",
  "record_type": "assignment",
  "title": "固定route scope候选Core＋hostless Extension一次限定测试",
  "lifecycle": "completed",
  "current_phase": "Completed：Core19＋Extension33全通过，0fail/skip，source25不变；非独立review/runtime/fullCI",
  "updated_at": "2026-10-10T15:02:35.211109+00:00",
  "decision_source": "Human 2026-10-10 +08:00：“授权固定候选上的 Core＋Extension 限定测试”",
  "parent_refs": [
    "TYPO-CORRECTION-002"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-VALIDATION-001"
  ],
  "responsibilities": {
    "assignment_authority": "Human Product Lead",
    "domain_owner": "Test / Release Maintainer（P2 evidence）",
    "executor": "当前Codex /root",
    "environment_executor": "当前Codex /root：本机Core及405D hostless test runner",
    "human_dependency": "Human提供405D独占使用；本轮无需手动操作",
    "architecture_reviewer": "Not Applicable：本轮执行测试不作独立架构结论，后续review另授权",
    "quality_reviewer": "Not Applicable：本轮仅Executor原始测试回执，独立Quality后续另授权",
    "product_approver": "Human Product Lead"
  },
  "scope": "一次Core QueryCostMemoryProbeTests，成功后一次hostless三套Extension限定测试；归档命令、日志、xcresult及来源核对",
  "non_goals": "不改源码/自动修正/重试/main追逐；不安装正常App/手动输入/LLDB/全CI/Release/发布/合并/Gate/父关闭",
  "fixed_identity": {
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
    "expected_extension_tests": 33,
    "attempts_each_max": 1,
    "dependency": "Core pass before Extension; first failure stops; no fix/retry",
    "cache": "existing own uk-armimpl1/SourcePackages; normal tool-managed caches allowed; no outer sandbox-exec",
    "expected_count_correction": "先前func test计数误含testingHooks辅助方法；实际test[A-Z]方法33，与执行清单相等"
  },
  "required_inputs": [
    "固定candidate25与HEAD",
    "前序实施strict format/lint回执",
    "独立本轮AUTH及Human测试授权",
    "405D独占，仅其Booted时运行Extension"
  ],
  "entry_criteria": [
    "25源hash与HEAD匹配",
    "固定命令/预算记录且AUTH消费",
    "磁盘free≥4GiB；Extension前405D ready"
  ],
  "exit_criteria": [
    "保存实际次数/exit/logs/用例结果，首失败亦保存",
    "候选hash未变；AUTH耗尽，父Active"
  ],
  "stop_conditions": [
    "首次失败/身份变化/超时/磁盘预算/环境不可用即停；不执行后续套件",
    "main推进不触发重试；修正或再验证须新AUTH"
  ],
  "handoff_target": "Human：测试回执；若通过下一限定独立复审，若失败最小修正新AUTH",
  "revalidation_triggers": [
    "固定源码变化或设备冲突；main推进自身不触发重验"
  ],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-query-cost-p2-route-scope-validation-001.md"
  ],
  "closeout_trigger_identity": "TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-VALIDATION-001:once-filtered-tests:AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-VALIDATION-001",
  "result": "52/0/0；AUTH exhausted"
}
```
