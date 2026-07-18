# KEYBOARD-LAYOUT-9KEY-PINYIN-001 Codex 第四次独立复审

- 复审日期：`2026-07-18 Asia/Shanghai`
- 复审角色：Architecture & Knowledge Steward；Quality, Performance & Release
- 分支：`feature/keyboard-layout-9key-pinyin-001`
- HEAD：`44d42130bd8e2012bce7b4c034c4bc51a149dec3`
- 对象：上述 HEAD 上的当前未提交工作区
- 输入 handoff：`docs/assignments/keyboard-layout-9key-pinyin-001-grok-fix-handoff-4.md`
- Architecture：**Fail / Changes Required**
- Quality：**Fail / Changes Required**
- Publication：**Not Ready**
- Product Gate：**Open；Human Dependency 未满足**

## 1. 独立性与权威

本复审重新读取仓库协作规则、Knowledge Index、Assignment、Product Decision、ADR 0020、前次独立 review、handoff 4、相关实现和测试。handoff 仅提供待核 claims 与定位入口；聊天和 handoff 中的结论、测试计数与完成声明均不作为权威。本记录依据当前工作区静态审查和本次独立执行结果。

## 2. Executive conclusion

handoff 4 已正确实现上一轮要求的基础机制：`rawInputGeneration` 与 `provenanceRevision` 已分离；expanded panel、lazy window 和点击 stale guard 均改为绑定 provenance revision；明确的 soft refresh 会保留同 snapshot 的后置 window issuance；明确的 hard rebuild 会 bump revision 并丢弃旧 issued keys。两个新增 Core 测试分别证明了这两种机制。

但 Architecture 与 Quality 仍不能通过。实现并没有可靠判断“当前 RIME output 是否仍属于同一个 comment snapshot”。`hardProvenance` 只由 raw 变化或调用方显式传入 `forceNewProvenance` 决定；通用 `applyRimeOutput`、partial candidate selection 等真实新 RIME output 路径仍调用默认 soft refresh。若 raw 相同而 candidates/comments 已变化，旧 issued keys 只经过 T9 compatibility 过滤，仍会留在当前 revision，重新造成 stale comment provenance。

换言之，revision 数据结构已经存在，但 revision 的推进条件仍以 raw identity 代替实际 snapshot 边界。handoff 4 的 residual risk 不是短暂展示问题：当前代码没有保证之后一定发生 hard rebuild，旧授权可以持续到 raw、页面或 rollback 等其他事件改变状态。

## 3. Blocking finding

### [P1] 新 RIME output 在 same raw 下仍走 soft refresh，provenance revision 不代表真实 snapshot

证据链：

- `refreshT9PinyinPathState` 仅在 `forceNewProvenance == true` 或 raw identity 变化时把 refresh 视为 hard provenance transition（`KeyboardController+T9PinyinPath.swift:196-218`）。
- soft 分支保留全部仍与 raw 位置兼容的 `previousIssued`（`:220-233`）。Compatibility 只能证明 `ni` 与 `64` 的键位关系，不能证明 `ni` 仍存在于当前 RIME comments。
- `applyRimeOutputWithoutPartialCommit` 接收到新的 RIME output 后覆盖 `state.lastRimeOutput`，却调用默认 `refreshT9PinyinPathState()`（`KeyboardController+PartialCommit.swift:437-460`）。当新 output raw 仍为 `64`、comments 从 `ni/mi` 变为仅 `mi` 时，revision 不变且旧 `ni` 继续 issued。
- partial candidate selection 在 result 仍有 raw 时同样调用默认 soft refresh（`KeyboardController+Candidates.swift:60-67`），尽管 `selectionResultChanged` 明确允许 candidates、composition、page 或 highlight 改变而 raw 不变。
- 新增 hard test 是直接调用 `refreshT9PinyinPathState(forceNewProvenance: true)`（`T9PinyinPathTests.swift:509-563`）。它证明 hard mechanism 正确，但没有证明生产调用链会在 same-raw new-output 时选择 hard transition。

可复现状态序列：

1. 当前 raw 为 `64`，完整面板已从旧 live snapshot 签发 `ni` 和 `mi`。
2. RIME 返回一个新的 usable output：raw 仍为 `64`，当前 comments 只剩 `mi`。
3. 通用 output apply 或 partial selection 调用默认 soft refresh。
4. `provenanceRevision` 不变；`ni` 因仍兼容 `64` 而保留在 `issuedReplacementKeys`。
5. Core 仍接受裸 `ni` path 并调用 `replaceInput("ni")`，违反 comment-only provenance。

影响：

- 违反 Product Decision §2 与 ADR 0020 §3：路径必须来自当前 RIME candidate comments，而不是来自某个相同 raw 的历史 snapshot。
- UIKit 看到 revision 未变，会合理地认为 accumulated paths 仍受当前 Core authority 支持；跨层 guard 无法发现错误。
- stale authorization 没有确定的自动失效时间，不能作为短暂或仅视觉风险接受。

Required change：

- 让“应用新的 RIME output”和“仅重新渲染/重复扫描同一 stored output”成为不同的显式 API/事件，而不是靠默认布尔值和 raw equality 推断。
- 每次应用可能改变 candidates/comments 的新 RIME output，即使 raw 相同，也必须开启新的 provenance revision、从 live scan 重建 issued set，并使 UIKit panel 重建或关闭。
- soft refresh 只允许用于已确认仍是同一 stored/live snapshot 的 UI/window refresh；同 revision 内继续累积后置 window issuance。
- 增加生产调用链测试，而不只直接测试 helper：先签发 `ni/mi`，再通过 `applyRimeOutput` 或 partial candidate selection 注入 same-raw、仅 `mi` 的新 output；断言 revision bump、`ni` 被撤权、panel/window token stale、`mi` 仍可选。

### [P2] Accepted ADR 与领域文档尚未记录双 revision 合同

- ADR 0020 仍将 `T9PinyinPathState` 描述为 compact paths、selected path 和 raw-input generation，并称 lazy window 为 generation-guarded（`0020-t9-precise-pinyin-path-selection.md:87-96`、`:132`）。
- `KEYBOARD_LAYOUT.md:63` 同样只记录 generation-guarded windows。
- `provenanceRevision` 已成为 Core/UI stale guard 的架构合同，而非局部实现细节。代码边界稳定后，应更新 ADR 0020 和领域文档，明确 raw lifecycle generation 与 comment provenance revision 的不同失效条件。

## 4. 上一轮 P1 复核

| 上一轮 finding | 本次判定 |
|---|---|
| raw generation 与 provenance snapshot revision 未分离 | **数据模型与 UIKit 绑定已修复** |
| same-snapshot expanded issuance 被 soft refresh 撤销 | **已修复**：后置路径 soft refresh 后仍 issued 且可选 |
| hard snapshot transition 应撤销旧 issued keys | **helper 机制已修复**；生产 new-output transition 选择仍不完整，见本次 P1 |
| panel 在 provenance 变化时重建 | **已修复（静态）** |

## 5. 独立验证

| 验证 | 本次结果 | 说明 |
|---|---|---|
| `swift test --package-path Packages/KeyboardCore --filter T9PinyinPathTests` | **PASS — 20 tests, 0 failures** | 缺少 same-raw new-output 的生产调用链负例 |
| `swift test --package-path Packages/KeyboardCore` | **PASS — 614 tests, 0 failures** | 独立运行，约 3.4 秒 |
| KeyboardTests / iPhone 17 Pro Max Simulator 27.0 | **PASS — 6 tests, 0 failures** | xcresult summary；无 hosted panel revision interaction test |
| Debug strict generic Simulator build | **PASS / exit 0** | complete concurrency + Swift/C warnings-as-errors；仍有既知 Boost x86_64 linker warnings |
| Release strict generic Simulator build | **PASS / exit 0** | 同上；不能声明全构建零 warning |
| RimeBridgeTests `build-for-testing` | **PASS / exit 0** | Simulator target 可编译；本轮未运行 real fixture Spike |
| `git diff --check` | **PASS for tracked diff** | 新功能多数文件仍 untracked；相关 Swift 文件 trailing-whitespace 扫描亦无结果 |
| clean-commit Spike archive | **未执行** | 无 commit / publication 授权 |
| physical-device interaction / latency / VoiceOver | **未执行** | Human Dependency 未满足；Product Gate 保持 Open |

## 6. Architecture boundary judgement

| Boundary | Result |
|---|---|
| Raw generation 与 provenance revision 数据模型分离 | Pass |
| UIKit panel/window/click 使用 provenance revision | Pass（静态） |
| 同 snapshot expanded issuance 生命周期 | Pass |
| 新 RIME comment snapshot 自动推进 revision | **Fail** |
| Current-comment-only Core authorization | **Fail**：same-raw new output 可保留 stale issued key |
| Rollback/page hard rebuild | Pass |
| Exact usable refinement / no raw host commit | Pass |
| RIME deploy/vendor boundary | Pass；未见 Extension deploy、schema mutation 或 vendor change |
| ADR/领域文档反映双 revision 架构 | **Partial / P2** |
| Hosted UI、VoiceOver、真机 latency | Open；Product Gate evidence 未完成 |

## 7. Gate decision and handoff

- Architecture：**Fail / Changes Required**。
- Quality：**Fail / Changes Required**。
- Assignment 保持 `Active`；不得标记 `Completed`、`Reviewed` 或 `Closed`。
- Publication：**Not Ready**；本次复审不授权 commit、push 或 PR。
- Product Gate：保持 **Open**。代码复审通过后仍需 clean evidence、hosted UI/VoiceOver 及真机 interaction/lifecycle/latency matrix。

下一 handoff 回到 Grok Executor。修复应聚焦 new-RIME-output 与 same-snapshot refresh 的显式边界、生产调用链测试，以及 ADR/领域文档同步；不要移除双 revision，也不要恢复跨 snapshot 无条件继承 issued keys。Codex 本次未修改实现代码。
