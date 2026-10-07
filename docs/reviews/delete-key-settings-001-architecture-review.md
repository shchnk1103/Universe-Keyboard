# DELETE-KEY-SETTINGS-001 独立 Architecture 审查

## 结论

Conditional Accept

本结论不是 Quality，不是 Product Gate，也不授权 commit、push、merge。

## Digest 与文件哈希

一致。

冻结包 `docs/evidence/delete-key-settings-001-architecture-packet.md` 的 Packet digest hex 换成 64 个 ASCII `0` 后，对其 UTF-8 做 SHA-256，得到 `517c13ebb83545f62d8ddc976c61ea70f4feeaa0ec03c44a35381f85857d3068`，与包内记录及期望 digest 相同。包内 15 个路径的 SHA-256 均与表中记录一致。因此继续审查行为，而不是在摘要不一致时 Reject。

对照基线 `141bc8ebcee456cfac8f8c826da9d6ce4e9e5b4f` 的未提交差异。`docs/product-decisions/DELETE-KEY-SCRUB-001-product-contract.md` 与 `Keyboard/Controllers/DeleteRepeatController.swift` 不在该差异中。`Keyboard/Controllers/KeyboardViewController+KeyFactory.swift` 也不在该差异中；其当前字节与冻结包哈希一致。

## 八项覆盖

### 1. 放置、三个开关、无长按开关

符合。

`Universe Keyboard/Views/Settings/SettingsTab.swift` 的「输入体验」中，顺序是键盘布局、键盘反馈、删除键。删除键是独立导航页，不在 App 设置、键盘布局或键盘反馈页内。`DeleteKeySettingsView` 只有三个开关，文案与合同表一致：

- 长按垃圾桶：开「按住后出现垃圾桶。移进去松手，清空光标前能看见的文字。」；关「按住后不出现垃圾桶。」
- 滑动擦除：开「按住后向左按距离删除，向右滑回刚删的字。」；关「手指离开删除键就停止这一次删除。」
- 组字时左滑：开「正在组字时向左滑，放弃还没上屏的拼音。」；关「正在组字时向左滑，不再放弃剩余拼音。」

`@AppStorage` 三个布尔默认值都是 `true`。页面没有第四个开关，也没有 0.5 秒、重复间隔或长按节奏说明。合同表里的「按住」描述保留，不算另加的长按说明。

### 2. 缺省为开，按下读一次

符合。

`DeleteKeyHoldFlags.isEnabled` 先看 `object(forKey:)`。键不存在则返回 `true`，没有用单独的 `bool(forKey:)` 把缺省当成关。`load(from: nil)` 返回 `allEnabled`。键盘侧 `sharedDefaults` 与主 App `universeAppGroupID` 都是 `group.com.DoubleShy0N.Universe-Keyboard`。

`deleteKeyTouchDown` 只调用一次 `DeleteKeyHoldFlags.load`，结果写入会话的 `let holdFlags`。之后的移动、重复、气泡和松手都读这份值，不在按住期间重读 UserDefaults。

### 3. 滑动关：键面上可点按和长按，离开后不恢复

符合。重复与点按节奏没有改。

滑动关时，`handleScrubDisabledFingerMove` 在 `keyFrame.contains(location)` 时直接返回，不因键面上的水平移动进入擦除，也不停止长按。长按仍由未改动的 `DeleteRepeatController` 启动：`initialDelay` 0.5、`repeatInterval` 0.08、`bubbleDelayAfterRepeatStart` 0.15。松手时只有 `phase == .pressed` 才补一次 `performDeleteBackward`。离开键面后阶段变为 `leftKeyPending`，松手不补点按删除。滑回键面时该阶段不调用 `resumeRepeating`。

### 4. 滑动关、垃圾桶开、气泡已出现时的缝

部分符合。过缝进入气泡、停在缝里松手、移到别处，这三支符合；滑回键面不是终态，见残留 `R-DELETE-KEY-SETTINGS-001-ARCH-1`。

`DeleteKeyHoldPolicy.outsideKeyIntent` 在垃圾桶关或 `bubbleVisible == false` 时，对缝、气泡和别处都返回 `stopWithoutResume`。气泡还没出现就离开键面，会停重复、藏气泡，且不会为尚未出现的气泡保留清空。

气泡已出现时，`deleteOffKeyZone` 把气泡帧当 `inBubble`，把气泡底到键顶、横向覆盖键与气泡并集的矩形当 `crossingGap`，其余当 `elsewhere`。气泡布局使用现有 `DeleteTrashBubbleView.gapAboveKey`（6）。缝内是 `seekBubble(inBubble: false)`：停重复，但气泡仍在，松手位置不在气泡内则不清空。走进气泡再松手时，`finishDeleteGesture` 允许 `leftKeyPending` 且 `fingerInBubble` 或位置落在气泡内，才走既有 `performDeleteAllBeforeCursor`。移到别处走 `stopWithoutResume`：藏起气泡，`bubbleVisible` 变 false，同一按住不能再清空。

滑回键面只把 `fingerInBubble` 清掉并返回，阶段仍是 `leftKeyPending`，气泡仍可见。同一按住再进入气泡会重新 `seekBubble(inBubble: true)`，松手仍会清空。合同要求滑回删除键就结束这一次：已删保留、不再重复、也不清空。不再重复这一点做到了，不再清空没有做成终态。

### 5. 滑动开保持 V1

符合。未发现把长按改成擦除，也未发现 `touchDragExit` 结束滑动开的按住。

`makeDeleteButton` 仍把 `.touchDragInside`、`.touchDragOutside`、`.touchDragExit` 交给 `deleteKeyTouchDrag`，不交给抬起或取消。滑动开不进入 `handleScrubDisabledFingerMove`。`.repeating` 只更新气泡悬停，不调用 `applyCommittedScrub`。组字时 `canShowDeleteTrashBubble` 仍要求没有活动预编辑，本切片没有放宽。默认「组字时左滑」开时，向左锁定仍先放弃剩余预编辑；向右水平锁定仍进入 `lockedWithoutDelete`，不擦已上屏。从气泡回到键面后恢复重复，仍要求 `phase == .repeating` 且 `scrubEnabled`。

### 6. 组字左滑的三种组合

符合。

向左超过现有 `DeleteScrubPlayhead.horizontalLockPoints`（10）且开关开、阶段仍是 `.pressed`、有活动预编辑时：停止重复计时器，调用既有 `dropRemainingPreeditKeepingConfirmedPrefix()`，阶段改为 `composingCleared`。该函数留下已确认的 Partial Commit 前缀，不用擦除账本去删已上屏文字。`composingCleared` 之后的移动不再擦除，重复 tick 也只在 `.repeating` 时删除。

组字左滑关且滑动开：不再走放弃分支。向左同样只是水平锁定，进入 `lockedWithoutDelete`，不放弃剩余拼音，也不擦已上屏。组字左滑关且滑动关：放弃分支不运行；向左离开键面按第 3 项停止这一次。键面上的水平移动本身不停止长按。

### 7. 冻结边界

符合。停止条件没有触发。

未改 0.5 / 0.08 / 0.15。设置页文案没有 256 字素上限，也没有「读不到光标前文字」。`DELETE-KEY-SCRUB-001` 合同文件相对基线无差异。本切片的删除动作文件没有 `selectAll`。相对基线的差异没有新增 `insertText`、`adjustTextPosition`、宿主文本日志或上传。清空仍走既有逐字素 `performDeleteBackward`；擦除回放仍走既有 `insertDirectText`。`performDeleteAllBeforeCursor` 使用既有 `DeleteScrubPlayhead.clearAllCap`（256），没有把该上限写进设置文案。取消或离开这一次没有额外播放删除音；进入气泡时的既有确认反馈还在。

### 8. 搜索与各页同一删除键手势

符合。

`SettingsSearchCatalog` 有目的地 `.deleteKey`，标题「删除键」，关键词含删除、垃圾桶、滑动、擦除、回删、组字、拼音、delete。`SearchTab.destinationView` 打开 `DeleteKeySettingsView`。26 键与英文字母走 `makeLetterThirdRow`，九键走 `makeT9NineKeyChrome`，中文与英文的数字页、符号页走各自的第三行。这些路径都调用同一个 `makeDeleteButton()`。表情页底行也复用该按钮，不另做一套手势。

## 残留

| ID | 问题 | Owner | Disposition |
|---|---|---|---|
| `R-DELETE-KEY-SETTINGS-001-ARCH-1` | 滑动关、垃圾桶开且气泡已出现时，滑回删除键只清除 `fingerInBubble`，阶段仍为 `leftKeyPending`，气泡仍可见。同一按住再进入气泡会重新武装，松手仍调用 `performDeleteAllBeforeCursor`。合同要求滑回键面即结束这一次，不得再清空，也不得恢复重复。缝仍应保持为过道：尚未滑回键面、尚未移到别处时，穿过缝进入气泡再松手仍可清空。移到别处已经会藏起气泡，这条不用放宽。 | DELETE-KEY-SETTINGS-001 Executor | `fix` |

## 用法

- 一次 pass。没有开第二轮。
- 停止原因：digest 与 15 个文件哈希一致，八项已对照未提交实现审完。预算没有用尽，所以结论不是 Partial / incomplete。
- 大约工具调用次数：39。未跑 `xcodebuild`，未跑 `swift test`，未使用 bundled git `/review`。测试计数没有当作架构事实。
- 只写入本审查页。未改 Swift、测试、Assignment、AUTH、冻结包或主检出。
- 冻结包文件表以外的工作区脏文件（含若干 docs 与未跟踪 Vendor）不改变上述手势判定，本轮没有把它们扩进产品范围。

本结论不授权 Quality、Product Gate、commit、push 或 merge。
