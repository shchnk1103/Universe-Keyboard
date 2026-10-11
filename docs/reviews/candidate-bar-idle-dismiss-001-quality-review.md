# CANDIDATE-BAR-IDLE-DISMISS-001 独立质量、性能与发布复审

**复审日期：** 2026-09-28（Asia/Shanghai）
**复审 lane：** KOS Quality, Performance & Release（`CANDIDATE-BAR-IDLE-DISMISS-001-QUALITY-001`，Round 1）
**复审范围：** Assignment [`CANDIDATE-BAR-IDLE-DISMISS-001`](../assignments/candidate-bar-idle-dismiss-001.md) 候选栏右侧既有 56 pt 槽的双模控件：有可展开内容时 `chevron.down` 展开；空闲时 template `chevron.down.circle` 请求 `dismissKeyboard()`。含下滑仅 Expand mode、AX 随模式切换、KeyboardCore 仅分类、圆角宿主透白 **out of scope**。不含 Product Gate、commit / push、TestFlight、Release、Human Simulator 目视。
**工作树：** `/private/tmp/universe-keyboard-candidate-bar-idle-dismiss-001`，分支 `grok/candidate-bar-idle-dismiss-001`（tracking `origin/main`）
**Git 基线：** `HEAD` `fbb4eb3bbbc2926ff6e248db9dcdfdf6a331f821`，与 `origin/main` 相同。本审查独立 `git rev-parse` / `git status` 核实，不是 Executor 口述。
**原始实现身份：** **无冻结实现 commit SHA。** 本结论钉在审查时的 **脏工作树** 切片文件 SHA-256，不是 commit / payload manifest。
**授权：** [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-QUALITY`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-QUALITY.md) — 仅独立 Quality；不授权 Product Gate / commit / push / 改 Swift。本 lane **未** 回写 AUTH consumption。冻结 Assignment 仍写 Quality Not authorized，那是 Quality 前快照；本 AUTH 才是本 lane 授权。
**Decision：** [`PD-CANDIDATE-BAR-IDLE-DISMISS-001`](../product-decisions/CANDIDATE-BAR-IDLE-DISMISS-001-authorization.md)（Human 锁定双模图标、可展开内容含联想、下滑不关闭、AX、全布局复用既有槽，`2026-09-28`）
**Packet：** [`candidate-bar-idle-dismiss-001-quality-review-packet.md`](candidate-bar-idle-dismiss-001-quality-review-packet.md)。本审查独立复现 Packet digest：将 Packet digest 行替换为 64 个 ASCII `0` 后对全文 UTF-8 做 SHA-256，得 `5adecb81985d91de0022471e74702181975c332589cac149643285da69718c28`，与冻结值一致。身份表十三份文件独立 `shasum -a 256` 均与 packet 一致，故继续评 claims。

本 lane **只写本文件与 usage 证据**。未改产品 Swift、测试、packet、`CHANGELOG`、`ACTIVE_WORK`、`ENGINEERING_DASHBOARD`、Assignment Current Status、AUTH consumption。Architecture Reviewer 按 Assignment 为 **Not Applicable**；本文件 **不** 给出 Architecture 结论。

脏树中与本片同批的 Assignment / PD / AUTH / `CHANGELOG` / Dashboard / Active Work / `PROJECT_CONTEXT` 镜像 **不** 升格为本片命中合同证据。Executor 聊天中的「TEST SUCCEEDED / 410 / 16」记为 Executor-recorded，**不** 构成本裁决；本审查已独立重跑同一 `xcodebuild`（指定 iPhone 17，未打 iPhone 17 Pro）。

## 身份（审查时工作树）

| Boundary | 本审查实测 |
|---|---|
| `HEAD` | `fbb4eb3bbbc2926ff6e248db9dcdfdf6a331f821` = `origin/main` |
| 分支 | `grok/candidate-bar-idle-dismiss-001`，相对 `origin/main` 无已提交超前 commit |
| 脏树 | 已修改：`CandidateBarView.swift`、`KeyboardViewController+CandidateBar.swift`、`KeyboardViewController+ExpandedCandidatePanel.swift`、`CandidateItem.swift`、`CandidateKindTests.swift`、`docs/UI_STYLE_GUIDE.md`、`CHANGELOG.md`、`docs/ACTIVE_WORK.md`、`docs/ENGINEERING_DASHBOARD.md`、`docs/PROJECT_CONTEXT.md`。未跟踪：`CandidateBarIdleDismissContractTests.swift`、Assignment / PD / `AUTH-…-001` / `AUTH-…-IMPLEMENT` / `AUTH-…-QUALITY`、本 packet |
| Packet digest（独立复现） | `5adecb81985d91de0022471e74702181975c332589cac149643285da69718c28` |
| `git diff -- Packages/RimeBridge/` | **空**（无 Vendor 例外文件） |
| 切片文件 SHA-256（工作区字节，非 git object） | 见下表。测试后复测 Swift 六文件，与审查开始时一致 |

| Path | SHA-256（本审查 `shasum -a 256`） |
|---|---|
| `Keyboard/Views/CandidateBar/CandidateBarView.swift` | `606b5553c14f86f1963116b977bcb5ccb905e9c64515273a581f98a74fab95de` |
| `Keyboard/Controllers/KeyboardViewController+CandidateBar.swift` | `8f1284ae6329d9c59e27be9866dcdf74717482f3f0c0c5a856df55bd72687c6c` |
| `Keyboard/Controllers/KeyboardViewController+ExpandedCandidatePanel.swift` | `0177c7750f017f978773f6bfd3c739be17f2228936369ee6ba1aef7e9c6d301f` |
| `Packages/KeyboardCore/Sources/KeyboardCore/CandidateItem.swift` | `e08a0d59d7cf6506b1c1344450166c530d852a5279e935eeb5e973693d150200` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/CandidateKindTests.swift` | `316bcbaacb70e630884cb6144ff048a3778c5ae171e675cf6aa6de29532ed394` |
| `KeyboardTests/CandidateBarIdleDismissContractTests.swift` | `bafa0a0bf677adc7188486a8e4b191a115d2588ac161719198d5d666937fa93c` |
| `docs/UI_STYLE_GUIDE.md` | `446012957516d9608184bf0649c6e77c78b1fb7f19d7b58819a10e997eb17558` |
| `docs/assignments/candidate-bar-idle-dismiss-001.md` | `642211a055137f766ceae21e696390474327b0037531e6635d11381823e391be` |
| `docs/product-decisions/CANDIDATE-BAR-IDLE-DISMISS-001-authorization.md` | `b75e9de164801a3130a1f9e6e017fd030c9955494e345172e3759b5f5f9c8c58` |
| `docs/authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001.md` | `5bbc40d20aad30ff2d1da927c64d26b2d02bffcccc1ef977ea2588c57cba92bf` |
| `docs/authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-IMPLEMENT.md` | `41fe0a62ee24a63b73b61251b347a6571f35d7ce190adad41808017716b06a4b` |
| `CHANGELOG.md` | `03bfda10829c3c2ead43e269eb1009028f7db2b024ac43e3e5f8f1755e0776d5` |
| `docs/PROJECT_CONTEXT.md` | `c435ddf7fba05769ec976b703ad8b510e43eeb45e4092bca006872ec4968a263` |

之后若这些文件再改、或首次 commit，本文件 **不能** 自动跟随新 SHA。

## Verdict

**Pass with conditions。** 无开放 P0/P1。相对 `PD-CANDIDATE-BAR-IDLE-DISMISS-001`，工作区把既有右侧 56 pt `CandidateBarExpandButton` 改成双模：`presentedCandidates` 含 `expandsCandidateBarPanel` 的 kind 时图标 `chevron.down`、点按 `toggleCandidateExpand()`、`allowsSwipeToExpand = true`；否则 template `chevron.down.circle`、点按 `dismissKeyboard()`、下滑手势 `shouldBegin` / 阈值触发均被 `allowsSwipeToExpand` 挡住。按钮始终 `isHidden = false`，宽度钉在 56，不新增第二颗键。`candidateBarHeight` 仍为 34。展开面板仍用独立 `chevron.up` 收起。KeyboardCore 只加分类属性；`Packages/RimeBridge/` 无 diff。圆角宿主透白按 Human 指示保持现状。

本结论 **不** 关闭 Assignment，**不** 授权 Product Gate / commit / merge / TestFlight / Release，**不是** Device-attested，**不是** Human Simulator 目视复验。

| 严重级别 | 数量 |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 3（均已 disposition，见残差表） |
| P3 | 2（均已 disposition，见残差表） |

### 条件

1. 残差表 disposition 保持有效；Quality 片关闭不要求先冻结实现 commit SHA，也不要求本 lane 补 Human/Device 目视，也不要求本 lane 修圆角透白。
2. 结论只对审查时身份表工作区字节有效。之后若这些文件再改、或首次 commit，本文件 **不能** 自动跟随新 SHA。
3. 不得把本文件当成 Product Gate、commit 许可或 TestFlight 许可。
4. 本 lane **没有** 在 Simulator 上打开键盘做人眼核对空闲关闭 / 展开图标。

## Packet claims

| # | Claim | 本审查结果 |
|---|---|---|
| 1 | One trailing control：既有 56 pt 槽；可展开用 `chevron.down`；空闲 template `chevron.down.circle` + `dismissKeyboard()`；无第二颗键；不改候选栏高度 | **Pass** |
| 2 | Expandable content：`expandsCandidateBarPanel` 对 candidate / composition / correction / continuation / punctuation / kaomoji 为 true，placeholder 为 false；联想保持展开 | **Pass** |
| 3 | Gestures and panel：`allowsSwipeToExpand` 仅 Expand mode；展开面板仍用上箭头收起；下滑不关闭 | **Pass** |
| 4 | Idle icon compositing：trailing `UIButton(type: .custom)` + `.alwaysTemplate`；`updateExpandButtonAppearance` 设 `configuration = nil`；trailing 无 `UIButton.Configuration` | **Pass** |
| 5 | Accessibility：Expand / collapse / dismiss 标签与 Hint 随模式切换 | **Pass**（源码合同；目视 VoiceOver 见 `CBID-02`） |
| 6 | Tests：独立 `swift-format lint --strict`、`CandidateKindTests`、指定 iPhone 17 `xcodebuild`；不复用 Executor 410/16 | **Pass**（独立复验） |
| 7 | KeyboardCore boundary：只加分类；候选生成 / 联想合同 / RimeBridge 未改；`git diff -- Packages/RimeBridge/` 空 | **Pass** |
| 8 | Non-claims：不授予 Product Gate / Device-attested / commit / push / merge / TestFlight / Release；Human 目视不属本 lane；圆角透白 out of scope，residual `accept` | **Pass**（本文件遵守；`CBID-CORNER` `accept`） |

Complete coverage：八条均有显式结果。无 `Uncovered`。

## 已通过的证据

| 领域 | 当前证据 | 结论 |
|---|---|---|
| 单槽 56 pt | [`KeyboardViewController+CandidateBar.swift`](../../Keyboard/Controllers/KeyboardViewController+CandidateBar.swift) L159–161：按钮不隐藏，宽度恒 56。[`CandidateBarView.swift`](../../Keyboard/Views/CandidateBar/CandidateBarView.swift) `expandButtonTouchSize = 56`。`KeyboardViewController.swift` `candidateBarHeight = 34` 未改。只 `addSubview(expandButton)` 一颗 trailing 控件 | **通过**（源码 + `git diff`） |
| 双模 action / 图标 | `handleCandidateBarTrailingButton`：`canExpand` → `toggleCandidateExpand()`，否则 `dismissKeyboard()`。`trailingChromeImage(expanding:)`：`chevron.down` / `chevron.down.circle` | **通过** |
| 可展开 kind | [`CandidateItem.swift`](../../Packages/KeyboardCore/Sources/KeyboardCore/CandidateItem.swift) L69–76：placeholder false，其余六种 true（含 `.continuationCandidate`）。`fillCandidateBar` 用该属性，不再只认 candidate/punctuation/kaomoji | **通过**。相对旧逻辑，composition / correction / continuation 现在也走展开，符合 PD |
| 下滑 | `allowsSwipeToExpand = canExpand`。`gestureRecognizerShouldBegin` 与 `triggerExpandIfSwipeDownThresholdPassed` 均 `guard allowsSwipeToExpand`。Dismiss mode 手势不 begin。Expand mode 下滑走同一 `expandAction`，此时 `canExpand` 为 true，进入 `toggleCandidateExpand()` 而非 `dismissKeyboard()` | **通过**（源码） |
| 展开面板收起 | [`KeyboardViewController+ExpandedCandidatePanel.swift`](../../Keyboard/Controllers/KeyboardViewController+ExpandedCandidatePanel.swift) `makeExpandedCandidatePanel`：独立 `chevron.up` collapse，target `toggleCandidateExpand`，无 dismiss | **通过** |
| 合成 | `CandidateBarExpandButton(type: .custom)` + `.alwaysTemplate`。`CandidateBarView.swift` **无** `UIButton.Configuration`。`updateExpandButtonAppearance` L226：`button.configuration = nil` | **通过**。展开面板 collapse 仍用 `UIButton.Configuration.plain()`，那不是 trailing 槽 |
| AX | Expand：`展开更多候选词` / `双击以查看完整候选列表`。已展开：`收起候选词` / `双击以收起完整候选列表`。Idle：`关闭键盘` / `双击以收起键盘`。面板 collapse：`收起候选面板` | **通过**（源码）。本 lane 未跑 VoiceOver |
| 指南 | [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) L125：56 pt 槽、双模图标、template、下滑仅 expand、AX 随模式 | **通过**（文档合同）。`CHANGELOG` / Dashboard **不是** 产品证明 |
| KeyboardCore | `git diff -- Packages/KeyboardCore/Sources/KeyboardCore/CandidateItem.swift` 仅新增 `expandsCandidateBarPanel`。测试仅新增 `testExpandableKindsKeepTheTrailingButtonInExpandMode`。RimeBridge diff 空 | **通过** |
| Swift 格式 | 身份表六个 `.swift`：`xcrun swift-format lint --strict --configuration .swift-format`，exit 0 | **通过**（本审查） |
| KeyboardCore 单测 | `swift test --package-path Packages/KeyboardCore --filter CandidateKindTests`：Executed **17**，failed **0**（含 expandable-kinds 1 条） | **通过**（本审查） |
| Simulator App+Keyboard | 本审查独立重跑（见下）。**TEST SUCCEEDED**：`UniverseKeyboardTests` 410 执行 / 10 skipped / 0 failed；`KeyboardTests` 16 / 0 failed（含 `CandidateBarIdleDismissContractTests` 1） | **独立复验通过。** 不是 hosted CI，不是 Device-attested |

### 本审查独立重跑的机器证据

按 [`AI_WORKFLOW.md`](../AI_WORKFLOW.md) 证据复用条件：未提交快照、内容相对 `HEAD` 已变、独立 Quality 不得把 Executor 计数当事实。本审查 **没有** 复用 Executor-recorded `410/16`，而是重跑 packet 指定 scheme / 配置 / destination。

```text
xcrun swift-format lint --strict --configuration .swift-format \
  Keyboard/Views/CandidateBar/CandidateBarView.swift \
  Keyboard/Controllers/KeyboardViewController+CandidateBar.swift \
  Keyboard/Controllers/KeyboardViewController+ExpandedCandidatePanel.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/CandidateItem.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/CandidateKindTests.swift \
  KeyboardTests/CandidateBarIdleDismissContractTests.swift
# exit 0

swift test --package-path Packages/KeyboardCore --filter CandidateKindTests
# Executed 17, failed 0；含 testExpandableKindsKeepTheTrailingButtonInExpandMode

xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" -configuration Debug \
  -destination 'platform=iOS Simulator,id=D3C353BE-3AA6-499B-8F87-349073D65BE4' \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 \
  SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
```

| 项 | 本审查记录 |
|---|---|
| Destination | **仅** `iPhone 17` (`D3C353BE-3AA6-499B-8F87-349073D65BE4`)；审查时 simctl 列为 iOS 26.0 **Booted**。**未** 把 `iPhone 17 Pro` (`8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`) 写入 `-destination`（该机当时也 Booted，仅出现在 `simctl list`）。SDK `iPhoneSimulator27.0` |
| 结果 | `** TEST SUCCEEDED **`（exit 0） |
| `UniverseKeyboardTests` | Executed **410**，skipped **10**，failed **0** |
| `KeyboardTests` | Executed **16**，failed **0** |
| `CandidateBarIdleDismissContractTests` | `testTrailingButtonWiresDismissAndKeepsExpand` passed（0.008 s），suite `2026-09-28 22:04:51.492` |
| `CandidateKindTests`（SPM） | 17 / 0，含 expandable-kinds |
| xcresult | `/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-dxwhfzxqseyzcuclkhpyzjwydgfz/Logs/Test/Test-Universe Keyboard-2026.09.28_22-04-17-+0800.xcresult` |
| DerivedData | `Universe_Keyboard-dxwhfzxqseyzcuclkhpyzjwydgfz` |
| Testing elapsed | `28.864` s（`IDETestOperationsObserverDebug`） |
| 未跑 | `RimeBridgeTests`、Release `build`、hosted CI、Simulator/真机目视候选栏、VoiceOver |

Executor 记录的 410 / 10 skipped / KeyboardTests 16 与本次数值一致，但本裁决只引用 **本审查这次** 的命令与 xcresult。

## Findings

无 P0/P1。下列不是「双模关闭键合同未落地」，而是脏树身份、证据分级或范围边界。

### P2-01：无冻结实现 SHA；切片文件与状态镜像并存于脏树

Keyboard / KeyboardCore Swift 与新合同测试未提交。同树还有 Assignment / PD / AUTH 与 `CHANGELOG` / Dashboard / Active Work / `PROJECT_CONTEXT` 镜像。P-01 对本片 Not applicable。

Disposition：`accept`（见 `CBID-01`）。任何 commit 必须把本片切片从无关状态镜像中按授权切开，并在新 SHA 上决定是否重验。

### P2-02：本 Quality lane 未打开 Simulator 键盘做人眼核对

Packet 写明 Human-attested Simulator glance of dismiss 不是本 lane。本审查未在 iPhone 17 上目视空闲圆圈、展开箭头、下滑不关闭。源码合同与独立测试覆盖接线，因此 **不** 因缺目视自动 Fail。Product Gate / Release **不得** 声称「Quality 已在 Simulator 上看到关闭键」。

Disposition：`accept`（见 `CBID-02`）。

### P2-03：顶左右圆角外侧宿主透白（light 更明显）

PD Non-goals 与 Human「先保持现状」把该表面排除在本切片之外。本审查 **未** 实现、也 **未** 要求实现填满系统圆角。

Disposition：`accept`（见 `CBID-CORNER`）。跟进须在本 Assignment Close 之后另开，不并进本片。

### P3-01：KeyboardTests 是源码字符串合同，不是运行时 UI

`CandidateBarIdleDismissContractTests` 读仓库源文件断言 selector / `dismissKeyboard()` / `allowsSwipeToExpand` / template / `.custom`，不断言 Simulator 上真的收起键盘，也不锁全部 AX 字符串。`CandidateKindTests` 锁分类布尔。packet Tests 句要求的是独立 lint + 指定套件重跑，已满足。不要求本片为 Quality 关闭去补 UI 测试。

Disposition：`accept`（见 `CBID-03`）。

### P3-02：下滑手势与 tap 共用 `handleCandidateBarTrailingButton`

Expand mode 下滑最终 `perform(expandAction)`。因 `allowsSwipeToExpand` 与 `canExpand` 在 `fillCandidateBar` 同步，当前路径会 `toggleCandidateExpand()` 而不是 dismiss。若未来两处状态脱节，理论上可能下滑关闭。现合同与守卫足够；不扩 scope。

Disposition：`accept`（见 `CBID-04`）。

## Architecture N/A

本审查 **不争议** Architecture `Not Applicable`，也 **不** 另给 Architecture 结论。实现停在既有展开槽、UIKit 呈现与 `dismissKeyboard()` 用户点按。KeyboardCore 只增加只读分类，未见候选生成、联想合同或 RimeBridge session 语义改动。

## 明确跳过的检查

- 未跑 `RimeBridgeTests`、Release `build`（本片 `Packages/RimeBridge/` 无 diff；Assignment 未要求 Quality 补跑）。
- 未做 hosted CI（无冻结 SHA）。
- 本 Quality lane **没有** 在 Simulator 或真机打开键盘核对图标 / 关闭行为 / VoiceOver，也没有操作圆角透白。
- 未审无关 Active Work 行的质量。
- 未操作 AUTH consumption、Product Gate、commit、push。

本地只读 + 独立测试：

```text
git rev-parse HEAD   # fbb4eb3bbbc2926ff6e248db9dcdfdf6a331f821
git status --short   # 脏树；双模切片 + 治理镜像并存
# packet digest 独立复现；身份表十三文件独立 shasum
# 阅读 Assignment / PD / AUTH-IMPLEMENT / AUTH-QUALITY / playbooks
# grep expandsCandidateBarPanel / chevron.down.circle / dismissKeyboard / UIButton.Configuration
xcrun swift-format lint --strict --configuration .swift-format  # 六个变更 .swift
swift test --package-path Packages/KeyboardCore --filter CandidateKindTests  # 17 / 0
# 上表 xcodebuild（独立重跑，非 Executor 复用；destination 仅 iPhone 17）
git diff -- Packages/RimeBridge/  # 空
```

## 残差账本

| Residual ID | 严重级别 | Owner | Disposition | Pointer |
|---|---|---|---|---|
| `CBID-01` | P2 | 发布 / 提交切片 | `accept` | 无冻结实现 SHA。`HEAD` `fbb4eb3bbbc…` + 脏树；`CandidateBarView.swift` SHA-256 `606b5553…`；`KeyboardViewController+CandidateBar.swift` `8f1284ae…` |
| `CBID-02` | P2 | Human Product Lead（Product Gate / 可选目视） | `accept` | 本 Quality lane 未打开 Simulator 键盘。Human glance 不是本 lane。无 UUID/截图。不得升格为 Device-attested |
| `CBID-CORNER` | P2 | Human Product Lead（Close 之后另开） | `accept` | 顶左右圆角外侧宿主透白（light 更明显）。PD Non-goals；本切片保持现状。**不要**在本片实现 |
| `CBID-03` | P3 | KeyboardTests（未来 Assignment） | `accept` | `CandidateBarIdleDismissContractTests` 为源码扫描，非运行时 dismiss / VoiceOver。`KeyboardTests/CandidateBarIdleDismissContractTests.swift` |
| `CBID-04` | P3 | Keyboard UI（观察，非本片） | `accept` | 下滑与 tap 共用 `handleCandidateBarTrailingButton`；由 `allowsSwipeToExpand` 与 `canExpand` 同步约束。`CandidateBarView.swift` `triggerExpandIfSwipeDownThresholdPassed` |

Quality 片关闭不因上述残差阻塞：每条都有 disposition。**Assignment Close / Product Gate 仍被未授权的 Gate 阻塞**，不因本文件自动解除。

## 非声称

- 不是 Product Gate、Assignment `Closed`、Quality 对 **Device-attested 或 Human Simulator 目视关闭键** 的 Pass。
- 不是 commit / push / PR / merge / TestFlight / App Store / Release。
- 不是 D-01 receipt、P-01 publication、hosted CI、冻结 payload。
- 不是 Architecture 复审（Assignment 为 N/A；本文件不给 Architecture 结论）。
- 不是圆角透白修复结论；`CBID-CORNER` 明确 `accept` 且禁止本片实现。
- 不是 Executor 测试计数的复用；本审查已独立重跑，仍不是 hosted CI。
- 本审查未消耗 AUTH-QUALITY 记录（禁止改 AUTH consumption）。

## 建议的下一步（Human）

1. **Product Gate（另授权）：** 若产品接受 `CBID-01`（脏树身份）、`CBID-02`（无本 lane 目视）与 `CBID-CORNER`（圆角保持现状）为本片发布前残差，可对 **双模 trailing 关闭键** 做 Product Gate；本文件 **不** 代替该 Gate。Gate 前可选产品在 iPhone 17 Simulator 看一眼空闲圆圈关闭、有候选仍展开、下滑不关闭。
2. `CBID-01`：commit 须新授权，且只切本片 Swift / 测试 / 必要文档；commit 后本审查 **不能** 自动钉新 SHA。
3. `CBID-CORNER`：本 Assignment Close 之后另开，不并进关闭键切片。

下一步默认交 **Product Lead（Human Product Gate）**，不是本 lane 继续改 Swift。
