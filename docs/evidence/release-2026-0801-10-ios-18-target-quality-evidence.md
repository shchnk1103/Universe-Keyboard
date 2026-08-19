# RELEASE-2026-0801-10 Phase 1 Quality 复验证据

> **Collected:** `2026-08-18 20:58 Asia/Shanghai`
> **Grade:** `Quality-reverified`（下表逐行标注；Executor 路径另行标明）
> **Reviewer:** 🧪 Quality, Performance & Release Maintainer — independent of the Executor
> **Assignment:** [`RELEASE-2026-0801-10`](../assignments/release-2026-08-01-10-ios-18-target.md)
> **Quality conclusion:** [`release-2026-08-01-10-quality-review.md`](../assignments/release-2026-08-01-10-quality-review.md)
> **HEAD:** `31f77a1a8a9d6694aa633cd49604b8ecc918eb5e`
> **Workspace:** dirty — Phase 1 未提交工作区（见下方 file list）
> **Toolchain:** Xcode `27.0` (`27A5237l`, beta); `xcode-select -p` = `/Applications/Xcode-beta.app/Contents/Developer`
> **SDK used by compile:** `iPhoneSimulator27.0.sdk`
> **Expiry:** 配置、Package platforms、Swift API 使用、工具链或最终 Archive 任一变化后失效

## Non-claims

- 不是 Product Gate、上架、Archive 或稳定工具链证明
- 不是 iOS 18 Simulator / 真机运行或 chrome 证据
- 不是把 Executor `/tmp/uk-ios18-debug` / `/tmp/uk-ios18-release` 改写成 Quality
- 不关闭 Phase 2

## Environment

| Item | Value | Grade |
|---|---|---|
| Date / timezone | `2026-08-18 20:58 CST` (`Asia/Shanghai`) | Quality-reverified |
| `git rev-parse HEAD` | `31f77a1a8a9d6694aa633cd49604b8ecc918eb5e` | Quality-reverified |
| Working tree | dirty（Phase 1 配置 + 文档未提交） | Quality-reverified |
| `xcodebuild -version` | `Xcode 27.0` / `Build version 27A5237l` | Quality-reverified |
| Available simulators | iOS 26.0 / 26.5 / 27.0；**无 iOS 18** | Quality-reverified |
| New DerivedData | `/tmp/uk-ios18-q-debug`、`/tmp/uk-ios18-q-release` | Quality-reverified |
| Executor DerivedData | `/tmp/uk-ios18-debug`、`/tmp/uk-ios18-release` 存在但未使用 | Executor-recorded；仅对照 |

Dirty paths at collection time（不含本 Quality 文件写入前的状态）：

```
 M CHANGELOG.md
 M Packages/KeyboardCore/Package.swift
 M Packages/RimeBridge/Package.swift
 M Universe Keyboard.xcodeproj/project.pbxproj
 M docs/ACTIVE_WORK.md
 M docs/ENGINEERING_DASHBOARD.md
 M docs/PROJECT_CONTEXT.md
 M docs/assignments/release-2026-08-01-02-scope-freeze.md
 M docs/assignments/release-2026-08-01-09-ios-26-target.md
 M docs/assignments/release-2026-08-01.md
 M docs/evidence/release-2026-08-01-02-architecture-review.md
 M docs/evidence/release-2026-08-01-02-quality-review.md
 M docs/evidence/release-2026-08-01-acceptance.md
 M docs/evidence/release-2026-0801-09-ios-26-target-architecture-review.md
?? docs/assignments/release-2026-08-01-10-ios-18-target.md
?? docs/evidence/release-2026-0801-10-ios-18-target-architecture-review.md
?? docs/evidence/release-2026-0801-10-ios-18-target-compile-evidence.md
?? docs/product-decisions/RELEASE-2026-0801-minimum-os-ios18.md
```

`Keyboard.xcscheme` 相对 HEAD SHA 一致：`07868d816966f7d722cddf73011c9cf2d885a3d8`。

## Configuration audit

| Check | Result | Grade |
|---|---|---|
| `IPHONEOS_DEPLOYMENT_TARGET` | 14 处，全部 `18.0`；无 `IPHONEOS_DEPLOYMENT_TARGET = 26.4` | Quality-reverified |
| App target Debug/Release | 无显式值，继承工程级 `18.0` | Quality-reverified |
| Keyboard / 全部测试 target | 显式 `18.0` | Quality-reverified |
| `Packages/KeyboardCore/Package.swift` | `.iOS("18.0")` | Quality-reverified |
| `Packages/RimeBridge/Package.swift` | `.iOS("18.0")` | Quality-reverified |
| `CLANG_WARN_UNGUARDED_AVAILABILITY` | 工程级 Debug/Release = `YES_AGGRESSIVE` | Quality-reverified |
| `SWIFT_STRICT_CONCURRENCY` | 14 处 `complete` | Quality-reverified |
| `SWIFT_SUPPRESS_WARNINGS` | 工程未设置 | Quality-reverified |
| `CreatedOnToolsVersion = 26.4.1` | 仅 Xcode 创建元数据，不是部署目标 | Quality-reverified |

## Diff boundary

`git diff --stat -- . ':!docs' ':!CHANGELOG.md'`：

```
 Packages/KeyboardCore/Package.swift         |  4 ++--
 Packages/RimeBridge/Package.swift           |  2 +-
 Universe Keyboard.xcodeproj/project.pbxproj | 26 ++++++++++++++------------
 3 files changed, 17 insertions(+), 15 deletions(-)
```

`.swift` 变更只有两个 `Package.swift`。无 Keyboard chrome、输入热路径、RIME 所有权或 `Keyboard.xcscheme` 宿主改动。

## Commands

独立路径，禁止复用 Executor DerivedData。

### Debug compile

```bash
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/uk-ios18-q-debug \
  CODE_SIGNING_ALLOWED=NO \
  SWIFT_VERSION=6.0 \
  SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO \
  build
```

Log: `/tmp/uk-ios18-q-debug-xcodebuild.log`

### Release compile

```bash
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/uk-ios18-q-release \
  CODE_SIGNING_ALLOWED=NO \
  SWIFT_VERSION=6.0 \
  SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO \
  build
```

Log: `/tmp/uk-ios18-q-release-xcodebuild.log`

### KeyboardCore tests

```bash
swift test --package-path Packages/KeyboardCore --build-path /tmp/uk-ios18-q-keyboardcore
```

Log: `/tmp/uk-ios18-q-keyboardcore-test.log`

### RimeBridgeTests（成比例，非 iOS 18 runtime）

本机无 iOS 18 Simulator。先 `xcrun simctl list devices available`，再用已存在的 `iPhone 17 Pro` / iOS 26.0。

```bash
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme RimeBridgeTests \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' \
  -derivedDataPath /tmp/uk-ios18-q-rimebridgetests \
  CODE_SIGNING_ALLOWED=NO \
  SWIFT_VERSION=6.0 \
  SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
  test
```

Log: `/tmp/uk-ios18-q-rimebridgetests.log`

## Results

| Check | Result | Grade |
|---|---|---|
| Debug compile | `** BUILD SUCCEEDED **`；产物 `Universe Keyboard.app` + 嵌入 `Keyboard.appex` | Quality-reverified |
| Release compile | `** BUILD SUCCEEDED **`；`EXIT:0` | Quality-reverified |
| Debug App `MinimumOSVersion` | `18.0` | Quality-reverified |
| Debug Appex `MinimumOSVersion` | `18.0` | Quality-reverified |
| Release App `MinimumOSVersion` | `18.0` | Quality-reverified |
| Release Appex `MinimumOSVersion` | `18.0` | Quality-reverified |
| Release `DTPlatformVersion` | `27.0`（SDK，不是最低系统） | Quality-reverified |
| KeyboardCore | `Executed 1030 tests, with 0 failures (0 unexpected)` | Quality-reverified |
| RimeBridgeTests | `Executed 68 tests, with 20 tests skipped and 0 failures`；`** TEST SUCCEEDED **`；`EXIT:0`；destination = iOS **26.0** | Quality-reverified compile/test on iOS 26 Simulator；**不是** iOS 18 runtime |
| Full `Universe Keyboard` scheme test | 未跑 | Skipped With Reason：Phase 1 Exit 是 compile-only |
| Release `ld: warning` ignoring arm64-only boost objects for x86_64 | 既有 Vendor slice；未关警告换绿 | Quality-reverified observation；不挡 Phase 1 |
| Executor `/tmp/uk-ios18-debug` / `/tmp/uk-ios18-release` | 未复跑、不引用为本结果 | Executor-recorded |

## Handoff

Phase 1 compile Quality 已独立复验。下一步仍是 Product Lead / `-01` Archive / Phase 2 授权。本文件不授权 Product Gate、不上架、不关闭 Phase 2。
