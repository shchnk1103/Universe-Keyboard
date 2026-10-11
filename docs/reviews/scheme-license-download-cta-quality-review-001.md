# SCHEME-LICENSE-DOWNLOAD-CTA-001 — 独立 Quality Review

**Reviewer:** `/root/scheme_license_quality`，GPT-6 Luna 独立 runtime；未参与实现或 Executor 测试证据。
**日期：** 2026-09-23（Asia/Shanghai）
**Assignment / AUTH:** [`SCHEME-LICENSE-DOWNLOAD-CTA-QUALITY-001`](../assignments/scheme-license-download-cta-quality-review-001.md) · [`AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-QUALITY-001`](../authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-QUALITY-001.md)
**产品合同：** [`PD-SCHEME-LICENSE-DOWNLOAD-CTA-001`](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-authorization.md)
**范围：** 对未提交 CTA 快照做只读源码/测试审查、变更 Swift 严格格式 lint、独立 Debug App + Keyboard tests。只写入本 receipt；未修改源码、测试、既有证据、Assignment 或 AUTH。

## Verdict

**Pass with conditions（有界）。** 源码路径符合本次产品合同；独立格式与 App + Keyboard 测试通过。保留两个条件：P2 自动回归测试尚未直接锁住许可 sheet 的副作用边界；P3 Active Work / Dashboard 在 Quality AUTH 已 live 后仍显示“Quality 尚未授权”。两项均列入 findings 与 disposition。

本结论只覆盖下述精确未提交快照。**不**是 Architecture、Product Gate、Release Gate、真机/用户验收、真实下载/部署、commit / push / PR / merge、TestFlight 或 Release 结论。

## 身份与精确输入绑定

| 项 | 审查时核实值 |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-scheme-license-download-cta-001` |
| Branch | `grok/scheme-license-download-cta-001` |
| HEAD | `80091f35cc5411b292eca78662f39e2b91694045` (`origin/main`) |
| 实现快照 status SHA-256 | `aca7f82f737e20b59c9a60f05224ac0e326f4ec97a6f06e8624d3b59adcd5f7b`，使用 AUTH 指定 pathspec 排除本 review Assignment、AUTH、receipt 三条记录 |
| tracked `git diff HEAD` SHA-256 | `e5e3138005997fa4a2815ac182bdf585e19af23865ef02072198ed2ba9e15257` |

| 绑定源码 / 测试文件 | SHA-256 |
|---|---|
| `Universe Keyboard/Models/ActivationChecklistState.swift` | `681f3ee517ef97a6cc27041596dcd42666cdaa4713c371808569f9d08a1c230b` |
| `Universe Keyboard/Models/SchemeLicenseDownloadCopy.swift` | `97d893792c1b707e1e84bda7c50c3b1e177a091d6cb420c81071c14932d25262` |
| `Universe Keyboard/Views/Guide/ActivationResourcePreparePanel.swift` | `641facd8fc2fb281be2afecb64ff9a23089c7d6b7a5ed5ae75ac4178f19cf2cb` |
| `Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift` | `11cf1465e07fba7601bdf365a90a352b95e1898ab91435e8647ec0c10421382b` |
| `Universe Keyboard/Views/Settings/RimeSettingsView.swift` | `338ea19674d767e883070f24a42d7ad92d717a2dd3980014b0a54de944a06491` |
| `Universe Keyboard/Views/Settings/SchemaDownloadContentViews.swift` | `53c52066a9b7adeb052b89cd9396a5b2c9e07f7f35f0e51f9961932e09be1d0f` |
| `Universe Keyboard/Views/Settings/SchemaSelectionSection.swift` | `5c80979ebc03ee9905ebed9598d0545436e4e579e8d06276664458fafe87a865` |
| `UniverseKeyboardTests/SchemeLicenseDownloadCopyTests.swift` | `1c93fef092efd35721d3b5942733fe80eec6c63eb598220980f9dd61fb1614d3` |

以上身份与哈希在开始审查前、测试结束后均独立核对并匹配 Assignment/AUTH。审查期间未观察到实现快照变化。

## 源码与合同核对

| 不变量 | 独立观察 | 结论 |
|---|---|---|
| 首次下载 CTA 只打开既有许可证 sheet | 详情卡只调用 `presentLicense(.download, schema:)`（`RimeSettingsView.swift#L237-L245`）；启用引导 CTA 只设置 `presentedLicense`（`ActivationResourcePreparePanel.swift#L180-L194`）；`SchemaDownloadCardView` 只有共享主按钮和 `onShowLicense`（`SchemaDownloadContentViews.swift#L3-L45`） | 符合 |
| 只有确认才接受并开始下载 | 详情页 sheet 的 `onAccept` 先 `acceptLicense` 再分派 `.download`（`RimeSettingsView.swift#L162-L170`、`#L316-L329`）；引导 sheet 回调同样按此顺序（`ActivationResourcePreparePanel.swift#L110-L119`） | 符合 |
| 关闭不下载 | `SchemeLicenseView` 的关闭 toolbar action 仅执行 `dismiss()`；接受和 dismiss 位于底部接受按钮的独立回调（`LicenseView.swift#L27-L50`） | 符合 |
| 九键首次安装及历史接受状态 | 缺少雾凇安装资源时始终构造 `PresentedSchemeLicense` 并 return；不根据旧接受状态启动下载（`KeyboardLayoutSettingsView.swift#L82-L91`、`#L219-L235`）。下载成功后才继续启用九键（`#L93-L105`） | 符合 |
| 文案共享 | 共享 owner 定义两个锁定字符串；设置详情、启用引导、九键 sheet 与 `ActivationCopy` alias 使用该 owner（`SchemeLicenseDownloadCopy.swift#L1-L7`） | 符合 |
| 已安装管理仍独立 | 管理网格仍保留检查更新、重新下载、卸载、许可证动作（`SchemaDownloadContentViews.swift#L97-L149`）；新增 `.download` action 不替换管理动作 | 符合 |
| 下载引擎 / Keyboard Extension 不受本 diff 影响 | `git diff --name-only HEAD` 中没有 `SchemaManager`、`Keyboard/` 或 Extension 源文件；`SchemaManager.startDownload` 仍要求方案可下载且当前许可已接受（`SchemaManager.swift#L115-L125`） | 符合 |
| 相关测试 | 新测试锁定共享文案与 ActivationCopy alias；现有 `SchemaManagerTests` 覆盖许可按方案隔离、旧 revision 失效与未接受许可时下载 fail closed（`SchemaManagerTests.swift#L147-L193`） | 部分覆盖，见 `SLD-CTA-Q-01` |

已读产品决策、CTA Assignment/AUTH、Grok handoff、`AGENTS.md`、`UI_STYLE_GUIDE.md`、`RIME_SCHEME_MANAGEMENT.md`、方案资源归属计划、ADR 0034、测试发布 playbook。指南与 CHANGELOG 描述的 CTA 合同与实现一致。Full Access「我已开启，继续」不属于本 Assignment，未复核。

## 独立验证

### Swift 格式

对全部 8 个变更 Swift 文件执行 strict lint（仅 lint，未 format）：

```bash
xcrun swift-format lint --strict --configuration .swift-format \
  "Universe Keyboard/Models/ActivationChecklistState.swift" \
  "Universe Keyboard/Models/SchemeLicenseDownloadCopy.swift" \
  "Universe Keyboard/Views/Guide/ActivationResourcePreparePanel.swift" \
  "Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift" \
  "Universe Keyboard/Views/Settings/RimeSettingsView.swift" \
  "Universe Keyboard/Views/Settings/SchemaDownloadContentViews.swift" \
  "Universe Keyboard/Views/Settings/SchemaSelectionSection.swift" \
  UniverseKeyboardTests/SchemeLicenseDownloadCopyTests.swift
```

**结果：** exit 0；8 个文件通过。

### Debug App + Keyboard

使用 XcodeBuildMCP 独立 profile 和 DerivedData `/private/tmp/scheme-license-download-cta-quality-derived`。发现 iPhone 17 Pro（iOS 26.0）已 boot，另有 iPhone 18 Pro / iPhone 17 Pro Max boot；为避免干扰任何用户模拟器，选择关机的等价 iPhone 17（iOS 26.0，UDID `D3C353BE-3AA6-499B-8F87-349073D65BE4`）。Xcode `27.0 (27A266)`，Apple Silicon `arm64`；构建 SDK 为 iPhoneSimulator 27.0。

有效构建调用（严格 Swift 6 参数与独立 DerivedData）：

```bash
xcodebuild -project "/private/tmp/universe-keyboard-scheme-license-download-cta-001/Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" -configuration Debug \
  -destination "platform=iOS Simulator,id=D3C353BE-3AA6-499B-8F87-349073D65BE4" \
  -derivedDataPath /private/tmp/scheme-license-download-cta-quality-derived \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 \
  SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build-for-testing
```

随后对同一 `.xctestproducts` 执行 `test-without-building`，同样传入上述 Swift 6 参数与 destination；`xcodebuild` 输出为 `** TEST EXECUTE SUCCEEDED **`。

| Target / 总计 | 结果 |
|---|---|
| `UniverseKeyboardTests` | 383 executed：374 passed、9 skipped、0 failed |
| `KeyboardTests` | 15 executed：15 passed、0 skipped、0 failed |
| `.xcresult` 汇总 | 389 passed、9 skipped、0 failed；total 398 |
| 独立测试日志 | `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-23T13-07-45-976Z_pid76569_23915d9e.log` |
| `.xcresult` | `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T13-07-45-977Z_pid76569_18fd20e3.xcresult` |

9 项跳过均来自现有条件：需外部固定 Ice/Wanxiang 测试归档或提取树的 fixture 用例，及 3 项仅允许在物理设备上执行的 TD-012 用例；没有 CTA 定向用例被跳过。XcodeBuildMCP 的 discovery 文本报 399 test(s)，但 `.xcresult` 精确汇总 398 项（389 pass + 9 skipped）；本 receipt 以 `.xcresult`/target 日志作为实际执行计数。

## Findings / residuals

| ID | 严重度 | Finding | Owner | Disposition |
|---|---|---|---|---|
| `SLD-CTA-Q-01` | P2 | 新增 `SchemeLicenseDownloadCopyTests` 仅断言文案和 alias（`SchemeLicenseDownloadCopyTests.swift#L5-L20`）。既有测试验证服务层许可门禁，但没有回归测试证明三种 UI 入口点击时不接受/不下载、sheet 确认按所选 schema 接受后才下载、关闭不产生副作用，或九键资源缺失且历史许可已接受时仍先呈现 sheet。源码审查确认当前实现符合这些不变量；此项是测试强度缺口，不是观察到的行为错误。 | App & Data Operations Maintainer / 后续测试 Assignment | `fix`：后续授权的 UI/流程回归测试应覆盖上述边界；本 reviewer 不改测试。 |
| `SLD-CTA-Q-02` | P3 | `docs/ACTIVE_WORK.md#L3` 仍写 Independent Quality 未授权，`docs/ENGINEERING_DASHBOARD.md#L16` 仍称 Quality 尚未授权；本次 Quality AUTH 已为 `live`。状态镜像待协调者同步。 | Coordinator | `fix`：本 review 结束后按 KOS M-02 更新状态镜像；本 reviewer 不改这些文件。 |

## Skipped / non-claims

- 未运行 Quality validator、Product Gate、Architecture/Release Gate、KeyboardCore 独立套件、RimeBridgeTests、Release build 或 hosted CI；当前授权仅要求本次 strict format lint 与 App + Keyboard Debug tests。
- 未执行真机测试、用户 UI 操作、真实 RIME 下载/部署或 Full Access 验收。
- 未复核或处理启用引导「我已开启，继续」运行时问题。
- 未修改、commit、push、创建 PR、merge、发布或清理分支/worktree；这些动作仍未授权。

## 生命周期边界

本 receipt 是当前绑定快照的独立 Quality 结果；实施 Assignment 仍应按生命周期源记录处理。上述任一源码/测试、Product Decision、分支/HEAD、绑定 digest 或 reviewer identity 变化都会使本结论失效。Product Gate、发布及所有外部动作仍需各自授权。
