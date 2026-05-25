# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Universe Keyboard is an iOS third-party custom keyboard with RIME-powered Chinese input. It has two Xcode targets:

- **`Universe Keyboard`** (main App) — SwiftUI app (two tabs: Guide / Settings) for keyboard setup, RIME deployment, and feedback configuration.
- **`Keyboard`** (Keyboard Extension, `Keyboard.appex`) — the actual keyboard that appears in other apps. Built with UIKit (`UIInputViewController`). Primary language: `zh-Hans`.

The long-term goal is a full-featured Chinese keyboard with RIME/librime engine + 雾凇拼音 configuration, swipe input, and near-native iOS feel. The full development plan is documented in `ios-rime-keyboard-development-plan.md`.

## UI Style Guide

All UI work must follow `docs/UI_STYLE_GUIDE.md`.

- Read it before changing `Universe Keyboard/` SwiftUI screens or `Keyboard/` UIKit views.
- Keep the keyboard close to native iOS keyboard appearance: system gray surface, high-contrast keys, readable candidates, compact stable layout.
- Keep the main app close to native iOS Settings: grouped backgrounds, compact rows, reusable components, no marketing-style decoration.
- After UI code changes, build with:

```bash
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## Current Status (2026-05-25)

**Phase 3 (RIME Bridge) + 雾凇拼音 Integration + librime-lua COMPLETE.** Enterprise-grade refactoring applied: duplicate code eliminated, large files split, project reorganized into logical subdirectories.

- **Test device**: iPhone 13 Pro (real device, primary). Simulator: iPhone 17 (iOS 26).
- **11 dependency xcframeworks** compiled from source and linked (9 base + liblua + librime-lua)
- **雾凇拼音 (rime-ice)** downloadable from main App (automatic download + deploy flow)
- **librime-lua plugin** compiled as `librime-lua.xcframework` (~3MB, 10 C++ source files + 32 Lua 5.4 C files)
- **liblua.xcframework** compiled (PUC Lua 5.4, ~400KB)
- **Main-app-side RIME deployment**: `RimeDeployer` (ObjC) runs `start_maintenance(full_check=True)` + `join_maintenance_thread()` in main App process, removing 5-15s blocking from keyboard extension startup. Keyboard only does lightweight `start_maintenance(full_check=False)` quick check.
- **`RIME_HAS_LUA=1`** defined in Keyboard target `GCC_PREPROCESSOR_DEFINITIONS`, ensuring Lua module loads correctly
- **Shared UI components**: `BulletRow`, `CapsuleBadge`, `ClickSoundGenerator`, `SettingsNavigationLink` extracted to eliminate duplication
- **CandidateBar split**: `CandidateButtonFactory` + `CandidateBarDataSource` extracted from 443-line extension
- **AutoCapitalizationRules** extracted from `KeyboardController` into standalone type
- **Project reorganized**: Main App (`App/` `Views/{Components,Settings,Diagnostics,License}` `Services/`), Keyboard (`Controllers/` `Views/CandidateBar/` `Services/` `Bridge/`)
- RIME schema picker UI: built-in luna_pinyin + downloadable rime_ice
- 6-phase download flow (idle → fetchingReleaseInfo → downloading → extracting → postProcessing → deploying → completed)
- **Schema verification**: `selectAndVerifySchema` with Phase 1 (currentSchemaID check) + Phase 2 (functional test with "ni") + auto-fallback to luna_pinyin

**Recent changes (2026-05-21, evening)**:
- **Keyboard flickering mitigation**: view.alpha = 0 with height-stability-detection fade-in (via `fadeInKeyboardIfNeeded()`) to mask iOS system's 3-phase keyboard resize (full-screen → intermediate → final). Apple DTS confirmed no API can prevent the resize itself.
- **Candidate bar simplified**: removed button reuse + associated-object tracking (`objc_getAssociatedObject` Bool bridging issue). Replaced with simple clear-rebuild each refresh. 20-button creation <0.5ms vs RIME 2-5ms — negligible.
- **Enter key chat-app adaptation**: `updateReturnKeyAppearance()` checks `textDocumentProxy.returnKeyType` and `hasText` — action keys (send/search/go) show blue accent when text present, gray when empty. Called from `textDidChange`, `syncUI`, `reloadKeyboard`.
- **ForEach duplicate ID fix**: `DiagnosticsView.swift` + `RimeSettingsView.swift` — changed `ForEach(lines, id: \.self)` to `ForEach(Array(lines.enumerated()), id: \.offset)` to handle repeated log lines.
- **Aggressive diagnostic logging**: `viewDidLayoutSubviews`, `fadeIn`, `fillCandidateBar`, `refreshCandidateBar`, `reloadKeyboard` all emit debug logs with view bounds, rootStack/candidateBar frames, and item counts. Critical for debugging keyboard resize/flickering issues.
- **Performance optimization**: `KeyClickPlayer` audio moved to background serial queue — main-thread blocking reduced from 18-76ms to <1ms per keystroke
- **Double-tap bug fix**: removed `UIView.animate` from `keyTouchDown`/`restoreKeyAppearance` — rapid same-key taps now register reliably
- **Deduplicated data source**: `candidateItems()` called once per keystroke (was twice in expanded mode)
- **Touch feedback**: instantaneous `transform` + `backgroundColor` (no Core Animation transactions per keystroke)

**Recent changes (2026-05-22, afternoon)**:
- **Flickering fix (current approach)**: `view.alpha = 0` in `viewDidLoad` + height-triggered reveal in `viewDidLayoutSubviews`. After `viewDidAppear`, the first layout pass with `view.bounds.height` in range (0, 400) sets `view.alpha = 1`. This waits until the 3-phase resize settles to the final height (250pt on iPhone 13 Pro) before making the keyboard visible. The intermediate heights (844pt, 445pt) are filtered out by the `< 400` guard.
- **RIME session auto-recovery**: `RimeSessionManager.processKey` now detects `sessionId == 0` and automatically calls `create_session()` + `select_schema()` to recover, instead of returning empty output. Handles intermittent session loss between `viewDidLoad` health check and first keystroke.
- **Expanded candidate panel height capped**: `makeExpandedCandidatePanel()` container constrained to `keyHeight * 4 + keySpacing * 3` (194pt), matching normal 4-row key area. Overflow candidates scroll vertically in `UIScrollView`. Prevents keyboard from jumping to half-screen height when expand button is pressed.
- **Flickering investigation — approaches attempted and discarded**:
  1. *Alpha=0 + fadeInKeyboardIfNeeded()* (original): iOS presentation animation overrides `view.alpha=0` during the 3-phase resize, causing half-screen flash at 445pt.
  2. *Mask overlay*: solid-color mask view covered keyboard content. Mask itself visibly changes size 844→445→250pt — user sees the mask shrinking.
  3. *Bottom-anchored layout*: rootStack pinned to view bottom with fixed height. Failed because final view height varies (216-250pt), and fixed content height either clips or leaves too much empty space.
  4. *Async alpha in viewDidAppear*: `DispatchQueue.main.async` not guaranteed to land after the final layout pass.
  5. *Current approach*: top+bottom pinning (original layout) + `view.alpha = 0` + height-triggered reveal. Simplest solution that works.
- **RIME session diagnostics**: NSLog in `RimeSessionManager.m` for `processKey(sessionId=0)`, `deployIfNeeded`, `createSession`, `destroySession`, plus `select_schema` after auto-recovery. All `_sessionId` format strings use `%lu` with `(unsigned long)` cast.
- **Logger category enhancement**: Added `Category.display` (DISP). Per-category toggle switches in settings (性能/画面/引擎/配置/部署/通用). `DiagnosticsView` with category filter chips and color-coded log lines (ERROR=red, WARN=orange, PERF=blue, DISP=purple).
- **iPhone 13 Pro**: Primary test device. Final keyboard view height: 258pt (may vary 216-268pt). Layout constants: `candidateBarHeight=44`, `keyHeight=44`, `keySpacing=8` (vertical), `keyHorizontalSpacing=6` (within-row), `keyCornerRadius=9`, horizontal margins 4pt. `preferredContentSize=258pt`.

**Recent changes (2026-05-25)** — 候选栏交互全面重构 + Apple HIG 合规:

- **Candidate bar swipe-based pagination**: Removed ◀ ▶ page buttons. Infinite horizontal scroll with auto-load: user scrolls right → near-edge detection triggers RIME page-down → new candidates appended smoothly via `appendToCandidateBar()` (no clear+rebuild flash). `scrollViewDidScroll` near-right-edge detection (80pt) + `scrollViewDidEndDragging` overscroll fallback (40pt).
- **Pre-load 2 pages**: `refreshCandidateBar()` immediately fetches RIME page 1 + page 2 on new input, showing ~18 candidates upfront. `loadMoreCandidates()` appends subsequent pages on demand.
- **Expanded panel redesign**: Flow layout replaces fixed 4-column grid. Buttons wrap naturally by text width, trailing spacers prevent `.fill` distribution stretch. Panel fills entire keyboard area (252pt, candidate bar disappears when expanded). Collapse button (chevron.up, 44×44pt) floats top-right above scrollView. Vertical infinite scroll with bottom-edge detection (80pt).
- **Fade mask refined**: Gradient range 82%→92%, last candidate almost fully visible.
- **Comprehensive diagnostic logging**: All scroll/load methods emit info-level DISP logs with candidate counts, distances, hasMorePages, RIME raw returns, dedup counts.
- **Apple HIG P0 (Touch Targets)**: `candidateBarHeight: 36→44` (≥44pt). Expand/collapse buttons: 34×36→44×44pt.
- **Apple HIG P0 (VoiceOver)**: All candidate/expand/collapse buttons have `accessibilityLabel` + `accessibilityHint`. Composition items read "提交拼音 X".
- **Apple HIG P1 (Dynamic Type)**: `UIFontMetrics(forTextStyle: .body).scaledFont(for:maximumPointSize: 28)` replaces hardcoded `systemFont(ofSize:)`.
- **Apple HIG P2 (Semantic colors + 8pt grid)**: Highlighted background uses `.systemGray3`/`.systemGray6`. Candidate stack spacing 3→4pt, highlighted insets 6→8pt, vertical panel spacing 5→4pt.
- **Apple HIG P3 (Spring animation + indicator)**: Chevron rotation uses `usingSpringWithDamping: 0.75` spring. "More" indicator `⋯` (U+22EF, `.quaternaryLabel`) appended when `hasMoreCandidates`, removed when exhausted.
- **KeySpacing split**: `keySpacing: 8` (vertical between rows) + `keyHorizontalSpacing: 6` (horizontal within rows). Total height 250→258pt.
- **Test suite**: 328 tests, 0 failures (was 225).

### Key Lessons Learned (2026-05-21)

1. **iOS keyboard flickering is unfixable at the API level.** Apple DTS engineers confirmed: the keyboard extension runs in a separate process, the system assigns wrong heights (844→445→216) before correcting. No constraint, `intrinsicContentSize`, `allowsSelfSizing`, or `preferredContentSize` prevents it. The only mitigation is making the keyboard invisible during the transition (alpha fade-in).
2. **Final keyboard height varies.** On iPhone 17 with iOS 26 non-adapted apps, the final height is **216pt** (not the standard 250-268pt). Any fixed-height constraint larger than `viewHeight - bottomMargin` causes clipping.
3. **Do NOT override `loadView` in `UIInputViewController`.** It breaks the RIME bridge (processKey returns 0 candidates with 0.0ms bridge time), likely by skipping internal `UIInputViewController` setup.
4. **Bottom anchoring causes candidate bar clipping at 216pt.** `rootStack.height(236) + bottomMargin(8) = 244pt` minimum, but view is only 216pt → top 28pt clipped including the candidate bar.
5. **Associated-object Bool bridging is unreliable.** `objc_getAssociatedObject(...) as? Bool` can fail on `__NSCFBoolean`, making the reuse check always think bold state changed. Simpler: just rebuild.
6. **Log aggressively.** Without `viewDidLayoutSubviews` frame logging, we wouldn't know the final height is 216pt or that viewDidAppear fires at intermediate height 445pt.
- Enterprise-grade refactoring: 5 duplicate blocks unified, 2 large files split, project reorganized into logical subdirectories (328 tests, 0 failures)
- Duplicate WAV generation unified → `ClickSoundGenerator` in KeyboardCore
- Duplicate Lua stripping removed from SchemaManager → uses `RimeConfigPostProcessor`
- Duplicate schema repair removed from `RimeEngineImpl.init` → uses `RimeConfigPostProcessor.repairSchemaIfNeeded`
- BulletRow + CapsuleBadge patterns unified into shared components (11 call sites updated)
- `RIME_HAS_LUA=1` defined in Keyboard target preprocessor macros
- `activateRimeIce()` + `deployRimeConfig()` order swapped: schema activated BEFORE deploy, so deploy compiles the correct schema and flags are not overridden
- `t9.schema.yaml` always installed (was conditionally skipped, causing "missing input schema: t9" in deployment_tasks.cc)
- `RimeConfigManager.prepareDirectories()` schema repair now guarded by `!rimeDeployed` — respects main App deploy results
- `RimeSettingsView.deployState` now refreshes via `.onChange(of: rimeIceDownloadState)` instead of only on `onAppear`
- `RimeDeployer.finalize` renamed to `cleanup` to avoid NSObject deprecated-method collision

## Build & Run

- Open `Universe Keyboard.xcodeproj` in Xcode (requires Xcode 26.4+, iOS 26.4+ deployment target).
- Bundle ID: `com.DoubleShy0N.Universe-Keyboard`, Keyboard extension: `com.DoubleShy0N.Universe-Keyboard.Keyboard`
- Team: `C33N6HTS9N`, code signing is automatic.
- To test the keyboard: run the Keyboard extension target on a simulator/device, then enable it in Settings → General → Keyboard → Keyboards → Add New Keyboard → Keyboard.
- Build with `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination 'platform=iOS Simulator,name=iPhone 17' build`
- KeyboardCore has unit tests under `Packages/KeyboardCore/Tests/` (**328 tests across 13 files**). Run with `swift test` in the `Packages/KeyboardCore/` directory.
- A **macOS verification tool** at `Packages/RimeBridge/TestTool/` validates the bridge code against real librime 1.16.1. Run with `cd Packages/RimeBridge/TestTool && make && ./test_rime`.

## Architecture

### Keyboard Extension — file layout

The keyboard is split across **17 files** in 4 subdirectories:

```
Keyboard/
├── Controllers/
│   ├── KeyboardViewController.swift          — 主控：生命周期、引擎选择、UI 同步
│   ├── KeyboardViewController+Display.swift   — 按钮标题计算 + 状态刷新
│   ├── KeyboardViewController+KeyFactory.swift — 按键工厂方法
│   ├── KeyboardViewController+CandidateBar.swift — 候选栏协调器（scroll、展开、数据源）
│   ├── KeyboardViewController+Layout.swift   — 键盘行布局
│   ├── KeyboardViewController+Actions.swift  — 按键动作 + 长按删除
│   └── KeyboardViewController+Gestures.swift — 高亮 + 长按变体
├── Views/
│   ├── KeyPopupView.swift                    — 变体弹出面板
│   └── CandidateBar/
│       ├── CandidateButtonFactory.swift       — 候选按钮工厂（UIButtonConfiguration）
│       └── CandidateBarDataSource.swift       — 候选数据源（RIME 优先，回退 Fake）
├── Services/
│   ├── KeyClickPlayer.swift                  — 内嵌键盘点击音播放器
│   ├── RimeConfigManager.swift               — RIME 配置部署 + OpenCC + custom.yaml 生成
│   └── UITextDocumentProxyAdapter.swift      — 代理适配器
├── Bridge/
│   ├── KeyboardType+UIKit.swift              — 类型桥接
│   └── RimeBridge/                           — ObjC 桥接层
│       ├── Keyboard-Bridging-Header.h
│       ├── RimeSessionManager.h/.m           — librime C API 封装
│       ├── rime_api.h                        — librime 官方 C API 头文件
│       └── RimeEngineImpl.swift              — RimeEngine 协议实现
├── Info.plist
└── Keyboard.entitlements
```

**Main App additions**:

```
Universe Keyboard/
├── App/
│   ├── Universe_KeyboardApp.swift        — @main 入口
│   └── ContentView.swift                 — 双 Tab 布局（引导 / 设置）
├── Views/
│   ├── Components/
│   │   ├── InfoSection.swift             — 信息卡片容器
│   │   ├── ToggleRow.swift               — 设置开关行
│   │   ├── BulletRow.swift               — 项目符号行（dot / checkmark）
│   │   ├── CapsuleBadge.swift            — 胶囊标签（filled / tinted）
│   │   └── SettingsNavigationLink.swift   — 设置导航行
│   ├── Settings/
│   │   ├── FeedbackSettingsView.swift    — 按键音 + 触感设置
│   │   ├── RimeSettingsView.swift        — RIME 方案设置（方案选择/下载/部署）
│   │   └── SchemaPickerRow.swift        — 方案选择行组件
│   ├── Diagnostics/
│   │   └── DiagnosticsView.swift         — 诊断日志查看器
│   └── License/
│       └── LicenseView.swift             — GPL-3.0 许可证查看
├── Services/
│   ├── SchemaManager.swift               — 方案管理 + 下载编排（@MainActor ObservableObject）
│   ├── RimeDeployer.h/.m                 — 主 App 端 RIME 部署封装
│   └── (future: SchemaDownloadService, SchemaInstallService, etc.)
├── UniverseKeyboard-Bridging-Header.h     — 主 App zlib + RimeDeployer 桥接头
└── Universe Keyboard.entitlements
```

**Testing** (328 tests across 13 files, 0 failures):

```
Packages/KeyboardCore/Tests/KeyboardCoreTests/
├── AutoCapitalizeTests.swift (29 tests)  ├── CompositionTests.swift (23 tests)
├── DeleteTests.swift (5 tests)           ├── InputModeTests.swift (6 tests)
├── KeyboardTypeTests.swift (6 tests)     ├── LoggerTests.swift (7 tests)
├── PageSwitchTests.swift (12 tests)      ├── RimeConfigPostProcessorTests.swift (17 tests)
├── RimeConfigTests.swift (26 tests)      ├── RimeControllerTests.swift (26 tests)
├── ShiftStateTests.swift (12 tests)      ├── SpaceReturnTests.swift (9 tests)
├── UnzipTests.swift (37 tests)
```

All state is managed in `KeyboardCore.KeyboardState` (via `KeyboardController`), not in the view controller. The VC delegates to `controller.handle(_:)` for all business logic and calls `syncUI(with:)` to refresh views.

### RIME Architecture (Phase 3 + librime-lua)

The keyboard uses a **dual-path** design in `KeyboardController`:

- **RIME path** (`rimeEngine != nil`): delegates composition and candidate lookup to the engine. Supports hot-reload via `deployIfNeeded()` on every keystroke.
- **Fallback path** (`rimeEngine == nil`): uses `CandidateProvider` + manual composition (original behavior).

**librime-lua integration**: `Packages/RimeBridge/Vendor/` contains 11 xcframeworks (9 original + `liblua.xcframework` + `librime-lua.xcframework`). The lua module is registered at runtime via `RIME_HAS_LUA=1` preprocessor macro. Lua scripts are deployed from rime-ice's `lua/` directory to `AppGroup/Rime/shared/lua/`.

**Inline preedit**: When typing in Chinese mode, the pinyin string is displayed directly in the host text field (like native iOS). `KeyboardState.insertedPreeditCount` tracks the length. On each keystroke, old preedit is deleted and new preedit is inserted. On candidate selection, preedit is deleted and the candidate text is inserted.

**Key files for RIME**:
- `KeyboardCore/Sources/KeyboardCore/RimeEngine.swift` — protocol definition
- `KeyboardCore/Sources/KeyboardCore/RimeOutput.swift` — output data model
- `KeyboardCore/Sources/KeyboardCore/CandidateProviderRimeAdapter.swift` — Fake → RimeEngine adapter
- `Keyboard/RimeBridge/RimeSessionManager.h/.m` — ObjC wrapper around librime C API
- `Keyboard/RimeBridge/RimeEngineImpl.swift` — Swift engine implementation
- `Packages/RimeBridge/` — SPM package (will contain compiled xcframework)

**macOS verification**: `Packages/RimeBridge/TestTool/main.cpp` tests the bridge code against Homebrew librime 1.16.1.

### KeyboardCore (pure logic, testable)

A local Swift Package at `Packages/KeyboardCore/`. Contains:

- **`KeyboardController`** — central state machine. Exposes `handle(_ action) -> KeyboardEffect` as the single entry point.
- **`KeyboardState`** — variables: `currentPage`, `inputMode`, `shiftState`, `currentComposition`, plus `activeKeyboardType` and timestamp fields. All enums (`KeyboardPage`, `InputMode`, `ShiftState`, `KeyboardType`) are co-located in this file.
- **`KeyboardAction`** — enum of all possible user actions (insertKey, toggleShift, togglePage, etc.). `insertCandidate` uses `CandidateKind` enum for type-safe dispatch.
- **`KeyboardEffect`** — OptionSet returned by `handle(_:)` to tell the UI what to refresh.
- **`CandidateItem`** — `CandidateKind` enum (`.candidate`, `.composition`, `.placeholder`) + `CandidateItem` struct. Replaces the old `(title: String, kind: String)` tuple scattered across 25+ locations. `CandidateKind` uses `Int` rawValue so it maps directly to `UIButton.tag`, avoiding the misuse of `accessibilityIdentifier` for business data.
- **`CandidateProvider`** — protocol for candidate lookup (currently `FakeCandidateProvider`; will be replaced by RIME).
- **`TextInputClient`** — protocol abstracting `UITextDocumentProxy` (enables unit testing with `FakeTextInputClient`).
- **`Logger`** — unified logging singleton. Log levels (debug/info/warning/error), categories (general/engine/config/deployment/performance), 500-entry ring buffer, master toggle via `logging_enabled` UserDefaults key. Tests in `LoggerTests.swift` (7 tests).
- **`Unzip`** — minimal zip extractor using system libz (raw deflate). Supports store (method 0) and deflate (method 8). Bounds checking + 100MB safety limit + 10K iteration guard. 37 tests.
- **`RimeConfigTemplates`** — pure YAML generation logic + string constants (default.yaml, luna_pinyin.schema.yaml, OpenCC configs, fallbackDict). Extracted from RimeConfigManager. 26 tests.
- **`RimeConfigPostProcessor`** — canonical Lua stripping + schema repair logic (used by both main App and keyboard engine-side). 17 tests.
- **`ClickSoundGenerator`** — shared WAV click sound generator (used by `KeyClickPlayer` + `FeedbackSettingsView`).
- **`AutoCapitalizationRules`** — pure static auto-capitalization logic, extracted from `KeyboardController`.
- **`ZLib`** — pure Swift `@_silgen_name` declarations for zlib types (`z_stream`, `uInt`), functions (`inflateInit2_`, `inflate`, `inflateEnd`, `deflateInit2_`, `deflate`, `deflateEnd`), and constants. Eliminates the CZLib SPM C-target to avoid Xcode 26 explicit-module-build issues.

### Main App

```
Universe Keyboard/
├── App/
│   ├── Universe_KeyboardApp.swift        — @main 入口
│   └── ContentView.swift                 — 双 Tab 布局（引导 / 设置）
├── Views/
│   ├── Components/                       — 5 shared components
│   ├── Settings/                         — 3 setting views
│   ├── Diagnostics/                      — log viewer
│   └── License/                          — GPL-3.0 viewer
└── Services/
    ├── SchemaManager.swift               — schema download + deploy orchestrator
    └── RimeDeployer.h/.m                 — main-app-side librime deploy wrapper
```

### Shared infrastructure

- **App Group**: `group.com.DoubleShy0N.Universe-Keyboard` — configured via entitlements on both targets. Used for sharing all keyboard settings between main app and keyboard extension.
- **Full Access is NOT required** for any current feature. Key click uses `KeyClickPlayer` (AVAudioPlayer with generated WAV), haptic uses `UIImpactFeedbackGenerator`. Both work without Full Access.

### Planned architecture (future)

```
Main App (SwiftUI) → settings, config import, onboarding
Keyboard Extension (UIInputViewController) → thin UI + state machine
  └─ KeyboardCore (pure logic, testable) → KeyboardAction, KeyboardState, CompositionState
  └─ KeyboardUI (views) → KeyButtonView, CandidateBarView, KeyboardPageView
  └─ RimeBridge (ObjC++ wrapper) → RimeEngine, librime.xcframework
  └─ SwipeEngine → trajectory → key sequence → candidate merging
```

## Key Design Decisions

- **All text insertion goes through `textDocumentProxy.insertText()`** — never manipulate host app text directly.
- **The globe key (`nextKeyboardButton`) is mandatory** — Apple requires third-party keyboards to provide a way to switch to the next keyboard. Its visibility is managed in `viewWillLayoutSubviews()` via `needsInputModeSwitchKey`.
- **`RequestsOpenAccess` is `true`** — kept for future features. Currently no feature requires Full Access: key click uses `KeyClickPlayer`, haptic uses `UIImpactFeedbackGenerator`.
- **Composition-first deletion**: when `currentComposition` is non-empty, delete key removes from the pinyin buffer first. Only after composition is empty does it call `textDocumentProxy.deleteBackward()`.
- **Email keyboard type auto-switches to English mode** and shows `@`/`.` shortcut keys in the bottom row.
- **URL/webSearch keyboard type auto-switches to English mode** and shows `/`/`.com` shortcut keys in the bottom row.
- **Number page is context-aware**: in Chinese mode it shows Chinese punctuation (。，、？！：；""''（）《》¥), in English mode it shows English punctuation (.,?!:;()$&@)—.
- **Symbol page (#+=)** is the third page in the cycle, with brackets, math symbols, currency signs, and typographic marks.
- **Dynamic page switch button** title: "123" on letters page, "#+=" on numbers page, "ABC" on symbols page.
- **Return key title** dynamically reflects `textDocumentProxy.returnKeyType` (return, search, go, send, etc.).
- **Shift double-tap** (within 0.35s) enters Caps Lock. Single tap cycles between off and single-use uppercase.
- **Double-space period** (within 0.45s) is enabled only in English mode with empty composition.
- **Auto-capitalization** applies at sentence start (after `.`, `!`, `?`, `。`, `！`, `？`) and on empty/new documents. It triggers when switching input mode to English (checks current text context) and after each delete operation (defensive check in `performDeleteBackward` in addition to `textDidChange`, because `UITextDocumentProxy.documentContextBeforeInput` can be stale when `textDidChange` fires). When switching back to Chinese mode, any active shift state (singleUse or capsLock) is automatically reset to off — auto-cap is explicitly English-mode-only.
- **Long-press letter keys** (0.3s) shows a popup with diacritic variants (e.g., a → à á â ä æ). 19 letters have variants. Selection follows finger position; releasing outside the popup cancels. Variants respect Shift state (uppercase/lowercase).
- **Keyboard click sound** uses `KeyClickPlayer` — generates a 4ms, 2000Hz+4000Hz harmonic click WAV in-memory, played via `AVAudioPlayer` on a background serial queue (`qos: .userInitiated`) with configurable volume (`key_click_volume`, 0.0–1.0). Dual-player architecture prevents clipping on rapid keystrokes. The background queue eliminates 18-76ms of main-thread blocking per keystroke. No Full Access required.
- **Haptic feedback** uses `UIImpactFeedbackGenerator(style: .light)` with `impactOccurred(intensity:)`. Intensity is configurable via `haptic_intensity` (0.1–1.0), cached at VC level. Generator is pre-warmed in `viewDidLoad` for low latency. Live preview available in settings.
- **Candidate bar** uses `UIScrollView` for horizontal swipeless scrolling (`decelerationRate: .fast`, `alwaysBounceHorizontal` tied to `hasMoreCandidates`). With inline preedit, the candidate bar shows only candidates (the pinyin is already displayed in the text field). A `CAGradientLayer` fade mask (92%→100%) on the scroll view gently fades the right edge. **No page buttons** — instead, pre-loaded 2-page candidates + near-edge auto-fetch (infinite scroll). New candidates appended directly to stack via `appendToCandidateBar()` (no clear+rebuild flash). **Expanded panel**: flow layout (adaptive width + wrap), fills entire keyboard area, vertical infinite scroll with bottom-edge detection, collapse button floating top-right. "More" indicator `⋯` when `hasMoreCandidates`. **Critical**: use `titleTextAttributesTransformer` for font/color styling, NOT `attributedTitle`. `candidateItems()` returns accumulated candidates (or falls back to current RIME page). When RIME produces an empty composition, the preedit text is shown as a `.composition` item so users can commit raw pinyin.
- **Inline preedit**: In Chinese mode, the pinyin composition is displayed directly in the host text field. `KeyboardController` tracks `state.insertedPreeditCount` and uses `updateInlinePreedit()` / `deleteInlinePreedit()` to manage the text field cursor. On each keystroke the old preedit is deleted and the new one inserted. On candidate selection or mode switch, the preedit is cleared before committing.
- **Long-press delete**: Touch-down immediately performs the first delete. After 0.5s, auto-repeat starts at 0.08s intervals (matching native iOS keyboard behavior).
- **Key click & haptic settings are cached** at the VC level on `viewDidLoad` (not read from `UserDefaults(suiteName:)` on every keypress, which would incur XPC overhead). Cache is invalidated via `UserDefaults.didChangeNotification` observer.
- **Layout extraction**: `reloadKeyboard()` and `reloadKeyboardContent()` share keyboard row construction through `addKeyboardRows(for:)`. No duplicated layout code.
- **iOS 26 native appearance**: key buttons use `KeyVisualStyle` enum for consistent styling (`.character`/`.function`/`.space`/`.returnKey`/`.active`). Dark/light mode custom colors for keyboard background, character keys, function keys, and highlighted state. Keys use `.continuous` corner curve with 9pt radius. Touch feedback uses instantaneous `backgroundColor` + `CGAffineTransform(scaleX: 0.96)` — no Core Animation transactions.
- Keyboard uses programmatic UIKit layout (UIStackView-based rows, no Storyboards) with fixed key sizes (`keyHeight: 44`, `candidateBarHeight: 36`, `keySpacing: 6`, `keyCornerRadius: 9`).

### RIME Deployment System

- **Main App deploy** (`SchemaManager.fetchAndDownload` → `deployRimeConfig()`): after downloading and installing rime_ice, main App calls `RimeDeployer` (minimal ObjC wrapper around librime C API) to run `start_maintenance(full_check=True)` + `join_maintenance_thread()`. This compiles all YAML → .bin (including rime_ice's 词库) in the main App process, so the keyboard starts with pre-built cache. Deploy runs in `Task.detached` to keep UI responsive.
- **Main App settings** (Settings → RIME 方案设置): unified sub-page with schema picker, download UI (6 phases: idle → fetchingReleaseInfo → downloading → extracting → postProcessing → deploying → completed), candidate count slider, simplification toggle, and deploy controls. Deploy section polls `rime_deployed`/`rime_deploying` and auto-refreshes via `.onChange(of: rimeIceDownloadState)`.
- **Keyboard Extension** (`viewDidLoad`): `RimeConfigManager.prepareDirectories()` writes YAML configs + OpenCC dictionaries to App Group. Uses `config_generation` counter to detect code-level config changes. Schema repair (replacing Lua-stripped schemas) only runs when `rime_deployed=false` — respects main App deploy results.
- **Keyboard initialize** (`RimeSessionManager.initializeEngine`): lightweight only — `initialize(NULL)` + Lua availability record + `start_maintenance(full_check=False)` quick check. No full deploy (already done by main App). Entire keyboard startup is sub-second.
- **Runtime deploy** (`RimeEngineImpl.processKey`): calls `syncCustomYamlFiles()` before `deployIfNeeded()`. Custom YAML generated from UserDefaults settings (page_size, simplification). If `rime_needs_deploy` is true (e.g., after settings change without main-app deploy), clears build cache, runs full maintenance, creates new session.
- **OpenCC integration**: `simplifier` filter added to luna_pinyin schema with `opencc_config: opencc/t2s.json`. OpenCC configs + OCD2 dictionaries auto-deployed to `shared/opencc/`.
- **Diagnostics**: `Logger` (singleton, KeyboardCore) with levels (debug/info/warning/error), categories, 500-entry ring buffer. Writes to `rime_diag_log` via shared UserDefaults. Main app DiagnosticsView shows logs with animated refresh/clear buttons.

## Project Skills

- **`pre-push-review`** (`.claude/skills/pre-push-review/SKILL.md`): automated workflow — scans diff + runs `swift test` + reviews for .bak/.DS_Store + creates commit + pushes. Trigger with "push", "upload to GitHub", "ship it", "commit and push". Blocks on test failures or exclusion-pattern files.
