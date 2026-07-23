# 九宫格完整 Path、候选与输入框原子同步实施计划

## 计划状态

- **计划编号：** `KEYBOARD-LAYOUT-9KEY-PINYIN-004`
- **执行者：** Grok 4.5
- **范围：** 仅九宫格 T9 拼音链路；26 键行为冻结。
- **测试约束：** 只运行相关单元、Bridge、UI Contract 测试，不运行全量测试。
- **发布约束：** 不提交、不推送、不创建 PR，除非用户另行授权。
- **工作树约束：** 当前分支存在 003 的未提交改动；禁止 reset、checkout 覆盖或清理这些改动。

## 一、目标与不可破坏的产品契约

建立一个由 KeyboardCore 统一发布的 T9 Composition Snapshot，使以下内容始终属于同一 revision：

1. RIME 当前 raw input。
2. 用户可见的 marked text。
3. 当前完整 Path 集合。
4. 当前选中或暂定 Path。
5. 当前候选词及其对应 raw identity。

具体行为：

- 每次九宫格按键仍只向 RIME 发送一次数字键，不枚举字母组合调用 RIME。
- Path 由本地固定拼音音节索引计算，不再依赖有限候选窗口是否恰好带有 comment。
- 一次按键最多增加一个可见字母槽位；按一次 `TUV` 只能先看到 `t`，不能看到 `ta`。
- 输入 `2、8` 后 Path 至少包含 `bu / cu / a / b / c`：
  - `bu/cu/a` 是完整音节；
  - `b/c` 是可选择的拼写前缀；
  - 点击 `b/c` 只锁定前缀、保留后续数字槽位并刷新 Path/候选，不确认音节。
- 完整音节选择会确认当前音节并推进到下一音节；前缀选择不会推进。
- 未选择时，输入框使用 Path 第一项作为“暂定投影”，但不能把它记为用户选择。
- 用户点击具体 Path 后，只替换它对应的输入槽位，未涉及的后缀保持不变。
- 候选词继续由 RIME 生成和排序；“候选匹配 Path”定义为候选来自同一 raw 约束和同一 revision，而不是要求每个 Path 都占据首屏候选位。
- 只要仍有有效 T9 composition，Path Bar 不得因为 RIME comment 为空、候选稀疏、Delete 或 Partial Commit 而消失。
- 任何内部数字或带数字的混合 raw 都不得传入宿主 marked text。
- 26 键继续按字母直传 RIME，不加载 T9 音节索引、不生成 Path、不改变候选和 marked-text 行为。

## 二、KOS 2.0 治理与角色

实施前先创建并互相引用：

- `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-004`
- `ADR 0023: T9 Complete Local Path Catalog And Atomic Presentation`
- `Assignment KEYBOARD-LAYOUT-9KEY-PINYIN-004`

角色固定为：

- **Product Lead / Product Approver：** Human Product Owner
- **Domain Owner：** Input Intelligence Maintainer
- **Executor：** Grok 4.5
- **Environment Executor：** Grok 4.5，仅执行定向本地和 Simulator 验证
- **Architecture Reviewer：** 独立 Architecture & Knowledge Steward
- **Quality Reviewer：** 不参与实现的独立 Quality Reviewer
- **Human Dependency：** 用户在 iPhone 13 Pro + 备忘录执行最终 Product Gate
- **Supporting Domains：** RIME Platform Maintainer、Keyboard Experience Maintainer

治理处理：

- 保留 003 的失败证据，不改写历史。
- 004 接受后，将 003 标记为“Human Product Gate 失败后由 004 取代”，而不是伪装为通过。
- ADR 0023 明确取代 ADR 0021/0022 中“多位数字只能依赖 RIME comment、禁止静态完整音节源”的限制。
- 如果音节资源来源、许可证或生成过程无法明确记录，停止交回 Product Lead，不得静默引入来源不明的音节表。

## 三、核心架构

### 1. 固定音节索引

从仓库已经包含的 `Keyboard/Resources/luna_pinyin.dict.yaml` 生成版本化索引：

- 生成器提取拼音编码列中的小写 ASCII 音节 token。
- 去重、排序并转换为 T9 数字签名。
- 生成编译期 Swift 数据，不在 Extension 热路径读取或解析 YAML/JSON。
- 生成结果记录：
  - 源文件；
  - `luna_pinyin` 版本；
  - 源文件 SHA-256；
  - 音节数量；
  - 生成器版本。
- 当前基线约为 418 个唯一音节；生成测试必须检测源文件变化，不能静默改变目录。
- 运行时索引形式为 `[数字签名: 有序音节数组]`。
- 单个焦点最多查询 1～6 位数字前缀，不构造整句笛卡尔积。

Path 排序规则固定为：

1. 消耗输入槽位更多的完整音节优先；
2. 相同长度下，当前 RIME comment 中出现的音节按首次出现顺序优先；
3. 未出现在 comment 中的合法音节按生成目录稳定顺序补齐；
4. 完整音节之后加入当前按键组中的前缀字母；
5. 同名完整音节与前缀去重，完整音节优先。

因此 `28` 的稳定结果为 `bu / cu / a / b / c`；`94` 即使 RIME 首屏只暴露 `yi`，也必须保留兼容的 `xi/yi/zi`。

### 2. Path 类型

为 Core 增加明确的选择类型：

```swift
enum T9PinyinPathKind {
    case completeSyllable
    case letterPrefix
}
```

每个 `T9PinyinPath` 增加：

- 稳定 ID；
- `kind`；
- `consumedSlotCount`；
- `displayText`；
- 完整 `replacementRawInput`；
- 所属 composition revision 和焦点槽位范围。

UIKit 不得自行拼接 replacement raw，也不得把 accessibility 字段当业务载荷。

### 3. Composition Snapshot

在 KeyboardCore 中建立单一的 `T9CompositionPresentationSnapshot`，至少包含：

- `revision`
- `sourceDigits`
- `rimeRawInput`
- `focusSlotRange`
- 已确认音节
- 当前锁定前缀
- `provisionalPathID`
- `selectedPathID`
- 完整 Path 数组
- 当前候选数组及 candidate raw identity
- 经过安全校验的 `visiblePreedit`
- Partial Commit/Delete checkpoint

所有按键、Path 选择、候选选择、Delete、恢复和回滚都必须先在 Core 内形成完整新快照，再一次性发布。UIKit 只读取一次快照；发现 revision 不一致时丢弃旧候选、旧 Path 点击和旧分页结果。

### 4. 输入与候选数据流

普通九宫格按键：

1. 更新 source digit slots。
2. 向 RIME 执行一次 `processKey(digit)`。
3. 从音节索引计算当前焦点的完整 Path。
4. 使用当前 RIME comment 只做 Path 排序提示，不做合法性授权。
5. 从同一 RIME output 安装候选。
6. 生成安全 visible preedit。
7. 一次性推进 revision 并发布。

完整音节选择：

1. 校验 Path ID 和 revision。
2. 用所选音节替换对应槽位，保留前后 source slots。
3. 使用 apostrophe 保存确认边界，例如 `qiu'53`。
4. 对 RIME 执行一次 `replaceInput`。
5. 只接受 exact raw、未意外提交且 session 可用的结果。
6. 确认音节并推进焦点，重算下一音节 Path、候选和 visible preedit。
7. 失败时完整恢复旧快照和旧 RIME raw。

前缀选择：

1. 例如 `28` 点击 `b`，生成约束 raw `b8`。
2. 执行一次 `replaceInput("b8")`。
3. 保留当前焦点，不确认音节。
4. Path 过滤为与 `b` 兼容的完整音节，并保留已选择的 `b` 前缀项。
5. 输入框显示显式前缀加第一兼容路径的暂定后缀，例如 `bu`。
6. 候选必须来自 `b8` 对应的新 RIME output。

候选选择和 Partial Commit：

- 中文候选仍由 RIME 选择。
- 部分候选提交后，source digit suffix、确认边界、焦点和 Path 必须在同一次 revision 更新。
- `qingweifandaowozuili → qing → wei → fan → dao → 请喂饭到` 后，Path 必须立即切换到剩余 `wo...` 的当前焦点。
- `toutoumaiqiule → 偷偷买 → qiu` 后，visible preedit 必须保留后缀，形成 `偷偷买qiule`，不能截断为 `偷偷买qiu`。

Delete：

1. 若存在刚完成的部分候选 checkpoint，第一次 Delete 原子恢复候选选择前状态。
2. 再次 Delete 删除最后一个输入槽位。
3. 固定验收结果：恢复 `qiule` 后再次 Delete 得到 `qiul`。
4. 使用更新后的槽位状态执行一次 exact raw replacement，并重算 Path/候选。
5. 只要 composition 仍有效，至少发布当前按键组前缀 fallback，禁止 Path Bar 消失。
6. 删除或恢复失败时保持旧快照或安全清空 composition，绝不发布含数字 preedit。

### 5. 输入框安全边界

所有 `setMarkedText` 必须经过唯一的 T9 host-visible resolver：

- 只允许中文、合法 ASCII 字母和允许的可见分隔形式。
- 任意 ASCII 数字出现即拒绝发布。
- 不允许直接回退显示 `rawInput`。
- 未选择时使用 provisional Path，但每个 source slot 最多产生一个可见字母。
- 显式 Path 只覆盖其槽位范围，已有安全后缀不得因新的候选排名而被截断或重写。
- 非 T9、显式数字键盘和 26 键不经过这条 T9 过滤链。

## 四、Path Bar UI

将当前固定 `UIStackView + prefix(5)` 替换为固定 34pt 高度的单行横向 `UICollectionView`：

- 展示 Core 发布的全部当前焦点 Path，不再截断为 5 项。
- 使用 cell reuse 和稳定 Path ID，避免每次按键销毁重建全部按钮。
- 新 composition 默认滚到首项。
- 前缀/完整 Path 选择后将选中项滚入可见区域。
- 同 revision 的候选分页不得重置 Path Bar 滚动位置。
- revision 改变时取消旧点击、旧动画和旧数据源更新。
- 保持现有字体、选中反色样式、分隔线和固定键盘高度。
- 每项保留至少 44pt 可点击宽度，并提供 VoiceOver 的“拼音、完整音节/拼写前缀、已选中”状态。
- 移除 Path 完整性对 expanded candidate window 和 `compactLimit` 的依赖；旧 Path 展开面板若无其他调用者，应在 004 范围内删除或明确退役。

## 五、性能边界

自动化断言：

- 普通数字按键：Path 逻辑额外 RIME 调用数为 0。
- Path/前缀点击：最多一次 `replaceInput`，Path 逻辑不得调用 `candidateWindow` 或逐拼写 probe。
- Path 计算：最多查询 6 个数字签名前缀。
- 不扫描整句组合，不生成多音节笛卡尔积。
- 候选分页只能由候选栏滚动触发，不能反过来决定 Path 是否完整。
- 音节索引在编译期生成，Extension 热路径无文件 I/O、JSON/YAML 解码或持久化写入。

物理设备只记录真实时延和主观卡顿，不人为发明新的毫秒阈值；若仍出现明显卡顿，再依据 signpost/ETTrace 单独立项。

## 六、定向测试

### KeyboardCore

至少覆盖：

- 单键 `2 → a/b/c`，visible preedit 只有一个字母。
- `28 → bu/cu/a/b/c`，候选来自 raw `28`。
- 点击 `b → raw b8`，不推进焦点，Path/候选/输入框同步。
- `94` 在 RIME comment 只有 `yi` 时仍提供 `xi/yi/zi`。
- `deizhaoyishengwenyixia` 到 `yi` 焦点时仍可选 `zi`。
- 每次 digit 仅一次 `processKey`；每次 Path 点击仅一次 `replaceInput`。
- Path 点击只替换对应槽位并保留后缀。
- `qingweifandaowozuili` 的连续 Path 选择和部分候选提交。
- `toutoumaiqiule → 偷偷买 → qiu → 球 → Delete → Delete`：
  - 第一次恢复 `qiule`；
  - 第二次得到 `qiul`；
  - Path 不消失；
  - marked-text history 从未出现数字。
- stale revision 点击被拒绝。
- replaceInput、Delete、恢复失败时完整回滚。
- `usesT9InputSemantics == false` 时行为、RIME 调用序列和 marked text 与当前 26 键基线完全一致。

### RimeBridge 定向 Spike

在 pinned t9 runtime 验证：

- `28`
- `b8`
- `cu`
- `94 → zi`
- `qiu'53`
- `qiul` 对应恢复 raw

每项记录 exact raw、候选是否非空、是否产生意外 committed text。Bridge 不负责生成完整 Path，只证明 Core 生成的精确 raw 可以被当前 T9 session 接受。

### UIKit / KeyboardTests

- 超过 5 项时可以横向滚动并访问末尾 Path。
- cell reuse、稳定 ID、选中样式和 VoiceOver 正确。
- 同 revision 才能同时展示候选、Path 和 marked text。
- 候选分页不重置 Path，也不授权旧 Path。
- 26 键不创建 Path Bar 数据源，不改变候选栏布局。

建议只运行：

- `T9PinyinCatalogTests`
- `T9PinyinPathTests`
- `T9HostPreeditSafetyTests`
- 相关 `PartialCommitControllerTests`
- 新增的 26 键隔离回归测试
- RimeBridge T9 selection Spike
- Path Bar UIKit contract tests

## 七、人工 Product Gate

由用户在 iPhone 13 Pro 的备忘录执行：

1. 单击任意九宫格键，只增加一个可见字母。
2. 输入 `28`，确认 Path 为 `bu/cu/a/b/c`，候选包含兼容的 `不/部/步/补/布/粗/醋/促` 等。
3. 点击 `b`，确认 Path、候选和输入框同时收窄。
4. 输入 `deizhaoyishengwenyixia`，确认长输入无明显卡顿，`yi` 焦点仍可横滑选择 `zi`。
5. 输入 `qingweifandaowozuili`，依次选 `qing/wei/fan/dao` 并选择“请喂饭到”，确认 Path 立即进入剩余部分。
6. 执行完整 `toutoumaiqiule`、`偷偷买`、`qiu`、`球`、两次 Delete 流程。
7. 全程确认输入框不出现内部数字。
8. 切换到 26 键，验证普通拼音输入、候选选择、删除、空格和回车没有变化。

只有独立 Architecture Review、独立 Quality Review 和上述真人设备验证都通过后，004 才能关闭；自动化测试不得替代 Human Product Gate。

## 八、Grok 4.5 交付要求

Grok 完成后必须留下：

- 新 PD、ADR、Assignment 和实施证据文档；
- 修改文件 allowlist；
- 音节目录来源、版本、hash、生成命令和许可证结论；
- 所有定向测试的命令与结果；
- RIME 调用次数证据；
- 26 键隔离证据；
- 未运行的测试及原因；
- iPhone 13 Pro 人工测试步骤和待填写结果；
- 是否需要更新 `CHANGELOG.md`、`KEYBOARD_LAYOUT.md`、输入管线文档和架构时间线；
- 不得声称已通过尚未执行的人类 Product Gate。
