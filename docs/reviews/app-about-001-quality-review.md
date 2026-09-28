# APP-ABOUT-001 独立质量、性能与发布复审

**复审日期：** 2026-09-28（Asia/Shanghai）
**复审 lane：** KOS Quality, Performance & Release（`APP-ABOUT-001-QUALITY-001`，Round 1）
**复审范围：** Assignment [`APP-ABOUT-001`](../assignments/app-about-001.md) 主 App「关于」页：身份（营销版本 + Build）、邮件 + 小红书、设置 IA 把隐私/开源挂进关于页、搜索目录。不含 Keyboard Extension 联系路径、自动附诊断、Human Simulator 目视。
**工作树：** `/private/tmp/universe-keyboard-app-about-001`，分支 `grok/app-about-001`（tracking `origin/main`）
**Git 基线：** `HEAD` `a536dca74acc18deebe1de9b7a2c22421cba9f95`，与 `origin/main` 相同。本审查独立 `git rev-parse` / `git status` 核实，不是 Executor 口述。
**原始实现身份：** **无冻结 SHA。** 本结论钉在审查时的 **脏工作树** 切片文件 SHA-256，不是 commit / payload manifest。
**授权：** [`AUTH-APP-ABOUT-001-QUALITY`](../authorizations/AUTH-APP-ABOUT-001-QUALITY.md) — 仅独立 Quality；不授权 Product Gate / commit / push / 改 Swift。本 lane **未** 回写 AUTH consumption。冻结 Assignment 仍写 Quality Not authorized，那是 Quality 前快照；本 AUTH 才是本 lane 授权。
**Decision：** [`PD-APP-ABOUT-001`](../product-decisions/APP-ABOUT-001-authorization.md)（Human 锁定入口、邮箱、小红书短链、邮件主题、隐私/开源 IA 挪动，`2026-09-28`）
**Packet：** [`app-about-001-quality-review-packet.md`](app-about-001-quality-review-packet.md)。本审查独立复现 Packet digest：将 Packet digest 行替换为 64 个 ASCII `0` 后对全文 UTF-8 做 SHA-256，得 `15a437f255a946f2073e646acfea6e388c2a76dfddbd4fa0ec758c9dfb7085c7`，与冻结值一致。身份表十六份文件独立 `shasum -a 256` 均与 packet 一致，故继续评 claims。

本 lane **只写本文件与 usage 证据**。未改产品 Swift、测试、packet、`CHANGELOG`、`ACTIVE_WORK`、`ENGINEERING_DASHBOARD`、Assignment Current Status、AUTH consumption。Architecture Reviewer 按 Assignment 为 **Not Applicable**；本文件 **不** 给出 Architecture 结论。

脏树中与本片同批的 Assignment / PD / AUTH / `CHANGELOG` / `ACTIVE_WORK` / `ENGINEERING_DASHBOARD` / `PROJECT_CONTEXT` 镜像 **不** 升格为本片命中合同证据。Executor 聊天中的「TEST SUCCEEDED / 410 / 10 / 15」记为 Executor-recorded，**不** 构成本裁决；本审查已独立重跑同一 `xcodebuild`（指定 iPhone 17，未打 iPhone 17 Pro）。

## 身份（审查时工作树）

| Boundary | 本审查实测 |
|---|---|
| `HEAD` | `a536dca74acc18deebe1de9b7a2c22421cba9f95` = `origin/main` |
| 分支 | `grok/app-about-001`，相对 `origin/main` 无已提交超前 commit |
| 脏树 | 已修改：`SettingsSearchCatalog.swift`、`SearchTab.swift`、`SettingsTab.swift`、`ActivationChecklistStateTests.swift`、`docs/UI_STYLE_GUIDE.md`、`docs/PRIVACY_POLICY.md`、`docs/RELEASE_CHECKLIST.md`、`CHANGELOG.md`、`docs/ACTIVE_WORK.md`、`docs/ENGINEERING_DASHBOARD.md`、`docs/PROJECT_CONTEXT.md`。未跟踪：`AppAboutContact.swift`、`AboutSettingsView.swift`、`AppAboutContactTests.swift`、Assignment / PD / `AUTH-…-001` / `AUTH-…-IMPLEMENT` / `AUTH-…-QUALITY`、本 packet |
| Keyboard Extension | `git diff -- Keyboard/` **空**；`Keyboard/` 无 `mailto` / `xhslink` / `AppAboutContact` / `doubleshy0n` |
| Packet digest（独立复现） | `15a437f255a946f2073e646acfea6e388c2a76dfddbd4fa0ec758c9dfb7085c7` |
| 切片文件 SHA-256（工作区字节，非 git object） | 见下表 |

| Path | SHA-256（本审查 `shasum -a 256`） |
|---|---|
| `Universe Keyboard/Models/AppAboutContact.swift` | `ed68f7490e8405bcc32ff485f5c332bdfd21c16583ac0a179272d0c927ab4868` |
| `Universe Keyboard/Views/Settings/AboutSettingsView.swift` | `08d6ff835b0429ba3a5734881730e9cebed4be49a65a00e5c4f315bc4695d2ec` |
| `Universe Keyboard/Views/Settings/SettingsTab.swift` | `2ff0065c37d4297d0193a29d9db3a796d0c932f7d577866511312721afda992a` |
| `Universe Keyboard/Models/SettingsSearchCatalog.swift` | `e0d5ef07ac79f1d78637d3e8041962b92d1b4d5176e919db65304845d3580472` |
| `Universe Keyboard/Views/Search/SearchTab.swift` | `29bc0100db1517f1247eeabf1e56966c845a900b0e588c18fb1d29eb1fd6c4c2` |
| `UniverseKeyboardTests/AppAboutContactTests.swift` | `b8f25387505a0a00e028ea9cf3e77b13bf1985ad1122f6efc852ae1824d5a35f` |
| `UniverseKeyboardTests/ActivationChecklistStateTests.swift` | `2aac73f5bd54aeba14030b89481a5f9f49466cb0670989400314c4246d69ca8a` |
| `docs/UI_STYLE_GUIDE.md` | `82c79d245db50bfa6df97eb355022de41c2070078abc9b83f5e1101492d33cb3` |
| `docs/assignments/app-about-001.md` | `67ec78a435a9de065ebd2f0e71e4ef9552ae848a3762f15fca2897e076947114` |
| `docs/product-decisions/APP-ABOUT-001-authorization.md` | `899c2b1a47890ec7408664572fc54b4b6b41b29889877c7806d0d9163d6d53a3` |
| `docs/authorizations/AUTH-APP-ABOUT-001.md` | `e7c70e0ca106ab3ada79ca4a8dab607ea3e1388341e8817b16fb8933b29aafdf` |
| `docs/authorizations/AUTH-APP-ABOUT-001-IMPLEMENT.md` | `0248ce54a8a00ecb0993565462221d0756498645a9ff94f647a9191d7df81674` |
| `docs/RELEASE_CHECKLIST.md` | `952369f9fde66b3213e73a31fb3f8c0698fa8f86b6c723f731b3f9a49751f428` |
| `docs/PRIVACY_POLICY.md` | `92d71cffe20c6c196638d79ef519e02312ae72098c2355d4bd8e20ba77ba8b77` |
| `CHANGELOG.md` | `8d4b7246838cf00a8bda458e8bc931e673d55d26b12bc98abf6298a81f118e0b` |
| `docs/PROJECT_CONTEXT.md` | `fd638bddc12ad4d7ce8368170faeda7e638c403a9f1cd8c9750634fa11b5c5c3` |

之后若这些文件再改、或首次 commit，本文件 **不能** 自动跟随新 SHA。

## Verdict

**Pass with conditions。** 无开放 P0/P1。相对 `PD-APP-ABOUT-001`，工作区把主 App「关于」放在设置「App 设置」末行（外观、通知与提醒、关于）；隐私与开源从设置根列表移除，改为关于页 `NavigationLink` 进入既有 `PrivacyDataView` / `OpenSourceLicensesView`（本片 `git diff` 未改这两页正文）。身份经 `AppAboutContact` 读 `CFBundleShortVersionString` / `CFBundleVersion`，不编写、不递增工程号；当前 `project.pbxproj` 默认 `MARKETING_VERSION=1.0`、`CURRENT_PROJECT_VERSION=1`。邮件锁定 `doubleshy0n@gmail.com`，主题 `Universe Keyboard 反馈 · {version} (Build {build})`，`mailto` 仅 `subject` query，无 body/附件。小红书锁定 `https://xhslink.cn/o/7lEn4EM0BtP`，仅用户点击 `openURL`。搜索目录含 `about` / `privacy` / `openSource`，`SearchTab` 路由到对应页。`Keyboard/` 无联系路径。`PRIVACY_POLICY.md` Network Use 写明点击后才打开系统邮件或小红书，不附诊断。

本结论 **不** 关闭 Assignment，**不** 授权 Product Gate / commit / merge / TestFlight / Release，**不是** Device-attested，**不是** Human Simulator 目视复验。

| 严重级别 | 数量 |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 2（均已 disposition，见残差表） |
| P3 | 3（均已 disposition，见残差表） |

### 条件

1. 残差表 disposition 保持有效；Quality 片关闭不要求先冻结实现 commit SHA，也不要求本 lane 补 Human/Device 目视。
2. 结论只对审查时身份表工作区字节有效。之后若这些文件再改、或首次 commit，本文件 **不能** 自动跟随新 SHA。
3. 不得把本文件当成 Product Gate、commit 许可或 TestFlight 许可。
4. 本 lane **没有** 在 Simulator 上打开关于页做人眼核对版本/Build 显示。

## Packet claims

| # | Claim | 本审查结果 |
|---|---|---|
| 1 | Settings IA：App 设置为外观、通知、关于；隐私/开源离开设置根，挂在关于页进入既有页 | **Pass** |
| 2 | Identity：Info.plist helpers；工程默认 1.0 / Build 1；不发明数字；`RELEASE_CHECKLIST` 拥有上传包身份 | **Pass**（源码 + 工程默认 + 清单；目视显示见 `ABOUT-02`） |
| 3 | Mail：锁定地址、主题格式、正文空、无诊断附件 | **Pass** |
| 4 | Xiaohongshu：锁定短链、仅用户点击 `openURL`；无 Telegram/Discord/应用内表单 | **Pass** |
| 5 | Search：catalog 有 `about`/`privacy`/`openSource`；SearchTab 路由；关键词覆盖 关于/版本/邮箱/小红书/隐私/开源 | **Pass** |
| 6 | Tests：锁定 subject/mailto/小红书；搜索 关于/小红书/开源/隐私；独立 lint + 指定 iPhone 17 `xcodebuild` | **Pass**（独立复验，不复用 Executor 410/10/15） |
| 7 | Keyboard 与隐私边界：`git diff -- Keyboard/` 空；联系仅主 App 点击；政策写明点击后打开且不附诊断 | **Pass** |
| 8 | Non-claims：不授予 Product Gate / Device-attested / commit / push / merge / TestFlight / Release；无冻结实现 SHA；Human 目视不属本 lane | **Pass**（本文件遵守） |

Complete coverage：八条均有显式结果。无 `Uncovered`。

## 已通过的证据

| 领域 | 当前证据 | 结论 |
|---|---|---|
| Settings IA | [`SettingsTab.swift`](../../Universe%20Keyboard/Views/Settings/SettingsTab.swift) `appSettingsSection` L241–275：外观、通知与提醒、关于。设置根无「隐私与数据」「开源软件与内容」行 | **通过**（源码） |
| 关于页导航 | [`AboutSettingsView.swift`](../../Universe%20Keyboard/Views/Settings/AboutSettingsView.swift) L46–58：`PrivacyDataView()` / `OpenSourceLicensesView()`。`git diff` 对 `PrivacyDataView.swift` / `LicenseView.swift` **空** | **通过**。启用指南 `GuideTab` 仍可进隐私页，不是设置根列表（`ABOUT-03`） |
| 身份 helpers | [`AppAboutContact.swift`](../../Universe%20Keyboard/Models/AppAboutContact.swift) L26–32：`CFBundleShortVersionString` / `CFBundleVersion`。关于页 LabeledContent 绑定这两个 helper。未发现写入/递增版本号 | **通过** |
| 工程默认 | `Universe Keyboard.xcodeproj/project.pbxproj`：`MARKETING_VERSION = 1.0`、`CURRENT_PROJECT_VERSION = 1`（App 与 Keyboard 配置）。`config/Info.plist` 使用 `$(MARKETING_VERSION)` / `$(CURRENT_PROJECT_VERSION)` | **通过**（仓库默认，不是 Simulator UI 截图） |
| 发布清单 | [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md)「Installed Version And Build Identity」：关于页只反映安装包；TestFlight/App Store 数字由当次上传包拥有 | **通过**（文档合同） |
| 邮件 | 地址 `doubleshy0n@gmail.com`；`feedbackMailSubject` 格式锁定；`feedbackMailtoURL` 仅 `subject` query，无 `body`/`attachment`。关于页 Button → `openURL` | **通过**（源码 + 单元测试） |
| 小红书 | `xiaohongshuURLString` / 测试锁定 `https://xhslink.cn/o/7lEn4EM0BtP`。关于页 Button → `openURL`。关于页无 Telegram/Discord/`MFMailCompose` 表单 | **通过** |
| 搜索 | Catalog L138–164：`about` / `privacy` / `openSource`；关键词含 关于、版本、build、邮箱、邮件、小红书、隐私、开源。[`SearchTab.swift`](../../Universe%20Keyboard/Views/Search/SearchTab.swift) L182–187 路由 About / Privacy / OSS | **通过**。`版本`/`邮箱` 关键词无单独 XCTest（`ABOUT-05`） |
| 指南 | [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) L156：App 设置末行关于；版本/Build 为安装 Info.plist；Debug 1.0 / Build 1 为工程默认 | **通过**（相对 PD 落地）。`CHANGELOG` / Dashboard **不是** 产品证明 |
| 隐私政策 | [`PRIVACY_POLICY.md`](../PRIVACY_POLICY.md) Network Use：关于页仅在用户点击后打开系统邮件或小红书；不附诊断或输入 | **通过** |
| 单元：联系 | `AppAboutContactTests` 3 条：主题、mailto 地址+subject、小红书 URL | **通过**（测试源码 + 本审查重跑） |
| 单元：搜索 | `testSettingsSearchCatalogMatchesKeywords`：关于 → `.about`、小红书 → `.about`、开源 → `.openSource`、隐私 → `.privacy` | **通过** |
| Swift 格式 | 身份表七个 `.swift`：`xcrun swift-format lint --strict --configuration .swift-format`，exit 0 | **通过**（本审查） |
| Simulator App+Keyboard | 本审查独立重跑（见下）。**TEST SUCCEEDED**：`UniverseKeyboardTests` 410 执行 / 10 skipped / 0 failed（含 `AppAboutContactTests` 3）；`KeyboardTests` 15 / 0 failed | **独立复验通过。** 不是 hosted CI，不是 Device-attested |

### 本审查独立重跑的机器证据

按 [`AI_WORKFLOW.md`](../AI_WORKFLOW.md) 证据复用条件：未提交快照、内容相对 `HEAD` 已变、独立 Quality 不得把 Executor 计数当事实。本审查 **没有** 复用 Executor-recorded `410/10/15`，而是重跑 packet 指定 scheme / 配置 / destination。

```text
xcrun swift-format lint --strict --configuration .swift-format \
  "Universe Keyboard/Models/AppAboutContact.swift" \
  "Universe Keyboard/Views/Settings/AboutSettingsView.swift" \
  "Universe Keyboard/Views/Settings/SettingsTab.swift" \
  "Universe Keyboard/Models/SettingsSearchCatalog.swift" \
  "Universe Keyboard/Views/Search/SearchTab.swift" \
  UniverseKeyboardTests/AppAboutContactTests.swift \
  UniverseKeyboardTests/ActivationChecklistStateTests.swift
# exit 0

xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" -configuration Debug \
  -destination 'platform=iOS Simulator,id=D3C353BE-3AA6-499B-8F87-349073D65BE4' \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 \
  SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
```

| 项 | 本审查记录 |
|---|---|
| Destination | **仅** `iPhone 17` (`D3C353BE-3AA6-499B-8F87-349073D65BE4`)；审查时 simctl 列为 iOS 26.0 **Booted**。**未** 使用 `iPhone 17 Pro` (`8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`)。SDK `iPhoneSimulator27.0` |
| 结果 | `** TEST SUCCEEDED **`（exit 0） |
| `UniverseKeyboardTests` | Executed **410**，skipped **10**，failed **0** |
| `AppAboutContactTests` | 3 条均 passed；suite passed `2026-09-28 20:34:56.043` |
| `testSettingsSearchCatalogMatchesKeywords` | passed（0.003 s） |
| `KeyboardTests` | Executed **15**，failed **0** |
| xcresult | `/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-gqyevogrroqswqfrigeerehorxzz/Logs/Test/Test-Universe Keyboard-2026.09.28_20-34-43-+0800.xcresult` |
| DerivedData | `Universe_Keyboard-gqyevogrroqswqfrigeerehorxzz` |
| 未跑 | KeyboardCore-only `swift test`、`RimeBridgeTests`、Release `build`、hosted CI、Simulator/真机目视关于页 |

Executor 记录的 410 / 10 skipped / KeyboardTests 15 与本次数值一致，但本裁决只引用 **本审查这次** 的命令与 xcresult。

## Findings

无 P0/P1。下列不是「关于页合同未落地」，而是脏树身份、证据分级或范围边界。

### P2-01：无冻结实现 SHA；切片文件与状态镜像并存于脏树

About Swift / 测试未提交。同树还有 Assignment / PD / AUTH 与 `CHANGELOG` / Dashboard / Active Work / `PROJECT_CONTEXT` 镜像。P-01 对本片 Not applicable。

Disposition：`accept`（见 `ABOUT-01`）。任何 commit 必须把关于页切片从无关状态镜像中按授权切开，并在新 SHA 上决定是否重验。

### P2-02：本 Quality lane 未打开 Simulator 关于页做人眼核对

Packet 写明 Human Simulator glance 是 Human-attested，不是本 lane 复验。本审查未在 iPhone 17 上目视「1.0 / Build 1」。源码合同与工程默认覆盖身份读取，因此 **不** 因缺目视自动 Fail。Product Gate / Release **不得** 声称「Quality 已在 Simulator 上看到版本数字」。

Disposition：`accept`（见 `ABOUT-02`）。

### P3-01：启用指南仍可进入隐私页

`GuideTab.swift` 仍有 `PrivacyDataView()`（「查看隐私与数据说明」）。这不是设置「App 设置」根列表。PD 只要求设置根去掉隐私/开源行。不扩 scope。

Disposition：`accept`（见 `ABOUT-03`）。

### P3-02：自动测试不锁 Info.plist 运行时取值，也不断言 mailto 无 body query

`AppAboutContactTests` 用字面量 `"1.0"` / `"55"` 锁主题与 mailto，不断言 `marketingVersion(from:)` 真读 bundle。`feedbackMailtoURL` 源码只有 `subject`；测试未 `XCTAssertNil` body/attachment。不要求本片为 Quality 关闭去补 UI 测试。

Disposition：`accept`（见 `ABOUT-04`）。

### P3-03：搜索测试未点名「版本」「邮箱」关键词

Catalog 关键词含「版本」「邮箱」；XCTest 覆盖 关于 / 小红书 / 开源 / 隐私，与 packet Tests 句一致。关键词覆盖由源码满足。

Disposition：`accept`（见 `ABOUT-05`）。

## Architecture N/A

本审查 **不争议** Architecture `Not Applicable`，也 **不** 另给 Architecture 结论。实现停留在主 App Settings/About、用户点击 `mailto`/`openURL`、既有隐私/OSS 页入口。未见 Keyboard Extension 联系路径，未见把隐私承诺或许可证正文改成新合同。

## 明确跳过的检查

- 未跑 `swift test --package-path Packages/KeyboardCore`、`RimeBridgeTests`、Release `build`（本片未改那些 target；Assignment 实施交接也未要求 Quality 补跑）。
- 未做 hosted CI（无冻结 SHA）。
- 本 Quality lane **没有** 在 Simulator 或真机打开关于页核对本机显示的版本/Build，也没有点邮件/小红书。
- 未审无关 Active Work 行的质量。
- 未操作 AUTH consumption、Product Gate、commit、push。

本地只读 + 独立测试：

```text
git rev-parse HEAD   # a536dca74acc18deebe1de9b7a2c22421cba9f95
git status --short   # 脏树；关于页切片 + 治理镜像并存
# packet digest 独立复现；身份表十六文件独立 shasum
# 阅读 Assignment / PD / AUTH-IMPLEMENT / AUTH-QUALITY / playbooks
# grep mailto / xhslink / AppAboutContact / Keyboard/
xcrun swift-format lint --strict --configuration .swift-format  # 七个变更 .swift
# 上表 xcodebuild（独立重跑，非 Executor 复用；destination 仅 iPhone 17）
```

## 残差账本

| Residual ID | 严重级别 | Owner | Disposition | Pointer |
|---|---|---|---|---|
| `ABOUT-01` | P2 | 发布 / 提交切片 | `accept` | 无冻结实现 SHA。`HEAD` `a536dca74acc…` + 脏树；`AppAboutContact.swift` SHA-256 `ed68f749…`；`AboutSettingsView.swift` `08d6ff83…` |
| `ABOUT-02` | P2 | Human Product Lead（Product Gate / 可选目视） | `accept` | 本 Quality lane 未打开 Simulator 关于页。Human glance 不是本 lane。无 UUID/截图。不得升格为 Device-attested |
| `ABOUT-03` | P3 | Human Product Lead（scope；非本片） | `accept` | 启用指南仍链到 `PrivacyDataView`：`Universe Keyboard/Views/Guide/GuideTab.swift`（约 L258）。设置「App 设置」根列表已无该行 |
| `ABOUT-04` | P3 | 主 App 测试（未来 Assignment） | `accept` | `AppAboutContactTests` 不锁 bundle Info.plist 读取，也不断言 mailto 无 `body`。`UniverseKeyboardTests/AppAboutContactTests.swift`；helpers 在 `AppAboutContact.swift` L16–32 |
| `ABOUT-05` | P3 | 主 App 测试（可选） | `accept` | Catalog 含「版本」「邮箱」；`testSettingsSearchCatalogMatchesKeywords` 未点名这两词。`SettingsSearchCatalog.swift` L138–144 |

Quality 片关闭不因上述残差阻塞：每条都有 disposition。**Assignment Close / Product Gate 仍被未授权的 Gate 阻塞**，不因本文件自动解除。

## 非声称

- 不是 Product Gate、Assignment `Closed`、Quality 对 **Device-attested 或 Human Simulator 目视关于页** 的 Pass。
- 不是 commit / push / PR / merge / TestFlight / App Store / Release。
- 不是 D-01 receipt、P-01 publication、hosted CI、冻结 payload。
- 不是 Architecture 复审（Assignment 为 N/A；本文件不给 Architecture 结论）。
- 不是 Keyboard Extension 联系通道结论（本片确认 Extension **没有** 该通道）。
- 不是 Executor 测试计数的复用；本审查已独立重跑，仍不是 hosted CI。
- 本审查未消耗 AUTH-QUALITY 记录（禁止改 AUTH consumption）。

## 建议的下一步（Human）

1. **Product Gate（另授权）：** 若产品接受 `ABOUT-02`（无本 lane 目视）与脏树身份 `ABOUT-01` 为本片发布前残差，可对 **主 App 关于页** 做 Product Gate；本文件 **不** 代替该 Gate。Gate 前可选产品在 iPhone 17 Simulator 看一眼版本/Build、邮件主题、小红书打开。
2. `ABOUT-01`：commit 须新授权，且只切关于页切片 + 必要文档；commit 后本审查 **不能** 自动钉新 SHA。
3. 可选后续（不要混进本片）：为 Info.plist helper / mailto 无 body 补测试；指南隐私入口是否保留由产品另决。

下一步默认交 **Product Lead（Human Product Gate）**，不是本 lane 继续改 Swift。
