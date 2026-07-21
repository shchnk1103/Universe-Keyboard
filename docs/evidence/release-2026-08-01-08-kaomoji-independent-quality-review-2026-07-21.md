# RELEASE-2026-0801-08 独立质量审查 — 2026-07-21

**审查角色：** 独立 Quality Reviewer（由 Product Lead 任命）
**审查范围：** `codex/release-2026-0801-kaomoji`，提交 `c9f2b34bd4b44dc528f39e6120db1af3f23c367e`，相对 `origin/main` 的差异
**审查方式：** 只读代码、差异、任务/产品决策/执行者交接及现有发布规则核对；未修改实现、未执行会改变环境的构建或测试。
**结论状态：** **Blocked — 不能满足 RELEASE-2026-0801-08 的独立质量结论。** 此结论不是 Product Gate、风险接受或发布决定。

## 审查边界

本记录只评价颜表情目录提交的实现与其提交的证据是否足以满足任务 `RELEASE-2026-0801-08` 的 Exit Criteria。它不替代：

- Product Lead 对版权/内容范围、风险或 Product Gate 的决定；
- `RELEASE-2026-0801-04` 的性能、内存和终止证据；
- `RELEASE-2026-0801-07` 的 iPad 支持矩阵和最终设备验收；
- 最终 archive、App Store 材料或发行结论。

## 证据矩阵

| 审查项 | 只读核对结果 | 结论 |
|---|---|---|
| 离线内容与来源边界 | `KaomojiDataSource` 是随 Keyboard Extension 编译的四个静态分类，每类 12 项；差异中没有网络、资源下载、第三方目录导入、账户、历史记录或持久化代码。`PD-RELEASE-2026-0801-08` 记录了 Human Product Owner 对“自建、离线、48 项、禁止第三方受版权限制内容”的决定。代码审查无法独立证明每个文本表达式的原创性；可核验的来源依据仅为该 Product Decision。 | **通过（实现边界）**；内容作者权属仍以 Product Decision 为准，不能由本审查扩张为法律/内容保证。 |
| 键盘热路径与输入边界 | 打开/切换分类只更新当前控制器内存状态并调用 `reloadKeyboardContent()`；面板生成读取静态数组。点选调用既有 `insertDirectText(_:)`，继而交给 `KeyboardCore` 和 `syncUI`，未新增 RIME session、部署、文件扫描、网络或同步调用。 | **通过（静态审查）**。这不构成当前设备上的延迟、内存或卡死性能证据；该发布级证据仍属于任务 04。 |
| 隐私边界 | 新增状态只存在于 `KeyboardViewController`；目录不含用户输入读取、日志、分析、网络、账户、同步、最近使用或持久化写入。Extension 的 `PrivacyInfo.xcprivacy` 未在本差异中变更，声明无收集数据。 | **通过（静态审查）**。最终二进制隐私清单和 App Store 隐私答复仍需按发布清单复核。 |
| iPad 布局 | 执行者记录了 iPad Pro（11 英寸，第 3 代）、iPadOS 27.0 的 Debug 观察：九键入口、分类切换、插入与较大文字可见。该记录没有截图、横竖屏/尺寸类别矩阵、深色模式、VoiceOver、最终 archive 或 iOS 26.0 证据。`RELEASE-2026-0801-07` 仍为 `Assigned — Entry Criteria pending`。 | **未通过 / 阻塞。** 单一 Debug 观察不能替代 iPad 支持任务所要求的物理设备矩阵与最终构建证据。 |
| 自动化测试与失败 | 本差异未新增 `KeyboardTests`、`UniverseKeyboardTests`、UI tests 或 SPM 测试。执行者记录的完整物理设备 `xcodebuild test` 为失败：121 个测试执行、5 个失败，报告涉及 `RimeSettingsStoreTests.testAutoBackupRunsForChangedLearningDataWhenEnabled()` 与 `testSaveFuzzyPinyinSettingsSkipsDeployWhenSignatureAlreadyMatches()`；`KeyboardTests` 在该物理设备目的地未运行。原始 `.xcresult` 位于执行者本机 DerivedData，但本审查环境没有读取该包内 `database.sqlite3` 的权限，因此仅能将交接记录视为“失败已报告”，不能独立复核失败详情或归因。 | **未通过 / 阻塞。** 不接受“与颜表情无关”的推断；必须由对应 RIME Settings 所有者复现、定因并提供可复核结果，或由 Product Lead 单独作出决定。 |
| 无障碍与降级 | 源码设置了分类、返回和条目的 VoiceOver 标签/提示，并启用 Dynamic Type 字号调整；执行者明确未执行 VoiceOver 焦点/朗读、深色模式、iPhone 设备和 Full Access 关闭验证。 | **未通过 / 阻塞。** 源码标签不是运行时 VoiceOver 通过证据，且任务 Exit Criteria 明确要求可访问性和支持设备行为。 |

## 阻塞项与交接

1. **Q-08-01：失败测试未闭环。**
   - 所有者：RIME Settings / Main App 领域所有者先完成复现与根因交接；Quality Reviewer 复核最终结果。
   - 需要：与候选提交和最终 release commit 绑定的完整测试命令、环境、`.xcresult` 可访问位置、所有失败名称/日志、根因及修复后或经 Product Lead 决定后的结果。
   - 边界：本审查不将失败归类为既有问题，也不接受风险。

2. **Q-08-02：颜表情功能的运行时无障碍与设备矩阵缺失。**
   - 所有者：Keyboard Experience Executor 与 Human Product Owner（物理设备操作）提供证据；Quality Reviewer 复核。
   - 需要：同一候选构建上的 iPhone 与 iPad、浅色/深色、VoiceOver 焦点顺序和朗读、Dynamic Type、Full Access 关闭下的基本输入与颜表情插入结果。证据须记录设备、OS、方向/尺寸类别、host、schema、Full Access 状态、构建/提交和截图或可复核观察。

3. **Q-08-03：iPad 支持不能由本任务单点观察关闭。**
   - 所有者：`RELEASE-2026-0801-07`。
   - 需要：该任务先满足 Entry Criteria，并交付受支持 iPad/OS/方向矩阵、最终 archive 一致性及其 Exit Criteria 所列的可访问性和布局证据。iPadOS 27.0 Debug 观察不可替代 iOS 26.0+ 的最终支持声明。

4. **Q-08-04：颜表情行为缺少回归自动化覆盖。**
   - 所有者：Keyboard Experience / Test & Release。
   - 需要：至少覆盖两处 `^_^` 入口、分类切换、精确文本插入、现有 composition 最终提交与返回键盘的可重复验证；可采用适合 Extension 限制的单元、集成或受控设备证据，但不得把不可运行的 `KeyboardTests` 写成通过。

5. **Q-08-05：本次静态热路径结论不能关闭发布性能 Gate。**
   - 所有者：`RELEASE-2026-0801-04`。
   - 需要：按 `PERFORMANCE_BASELINE.md` 在当前候选构建收集冷启动、按键、内存与终止相关证据；不得以“未新增 I/O”的代码观察替代实测。

## 独立质量结论

实现的离线、无持久化和既有最终提交路径在静态审查中符合已记录的产品边界，且未发现将颜表情目录置入 RIME 部署或网络热路径的证据。可是，失败测试尚未定因/复核，颜表情所需的无障碍与支持设备验证尚未完成，iPad 支持任务也尚未具备其自身的可执行入口。因此 **RELEASE-2026-0801-08 维持 Blocked**，不得据此声称颜表情功能、iPad 支持或发布候选已通过 Quality。

下一交接对象：Product Lead（知悉阻塞项）以及各阻塞项指定的领域所有者。是否修复、是否缩小范围、是否接受风险、是否通过 Product Gate，均保留给明确授权的 Human Product Owner。

## 勘误 / 补充 — Q-08-01 独立 Simulator 复现

本补充不删除或重写原始执行者交接中“物理设备完整测试报告 5 个失败”的事实，也不将原始 `.xcresult` 的不可读状态表述为通过。

后续独立 Simulator 复现**未复现**该两项已报告的 `RimeSettingsStoreTests` 失败。因此，现有证据不足以将 Q-08-01 的失败归因于 `RELEASE-2026-0801-08` 的颜表情差异；本审查不再把它作为 -08 实现缺陷的归因性证据。

这不是完整测试的通过结论：最终候选构建的完整测试、结果包可复核性和任何跨目标失败的处置，仍由 `RELEASE-2026-0801-04`（质量/设备证据）与 `RELEASE-2026-0801-01`（稳定 archive）负责。Q-08-02、Q-08-03、Q-08-04 和 Q-08-05 均保持开放；本补充不将任务改为 Pass、不关闭任务，也不构成风险接受或 Product Gate 决定。

## 补充结论 — Q-08-02 高版本真机运行时证据复核

**复核证据：** [`Q-08-02 真机运行时证据`](release-2026-08-01-08-q-08-02-physical-device-runtime.md)，证据提交 `86261833970140e91e83df3dc0d0a1a43508291c`；被测提交 `c9f2b34bd4b44dc528f39e6120db1af3f23c367e`。

**限定结论：** **Q-08-02 已在“iOS/iPadOS 27.0 高版本真机运行时观察”范围内满足。** 这只撤销本记录对 Q-08-02“运行时设备/无障碍证据缺失”的原有限定；不构成 iOS/iPadOS 26.0 支持结论、最终 archive 一致性结论、整体 Quality Pass、任务关闭或 Product Gate。

| 复核项 | 独立核对 | 限定结论 |
|---|---|---|
| 环境与提交绑定 | 两个运行编号分别记录 iPad Pro 11 英寸（第 3 代）/ iPadOS 27.0 / 横屏 / Apple 备忘录，以及 iPhone 13 Pro / iOS 27.0 / 竖屏 / Apple 备忘录。证据绑定 Debug `1.0 (1)` 与 `c9f2b34`；Git 对象存在。证据提交只新增该运行时记录。 | 满足高版本真机观察的环境与提交追溯要求。 |
| 构建产物一致性 | 复算主 App SHA-256 为 `2d6b24381e4260eb72ac25c6ad79af0219002ce29a5389b2a7f65b69a2e1ac17`，Keyboard Extension SHA-256 为 `381c8cbbc6a4ef67569b8f8da5998adde95a436db8a9f8d62b4e1b4f010cd4b1`，与证据一致；产物元数据为版本 `1.0 (1)`、`iphoneos27.0` SDK、`MinimumOSVersion=26.4`。 | 两台设备记录可追溯到同一冻结产物；`MinimumOSVersion=26.4` 也明确不能证明 iOS 26.0。 |
| 两处入口、分类、插入与返回 | iPad 与 iPhone 均记录九宫格右侧入口和 `123` → `#+=` 二级符号页入口打开同一面板；iPad 记录切换“开心”、精确插入 `ヽ(✿ﾟ▽ﾟ)ノ` 并返回原键盘；两台设备均观察到 `^_^` 精确插入。 | 满足 Q-08-02 在两台高版本真机上的入口与核心交互观察。 |
| Full Access 关闭 | 两台设备均由 Human Product Owner 当次关闭 Full Access，并在关闭状态下记录合成文本 `2026` 的基础输入和后缀 `2026^_^` 的颜表情插入；关闭前未核验状态的行没有被误写为开启。 | 满足 Full Access 关闭场景的基础输入与颜表情插入观察。 |
| VoiceOver | iPad 当次人工朗读记录覆盖“返回”→四个分类→按视觉从左到右、从上到下的条目顺序，并到达最后一项；iPhone 当次只实际复核“返回”→“常用”→“开心”前三个焦点。证据没有音频文件，来源被明确标为当次人工复述。 | 满足高版本真机范围内的焦点与朗读顺序观察；不得据此声称 iPhone 已完成全部条目遍历。 |
| 浅色、深色与 Dynamic Type | iPad、iPhone 均有浅色/深色可辨认观察；iPad Text Size `3→7`、iPhone `2→7` 时四分类与 12 项仍可操作，采集后恢复原显示设置。 | 满足高版本真机范围内的两种外观和较大 Dynamic Type 观察。 |

证据未把临时 Device Hub 截图或 VoiceOver 音频加入仓库，复核所依据的是逐行记录的实时画面观察与 Human Product Owner 当次操作/朗读复述。事后 `devicectl` 设备重新枚举超时，因此本补充不把事后设备探测写成独立佐证；设备型号和 OS 仍以当次 Device Hub 记录为准。

Q-08-03、Q-08-04、Q-08-05 均保持开放，其所有者、所需证据和边界不变。本补充不更新 Assignment 生命周期，不关闭 `RELEASE-2026-0801-08`，不作风险接受、Product Gate、合并或发布授权。
