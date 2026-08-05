# Architecture Re-review Addendum 2: T9-RESPONSIVE-PIPELINE-001 / P1-D2 Amendment B

| Field | Value |
|---|---|
| Reviewer role | 🏛️ Architecture & Knowledge Steward（独立、只读最终增量复审） |
| Review date | 2026-08-01 Asia/Shanghai |
| Assignment | [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md) |
| Previous reviews | [`Architecture review`](t9-responsive-pipeline-001-p1-d2-amendment-b-architecture-review.md)、[`Architecture re-review`](t9-responsive-pipeline-001-p1-d2-amendment-b-architecture-rereview.md) |
| Repository tip | `HEAD 3585a54` + 当前工作树未提交变更（无 release artifact） |
| Test evidence | Executor/Quality report: focused **16/0**, KeyboardCore full **858/0** |
| Verdict | **Pass with conditions — P1-1、P1-2 均 Closed（bounded Amendment B）；仍非 Release/Gate 结论** |
| P0 / P1 / P2 / P3 | **0 / 0 / 4 / 1** |

## 1. 复审边界与证据来源

本 addendum 不覆盖或改写前两份 Architecture 记录，只复核最新工作树对两个 P1
修复的最终状态，重点是完整 D3 ordered Delete/restore 调用链：

- candidate prefetch 是否在 `provisionalAhead` 前 fail closed；
- stable shadow 是否在所有 RIME 输出、Delete、restore、Path recovery 和 host
  marked-text 出口统一捕获；
- L1 是否仍保持 raw/display 分离、L2 precedence 和双 gate default-off。

16/0 与 858/0 来自当前 tip 的 Executor/Quality 报告；本角色曾尝试以独立 scratch
路径重跑，SwiftPM manifest 被本机 `sandbox_apply: Operation not permitted` 阻断，
因此不把该数字称为本角色独立执行结果。`git diff --check` 通过。真实 librime、
Extension Release wiring、真机、jetsam、Product Gate 仍不在本复审范围。

## 2. P1 修复最终复核

### P1-1 — candidate prefetch 绕过 fail-closed：**Closed**

`Keyboard/Controllers/KeyboardViewController+CandidatePaging.swift` 的
`loadMoreCandidates` 在读取 `rimeEngine` 和调用 `candidateWindow` 之前执行：

```swift
guard !controller.isResponsiveProvisionalAhead else { return }
```

bar/expanded 的 scheduled/deferred prefetch 最终都回到该入口；ahead 时不会进入
`ThreadAffineRimeEngineBridge.candidateWindow`，也不会由此入口触发
`coordinator.flushPending()`。这与 Core candidate selection、correction、paging
和 Path/Space 的共同 fail-closed 边界一致。P1-1 的直接绕行已闭合。

尚缺 Extension/UI 层“ahead + prefetch 不等待、不入队、不改变 candidate snapshot”
专项回归，作为 P2 覆盖债务，不影响本次代码层 P1 判定。

### P1-2 — ordered Delete/restore 的 stable shadow：**Closed（完整 D3 residual）**

最新实现不再依赖某一条 Delete 分支的外层补丁，而是建立了统一的 MainActor
capture boundary：

1. `captureResponsiveStablePreeditIfReady()` 只在双 gate 开启且
   `!provisionalCompositionMirror.isProvisionalAhead` 时，将当前安全的
   `state.insertedPreeditText` 记录为 stable prefix；L1 dots 在 ahead 时不会反向
   覆盖 stable anchor。
2. `alignResponsiveProvisionalAfterOrderedEngineApply()` 先
   `clearPending()`，再 capture；因此 ordered action 结束后、异步 publish callback
   尚未到达 MainActor 的间隙，不会继续沿用旧 ledger 状态。
3. `applyRimeOutputPreservingPartialCommit` 使用 `defer` 在**输出处理完成后**再次
   capture。该统一 completion boundary 覆盖普通 Delete、auto-anchor rollback、
   partial-commit restore、Path recovery 以及其它经 `applyRimeOutput` 进入的
   RIME-output 分支，即使早退/提交也不会把旧 stable prefix 留给下一键。
4. `updateInlinePreedit`、`clearInlinePreedit`、`deleteInlinePreedit`、
   `commitInlinePreedit` 的 host marked-text/state 出口均调用同一 helper。直接
   `replaceInput`/Path identity resync 之后若有新的 host projection，也必须经这些
   出口，因此不再存在只更新 host、却漏记 stable anchor 的旁路；epoch/reset/abandon
   仍通过 mirror clear 丢弃旧 prefix。
5. 对 L1 自身的 `updateInlinePreedit(·×N)`，helper 因 ahead guard 不写入 mirror；
   这保持 raw/display 分离，并让下一枚 L1 只追加到最近一次已完成 L2/ordered
   host snapshot。

静态调用链复核覆盖了原 rereview 指出的 `.restored`、partial-commit、confirmed-focus、
visible-spelling、identity resync 等分支。新增
`testOrderedDeleteRefreshesStableShadowBeforeNextPendingKey` 与 16/0 专项结果提供
代表性 callback-gap 回归；统一 completion/host-output boundary 关闭了原 P1-2 的
完整 D3 residual，而不再只依赖普通 engine-composing Delete 测试路径。

## 3. D10、raw/display 与治理边界复核

| 契约 | 当前结论 |
|---|---|
| L0 accept 不等待 RIME | 保持；L1 由 dual gate 延迟调度，capture helper 不调用 RIME |
| L1 视觉影子 | 仅更新 host marked text；不写 `currentComposition` raw，不调用 `replaceInput`/`insertText`，且 dots 不会成为 stable anchor |
| L2 precedence | live epoch/revision/watermark 通过后取消延迟 L1、清 ledger 并原子应用完整输出；随后统一 capture 最新 host projection |
| raw/display 分离 | `currentComposition`/`lastRimeOutput.rawInput` 与 `insertedPreeditText` 分离，T9 内部数字仍在 host 边界 fail closed |
| stale chrome | L1 不触发 Extension presentation callback；Candidate/Path 仍可稳定显示，但相关 Core/UI 操作 fail closed |
| Gate/ADR 边界 | 双 gate 继续 default-off；ADR 0025 仍 Proposed；本复审不授予 ADR Accept、R6、Product Gate、Release default-on 或 real-librime wiring |

## 4. 残余 P2 / P3

### P2-D2-RR2-1 — prefetch guard 缺少 UI 级回归

代码入口已经 fail closed，但没有 Extension 测试直接观测 ahead 时
`candidateWindow` 未调用、owner pending depth 未被刷新、candidate snapshot 未改变。

### P2-D2-RR2-2 — fail-closed action / stale-chrome 矩阵仍不完整

16/0 覆盖代表性 candidate、correction、page-down、Path cycle、Space；仍缺 direct
Path tap、page-up、各 `CandidateKind`、带 Partial Commit 组合，以及 stale tap 前后
Candidate/Path snapshot 相等的 UI/Core 联合断言。

### P2-D2-RR2-3 — epoch/abandon 的 host-history 证明不完整

现有测试证明 ledger/state 和 coalesced presentation 清理，但尚未逐项断言已排队的
延迟 L1 task 在 abandon/epoch barrier 后绝不再次写入 `markedTextHistory`。

### P2-D2-RR2-4 — 真实性能与发布证据未建立

16/0、858/0 是 Fake/KeyboardCore 回归，不是 real librime/Lua 延迟分布、Extension
主观不卡顿、队列深度、内存/jetsam、iOS 26.0 Release 或 Product Gate 证据。48 ms
仍是 Debug 实验参数，不是 Product SLO。

### P3-D2-RR2-1 — `provisionalAhead` 文字定义与实现谓词仍略有漂移

实现仍以 `isActive && slotCount > 0` 判定 ahead，而 D4 文字定义还提到 L1 active 或
watermark 高于最后 L2。当前统一 capture boundary 和 append/clear 不变量使主路径
安全，但后续可将 epoch/revision floor 显式纳入状态机测试；不应借此扩大本次 B 范围。

## 5. 最终 Architecture 结论与停止点

**P1-1 Closed。P1-2 Closed。完整 D3 ordered Delete/restore stable-shadow residual
Closed（代码边界）；其专项分支矩阵仍作为 P2 回归债务保留。**

因此本次 Architecture verdict 为 **Pass with conditions（仅 bounded KeyboardCore /
Amendment B）**。P1 已清零，但这不等于工程全闭合、主观不卡顿、真实设备稳定、
Release、Product Gate 或 ADR 0025 Accept。

下一步可由 Product Lead 决定是否接受 P2 回归债务，或在任何 R6/真实 librime/真机
接线前补齐 action、prefetch、epoch/history 和 stale-chrome 矩阵。dual-gate 必须
继续 default-off；本 addendum 不授予超出 P1-D2 的任何生产或发布授权。

