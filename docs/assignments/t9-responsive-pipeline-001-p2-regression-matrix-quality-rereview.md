# Quality Re-review Addendum: T9-RESPONSIVE-PIPELINE-001 / P2-Regression-Matrix-001

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（独立、只读增量复审） |
| Review date | 2026-08-01 Asia/Shanghai |
| Assignment | [`P2-Regression-Matrix-001`](t9-responsive-pipeline-001-p2-regression-matrix.md) |
| Previous review | [`P2 Regression Matrix Quality review`](t9-responsive-pipeline-001-p2-regression-matrix-quality-review.md) |
| Parent design | [ADR 0025 Proposed Amendment B](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md#13-proposed-amendment-b--p1-d2-visual-shadow-anchor-and-stable-stale-chrome) |
| Repository provenance | `HEAD 3585a54` + 当前工作树未提交变更；无 Release artifact |
| Verdict | **Pass with conditions**：bounded KeyboardCore 回归矩阵；不等于 UIKit Extension、Release、Product Gate 或 ADR Accept |
| P0 / P1 / P2 / P3 | **0 / 0 / 3 / 0** |

## 1. 复审边界与变更

本次只读增量复审针对上一轮唯一未闭合的 P2-EPC-01 断言：

`testAbandonEpochDropsDeferredHostWritesAndStaleResult` 在释放旧 epoch work 后现在同时
断言：

- `client.markedTextHistory.count == historyStartAfterAbandon`；
- `postAbandonHistory.isEmpty`；
- epoch 已增加、stale epoch work 已计数/丢弃，最终没有 provisional dots。

这使测试直接检查 abandon 后 host marked-text history 没有新增写入，而不只是检查旧
占位符没有再次出现。本角色没有修改生产逻辑、测试或既有 review，只新增本 addendum；
前一阶段的未提交生产/文档改动仍是 ambient worktree provenance。

## 2. Independent evidence

### 2.1 Test evidence

针对修复后的三条新增回归独立重跑：

```text
swift test --package-path Packages/KeyboardCore \
  --filter 'ResponsiveProvisionalL1WireTests/testDualGateStaleActionMatrixFailsClosedWithoutStateMutation|ResponsiveProvisionalL1WireTests/testDeferredL1LeavesSettledChromeSnapshotUntouched|ResponsiveProvisionalL1WireTests/testAbandonEpochDropsDeferredHostWritesAndStaleResult'
→ Executed 3 tests, with 0 failures (5.494s)
  2026-08-01 17:49:45–17:49:50
```

当前修复后独立执行 KeyboardCore 全量：

```text
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-clang-cache-p2quality \
SWIFT_MODULECACHE_PATH=/private/tmp/universe-keyboard-swift-cache-p2quality \
swift test --package-path Packages/KeyboardCore
→ Executed 861 tests, with 0 failures (55.705s)
  2026-08-01 17:50:22–17:51:17
```

上一轮冻结的 focused 目标为 **19/0**；本次只变更测试断言，且当前全量仍包含并通过
全部 19 个 responsive tests。三条目标测试在修复后再次单独运行为 3/0，证明该断言
修改可重复通过。Fake owner/semaphore 和固定等待窗口提供可重复行为，但不构成高负载
或 CI timing-stress 证明。

### 2.2 Repository/vendor evidence

```text
bash scripts/ensure_rime_vendor.sh verify
→ Verified structural inventory of 11 RIME framework artifacts

git diff --check
→ passed
```

这些检查只证明当前 vendor 结构和工作树格式，不证明真实 librime/Lua 行为。

## 3. Acceptance matrix re-review

| Contract | 结果 | 证据 / 边界 |
|---|---|---|
| P2-ACT-01：L1 ahead + candidate/correction/page/Path/Space | **Passed（bounded Core）** | stale action matrix 覆盖 CandidateKind、纠错、翻页、direct Path、cycle、Space；每个入口返回空 effect，Core state 与 host history 不变。 |
| P2-ACT-01：Partial Commit | **Passed（bounded Core）** | 测试在动作矩阵前保留 `PartialCommitState` checkpoint，未进入 restore/selection；没有直接 owner-call 或纠错学习回调计数。 |
| P2-CHR-01：settled stale chrome | **Passed（Core snapshot）** | `lastRimeOutput`、Path、Partial Commit、纠错状态、presentation callback 与 host marked text 均保持预期；没有实际 UIKit Extension snapshot。 |
| P2-EPC-01：epoch/abandon host history | **Closed（bounded Core）** | 新断言证明 abandon 后 history count 不增加且 post-abandon slice 为空，同时 epoch 增加、stale work 计数/丢弃、无 dots。 |
| P2-UI-01：UIKit Extension prefetch | **Skipped / residual P2** | 未从 bar/expanded UI 观测 `candidateWindow` no-op、owner depth 或候选 snapshot。 |
| P2-PERF-01：real librime/device long-sequence | **Skipped / residual P2** | 未执行真实 librime、真机主观延迟、队列/内存/jetsam 或 Release 验收。 |

## 4. Residual P2

### P2-RM-RR1 — UIKit Extension prefetch 仍未建立 no-op 证据

Core 中的 `loadMoreCandidates` guard 已在 `candidateWindow` 前 fail-closed，但本子件
没有 UI target 依赖，也没有直接观测 bar/expanded prefetch 是否调用 owner、改变候选
snapshot 或刷新 UI。该 residual 仍需独立 UI/Extension 测试授权，不能用 19/0 或 861/0
替代。

### P2-RM-RR2 — owner-call 与真实 stale chrome 仍未直接观测

stale action 测试通过空 effect、Core state 与 host history 证明 bounded fail-closed；
settled chrome 测试通过 state proxy、presentation callback 计数和 marked text 证明
L1 不触发 Core presentation bridge。但尚未记录 RIME owner/candidateWindow 调用次数、
纠错学习回调，或实际 Extension Candidate/Path snapshot 前后相等。若未来 UI 接线绕过
Core guard，当前 Core 矩阵不一定能检测到。

### P2-RM-RR3 — 真实性能、设备和发布证据不在本子件内

Fake owner 和 19/0、861/0 只证明 bounded 行为与回归合同，不提供 real librime/Lua/
OpenCC 延迟分布、长句主观不卡顿、队列/内存压力、Extension jetsam、iOS 26.0 Release、
archive/dSYM、TestFlight/App Store 或 Product Gate 证据。测试中的 20–150 ms 阻塞窗口
不是产品 SLO。

## 5. Gate and authority check

- `isResponsiveRimePipelineEnabled` 与 `isThreadAffineRimeOwnerEnabled` 仍为
  **default-off**；测试显式打开双 gate，不改变 Release 默认路径。
- ADR 0025 仍为 **Proposed**；本子件未 Accept ADR、未授权真实接线、未改变 ADR 0004
  gate-off 等价路径。
- P2-EPC 关闭只表示该 bounded KeyboardCore history contract 已有回归证明，不是
  Product Gate、R6、Release 或主观不卡顿结论。

## 6. Passed / Failed / Skipped

### Passed

- P2-EPC-01：epoch/abandon 后 host history count 不增加，post-abandon slice 为空，
  且 stale work 被计数/丢弃。
- stale action（含 Partial Commit）与 settled Core stale chrome 的既有回归继续通过。
- 修复后新增三测试 **3/0**、KeyboardCore 全量 **861/0**；上一轮 focused **19/0**。
- RIME vendor structural verify、`git diff --check`。
- 没有发现 default-off、ADR Proposed 或 Product Gate 边界被本子件违反。

### Failed / P0-P1 blockers

- **无 P0/P1 blocker（bounded Quality scope）。**
- P2-EPC 的 bounded acceptance 已关闭；剩余三项仍是 UI/真实性能与发布证据债务，不能
  被误报为生产已闭合。

### Skipped（明确边界）

- UIKit Extension bar/expanded prefetch no-op 与实际 Candidate/Path UI snapshot。
- RIME owner/candidateWindow/纠错回调直接调用计数。
- real librime/Lua/OpenCC smoke、iOS Simulator/physical-device A/B。
- 长句主观不卡顿、队列/内存压力、Extension jetsam。
- iOS 26.0 Release、archive/dSYM、TestFlight/App Store、R6、Product Gate、ADR 0025
  Accept、Release default-on。

## 7. Bounded Quality verdict and handoff

**结论：Pass with conditions（仅 P2-Regression-Matrix-001 的 bounded KeyboardCore
证据）。** P2-EPC-01 已因 history count/empty 断言而关闭；stale action（含 Partial
Commit）与 settled Core stale chrome 继续通过。剩余 P2 仅涉及 UIKit Extension prefetch、
owner-call/真实 UI 观测，以及 real librime/设备/性能/Release 边界。

建议：

1. 保持当前测试矩阵与证据冻结；不要把 P2-EPC 关闭扩展为 UIKit 或真实设备结论；
2. 如需继续，另行授权 UI/Extension prefetch 与 owner-call 观测；
3. 将 real librime、真机、性能/jetsam、Release 和 Product Gate 建立为独立任务，使用
   新的 build/device provenance 与 acceptance matrix；
4. dual-gate 继续 default-off，不以本记录宣布 ADR 0025 Accept 或 Release ready。
