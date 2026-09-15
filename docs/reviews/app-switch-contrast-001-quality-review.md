# APP-SWITCH-CONTRAST-001 独立质量、性能与发布复审

**复审日期：** 2026-09-15（Asia/Shanghai）
**复审 lane：** KOS Quality, Performance & Release
**复审范围：** Assignment [`APP-SWITCH-CONTRAST-001`](../assignments/app-switch-contrast-001.md) 主 App **共享开关对比度**（`AppSwitch` / `.toggleStyle(.appSwitch)`、锁定四态配对、系统 `UISwitch` chrome、调用点全量、Form crash 合同、指南修订）
**工作树：** `/Users/doubleshy0n/Dev/Universe Keyboard`，分支 `main`
**Git 基线：** `HEAD` `83f840bfc335e9919439ddf7ac54f7de8bfaf3e3`（`83f840b Merge pull request #127 from shchnk1103/feature/build55-evidence-pack`）
**原始实现身份：** **无冻结 SHA。** 本结论钉在审查时的 **脏工作树** 上的开关切片文件，不是 commit / payload manifest。见文末“新 SHA 增量核对”附录。
**授权：** [`AUTH-APP-SWITCH-CONTRAST-001-QUALITY`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-QUALITY.md) — 仅独立 Quality；不授权 Product Gate / commit / push / 改 Swift
**Decision：** [`PD-APP-SWITCH-CONTRAST-001`](../product-decisions/APP-SWITCH-CONTRAST-001-authorization.md)（Human 锁定对比度配对与共享 owner，`2026-09-15`）

本 lane **只写本文件**。未改产品 Swift、测试、`CHANGELOG`、`ACTIVE_WORK`、`ENGINEERING_DASHBOARD`、Assignment Current Status、AUTH consumption。Architecture Reviewer 按 Assignment 为 **Not Applicable**（系统 `UISwitch`、无 Capsule/ZStack 自绘 thumb、无主开关驱动的 Section 插拔、无新的 crash-contract 例外）；本文件 **不** 给出 Architecture 结论。

脏树中与本片无关的 CI heavy-job split、ReleaseEvidence、ADR 0035、Build 55 证据 **不纳入** 本裁决。`DiagnosticsSettingsView.swift` 同时含本片 `.appSwitch` 与无关「发布证据」`NavigationLink`：后者只记为脏树混入，不升格为本片 Form crash 违约。

## Verdict

**Pass with conditions。** 无开放 P0/P1。相对 `PD-APP-SWITCH-CONTRAST-001`，工作区源码把全部主 App `Toggle` 收到共享 `.toggleStyle(.appSwitch)`；chrome 是 `UIViewRepresentable` 托管的系统 `UISwitch`，不是 Capsule/ZStack 自绘；`AppSwitchChrome` 的 thumb 映射为「白色，仅 dark+on 为黑」；诊断 / 模糊音 / 触感 / 通知 / 同步 gated 子项仍 always-mounted + disabled/dimming。仓库 Swift 中 **没有** 残留 `.toggleStyle(.switch)`。Keyboard Extension 无 `Toggle` / `AppSwitch`。Human 会话内「真机没什么问题」只覆盖产品观察，**不是** Quality Pass，也 **不是** Product Gate。

本结论 **不** 关闭 Assignment，**不** 授权 Product Gate / commit / merge / TestFlight / Release。

| 严重级别 | 数量 |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 2（均已 disposition，见残差表） |
| P3 | 3（均已 disposition，见残差表） |

### 条件

1. 残差表 disposition 保持有效；Quality 片关闭不要求先补 Device-attested UUID/dSYM/payload，也不要求本审查重跑 `xcodebuild`。
2. 结论只对审查时的开关相关工作区文件有效。之后若这些文件再改、或首次 commit，本文件 **不能** 自动跟随新 SHA。
3. 不得把本文件当成 Product Gate、commit 许可或 TestFlight 许可。

## 已通过的证据

| 领域 | 当前证据 | 结论 |
|---|---|---|
| 共享 owner | 新建 [`AppSwitch.swift`](../../Universe%20Keyboard/Views/Components/AppSwitch.swift)：`AppSwitchChrome` + `AppSwitch: UIViewRepresentable` + `AppSwitchToggleStyle` / `.appSwitch`。`ToggleRow.swift` L27 与 `ContentView.swift` L129 使用 `.appSwitch`。裸 `Toggle` 调用点均带 `.toggleStyle(.appSwitch)`（见调用点清单） | **通过**（源码） |
| 无残留 `.toggleStyle(.switch)` | 全仓库 `*.swift` grep：`toggleStyle(.switch)` **0 命中**；`toggleStyle(.appSwitch)` 覆盖主 App 全部开关 style | **通过** |
| 系统 chrome，非 Capsule 自绘 | `AppSwitchToggleStyle.makeBody`（`AppSwitch.swift` L86–93）仅为 `HStack { label; Spacer; AppSwitch }`。`makeUIView` 返回 `UISwitch()`（L38–47）。无 track/thumb `Capsule` / `ZStack` | **通过**。Architecture 仍 N/A |
| 对比度配对（代码映射） | `onTintColor()` → `UIColor.label`（浅黑深白轨道）。`thumbTintColor(isOn:isDark:)`：`isDark && isOn` → `.black`，否则 `.white`（L16–26）。关闭态 **不是** 黑点 | **通过**（chrome 函数）。四态目视由 Human-attested 支撑，非本 lane 重验 |
| 根级 `.tint(.primary)` | `ContentView.swift` L128–129：`.tint(.primary)` 后跟 `.toggleStyle(.appSwitch)`。`updateUIView` / `valueChanged` 显式写 `onTintColor` / `thumbTintColor`，不依赖 SwiftUI `.tint` 当 thumb | **源码对齐 PD**。Quality 未在 Simulator 目视 |
| SettingsTab / Appearance | `SettingsTab.swift` L114–132、L199–205 与 `AppearanceSettingsView.swift` L69–73 走 `ToggleRow`，无页面私有 thumb/track 颜色。两文件本片无独立 diff（owner 在 `ToggleRow`） | **通过** |
| 诊断 Form crash 合同 | `DiagnosticsSettingsView.swift`：主开关独立 Section（L109–131）；分类 Section 始终挂载 + `.disabled(!loggingEnabled)` + opacity（L145–162）；短时采样始终挂载 + disabled/opacity（L202–235）。无主开关 `.animation`。注释 L6–12 与 [`DEBUGGING.md`](../DEBUGGING.md) L73–79 一致 | **通过**（源码）。同文件 L322–330 的「发布证据」链接 **不** 由主开关插拔 |
| 模糊音 / 高级输入 gated | `RimeFuzzyPinyinSettingsView.swift`：子 Section 始终存在，`.disabled(!supports \|\| !fuzzyEnabled)`（L54–57、L71–74）。`if supportsManagedFuzzyPinyin` 是方案能力，不是主开关 remount（既有 TD-010）。`RimeAdvancedInputSettingsView.swift` feature Section `.disabled(!supports \|\| !masterEnabled)`（L99） | **通过** |
| 触感 / 通知 / 同步 gated | `FeedbackSettingsView.swift` 震动强度 Section 始终挂载（L39–56）。`NotificationSettingsView.swift` `RimeSyncNotificationControls` + scopes always-mounted（L43–53、L185–216）。`RimeSyncSettingsView.swift` 自动同步子项 Group always-mounted（L132–177） | **通过** |
| 语义 / 默认值 | 本片 `git diff` 对上述绑定/默认值仅为 `.switch` → `.appSwitch`（及 `RimeAdvancedInputSettingsView` 示例数组尾逗号格式）。未见 gated-child 规则改写 | **通过**（diff 审计） |
| Keyboard Extension | `Keyboard/` 无 `Toggle` / `toggleStyle` / `AppSwitch` | **通过**（范围外且未改 chrome） |
| 指南 | [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) L177：共享 `.appSwitch` + 四态配对 + 禁止 Capsule + `.tint` 不得洗 thumb。[`DEBUGGING.md`](../DEBUGGING.md) L76：`.appSwitch` 托管 `UISwitch` | **通过** |
| 单元：chrome 映射 | [`AppSwitchChromeTests.swift`](../../UniverseKeyboardTests/AppSwitchChromeTests.swift) 四用例：on-tint `.label`；浅色 on/off 白点；深色 on 黑点；深色 off 白点 | **通过**（测试源码）。不覆盖 `UIViewRepresentable` |
| 工程收录 | `project.pbxproj` 对 `Universe Keyboard/` 与 `UniverseKeyboardTests/` 为 `PBXFileSystemSynchronizedRootGroup`；未跟踪的 `AppSwitch.swift` / `AppSwitchChromeTests.swift` 会进入对应 target | **通过**（工程模型） |
| Simulator App+Keyboard | 原始脏树记录的测试计数不再作为冻结 SHA 证据；新 SHA 增量复验为 `UniverseKeyboardTests 361 / 9 skipped`（含 `AppSwitchChromeTests`）、`KeyboardTests 11`，结果 **TEST SUCCEEDED**。 | **增量复验通过。** 原始审查正文仍绑定脏树身份 |
| Human 真机观察 | [`SHA-bound Human-attested record`](../evidence/app-switch-contrast-001-human-attested-observation-2026-09-15.md)：iPhone 13 Pro / iOS 27；设置首页、诊断页、模糊音 Form；四态均可读 | **Human-attested / Product observation。** 不是 Device-attested，不是 Quality 复验真机，不是 Product Gate |

## 调用点清单（本审查独立 grep）

Assignment Scope 所列路径与工作区 `Toggle(` / `.toggleStyle` 对照：

| 路径 | 开关入口 | `.appSwitch` |
|---|---|---|
| `Views/Components/ToggleRow.swift` | 内嵌 `Toggle` | L27 |
| `Views/Settings/SettingsTab.swift` | `ToggleRow` ×3（上屏后联想 / 成对符号 / 默认简体） | 经 `ToggleRow` |
| `Views/Settings/AppearanceSettingsView.swift` | `ToggleRow`（Liquid Glass） | 经 `ToggleRow` |
| `Views/Settings/DiagnosticsSettingsView.swift` | 主开关 + 分类 + Debug 高保真/到期通知/按键 overlay | L125、L192、L216、L227、L247 |
| `Views/Settings/NotificationSettingsView.swift` | 允许通知、操作提示、Debug 诊断结束、RIME 同步类别与 scopes | L41、L108、L148、L183、L211 |
| `Views/Settings/FeedbackSettingsView.swift` | 按键音、按键震动 | L23、L32 |
| `Views/Settings/TypingIntelligenceView.swift` | 洞察开关 | L90 |
| `Views/Settings/TypoCorrectionBenchmarkView.swift` | 漏字 / 转置实验 | L143、L152 |
| `Views/Settings/RimeFuzzyPinyinSettingsView.swift` | 主开关与各组（含 unsupported 常量绑定） | L14–17、L39–47、L62–64 |
| `Views/Settings/RimeAdvancedInputSettingsView.swift` | 主开关 + `AdvancedInputFeatureToggle` | L42、L45、L159 |
| `Views/Settings/RimeUserDictionarySettingsView.swift` | 自动备份；方案详情 | L15、L68 |
| `Views/Settings/RimeSyncSettingsView.swift` | 自动同步及两项子开关 | L129、L147、L162 |
| `App/ContentView.swift` | 根级 style | L129 |
| `Views/Guide/**`、`Views/Diagnostics/**`（除设置页） | 无 `Toggle(` | n/a |

未发现 Assignment 清单外的主 App `Toggle` 漏网。

## Findings

无 P0/P1。下列不是「实现相对 PD 写错」，而是证据分级或脏树残差。

### P2-01：真机对比度为 Human-attested，不是 Device-attested

AUTH 记录 Human「真机没什么问题」。无设备 UUID、已安装 executable / dSYM、OS 矩阵、payload SHA、截图附件。按 [`universe-keyboard-human-operated-evidence-profile.md`](../kos/universe-keyboard-human-operated-evidence-profile.md) **不能** 记为 Device-attested，也 **不能** 记为本 Quality lane 复验真机。

源码四态映射与 PD 锁定配对一致（见上表），因此 **不** 因缺 Device-attested 自动 Fail。Product Gate / Release **不得** 声称「Quality 已在真机证明四态对比度」。

Disposition：`accept`（本 Quality 片；见 `ASC-01`）。

### P2-02：无冻结实现 SHA；开关文件与无关脏树并存

`AppSwitch.swift`、`AppSwitchChromeTests.swift` 仍为未跟踪文件；调用点与指南为已修改未提交。同树还有 CI split、ReleaseEvidence、ADR 0035 等。P-01 对本片 Not applicable。

`DiagnosticsSettingsView.swift` 在「查看与管理」增加静态 `ReleaseEvidenceView` `NavigationLink`（L322–330）及 footer 文案——**不是** 主开关 Section 插拔，但提交时必须与本片切开。

Disposition：`accept`（见 `ASC-02`）。任何 commit 必须把开关文件从无关脏改动中切开，并在新 SHA 上决定是否重验。

### P3-01：自动测试只锁 `AppSwitchChrome` 颜色函数

四条 XCTest 不断言 `UISwitch.onTintColor` 实际写回、`updateUIView` 与 `valueChanged` 路径、或调用点 completeness。调用点由本审查 grep 补齐。不要求本片为 Quality 关闭去补 UI 测试。

Disposition：`accept`（见 `ASC-03`）。

### P3-02：关闭态轨道颜色交给系统 `UISwitch` 默认值

PD 浅关「浅槽 + 白点」、深关「深槽 + 白点」。实现只显式设置 `onTintColor` 与 `thumbTintColor`；off-track 未设自定义色。这符合「只用系统 chrome、禁止自绘」，thumb 在 dark-off 保持白色（测试锁定）。Quality 未独立目视系统灰槽是否仍可读。

Disposition：`accept`（见 `ASC-04`）。

### P3-03：`valueChanged` 用 `traitCollection`，`updateUIView` 用 SwiftUI `colorScheme`

`AppSwitch.swift` L56 vs L79。在 `preferredColorScheme` 覆盖下，下一次 `updateUIView` 会按 environment 纠正。Human 未报告外观错配。不是合同违约。

Disposition：`accept`（见 `ASC-05`）。

## Architecture N/A

本审查 **不争议** Architecture `Not Applicable`。`AppSwitchToggleStyle` 是布局包装 + 系统 `UISwitch`，不是 Capsule/ZStack 自绘 thumb。主开关周围 Form 拓扑仍为 always-mounted + disabled/dimming；未见新的 crash-contract 例外请求。若未来改回自绘 `ToggleStyle`、或按主开关 `if` 插拔 Section，才需要 Architecture 与新的 Product Decision。

诊断页混入的「发布证据」行属于 **另一 Assignment** 的静态导航，不在本 Architecture 触发条件内；本文件不对 ReleaseEvidence 做质量结论。

## Human-attested 真机观察（诚实分级）

记录来源：[`SHA-bound Human-attested observation`](../evidence/app-switch-contrast-001-human-attested-observation-2026-09-15.md)。Human Product Owner 在实现 SHA `5d3880b13109a65b8e441ded74b82f9927ffb9b4` 对应的主 App 上报告：iPhone 13 Pro / iOS 27，设置首页、诊断页、模糊音 Form 的浅/深色 × 开/关四态均可读。此前 [`AUTH-APP-SWITCH-CONTRAST-001-QUALITY`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-QUALITY.md) 的口头观察仍保留为历史来源。

**Grade：Human-attested / Product observation。** 记录绑定实现 SHA，但没有 UUID/SHA-256/dSYM/冻结 manifest/截图，因此按 Human-operated evidence profile **不是** Device-attested，**不是** Quality-reverified 真机，**不是** Product Gate。足以支撑「该 SHA 对应主 App 的四态对比度曾被产品在真机观察为可读」的窄工程叙述；不足以单独构成 Quality 无条件 Pass 或 Release。

## 明确跳过的检查

本审查 **没有** 重跑 `xcodebuild` / `swift test` / KeyboardCore / RimeBridgeTests / Debug-Release `build`。未操作 Simulator 或真机。未做 hosted CI（无 SHA）。未审 CI split / ReleaseEvidence / ADR 0035 脏文件（`DiagnosticsSettingsView` 中与开关无关的链接除外，仅作混入记录）。

本地只读：

```text
git rev-parse HEAD   # 83f840bfc335e9919439ddf7ac54f7de8bfaf3e3
git status --short   # 脏树；开关文件与无关文件并存
# 阅读 Assignment / PD / AUTH / UI_STYLE_GUIDE / DEBUGGING / 指定 Swift 与测试
# grep Toggle / toggleStyle(.switch) / toggleStyle(.appSwitch) / Capsule ToggleStyle
```

Executor 自检与聊天记录不构成本裁决；原始审查的测试记录仅作 Executor-recorded 机器证据引用。新 SHA 的增量复验另见下方附录。

## 新 SHA 增量核对（2026-09-15）

| Boundary | Result |
|---|---|
| Implementation source | `5d3880b13109a65b8e441ded74b82f9927ffb9b4` |
| Final tip | `63f1a6d95316187249bcd3f85c5f7883bc13bf7d`；相对实现 SHA 仅文档回写 |
| Swift strict lint | 变更的 13 个 Swift 文件全部通过 |
| Main-App / Keyboard Debug test | **TEST SUCCEEDED**；`UniverseKeyboardTests` 361 执行、9 跳过、0 失败；`KeyboardTests` 11 执行、0 失败 |
| Static scope audit | `.toggleStyle(.switch)` 0 命中；无 CI heavy-job、ReleaseEvidence、ADR 0035 混入 |
| Conclusion | 未发现新的 P0/P1/P2 代码问题；原始 Quality `Pass with conditions` 继续有效，`ASC-01` 仍保持 Human-attested 边界 |

## 残差账本

| Residual ID | 严重级别 | Owner | Disposition | Pointer |
|---|---|---|---|---|
| `ASC-01` | P2 | Human Product Lead（Product Gate / 可选 Device-attested） | `accept` | 真机仅为 Human-attested。AUTH-APP-SWITCH-CONTRAST-001-QUALITY 决策句；无 UUID/dSYM/OS 矩阵文件 |
| `ASC-02` | P2 | 发布 / 提交切片 | `accept` | 已由实现 SHA `5d3880b`、文档回写 tip `63f1a6d` 和新 SHA 增量核对闭合；切片未混入 CI heavy-job、ReleaseEvidence 或 ADR 0035 |
| `ASC-03` | P3 | 主 App UI 测试（未来 Assignment） | `accept` | 仅 `UniverseKeyboardTests/AppSwitchChromeTests.swift`；无 UISwitch/Form/调用点自动锁 |
| `ASC-04` | P3 | 主 App UI（系统 chrome 边界） | `accept` | off-track 未设自定义色：`AppSwitch.swift` `applyChrome` L59–65；PD 关闭态槽色委托系统 `UISwitch` |
| `ASC-05` | P3 | 主 App UI（可选后续） | `accept` | `updateUIView` 用 `colorScheme`（L56），`valueChanged` 用 `traitCollection`（L79） |

Quality 片关闭不因上述残差阻塞：每条都有 disposition。

## 非声称

- 不是 Product Gate、Assignment `Closed`、Quality 对 **Device-attested 四态目视** 的 Pass。
- 不是 commit / push / PR / merge / TestFlight / App Store / Release。
- 不是 D-01 receipt、P-01 publication、hosted CI、冻结 payload。
- 不是 Architecture 复审。
- 不是 Keyboard Extension 外观结论。
- 不是 CI-HEAVY-JOB-SPLIT-001 或 RELEASE-EVIDENCE-PROMOTION-001 质量结论。
- 不是「Human 真机没什么问题」= Quality 无条件 Pass。
- 原始脏树审查未重跑 `xcodebuild`；新 SHA 增量核对已单独重跑并记录在上方，不发明 hosted CI 结果。

## 建议的下一步（Human）

1. **Product Gate（另授权）：** 若产品接受 ASC-01（无 Device-attested 载荷）为本片发布前残差，可对 **主 App 开关对比度** 做 Product Gate；本文件 **不** 代替该 Gate。Gate 前建议产品再确认浅/深 × 开/关四态，尤其深色关闭白点、深色开启黑点。
2. `ASC-02` 实现切片已经由 `5d3880b` 冻结并完成新身份增量核对；本次仅为经授权的 docs-only 证据回写，不重新打开 Swift 实现，也不授权 push / PR / merge。
3. 可选后续（不要混进本片）：为 `UISwitch` 写回增加测试；统一 `colorScheme` / `traitCollection` 来源。

下一步默认交 **Product Lead（Human Product Gate）**，不是本 lane 继续改 Swift。
