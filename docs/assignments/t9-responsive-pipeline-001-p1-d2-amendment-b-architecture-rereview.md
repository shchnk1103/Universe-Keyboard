# Architecture Re-review Addendum: T9-RESPONSIVE-PIPELINE-001 / P1-D2 Amendment B

| Field | Value |
|---|---|
| Reviewer role | 🏛️ Architecture & Knowledge Steward（独立、只读增量复审） |
| Review date | 2026-08-01 Asia/Shanghai |
| Assignment | [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md) |
| Previous review | [`P1-D2 Amendment B Architecture review`](t9-responsive-pipeline-001-p1-d2-amendment-b-architecture-review.md) |
| Repository tip | `HEAD 3585a54` + 当前工作树未提交变更（无 release artifact） |
| Test evidence | Executor/Quality report: focused **16/0**, KeyboardCore full **858/0** |
| Verdict | **Conditional Hold — P1-1 closed；P1-2 仅 bounded path closed，完整 D3 ordered-Delete 合同仍未闭合** |
| P0 / P1 / P2 / P3 | **0 / 1 / 4 / 1** |

## 1. 复审边界与证据来源

本 addendum 只复核原 Architecture review 中的 P1-1（candidate prefetch 绕过
fail-closed）和 P1-2（ordered Delete 后 stable shadow 可能过期）修复；不覆盖、
不改写原始 Conditional Hold 记录，也不修改生产代码、测试或其他 review。

当前工作树的代码审计包含：

- `KeyboardViewController+CandidatePaging.loadMoreCandidates` 的 ahead guard；
- `alignResponsiveProvisionalAfterOrderedEngineApply` 的 stable-prefix 捕获；
- 新增 `testOrderedDeleteRefreshesStableShadowBeforeNextPendingKey`；
- 相关 D3/D10 Proposed Amendment 与 Product Decision 边界。

16/0 与 858/0 来自当前 tip 的 Executor/Quality 报告；本角色尝试用独立 scratch
路径重跑时，SwiftPM manifest 被本机 `sandbox_apply: Operation not permitted`
阻断，因此不把该数字称为本角色独立执行结果。`git diff --check` 通过。真实
librime、Extension Release wiring、真机、jetsam 和 Product Gate 仍不在本复审范围。

## 2. P1 修复复核

### P1-1 — candidate prefetch 绕过 fail-closed：**Closed（代码层）**

`Keyboard/Controllers/KeyboardViewController+CandidatePaging.swift` 的
`loadMoreCandidates` 现在在读取 `controller.rimeEngine` 和调用
`engine.candidateWindow` 之前执行：

```swift
guard !controller.isResponsiveProvisionalAhead else { return }
```

这条 guard 覆盖 bar/expanded 的同一 prefetch 入口；在 ahead 时不会进入
`ThreadAffineRimeEngineBridge.candidateWindow`，因而不会由该入口触发
`coordinator.flushPending()`。Core 的候选选择、分页和 UI prefetch 边界现在方向
一致，原 P1-1 的直接绕行已关闭。

**保留条件：** 当前没有 Extension/UI 专项测试证明“ahead + prefetch 不等待、不入队、
不改候选快照”；将其列为 P2 回归债务，不把 guard 本身扩大成真实设备不卡顿证据。

### P1-2 — ordered Delete 后 stable shadow：**部分 Closed，完整合同仍 Open**

本次修改把 `alignResponsiveProvisionalAfterOrderedEngineApply` 改为在
`clearPending()` 前捕获当前 `state.insertedPreeditText`，并且普通
`handleDeleteBackward` 的 engine-composing 分支在
`applyRimeOutputPreservingPartialCommit(...)` 返回后再次调用该 helper。对于该
主路径，Delete 返回的 host marked text 会先成为 stable prefix，再允许下一枚键
安排 L1 dots；原报告中的普通 callback-gap 场景已得到修复。

但是 D3 的 v1 path A 要求“同步 Delete 以返回 L2 shorten，并从返回 L2 清除/对齐
provisional ledger”，不只覆盖这一条分支。当前仍存在以下结构性缺口：

1. `applyRimeOutputPreservingPartialCommit` 自身在**输出应用之前**调用
   `alignResponsiveProvisionalAfterOrderedEngineApply`；它随后才更新
   `state.insertedPreeditText`。任何只调用这个函数、没有外层“输出后再次 align”
   的路径仍可能留下旧 stable prefix。
2. `handleDeleteBackward` 的
   `rollbackAcceptedT9AutoAnchorForDelete(...)=.restored` 分支（约第 208–216 行）
   调用 `engine.deleteBackward()` + `applyRimeOutputPreservingPartialCommit` 后
   直接返回，没有输出后 stable refresh。
3. `restorePartialCommitCheckpoint`、confirmed-focus / visible-spelling 等 Delete
   子路径也会直接重建或应用 RIME 输出；当前新增测试没有覆盖这些路径，也没有证明
   每一条路径都在下一键前同步刷新 stable shadow。

因此，新增测试证明的是“普通一键 Delete 流程的 bounded 回归”，不是完整
ordered-Delete API surface 的闭合。P1-2 只有在以下任一条件满足后才能标记 Closed：

- 将 stable-prefix 捕获放到统一的“输出已应用”边界，使所有调用者天然得到同一语义；
- 或为每一个返回 RIME 输出的 Delete/restore 分支增加输出后 refresh，并补齐
  “settled L2 → 各 Delete 分支 → publish callback 尚未运行 → next key”的矩阵。

这不是要求扩大 auto-anchor 功能；即使 auto-anchor 继续 default-off，也必须明确
Debug/测试开关下该现有分支是被排除的合同，或让它遵守同一 stable-shadow 不变量。

## 3. 残余 P2 / P3

### P2-D2-R1 — prefetch guard 缺少 UI 级回归

代码 guard 已覆盖直接绕行，但 KeyboardCore focused tests 没有 Extension
`loadMoreCandidates` 的调用矩阵。应在能观测 owner pending depth、candidate snapshot
和 MainActor elapsed 的测试层补一条 ahead-prefetch no-op 证明。

### P2-D2-R2 — fail-closed action matrix 仍不完整

配套 Quality 记录的 16/0、858/0 已证明代表性 candidate/correction/page-down/
Path cycle/Space 行为；仍缺 direct Path tap、page-up、各 `CandidateKind` 和带
Partial Commit 的组合矩阵。稳定 stale chrome 的 UI snapshot 前后相等也尚未直接断言。

### P2-D2-R3 — epoch/abandon 与 marked-text history 证据不完整

现有测试证明 ledger/state 清空和 gate-off 不产生 dots，但还没有逐项证明已经排队的
延迟 L1 paint 在 abandon/epoch barrier 后绝不会再次写入 host history。

### P2-D2-R4 — 真实性能/发布证据仍未建立

16/0、858/0 是 Fake/KeyboardCore 回归结果，不是 real librime 延迟分布、Extension
主观不卡顿、队列深度、jetsam、iOS 26.0 Release 或 Product Gate 证据。48 ms 仍是
Debug 实验参数，不是 Product SLO。

### P3-D2-R1 — 设计谓词与实现谓词仍有轻微漂移

`ResponsiveProvisionalCompositionMirror.isProvisionalAhead` 仍是
`isActive && slotCount > 0`，而 D4 文字定义还包括 L1 active / watermark 高于
最后 L2。当前 append 主路径通常维持该不变量，但建议后续将 epoch/revision 与
ahead 判定显式化并测试；不应借此扩大本次 B 生产范围。

## 4. 复审结论与交接

**P1-1：Closed（bounded code path）。**

**P1-2：普通 engine-composing Delete path Closed；完整 D3 ordered-Delete contract
仍 Open。** 新测试和 helper 修复是有效进展，但不能把只覆盖一条路径的 16/0 结果
升级为所有 Delete/restore 分支的 Architecture 证明。

因此当前 Architecture verdict 仍为 **Conditional Hold**，而不是无条件 Pass：
先统一或覆盖 P1-2 的剩余 ordered-apply 分支，再执行 focused + full 回归并进行
独立 Architecture/Quality re-review。dual-gate 必须继续 default-off；本 addendum
不接受 ADR 0025、不创建 Product Gate、不授权 R6 或 Release default-on。

配套 Quality 以 bounded KeyboardCore slice 报告 P1=0 与本结论并不矛盾：本
Architecture 复审额外检查了 D3 的完整 ordered API surface 和调用路径闭合性。

