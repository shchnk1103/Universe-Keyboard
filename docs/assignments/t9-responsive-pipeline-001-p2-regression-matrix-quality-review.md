# Quality Review: T9-RESPONSIVE-PIPELINE-001 / P2-Regression-Matrix-001

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（独立、只读） |
| Review date | 2026-08-01 Asia/Shanghai |
| Assignment | [`P2-Regression-Matrix-001`](t9-responsive-pipeline-001-p2-regression-matrix.md) |
| Parent design | [ADR 0025 Proposed Amendment B](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md#13-proposed-amendment-b--p1-d2-visual-shadow-anchor-and-stable-stale-chrome) |
| Repository provenance | `HEAD 3585a54` + 当前工作树未提交变更；无 Release artifact |
| Verdict | **Pass with conditions**：bounded KeyboardCore 回归矩阵；不等于 UIKit Extension、Release、Product Gate 或 ADR Accept |
| P0 / P1 / P2 / P3 | **0 / 0 / 4 / 0** |

## 1. 复审边界与独立性

本次只读复审检查 P2-Regression-Matrix-001 新增的三条 KeyboardCore 回归：

1. `provisionalAhead` 下的 stale action fail-closed（包含 Partial Commit）；
2. settled L2 后进入 blocked key 时，stale Candidate/Path chrome 与 RIME snapshot
   保持稳定；
3. visibility abandon 的 epoch barrier 后，不再把旧 provisional work 写回 host
   `markedTextHistory`。

本角色没有修改生产逻辑、测试或既有 review，只新增本 addendum。当前工作树还包含前一
阶段 Amendment B 的未提交生产/文档改动；本复审不把这些 ambient changes 视为本子件的
新实现，也不覆盖旧 review。结论只适用于 bounded Core 测试证据。

## 2. Independent evidence

### 2.1 Test runs

在当前工作树上独立运行：

```text
mkdir -p /private/tmp/universe-keyboard-clang-cache-p2quality \
  /private/tmp/universe-keyboard-swift-cache-p2quality

CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-clang-cache-p2quality \
SWIFT_MODULECACHE_PATH=/private/tmp/universe-keyboard-swift-cache-p2quality \
swift test --package-path Packages/KeyboardCore \
  --filter 'ResponsiveProvisionalCompositionTests|ResponsiveProvisionalL1WireTests'
→ Executed 19 tests, with 0 failures (50.618s)
  2026-08-01 17:40:07–17:40:58

CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-clang-cache-p2quality \
SWIFT_MODULECACHE_PATH=/private/tmp/universe-keyboard-swift-cache-p2quality \
swift test --package-path Packages/KeyboardCore
→ Executed 861 tests, with 0 failures (55.791s)
  2026-08-01 17:41:07–17:42:02
```

为检查三条新增测试的重复性，又单独运行了一次：

```text
swift test --package-path Packages/KeyboardCore \
  --filter 'ResponsiveProvisionalL1WireTests/testDualGateStaleActionMatrixFailsClosedWithoutStateMutation|ResponsiveProvisionalL1WireTests/testDeferredL1LeavesSettledChromeSnapshotUntouched|ResponsiveProvisionalL1WireTests/testAbandonEpochDropsDeferredHostWritesAndStaleResult'
→ Executed 3 tests, with 0 failures (5.499s)
  2026-08-01 17:44:20–17:44:26
```

固定的 Fake owner、semaphore 和显式 revision/epoch 让这三条测试在当前主机上可重复；
它们仍使用 20–150 ms 的测试等待窗口，没有做高负载、多轮压力或 CI 抖动统计，因此
“重复通过”不能升级为 timing-stress 证明。

### 2.2 Repository/vendor checks

```text
bash scripts/ensure_rime_vendor.sh verify
→ Verified structural inventory of 11 RIME framework artifacts

git diff --check
→ passed
```

这些检查证明的是当前 vendor 结构和工作树空白格式，不证明真实 librime/Lua 行为。

## 3. Acceptance matrix review

| Contract | 结果 | 已证明 / 限制 |
|---|---|---|
| P2-ACT-01：L1 ahead + candidate/correction/page/Path/Space | **Passed（bounded Core）** | `testDualGateStaleActionMatrixFailsClosedWithoutStateMutation` 覆盖普通 candidate、`.composition`、`.placeholder`、`.correctionCandidate`、`.continuationCandidate`、纠错、page-up/down、direct Path、cycle、Space；每次返回空 effect，并断言 Core `state` 和 host marked-text history 不变。 |
| P2-ACT-01：Partial Commit 组合 | **Passed（bounded Core）** | 测试在动作矩阵前保留人工 `PartialCommitState` checkpoint，验证候选/纠错等入口不会进入 restore/selection 分支。未直接观测 owner 是否被调用，也未单独断言纠错回调没有副作用。 |
| P2-CHR-01：settled stale chrome | **Passed（Core snapshot）** | `testDeferredL1LeavesSettledChromeSnapshotUntouched` 断言 `lastRimeOutput`、T9 Path、Partial Commit、纠错状态、presentation callback 计数均不变，host 只出现稳定文本 + `·`。没有 UIKit Extension Candidate/Path 快照或真实 UI 重绘证据。 |
| P2-EPC-01：epoch/abandon host history | **Partial — P2 gap** | `testAbandonEpochDropsDeferredHostWritesAndStaleResult` 证明 epoch 增加、ahead 清除、最终无 `·`、stale epoch counter 增加，并且 abandon 后 history 中没有 `·`。但它没有断言 post-abandon `markedTextHistory` 完全为空/计数不变；旧 L2 安全文本若被错误写入，当前断言仍可能通过。 |
| P2-UI-01：UIKit Extension bar/expanded prefetch | **Skipped** | 当前仅有 `loadMoreCandidates` 代码 guard，没有 UI 调用层的 `candidateWindow` no-op、owner depth 或 candidate snapshot 观测。 |
| P2-PERF-01：真实 librime / device long-sequence | **Skipped** | 没有真实 librime/Lua 延迟、主观不卡顿、队列/内存/jetsam 或 Release 证据。 |

## 4. Findings

### P2-RM-Q1 — epoch/abandon 的 host-history 断言不足

`historyStartAfterAbandon` 被记录后，测试只检查后续 history 项不包含 `·`。这足以
证明 provisional placeholder 没有再次出现，但不足以证明“旧 L1/L2 工作不再写入
host history”这一完整契约。建议改为同时断言：

```swift
XCTAssertEqual(client.markedTextHistory.count, historyStartAfterAbandon)
```

或对 post-abandon history 使用空集合断言，并保留 stale epoch counter 作为 owner 侧
证据。当前归类为 P2 测试覆盖债务，不把它升级为生产 P1。

### P2-RM-Q2 — UIKit Extension prefetch 仍没有可观测回归

Assignment 要求 bar/expanded prefetch 在 ahead 时不调用 `candidateWindow`、不刷新
owner、且不改变候选 snapshot；本子件明确没有 UI target 依赖，也没有伪装成 SwiftPM
KeyboardCore 证据。因此 Core action matrix 通过不能关闭这项 UIKit/UI residual。

### P2-RM-Q3 — stale action/chrome 的副作用与真实 UI 仍未完全观测

动作矩阵通过空 effect、Core state 和 host history 证明了 bounded fail-closed 行为；
settled chrome 测试通过 state proxy 与 callback 计数证明 L1 不触发 presentation bridge。
但测试没有直接记录 RIME owner/candidateWindow 调用次数、纠错学习回调次数，或
Extension 实际 Candidate/Path snapshot 前后相等。若未来 UI 接线绕过 Core guard，当前
矩阵不一定能捕获。

### P2-RM-Q4 — 真实性能、设备和发布证据不在本子件内

19/0 与 861/0 是 Fake/KeyboardCore 回归结果，不是 real librime/OpenCC/Lua、真机
长句主观不卡顿、队列深度、内存/jetsam、iOS 26.0 Release、archive/dSYM、TestFlight
或 App Store 证据。不能将测试时长或 20–150 ms Fake 阻塞参数解释为产品 SLO。

## 5. Gate and authority check

- `isResponsiveRimePipelineEnabled` 与 `isThreadAffineRimeOwnerEnabled` 仍为
  **default-off**；新增测试显式打开双 gate，不改变 Release 默认路径。
- ADR 0025 当前仍是 **Proposed**；P2 子件没有 Accept ADR、授权真实接线或改变
  `ADR 0004` gate-off 等价路径。
- Product Decision 和 Assignment 明确把 UIKit prefetch、真实设备、Release、R6、
  Product Gate 列为未授权/未执行；本复审不把 19/0、861/0 改写成任何一种发布结论。

## 6. Passed / Failed / Skipped

### Passed

- 三条新增测试在首次专项/全量运行和第二次三测试重跑中均通过。
- stale action Core 矩阵包含 Partial Commit 状态，覆盖 candidate/correction/page/
  Path/Space 入口，且无 state/host history 变化。
- settled stale chrome 的 Core snapshot、marked text 和 presentation callback 约束。
- `swift test` focused **19/0**、full **861/0**、RIME vendor verify、`git diff --check`。
- 没有发现 default-off、ADR Proposed 或 Product Gate 边界被本子件违反。

### Failed / P0-P1 blockers

- **无 P0/P1 blocker（bounded Quality scope）。**
- P2-EPC-01 的“history 完全不写入”断言尚不完整，记录为 P2，而非宣称该 acceptance
  已无条件关闭。

### Skipped（明确边界）

- UIKit Extension bar/expanded candidate prefetch no-op 及真实 Candidate/Path UI snapshot。
- real librime/Lua/OpenCC smoke、iOS Simulator/physical-device A/B。
- 长句主观不卡顿、性能分布、队列/内存压力、Extension jetsam。
- iOS 26.0 Release、archive/dSYM、TestFlight/App Store、R6、Product Gate、ADR 0025
  Accept、Release default-on。

## 7. Bounded Quality verdict and handoff

**结论：Pass with conditions（仅 P2-Regression-Matrix-001 的 bounded KeyboardCore
证据）。** 新增三条测试可在当前 Fake owner 环境重复通过，并确实覆盖 stale action
（含 Partial Commit）与 settled Core stale chrome；epoch/abandon 已覆盖“无旧占位符”
与 stale counter，但尚未完全证明 post-abandon host history 零写入。

建议按以下顺序收尾：

1. 先补强 `P2-RM-Q1` 的 history count/empty 断言；
2. 在获得 UI 专项授权后补 `P2-RM-Q2/Q3` 的 Extension prefetch 与真实 UI/owner-call
   观测；
3. 将 real librime、真机、性能/jetsam、Release 和 Product Gate 作为独立后续任务，
   建立新的 build/device provenance 和 acceptance matrix；
4. dual-gate 继续 default-off，不以本记录宣布 ADR 0025 Accept 或 Release ready。
