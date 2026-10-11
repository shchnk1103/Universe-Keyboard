# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-PAYLOAD-001

Policy version 1.0.0

## Current Status

Completed：一次build/artifact核验Pass，AUTH consumed/exhausted；未安装，父Active。

```kos-record
{
  "schema_version": {
    "major": 1,
    "minor": 0
  },
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-PAYLOAD-001",
  "record_type": "assignment",
  "title": "固定route候选一次DEBUG正常App新包构建及产物核验",
  "lifecycle": "completed",
  "current_phase": "Completed：once settings/build +19native readout Pass，78files/6MachO，source25不变；未installed/runtime",
  "updated_at": "2026-10-10T15:40:59.393835+00:00",
  "decision_source": "Human 2026-10-10 +08:00“继续”，响应固定候选一次新DEBUG包构建及产物核验建议",
  "parent_refs": [
    "TYPO-CORRECTION-002"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-PAYLOAD-001"
  ],
  "responsibilities": {
    "assignment_authority": "Human Product Lead",
    "domain_owner": "Test / Release Maintainer（P2 evidence）",
    "executor": "当前Codex /root：一次构建/产物回执",
    "environment_executor": "当前Codex /root：同账户独立outputs/generic Simulator编译，不设备操作",
    "human_dependency": "Human本次build/readout授权，无手动输入/独占模拟器要求",
    "architecture_reviewer": "Not Applicable：沿原已复审candidate，无新源改动/架构结论",
    "quality_reviewer": "Not Applicable：本轮Executor产物核验，不独立Quality/Gate决定",
    "product_approver": "Human Product Lead"
  },
  "scope": "one showBuildSettings metadata query then one Debug build, successful only then bounded artifact readout; full inventory/MachO/UUID/entitlement XML+DER/sign/copy/probe and route symbols",
  "non_goals": "No source change/new tests/defaultRelease/fullCI/deviceinstall/launch/LLDB/input/publication/Gate/Close/main chasing/rebuild retry",
  "fixed_identity": {
    "candidate_sha256": "d45bdc9be791aa1654dfde1699a261c34434cd05f68de9456d8102beebd1c2c2",
    "source_head": "72dd21710f2a86c9f951d489f645bae89b053b58",
    "writer": "/Users/doubleshy0n/.codex/worktrees/int003-query-cost-memory-impl-001/Universe Keyboard",
    "xcode": "/Applications/Xcode.app/Contents/Developer /27.0/27A266a",
    "argv": [
      "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild",
      "-project",
      "Universe Keyboard.xcodeproj",
      "-scheme",
      "Universe Keyboard",
      "-configuration",
      "Debug",
      "-destination",
      "generic/platform=iOS Simulator",
      "-parallel-testing-enabled",
      "NO",
      "-maximum-concurrent-test-simulator-destinations",
      "1",
      "-clonedSourcePackagesDirPath",
      "/private/tmp/uk-routepkg1/SourcePackages",
      "-disableAutomaticPackageResolution",
      "-skipPackageUpdates",
      "-derivedDataPath",
      "/private/tmp/uk-routepkg1/DD",
      "CODE_SIGNING_ALLOWED=YES",
      "CODE_SIGN_IDENTITY=-",
      "CODE_SIGNING_REQUIRED=NO",
      "SWIFT_VERSION=6.0",
      "SWIFT_STRICT_CONCURRENCY=complete",
      "SWIFT_SUPPRESS_WARNINGS=NO",
      "SWIFT_TREAT_WARNINGS_AS_ERRORS=YES",
      "QUERY_COST_PROBE_CONDITIONS=KEYBOARD_QUERY_COST_PROBE",
      "OTHER_SWIFT_FLAGS=$(inherited) -DKEYBOARD_QUERY_COST_PROBE",
      "OTHER_CFLAGS=$(inherited) -DDEBUG=1",
      "-resultBundlePath",
      "/private/tmp/uk-routepkg1/Results/payload.xcresult",
      "ENABLE_CODE_COVERAGE=NO",
      "CLANG_ENABLE_CODE_COVERAGE=NO",
      "CLANG_COVERAGE_MAPPING=NO",
      "ARCHS=arm64",
      "ONLY_ACTIVE_ARCH=YES",
      "build"
    ],
    "timeout_seconds": 1800,
    "attempts": 1,
    "environment": {
      "DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer",
      "TMPDIR": "/private/tmp/uk-routepkg1/tmp",
      "SWIFTPM_MODULECACHE_OVERRIDE": "/private/tmp/uk-routepkg1/Caches/SwiftPMManifestModuleCache",
      "CLANG_MODULE_CACHE_PATH": "/private/tmp/uk-routepkg1/Caches/ClangModuleCache.noindex"
    },
    "source_packages": "copied existing own resolved metadata, no dependency update",
    "readout_tools": [
      "file",
      "lipo",
      "otool",
      "nm",
      "codesign"
    ],
    "readout_scope": "retain prior full payload/MachO/XML+DER+signature/copy/probe checks; additionally new route/facade symbols in Keyboard.debug.dylib",
    "budgets": "settings180s once/build1800s once/readout≤40native300s; DD allocated≤6GiB/free≥4GiB; 0 install/launch/input/sim operation",
    "automatic_effects": "same account isolated outputs and normal necessary Xcode/SwiftPM cache/temp/diagnostics atomic writes; no outer sandbox-exec",
    "non_goals": "No source change/new tests/defaultRelease/fullCI/deviceinstall/launch/LLDB/input/publication/Gate/Close/main chasing/rebuild retry",
    "settings_argv": [
      "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild",
      "-project",
      "Universe Keyboard.xcodeproj",
      "-scheme",
      "Universe Keyboard",
      "-configuration",
      "Debug",
      "-destination",
      "generic/platform=iOS Simulator",
      "-parallel-testing-enabled",
      "NO",
      "-maximum-concurrent-test-simulator-destinations",
      "1",
      "-clonedSourcePackagesDirPath",
      "/private/tmp/uk-routepkg1/SourcePackages",
      "-disableAutomaticPackageResolution",
      "-skipPackageUpdates",
      "-derivedDataPath",
      "/private/tmp/uk-routepkg1/DD",
      "CODE_SIGNING_ALLOWED=YES",
      "CODE_SIGN_IDENTITY=-",
      "CODE_SIGNING_REQUIRED=NO",
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
      "ARCHS=arm64",
      "ONLY_ACTIVE_ARCH=YES",
      "-showBuildSettings",
      "-json"
    ],
    "settings_timeout_seconds": 180,
    "settings_attempts": 1,
    "destination_explanation": "generic Simulator arm64, compile-only; no device UDID operation"
  },
  "required_inputs": [
    "固定source25与HEAD",
    "Core19/Extension33测试证据及AR-01/F1 closure",
    "旧同类成功runner/helpers/readout方法",
    "normal Xcode.app及必要工具-managed cache权限"
  ],
  "entry_criteria": [
    "新AUTH释放消费先于执行",
    "source25/head匹配，free≥4GiB，isolated new root",
    "runner只root替换及newroute symbol check；精确命令绑定"
  ],
  "exit_criteria": [
    "each settings/build once only，首失败stop保存native receipt",
    "payload完整manifest及MachO/sign/entitlements/flags/source关联或具体失败",
    "父Active，AUTH耗尽，安装及actualarm另AUTH"
  ],
  "stop_conditions": [
    "首次失败/identity变化/预算或free超限立即停，不auto fix/rebuild",
    "no main chase；不启动/安装/停止任何模拟器",
    "若须源码变化或扩大验证，交Human新AUTH"
  ],
  "handoff_target": "Human：新包产物证据；随后确认405D独占并安装独立AUTH，再actualarm/capture",
  "revalidation_triggers": [
    "source/payload/tool environment变化需核查；main推进本身不重建"
  ],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-query-cost-p2-route-payload-001.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p2-route-payload-001-payload-manifest.json"
  ],
  "closeout_trigger_identity": "TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-PAYLOAD-001:once-debug-build-readout:AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-PAYLOAD-001"
}
```
