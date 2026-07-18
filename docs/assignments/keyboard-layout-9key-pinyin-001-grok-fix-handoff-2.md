# KEYBOARD-LAYOUT-9KEY-PINYIN-001 — Grok Fix Handoff 2 (Codex rereview P1s)

Prepared by: Grok（Executor / Input Intelligence Maintainer）  
Handoff target: **Codex Architecture + Quality re-review**  
Date / timezone: `2026-07-18 Asia/Shanghai`  
Branch: `feature/keyboard-layout-9key-pinyin-001`  
HEAD (baseline under dirty worktree): `44d42130bd8e2012bce7b4c034c4bc51a149dec3`  
Source review: [`keyboard-layout-9key-pinyin-001-codex-rereview.md`](keyboard-layout-9key-pinyin-001-codex-rereview.md)

> Conversation is not authority. Assignment remains **`Active`**.  
> Executor does **not** declare Architecture Pass, Quality Pass, Product Gate, Reviewed, or Closed.  
> No commit / push / PR.

---

## 1. Finding-by-finding matrix (4 blocking P1s)

### [P1] Core provenance guard was effectively only `isCompatible`

| Field | Content |
|---|---|
| **P1 finding** | `known \|\| isCompatible` then `isCompatible` → bare constructible path could call `replaceInput` without comment issuance. |
| **根因** | Core 未维护 generation-bound issued set；选择 API 接受任意可构造 `T9PinyinPath`。 |
| **修改文件** | `T9PinyinPath.swift`（`issuedReplacementKeys` / discovery 字段）；`KeyboardController+T9PinyinPath.swift`；`KeyboardViewController+T9PinyinPath.swift` |
| **实际修复** | Core 在 refresh / `t9PinyinPathWindow` 时登记 `issuedReplacementKeys`。`handleSelectT9PinyinPath` **必须** `issuedReplacementKeys.contains(replacement)` 且 generation>0 且 compatible；否则 fail closed。UI 也只转发 issued keys。 |
| **新增测试** | `testCompatibleButUnissuedPathRejected` |
| **Command** | `cd Packages/KeyboardCore && swift test --filter T9PinyinPathTests` |
| **Result** | **PASS** — 18 tests, 0 failures（整包 **612**） |

### [P1] 16-candidate peek 会把后置有效路径永久锁死

| Field | Content |
|---|---|
| **P1 finding** | compact 空时 `hasSelectable` 只 peek 16；后置路径无法开面板。 |
| **根因** | 把 “compact 未发现” 误当成 “全局无路径”。 |
| **修改文件** | `T9PinyinPathState.discoveryMayHaveMore` / `discoveryNextIndex`；`t9PinyinPathAvailability()`；UI 按钮；`presentPinyinPathExpandedPanel` 有界 auto-advance |
| **实际修复** | 可用性三态：`pathsAvailable` / `discoveryPending` / `exhaustedNoPaths`。只要 `discoveryMayHaveMore` 为真即可开面板；打开时首窗 48 并有界推进（最多 8 次）直到发现路径或穷尽。 |
| **新增测试** | `testDiscoveryPendingWhenValidPathPastHotPathPeek`（前 16 无效、17+ 有效） |
| **Command** | `swift test --filter T9PinyinPathTests` |
| **Result** | **PASS** |

### [P1] refinement/rollback 未要求 usable composition/candidates

| Field | Content |
|---|---|
| **P1 finding** | raw 非空即可当 composition；rollback 只比 raw identity。 |
| **根因** | `composition != nil \|\| !raw.isEmpty` 过松；未要求 candidates。 |
| **修改文件** | `KeyboardController+T9PinyinPath.swift`（`isUsableT9SessionOutput`） |
| **实际修复** | 成功要求：无 commit、**非空 composition.preedit**、**非空 raw**、**非空 candidates**、规范化 raw 精确等于 path。Rollback：usable live equivalent → apply + **返回** `.compositionChanged`/`.t9PinyinPathsChanged`；same-raw-unusable → fail-closed reset；完全失败 → reset。 |
| **新增测试** | `testExactRawWithoutCompositionRejected`；`testRollbackSameRawUnusableFailClosed`；更新 rollback/unexpected-commit 期望 effect |
| **Command** | `swift test --filter T9PinyinPathTests` |
| **Result** | **PASS** |

### [P1] 页面往返只清空 path，返回 letters 不重建

| Field | Content |
|---|---|
| **P1 finding** | letters→numbers→letters 后 path bar 丢失，需再按键。 |
| **根因** | `handleTogglePage` 无条件 clear，无 return-to-letters rebuild。 |
| **修改文件** | `KeyboardController+ModeAndShift.swift`；`rebuildT9PinyinPathStateIfComposing()` |
| **实际修复** | 进入 `.letters` 且仍有 active T9 composition 时 `refreshT9PinyinPathState`；离开 letters 时 clear。 |
| **新增测试** | `testPageRoundTripRebuildsPathsWithoutNewKey` |
| **Command** | `swift test --filter T9PinyinPathTests` |
| **Result** | **PASS** |

---

## 2. Aggregated verification

| Check | Exact command | Exact result |
|---|---|---|
| Path focused tests | `cd Packages/KeyboardCore && swift test --filter T9PinyinPathTests` | **PASS — 18 tests, 0 failures** |
| KeyboardCore full | `cd Packages/KeyboardCore && swift test` | **PASS — 612 tests, 0 failures** |
| Whitespace | `git diff --check` | **PASS** (exit 0) |
| App Debug strict | `xcodebuild build -scheme "Universe Keyboard" -configuration Debug -destination generic/platform=iOS Simulator SWIFT_STRICT_CONCURRENCY=complete CODE_SIGNING_ALLOWED=NO` | **BUILD SUCCEEDED** |
| App Release strict | same Release | **BUILD SUCCEEDED** |
| Keyboard Debug strict | `xcodebuild build -scheme Keyboard … Debug … SWIFT_STRICT_CONCURRENCY=complete` | **BUILD SUCCEEDED** |
| KeyboardTests | `xcodebuild test -scheme "Universe Keyboard" -only-testing:KeyboardTests …` | **PASS — 6 tests, 0 failures** |
| Real librime Spike re-run | — | **Not re-run** this pass |
| Physical device / Product Gate | — | **Not executed** |

---

## 3. Not executed (do not claim pass)

1. Clean-commit Spike re-archive（无 commit 授权）  
2. Physical-device Product Gate / key latency  
3. Hosted UIViewController path-panel scroll UI tests  
4. Architecture / Quality Gate 结论（交 Codex）  
5. Publication / lifecycle Closed  

---

## 4. Git / workspace

```text
Branch: feature/keyboard-layout-9key-pinyin-001
HEAD:   44d4213
Status: dirty worktree (~43 short-status lines; implementation uncommitted)
Commit/push/PR: NOT performed
```

---

## 5. Residual risks

1. Same-raw refresh **retains** previously issued keys（有意：comment 可能不在当前 page）；依赖 generation bump 在 raw 变化时清空。  
2. Panel auto-advance 以 8 次 × 48 为界，极端稀疏表可能仍需用户滚动（滚动入口仍在）。  
3. Rollback live-equivalent 恢复 previousPathState 时可能与 live candidates 细微差异——以 usable live apply 为主。  

---

## 6. Next handoff target

**Codex — Architecture + Quality re-review** against this handoff + `keyboard-layout-9key-pinyin-001-codex-rereview.md` + current dirty tree.

**Executor stops here.**
