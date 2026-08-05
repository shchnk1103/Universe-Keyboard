# 独立 Architecture 复审：T9-RESPONSIVE-PIPELINE-001 / P2-Regression-Matrix-001

| 字段 | 结论 |
|---|---|
| 复审角色 | 🏛️ Architecture & Knowledge Steward（独立复审） |
| 复审日期 | 2026-08-01（Asia/Shanghai） |
| 复审对象 | `T9-RESPONSIVE-PIPELINE-001 / P2-Regression-Matrix-001` |
| 设计基线 | ADR 0025 Amendment B（`Proposed`） |
| 证据基线 | focused 19/0；KeyboardCore full 861/0；vendor verify 与 `git diff --check` 已报告通过 |
| 工作树基线 | `3585a54`；工作树已有其他任务的未提交改动，本复审不归因、不修改这些改动 |
| Architecture 结论 | **Bounded Pass with conditions**：Core 回归证据有价值，但本子件仍保持 `Active`，不能关闭所有 P2 债务 |
| P0 / P1 / P2 / P3 | **0 / 0 / 5 / 1** |
| 治理结论 | 不接受 ADR 0025；不形成 Product Gate、R6、Release 或默认开启结论 |

## 1. 复审范围与方法

本复审只检查 P2 子件的测试契约、fixture/concurrency 可信度、证据文档的
边界诚实性以及 KOS 状态，不修改生产逻辑，不增加 UI target 依赖，不进行真实
librime、真机、jetsam 或 Release 验证。

核对的材料为：

- [`P2 assignment`](t9-responsive-pipeline-001-p2-regression-matrix.md)
- [`P2 evidence`](../evidence/t9-responsive-pipeline-p2-regression-matrix-2026-08-01.md)
- `ResponsiveProvisionalCompositionTests.swift` 中新增的三个 P2 测试及其
  `BlockingDigitEngine` fixture
- [`parent Product Decision`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md)
  、[`plan`](../plans/t9-responsive-rime-pipeline-plan.md)、ADR 0025 Amendment B

执行器报告的 19/0 与 861/0 作为本次冻结证据引用；本复审不把测试绿色等同于
真实设备或产品门禁证据。`git diff --check` 在当前工作树通过，但工作树是脏的，
因此不能把它当作“所有未提交改动均已审查”的证明。

## 2. Acceptance matrix 逐项结论

| ID | Architecture 判断 | 已证明与边界 |
|---|---|---|
| `P2-ACT-01` | **Core guard 层面通过；条件保留** | `testDualGateStaleActionMatrixFailsClosedWithoutStateMutation` 覆盖五种 `CandidateKind`、纠错候选、翻页、直接/循环 Path 和 Space，共 11 个 stale action；`handle` 返回空 effect，Core state 与 Fake host history 保持不变。测试还直接放入一个 `PartialCommitState` 以覆盖 guard 优先级。它没有 engine API call spy，也没有从真实 RIME 输出产生 Partial Commit，因此“未调用任何 RIME API”主要由当前代码的静态 guard 顺序支持，而不是由该测试单独证明。 |
| `P2-CHR-01` | **Core 快照层面通过；UI 条件未覆盖** | `testDeferredL1LeavesSettledChromeSnapshotUntouched` 在第二次 `processKey` 被阻塞时，验证 last RIME output、Path、Partial Commit、纠错状态与 Extension presentation callback 计数不变，host 只追加稳定前缀后的 `·`。这证明了 Core 的 shadow 投影边界；没有 UIKit candidate bar / Path bar snapshot、候选窗口调用计数或真实 stale tap，因此不能宣称 Extension chrome 已验证。 |
| `P2-EPC-01` | **部分通过；当前验收断言不足以关闭 host-history 债务** | `testAbandonEpochDropsDeferredHostWritesAndStaleResult` 验证 epoch 增长、abandon 后去除 `·`、旧 work 的 stale counter 增加，并检查 abandon 后历史中没有新的 `·`。但实现是 `dropFirst(historyStartAfterAbandon).allSatisfy { !$0.contains("·") }`：普通文本的旧 epoch 写入会通过，零条写入时 `allSatisfy` 也会真；因此它证明的是“没有旧占位点写回”，不是“旧 epoch 完全不再写 host history”。 |
| `P2-UI-01` | **Open（正确保留）** | Assignment 与 evidence 都明确没有 UIKit Extension target 的 candidate-bar / expanded-prefetch 测试；SwiftPM KeyboardCore 结果不能替代该层证据。 |
| `P2-PERF-01` | **Open（正确保留）** | 真实 librime、长句主观延迟、队列深度、内存/jetsam、Release 均没有执行，也不属于本测试限定授权。 |

### 2.1 必须优先补清的 P2-1：epoch 后 host history 的“零写入”语义

P2 assignment 的 Required assertion 写的是“旧 epoch 后续不再写 host history”，而
当前测试只排除了包含 `·` 的历史项。建议下一轮在测试层明确以下任一等价契约：

1. 记录 abandon 后的 history count，等待旧 work 完成后要求 count 完全不变，并可
     对 history 做全量等值比较；或
2. 对 host write 记录 revision/epoch provenance，断言 abandon 前 epoch 的任何
     写入均不再发生。

在该断言补齐之前，P2-EPC-01 不能从“部分通过”升级为完全通过。这里不要求本次
复审直接修改测试或生产逻辑。

## 3. Fixture 与并发可信度

### 3.1 可信部分

- `BlockingDigitEngine` 只在 owner 线程的指定 `processKey` 调用上通过
  `DispatchSemaphore` 阻塞；`processEntered` 让测试知道阻塞确实已发生，
  `releaseFirst` 再放行，避免仅靠随机慢机复现。
- 测试在 `@MainActor` controller 上连续 enqueue T9 key，然后等待 owner 进入；
  因而能够观察 L1 在 L2 尚未返回时的 host 视觉影子，并检查 stale action 在
  主线程同步入口处 fail closed。
- Fake host 的 `markedTextHistory` 使“最终文本正确”与“中间是否写过占位点”
  分离，方向是正确的。
- `blockOnProcessCall: 2` 用于 settled-L2 后再阻塞，能区分“已有稳定 chrome”
  与“完全没有 L2”两种状态；这比只断言最终 composition 更有诊断价值。

### 3.2 仍可能产生假阳性或假阴性的地方

1. **Partial Commit 是合成状态。** 测试直接赋值 `controller.state.partialCommit`，
   没有同步构造对应的 host text、RIME session 或真实 remaining raw input。它能
   验证 `provisionalAhead` guard 优先于 Partial Commit 分支，但不能证明真实
   Partial Commit 恢复、候选选择和 Path 替换在同一时序下都安全。
2. **没有 engine-call spy。** `BlockingDigitEngine` 只记录/阻塞 `processKey`，
   `selectCandidate`、`pageUp/pageDown`、`replaceInput` 等方法只是 delegate；
   state/history 不变很有用，但不能单独证明每个入口均未触碰 RIME。当前结论应
   写成“行为结果未变，且静态 guard 位于 engine 调用前”，不要扩大成完整调用计数证明。
3. **时间等待仍是 wall-clock。** 关键断言使用 20ms/35ms 视觉延迟和
   100ms/150ms 清理等待。owner 进入有 semaphore，属于较强同步；但 L1 paint、
   MainActor drain 与 stale result 的最终排空没有统一的 completion barrier。在
   高负载 CI 上可能出现 flaky timeout，也可能在等待窗口尚未真正完成时取得中间
   快照。后续应优先用可等待的 presentation/owner-drain signal，或在证据中明确
   这些 sleep 是测试 fixture 的时间预算而非性能阈值。
4. **“settled chrome”是 Core proxy。** callback count 未增加能说明当前 Core 没有
   发出新的 Extension presentation，但不能观察 UIKit 是否因自身生命周期、prefetch
   或旧窗口缓存而刷新。该边界已在 P2-UI-01 正确标记为 Open。

上述第 1、2、3 项属于测试契约/fixture 的 P2/P3 残余，不构成当前生产路径的 P0/P1
架构缺陷；不要通过修改生产逻辑来迎合测试。

## 4. 文档与证据诚实性

### 4.1 已经诚实的部分

- P2 assignment 的禁止范围明确不接真实 librime、Extension、设备、jetsam、
  Release、R6、Product Gate，也明确不改变双 gate。
- P2 evidence 顶部把 `responsive + thread-affine` 标为 default-off，并明确
  “no real librime, Extension UI target, device, Release, jetsam, ADR 0025 Accept
  or Product Gate result”。
- Product Decision 的 P2 段落明确 19/0、861/0 只是 bounded Core evidence，
  并把 UIKit prefetch、真实 librime/真机主观延迟、队列/内存/jetsam、Release、
  R6 和 Product Gate 列为未授权或未验证。
- Assignment 仍为 `Active — Core regression subset implemented; independent
  review pending`，与本复审的条件性结论一致。

### 4.2 需要收窄措辞的部分（P2-5）

- P2 assignment 的 `P2-EPC-01` required assertion 使用了绝对的“旧 epoch 后续不再
  写 host history”，但测试只验证“没有新的 `·`”。应在测试补强前改为“没有旧
  占位点写回，并观察到 stale work 被计数”，或保留原契约但标记为未闭环。
- evidence 的“epoch/host-history portions are now represented”可以保留，但不宜
  读成“无写入证明已经完成”。计划时间线中“epoch/abandon host-history contracts
  are covered”也应补充 bounded/no-dot 限定，避免后续 Dashboard 或 Product Lead
  将其误读为完整 host-history barrier 证明。

这属于证据语义校准，不是要求本复审越权编辑父文档；建议由 Executor 在补测试时
一并更新 assignment/evidence/plan 的措辞，并留下变更指纹。

## 5. 已证明与未证明清单

### 已证明（限定于本 Core fixture）

- `provisionalAhead` 时，候选/纠错/翻页/Path/Space 的 stale action 在
  `handle` 层返回空 effect，快照与 Fake host history 未被这些入口改变。
- 有已 settle 的 L2 时，L1 只生成 stable prefix + `·` 的 host projection；
  last RIME output、Path、Partial Commit、纠错状态和 presentation callback 不变。
- visibility abandon 会提高 session epoch、清掉当前 provisional presentation，
  并且旧 work 被计数/丢弃；当前测试没有观察到旧占位点再次写回。
- 执行器报告的 focused 19/0、KeyboardCore full 861/0、vendor verify 与
  `git diff --check` 结果可作为这组三个回归测试的自动化证据。

### 未证明

- epoch barrier 后 host history **完全零写入**（包括普通文本写入）；
- 每一个 stale action 的真实 RIME API 调用计数为零；
- 由真实 RIME 输出产生的 Partial Commit 与候选/Path 恢复组合；
- UIKit candidate bar / expanded panel 的 prefetch no-op、旧窗口点击和真实视觉
  chrome 快照稳定性；
- 真实 librime 长句、iPhone/iOS 目标版本主观不卡、队列/内存/jetsam、Release
  包以及 Product Gate。

## 6. 严重度与交接条件

### P0 / P1

当前没有发现 P0 或 P1。复审未发现会立即破坏输入安全、跨 session/epoch 隔离或
将 gate 默认打开的架构问题；但这不等于真实设备性能已通过。

### P2（5 项）

1. **P2-EPC-01 断言缺口：**补足 abandon 后 host history 零写入的可证伪断言。
2. **P2-ACT-01 真实性缺口：**增加 RIME 方法调用 spy，或把“静态 guard + 行为
   不变”明确写成组合证据，不宣称单测独自覆盖 API 零调用。
3. **P2-ACT-01 Partial Commit 缺口：**增加真实 engine-produced Partial Commit
   fixture，或明确该测试仅覆盖 guard precedence。
4. **P2-CHR-01/UI 缺口：**在获得额外授权后，补 UIKit Extension candidate/Path
   prefetch 与 stale tap contract；不得把 SwiftPM Core 结果冒充 UI 证据。
5. **P2-PERF-01 未验证：**真实 librime、真机长句延迟、队列/内存/jetsam 与 Release
   仍需独立授权和矩阵，不能由 19/0 或 861/0 推断。

### P3（1 项）

- 将基于 `Task.sleep` 的时间窗口替换为可等待的 owner/presentation completion
  barrier，或在测试与 evidence 中明确其用途是时序 fixture，不是性能 SLO；同时
  将“covered”措辞限定为 bounded Core/no-dot evidence。

## 7. 最终判断与停止点

本子件可交给独立 Quality 复审，并可作为“Core 回归子集已经有可运行证据”的依据；
但在 P2-EPC-01 的 host-history 断言补强、文档措辞收窄以及明确 UI/真实性能未验证
之前，不应把它标记为全部 P2 债务 Closed。

本复审**不**：

- 接受 ADR 0025 或 Proposed Amendment B；
- 宣布 Architecture/Quality 全局通过、Product Gate 通过或 Release ready；
- 授权 R6、真实设备 A/B、UIKit target 接线、生产默认开启或扩大 auto-anchor；
- 修改生产代码、测试代码或其他工作树文件。

交接给 Product Lead / Quality reviewer 时，建议保持 dual gate default-off，保留
当前 `Active` 状态，并以新的测试/文档变更指纹重新复审上述 P2 条件。
