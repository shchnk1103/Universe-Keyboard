# 独立 Quality / Performance 复审：T9-RESPONSIVE-PIPELINE-001 / P2-D1

| 字段 | 结论 |
|---|---|
| 复审角色 | 🧪 Quality, Performance & Release Maintainer（独立、只读） |
| 复审日期 | 2026-08-02（Asia/Shanghai） |
| 复审对象 | [`P2-D1 Marker Contract`](t9-responsive-pipeline-001-p2-d1-marker-contract.md) |
| 复审基线 | `HEAD=3585a54`；当前 worktree 含其他任务的 ambient 改动，本复审不归因、不覆盖、不暂存 |
| 关联合同 | [`P2-PERF-02 Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)；[`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) 仍为 `Proposed` |
| Quality 结论 | **Pass with conditions（bounded diagnostic-contract review）**；P2-D1 的独立 Architecture / Quality 复审均已完成，但不能标记为 Product/Release 完成 |
| P0 / P1 / P2 / P3 | **0 / 0 / 0 / 1** |
| 治理边界 | 不宣布 Product Gate、ADR 0025 Accept、真实 librime off-main 完成、Release 或默认开启 |

## 1. 复审范围与证据分层

本次只读核对了 P2-D1 Assignment、P2-PERF-02 Evidence Contract §7.1、ADR 0025 的
Proposed amendment，以及以下 allow-list 相关实现和测试：

- `T9ResponsiveEvidenceValidator.swift`：arm-aware sync/B 校验、PUBLISH/PAINT 语义、隐私
  count-only 规则；
- `ResponsiveRimeFeltMetrics.swift`：owner completion 与 UI presentation 的拆分及去重；
- `KeyboardController.swift`：owner completion 在 latest-only coalescing 前记录、PAINT/VISIBLE
  在 UI apply 阶段记录；
- `T9ResponsiveEvidenceValidatorTests.swift`、`ResponsiveRimeFeltMetricsTests.swift`：专项
  fixtures 和回归。

当前工作树中其他文件的修改（包括早先 hardening、P1-D2 及设备证据文档）保留为 ambient
changes，不作为 P2-D1 贡献，也没有被本复审覆盖或写回。

证据严格分层：

1. Assignment verification snapshot 提供当前 tip 的 XCTest 结果；
2. Swift 6 全源 type-check 是编译/隔离证据，**不**当作 XCTest 通过；
3. `git diff --check` 通过；
4. Simulator、真机、真实 librime 和 Extension runtime 不在本子授权范围，按未执行记录，
   不用静态源码或 type-check 冒充运行时证据。

## 2. 当前测试与契约覆盖

### 2.1 当前执行结果

| 命令/范围 | 当前记录 | 证据解释 |
|---|---:|---|
| `swift test --package-path Packages/KeyboardCore --filter T9ResponsiveEvidenceValidatorTests` | **28 / 0** | 当前 validator 专项 XCTest；不是 type-check |
| `swift test --package-path Packages/KeyboardCore --filter ResponsiveRimeFeltMetricsTests` | **5 / 0** | 当前 owner/presentation metrics 专项 XCTest |
| `swift test --package-path Packages/KeyboardCore` | **894 / 0** | 当前 KeyboardCore 全量 XCTest；有既存 optional-interpolation warning，无新增失败 |
| Swift 6 普通条件及 `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` 全源 type-check | **通过** | 仅类型/并发编译证据，未计入上述测试数量 |
| `git diff --check` | **通过** | 工作树格式检查；不代表运行时通过 |

### 2.2 要求矩阵

| P2-D1 要求 | 当前实现/回归 | Quality 判定 |
|---|---|---|
| sync-positive 不要求响应式链 | `T9ResponsiveEvidenceExpectation.arm == .sync` 默认关闭 responsive felt 要求；`testSyncArmDoesNotRequireResponsiveFeltMarkers` | **通过** |
| B 每个 accepted revision 有 epoch-bound owner PUBLISH | validator 收集并比较 accepted 与 epoch-bound revision 集合；`testEpochBoundPublishMustCoverEveryAcceptedRevision` | **通过（bounded）** |
| 缺 PUBLISH 不能由 PAINT 补齐 | `testPaintCannotSubstituteForOwnerCompletion`；PUBLISH 含 UI 字段也被拒绝 | **通过** |
| owner completion 与 UI paint 分离 | `recordOwnerCompletion` 只生成不带 `lagMs/pendingAfter/coalesced` 的 `PUBLISH`；`recordPresentation` 生成 `PAINT`；controller 在 coalesce 前记录 owner completion | **通过（源码 + XCTest）** |
| duplicate owner PUBLISH 不扩大计数 | tracker 的 `completedOwnerRevisions` 防重复；validator 的 `duplicate-owner-publish`；metrics duplicate-call 与 validator duplicate-line 回归 | **通过（bounded）** |
| engine VISIBLE/PAINT 必须晚于 owner PUBLISH | validator 使用已完成的 owner revision 集合；`testEngineVisibleAndPaintMustFollowOwnerCompletion` | **通过（当前 tip）** |
| PAINT coalescing/burst | metrics 以 `coalesced=1` 生成 PAINT/BURST；既有 `ThreadAffineRimeWireTests` 覆盖 dual-gate backlog coalescing | **通过（组件级）** |
| privacy count/text/malformed | `candidates=12,` 允许；候选文本、`12ms` 等 malformed 值 blocked；非 ASCII/raw 字段 fail-closed | **通过** |
| content-free 与默认 gate | marker 只带 schema/run/revision/epoch/count/timing；Assignment 与 ADR 均保持 Proposed/default-off | **通过（静态/组件级）** |

## 3. 已证明的实现边界

### 3.1 PUBLISH 不再承担 UI paint 语义

`ResponsiveRimePreflight.publishMarkerLine` 是 owner completion 行；
`ResponsiveRimeFeltMetrics.presentationLagMarkerLine` 改为 `PAINT`。Controller 在
`applyResponsivePublishedSnapshot` 进入 latest-only UI coalescing 前调用
`recordOwnerCompletion`，而 `performResponsivePresentationApply` 才记录 PAINT 与 VISIBLE。
这样，中间 UI revision 被 coalesce 时仍有 owner-completion 证据，不会把 UI paint 缺失误报成
engine publish 缺失。

### 3.2 duplicate 与 epoch 绑定的 producer 保护

`ResponsiveRimeFeltMetricsTracker` 只接受与 accepted revision 相同 epoch 的 owner completion，
并以 `completedOwnerRevisions` 保证同一 revision 不重复产生 PUBLISH；`reset()` 在 epoch/
visibility barrier 清除该集合。Validator 另以 `epochPublishRevisions` 检出重复 PUBLISH，并
按 `acceptedEpochByRevision` 检查 epoch。显式 preflight 的 ACCEPT、PUBLISH、VISIBLE、PAINT
和 BURST 现在统一经过 `recordResponsiveFeltMarker` 的 mandatory channel；普通构建仍使用
`Logger.performance`。当前 28/0 与 5/0 已覆盖这一 bounded 语义；metrics 回归还覆盖了
最终 tip 中 epoch 变化时 accepts/paint/visible 状态的 bounded 清理，revision counter 重用不会
继承旧 epoch 的去重状态，且旧 epoch late completion 会被拒绝。

### 3.3 arm-aware 与隐私规则

sync arm 只检查 gate-off PATH、T9SEG、geometry、session 和 commit 事实，不强迫制造
ACCEPT/PUBLISH；thread-affine arm 才要求完整 owner completion 链。候选摘要只接受非负数字
count，候选文本和 malformed value 仍 fail-closed。没有看到 `@unchecked Sendable`、默认 gate
开启或真实 `RimeEngineImpl` 生产接线变化。

## 4. Quality findings

### P2-D1-Q1 — 已关闭：epoch 回退与 epoch 变化后的 revision 复用

Evidence Contract §7 冻结的顺序是：

```text
ACCEPT →（可选 provisional VISIBLE）→ owner PUBLISH →（可选 engine VISIBLE/PAINT）
```

当前 validator 已经拒绝 engine VISIBLE/PAINT 早于 owner PUBLISH，
`testEngineVisibleAndPaintMustFollowOwnerCompletion` 覆盖该负例；PUBLISH duplicate、epoch
与同 revision accepted epoch 不匹配也会失败。新增 `lastPublishedEpoch` 单调检查和
`testEpochRegressionIsPartial`，对 `2 → 1` 的 PUBLISH 序列返回 `epoch-regression`；
`testOwnerCompletionAllowsRevisionReuseAfterEpochChange` 则证明新 epoch 重启 revision counter
后不会继承旧 epoch 的 owner-completion 去重状态。因此前一版 Q1 已关闭。

这项回归只收紧诊断证据判定，不改变生产输入行为、默认 gate 或 ADR 状态。本复审已覆盖
最终 tip 的 epoch 变化清理与旧 epoch late completion 的 bounded 拒绝；但真实 runtime
reset/recover、late-result 丢弃和 revision 重置的生命周期仍未证明（见 P3-D1-Q3），不能由这组
纯函数 XCTest 推导。

### P3-D1-Q3 — target-level timeout/fallback 与真实 runtime 尚未闭合

当前 28/0 validator、5/0 metrics 和 894/0 全量都是 KeyboardCore/组件层证据；没有 App/
Extension target-level 测试直接证明 owner timeout → PATH + NOT_READY → gate 清除 → 同步
回退；也没有真实 epoch reset/recover 后的 late-result 丢弃证明，以及真实 `RimeEngineImpl`、
App Group persistence、jetsam 或键盘 reload 运行。该缺口
已被 Assignment 明确列为越界/未执行，属于 **P3 runtime integration evidence**，不是本次
擅自扩大范围的理由。

## 5. 未执行验证与环境阻塞

明确未执行：

- XcodeBuildMCP iOS Simulator XCTest：缓存的 simulator UDID
  `D3C353BE-3AA6-499B-8F87-349073D65BE4` 不存在，目的地解析失败；本次没有自动创建或擦除
  Simulator；
- iPhone 真机安装、手动长句、真实 `RimeEngineImpl`、`rime_diag_log` persistence/export；
- Extension jetsam、内存峰值、队列深度、多次 keyboard reload/epoch barrier；
- iOS 26.0 Release RC、签名 archive/dSYM、TestFlight/App Store、Product Gate、ADR 0025
  Accept 和 Release default-on。

这些项目要么是当前环境 blocker，要么不在 P2-D1 授权范围；不把它们写成 XCTest 失败，也不
把历史 P2-H-06 B evidence 从 `Partial` 改写为通过。

## 6. 最终结论与交接

**Quality verdict：Pass with conditions。** P2-D1 已完成四种 marker 的基本语义拆分、arm-aware
validator、duplicate owner completion 防护、engine-before-PUBLISH、epoch rollback 与 epoch
变化后的 revision reuse 回归，以及 privacy count/text 回归；当前 28/0、5/0、894/0 与
type-check 结果分层记录正确，且没有
默认 gate、ADR 或 Product Gate 变更。

P2-D1-Q1 已关闭；P3-D1-Q3 保留 target/runtime、epoch reset/recover/late-result 与真实
persistence 证据边界。显式 preflight felt-marker channel 已按当前 tip 修复，但真实 persistence
仍未执行。独立 Architecture / Quality 复审均已完成，双方结论均为
**Pass with conditions**；保持 Assignment 为
`Completed with bounded residuals; Architecture/Quality reviews complete`，不得宣布
P2-D1 Complete、ADR 0025 Accepted、真实 off-main 生产接线、Release 或 Product Gate。

本文件是独立只读 Quality/Performance 复审记录；未修改生产逻辑、默认 gate、RIME/Lua、设备
状态或治理结论。
