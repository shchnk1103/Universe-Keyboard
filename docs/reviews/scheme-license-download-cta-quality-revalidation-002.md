# SCHEME-LICENSE-DOWNLOAD-CTA-001 — 独立 Quality revalidation 002

**审查日期：** 2026-09-24（Asia/Shanghai）\
**Reviewer / Environment Executor：** `/root/scheme_license_quality_revalidation_d614b8e`，新鲜独立 GPT-6 Luna runtime；未参与实现或原证据编写。\
**Assignment / AUTH：** [`SCHEME-LICENSE-DOWNLOAD-CTA-QUALITY-REVALIDATION-002`](../assignments/scheme-license-download-cta-quality-revalidation-002.md) · [`AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-QUALITY-REVALIDATION-002`](../authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-QUALITY-REVALIDATION-002.md)\
**Product Decision：** [`PD-SCHEME-LICENSE-DOWNLOAD-CTA-001`](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-authorization.md)

## Verdict

**Pass（有界）。** 对精确绑定的 22-file package，首次下载许可流程符合 Product Decision；`SLD-CTA-Q-01` 的共享生产流程回归缺口已由本包的五条流程测试覆盖，`SLD-CTA-Q-02` 的状态镜像也已显示本次 revalidation 正在进行。9 个 Swift 文件 strict lint 通过，App + Keyboard Debug 测试通过，未发现新的阻断 Quality finding。

本结论仅覆盖下列 commit、manifest digest、所审源码/文档和自动化验证。**不**代表 Product Gate、Release Gate、人工/真机 UI 验收、真实网络下载、RIME 部署、commit、push、PR、merge、TestFlight 或 Release 通过。

## 精确身份与审查输入

| 项 | 审查前 / 审查后核验值 |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-scheme-license-download-cta-001` |
| Branch | `grok/scheme-license-download-cta-001` |
| HEAD | `d614b8e03006ff305137754ac118e50445938068` |
| Parent | `a9b82a58cac0c28e8a5d8a957d464d803d6d92d1` |
| Package members | 22；审查前、测试后每个 SHA-256 均匹配 Assignment 表格 |
| 排序 manifest SHA-256 | `6146c454c0f0305f0f6055bbe141db8e1473fc6c99657c525f11bb3b3ef6fe39`；按 UTF-8 路径字节排序的 `path<TAB>file-sha256<LF>` 计算，审查前后相同 |
| 审查前后 git status | 仅 `docs/ACTIVE_WORK.md`、`docs/ENGINEERING_DASHBOARD.md` 两个授权治理镜像为 modified；本 Assignment/AUTH 为 untracked。没有源码、测试、工程或 CI 变更 |

首次运行普通沙箱命令因 CoreSimulator 连接及 SwiftPM/Clang 用户缓存访问限制，在测试前的依赖解析阶段退出（exit 74）。按 AUTH 使用完全相同的唯一命令、Simulator、DerivedData 与 xcresult 路径升级运行后成功。升级调用先遇到普通调用产生的未完成 xcresult 包；确认该包无可读测试结果后，仅清除该失败调用生成的临时包，再以同一指定路径运行一次。成功调用 exit 0；没有更换路径或重跑测试。

## 产品合同与源码路径复核

已对照 Product Decision、父 Assignment、UI Style Guide、CHANGELOG、handoff、回归测试 Assignment/AUTH、既有 Quality receipt、测试计数对账记录，以及绑定 package 中相关视图、模型与测试。

| 合同路径 | 当前源码 / 自动化覆盖 | 判定 |
|---|---|---|
| 设置方案详情首次下载 | `SchemaDownloadCardView` 的唯一主按钮使用共享「查看许可并下载」文案并只调用 `onShowLicense`；`RimeSettingsView` 对 `.download` 只构造既有 `SchemeLicenseView` presentation | 符合；未在卡片启动下载 |
| 启用引导准备资源 | 可下载且未安装时显示同一共享 CTA；点击调用许可页呈现路由。sheet 确认回调使用所选 schema 执行接受与下载效果 | 符合 |
| 九键缺资源与历史接受 | `nineKeyRoute` 在 `resourcesExist == false` 时返回 `.presentLicense`，不依据 `licenseAccepted` 绕过。仅资源已存在且 readiness 不匹配时走已安装资源准备；已 ready 路径仍可直接返回 | 符合；无缺资源时因历史接受状态直接下载的路径 |
| 确认顺序与关闭副作用 | 所有入口的确认回调消费共享效果序列：先 `.acceptLicense`，再 `.startDownload`；许可证页关闭 action 只执行 dismiss，接受按钮才调用 `onAccept` 后 dismiss | 符合 |
| 文案共享 | 设置详情卡、启用引导、九键许可 sheet 和 `ActivationCopy` alias 读取 `SchemeLicenseDownloadCopy` | 符合 |
| 已安装管理及失败重试 | 管理网格仍为「检查更新 / 重新下载 / 卸载 / 许可证」；失败路径仍为「重试」/「重试下载」，由原独立 action 处理 | 符合；不属于首次下载 CTA |
| 旧/遗留调用点 | `SchemaSelectionSection` 复用共享下载卡；代码 diff 不改变 SchemaManager、许可存储、下载/部署引擎或 Keyboard Extension | 符合范围边界 |

### 历史 Quality findings

| Finding | 本次复判 |
|---|---|
| `SLD-CTA-Q-01`（P2，流程边界自动回归不足） | **已解决于共享生产流程逻辑层。** `SchemeLicenseDownloadFlow` 是三个生产入口实际调用的纯路由/效果 owner；新增五条测试覆盖三入口首次请求仅呈现许可页、确认先接受后下载、关闭仅 dismiss、九键缺资源时历史接受仍呈现许可，以及已 ready/已有资源路由保留。五条均在本次 xcresult 中通过。该覆盖不模拟 SwiftUI 点击，也不执行网络下载或 RIME 部署；这些仍是明确非声明。 |
| `SLD-CTA-Q-02`（P3，状态镜像未同步 live Quality AUTH） | **已解决。** 当前 `ACTIVE_WORK` 与 Dashboard 将 `d614b8e` 的独立 Quality revalidation 表述为进行中、尚未出结论；与当前 live AUTH 一致，不再写 Quality 未授权。 |

## 独立验证

### Swift strict format

仅 lint、未 format；对 Assignment 指定的全部 9 个 Swift 文件执行：

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

**结果：** exit 0；9 个文件全部通过。

### App + Keyboard Debug

```bash
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug -destination 'platform=iOS Simulator,id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2' -derivedDataPath /private/tmp/scheme-license-download-cta-quality-revalidation-d614b8e-derived -resultBundlePath /private/tmp/scheme-license-download-cta-quality-revalidation-d614b8e.xcresult CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
```

- **成功结果包：** `/private/tmp/scheme-license-download-cta-quality-revalidation-d614b8e.xcresult`
- **独立 DerivedData：** `/private/tmp/scheme-license-download-cta-quality-revalidation-d614b8e-derived`
- **Simulator：** iPhone 17 Pro，UDID `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`，iOS 26.0，build `23A343`，arm64。
- **Toolchain：** Xcode 27.0（build `27A266a`）；Swift 6.4.0（`swift-driver 1.168.6`，`swiftlang-6.4.0.34.1`）；iPhoneSimulator SDK 27.0；xcresult 环境描述为 macOS 27.0。

| Target / aggregate | Passed | Skipped | Failed | Total |
|---|---:|---:|---:|---:|
| `UniverseKeyboardTests` | 379 | 9 | 0 | 388 |
| `KeyboardTests` | 15 | 0 | 0 | 15 |
| xcresult aggregate | 394 | 9 | 0 | 403 |

下列五条许可流程用例均为 `Passed`：

- `testFirstDownloadRequestOnlyPresentsLicenseForEveryEntryPoint`
- `testLicenseAcceptancePrecedesDownloadForEveryEntryPoint`
- `testDismissOnlyDismissesTheLicenseSheet`
- `testNineKeyMissingResourcesStillRequiresLicenseAfterPriorAcceptance`
- `testNineKeyRoutePreservesReadyAndInstalledResourcePaths`

9 个跳过项没有 CTA 定向用例：6 项依赖独立下载的方案源归档、固定 Ice/Wanxiang 提取树或固定 `default.yaml` fixture；另 3 项是 TD-012 G2 明确限定为 physical-device-only 的 staging、model-load 与 cleanup 用例。xcresult summary 的结果为 `Passed`，没有失败或预期失败。

## 变更与非声明

审查期间没有修改任何 package member、源码、测试、工程或 CI 文件；测试后再次核对 HEAD、parent、全部 22 个成员摘要、manifest digest 与 git status，均与审查前身份一致。唯一新增审查文件为本 receipt。

未执行 XCUITest、人工 UI/真机验收、真实网络下载、RIME 部署、KeyboardCore 独立套件、RimeBridgeTests、Release build、hosted CI、Product Gate 或 Release Gate；这些不属于当前 AUTH。Simulator 运行日志含 App Group entitlement 诊断信息，但 xcresult 对应测试目标均通过；因此本记录不将其扩大为共享容器/真实设备行为证明。

本 receipt 的结论只绑定 `d614b8e03006ff305137754ac118e50445938068` 与 manifest digest `6146c454c0f0305f0f6055bbe141db8e1473fc6c99657c525f11bb3b3ef6fe39`。任何绑定成员、branch/HEAD、审查范围或 reviewer identity 变化都会触发重新审查。
