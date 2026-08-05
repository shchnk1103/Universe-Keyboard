# Quality Re-review Addendum: T9-RESPONSIVE-PIPELINE-001 / P1-D2 Amendment B

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（独立、只读增量复审） |
| Review date | 2026-08-01 Asia/Shanghai |
| Assignment | [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md) |
| Previous review | [`P1-D2 Amendment B Quality review`](t9-responsive-pipeline-001-p1-d2-amendment-b-quality-review.md) |
| Design authority | [ADR 0025 Proposed Amendment B](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md#13-proposed-amendment-b--p1-d2-visual-shadow-anchor-and-stable-stale-chrome) |
| Repository tip | `HEAD 3585a54` + 当前工作树未提交变更（无 release artifact） |
| Verdict | **Pass with conditions**：仅适用于 bounded KeyboardCore Amendment B；不构成 Architecture Accept、Product Gate、Release 或 default-on 证据 |
| P0 / P1 / P2 / P3 | **0 / 0 / 4 / 0** |

## 1. 复审边界与独立性

本次只读复审重新检查原 Quality review 提出的风险，以及两项已声明的 P1 修复：

1. Candidate prefetch 在 `provisionalAhead` 时不得绕过 fail-closed 入口；
2. ordered Delete 在下一枚键的 L1 之前必须捕获最新稳定 host snapshot。

本角色没有修改生产代码、测试或原 Quality review；只新增本 addendum。复审结论是
Quality 角色在 bounded slice 上的独立判断，不替代 Architecture 角色对完整 D3
ordered-Delete API surface 的判定。当前 Architecture 增量复审仍把未覆盖的 Delete/
restore 分支列为 residual，不能由本记录关闭。

## 2. Independent evidence

复审时工作树为 `main...origin/main`，包含 Executor/Architecture 预期的未提交改动。
`git diff --check` **通过**；RIME vendor structural verify **通过**（11 个 framework
artifact）。

在当前 `HEAD + working-tree diff` 上独立执行：

```text
mkdir -p /private/tmp/universe-keyboard-clang-cache \
  /private/tmp/universe-keyboard-swift-cache

CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-clang-cache \
SWIFT_MODULECACHE_PATH=/private/tmp/universe-keyboard-swift-cache \
swift test --package-path Packages/KeyboardCore \
  --filter 'ResponsiveProvisionalCompositionTests|ResponsiveProvisionalL1WireTests'
→ Executed 16 tests, with 0 failures (45.118s)

CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-clang-cache \
SWIFT_MODULECACHE_PATH=/private/tmp/universe-keyboard-swift-cache \
swift test --package-path Packages/KeyboardCore
→ Executed 858 tests, with 0 failures (50.395s)

bash scripts/ensure_rime_vendor.sh verify
→ Verified structural inventory of 11 RIME framework artifacts
```

缓存目录只用于绕过本机受限的 Swift/Clang 默认 cache，不改变测试输入、生产代码或
运行时隔离边界。

## 3. P1 修复复核

### P1-1：candidate prefetch 绕过 fail-closed — bounded path confirmed

`Keyboard/Controllers/KeyboardViewController+CandidatePaging.swift` 的
`loadMoreCandidates` 现在在读取 `rimeEngine`、计算窗口之前执行
`guard !controller.isResponsiveProvisionalAhead else { return }`。bar/expanded 的
scheduled/deferred prefetch 最终都回到这个入口，因此在 ahead 时不会由该入口调用
`candidateWindow` 或触发 thread-affine owner flush。

修复方向和 Core 的候选选择、分页、纠错 guard 一致。当前没有 UI 层专项测试直接证明
“ahead + prefetch 不等待、不入队、不改变候选 snapshot”，所以逻辑修复确认，但回归
覆盖仍记为 P2。

### P1-2：ordered Delete 后 stable shadow — standard path confirmed

`alignResponsiveProvisionalAfterOrderedEngineApply()` 现在先执行
`setStablePreedit(state.insertedPreeditText)`，再 `clearPending()`。这保证 ordered
输出已经回到 host、但异步 publish callback 尚未到达 MainActor 的间隙，下一枚键的
L1 dots 使用最新稳定前缀。

新增的
`testOrderedDeleteRefreshesStableShadowBeforeNextPendingKey` 通过了：它在 Delete
完成后、延迟 publish 尚未运行时按下下一枚键，并断言 host marked text 为
`stableAfterDelete + "·"`，没有把旧前缀重新拼回去。

该证据关闭的是本测试覆盖的普通 engine-composing Delete 路径；它不宣称所有
Delete/restore/partial-commit 分支均已满足 D3。Architecture addendum 中列出的完整
ordered-Delete residual 仍需由 Architecture/Executor 单独处理。

## 4. Evidence matrix

| Contract / case | Result | Evidence / limitation |
|---|---|---|
| 稳定 L2 文本 + pending dots | **Passed** | 稳定前缀与 `·` 测试检查 host history。 |
| 无稳定前缀 | **Passed** | L1 只产生 `·×N`，不泄漏 T9 数字。 |
| L2 原子替换 | **Passed** | 稳定前缀测试断言 `[L2, L2+·, final L2]`；快速 owner 不留下 transient dot。 |
| Candidate prefetch fail-closed | **Passed with P2 coverage gap** | 入口 guard 已在 `candidateWindow` 前；缺少 UI 调用层 no-op/owner-depth 回归。 |
| Candidate / Correction / Path / Space / paging | **Passed with P2 coverage gap** | 代表性 Candidate、Correction、cycle、Space、page-down 通过；direct Path、page-up、各 `CandidateKind` 矩阵未完全建立。 |
| Partial Commit 组合 | **Passed with P2 coverage gap** | 入口 guard 在 partial-selection 前；尚无带 partial state 的独立 UI 回归。 |
| ordered Delete → next key | **Passed (bounded)** | 新增 Delete→next-key 测试通过；其它 Delete/restore 分支仍是 Architecture residual。 |
| Epoch / abandon | **Passed with P2 coverage gap** | ledger/state 和 coalesced presentation 清理通过；缺少延迟 L1 task 不再写 `markedTextHistory` 的直接断言。 |
| Stable stale chrome | **Passed with P2 coverage gap** | callback 不增加已验证；缺少 Candidate/Path snapshot 前后相等及 stale tap no-op 的直接断言。 |
| Gate-off 默认与同步等价 | **Passed** | gate-off 与既有 synchronous tests 通过；dual-gate 仍 default-off。 |
| 内部 T9 数字不进入 host | **Passed** | marked-text history/final text 未出现 ASCII digits。 |
| 真实性能与发布 | **Skipped — scope boundary** | Fake owner 与 16/0、858/0 不代表 real librime latency、主观不卡顿、jetsam 或 Release。 |

## 5. Findings

### P2-D2-RR1 — prefetch guard 缺少 UI 级回归

实现已堵住 `loadMoreCandidates` 的直接绕行，但尚无测试在
`provisionalAhead` 时调用 bar/expanded prefetch，并观测 `candidateWindow` 未被调用、
owner pending depth 未被刷新、candidate snapshot 未被修改。建议在 UI/Core 可观测
测试层补齐；这属于回归敏感度债务，不是当前代码层 P1 blocker。

### P2-D2-RR2 — fail-closed 与 stale chrome action matrix 不完整

共同 guard 的方向正确，但 direct Path tap、page-up、每个 `CandidateKind`、带
Partial Commit 的组合尚未逐项覆盖；也没有直接比较 L1 前后的 Candidate/Path snapshot
相等，或 stale tap 前后 snapshot/engine call 不变。后续 UI 接线变化可能绕过现有
代表性测试而不被捕获。

### P2-D2-RR3 — epoch/abandon 对 host history 的证明不完整

现有测试证明 ledger/state 会清空、旧 coalesced presentation 不会恢复 composition，
但未直接证明已经排队的延迟 L1 paint 在 abandon/epoch barrier 后不会再次调用
`setMarkedText`。建议用 `FakeTextInputClient.markedTextHistory` 增加一条专门回归。

### P2-D2-RR4 — 真实性能与发布证据仍未建立

本次 Fake owner 测试证明顺序、隔离和 fail-closed 行为，不提供真实 librime/Lua 的
延迟分布、Extension 主观不卡顿、队列深度、内存/jetsam、iOS 26.0 Release 或
archive/dSYM 证据。48 ms Debug delay 不是产品 SLO；这些验证超出本 Amendment 授权。

## 6. Passed / Failed / Skipped

### Passed

- P1-1 prefetch guard 的 bounded 代码路径审查。
- P1-2 普通 ordered engine-composing Delete→next-key 的 stable-shadow 回归。
- visual shadow、稳定前缀 + dots、L2 原子 handoff、快速 owner 抑制 transient L1。
- Candidate/Correction/Space/cycle/page-down 代表性 fail-closed、abandon/epoch、
  gate-off、host 数字安全边界。
- KeyboardCore focused **16/0**、full **858/0**、RIME vendor verify、`git diff --check`。

### Failed / P1 blockers

- **无 P0/P1 blocker（Quality bounded slice）。**
- 本结论不关闭 Architecture 对完整 D3 ordered-Delete/restore surface 的 residual，
  也不把测试通过升级为 Product Gate 或 Release 结论。

### Skipped（scope / evidence boundary）

- 真实 librime Extension 接线、真实 RIME/Lua/OpenCC smoke。
- iOS Simulator `xcodebuild`、physical-device A/B、iOS 26.0/Release 验收。
- Extension jetsam、memory/queue stress、archive/dSYM、TestFlight/App Store gates。
- Product Gate、ADR 0025 Accept、dual-gate Release default-on。

## 7. Quality conclusion and handoff

**结论：Pass with conditions（仅 bounded KeyboardCore Amendment B）。** 当前实现和
独立自动化结果足以确认两项声明修复在其覆盖路径上生效，并支持继续进行独立
Architecture/Executor 处理；不支持宣布工程全闭合、主观不卡顿、真实设备稳定、
Product Gate、Release 或 ADR Accept。

建议：

1. Architecture 继续按其 addendum 处理完整 D3 ordered-Delete/restore residual，
   不用本 Quality 记录替代 Architecture verdict；
2. 在进入 R6 前由 Product Lead 决定是否接受四项 P2 回归债务，或先补齐 action、
   prefetch、epoch/history、stale-chrome 矩阵；
3. dual-gate 保持 default-off，任何 real-librime/真机/Release 接线需另行授权并建立
   新的 provenance 与 acceptance matrix。
