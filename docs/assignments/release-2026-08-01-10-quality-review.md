# RELEASE-2026-0801-10 Phase 1 — Quality Review Conclusion

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-18 20:56 Asia/Shanghai` |
| **Reviewer role** | 🧪 Quality, Performance & Release Maintainer — independent of the Executor |
| **Object under review** | [`RELEASE-2026-0801-10`](release-2026-08-01-10-ios-18-target.md) Phase 1：全部 target / 两个 Package platforms 对齐 iOS 18.0，且 `Universe Keyboard` scheme Debug/Release **编译**通过 |
| **Workspace** | `HEAD` `31f77a1a8a9d6694aa633cd49604b8ecc918eb5e` + 未提交 Phase 1 工作区 |
| **Evidence inputs** | [Assignment](release-2026-08-01-10-ios-18-target.md) · [PD](../product-decisions/RELEASE-2026-0801-minimum-os-ios18.md) · [Architecture review](../evidence/release-2026-0801-10-ios-18-target-architecture-review.md) · [Executor compile evidence](../evidence/release-2026-0801-10-ios-18-target-compile-evidence.md)（仅对照） · 本 reviewer 独立配置/diff 审计与新 DerivedData 复跑 |
| **Independent evidence** | [`release-2026-0801-10-ios-18-target-quality-evidence.md`](../evidence/release-2026-0801-10-ios-18-target-quality-evidence.md) |

本 reviewer 不是 Executor，未实施 Phase 1，不把 Assignment 标 Completed，不做 Product Gate / 上架 / Archive 结论，不关闭 Phase 2。

Executor 的 `/tmp/uk-ios18-debug` 与 `/tmp/uk-ios18-release` **未被复用**，也未被改写成 `Quality-reverified`。

## Verdict

**Pass with conditions**

Phase 1 的编译对齐合同已独立复验：全部显式 `IPHONEOS_DEPLOYMENT_TARGET` 与两个 Package iOS platform 均为 `18.0`；`Universe Keyboard` scheme 的 Debug / Release 在新 DerivedData 上编过；App 与 `Keyboard.appex` 产物 `MinimumOSVersion` 均为 `18.0`。未发现键盘 chrome / 输入热路径 / RIME 所有权混入，也未发现削弱 warnings / concurrency / availability 的工程改动。

本结论只覆盖 **Phase 1 compile-only**。它仍受下列条件约束，且：

- **不授权 Product Gate**
- **不上架**
- **不关闭 Phase 2**
- **不把 Assignment 标 Completed**
- **不把 beta Xcode 写成稳定工具链 / Archive / 发布证明**
- **不把 iOS 26 Simulator 测试写成 iOS 18 运行时证据**

## Conditions

| ID | Condition | Why it blocks a plain Pass |
|---|---|---|
| C1 | 工具链仍是 Xcode `27.0` / `27A5237l`（beta，`xcode-select` → `Xcode-beta.app`） | Product Decision 允许用它做 Phase 1 编译证据，但禁止把它写成稳定工具链、Archive 或发布证明。 |
| C2 | 本机没有 iOS 18 Simulator / 真机 | 本轮不能做 iOS 18 输入或 chrome 验收。可用模拟器只有 iOS 26.0 / 26.5 / 27.0。 |
| C3 | 完整 `Universe Keyboard` scheme `test` 未跑 | Phase 1 Exit 是 compile-only；完整套件留给 merge / Archive。 |
| C4 | Phase 2 chrome / iOS 18 运行时仍未授权 | 最低系统改成 18.0 不等于 iOS 18 外观或输入已验证。 |

## Evidence classification

| Check | Review position |
|---|---|
| `project.pbxproj` 全部 `IPHONEOS_DEPLOYMENT_TARGET` = `18.0`（14 处；无 `26.4` 部署目标残留） | Quality-reverified |
| App target Debug/Release 无显式 `IPHONEOS_DEPLOYMENT_TARGET`，继承工程级 `18.0` | Quality-reverified |
| `Packages/KeyboardCore/Package.swift` `.iOS("18.0")` | Quality-reverified |
| `Packages/RimeBridge/Package.swift` `.iOS("18.0")` | Quality-reverified |
| `CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE`（工程级 Debug/Release） | Quality-reverified |
| 未削弱 `SWIFT_STRICT_CONCURRENCY=complete` / `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`；工程未设置 `SWIFT_SUPPRESS_WARNINGS` | Quality-reverified |
| `git diff --stat` 边界：生产代码仅 Package platforms + `project.pbxproj` 目标；无 Keyboard chrome / 热路径 / RIME 所有权改动 | Quality-reverified |
| `Keyboard.xcscheme` 相对 `HEAD` 无改动 | Quality-reverified |
| `Universe Keyboard` Debug `xcodebuild` build（`/tmp/uk-ios18-q-debug`） | Quality-reverified pass：`** BUILD SUCCEEDED **` |
| `Universe Keyboard` Release `xcodebuild` build（`/tmp/uk-ios18-q-release`） | Quality-reverified pass：`** BUILD SUCCEEDED **`；`EXIT:0` |
| Debug App / Appex `MinimumOSVersion` | Quality-reverified：均为 `18.0` |
| Release App / Appex `MinimumOSVersion` | Quality-reverified：均为 `18.0` |
| Executor `/tmp/uk-ios18-debug` 与 `/tmp/uk-ios18-release` | Executor-recorded；仅对照，不作为本评审结果 |
| `swift test --package-path Packages/KeyboardCore --build-path /tmp/uk-ios18-q-keyboardcore` | Quality-reverified pass：`Executed 1030 tests, with 0 failures` |
| `RimeBridgeTests` xcodebuild test | Quality-reverified pass：**不是 iOS 18 runtime**。destination = `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0`；`Executed 68 tests, with 20 tests skipped and 0 failures`；`** TEST SUCCEEDED **`；`EXIT:0` |
| 完整 `Universe Keyboard` scheme test | Skipped With Reason：Phase 1 Exit 只要求 Debug/Release compile；完整套件留给 merge / Archive |
| iOS 18 Simulator / 真机输入 / chrome | Skipped With Reason：不在 Phase 1 关闭范围；本机无 iOS 18 runtime |
| 签名 Archive / TestFlight / App Store | Skipped With Reason：不在本轮授权范围 |
| 稳定工具链证明 | Skipped With Reason：当前唯一可用 Xcode 为 beta `27A5237l` |

## Diff / configuration observations

- 相对 `31f77a1` 的非文档生产 diff 只有：`Packages/KeyboardCore/Package.swift`、`Packages/RimeBridge/Package.swift`、`Universe Keyboard.xcodeproj/project.pbxproj`。
- `CreatedOnToolsVersion = 26.4.1` 仍在 `project.pbxproj`。这是 Xcode 工程创建元数据，不是 `IPHONEOS_DEPLOYMENT_TARGET`，不构成 26.4 部署目标残留。
- 工作区文档 / `CHANGELOG.md` 更新了最低系统陈述，并写明这不是 iOS 18 外观、真机或上架证据。文档更新不是 Product Gate。
- Release generic iOS Simulator 链接出现既有 Vendor `x86_64` slice 缺失的 `ld: warning`。这不是本轮引入，也没有靠关警告换绿。它不挡 Phase 1 compile，但不能外推为 iOS 18 运行时或通用 Simulator 切片健康。

## Residuals

| ID | Residual | Owner | Disposition | Pointer |
|---|---|---|---|---|
| R10-01 | iOS 18 keyboard surface / chrome | Keyboard UI，需新的 Product 授权 | `accept` | Phase 1 明确排除；PD Phase 2 未授权 |
| R10-02 | iOS 18 Simulator / 真机输入矩阵 | Quality / later Environment Executor | `accept` | 本机无 iOS 18 runtime；C2 |
| R10-03 | Phase 1 独立 Quality 复验 | Quality Reviewer | `accept` | 本文件完成 Phase 1 compile 复验；不关闭 Assignment / Phase 2 |
| R10-04 | 稳定工具链上的签名 Archive | `RELEASE-2026-0801-01` | `accept` | C1 / C4；本轮未 archive |
| Q-R10-01 | beta Xcode 不得升格为发布工具链 | `RELEASE-2026-0801-01` / Human Product Owner | `accept` | Xcode `27.0` (`27A5237l`) |
| Q-R10-02 | 完整 App+Keyboard xcodebuild test 未跑 | Quality / merge gate | `accept` | Phase 1 Exit = compile-only |
| Q-R10-03 | Vendor xcframework 缺 `MinimumOSVersion`，Release Simulator 缺 x86_64 slice | RIME / Vendor owner | `accept` | Architecture review 已记录；不构成本轮 Fail |

无本轮必须 `fix` 的 Phase 1 缺陷。

## Re-review / next handoff

以下任一变化都要使本 Phase 1 Quality 结论失效：target / Package platform 漂移、出现未守卫的 post-iOS-18 API、警告/并发/availability 检查被削弱、chrome 或热路径被塞进同一 diff、工具链或最终 Archive 变化。

下一交接：

- Product Lead：决定是否授权 Phase 2 chrome / iOS 18 运行时，或把 Phase 1 工作区提交。
- `RELEASE-2026-0801-01`：稳定工具链 Archive。
- 本 reviewer **不**做 Product Gate、不上架、不 Archive、不关闭 Phase 2。

`SUMMARY_DECISION=Pass with conditions`
