# Quality Review: T9-RESPONSIVE-PIPELINE-001 / P1-D2 Amendment B

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（独立、只读） |
| Review date | 2026-08-01 Asia/Shanghai |
| Assignment | [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md) |
| Design authority | [ADR 0025 Proposed Amendment B](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md#13-proposed-amendment-b--p1-d2-visual-shadow-anchor-and-stable-stale-chrome) |
| Repository HEAD | `3585a540ba8389673acd49128d87040ac9619f27` |
| Provenance | HEAD is the documentation tip; Amendment B production/test changes are an uncommitted working-tree diff. No release commit or build artifact was reviewed. |
| Verdict | **Pass with conditions** for the bounded KeyboardCore Amendment B slice; **not** Product Gate, Release, ADR Accept or default-on evidence |
| P0 / P1 / P2 / P3 | **0 / 0 / 4 / 0** |

## Scope and independence

本复审只检查当前工作树中的 Amendment B：视觉影子前缀、pending `·`、L2 原子替换、
`provisionalAhead` 期间的 fail-closed 交互、epoch/abandon 生命周期，以及 gate-off
边界。未修改生产代码、测试或既有 review，也未把历史 device evidence 当作本次结论。

## Independent evidence

工作树在复审时为 `main...origin/main`，包含 Product/Executor 预期的未提交改动；
`git diff --check` **通过**。

在当前 HEAD + working-tree diff 上独立执行：

```text
mkdir -p /private/tmp/universe-keyboard-clang-cache \
  /private/tmp/universe-keyboard-swift-cache

CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-clang-cache \
SWIFT_MODULECACHE_PATH=/private/tmp/universe-keyboard-swift-cache \
swift test --package-path Packages/KeyboardCore \
  --filter 'ResponsiveProvisionalCompositionTests|ResponsiveProvisionalL1WireTests'
→ 15 tests, 0 failures, 44.927s

CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-clang-cache \
SWIFT_MODULECACHE_PATH=/private/tmp/universe-keyboard-swift-cache \
swift test --package-path Packages/KeyboardCore
→ 857 tests, 0 failures, 50.154s

bash scripts/ensure_rime_vendor.sh verify
→ structural inventory of 11 RIME framework artifacts verified
```

缓存路径仅用于绕过本机受限的默认 Swift/Clang cache；它不改变测试输入或生产代码。

## Evidence matrix

| Contract / case | Result | Evidence / limitation |
|---|---|---|
| 稳定 L2 文本 + pending dots | **Passed** | `testSettledEngineThenBlockedKeyAppendsDotsToStablePreedit`、`testPresentationAppendsPendingDotsToStablePreedit`；验证 `稳定文本 + ·` 的 host history。 |
| 无稳定前缀 | **Passed** | `testDualGateL1PaintsDotsBeforeEngine`、`testCoalesceBacklogStillPaintsL1`；验证 `·×N` 且不泄漏数字。 |
| L2 原子替换 | **Passed** | 稳定前缀测试断言 history 为 `[L2, L2+·, final L2]`，最终无 `·`；`testFastEngineDoesNotWriteTransientProvisionalMarkedText` 验证快速 owner 不留下临时占位。 |
| Candidate fail-closed | **Passed with P2 coverage gap** | blocked-owner 测试验证普通 candidate tap；实现入口统一 guard 覆盖 candidate-like kind，但未为 `.composition` / `.continuationCandidate` / `.placeholder` 各自建立独立动作矩阵。 |
| Path selection / cycling fail-closed | **Passed with P2 coverage gap** | `testDualGateL1PaintsDotsBeforeEngine` 验证 cycle；直接 Path tap 与 stale Path snapshot 尚无 Amendment B 专项断言。 |
| Space / 选定 fail-closed | **Passed** | blocked-owner 测试验证 `.insertSpace` 无 effect；未产生 host commit。 |
| Candidate paging fail-closed | **Passed with P2 coverage gap** | blocked-owner 测试验证 page-down；page-up 尚未单独断言，但两入口共用同一 guard。 |
| Correction candidate fail-closed | **Passed** | blocked-owner 测试验证 `insertCorrectionCandidate` 无 effect。 |
| Partial Commit action fail-closed | **Passed with P2 coverage gap** | candidate 入口 guard 位于 partial-selection 前；尚无独立“带 partial state 点击候选/纠错”回归。 |
| Epoch / abandon | **Passed with P2 coverage gap** | `testAbandonClearsL1`、既有 `testDualGateAbandonDropsDeferredCoalescedPresentation` 及全量 epoch 测试通过；尚无专门断言“abandon 后延迟 L1 task 不再写 host marked-text history”。 |
| Gate-off 默认与同步等价 | **Passed** | `testGateOffHasNoL1`、`testDualGatesDefaultOff`、既有 R2 gate-off/synchronous tests；全量 857/0。 |
| 内部 T9 数字不进入 host | **Passed** | L1 wire 与稳定前缀测试检查 marked-text history / final text 无 ASCII digits；`updateInlinePreedit` 的最终安全边界仍生效。 |
| L1 不触发 Extension chrome redraw | **Passed with P2 coverage gap** | `testDeferredL1DoesNotNotifyExtensionChrome` 验证 callback 不增加；未直接比较 Candidate/Path 快照在 L1 期间保持不变。 |
| Delete / Return / direct reset 生命周期 | **Partial** | Return 与 abandon 有专项覆盖；Delete 仍沿既有 D3 path A，当前没有“L1 ahead + Delete + delayed result”专门矩阵。 |

## Findings

### P2-D2-Q1 — fail-closed action matrix 不完整

当前代码在 Candidate、Correction、paging、Path、Space 等入口使用共同的
`rejectIfResponsiveProvisionalAhead()`，因此安全方向正确；但测试只覆盖了部分代表性动作。
缺少 direct Path tap、page-up、不同 CandidateKind 和带 Partial Commit 状态的组合矩阵。
这不会否定本次 bounded slice，但会降低以后 UI 接线变化时的回归敏感度。

### P2-D2-Q2 — epoch/abandon 对 host history 的证明不完整

现有测试证明 ledger/state 会清空、旧 coalesced presentation 不会恢复 composition；
尚未直接证明已排队的延迟 L1 paint 在 abandon/epoch barrier 后不会再次调用
`setMarkedText`。建议后续使用可观察的 `FakeTextInputClient.markedTextHistory` 补一条回归。

### P2-D2-Q3 — stable stale chrome 只有 callback 级证据

Amendment B 接受“视觉上保留旧 Candidate/Path，但交互 fail-closed”。现有测试证明
L1 不调用 Extension presentation callback，却没有捕获 Candidate/Path snapshot 前后相等、
或在 stale tap 后 snapshot/engine call 不变的 UI/Core 联合断言。

### P2-D2-Q4 — 性能与发布证据仍未形成

本次 Fake owner 测试证明了行为顺序和不写入临时占位，但不提供真实 librime 的延迟分布、
Extension 主观不卡顿、队列深度、内存/jetsam 或 iOS 26.0 Release 证据。48 ms delay 仍是
Debug 实验参数，不是产品 SLO。当前未执行 xcodebuild Simulator/physical-device、真实
librime/Lua、archive/dSYM 或 Release acceptance matrix；这些均超出 Amendment B 授权范围。

## Passed / Failed / Skipped

### Passed

- Amendment B 的纯 KeyboardCore visual-shadow 结构和 stable-prefix + dots 回归。
- L2 原子 handoff、快速 owner 抑制 transient L1、host 数字安全边界。
- Candidate/Correction/Space/cycle/page-down 代表性 fail-closed 行为。
- Abandon、既有 epoch/generation 与 gate-off 默认路径的自动化验证。
- KeyboardCore focused 15/0、full 857/0；RIME vendor structural verify；`git diff --check`。

### Failed / P1 blockers

- **无 P0/P1 blocker。** 旧 D2 “必须清空/禁用 chrome”的冲突已由 Product 选择
  Amendment B 正式改为“stable stale chrome + fail-closed action”，因此不再作为当前 P1。

### Skipped (scope / evidence boundary)

- 真实 librime Extension 接线、真实 RIME/Lua/OpenCC smoke。
- iOS Simulator `xcodebuild`、physical-device A/B、iOS 26.0/Release 验收。
- Extension jetsam、memory/queue stress、archive/dSYM、TestFlight/App Store release gates。
- Product Gate、ADR 0025 Accept、dual-gate Release default-on。

这些 skipped 项目不是本次 Amendment B 的失败，但在任何 R6/Release 任务中都必须重新建立当前
build/device provenance，不能复用本记录作为替代证据。

## Quality conclusion and handoff

**结论：Pass with conditions（bounded KeyboardCore Amendment B only）。** 当前实现和自动化
结果足以支持把 P1-D2 从“契约冲突”降为已选定、可继续独立审查的 Amendment；不支持宣布
工程全闭合、主观不卡顿、真实设备稳定、Product Gate、Release 或 ADR Accept。

建议下一步由独立 Architecture reviewer 核对 Amendment B 是否与 ADR 0025、R1 状态机、
epoch/revision 和 App/Extension 边界一致；随后由 Product Lead 决定是否接受上述 P2 回归债务，
或在进入 R6 前补齐 action/epoch/chrome 矩阵。dual-gate 必须继续 default-off。
