# KEYBOARD-LAYOUT-9KEY-PINYIN-004 — Codex 审查整改记录

**Date:** 2026-07-22 Asia/Shanghai  
**Executor:** Grok 4.5  
**Source conclusions:** [`keyboard-layout-9key-pinyin-004-codex-review-conclusions.md`](keyboard-layout-9key-pinyin-004-codex-review-conclusions.md)  
**Request:** 关闭 Blocker/High findings 后请求 **独立** 二次 Architecture + Quality 审查。  
**Follow-up (post 二审):** Product Lead 选定 **A-004-03 方案 1（严格 PD）**；并实现 A-004-04 单 snapshot 刷新 + Q-004-09 测例。见文末「三审前增量」。

## 定向矩阵复跑（整改后）

```bash
cd Packages/KeyboardCore
swift test --filter 'T9PinyinCatalogTests|T9PinyinCatalogControllerTests|T9HostPreeditSafetyTests|T9PinyinPathTests|KeyboardLayoutAndT9RuntimeTests|PartialCommitControllerTests'
```

| Suite | 结果（一审后整改） | 结果（二审后 PD 方案 1 + snapshot） |
|---|---|---|
| KeyboardLayoutAndT9RuntimeTests | 14/14 | 14/14 |
| PartialCommitControllerTests | 39/39 | **42/42**（+Q-004-09） |
| T9HostPreeditSafetyTests | 6/6 | 6/6 |
| T9PinyinCatalogControllerTests | 3/3 | 3/3 |
| T9PinyinCatalogTests | 8/8 | 8/8 |
| T9PinyinPathTests | 49/49 | 49/49 |
| **合计** | **119/119** | **122/122 PASS** |

## Findings 关闭状态

| ID | 原判定 | 整改 | 状态 |
|---|---|---|---|
| **Q-004-01** | High — 候选翻页清 checkpoint | `handleCandidatePageUp/Down` 在 partial 时只换候选页载荷、保留 remaining identity + checkpoint；可 `advanceCompositionRevision`；T9 同 raw 重算 Path | **Closed（自动化）** |
| **Q-004-02** | High — `xx` 进入 catalog | 生成器 v2 过滤 placeholder + 无元音 token；基线 **417**；测试断言无 `xx` | **Closed（自动化）** |
| **A-004-03** | High — letterPrefix 可推进 | `canConfirmAndAdvance` 仅 `completeSyllable`；单位 focus 键组字母发布为 **completeSyllable**（满槽选择，非多位前缀）；remap 保留 kind 并 restamp revision | **Closed（按 PD 解释单位 focus）** |
| **A-004-04** | High — 原子 snapshot / stale revision | `t9CompositionPresentationSnapshot()` 含 paths/candidates/visiblePreedit/IDs；UIKit Path Bar 消费 snapshot；Core 选择强制 `compositionRevision` 匹配；restore restamp | **Closed（核心合同）；UI 仍分栏读 candidates 需二次审查确认是否足够** |
| **A-004-05** | High — panel window 授权 | `t9PinyinPathWindow` **不再** `candidateWindow`/comment 发现；只切片当前 catalog compactPaths；`hasMoreCandidates=false` | **Closed（自动化语义）** |
| **A-004-06** | High — license | [`docs/architecture/t9-pinyin-syllable-catalog.md`](../architecture/t9-pinyin-syllable-catalog.md) 记录 LGPL-3.0 上游、hash、过滤策略；生成物 `sourceLicenseNote` | **Closed for review（需 Architecture 接受文档是否充分）** |
| **Q-004-07** | Medium — Scripts 大小写 | 规范为 `scripts/generate_t9_pinyin_syllable_catalog.py` | **Closed** |
| **A-004-08** | Medium — 44pt 命中 / layout | Path Bar `point(inside:)` 垂直扩展至约 44pt；保留 34pt 视觉高度 | **Mitigated** |

## 关键代码入口（二次审查）

1. `KeyboardController+Candidates.swift` — `applyPagedCandidateOutput` / `applyCandidatePageWhilePartialCommit`
2. `scripts/generate_t9_pinyin_syllable_catalog.py` + generated catalog
3. `KeyboardController+T9PinyinPath.swift` — `t9PinyinPathWindow`, `t9CompositionPresentationSnapshot`, select revision guard, remint helpers
4. `T9PinyinLocalPathCatalog.swift` — single-digit complete choices; catalogRank map
5. `KeyboardViewController+T9PinyinPath.swift` / `T9PinyinPathBarView.swift`
6. `docs/architecture/t9-pinyin-syllable-catalog.md`

## 仍未跑（不宣称关闭）

- RimeBridge pinned runtime Spike（`28/b8/cu/94→zi/qiu'53/qiul`）
- UIKit contract / Simulator 整包 / 全量 KeyboardCore
- Human Product Gate

## 请 Codex 二次审查回答

1. Architecture：上述关闭是否足以从 **Reject** 改为 **Accept / Accept-with-findings**？  
2. Quality：119 矩阵是否构成 **Automated Pass**？Q-004-01 是否还要补「普通/typo/T9 partial 翻页 + 继续输入失效 checkpoint」扩展用例？  
3. A-004-03 单位 focus = completeSyllable 的产品解释是否接受？  
4. A-004-04 是否仍要求 UIKit 候选栏也只读同一 snapshot 对象？  
5. 许可证文档是否关闭 Stop Condition？  
6. 是否允许进入 Human Product Gate？

**不得**由审查者宣布 Product Gate 通过。

---

## 三审前增量（二审后）

### Product Decision on A-004-03

Human Product Owner 选择 **方案 1：严格 PD-004**。

- 仅 catalog 合法音节为 `completeSyllable`（如 `o`/`a`/`e`/`bu`/`ni`）。
- 键组其它字母（`m`/`n`/`b`/`c`…）为 `letterPrefix`：只锁定、不确认、不推进。
- **不**引入 `completeFocusChoice`，**不**用 enum 伪装非音节字母。

### A-004-04 实现

- `shouldPublishAtomicT9Presentation` + `refreshT9PresentationFromCoreSnapshot()` / `applyT9PresentationSnapshot`。
- `syncUI` 在 T9 composition 时一次 snapshot 同时刷新 Path Bar、候选栏、扩展 Path panel。
- `resetCandidateSnapshot(from:)` 用 snapshot.candidates 与 `candidateSnapshotCompositionRevision`。
- `loadMoreCandidates` 丢弃 revision 不匹配的延迟 `candidateWindow` 结果。
- 26 键仍走原 `refreshCandidateBar` / `resetCandidateSnapshotFromController`。

### Q-004-09 测例

- `testCandidatePagingDuringNormalPartialCommitDoesNotInvalidateCheckpoint`
- `testCandidatePagingDuringT9PartialCommitKeepsPathsAndCheckpoint`
- `testTypingAfterCandidatePagingInvalidatesPartialCheckpoint`

### 请 Codex 三审

1. Architecture：A-004-03 / A-004-04 是否关闭？  
2. Quality：122 矩阵是否 Automated Pass？Q-004-09 是否足够？  
3. 是否允许进入 Human Product Gate？（审查者仍不得代填真机 Gate）

---

## 三审后：Gate 入口自动化补齐（2026-07-22）

三审要求先补 Bridge Spike 与 focused UI contract，再交 Human Gate。Executor 已补：

| 项 | 结果 | 文档 |
|---|---|---|
| Pinned Bridge baseline spike | PASS | [`keyboard-layout-9key-pinyin-004-bridge-spike-evidence.md`](keyboard-layout-9key-pinyin-004-bridge-spike-evidence.md) |
| 004 exact raws `28/b8/cu/94→zi/qiu'53/qiul` | PASS | same |
| Presentation/UI contracts (Core) | 4/4 PASS | [`keyboard-layout-9key-pinyin-004-ui-contract-evidence.md`](keyboard-layout-9key-pinyin-004-ui-contract-evidence.md) |
| Directed Core matrix | **126/126 PASS** | includes new contract tests |
| Snapshot paging metadata polish | done | `candidatePageNumber` / `hasMorePages` / `compositionPreedit` |
| Gate entry status | **ready for Human** (not claimed) | [`keyboard-layout-9key-pinyin-004-gate-entry-status.md`](keyboard-layout-9key-pinyin-004-gate-entry-status.md) |

**仍不得由 agent 宣布 Human Product Gate 通过。**
