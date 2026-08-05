# Architecture Review: T9-RESPONSIVE-PIPELINE-001 / P1-D2 Amendment B

| Field | Value |
|---|---|
| Reviewer role | 🏛️ Architecture & Knowledge Steward（独立、只读） |
| Review date | 2026-08-01 Asia/Shanghai |
| Assignment | [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md) |
| Decision under review | P1-D2 Amendment B（stable L2 + pending `·` + stable stale chrome + fail-closed） |
| Code tip | `HEAD 3585a54` + 当前工作树中的 Amendment B 变更（工作树非干净） |
| Test evidence | Executor report: focused **15/0**, KeyboardCore full **857/0**；本复审未重复执行 |
| Verdict | **Conditional Hold — P1 未闭合；不可称 Architecture closed** |
| P0 / P1 / P2 / P3 | **0 / 2 / 3 / 1** |

## 1. 审查边界与方法

本次只读复审检查 Amendment B 是否遵守 D10 的 precedence、raw/display 分离、
fail-closed affordances、双 gate 默认关闭以及 ADR/Assignment 边界。检查对象包含
当前工作树中的 KeyboardCore、Extension candidate/Path 读取边界和对应 Proposed
Amendment/产品决策文档；未修改生产代码、未修改既有 review、未提交。

测试数字来自 Executor/Quality 的当前 tip 回报；本角色没有把该回报重新包装成
独立执行结果。当前沙箱重跑 `swift test` 时被 `sandbox_apply: Operation not
permitted` 阻断，因此以下结论以代码/文档审计和已提交的 content-free evidence
为依据。

## 2. D10 precedence 与数据边界

### 2.1 已符合的部分

| 契约 | 当前实现观察 | Architecture 判断 |
|---|---|---|
| L0 accept 不等待 L1/L2 | L1 只在 dual gate 下由 `applyResponsiveProvisionalL1IfEligible` 延迟调度 | 符合；未看到为等待 RIME 而扩大主线程同步边界 |
| L1 只做视觉投影 | `applyProvisionalL1Visual` 仅调用 `updateInlinePreedit(..., source: .compositionProjection)`，没有 `replaceInput`、`insertText` 或 RIME 调用 | 符合；`currentComposition` 仍是 raw/recovery 状态 |
| 稳定前缀 + pending dots | `ResponsiveProvisionalComposition.presentation` 构造 `stablePreedit + (·×N)`；无稳定 L2 时仅输出 dots | 符合；中间点不是数字、拼音或候选文本 |
| L2 胜出 | `isLivePresentationSnapshot` 先校验 epoch/revision/watermark，随后取消延迟 L1、清空 pending ledger 并应用完整 L2 快照 | 设计方向符合；L2 仍是最终可见权威 |
| raw/display 分离 | `state.currentComposition`/`lastRimeOutput.rawInput` 与 `state.insertedPreeditText` 分离；T9 内部数字在 composition projection 的 host 边界被拒绝 | 符合；未发现把 `·` 或 T9 数字写回 RIME raw 的路径 |
| 默认关闭与治理边界 | `isResponsiveRimePipelineEnabled`、`isThreadAffineRimeOwnerEnabled` 默认关闭；ADR 0025 仍 Proposed，B 文档明确不授予 ADR Accept、R6、Product Gate 或 Release default-on | 符合；本复审不产生任何 Gate/Accept 授权 |

### 2.2 P1-1：candidate prefetch 绕过 fail-closed 边界

**位置：** [`KeyboardViewController+CandidatePaging.swift`](../../Keyboard/Controllers/KeyboardViewController+CandidatePaging.swift)
`loadMoreCandidates` 约第 168–192 行。

当前 UI prefetch 在读取 candidate window 前没有检查
`controller.isResponsiveProvisionalAhead`，直接调用 `engine.candidateWindow`。在
thread-affine bridge 中，`candidateWindow` 约第 350–352 行先调用
`coordinator.flushPending()`。该等待可阻塞 MainActor，直到 owner backlog 清空；它
也使 candidate paging/prefetch 在 visual shadow ahead 时重新触碰 engine pipeline。

这与 Amendment B “candidate selection、correction、candidate paging、Path、Space、
Partial Commit 在 ahead 时 fail closed”以及“L1 不等待/触碰 RIME”的边界不一致。即使
随后 Core 的选择入口返回空，prefetch 已经可能引入等待或 owner 侧工作，因此不能把它
视为纯 UI 读取。

**关闭条件：** 在 UI prefetch 入口增加 ahead guard 并返回已缓存的稳定 window，或
让 bridge 在 ahead 时只读缓存且绝不 `flushPending`；随后补一条“ahead + prefetch
不等待、不入队、不改变候选/Path 状态”的回归。该路径位于 Keyboard Extension
控制器，不在当前仅允许的 KeyboardCore slice 内；若要修复，需 Product/Assignment
明确扩展边界，不能默认为 B 已包含。

### 2.3 P1-2：ordered Delete 后下一键可能使用过期 stable prefix

**位置：** [`KeyboardController+TextEditing.swift`](../../Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TextEditing.swift)
约第 204–239 行、[`KeyboardController.swift`](../../Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift)
约第 587–594 行，以及 [`ThreadAffineRimeSession.swift`](../../Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift)
约第 153–163、212–220 行。

thread-affine `deleteBackward()` 通过 `performOrderedNow` 等待 owner 的 sink revision，
但 publish notification 再经 `.main` observer 和 `Task { @MainActor ... }` 异步路由。
Delete 的同步返回路径会应用输出并 `clearPending()`，但不会在该时刻把
`state.insertedPreeditText` 更新为新的 stable prefix；`notifyResponsivePresentation`
可能稍后才调用 `setStablePreedit`。如果用户在这个 MainActor 回调到达前按下下一枚
T9 键，L1 会把新 dot 追加到 Delete 之前的 stable prefix。

这不一定造成 raw 污染，但违反 D10 对“latest host-visible L2 stable text”的定义，
并会产生错误的视觉快照/marked-text history。它也说明 `clearPending()` 保留 stable
prefix 的设计需要和 ordered-operation 的同步结果绑定，而不能只依赖迟到的 publish
handler。

**关闭条件：** 让 ordered Delete 的返回快照在清 ledger 的同一 MainActor 临界点
更新 stable prefix（或统一走带 epoch/revision 的 L2 apply），并加入
“settled L2 → Delete → publish callback 尚未运行 → next key”回归，断言 dot 只附加到
Delete 后的前缀、最终 L2 原子替换且不提交 `·`。不得用 `@unchecked Sendable` 或绕过
owner 隔离来解决。

## 3. P2 / P3 观察

### P2-1：Path UI 仍可能在 fail-closed 后触发无状态 redraw

[`KeyboardViewController+T9PinyinPath.swift`](../../Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift)
约第 205–217 行在 Core handler 返回后无条件 union
`.t9PinyinPathsChanged` 并 `syncUI`。Core 已经 fail closed，因此没有 RIME/Path
状态突变；但 stale Path tap/cycle 仍可能关闭面板或触发一次 redraw，与“stable chrome”
的视觉意图存在边界差异。应补 UI-level no-op/视觉稳定性回归，或在 Amendment 文档中
明确这是允许的 UI-only side effect。

### P2-2：`provisionalAhead` 的代码谓词比 D4 文字定义窄

`ResponsiveProvisionalCompositionMirror.isProvisionalAhead` 当前是
`isActive && slotCount > 0`；Rem-3 D4 的定义还包括 L1 active 或 watermark 高于
最后发布的 L2。现有 append 流程通常同时设置 active/slotCount，因此尚未看到立即的
功能错误，但实现与设计定义不完全同构，未来任何清 ledger/迟到快照路径都可能漏掉
fail-closed。应统一谓词或把不变量写成可测试的显式状态机。

### P2-3：测试/证据数字在文档间不一致

当前 Executor 回报 focused **15/0**、full **857/0**；工作树既有 Quality review/
evidence 仍记录过 **22/0**、**854/0**（另有旧 focused **12/0**）。这不影响代码
审计结论，但会让后续审查无法确定测试集合和命令。下一轮应以当前 tip 冻结命令、
filter、测试总数和环境，并同步 Product Decision、evidence 与 Assignment；不能把
旧数字当作 Amendment B 的独立证明。

### P3：`setStablePreedit` 的锚点身份仍隐含在调用方

Mirror 只按字符串拒绝包含 `·` 的值，没有把 stable prefix 的 epoch/revision 一起存储。
当前主路径由 `isLivePresentationSnapshot` 和 MainActor 调用顺序保护，风险可控；但
若未来增加另一条写入路径，单靠字符串检查不足以证明锚点来自当前 L2。建议后续将
epoch/revision 作为测试可见不变量，而不扩大本次 B 生产范围。

## 4. 已证明、未证明与停止点

**已证明（基于代码审计和 Executor 报告）：**

- Amendment B 的主要 precedence 方向正确：L1 是 host marked-text 视觉层，L2 以
  live epoch/revision/watermark 通过后原子替换。
- `·` 不进入 RIME raw，不由 L1 调用 `replaceInput`/`insertText`，Return/直写路径
  会先丢弃 provisional shadow。
- Core candidate/correction/page/Path/Space 入口已有 fail-closed guards；双 gate
  默认关闭，文档未偷渡 ADR 0025 Accept、Product Gate 或 Release default-on。
- Executor 报告的当前 B focused/full 回归为 **15/0、857/0**。

**未证明：**

- candidate prefetch 在 ahead 时不触碰 owner、不阻塞 MainActor（P1-1 未闭合）。
- ordered Delete 与下一键之间的 stable-prefix 顺序（P1-2 未闭合）。
- 真 librime、真实 Extension Release wiring、jetsam、跨设备/Release/iOS 26.0、正式
  Product Gate 或主观 SLO。

**停止点：** 在 P1-1/P1-2 修复或获得明确的范围/风险决定前，本复审不建议把 B 标记
为 Architecture closed，也不建议进入 R6、ADR 0025 Accept、Product Gate 或
Release default-on。修复后应重新执行 focused + KeyboardCore full，并由独立
Architecture 与 Quality 再复审；本记录本身不构成 Product 决定。

