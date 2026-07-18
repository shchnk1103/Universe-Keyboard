# KEYBOARD-LAYOUT-9KEY-PINYIN-001 — Grok Fix Handoff 3 (Codex rereview-2 P1)

Prepared by: Grok（Executor / Input Intelligence Maintainer）  
Handoff target: **Codex Architecture + Quality re-review**  
Date / timezone: `2026-07-18 Asia/Shanghai`  
Branch: `feature/keyboard-layout-9key-pinyin-001`  
HEAD (baseline under dirty worktree): `44d42130bd8e2012bce7b4c034c4bc51a149dec3`  
Source review: [`keyboard-layout-9key-pinyin-001-codex-rereview-2.md`](keyboard-layout-9key-pinyin-001-codex-rereview-2.md)

> Conversation is not authority. Assignment remains **`Active`**.  
> Executor does **not** declare Architecture Pass, Quality Pass, Product Gate, Reviewed, or Closed.  
> No commit / push / PR.

---

## 1. Finding matrix (single blocking P1)

### [P1] rollback 用旧路径快照覆盖 live RIME provenance

| Field | Content |
|---|---|
| **P1 finding** | usable rollback 在 `applyRimeOutput` 后整体写回 `previousPathState`，把旧 `issuedReplacementKeys` / compact / selected 重新注入，即使 live comments 已变。 |
| **根因** | 将 “same raw identity” 误当成可完整恢复 pre-failure path snapshot；`refresh` 也曾对同 generation **继承** previous issued set。 |
| **修改文件** | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift`；`Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift` |
| **实际修复** | 1) usable rollback **不再**赋值 `previousPathState`；以 live `applyRimeOutput` 重建路径/issued。2) 仅当 live 重新签发相同 replacement 时保留 selected。3) `refreshT9PinyinPathState` **不再继承** previous issued set，仅从本次 live page/hot-path 扫描重建签发集合。 |
| **新增测试** | `testRollbackLiveOutputDropsStaleIssuedPaths`：恢复前 comments `ni/mi`，rollback live 仅 `mi`；断言 `ni` 从 compact/issued/selected 消失，裸 `ni` 选择被拒，live `mi` 仍可选。 |
| **Command** | `cd Packages/KeyboardCore && swift test --filter T9PinyinPathTests` |
| **Result** | **PASS — 19 tests, 0 failures** |
| **Full suite** | `cd Packages/KeyboardCore && swift test` → **PASS — 613 tests, 0 failures** |

---

## 2. Aggregated verification

| Check | Exact command | Exact result |
|---|---|---|
| Path tests | `swift test --filter T9PinyinPathTests` | **PASS — 19 / 0 failures** |
| KeyboardCore full | `swift test` (package) | **PASS — 613 / 0 failures** |
| `git diff --check` | `git diff --check` | **PASS** (exit 0) |
| App Debug strict | `xcodebuild build -scheme "Universe Keyboard" -configuration Debug -destination generic/platform=iOS Simulator SWIFT_STRICT_CONCURRENCY=complete CODE_SIGNING_ALLOWED=NO` | **BUILD SUCCEEDED** |
| App Release strict | same Release | **BUILD SUCCEEDED** |
| Keyboard Debug strict | `xcodebuild build -scheme Keyboard … Debug … SWIFT_STRICT_CONCURRENCY=complete` | **BUILD SUCCEEDED** |
| Real Spike re-run | — | **Not re-run** |
| Physical Product Gate | — | **Not executed** |

---

## 3. Not executed (must not claim pass)

1. Clean-commit Spike re-archive  
2. Physical-device Product Gate / VoiceOver / latency  
3. Hosted UI path-panel automation  
4. Architecture / Quality Gate 结论  
5. commit / push / PR / Closed  

---

## 4. Git / workspace

```text
Branch: feature/keyboard-layout-9key-pinyin-001
HEAD:   44d4213
Status: dirty worktree (~45 short-status lines; implementation uncommitted)
Commit/push/PR: NOT performed
```

---

## 5. Residual risks

1. Same-raw refresh 现在每次从 live 重建 issued：面板通过 `t9PinyinPathWindow` 额外签发的后置路径，若随后发生仅 refresh 而不保留 window 扫描结果，可能需要再次打开面板才能 re-issue（raw 未变时）。这是为修 stale issued 继承刻意收紧的边界。  
2. Product Gate 与 clean Spike 仍开放。  

---

## 6. Next handoff target

**Codex — Architecture + Quality re-review** against this handoff + `keyboard-layout-9key-pinyin-001-codex-rereview-2.md` + current dirty tree.

**Executor stops here.**
