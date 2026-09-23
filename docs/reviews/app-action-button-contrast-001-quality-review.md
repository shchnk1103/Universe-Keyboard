# APP-ACTION-BUTTON-CONTRAST-001 独立质量、性能与发布复审

**复审日期：** 2026-09-23（Asia/Shanghai）
**复审 lane：** KOS Quality, Performance & Release
**复审范围：** Assignment [`APP-ACTION-BUTTON-CONTRAST-001`](../assignments/app-action-button-contrast-001.md) 主 App **共享操作按钮对比度**（`AppActionButton` / `AppActionButtonChrome`、锁定 primary 深浅反转、secondary / destructive / disabled / Reduce Transparency、调用点全量、Liquid Glass 保留、指南修订）
**工作树：** `/private/tmp/universe-keyboard-app-action-button-contrast-001`，分支 `grok/app-action-button-contrast-001`（tracking `origin/main`）
**Git 基线：** `HEAD` `9b8b7a73f4d373adbd7ee436d318cde3d9bc4c78`（`9b8b7a7 docs(typo-correction-002): mark INT-003 cancel observability markers AUTH Live (#151)`），与 `origin/main` 相同。本审查独立 `git rev-parse` / `git status` 核实，不是 Executor 口述。
**原始实现身份：** **无冻结 SHA。** 本结论钉在审查时的 **脏工作树** 上的按钮切片文件，不是 commit / payload manifest。
**授权：** [`AUTH-APP-ACTION-BUTTON-CONTRAST-001-QUALITY`](../authorizations/AUTH-APP-ACTION-BUTTON-CONTRAST-001-QUALITY.md) — 仅独立 Quality；不授权 Product Gate / commit / push / 改 Swift。本 lane **未** 回写 AUTH consumption。
**Decision：** [`PD-APP-ACTION-BUTTON-CONTRAST-001`](../product-decisions/APP-ACTION-BUTTON-CONTRAST-001-authorization.md)（Human 锁定 primary 浅黑底白字 / 深白底黑字，并确认补充态 5–11，`2026-09-23`）

本 lane **只写本文件**。未改产品 Swift、测试、`CHANGELOG`、`ACTIVE_WORK`、`ENGINEERING_DASHBOARD`、Assignment Current Status、AUTH consumption。Architecture Reviewer 按 Assignment 为 **Not Applicable**（仍在既有 `AppActionButton` + `glassEffect(.regular.interactive())`，无第二套按钮家族、未丢掉 Liquid Glass、未改 Keyboard chrome）；本文件 **不** 给出 Architecture 结论。

脏树中与本片同批的 Assignment / PD / AUTH / `CHANGELOG` / `ACTIVE_WORK` / `ENGINEERING_DASHBOARD` / `PROJECT_CONTEXT` 镜像 **不** 升格为本片对比度合同证据。Executor 聊天中的「TEST SUCCEEDED / 381 / 15」记为 Executor-recorded，**不** 构成本裁决；本审查已独立重跑同一 `xcodebuild`。

## 身份（审查时工作树）

| Boundary | 本审查实测 |
|---|---|
| `HEAD` | `9b8b7a73f4d373adbd7ee436d318cde3d9bc4c78` = `origin/main` |
| 分支 | `grok/app-action-button-contrast-001`，相对 `origin/main` 无已提交超前 commit |
| 脏树 | 已修改未提交：`Universe Keyboard/Views/Components/AppActionButton.swift`、`docs/UI_STYLE_GUIDE.md`、`CHANGELOG.md`、`docs/ACTIVE_WORK.md`、`docs/ENGINEERING_DASHBOARD.md`、`docs/PROJECT_CONTEXT.md`。未跟踪：`UniverseKeyboardTests/AppActionButtonChromeTests.swift`、Assignment / PD / 三份 AUTH |
| Keyboard Extension | `git diff -- Keyboard/` **空** |
| 切片文件 SHA-256（工作区字节，非 git object） | `AppActionButton.swift` `a25c6a8d1962fcdde1413bae39e5151f2aad37d0b008cc2d94e6e6ad1a38f595`；`AppActionButtonChromeTests.swift` `bc9a49ff826faff8f4fc3e2da62bc91bdd83582400419e10009b07b8df6ba9a0`；`UI_STYLE_GUIDE.md` `2f0b3e52297b074acdf35b6956b4610ee8aff18b2332fca5da12b395129f737a` |

之后若这些文件再改、或首次 commit，本文件 **不能** 自动跟随新 SHA。

## Verdict

**Pass with conditions。** 无开放 P0/P1。相对 `PD-APP-ACTION-BUTTON-CONTRAST-001`，工作区源码把主 App 内容操作按钮的颜色 / 玻璃 tint / fallback / disabled 透明度收到共享 `AppActionButtonChrome`；`AppActionButtonSurface` 在 Reduce Transparency off 且 iOS 26 时继续 `.glassEffect(.regular.tint(...).interactive())`（secondary 为近无 tint 的 `.regular.interactive()`），否则实心 fallback。Primary 映射为 label fill + `systemBackground` 文字 + glass tint `0.92`；destructive 保持语义红（浅 0.22 / 深 0.28）；disabled 为同一颜色对 × `0.40` opacity，没有另做中灰填充。全仓库 `*.swift` **没有** `.borderedProminent`。`Keyboard/` 无 `AppActionButton` 且本片未改 Extension chrome。Human 会话内「视觉上我觉得可以通过」只覆盖产品观察，**不是** Quality 复验真机，**不是** Device-attested，**不是** Product Gate。

本结论 **不** 关闭 Assignment，**不** 授权 Product Gate / commit / merge / TestFlight / Release。

| 严重级别 | 数量 |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 3（均已 disposition，见残差表） |
| P3 | 3（均已 disposition，见残差表） |

### 条件

1. 残差表 disposition 保持有效；Quality 片关闭不要求先补 Device-attested UUID/dSYM/payload，也不要求先去掉调用点上既有的额外 `.opacity`。
2. 结论只对审查时的按钮相关工作区文件有效。之后若这些文件再改、或首次 commit，本文件 **不能** 自动跟随新 SHA。
3. 不得把本文件当成 Product Gate、commit 许可或 TestFlight 许可。
4. Human 目视分级保持 **Human-attested / Product observation**。

## 已通过的证据

| 领域 | 当前证据 | 结论 |
|---|---|---|
| 共享 owner | [`AppActionButton.swift`](../../Universe%20Keyboard/Views/Components/AppActionButton.swift)：`AppActionButtonChrome`（L5–67）拥有 tokens；`AppActionButton` 只读 `prominence` / `@Environment(\.isEnabled)`；`AppActionButtonSurface` 拥有 glass / solid。调用点无 fill / foreground 覆写（见调用点清单） | **通过**（源码） |
| Primary 配对 | chrome：`solidFillColor(.primary)` = `.label`；`labelColor(.primary)` = `.systemBackground`；`primaryGlassTintOpacity` = `0.92`。glass：`Color.primary.opacity(0.92)`（L181–186）。浅色 = 黑底白字，深色 = 白底黑字（系统 label / systemBackground 语义） | **通过**（chrome 函数 + Surface）。目视由 Human-attested 支撑，非本 lane 重验 |
| Secondary | iOS 26：`.regular.interactive()`、无额外 tint（L187–191）；文字 `.label`。solid fallback：`secondarySystemGroupedBackground` + `.separator` + `0.5 pt`（`fallbackSecondaryBorderWidth`） | **通过**（源码）。深色玻璃抬升未由本 lane 目视 |
| Destructive | 语义红：文字 `.systemRed`；glass `Color.red` × 浅 `0.22` / 深 `0.28`（`colorScheme == .dark`）；solid fill 红 `0.12` + 描边红 `0.18` / `0.7 pt` | **通过**（源码）。glass 用 `Color.red`、solid 用 `systemRed`，见 `AABC-06` |
| Disabled / busy | `controlOpacity`：enabled `1`、disabled `0.40`，挂在控件根（L135）。没有 disabled 专用中灰 fill。同步中 ProgressView 仍在 `RimeSyncSettingsView` 状态行（L86–88），按钮只 `.disabled(isSynchronizing)` | **通过**（组件合同）。三处调用点另叠 `.opacity(0.45)`，见 `AABC-03` |
| Reduce Transparency / Liquid Glass | `usesGlassMaterial(reduceTransparency:)`：off → 允许玻璃；on → 实心。`AppActionButtonSurface`：允许玻璃且 `#available(iOS 26.0, *)` 才 `glassEffect`；否则 `solid`。未见改回无材质灰胶囊 | **通过**（源码）。真实 `glassEffect` 渲染未由 XCTest 锁住 |
| Pressed | glass 均带 `.interactive()`。组件 `.buttonStyle(.plain)`，未再叠灰色 overlay，也未新套 `AppPressableButtonStyle`（PD 允许「若已套用」） | **通过** |
| 无手写 `.borderedProminent` | 全仓库 `*.swift` grep：`borderedProminent` **0 命中** | **通过** |
| Keyboard Extension | `Keyboard/` 无 `AppActionButton`；本片 `git diff -- Keyboard/` 空 | **通过**（范围外且未改 chrome） |
| 指南 | [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) L166：共享 chrome + Liquid Glass + 锁定配对 + disabled `0.40`。L194：禁止调用点覆写 fill / foreground，只传 prominence / `.disabled` | **通过**（相对 PD 落地） |
| 单元：chrome 映射 | [`AppActionButtonChromeTests.swift`](../../UniverseKeyboardTests/AppActionButtonChromeTests.swift) 8 用例：primary 文字/fill、secondary 文字/grouped fill、destructive 红、disabled opacity、Reduce Transparency 开关、destructive 深浅 tint、primary glass `0.92` | **通过**（测试源码 + 本审查重跑）。不覆盖真实 `glassEffect` / 调用点 |
| 工程收录 | `project.pbxproj`：`Universe Keyboard/` 与 `UniverseKeyboardTests/` 为 `PBXFileSystemSynchronizedRootGroup`；未跟踪的 chrome 测试会进入 `UniverseKeyboardTests` | **通过**（工程模型） |
| Swift 格式 | 本审查对变更的两个 `.swift` 文件执行 `xcrun swift-format lint --strict --configuration .swift-format`，exit 0 | **通过**（本审查） |
| Simulator App+Keyboard | 本审查独立重跑（见下）。**TEST SUCCEEDED**：`UniverseKeyboardTests` 381 执行 / 9 skipped / 0 failed（含 `AppActionButtonChromeTests` 8）；`KeyboardTests` 15 / 0 failed | **独立复验通过。** 不是 hosted CI，不是 Device-attested |
| Human 目视 | AUTH-QUALITY 决策句：Human Product Owner「视觉上我觉得可以通过」（`2026-09-23` in-session） | **Human-attested / Product observation。** 不是 Device-attested，不是 Quality 复验真机，不是 Product Gate |

### 本审查独立重跑的机器证据

按 [`AI_WORKFLOW.md`](../AI_WORKFLOW.md) 证据复用条件：未提交快照、内容相对 `HEAD` 已变、独立 Quality 不得把 Executor 计数当事实。本审查 **没有** 复用 Executor-recorded `TEST SUCCEEDED`，而是重跑同一 scheme / 配置 / destination。

```text
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" -configuration Debug \
  -destination 'platform=iOS Simulator,id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2' \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 \
  SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
```

| 项 | 本审查记录 |
|---|---|
| Destination | `iPhone 17 Pro` (`8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`)，simctl 列为 iOS 26.0 **Booted**；SDK `iPhoneSimulator27.0` |
| 结果 | `** TEST SUCCEEDED **`（exit 0） |
| `UniverseKeyboardTests` | Executed **381**，skipped **9**，failed **0** |
| `AppActionButtonChromeTests` | Executed **8**，failed **0** |
| `KeyboardTests` | Executed **15**，failed **0** |
| xcresult | `/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-eafbtfbybcomluaqpklttnscjopv/Logs/Test/Test-Universe Keyboard-2026.09.23_19-19-22-+0800.xcresult` |
| 未跑 | KeyboardCore-only `swift test`、`RimeBridgeTests`、Release `build`、hosted CI |

Executor 记录的 381 / 9 skipped / KeyboardTests 15 与本次数值一致，但本裁决只引用 **本审查这次** 的命令与 xcresult。

## 调用点清单（本审查独立 grep）

全仓库 `AppActionButton(`：**38** 处，11 个 Swift 文件。未发现页面覆写 fill / foreground / `.borderedProminent`。布局 `.frame` / `.padding` / `.accessibilityHint` / `.disabled` 不算 chrome 覆写。

| 路径 | 入口（prominence） | 额外视觉修饰 |
|---|---|---|
| `Views/Settings/RimeSyncSettingsView.swift` | 「立即同步」`.primary` L92；「重新选择同步文件夹」`.primary` L105；「保存 WebDAV 设置」默认 secondary L254；「保存恢复码」`.primary` shareText L338；「使用已有恢复码」默认 secondary L345 | 「立即同步」`.disabled(isSynchronizing)`。页级 `.tint(.primary)` L30（accent，不是按钮 fill） |
| `Views/Settings/RimeDeploymentContent.swift` | 部署 `.primary` L53；「取消」默认 secondary L62；「重置」默认 secondary L72 | 「重置」`.frame(maxWidth: 112)` |
| `Views/Settings/RimeUserDictionarySettingsView.swift` | 「备份」「恢复」`.secondary` L88/L98；「清空…学习记录」`.destructive` L116 | 备份/恢复在 `.disabled` 上再 `.opacity(… ? 1 : 0.45)` → `AABC-03` |
| `Views/Settings/RimeSettingsView.swift` | 高级输入恢复动作，默认 secondary L393 | 无 |
| `Views/Settings/SchemaDownloadContentViews.swift` | 「查看许可证」默认 secondary L43；「同意并下载」`.primary` L49；「重试」默认 secondary L97；管理网格：检查更新/重新下载/许可证默认 secondary，「卸载」`.destructive` L131–148 | 「同意并下载」`.disabled(!isLicenseAccepted)`；「重试」`.frame(maxWidth: 92)` |
| `Views/Settings/TypoCorrectionBenchmarkView.swift` | 「重置实验学习记录」`.destructive` L172 | `.disabled` + `.opacity(0.45)` 当计数为 0 → `AABC-03` |
| `Views/Diagnostics/ReleaseEvidenceView.swift` | 「开始记录会话」「复制为外部候选」`.primary` L61/L101；「分享结构化证据」shareText 默认 secondary L111 | 前两处 `.disabled(model.isSaving)` |
| `Views/License/LicenseView.swift` | 接受 `.primary` L41 | `.padding()`；外层 sheet `.background(.regularMaterial)` 不是按钮 fill |
| `Views/Guide/ActivationWelcomeView.swift` | 开始 `.primary` L71；稍后 `.secondary` L80 | accessibilityHint only |
| `Views/Guide/ActivationResourcePreparePanel.swift` | 下载/许可证 `.primary` L183；激活部署 `.primary` L207；重试下载/部署 `.secondary` L247/L279 | busy 时 `.disabled` |
| `Views/Guide/GuideTab.swift` | 重走/打开设置 `.primary` L196/L222/L322；确认/推迟/继续 `.secondary` L406–458 | accessibilityHint only |

未发现 Assignment 清单外的 `AppActionButton(` 漏网。仓库另有 `DiagnosticsLogContentView.swift` L73 `.buttonStyle(.bordered)`（「加载更早记录」分页），**不是** `AppActionButton`，也不在本片「下载 / 部署 / 重置」禁止名单的自动 Fail 范围内。

## Findings

无 P0/P1。下列不是「primary 配对写错」，而是证据分级、脏树身份或调用点既有叠层。

### P2-01：目视为 Human-attested，不是 Device-attested

AUTH 记录 Human「视觉上我觉得可以通过」。无设备 UUID、已安装 executable / dSYM、OS 矩阵、payload SHA、截图附件。按 [`universe-keyboard-human-operated-evidence-profile.md`](../kos/universe-keyboard-human-operated-evidence-profile.md) **不能** 记为 Device-attested，也 **不能** 记为本 Quality lane 复验真机或 Simulator 目视。

源码 chrome 映射与 PD 锁定配对一致（见上表），因此 **不** 因缺 Device-attested 自动 Fail。Product Gate / Release **不得** 声称「Quality 已在真机证明深浅对比度」。

Disposition：`accept`（本 Quality 片；见 `AABC-01`）。

### P2-02：无冻结实现 SHA；切片文件与状态镜像并存于脏树

`AppActionButton.swift` 已修改未提交；`AppActionButtonChromeTests.swift` 未跟踪。同树还有 Assignment / PD / AUTH 与 `CHANGELOG` / Dashboard / Active Work / `PROJECT_CONTEXT` 镜像。P-01 对本片 Not applicable。

Disposition：`accept`（见 `AABC-02`）。任何 commit 必须把按钮切片从无关状态镜像中按授权切开，并在新 SHA 上决定是否重验。

### P2-03：三处调用点在组件 `0.40` 之外再叠 `.opacity(0.45)`

`RimeUserDictionarySettingsView` 备份/恢复、`TypoCorrectionBenchmarkView` 重置：均已 `.disabled`，再乘 `0.45`。组件根已对 disabled 应用 `0.40`，合成约 `0.18`。这 **不是** fill/foreground 覆写，也 **不是** 「可点击却发灰」（这些控件当时确实 disabled），但偏离 Assignment「调用点只传 prominence / `.disabled`」的字面完整性。改动为既有调用点，本片 Swift diff 未改这些文件。

Disposition：`accept`（见 `AABC-03`）。不阻塞本 Quality 片；可选后续收进共享 disabled，不要在本片混修语义绑定。

### P3-01：自动测试只锁 chrome 函数，不锁真实 `glassEffect` / 调用点 / 目视

八条 XCTest 不断言 `glassEffect` 实际挂上、Reduce Transparency 环境路径、或 38 处调用点 completeness。调用点由本审查 grep 补齐。不要求本片为 Quality 关闭去补 UI 测试。

Disposition：`accept`（见 `AABC-04`）。

### P3-02：iOS 26 secondary 玻璃无 tint；深色抬升委托系统材质

PD 补充态 6：近无 tint + 深色要有足够抬升以免融进 grouped 底。实现是完全不 tint 的 `.regular.interactive()`。符合「近无 tint」，深色抬升是否足够 **未** 由本 lane 目视。Human 口头观察覆盖产品接受，不是 Quality 复验。

Disposition：`accept`（见 `AABC-05`）。

### P3-03：destructive glass 用 `Color.red`，solid / 文字用 `UIColor.systemRed`

同一语义红，API 不一致。测试只锁 `systemRed` 的 solid/label。未见品牌 accent。不是合同违约。

Disposition：`accept`（见 `AABC-06`）。

## Architecture N/A

本审查 **不争议** Architecture `Not Applicable`，也 **不** 另给 Architecture 结论。实现仍是既有 `AppActionButton` + `glassEffect(.regular.interactive())`（Reduce Transparency / iOS 18 走实心 fallback）。未见第二套内容操作按钮家族，未见丢掉 iOS 26 Liquid Glass（在 Reduce Transparency off 时），未见 Keyboard Extension chrome 被拉进范围。`AppPressableButtonStyle` 仍只用于 Home / `SettingsNavigationLink` 按压，不是第二套 action-button 外观。若未来新增按钮家族、禁止 Liquid Glass、或改 Keyboard 按键/候选 chrome，才需要 Architecture 与新的 Product Decision。

## Human-attested 观察（诚实分级）

记录来源：[`AUTH-APP-ACTION-BUTTON-CONTRAST-001-QUALITY`](../authorizations/AUTH-APP-ACTION-BUTTON-CONTRAST-001-QUALITY.md) 决策句。Human Product Owner，当前会话 `2026-09-23 Asia/Shanghai`：「视觉上我觉得可以通过。」无独立 evidence 文件、无 UUID/SHA-256/dSYM/冻结 manifest/截图。

**Grade：Human-attested / Product observation。** 按 Human-operated evidence profile **不是** Device-attested，**不是** Quality-reverified 真机，**不是** Product Gate。足以支撑「产品在会话内接受当前主 App 按钮对比度观感」的窄工程叙述；不足以单独构成 Quality 无条件 Pass 或 Release。

## 明确跳过的检查

- 未跑 `swift test --package-path Packages/KeyboardCore`、`RimeBridgeTests`、Release `build`（本片未改那些 target；Assignment 实施交接也未要求 Quality 补跑）。
- 未做 hosted CI（无冻结 SHA）。
- 本 Quality lane **没有** 在 Simulator 或真机上目视浅/深 × primary/secondary/destructive × enabled/disabled × Reduce Transparency。
- 未审无关 Active Work 行（TYPO / Release 等）的质量。
- 未操作 AUTH consumption、Product Gate、commit、push。

本地只读 + 独立测试：

```text
git rev-parse HEAD   # 9b8b7a73f4d373adbd7ee436d318cde3d9bc4c78
git status --short   # 脏树；按钮切片 + 治理镜像并存
# 阅读 Assignment / PD / AUTH-IMPLEMENT / AUTH-QUALITY / UI_STYLE_GUIDE / playbooks
# grep AppActionButton( / borderedProminent / glassEffect / Keyboard/AppActionButton
xcrun swift-format lint --strict --configuration .swift-format \
  "Universe Keyboard/Views/Components/AppActionButton.swift" \
  UniverseKeyboardTests/AppActionButtonChromeTests.swift
# 上表 xcodebuild（独立重跑，非 Executor 复用）
```

## 残差账本

| Residual ID | 严重级别 | Owner | Disposition | Pointer |
|---|---|---|---|---|
| `AABC-01` | P2 | Human Product Lead（Product Gate / 可选 Device-attested） | `accept` | 目视仅为 Human-attested。AUTH-APP-ACTION-BUTTON-CONTRAST-001-QUALITY 决策句；无 UUID/dSYM/OS 矩阵文件 |
| `AABC-02` | P2 | 发布 / 提交切片 | `accept` | 无冻结实现 SHA。`HEAD` `9b8b7a73…` + 脏树；`AppActionButton.swift` SHA-256 `a25c6a8d…` |
| `AABC-03` | P2 | 主 App UI（可选后续） | `accept` | 调用点额外 `.opacity(0.45)`：`RimeUserDictionarySettingsView.swift` L96/L106；`TypoCorrectionBenchmarkView.swift` L183。叠在组件 `0.40` 上 |
| `AABC-04` | P3 | 主 App UI 测试（未来 Assignment） | `accept` | 仅 `UniverseKeyboardTests/AppActionButtonChromeTests.swift` 8 条 chrome 函数；无 `glassEffect` / 调用点 / 目视自动锁 |
| `AABC-05` | P3 | 主 App UI（系统玻璃边界） | `accept` | iOS 26 secondary 无 tint：`AppActionButton.swift` L187–191；深色抬升未由 Quality 目视 |
| `AABC-06` | P3 | 主 App UI（可选后续） | `accept` | destructive glass `Color.red`（L196）vs solid/label `UIColor.systemRed`（L42–53） |

Quality 片关闭不因上述残差阻塞：每条都有 disposition。**Assignment Close / Product Gate 仍被未授权的 Gate 阻塞**，不因本文件自动解除。

## 非声称

- 不是 Product Gate、Assignment `Closed`、Quality 对 **Device-attested 或 Quality 复验目视** 的 Pass。
- 不是 commit / push / PR / merge / TestFlight / App Store / Release。
- 不是 D-01 receipt、P-01 publication、hosted CI、冻结 payload。
- 不是 Architecture 复审（Assignment 为 N/A；本文件不给 Architecture 结论）。
- 不是 Keyboard Extension 外观结论。
- 不是「视觉上我觉得可以通过」= Quality 无条件 Pass。
- 不是 Executor 测试计数的复用；本审查已独立重跑，仍不是 hosted CI。
- 本审查未消耗 AUTH-QUALITY 记录（禁止改 AUTH consumption）。

## 建议的下一步（Human）

1. **Product Gate（另授权）：** 若产品接受 AABC-01（无 Device-attested 载荷）与 AABC-03（三处额外 disabled opacity）为本片发布前残差，可对 **主 App 操作按钮对比度** 做 Product Gate；本文件 **不** 代替该 Gate。Gate 前建议产品再确认：浅/深 primary、深色 secondary 玻璃是否仍从 grouped 底抬起、destructive 红、disabled 淡化是否仍不像「可点击发灰」、Reduce Transparency 实心 fallback。
2. `AABC-02`：commit 须新授权，且只切按钮切片 + 必要文档；commit 后本审查 **不能** 自动钉新 SHA。
3. 可选后续（不要混进本片）：去掉调用点额外 `.opacity`；为 `glassEffect` / Reduce Transparency 环境补测试；统一 `Color.red` / `systemRed`。

下一步默认交 **Product Lead（Human Product Gate）**，不是本 lane 继续改 Swift。
