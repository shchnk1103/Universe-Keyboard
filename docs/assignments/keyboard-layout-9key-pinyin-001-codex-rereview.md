# KEYBOARD-LAYOUT-9KEY-PINYIN-001 Codex 独立复审

- 复审日期：`2026-07-18 Asia/Shanghai`
- 复审角色：Architecture & Knowledge Steward；Quality, Performance & Release
- 分支：`feature/keyboard-layout-9key-pinyin-001`
- HEAD：`44d42130bd8e2012bce7b4c034c4bc51a149dec3`
- 对象：上述 HEAD 上的当前未提交工作区
- 输入 handoff：`docs/assignments/keyboard-layout-9key-pinyin-001-grok-fix-handoff.md`
- Architecture：**Fail / Changes Required**
- Quality：**Fail / Changes Required**
- Publication：**Not Ready**
- Product Gate：**Open；Human Dependency 未满足**

## 1. 独立性与权威

本复审重新读取 Assignment、Product Decision、ADR 0020、原 Codex review、Grok fix handoff、领域文档和当前代码。Grok handoff 只提供待核 claims 与定位入口；其中的 PASS、根因和完成声明均由本次静态审查及独立命令重新验证。聊天不作为权威。

## 2. Executive conclusion

Grok 对原 review 的多数直接缺陷做了实质修复：ASCII contract、位置式 mixed-raw 校验、exact-raw 比较、滚动入口、accessibility payload、常见 finalize/abandon 清理、generation 稳定性和 whitespace gate 均比首轮实现明显改善。

但 Architecture/Quality 仍不能通过。当前还有四个 P1：Core 没有真正执行 comment provenance；稀疏路径若首次出现在第 17 个候选之后，按钮会把完整面板永久锁死；refinement/rollback 仍把“只有相同 raw、没有可用 composition/candidates”的输出当成功；页面往返只清空路径而不重建。它们分别破坏 ADR 0020 的来源、完整路径可达性、事务语义和 lifecycle state contract。

## 3. Blocking findings

### [P1] Core 的 provenance guard 逻辑等价于只做 compatibility

证据：

- `handleSelectT9PinyinPath` 先允许 `known || isCompatible`，紧接着又单独要求 `isCompatible`（`KeyboardController+T9PinyinPath.swift:83-92`）。两个 guard 合并后的实际条件仅是 `isCompatible`；`known` 对结果没有约束。
- `KeyboardAction.selectT9PinyinPath` 是公开 action，`T9PinyinPath` 也是可公开构造的值。任何调用方都能构造一个与 raw 槽位兼容、但从未出现在当前 Rime candidate comments 中的路径，并触发 `replaceInput`。
- 当前测试没有“兼容但未由当前 generation/window 颁发的路径必须拒绝”的负例。

影响：

- Product Decision §2 和 ADR 0020 §3 要求路径只能来自当前 Rime comments；ADR 同时把 parsing、validation、ranking、dedupe、window state 归 KeyboardCore。当前安全性依赖 UIKit 恰好只传 window 数组，Core 自己没有守住 provenance boundary。

Required change：

- 让 Core 选择 API 接受由 Core 颁发、绑定当前 raw generation 的稳定引用/token，或让 Core 保存当前可选择 window provenance；不要接受裸的、任意可构造 path 作为充分授权。
- compact 与 expanded path 都必须在 Core 验证“当前 generation + 来自当前 Rime window”；加入 compatible-but-unissued、old-generation、expanded-issued 三类测试。

### [P1] `hasSelectableT9PinyinPaths` 的 16-candidate peek 会让后置有效路径不可达

证据：

- compact refresh 只看当前 page candidates，再同步扫描 `hotPathWindowLimit == 16`（`T9PinyinPath.swift:62-65`、`KeyboardController+T9PinyinPath.swift:168-185`）。
- compact 为空时，`hasSelectableT9PinyinPaths()` 仍只扫描前 16 个候选（`KeyboardController+T9PinyinPath.swift:55-68`）。
- UIKit 用这个布尔值禁用“选拼音”并阻止打开面板（`KeyboardViewController+T9PinyinPath.swift:33-50`、`:70-80`）。
- 但面板首窗本可读取 48 个候选并继续 lazy paging（`:96-105`）。如果前 16 个 comments 无效、有效路径首次位于 17–48，按钮会被禁用，面板及后续 paging 永远没有入口。
- Grok 新增的测试只验证“所有 comments 均无效时 false”，未覆盖“前 16 无效、后续 window 有效”。

影响：

- Product Decision §1.4 的完整路径面板和 ADR 0020 的 sparse-comment/lazy-window 设计在合法数据分布下不可达。这不是单纯空态文案问题，而是有效路径功能丢失。

Required change：

- 将“当前没有发现 compact path”与“已证明全局没有任何 path”分开建模。只要 candidate window 仍可能前进，就不能用 16-item negative peek 宣告无路径。
- 为后置路径设计有界、可继续的 discovery 状态；必要时允许 panel 以 loading/empty-so-far 状态打开并自动推进有界窗口，同时保持无穷扫描防护。
- 增加 valid-at-index-17、valid-after-empty-window、all-invalid-to-end 和 stale-generation 的 Core/UI contract 测试。

### [P1] exact refinement 与 rollback 仍未要求 usable composition/candidates

证据：

- `isExactSuccessfulT9Refinement` 将 `result.composition != nil || !refinedRaw.isEmpty` 视为有 composition；因此只要 raw 与 requested path 相同，即使 `composition == nil` 且 candidates 为空也会成功（`KeyboardController+T9PinyinPath.swift:209-218`）。
- rollback 的 `sessionRestored` 同样只验证 committedText 为空和 raw identity 相同，不验证 composition/candidates（`:229-247`）。
- rollback 成功分支调用 `applyRimeOutput` 后返回空 effect；如果 live restored output 与 previous snapshot 的 composition/candidates/marked text 不同，UI 没有收到相应刷新信号。
- `previous`、`previousMarked`、`previousComposition` 最终被显式丢弃（`:260-262`），与 Product Decision “恢复旧 composition、Chinese candidates、host marked text”的事务要求不一致。
- 新测试覆盖 wrong raw、unexpected commit 和完全空 rollback failure，但没有覆盖“raw identity 正确、composition/candidates 丢失”的半失败输出。

影响：

- Rime 可以返回相同 raw 的不可用状态而被当成 refinement/rollback 成功；Core、候选 UI 和 marked text 仍可能分叉。ADR 0020 §1、Spike gate 和实施计划均要求 usable/non-empty composition，并在失败时恢复旧 candidates/marked text。

Required change：

- refinement 成功至少要求：exact raw、无 commit、有效 composition/session composing，以及符合合同的候选状态；不能用 raw 非空代替 composition。
- rollback 必须验证可用 session state，并确保 previous composition、candidate snapshot 和 marked text 得到恢复或用经过验证的 live equivalent 替代；任何可见变化必须返回正确 effect。
- 增加 exact-raw-but-no-composition、exact-raw-empty-candidates、rollback-same-raw-unusable、rollback-live-equivalent 四类测试。

### [P1] 页面切换只清空 path state，返回 letters 时没有重建

证据：

- `handleTogglePage()` 在每次 page transition 后无条件清空 path state，并注释“rebuild on next T9 apply”（`KeyboardController+ModeAndShift.swift:19-35`）。
- 当前 page switch 不会放弃 Rime composition；从 letters 切到 numbers，再不输入任何字符返回 letters，不会发生新的 Rime apply。
- `cycleKeyboardPage(to:)` 只重复调用 `.togglePage`（`KeyboardViewController+ModeActions.swift:65-74`）。返回 letters 后 path bar 从空 state 渲染；最多按钮通过另一次 peek 变为可用，compact paths 不会恢复。
- lifecycle 测试只断言离开 page 后 paths 为空，没有验证带着同一 composition 返回 letters 后重建。

影响：

- 用户仅浏览数字/符号页再返回时，精准路径栏会在仍有 active composition 的情况下消失，直到下一次 Rime 输入。ADR 0020 §6 要求 page switch 清空/重建，而不是永久丢失仍有效的展示状态。

Required change：

- 明确二选一合同：离开 letters 时真正 abandon composition；或返回 Chinese nine-key letters 时从当前 live Rime output 重建 path state。不要只等待未来按键偶然修复。
- 增加 letters → numbers → letters、direct target page cycle、带/不带 active composition 的 state/effect 测试。

## 4. 首轮 findings 复核矩阵

| 首轮 finding | 复审判定 |
|---|---|
| mixed raw 数字后缀被忽略 | **已修复**：按槽位校验及负例存在 |
| 任意变化 raw 被接受 | **部分修复**：exact raw 已收紧；usable composition/rollback 仍见新 P1 |
| full panel lazy paging 无滚动入口 | **入口已修复**；availability false-negative 仍见新 P1 |
| finalize/abandon 不清 path | **大部分修复**；page round-trip rebuild 仍见新 P1 |
| accessibility metadata 承载 replacement | **已修复**：a11y value 不再作为 replacement 路由 |
| 无路径按钮仍可用 | **局部修复**：全无效时可禁用；后置有效路径被误判无路径 |
| ASCII contract 过宽 | **已修复** |
| generation 每 refresh 增长 | **已修复**：相同 raw 稳定，raw 变化 +1 |
| 同步 48-candidate hot-path scan | **风险降低但未验收**：缩至 16；仍有重复 peek，需真机 latency evidence |
| dirty Spike 被当 publication snapshot | **证据边界已纠正**；clean snapshot 仍未生成 |
| trailing whitespace | **已修复**：`git diff --check` 通过 |

## 5. 独立验证

| 验证 | 本次结果 | 说明 |
|---|---|---|
| `swift test --package-path Packages/KeyboardCore` | **PASS — 607 tests, 0 failures** | 独立运行；当前测试集合不覆盖上述四个 P1 |
| KeyboardTests / iPhone 17 Pro Simulator 26.5 | **PASS — 6 tests, 0 failures** | xcresult summary；没有 path-panel hosted UI tests |
| Debug strict Simulator build | **exit 0 / succeeded** | `SWIFT_STRICT_CONCURRENCY=complete`、Swift warnings-as-errors；仍有 Boost x86_64 linker warnings |
| Release strict Simulator build | **exit 0 / succeeded** | 同上；不能宣称全矩阵零警告 |
| RimeBridgeTests `build-for-testing` | **PASS / exit 0** | 证明新增 Spike test target 可编译；本次未运行 real fixture Spike |
| `git diff --check` | **PASS** | 无输出 |
| clean-commit Spike archive | **未执行** | 无 commit authorization；现有 archive 仍仅 feasibility |
| physical-device matrix / key latency | **未执行** | Human Dependency；Product Gate 保持 Open |

## 6. Architecture boundary judgement

| Boundary | Result |
|---|---|
| ADR 0020 extends ADR 0018 without deploy/vendor change | Pass |
| Comment parsing / ASCII / positional compatibility | Pass |
| Comment-only provenance enforced by KeyboardCore | **Fail** |
| Exact, usable composition refinement and transactional rollback | **Fail** |
| Lazy window wiring and generation guard | Partial；滚动入口 Pass，discovery/availability Fail |
| UIKit no accessibility business payload | Pass |
| Lifecycle clear/rebuild | Partial；常见终止 Pass，page return rebuild Fail |
| Fixed 34 pt / mutual exclusion | Static direction Pass；device/UI evidence open |

## 7. Gate decision and next handoff

- Architecture：**Fail / Changes Required**。
- Quality：**Fail / Changes Required**。
- Assignment 保持 `Active`；不得标记 `Reviewed`、`Completed` 或 `Closed`。
- Publication：**Not Ready**；不要 commit/push/PR。
- Product Gate：保持 **Open**；代码复审通过后仍需 clean evidence、hosted UI/VoiceOver、真机 interaction/lifecycle/latency matrix。

下一 handoff 回到 Grok Executor。修复包必须逐项提供新 P1 的 code diff、negative tests、exact commands/results，并保留未执行真机证据边界。Codex 不在本次 review 中代为修改实现。
