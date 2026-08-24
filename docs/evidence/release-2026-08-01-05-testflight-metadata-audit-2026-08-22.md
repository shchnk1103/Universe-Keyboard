# RELEASE-2026-0801-05 — 外部 TestFlight 元数据与合规审计

> **Evidence grade:** `Executor-recorded`  
> **Collected:** `2026-08-22 Asia/Shanghai`  
> **Repository base:** `main` at `4fd3ce70d9acfc54472923fb7d66ff0589e11f6d`；审计开始时工作区干净  
> **Authority:** Human Product Owner 在当前 Codex 任务中授权只读审计、补齐可证明的外部 TestFlight 信息，并按 KOS 更新交接文档  
> **Assignment:** [`RELEASE-2026-0801-05`](../assignments/release-2026-08-01-05-app-store-materials.md)

## Scope

- 审计 App Store Connect 中外部 TestFlight、App 信息、App 隐私与 `1.0` 版本页面的当前字段状态。
- 只写入由仓库事实与已完成测试支持、且不需要猜测个人或法律答案的 TestFlight 文案。
- 对隐私、出口合规、内容版权、年龄分级与联系人字段保留明确的人类 Gate。
- 不上传构建、不创建测试组、不添加测试员、不提交 TestFlight App Review 或 App Store Review，不冻结 RC。

## Account And Build Snapshot

| Item | Observed value |
|---|---|
| App | `Universe Keyboard` |
| Apple ID | `6804236252` |
| Bundle ID | `com.DoubleShy0N.Universe-Keyboard` |
| Primary language | 简体中文 |
| App version record | `1.0`，状态“准备提交” |
| TestFlight builds | 无；页面仍显示“提交构建版本以开始测试” |
| Cloud Archive pilot | Build 3，workflow `Archive Pilot (No Distribution)`，`main` / `4fd3ce7` |
| Cloud environment | Xcode 26.6 (`17F113`) / macOS Tahoe 26.6.2 (`25G83`) |
| Cloud result | `Archive - iOS` 成功，App Store distribution signing 成功；无 TestFlight distribution/post-action |
| Build record | [App Store Connect Build 3](https://appstoreconnect.apple.com/teams/82c0e48e-c8bf-442c-9db9-19ed80ce4d87/apps/6804236252/ci/builds/6aec0bbf-6bbe-4cd3-81b5-8382f2d3898d/summary) |

该 Cloud 结果证明当前 `main` 的稳定工具链 Archive/签名路径可行；它不是冻结 RC、最终 archive/dSYM retention、上传或 TestFlight smoke 证据。

## TestFlight Test Information

| Field | Online state after this run | Disposition |
|---|---|---|
| Show approved screenshots/category | 开启 | Preserved；当前没有“可分发”App Store 版本，因此没有可展示素材 |
| Beta App Description | 已保存 | Executor-recorded；见下方固定文本 |
| Feedback Email | 空 | `UNKNOWN — Human Product Owner input required` |
| Marketing URL | 空 | Optional；公开站点上线后再决定 |
| Privacy Policy URL | 空 | `BLOCKED — verified public HTTPS URL required` |
| Review contact last/first name | 空 | `UNKNOWN — Human Product Owner input required` |
| Review contact phone | 空 | `UNKNOWN — Human Product Owner input required` |
| Review contact email | 空 | `UNKNOWN — Human Product Owner input required` |
| Login required | 关闭 | Correct：产品没有账户系统 |
| Review Notes | 已保存 | Executor-recorded；见下方固定文本 |
| Custom beta license agreement | 空 | Apple 标准协议保持不变；未创建自定义协议 |
| What to Test | 尚不可填 | Build-specific；上传候选构建后填写，当前无 TestFlight build |

### Saved Beta App Description

```text
Universe Keyboard 是一款基于 RIME 的 iOS 第三方中文输入法。输入处理在设备本地完成，支持 26 键与九宫格中文输入、候选与拼音路径选择、输入方案准备及本地个性化设置。

本次 Beta 重点验证首次启用流程、完全访问开启或关闭时的真实降级、基础中英文输入、候选选择、九宫格、横竖屏、iPad、深色模式与 VoiceOver。
```

### Saved Beta Review Notes

```text
本 App 无账户系统，无需登录。

测试步骤：
1. 启动主 App，打开“帮助”中的启用指南。
2. 按指南在系统设置中添加“Universe Keyboard — RIME 中文输入法”。
3. 返回 App，选择并准备输入方案。九宫格需安装支持九宫格的方案（例如雾凇拼音）。
4. 如需验证共享方案、设置、本地词典与反馈，请在系统键盘设置中开启“允许完全访问”。完全访问用于访问主 App 与键盘共享的本地 App Group 数据，不用于上传按键内容。
5. 在 App 的“搜索”输入框或任意系统文本框切换至 Universe Keyboard，测试 26 键或九宫格输入、候选选择、删除、横竖屏及深色模式。

注意：
- 键盘输入不要求账户，也不依赖开发者服务器。
- 未开启完全访问时，基本输入通常仍可用，但共享资源、设置和反馈可能不可用或不可靠。
- 可下载方案通过用户主动操作从 GitHub 获取。
- 当前 Beta 不需要提供用户名或密码。
```

### Prepared Build-Specific What To Test

以下只是待上传候选构建的模板，不得在 RC/build 未冻结前声称已经绑定到某个 build：

```text
请重点测试：
1. 首次安装后的键盘添加、方案准备与“允许完全访问”引导；验证“稍后再开启”仍可继续方案选择。
2. 完全访问关闭时的基础输入，以及开启后的共享方案、设置、本地词典和反馈。
3. 26 键与九宫格中文输入：组合下划线、候选选择、拼音路径、删除与提交后状态清理。
4. 竖屏/横屏、iPhone/iPad、浅色/深色模式与 VoiceOver。
5. 宿主 App 切换、键盘重新出现和连续输入稳定性。

反馈时请附上设备型号、iOS/iPadOS 版本、键盘布局、输入方案、完全访问状态和复现步骤；请勿发送私人输入内容。
```

## Compliance And App Information Audit

| Area | Current observation | KOS disposition |
|---|---|---|
| Privacy policy publication | 主仓库 `docs/PRIVACY_POLICY.md` 是当前源；`UniverseWeb` 已有 `/[locale]/privacy/` 页面代码，但 metadata 使用 `https://universekeyboard.example`，未发现已验证生产域名 | Blocked；部署并验证公开 HTTPS URL 后才能填写 |
| App Privacy questionnaire | App Store Connect 尚未开始；主 App/Extension privacy manifests 均为 `NSPrivacyTracking=false`、空 `NSPrivacyCollectedDataTypes` | Candidate answer is “No data collected”；仍需 Architecture/privacy review 与 Human Product Owner 公开声明确认，不在本次点击“发布” |
| Required Reason APIs | Main App: UserDefaults `CA92.1`/`1C8F.1`、FileTimestamp `C617.1`、DiskSpace `E174.1`；Extension: UserDefaults `1C8F.1`、FileTimestamp `C617.1` | Present in both bundled manifests；final archive must reverify bundle inclusion |
| Export compliance | App 使用 CryptoKit authenticated encryption for optional settings sync；`config/Info.plist` 未设置 `ITSAppUsesNonExemptEncryption` | `UNKNOWN — legal/export determination required`；不得由 agent 猜测豁免或上传文稿结论 |
| Content rights | Human Product Owner 报告已保存“是，App 包含或访问第三方内容且拥有必要权利” | Human-reported save；执行方未打开 App Store Connect 复核 |
| Primary category | Human Product Owner 报告已保存主要 `工具`、次要 `效率` | 与 Codex 书面建议一致。执行方未打开 App Store Connect 复核 |
| Age rating | Human 后续完成问卷；页面显示全球 `4+` 及地区等效等级 | Human-confirmed complete；若功能/内容范围变化则重答 |
| DSA trader status | 页面显示开发者声明“不是交易商” | Existing account-level fact only；本次未改 |
| China mainland ICP | 未设置 | Availability decision dependent；若计划在中国大陆提供，需要 Human/legal follow-up |
| License agreement | Apple 标准许可协议 | Preserved |

Apple 当前说明要求外部测试提供 Beta 描述、反馈邮箱与 TestFlight App Review 信息；首次外部 build 需要 review。隐私政策 URL 对 iOS App 必填，App Privacy 回答必须覆盖开发者与集成第三方的实际数据实践。出口合规由开发者负责判定。参考：

- [Provide test information](https://developer.apple.com/help/app-store-connect/test-a-beta-version/provide-test-information/)
- [Invite external testers](https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers)
- [Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy)
- [App privacy details](https://developer.apple.com/app-store/app-privacy-details/)
- [Overview of export compliance](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance)

## App Store 1.0 Future-Gate Snapshot

These fields are not required to finish the current TestFlight test-information page, but they remain blockers before App Store submission:

- iPhone screenshots `0/10`；iPad screenshots not prepared.
- Promotional text, description, keywords, support URL, marketing URL and copyright are empty.
- No uploaded build is attached.
- App Store Review “需要登录” is currently **checked**, although the product has no account system; correct it before App Store submission, not by inferring that this TestFlight task authorized the whole version page.
- App Store version release is currently set to automatic; final release-control choice remains a separate Human Product Owner decision.

## Human Input Gate

The next account-writing turn must receive or verify all required values below before the Assignment may claim external-review metadata complete:

1. Feedback email visible to testers.
2. Beta Review contact: first name, last name, phone and email.
3. Public privacy policy HTTPS URL; optional marketing/support URL decision.
4. Human confirmation of App Privacy answer after Architecture/privacy review.
5. Export-compliance determination for CryptoKit-based authenticated encryption and the correct Info.plist/App Store Connect answer.
6. Content-rights answer for bundled/downloadable RIME ecosystem assets.
7. Primary category and age-rating answers.
8. Exact candidate version/build and approved build-specific What to Test copy after RC freeze/upload authorization.

## Subsequent Privacy And Export-Compliance Update — 2026-08-23

### Human-confirmed online completion

- Human Product Owner confirmed the TestFlight feedback email and Beta Review first name, last name, phone and email were re-entered and saved. Values are intentionally omitted from repository evidence.
- Human Product Owner confirmed the public privacy URL was saved in App Privacy and the App Privacy answer **No data collected** was published.
- The public privacy-page cleanup is being handled independently in `UniverseWeb`; this repository update does not claim that cleanup has been deployed or reverified.

### Read-only App Store Connect observation

- App Information still shows no App Encryption Documentation record.
- Primary category and Content Rights were later reported saved by Human Product Owner; see the 2026-08-23 content-rights update. This snapshot line is historical.
- Human Product Owner subsequently confirmed the age-rating questionnaire was completed. App Store Connect displays a global `4+` rating with regional equivalents (including Brazil `AL`, Korea `全部`, Vietnam `00+`); the gate reopens if the product content or feature scope changes.

### Encryption implementation audit

- The shipping main-App sync path uses Apple `CryptoKit` `ChaChaPoly` (`ChaCha20-Poly1305`) with a 256-bit device-generated key to protect the user-directed private settings package.
- HTTPS is provided through Apple `URLSession`; credentials and the content key use Apple Keychain APIs. Other audited `CryptoKit` imports use SHA-256 digests, not an additional encryption implementation.
- No proprietary or non-standard algorithm implementation was found. No linked RIME vendor archive exposed unresolved OpenSSL, CommonCrypto, CryptoPP, libsodium, AES, ChaCha or SSL encryption symbols in the bounded iOS-arm64 archive scan.
- On `2026-08-23 Asia/Shanghai`, after explicit Human Product Owner authorization, `config/Info.plist` was updated to contain `ITSAppUsesNonExemptEncryption = NO`.

### Determination and remaining human/legal boundary

Apple states that `ITSAppUsesNonExemptEncryption` may be `NO` when an app uses no encryption or only encryption exempt from documentation requirements, and that encryption built into the operating system is typically exempt from document upload. Based on the audited implementation, the repository-supported recommendation is:

```text
ITSAppUsesNonExemptEncryption = NO
Do not upload App Encryption Documentation for the current implementation.
```

This is a technical classification recommendation, not a legal guarantee. Apple notes that exempt encryption may still create a year-end U.S. self-classification reporting obligation. Human Product Owner remains responsible for that legal/export obligation and for revalidation if the algorithm implementation, linked libraries, sync architecture or distribution territories change.

After the read-only determination, the Human Product Owner separately authorized the recommended declaration. The source plist passed `plutil` validation; an Xcode 27 beta Release build for generic iOS Simulator succeeded, and the built App plist resolves the key to `false`. This confirms local integration only and does not replace final stable Xcode Cloud/RC evidence. No encryption documentation, build or review submission was uploaded.

## Handoff

- **Current lifecycle:** `Active — TestFlight contacts/privacy/export/age/content-rights/category complete; screenshots/copy/What to Test pending`.
- **Completed:** no-distribution Cloud Archive/signing pilot; App Store Connect field audit; Beta description and Review Notes; Human-confirmed TestFlight contacts; public privacy URL; published `No data collected` privacy answer; bounded export-compliance technical audit; authorized `ITSAppUsesNonExemptEncryption = NO`; age questionnaire; per-scheme license disclosure implementation and persistent open-source notice surface; Phase A receipt acceptance; Human-reported content-rights “Yes”, primary category `工具` and secondary category `效率`.
- **Blocked:** build-specific What to Test and all upload/review actions. The possible annual self-classification obligation remains a Human legal residual, not a repository execution blocker.
- **Next owner:** Remaining materials (screenshots, store copy, What to Test) wait on RC freeze/upload. Human retains the export legal residual and revalidation duty.
- **Revalidation:** rerun this audit if App Store Connect requirements, release scope/binary, privacy behavior, website URL, dependency inventory or target build changes.

## Subsequent Content-Rights And License-Disclosure Update — 2026-08-23

### First-principles finding

The App bundles or lets the user download third-party input content and runtime components. Therefore the content-rights question cannot truthfully be answered as if the App contains only first-party material. The implementation must make the actual source, license and local modification boundary available for each project; one generic hard-coded dialog is insufficient.

### Implemented repository boundary

- `ThirdPartyLicenseDescriptor` is the auditable source of project name, license, attribution, usage/modification note, upstream links and acknowledgement revision.
- `RimeSchemeCatalogEntry` owns the descriptor for each downloadable scheme. Rime-ice declares `GPL-3.0-only`; Wanxiang declares `CC BY 4.0`.
- Download, update and redownload flows present the selected scheme with `.sheet(item:)`, then accept and start that same scheme. Views contain no scheme-specific legal body.
- Acceptance is fail-closed in `SchemaManager.startDownload` and `forceRedownload`, and persists the current per-scheme disclosure revision. A changed revision requires renewed confirmation.
- Historical rime-ice Boolean acceptance migrates because the old dialog showed rime-ice. Historical Wanxiang Boolean acceptance deliberately does not migrate because the old shared dialog displayed the wrong project.
- Settings now includes “开源软件与内容” for durable access to downloadable schemes, bundled Luna Pinyin content and packaged RIME ecosystem components.
- Links open only after an explicit action in the main App. The Keyboard Extension does not fetch license pages or add a network path to the typing hot path.

The App now bundles offline license/copyright/attribution documents for every catalogued downloadable scheme, bundled input resource and binary dependency. Retained clean build trees and byte-identical device archives recovered exact inputs for librime, glog, LevelDB, yaml-cpp, OpenCC, MARISA and Boost; shipped headers plus the official source-package checksum fix Lua at 5.4.8. Phase A then bound `librime-lua` to upstream `ec52e48…` plus a local empty OpenCC stub with 9/10 exact object matches on device arm64 and Simulator arm64/x86_64. The remaining `types.o` uses `re_detail_500`; official Boost.Regex 1.88.0 (500) and 1.89.0 (600) were tested against the fixed receipt and did not match SHA-256. The bundled Luna file is exactly official `rime/brise` blob `728f883…` plus one attribution-URL update, not an unmodified upstream blob. Human Product Owner accepted those derived receipts as an external-candidate residual under [`PD-RELEASE-2026-0801-05-PROVENANCE-A-ACCEPT`](../product-decisions/RELEASE-2026-0801-05-provenance-a-accept.md). Human Product Owner then reported saving content rights “Yes”, primary category `工具` and secondary category `效率`. The detailed evidence and accepted octagram header residual are recorded in [`release-2026-08-01-05-third-party-notice-provenance-2026-08-23.md`](release-2026-08-01-05-third-party-notice-provenance-2026-08-23.md) and the [`Phase A handoff`](release-2026-08-01-05-provenance-recovery-phase-a-2026-08-23.md).

### Verification

| Check | Result |
|---|---|
| `git diff --check` | Pass |
| Swift formatting | Strict lint Pass for every changed Swift file |
| RIME vendor structural inventory | Pass; 12 framework artifacts verified |
| `swift test --package-path Packages/KeyboardCore` | Pass; 1,030 tests, 0 failures |
| Generic iOS Simulator Debug build | Pass under Xcode 27 beta |
| Generic iOS Simulator Release build | Pass under Xcode 27 beta |
| Swift 6 `build-for-testing` for App/Keyboard test targets | Pass |
| Swift 6 `RimeBridgeTests` build-for-testing | Pass |
| `SchemaManagerTests` runtime on iPhone 17 Pro / iOS 26.0 | Environment-blocked twice before tests began: Xcode remained at `waiting for workers to materialize`; runs were interrupted after bounded waits |

The earlier test-runner condition is not recorded as a test pass. The test source covers descriptor separation, per-scheme acceptance, stale-revision rejection, safe rime-ice migration, rejected Wanxiang migration and download fail-closed behavior.

After offline notice resources were added, a later Xcode 27 beta run successfully started the same iPhone 17 Pro / iOS 26.0 worker. The new catalog-to-bundle test passed and confirmed every referenced offline document exists in the built App. A subsequent complete `SchemaManagerTests` attempt passed eight tests, then hit a native hosted-process `malloc` invalid-free crash, restarted and crashed again; it was interrupted to stop the loop. Therefore the focused new test is `Pass`, while the full suite remains not passed under this beta environment.

### Human UI evidence

Human Product Owner confirmed all three requested checks on `2026-08-23 Asia/Shanghai`:

1. Rime-ice detail shows the rime-ice project and `GPL-3.0-only`.
2. Wanxiang detail shows the Wanxiang project and `CC BY 4.0`.
3. Settings “开源软件与内容” opens the expected scheme/component lists and details.

Disposition: per-scheme disclosure UI Product Gate `Pass`. This does not close the separate transitive-binary notice/provenance gate.

### App Store Connect disposition

Repository-supported answer:

```text
是，App 包含或访问第三方内容，并且拥有使用这些内容的必要权利。
```

This is supported for the identified projects by the corrected attribution surfaces and bundled offline notices, but it remains a Human legal/product attestation. Because two exact source identities remain unresolved, the content-rights gate stays open pending Product disposition of that residual provenance risk. This task has not clicked or saved the field.
