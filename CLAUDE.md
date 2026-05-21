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

## Current Status (2026-05-21)

**Phase 3 (RIME Bridge) + 雾凇拼音 Integration + librime-lua COMPLETE.** Enterprise-grade refactoring applied: duplicate code eliminated, large files split, project reorganized into logical subdirectories.

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

**Recent changes (2026-05-21)**:
- Enterprise-grade refactoring: 5 duplicate blocks unified, 2 large files split, project reorganized into logical subdirectories (224 tests, 0 failures)
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
- KeyboardCore has unit tests under `Packages/KeyboardCore/Tests/` (**224 tests across 13 files**). Run with `swift test` in the `Packages/KeyboardCore/` directory.
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

**Testing** (224 tests across 13 files, 0 failures):

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
- **Keyboard click sound** uses `KeyClickPlayer` — generates a 4ms, 2000Hz+4000Hz harmonic click WAV in-memory, played via `AVAudioPlayer` with configurable volume (`key_click_volume`, 0.0–1.0). Dual-player architecture prevents clipping on rapid keystrokes. No Full Access required.
- **Haptic feedback** uses `UIImpactFeedbackGenerator(style: .light)` with `impactOccurred(intensity:)`. Intensity is configurable via `haptic_intensity` (0.1–1.0), cached at VC level. Generator is pre-warmed in `viewDidLoad` for low latency. Live preview available in settings.
- **Candidate bar** uses `UIScrollView` for horizontal scrolling (`decelerationRate: .fast`). With inline preedit, the candidate bar shows only candidates (the pinyin is already displayed in the text field). A `CAGradientLayer` fade mask on the scroll view fades the right edge. The expanded panel uses a 4-column grid layout. **Critical**: use `titleTextAttributesTransformer` for font/color styling, NOT `attributedTitle`. `candidateItems()` reads from `state.lastRimeOutput` first (RIME path), falls back to `candidateProvider.candidates(for:)` (Fake path). When RIME produces an empty composition, the preedit text is shown as a `.composition` item so users can commit raw pinyin.
- **Inline preedit**: In Chinese mode, the pinyin composition is displayed directly in the host text field. `KeyboardController` tracks `state.insertedPreeditCount` and uses `updateInlinePreedit()` / `deleteInlinePreedit()` to manage the text field cursor. On each keystroke the old preedit is deleted and the new one inserted. On candidate selection or mode switch, the preedit is cleared before committing.
- **Long-press delete**: Touch-down immediately performs the first delete. After 0.5s, auto-repeat starts at 0.08s intervals (matching native iOS keyboard behavior).
- **Key click & haptic settings are cached** at the VC level on `viewDidLoad` (not read from `UserDefaults(suiteName:)` on every keypress, which would incur XPC overhead). Cache is invalidated via `UserDefaults.didChangeNotification` observer.
- **Layout extraction**: `reloadKeyboard()` and `reloadKeyboardContent()` share keyboard row construction through `addKeyboardRows(for:)`. No duplicated layout code.
- **iOS 26 native appearance**: key buttons use `systemBackground` with 10pt corner radius and subtle shadow, on a `systemGray4` keyboard background. The candidate bar shares the same `systemGray4` background and 10pt corner radius.
- Keyboard uses programmatic UIKit layout (UIStackView-based rows, no Storyboards) with fixed key sizes (`keyHeight: 44`, `candidateBarHeight: 36`, `keySpacing: 6`, `keyCornerRadius: 10`).

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
