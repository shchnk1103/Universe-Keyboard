# 键盘数值索引

## 用途与权威

本文是当前键盘数值的带来源索引，**权威是代码**，不是新的 Product Contract。
改任何布局 / 高度 / 触摸 / 字号数值之前必须先读本文并核对源码；只读工作可直接引用本文。
数值改变时，实施者必须在同一次变更中更新本文。核对日期：2026-10-22 Asia/Shanghai；
基线：`origin/main` = `b62bde16c9b8653be58243d6ce6a6b40435a65d7`。
下列路径均相对仓库根目录，行号属于该基线；漂移后以符号名定位，不能将旧行号当作当前证据。
所有结果仅为 Executor-recorded 静态核对，不代表真机、UI-1 / UI-2 验收或 UI-4 立项。
单位未特别注明时为 pt。颜色、圆角和动画不在本次范围。

## 数值表

### 键盘行与间距

| 名称（符号） | 值 | 来源（基线） | 使用处 / 说明 |
|---|---|---|---|
| keyboardContentTopInset / BottomInset | 2 / 0 | `Keyboard/Controllers/KeyboardViewController.swift:366`；`Keyboard/Controllers/KeyboardViewController.swift:368` | rootStack 上下边界 |
| keyHeight | 45 | `Keyboard/Controllers/KeyboardViewController.swift:376` | 四行按键的期望高度 |
| keySpacing | 8 | `Keyboard/Controllers/KeyboardViewController.swift:378`；`Keyboard/Controllers/KeyboardViewController+Presentation.swift:21` | rootStack 常规行间距 |
| keyboardGroupSpacing | 10 | `Keyboard/Controllers/KeyboardViewController.swift:380` | 字母区与底行间距 |
| keyHorizontalSpacing / thirdRowFunctionSpacing | 6 / 10 | `Keyboard/Controllers/KeyboardViewController.swift:382`；`Keyboard/Controllers/KeyboardViewController.swift:384` | 行内与第三行分组横向间距 |
| primaryFunctionKeyWidth | 46 | `Keyboard/Controllers/KeyboardViewController.swift:386` | 主要功能键宽，非候选栏高度 |
| rootStack leading / trailing | +7 / -7 | `Keyboard/Controllers/KeyboardViewController+Presentation.swift:57`；`Keyboard/Controllers/KeyboardViewController+Presentation.swift:58` | 按键横向边距；候选 header 单独延伸至全宽 |
| installCandidateBarRow custom spacing | 0 | `Keyboard/Controllers/KeyboardViewController+Presentation.swift:78` | 不再额外添加候选到按键的 14pt 桥接 |
| makeLetterRow horizontalInset | 默认 0；第二行 18 | `Keyboard/Controllers/KeyboardViewController+Rows.swift:257`；`Keyboard/Controllers/KeyboardViewController+Presentation.swift:202` | 第二行横向错位，非垂直留白 |
| makeT9NineKeyChrome totalHeight | 45×4 + 8×2 + 10 = 206 | `Keyboard/Controllers/KeyboardViewController+Rows.swift:156` | 九键 host，不含候选与路径栏 |
| returnHeight | 45×2 + 10 = 100 | `Keyboard/Controllers/KeyboardViewController+Rows.swift:117` | 九键右侧跨两行 Return |
| rightStack / leftStack 宽度比 | 0.25 | `Keyboard/Controllers/KeyboardViewController+Rows.swift:138` | 右列相当于左侧四列之一 |

### 候选栏与展开面板

| 名称（符号） | 值 | 来源（基线） | 使用处 / 说明 |
|---|---|---|---|
| CandidateBar.totalHeight / normalCellHeight | 46 / 派生为 46 | `Keyboard/Views/KeyboardDesignTokens.swift:6`；`Keyboard/Views/KeyboardDesignTokens.swift:7` | 普通候选与组字 cell 总高 |
| CandidateBar.actionZoneWidth / actionSymbolSize | 56 / 22 | `Keyboard/Views/KeyboardDesignTokens.swift:8`；`Keyboard/Views/KeyboardDesignTokens.swift:9` | 操作区宽度 / 符号字号；操作区高 46 |
| CandidateBar.minimumTouchSize | 44 | `Keyboard/Views/KeyboardDesignTokens.swift:10` | 定义值，不将其误当 46pt 栏高 |
| CandidateBar.horizontalPadding / trailingContentPadding | 6 / 8 | `Keyboard/Views/KeyboardDesignTokens.swift:11`；`Keyboard/Views/KeyboardDesignTokens.swift:12` | collection section 左右边距 |
| CandidateBarView sectionInset / layout spacing | 上下 0，左右 6/8；行 / item 0 | `Keyboard/Views/CandidateBar/CandidateBarView.swift:122` | cell 触摸区连续，视觉空隙放在 cell 内 |
| ExpandedCandidates.rowHeight | 42 | `Keyboard/Views/KeyboardDesignTokens.swift:16` | 展开 cell 高度，不随文字撑高 |
| ExpandedCandidates.contentInsets | top (46−42)/2=2，left 6，bottom 6，right 8 | `Keyboard/Views/KeyboardDesignTokens.swift:18` | 展开列表内边距 |
| ExpandedCandidates.itemSpacing | 0 | `Keyboard/Views/KeyboardDesignTokens.swift:21` | 展开行 / item 间距 |
| minimumReadableExtent / minimumReadableFraction | 12 / 0.2 | `Keyboard/Views/KeyboardDesignTokens.swift:22`；`Keyboard/Views/KeyboardDesignTokens.swift:23` | 展开时首个可读项的可见程度判定 |
| firstRowTrailingReservedWidth | 56+8=64 | `Keyboard/Controllers/KeyboardViewController+ExpandedCandidatePanel.swift:538` | 仅与顶部操作区相交的行预留尾部 |
| reservedActionBottom | 46 | `Keyboard/Controllers/KeyboardViewController+ExpandedCandidatePanel.swift:9` | 顶部行预留判定的边界 |
| CandidateSizing.visualHorizontalGap / minimumTouchWidth | 4 / 44 | `Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:6`；`Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:7` | 自然宽度至少 44，再加入视觉间隙 4 |
| CandidateSizing.correctionHintSpacing | 3 | `Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:8`；`Keyboard/Views/CandidateBar/CandidateCell.swift:69` | 测量和内容 stack 的提示间距一致 |
| titleInsets | 首选 16；普通 24 | `Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:197` | 测量时加入的横向文字内边距总和 |
| expanded maxWidth | max(44, collectionWidth−16) | `Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:219` | 展开测量上限，随后仍受 flow 剩余行宽限制 |
| VisualSpacing.horizontalGap / verticalGap | 4 / 4 | `Keyboard/Views/CandidateBar/CandidateCell.swift:9`；`Keyboard/Views/CandidateBar/CandidateCell.swift:10`；`Keyboard/Views/CandidateBar/CandidateCell.swift:255` | 左右各缩 2；展开上下各缩 2，普通上下不缩 |
| CandidateActionAppearance.controlDiameter / controlBackgroundInsets | 36；上下 5、左右 10 | `Keyboard/Views/KeyboardDesignTokens.swift:36`；`Keyboard/Views/KeyboardDesignTokens.swift:38` | 操作区内部视觉 plate，不是触摸区 |
| recoveryLabel | caption1，无显式数值上限；2 行；左右 8 | `Keyboard/Views/CandidateBar/CandidateBarView.swift:158`；`Keyboard/Views/CandidateBar/CandidateBarView.swift:160`；`Keyboard/Views/CandidateBar/CandidateBarView.swift:166` | 恢复提示位于固定候选栏内 |

### 九键路径栏与路径面板

| 名称（符号） | 值 | 来源（基线） | 使用处 / 说明 |
|---|---|---|---|
| T9PinyinBar.visibleHeight | 34 | `Keyboard/Views/KeyboardDesignTokens.swift:29` | 已展开可见高度 |
| presentedT9PinyinPathBarHeight | 0 / 34 | `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:50`；`Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:51` | 空闲新周期可为 0；首次有效信号后锁存 34，不是每次清空就折叠 |
| setRowVisible collectionBottomConstraint | 显示 −1；折叠 0 | `Keyboard/Views/T9PinyinPathBarView.swift:199`；`Keyboard/Views/T9PinyinPathBarView.swift:203` | 折叠时 row 高 0，无触摸或 AX 内容 |
| Path compact sectionInset / spacing | 上下 0，左右 4；行 / item 0 | `Keyboard/Views/T9PinyinPathBarView.swift:67` | 横向 collection |
| Path compact item size | width=max(44,ceil(textWidth)+20)，height=max(0,34−1)=33 | `Keyboard/Views/T9PinyinPathBarView.swift:396` | 宽度测量按未选中 inset 10×2 |
| Path compact separator | 1/max(displayScale,1) | `Keyboard/Views/T9PinyinPathBarView.swift:135` | 1 物理像素；collection 单独保留 1pt 底部 |
| T9PinyinPathBarCell.horizontalInset | selected 8；普通 10 | `Keyboard/Views/T9PinyinPathBarView.swift:560` | 单侧文字 inset |
| T9PinyinPathBarCell contentView 最小尺寸 | 宽 44 / 高 32 | `Keyboard/Views/T9PinyinPathBarView.swift:612` | 不等于 44pt 外扩触摸高度 |
| idleHintLabel | 字号 14；左右 12 | `Keyboard/Views/T9PinyinPathBarView.swift:107`；`Keyboard/Views/T9PinyinPathBarView.swift:129` | 保留实现定义，不据此声称空闲提示实际展示 |
| makePinyinPathExpandedPanel layout | item / line 8；inset top/left/bottom/right=12/12/12/56 | `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:336` | 旧路径展开面板定义，与紧凑栏分开 |
| 路径展开 container minimumHeight | 45×4+8×3=204 | `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:358` | 最小高度约束，不是九键 host 206 |
| 路径展开 close / cell 最小尺寸 | 44×44 | `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:367`；`Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:468` | 关闭按钮与旧路径 cell |
| 路径展开 cell label inset / item 宽度 | 左右 8，上下 6；测量 textWidth+24，至少 44 | `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:464`；`Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:163` | 两处横向数字独立存在，不能混为同一个 token |

### 表情页、其它页与覆盖层

| 名称（符号） | 值 | 来源（基线） | 使用处 / 说明 |
|---|---|---|---|
| emoji container / categoryRow / grid / row spacing | 均 2 | `Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:10`；`Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:15`；`Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:36`；`Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:49` | 表情页内部 |
| emoji categoryRow height / label | 24 / 12 | `Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:69`；`Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:21` | 分类行固定高度 / 字号 |
| emoji columns / maxRows / visibleCount | 8 / 4 / 32 | `Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:41` | 初始最多显示 32 个槽 |
| emojiGrid preferred height | 45×3+8×2=151 | `Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:75` | 是 grid 内容的期望高度，不是整页解析高度 |
| emoji button font | 24 | `Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:84` | 非候选字号 |
| numbers / symbols / bottom rows | 复用 keyHeight=45 与 keySpacing=8、分组 10 | `Keyboard/Controllers/KeyboardViewController+Presentation.swift:209`；`Keyboard/Controllers/KeyboardViewController+Presentation.swift:229`；`Keyboard/Controllers/KeyboardViewController+BottomRow.swift:63` | 页构造仍复用公共几何，不另增高度设置 |
| KeyPopupView itemWidth / spacing / padding / popupHeight / gap | 36 / 2 / 8 / 38 / 6 | `Keyboard/Views/KeyPopupView.swift:103` | 变体字符覆盖层，不增加根视图请求高度 |
| KeyPopupView horizontal clamp | 3 | `Keyboard/Views/KeyPopupView.swift:120` | 左右最小边界 |
| KeyPopupView.stackView vertical inset | 上下各 4 | `Keyboard/Views/KeyPopupView.swift:145`；`Keyboard/Views/KeyPopupView.swift:146` | 标签栈内边距，独立于覆盖层外框高度 38 |
| KeyPopupView 变体 label font | 17；选中 bold，未选中 medium | `Keyboard/Views/KeyPopupView.swift:155`；`Keyboard/Views/KeyPopupView.swift:196`；`Keyboard/Views/KeyPopupView.swift:199` | 初始化与高亮切换保持相同基准字号 |
| DeleteTrashBubbleView preferredHeight / minimumHeight / gapAboveKey / topInset / width | 32 / 12 / 6 / 2 / 36 | `Keyboard/Views/DeleteTrashBubbleView.swift:5` | 覆盖层可压低；不改变按键或候选高度 |
| DeleteTrashBubbleView.symbolView size upper bounds | 宽≤容器宽−10；高≤容器高−8 | `Keyboard/Views/DeleteTrashBubbleView.swift:39`；`Keyboard/Views/DeleteTrashBubbleView.swift:40` | 符号内部约束，不是 bubble 外框内缩或根高度请求 |
| DeleteTrashBubbleView.symbolView pointSize | 15（regular） | `Keyboard/Views/DeleteTrashBubbleView.swift:42`；`Keyboard/Views/DeleteTrashBubbleView.swift:43` | trash SF Symbol 基准字号 |
| DeleteTrashBubbleView.intrinsicContentSize | 36×28 | `Keyboard/Views/DeleteTrashBubbleView.swift:70`；`Keyboard/Views/DeleteTrashBubbleView.swift:71` | intrinsic 尺寸；不同于控制器使用的 preferredHeight 32，实际外框仍受 available 限制 |
| Delete bubble 实际 height | min(32, keyMinY−6−2)，available≥12 才展示 | `Keyboard/Controllers/KeyboardViewController+DeleteActions.swift:261`；`Keyboard/Controllers/KeyboardViewController+DeleteActions.swift:265` | 容器内可用空间约束 |

### 触摸热区

| 名称（符号） | 值 | 来源（基线） | 使用处 / 说明 |
|---|---|---|---|
| KeyTouchCellLayout 中线规则 | 无固定扩展常量，取相邻键中线 | `Packages/KeyboardCore/Sources/KeyboardCore/KeyTouchCellLayout.swift:53`；`Packages/KeyboardCore/Sources/KeyboardCore/KeyTouchCellLayout.swift:129`；`Packages/KeyboardCore/Sources/KeyboardCore/KeyTouchCellLayout.swift:146` | 实时 frame 计算；首末行保持可视上下边界，首末键填至容器横边界 |
| midlineFilledColumnBounds | 相邻列中线；除以 2 | `Packages/KeyboardCore/Sources/KeyboardCore/KeyTouchCellLayout.swift:244` | 九键分列，不使 tall return 抢左列热区 |
| groupedIdentifiedRows / groupedRows | 排序 midY 差阈值 1；分行 max(8,height×0.5) | `Packages/KeyboardCore/Sources/KeyboardCore/KeyTouchCellLayout.swift:268`；`Packages/KeyboardCore/Sources/KeyboardCore/KeyTouchCellLayout.swift:278`；`Packages/KeyboardCore/Sources/KeyboardCore/KeyTouchCellLayout.swift:307` | 分行启发式常量，非热区 padding |
| KeyboardKeyButton.touchSlop | 4 | `Keyboard/Controllers/KeyboardKeyButton.swift:16`；`Keyboard/Controllers/KeyboardKeyButton.swift:29` | 有 localTouchBounds 时优先用快照；无快照时才使用 slop/outsets 回退 |
| ChromeTouchHitGeometry.pathBarMinimumHitHeight | 44 | `Packages/KeyboardCore/Sources/KeyboardCore/ChromeTouchHitGeometry.swift:9`；`Packages/KeyboardCore/Sources/KeyboardCore/ChromeTouchHitGeometry.swift:14` | max(0,(44−barHeight)/2) 向上下外扩，不增加布局高 |
| CandidateBar action hit | 全部可见 56×46，无额外 outset | `Keyboard/Views/CandidateBar/CandidateBarView.swift:4`；`Keyboard/Views/CandidateBar/CandidateBarView.swift:130`；`Keyboard/Views/CandidateBar/CandidateBarView.swift:177` | 候选 viewport 与操作区分开 |
| ExpandedCandidateCollapseButton.hitOutsets | 初值 zero | `Keyboard/Controllers/KeyboardViewController+ExpandedCandidatePanel.swift:93` | 收起操作区不侵占旁边候选 |
| 触摸资格 / frame 有效性门槛 | alpha > 0.01；frame 宽高 > 0 | `Keyboard/Controllers/KeyboardInputHitAreaStackView.swift:435`；`Keyboard/Controllers/KeyboardInputHitAreaStackView.swift:439`；`Keyboard/Controllers/KeyboardKeyButton.swift:30` | 隐藏或不可交互对象排除；这影响命中资格，不是几何扩展 padding |

### 字号与高度请求

| 名称（符号） | 值 | 来源（基线） | 使用处 / 说明 |
|---|---|---|---|
| CandidateCollectionCell.configureTitle fontSize | composition 15 / candidate 17 | `Keyboard/Views/CandidateBar/CandidateCell.swift:309` | 首选 semibold，其余 regular |
| Candidate title Dynamic Type maximumPointSize | 28 | `Keyboard/Views/CandidateBar/CandidateCell.swift:312`；`Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:195` | 渲染 / 测量必须一起更新 |
| correctionHint fontSize / maximumPointSize | 13 / 18 | `Keyboard/Views/CandidateBar/CandidateCell.swift:319`；`Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:202` | caption1 缩放，提示为 semibold |
| T9PinyinPathBarCell.titlePointSize | 16 | `Keyboard/Views/T9PinyinPathBarView.swift:548`；`Keyboard/Views/T9PinyinPathBarView.swift:588` | 当前紧凑 Path；普通 systemFont，没有 UIFontMetrics 上限 |
| T9PinyinPathCell label / measurement | 17 | `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:458`；`Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:163` | 旧展开 Path，不等于紧凑 chip |
| CandidateButtonFactory.candidateConfiguration | composition 14 / candidate 16；上限 28 | `Keyboard/Views/CandidateBar/CandidateButtonFactory.swift:100`；`Keyboard/Views/CandidateBar/CandidateButtonFactory.swift:122` | 基线 Swift 检索仅有定义，无生产调用命中；不得据此断言动态运行绝不调用 |
| functionKeySymbol / characterKeyTitle / functionKeyTitle / spaceKeyTitlePointSize | 22 / 17 / 15 / 14 | `Keyboard/Controllers/KeyboardViewController.swift:388`；`Keyboard/Controllers/KeyboardViewController.swift:390`；`Keyboard/Controllers/KeyboardViewController.swift:392`；`Keyboard/Controllers/KeyboardViewController.swift:394` | 公共按键 type scale，非候选 Dynamic Type |
| makeT9KeyButton 字母组 minimumScaleFactor | 0.7 | `Keyboard/Controllers/KeyboardViewController+KeyFactory.swift:51`；`Keyboard/Controllers/KeyboardViewController+KeyFactory.swift:52` | 已有 adjustsFontSizeToFitWidth 宽度适配比例下限，不是固定字号或 Dynamic Type 上限 |
| punctuationButton / kaomojiButton minimumScaleFactor | 均 0.55 | `Keyboard/Controllers/KeyboardViewController+Rows.swift:58`；`Keyboard/Controllers/KeyboardViewController+Rows.swift:59`；`Keyboard/Controllers/KeyboardViewController+Rows.swift:69`；`Keyboard/Controllers/KeyboardViewController+Rows.swift:70` | 标点 / 颜文字已有宽度适配比例，不表示始终按该倍率渲染 |
| selectPinyinButton minimumScaleFactor | 0.45 | `Keyboard/Controllers/KeyboardViewController+Rows.swift:202`；`Keyboard/Controllers/KeyboardViewController+Rows.swift:203` | 选拼音已有宽度适配下限，不是固定字号 |
| languageButton minimumScaleFactor（符号页返回语言键） | 0.65 | `Keyboard/Controllers/KeyboardViewController+BottomRow.swift:156`；`Keyboard/Controllers/KeyboardViewController+BottomRow.swift:157` | makeSymbolicBottomRow 内已有宽度适配下限，不是固定字号或 Dynamic Type 上限 |
| installPreferredKeyboardHeight priority | defaultHigh（750） | `Keyboard/Controllers/KeyboardViewController+Layout.swift:58`；`Keyboard/Controllers/KeyboardViewController+Layout.swift:59` ；外部 SDK `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/Frameworks/UIKit.framework/Headers/NSLayoutConstraint.h:19`（非仓库文件，随 Xcode 版本变化） | 单一 view.heightAnchor 等式期望约束，已有约束仅更新常量 |
| preferredRowHeightConstraint priority | defaultHigh（750） | `Keyboard/Controllers/KeyboardViewController+Layout.swift:66`；`Keyboard/Controllers/KeyboardViewController+Layout.swift:68` ；外部 SDK `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/Frameworks/UIKit.framework/Headers/NSLayoutConstraint.h:19`（非仓库文件，随 Xcode 版本变化） | 系统可压缩；不是硬性指定实际高度 |
| 路径 row / 候选 row / 旧路径最小高度 | 未显式降 priority，NSLayoutConstraint 默认 required（1000） | `Keyboard/Views/T9PinyinPathBarView.swift:121`；`Keyboard/Views/CandidateBar/CandidateBarView.swift:187`；`Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:358` ；外部 SDK `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/Frameworks/UIKit.framework/Headers/NSLayoutConstraint.h:18`（非仓库文件，随 Xcode 版本变化） | 与公共按键行的 defaultHigh 区别；实际求解需运行证据 |

### 独立检索补充的内边距与页面参数

| 名称（符号） | 值 | 来源（基线） | 使用处 / 说明 |
|---|---|---|---|
| CandidateCollectionCell title label inset | 高亮左右各 8；普通各 12；上下各 4 | `Keyboard/Views/CandidateBar/CandidateCell.swift:326`；`Keyboard/Views/CandidateBar/CandidateCell.swift:136` | 与 titleInsets 16/24 配对，独立于外层 gap |
| bottom row return / context key widths | Return 78；@、slash、dot 40；.com 60 | `Keyboard/Controllers/KeyboardViewController+BottomRow.swift:66`；`Keyboard/Controllers/KeyboardViewController+BottomRow.swift:74`；`Keyboard/Controllers/KeyboardViewController+BottomRow.swift:79`；`Keyboard/Controllers/KeyboardViewController+BottomRow.swift:103`；`Keyboard/Controllers/KeyboardViewController+BottomRow.swift:108` | 符号底行 Return 同为 78（同文件 :171） |
| T9 bottom space width | emojiWidth×2+keyHorizontalSpacing | `Keyboard/Controllers/KeyboardViewController+Rows.swift:239` | 1+1+2 列节奏，额外间隙为 6 |
| 旧路径展开 close placement | top 4；trailing −8 | `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:365` | 44×44 按钮的边距 |
| expanded candidate panel frame | top=候选栏 top，bottom=rootStack bottom，全键盘宽 | `Keyboard/Controllers/KeyboardViewController+ExpandedCandidatePanel.swift:452` | 覆盖候选和按键区，不另增加根高；collection 等高于 container（:582） |
| LayoutPreviewPalette keySpacing / rowSpacing | 2.5 / 3 | `Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:287`；`Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:288` | 仅静态缩略图，不与 Extension 自动联动 |
| TwentySixKeyThumbnail rows / padding | 字母行高 13；底行高 14；padding 8 | `Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:299`；`Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:311`；`Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:319` | 轮廓比例而非实际尺寸 |
| NineKeyThumbnail letterH / bottomH / returnH | 15 / 13 / 15+3+13=31 | `Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:370`；`Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:371`；`Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:380` | 静态缩略图，padding 8（:427） |

750 / 1000 的 UIKit 语义来源为上述完整路径的外部 SDK 头文件第 18–19 行：
Required=1000、DefaultHigh=750。它是外部 SDK，非仓库文件，随 Xcode 版本变化；
本次核对为 Xcode 27.1（Build 27A9275）、iPhoneSimulator SDK 27.1，
通用 iPhoneSimulator.sdk 路径解析到 iPhoneSimulator27.1.sdk。系统默认 priority 不是仓库自行定义的常量。

### 共享存储与布局设置

| 名称（符号） | 值 | 来源（基线） | 使用处 / 说明 |
|---|---|---|---|
| KeyboardViewController.appGroupID / sharedDefaults | group.com.DoubleShy0N.Universe-Keyboard | `Keyboard/Controllers/KeyboardViewController.swift:344`；`Keyboard/Controllers/KeyboardViewController.swift:345` | UserDefaults(suiteName:)；不证明无 Full Access 时可读 |
| KeyboardLayoutSettingsKey.layoutStyle | keyboard_layout_style | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift:22` | 布局偏好 |
| KeyboardLayoutStyle raw values / defaultStyle | twenty_six_key / nine_key；默认 twentySixKey | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift:7`；`Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift:10` | 缺失 / 未知解码回 26 键 |
| schemeBinding26 / schemeBinding9 | keyboard_layout_scheme_26 / keyboard_layout_scheme_9 | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift:24`；`Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift:26` | 中文两种布局的方案绑定 |
| RimeT9Readiness.SettingsKey.marker / legacyReady | rime_t9_readiness_marker / rime_t9_ready | `Packages/KeyboardCore/Sources/KeyboardCore/RimeT9Readiness.swift:31`；`Packages/KeyboardCore/Sources/KeyboardCore/RimeT9Readiness.swift:33` | JSON marker 为准，单个 legacy 布尔不足以匹配 |
| currentCompatibilityVersion | 字符串 2 | `Packages/KeyboardCore/Sources/KeyboardCore/RimeT9Readiness.swift:27` | readiness 匹配还需要资源 fingerprint |
| KeyboardLayoutSettingsView.previewSize | 148×112 | `Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:17` | 主 App 的静态缩略图，不是 Extension 高度或实时预览 |

共享标识只列实际存在的布局 / readiness 存储；本基线 `keyHeight` 是实例 `let`（45），
候选字号也直接定义于代码，未在这些设置键中发现“键盘高度 / 候选字号”设置。
设置快照读取见 `Keyboard/Controllers/KeyboardViewController+Feedback.swift:114`；
`+Bootstrap.swift:183` 在 viewDidLoad 刷新，`:195` 判断是否返回已有键盘，`:199` 才再次刷新。
首次安装位于 `Keyboard/Controllers/KeyboardViewController.swift:469` 的 viewWillAppear 路径；
这证明静态调用安排，不替代所有宿主下的首次生命周期时序证据。

## 合计高度与测试固定值

`keyboardHeightWithoutT9Path`（`Keyboard/Controllers/KeyboardViewController+Layout.swift:36`）：

- 26 键：top + candidates + 4×keyHeight + 2×keySpacing + groupSpacing + bottom
  = 2 + 46 + 4×45 + 2×8 + 10 + 0 = **254**。
- 九键新周期空闲、路径栏 0：254 + 0 = **254**。
- 九键路径栏已展开 / 本周期锁存：254 + 34 = **288**。

这是 `preferredKeyboardHeight` 的请求值（同文件 `:45` 与 `+T9PinyinPath.swift:50`），不是系统实授高度。
九键普通 chrome 206 与旧路径面板下限 204 使用不同间距公式，不能互换。
表情 grid 151 不足以推导表情整页最终高度：category 24、内部 spacing 2、滚动 viewport、
底行及 rootStack 约束还参与求解（`+EmojiLayout.swift:69`；`+Presentation.swift:245`）。

固定值断言及检索范围：

- `KeyboardTests/ControllerLayout/CompactHeaderControllerLayoutTests.swift:177`：254；`:22,175`：46；`:656`：45。
- `KeyboardLayoutIntegrationTests/T9AdaptiveRowTests.swift:13,14`：254 / 288；`:21`：45；
  34 的断言或构造位于 `:37,86,93,104,123,127,181,211,236,247,297,324,327,337,367,492,535,545`。
- `KeyboardExtensionTests/CompactCandidateBarLayoutTests.swift:11,13,38,117,161,164`：46；`:18` 的 45 是操作区采样坐标。
- `KeyboardExtensionTests/KeyRecoveryAccessibilityTests.swift:70,72`：45 高度 fixture。
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/KeyTouchCellLayoutTests.swift`：多处 45 行高 / 中线、46 宽度、34 路径栏 fixture；
  `:7,17,33,76,380,382,494` 是各类代表位置，完整命中可用下节全仓检索复现，254 在 `:382` 是 x 坐标而非总高。
- `UniverseKeyboardUITests/T9DevicePreflightUITests.swift:179,183,187,217,221,1362–1369`：45 高度 fixture。
- 其它数字同值但**非布局合同**的命中：`KeyboardExtensionTests/TypoCorrectionRecallCoordinatorIntegrationTests.swift:378` 的 34 次循环；
  `KeyboardExtensionTests/CandidatePagingConsumerFixtureTests.swift:410` 的 0.45 alpha；
  `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9ResponsiveEvidenceValidatorTests.swift:10` 的 288 坐标；
  `Packages/KeyboardCore/Tests/KeyboardCoreTests/UnzipArchiveReadingTests.swift:303` 的 46 字节；
  `Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9AutoAnchorRetryMatrixTests.swift:2601,2660` 的 34 槽位。

以上是静态定位，**没有运行这些测试，也不声明测试通过**。


### 测试同值完整命中位置（基线快照）

以下是全仓 rg 的全部文件与行号，含非布局命中，不把同值误判为高度合同。

- `KeyboardExtensionTests/CandidatePagingConsumerFixtureTests.swift`：410。
- `KeyboardExtensionTests/CompactCandidateBarLayoutTests.swift`：11, 13, 18, 38, 117, 161, 164。
- `KeyboardExtensionTests/KeyRecoveryAccessibilityTests.swift`：70, 72。
- `KeyboardExtensionTests/TypoCorrectionRecallCoordinatorIntegrationTests.swift`：378。
- `KeyboardLayoutIntegrationTests/T9AdaptiveRowTests.swift`：13, 14, 21, 37, 86, 93, 104, 123, 127, 181, 211, 236, 247, 297, 324, 327, 337, 367, 492, 535, 545。
- `KeyboardTests/ControllerLayout/CompactHeaderControllerLayoutTests.swift`：22, 175, 177, 656。
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/KeyTouchCellLayoutTests.swift`：7, 8, 11, 17, 18, 20, 30, 31, 32, 33, 34, 58, 59, 62, 76, 132, 156, 180, 184, 188, 189, 221, 233, 234, 235, 236, 262, 263, 264, 265, 308, 309, 319, 320, 324, 380, 382, 436, 440, 464, 468, 472, 494。
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9ResponsiveEvidenceValidatorTests.swift`：10。
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/UnzipArchiveReadingTests.swift`：303。
- `Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9AutoAnchorRetryMatrixTests.swift`：2601, 2660。
- `UniverseKeyboardUITests/T9DevicePreflightUITests.swift`：179, 183, 187, 217, 221, 1362, 1363, 1364, 1365, 1366, 1367, 1368, 1369。

## 已知分歧（只列出，不修）

1. 本地 `docs/plans/keyboard-height-and-candidate-size-discussion-2026-10-08.md`（未提交，不在仓库）`:15–19,49` 写
   候选 34、额外间距 14、总高约 256/290；基线 `KeyboardDesignTokens.swift:6` 为 46、
   `+Presentation.swift:78` 为 0、`+Layout.swift:36–46` 得 254/288，且九键空闲可 254。
2. 同一本地记录 `:19` 提到 UI_STYLE_GUIDE 的 8；基线 `docs/UI_STYLE_GUIDE.md:60–61` 已是 46/0，
   `:68` 的 8 是行距。旧说法不是当前冻结基线。
3. `docs/PROJECT_CONTEXT.md:261` 描述 216pt、view.alpha=0、height>0且<400 后显示，并声称处理全部高度；
   `Keyboard/Controllers/KeyboardViewController+Layout.swift:51–69` 实际以 750 约束请求高度，
   `KeyboardViewController.swift:808–834` 负责布局后几何更新与日志。按下节关键词扫描未找到所述 alpha/400 显示机制；
   216pt 下实际压缩仍 UNKNOWN。
4. ADR 0020（`docs/architecture/decisions/0020-t9-precise-pinyin-path-selection.md:107`）和
   ADR 0023（`docs/architecture/decisions/0023-t9-complete-local-path-catalog-and-atomic-presentation.md:67`）写固定 34；
   `+T9PinyinPath.swift:49–52`、`docs/UI_STYLE_GUIDE.md:46,52` 已记录 0/34 锁存自适应。
5. `Keyboard/Controllers/KeyboardViewController+Presentation.swift:5` 注释称不请求自定义高度；
   同文件 `:116,176` 实际安装请求。`+Layout.swift:49–50` 的 compact/reduction 注释不能完整表达当前
   `:45–46` 与 `+T9PinyinPath.swift:49–65` 的 0/34 高度变化。另 `KeyboardViewController.swift:371` 仍称 fixed reservation。
6. `Keyboard/Views/CandidateBar/CandidateButtonFactory.swift:100` 定义 14/16，`:119` 注释称候选栏 44；
   当前 `CandidateCell.swift:309` 与 `+CandidateDataSource.swift:191` 为 15/17，`KeyboardDesignTokens.swift:6` 为 46。
   同一文件 `Keyboard/Views/CandidateBar/CandidateButtonFactory.swift:89` 的注释写高亮 contentInsets 为 6，
   实际 `Keyboard/Views/CandidateBar/CandidateButtonFactory.swift:110` 为左右各 8；仅记录，不改源码。
   全仓 Swift 引用检索只有 factory 定义与测试注释，未发现生产调用；“完全死代码”不作运行时结论。
7. 盘点材料把 Path chip 记为 17；紧凑 Path `Keyboard/Views/T9PinyinPathBarView.swift:548` 实为 16，
   17 对应旧展开 Path `+T9PinyinPath.swift:458`。这属于参数归属差异，不修代码。
8. 独立重复常量：44 分别出现在 `ChromeTouchHitGeometry.swift:9`、`+CandidateDataSource.swift:7`、
   `KeyboardDesignTokens.swift:10` 与 `T9PinyinPathBarView.swift:612`；34 同时用于
   `KeyboardDesignTokens.swift:29` 的高度与 `KeyboardViewController.swift:374` 的遮罩圆角，语义不同。
   4pt 视觉 gap 在 `CandidateCell.swift:9` 与 `+CandidateDataSource.swift:6` 重复；15/17、28、13/18 的
   渲染 / 测量定义也重复（表中两侧来源）。相同数字不代表共享权威或应自动联动。
9. `docs/KEYBOARD_LAYOUT.md:81` 已写新周期 0 / Sticky34，但 `:82` 仍称空闲保留、无高度跳变；
   与 `+T9PinyinPath.swift:49–52` 的初始 0 不完全一致。同文 `:100` 起的历史 UI-1 固定 34 叙述
   不能用作当前 UI-2 行为证据。
10. 盘点材料说设置刷新只在 viewDidLoad / viewDidAppear 调用，但未区分首次；
    `+Bootstrap.swift:195–199` 明确仅返回已有键盘才在 appear 刷新。首次复用快照，见
    `docs/PROJECT_CONTEXT.md:257`；不据此声称已验证实际宿主安装顺序。

路径简称在本节未带目录时，指上表同名基线源码；盘点材料本身是外部非权威输入，见本任务 Assignment。

## UNKNOWN 清单

- 横屏、小窗、不同宿主 / 系统最终实际高度：UNKNOWN；750 请求不等于系统实授尺寸。
- 系统仅给 216pt 时每行如何压缩、是否存在裁切 / 约束冲突：UNKNOWN，未运行 Extension。
- 表情页真实 viewport / 最终整页解析高度：UNKNOWN；不能把内容 grid 151 当整页高。
- 设置快照与所有宿主下首次安装的真实时序、返回刷新是否触发目标重建：UNKNOWN；这里只核对静态调用点。
- 没有 Full Access 时真实 App Group UserDefaults 读取能力：UNKNOWN，suite 创建不等于权限能力证据。
- 大字号下真实裁切与 VoiceOver / Dynamic Type 可用性：UNKNOWN；代码固定栏高不代表已验证渲染。
- factory 的动态运行可达性、旧路径面板实际产品入口：UNKNOWN；引用检索只给静态证据。

## 核对方法

在仓库中运行只读命令；先确认 SHA，再核对符号与值。以下无需新增脚本：

```bash
git rev-parse origin/main
git show b62bde16c9b8653be58243d6ce6a6b40435a65d7:Keyboard/Views/KeyboardDesignTokens.swift
git show b62bde16c9b8653be58243d6ce6a6b40435a65d7:Keyboard/Controllers/KeyboardViewController+Layout.swift
git grep -n -E 'keyHeight|keySpacing|keyboardContent|PointSize' b62bde16c9b8653be58243d6ce6a6b40435a65d7 -- Keyboard/Controllers/KeyboardViewController.swift
git grep -n -E 'fontSize|maximumPointSize|titlePointSize|touchSlop|pathBarMinimumHitHeight' b62bde16c9b8653be58243d6ce6a6b40435a65d7 -- Keyboard/ Packages/KeyboardCore/
git grep -n -E 'alpha = 0|< 400|216' b62bde16c9b8653be58243d6ce6a6b40435a65d7 -- Keyboard/
git grep -n 'CandidateButtonFactory' b62bde16c9b8653be58243d6ce6a6b40435a65d7 -- '*.swift'
rg -n '\b(45|46|34|254|288)\b' --glob '*Tests.swift' --glob '!**/.build/**'
git diff b62bde16c9b8653be58243d6ce6a6b40435a65d7 HEAD -- Keyboard/ Packages/KeyboardCore/ 'Universe Keyboard/'
```

过期判据：关联源码 / 设置键 / 公式 / 调用边界发生变化而本文尚未同步，或源符号无法定位、值与行号不符。
仅 SHA 前进不自动使所有值错误；应逐项核对相关 diff。rg 命令读当前 checkout，复核该快照时需在同基线 checkout 中执行。

## 更新规则

任何修改相关数值的 Executor，在同一变更中更新此索引及公式、来源、测试固定值和分歧 / UNKNOWN；
Reviewer 按源码逐行核对，Coordinator 不以盘点材料取代源码。来源移动也应更新行号与核对基线。
`docs/UI_STYLE_GUIDE.md` 的冻结基线是承诺的基准，本文记录当前代码实际值；两者不同须列在已知分歧，
不得悄悄修改冻结基线。现基线冻结表的 46/0/45 与代码一致；这不抹去 ADR / 历史文档的漂移，
也不授予改变 Product Contract 的权限。未来高度可调或字号设置须单独立项；本文不增加任何设置。
