# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Universe Keyboard is an iOS third-party custom keyboard with RIME-powered Chinese input. It has two Xcode targets:

- **`Universe Keyboard`** (main App) — SwiftUI app (two tabs: Guide / Settings) for keyboard setup, RIME deployment, and feedback configuration.
- **`Keyboard`** (Keyboard Extension, `Keyboard.appex`) — the actual keyboard that appears in other apps. Built with UIKit (`UIInputViewController`). Primary language: `zh-Hans`.

The long-term goal is a full-featured Chinese keyboard with RIME/librime engine + 雾凇拼音 configuration, swipe input, and near-native iOS feel. The full development plan is documented in `ios-rime-keyboard-development-plan.md`.

## Current Status (2026-05-15)

**Phase 3 (RIME Bridge) architecture is COMPLETE.** The entire RimeEngine protocol stack, dual-path controller, ObjC bridge, and inline preedit system are built and verified against real librime 1.16.1 on macOS. The keyboard currently uses a `FakeCandidateProvider` adapter because the pre-compiled librime xcframework (v1.8.5 from amorphobia/LibrimeKit) is too old to produce candidates. **Next step: compile librime 1.16.1 from source for iOS** (Boost and yaml-cpp already built).

## Build & Run

- Open `Universe Keyboard.xcodeproj` in Xcode (requires Xcode 26.4+, iOS 26.4+ deployment target).
- Bundle ID: `com.DoubleShy0N.Universe-Keyboard`, Keyboard extension: `com.DoubleShy0N.Universe-Keyboard.Keyboard`
- Team: `C33N6HTS9N`, code signing is automatic.
- To test the keyboard: run the Keyboard extension target on a simulator/device, then enable it in Settings → General → Keyboard → Keyboards → Add New Keyboard → Keyboard.
- Build with `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination 'platform=iOS Simulator,name=iPhone 17' build`
- KeyboardCore has unit tests under `Packages/KeyboardCore/Tests/` (113 tests across 9 files). Run with `swift test` in the `Packages/KeyboardCore/` directory.
- A **macOS verification tool** at `Packages/RimeBridge/TestTool/` validates the bridge code against real librime 1.16.1. Run with `cd Packages/RimeBridge/TestTool && make && ./test_rime`.

## Architecture

### Keyboard Extension — file layout

The keyboard is split across **14 files**:

```
Keyboard/
├── KeyboardViewController.swift          — 主控：生命周期、引擎选择、UI 同步
├── KeyboardViewController+Display.swift   — 按钮标题计算 + 状态刷新
├── KeyboardViewController+KeyFactory.swift — 按键工厂方法
├── KeyboardViewController+CandidateBar.swift — 候选栏（RIME 优先，回退 Fake）
├── KeyboardViewController+Layout.swift   — 键盘行布局
├── KeyboardViewController+Actions.swift  — 按键动作 + 长按删除
├── KeyboardViewController+Gestures.swift — 高亮 + 长按变体
├── KeyPopupView.swift                    — 变体弹出面板
├── UITextDocumentProxyAdapter.swift      — 代理适配器
├── KeyboardType+UIKit.swift              — 类型桥接
├── RimeConfigManager.swift               — RIME 配置文件部署到 App Group
├── RimeDiagnostics.swift                 — 引擎状态诊断（写入共享 UserDefaults）
└── RimeBridge/                           — ObjC 桥接层
    ├── Keyboard-Bridging-Header.h
    ├── RimeSessionManager.h/.m           — librime C API 封装
    ├── rime_api.h                        — librime 官方 C API 头文件
    └── RimeEngineImpl.swift              — RimeEngine 协议实现（keycode 翻译 + session 管理）
```

All state is managed in `KeyboardCore.KeyboardState` (via `KeyboardController`), not in the view controller. The VC delegates to `controller.handle(_:)` for all business logic and calls `syncUI(with:)` to refresh views.

### RIME Architecture (Phase 3)

The keyboard uses a **dual-path** design in `KeyboardController`:

- **RIME path** (`rimeEngine != nil`): delegates composition and candidate lookup to the engine. Supports hot-reload via `deployIfNeeded()` on every keystroke.
- **Fallback path** (`rimeEngine == nil`): uses `CandidateProvider` + manual composition (original behavior).

**Inline preedit**: When typing in Chinese mode, the pinyin string is displayed directly in the host text field (like native iOS). `KeyboardState.insertedPreeditCount` tracks the length. On each keystroke, old preedit is deleted and new preedit is inserted. On candidate selection, preedit is deleted and the candidate text is inserted.

**Key files for RIME**:
- `KeyboardCore/Sources/KeyboardCore/RimeEngine.swift` — protocol definition
- `KeyboardCore/Sources/KeyboardCore/RimeOutput.swift` — output data model
- `KeyboardCore/Sources/KeyboardCore/CandidateProviderRimeAdapter.swift` — Fake → RimeEngine adapter
- `Keyboard/RimeBridge/RimeSessionManager.h/.m` — ObjC wrapper around librime C API
- `Keyboard/RimeBridge/RimeEngineImpl.swift` — Swift engine implementation
- `Packages/RimeBridge/` — SPM package (will contain compiled xcframework)

**macOS verification**: `Packages/RimeBridge/TestTool/main.cpp` tests the bridge code against Homebrew librime 1.16.1.

**Known issue**: The pre-compiled xcframework from `amorphobia/LibrimeKit` contains librime 1.8.5 (2019) which cannot produce dictionary-based candidates. The solution is to compile librime 1.16.1 from source for iOS using the already-built Boost and yaml-cpp libraries.

### KeyboardCore (pure logic, testable)

A local Swift Package at `Packages/KeyboardCore/`. Contains:

- **`KeyboardController`** — central state machine. Exposes `handle(_ action) -> KeyboardEffect` as the single entry point.
- **`KeyboardState`** — variables: `currentPage`, `inputMode`, `shiftState`, `currentComposition`, plus `activeKeyboardType` and timestamp fields. All enums (`KeyboardPage`, `InputMode`, `ShiftState`, `KeyboardType`) are co-located in this file.
- **`KeyboardAction`** — enum of all possible user actions (insertKey, toggleShift, togglePage, etc.). `insertCandidate` uses `CandidateKind` enum for type-safe dispatch.
- **`KeyboardEffect`** — OptionSet returned by `handle(_:)` to tell the UI what to refresh.
- **`CandidateItem`** — `CandidateKind` enum (`.candidate`, `.composition`, `.placeholder`) + `CandidateItem` struct. Replaces the old `(title: String, kind: String)` tuple scattered across 25+ locations. `CandidateKind` uses `Int` rawValue so it maps directly to `UIButton.tag`, avoiding the misuse of `accessibilityIdentifier` for business data.
- **`CandidateProvider`** — protocol for candidate lookup (currently `FakeCandidateProvider`; will be replaced by RIME).
- **`TextInputClient`** — protocol abstracting `UITextDocumentProxy` (enables unit testing with `FakeTextInputClient`).

### Main App

```
Universe Keyboard/
├── ContentView.swift                     — 主页面：引导启用、键盘反馈设置、Full Access 引导、进度、测试清单
├── Universe_KeyboardApp.swift            — @main 入口
└── Components/
    ├── InfoSection.swift                 — 可复用信息卡片容器
    └── ToggleRow.swift                   — 可复用设置开关行
```

### Shared infrastructure

- **App Group**: `group.com.DoubleShy0N.Universe-Keyboard` — configured via entitlements on both targets. Used for sharing keyboard settings (key click, haptic toggles) between the main app and the keyboard extension.
- **App Group does NOT require Full Access**. Full Access is only needed for `AudioServicesPlaySystemSound(1104)` (keyboard click sound).

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
- **`RequestsOpenAccess` is `true`** — needed for `AudioServicesPlaySystemSound(1104)` (keyboard click sound). Haptic feedback (`UIImpactFeedbackGenerator`) does NOT require Full Access. App Group settings sharing also works without it. The main app's Full Access guide card explains this to users.
- **`UIDevice.current.playInputClick()` does NOT work in keyboard extensions** — this is a known Apple limitation. Use `AudioServicesPlaySystemSound(1104)` instead, which requires Full Access.
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
- **Keyboard click sound** uses `AudioServicesPlaySystemSound(1104)` (the system keyboard click), gated by `hasFullAccess` and the shared `key_click_enabled` UserDefaults toggle.
- **Haptic feedback** uses `UIImpactFeedbackGenerator(style: .light)`, gated by the shared `haptic_enabled` UserDefaults toggle. Generator is pre-warmed in `viewDidLoad` for low latency.
- **Candidate bar** uses `UIScrollView` for horizontal scrolling (`decelerationRate: .fast`). With inline preedit, the candidate bar shows only candidates (the pinyin is already displayed in the text field). A `CAGradientLayer` fade mask on the scroll view fades the right edge. The expanded panel uses a 4-column grid layout. **Critical**: use `titleTextAttributesTransformer` for font/color styling, NOT `attributedTitle`. `candidateItems()` reads from `state.lastRimeOutput` first (RIME path), falls back to `candidateProvider.candidates(for:)` (Fake path). When RIME produces an empty composition, the preedit text is shown as a `.composition` item so users can commit raw pinyin.
- **Inline preedit**: In Chinese mode, the pinyin composition is displayed directly in the host text field. `KeyboardController` tracks `state.insertedPreeditCount` and uses `updateInlinePreedit()` / `deleteInlinePreedit()` to manage the text field cursor. On each keystroke the old preedit is deleted and the new one inserted. On candidate selection or mode switch, the preedit is cleared before committing.
- **Long-press delete**: Touch-down immediately performs the first delete. After 0.5s, auto-repeat starts at 0.08s intervals (matching native iOS keyboard behavior).
- **Key click & haptic settings are cached** at the VC level on `viewDidLoad` (not read from `UserDefaults(suiteName:)` on every keypress, which would incur XPC overhead). Cache is invalidated via `UserDefaults.didChangeNotification` observer.
- **Layout extraction**: `reloadKeyboard()` and `reloadKeyboardContent()` share keyboard row construction through `addKeyboardRows(for:)`. No duplicated layout code.
- **iOS 26 native appearance**: key buttons use `systemBackground` with 10pt corner radius and subtle shadow, on a `systemGray4` keyboard background. The candidate bar shares the same `systemGray4` background and 10pt corner radius.
- Keyboard uses programmatic UIKit layout (UIStackView-based rows, no Storyboards) with fixed key sizes (`keyHeight: 44`, `candidateBarHeight: 36`, `keySpacing: 6`, `keyCornerRadius: 10`).

### RIME Deployment System

- **Main App** (Settings tab): deploy button triggers `rime_needs_deploy = true` in shared UserDefaults. Polls `rime_deployed` flag every 2s. Shows 5 phases: idle → triggered → deploying → deployed → failed. Deployment logs and keyboard diagnostics are shown in collapsible sections with copy buttons.
- **Keyboard Extension** (`viewDidLoad`): `RimeConfigManager.prepareDirectories()` writes YAML configs to App Group. `RimeEngineImpl` is always created (no fallback to adapter unless App Group is unavailable). Health check tests "ni" for candidates.
- **Runtime deploy** (`RimeEngineImpl.processKey`): calls `deployIfNeeded()` on every keystroke. If `rime_needs_deploy` is true, clears build cache, runs full maintenance, creates new session. This means users don't need to switch keyboards — deployment happens on the first keystroke after clicking "Deploy".
- **Diagnostics**: `RimeDiagnostics` writes engine status to `rime_diag_log` in shared UserDefaults. `RimeConfigManager` writes file deployment status. Main app displays both in the Settings tab.
