# KEYBOARD-LAYOUT-9KEY-PINYIN-001 Codex 独立实现审查

- 审查日期：`2026-07-18 Asia/Shanghai`
- 审查角色：Architecture & Knowledge Steward；Quality, Performance & Release
- 审查分支：`feature/keyboard-layout-9key-pinyin-001`
- 审查基线 HEAD：`44d42130bd8e2012bce7b4c034c4bc51a149dec3`
- 审查对象：上述 HEAD 上的未提交工作区实现；本记录不把聊天或 Executor 自检结论当作事实来源
- Architecture 结论：**Fail / Changes Required**
- Quality 结论：**Fail / Changes Required**
- 发布准备度：**Not Ready**；当前不应授权 commit / push / PR
- Product Gate：**Open**；即使以下代码问题修复，仍需 Human Dependency 真机矩阵

## 1. 权威与审查方法

本次审查从仓库重新建立事实链，主要依据：

1. `AGENTS.md`、`docs/KNOWLEDGE_INDEX.md`、`docs/READING_MAPS.md`；
2. Assignment `docs/assignments/keyboard-layout-9key-pinyin-001.md` 与 Codex handoff；
3. Product Decision `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-001`；
4. ADR 0020、ADR 0018、输入管线、`KEYBOARD_LAYOUT.md`、`UI_STYLE_GUIDE.md`；
5. KeyboardCore、Keyboard Extension、RimeBridge Spike 测试及当前未提交 diff；
6. 独立测试、严格 Debug/Release Simulator 构建和 `git diff --check`。

Executor handoff 仅用于定位待核事实，不作为 Architecture 或 Quality 结论。

## 2. 总体结论

实现方向与 ADR 0020 的大框架一致：路径来自 Rime comment、选择走现有 `replaceInput`、没有第二候选引擎、没有扩张 Extension 部署边界、固定 34 pt 路径栏也已经接入。Spike 足以支持“当前 pinned librime 具备实现可行性”这一有限结论。

但当前实现没有完整兑现路径兼容、事务式 refinement、全路径懒加载、状态生命周期和 UIKit 薄呈现边界。自动化测试全部通过并不能覆盖这些缺口。以下 P1 在修复并复审前阻止 Architecture/Quality 通过和发布。

## 3. Blocking findings

### [P1] 混合 raw 的路径兼容校验忽略数字后缀约束

证据：

- `T9PinyinPathExtractor.isCompatible` 先把 raw 拆成互不关联的 letters/digits；混合分支在 digit-only 匹配失败后，只要路径与 raw 字母部分存在前缀关系就接受（`T9PinyinPath.swift:133-160`）。
- 例如 raw `ni4` 会接受 `nia`、`nim` 等仅以 `ni` 开头、但末字母并不属于数字 `4` 的路径。
- 现有测试只断言 `ni` 与 `ni4` 兼容，没有任何“固定字母前缀 + 数字槽位不匹配”负例（`T9PinyinPathTests.swift:18-29`）。

影响：

- composition-incompatible comment 可以进入 compact/full path UI，并被交给 Rime refinement；这违反 Product Decision §2 和 ADR 0020 §3 的 fail-closed validation。

Required change：

- 对规范化 raw 按原始位置逐槽校验：字母槽必须精确相等，数字槽必须包含对应路径字母，separator 采用明确规则；不要通过分别抽取 letters/digits 丢失顺序。
- 明确并测试 `ni4` 下允许的短 comment 语义，同时至少加入错位、错误数字组、separator 和长度边界负例。

### [P1] refinement 接受任意“发生变化”的 engine raw，事务回滚也未验证 session 已恢复

证据：

- 选择 `ni` 后，只要 engine 返回非空且不同于 previous raw，即使返回 `foo` 也会被 `refinedOk` 接受（`KeyboardController+T9PinyinPath.swift:88-94`）。
- 拒绝或意外 commit 分支调用 `engine.replaceInput(previousRaw)` 后忽略恢复结果，却无条件把 KeyboardCore 镜像和 host marked text 改回旧值（`:78-101`）。
- 单测的失败 fake 在 `replaceInputShouldFail` 时根本不改变 fake session；因此只证明 Core 镜像没变，未证明“session 已被错误改变且恢复也失败”的情形（`FakeRimeEngine.swift:174-185`、`T9PinyinPathTests.swift:136-144`）。

影响：

- UI/Core 可能把错误 refinement 当成功；恢复失败时，Core/marked text 与真实 Rime session 会分叉，随后 Delete、候选选择和恢复均可能基于不同 raw。

Required change：

- 成功条件必须验证 engine 返回的规范化 raw 与请求的 replacement 精确一致，并确认仍有可用 composition、没有 host commit。
- 回滚必须验证 engine 已恢复 previous raw；恢复失败时走明确的 reset/recover/replay 或 fail-closed 路径，不能只恢复本地镜像。
- 增加 wrong-nonempty-raw、unexpected-commit-after-session-mutation、rollback-success、rollback-failure 四类测试，并同时断言 Core、fake engine session 与 marked text。

### [P1] 完整路径面板的“按需加载更多”没有接入任何滚动入口

证据：

- `loadMorePinyinPathsIfNeeded()` 虽已定义（`KeyboardViewController+T9PinyinPath.swift:175-193`），全仓库没有调用方。
- collection view delegate 最终进入的 paging 逻辑只识别 `candidateScrollView` 与 `expandedPanelScrollView`，遇到 `pinyinPathCollectionView` 直接返回（`KeyboardViewController+CandidatePaging.swift:57-72`）。
- 因而面板永远停在首次 `t9PinyinPathWindow(from: 0, limit: 48)` 的结果。

影响：

- Product Decision §1.4 和 ADR 0020 §3 要求的 lazy global-index advancement 实际不可达；后续候选窗口中的有效路径用户无法选择。

Required change：

- 把路径 collection 的接近底部/滚动结束事件接到 generation-guarded path paging；处理空窗口但 index 前进、无 index 前进、去重后新增为零等终止条件。
- 加入 UI/contract 测试，证明第二个及后续 window 可加载、旧 generation 结果被丢弃、不会触发普通候选预取。

### [P1] composition 终止/放弃路径没有统一清空精准路径状态

证据：

- T9 Space commit 和 Return commit 清空 composition/Rime/typo，却未调用 `clearT9PinyinPathState`（`KeyboardController+TextEditing.swift:49-65`、`:141-148`）。
- language switch 与 auto-English abandon 同样未清路径状态（`KeyboardController+ModeAndShift.swift:43-51`、`:92-99`）。
- `handleTogglePage` 只切 page，不清空或重建路径；当前测试只覆盖普通候选 commit 的清理。
- ADR 0020 §6 明确要求 delete、abandon、page switch、final commit 和 session recovery 清空/重建。

影响：

- 最终提交后 compact bar 仍可显示旧路径；语言/页面切换后回到九键也可能重新暴露上一段 composition 的 path snapshot。按钮是否禁用不能消除陈旧呈现和状态所有权错误。

Required change：

- 建立单一 composition-finalize/abandon 清理入口，并在 Space、Return、language、auto-English、page、visibility、recovery、normal candidate commit 全部复用；同步返回 `.t9PinyinPathsChanged`。
- 为每条生命周期路径增加 state/effect/host-text 回归测试。

### [P1] UIKit 把 replacement business data 写入 accessibility metadata

证据：

- `T9PinyinPathBarView` 把 `replacementRawInput` 写入 `UIButton.accessibilityValue`（`T9PinyinPathBarView.swift:67-76`）。
- action handler 再读取该值，并在 Core state 找不到时自行构造一个 `T9PinyinPath`（`KeyboardViewController+T9PinyinPath.swift:46-52`）。
- `docs/playbooks/keyboard-ui.md:38-43` 明确禁止把 business state 放进 view/accessibility metadata；Product Decision §4.1 也要求 UIKit 只渲染并转发 Core action。

影响：

- VoiceOver 的 value 被内部路由数据污染；UIKit 还获得了伪造/重建领域对象的能力，越过 KeyboardCore 的 provenance 与 validation 边界。

Required change：

- 使用类型化 UI mapping、稳定 index/tag 或专用 button/closure 持有已经由 Core 提供的 path 引用；accessibilityValue 只表达真实的无障碍语义。
- UI 不得在 state lookup 失败时构造 fallback path；陈旧点击应 fail closed。

### [P1] 无有效路径时“选拼音”仍可用并打开空面板

证据：

- `updateSelectPinyinButtonAvailability()` 只检查 T9 composition 是否 active，不检查 `compactPaths` 或可用 path window（`KeyboardViewController+T9PinyinPath.swift:33-44`）。
- `t9SelectPinyin` 也只以 composition 为 guard（`:59-78`）。
- 实施计划明确要求“无有效路径时保持空白；选拼音键禁用并提供准确的 VoiceOver 状态”。

影响：

- Rime comment 缺失/稀疏这一被 ADR 明确接受的降级场景，会暴露一个声称可选但打开空内容的控制；当前 accessibility hint 与真实 enabled 状态矛盾。

Required change：

- availability 必须来自 KeyboardCore 已验证路径/窗口能力；无路径时禁用，且不能打开面板。
- 增加无 comment、全非法 comment、只有后续 window 有路径三种 UI 行为测试。

## 4. Non-blocking findings / follow-up risks

### [P2] ASCII contract 实现成了 Unicode CharacterSet contract

`path(fromComment:)` 与 `isValidT9RawInput` 使用 Unicode uppercase/lowercase/decimalDigits/whitespaces，`lettersOnly`/`digitsOnly` 使用 `isLetter`/`isNumber`（`T9PinyinPath.swift:81-101`、`:122-130`、`:211-216`）。ADR 0020 只允许 ASCII letters、`0...9`、普通 space 与 apostrophe。应改为显式 ASCII scalar 校验，并加入 accented letters、全角数字、tab/newline/non-breaking-space 负例。

### [P2] raw generation 实际每次 refresh 都增长，未实现“raw identity changed”

`refreshT9PinyinPathState()` 把当前 `output.rawInput` 与刚写入同一 state 的 `lastRimeOutput.rawInput` 比较，结果不可能表达 previous raw；随后又无条件 `previousGeneration + 1`（`KeyboardController+T9PinyinPath.swift:132-145`）。path selection 在 `applyRimeOutput` 内 refresh 后又显式 refresh 一次（`:104-106`）。这虽偏向安全失效，但会产生无意义 generation churn/面板重载。应把规范化 raw identity 明确存入 state 或由 apply 边界传入 previous raw，并测试“same raw stable / changed raw increments exactly once”。

### [P2] compact path 在每次 T9 output apply 中同步扫描最多 48 个 Rime candidate

`applyRimeOutputWithoutPartialCommit` 在输入处理路径同步调用 `refreshT9PinyinPathState`，后者在首屏路径不足时同步执行 `candidateWindow(from: 0, limit: 48)`（`KeyboardController+PartialCommit.swift:435-458`、`KeyboardController+T9PinyinPath.swift:147-161`）。现有普通候选预取会主动延迟到首屏渲染之后，并对 ≥30 ms 记录性能告警。当前没有这条新增同步扫描的按键延迟证据。修复 P1 后需在真机测量 key-to-marked-text/candidate latency；若超出既有体验，应将稀疏窗口扫描移出首个按键响应阶段，同时保持 session/MainActor 边界。

### [P2] Spike 是可行性证据，不是可发布的冻结证据

Spike 使用 `UK_T9_SPIKE_ALLOW_DIRTY=1`，HEAD 仍是实现前基线，并复用了旧 isolated shared tree。原始结果支持 pinned librime 下 `replaceInput`、mixed raw 和 comment 可用性，但不绑定当前可发布实现快照。发布前需在获得 commit 授权后，用干净、可复现 snapshot 重新归档 manifest/HEAD/命令/完整日志。

### [P2] 文档 whitespace gate 失败

`git diff --check` 报告 `docs/KEYBOARD_LAYOUT.md:3-6` trailing whitespace。发布前必须修复并重新运行 staged/unstaged scope checks。

## 5. 独立验证结果

| 验证 | 结果 | 边界 |
|---|---|---|
| `swift test --package-path Packages/KeyboardCore` | **PASS — 601 tests, 0 failures** | 证明当前单测集合通过，不覆盖上述缺失场景 |
| Debug Simulator 严格构建，`SWIFT_STRICT_CONCURRENCY=complete`、Swift warnings-as-errors | **BUILD SUCCEEDED** | `Universe Keyboard` scheme，generic iOS Simulator |
| Release Simulator 严格构建，同上 | **BUILD SUCCEEDED，仍有 linker warnings** | Boost xcframework 缺 x86_64 slice/arm64 archive 被忽略；因此不能写成“全矩阵零警告” |
| `git diff --check` | **FAIL** | `docs/KEYBOARD_LAYOUT.md:3-6` trailing whitespace |
| Real librime Spike archive inspection | **PASS（feasibility only）** | dirty run + reused shared fixture；未成为 publication snapshot |
| Keyboard UI focused tests | **缺失** | 未发现本 Work Item 对 fixed bar、button availability、panel paging、互斥、stale generation 的 UI/contract 覆盖 |
| Physical-device Product Gate | **未执行 / Human Dependency** | 仍为硬门禁 |

## 6. Architecture 边界判定

| 边界 | 判定 |
|---|---|
| ADR 0020 对 ADR 0018 的 mixed-T9 扩展方向 | 符合 |
| Path provenance 仅来自 Rime comments | 符合 |
| 无第二候选引擎、无 RimeEngine protocol 扩张 | 符合 |
| Extension session-only；无 deploy/vendor change | 符合 |
| Composition refinement 事务语义 | **不符合，见 P1** |
| KeyboardCore business-state ownership | **不符合，见 accessibility P1** |
| Global-index lazy full panel | **不符合，见 P1** |
| Lifecycle clear/rebuild | **不符合，见 P1** |
| 固定 34 pt reservation 与 expansion mutual exclusion 的代码方向 | 静态符合；仍缺 UI/真机证据 |

## 7. Executor 修复与复审入口

建议按以下顺序处理，避免在错误状态模型上补 UI：

1. 收紧 ASCII/混合 raw/path compatibility 纯逻辑与测试；
2. 修复 exact refinement + session-verifiable transaction rollback；
3. 统一 composition lifecycle path-state 清理；
4. 移除 accessibility business state 与 UIKit fallback model construction；
5. 接通 full-panel lazy paging，并修正空路径 button 状态；
6. 补 UI/contract、KeyboardCore、RimeBridge 回归测试；
7. 修 whitespace，重跑 KeyboardCore、RimeBridgeTests、Debug/Release 严格构建及 `git diff --check`；
8. 提交授权后生成 clean Spike snapshot；最后执行 simulator + physical-device Product Gate。

复审 handoff 必须逐项列出：finding → 修改文件 → 新测试 → exact command/result → 未完成设备证据。不得用现有 601/601 直接宣称这些未覆盖行为已经通过。

## 8. Gate decision

- Architecture：**Fail / Changes Required**。
- Quality：**Fail / Changes Required**。
- Publication：**Not Ready**；不要 commit/push/PR。
- Product Gate：保持 **Open**。完成代码复审后，仍需真机覆盖 compact 路径、完整面板分页、选择后继续数字、Delete、Space/Return、语言/页面/visibility/recovery、候选空态、VoiceOver、light/dark 与按键延迟。
