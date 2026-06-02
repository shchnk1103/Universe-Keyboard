# CLAUDE.md

> **Maintenance Rule:** Do NOT add "Recent changes" or chronological logs to this file. All historical changes and timestamped logs must go to `CHANGELOG.md`. Keep this file focused on permanent architecture, design decisions, and current status.

This file provides guidance to AI assistants when working with code in this repository.

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

## Current Status (2026-05-26)

**Swift 6 migration complete.** Both targets build with Swift 6 strict concurrency. RIME boundary is consolidated in `Packages/RimeBridge`. Do not recreate bridge sources in either target. Do not silence issues with `@unchecked Sendable` or unsafe isolation.

**Phase 3 complete: RIME Bridge + 雾凇拼音 + librime-lua.** 11 xcframeworks linked (librime 1.16.1 + Lua). App-side full deployment; keyboard session-only at runtime. Schema picker: built-in luna_pinyin + downloadable rime_ice. 6-phase download flow. Schema verification with auto-fallback to luna_pinyin.

- **Test device**: iPhone 13 Pro (real device, primary). Simulator: iPhone 17 (iOS 26).
- **Test baseline**: run `swift test --package-path Packages/KeyboardCore` for current count.
- **Lua**: `RIME_HAS_LUA=1` linked; Lua schema smoke test still BLOCKED (see `docs/architecture/swift6-manual-acceptance.md`).

For detailed change history, see `CHANGELOG.md`.


## Build & Run

- Open `Universe Keyboard.xcodeproj` in Xcode (requires Xcode 26.4+, iOS 26.4+ deployment target).
- Bundle ID: `com.DoubleShy0N.Universe-Keyboard`, Keyboard extension: `com.DoubleShy0N.Universe-Keyboard.Keyboard`
- Team: `C33N6HTS9N`, code signing is automatic.
- To test the keyboard: run the Keyboard extension target on a simulator/device, then enable it in Settings → General → Keyboard → Keyboards → Add New Keyboard → Keyboard.
- Build with `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination 'platform=iOS Simulator,name=iPhone 17' build`
- KeyboardCore has unit tests under `Packages/KeyboardCore/Tests/` (**347 tests at the Swift 6 migration baseline**). Run with `swift test --package-path Packages/KeyboardCore`.
- `RimeBridgeTests` is an iOS Simulator Xcode test target because the pinned RIME xcframework inventory is iOS-only; do not replace it with macOS `swift test --package-path Packages/RimeBridge`.
- A **macOS verification tool** at `Packages/RimeBridge/TestTool/` validates the bridge code against real librime 1.16.1. Run with `cd Packages/RimeBridge/TestTool && make && ./test_rime`.

## Architecture

### Keyboard Extension — file layout

The keyboard is split by presentation, input action, candidate paging, feedback, and accessibility responsibilities:

```
Keyboard/
├── Controllers/
│   ├── KeyboardViewController.swift          — 主控：生命周期、引擎选择、UI 同步
│   ├── KeyboardViewController+Display.swift   — 按钮标题计算 + 状态刷新
│   ├── KeyboardViewController+KeyFactory.swift — 按键工厂方法
│   ├── KeyboardViewController+CandidateBar.swift — 候选栏薄适配
│   ├── KeyboardViewController+CandidatePaging.swift — 候选分页
│   ├── KeyboardViewController+ExpandedCandidatePanel.swift — 展开面板
│   ├── KeyboardViewController+InputActions.swift — 输入动作
│   ├── KeyboardViewController+DeleteActions.swift — 删除交互
│   ├── KeyboardViewController+Presentation.swift — 展示布局
│   ├── KeyboardViewController+Bootstrap.swift — 轻量会话启动
│   └── KeyboardViewController+KeyAccessibility.swift — 无障碍语义
├── Views/
│   ├── KeyPopupView.swift                    — 变体弹出面板
│   └── CandidateBar/
│       ├── CandidateButtonFactory.swift       — 候选按钮工厂（UIButtonConfiguration）
│       ├── CandidateBarView.swift             — 候选栏容器
│       ├── CandidateCell.swift                — 候选单元格
│       └── CandidateBarDataSource.swift       — 候选数据源（RIME 优先，回退 Fake）
├── Services/
│   ├── KeyClickPlayer.swift                  — actor 隔离点击音播放器
│   └── UITextDocumentProxyAdapter.swift      — 文本代理适配器
├── Bridge/
│   ├── KeyboardType+UIKit.swift              — 类型桥接
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
│   ├── Guide/
│   │   └── GuideTab.swift                — 首次启用与系统设置引导
│   ├── Settings/
│   │   ├── SettingsTab.swift             — 设置页导航与诊断开关
│   │   ├── FeedbackSettingsView.swift    — 按键音 + 触感设置
│   │   ├── RimeSettingsView.swift        — RIME 方案设置（方案选择/下载/部署）
│   │   └── SchemaPickerRow.swift        — 方案选择行组件
│   ├── Diagnostics/
│   │   └── DiagnosticsView.swift         — 诊断日志查看器
│   └── License/
│       └── LicenseView.swift             — GPL-3.0 许可证查看
├── Services/
│   └── SchemaManager.swift               — 方案管理 + 下载编排（@MainActor @Observable）
└── Universe Keyboard.entitlements
```

**Testing** (`KeyboardCore` Swift 6 baseline: 347 tests, 0 failures):

```
Packages/KeyboardCore/Tests/KeyboardCoreTests/
├── AutoCapitalizeTests.swift             ├── CompositionTests.swift
├── DeleteTests.swift                     ├── InputModeTests.swift
├── KeyboardTypeTests.swift               ├── LoggerTests.swift
├── PageSwitchTests.swift                 ├── RimeConfigPostProcessor*Tests.swift
├── RimeConfig*Tests.swift                ├── RimeController*Tests.swift
├── ShiftStateTests.swift                 ├── SpaceReturnTests.swift
├── Unzip*Tests.swift
```

All state is managed in `KeyboardCore.KeyboardState` (via `KeyboardController`), not in the view controller. The VC delegates to `controller.handle(_:)` for all business logic and calls `syncUI(with:)` to refresh views.

### RIME Architecture (Phase 3 + librime-lua)

The keyboard uses a **dual-path** design in `KeyboardController`:

- **RIME path** (`rimeEngine != nil`): delegates composition and candidate lookup to the engine. Keystrokes never run deployment or configuration file synchronization.
- **Fallback path** (`rimeEngine == nil`): uses `CandidateProvider` + manual composition (original behavior).

**librime-lua integration**: `Packages/RimeBridge/Vendor/` expects 11 xcframeworks (9 original + `liblua.xcframework` + `librime-lua.xcframework`). The lua module is registered at runtime via `RIME_HAS_LUA=1` preprocessor macro. Full Lua behavior remains subject to a real-artifact schema smoke test before release.

**Inline preedit**: When typing in Chinese mode, the pinyin string is displayed directly in the host text field (like native iOS). `KeyboardState.insertedPreeditCount` tracks the length. On each keystroke, old preedit is deleted and new preedit is inserted. On candidate selection, preedit is deleted and the candidate text is inserted.

**Key files for RIME**:
- `KeyboardCore/Sources/KeyboardCore/RimeEngine.swift` — protocol definition
- `KeyboardCore/Sources/KeyboardCore/RimeOutput.swift` — output data model
- `KeyboardCore/Sources/KeyboardCore/CandidateProviderRimeAdapter.swift` — Fake → RimeEngine adapter
- `Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m` — ObjC wrapper around librime C API
- `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl.swift` — Swift session engine implementation
- `Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift` — app-side full-deployment API

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
- **`Logger`** — lightweight `Sendable` facade backed by a FIFO serial writer. Log filtering, bounded buffering and persistence run away from the keyboard input path; `requestFlush()` never synchronously blocks a key event.
- **`Unzip` / `ZipArchiveReader` / `ZipBinaryReader` / `ZipInflater`** — minimal ZIP extraction boundary using system libz (raw deflate), with parsing, binary reads and inflate responsibilities split for focused tests.
- **`RimeConfigTemplateGenerator` / template files** — pure YAML generation logic plus schema, OpenCC and fallback dictionary templates extracted from `RimeConfigManager`.
- **`RimeConfigPostProcessor`** — canonical Lua stripping and schema repair logic used from the main App deployment preparation path; the Keyboard Extension does not repair files while opening a session.
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
    └── RimeDeploymentService.swift       — main-app-side full deployment API
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
- **Keyboard click sound** uses `KeyClickPlayer` — generates a 4ms, 2000Hz+4000Hz harmonic click WAV in-memory, played via `AVAudioPlayer` with configurable volume (`key_click_volume`, 0.0–1.0). Dual-player architecture prevents clipping on rapid keystrokes. Playback is submitted asynchronously through the player actor so the main thread only pays dispatch cost. No Full Access required.
- **Haptic feedback** uses `UIImpactFeedbackGenerator(style: .light)` with `impactOccurred(intensity:)`. Intensity is configurable via `haptic_intensity` (0.1–1.0), cached at VC level. Generator is pre-warmed in `viewDidLoad` for low latency. Standard key feedback is unified around touch-down: visual highlight/scale, haptic, and click are emitted as one interaction event; candidate and long-press variant commits use the shared feedback helper at commit time.
- **Candidate bar** uses `UIScrollView` for horizontal swipeless scrolling (`decelerationRate: .fast`, `alwaysBounceHorizontal` tied to `hasMoreCandidates`). With inline preedit, the candidate bar shows only candidates (the pinyin is already displayed in the text field). A `CAGradientLayer` fade mask (92%→100%) on the scroll view gently fades the right edge. **No page buttons** — instead, pre-loaded 2-page candidates + near-edge auto-fetch (infinite scroll). New candidates appended directly to stack via `appendToCandidateBar()` (no clear+rebuild flash). **Expanded panel**: flow layout (adaptive width + wrap), fills entire keyboard area, vertical infinite scroll with bottom-edge detection, collapse button floating top-right. "More" indicator `⋯` when `hasMoreCandidates`. **Critical**: use `titleTextAttributesTransformer` for font/color styling, NOT `attributedTitle`. `candidateItems()` returns accumulated candidates (or falls back to current RIME page). When RIME produces an empty composition, the preedit text is shown as a `.composition` item so users can commit raw pinyin.
- **Fuzzy pinyin typo correction must be benchmark-driven**: use `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionTests.swift` and `docs/TYPO_BENCHMARK.md` as the source of truth before changing correction rules, candidate ranking, or typo correction UI.
- **Inline preedit**: In Chinese mode, the pinyin composition is displayed directly in the host text field. `KeyboardController` tracks `state.insertedPreeditCount` and uses `updateInlinePreedit()` / `deleteInlinePreedit()` to manage the text field cursor. On each keystroke the old preedit is deleted and the new one inserted. On candidate selection or mode switch, the preedit is cleared before committing.
- **Long-press delete**: Touch-down immediately performs the first delete. After 0.5s, auto-repeat starts at 0.08s intervals (matching native iOS keyboard behavior).
- **Key click & haptic settings are cached** at the VC level on `viewDidLoad` (not read from `UserDefaults(suiteName:)` on every keypress, which would incur XPC overhead). Cache is invalidated via `UserDefaults.didChangeNotification` observer.
- **Layout extraction**: `reloadKeyboard()` and `reloadKeyboardContent()` share keyboard row construction through `addKeyboardRows(for:)`. No duplicated layout code.
- **iOS 26 native appearance**: key buttons use `KeyVisualStyle` enum for consistent styling (`.character`/`.function`/`.space`/`.returnKey`/`.active`). Dark/light mode custom colors for keyboard background, character keys, function keys, and highlighted state. Keys use `.continuous` corner curve with 9pt radius. Touch feedback uses instantaneous `backgroundColor` + `CGAffineTransform(scaleX: 0.96)` — no Core Animation transactions.
- Keyboard uses programmatic UIKit layout (UIStackView-based rows, no Storyboards) with V1 frozen geometry: `keyHeight=45`, `candidateBarHeight=44`, `keySpacing=8`, `keyboardGroupSpacing=10`, `keyHorizontalSpacing=6`, `thirdRowFunctionSpacing=10`, `primaryFunctionKeyWidth=46`, `functionKeySymbolPointSize=18`, horizontal margins `7`, `keyCornerRadius=9`. Future UI changes must have a specific usability reason; avoid cosmetic tuning while the V1 UI freeze is active.
- **iPhone 17 final keyboard height may be 216pt** (vs. standard 250–268pt on iOS 26 non-adapted apps). Never use a fixed-height constraint larger than `viewHeight - bottomMargin`. The current approach — `view.alpha = 0` in `viewDidLoad` + height-triggered reveal in `viewDidLayoutSubviews` (guard: `height > 0 && height < 400`) — handles all device/OS height variations correctly.
- **`viewDidAppear` is the session recovery safety net.** After an app-switch, the RIME session may be lost. Always call `engine.resetSession()` and clear accumulated candidate state in `viewDidAppear` to guarantee a clean state before the next keystroke.

### RIME Deployment System

- **Main App deploy** (`SchemaManager.fetchAndDownload` → `deployRimeConfig()`): after installing rime_ice, the app calls the actor-isolated `RimeDeploymentService` package API. Its ObjC implementation runs full maintenance in the app process, so the keyboard starts with pre-built cache without owning the deployment boundary.
- **Main App settings** (Settings → RIME 方案设置): unified sub-page with schema picker, download UI, candidate count slider, simplification toggle, and deploy controls. The deploy action awaits main-app compilation and reports success before the user returns to the keyboard.
- **Keyboard Extension** (`viewDidLoad`): resolves already-prepared runtime directories and creates a session only. It does not write YAML, repair schemas, invalidate caches, or deploy while the keyboard is being presented.
- **Keyboard initialize** (`RimeSessionManager.initializeEngine`): lightweight only — `initialize(NULL)` followed by session creation over prepared runtime data. It performs no maintenance and writes no deployment or Lua capability preference state.
- **Deployment ownership**: the main App writes `.custom.yaml` and calls `RimeDeploymentService.deploy(.fullCheck)` before the user returns to the keyboard. `RimeEngineImpl.processKey` performs session input only; Extension recovery may recreate a session but must never run full maintenance.
- **OpenCC integration**: `simplifier` filter added to luna_pinyin schema with `opencc_config: opencc/t2s.json`. OpenCC configs + OCD2 dictionaries auto-deployed to `shared/opencc/`.
- **Diagnostics**: `Logger` (singleton, KeyboardCore) with levels (debug/info/warning/error), categories, 500-entry ring buffer. Writes to `rime_diag_log` via shared UserDefaults. Main app DiagnosticsView shows logs with animated refresh/clear buttons.

## Project Skills

- **`pre-push-review`** (`.claude/skills/pre-push-review/SKILL.md`): automated workflow — scans diff + runs `swift test` + reviews for .bak/.DS_Store + creates commit + pushes. Trigger with "push", "upload to GitHub", "ship it", "commit and push". Blocks on test failures or exclusion-pattern files.
