# KEYBOARD-LAYOUT-9KEY-PINYIN-001 — Grok Fix Handoff 4 (Codex rereview-3 P1)

Prepared by: Grok（Executor / Input Intelligence Maintainer）  
Handoff target: **Codex Architecture + Quality re-review**  
Date / timezone: `2026-07-18 Asia/Shanghai`  
Branch: `feature/keyboard-layout-9key-pinyin-001`  
HEAD (baseline under dirty worktree): `44d42130bd8e2012bce7b4c034c4bc51a149dec3`  
Source review: [`keyboard-layout-9key-pinyin-001-codex-rereview-3.md`](keyboard-layout-9key-pinyin-001-codex-rereview-3.md)

> Conversation is not authority. Assignment remains **`Active`**.  
> Executor does **not** declare Architecture Pass, Quality Pass, Product Gate, Reviewed, or Closed.  
> No commit / push / PR.

---

## 1. Finding matrix (single blocking P1)

### [P1] same-raw refresh 撤销后置路径，但 UI generation 不失效

| Field | Content |
|---|---|
| **P1 finding** | `refresh` 清空 issued 后只重建 page+16；expanded window 签发的路径被撤权；`rawInputGeneration` 不变导致 UI 仍展示旧 accumulated paths；点击静默失败。 |
| **根因** | 把 raw-input generation 与 comment/window provenance 当成同一版本；硬清 issued 与 soft same-raw refresh 未分离。 |
| **修改文件** | `T9PinyinPath.swift`（`provenanceRevision`）；`KeyboardController+T9PinyinPath.swift`；`KeyboardViewController+T9PinyinPath.swift`；`KeyboardViewController+CandidateDataSource.swift`；`KeyboardViewController+Presentation.swift`；`T9PinyinPathTests.swift` |
| **实际修复** | 1) 新增独立 **`provenanceRevision`**。2) soft refresh（same raw）：保留仍兼容的 expanded issued keys，再 union live page/hot-path；**不** bump provenance。3) hard rebuild（`forceNewProvenance` / raw 变化 / usable rollback / page rebuild）：bump provenance，issued 仅从 live 扫描重建。4) UIKit 面板绑定 **provenanceRevision**；revision 变化时重建 accumulated paths。5) **不**永久继承跨 snapshot 的旧 issued set。 |
| **新增/强化测试** | `testDiscoveryPendingWhenValidPathPastHotPathPeek`：window 签发后 soft refresh 仍 issued 且可选。`testHardProvenanceRefreshDropsExpandedKeysNotInLiveScan`：hard rebuild 丢弃非 live 的 ni。 |
| **Command** | `cd Packages/KeyboardCore && swift test --filter T9PinyinPathTests` |
| **Result** | **PASS — 20 tests, 0 failures** |
| **Full suite** | `swift test` → **PASS — 614 tests, 0 failures** |

---

## 2. Aggregated verification

| Check | Exact command | Exact result |
|---|---|---|
| Path tests | `swift test --filter T9PinyinPathTests` | **PASS — 20 / 0 failures** |
| KeyboardCore full | `swift test` (package) | **PASS — 614 / 0 failures** |
| `git diff --check` | `git diff --check` | **PASS** (exit 0) |
| App Debug strict | `xcodebuild build -scheme "Universe Keyboard" Debug … SWIFT_STRICT_CONCURRENCY=complete` | **BUILD SUCCEEDED** |
| App Release strict | same Release | **BUILD SUCCEEDED** |
| Keyboard Debug strict | `xcodebuild build -scheme Keyboard …` | **BUILD SUCCEEDED** |
| Real Spike / device | — | **Not executed** |

---

## 3. Not executed

1. Clean-commit Spike archive  
2. Physical-device Product Gate / VoiceOver / latency  
3. Hosted UIViewController panel interaction tests  
4. Architecture/Quality Gate 结论  
5. commit / push / PR / Closed  

---

## 4. Git / workspace

```text
Branch: feature/keyboard-layout-9key-pinyin-001
HEAD:   44d4213
Status: dirty worktree (~47 short-status lines; implementation uncommitted)
Commit/push/PR: NOT performed
```

---

## 5. Residual risks

1. Soft refresh 用 compatibility 过滤保留 issued keys；若 comment 语义变化但仍兼容，可能短暂保留直到 hard rebuild。  
2. Panel auto-advance / scroll 仍缺 hosted UI 自动化。  
3. Product Gate 与 clean Spike 仍开放。  

---

## 6. Next handoff target

**Codex — Architecture + Quality re-review** against this handoff + `keyboard-layout-9key-pinyin-001-codex-rereview-3.md` + current dirty tree.

**Executor stops here.**
