# Architecture addendum：P3-D1-T02/T03 纯值 evidence validator

| 字段 | 结论 |
|---|---|
| 复审角色 | 🏛️ Architecture & Knowledge Steward（独立补充、只读） |
| 日期 | 2026-08-03（Asia/Shanghai） |
| 上一份复审 | [`Architecture re-review`](t9-responsive-pipeline-001-p3-d1-t02-t03-architecture-rereview.md) |
| 新增对象 | `P3D1LifecycleEvidenceValidator.swift` 与 `P3D1LifecycleEvidenceValidatorTests.swift` |
| Executor 报告专项结果 | **validator 6/0；Wire 10/0；KeyboardCore full 901/0**（本 addendum 未重复执行） |
| 本次 Run ID | `P3D1-T02-T03-SIM-20260803-001` |
| 结论 | **helper、跨 epoch validator、RETURN_CLEAN 的 bounded 子项关闭；target host provenance 与 PUBLISH 语义仍开放** |
| 治理边界 | 不改变生产 gate、ADR 0025、Product Gate、Release 或真机状态 |

## 1. 本次只读检查

新增 validator 是独立于 Logger/XCTest 的纯值函数：它解析 `P3LIFE` 行，要求 schema-v1、
expected `runID`、required fields，并对 owner-ready → owner-begin → owner-end 顺序、
accepted/applied 是否出现、required marker、privacy deny-list 和 malformed shape 做
fail-closed 分类（`complete` / `partial` / `blocked` / `notRun`）。新增 6 个测试覆盖：

- 正常 content-free owner/clear/return fixture；
- 错误或缺失 Run ID 阻断；
- privacy-sensitive field 阻断；
- owner 顺序/required publish 不完整时 Partial；
- lifecycle epoch 增长时允许 revision reset；
- 空导出 NotRun。

因此，前一份 Architecture re-review 中“没有 validator”这一部分可以在 **纯值/fixture
层**关闭：validator 不会从 UI surface 或缺少日志推断 target 执行，且错误 Run ID 不会被
当作当前 run 证据。

本次 Executor 记录的构建与 UI 结果路径为：

- harness-on Keyboard build：[`build_sim_2026-08-02T16-17-30-946Z_pid40269_94150708.log`](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-08-02T16-17-30-946Z_pid40269_94150708.log)；
- gate-off Keyboard build：[`build_sim_2026-08-02T16-18-05-079Z_pid40269_f2122b35.log`](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-08-02T16-18-05-079Z_pid40269_f2122b35.log)；
- T02/T03 UI result：[`test_sim_2026-08-02T16-19-23-797Z_pid40269_b0e95931.xcresult`](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-08-02T16-19-23-797Z_pid40269_b0e95931.xcresult)。

这些路径和 `P3D1-T02-T03-SIM-20260803-001` 的 source snapshot 一并作为 Executor 快照
引用；本 Architecture addendum 未重新打开或重跑它们。

## 2. 不能扩大为 target runtime closure 的部分

### 2.1 Validator 尚未接入 T02/T03 host export

当前 T02/T03 UI test 仍只读取 `P3D1LifecycleHarness` accessibility value，并未将收集到的
marker 行送入该 validator；本次 Messages host 也没有到达 actual Extension activation。故
`6/0` 只证明纯值规则，不证明：

- 当前 Run ID 已进入 Messages/Keyboard.appex；
- target marker 的 `run=` 与 execution record 相等；
- 实际 owner delay、ordered/no-drop/no-reorder 或 visibility return 已发生；
- 真实导出没有被旧进程、错误 appex 或混 run marker 污染。

在 target host 可达前，T02/T03 仍保持 `Blocked (host accessibility)`，P2-ARCH-01 的
**target provenance** 部分仍开放。上述专项 validator 结果为 **6/0**，不是旧快照的 5/0。

### 2.2 跨 epoch 的 revision 规则：bounded closed

validator 现在按 epoch watermark 比较 revision：同一 epoch 内仍拒绝 revision regression，
epoch 增长时允许 owner revision 从 1 重新开始，并有正例回归。Executor 报告 validator
专项 **6/0**，因此该纯值规则在 bounded fixture 层关闭；它不证明实际 target marker stream
已经导出或按预期重建 owner。

### 2.3 `RETURN_CLEAN`：bounded target seam closed，host runtime 仍未证明

`handleKeyboardDidAppear` 的真实 return 分支现在发出 `RETURN_CLEAN`，marker line 新增
`returnClean=1` 字段，T03 helper 改为等待该 token；因此 fixture 与 actual target seam 的
标记形状已对齐。由于 Messages activation 仍在前置边界被 Skip，尚未观察实际
`DISAPPEAR → SUSPEND_RELEASE → RETURN_CLEAN` marker stream，不能升级为 T03 runtime Pass。

## 3. 与 target helper / 当前源码 provenance 的交叉核对

独立 Quality re-review 进一步发现的 helper 缺口现已修复：
`waitForP3D1LifecycleDiagnostic` 在 value 不匹配或超时后返回 `nil`，不会再把旧 value 当成
当前 marker。`cleared=1` 与 `returnClean=1` 仍是进程级 sticky state，故 target host run
仍需用当前 epoch/Run ID 证明它们属于本次 return。

同时，当前 `KeyboardViewController+Presentation.swift` 的 SHA-256 为
`22554f0cffa54d862b684679c422561a68e399e1c914dfdcdb19f54d3eb6f9ab`，与新 Run ID
`P3D1-T02-T03-SIM-20260803-001` 的 source snapshot 一致；最新 harness-on/gate-off build
和 UI result bundle 已记录，但 appex/test bundle hash、resolved flags digest、marker export
privacy digest 和 teardown 状态仍未冻结。

## 4. 独立 disposition

- **Bounded validator schema/run/order/privacy/epoch-reset 子项：Closed（纯值层，6/0）。**
- **Helper timeout fail-closed：Closed（bounded source review）。** 不再返回旧 value。
- **RETURN_CLEAN/returnClean marker shape：Closed（bounded target seam review）。** 实际
  return 分支发出 marker，T03 等待 `returnClean=1`；host stream 未运行。
- **P2-ARCH-01 target Run ID/actual marker provenance：仍 Open。** Host 未激活，UI test
  尚未把实际 target export 送入 validator；sticky return state 也未与本次 epoch 绑定。
- **P2 source/artifact provenance：仍 Open。** 新 Run ID、source hashes、build logs/UI
  result bundle 已记录，但 appex/test bundle hash、resolved flags/export/privacy digest
  和 teardown 状态仍缺失。
- **P2 PUBLISH semantic boundary：仍 Open。** `P3LIFE PUBLISH` 仍在 UI presentation callback
  记录，不能替代 owner completion/P2-D1 `PUBLISH` 证据。
- T02/T03 继续 `Blocked (host accessibility)`；ADR 0025 继续 Proposed；不形成真实
  off-main RIME、Release、Product Gate、真机或主观性能结论。

本角色到此停止。该 addendum 仅供独立 Quality 复审和后续 Product Lead 决策使用，不修改
生产逻辑、默认 gate、测试执行环境或设备状态。
