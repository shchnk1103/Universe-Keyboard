# 键盘数值索引

## 用途与权威

本文是当前键盘数值的带来源索引，**权威是代码**，不是新的 Product Contract。
改任何布局 / 高度 / 触摸 / 字号数值之前必须先读本文并核对源码；只读工作可直接引用本文。
数值改变时，实施者必须在同一次变更中更新本文。原始盘点日期：2026-10-22 Asia/Shanghai；
基线：`origin/main` = `b62bde16c9b8653be58243d6ce6a6b40435a65d7`。
下列路径均相对仓库根目录，行号属于该基线；漂移后以符号名定位，不能将旧行号当作当前证据。
P5 高度镜像核对日期：2026-10-24 Asia/Shanghai；高度相关更新基线为
`160bd713efbfe8eebb17b22ddd058d73ee54b9a1`（下称 P5 高度基线）。本次更新的来源使用符号定位；
其余表项、历史测试命中与分歧保留原始盘点基线，不声明已全量刷新行号。
UI3 P3/P4 字号及受本次抽取影响的来源核对基线为 `76bfd4fbdd1673656c80c5cd104184dff95e5bc4`；下方字号与共享键新增行使用该提交的当前行号。
所有数值核对仅为 Executor-recorded 静态证据，不代表真机验收、合并或 Release。
单位未特别注明时为 pt。颜色、圆角和动画不在本次范围。

## 数值表

### 键盘行与间距

| 名称（符号） | 值 | 来源（基线） | 使用处 / 说明 |
|---|---|---|---|
| keyboardContentTopInset / BottomInset | 2 / 0 | `Keyboard/Controllers/KeyboardViewController.swift:366`；`Keyboard/Controllers/KeyboardViewController.swift:368` | rootStack 上下边界 |
| keyHeight | 默认 45；运行时为有效行高 h | P5 高度基线：`Keyboard/Controllers/KeyboardViewController.swift` 的 keyHeight；`Keyboard/Controllers/KeyboardViewController+HeightSettings.swift` 的 resolveKeyboardRowHeight | 四行共用；保存值经方向封顶与宿主实授预算夹取，不是固定常量 |
| keySpacing | 8 | `Keyboard/Controllers/KeyboardViewController.swift:378`；`Keyboard/Controllers/KeyboardViewController+Presentation.swift:21` | rootStack 常规行间距 |
| keyboardGroupSpacing | 10 | `Keyboard/Controllers/KeyboardViewController.swift:380` | 字母区与底行间距 |
| keyHorizontalSpacing / thirdRowFunctionSpacing | 6 / 10 | `Keyboard/Controllers/KeyboardViewController.swift:382`；`Keyboard/Controllers/KeyboardViewController.swift:384` | 行内与第三行分组横向间距 |
| primaryFunctionKeyWidth | 46 | `Keyboard/Controllers/KeyboardViewController.swift:386` | 主要功能键宽，非候选栏高度 |
| rootStack leading / trailing | +7 / -7 | `Keyboard/Controllers/KeyboardViewController+Presentation.swift:57`；`Keyboard/Controllers/KeyboardViewController+Presentation.swift:58` | 按键横向边距；候选 header 单独延伸至全宽 |
| installCandidateBarRow custom spacing | 0 | `Keyboard/Controllers/KeyboardViewController+Presentation.swift:78` | 不再额外添加候选到按键的 14pt 桥接 |
| makeLetterRow horizontalInset | 默认 0；第二行 18 | `Keyboard/Controllers/KeyboardViewController+Rows.swift:257`；`Keyboard/Controllers/KeyboardViewController+Presentation.swift:202` | 第二行横向错位，非垂直留白 |
| makeT9NineKeyChrome totalHeight | 4×h + 8×2 + 10；默认 206 | `Keyboard/Controllers/KeyboardViewController+Rows.swift:155` 的 preferredRowHeightConstraint(for: host, rows: 4, extraHeight: keySpacing * 2 + keyboardGroupSpacing) | 九键 host，不含候选与路径栏 |
| makeT9NineKeyChrome / returnButton 高度 | 2×h + 10；默认 100 | `Keyboard/Controllers/KeyboardViewController+Rows.swift:119` 的 preferredRowHeightConstraint(for: returnButton, rows: 2, extraHeight: keyboardGroupSpacing) | 九键右侧跨两行 Return；当前源码无 returnHeight 局部符号 |
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
| CandidateSizing.correctionHintSpacing | 3 | `Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:8`；`Keyboard/Views/CandidateBar/CandidateCell.swift:70` | 测量和内容 stack 的提示间距一致 |
| titleInsets | 首选 16；普通 24 | `Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:199` | 测量时加入的横向文字内边距总和 |
| expanded maxWidth | max(44, collectionWidth−16) | `Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:218` | 展开测量上限，随后仍受 flow 剩余行宽限制 |
| VisualSpacing.horizontalGap / verticalGap | 4 / 4 | `Keyboard/Views/CandidateBar/CandidateCell.swift:9`；`Keyboard/Views/CandidateBar/CandidateCell.swift:10`；`Keyboard/Views/CandidateBar/CandidateCell.swift:261` | 左右各缩 2；展开上下各缩 2，普通上下不缩 |
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
| makePinyinPathExpandedPanel / container 最小高度 | 4×h+8×3；默认 204 | `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:360` 的 preferredRowHeightConstraint；`:361` 的 rows: 4 / extraHeight: keySpacing * 3 / minimum: true（约束调用至362） | 最小高度约束，不是九键 host 206 |
| 路径展开 close / cell 最小尺寸 | 44×44 | `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:367`；`Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:468` | 关闭按钮与旧路径 cell |
| 路径展开 cell label inset / item 宽度 | 左右 8，上下 6；测量 textWidth+24，至少 44 | `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:464`；`Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:163` | 两处横向数字独立存在，不能混为同一个 token |

### 表情页、其它页与覆盖层

| 名称（符号） | 值 | 来源（基线） | 使用处 / 说明 |
|---|---|---|---|
| emoji container / categoryRow / grid / row spacing | 均 2 | `Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:10`；`Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:15`；`Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:36`；`Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:49` | 表情页内部 |
| emoji categoryRow height / label | 24 / 12 | `Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:69`；`Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:21` | 分类行固定高度 / 字号 |
| emoji columns / maxRows / visibleCount | 8 / 4 / 32 | `Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:41` | 初始最多显示 32 个槽 |
| emojiGrid preferred height | 3×h+8×2；默认 151 | `Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:75` | 是 grid 内容的期望高度，不是整页解析高度 |
| emoji button font | 24 | `Keyboard/Controllers/KeyboardViewController+EmojiLayout.swift:84` | 非候选字号 |
| numbers / symbols / bottom rows | 复用有效 keyHeight=h（默认45）与 keySpacing=8、分组10 | `Keyboard/Controllers/KeyboardViewController+Presentation.swift:183` 的 addKeyboardRows(for:)：`:213` numbers、`:233` symbols；`Keyboard/Controllers/KeyboardViewController+BottomRow.swift:16` 的 makeBottomRow 在 `:63` 接入公共行约束 | 页构造仍复用公共几何，不另增高度设置 |
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
| CandidateFontSettings.policy(isComposition:) / CandidateFontSnapshot.titleFont(kind:preferred:) | 默认 composition 15 / candidate 17；其它档 n−2 / n | `Packages/KeyboardCore/Sources/KeyboardCore/CandidateFontSettings.swift:28`；`Keyboard/Views/CandidateBar/CandidateFontSnapshot.swift:15`；`Keyboard/Views/CandidateBar/CandidateCell.swift:321` | 首选 semibold，其余 regular；预览共用此函数 |
| CandidateFontSnapshot.titleFont(kind:preferred:) Dynamic Type maximumPointSize | 默认档各28；其它档不缩放 | `Keyboard/Views/CandidateBar/CandidateFontSnapshot.swift:20`；`Keyboard/Views/CandidateBar/CandidateFontSnapshot.swift:22`；`Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:198` | 渲染 / 测量共用同一快照 |
| CandidateFontSnapshot.correctionHintFont fontSize / maximumPointSize | 13 / 18 | `Keyboard/Views/CandidateBar/CandidateFontSnapshot.swift:25`；`Keyboard/Views/CandidateBar/CandidateFontSnapshot.swift:27`；`Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:203` | caption1 缩放，提示为 semibold |
| T9PinyinPathBarCell.titlePointSize | 16 | `Keyboard/Views/T9PinyinPathBarView.swift:548`；`Keyboard/Views/T9PinyinPathBarView.swift:588` | 当前紧凑 Path；普通 systemFont，没有 UIFontMetrics 上限 |
| T9PinyinPathCell label / measurement | 17 | `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:458`；`Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift:163` | 旧展开 Path，不等于紧凑 chip |
| CandidateButtonFactory.candidateConfiguration | composition 14 / candidate 16；上限 28 | `Keyboard/Views/CandidateBar/CandidateButtonFactory.swift:100`；`Keyboard/Views/CandidateBar/CandidateButtonFactory.swift:122` | 基线 Swift 检索仅有定义，无生产调用命中；不得据此断言动态运行绝不调用 |
| functionKeySymbol / characterKeyTitle / functionKeyTitle / spaceKeyTitlePointSize | 22 / 17 / 15 / 14 | `Keyboard/Controllers/KeyboardViewController.swift:388`；`Keyboard/Controllers/KeyboardViewController.swift:390`；`Keyboard/Controllers/KeyboardViewController.swift:392`；`Keyboard/Controllers/KeyboardViewController.swift:394` | 公共按键 type scale，非候选 Dynamic Type |
| makeT9KeyButton 字母组 minimumScaleFactor | 0.7 | `Keyboard/Controllers/KeyboardViewController+KeyFactory.swift:51`；`Keyboard/Controllers/KeyboardViewController+KeyFactory.swift:52` | 已有 adjustsFontSizeToFitWidth 宽度适配比例下限，不是固定字号或 Dynamic Type 上限 |
| punctuationButton / kaomojiButton minimumScaleFactor | 均 0.55 | `Keyboard/Controllers/KeyboardViewController+Rows.swift:58`；`Keyboard/Controllers/KeyboardViewController+Rows.swift:59`；`Keyboard/Controllers/KeyboardViewController+Rows.swift:69`；`Keyboard/Controllers/KeyboardViewController+Rows.swift:70` | 标点 / 颜文字已有宽度适配比例，不表示始终按该倍率渲染 |
| selectPinyinButton minimumScaleFactor | 0.45 | `Keyboard/Controllers/KeyboardViewController+Rows.swift:202`；`Keyboard/Controllers/KeyboardViewController+Rows.swift:203` | 选拼音已有宽度适配下限，不是固定字号 |
| languageButton minimumScaleFactor（符号页返回语言键） | 0.65 | `Keyboard/Controllers/KeyboardViewController+BottomRow.swift:156`；`Keyboard/Controllers/KeyboardViewController+BottomRow.swift:157` | makeSymbolicBottomRow 内已有宽度适配下限，不是固定字号或 Dynamic Type 上限 |
| installPreferredKeyboardHeight priority | 常态 defaultHigh（750）；旋转后条件性 999 | P3-R2：`Keyboard/Controllers/KeyboardViewController+Layout.swift` 的 KeyboardHeightRotationPriority / installPreferredKeyboardHeight；`Keyboard/Controllers/KeyboardViewController.swift` 的 viewWillTransition / viewWillDisappear | 持有租约绑定约束身份；下一旋转、消失、换约束、窗口移除或宿主suspend恢复750，不是硬性指定系统实授 |
| preferredRowHeightConstraint priority | defaultHigh（750） | `Keyboard/Controllers/KeyboardViewController+Layout.swift:66`；`Keyboard/Controllers/KeyboardViewController+Layout.swift:68` ；外部 SDK `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/Frameworks/UIKit.framework/Headers/NSLayoutConstraint.h:19`（非仓库文件，随 Xcode 版本变化） | 系统可压缩；不是硬性指定实际高度 |
| 路径 row / 候选 row / 旧路径最小高度 | 未显式降 priority，NSLayoutConstraint 默认 required（1000） | `Keyboard/Views/T9PinyinPathBarView.swift:121`；`Keyboard/Views/CandidateBar/CandidateBarView.swift:187`；`Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:358` ；外部 SDK `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/Frameworks/UIKit.framework/Headers/NSLayoutConstraint.h:18`（非仓库文件，随 Xcode 版本变化） | 与公共按键行的 defaultHigh 区别；实际求解需运行证据 |

### 独立检索补充的内边距与页面参数

| 名称（符号） | 值 | 来源（基线） | 使用处 / 说明 |
|---|---|---|---|
| CandidateCollectionCell title label inset | 高亮左右各 8；普通各 12；上下各 4 | `Keyboard/Views/CandidateBar/CandidateCell.swift:333`；`Keyboard/Views/CandidateBar/CandidateCell.swift:137` | 与 titleInsets 16/24 配对，独立于外层 gap |
| bottom row return / context key widths | Return 78；@、slash、dot 40；.com 60 | `Keyboard/Controllers/KeyboardViewController+BottomRow.swift:66`；`Keyboard/Controllers/KeyboardViewController+BottomRow.swift:74`；`Keyboard/Controllers/KeyboardViewController+BottomRow.swift:79`；`Keyboard/Controllers/KeyboardViewController+BottomRow.swift:103`；`Keyboard/Controllers/KeyboardViewController+BottomRow.swift:108` | 符号底行 Return 同为 78（同文件 :171） |
| T9 bottom space width | emojiWidth×2+keyHorizontalSpacing | `Keyboard/Controllers/KeyboardViewController+Rows.swift:239` | 1+1+2 列节奏，额外间隙为 6 |
| 旧路径展开 close placement | top 4；trailing −8 | `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:365` | 44×44 按钮的边距 |
| expanded candidate panel frame | top=候选栏 top，bottom=rootStack bottom，全键盘宽 | `Keyboard/Controllers/KeyboardViewController+ExpandedCandidatePanel.swift:452` | 覆盖候选和按键区，不另增加根高；collection 等高于 container（:582） |
| LayoutPreviewPalette keySpacing / rowSpacing | 2.5 / 3 | `Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:290`；`Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:291` | 仅静态缩略图，不与 Extension 自动联动 |
| TwentySixKeyThumbnail rows / padding | 字母行高 13；底行高 14；padding 8 | `Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:302`；`Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:314`；`Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:322` | 轮廓比例而非实际尺寸 |
| NineKeyThumbnail letterH / bottomH / returnH | 15 / 13 / 15+3+13=31 | `Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:373`；`Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:374`；`Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:383` | 静态缩略图，padding 8（:430） |

750 / 1000 的 UIKit 语义来源为上述完整路径的外部 SDK 头文件第 18–19 行：
Required=1000、DefaultHigh=750。它是外部 SDK，非仓库文件，随 Xcode 版本变化；
本次核对为 Xcode 27.1（Build 27A9275）、iPhoneSimulator SDK 27.1，
通用 iPhoneSimulator.sdk 路径解析到 iPhoneSimulator27.1.sdk。系统默认 priority 不是仓库自行定义的常量。

### 共享存储与布局设置

UI3-FONT-001 P3/P4 登记：`keyboard_candidate_font_size`（`CandidateFontSettings.storageKey`）在
App Group 保存整数档位13–22；17、缺省/删除、非法类型或越界均解析为默认动态档。
主 App `CandidateFontSettingsPageModel.select(_:)` 写入整数，选17删除该键；只用App Group，不回退到扩展私有域。键盘通过 `KeyboardViewController+CandidateFont.swift` 的
`prepareCandidateFontForAppearance` 在首次构造前及每次出现前幂等读取并冻结快照，消失后才允许重读。
独立文件 `CandidateFontSnapshot.swift` 的 `CandidateFontSnapshot` 是唯一 UIKit 字体物化入口，渲染与
`KeyboardViewController+CandidateDataSource.swift` 的测量使用同一快照/trait；默认分别缩放17/15、
各封顶28，固定其它档为n/n−2且不缩放。更新快照同时清除尺寸缓存并失效普通/展开布局。
完全访问关闭时主 App 写→键盘采用仍为UNKNOWN；读取失败回默认，不是已证明的跨进程采用。

| 名称（符号） | 值 | 来源（基线） | 使用处 / 说明 |
|---|---|---|---|
| CandidateFontSettings.storageKey | keyboard_candidate_font_size | `Packages/KeyboardCore/Sources/KeyboardCore/CandidateFontSettings.swift:6` | 共享整数档位13–22；缺省/非法回默认17 |
| CandidateFontSettingsPageModel.init(defaults:) / select(_:) | 读初值；17删键，其它档写整数 | `Universe Keyboard/Models/CandidateFontSettingsPageModel.swift:12`；`Universe Keyboard/Models/CandidateFontSettingsPageModel.swift:19`；`Universe Keyboard/Models/CandidateFontSettingsPageModel.swift:24`；`Universe Keyboard/Models/CandidateFontSettingsPageModel.swift:26` | 主 App App Group；不读扩展私有存储 |
| KeyboardViewController.appGroupID / sharedDefaults | group.com.DoubleShy0N.Universe-Keyboard | `Keyboard/Controllers/KeyboardViewController.swift:359`；`Keyboard/Controllers/KeyboardViewController.swift:360` | UserDefaults(suiteName:)；不证明无 Full Access 时可读 |
| KeyboardLayoutSettingsKey.layoutStyle | keyboard_layout_style | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift:22` | 布局偏好 |
| KeyboardLayoutStyle raw values / defaultStyle | twenty_six_key / nine_key；默认 twentySixKey | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift:7`；`Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift:10` | 缺失 / 未知解码回 26 键 |
| schemeBinding26 / schemeBinding9 | keyboard_layout_scheme_26 / keyboard_layout_scheme_9 | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift:24`；`Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift:26` | 中文两种布局的方案绑定 |
| RimeT9Readiness.SettingsKey.marker / legacyReady | rime_t9_readiness_marker / rime_t9_ready | `Packages/KeyboardCore/Sources/KeyboardCore/RimeT9Readiness.swift:31`；`Packages/KeyboardCore/Sources/KeyboardCore/RimeT9Readiness.swift:33` | JSON marker 为准，单个 legacy 布尔不足以匹配 |
| currentCompatibilityVersion | 字符串 2 | `Packages/KeyboardCore/Sources/KeyboardCore/RimeT9Readiness.swift:27` | readiness 匹配还需要资源 fingerprint |
| KeyboardLayoutSettingsView.previewSize | 148×112 | `Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift:17` | 主 App 的静态缩略图，不是 Extension 高度或实时预览 |

共享标识表保留原始布局 / readiness 盘点。P5 高度基线的 `keyHeight` 已是可变有效值；
`Keyboard/Services/KeyboardHeightAdjustmentSession.swift` 的 `KeyboardHeightPreferenceStore.rowHeightKey`
为 `keyboard_private_row_height`，仅存于扩展自己的 UserDefaults 域，不是 App Group 高度设置键。
主 App 不读取保存行高；缺省为45，重置在确定时删除保存键。
设置快照读取见 `Keyboard/Controllers/KeyboardViewController+Feedback.swift:114`；
`+Bootstrap.swift:183` 在 viewDidLoad 刷新，`:195` 判断是否返回已有键盘，`:199` 才再次刷新。
首次安装位于 `Keyboard/Controllers/KeyboardViewController.swift:469` 的 viewWillAppear 路径；
这证明静态调用安排，不替代所有宿主下的首次生命周期时序证据。

## 合计高度与测试固定值

### P5 当前高度模型

以下均以 P5 高度基线源码为准，不构成新增产品决定：

- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardHeightSettings.swift`：默认45、下限40；
  竖屏上限为 floor((屏幕高度×0.5−固定部分)/4)，横屏行高上限45。无有效几何或预算不足40时交调用方处理，不静默突破下限。
- `Keyboard/Controllers/KeyboardViewController+HeightSettings.swift` 的 resolveKeyboardRowHeight：
  固定部分 F=2+46+2×8+10+0+路径栏高度=74+路径栏高度；宿主预算更低时再夹取有效行高 h，
  不将压缩后的值自动写回保存值；不足四行40pt时隐藏并等待可用几何。
- 候选栏仍为46，九宫格路径栏仍为0/34；本次行高设置不改变它们，也不改变横向间距、字号或按键宽度。
- 行约束通过 `Keyboard/Controllers/KeyboardViewController+Layout.swift` 的 preferredRowHeightConstraint
  跟随 h；九键 host=4h+26、跨行 Return=2h+10、旧路径面板下限=4h+24、表情 grid=3h+16。
  表中206/100/204/151仅为 h=45 的默认派生值，相关来源以这些文件的同名符号定位。
- 默认行高不变：h=45 时，无路径总高254，有34pt路径总高288。有效行高可以变化，默认高度并非所有保存值下的总高。
- P3-R1 拖动期间只更新待定值，松手应用预览，确定才持久化；此处只镜像当前实现，不宣称真机持久化、封顶、40pt或触觉验收通过。

### 默认派生高度与历史测试快照

`keyboardHeightWithoutT9Path`（`Keyboard/Controllers/KeyboardViewController+Layout.swift:36`）：

- 26 键：top + candidates + 4×h + 2×keySpacing + groupSpacing + bottom = **4h+74**；
  默认 h=45 时，2 + 46 + 4×45 + 2×8 + 10 + 0 = **254**。
- 九键新周期空闲、路径栏0：4h+74；默认 **254**。
- 九键路径栏已展开 / 本周期锁存：4h+108；默认254+34=**288**。

这是 `preferredKeyboardHeight` 的请求值（同文件 `:45` 与 `+T9PinyinPath.swift:50`），不是系统实授高度。
九键普通 chrome 默认206与旧路径面板下限默认204使用不同间距公式，不能互换。
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
   当前 `CandidateFontSnapshot.swift:15` / `CandidateFontSettings.swift:28` 定义默认15/17，`+CandidateDataSource.swift:198` 共用快照，`KeyboardDesignTokens.swift:6` 为 46。
   同一文件 `Keyboard/Views/CandidateBar/CandidateButtonFactory.swift:89` 的注释写高亮 contentInsets 为 6，
   实际 `Keyboard/Views/CandidateBar/CandidateButtonFactory.swift:110` 为左右各 8；仅记录，不改源码。
   全仓 Swift 引用检索只有 factory 定义与测试注释，未发现生产调用；“完全死代码”不作运行时结论。
7. 盘点材料把 Path chip 记为 17；紧凑 Path `Keyboard/Views/T9PinyinPathBarView.swift:548` 实为 16，
   17 对应旧展开 Path `+T9PinyinPath.swift:458`。这属于参数归属差异，不修代码。
8. 独立重复常量：44 分别出现在 `ChromeTouchHitGeometry.swift:9`、`+CandidateDataSource.swift:7`、
   `KeyboardDesignTokens.swift:10` 与 `T9PinyinPathBarView.swift:612`；34 同时用于
   `KeyboardDesignTokens.swift:29` 的高度与 `KeyboardViewController.swift:374` 的遮罩圆角，语义不同。
   4pt 视觉 gap 在 `CandidateCell.swift:9` 与 `+CandidateDataSource.swift:6` 重复；15/17、28、13/18 的
   渲染 / 测量现已共用 `CandidateFontSnapshot`；外层4pt gap仍是独立几何定义。相同数字不代表应自动联动。
9. `docs/KEYBOARD_LAYOUT.md:81` 已写新周期 0 / Sticky34，但 `:82` 仍称空闲保留、无高度跳变；
   与 `+T9PinyinPath.swift:49–52` 的初始 0 不完全一致。同文 `:100` 起的历史 UI-1 固定 34 叙述
   不能用作当前 UI-2 行为证据。
10. 盘点材料说设置刷新只在 viewDidLoad / viewDidAppear 调用，但未区分首次；
    `+Bootstrap.swift:195–199` 明确仅返回已有键盘才在 appear 刷新。首次复用快照，见
    `docs/PROJECT_CONTEXT.md:257`；不据此声称已验证实际宿主安装顺序。

路径简称在本节未带目录时，指上表同名基线源码；盘点材料本身是外部非权威输入，见本任务 Assignment。

## P3-R2 旋转完成后的高度请求优先级

750 为常态请求；旋转完成后宿主仍未采用请求（尤其仍小于请求）时，只有未取消、窗口存在、
生命周期 visible、已有约束且实际高度不等于 uncompressed 请求值，才条件性提升到999。
一个 transition 最多一次，不定时重试；持有至下一次旋转开始（super之前）、消失（super之后）、
约束对象重建/替换、窗口移除或宿主 resign 的 suspend 路径，再恢复750并失效旧完成回调。
`KeyboardHeightRotationPriority` 是唯一提升/还原所有者，适用于 Debug 与 Release，不带临时日志。
行约束仍为750；模型默认45/254/288、方向封顶、40下限与保存不写回不变。
即使提升后宿主仍给低预算，仍按稳定后的实授压低行高或在不足四行40时隐藏；增高过渡的旧 bounds 判定见[高度预算与保存意图](#build167-s3-高度预算与保存意图)。
999 低于 required1000，但会改变与宿主约束竞争，不能据此保证真实低预算、分屏或所有设备无冲突。
750 请求不等于系统实授，999 也不构成实授保证；内部根因仍 UNKNOWN。

外置依据（只引用原观察，不改写为本次正式代码验收）：

- `~/.kos-work/Universe-Keyboard/UI4-HEIGHT-001/reports/executor-report-orientation-round3.md`：
  SHA-256 `ae7849c0cb2651e572df10d71196740b84b7fcddd97db51a41eb5c47dc401eb3`；
  模拟器单次 C4 有效，A 段可见 Encapsulated 高度1000，不证明系统协商根因。
- `~/.kos-work/Universe-Keyboard/UI4-HEIGHT-001/reports/c4-device-trial-human-result.md`：
  SHA-256 `3c9d8c35686bfd99c0faec85bdaad9894a9832ed3bd4a9f4def735c2b2b2dd73`；
  Human 九项 Pass 属于 DEBUG 临时 C4，iOS版本待补；正式实现仍需 Human 重验。
- C4 实验小补丁 SHA-256 `8a18ac4cddea1d54071d7d28cb49961264447f253f4251a306adaf6abbd6e1c6`，
  总补丁 SHA-256 `652136bea164cc820b586bc10e2233b6ea57395003dee920c230e2d1795ed306`；
  正式代码新增约束身份与退出保护，不直接带入 DEBUG 实验代码。

## Round 1 已接受限制与有界记录（P3-R3）

本节记录 Human 明确处置，产品决定文字未改，对其 §7“同一标记不再重新进入”按本句作有界解释；标记去重只保证最近 64 次成功消费内同一标记不重入，更早的标记可能被再次消费；
主 App 每次进入页面或明确重开都会生成新标记，常规流程不受影响；Human 已接受该边界（确认记录
`reports/human-confirmation-r2-f01-closeout.md`，SHA-256 `ec382ccba6f9b53102e4150f662b4a0f546d63530a0c21609970d76133973002`）。
与外置 `reports/pm-acceptance-matrix-v3.md`（SHA-256 `f54efe17f5c6a5f4fb5c8681584cfec92658c5f36e79994b9cea05a7ba2244c5`）的
Human 观察 / 夹具 / UNKNOWN 层级一致。上面本次修订的 Return、九键host、路径面板与数字/符号表行，
已按本分支 P3-R3 最终源码符号和行号核对；其它历史盘点项不作无界刷新。

- R-01（Human accept）：宿主预算不足四行40pt时整面隐藏，不是缩到任意可用高度；
  模型/夹具证明该分支，真实宿主全覆盖未验证。出现真实设备/宿主触发隐藏时复审。
- R-04（Human accept）：999参与求解后，accepted只观察求解后的bounds；它不保证识别被更高优先级覆盖的软预算意图。
  真实低预算、iPad分屏、浮动键盘未独立验证；有裁切/高度异常反馈或取得这些环境设备时复审。
- R-06（Human accept UNKNOWN）：本次真机iOS版本、安装时间、所装完整提交/配置及未提供的最大高度测量仍UNKNOWN；
  Human单机总体通过不是独立测量，Release真机二进制配置未独立核验。
- 竖屏最大值占屏比例：Human目测“约三分之二”不是测量，是否含系统底栏未知，50%实际符合性仍UNKNOWN（已接受待测）。
- 端点震动：完全访问开时端点震动为已接受剩余，来源UNKNOWN；不因此声称无触觉。
- `KeyboardHeightAdjustmentTokenStore.consume` 在私有存储中按FIFO仅保留最近64个已消费UUID；
  界内重复仍拒绝，淘汰后的旧UUID不再承诺去重，活动会话和宿主内容不持久化，协议格式/存储键不变。
- 宿主 resign 可能没有 willDisappear；`suspendKeyboardRuntime` 也通过原单一租约owner还原750并失效迟到完成。
  这是清理边界补齐，不把挂起/恢复夹具当成所有真实宿主的测量证明。

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
也不授予改变 Product Contract 的权限。高度可调由 UI4-HEIGHT-001 单独授权；字号可调由 UI3-FONT-001 授权；本文仅镜像已实现模型与设置，不扩大产品合同或验收范围。

## BUILD167 S3 高度预算与保存意图

高度请求、方向几何或新一轮出现变化时清除旧 accepted。可见窗口布局启动有界的
`CADisplayLink` 观察；布局回调次数（包括本代码引起的回调）不构成稳定证据，也不再调度额外布局取样。
实际 bounds 已满足请求时可立即采用；不足时至少经过 4/60 秒（约66.7ms），
且至少两次真实帧采样、读数在采样间保持相同至少 1/60 秒（约16.7ms），才把它视为显示预算。
这以 S2 约32–50ms宿主增高读数加一帧余量为依据；不是平台保证，详见
[ADR 0037（Proposed）](architecture/decisions/0037-keyboard-height-host-budget-trust.md)。

请求待结算期间保持方向封顶后的意图行高、可见性与高度请求，不因过渡旧预算夹低或隐藏。
稳定预算不足四行40时仍隐藏，满足请求后恢复；结算后的新低读数也须重新经过同一判据。
单次观察在帧时间达到 8/60 秒（约133.3ms）仍不能证明稳定、或收到32次帧采样时停止；
到时保持意图，不把最后一个振荡值变成 accepted；R3只在耗尽后等待至少66.7ms，再允许一次同判据观察，
即使稳定值与耗尽读数相同也可确认。等待最多133.3ms/32回调；恢复窗口最多133.3ms/32采样，
两个预算窗口与一次等待合计最多96回调、帧时间预算400ms；持续振荡时不会因重复布局继续取得窗口。
恢复仍失败或等待超限则保持意图至新请求/几何/出现等新代际；正常未耗尽路径不变。
显示帧暂停时无轮询；时间上界在下次帧回调检查，不承诺墙钟准时回调。
窗口移除、宿主挂起或请求代际变化会取消观察，旧回调不能结算新代际。
采样启动依赖可见布局回调，若请求后无布局则不会启动，阶段 B 真机必查 Path 出现是否产生布局。
结算后不同低读数会先撤销旧钳制，在约66.7ms的重新观察期间保持意图，可能暂时闪现意图高度。

调节滑块上限仍只使用横屏45 / 竖屏50%产品封顶；确定保存界内用户意图整数（重置删除），
不保存宿主压缩后的有效行高。真实低预算、振荡期间暂时超出容器的显示与真机漏按/错行仍须后续真机复测。
