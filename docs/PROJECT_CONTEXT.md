# PROJECT_CONTEXT.md

> **Maintenance Rule:** Do NOT add "Recent changes", chronological logs, or dated current-status snapshots to this file. All historical changes and status updates must go to `CHANGELOG.md`. Keep this file focused on permanent architecture, design decisions, and implementation constraints.

This file provides durable project context for AI assistants working with code in this repository.

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

## Status And History

This file does not track the latest project status. Use `CHANGELOG.md` for recent changes, milestone progress, and dated status snapshots.

The durable implementation constraints are:

- Both targets are expected to build with Swift 6 strict concurrency.
- RIME production bridge code belongs in `Packages/RimeBridge`; do not recreate bridge sources in app or extension targets.
- Do not silence concurrency issues with `@unchecked Sendable` or unsafe isolation.
- Full RIME deployment is owned by the main App; the Keyboard Extension runtime path is session-only.
- Lua and release-readiness validation status belongs in `CHANGELOG.md` and `docs/architecture/swift6-manual-acceptance.md`.


## Build & Run

- Open `Universe Keyboard.xcodeproj` in Xcode (requires Xcode 26.4+, iOS 26.4+ deployment target).
- Bundle ID: `com.DoubleShy0N.Universe-Keyboard`, Keyboard extension: `com.DoubleShy0N.Universe-Keyboard.Keyboard`
- Team: `C33N6HTS9N`, code signing is automatic.
- To test the keyboard: run the Keyboard extension target on a simulator/device, then enable it in Settings → General → Keyboard → Keyboards → Add New Keyboard → Keyboard.
- Build with `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination 'platform=iOS Simulator,name=iPhone 17' build`
- KeyboardCore has unit tests under `Packages/KeyboardCore/Tests/`. Run `swift test --package-path Packages/KeyboardCore` for the current count and result.
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
│       ├── CandidateBarView.swift             — 候选栏容器
│       ├── CandidateCell.swift                — 候选单元格
│       ├── CandidateScrollViewStyle.swift      — 候选滚动视图外观防护
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
│   │   ├── AppActionButton.swift         — 主 App 内容操作按钮（Liquid Glass + fallback）
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

**Testing** (`KeyboardCore` unit test layout):

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

**Inline preedit / marked text**: When typing in Chinese mode, the active composition is displayed directly in the host text field using `UITextDocumentProxy.setMarkedText`, so iOS renders the composing underline. RIME `rawInput` and display `preeditText` must remain separate because librime may display segmented strings such as `ni h`.

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
- **`TextInputClient`** — protocol abstracting `UITextDocumentProxy` insertion, deletion, cursor movement, text-presence checks, and marked text APIs (enables unit testing with `FakeTextInputClient`).
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
│   ├── Components/                       — shared SwiftUI components
│   ├── Settings/                         — 3 setting views
│   ├── Diagnostics/                      — log viewer
│   └── License/                          — GPL-3.0 viewer
└── Services/
    ├── SchemaManager.swift               — schema download + deploy orchestrator
    └── RimeDeploymentService.swift       — main-app-side full deployment API
```

### Shared infrastructure

- **App Group**: `group.com.DoubleShy0N.Universe-Keyboard` — configured via entitlements on both targets. Used for sharing keyboard settings, diagnostics, and RIME state between the main app and keyboard extension.
- **Full Access dependency**: App Group settings, diagnostics, and user-configured keyboard feedback may not function correctly unless the user enables "Allow Full Access" for the keyboard in iOS Keyboard Settings. The sound and haptic APIs run inside the extension, but their persisted enable/level settings are App Group-backed.

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

- **All committed text insertion goes through `textDocumentProxy.insertText()`**; active Chinese composition uses the public `UITextDocumentProxy.setMarkedText(_:selectedRange:)` / `unmarkText()` APIs so host text fields can render the system composing underline. Never manipulate host app text directly.
- **The globe key (`nextKeyboardButton`) is mandatory** — Apple requires third-party keyboards to provide a way to switch to the next keyboard. Its visibility is managed in `viewWillLayoutSubviews()` via `needsInputModeSwitchKey`.
- **`RequestsOpenAccess` is `true`** — required for features that rely on the shared App Group container, including main-app-managed feedback settings and diagnostics.
- **Composition-first deletion**: when `currentComposition` is non-empty, delete key removes from the pinyin buffer first. Only after composition is empty does it call `textDocumentProxy.deleteBackward()`.
- **Email keyboard type auto-switches to English mode** and shows `@`/`.` shortcut keys in the bottom row.
- **URL/webSearch keyboard type auto-switches to English mode** and shows `/`/`.com` shortcut keys in the bottom row.
- **Number and symbol pages are context-aware**: Chinese mode mirrors native Chinese symbol ordering with a `#+=` second-level symbol key, `123` return key, kaomoji placeholder entry (`^_^`), and a `拼音 / emoji / space / return` bottom row. English mode uses matching first/second-level symbol layouts with `English / emoji / space / return`.
- **Symbol-page one-shot input**: number/symbol pages use mode-specific one-shot whitelists. Chinese mode returns `currentPage` to `.letters` only for `；（）@“”。，、？！【】｛｝#%^*+=_\｜《》&·`; the ASCII period `.` and Chinese `‘` key are intentionally not one-shot in Chinese mode. English mode keeps half-width punctuation semantics, so `.` behaves as an English period and returns to letters. Digits and non-whitelisted symbols never auto-return. Left paired symbols (`（`, `“`, `【`, `｛`, `《` and English equivalents) insert both sides and move the cursor between them when `paired_symbol_completion_enabled` is enabled; the App Group-backed setting defaults to on and can be disabled from the main App settings. During active Chinese composition, ordinary punctuation first commits the first RIME candidate, then inserts the symbol/pair. The Chinese `‘` key is special: during composition it is sent to RIME as an ASCII apostrophe separator and returns to letters without committing; outside composition it remains a normal symbol and stays on the current symbol page. Emoji page insertion is separate and does not use this one-shot behavior.
- **Smart quote key on English number page**: the visible `”` key inserts `“` first, then `”`; once an open/close pair exists in the context, repeated presses insert `”` until both quotes are deleted from the context.
- **Dynamic page switch button** title: "123" on letters page, "#+=" on numbers page, emoji on symbols page, and "ABC" on emoji page.
- **Return key title** dynamically reflects `textDocumentProxy.returnKeyType` (return, search, go, send, etc.).
- **Shift double-tap** (within 0.35s) enters Caps Lock. Single tap cycles between off and single-use uppercase.
- **Double-space period** (within 0.45s) is enabled only in English mode with empty composition.
- **Auto-capitalization** applies at sentence start (after `.`, `!`, `?`, `。`, `！`, `？`) and on empty/new documents. It triggers when switching input mode to English (checks current text context) and after each delete operation (defensive check in `performDeleteBackward` in addition to `textDidChange`, because `UITextDocumentProxy.documentContextBeforeInput` can be stale when `textDidChange` fires). When switching back to Chinese mode, any active shift state (singleUse or capsLock) is automatically reset to off — auto-cap is explicitly English-mode-only.
- **Long-press letter keys** (0.3s) shows a popup with diacritic variants (e.g., a → à á â ä æ). 19 letters have variants. Selection follows finger position; releasing outside the popup cancels. Variants respect Shift state (uppercase/lowercase).
- **Feedback settings model**: key click and haptic feedback each use an independent enabled switch plus five discrete levels (`light`, `softer`, `normal`, `stronger`, `heavy`) stored as `key_click_level` / `haptic_level` values `1...5`. Current key click curve is `0.15 / 0.24 / 0.36 / 0.48 / 0.60`; current haptic curve is `0.35 / 0.5 / 0.65 / 0.82 / 1.0`. Legacy `key_click_volume` and `haptic_intensity` are migrated to the nearest level and kept for rollback compatibility.
- **Keyboard click sound** uses `KeyClickPlayer` — generates a native-style, low-profile click WAV in-memory via `ClickSoundGenerator`, played through `AVAudioPlayer`. Final Phase 1 generator parameters: 9ms duration, 1450Hz fundamental, 2900Hz harmonic at 0.075, noise range `±0.018`, 0.0006s attack ramp, `exp(-t / 0.0020)` decay, and 0.44 peak amplitude. Design principle: the click should be light, short, restrained, not sharp, not muffled, and should not dominate typing even at the heavy level. Dual-player architecture and async actor playback remain unchanged.
- **Feedback event model**: `KeyboardFeedbackEvent` separates `tap`, `modeEnter`, `repeat`, `commit`, and `preview`. Standard tap feedback remains touch-down based; candidate and variant selection use `commit`; space long-press emits one stronger `modeEnter` haptic when cursor movement mode actually begins; settings preview is handled by the main-app preview coordinator with same-level suppression and throttling.
- **Haptic feedback** uses `UIImpactFeedbackGenerator` with the five-level model above plus an independent `haptic_enabled` switch. The regular generator is pre-warmed in `viewDidLoad`; the space cursor mode-enter path uses a separate `.heavy` generator prepared at bootstrap.
- **Delete Repeat UX Phase 1.1**: long-press delete keeps the existing 0.5s delay and 0.08s repeat tick. The first touch-down still performs one delete with normal tap feedback. Repeat feedback is emitted only after a conservatively detected effective delete, using UI-layer signals (`currentComposition`, inline preedit count, or `documentContextBeforeInput`) rather than changing the KeyboardCore delete contract. Repeat click plays on the first effective repeat and every second effective repeat at `tapVolume * 0.60`; repeat haptic plays every fourth effective repeat at `max(0.25, tapIntensity * 0.7)`. Empty-field long press is silent after the first tap feedback.
- **Future Full Access onboarding**: full onboarding is intentionally deferred. Future options include TipKit, first-launch guidance, illustrated permission instructions, and a system Settings entry point. Phase 1 keeps only simple Full Access text because the main app cannot reliably query the keyboard extension's real-time Full Access state before the keyboard has run.
- **Candidate bar** uses `UICollectionView` for horizontal swipeless scrolling (`decelerationRate: .normal`, `alwaysBounceHorizontal` tied to `hasMoreCandidates`). With inline preedit, the candidate bar shows only candidates (the pinyin is already displayed in the text field). **No page buttons** — instead, accumulated candidates + near-edge auto-fetch (infinite scroll). New candidates are appended through `appendToCandidateBar()` while preserving scroll position. **Expanded panel**: flow layout (adaptive width + wrap), fills the keyboard content area, vertical infinite scroll with bottom-edge detection, collapse button floating top-right. `candidateItems()` returns accumulated candidates (or falls back to current RIME page). When RIME produces an empty composition, the preedit text is shown as a `.composition` item so users can commit raw pinyin.
- **Candidate rendering must stay independent from system button/material compositing**: `CandidateCollectionCell` renders candidates with a plain `UILabel` and an explicit highlighted background view. Do not reintroduce `UIButton.Configuration` for candidate text rendering unless real-device testing proves it does not create glass/material washout.
- **iOS 26+ scroll edge effect guard**: candidate `UICollectionView`s must use `CandidateScrollViewStyle.apply(to:)`. iOS 26 adds `UIScrollEdgeEffect` to scroll views; inside the system keyboard Liquid Glass container it can appear as a rectangular fade/overlay over the first candidate row. The helper hides all four edge effects, disables inset adjustment, and keeps the scroll view transparent. Do not add custom candidate fade masks or remove this guard without real-device verification.
- **Fuzzy pinyin typo correction must be benchmark-driven**: use `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionTests.swift` and `docs/TYPO_BENCHMARK.md` as the source of truth before changing correction rules, candidate ranking, or typo correction UI.
- **Typo correction must normalize real RIME preedit**: librime may expose segmentation spaces such as `ni h a p` or `ni hap`; typo matching and corrected-candidate lookup must operate on normalized pinyin.
- **RIME raw input and display preedit are separate contracts**: `RimeOutput.rawInput` is the unformatted input source for composition restoration, while `composition.preeditText` may contain display-oriented segmentation or selected Chinese segments.
- **Partial Commit must follow real librime selection semantics**: `selectCandidate` may return `committedText == nil` while `composition.preeditText` already contains the selected Chinese segment. Do not prepend confirmed text again when the preedit already starts with that segment.
- **Clean Partial Commit restore requires session rebuild**: `replaceInput(_:)` may preserve selected segmentation in librime. For a clean undo to the previous raw composition, reset the session and replay `RimeOutput.rawInput` instead of relying on `replaceInput` alone.
- **Typo correction Partial Commit is gated and original-input preserving**: the feature flag defaults off, so correction candidates keep full-commit behavior unless explicitly enabled. When enabled, Delete restore must replay the user's exact `originalInput`; continued composition uses the corrected RIME session and its remaining preedit/candidates. Repeated-final deletion, multi-edit/low-confidence corrections, missing corrected candidates, no-remaining-composition cases, and typo correction selected during an active Partial Commit must stay full commit. Intermediate-syllable typo correction (for example `nihapanpai -> nihaoanpai`) is future typo-engine expansion, not a Phase 3 bug. The current Delete restore behavior is accepted for this milestone and should not be optimized further until English input mode architecture is revisited.
- **Candidate selection references are production metadata**: normal RIME candidates carry page/index references and Partial Commit uses them to select the intended candidate. Correction, composition, placeholder, and fallback candidates must keep `selectionReference == nil`.
- **Inline preedit / marked text**: In Chinese mode, the active composition is displayed directly in the host text field as system marked text, producing the native composing underline. `KeyboardController` tracks `state.insertedPreeditText` / `state.insertedPreeditCount` and uses `updateInlinePreedit()` / `deleteInlinePreedit()` to replace or clear the current marked range. Partial Commit keeps the full visible composing display marked, including confirmed Chinese segments plus the remaining raw/preedit text (for example `你好mingtian` stays underlined until the whole composition is finalized). Candidate selection, direct text insertion, input-mode switch, and other final-commit paths call `commitInlinePreedit(as:)` to replace the marked range with committed text and then `unmarkText()`. Return uses `finishActiveCompositionAsRawInput()` for non-partial RIME composition so segmented display preedit like `ni h` commits as raw `nih` and clears the underline.
- **Long-press delete**: Touch-down immediately performs the first delete. After 0.5s, auto-repeat starts at 0.08s intervals (matching native iOS keyboard behavior).
- **Key click & haptic settings are cached** at the VC level on `viewDidLoad` (not read from `UserDefaults(suiteName:)` on every keypress, which would incur XPC overhead). Cache is invalidated via `UserDefaults.didChangeNotification` observer.
- **Layout extraction**: `reloadKeyboard()` and `reloadKeyboardContent()` share keyboard row construction through `addKeyboardRows(for:)`. No duplicated layout code.
- **iOS 26 native appearance**: key buttons use `KeyVisualStyle` enum for consistent styling (`.character`/`.function`/`.space`/`.returnKey`/`.active`). Dark/light mode custom colors for keyboard background, character keys, function keys, and highlighted state. Keys use `.continuous` corner curve with 9pt radius. The system now provides the outer rounded keyboard container; keep `view.backgroundColor` clear and avoid drawing a second large rounded surface inside the extension. Touch feedback uses instantaneous `backgroundColor` + `CGAffineTransform(scaleX: 0.96)` — no Core Animation transactions.
- Keyboard uses programmatic UIKit layout (UIStackView-based rows, no Storyboards) with current appearance geometry: `keyboardContentTopInset=2`, `keyboardContentBottomInset=0`, `keyHeight=45`, `candidateBarHeight=34`, `candidateToKeySpacing=8`, `keySpacing=8`, `keyboardGroupSpacing=10`, `keyHorizontalSpacing=6`, `thirdRowFunctionSpacing=10`, `primaryFunctionKeyWidth=46`, `functionKeySymbolPointSize=18`, horizontal margins `7`, `keyCornerRadius=9`. Horizontal candidate text uses 17pt for normal candidates and 15pt for composition fallback, with Dynamic Type capped at 28pt. Future UI changes must have a specific usability reason; avoid cosmetic tuning while the V1 UI freeze is active.
- **iPhone 17 final keyboard height may be 216pt** (vs. standard 250–268pt on iOS 26 non-adapted apps). Never use a fixed-height constraint larger than `viewHeight - bottomMargin`. The current approach — `view.alpha = 0` in `viewDidLoad` + height-triggered reveal in `viewDidLayoutSubviews` (guard: `height > 0 && height < 400`) — handles all device/OS height variations correctly.
- **`viewDidAppear` is the session recovery safety net.** After an app-switch, the RIME session may be lost. Always call `engine.resetSession()` and clear accumulated candidate state in `viewDidAppear` to guarantee a clean state before the next keystroke.

### RIME Deployment System

- **Main App deploy** (`SchemaManager.fetchAndDownload` → `deployRimeConfig()`): after installing rime_ice, the app calls the actor-isolated `RimeDeploymentService` package API. Its ObjC implementation runs full maintenance in the app process, so the keyboard starts with pre-built cache without owning the deployment boundary.
- **Main App settings** (Settings → RIME 方案设置): unified sub-page with schema picker, download UI, candidate count slider, simplification toggle, and deploy controls. The deploy action awaits main-app compilation and reports success before the user returns to the keyboard.
- **Keyboard Extension** (`viewDidLoad`): resolves already-prepared runtime directories and creates a session only. It does not write YAML, repair schemas, invalidate caches, or deploy while the keyboard is being presented.
- **Keyboard initialize** (`RimeSessionManager.initializeEngine`): lightweight only — `initialize(NULL)` followed by session creation over prepared runtime data. It performs no maintenance and writes no deployment or Lua capability preference state.
- **Deployment ownership**: the main App writes `.custom.yaml` and calls `RimeDeploymentService.deploy(.fullCheck)` before the user returns to the keyboard. `RimeEngineImpl.processKey` performs session input only; Extension recovery may recreate a session but must never run full maintenance.
- **OpenCC integration**: `simplifier` filter added to luna_pinyin schema with `opencc_config: opencc/t2s.json`. OpenCC configs + OCD2 dictionaries auto-deployed to `shared/opencc/`.
- **Traditional RIME fuzzy pinyin**: main-app settings write App Group flags for the master switch plus `zh/z`, `ch/c`, `sh/s`, and `n/l`. Full deployment post-processes only the active schema's `speller/algebra` managed block in `Rime/shared/{schema}.schema.yaml`; Keyboard Extension consumes compiled results and must not write schema YAML or block input for pending fuzzy deployment at runtime. This is separate from small-screen typo correction.
- **RIME user dictionary learning**: main-app settings own per-schema candidate-learning switches, `{schema}.userdb*` backup/restore/reset operations, manifest comparison, and optional automatic backups. The Keyboard Extension must not scan, hash, copy, restore, or back up user dictionary files while typing. The scalable UI pattern is a top-level scheme list plus per-scheme detail pages; full details live in `docs/RIME_USER_DICTIONARY.md`.
- **Diagnostics**: `Logger` (singleton, KeyboardCore) with levels (debug/info/warning/error), categories, 500-entry ring buffer. Writes to `rime_diag_log` via shared UserDefaults. Main app DiagnosticsView shows logs with animated refresh/clear buttons.

## Project Skills

- **`pre-push-review`** (`.claude/skills/pre-push-review/SKILL.md`): automated workflow — scans diff + runs `swift test` + reviews for .bak/.DS_Store + creates commit + pushes. Trigger with "push", "upload to GitHub", "ship it", "commit and push". Blocks on test failures or exclusion-pattern files.
