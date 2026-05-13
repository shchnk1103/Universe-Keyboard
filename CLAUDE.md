# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Universe Keyboard is an iOS third-party custom keyboard with RIME-powered Chinese input. It has two Xcode targets:

- **`Universe Keyboard`** (main App) — SwiftUI app that guides users through enabling the keyboard, importing RIME configurations, and managing settings.
- **`Keyboard`** (Keyboard Extension, `Keyboard.appex`) — the actual keyboard that appears in other apps. Built with UIKit (`UIInputViewController`). Primary language: `zh-Hans`.

The long-term goal is a full-featured Chinese keyboard with RIME/librime engine + 雾凇拼音 configuration, swipe input, and near-native iOS feel. The full development plan is documented in `ios-rime-keyboard-development-plan.md`.

## Build & Run

- Open `Universe Keyboard.xcodeproj` in Xcode (requires Xcode 26.4+, iOS 26.4+ deployment target).
- Bundle ID: `com.DoubleShy0N.Universe-Keyboard`, Keyboard extension: `com.DoubleShy0N.Universe-Keyboard.Keyboard`
- Team: `C33N6HTS9N`, code signing is automatic.
- To test the keyboard: run the Keyboard extension target on a simulator/device, then enable it in Settings → General → Keyboard → Keyboards → Add New Keyboard → Keyboard.
- Build with `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination 'platform=iOS Simulator,name=iPhone 17' build`
- KeyboardCore has unit tests under `Packages/KeyboardCore/Tests/` (93 tests across 8 files covering composition, shift, delete, space/return, input mode, page switching, keyboard type, and auto-capitalization). Run with `swift test` in the `Packages/KeyboardCore/` directory.

## Architecture

### Keyboard Extension — file layout

The keyboard is split across **10 focused files**, each with a single concern:

```
Keyboard/
├── KeyboardViewController.swift          — 主控：属性、生命周期、反馈播放、UI 同步
├── KeyboardViewController+Display.swift   — 计算属性（shift/空格/return/翻页按钮标题）+ 按钮状态刷新
├── KeyboardViewController+KeyFactory.swift — 按键创建工厂方法（makeKeyButton, makeDeleteButton, displayTitle）
├── KeyboardViewController+CandidateBar.swift — 候选栏创建、刷新、数据源
├── KeyboardViewController+Layout.swift   — 键盘行布局（字母行、文本行、第三行、底部功能行）
├── KeyboardViewController+Actions.swift  — 按键动作（字母/候选/符号输入、切换、空格、回车、删除）
├── KeyboardViewController+Gestures.swift — 按键高亮 + 长按变体字符弹出面板
├── KeyPopupView.swift                    — 长按弹出面板视图（变体字符数据字典 + UI）
├── UITextDocumentProxyAdapter.swift      — UITextDocumentProxy → TextInputClient 适配器
└── KeyboardType+UIKit.swift              — UIKeyboardType → KeyboardType 桥接
```

All state is managed in `KeyboardCore.KeyboardState` (via `KeyboardController`), not in the view controller. The VC delegates to `controller.handle(_:)` for all business logic and calls `syncUI(with:)` to refresh views.

### KeyboardCore (pure logic, testable)

A local Swift Package at `Packages/KeyboardCore/`. Contains:

- **`KeyboardController`** — central state machine. Exposes `handle(_ action) -> KeyboardEffect` as the single entry point.
- **`KeyboardState`** — variables: `currentPage`, `inputMode`, `shiftState`, `currentComposition`, plus `activeKeyboardType` and timestamp fields.
- **`KeyboardPage`** — three-page system: `.letters` (ABC), `.numbers` (123), `.symbols` (#+=). Page switch cycles letters → numbers → symbols → letters via `handleTogglePage()`.
- **`KeyboardAction`** — enum of all possible user actions (insertKey, toggleShift, togglePage, etc.).
- **`KeyboardEffect`** — OptionSet returned by `handle(_:)` to tell the UI what to refresh.
- **`TextInputClient`** — protocol abstracting `UITextDocumentProxy` (enables unit testing with `FakeTextInputClient`).
- **`CandidateProvider`** — protocol for candidate lookup (currently `FakeCandidateProvider`; will be replaced by RIME).

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
- **Long-press letter keys** (0.3s) shows a popup with diacritic variants (e.g., a → à á â ä æ). 19 letters have variants. Selection follows finger position; releasing outside the popup cancels. Variants respect Shift state (uppercase/lowercase).
- **Keyboard click sound** uses `AudioServicesPlaySystemSound(1104)` (the system keyboard click), gated by `hasFullAccess` and the shared `key_click_enabled` UserDefaults toggle.
- **Haptic feedback** uses `UIImpactFeedbackGenerator(style: .light)`, gated by the shared `haptic_enabled` UserDefaults toggle. Generator is pre-warmed in `viewDidLoad` for low latency.
- **Candidate bar** currently uses hardcoded "fake" pinyin candidates — RIME/librime integration has not started yet.
- Keyboard uses programmatic UIKit layout (UIStackView-based rows, no Storyboards) with fixed key sizes (`keyHeight: 44`, `candidateBarHeight: 36`, `keySpacing: 6`).
