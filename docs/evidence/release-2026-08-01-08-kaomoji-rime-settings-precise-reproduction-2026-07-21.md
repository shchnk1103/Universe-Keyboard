# RELEASE-2026-0801-08 RimeSettingsStoreTests 精确复现 — 2026-07-21

**证据类型：** 独立 Quality Reviewer 的定向自动化复现与差异归因。

**审查范围：** `codex/release-2026-0801-kaomoji` 的 `c9f2b34bd4b44dc528f39e6120db1af3f23c367e`；只针对执行者交接中报告的两个 `RimeSettingsStoreTests` 名称及其五个失败断言。

**结论边界：** 本记录仅裁定 **Q-08-01 不阻塞颜表情代码归因交接**。它不关闭 `RELEASE-2026-0801-08`，不构成发布质量通过、风险接受或 Product Gate 结论。

## 复现环境

- 提交：`c9f2b34bd4b44dc528f39e6120db1af3f23c367e`
- Xcode：`/Applications/Xcode-beta.app`
- 目的地：iPhone 17 Pro Simulator
- Simulator UDID：`900FB396-39BF-4A84-9E75-FF813C155FA7`
- OS：iOS Simulator `26.5`（build `23F73`）
- RIME 依赖：在隔离工作树中复制主工作区已通过结构校验的 11 个 pinned xcframework；随后执行 `bash scripts/ensure_rime_vendor.sh verify` 通过。
- DerivedData：`/private/tmp/dd-c9f2b34-tests`
- 结果包：`/private/tmp/c9f2b34-rime-settings.xcresult`

## 精确命令与结果

```bash
xcodebuild -quiet -project 'Universe Keyboard.xcodeproj' \
  -scheme 'Universe Keyboard' \
  -destination 'platform=iOS Simulator,id=900FB396-39BF-4A84-9E75-FF813C155FA7' \
  -derivedDataPath /private/tmp/dd-c9f2b34-tests \
  -resultBundlePath /private/tmp/c9f2b34-rime-settings.xcresult \
  CODE_SIGNING_ALLOWED=NO \
  SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
  -only-testing:UniverseKeyboardTests/RimeSettingsStoreTests/testAutoBackupRunsForChangedLearningDataWhenEnabled \
  -only-testing:UniverseKeyboardTests/RimeSettingsStoreTests/testSaveFuzzyPinyinSettingsSkipsDeployWhenSignatureAlreadyMatches \
  test
```

`xcresulttool get test-results summary` 的结果：`totalTestCount: 2`、`passedTests: 2`、`failedTests: 0`、`result: Passed`。因此，执行者交接中物理设备测试记录的五个失败断言未能在本次标准 Simulator 精确复现中出现。

## 与 c9f2b34 的差异归因

对父提交 `c9f2b34^` 与 `c9f2b34` 执行了以下范围差异检查：

```bash
git diff --quiet c9f2b34^ c9f2b34 -- \
  'Universe Keyboard/Views/Settings/RimeSettingsStore.swift' \
  'Universe Keyboard/Views/Settings/RimeSettingsStore+Sync.swift' \
  UniverseKeyboardTests/RimeSettingsStoreTests.swift
```

退出状态为 `0`，即三个 Rime Settings 实现/测试文件在该提交中均未变更。`c9f2b34` 的改动位于 Keyboard 颜表情目录与其文档，不包含 Rime Settings 行为或其测试。

据此，五个历史失败不能归因于 `c9f2b34` 的颜表情代码。由于本次定向测试通过，且该测试代码与父提交一致，现有证据不足以将它们定性为稳定的“基线失败”；它们保留为执行者物理设备环境中的历史异常观察，若需要发布级闭环，应由 Rime Settings 所有者在对应物理设备环境另行复现和定因。

## 限制与交接

- 本次没有运行完整 `Universe Keyboard` 测试套件，也没有将两项定向测试的通过扩大为全套测试通过。
- 父提交使用同一命令的对照运行已发起，但受本机并发 Xcode 构建延迟，未在本记录中作为结果依据；差异归因仅依赖可复核的零差异范围与当前提交的精确通过结果。
- VoiceOver、深色模式、iPhone/iPad 颜表情运行时验收不在本记录范围，仍应由独立的设备/无障碍证据覆盖。

**限定结论：Q-08-01 不阻塞颜表情代码归因交接。** 任何 -08 任务关闭、发布质量或 Product Gate 判断均保留给其指定的 Quality/Product 责任人。
