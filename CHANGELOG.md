# CHANGELOG

Change history for Universe Keyboard. Entries are in reverse chronological order.

> **AI agents**: Load this file only when investigating historical decisions, debugging regressions, or understanding why a specific implementation approach was chosen. Do not load for routine coding tasks.

---

## 2026-06-03 — Feedback settings and RIME management reliability

- Persisted keyboard sound and haptic settings through the shared App Group store, refreshed extension-side cached values when the keyboard appears, and documented the Allow Full Access dependency for shared settings and diagnostics.
- Separated RIME update checks from forced redownloads: update checks now compare the installed release tag and report when rime_ice is already current, while redownload always starts a fresh download.
- Removed temporary runtime diagnostics after validating the App Group and deployment paths.

---

## 2026-06-02 — Typo correction benchmark reference

- Added `docs/TYPO_BENCHMARK.md` as the benchmark reference for fuzzy pinyin typo correction coverage, scoring principles, known unsupported categories, and next milestone guidance.
- Linked typo correction work in `CONTEXT_INDEX.md` and added a long-term `CLAUDE.md` note requiring future correction rules, ranking, and UI work to use `TypoCorrectionTests` plus the benchmark document as the source of truth.

---

## 2026-06-01 — Keyboard UI V1 freeze

- **Frozen layout baseline**: `candidateBarHeight=44`, `keyHeight=45`, `keySpacing=8`, `keyboardGroupSpacing=10`, `keyHorizontalSpacing=6`, `thirdRowFunctionSpacing=10`, `primaryFunctionKeyWidth=46`, `functionKeySymbolPointSize=18`, horizontal margins `7`, `keyCornerRadius=9`.
- **Input feedback baseline**: standard keys emit visual press state, haptic feedback, and key click together from touch-down. Candidate commits and long-press variant commits use the shared feedback helper at commit time. Key click playback keeps the overlapping rapid-typing behavior.
- **V1 UI freeze rule**: keyboard UI is frozen unless a major usability issue is found. Future UI changes must cite a specific usability reason such as mistouch reduction, clipping, accessibility, or interaction regression.
- **Manual verification checklist captured**: slow typing, rapid typing, repeated function keys, long-press delete, edge keys, candidate commits, and accessibility labels.

## 2026-05-25 (evening) — 候选栏滑动检测重构

- **三层滚动检测**: ① `scrollViewDidScroll` 用百分比阈值（>60% 可滚宽度）替代绝对距离 ② `scrollViewWillEndDragging` 预测性触发（Apple 推荐方式，在 deceleration 开始前触发）③ `scrollViewDidEndDragging` overscroll 兜底（>30pt）
- **百分比阈值更可靠**: 候选栏/展开面板统一用 `progress = offset / max(1, scrollableWidth)` > 0.6，不受设备宽度或候选数量绝对值影响
- **新增 6 个 loadMore 流程测试**: pageDown/pageUp 恢复、composing 状态保持、去重逻辑、预加载流程、多次翻页回到页1、深度追踪

**Key Lessons:**
- 百分比阈值优于绝对距离。80pt 阈值在不同设备/不同候选数量下表现不一致，60% 可滚宽度是通用解法。
- 三层检测（scroll + willEndDrag + didEndDrag）互补覆盖所有滚动场景。单靠 `scrollViewDidScroll` 可能在快速滑动时漏检。

---

## 2026-05-25 (afternoon) — 关键 Bug 修复

- **Bug 1 (候选栏滚动后空格失效)**: 预加载和 `loadMoreCandidates` 使用 `controller.handle(.candidatePageDown)` 污染了 `state.lastRimeOutput`（从第1页变为第2/N页）。修复：直接用 `engine.pageDown()`/`pageUp()`，不经过 controller。添加 `candidatePageDepth` 跟踪深度，每次加载后回到第1页。`handleInsertSpace` 改为从 `lastRimeOutput.candidates.first` 直接取最佳候选提交。
- **Bug 2 (首候选背景拉伸)**: 候选栏 `UIStackView` 的 `.fill` distribution 导致单按钮被拉伸至整行宽。修复：在 `fillCandidateBar` 和 `appendToCandidateBar` 末尾添加 low-hugging trailing spacer。
- **Bug 3 (选择候选后删除键重现拼音)**: `handleInsertCandidate` fallback 路径没有调用 `engine.resetSession()`，RIME 残留旧 composition。删除时 `isComposing()` 仍返回 true → 从残留拼音删除 → 重现旧拼音。修复：fallback 路径添加 `rimeEngine?.resetSession()`，`handleInsertSpace` 所有分支都确保重置。
- **Bug 4 (应用切换后无候选词)**: 键盘挂起恢复后 RIME session 可能失效，`viewDidAppear` 未做检查。修复：`viewDidAppear` 调用 `engine.resetSession()` + 清空累积状态。
- 新增 7 个回归测试。Test suite at this point: 341 → 347 tests, 0 failures.

**Key Lessons:**
- 预加载/翻页必须直接用 engine，不能经过 `controller.handle`。`controller.handle(.candidatePageDown)` 会更新 `state.lastRimeOutput`，破坏 UI 层依赖的"第1页"假设。UI 层翻页累积候选词 ≠ RIME 引擎翻页改变内部状态，两者必须解耦。
- 所有候选/空格提交路径都必须 `engine.resetSession()`。无论是 RIME 路径还是 fallback 路径，提交后残留 composition 会导致下次删除从旧拼音删除、重现候选词。
- `.fill` distribution 的 UIStackView 不能有单按钮行。每行末尾加 trailing spacer 是最简单的防御措施。
- `viewDidAppear` 是键盘恢复的最后防线。应用切换后 session 可能丢失，在这里重置保证干净状态。→ *Promoted to Key Design Decisions in CLAUDE.md.*

---

## 2026-05-25 (morning) — 候选栏交互全面重构 + Apple HIG 合规

- **Candidate bar swipe-based pagination**: Removed ◀ ▶ page buttons. Infinite horizontal scroll with auto-load: user scrolls right → near-edge detection triggers RIME page-down → new candidates appended via `appendToCandidateBar()` (no clear+rebuild flash). `scrollViewDidScroll` near-right-edge detection (80pt) + `scrollViewDidEndDragging` overscroll fallback (40pt).
- **Pre-load 2 pages**: `refreshCandidateBar()` immediately fetches RIME page 1 + page 2 on new input, showing ~18 candidates upfront. `loadMoreCandidates()` appends subsequent pages on demand.
- **Expanded panel redesign**: Flow layout replaces fixed 4-column grid. Buttons wrap naturally by text width, trailing spacers prevent `.fill` distribution stretch. Panel fills entire keyboard area (252pt, candidate bar disappears when expanded). Collapse button (chevron.up, 44×44pt) floats top-right above scrollView. Vertical infinite scroll with bottom-edge detection (80pt).
- **Fade mask refined**: Gradient range 82%→92%, last candidate almost fully visible.
- **Apple HIG P0 (Touch Targets)**: `candidateBarHeight: 36→44` (≥44pt). Expand/collapse buttons: 34×36→44×44pt.
- **Apple HIG P0 (VoiceOver)**: All candidate/expand/collapse buttons have `accessibilityLabel` + `accessibilityHint`. Composition items read "提交拼音 X".
- **Apple HIG P1 (Dynamic Type)**: `UIFontMetrics(forTextStyle: .body).scaledFont(for:maximumPointSize: 28)` replaces hardcoded `systemFont(ofSize:)`.
- **Apple HIG P2 (Semantic colors + 8pt grid)**: Highlighted background uses `.systemGray3`/`.systemGray6`. Candidate stack spacing 3→4pt, highlighted insets 6→8pt, vertical panel spacing 5→4pt.
- **Apple HIG P3 (Spring animation + indicator)**: Chevron rotation uses `usingSpringWithDamping: 0.75` spring. "More" indicator `⋯` (U+22EF, `.quaternaryLabel`) appended when `hasMoreCandidates`, removed when exhausted.
- **KeySpacing split**: `keySpacing: 8` (vertical between rows) + `keyHorizontalSpacing: 6` (horizontal within rows). Total height 250→258pt.
- Test suite at this point: 347 KeyboardCore tests, 0 failures.

---

## 2026-05-22 (afternoon) — Flickering 修复 + Session 自动恢复

- **Flickering fix (current approach)**: `view.alpha = 0` in `viewDidLoad` + height-triggered reveal in `viewDidLayoutSubviews`. After `viewDidAppear`, the first layout pass with `view.bounds.height` in range (0, 400) sets `view.alpha = 1`. This waits until the 3-phase resize settles to the final height (250pt on iPhone 13 Pro). The intermediate heights (844pt, 445pt) are filtered out by the `< 400` guard.
- **RIME session auto-recovery**: `RimeSessionManager.processKey` now detects `sessionId == 0` and automatically calls `create_session()` + `select_schema()` to recover, instead of returning empty output.
- **Expanded candidate panel height capped**: `makeExpandedCandidatePanel()` container constrained to `keyHeight * 4 + keySpacing * 3` (194pt). Overflow candidates scroll vertically in `UIScrollView`.
- **Logger category enhancement**: Added `Category.display` (DISP). Per-category toggle switches in settings (性能/画面/引擎/配置/部署/通用). `DiagnosticsView` with category filter chips and color-coded log lines (ERROR=red, WARN=orange, PERF=blue, DISP=purple).
- **iPhone 13 Pro**: Primary test device. Final keyboard view height: 258pt (may vary 216–268pt). Layout constants: `candidateBarHeight=44`, `keyHeight=44`, `keySpacing=8` (vertical), `keyHorizontalSpacing=6` (within-row), `keyCornerRadius=9`, horizontal margins 4pt. `preferredContentSize=258pt`.
- **RIME session diagnostics**: NSLog in `RimeSessionManager.m` for `processKey(sessionId=0)`, `createSession`, `destroySession`, plus `select_schema` after auto-recovery.

**Flickering approaches attempted and discarded:**
1. *Alpha=0 + fadeInKeyboardIfNeeded()* (original): iOS presentation animation overrides `view.alpha=0` during the 3-phase resize, causing half-screen flash at 445pt.
2. *Mask overlay*: solid-color mask view covered keyboard content. Mask itself visibly changes size 844→445→250pt — user sees the mask shrinking.
3. *Bottom-anchored layout*: rootStack pinned to view bottom with fixed height. Failed because final view height varies (216–250pt), and fixed content height either clips or leaves too much empty space.
4. *Async alpha in viewDidAppear*: `DispatchQueue.main.async` not guaranteed to land after the final layout pass.
5. *Current approach*: top+bottom pinning (original layout) + `view.alpha = 0` + height-triggered reveal. ✅ Simplest solution that works.

---

## 2026-05-21 (evening) — 性能与稳定性优化

- **Keyboard flickering mitigation**: `view.alpha = 0` + height-stability-detection fade-in (via `fadeInKeyboardIfNeeded()`) to mask iOS system's 3-phase keyboard resize (full-screen → intermediate → final). Apple DTS confirmed no API can prevent the resize itself.
- **Candidate bar simplified**: Removed button reuse + associated-object tracking (`objc_getAssociatedObject` Bool bridging issue). Replaced with simple clear-rebuild each refresh. 20-button creation <0.5ms vs RIME 2–5ms — negligible.
- **Enter key chat-app adaptation**: `updateReturnKeyAppearance()` checks `textDocumentProxy.returnKeyType` and `hasText` — action keys (send/search/go) show blue accent when text present, gray when empty. Called from `textDidChange`, `syncUI`, `reloadKeyboard`.
- **ForEach duplicate ID fix**: `DiagnosticsView.swift` + `RimeSettingsView.swift` — changed `ForEach(lines, id: \.self)` to `ForEach(Array(lines.enumerated()), id: \.offset)` to handle repeated log lines.
- **Performance optimization**: `KeyClickPlayer` audio moved to background serial queue — main-thread blocking reduced from 18–76ms to <1ms per keystroke.
- **Double-tap bug fix**: Removed `UIView.animate` from `keyTouchDown`/`restoreKeyAppearance` — rapid same-key taps now register reliably.
- **Deduplicated data source**: `candidateItems()` called once per keystroke (was twice in expanded mode).
- **Touch feedback**: Instantaneous `transform` + `backgroundColor` (no Core Animation transactions per keystroke).

**Key Lessons:**
- iOS keyboard flickering is unfixable at the API level. Apple DTS engineers confirmed: the keyboard extension runs in a separate process, the system assigns wrong heights (844→445→216) before correcting. No constraint, `intrinsicContentSize`, `allowsSelfSizing`, or `preferredContentSize` prevents it. Only mitigation: alpha fade-in.
- Final keyboard height varies. On iPhone 17 with iOS 26 non-adapted apps, the final height is **216pt** (not the standard 250–268pt). → *Promoted to Key Design Decisions in CLAUDE.md.*
- Do NOT override `loadView` in `UIInputViewController`. It breaks the RIME bridge (processKey returns 0 candidates with 0.0ms bridge time). → *See `docs/architecture/swift6-migration.md` Regression Invariants.*
- Bottom anchoring causes candidate bar clipping at 216pt. `rootStack.height(236) + bottomMargin(8) = 244pt` minimum, but view is only 216pt → top 28pt clipped.
- Associated-object Bool bridging is unreliable. `objc_getAssociatedObject(...) as? Bool` can fail on `__NSCFBoolean`. Simpler: just rebuild.
- Log aggressively. Without `viewDidLayoutSubviews` frame logging, we wouldn't know the final height is 216pt or that `viewDidAppear` fires at intermediate height 445pt.

---

## 2026-05-21 (earlier) — Swift 6 企业级重构 + RIME 统一桥接

- Enterprise-grade refactoring: RIME C/ObjC ownership consolidated in `Packages/RimeBridge`; Swift 6 baseline verified 347 KeyboardCore tests with 0 failures.
- Duplicate WAV generation unified → `ClickSoundGenerator` in KeyboardCore.
- Duplicate Lua stripping removed from SchemaManager → uses `RimeConfigPostProcessor`.
- Schema repair and Lua stripping are performed in the main App preparation/deployment flow; `RimeEngineImpl.init` only starts an input session over prepared data.
- BulletRow + CapsuleBadge patterns unified into shared components (11 call sites updated).
- `RIME_HAS_LUA=1` defined in Keyboard target preprocessor macros.
- `activateRimeIce()` + `deployRimeConfig()` order swapped: schema activated BEFORE deploy, so deploy compiles the correct schema and flags are not overridden.
- `t9.schema.yaml` always installed (was conditionally skipped, causing "missing input schema: t9" in deployment_tasks.cc).
- App-side `RimeConfigManager.prepareDirectories()` schema repair is guarded by `!rimeDeployed` so it respects prior deployment results.
- `RimeSettingsView.deployState` now refreshes via `.onChange(of: rimeIceDownloadState)` instead of only on `onAppear`.
- `RimeDeployer.finalize` renamed to `cleanup` to avoid NSObject deprecated-method collision.
