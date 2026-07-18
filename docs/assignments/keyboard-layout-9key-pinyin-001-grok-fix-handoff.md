# KEYBOARD-LAYOUT-9KEY-PINYIN-001 — Grok Fix Handoff (Codex P1/P2)

Prepared by: Grok（Executor / Input Intelligence Maintainer）  
Handoff target: **Codex Architecture + Quality re-review**  
Date / timezone: `2026-07-18 Asia/Shanghai`  
Branch: `feature/keyboard-layout-9key-pinyin-001`  
Base HEAD (still uncommitted worktree): `44d42130bd8e2012bce7b4c034c4bc51a149dec3`  
Source review: [`keyboard-layout-9key-pinyin-001-codex-implementation-review.md`](keyboard-layout-9key-pinyin-001-codex-implementation-review.md)

> Conversation is not authority. This handoff records Executor fixes against Codex findings only.  
> Executor does **not** declare Architecture Pass, Quality Pass, Product Gate, Reviewed, or Closed.

---

## 1. Finding-by-finding matrix

### [P1] 混合 raw 路径兼容忽略数字后缀

| Field | Content |
|---|---|
| **Codex finding** | `isCompatible` 拆分 letters/digits 后允许 `ni4` 接受 `nia`/`nim` 等错位路径。 |
| **根因** | 兼容性未按 raw **原始位置槽**校验；字母前缀关系替代了 digit-group 约束。 |
| **修改文件** | `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinPath.swift` |
| **实际修复** | 新增 `rawSlots` 顺序遍历：字母槽精确相等，数字槽必须落在 T9 字母组；纯数字要求全长路径；混合允许“短路径 + 仅 trailing digits”（`ni` on `ni4`）。 |
| **测试** | `T9PinyinPathTests.testCompatibilityPositionBasedMixedAndNegatives` |
| **Command** | `cd Packages/KeyboardCore && swift test --filter T9PinyinPathTests` |
| **Result** | **PASS** — 13 tests, 0 failures |

### [P1] refinement 接受任意变化 raw；rollback 未验证 session

| Field | Content |
|---|---|
| **Codex finding** | `refinedOk` 允许任意非空变化；rollback 只恢复 Core 镜像。 |
| **根因** | 成功条件过松；`replaceInput(previousRaw)` 返回值被忽略。 |
| **修改文件** | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift`；`FakeRimeEngine.swift`（`replaceInputScript`） |
| **实际修复** | 成功：规范化 raw **必须精确等于** requested path，且无 committedText。失败：`rollbackT9PinyinRefinement` 校验 session 恢复的 raw identity；失败则 `resetSession` + 清空 Core/marked/path（fail closed）。 |
| **测试** | `testSelectPathExactRefineAndSessionRollback`；`testUnexpectedCommitAndRollbackFailureFailClosed`（wrong raw / unexpected commit / rollback fail） |
| **Command** | `cd Packages/KeyboardCore && swift test --filter T9PinyinPathTests` |
| **Result** | **PASS** |

### [P1] 完整路径面板 lazy paging 无入口

| Field | Content |
|---|---|
| **Codex finding** | `loadMorePinyinPathsIfNeeded` 无调用方；scroll delegate 忽略 path collection。 |
| **根因** | 只实现了方法，未接入 scroll 结束 / near-end 检测。 |
| **修改文件** | `Keyboard/Controllers/KeyboardViewController+CandidatePaging.swift`；`KeyboardViewController+T9PinyinPath.swift` |
| **实际修复** | `scrollViewDidEndDragging/Decelerating` 对 `pinyinPathCollectionView` 调用 `requestMorePinyinPathsIfNeeded`；generation-guarded；空窗且 index 不前进则停止；**不**触发普通候选 prefetch。 |
| **测试** | KeyboardCore：`testPathWindowGenerationGuardDropsStaleExtend`；window paging 语义覆盖。**无** UIViewController 宿主 UI 自动化（见未执行验证）。 |
| **Command** | `swift test --filter T9PinyinPathTests`；`xcodebuild test … -only-testing:KeyboardTests` |
| **Result** | KeyboardCore path tests **PASS**；KeyboardTests 6 tests **PASS**（既有 contract，非 path panel UI） |

### [P1] composition 终止路径未统一清空 path 状态

| Field | Content |
|---|---|
| **Codex finding** | Space/Return/language/auto-English/page 等未清 path。 |
| **根因** | 仅 candidate commit / visibility 清路径；T9 finalize 路径遗漏。 |
| **修改文件** | `KeyboardController+TextEditing.swift`；`+ModeAndShift.swift`；`+Candidates.swift`；`+PartialCommit.swift`（`finishActiveComposition*`）；`+T9PinyinPath.swift`（`clearT9PinyinPathStateReturningEffect`） |
| **实际修复** | 统一 `clearT9PinyinPathStateReturningEffect()`，接入 Space/Return 提交、language/auto-English abandon、page switch、finish composition、candidate commit、visibility abandon。 |
| **测试** | `testLifecycleClearsPathState`；`testCandidateCommitClearsPathState` |
| **Command** | `swift test --filter T9PinyinPathTests` |
| **Result** | **PASS** |

### [P1] accessibility 存 business state；UIKit 构造 fallback path

| Field | Content |
|---|---|
| **Codex finding** | `accessibilityValue = replacementRawInput`；lookup 失败时 `T9PinyinPath(...)` 自造。 |
| **根因** | 用 a11y 当路由通道。 |
| **修改文件** | `Keyboard/Views/T9PinyinPathBarView.swift`；`KeyboardViewController+T9PinyinPath.swift` |
| **实际修复** | `T9PinyinPathButton` 持有 Core 提供的 `path` 引用；a11y 仅标签/选中语义；点击必须 `compactPaths.contains(path)`，否则 fail closed，不构造 fallback。 |
| **测试** | Core stale/incompatible selection fail closed（`testSelectPathExactRefine…` 兼容负例）；UI 层无独立 XCTest host。 |
| **Command** | 同上 path tests + Keyboard Debug build |
| **Result** | **PASS** / **BUILD SUCCEEDED** |

### [P1] 无有效路径时「选拼音」仍可用

| Field | Content |
|---|---|
| **Codex finding** | 只检查 composition active。 |
| **根因** | 未绑定 Core 已验证路径能力。 |
| **修改文件** | `KeyboardController+T9PinyinPath.swift`（`hasSelectableT9PinyinPaths`）；`KeyboardViewController+T9PinyinPath.swift` |
| **实际修复** | `enabled = composing && hasSelectableT9PinyinPaths()`；无路径禁用 + `notEnabled` trait + 准确 hint；`t9SelectPinyin` 双重 guard。 |
| **测试** | `testHasSelectablePathsFalseWithoutValidComments` |
| **Command** | `swift test --filter T9PinyinPathTests` |
| **Result** | **PASS** |

### [P1] KEYBOARD_LAYOUT trailing whitespace

| Field | Content |
|---|---|
| **Codex finding** | `git diff --check` fail lines 3–6。 |
| **根因** | 行尾空白。 |
| **修改文件** | `docs/KEYBOARD_LAYOUT.md` |
| **实际修复** | 移除 trailing whitespace；补充 ASCII/hot-path 说明。 |
| **测试** | n/a |
| **Command** | `git diff --check` |
| **Result** | **PASS**（无输出） |

### [P2] ASCII contract

| Field | Content |
|---|---|
| **Codex finding** | Unicode CharacterSet 过宽。 |
| **根因** | 使用 Unicode letter/digit/whitespace。 |
| **修改文件** | `T9PinyinPath.swift` |
| **实际修复** | 显式 ASCII A–Z/a–z、0–9、space(0x20)、apostrophe；accented/全角/tab/nbsp 拒绝。 |
| **测试** | `testCommentNormalization…`；`testASCIIRawContractRejectsUnicodeDigitsAndWhitespace` |
| **Result** | **PASS** |

### [P2] rawInputGeneration 语义

| Field | Content |
|---|---|
| **Codex finding** | 每次 refresh 都 +1。 |
| **根因** | 未存储 previous raw identity。 |
| **修改文件** | `T9PinyinPathState.trackedRawInput`；`refreshT9PinyinPathState` |
| **实际修复** | 规范化 raw 存入 state；相同 identity generation 稳定；变化时 +1。 |
| **测试** | `testGenerationStableForSameRawAndIncrementsOnceOnChange` |
| **Result** | **PASS** |

### [P2] 热路径同步扫描 48 candidates

| Field | Content |
|---|---|
| **Codex finding** | 每键最多同步 window 48。 |
| **根因** | compact 不足时无界扩展。 |
| **修改文件** | `T9PinyinPath.swift`（`hotPathWindowLimit = 16`）；`refreshT9PinyinPathState`；`KEYBOARD_LAYOUT.md` |
| **实际修复** | 先用 page candidates；不足时仅 `hotPathWindowLimit=16`；panel 仍用 48。未发明延迟阈值；真机 key latency 仍为 Product Gate 项。 |
| **Result** | 代码已收紧；**无**设备延迟证据（不得写为通过） |

### [P2] Spike dirty snapshot 边界

| Field | Content |
|---|---|
| **Codex finding** | 可行性证据 ≠ publication snapshot。 |
| **根因** | `ALLOW_DIRTY=1` + pre-impl HEAD。 |
| **修改文件** | `keyboard-layout-9key-pinyin-001-spike-summary.md` |
| **实际修复** | 明确标注 feasibility only、非 publication、需 commit 后重归档。 |
| **Result** | 文档边界已纠正 |

---

## 2. Aggregated verification

| Check | Exact command | Exact result |
|---|---|---|
| KeyboardCore full | `cd Packages/KeyboardCore && swift test` | **PASS — 607 tests, 0 failures**（含 13 个 `T9PinyinPathTests`） |
| T9PinyinPath focused | `swift test --filter T9PinyinPathTests` | **PASS — 13 tests, 0 failures** |
| KeyboardTests | `xcodebuild test -scheme "Universe Keyboard" -only-testing:KeyboardTests … CODE_SIGNING_ALLOWED=NO` | **PASS — 6 tests** |
| App Debug strict | `xcodebuild build -scheme "Universe Keyboard" -configuration Debug -destination generic/platform=iOS Simulator SWIFT_STRICT_CONCURRENCY=complete CODE_SIGNING_ALLOWED=NO` | **BUILD SUCCEEDED** |
| App Release strict | same with Release | **BUILD SUCCEEDED** |
| Keyboard Debug strict | `xcodebuild build -scheme Keyboard … Debug … SWIFT_STRICT_CONCURRENCY=complete` | **BUILD SUCCEEDED** |
| RimeBridgeTests compile | `xcodebuild build-for-testing -scheme RimeBridgeTests …` | **TEST BUILD SUCCEEDED** |
| Whitespace | `git diff --check` | **PASS**（no trailing whitespace reported） |
| Real librime Spike re-run | — | **Not re-run in this fix pass**（先前 dirty feasibility archive 仍有效边界见 P2） |
| Physical device | — | **Not executed**（Human Dependency） |

---

## 3. Not executed / must not claim pass

1. **Clean-commit Spike re-archive** — no commit authorization.  
2. **Physical-device Product Gate** — Human Dependency; still Open.  
3. **UIViewController-hosted UI automation** for path panel scroll paging / VoiceOver hit testing — not present; Core/window + scroll wiring reviewed statically + Keyboard Debug build.  
4. **Key-path latency measurement** for bounded hot-path window — device only; no invented threshold.  
5. **Architecture / Quality Gate** — await Codex re-review.  
6. **Product Gate / Closed** — forbidden for Executor to declare.

---

## 4. Git / workspace state

```text
Branch: feature/keyboard-layout-9key-pinyin-001
HEAD:   44d4213 (clean main-line baseline under dirty feature worktree)
Commit/push/PR: NOT performed (Human Product Owner constraint)
```

Working tree remains **dirty** with modified + untracked implementation/docs (see `git status`). Local Spike archive under gitignored `evidence/keyboard-layout-9key-pinyin-spike/…`.

---

## 5. Residual risks

1. Sparse Rime comments on single keys may leave compact bar empty until more keys / panel window — fail closed by design.  
2. Hot-path `hotPathWindowLimit=16` may still cost on slow devices — measure on device before Product Gate.  
3. Path panel lazy paging is wired; lacks instrumented UI test proving multi-window load under real UIKit scroll.  
4. Spike archive is still dirty/feasibility-only until clean re-run after commit auth.  
5. Rollback fail-closed resets session (may surprise if Rime intermittent) — intentional vs Core/session desync.

---

## 6. Next handoff target

**Codex — Architecture + Quality re-review** against:

1. This fix handoff  
2. Original Codex implementation review  
3. ADR 0020 / Assignment / PD (unchanged product intent)  
4. Current dirty worktree on `feature/keyboard-layout-9key-pinyin-001`

Please produce independent re-review conclusions (Pass / Fail / Pass-with-findings). Do not treat Executor self-check as Gate.

**Executor stops here.** No publication, no lifecycle Close.
