# KEYBOARD-LAYOUT-9KEY-PINYIN-001 — Grok Fix Handoff 5 (Codex rereview-4 P1/P2)

Prepared by: Grok（Executor / Input Intelligence Maintainer）  
Handoff target: **Codex Architecture + Quality re-review**  
Date / timezone: `2026-07-18 Asia/Shanghai`  
Branch: `feature/keyboard-layout-9key-pinyin-001`  
HEAD (baseline under dirty worktree): `44d42130bd8e2012bce7b4c034c4bc51a149dec3`  
Source review: [`keyboard-layout-9key-pinyin-001-codex-rereview-4.md`](keyboard-layout-9key-pinyin-001-codex-rereview-4.md)

> Conversation is not authority. Assignment remains **`Active`**.  
> Executor does **not** declare Architecture Pass, Quality Pass, Product Gate, Reviewed, or Closed.  
> No commit / push / PR.

---

## 1. Finding matrix

### [P1] 新 RIME output 在 same raw 下仍走 soft refresh，provenance 不代表真实 snapshot

| Field | Content |
|---|---|
| **P1 finding** | `hardProvenance` 仅由 raw 变化或显式 `forceNewProvenance` 决定；`applyRimeOutput` / partial selection 默认 soft。same-raw 下 comments 从 `ni/mi` → 仅 `mi` 时 revision 不变，`ni` 仍 issued。 |
| **根因** | 把「应用新 RimeOutput」与「同 snapshot 再扫描」共用 soft 默认；revision 推进条件以 raw identity 代替 comment snapshot 边界。 |
| **修改文件** | `KeyboardController+T9PinyinPath.swift`；`KeyboardController+PartialCommit.swift`；`KeyboardController+Candidates.swift`；`T9PinyinPathTests.swift`；`FakeRimeEngine.swift`（测试用 dict/comments 可变） |
| **实际修复** | 1) 显式 API：`applyT9PinyinPathStateFromNewRimeOutput()` = 始终 hard provenance；`refreshT9PinyinPathStateForSameSnapshot()` = soft 同 snapshot。2) `applyRimeOutputWithoutPartialCommit` 安装新 output 后调用 **hard** API。3) partial candidate selection 保留 raw 时调用 **hard** API。4) partial-commit 保留 remaining composition 时 T9 下 hard apply；final commit 清 path state。5) soft 仅用于已确认同一 stored output 的 UI/window re-scan（expanded issuance 仍可累积）。 |
| **新增/强化测试** | `testApplyRimeOutputSameRawNewCommentsRevokesStaleIssuedPaths`：**生产调用链** `applyRimeOutput` — 先签发 ni/mi，再注入 same-raw 仅 mi 的新 output；断言 raw generation 稳定、provenance bump、`ni` 撤权、stale window revision、`mi` 可选。既有 soft / hard helper 测试保留。 |
| **Command** | `cd Packages/KeyboardCore && swift test --filter T9PinyinPathTests` |
| **Result** | **PASS — 21 tests, 0 failures** |
| **Full suite** | `swift test` → **PASS — 615 tests, 0 failures** |

### [P2] ADR / KEYBOARD_LAYOUT 未记录双 revision 合同

| Field | Content |
|---|---|
| **修改文件** | `docs/architecture/decisions/0020-t9-precise-pinyin-path-selection.md`；`docs/KEYBOARD_LAYOUT.md` |
| **实际修复** | ADR §3 明确 current-comment-only authorization；§6 记录 `rawInputGeneration` vs `provenanceRevision`、apply vs soft 边界、UIKit 绑定 provenance；Risks 改为 dual-revision-guarded。`KEYBOARD_LAYOUT.md` 同步双 revision 与 apply hard / soft re-scan 语义。 |

---

## 2. Aggregated verification

| Check | Exact command | Exact result |
|---|---|---|
| Path tests | `swift test --filter T9PinyinPathTests` | **PASS — 21 / 0 failures** |
| KeyboardCore full | `swift test` (package) | **PASS — 615 / 0 failures** |
| `git diff --check` | `git diff --check` | **PASS** (exit 0) |
| App Debug strict | `xcodebuild build -scheme "Universe Keyboard" Debug … SWIFT_STRICT_CONCURRENCY=complete` | **BUILD SUCCEEDED** (exit 0；既知 Boost x86_64 notes) |
| App Release strict | same Release | **BUILD SUCCEEDED** (exit 0；既知 Boost x86_64 linker notes) |
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
Status: dirty worktree (implementation uncommitted)
Commit/push/PR: NOT performed
```

---

## 5. Residual risks

1. 每次新 RimeOutput 均 hard-open provenance；同 raw 下 comments 完全未变也会 bump revision（偏安全；面板可能更频繁重建）。  
2. soft retention 仍用 raw compatibility 过滤 expanded keys；仅允许在同 snapshot re-scan 路径，不再经由 apply 默认进入。  
3. Product Gate / clean Spike / 真机矩阵仍开放。  

---

## 6. Next handoff target

**Codex — Architecture + Quality re-review** against this handoff + `keyboard-layout-9key-pinyin-001-codex-rereview-4.md` + current dirty tree.

**Executor stops here.**
