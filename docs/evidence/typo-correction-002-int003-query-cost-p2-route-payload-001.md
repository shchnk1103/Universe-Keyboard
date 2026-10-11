# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-PAYLOAD-001 回执

## 结论

Executor一次DEBUG正常App包构建与产物核验 **Pass**。一次settings exit0（9.926s）、一次build exit0（27.771s）；19个native产物检查全部exit0。78文件/6MachO身份、签名、AppGroup、XML+DER+生成文件/签名/Extension copy链和探针符号符合。此结论仅为包元数据，不是已安装、真实route/arm、P2 Capture、fullCI/Release或Gate。父TYPO-CORRECTION-002 Active。

## 权限与固定来源

Human“继续”承接一次新DEBUG包构建及产物核验建议；[Assignment](../assignments/typo-correction-002-int003-query-cost-p2-route-payload-001.md) / [独立AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-PAYLOAD-001.md)先释放并消费，本轮耗尽；未复用旧AUTH。

- Source writer：`/Users/doubleshy0n/.codex/worktrees/int003-query-cost-memory-impl-001/Universe Keyboard`；HEAD `72dd21710f2a86c9f951d489f645bae89b053b58`。
- Source25 candidate SHA256 `d45bdc9be791aa1654dfde1699a261c34434cd05f68de9456d8102beebd1c2c2`，变更前后hash全部相同；不追main，无Swift修改/commit/push。
- Xcode正式`/Applications/Xcode.app`（沿原已记录27.0/27A266a）；Swift6 strict/warnings-as-errors，probe DEBUG宏启用，TESTING/coverage关闭。
- 独立root：`/private/tmp/uk-routepkg1`；destination `generic/platform=iOS Simulator`，ARCHS arm64，ONLY_ACTIVE_ARCH YES；不按UDID启动或操作设备。
- 正常工具管理的必要同账户cache/temp/diagnostics允许，复制既有SourcePackages metadata，无dependency更新，无外加sandbox-exec。

## 产物与核验

[耐久产物manifest](./typo-correction-002-int003-query-cost-p2-route-payload-001-payload-manifest.json) SHA256 `8bded308bca12cac26d3a1f572287464d1642aea957b338b6d176ebeaa6aa442`记录全部78文件hash/大小、6MachO UUID/arm64/IOSSIMULATOR、App及Keyboard bundle身份、签名权限与sourcecandidate绑定。actual包路径 `/private/tmp/uk-routepkg1/DD/Build/Products/Debug-iphonesimulator/Universe Keyboard.app`，当前尚未安装。本manifest没有loaded/installed/runtime声明。

- App/Extension严格签名验证通过；launcher XML与生成Simulated.xcent字节相同，DER字节相同且derq解码等于XML；regular xcent与codesign声明相同，生成/链接/签名/Extension copy链符合。AppGroup均为`group.com.DoubleShy0N.Universe-Keyboard`。
- 探针已有anchor/arm diagnostic符号以及新增`queryCostDebugFacadeScope`、`FacadeScope`、`queryCostFacadeOrdinal`均在新Keyboard.debug.dylib符号表。纯静态符号存在不证明实际arm成功。
- 产物无xctest bundle、无synthetic testing symbol；生产Swift/Clang flags无TESTING与coverage。
- DD最终实际allocated 453656576 bytes（约432.6MiB），低于6GiB预算；logical大缓存不用于占用判断。未删历史唯一证据或其他线程目录。

## 精确命令与日志

`/private/tmp/uk-routepkg1/execution-binding.json`记录settings/build完整argv与environment，原生argv不经过shell解释继承参数。

```json
{
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
  "build_argv": [
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
  "environment": {
    "DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer",
    "TMPDIR": "/private/tmp/uk-routepkg1/tmp",
    "SWIFTPM_MODULECACHE_OVERRIDE": "/private/tmp/uk-routepkg1/Caches/SwiftPMManifestModuleCache",
    "CLANG_MODULE_CACHE_PATH": "/private/tmp/uk-routepkg1/Caches/ClangModuleCache.noindex"
  }
}
```

`Logs/`各stdout/stderr与21个receipts（含settings/build+19readout）、readout-binding/artifact-readout/clang-proof及两permission-proof保留在root；archive-manifest保存命令/工具/日志/回执哈希。

## 非声明及交接

本轮0test/0device操作/0install/0launch/0LLDB/0input/0Git发布。未新跑Core/Extension/fullCI/Release；原52测试及单finding closure证据保留，不冒充新测试。未验证真实route选择/FullAccess/实际arm/snapshot传输/P2成本读数。无需产品CHANGELOG更新；scope产品设计已有前阶段记录，本轮更新证据/Assignment/经验即可。

下一最值得做：Human授权并再次确认405D独占后，单次安装本manifest绑定的App且核对installed78files；随后按另AUTH检查运行前置状态和实际arm/正式P2采集。本轮技术无blocker，P2真实证据仍缺，父Active，无Gate/Close/ADR Accept/TestFlight/Release。
