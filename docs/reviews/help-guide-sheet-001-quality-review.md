# HELP-GUIDE-SHEET-001 独立质量、性能与发布复审

**复审日期：** 2026-09-14（Asia/Shanghai）
**复审 lane：** KOS Quality, Performance & Release
**复审范围：** Assignment [`HELP-GUIDE-SHEET-001`](../assignments/help-guide-sheet-001.md) 主 App **展示包装**（Settings 工具栏「？」、无帮助 Tab、J0–J5 单 sheet、J4 页内试用、F1 标记与下次进程自动弹出、F2 进程内「稍后再说」、已完成说明书重看 / 「从第一步开始」不清进度、测试与 Human 观察）
**工作树：** `/Users/doubleshy0n/Dev/Universe Keyboard`，分支 `main`
**Git 基线：** `HEAD` `3139f8d3bdb6be6622504ea731988f42681896fb`（`3139f8d docs: record Build 55 physical Product Gate`）
**实现身份：** **无冻结 SHA。** 本结论钉在审查时的 **脏工作树** 上的引导相关文件，不是 commit / payload manifest。
**授权：** [`AUTH-HELP-GUIDE-SHEET-001-QUALITY`](../authorizations/AUTH-HELP-GUIDE-SHEET-001-QUALITY.md) — 仅独立 Quality；不授权 Product Gate / commit / push / 改 Swift
**Decision：** [`PD-HELP-GUIDE-SHEET-001`](../product-decisions/HELP-GUIDE-SHEET-001-authorization.md)；展示 SoT 修正 [`PD-HELP-TIPKIT-001`](../product-decisions/HELP-TIPKIT-001-authorization.md) `2026-09-14`；J4 载体 [`PD-APP-SEARCH-001`](../product-decisions/APP-SEARCH-001-authorization.md) `2026-09-14`

本 lane **只写本文件**。未改产品 Swift、测试、`CHANGELOG`、`ACTIVE_WORK`、Assignment Current Status、ReleaseEvidence / Build 55 文档。Architecture Reviewer 按 Assignment 为 **Not Applicable**（未改 App Group 所有权、FA 观察模型、隐私声称或激活成功定义）；本文件 **不** 给出 Architecture 结论。

脏树中与本片无关的 `DiagnosticsSettingsView`、ADR 0035、ReleaseEvidence、Build 55 证据 **不纳入** 本裁决。引导 Swift 未混入这些路径。

## Verdict

**Pass with conditions。** 无开放 P0/P1。相对 `PD-HELP-GUIDE-SHEET-001` / 修正后的 TipKit 与 Search 决策，工作区源码把帮助 Tab 换成设置「？」+ 单 sheet；J4 试用框在 sheet 内；F1 标记与「下次进程自动弹出」在投影与 `ContentView` 控制流上对齐；F2 「稍后再说」是进程内 `@State`，不是完成、也不是抑制下次启动；已完成说明书的「从第一步开始」是 `replayStep` 展示游标，不写 affirmation。Human「完全满足预期」只覆盖已完成说明书路径，**不是** Quality Pass，也 **不是** Product Gate。

本结论 **不** 关闭 Assignment，**不** 授权 Product Gate / commit / merge / TestFlight / Release。

| 严重级别 | 数量 |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 2（均已 disposition，见残差表） |
| P3 | 3（均已 disposition，见残差表） |

### 条件

1. 残差表 disposition 保持有效；Quality 片关闭不要求先补 F1/F2 真机（Assignment 已把该路径标为未证明 / Human Dependency）。
2. 结论只对审查时的引导相关工作区文件有效。之后若这些文件再改、或首次 commit，本文件 **不能** 自动跟随新 SHA。
3. 不得把本文件当成 Product Gate、commit 许可或 TestFlight 许可。

## 已通过的证据

| 领域 | 当前证据 | 结论 |
|---|---|---|
| 无帮助 Tab；Tab 序 首页 \| 设置 \| 搜索 | `ContentView.swift` `MainTab` 仅 `home` / `settings` / `search`（L14–18）；`TabView` 三段且搜索始终最后（L99–127）。工作区无 `shouldShowHelpTab` / `MainTab.help` / `Label("帮助"` 产品入口 | **通过**（源码）。Human 从设置「？」打开指南见观察记录，不是独立 UI 测试 |
| F3 单入口：列表行删除，工具栏「？」 | `SettingsTab.swift` toolbar `questionmark.circle`（L52–67）；`git diff` 删除「使用帮助与启用指南」`SettingsNavigationLink`。无障碍名 `ActivationCopy.settingsHelpEntryTitle`（「使用帮助与启用指南」） | **通过**（源码）。搜索目录仍可发现同一 sheet，见 P3-01 |
| 单 sheet；J0 为第一页 | `ActivationGuideSheet.swift`（新建）：`showsWelcome` 时 `ActivationWelcomeView`，否则 `GuideTab`；同一 `.sheet`（`ContentView.swift` L132–147）。`showsWelcome = !activationWelcomeSeen && shouldOfferGuideSession`。开始设置只写 `activationWelcomeSeen`，不切 Tab | **通过**（源码） |
| J4 页内试用；搜索不再是主路径 | `GuideTab.swift` `firstInputActions` 内 `TextField`（L338–355）；`ActivationCopy.nextActionTitle(.firstInput)` / `firstInputTryCTA` 改为「本页 / 在此」。`SearchTab` 去掉 `focusRequestToken`；文案指向设置问号。搜索仍有设置检索 + 可选试用 | **通过**（源码 + 文案测试 `testFirstInputCopyAllowsAnyContentInSheet`） |
| F1 标记（非仅颜色） | `shouldMarkHelpEntryIncomplete`（`ActivationChecklistState.swift` L71–79）在 `nextStep != nil` 或共享数据不可用 / J3 失败部署等恢复条件为 true。`SettingsTab` 红色 `foregroundStyle` **且** `accessibilityValue` 「启用未完成」/「可重看启用步骤」（L58–65）。单元：`testHelpMarkerVisibleWhileActivationIncomplete`、`HiddenWhenFullyActivatedAndHealthy`、`ReturnsWhenSharedDataUnavailable`、`ReturnsWhenDeploymentFailed` | **通过**（投影 + 无障碍绑定）。红色「？」真机观感 **未** Human 证明 |
| F1 下次进程自动弹出；同进程 foreground 不因「稍后再说」再弹 | `presentActivationGuideIfNeeded` 仅 `body` `.onAppear`（`ContentView.swift` L148–150、L322–332）；`scenePhase` `.active` **不** 调自动弹出（L199–205）。`deferredGuideThisProcess` 为 `@State`（L42），「稍后再说」置位并关 sheet（L339–342）。用户再点「？」走 `presentActivationGuide()`（L335–337），不读 defer 闩 | **源码对齐 PD。** 未完成路径 / 杀进程恢复 **无** 真机或 Simulator UI 证明（P2-01） |
| F2 「稍后再说」进程局部 | 未完成：`interactiveDismissDisabled(!isReRead)`、隐藏拖条（`ActivationGuideSheet.swift` L29–31）；Welcome `onSkip` 与 Guide 工具栏均 `onDefer`。Skip **不** 写 `activationWelcomeSeen`（对比旧 Welcome `onDismiss` 一律标 seen）。不写 checklist affirmation | **源码对齐 PD。** 同进程 vs 下次启动 **无** Human 证明（P2-01） |
| 已完成重看；「从第一步开始」不清进度 | `isReRead = !shouldOfferGuideSession`；完成态 `onClose`「完成」、可滑动关闭。`replayStep` / `expandedReReadStep` 仅为 `@State`。`isReplayWalkthrough` 时 `affirmButtons` 走 `replayAdvanceButton`，不写 `keyboardAddedAffirmed` 等。`startReplayFromFirstStep` 只设游标为 `.addKeyboard`（`GuideTab.swift` L497–502）。Human：[completed-manual 观察](../evidence/help-guide-sheet-001-human-completed-manual-2026-09-14.md) | **通过**（源码 + Human-attested 已完成路径）。不是 Device-attested，不是 Product Gate |
| 进度真理仍是 `nextStep` | `git diff` 未改 `ActivationChecklistState.nextStep` / FA / 资源就绪规则（L55–63、L86–104）。`featuredStep = replayStep ?? checklist.nextStep`；replay 仅在 `isFullyActivated` 横幅出现 | **通过**。未发明第二份完成清单 |
| 未发明 live Extension FA 标志 | 启用 affirmation 仍在 standard `UserDefaults`；`rime_deployed` / active schema 仍走既有 App Group。`refreshSharedContainerObservation` 注释与行为：主 App 容器可达 ≠ Extension FA（`GuideTab.swift` L525–542） | **通过**（源码审计） |
| C1–C9 / FA 可选 | `ActivationCopy` 的 C1–C5/C7–C9 字符串本 diff 未改写成功定义；J4 仅改载体文案。`testCanonicalCopyBoundariesRemainNonEmpty` 仍断言「必须」不出现在降级打字文案 | **通过**（本片未改语义 SoT） |
| Session-offer 单元测试 | `shouldOfferGuideSession` 与 marker 同投影（L81–82）；上述 Help marker 用例同时断言 offer。文案：`testHelpSettingsEntryCopyDoesNotImplyProgressReset`（「从第一步开始」/「不会清除」） | **通过**（单元）。**无** 自动测试覆盖 `ContentView` 进程闩 / sheet dismiss |
| Simulator App+Keyboard | Assignment Handoff：`xcodebuild` scheme `Universe Keyboard` Debug test，destination `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0`（`name=iPhone 17 Pro` unmatched），`CODE_SIGNING_ALLOWED=NO` `SWIFT_VERSION=6.0` `SWIFT_STRICT_CONCURRENCY=complete` `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES` — **TEST SUCCEEDED**（UniverseKeyboardTests 369 / 9 skipped；KeyboardTests 11）。未跑 KeyboardCore-only、RimeBridgeTests、Debug/Release `build` | **机器证据引用 Assignment，本审查未重跑。** 未见矛盾该声称的源码理由 |
| 展示文档 | [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md) Surfaces / F1 / 重看（约 L163–189）与 PD 一致：无帮助 Tab、sheet、「？」、稍后再说进程局部、从第一步开始不清进度 | **正文通过。** 文首 Assignment 状态行仍偏旧（P3-02） |
| TipKit（可选） | Help Tab 已删；`GuideTab` featured step `.activationPopoverTip`；J4 tip 文案跟 `nextActionTitle`（本页）。Settings RIME 行与 Home 键盘卡仍按既有 TipKit 规则 | **范围内可接受**（PD 允许 TipKit 为后续包装；本片已把原帮助面绑到 sheet） |
| 隐私 / 扩展 | 无 Extension 引导 UI；无新网络/账号；无把按键或路径打进新 Logger 的本片 diff | **源码审计通过** |

## Findings

无 P0/P1。下列不是「实现相对 PD 写错」，而是证据或文档残差。

### P2-01：未完成路径 F1 自动弹出与 F2「稍后再说」无真机 / 杀进程证明

Human 观察只覆盖 **已完成** 说明书 +「从第一步开始」（见证据 Non-claims）。Assignment Exit Criteria 已把 fresh-install / incomplete F1 与 F2 同进程 vs 下次启动标为未勾选。

源码控制流与 PD 一致（见上表），因此 **不** 因缺真机自动 Blocked。发布或 Product Gate 不得声称「已在真机证明下次启动会再弹出 / 稍后再说只挡本次进程」。

Disposition：`accept`（本 Quality 片；见 `HGS-01`）。

### P2-02：进程会话与 replay 无副作用缺少自动测试

`deferredGuideThisProcess`、`presentActivationGuideIfNeeded` 的 onAppear-only、Welcome skip 不写 `activation_welcome_seen`、`replayStep` 不写 affirmation，都在 SwiftUI 视图里。`ActivationChecklistStateTests` 覆盖纯投影与文案，**不能** 抓住「稍后再说被误持久化」或「从第一步开始误写 checklist」。

本审查用源码核对补了这条；不要求本片为 Quality 关闭去补 UI 测试。

Disposition：`accept`（见 `HGS-02`）。若后续要回归锁，另开 Assignment，不要混进本片 commit。

### P3-01：设置搜索目录仍有「使用帮助与启用指南」

`SettingsSearchCatalog.swift` L160–166 + `SearchTab` `destination == .activationHelp` 打开 **同一** sheet。F3 删除的是 Settings **列表行**，永久入口是工具栏「？」。`PD-APP-SEARCH-001` 仍允许设置项检索。这不是第二份 Settings 列表入口。

Disposition：`accept`（见 `HGS-03`）。

### P3-02：`ONBOARDING_ACTIVATION.md` / `PD-HELP-TIPKIT-001` 文首状态行未跟上实施

正文展示规则已改为 sheet /「？」。文首仍写 Assignment `Ready`、Swift 未授权（`ONBOARDING_ACTIVATION.md` L8；TipKit PD L7）。与 Assignment「实施已交付」及本审查所见工作区不一致，但不与 C1–C9 冲突。

Disposition：`accept`（见 `HGS-04`）。文档卫生可由后续 docs 回合修正；本 Quality 不改那些文件。

### P3-03：无冻结实现 SHA；工作树脏

引导实现与 Assignment / AUTH / Human 观察均未提交。同树还有 ReleaseEvidence、Build 55、诊断等无关改动。P-01 对本片 Not applicable。

Disposition：`accept`（见 `HGS-05`）。任何 commit 必须把引导文件从无关脏改动中切开，并在新 SHA 上决定是否重验。

## F1 / F2 控制流（源码核对）

| 事件 | 预期（PD） | 实现 |
|---|---|---|
| 冷启动且 `shouldOfferGuideSession` | 自动呈现 sheet | `onAppear` → `presentActivationGuideIfNeeded`（XCTest 环境跳过） |
| 「稍后再说」 | 只关本次进程 sheet；不完成步骤 | `@State deferredGuideThisProcess = true`；`showActivationGuide = false` |
| 同进程 `scenePhase` 回前台 | 不再自动弹 | `.active` 只刷新通知/同步，不调用 present |
| 同进程再点「？」 | 立即能打开 | `presentActivationGuide()` 不读 defer 闩 |
| 杀进程后再开 | 再自动弹（offer 仍真） | defer `@State` 丢失；`shouldOfferGuideSession` 由 checklist 派生 |
| Welcome「稍后再说」 | 不是激活成功 | 不写 `activationWelcomeSeen`；下次仍可走 J0 |
| 未完成误滑关 | 禁止 | `interactiveDismissDisabled(!isReRead)` |
| 已完成重看 | 可关；默认不清进度 | `isReRead` 时允许手势 +「完成」；replay 不写 storage |

`shouldOfferGuideSession` 与 `shouldMarkHelpEntryIncomplete` 同一投影，满足 F1「标记 **且** 下次进程自动弹出」。未把 step index 持久化为完成真理。

## Architecture N/A

本审查 **不争议** Architecture `Not Applicable`。`nextStep`、FA 四态、J2 暂缓顺序、J3 就绪定义、App Group 部署键、C1–C9 成功语义均未在本 diff 重写。主 App 仍不声称 live Extension Full Access。若未来把「稍后再说」写成持久抑制、或把 replay 写成重置进度，那才需要 Architecture 与新的 Product Decision。

## Human-attested 已完成说明书（诚实分级）

记录：[`help-guide-sheet-001-human-completed-manual-2026-09-14.md`](../evidence/help-guide-sheet-001-human-completed-manual-2026-09-14.md)。Human Product Owner：设置「？」→ 已完成说明书（启用指南、「完成」、「重新走一遍」、「清单步骤已确认完成」）→ 要求「从第一步开始」不清进度 → 安装工作区后再说「完全满足我的预期」。

**Grade：Human-attested / Product observation。** 本 Quality 未操作设备，无 UUID/SHA/payload。按 Human-operated evidence profile **不是** Device-attested，**不是** Quality-reverified 真机，**不是** Product Gate。足以支撑「完成态说明书路径被产品接受」的工程叙述；不足以关闭 F1/F2，也不足以单独构成 Quality Pass。

## 明确跳过的检查

本审查 **没有** 重跑 `xcodebuild` / `swift test` / KeyboardCore / RimeBridgeTests / Debug-Release `build`。未操作 Simulator 或真机。未做 hosted CI（无 SHA）。未审 ReleaseEvidence / Build 55 脏文件。

本地只读：

```text
git rev-parse HEAD   # 3139f8d3bdb6be6622504ea731988f42681896fb
git status --short   # 脏树；引导文件与无关文件并存
# 阅读 Assignment / PD / ONBOARDING / Human 观察 / 指定 Swift 与测试
```

Executor 自检与聊天记录不构成本裁决。

## 残差账本

| Residual ID | 严重级别 | Owner | Disposition | Pointer |
|---|---|---|---|---|
| `HGS-01` | P2 | Human Device Operator / Product Lead（未完成路径） | `accept` | F1 自动弹出与 F2 稍后再说未真机证明。源码：`ContentView.swift` L42、L148–150、L199–205、L322–342；`ActivationGuideSheet.swift` L29–31。Assignment Exit 未勾选行 |
| `HGS-02` | P2 | 主 App UI 测试（未来 Assignment） | `accept` | 无自动测试锁进程闩与 replay 无写。`ActivationChecklistStateTests.swift` 仅投影/文案；逻辑在 `GuideTab.swift` L396–518、`ContentView.swift` |
| `HGS-03` | P3 | 主 App 设置搜索 | `accept` | 搜索命中仍可打开 sheet：`SettingsSearchCatalog.swift` L160–166；`SearchTab.swift` L107–113。不是已删的 Settings 列表行 |
| `HGS-04` | P3 | 文档卫生（Executor / 后续 docs） | `accept` | `ONBOARDING_ACTIVATION.md` L8；`HELP-TIPKIT-001-authorization.md` L7 文首仍写未实施 |
| `HGS-05` | P3 | 发布 / 提交切片（尚未授权） | `accept` | 无冻结 SHA；脏树。本结论不绑定未来 commit |

Quality 片关闭不因上述残差阻塞：每条都有 disposition。

## 非声称

- 不是 Product Gate、Assignment `Closed`、Quality 对 **真机 F1/F2** 的 Pass。
- 不是 commit / push / PR / merge / TestFlight / App Store / Release。
- 不是 D-01 receipt、P-01 publication、hosted CI、冻结 payload。
- 不是 Architecture 复审。
- 不是「稍后再说」或 Welcome-seen 等于激活成功。
- 不是 live Extension Full Access 标志。
- 不是 Build 55 / ReleaseEvidence 质量结论。
- Human「完全满足预期」≠ Quality Pass。

## 建议的下一步（Human）

1. **Product Gate（另授权）：** 若产品接受 HGS-01（F1/F2 未真机）为发布前残差，可对 **本展示包装** 做 Product Gate；本文件 **不** 代替该 Gate。
2. **更多真机（可选，Gate 前或后由产品决定）：** 干净安装或未完成态：冷启动自动 sheet；「稍后再说」后同进程回前台不自动弹、问号仍可点；杀 App 后再开再弹；未完成「？」非仅颜色（VoiceOver「启用未完成」）。
3. **不要** 在本 Quality 结论上直接 commit：先切开无关脏树，另要 commit AUTH；提交后本审查需按新身份决定是否复验。

下一步默认交 **Product Lead（Human Product Gate）**，不是本 lane 继续改 Swift。
