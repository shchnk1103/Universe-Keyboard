# RELEASE-2026-0801-07 — iPad 最终 RC 验证矩阵预备方案

> **Lifecycle:** Active
>
> **文档类型：** Final RC 执行前预备矩阵；不是 Environment Evidence、Quality Gate 或 Product Gate
>
> **预备日期 / 时区：** `2026-07-21 Asia/Shanghai`
>
> **Assignment：** [`RELEASE-2026-0801-07`](../assignments/release-2026-08-01-07-ipad-support.md)
>
> **当前产品范围来源：** [`RELEASE-2026-0801-02`](../assignments/release-2026-08-01-02-scope-freeze.md)

## 1. 责任、用途与边界

本文件只把最终 Release Candidate（RC）的 iPad 验证工作预先整理成可执行、可复核的矩阵。它不记录本轮真机结果，不改变 Assignment 生命周期，也不替代 [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md)、任务 04 的设备/性能结论或任务 05 的 App Store 材料结论。

- **单一责任：** 定义 `RELEASE-2026-0801-07` 最终 RC 的 iPad 验证输入、执行行、证据字段、失败/跳过规则和重新验证边界。
- **执行者：** Assignment 中命名的 Keyboard Experience Executor；物理触控、系统设置和设备解锁由 Human Product Owner 执行。
- **复核与交接：** 结果先交给 Quality, Performance & Release Maintainer；截图清单同时交给任务 05；最终 Product Gate 仍由 Product Lead 决定。
- **禁止外推：** Simulator 不能替代物理 iPad；Debug 构建不能替代最终 Release RC；历史观察不能继承为当前行的 `Pass`；截图不能单独证明 VoiceOver 朗读、性能、崩溃或 Full Access 状态。
- **隐私边界：** 只使用本文定义的合成文本；不得采集真实用户输入、周边文本、候选内容、账户信息或凭据。
- **非目标：** 不修改主 App、Keyboard Extension、RIME 部署边界、输入语义、生命周期、支持范围或发布状态；不执行上传、提交审核、合并或推送。

## 2. 上游事实与不可继承的历史观察

当前 Product Lead 批准的 V1.0 声明是 **iPhone 与 iPad、iOS/iPadOS 26.0+**，并要求最终 archive、设备矩阵、截图和无障碍审查覆盖两个设备家族。预备基线 `8513e52` 的工程配置同时声明 iPad 设备家族；[`config/Info.plist`](../../config/Info.plist) 为主 App 声明竖屏、倒置竖屏、左横屏与右横屏。上述是待验证的支持合同，不是已经通过的设备证据。

同一预备基线的工程 deployment target 仍为 `26.4`，而 [`RELEASE-2026-0801-09`](../assignments/release-2026-08-01-09-ios-26-target.md) 仍保留最低系统实现/验证阻塞。因此最终 RC 若未把目标与 `26.0+` 声明对齐，本矩阵的 `S1` 和整体 iPad 支持结论必须保持 `Blocked`；预备文档不能把产品声明改成 `26.4+`，也不能把高版本通过外推到最低系统。

[`Q-08-02 高版本真机运行时观察`](../evidence/release-2026-08-01-08-q-08-02-physical-device-runtime.md)只可作为执行方法参考：它在 iPad Pro 11 英寸（第 3 代）/ iPadOS 27.0 / 横屏 / Apple 备忘录上记录了 Debug `1.0 (1)`、提交 `c9f2b34` 的颜表情、浅深色、较大文字、VoiceOver 和 Full Access 关闭观察，并绑定了主 App 与 Extension 可执行文件 SHA-256。独立复核也明确：这不证明 iPadOS 26.0、不证明最终 archive 一致性、不关闭 `RELEASE-2026-0801-07`，不得将其结果预填入本矩阵。

## 3. 最终执行 Entry Gate

以下条件全部满足后，矩阵执行才能开始；否则只记录 `Blocked`，不得降级为“先跑一部分即通过”：

1. Product Lead 已冻结本次 RC 的完整 Git 提交，工作树无未提交改动。
2. 任务 01 提供同一提交生成的签名 `Release` archive、版本/构建号、Xcode/SDK 和 dSYM。
3. 最终 RC 的部署目标与产品声明一致；若仍无法安装或运行于 iPadOS 26.0，最低系统行和整体 iPad 支持结论均为 `Blocked`。
4. 物理 iPad、Human Product Owner、至少一个可输入文本宿主可用；Universe Keyboard 已能按步骤启用和切换。
5. 主 App 与 Keyboard Extension 的可执行文件指纹已冻结；安装后再次读取的版本/构建必须一致。
6. 使用的 RIME schema、资源状态、Full Access 初始状态和测试用合成文本已经记录。
7. 所有必需 Assignment 字段仍完整；支持范围、方向政策、无障碍合同和审查角色没有触发 Revalidation。

## 4. 设备、系统与窗口层

| 层级 | 环境 | 必需性 | 能回答的问题 | 不能回答的问题 |
|---|---|---|---|---|
| `P1` 物理 iPad 主门槛 | iPad Pro 11 英寸（第 3 代）或 Product Lead 重新确认的物理 iPad；记录精确 iPadOS、容量状态和设备标识 | **必需** | 真机安装、主 App、Extension、触控、宿主、Full Access、VoiceOver、旋转和截图 | 不能单独证明最低 iPadOS 或所有 iPad 几何 |
| `S1` 最低系统兼容层 | 已安装的 iPadOS `26.0` Simulator；运行时发现一个较窄 iPad 几何和一个较大 iPad 几何 | **必需** | 最低系统启动、布局、方向、窗口尺寸和基本交互兼容 | 不能替代物理设备、签名/App Group、真实性能或系统触觉 |
| `P2` 补充物理层 | 若可用，与 `P1` 不同屏幕尺寸或最低支持系统的第二台物理 iPad | 建议；缺失必须记录为 residual risk | 降低单一硬件/高版本系统外推风险 | 缺失时不能写成已覆盖所有 iPad 型号 |

每层都必须覆盖主 App 全屏以及系统实际允许的最窄可调整窗口/分屏尺寸。若某设备或系统不提供窗口调整能力，记录 `Not Applicable`、系统原因和可复核画面；不得写成 `Skipped` 后静默通过。

## 5. RC 与提交指纹

执行前创建一个不可变的 Run Header。所有矩阵行、截图和失败记录引用同一 `Run ID`；任一关键值不同即停止并新建 Run。

| 字段 | 最终执行必填值 |
|---|---|
| Run ID | `R07-YYYYMMDD-<short-commit>-IPAD-RC-<NN>` |
| Git | 完整 commit SHA；branch/tag（仅辅助）；`git status --porcelain` 为空 |
| 构建 | scheme、`Release`、archive 创建时间、Xcode build、SDK build、签名 Team/identity 摘要 |
| 产品 | 主 App 与 Extension 的 bundle ID、`CFBundleShortVersionString`、`CFBundleVersion`、`MinimumOSVersion` |
| archive | `.xcarchive` 受控位置；导出产物或归档清单 SHA-256 |
| 主 App | 安装包内主可执行文件 SHA-256、Mach-O UUID、对应 dSYM UUID |
| Extension | 安装包内 Extension 可执行文件 SHA-256、Mach-O UUID、对应 dSYM UUID |
| 设备 | 型号、精确 OS/build、设备标识（只放清单，不放截图文件名）、可用存储、是否接调试器 |
| 运行状态 | 宿主、schema/版本、简繁/Lua 状态、Full Access、外观、Dynamic Type 类别、VoiceOver、方向/窗口宽度 |

指纹核对至少使用 `git rev-parse HEAD`、`shasum -a 256`、`dwarfdump --uuid` 和 archive/安装产物的 `Info.plist`。命令原始输出保存在本次 evidence 包；文档只引用位置和摘要，不能手工推测值。

## 6. 执行顺序与状态隔离

1. **Fresh / Full Access 关闭：** 安装最终 RC；只启用键盘，不开启 Full Access。终止旧 Extension 进程后，在宿主完成基础英文直输、地球键切换、Delete、Space、Return；确认 basic input 不依赖网络或 Full Access。
2. **主 App 准备：** 启动主 App，走启用指南、状态与恢复入口；按最终范围准备内置资源和 `rime_ice`。部署只能由主 App 完成。
3. **Full Access 开启：** 由 Human Product Owner 开启；终止 Extension 进程，按 `KBD-05` 至 `KBD-08` 执行。
4. **Full Access 再关闭：** 关闭后再次终止 Extension 进程，复跑 `KBD-01`/`KBD-02` 的基础输入和已部署资源降级观察，避免把缓存中的开启状态当成关闭证据。
5. **方向与窗口：** 所有旋转先从 idle 状态执行；活动 composition 的旋转单列观察，不以本计划创造新的持久化/清理语义。任何崩溃、挂起、重复提交、原始字母/数字泄漏或无法返回可输入状态均为 `Fail`。
6. **恢复设置：** 记录并恢复外观、文字大小、VoiceOver 和 Full Access；不得为“方便下次测试”擅自留下开启状态。

## 7. 必测场景矩阵

`DT-Default` 表示系统默认文字大小；`DT-Max` 表示设备可选的最大无障碍文字档，执行记录必须同时写入实际 `UIContentSizeCategory` 或系统显示档位。`Window-Narrow` 表示该系统实际允许的最窄可用窗口，不预设像素宽度。

### 7.1 主 App

| ID | 方向 | 窗口 | 外观 | Dynamic Type | VoiceOver | Full Access | 必须执行的检查包 |
|---|---|---|---|---|---|---|---|
| `APP-01` | 竖屏 | 全屏 | 浅色 | `DT-Default` | 关 | 关 | `APP-A`、`APP-B` |
| `APP-02` | 竖屏 | `Window-Narrow` | 深色 | `DT-Max` | 开 | 开 | `APP-A`、`APP-C` |
| `APP-03` | 横屏 | 全屏 | 深色 | `DT-Default` | 关 | 开 | `APP-A`、`APP-B` |
| `APP-04` | 横屏 | `Window-Narrow` | 浅色 | `DT-Max` | 开 | 关 | `APP-A`、`APP-C` |

- **`APP-A` 布局与导航：** 冷启动；Home、Guide、设置、方案/布局、Privacy & Data、支持/关于入口可达；无裁切、重叠、不可滚动内容、错误安全区或被键盘遮挡的主要操作；返回路径稳定。
- **`APP-B` 状态真实性：** 键盘启用/Full Access 文案与系统状态一致；关闭时不宣称共享能力已启用，开启时不宣称系统设置可被 App 自动改变；资源准备/部署操作只发生在主 App。
- **`APP-C` 无障碍：** VoiceOver 顺序与视觉层级一致；按钮、开关、选中态、错误与恢复操作具有可理解的 label/value/hint；`DT-Max` 下正文可读、操作可达且滚动不丢失焦点。

### 7.2 Keyboard Extension（Apple 备忘录）

所有行使用 Apple 备忘录中的空白草稿和合成输入：英文 `hello 2026`、中文 raw `nihao`、九键 `64`、颜表情 `^_^`。不得使用真实文本。Full Access 状态必须由 Human Product Owner 当次确认，不能由行为反推。

| ID | 方向 | 窗口 | 外观 | Dynamic Type | VoiceOver | Full Access | 必须执行的检查包 |
|---|---|---|---|---|---|---|---|
| `KBD-01` | 竖屏 | 全屏 | 浅色 | `DT-Default` | 关 | 关 | `KBD-A`、`KBD-B` |
| `KBD-02` | 竖屏 | `Window-Narrow` | 深色 | `DT-Max` | 开 | 关 | `KBD-A`、`KBD-C` |
| `KBD-03` | 横屏 | 全屏 | 深色 | `DT-Default` | 关 | 关 | `KBD-A`、`KBD-D` |
| `KBD-04` | 横屏 | `Window-Narrow` | 浅色 | `DT-Max` | 开 | 关 | `KBD-A`、`KBD-C`、`KBD-D` |
| `KBD-05` | 竖屏 | 全屏 | 浅色 | `DT-Max` | 开 | 开 | `KBD-A`、`KBD-C` |
| `KBD-06` | 竖屏 | `Window-Narrow` | 深色 | `DT-Default` | 关 | 开 | `KBD-A`、`KBD-B` |
| `KBD-07` | 横屏 | 全屏 | 浅色 | `DT-Default` | 开 | 开 | `KBD-A`、`KBD-C`、`KBD-D` |
| `KBD-08` | 横屏 | `Window-Narrow` | 深色 | `DT-Max` | 关 | 开 | `KBD-A`、`KBD-D` |

- **`KBD-A` 基础可用性：** 键盘可选中且不自动退回；地球键可切换；英文直输、Delete、Space、Return 正常；键帽、候选、路径栏、展开面板和底栏无裁切/重叠，触控区域可用。
- **`KBD-B` 输入与 Full Access：** Full Access 关闭时 basic input 必须可用且不出现虚假的共享统计/反馈声明；开启时核对共享设置、声音/触觉等最终支持能力。`rime_ice` 已部署后关闭 Full Access 的候选表现只记录实际结果，不从历史 iPhone/iPadOS 27 观察外推。
- **`KBD-C` VoiceOver 与大文字：** 逐项遍历地球键、模式切换、字母/九键、候选、路径选择、选中态、Delete、Space/选定、Return、颜表情返回/分类/条目；顺序可预测，无焦点陷阱；label/value/hint 与实际动作一致；每次激活只插入或执行一次。
- **`KBD-D` 中文与面板：** 26 键 `nihao` 和九键 `64` 不向宿主泄漏 raw 字母/数字；候选提交、Delete、展开/收起、`123`/`#+=`、两处 `^_^` 入口、分类切换、精确插入 `^_^` 与返回键盘可用。固定路径栏、候选栏和九键高度在横竖屏/窄窗口无不可操作裁切。

### 7.3 方向、窗口与生命周期巡检

| ID | 目标 | 操作 | 通过条件 |
|---|---|---|---|
| `ROT-01` | 主 App | idle 状态依次进入竖屏、左横屏、倒置竖屏、右横屏；每次访问 Home 与 Guide | 四个已声明 iPad 方向均能稳定布局、滚动与返回；无黑屏、错误安全区或丢失主要操作 |
| `ROT-02` | Extension / 备忘录 | idle 状态按相同四方向旋转并完成一次 `hello 2026` | 每次旋转后键盘仍可见、可输入、可切换；无挂起、崩溃或系统键盘意外接管 |
| `ROT-03` | Extension / 备忘录 | 建立合成 `nihao`，执行一次竖转横和横转竖 | 记录 composition/marked text 的实际变化；不得重复提交、泄漏 raw 文本、卡死或无法恢复。若与现有合同不一致则 `Fail`，不得在本任务中改变生命周期 |
| `WIN-01` | 主 App + Extension | 全屏与系统最窄可调整窗口之间往返 | 两个目标均可重新布局，关键操作持续可达；Extension 高度变化不造成候选/路径栏与键区重叠 |

### 7.4 最低系统与第二几何

在 `S1` 上至少复跑 `APP-01`、`APP-04`、`KBD-01`、`KBD-04`、`ROT-01`、`ROT-02` 和 `WIN-01`。Simulator 结果单独标记为 compatibility evidence；若 iPadOS 26.0 runtime 不可用或 RC 的 `MinimumOSVersion` 高于 26.0，则这些行是 `Blocked`，不能用 iPadOS 26.5/27.0 替代。

`P2` 可用时，至少复跑 `APP-02`、`KBD-02`、`KBD-07` 和 `ROT-02`。若 `P2` 不可用，失败/跳过表必须记录“仅一台物理 iPad”的 residual risk，并由 Quality Reviewer 与 Product Lead 决定是否足以支撑当前非型号化 iPad 声明；预备者无权接受该风险。

## 8. 截图、朗读与文件命名

每个必测行至少保留一张稳定结果截图；涉及页面切换、插入或旋转时保留 before/after。VoiceOver 行还必须有逐项人工朗读记录，截图只能证明可见布局和焦点外观。

统一命名：

```text
R07_<RunID>_<CaseID>_<Target>_<DeviceSlug>_<OS>_<Orientation>_<Window>_<Appearance>_<DT>_<VO>_<FA>_<Host>_<Seq>.png
```

示例仅说明格式，不是证据：

```text
R07_R07-20260721-abcdef0-IPAD-RC-01_KBD-04_EXT_ipad-pro-11_ipados-26-0_landscape_narrow_light_dt-max_vo-on_fa-off_notes_01.png
```

约束：

- `Target` 只用 `APP` 或 `EXT`；方向用 `portrait`、`portrait-upside-down`、`landscape-left`、`landscape-right`。
- 文件名不含 UDID、人员姓名、账户、文本内容或绝对路径；完整设备标识只在 evidence manifest 中保存。
- 原图不得裁掉状态栏、宿主身份、键盘边界或关键系统状态；如需脱敏，保留原图哈希并另存 `-redacted` 派生图。
- 每个文件在 manifest 中记录 SHA-256、Case ID、拍摄时间/时区、操作者、来源设备、是否脱敏和观察说明。
- VoiceOver 朗读记录使用同名 `.md` 或 evidence 表格行；没有音频时明确写“Human Product Owner 当次复述”，不得声称存在录音。

## 9. 单行记录模板

| 字段 | 内容 |
|---|---|
| Case / Run | Case ID、Run ID |
| Result | `Pass` / `Fail` / `Blocked` / `Skipped` / `Not Applicable` |
| Target / environment | APP/EXT、设备、OS/build、方向、窗口宽度/尺寸类别、宿主 |
| State | 外观、Dynamic Type、VoiceOver、Full Access、schema/资源状态、冷/暖进程 |
| Fingerprint | commit、version/build、主 App/Extension SHA-256、Mach-O/dSYM UUID |
| Steps / expected | 实际执行步骤与本矩阵对应检查包 |
| Observed | 只写实际观察；VoiceOver 标明朗读来源 |
| Evidence | 截图/记录/日志相对路径及 SHA-256 |
| Defect / owner | 缺陷 ID、严重度、领域 owner、release impact |
| Retest | 修复提交/新 archive 后需要重跑的 Case ID |

## 10. 失败、跳过与总体判定

每个失败或未执行项必须新增一行，不能只写在自由文本里：

| Record ID | Case ID | 状态 | 原因/实际结果 | Release impact | Owner | 证据 | 重新验证条件 | 风险决定 |
|---|---|---|---|---|---|---|---|---|
| `R07-GAP-<NN>` | — | — | — | — | — | — | — | `None` 或 Product Lead 决定链接 |

判定规则：

- `Pass`：只用于同一最终 RC、同一 Run Header 下已完整执行且证据可复核的行。
- `Fail`：观察到违反通过条件的行为；立即交给对应领域 owner，修复后按第 11 节重跑。
- `Blocked`：设备、最低系统、宿主、最终 archive、指纹或必需权限不可用；所有必需行中的 `Blocked` 都阻止 iPad Quality 结论。
- `Skipped`：只描述人为未执行；必需行被跳过默认阻止结论。只有 Product Lead 的独立、明确、带期限风险决定才能改变发布处置，矩阵预备者和 Quality Reviewer 不能代为接受。
- `Not Applicable`：仅在系统客观不提供某能力且有可复核事实时使用；必须写明原因，不能用来隐藏缺失设备或证据。

`RELEASE-2026-0801-07` 只有在所有必需物理/最低系统行通过、无未处理失败或阻塞、截图/manifest 完整、指纹一致，并由独立 Quality Reviewer 给出明确结论后，才能交给 Product Lead。该交接仍不等于 Product Gate 或发布授权。

## 11. 重新验证触发条件

| 变化 | 最小重跑范围 |
|---|---|
| Git commit、Release archive、版本/构建、签名、主 App/Extension 哈希或 Mach-O/dSYM UUID 变化 | **全部矩阵，新 Run ID** |
| iPad deployment target、支持型号/系统、方向声明、多窗口/尺寸类别政策变化 | `P1`、`S1` 全部；必要时增加新设备层 |
| 主 App SwiftUI、导航、安全区、Guide、设置、隐私/支持页面变化 | `APP-01` 至 `APP-04`、`ROT-01`、`WIN-01`；受影响截图全部重拍 |
| Keyboard Extension 布局、键高、候选/路径栏、颜表情、颜色或字体变化 | `KBD-01` 至 `KBD-08`、`ROT-02`/`03`、`WIN-01` |
| VoiceOver label/value/hint、焦点顺序、Dynamic Type 或可访问性合同变化 | 所有 `VO-on` / `DT-Max` 行，两个目标各补一次横竖屏回归 |
| Full Access、App Group、共享设置、反馈或降级文案/行为变化 | `APP-B` 与 `KBD-B` 的开启/关闭全序列，含进程终止后的再验证 |
| KeyboardCore 输入语义、RIME schema/资源、session/recovery、部署或 fallback 变化 | `KBD-A` 至 `KBD-D`、`ROT-03`；部署仍只在主 App 验证 |
| iPadOS/Xcode/SDK/宿主 App 更新，或设备型号/窗口能力改变 | 受影响环境层全部；若无法证明影响范围则全部矩阵 |
| 任一缺陷修复 | 缺陷 Case、同目标同方向的相邻场景、`APP-01`、`KBD-01`、`ROT-02`；跨目标/生命周期影响则全部矩阵 |
| 截图、manifest、指纹不一致或证据文件损坏 | 对应 Case 重采；无法确认影响范围时新建 Run 并全部重跑 |

## 12. 交接、文档影响与退休条件

最终 evidence 包必须包含：Run Header、完整矩阵、截图 manifest、VoiceOver 朗读记录、失败/跳过表、缺陷与重跑记录、Quality 结论，以及任务 04/05 的交接链接。结果文档应作为独立 evidence 新增，不能把本预备文件改写成“已通过证据”。

本预备方案没有改变架构、产品合同、用户数据、Extension 生命周期、RIME/Lua/OpenCC、测试命令或 `RELEASE_CHECKLIST`，因此不需要 ADR、`CHANGELOG.md`、`DEBUGGING.md`、`TECH_DEBT.md` 或其他当前事实文档更新。

当最终 RC 证据已由 Quality Reviewer 接收，或 Product Lead 改变 iPad 支持范围/验证策略时，本计划必须标记为 `Archived` 或 `Superseded`，写明日期、替代 evidence/决定与“本计划不再是当前执行指导”。
