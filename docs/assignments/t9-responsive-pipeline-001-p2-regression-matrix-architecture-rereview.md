# Architecture re-review addendum：T9-RESPONSIVE-PIPELINE-001 / P2-Regression-Matrix-001

| 字段 | 结论 |
|---|---|
| 复审角色 | 🏛️ Architecture & Knowledge Steward（独立复审） |
| 复审日期 | 2026-08-01（Asia/Shanghai） |
| 复审对象 | `T9-RESPONSIVE-PIPELINE-001 / P2-Regression-Matrix-001` |
| 前一份复审 | [`Architecture review`](t9-responsive-pipeline-001-p2-regression-matrix-architecture-review.md) |
| 变更范围 | 仅加强 `P2-EPC-01` 测试断言；本复审未修改生产逻辑 |
| 独立专项运行 | 3 tests, 0 failures，5.492s（2026-08-01 17:49:52–17:49:58） |
| 冻结全量证据 | focused 19/0；KeyboardCore full 861/0；vendor verify 与 `git diff --check` 已报告通过 |
| Architecture 结论 | **Bounded Pass with conditions**：`P2-EPC-01` 在 Core fixture 层关闭；其余 UI、engine 观测、真实性能与时序残余仍开放 |
| P0 / P1 / P2 / P3 | **0 / 0 / 4 / 1** |
| 治理结论 | ADR 0025 仍为 `Proposed`；不形成 Product Gate、R6、Release 或默认开启结论 |

## 1. 复审范围与独立证据

本次只读 re-review 针对前一份 Architecture review 的 P2-EPC finding：父任务已将
`testAbandonEpochDropsDeferredHostWritesAndStaleResult` 从“只排除 `·`”加强为：

1. abandon 后记录 `historyStartAfterAbandon`；
2. 释放旧 owner work、flush pending 并等待；
3. 断言 `client.markedTextHistory.count == historyStartAfterAbandon`；
4. 断言 post-abandon history slice 为空；
5. 仍保留 epoch 增加、最终无 `·` 与 `skippedStaleEpochCount >= 1`。

我独立运行了三条新增回归：

```text
swift test --package-path Packages/KeyboardCore \
  --filter 'ResponsiveProvisionalL1WireTests/testDualGateStaleActionMatrixFailsClosedWithoutStateMutation|ResponsiveProvisionalL1WireTests/testDeferredL1LeavesSettledChromeSnapshotUntouched|ResponsiveProvisionalL1WireTests/testAbandonEpochDropsDeferredHostWritesAndStaleResult'
→ Executed 3 tests, with 0 failures (5.492s)
```

19/0 focused、861/0 full、vendor verify 和 `git diff --check` 作为本子件已冻结证据
引用；它们不是本次 Architecture re-review 重跑的全量结果。本工作树仍包含其他任务的
未提交改动，复审不把 ambient diff 归因于 P2，也不把脏工作树解释为 Release 构建。

## 2. P2-EPC-01 re-review：已关闭，但范围必须限定

### 2.1 结论

**P2-EPC-01 在 bounded KeyboardCore/Fake host fixture 层关闭。** 新断言不再只检查
“没有新的占位点”，而是要求 abandon 后 `markedTextHistory` 计数不增加且新增切片
为空。因此，旧 epoch 的普通文本 host write、旧 epoch 的 `·` write，以及“最终状态
正确但中间写过一次”的情况，在本测试的等待窗口内都会失败。

这关闭了前一份 Architecture review 指出的逻辑漏洞：
`dropFirst(...).allSatisfy { !$0.contains("·") }` 在普通文本写入或零条写入时的
假阳性问题不再存在。

### 2.2 保留边界

该关闭只证明当前 fake owner、semaphore 和 drain/等待窗口内的 host-history barrier：

- 它不是 UIKit `UITextDocumentProxy` 的真机证明；
- 它不是 Extension suspend/jetsam 期间的生命周期证明；
- 它不是“所有未来 host writer 都携带 provenance”的静态架构证明；
- 150ms 等待仍是 fixture 的排空预算，不是性能 SLO。

因此 P2-EPC-01 从“P2 未闭环”移出，但不应改写为“真实设备/所有异步时序均已验证”。

## 3. 其余 Acceptance matrix 结论

| ID | re-review 结果 | 仍然已证明/未证明 |
|---|---|---|
| `P2-ACT-01` | **Bounded Core 通过，条件保留** | 11 个 stale action（五种 `CandidateKind`、纠错、翻页、直接/循环 Path、Space）均返回空 effect，Core state 与 host history 不变。Partial Commit 仍是直接注入的合成 checkpoint；没有 engine-call spy，因此不是“每个 RIME API 均被计数为零”的证明。 |
| `P2-CHR-01` | **Core snapshot 通过，UI 层开放** | 已 settle 的 L2 后 blocked key 的 L1 只追加 stable prefix + `·`，last output、Path、Partial Commit、纠错状态及 presentation callback count 保持稳定。没有 UIKit Candidate/Path snapshot、真实 stale tap 或 `candidateWindow` 调用观测。 |
| `P2-EPC-01` | **Closed（bounded Core fixture）** | epoch 增加；abandon 后无占位点；释放旧 work 后 history count 不增加、post-abandon slice 为空，stale counter 增加。范围限制见第 2 节。 |
| `P2-UI-01` | **Open** | 未测试 Keyboard Extension candidate bar / expanded panel prefetch 在 ahead 时的 no-op、owner depth 或候选 snapshot 稳定性。KeyboardCore SwiftPM 结果不能替代 UIKit target 证据。 |
| `P2-PERF-01` | **Open** | 未执行真实 librime/Lua、真机长句主观延迟、队列/内存/jetsam、Release 或 Product Gate。 |

## 4. Fixture / concurrency re-check

### 4.1 现在可以信任的部分

- `BlockingDigitEngine` 以 `processEntered` 确认 owner 确实进入阻塞，再以
  `releaseFirst` 放行；没有依赖随机的“慢到某个时间”来制造 abandon race。
- P2-EPC 修复后的 count equality + empty slice 断言把 host history 的“零写入”变成
  可证伪结果，而不是仅凭最终 `markedText` 不含 `·` 推断。
- `blockOnProcessCall: 2` 仍正确区分 settled-L2 与后续 blocked key，避免把“没有
  稳定前缀”误当成 stable-chrome 通过。

### 4.2 仍需在后续授权中处理的部分

1. `PartialCommitState` 仍由测试直接赋值，不是由真实 engine output 产生；它证明
   guard precedence，而不证明 Partial Commit 恢复/候选/Path 替换的完整组合。
2. `selectCandidate`、`pageUp/pageDown`、`replaceInput` 等 RIME 方法仍只是 delegate，
   没有逐方法 call counter。当前应把结论写成“guard + state/history 行为组合证明”，
   不能扩大成 engine API 零调用证明。
3. 关键测试仍使用 20–150ms `Task.sleep`。owner 入口有 semaphore，但 L1 paint、
   MainActor drain 与全部 stale presentation 的 completion 没有统一 barrier；高负载
   CI 的 timing 稳定性尚未做多轮压力统计。

## 5. Findings 与严重度变化

### 已关闭

- **原 P2-EPC-01：** host history 断言缺口已修复，计数不增加且新增切片为空；独立
  三测试重跑通过。

### 剩余 P2（4 项）

1. **P2-ACT-01 engine/PartialCommit 观测：**补逐方法 engine spy，或增加真实
   engine-produced Partial Commit fixture；否则保留“静态 guard + 行为结果”的窄结论。
2. **P2-CHR-01 UI chrome：**Core callback/state proxy 不能替代 UIKit Candidate/Path
   视觉快照、旧窗口点击和生命周期行为。
3. **P2-UI-01 Extension prefetch：**需单独获得 UI target 授权，验证 ahead 时
   `candidateWindow` 不调用、不刷新 owner、不改变 candidate snapshot。
4. **P2-PERF-01 真实性能：**真实 librime/Lua、设备主观延迟、队列/内存/jetsam 与
   Release/Product Gate 仍是独立后续矩阵。

### P3（1 项）

- **Timing fixture：**用 owner/presentation completion barrier 或多轮压力统计替代
  对固定 sleep 窗口的隐含依赖；并明确 20–150ms 不是产品性能阈值。

没有发现 P0/P1。上述 P2/P3 是证据完备性与测试可维护性残余，不是要求本次修改生产
逻辑的理由。

## 6. 文档与治理一致性

### 一致的部分

- P2 assignment 已将 `P2-EPC-01` 写为“旧 epoch 后续不再增加 host history”，与
  新测试的 count equality 一致。
- P2 evidence 已明确写出 history count 不增加，并把 per-method engine spy、UIKit
  prefetch、真实设备与性能留作非声明/残余债务。
- dual gate 继续 default-off；ADR 0025 Amendment B 仍 Proposed；P2 子件没有修改
  Release 路径、没有授权 R6、没有创建 Product Gate 证据。

### 需要交给 Quality / Executor 的文档同步点

当前已有的 P2 Quality review 文档仍保留修复前的表述（将 P2-EPC-01 写成“只检查
`·`、history count 未断言”）。这不是本次生产缺陷，但会造成复审记录互相矛盾；应由
Quality reviewer 发布独立 addendum 或更新其复审状态，明确 P2-EPC 已关闭、其余残余
仍在开放。Architecture 本文不代替 Quality 的角色，也不直接改写该文档。

计划/产品决策中将 Core epoch/host-history 称为“covered”现在有测试依据，但仍应保留
“bounded Core”限定，不能从该措辞推导 UIKit、真机或 Release 通过。

## 7. Final verdict / stop point

本次 re-review **Pass with conditions**：

- P2-EPC-01 已在 bounded Core fixture 层关闭；
- P2-ACT/P2-CHR 的 Core 行为证据可继续保留，但 engine spy、真实 Partial Commit
  和 UIKit chrome 仍未证明；
- P2-UI-01 与 P2-PERF-01 仍 Open；timing 只列为 P3 测试残余；
- 可交给 Quality 进行对应 addendum，之后再由 Product Lead 决定是否授权 UI 专项或
  真实性能矩阵。

本结论不接受 ADR 0025、不宣布全局 Architecture/Quality Pass、不授权 R6、不形成
Product Gate/Release ready，也不改变 dual-gate default-off。

本角色到此停止，不修改生产逻辑。 
