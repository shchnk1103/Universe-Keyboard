# RELEASE-2026-0801-08 — Q-08-02 真机运行时证据

> **证据类型：** Environment Evidence（运行时观察，不包含 Quality Gate 或 Product Gate 结论）
> **采集日期 / 时区：** `2026-07-21 Asia/Shanghai`
> **Assignment：** [`RELEASE-2026-0801-08`](../assignments/release-2026-08-01-08-kaomoji-content.md)
> **运行编号：** `Q-08-02-20260721-C9F2B34-IPAD-01`、`Q-08-02-20260721-C9F2B34-IPHONE-01`
> **物理操作员：** Human Product Owner；Device Hub 观察与自动显示设置：Codex Environment Evidence Executor

## 证据边界

- 本记录只描述在指定环境中实际观察到的行为，不作通过/不通过判断，不关闭任何 Quality 或 Product Gate。
- 两台真机均为 `27.0`，因此下表全部只能作为**高版本系统运行时观察**；本次没有验证 iOS/iPadOS `26.0` 最低系统。
- 仅使用备忘录中的合成文本 `2026` 与颜表情；未记录真实输入内容。
- 按“只提交独立 evidence 文件”的范围要求，没有把 Device Hub 临时截图加入仓库。下表逐行给出可复核的实时画面观察或当次 Human Product Owner 朗读/操作观察。
- Full Access 在明确关闭前未做状态核验，相关行如实记为“未核验”，不据此推断为开启。

## 冻结构建与安装

| 字段 | 记录 |
|---|---|
| 被测提交 | `c9f2b34bd4b44dc528f39e6120db1af3f23c367e` |
| 隔离源码工作树 | `/private/tmp/uk-release-2026-08-01-kaomoji`，采集前 `HEAD` 复核为上述提交 |
| 构建 | Xcode Debug；`CFBundleShortVersionString=1.0`，`CFBundleVersion=1`；`iphoneos27.0` SDK；产物 `MinimumOSVersion=26.4` |
| 构建命令 | `xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme 'Universe Keyboard' -configuration Debug -destination 'platform=iOS,id=<iPad device id>' -derivedDataPath /private/tmp/uk-q0802-c9f2b34-derived CODE_SIGNING_ALLOWED=YES SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build` |
| 构建结果 | `BUILD SUCCEEDED`；同一签名产物通过 `devicectl device install app` 安装到两台真机 |
| 主 App 可执行文件 SHA-256 | `2d6b24381e4260eb72ac25c6ad79af0219002ce29a5389b2a7f65b69a2e1ac17` |
| Keyboard Extension 可执行文件 SHA-256 | `381c8cbbc6a4ef67569b8f8da5998adde95a436db8a9f8d62b4e1b4f010cd4b1` |

下表所有“构建 / 提交”均指同一冻结产物：`Debug 1.0 (1) / c9f2b34`。

## 逐项运行时观察

| ID | 设备 | OS | 方向 | 宿主 App | Full Access | 构建 / 提交 | 截图或可复核观察 |
|---|---|---|---|---|---|---|---|
| IPAD-01 | iPad Pro 11 英寸（第 3 代） | iPadOS 27.0（高版本观察） | 横屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | Device Hub 实时画面：九宫格右侧 `^_^` 入口可见；Human Product Owner 点按后，面板显示“返回、常用、开心、互动、情绪”及常用 12 项。 |
| IPAD-02 | iPad Pro 11 英寸（第 3 代） | iPadOS 27.0（高版本观察） | 横屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | Human Product Owner 切换到“开心”；Device Hub 实时画面观察到选中态移动、内容网格改变。 |
| IPAD-03 | iPad Pro 11 英寸（第 3 代） | iPadOS 27.0（高版本观察） | 横屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | Human Product Owner 点按“开心”第一项；Device Hub 实时画面观察到光标处精确插入 `ヽ(✿ﾟ▽ﾟ)ノ`，插入后面板保持显示。 |
| IPAD-04 | iPad Pro 11 英寸（第 3 代） | iPadOS 27.0（高版本观察） | 横屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | Human Product Owner 点按“返回”；Device Hub 实时画面观察到九宫格原键盘恢复，已插入文本保留。 |
| IPAD-05 | iPad Pro 11 英寸（第 3 代） | iPadOS 27.0（高版本观察） | 横屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | Human Product Owner 依次进入 `123`、`#+=`；Device Hub 实时画面观察到二级符号页。点按该页 `^_^` 后，同一四分类颜表情面板打开，覆盖第二入口。 |
| IPAD-06 | iPad Pro 11 英寸（第 3 代） | iPadOS 27.0（高版本观察） | 横屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | Device Hub 自动切换浅色与深色；实时画面观察到分类栏和 12 项网格在两种外观下均可辨认。 |
| IPAD-07 | iPad Pro 11 英寸（第 3 代） | iPadOS 27.0（高版本观察） | 横屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | Device Hub 将 Text Size 从 3 调至 7；实时画面观察到四个分类与 12 项仍完整可用，未出现阻断操作的截断；采集后恢复 Text Size 3。 |
| IPAD-08 | iPad Pro 11 英寸（第 3 代） | iPadOS 27.0（高版本观察） | 横屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | VoiceOver 由 Device Hub 开启；Human Product Owner 当次连续单指右滑报告顺序为：`返回键盘，关闭颜表情目录` → `颜表情分类，常用，已选中，显示常用颜表情` → `颜表情分类，开心，未选中，显示开心颜表情` → `颜表情分类，互动，未选中，显示互动颜表情` → `颜表情分类，情绪，未选中，显示情绪颜表情` → 颜表情条目。条目焦点按视觉从左到右、从上到下移动，并在页面最后一项停止；末项实际朗读报告为 `插入颜表情，插入符号（描述当前颜表情），插入当前光标位置`。本行没有音频文件，来源为当次人工朗读复述。 |
| IPAD-09 | iPad Pro 11 英寸（第 3 代） | iPadOS 27.0（高版本观察） | 横屏 | Apple 备忘录 | 关闭（Human Product Owner 当次操作） | Debug 1.0 (1) / `c9f2b34` | Human Product Owner 关闭 Full Access 后输入合成文本 `2026`；Device Hub 实时画面精确观察到 `2026`。 |
| IPAD-10 | iPad Pro 11 英寸（第 3 代） | iPadOS 27.0（高版本观察） | 横屏 | Apple 备忘录 | 关闭（Human Product Owner 当次操作） | Debug 1.0 (1) / `c9f2b34` | 同一关闭状态下打开右侧 `^_^` 面板并点按“常用”第一项；Device Hub 实时画面精确观察到后缀 `2026^_^`，面板保持显示。 |
| IPHONE-01 | iPhone 13 Pro | iOS 27.0（高版本观察） | 竖屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | Device Hub 实时画面：九宫格右侧 `^_^` 入口可见。Human Product Owner 打开面板并点按“常用”第一项；实时画面精确观察到文本 `^_^`，面板保持显示。 |
| IPHONE-02 | iPhone 13 Pro | iOS 27.0（高版本观察） | 竖屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | Human Product Owner 点按“返回”；Device Hub 实时画面观察到原九宫格恢复，已插入 `^_^` 保留。 |
| IPHONE-03 | iPhone 13 Pro | iOS 27.0（高版本观察） | 竖屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | Human Product Owner 依次进入 `123`、`#+=` 并点按二级符号页 `^_^`；Device Hub 实时画面观察到同一四分类、12 项面板打开，覆盖第二入口。 |
| IPHONE-04 | iPhone 13 Pro | iOS 27.0（高版本观察） | 竖屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | Device Hub 深色实时画面：颜表情分类栏与网格可辨认；返回原键盘后九宫格与已插入文本亦可辨认。采集结束时已恢复浅色。 |
| IPHONE-05 | iPhone 13 Pro | iOS 27.0（高版本观察） | 竖屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | Device Hub 将 Text Size 从 2 调至 7；深色实时画面观察到四个分类与 12 项仍完整可见，无阻断操作的截断；采集后恢复 Text Size 2。 |
| IPHONE-06 | iPhone 13 Pro | iOS 27.0（高版本观察） | 竖屏 | Apple 备忘录 | 未核验 | Debug 1.0 (1) / `c9f2b34` | VoiceOver 由 Device Hub 开启；Human Product Owner 当次逐步报告前三个焦点为：`返回键盘，关闭颜表情目录` → `颜表情分类，常用，已选中，显示常用颜表情` → `颜表情分类，开心，未选中，显示开心颜表情`。采集后 VoiceOver 已关闭。完整条目遍历见 IPAD-08，本行不外推未实际遍历的 iPhone 后续焦点。 |
| IPHONE-07 | iPhone 13 Pro | iOS 27.0（高版本观察） | 竖屏 | Apple 备忘录 | 关闭（Human Product Owner 当次操作） | Debug 1.0 (1) / `c9f2b34` | Human Product Owner 关闭 Full Access 后输入合成文本 `2026`，再由右侧入口打开面板并点按“常用”第一项。Device Hub 最终浅色实时画面精确观察到已有合成前缀后的连续后缀 `2026^_^`，面板保持显示。 |

## 采集后状态与限制

- Device Hub 显示设置已恢复：iPhone 为 Light、Text Size 2、VoiceOver 关闭；iPad 为 Light、Text Size 3、VoiceOver 关闭。
- iPhone 与 iPad 的 Full Access 均由 Human Product Owner 关闭；本记录没有擅自重新开启。
- Device Hub 当前可见模拟器为 iOS 26.5/27.0 等环境，没有已安装的 iOS 26.0 runtime；本次没有创建或使用模拟器证据。后续若安装 iOS 26.0 runtime，应使用新的运行编号另行补充，不能把本次 27.0 真机观察改写为最低系统验证。
- 物理设备触控、Full Access 切换及 VoiceOver 手势由 Human Product Owner 完成；Codex 只读取 Device Hub 画面并自动切换可用的外观、文字大小与 VoiceOver 开关。

## 复核交接

本文件交由 Assignment 中现有独立 **Quality Reviewer（Quality, Performance & Release Maintainer）**复核。复核者应基于本记录及其证据边界独立判断；本文件本身不表达 Quality Gate 或 Product Gate 结论。
