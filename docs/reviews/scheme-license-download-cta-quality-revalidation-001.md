# SCHEME-LICENSE-DOWNLOAD-CTA-QUALITY-REVALIDATION-001 — 独立 Quality revalidation

**Reviewer:** `/root/scheme_license_quality_revalidation`，新鲜独立 GPT-6 Luna runtime；未参与实现或原 P2 测试证据创建。\
**日期：** 2026-09-23（Asia/Shanghai）\
**Assignment / AUTH:** [`SCHEME-LICENSE-DOWNLOAD-CTA-QUALITY-REVALIDATION-001`](../assignments/scheme-license-download-cta-quality-revalidation-001.md) · [`AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-QUALITY-REVALIDATION-001`](../authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-QUALITY-REVALIDATION-001.md)\
**产品合同：** [`PD-SCHEME-LICENSE-DOWNLOAD-CTA-001`](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-authorization.md)

## Verdict

**Pass with conditions（有界）。** 本次绑定实现包符合产品决策；此前 `SLD-CTA-Q-01` 的流程回归缺口已由五条生产路由流程用例补齐，并在本次独立 Debug App + Keyboard 测试中全部通过。strict Swift format lint 通过。旧 Quality receipt 只用于识别历史 findings，本 verdict 独立绑定下述包身份。

本结论只覆盖固定 22-file package、strict lint 与指定 iPhone 17 Pro Simulator 自动测试。9 个非 CTA fixture/设备用例被跳过；不作 XCUITest、人工/真机验收、真实网络下载、真实 RIME 部署、Product Gate、commit / push / PR / merge、TestFlight 或 Release 声明。

## 身份与 package digest

| 项 | 审查前 | 测试后复核 |
|---|---|---|
| Worktree | `/private/tmp/universe-keyboard-scheme-license-download-cta-001` | 同一 worktree |
| Branch | `grok/scheme-license-download-cta-001` | 匹配 |
| HEAD | `80091f35cc5411b292eca78662f39e2b91694045` | 匹配 |
| 22 个固定成员路径 hash | 全部匹配 Assignment 表格 | 全部匹配，未观察到包成员改变 |
| 排序 manifest SHA-256 | `4f097b709ef993b0c81eb879f8d093c99213ae766c8397582a67ff1ada5f9f3e` | 同一 digest |

审核开始时 `git status` 显示隔离 worktree 有意保留的未提交实现、测试和状态镜像文件；不以 dirty status 推断所有权或合并准备情况。审查期间没有改动源码、测试、Assignment、AUTH 或状态镜像；只新增本 receipt。固定包 digest 不含明确排除的 Active Work、Dashboard、本 Assignment/AUTH/receipt 状态记录。

## 源码与测试审查

| 合同 / 关注点 | 观察与结论 |
|---|---|
| 三个首次下载入口只展示许可 sheet | 设置详情 `RimeSettingsView.swift#L241-L246`、启用引导 `ActivationResourcePreparePanel.swift#L193-L202`、九键安装 `KeyboardLayoutSettingsView.swift#L247-L262` 都经 `SchemeLicenseDownloadFlow.requestFirstDownload` 并只产生 `presentLicense`；入口点击没有直接接受许可或启动下载。三个生产入口均使用测试覆盖的共享路由。符合。 |
| sheet 确认先接受再下载 | 三个生产入口都按 `agreeToFirstDownload` 返回的 effect 顺序调用 `acceptLicense`、`startDownload`；设置详情还避免在通用 sheet 回调中提前接受下载许可（`RimeSettingsView.swift#L162-L171`、`#L341-L353`）。符合。 |
| 关闭不接受、不下载 | `SchemeLicenseView` 的关闭 toolbar 与接受后的关闭均经过只返回 `.dismissLicense` 的路由（`LicenseView.swift#L27-L30`、`#L38-L62`）；许可接受/下载只由 `onAccept` 路径触发。符合。 |
| 九键资源缺失时不被历史许可绕过 | `nineKeyRoute` 在资源不存在时返回 `.presentLicense`，不使用 `licenseAccepted` 作 bypass（`SchemeLicenseDownloadCopy.swift#L51-L64`）；安装入口实际读取此 route 并展示同一许可 sheet（`KeyboardLayoutSettingsView.swift#L233-L262`）。符合。 |
| 管理网格、重试及下载引擎边界 | 已安装管理网格仍提供检查更新、重新下载、卸载及许可证动作（`SchemaDownloadContentViews.swift#L97-L142`）；失败重试仍为“重试”并调用原下载入口（`SchemaDownloadContentViews.swift#L74-L94`、`RimeSettingsView.swift#L252-L264`）；`SchemaManager.startDownload` 的可下载方案/已接受许可 guard 未纳入包修改（`SchemaManager.swift#L115-L125`）。符合。 |
| 新增流程回归覆盖生产路由 | `SchemeLicenseDownloadCopyTests.swift` 的五条流程用例检查三入口只展示 sheet、确认顺序、关闭、副作用边界、九键资源缺失且历史已接受，以及既有 ready/installed 路由；生产代码直接调用被测 helper。符合。 |

### 历史 finding 重判

| ID | 本次状态 | 证据 |
|---|---|---|
| `SLD-CTA-Q-01`（P2 流程回归覆盖） | **Resolved for this package** | 五条流程用例真实调用三个生产入口共同使用的 `SchemeLicenseDownloadFlow`，本次 xcresult 中全部 Passed；详见下方。 |
| `SLD-CTA-Q-02`（P3 状态镜像未同步） | **Resolved** | 当前 `docs/ACTIVE_WORK.md#L3` 和 `docs/ENGINEERING_DASHBOARD.md#L29-L35` 均记录本 revalidation Active / 进行中；不再沿用旧 receipt 的历史状态。 |

未发现新的源码或测试 defect。上述 finding disposition 仅针对本次固定 package，不改变父 Assignment 生命周期或任何 Gate 状态。

## 独立验证

### Strict Swift format lint

对 Assignment 列出的九个 Swift 文件执行：

```bash
xcrun swift-format lint --strict --configuration .swift-format \
  "Universe Keyboard/Models/ActivationChecklistState.swift" \
  "Universe Keyboard/Models/SchemeLicenseDownloadCopy.swift" \
  "Universe Keyboard/Views/Guide/ActivationResourcePreparePanel.swift" \
  "Universe Keyboard/Views/License/LicenseView.swift" \
  "Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift" \
  "Universe Keyboard/Views/Settings/RimeSettingsView.swift" \
  "Universe Keyboard/Views/Settings/SchemaDownloadContentViews.swift" \
  "Universe Keyboard/Views/Settings/SchemaSelectionSection.swift" \
  UniverseKeyboardTests/SchemeLicenseDownloadCopyTests.swift
```

**结果：** exit 0；九个文件通过。只运行 lint，未格式化或修改文件。

### Debug App + Keyboard tests

在普通沙箱中按 AUTH 指定命令启动时，xcodebuild 于 package resolution 阶段因 SwiftPM/Clang cache 权限与 CoreSimulator 连接失败而 exit 74，未启动测试。获批受控权限后，同一指定 `-resultBundlePath` 因前次 preflight 留下的目录而 exit 64，仍未启动测试。没有删除产物或重跑同一路径。随后获批以新的独立结果包路径执行了唯一一次实际测试套件；该次完整运行成功：

```bash
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" \
  -configuration Debug \
  -destination 'platform=iOS Simulator,id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2' \
  -derivedDataPath /private/tmp/scheme-license-download-cta-quality-revalidation-derived \
  -resultBundlePath /private/tmp/scheme-license-download-cta-quality-revalidation-run2.xcresult \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
```

| 目标 / 汇总 | 独立 xcresult 结果 |
|---|---|
| `UniverseKeyboardTests` | 379 passed / 9 skipped / 0 failed |
| `KeyboardTests` | 15 passed / 0 skipped / 0 failed |
| xcresult aggregate | 394 passed / 9 skipped / 0 failed（共 403 项） |
| Simulator | iPhone 17 Pro，UDID `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`，iOS 26.0（build `23A343`），arm64 |
| Toolchain | Xcode 27.0（`27A266a`）；iPhoneSimulator SDK 27.0 |
| 结果包 | `/private/tmp/scheme-license-download-cta-quality-revalidation-run2.xcresult` |

以下五条流程用例均在 `UniverseKeyboardTests` target **Passed**：

- `testFirstDownloadRequestOnlyPresentsLicenseForEveryEntryPoint`
- `testLicenseAcceptancePrecedesDownloadForEveryEntryPoint`
- `testDismissOnlyDismissesTheLicenseSheet`
- `testNineKeyMissingResourcesStillRequiresLicenseAfterPriorAcceptance`
- `testNineKeyRoutePreservesReadyAndInstalledResourcePaths`

同文件的两条共享文案测试也均 Passed。9 个 skip 为依赖外部 fixture 的 6 项方案资源测试，以及仅物理设备可执行的 3 项 TD-012 测试；无 CTA 用例被跳过。xcresult summary 与 test tree 的 target 数相符。

测试后再次核对 branch、HEAD、22 个成员哈希与排序 manifest digest，全部仍与 Assignment 一致。

## Skipped / 非声明

- 未运行 XCUITest、人工 Simulator 操作、真机验收、真实网络下载、真实 RIME 部署或部署后验证。
- 未运行其他独立 CI 门禁、Release build、Product Gate 或 Release Gate；本 AUTH 只要求 strict lint 与 Debug App + Keyboard tests。
- 本 receipt 不授权修复、状态同步、提交、推送、PR、合并、TestFlight、Release 或清理 branch/worktree。

## 生命周期边界

此 receipt 仅为绑定包的独立 Quality 证据。Product Gate、实现 Assignment Close、publication 与 Release 仍各自分离；源码/测试、Product Decision、branch/HEAD、22-file digest 或 review scope 变化将使本结论失效。
