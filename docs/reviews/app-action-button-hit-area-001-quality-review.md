# APP-ACTION-BUTTON-HIT-AREA-001 独立质量、性能与发布复审

**复审日期：** 2026-09-28（Asia/Shanghai）
**复审 lane：** KOS Quality, Performance & Release（`APP-ACTION-BUTTON-HIT-AREA-001-QUALITY-001`，Round 1）
**复审范围：** Assignment [`APP-ACTION-BUTTON-HIT-AREA-001`](../assignments/app-action-button-hit-area-001.md) 主 App **共享内容操作按钮整块可见胶囊命中**（`AppActionButton` / `AppActionButtonChrome.hitFillShape`）。不改对比度、Liquid Glass、按钮语义、Keyboard Extension chrome。
**工作树：** `/private/tmp/universe-keyboard-app-action-button-hit-area-001`，分支 `grok/app-action-button-hit-area-001`（tracking `origin/main`）
**Git 基线：** `HEAD` `b92a59b91b15073f457cbb7cd856f015117f4ac7`，与 `origin/main` 相同。本审查独立 `git rev-parse` / `git status` 核实，不是 Executor 口述。
**原始实现身份：** **无冻结 SHA。** 本结论钉在审查时的 **脏工作树** 切片文件 SHA-256，不是 commit / payload manifest。
**授权：** [`AUTH-APP-ACTION-BUTTON-HIT-AREA-001-QUALITY`](../authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-QUALITY.md) — 仅独立 Quality；不授权 Product Gate / commit / push / 改 Swift。本 lane **未** 回写 AUTH consumption。冻结 Assignment 仍写 Quality Not authorized，那是 Quality 前快照；本 AUTH 才是本 lane 授权。
**Decision：** [`PD-APP-ACTION-BUTTON-HIT-AREA-001`](../product-decisions/APP-ACTION-BUTTON-HIT-AREA-001-authorization.md)（Human 锁定整块可见胶囊可点，`2026-09-28`）
**Packet：** [`app-action-button-hit-area-001-quality-review-packet.md`](app-action-button-hit-area-001-quality-review-packet.md)。本审查独立复现 Packet digest：将 Packet digest 行替换为 64 个 ASCII `0` 后对全文 UTF-8 做 SHA-256，得 `ff793f8f84d355f453e3e93f5f8970770d5a97432dab516ea95ebd2f6944b2f0`，与冻结值一致。身份表九份文件独立 `shasum -a 256` 均与 packet 一致，故继续评 claims。

本 lane **只写本文件与 usage 证据**。未改产品 Swift、测试、packet、`CHANGELOG`、`ACTIVE_WORK`、`ENGINEERING_DASHBOARD`、Assignment Current Status、AUTH consumption。Architecture Reviewer 按 Assignment 为 **Not Applicable**；本文件 **不** 给出 Architecture 结论。

脏树中与本片同批的 Assignment / PD / AUTH / `CHANGELOG` / `ACTIVE_WORK` / `ENGINEERING_DASHBOARD` / `PROJECT_CONTEXT` 镜像 **不** 升格为本片命中合同证据。Executor 聊天中的「TEST SUCCEEDED / 407 / 10 / 15」记为 Executor-recorded，**不** 构成本裁决；本审查已独立重跑同一 `xcodebuild`。

## 身份（审查时工作树）

| Boundary | 本审查实测 |
|---|---|
| `HEAD` | `b92a59b91b15073f457cbb7cd856f015117f4ac7` = `origin/main` |
| 分支 | `grok/app-action-button-hit-area-001`，相对 `origin/main` 无已提交超前 commit |
| 脏树 | 已修改：`Universe Keyboard/Views/Components/AppActionButton.swift`、`UniverseKeyboardTests/AppActionButtonChromeTests.swift`、`docs/UI_STYLE_GUIDE.md`、`CHANGELOG.md`、`docs/ACTIVE_WORK.md`、`docs/ENGINEERING_DASHBOARD.md`、`docs/PROJECT_CONTEXT.md`。已暂存未提交：Assignment / PD / `AUTH-…-001` / `AUTH-…-IMPLEMENT`。未跟踪：`AUTH-…-QUALITY`、本 packet |
| Keyboard Extension | `git diff -- Keyboard/` **空**；`Keyboard/` 无 `AppActionButton` |
| Packet digest（独立复现） | `ff793f8f84d355f453e3e93f5f8970770d5a97432dab516ea95ebd2f6944b2f0` |
| 切片文件 SHA-256（工作区字节，非 git object） | 见下表 |

| Path | SHA-256（本审查 `shasum -a 256`） |
|---|---|
| `Universe Keyboard/Views/Components/AppActionButton.swift` | `1da8b39cc8f5198f2cd73606e5683c674bed1f11fb86ec711682494159738485` |
| `UniverseKeyboardTests/AppActionButtonChromeTests.swift` | `95e90b3e810ee27138e500530c427b9ce6baac38cff4e2d88d93d2a411dbfff6` |
| `docs/UI_STYLE_GUIDE.md` | `b6a2a8f805291720f4d71365348bbdae04f66ffed240ad23bae8ccb98143331a` |
| `docs/assignments/app-action-button-hit-area-001.md` | `a0b2682db5015a12660a50fd1121cb2ba7208af861639ae7252f7104c580bc62` |
| `docs/product-decisions/APP-ACTION-BUTTON-HIT-AREA-001-authorization.md` | `a1863f7ba39d51436cd250010442e2d41b8203bcd41323214605a6cbe1a26aac` |
| `docs/authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001.md` | `bc3fe74cfeadc375b656df88666ac922a21a3467a9e59bb27a6816cf14ef8aa5` |
| `docs/authorizations/AUTH-APP-ACTION-BUTTON-HIT-AREA-001-IMPLEMENT.md` | `6de92ff7bf79ca1fcd7909def735a4138cdf93c5f8a27c9dbf74cb09e41c95dc` |
| `CHANGELOG.md` | `1dd52e8050deb59c280a9983489d872dfff4de8dfc2d233831098acc46a52435` |
| `docs/PROJECT_CONTEXT.md` | `e122d95a86227f6a75eb4a8879dffcc5b26bdd74db808b7df1dd05e2091df525` |

之后若这些文件再改、或首次 commit，本文件 **不能** 自动跟随新 SHA。

## Verdict

**Pass with conditions。** 无开放 P0/P1。相对 `PD-APP-ACTION-BUTTON-HIT-AREA-001`，工作区源码把主 App 内容操作按钮的命中形状收到共享 `AppActionButtonChrome.hitFillShape`（`cornerRadius` 16、`.continuous`）；`Button` 与 `ShareLink` 变体在 padded surface 与外层控件上均应用该形状，label 在扩展 `frame` 之后使用 `.contentShape(Rectangle())`。相对 `HEAD` 的 Swift diff **只** 增加 `hitFillShape` 与三处 `contentShape`，未改 contrast token、`glassEffect`、disabled opacity、prominence 或调用点语义。全仓库 `*.swift` **没有** `.borderedProminent`。`Keyboard/` 无 `AppActionButton` 且本片未改 Extension chrome。系统 Alert / Toolbar / compact Form 文本按钮保持系统命中。命名的 `.plain` 列表/芯片控件 **不在 Assignment 范围**，记为 `accept` 残差，**不是** 本切片 Blocker；本审查未发现范围内 `AppActionButton` 仍只命中字形。

本结论 **不** 关闭 Assignment，**不** 授权 Product Gate / commit / merge / TestFlight / Release，**不是** Device-attested。

| 严重级别 | 数量 |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 2（均已 disposition，见残差表） |
| P3 | 3（均已 disposition，见残差表） |

### 条件

1. 残差表 disposition 保持有效；Quality 片关闭不要求先把范围外 `.plain` 列表/芯片收进 `AppActionButton`，也不要求先补 Device-attested 点按。
2. 结论只对审查时的按钮相关工作区文件有效。之后若这些文件再改、或首次 commit，本文件 **不能** 自动跟随新 SHA。
3. 不得把本文件当成 Product Gate、commit 许可或 TestFlight 许可。
4. 本 lane **没有** 在 Simulator / 真机上点按空白玻璃 vs 标题做目视复验。

## Packet claims

| # | Claim | 本审查结果 |
|---|---|---|
| 1 | Shared hit owner：`hitFillShape` 为唯一命中形状 owner；action 与 ShareLink 均应用；调用点无第二命中路径 | **Pass** |
| 2 | Full visible capsule：label `Rectangle()` 在扩展 frame 之后；padded surface 与外层 Button/ShareLink 用 `hitFillShape` | **Pass** |
| 3 | Shape follows chrome：半径 16、`.continuous`；视觉尺寸 / prominence / contrast / Liquid Glass / disabled 相对 CONTRAST-001 未改 | **Pass** |
| 4 | Call-site completeness：`Universe Keyboard/` 内 `AppActionButton(` 均走共享组件；无新 `.borderedProminent` 家族；Keyboard 未改 | **Pass** |
| 5 | Assignment-scope vs whole-app tappables：系统 chrome 保持；命名 `.plain` 列表/芯片 out of scope | **Pass with conditions**（`AABH-01` / `AABH-02` `accept`） |
| 6 | Tests：`testHitFillShapeMatchesTheVisibleCapsule`；独立 `swift-format lint --strict` 与指定 destination 的 App+Keyboard Debug test | **Pass**（独立复验，不复用 Executor 407/10/15） |
| 7 | Documentation：`UI_STYLE_GUIDE.md` 写明整块胶囊命中；`CHANGELOG.md` 记录落地行为；状态镜像不是产品证明 | **Pass** |
| 8 | Non-claims：不授予 Product Gate / Device-attested / commit / push / merge / TestFlight / Release；无冻结实现 SHA | **Pass**（本文件遵守） |

Complete coverage：八条均有显式结果。无 `Uncovered`。

## 已通过的证据

| 领域 | 当前证据 | 结论 |
|---|---|---|
| 共享 owner | [`AppActionButton.swift`](../../Universe%20Keyboard/Views/Components/AppActionButton.swift)：`hitFillShape` L23–25。action L133、ShareLink L140、surface L173 均用该形状。调用点无第二 `contentShape` 覆写（见调用点清单） | **通过**（源码） |
| 整块胶囊 | label：`.frame(maxWidth: .infinity, minHeight:)` 之后 `.contentShape(Rectangle())`（L152–153）。surface 在 horizontal 10 / vertical 7 padding 之后 `hitFillShape`。外层 Button/ShareLink 再套 `hitFillShape` | **通过**（源码）。真实 SwiftUI hit-test 未由 XCTest 锁住，见 `AABH-05` |
| 形状跟随 chrome | `RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)`，`cornerRadius` 仍为 16。`git diff` 相对 `HEAD` 仅 +10 行 Swift（注释 + `hitFillShape` + 三处 `contentShape`）。contrast / `glassEffect(.regular…interactive())` / `controlOpacity` 0.40 未改 | **通过** |
| 无手写 `.borderedProminent` | 全仓库 `*.swift` grep：`borderedProminent` **0 命中** | **通过** |
| Keyboard Extension | `Keyboard/` 无 `AppActionButton` / `contentShape`；本片 `git diff -- Keyboard/` 空 | **通过**（范围外且未改 chrome） |
| 指南 | [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) L166：Hit owner 为同一 chrome；整块可见胶囊（含 padding 与玻璃空白）可点；禁止 `.plain` 只命中标题字形 | **通过**（相对 PD 落地） |
| CHANGELOG | [`CHANGELOG.md`](../../CHANGELOG.md) `2026-09-28 — 主 App 操作按钮整块可点`：整块可见胶囊；16 pt 连续圆角；对比度 / Liquid Glass / 语义不变 | **通过**。`ACTIVE_WORK` / Dashboard / `PROJECT_CONTEXT` **不是** 产品证明 |
| 单元：hit 形状 | [`AppActionButtonChromeTests.swift`](../../UniverseKeyboardTests/AppActionButtonChromeTests.swift) `testHitFillShapeMatchesTheVisibleCapsule`：corner 宽高 = `cornerRadius`，style `.continuous` | **通过**（测试源码 + 本审查重跑）。不覆盖真实 hit-testing / 调用点 |
| Swift 格式 | 本审查对两个变更 `.swift` 执行 `xcrun swift-format lint --strict --configuration .swift-format`，exit 0 | **通过**（本审查） |
| Simulator App+Keyboard | 本审查独立重跑（见下）。**TEST SUCCEEDED**：`UniverseKeyboardTests` 407 执行 / 10 skipped / 0 failed（含 `AppActionButtonChromeTests` 9）；`KeyboardTests` 15 / 0 failed | **独立复验通过。** 不是 hosted CI，不是 Device-attested |

### 本审查独立重跑的机器证据

按 [`AI_WORKFLOW.md`](../AI_WORKFLOW.md) 证据复用条件：未提交快照、内容相对 `HEAD` 已变、独立 Quality 不得把 Executor 计数当事实。本审查 **没有** 复用 Executor-recorded `407/10/15`，而是重跑同一 scheme / 配置 / destination。

```text
xcrun swift-format lint --strict --configuration .swift-format \
  "Universe Keyboard/Views/Components/AppActionButton.swift" \
  UniverseKeyboardTests/AppActionButtonChromeTests.swift
# exit 0

xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" -configuration Debug \
  -destination 'platform=iOS Simulator,id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2' \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 \
  SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
```

| 项 | 本审查记录 |
|---|---|
| Destination | `iPhone 17 Pro` (`8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`)；审查开始时 simctl 列为 iOS 26.0 **Shutdown**，由本次 `xcodebuild test` 启动。SDK `iPhoneSimulator27.0` |
| 结果 | `** TEST SUCCEEDED **`（exit 0） |
| `UniverseKeyboardTests` | Executed **407**，skipped **10**，failed **0** |
| `AppActionButtonChromeTests` | 9 条均 passed（含 `testHitFillShapeMatchesTheVisibleCapsule`）；suite passed `2026-09-28 19:18:30.390` |
| `KeyboardTests` | Executed **15**，failed **0** |
| xcresult | `/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-gbpxpyvspqukjxflidhyejvbxuvf/Logs/Test/Test-Universe Keyboard-2026.09.28_19-16-23-+0800.xcresult` |
| 未跑 | KeyboardCore-only `swift test`、`RimeBridgeTests`、Release `build`、hosted CI、Simulator/真机目视点按 |

Executor 记录的 407 / 10 skipped / KeyboardTests 15 与本次数值一致，但本裁决只引用 **本审查这次** 的命令与 xcresult。

## 调用点清单（本审查独立 grep）

全仓库 `AppActionButton(`：**37** 处，11 个 Swift 文件，全部在 `Universe Keyboard/`。`ShareLink(` 仅 `AppActionButton.swift` 一处（共享变体）。调用点 **没有** 再叠 `contentShape` / 第二 hit path。布局 `.frame` / `.padding` / `.accessibilityHint` / `.disabled` 不算命中覆写。

| 路径 | 入口 | 额外命中修饰 |
|---|---|---|
| `Views/Settings/RimeSyncSettingsView.swift` | 「立即同步」「重新选择同步文件夹」「保存 WebDAV 设置」「保存恢复码」`shareText`、「使用已有恢复码」 | 无第二 `contentShape` |
| `Views/Settings/RimeDeploymentContent.swift` | 部署 / 取消 / 重置 | 无 |
| `Views/Settings/RimeUserDictionarySettingsView.swift` | 备份 / 恢复 / 清空学习记录 | 无 |
| `Views/Settings/RimeSettingsView.swift` | 高级输入恢复动作 L425 | 同文件 L131–133 的「方案信息」行是 `.plain` 列表行，**不是** `AppActionButton`（`AABH-02`） |
| `Views/Settings/SchemaDownloadContentViews.swift` | 查看许可并下载 / 重试 / 检查更新 / 重新下载 / 许可证 / 卸载 | 无 |
| `Views/Settings/TypoCorrectionBenchmarkView.swift` | 重置实验学习记录 | 无 |
| `Views/Diagnostics/ReleaseEvidenceView.swift` | 开始记录会话 / 复制为外部候选 / 分享结构化证据 `shareText` | 历史会话行 L212 `.plain`，范围外（`AABH-01`） |
| `Views/License/LicenseView.swift` | 接受 | 无 |
| `Views/Guide/ActivationWelcomeView.swift` | 开始 / 稍后 | 无 |
| `Views/Guide/ActivationResourcePreparePanel.swift` | 下载/许可证、激活部署、重试 | 方案选择行 L179 `.plain`，范围外（`AABH-01`） |
| `Views/Guide/GuideTab.swift` | 重走/打开设置/确认/推迟/继续 等 8 处 | 清单展开行 L305 `.plain`，范围外（`AABH-02`） |

未发现范围内 `AppActionButton` 仍只命中字形。未把范围扩到第二按钮家族。

## Findings

无 P0/P1。下列不是「共享胶囊仍只点标题」，而是范围边界、脏树身份或证据分级。

### P2-01：无冻结实现 SHA；切片文件与状态镜像并存于脏树

`AppActionButton.swift` 与 chrome 测试已修改未提交。同树还有 Assignment / PD / AUTH 与 `CHANGELOG` / Dashboard / Active Work / `PROJECT_CONTEXT` 镜像。P-01 对本片 Not applicable。

Disposition：`accept`（见 `AABH-03`）。任何 commit 必须把按钮切片从无关状态镜像中按授权切开，并在新 SHA 上决定是否重验。

### P2-02：本 Quality lane 未点按空白胶囊

Packet / AUTH 要求独立机器测试，不要求本 lane 做 Device-attested。本审查未在 Simulator 或真机上点按玻璃空白 vs 标题。源码合同与 chrome 测试覆盖形状 owner，因此 **不** 因缺目视点按自动 Fail。Product Gate / Release **不得** 声称「Quality 已在设备上证明整块可点」。

Disposition：`accept`（见 `AABH-04`）。

### P3-01：packet 点名的 `.plain` 列表/芯片不在 Assignment 内

下列控件使用 `.buttonStyle(.plain)`，**不是** `AppActionButton`：

- `MetricCell`（有 `action` 时，L22）
- `SchemaPickerRow` L47
- `DiagnosticsDayPicker` L58
- `KeyboardLayoutSettingsView.schemeRow` L210
- Guide / prepare 方案行：`ActivationResourcePreparePanel` L179
- `ReleaseEvidenceView` 历史会话行 L212

按 packet：记残差 `accept`，不扩 scope，不构成本片 Blocker。

Disposition：`accept`（见 `AABH-01`）。

### P3-02：其它主 App `.plain` 同样范围外

packet「including」未穷尽。本审查另见：`KeyboardLayoutSettingsView` 布局缩略行 L180（已有 `contentShape(Rectangle())`，仍非 `AppActionButton`）、`GuideTab` 清单展开 L305、`RimeSettingsView` 方案信息行 L133、`DiagnosticsLogContentView` 日志行 L102、`AppearanceSettingsView`、`FeedbackLevelSelectionView`、`SearchTab`。系统 Alert / Toolbar / compact Form 文本按钮保持系统 chrome。均 **out of scope**。

Disposition：`accept`（见 `AABH-02`）。

### P3-03：自动测试只锁 chrome 形状，不锁真实 hit-testing

`testHitFillShapeMatchesTheVisibleCapsule` 不断言 SwiftUI 实际把 `contentShape` 挂上、也不对 37 处调用点做 hit-test。调用点由本审查 grep 补齐。不要求本片为 Quality 关闭去补 UI 测试。

Disposition：`accept`（见 `AABH-05`）。

## Architecture N/A

本审查 **不争议** Architecture `Not Applicable`，也 **不** 另给 Architecture 结论。实现仍是既有 `AppActionButton` + `glassEffect(.regular.interactive())`（Reduce Transparency / iOS 18 走实心 fallback），仅增加与可见胶囊对齐的 `contentShape`。未见第二套内容操作按钮家族，未见丢掉 Liquid Glass，未见 Keyboard Extension chrome 被拉进范围。

## 明确跳过的检查

- 未跑 `swift test --package-path Packages/KeyboardCore`、`RimeBridgeTests`、Release `build`（本片未改那些 target；Assignment 实施交接也未要求 Quality 补跑）。
- 未做 hosted CI（无冻结 SHA）。
- 本 Quality lane **没有** 在 Simulator 或真机上点按浅/深 × primary/secondary/destructive × 空白玻璃 vs 标题。
- 未审无关 Active Work 行（TYPO / Release 等）的质量。
- 未操作 AUTH consumption、Product Gate、commit、push。

本地只读 + 独立测试：

```text
git rev-parse HEAD   # b92a59b91b15073f457cbb7cd856f015117f4ac7
git status --short   # 脏树；按钮切片 + 治理镜像并存
# packet digest 独立复现；身份表九文件独立 shasum
# 阅读 Assignment / PD / AUTH-IMPLEMENT / AUTH-QUALITY / UI_STYLE_GUIDE / playbooks
# grep AppActionButton( / borderedProminent / contentShape / buttonStyle(.plain) / Keyboard/
xcrun swift-format lint --strict --configuration .swift-format \
  "Universe Keyboard/Views/Components/AppActionButton.swift" \
  UniverseKeyboardTests/AppActionButtonChromeTests.swift
# 上表 xcodebuild（独立重跑，非 Executor 复用）
```

## 残差账本

| Residual ID | 严重级别 | Owner | Disposition | Pointer |
|---|---|---|---|---|
| `AABH-01` | P3 | Human Product Lead（scope；非本片） | `accept` | packet 点名的 `.plain` 列表/芯片：`MetricCell.swift` L22；`SchemaPickerRow.swift` L47；`DiagnosticsDayPicker.swift` L58；`KeyboardLayoutSettingsView.swift` `schemeRow` L210；`ActivationResourcePreparePanel.swift` L179；`ReleaseEvidenceView.swift` L212 |
| `AABH-02` | P3 | Human Product Lead（scope；非本片） | `accept` | 其它 out-of-scope `.plain`：`KeyboardLayoutSettingsView.swift` L180；`GuideTab.swift` L305；`RimeSettingsView.swift` L133；`DiagnosticsLogContentView.swift` L102；`AppearanceSettingsView.swift`；`FeedbackLevelSelectionView.swift`；`SearchTab.swift`。系统 Alert/Toolbar/Form compact 保持系统 chrome |
| `AABH-03` | P2 | 发布 / 提交切片 | `accept` | 无冻结实现 SHA。`HEAD` `b92a59b91b…` + 脏树；`AppActionButton.swift` SHA-256 `1da8b39c…` |
| `AABH-04` | P2 | Human Product Lead（Product Gate / 可选目视） | `accept` | 本 Quality lane 未点按空白胶囊。无 UUID/dSYM/截图。不得升格为 Device-attested |
| `AABH-05` | P3 | 主 App UI 测试（未来 Assignment） | `accept` | 仅 chrome 形状断言；无 SwiftUI hit-test / 调用点自动锁。`UniverseKeyboardTests/AppActionButtonChromeTests.swift` L73–78 |

Quality 片关闭不因上述残差阻塞：每条都有 disposition。**Assignment Close / Product Gate 仍被未授权的 Gate 阻塞**，不因本文件自动解除。

## 非声称

- 不是 Product Gate、Assignment `Closed`、Quality 对 **Device-attested 或 Quality 复验目视点按** 的 Pass。
- 不是 commit / push / PR / merge / TestFlight / App Store / Release。
- 不是 D-01 receipt、P-01 publication、hosted CI、冻结 payload。
- 不是 Architecture 复审（Assignment 为 N/A；本文件不给 Architecture 结论）。
- 不是 Keyboard Extension 外观或命中结论。
- 不是「主 App 中所有可点控件」已整块可点；合同只覆盖共享 `AppActionButton`。
- 不是 Executor 测试计数的复用；本审查已独立重跑，仍不是 hosted CI。
- 本审查未消耗 AUTH-QUALITY 记录（禁止改 AUTH consumption）。

## 建议的下一步（Human）

1. **Product Gate（另授权）：** 若产品接受 `AABH-01`/`AABH-02`（范围外 `.plain` 不进本片）与 `AABH-04`（无 Device-attested 点按）为本片发布前残差，可对 **主 App 共享内容操作按钮整块命中** 做 Product Gate；本文件 **不** 代替该 Gate。Gate 前可选产品再点：空白玻璃、图标两侧、上下内边距。
2. `AABH-03`：commit 须新授权，且只切按钮切片 + 必要文档；commit 后本审查 **不能** 自动钉新 SHA。
3. 可选后续（不要混进本片）：范围外列表/芯片命中；为真实 hit-testing 补 UI 测试。

下一步默认交 **Product Lead（Human Product Gate）**，不是本 lane 继续改 Swift。
