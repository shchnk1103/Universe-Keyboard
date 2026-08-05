# Quality Re-review 2: T9-RESPONSIVE-PIPELINE-001 / P1-D2 Amendment B

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（独立、只读增量复审） |
| Review date | 2026-08-01 Asia/Shanghai |
| Assignment | [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md) |
| Previous review | [`Quality re-review 1`](t9-responsive-pipeline-001-p1-d2-amendment-b-quality-rereview.md) |
| Design authority | [ADR 0025 Proposed Amendment B](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md#13-proposed-amendment-b--p1-d2-visual-shadow-anchor-and-stable-stale-chrome) |
| Repository tip | `HEAD 3585a54` + 当前工作树最新未提交变更（无 release artifact） |
| Verdict | **Pass with conditions**：仅适用于 bounded KeyboardCore Amendment B；不构成 Architecture Accept、Product Gate、Release 或 default-on 证据 |
| P0 / P1 / P2 / P3 | **0 / 0 / 4 / 0** |

## 1. 复审边界与独立性

本次复审针对上一轮之后的统一修复：

- 新增 `captureResponsiveStablePreeditIfReady`，并在 `@MainActor` 的
  `updateInlinePreedit`、`clearInlinePreedit`、`commitInlinePreedit` 和 presentation
  出口统一捕获安全的稳定 host preedit；
- `applyRimeOutputPreservingPartialCommit` 使用 `defer` 在 engine output 已安装后
  再捕获；
- `alignResponsiveProvisionalAfterOrderedEngineApply` 改为先 `clearPending()`，再
  捕获当前安全快照。

本角色只做 Quality/Performance/Release 视角的代码审计与回归复核，没有修改生产代码、
测试或旧 review，只新增本 addendum。它不替代 Architecture 角色对 ADR 0025、D3
ordered-Delete/restore API surface 的结论；旧 Architecture addendum 若仍引用修复前
顺序，必须由 Architecture 在当前工作树上另行更新，不能由本记录自动接受。

## 2. Independent evidence

复审时工作树为 `main...origin/main`，包含 Executor 最新未提交改动。`git diff --check`
通过；`bash scripts/ensure_rime_vendor.sh verify` 通过，验证了 11 个 RIME framework
artifact 的结构清单。

本角色在当前 `HEAD + working-tree diff` 上独立执行：

```text
mkdir -p /private/tmp/universe-keyboard-clang-cache-final \
  /private/tmp/universe-keyboard-swift-cache-final

CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-clang-cache-final \
SWIFT_MODULECACHE_PATH=/private/tmp/universe-keyboard-swift-cache-final \
swift test --package-path Packages/KeyboardCore \
  --filter 'ResponsiveProvisionalCompositionTests|ResponsiveProvisionalL1WireTests'
→ Executed 16 tests, with 0 failures (45.136s)

CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-clang-cache-final \
SWIFT_MODULECACHE_PATH=/private/tmp/universe-keyboard-swift-cache-final \
swift test --package-path Packages/KeyboardCore
→ Executed 858 tests, with 0 failures (50.497s)

bash scripts/ensure_rime_vendor.sh verify
→ Verified structural inventory of 11 RIME framework artifacts
```

测试使用独立 `/private/tmp` cache，只是绕过本机默认 Swift/Clang cache 的沙箱限制，未
改变测试输入、生产代码或线程隔离边界。

## 3. Final repair audit

### P1-D2 ordered stable shadow — code-level closure confirmed

`KeyboardController` 是 `@MainActor`，统一 helper 只在 MainActor 观察并写入
`ResponsiveProvisionalCompositionMirror.stablePreedit`。当前代码审计确认：

1. 所有 host marked-text 出口（更新、清空、提交）都会在 state 与 host 投影同步后
   尝试捕获稳定前缀；L1 ahead 时 helper fail-closed，不会把 `·` 自己当成稳定前缀；
2. `applyRimeOutputPreservingPartialCommit` 的 `defer` 覆盖 Delete、partial restore、
   Path recovery、auto-anchor rollback 以及普通 RIME output apply 的共同完成边界，
   在输出 state/host projection 安装完成后刷新 stable shadow；
3. ordered 对齐先 `clearPending()`，再捕获当前安全快照，随后由 engine-output
   completion 的 `defer` 再次覆盖为最终 output；因此 callback 尚未回到 MainActor 时，
   下一枚键不会继续使用旧 stable prefix；
4. Candidate prefetch 仍在读取 `rimeEngine` / `candidateWindow` 前检查
   `!controller.isResponsiveProvisionalAhead`，没有撤回上一轮 fail-closed 修复。

新增的 Delete→next-key 回归，以及 focused/full 全量回归均通过。Quality 视角不再发现
上一轮的 P1 级 stale stable-shadow 缺口；但逐分支 host-history 回归仍列为 P2 覆盖债务，
不把代码级 closure 扩大成真实 RIME 或设备证据。

## 4. Evidence matrix

| Contract / case | Result | Evidence / limitation |
|---|---|---|
| 稳定 L2 文本 + pending dots | **Passed** | host history 验证稳定文本后只追加 `·`，没有回退旧前缀。 |
| 无稳定前缀 | **Passed** | L1 产生 `·×N`，不泄漏 T9 内部数字。 |
| L2 原子替换 | **Passed** | focused wire tests 验证稳定文本、临时 dots、最终 L2 的顺序；快速 owner 不留下临时 `·`。 |
| ordered Delete → next key | **Passed (code-level bounded closure)** | 新增回归通过；统一 output `defer` 覆盖共同 engine apply 边界，逐个 restore/anchor 分支仍缺专门 history 矩阵。 |
| Candidate prefetch fail-closed | **Passed with P2 coverage gap** | `loadMoreCandidates` guard 位于 `candidateWindow` 前；没有 Extension/UI 层 no-op 与 owner-depth 断言。 |
| Candidate / Correction / Path / Space / paging | **Passed with P2 coverage gap** | 代表性 Candidate、Correction、cycle、Space、page-down 通过；direct Path、page-up、各 `CandidateKind` 组合未完全覆盖。 |
| Partial Commit 组合 | **Passed with P2 coverage gap** | 共同入口已保护；尚无带 partial state 的逐动作回归矩阵。 |
| Epoch / abandon | **Passed with P2 coverage gap** | ledger/state 与 coalesced presentation 清理通过；缺少延迟 L1 task 不再写 host history 的直接断言。 |
| Stable stale chrome | **Passed with P2 coverage gap** | L1 不触发 Extension presentation callback 已验证；缺少 Candidate/Path snapshot 相等及 stale tap no-op 的直接断言。 |
| Gate-off 默认与同步等价 | **Passed** | gate-off tests 与既有同步路径通过；dual-gate 仍 default-off。 |
| 内部 T9 数字不进入 host | **Passed** | marked-text history/final text 未出现 ASCII digits。 |
| 真实性能与发布 | **Skipped — scope boundary** | Fake owner 与 KeyboardCore 通过不等同于 real librime、主观不卡顿、jetsam 或 Release。 |

## 5. Residual P2

### P2-D2-RR2-1 — prefetch UI no-op 证据不足

代码已堵住 `loadMoreCandidates` 的直接绕行，但没有在 `provisionalAhead` 时从 bar /
expanded UI 调用 prefetch，并观察 `candidateWindow` 未调用、owner pending depth 未被
刷新、candidate snapshot 未改变。建议在 UI/Core 可观测层补充。

### P2-D2-RR2-2 — ordered-output 分支与 fail-closed/stale chrome 矩阵不完整

统一 `defer` 已将 stable capture 放到共同 engine-output 完成边界，降低了分支遗漏风险；
但尚无 Delete/restore/auto-anchor/partial-commit 各分支的独立 host-history 回归，也没有
逐项覆盖 direct Path、page-up、各 `CandidateKind`、带 Partial Commit 的 stale action，
或比较 L1 前后的 Candidate/Path snapshot 是否严格不变。该项是测试敏感度债务，不是
当前代码审计发现的 P1 blocker。

### P2-D2-RR2-3 — epoch/abandon 对延迟 host 写入的证明不完整

已有测试证明 ledger/state 清空且旧 coalesced presentation 不恢复 composition；仍需用
`FakeTextInputClient.markedTextHistory` 直接证明 abandon/epoch barrier 后，已排队的延迟
L1 task 不会再次调用 `setMarkedText`。

### P2-D2-RR2-4 — 真实性能与发布证据仍未建立

16/0、858/0 与 Fake owner 只证明行为顺序、隔离和 fail-closed；不提供真实 librime/Lua
延迟分布、Extension 主观不卡顿、队列深度、内存/jetsam、iOS 26.0 Release、archive/dSYM
或 TestFlight/App Store 证据。48 ms Debug delay 不是产品 SLO；这些验证超出本 Amendment
授权。

## 6. Passed / Failed / Skipped

### Passed

- 统一 stable capture 与 ordered engine-output completion 的代码审计；上一轮普通
  Delete stale-prefix P1 风险在 bounded 路径上已消除。
- visual shadow、稳定前缀 + dots、L2 原子 handoff、快速 owner 抑制 transient L1。
- Candidate/Correction/Space/cycle/page-down 代表性 fail-closed、abandon/epoch、
  gate-off 与 host 数字安全边界。
- 独立 focused **16/0**、KeyboardCore 全量 **858/0**、RIME vendor verify、
  `git diff --check`。

### Failed / P1 blockers

- **无 Quality 视角的 P0/P1 blocker。**
- 这不替代 Architecture 对最新 helper 的独立复审，也不把测试结果升级为 ADR Accept、
  Product Gate 或 Release 结论。

### Skipped（scope / evidence boundary）

- 真实 librime Extension 接线、RIME/Lua/OpenCC smoke、iOS Simulator `xcodebuild`。
- physical-device A/B、iOS 26.0/Release 验收、Extension jetsam、memory/queue stress。
- archive/dSYM、TestFlight/App Store gates、Product Gate、ADR 0025 Accept、dual-gate
  Release default-on。

## 7. Quality conclusion and handoff

**结论：Pass with conditions（仅 bounded KeyboardCore Amendment B）。** 本次统一修复
在代码结构上消除了上一轮 P1 的共同边界遗漏，且当前 focused/full 回归均为 0 failure；
但仍不能宣布工程全闭合、主观不卡顿、真实设备稳定、Product Gate、Release 或 ADR Accept。

下一步交接：

1. 由独立 Architecture reviewer 基于当前最新工作树重新确认统一 `defer` 是否满足完整
   D3 ordered-Delete/restore 合同，并更新其旧 addendum 的状态；
2. Product Lead 决定是否接受四项 P2 回归债务，或在 R6 前补齐 prefetch、action/chrome、
   epoch/history 及真实性能矩阵；
3. dual-gate 继续保持 default-off。任何真实 librime、真机或 Release 接线都必须另行
   授权，并建立新的 build/device provenance 与 acceptance matrix。
