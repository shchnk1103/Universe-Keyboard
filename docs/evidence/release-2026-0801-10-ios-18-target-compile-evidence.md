# RELEASE-2026-0801-10 Phase 1 编译证据

> **Collected:** `2026-08-18 Asia/Shanghai`
> **Grade:** `Executor-recorded`
> **Assignment:** [`RELEASE-2026-0801-10`](../assignments/release-2026-08-01-10-ios-18-target.md)
> **Base commit:** `31f77a1` plus the Phase 1 working-tree alignment
> **Toolchain:** Xcode `27.0` (`27A5237l`, beta)
> **Expiry:** 配置、Package platforms、Swift API 使用或最终 Archive 任一变化后失效

## Non-claims

- 不是独立 Quality 复验
- 不是稳定工具链 / 签名 Archive 证据
- 不是 iOS 18 Simulator 或真机运行证据
- 不是键盘外观、输入、Full Access 或可上架结论

## Commands

Debug 与 Release 均使用干净 DerivedData，未改工程签名设置：

```bash
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/uk-ios18-debug \
  CODE_SIGNING_ALLOWED=NO \
  SWIFT_VERSION=6.0 \
  SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO \
  build

xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/uk-ios18-release \
  CODE_SIGNING_ALLOWED=NO \
  SWIFT_VERSION=6.0 \
  SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO \
  build
```

## Results

| Check | Result | Boundary |
|---|---|---|
| Debug compile | 产物存在：`Universe Keyboard.app` 与嵌入的 `Keyboard.appex`；activity log 无 `error:` | beta Xcode；generic iOS Simulator；unsigned |
| Release compile | 产物存在：`Universe Keyboard.app` 与嵌入的 `Keyboard.appex`；activity log 无 `error:` | 同上 |
| App `MinimumOSVersion` | Debug / Release 均为 `18.0` | Info.plist 观察，不是 App Store 宣称授权 |
| Appex `MinimumOSVersion` | Debug / Release 均为 `18.0` | 同上 |
| Compiler API edits | 无。对齐 target / Package 后没有出现需要 `#available` 补丁的诊断 | 只覆盖本次编译；不证明将来 API 不会露出 |
| Tests | 未跑 `KeyboardCore` / `RimeBridgeTests` / `Universe Keyboard` test | Phase 1 Exit 只要求 Debug/Release compile |

## Configuration changed

- `Universe Keyboard.xcodeproj/project.pbxproj`：全部 `IPHONEOS_DEPLOYMENT_TARGET` → `18.0`
- `Packages/KeyboardCore/Package.swift`：`.iOS("18.0")`
- `Packages/RimeBridge/Package.swift`：`.iOS("18.0")`
- 撤回工作区里与最低系统无关的 `Keyboard.xcscheme` 宿主改动

## Handoff

下一交接：独立 Quality Reviewer 复跑上述命令（或等价稳定工具链命令）。Phase 2 chrome / iOS 18 运行时仍未授权。
