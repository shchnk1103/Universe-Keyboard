DONE
运行时身份：Grok Bot「Executor」（只读调研，云端 box 会话）；模型 UNKNOWN

# APPSTORE-GAP-001 — App Store 提交材料缺口清单

- 包 SHA-256 未复算（云端粘贴），以 Human 派发块给出的值为准：`c736c7f1d21b9231804d2e0e207a38853a48ed3c89d8766f06c07003c3e870fa`。
- 仓库：`shchnk1103/Universe-Keyboard` `main`。实际读取提交是 `145d24161146b9d38be829a1ebe0a9acf9a7b1d7`，与包给的参考提交一致。
- 网络来源访问日期：全部为 2026-11-02（Asia/Shanghai）。
- 证据标注：**已证** / **推断** / **UNKNOWN**。引用不超过 15 字。本文只列事实，不写商店文案，不构成法律意见。凡涉及法律、税务或备案办理的地方，都写了“需专业意见确认”。

## 授权原文

云端无法写 `reports/human-authorization-issued.md`，因此改为把授权原文逐字写在本节，并在本节末尾附上本节文字的 SHA-256。

PM 转来的包授权原文（文件 `/workspace/appstore-gap-001/user-message.md`，复算 SHA-256 为 `958ea4c6bdea8da59288f442a16ad22a4afee5e33b49b09db6c099a8f67aabd2`，与预期前缀 958ea4c6、尾 abd2 一致）：

```
APPSTORE-GAP-001 App Store 提交材料缺口清单（云端只读）
角色：只读调研员（Executor，调研）
包 SHA-256（云端无法复算，以此为准）：c736c7f1d21b9231804d2e0e207a38853a48ed3c89d8766f06c07003c3e870fa
授权，直接执行。
```

用户在派发方聊天中的确认原文：

```
授权 APPSTORE-GAP-001 按任务包（SHA-256 c736c7f1…870fa）执行
```

本节 SHA-256 的计算范围：从本节标题行到本行（含本行）为止的 UTF-8 文本，行尾换行符计入。结果写在下一行。
<!-- AUTH-SECTION-END -->
本节 SHA-256：b6f8b996a50e597dad14d625c98635135c4c64a248624c7aeba1567fe9a01b87

## 1. 仓库已有材料盘点（main @ 145d241）

| 项 | 位置 | 内容（短引） | 证据 |
|---|---|---|---|
| 发布清单：隐私页与外部 URL 一致 | `docs/RELEASE_CHECKLIST.md:462` | “privacy-policy URL match” | 已证 |
| 发布清单：审核备注说明完全访问 | `docs/RELEASE_CHECKLIST.md:463` | “App Review notes explain Full Access” | 已证 |
| 发布清单：完全访问说明准确 | `docs/RELEASE_CHECKLIST.md:305` | “Full Access explanation remains accurate” | 已证 |
| 截图状态 | `docs/assignments/release-2026-08-01-05-app-store-materials.md:15` | “App Store 截图 0/10” | 已证（2026-08 记录，当前在线值 UNKNOWN） |
| App Privacy 已发布“未收集数据” | 同上 `:64` | “No data collected” | 已证（Human 报告） |
| 加密 / 类别 / 内容权利（2026-08 快照） | 同上 `:65`；审计 `:149` | 类别与内容权利后来由 Human 报告“已保存” | 已证（Human 报告） |
| 出口合规声明 | `config/Info.plist:25-26` | `ITSAppUsesNonExemptEncryption` false | 已证 |
| 出口合规依据 | 审计 `docs/evidence/release-2026-08-01-05-testflight-metadata-audit-2026-08-22.md:152-168` | “not a legal guarantee” | 已证 |
| 年龄分级 | 审计 `:102` | 页面显示全球 `4+` | 已证（Human 确认；问卷后来有变化，见第 2 节） |
| 中国大陆 ICP | 审计 `:104` | “China mainland ICP | 未设置” | 已证（2026-08 快照） |
| 隐私政策 URL（TestFlight 阶段） | 审计 `:41`、`:143` | 先为 BLOCKED，后由 Human 确认已保存 | 已证（URL 值本仓库未见，UNKNOWN） |
| 商店字段为空（2026-08） | 审计 `:120` | “description, keywords, support URL … empty” | 已证 |
| 商店文案草稿 | `docs/evidence/release-2026-08-01-05-store-copy-and-what-to-test-2026-08-24.md:25`（副标题）、`:59`（关键词）、`:130` | “Human-reported 覆盖范围” | 已证（是否已填入 ASC 由 Human 报告，执行方未复核） |
| Beta 审核备注（含完全访问） | 审计 `:58-72` | “允许完全访问” | 已证（只有 TestFlight 版；正式版审核备注 UNKNOWN） |
| 隐私政策正文 | `docs/PRIVACY_POLICY.md:3` 生效日期；`:13`；`:15`；`:45`；`:72` | “Effective date: 2026-07-12” | 已证 |
| 主 App 隐私清单 | `Universe Keyboard/PrivacyInfo.xcprivacy:5-6`、`:18-19`、`:27`、`:35`、`:43` | Tracking false；CA92.1 / 1C8F.1、C617.1、35F9.1、E174.1 | 已证 |
| 键盘扩展隐私清单 | `Keyboard/PrivacyInfo.xcprivacy:5-6`、`:18`、`:26`、`:34` | Tracking false；1C8F.1、C617.1、35F9.1 | 已证 |
| 键盘请求完全访问 | `Keyboard/Info.plist:15-16` | `RequestsOpenAccess` true | 已证 |
| App Group | `Universe Keyboard/Universe Keyboard.entitlements:7`、`Keyboard/Keyboard.entitlements:7` | `group.com.DoubleShy0N.Universe-Keyboard` | 已证 |
| 后台任务 | `config/Info.plist:5-8`（BGTask）、`:34-37`（UIBackgroundModes processing） | “rime-standard-sync” | 已证 |
| 支持设备 | `Universe Keyboard.xcodeproj/project.pbxproj:1024` 等 | `TARGETED_DEVICE_FAMILY = "1,2"` | 已证（iPhone + iPad） |
| 本项目许可证 | `LICENSE:1` | “MIT License” | 已证 |
| 第三方许可证 | `Universe Keyboard/ThirdPartyLicenses/`（29 个文件，含 GPL-3.0、LGPL-3.0、CC-BY-4.0） | “RIME-ICE-GPL-3.0-only.txt” | 已证 |
| Xcode Cloud 克隆脚本 | `ci_scripts/ci_post_clone.sh:17` | “ensure_rime_vendor.sh fetch” | 已证 |

## 2. Apple 官方要求（访问日期 2026-11-02）

| 要求 | 来源 | 短引 | 证据 |
|---|---|---|---|
| 名称不超过 30 字符；副标题不超过 30 | A1 | “no more than 30 characters” | 已证 |
| 宣传文本不超过 170；描述不超过 4000，必填；关键词不超过 100 字节，必填 | A2 | “up to 100 bytes” | 已证 |
| 支持 URL 必填，须有联系方式 | A2 | “must lead to actual contact” | 已证 |
| 版权必填 | A2 | “This property is required.” | 已证 |
| 隐私政策 URL：iOS 必填 | A1 | “Required for iOS and macOS” | 已证 |
| 截图：iPhone 需要“灵动岛 medium”，至少 1 张；支持 iPad 时需要 13 英寸，至少 1 张；每个尺寸最多 10 张 | A3 | “at least one screenshot” | 已证 |
| iPhone Duo 截图：2027 年 4 月起，用 iOS 27.1 SDK 的 App 需要提供 | A3 | “Starting in April 2027” | 已证 |
| 审核信息：联系人；备注不超过 4000 字节 | A2 | “up to 4000 bytes” | 已证 |
| App 隐私详情：提交新 App 必填；仅在设备上处理的数据不算“收集” | A4 | “processed only on device” | 已证 |
| 年龄分级：必填，按问卷生成；未分级的 App 不能上架 | A5、A1 | “Unrated app can't be published” | 已证 |
| 问卷新增社交媒体题，2026-09 起必答 | A7 | “responses will be required” | 已证 |
| 出口合规：使用加密就要做判定；Info.plist 可以免去每次回答 | A6 | “determine your export compliance” | 已证（是否需要 CCATS 需专业意见确认） |
| 键盘扩展 4.4.1：不开完全访问也要能用 | A8 | “without requiring full access” | 已证 |
| 4.4.1：只为增强键盘而收集活动数据 | A8 | “Collect user activity only” | 已证 |
| 4.4.1：须有切换到下一个键盘的方法 | A8 | “progressing to the next keyboard” | 已证 |
| 4.4：在营销文字中披露扩展 | A8 | “clearly and accurately disclose” | 已证 |
| 5.1.1(i)：App 内也要提供隐私政策链接 | A8 | “within the app” | 已证 |
| 2.3.1(a)：审核备注要具体说明功能 | A8 | “described with specificity” | 已证 |
| 4.2.3(ii)：首次启动需要下载资源时，要披露大小并提示 | A8 | “disclose the size of the download” | 已证 |
| 5.2 / 内容权利：第三方内容要有权利 | A8、A1 | “necessary rights” | 已证 |
| 3.1.2(a)：订阅周期至少 7 天，所有设备可用 | A8 | “at least seven days” | 已证（仅在之后加订阅时适用） |
| 完全访问的开发者责任（存档文档） | A9 | “increases your responsibilities” | 已证（存档文档，现行效力 UNKNOWN） |
| Required Reason API 隐私清单 | A10 | 页面正文未能加载 | **UNKNOWN**（没有凭记忆补） |
| 中国大陆：需要有效 ICP 备案号，且需与 ASC 元数据一致 | A1 “Availability in China mainland” | “valid Internet Content Provider (ICP) Filing Number” | 已证 |
| 工信部：在境内从事互联网信息服务的 App 须备案 | M1、M2 | “未履行备案手续的，不得从事” | 已证（本 App 是否属于“从事互联网信息服务”需专业意见确认） |
| 工信部：分发平台不得分发未备案 App | M1 | “不得为未履行备案手续的APP” | 已证 |

## 3. 缺口表

| 要求项 | Apple 来源 | 仓库现状 | 状态 | 谁能补 |
|---|---|---|---|---|
| App 名称 / 副标题 | A1 | 草稿 `store-copy…-2026-08-24.md:25` | 不确定（ASC 在线值 UNKNOWN） | Human 在 ASC 核对 |
| 描述 / 关键词 / 宣传文本 | A2 | 草稿 `:59`；`:130` 为 Human 报告已填 | 不确定 | Human 在 ASC 核对；PM 起草修订 |
| 截图：iPhone 灵动岛 medium，至少 1 张 | A3 | `materials.md:15` 记录“0/10” | 缺 | 需 Mac 验证（模拟器 / 真机截图）+ Human 上传 |
| 截图：iPad 13 英寸（App 支持 iPad） | A3 | `project.pbxproj:1024` 显示支持 iPad；截图“推迟” | 缺 | 需 Mac 验证 + Human；或由 Human 决定是否去掉 iPad 支持 |
| 支持 URL（含联系方式） | A2、A8 1.5 | 审计 `:120` 记录为空；仓库中未见 URL | 缺 | Human 决定网址；PM 起草页面内容 |
| 隐私政策 URL | A1、A4 | 审计 `:143` 记录 Human 已保存；URL 值在仓库中未见 | 不确定 | Human 在 ASC 核对 |
| App 内隐私政策链接 | A8 5.1.1(i) | 在 Swift 中检索隐私链接未命中 | 不确定（推断缺） | 需 Mac 验证 |
| App 隐私详情 | A4 | `materials.md:64` 为“No data collected”；同步功能后来有变化 | 需 Human 决定（是否重新评估） | Human 在 ASC；需专业人士 |
| 年龄分级问卷（含新社交媒体题） | A5、A7 | 审计 `:102` 为 2026-08 完成 | 不确定（新题是否已答 UNKNOWN） | Human 在 ASC |
| 出口合规 | A6 | `config/Info.plist:25-26` 为 false；审计 `:168` 写明“not a legal guarantee” | 齐（技术面）/ 法律残留 | 需专业人士（年度自分类报告等） |
| 审核备注（正式版：完全访问、资源下载） | A2、A8 2.3.1 / 4.4.1 | 只有 Beta 备注（审计 `:58-72`）；清单 `RELEASE_CHECKLIST.md:463` 未勾 | 缺 | PM 起草 + Human 在 ASC 填写 |
| 键盘不开完全访问可用 | A8 4.4.1 | 清单 `:365` 未勾；TD-004 有范围跳过（`:73`） | 不确定 | 需 Mac 验证（真机） |
| 营销文字披露扩展 | A8 4.4 | 依赖描述草稿 | 不确定 | PM 起草 |
| 内容权利 / 第三方内容 | A1、A8 5.2 | 审计 `:100` 为 Human 报告“是”；`ThirdPartyLicenses/` 29 个文件 | 需 Human 决定 / 需专业人士（GPL-3.0 与 App Store 分发的兼容性） | 需专业人士 |
| 版权行 | A2 | `materials.md:15` 为 Human 报告已填 | 齐（Human 报告） | Human 核对 |
| Required Reason API 清单 | A10（UNKNOWN） | 两份 xcprivacy 已声明 4 类 | 不确定（是否完整需对照代码与官方清单） | 需 Mac 验证 + 官方页 |
| 首次下载资源的大小与提示 | A8 4.2.3(ii) | `ci_post_clone.sh:17`（构建时）；运行时下载行为 UNKNOWN | 不确定 | 需 Mac 验证 |
| 中国大陆 ICP 备案号 | A1、M1 | 审计 `:104` 记录“未设置” | 缺 / 需 Human 决定 | Human（备案办理不在本包范围，需专业意见确认） |
| 订阅（之后） | A8 3.1.2 | 无 | 需 Human 决定 | Human / 之后再说 |

## 4. 可能与提交要求冲突的点（只列事实）

1. **同步说明与隐私政策可能不一致。**
   - `PrivacyDataView.swift:63`：“不包含用户词典”。
   - `docs/PRIVACY_POLICY.md:45`：标准 RIME 同步可能把用户词典放到共享文件夹。
   - 前者指的是“私密设置同步”（`PRIVACY_POLICY.md:39`），两处是否会让用户混淆：推断存在风险。
2. **App 内隐私政策链接：** 静态检索未找到 App 内的隐私政策 URL 链接。可能用了其他形式实现，UNKNOWN，需 Mac 验证。
3. **完全访问：**
   - `Keyboard/Info.plist:15-16` 请求了完全访问。
   - 4.4.1 要求不开完全访问也能用。清单 `RELEASE_CHECKLIST.md:365` 中“关闭时可基本输入”未勾选，本轮相关条目也明确不声称关闭时的表现（`:381`、`:387`）。
   - 实际表现 UNKNOWN。
4. **App 隐私详情：** “No data collected”是在 2026-08 发布的，之后加入了标准同步（`PRIVACY_POLICY.md:45-51`）。同步是用户自选目的地；按 A4 的定义（“传到开发者或第三方可访问”），推断仍不算收集，但需 Human / 专业意见确认。
5. **iPad：** 工程支持 iPad（`TARGETED_DEVICE_FAMILY = "1,2"`），因此需要 iPad 13 英寸截图（A3），而截图被推迟（`materials.md:15`）。
6. **第三方许可证：** 内含 GPL-3.0-only 资源（`RIME-ICE-GPL-3.0-only.txt`）。与 App Store 分发条款是否兼容，需专业意见确认。
7. **后台处理：** `UIBackgroundModes processing` 和 BGTask 用于同步，与 2.5.4（后台服务只用于预期用途）是否一致，UNKNOWN。

## 5. 建议的补齐顺序（建议，不是决定）

1. **现在可以远程做：**
   - PM 起草正式版审核备注（完全访问用途、关闭时的降级、资源下载）。
   - PM 起草支持页内容。
   - 核对描述中是否披露了键盘扩展。
   - 整理第三方许可证问题清单，交专业人士。
2. **必须在 Mac 上做：**
   - iPhone 与 iPad 13 英寸截图。
   - 关闭完全访问时的真机验证。
   - App 内隐私政策入口检查。
   - 核对 Required Reason API 声明是否完整。
3. **必须在 App Store Connect 上做（Human）：**
   - 填写支持 URL。
   - 核对名称、副标题、描述、关键词、宣传文本、隐私政策 URL。
   - 年龄分级（含新的社交媒体题）。
   - 重新确认 App 隐私详情。
   - 填写审核备注。
4. **需要 Human 决定或专业意见：**
   - 中国大陆首发与 ICP 备案。
   - GPL 资源。
   - 出口合规的法律残留。
   - 之后的订阅。

## 读取的仓库文件

- `docs/RELEASE_CHECKLIST.md`
- `docs/assignments/release-2026-08-01-05-app-store-materials.md`
- `docs/evidence/release-2026-08-01-05-testflight-metadata-audit-2026-08-22.md`
- `docs/evidence/release-2026-08-01-05-store-copy-and-what-to-test-2026-08-24.md`（检索）
- `docs/evidence/release-2026-09-13-build55-store-upload-package.md`（检索）
- `docs/PRIVACY_POLICY.md`
- `Universe Keyboard/PrivacyInfo.xcprivacy`、`Keyboard/PrivacyInfo.xcprivacy`
- `config/Info.plist`、`Keyboard/Info.plist`
- `Universe Keyboard/Universe Keyboard.entitlements`、`Keyboard/Keyboard.entitlements`
- `LICENSE`
- `Universe Keyboard/ThirdPartyLicenses/`（目录列表）
- `ci_scripts/ci_post_clone.sh`
- `Universe Keyboard.xcodeproj/project.pbxproj`（检索）
- `Universe Keyboard/Views/**`（检索）

## 网络来源（访问日期均为 2026-11-02）

- A1：https://developer.apple.com/help/app-store-connect/reference/app-information/app-information
- A2：https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information
- A3：https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications
- A4：https://developer.apple.com/app-store/app-privacy-details/
- A5：https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions
- A6：https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance
- A7：https://developer.apple.com/news/?id=lfmkx3v2（Apple Developer News 列表页）
- A8：https://developer.apple.com/app-store/review/guidelines/（页面显示 Last Updated: October 16, 2026）
- A9：https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html（存档文档）
- A10：https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api：正文未加载，UNKNOWN
- 打不开：https://developer.apple.com/help/app-store-connect/reference/app-information/app-icp-filing-number（404），UNKNOWN
- M1：https://www.miit.gov.cn/jgsj/xgj/wjfb/art/2023/art_dd783a581c9644a4aee10afa582811db.html（工信部信管〔2023〕105号；正文经搜索结果读取，未单独打开页面）
- M2：https://www.gov.cn/zhengce/202308/content_6897437.htm（解读；经搜索结果读取）

## 观察与改进意见（不影响状态，不在本包范围）

1. **Required Reason API 页面无法读取。**
   - 遇到的情况：A10 正文为空，页面靠 JS 渲染。
   - 建议：以后读这类页面时改用浏览器或 Apple 的 JSON 文档接口。
   - 影响层：工具链。把握：已证。
2. **ICP 帮助页 404。**
   - 遇到的情况：`app-icp-filing-number` 返回 404。
   - 建议：只引用 A1 中“Availability in China mainland”一段，或另找现行链接。
   - 影响层：其它。把握：已证。
3. **ASC 在线值都停留在 2026-08 的 Human 报告。**
   - 遇到的情况：审计 `:149` 是“Human-reported”。
   - 建议：提交前由 Human 导出 ASC 各字段的当前截图，作为证据。
   - 影响层：KOS 流程。把握：推断。
4. **支持 URL 和 App 内隐私链接在仓库中没有记录。**
   - 遇到的情况：审计 `:120` 记录“support URL … empty”。
   - 建议：在 `RELEASE_CHECKLIST.md` 中增加“URL 实值”一行。
   - 影响层：项目文档。把握：想法。
