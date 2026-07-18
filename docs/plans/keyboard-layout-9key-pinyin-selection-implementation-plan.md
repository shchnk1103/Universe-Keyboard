# 九宫格“精准选拼音”逐步实现计划

Lifecycle status: Archived

Closed by: Assignment [`keyboard-layout-9key-pinyin-001.md`](../assignments/keyboard-layout-9key-pinyin-001.md) (`Accepted / Closed` after PR #20 merge to `main` as `fe9010f`, `2026-07-19 Asia/Shanghai`).

## 总结

目标是在中文九键模式中增加一条位于中文候选栏上方的“拼音路径栏”：

```text
[m] [n] [o]                    ← 精准拼音路径栏
[吗] [你] [哦] [年] ... [展开]  ← 现有中文候选栏
[九宫格按键区域]
```

采用已确认的产品语义：

- 精准栏展示当前完整九键序列对应的有效拼音路径，而不只是最后一个按键的字母。
- 默认展示 Rime 排序靠前的最多 4 个去重路径。
- “选拼音”展开完整路径面板，按需加载更多路径。
- 点选路径只收窄当前 Rime composition，绝不直接向宿主上屏字母。
- 九键仍由现有 `t9` schema、session 和候选排序负责，不建立第二套中文候选引擎。

## 分阶段实施

### 1. 先补产品与架构授权

- 建立 `KEYBOARD-LAYOUT-9KEY-PINYIN-001` Product Decision 与完整 Assignment；在无 `UNKNOWN` 且进入 `Ready` 前不开始实现。
- 新增独立 ADR，记录精准拼音选择是对 ADR 0018 的扩展：
  - Rime raw input 允许纯数字、纯字母和字母/数字/分隔符混合形态。
  - 精准选择属于 composition refinement，不属于候选提交。
  - Extension 只操作当前 session，不部署或修改 schema。
  - 路径来源是当前 Rime 候选的拼音 comment，避免维护可能与 Rime 配置漂移的平行拼音表。
- 明确非目标：不升级 librime、不改主 App 设置、不改 26 键、不实现多击选字母或滑动选字母。

### 2. 真实 librime Spike，未通过则停止 UI 开发

在隔离的 T9 runtime 中扩展现有 Spike，验证：

- 输入 `6` 后，候选 comment 去重可以得到 `m / n / o`；若 Rime 实际输出不同，记录全部 comment 并停止确认产品策略。
- `replaceInput("m")`：
  - raw input 变为 `m`；
  - composition 和中文候选非空；
  - 不产生 `committedText`。
- `64 → 选择 ni → replaceInput("ni")` 后候选确实收窄；继续按键可形成 `ni4` 等混合 raw input。
- 混合输入下 Backspace、Space、Return、语言切换、session recovery、候选分页行为正确。
- 无候选时 Space/Return 仍不得把 `ni4`、`64` 等内部 raw input 直接提交给宿主。
- 记录 pinned librime、schema、输入输出、候选 comment、删除结果和性能日志。

停止条件：

- `set_input/replaceInput` 不接受混合输入；
- candidate comment 不能稳定表达完整拼音路径；
- 必须修改 schema 或升级 vendor 才能工作。

触发停止条件后回到架构评审，不用 UI 层模拟结果。

### 3. 扩展 KeyboardCore 状态与动作

新增公开的纯逻辑模型：

- `T9PinyinPath`
  - `displayText`：界面显示，如 `ni hao`；
  - `replacementRawInput`：传给 Rime，如 `ni'hao`。
- `T9PinyinPathState`
  - 当前 compact paths；
  - 当前选中的精确路径；
  - 当前 raw-input generation，用于丢弃过期分页结果。
- `T9PinyinPathWindow`
  - 去重路径；
  - 下一 Rime 全局候选索引；
  - 是否仍有候选可扫描。

新增接口：

- `KeyboardAction.selectT9PinyinPath(T9PinyinPath)`。
- `KeyboardEffect.t9PinyinPathsChanged`。
- `KeyboardController.t9PinyinPathWindow(from:limit:)`，封装候选窗口读取、comment 解析、校验和去重；UIKit 不自行解释 Rime comment。
- 不修改 `RimeEngine` 协议：复用现有 `replaceInput` 和 `candidateWindow`。

路径解析规则：

- 只接受由 ASCII 拼音字母、空格或 `'` 组成的 comment。
- 转为小写；连续空白归一化为单个拼音分隔符 `'`。
- 校验路径与当前数字/字母 raw input 兼容，拒绝装饰符号、Emoji、空 comment 和不匹配路径。
- 按对应中文候选首次出现的顺序排名，并按 `replacementRawInput` 去重。
- compact 栏取前 4 个；展开面板按 Rime 候选窗口惰性扫描，不一次性遍历完整候选集。

### 4. 修正混合 T9 输入的不变量

现有 T9 安全策略只识别“纯数字”，必须先扩展为“有效 T9 composition”：

- 将纯数字判断改为：`usesT9InputSemantics == true` 且 raw input 非空，并仅包含 T9 支持的字母、数字和拼音分隔符。
- 混合输入继续遵守：
  - Space/Return 有候选时提交高亮或首候选；
  - 无候选时保留 composition；
  - 语言/自动英文切换放弃 composition；
  - 永不直接提交 raw input。
- 混合 T9 输入继续屏蔽普通 26 键拼写纠错，避免 `ni4` 被误判为 typo。
- 精准路径选择采用事务式更新：
  - 先保存旧 `RimeOutput`；
  - 调用 `replaceInput`；
  - 只有返回有效 composition 时才更新状态和 marked text；
  - 失败时保留旧 composition、中文候选和宿主 marked text。
- Delete、可见性放弃、页面切换、最终候选提交和 session recovery 都同步清空或重建精准路径状态。
- raw input 仍是恢复与删除的唯一来源；不能从展示用 preedit 或拼音栏文字反推 composition。

### 5. 增加固定高度的精准拼音栏

Keyboard Extension 实际使用 UIKit，因此在现有候选组件体系中新增 `T9PinyinPathBarView`：

- 仅用于“中文 + letters 页 + 有效九键 runtime”。
- 九键页面始终预留 34pt 高度；无 composition 时内容为空，避免每次按键导致键盘高度跳变。
- 顺序固定为：精准栏 → 中文候选栏 → 九宫格键区。
- 九键首选高度在现有值上增加 34pt，按键高度和四行几何保持不变。
- 路径使用普通文字、透明背景、连续触控单元；不使用候选高亮 pill，视觉接近原生截图。
- 精准栏与中文候选栏之间允许一条 1px 语义分隔线；不增加卡片或装饰背景。
- 最多直接显示 4 个路径；布局从左向右，保证 `m / n / o` 拥有稳定且不小于 44pt 的触控区域。
- 无有效路径时保持空白；“选拼音”键禁用并提供准确的 VoiceOver 状态。

### 6. 实现“选拼音”完整路径面板

- 将现有候选展开布尔状态收敛成互斥展示模式：
  - `none`
  - `candidateExpansion`
  - `pinyinPathExpansion`
- 点击“选拼音”：
  - 有 composition 和路径时打开拼音面板；
  - 无 composition 时不打开。
- 面板复用候选展开容器的尺寸、背景、滚动和关闭手势，但使用独立数据源与 cell，不把拼音伪装成 `CandidateKind.candidate`。
- 初次按 Rime 全局候选索引读取一批候选并提取去重路径；接近底部时继续扫描。
- composition generation 改变后立即丢弃旧分页结果并关闭或刷新面板，避免旧路径替换新输入。
- 点选路径后：
  - 关闭面板；
  - 发送 `.selectT9PinyinPath`；
  - 更新 marked preedit、精准栏和中文候选栏；
  - 只发一次 commit 型触觉/点击反馈，不上屏文字。
- 中文候选展开面板与拼音面板不能同时存在。

## 测试与验收

### 自动化测试

- KeyboardCore：
  - comment 规范化、兼容性校验、排序、去重和非法输入过滤。
  - `6 → m/n/o`、`64 → mi/ni` 等路径状态。
  - 精准选择成功、Rime 拒绝时回滚、过期 generation 丢弃。
  - 混合 T9 输入的 Delete、Space、Return、语言切换、恢复和 typo suppression。
  - 候选提交后所有精准状态清空。
- RimeBridge：
  - 真实 `t9` schema 的纯数字、纯字母、混合输入和 `replaceInput`。
  - comment 路径与中文候选一致。
  - 候选窗口分页不改变当前 composition 或高亮候选状态。
- Keyboard UI/contract：
  - 精准栏只出现在中文九键字母页。
  - 空闲与输入中键盘高度稳定。
  - compact Top 4、面板互斥、过期结果保护、按钮禁用状态和 VoiceOver 标签。

### 构建与真机验收

- 运行 KeyboardCore 全量测试、RimeBridgeTests、主工程 Debug/Release 严格并发构建。
- 真机至少覆盖：
  - `MNO → m/n/o` 可见且分别产生不同候选；
  - 连续多键后选择完整拼音路径，候选明显收窄；
  - 选择路径后继续输入、删除、再选择；
  - 无候选时 Return/Space 不泄漏 raw input；
  - 候选展开与拼音展开反复切换；
  - 宿主切换、Extension 重启和 Rime session recovery；
  - 浅色/深色、VoiceOver、Dynamic Type、左右边缘触控；
  - 快速输入、路径刷新和分页无可感知卡顿。
- 记录与原生输入法的并排截图和操作录像；最终验收以真机可观察行为为准。

## 文档与默认约定

- 更新 `KEYBOARD_LAYOUT.md`、输入管线文档和 UI Style Guide，记录新增行高、精准选择语义及混合 raw-input 不变量。
- 更新 Release Checklist，加入精准栏、混合输入、生命周期和性能验收项。
- 实现完成后更新 `CHANGELOG.md`；计划归档后不继续充当当前行为来源。
- 第一版不增加用户开关：中文九键可用时默认启用。
- Rime comment 缺失或解析失败时安全降级为普通九键候选；不猜测拼音、不提交 raw input、不影响基本输入。
- 不改变 T9 安装、readiness、主 App 部署和 vendor 版本边界。
